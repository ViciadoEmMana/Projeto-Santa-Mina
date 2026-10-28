// Usa as fontes isoladas pelo ImageGen; não toca nos pixels.
import fs from 'node:fs';
const pasta='assets/enemies/bandits/porrete';
const arquivo=pasta+'/porrete_animacoes.tres';
let texto=fs.readFileSync(arquivo,'utf8');
const fontes=['pares','impares'].map(nome=>JSON.parse(fs.readFileSync(`${pasta}/${nome}_regioes.json`,'utf8')));
if (!texto.includes('id="4"')) {
 texto=texto.replace('load_steps=32','load_steps=34');
 texto=texto.replace('[sub_resource type="AtlasTexture" id="Quadro_0"]', '[ext_resource type="Texture2D" path="res://'+pasta+'/porrete_ataque_pares_v01.png" id="4"]\n[ext_resource type="Texture2D" path="res://'+pasta+'/porrete_ataque_impares_v01.png" id="5"]\n\n[sub_resource type="AtlasTexture" id="Quadro_0"]');
}
for(let i=0;i<8;i++) {
 const [x,y,w,h,apoio]=fontes[i%2][Math.floor(i/2)];
 const regiao=`[sub_resource type="AtlasTexture" id="Quadro_${8+i}"]\natlas = ExtResource("${4+i%2}")\nregion = Rect2(${x-1}, ${y-1}, ${w+2}, ${h+2})\nmargin = Rect2(${320-(apoio-x+1)}, ${560-h-2}, ${638-w}, ${638-h})\nfilter_clip = true`;
 texto=texto.replace(new RegExp('\\[sub_resource type="AtlasTexture" id="Quadro_'+(8+i)+'"\\][\\s\\S]*?filter_clip = true'),regiao);
}
fs.writeFileSync(arquivo,texto);
console.log('Oito poses do golpe usam fontes com colunas alternadas vazias.');
