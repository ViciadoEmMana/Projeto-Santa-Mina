# Santa Mina — projeto Godot 4

**🎮 [JOGAR SANTA MINA HTML5 — LINK OFICIAL](https://viciadoemmana.github.io/Projeto-Santa-Mina/)**

A versão HTML5 oficial é mantida em `html5/principal/index.html`. Alterações aprovadas do autor e da colaboradora são integradas via pull request na branch `main` e publicadas automaticamente no mesmo link.

Repositório do **Santa Mina**, RPG tático de fantasia sombria com combate
em tabuleiro **3×6**, cartas e a minicampanha **O Covil de Tripa Seca**.

**Versão em desenvolvimento neste projeto: Godot 4.7.2, GDScript.**
O protagonista jogável atual é **Zeno, Humano Guerreiro**, com Espada de Ferro,
Escudo de Ferro e Madeira, 14 PV e 5 PA. Brokk permanece como legado interno.

## Abrir e jogar

1. Instale Godot **4.7.2** para usar a mesma versão da última validação.
2. Clone este repositório para uma pasta local.
3. No gerenciador de projetos do Godot, importe **project.godot**, na raiz.
4. Aguarde a importação das texturas e recursos.
5. Abra **Campanha.tscn** e pressione **F6** para jogar a minicampanha.

Outros pontos de entrada:

- **Combate.tscn + F6:** combate independente.
- **F5:** tabuleiro 3×6 original, preservado.
- **BrokkAnimacoes.tscn**, **ArqueiroAnimacoes.tscn**, **PorreteAnimacoes.tscn**
  e **InimigosAnimacoes.tscn:** mostruários visuais de desenvolvimento.
- **scenes/characters/Zeno.tscn:** componente visual do protagonista atual.

Não é necessário copiar a pasta .godot: o editor a recria a partir dos arquivos
versionados. Os arquivos .uid e .import, cenas, scripts, recursos e imagens-fonte
acompanham o projeto.

## Sistemas implementados

- Iniciativa 1d20 + DES efetiva, desempates e posicionamento inicial.
- Turnos, PA individuais, alcance, obstáculos e movimentação.
- Cinco cartas básicas permanentes, seleção de alvos e cancelamento com Esc.
- Dados 3D d4, d6, d8, d10, d12 e d20, com resultado visual sincronizado.
- Vantagem/Desvantagem, Defesa, escudo, condições e fogo amigo de arcos.
- Guerreiro: Físico Atlético, Mestre das Armas e Muralha de Ferro.
- Zeno: Veterano de Batalha e repetição própria da Espada de Ferro.
- IA ofensiva, sete inimigos e habilidades Golpe Sujo / Me Protejam! de Tripa Seca.
- Quatro capítulos, saques, inventário, alimentos, descansos e progressão.
- Salvamento local manual entre confrontos, backup e migração de saves antigos.
- Sprites e animações próprios, quatro cenários, efeitos, áudio e interface.

O projeto é um protótipo jogável em evolução. Cartas especiais completas,
exploração livre e história principal definitiva continuam como trabalho futuro.

## Documentação e histórico

- [Estado atual do projeto Godot e regras](docs/SANTA_MINA_GODOT.md)
- [Transição para Zeno, arquivos alterados e limites](docs/ATUALIZACAO_ZENO.md)
- [Campanha e regras dos inimigos](CAMPANHA.md)
- [Salvamento e compatibilidade](SALVAMENTO.md)
- [Interface e tabuleiro ampliado](INTERFACE_ARENA.md)
- [Histórico do desenvolvimento neste chat](docs/HISTORICO_DESENVOLVIMENTO.md)
- [Como continuar em dois computadores](docs/TRABALHAR_EM_DOIS_COMPUTADORES.md)
- [Comandos e referências recebidos](docs/referencias/README.md)
- [Créditos e origem dos assets](ASSET_CREDITS.md)

Os documentos de planejamento que já estavam no GitHub também foram preservados:
Documento Mestre 2026, GDD Universal e comando para IA. Eles não significam que
todas as funcionalidades planejadas estejam implementadas no Godot.

## Validação

A última execução completa registrada para a implementação Godot é de
**24/10/2026: 6.452 verificações automatizadas e 20 verificações renderizadas,
sem falhas finais**. Este número é histórico; publicar o repositório não equivale
a executar novamente a suíte.

No Windows, execute a partir da pasta do projeto:

    .\tools\validar_apresentacao.ps1 -Godot "C:\caminho\Godot_v4.7.2-stable_win64.exe"

Para uma captura nativa de Zeno:

    Godot --path . --script res://tests/capturar_zeno.gd

As capturas anteriores estão em tests/. A suíte usa slots temporários próprios
para os testes de salvamento.

## Materiais anteriores preservados

O repositório já continha um **protótipo HTML5 separado**. Seu código em html5/,
o index.html da raiz, o ZIP em releases/ e as imagens em screenshots/ foram
mantidos. O projeto Godot abre por project.godot; esses arquivos web não
substituem a implementação Godot.

O README e o GDD Godot anteriores à consolidação foram arquivados em
docs/referencias/github_antes_importacao/, além de permanecerem no histórico Git.

O diretório Assets 32 rogues é material legado preservado com seus créditos.
Ele não é usado como base para a arte atual. Os recursos e relatórios de Brokk
também permanecem para histórico e regressões.

## Limites atuais

- A ilustração oficial de Zeno mencionada pelo usuário ainda está pendente;
  o visual integrado é provisório e usa arte própria gerada.
- A ativação defensiva de Veterano por bloqueio automático apenas com escudo,
  sem a ação Defender, aguarda definição. Defender sem dano já está integrado.
- Não existe uma ação de esquiva completa: a integração do talento está preparada.
- O teste físico pelo Computer Use ficou pendente por expiração da autorização;
  houve validação no renderizador nativo com eventos enviados à entrada do Godot.
- Saves de campanha são locais, em user://; não acompanham automaticamente o Git.
- Cache do editor, configurações privadas e backups automáticos de atualização
  do plugin Godot AI ficam fora do versionamento. O código ativo do addon permanece.

## Créditos

Consulte ASSET_CREDITS.md e as licenças presentes junto aos materiais.
Nenhuma licença geral de redistribuição do projeto foi estabelecida.

---

## 🗂️ Organização do repositório

> **Versão principal de testes no navegador: [🎮 Santa Mina HTML5 V8](html5/principal/index.html).**
> O arquivo HTML5 principal fica exclusivamente em `html5/principal/`.

| Ícone | Pasta | Para que serve |
|:---:|---|---|
| 🎮 | [html5/principal](html5/principal/) | **Jogo principal V8** — um único HTML para abrir no navegador |
| 🗃️ | [html5/versoes](html5/versoes/) | Entradas antigas preservadas como histórico |
| 📖 | [html5/docs](html5/docs/) | Documentação da versão de navegador |
| 🎨 | [assets](assets/) | Personagens, cenários, cartas e imagens do projeto Godot |
| 🔊 | [audio](audio/) | Áudios e efeitos |
| 🕹️ | [scenes](scenes/) | Cenas Godot |
| ⚙️ | [scripts](scripts/) | Código GDScript auxiliar |
| 🧪 | [tests](tests/) | Testes do projeto |
| 📚 | [docs](docs/) | Documentação geral e referências |
| 📦 | [releases](releases/) | Entregas anteriores |
| 📷 | [screenshots](screenshots/) | Capturas de tela |
| 🧩 | [addons](addons/) | Extensões do Godot |
| 🧰 | [tools](tools/) | Ferramentas auxiliares |
| 🧱 | [Assets 32 rogues](Assets%2032%20rogues/) | Pacotes de arte originais, mantidos no caminho atual |

**Observação:** os emojis são utilizados neste índice, sem renomear os diretórios Godot existentes, para não quebrar referências de cenas e assets. `index.html` na raiz e `html5/index.html` são redirecionamentos; o jogo V8 está apenas em `html5/principal/index.html`.
