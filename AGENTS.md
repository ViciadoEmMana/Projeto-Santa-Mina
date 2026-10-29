# Instruções para assistentes de IA (Codex/GPT, Claude e outros)

Este repositório tem duas pessoas trabalhando, cada uma com o seu assistente:
- **Gabriel (ViciadoEmMana):** regras, jogabilidade e projeto Godot, com o ChatGPT/Codex.
- **Parceira de design (luudalmeid-ops):** visual do HTML5, com o Claude.

## Regra obrigatória — jogo HTML5 oficial e link único

- **Endereço público oficial, permanente:** https://viciadoemmana.github.io/Projeto-Santa-Mina/
- **Fonte única do jogo:** `html5/principal/index.html` na branch `main`. **Não criar outro HTML principal nem mudar a URL pública a cada versão.**
- **Toda alteração solicitada por Gabriel ou pela colaboradora de design deve ser integrada nesse mesmo arquivo**, respeitando as áreas de responsabilidade e preservando as mecânicas aprovadas. Uma mudança não publicada no `main` ainda não faz parte da versão oficial.
- **Fluxo obrigatório:** atualizar o ramo a partir de `main` → alterar a fonte oficial → testar → abrir pull request → revisar/mesclar → confirmar que GitHub Pages publicou → testar o endereço público oficial.
- **Publicação:** o GitHub Actions publica `html5/`; `html5/index.html` encaminha para `principal/index.html`. Assim a URL de entrada permanece fixa mesmo que o navegador seja redirecionado para `/principal/`.
- **Ao entregar ao usuário:** fornecer sempre o link direto para jogar no navegador e, quando solicitado, o arquivo HTML baixável da mesma versão publicada.
- **Registro:** alterações visuais em `html5/MUDANCAS_DESIGN.md`; alterações de regras na documentação. Documentação e arquivos auxiliares não substituem o arquivo principal.
- Se a implantação falhar, avisar explicitamente; **não afirmar que o link já foi atualizado sem confirmar a publicação**.

## Antes de mexer no HTML5
- **Leia `html5/MUDANCAS_DESIGN.md`.** Ali está o que mudou no visual e por quê. Não desfaça essas mudanças sem combinar.
- **Base do HTML5:** a versão oficial é `html5/principal/index.html`. As pastas `html5/versoes/` são só histórico.

## Ao entregar mudanças
- **Trabalhe num ramo próprio e abra um pull request.** Não envie direto para `main`.
- **Mudanças de design:** acrescente uma entrada no topo de `html5/MUDANCAS_DESIGN.md`, dizendo o que mudou, por que e onde mexer.
- **Mudanças de regra:** registre no README ou na documentação correspondente.
