# Charm reactions after ordinary shields

W3 F9, 2026-10-27. Baseline 7380715 reproduces a shield-order defect in You're Absolutely Right!: a supplied ordinary bullet is blocked by Sold Out, yet the shooter has already received charm and the reaction caption. The regression uses real charm, Constitution, backlog common, Sold Out and Red Stamp modules. This is offline callback evidence, not native health/status timing or gameplay acceptance.

## Correction and preserved behavior

The charm callback now uses `CallbackPriority.LATE`, after the ordinary-priority backlog shields that main.lua registers later. Its player filter, source resolution, non-boss/non-friendly eligibility, 150-frame duration, owner attribution, caption and nil return remain unchanged. There is no additional state, flag exclusion, priority change to another module, save migration or numeric balance change.

The [API callback reference](https://wofsauge.github.io/IsaacDocs/rep/enums/ModCallbacks.html#mc_entity_take_dmg) describes a pre-damage hook and warns that any non-nil return stops later callbacks. The fixture models that rule with stable registration order and the documented [priority values](https://wofsauge.github.io/IsaacDocs/rep/enums/CallbackPriority.html). It does not infer final health loss from reaching the callback.

The earlier F9 audit treated missing fake/no-penalty filters as a candidate issue. The [damage-flag reference](https://wofsauge.github.io/IsaacDocs/rep/enums/DamageFlag.html) describes fake damage as triggering player damage effects, and no-penalty damage as avoiding penalties. This beneficial charm effect cannot inherit Risk/Vibe's penalty exclusions automatically. Existing flag behavior is retained; any different eligibility rule needs a concrete owner decision.

## Offline evidence

[absolutely_right_damage_test.lua](../tests/absolutely_right_damage_test.lua) preserves the three services' relative main.lua registration order and dispatches filters, priority and first-non-nil results. It runs the cases with a charm stub that only records the effect, then with one that also sets the friendly flag. The baseline failure already occurs in the first model, so it does not depend on assuming immediate native flag changes.

| Scenario | Supplied outcome checked |
|---|---|
| Sold Out | The guarded bullet is removed, exactly one guard is spent, and no charm/caption occurs; the next unguarded hit charms normally. |
| Red Stamp | Stamped contact is blocked for either holder without charm; contact after the supplied expiry can charm. |
| Two owners | One holder's guard does not absorb the other holder's hit; charm attribution stays with the hit holder. |
| Constitution plus Sold Out | The Constitution block preserves the bullet guard, the subsequent bullet consumes it, and an ordinary hit after both shields still charms. |
| Ordinary contact/projectile | Source, owner, duration, caption and nil return remain; bosses, friendly sources, non-holders and missing sources do not react. |
| Existing flag behavior | Supplied eligible enemy sources retain their existing fake, no-penalty, combined, IV Bag and red-heart flag reactions. These inputs are not claims about native self-damage source attribution. |
| Dispatch limits | An earlier false prevents charm; an earlier true also ends dispatch; a supplied veto after LATE can still happen after charm. |

The baseline passes ordinary, flag and limit groups but fails the shield group. The candidate passes all groups in both status models. Four syntactically valid faulty copies fail assertions: default priority, a new fake/no-penalty exclusion, an omitted reaction and a changed duration. Existing suites/assertions are unchanged.

The full gate passes 73 Lua suites, 11 scanner cases, 13 item-art groups and six thumbnail groups, with 190 tracked Lua files, five XML files, assets/poses, all ten art sheets and the refreshed interaction inventory. Only the charm production module changes. All 208 art paths, tooling, XML, item text, balance values and save formats remain unchanged.

## Open acceptance

This correction covers blockers that run before the late observer. It cannot observe a later veto, an earlier non-nil allow, native invulnerability decisions or status immunity as final health loss. Other F9 reactions, including Disgrace Loop, retain their separate unresolved cases. No blanket fake/self-damage policy is introduced.

During a future authorized engine window, combine the item with Sold Out, Red Stamp and Constitution, observe health/guard/charm/caption separately, then repeat unguarded contact/projectiles and two-owner cases. Check native flags, actual charm timing, immunity, external blockers and representative special-player forms. Installed 8fd6a8c remains owner-untried and untouched; no runtime/game/settings/save access occurs in this unit. All broad item/character completion rows stay open.
