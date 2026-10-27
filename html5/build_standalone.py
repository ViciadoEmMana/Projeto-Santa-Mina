"""Build a fully offline, single-file Santa Mina HTML game."""
from pathlib import Path
import base64, re, json
p=Path(__file__).parent
html=(p/'index.html').read_text()
css=(p/'game.css').read_text()
js=(p/'game.js').read_text()
assets={}
for f in sorted((p/'assets').iterdir()):
 if f.suffix in ('.png','.jpg'):
  mime='image/png' if f.suffix=='.png' else 'image/jpeg'
  assets[f.stem]=f'data:{mime};base64,'+base64.b64encode(f.read_bytes()).decode()
css=css.replace('url(assets/floresta.jpg)','url('+assets['floresta']+')')
js=js.replace("i.src=`assets/${n}.${['floresta','mata','passagem','covil'].includes(n)?'jpg':'png'}`", "i.src=ASSETS[n]")
js=js.replace('src="assets/${e.sprite}.png"','src="${ASSETS[e.sprite]}"')
html=html.replace('<link rel="stylesheet" href="game.css">','<style>'+css+'</style>')
html=html.replace('src="assets/brokk.png"','src="'+assets['brokk']+'"')
html=html.replace('<script src="game.js"></script>','<script>const ASSETS='+json.dumps(assets,ensure_ascii=False)+';</script>\n<script>'+js+'</script>')
output=Path('/mnt/data/Santa_Mina_Teste_HTML5.html')
output.write_text(html)
print(output, output.stat().st_size, 'bytes')
