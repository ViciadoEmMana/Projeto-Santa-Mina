// Só monta recursos Godot a partir de inspeções alfa. Nunca modifica imagens.
import fs from 'node:fs';
const perfil = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
for (const item of perfil) {
  const acoes = JSON.parse(fs.readFileSync(item.pasta + '/acoes_regioes.json', 'utf8'));
  const reacoes = JSON.parse(fs.readFileSync(item.pasta + '/reacoes_regioes.json', 'utf8'));
  if (acoes.length !== 12 || reacoes.length !== 12) throw new Error(item.id + ': esperados 12 quadros por fonte.');
  const gesto = item.gesto ? JSON.parse(fs.readFileSync(item.pasta + '/gesto_regioes.json', 'utf8')) : [];
  if (item.gesto && gesto.length !== 4) throw new Error('Reação do chefe exige quatro quadros.');
  const fontes = item.gesto ? [acoes, reacoes, gesto] : [acoes, reacoes];
  const escala = item.altura / acoes[0][3];
  const escalaReacao = item.altura / reacoes[3][3];
  const frames = fontes.flatMap((lista, fonte) => lista.map((r, i) => {
    const [x,y,w,h,apoio] = r;
    const ancora = fonte === 2 && item.apoios_gesto ? item.apoios_gesto[i] : (fonte === 1 && i >= 8 ? x+w/2 : apoio);
    return {fonte:fonte+1,x:x-1,y:y-1,w:w+2,h:h+2,mx:320-(ancora-x+1),my:560-h-2};
  }));
  let texto = `[gd_resource type="SpriteFrames" load_steps=${frames.length+fontes.length+1} format=3]\n`;
  (item.gesto ? ['acoes','reacoes','gesto'] : ['acoes','reacoes']).forEach((nome,i) => texto += `\n[ext_resource type="Texture2D" path="res://${item.pasta}/${item.id}_${nome}_fonte_${nome === 'acoes' ? (item.versao_acoes || 'v01') : 'v01'}.png" id="${i+1}"]\n`);
  frames.forEach((r,i) => {
    if (r.mx < 0 || r.my < 0) throw new Error(item.id + ': margem negativa ' + i);
    texto += `\n[sub_resource type="AtlasTexture" id="Q${i}"]\natlas = ExtResource("${r.fonte}")\nregion = Rect2(${r.x}, ${r.y}, ${r.w}, ${r.h})\nmargin = Rect2(${r.mx}, ${r.my}, ${640-r.w}, ${640-r.h})\nfilter_clip = true\n`;
  });
  const animacoes = [['idle',4,true,0,4], ['caminhar',8,true,4,4], ['ataque',8,false,8,4], ['dano',12,false,12,4], ['morte',10,false,16,8]];
  if(item.gesto) animacoes.push(['reacao',10,false,24,4]);
  texto += '\n[resource]\nanimations = [' + animacoes.map(([nome,fps,loop,inicio,n]) => `{"name": &"${nome}", "speed": ${fps}.0, "loop": ${loop}, "frames": [${Array.from({length:n},(_,i)=>`{"duration": 1.0, "texture": SubResource("Q${inicio+i}")}`).join(', ')}]}`).join(',\n') + ']\n';
  texto += `metadata/escala_acoes = ${escala}\nmetadata/escala_ataque = ${escala}\nmetadata/escala_reacoes = ${escalaReacao}\nmetadata/quadro_impacto = 2\n`;
  if(item.gesto) texto += `metadata/escala_reacao = ${item.altura/gesto[0][3]}\n`;
  fs.writeFileSync(item.pasta + '/' + item.id + '_animacoes.tres', texto);
  fs.writeFileSync('scenes/characters/' + item.cena + '.tscn', `[gd_scene load_steps=3 format=3]\n\n[ext_resource type="Script" path="res://scripts/presentation/inimigo_visual.gd" id="1"]\n[ext_resource type="SpriteFrames" path="res://${item.pasta}/${item.id}_animacoes.tres" id="2"]\n\n[node name="${item.cena}" type="Sprite2D"]\nscript = ExtResource("1")\nquadros = ExtResource("2")\nidentidade_visual = &"${item.id}_original"\nprojetil = ${!!item.projetil}\n`);
  console.log(item.id + ': ' + frames.length + ' quadros, altura ' + item.altura + ' px.');
}
