// Migração pontual da apresentação: um controlador compartilhado, sem regras.
import fs from 'node:fs';
const arquivo = 'scripts/presentation/porrete_visual.gd';
let base = fs.readFileSync(arquivo, 'utf8');
if (!base.startsWith('extends Sprite2D')) throw new Error('Migração já aplicada; não executar novamente.');
base = base.replace('## Somente apresentação do bandido humano. Não calcula dano, PA ou rolagens.', '## Apresentação compartilhada dos inimigos originais. Não calcula PV, PA ou RNG.');
base = base.replace('signal impacto\n', 'signal impacto\nsignal soltura\n');
base = base.replace(/const QUADROS = .*\nconst ESCALA_ACOES := .*\nconst ESCALA_ATAQUE := .*\nconst ESCALA_REACOES := .*\n/, '@export var quadros: SpriteFrames\n@export var identidade_visual: StringName = &"inimigo_original"\n@export var projetil := false\n@export var escala_acoes := 0.185\n@export var escala_ataque := 0.178\n@export var escala_reacoes := 0.206\n');
base = base.replace('set_meta("porrete_original", true)', 'set_meta(identidade_visual, true)\n\tset_meta("inimigo_original", true)');
base = base.replace('"AnimacaoPorrete"', '"AnimacaoInimigo"').replace('animacao.sprite_frames = QUADROS', 'animacao.sprite_frames = quadros');
base = base.replace('var escala := ESCALA_REACOES if nome in [&"dano", &"morte"] else (ESCALA_ATAQUE if nome == &"ataque" else ESCALA_ACOES)', 'var chave := "escala_reacoes" if nome in [&"dano", &"morte"] else ("escala_ataque" if nome == &"ataque" else "escala_acoes")\n\tvar padrao := escala_reacoes if nome in [&"dano", &"morte"] else (escala_ataque if nome == &"ataque" else escala_acoes)\n\tvar escala: float = quadros.get_meta(chave, padrao)');
base = base.replace('animacao.frame == 4:', 'animacao.frame == int(quadros.get_meta("quadro_impacto", 4)):');
base = base.replace('\t\timpacto.emit()\n\nfunc _terminar', '\t\timpacto.emit()\n\t\tif projetil:\n\t\t\tsoltura.emit()\n\nfunc _terminar');
base = base.replace('\t\t\timpacto.emit()\n\t\tmorte_em', '\t\t\timpacto.emit()\n\t\t\tsoltura.emit()\n\t\tmorte_em');
base += '\nfunc animar_disparo_ate_soltura() -> void:\n\tawait animar_golpe_ate_impacto()\n\nfunc origem_disparo() -> Vector2:\n\treturn position + Vector2(28 if animacao.flip_h else -28, -14)\n';
fs.writeFileSync('scripts/presentation/inimigo_visual.gd', base);
fs.writeFileSync(arquivo, 'extends "res://scripts/presentation/inimigo_visual.gd"\n## Configuração visual do humano; o comportamento comum fica no componente base.\nconst QUADROS = preload("res://assets/enemies/bandits/porrete/porrete_animacoes.tres")\nconst ESCALA_ACOES := 0.185\nconst ESCALA_ATAQUE := 0.178\nconst ESCALA_REACOES := 0.206\n\nfunc _init() -> void:\n\tquadros = QUADROS\n\tidentidade_visual = &"porrete_original"\n');
console.log('Controlador visual compartilhado criado; ficha e resolvedor preservados.');
