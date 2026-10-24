"""Build a self-contained, offline before/after review of movement skins.

Defaults to the original four; pass --walk-roster for the nine animate_roster_walk.py skins.
"""
import argparse
import base64
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parent.parent
KEYS = ('claude', 'deepseek', 'claude_b', 'deepseek_b')
WALK_KEYS = ('gpt', 'gemini', 'grok', 'qwen', 'llama', 'mistral', 'doubao', 'kimi', 'glm')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('output', type=Path)
    parser.add_argument('--before-ref', required=True)
    parser.add_argument('--walk-roster', action='store_true')
    args = parser.parse_args()
    entries = []
    for key in WALK_KEYS if args.walk_roster else KEYS:
        gamekey = key.replace('_b', 'chan_b') if key.endswith('_b') else key + 'chan'
        path = f'resources/gfx/characters/costumes/character_{gamekey}.png'
        old = subprocess.check_output(['git', 'show', f'{args.before_ref}:{path}'], cwd=ROOT)
        def data(raw):
            return 'data:image/png;base64,' + base64.b64encode(raw).decode('ascii')
        entries.append({'key': key, 'before': data(old), 'after': data((ROOT / path).read_bytes())})
    title = 'Roster walk cycles' if args.walk_roster else 'The original four, refined'
    lede = ('One stable body per direction with drawn legs, stride and bob.' if args.walk_roster
            else 'Selected portrait identities, clearer profiles, distinct firing faces and dedicated carrying bodies.')
    html = '''<!doctype html><meta charset="utf-8"><title>Original Character Art Review</title>
<style>
*{box-sizing:border-box}body{background:#10141e;color:#f1ede5;font:16px system-ui;margin:24px auto;max-width:1120px;padding:0 24px}h1{font-size:30px;margin-bottom:8px}p{color:#c5cbd8;line-height:1.5}button,select{font:inherit;background:#29354b;color:white;border:1px solid #697995;border-radius:8px;padding:9px;margin-right:8px}main{display:grid;grid-template-columns:1fr 1fr;gap:18px;margin-top:22px}article{background:#1c2433;border:1px solid #39435b;border-radius:14px;padding:16px}h2{margin:0 0 12px;font-size:20px}.pair{display:grid;grid-template-columns:1fr 1fr;gap:12px}figure{margin:0;text-align:center}canvas{width:100%;height:auto;image-rendering:pixelated;background:radial-gradient(ellipse at 50% 60%,#485069,#293246);border-radius:10px}figcaption{padding-top:8px;font-size:13px;color:#c5cbd8}footer{margin:24px 0;font-size:13px;color:#aeb9cb}@media(max-width:700px){main{grid-template-columns:1fr}}
</style><h1>TITLE</h1>
<p>LEDE<br>Offline movement preview only. Special poses, costumes and in-game motion still need acceptance.</p>
<select id="direction" aria-label="Direction"><option value="0">Front</option><option value="1">Right</option><option value="2">Rear</option><option value="3">Left</option></select>
<select id="action" aria-label="Action"><option value="walk">Walk</option><option value="fire">Fire while walking</option><option value="carry">Carry</option></select><button id="pause">Pause</button>
<main id="cards"></main><footer>Design credit: ZipZipPipe; DeepSeek also credits Shangshan Wuxing. Non-commercial derivatives. Built-in image tool artwork, mechanically packed into existing cells. This simplified preview uses the observed base player pivots; it does not simulate engine overlays, interpolation, weapons or game input.</footer>
<script>
const entries=DATA, names={claude:'Claude',deepseek:'DeepSeek',claude_b:'Tainted Claude',deepseek_b:'Tainted DeepSeek',gpt:'GPT',gemini:'Gemini',grok:'Grok',qwen:'Qwen',llama:'Llama',mistral:'Mistral',doubao:'Doubao',kimi:'Kimi',glm:'GLM'};
const views=[];
for(const e of entries){const card=document.createElement('article');card.innerHTML='<h2>'+names[e.key]+'</h2><div class="pair"></div>';cards.append(card);for(const which of ['before','after']){const f=document.createElement('figure'),c=document.createElement('canvas'),cap=document.createElement('figcaption');c.width=192;c.height=192;cap.textContent=which==='before'?'Previous atlas':'Revised atlas';f.append(c,cap);card.lastChild.append(f);const im=new Image();im.src=e[which];views.push({c,im});}}
let paused=false,tick=0,last=0;pause.onclick=()=>{paused=!paused;pause.textContent=paused?'Play':'Pause'};
function part(ctx,im,x,y,w,h,px,py,flip){ctx.save();ctx.translate(32,49);if(flip)ctx.scale(-1,1);ctx.drawImage(im,x,y,w,h,px,py,w,h);ctx.restore();}
function render(t){if(!paused&&t-last>85){tick++;last=t}const dir=Number(direction.value),act=action.value,n=tick%10,side=dir===1||dir===3,flip=dir===3,carry=act==='carry';for(const {c,im} of views){const ctx=c.getContext('2d');ctx.setTransform(1,0,0,1,0,0);ctx.clearRect(0,0,192,192);ctx.scale(3,3);ctx.imageSmoothingEnabled=false;let x,y;if(side){x=(n<8?n:n-8)*32;y=n<8?64:96}else{x=(n<8?n:n-2)*32;y=n<8?32:0}if(carry)x+=256;if(im.complete){part(ctx,im,x,y,32,32,-16,-23,flip);let head=side?2:dir===2?4:0;if(act==='fire'&&tick%4<2)head++;if(carry)part(ctx,im,256,128,64,64,-32,-49,false);else part(ctx,im,head*32,0,32,32,-16,-33,flip);}}requestAnimationFrame(render)}requestAnimationFrame(render);
</script>'''
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(html.replace('DATA', json.dumps(entries)).replace('TITLE', title).replace('LEDE', lede), encoding='utf-8')
    print(args.output)


if __name__ == '__main__':
    main()
