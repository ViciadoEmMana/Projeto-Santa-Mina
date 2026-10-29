# 🎮 Link fixo para jogar Santa Mina

**Endereço planejado do jogo:** https://viciadoemmana.github.io/Projeto-Santa-Mina/principal/

A pasta oficial do HTML é [`html5/principal/index.html`](principal/index.html), compartilhada entre todos os colaboradores. **Não duplique nem substitua o arquivo ao publicar.**

## Como funciona

1. O colaborador cria um ramo e um pull request para o design; o responsável analisa e integra em `main`.
2. Toda alteração em `html5/**` incorporada na branch `main` dispara o workflow [publicar-html5.yml](../.github/workflows/publicar-html5.yml).
3. O jogo passa a ser servido sempre pelo **mesmo endereço**, sem necessidade de baixar outro HTML.
4. O histórico de versões continua em [`html5/versoes`](versoes/).

## Ativação necessária (uma vez)

Nas configurações do repositório, abra **Settings → Pages → Build and deployment → Source** e escolha **GitHub Actions**.

⚠️ A URL só estará disponível depois dessa ativação e de uma execução bem-sucedida do workflow na branch `main`.

O GitHub Pages publica todo o conteúdo de `html5/`, então `html5/principal/index.html` fica em `/principal/`.

Para ver o andamento, consulte a guia **Actions → 🎮 Publicar Santa Mina HTML5**.
