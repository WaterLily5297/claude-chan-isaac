"""Source-scanner regressions; these do not simulate Isaac callbacks."""
import importlib.util
from pathlib import Path
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('interaction_audit', ROOT / 'tools/audit_interactions.py')
audit = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = audit
spec.loader.exec_module(audit)


class InteractionAuditTest(unittest.TestCase):
    def scan(self, source, path='scripts/example.lua'):
        return audit.scan_module(path, source)

    def test_comments_strings_and_comparisons_are_not_writers(self):
        result = self.scan('''-- player.Damage = 999
--[=[ mod:AddCallback(ModCallbacks.BAD, function() end) ]=]
local text = "player.Luck = 99 -- not a comment"
local block = [==[Risk.state.fake = {}; tear.Color = nil]==]
if player.Damage == 9 then return end
player.Damage = player.Damage + 1
''')
        self.assertEqual(len(result['writes']), 1)
        self.assertEqual(result['writes'][0]['line'], 6)
        self.assertEqual(result['writes'][0]['mode'], 'self-dependent')
        self.assertEqual(result['callbacks'], [])
        self.assertEqual(result['state'], [])

    def test_callback_priorities_and_multiline_arguments(self):
        result = self.scan('''mod:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE, function() end)
mod:AddPriorityCallback(ModCallbacks.MC_POST_FIRE_TEAR,
    CallbackPriority.LATE, function() end)
mod:AddCallback("Custom:Probe", function() end)
mod:AddPriorityCallback(callback, priority + 1, handler)
''')
        self.assertEqual([(r['callback'], r['priority']) for r in result['callbacks']], [
            ('ModCallbacks.MC_EVALUATE_CACHE', 'default'),
            ('ModCallbacks.MC_POST_FIRE_TEAR', 'CallbackPriority.LATE'),
            ('"Custom:Probe"', 'default'), ('callback', 'priority+1')])

    def test_write_modes_and_multiline_expression(self):
        result = self.scan('''player.Damage = player.Damage *
    factor
player.MoveSpeed = math.max(0.1,
    player.MoveSpeed - delta)
tear.CollisionDamage = parent.CollisionDamage
laser.CollisionDamage = 0
player["Luck"] = 1
player.MoveSpeed = speed
tear.TearFlags = tear.TearFlags | TearFlags.TEAR_HOMING
''')
        self.assertEqual([w['mode'] for w in result['writes']], [
            'self-dependent', 'self-dependent', 'indirect', 'literal', 'literal',
            'indirect', 'self-dependent'])
        self.assertIn('factor', result['writes'][0]['rhs'])
        self.assertIn('player.MoveSpeed-delta', result['writes'][1]['rhs'])
        self.assertEqual(result['writes'][4]['field'], 'Luck')

    def test_state_access_distinguishes_writes_reads_and_dynamic_roots(self):
        result = self.scan('''local all = Risk.state.backlog
Risk.state.backlog = all
Risk.state["rice"] = {}
Risk.state[key] = migrated
Risk.state = nextState
self.state.risk = 9
''')
        self.assertEqual([(s['key'], s['access']) for s in result['state']], [
            ('backlog', 'read/alias'), ('backlog', 'direct write'),
            ('rice', 'direct write'), ('[dynamic]', 'direct write'),
            ('[whole table]', 'direct write')])
        risk = self.scan('self.state.risk = 9', 'scripts/risk.lua')
        self.assertEqual(risk['state'][0]['key'], 'risk')

    def test_cache_flags_and_mutator_calls_are_visible(self):
        result = self.scan('''local flag = CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_SPEED
tear:AddTearFlags(TearFlags.TEAR_HOMING)
player:SetColor(color, 1, 0, false, false)
''')
        self.assertEqual(result['cache_flags'], ['CACHE_DAMAGE', 'CACHE_SPEED'])
        self.assertEqual([m['method'] for m in result['mutators']], ['AddTearFlags', 'SetColor'])

    def test_dynamic_field_and_multiple_target_assignment_are_disclosed(self):
        result = self.scan('''player[field] = value
player.Damage, player.Luck = 2, 3
''')
        self.assertTrue(any('dynamic field' in item for item in result['limitations']))
        self.assertTrue(any('multiple assignment' in item for item in result['limitations']))
        self.assertEqual([w['field'] for w in result['writes']], ['Damage', 'Luck'])
        self.assertTrue(all(w['mode'] == 'multiple-target; manual mapping' for w in result['writes']))

    def test_similar_field_names_do_not_imply_self_dependency(self):
        result = self.scan('''p.Damage = p.DamageBonus
p.Damage = other.p.Damage
''')
        self.assertEqual([w['mode'] for w in result['writes']], ['indirect', 'indirect'])

    def test_unterminated_lexical_regions_fail_explicitly(self):
        for source in ['--[=[ missing', 'local s = "missing', 'local s = [[missing']:
            with self.assertRaises(ValueError):
                self.scan(source)

    def test_overlap_is_a_candidate_and_report_is_deterministic(self):
        modules = [self.scan('p.Damage = p.Damage + 1', 'scripts/a.lua'),
                   self.scan('p.Damage = p.Damage * 2', 'scripts/b.lua')]
        report = audit.render_report(modules)
        self.assertIn('Candidate overlaps', report)
        self.assertIn('Damage', report)
        self.assertEqual(report, audit.render_report(list(reversed(modules))))

    def test_checked_report_detects_stale_source_and_preserves_manual_prose(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / 'scripts').mkdir()
            (root / 'docs').mkdir()
            (root / 'main.lua').write_text('-- entry\n', encoding='utf-8')
            (root / 'scripts/a.lua').write_text('p.Damage = p.Damage + 1\n', encoding='utf-8')
            doc = root / 'docs/INTERACTIONS.md'
            doc.write_text('Review remains manual.\n' + audit.BEGIN + '\nold\n' + audit.END + '\n', encoding='utf-8')
            audit.update_report(root, check=False)
            before = doc.read_bytes()
            audit.update_report(root, check=True)
            self.assertEqual(before, doc.read_bytes())
            self.assertTrue(before.startswith(b'Review remains manual.'))
            (root / 'scripts/a.lua').write_text('p.Damage = 0\n', encoding='utf-8')
            with self.assertRaisesRegex(ValueError, 'stale'):
                audit.update_report(root, check=True)

    def test_tungsten_indirect_write_is_not_called_a_confirmed_overwrite(self):
        source = (ROOT / 'scripts/items/tungsten_cube.lua').read_text(encoding='utf-8')
        result = self.scan(source)
        speed = [w for w in result['writes'] if w['field'] == 'MoveSpeed']
        self.assertEqual(len(speed), 1)
        self.assertEqual(speed[0]['mode'], 'indirect')
        self.assertNotIn('confirmed', speed[0]['mode'])


if __name__ == '__main__':
    unittest.main()
