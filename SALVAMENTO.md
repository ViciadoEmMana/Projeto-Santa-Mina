# Santa Mina — salvamento local da minicampanha

Atualização de 24/10/2026: Zeno, Humano Guerreiro, é o protagonista atual.
O formato JSON v2 usa a seção `heroi` com sua identidade. Saves v1 com a seção
legada `brokk` são migrados em memória ao carregar, preservando progresso,
inventário, PV, habilidades gastas e débitos. O slot continua no mesmo caminho.
A arma padrão passa a ser a Espada de Ferro; armas explicitamente equipadas são
preservadas. Veterano não restaura bônus de um confronto encerrado.

## Como usar

1. Abra `Campanha.tscn` no Godot 4 e pressione **F6**.
2. Fora do confronto, clique em **Salvar**, no canto superior direito.
3. Feche e abra a cena quando quiser. Clique em **Carregar** para retomar.
4. Continue pelo botão **Iniciar confronto** ou **Próximo capítulo**, conforme
   a fase que foi salva.

Existe **um slot manual**. Salvar novamente substitui esse slot, conservando uma
cópia da gravação válida anterior. Não há gravação automática nem carga automática
ao abrir a cena. **Reiniciar** cria uma campanha em memória e preserva o slot em
disco; somente um novo **Salvar** substitui o progresso gravado.

Salvar/carregar fica indisponível durante o confronto, inclusive no combate
original independente. A proteção também existe nos callbacks e no formato do
save. Esta etapa não serializa iniciativa pendente, dados em movimento, inimigos
de um confronto ativo ou decisões de reação.

## Dados preservados

- Capítulo, fase de preparação/vitória/final/derrota, local e turno de exploração.
- Histórico de recompensas, com chaves inteiras reconstruídas; carregar uma
  vitória não gera loot novamente. Equipamentos guardados e Porção Comum ficam
  no inventário, sem equipar ou conceder efeitos automaticamente.
- PV atuais, usos de Mestre das Armas/Muralha, PA e débitos pendentes, condições
  e fontes de Vantagem/Desvantagem.
- Arma canônica equipada e presença do escudo. Não foi criada uma nova tela de
  troca de equipamento.
- Mantimentos, equipamentos guardados, itens especiais e coroas, sem reposição
  das provisões iniciais ao carregar.
- Efeitos alimentares, duração restante, PV temporários restantes, relógio e
  configuração de movimento. Efeitos expirados não voltam.

Atributos permanentes, PV máximos, PA máximos, regras das armas e bônus de
alimentos vêm das fichas e catálogos existentes. O JSON guarda identificadores e
estado; não carrega objetos, cenas ou scripts indicados pelo arquivo.
Defesas derivadas são recalculadas. Carregar não é um descanso e não renova usos,
cura PV ou remove débitos.

## Arquivo e falhas de gravação

Slot: `user://campanha_v1.json`, na pasta de dados de usuário do Godot para
Santa Mina. Cópia anterior: `campanha_v1.json.bak`. Gravação intermediária:
`campanha_v1.json.tmp`. Esses arquivos não ficam na pasta de código do projeto.

O serviço valida o estado, grava e confere o temporário, conserva o save válido
anterior e substitui o principal por renomeação. Falhas de abertura, conferência,
cópia ou renomeação retornam uma mensagem sem afirmar sucesso. Um temporário
interrompido não é tratado como save completo.

Ao carregar, valida versão, tipos, limites, capítulos, histórico, equipamentos e
alimentos antes de construir uma nova campanha. Um arquivo principal ilegível
ou inválido permite recuperar a cópia anterior válida, com aviso na interface.
Se nenhum arquivo for válido, a instância atual permanece intacta.
Não há promessa de proteção contra falhas físicas do disco nem contra edição
manual deliberada de valores válidos. A migração aceita v1; outras versões não
reconhecidas continuam sendo rejeitadas.

## Arquivos desta etapa

Novos:

- `salvamento_campanha.gd`: serialização, validação, leitura/gravação e backup.
- `tests/teste_salvamento.gd`: round-trip em disco, fases, alimentos, equipamentos,
  descansos, entradas inválidas, backup, input real e combate retomado.
- `tests/teste_salvamento_processos.gd`: grava e lê em dois processos Godot
  separados, com o primeiro encerrado antes da segunda execução.
- `tests/capturar_salvamento.gd` e cinco PNGs `tests/salvamento_*.png`.
- Este relatório; metadados do Godot, quando gerados.

Modificados:

- `tela_campanha.gd`: botões Salvar/Carregar, mensagens e proteção durante encontro.
- `tools/validar_apresentacao.ps1`: acrescenta as verificações desta etapa.
- `CAMPANHA.md` e `docs/SANTA_MINA_GODOT.md`: estado atual da persistência.

`sistema_campanha.gd`, fichas, regras, `Combate.tscn`, `combate.gd`, sprites,
sons e animações não precisaram de alterações. Os hashes de `tabuleiro.gd`,
`cena_principal.tscn` e `project.godot` continuam sendo conferidos pelo validador.
F5 continua abrindo o tabuleiro original.

## Validação

Godot 4.7.2: **5.080 verificações automatizadas, zero falhas**, nesta execução:

| Conjunto | Verificações | Falhas |
| --- | ---: | ---: |
| Dez suítes anteriores de combate/campanha/apresentação | 4.314 | 0 |
| Salvamento, validação, UI e confronto retomado | 758 | 0 |
| Dois processos separados: gravação e leitura | 8 | 0 |
| **Total automatizado** | **5.080** | **0** |
| Captura renderizada adicional (cinco PNGs) | 19 | 0 |

Execute no PowerShell, a partir do projeto:

```powershell
./tools/validar_apresentacao.ps1 -Godot 'caminho/para/Godot.exe'
```

Os testes usam slots isolados na pasta temporária do sistema, sem tocar no
save real do jogador. O validador exige saída explícita, zero falhas, ausência de
erros de GDScript e os hashes originais. Logs também ficam no temporário do SO.

A suíte nova inclui retomada de um confronto real no capítulo II: iniciativa,
posicionamento, débito de 1 PA descontado uma vez, habilidade ainda usada,
ataque natural 2 + FOR 4 − Defesa 2 = 4, custo de 3 PA e visual original de Sucata.
A campanha inteira com quatro vitórias continua na suíte de regressão existente.

Para repetir as capturas com renderizador:

```text
Godot --path . --script res://tests/capturar_salvamento.gd
```

São cinco imagens reais: gravação, reabertura, carga, 1280×720 e 864×648.
As capturas usam fixture de preparação no capítulo II, com Brokk em 9 PV e
habilidades gastas; os botões recebem eventos de mouse pelo Viewport.
O teste renderizado concluiu 19 verificações, zero falhas. Imagens inspecionadas
em 960×540, 1280×720 e 864×648, com texto e controles dentro da área visível.

Os avisos ambientais conhecidos de certificado Windows, editor_settings e
fallback ANGLE não são erros dos scripts do jogo.
