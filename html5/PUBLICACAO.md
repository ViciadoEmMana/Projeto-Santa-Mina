# 🎮 Link fixo para jogar Santa Mina

**Endereço oficial e fixo do jogo:** https://viciadoemmana.github.io/Projeto-Santa-Mina/

**Regra do projeto:** todas as alterações aprovadas solicitadas por Gabriel ou pela colaboradora devem chegar ao mesmo arquivo `html5/principal/index.html` na branch `main`; o endereço público não muda.

A pasta oficial do HTML é [`html5/principal/index.html`](principal/index.html), compartilhada entre todos os colaboradores. **Não duplique nem substitua o arquivo ao publicar.**

## Como funciona

1. O colaborador cria um ramo e um pull request para o design; o responsável analisa e integra em `main`.
2. Toda alteração em `html5/**` incorporada na branch `main` dispara o workflow [publicar-html5.yml](../.github/workflows/publicar-html5.yml).
3. O jogo passa a ser servido sempre pelo **mesmo endereço oficial da raiz**, sem necessidade de baixar outro HTML.
4. O histórico de versões continua em [`html5/versoes`](versoes/).

## Ativação necessária (uma vez)

Nas configurações do repositório, abra **Settings → Pages → Build and deployment → Source** e escolha **GitHub Actions**.

⚠️ A URL só estará disponível depois dessa ativação e de uma execução bem-sucedida do workflow na branch `main`.

O GitHub Pages publica todo o conteúdo de `html5/`. O arquivo `html5/index.html` redireciona a raiz pública `/Projeto-Santa-Mina/` para o arquivo principal em `/Projeto-Santa-Mina/principal/`. O **link oficial de divulgação continua sendo o endereço da raiz**.

Para ver o andamento, consulte a guia **Actions → 🎮 Publicar Santa Mina HTML5**.
