# Santa Mina — continuar em dois computadores

## Preparar o segundo computador

1. Instale Godot 4.7.2 e GitHub Desktop.
2. Entre no GitHub Desktop na conta que tem acesso ao repositório privado.
3. Selecione File → Clone repository → ViciadoEmMana/Projeto-Santa-Mina.
4. Escolha uma pasta local e conclua o clone.
5. Importe o project.godot da raiz no Godot e aguarde a importação dos assets.
6. Abra Campanha.tscn com F6 ou Combate.tscn com F6. F5 abre o tabuleiro original.
7. Para continuar com um assistente, abra a mesma pasta como projeto local e
   indique README.md, docs/SANTA_MINA_GODOT.md e docs/ATUALIZACAO_ZENO.md.

## Rotina a cada sessão

- Antes de começar: Fetch origin e Pull origin, se houver atualizações.
- Ao terminar: salve os arquivos no editor, revise Changes, escreva uma descrição
  curta, faça Commit to main e depois Push origin.
- Antes de trocar de computador: termine o envio. No outro, baixe as atualizações.
- Trabalhe em um computador por vez para o mesmo conjunto de mudanças.
- Commit registra localmente; Push envia ao GitHub. Só o commit não sincroniza
  o outro computador.

## Este computador

A publicação inicial foi feita pelo plugin do GitHub. A pasta de origem foi
preservada; ela não se transforma automaticamente em um clone Git local.
No GitHub Desktop, use File → Clone repository e escolha uma nova pasta.
Abra o project.godot dessa cópia para continuar trabalhando com Commit e Push.
Mantenha a pasta de origem como backup até conferir o clone.
A autenticação do Desktop/Git local pode ser necessária: conectar o plugin do
GitHub não autentica automaticamente o terminal Git.

## Arquivos e dados locais

- A pasta .godot é cache e será recriada em cada computador.
- Scripts, cenas, recursos, .uid, .import, assets, testes e documentação pertencem
  ao repositório.
- O save da campanha fica em user://, fora da pasta do código; Git não sincroniza
  automaticamente uma partida salva.
- Histórico de chat e arquivos do projeto são coisas diferentes. O resumo em
  docs/HISTORICO_DESENVOLVIMENTO.md ajuda a retomar o contexto.
- Se aparecer conflito, preserve as duas versões para revisão antes de escolher
  o conteúdo final. Não substitua arquivos de um computador às cegas.
