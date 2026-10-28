# Áudio provisório de combate

Oito efeitos originais gerados por síntese programática em `gerar_sons.js`.
Não contêm gravações, amostras ou recursos de terceiros.

- `escudo.wav`: ruído de ataque e parciais metálicas amortecidas.
- `corte_normal.wav`, `corte_forte.wav`: ruído de passagem de lâmina e impacto.
- `pancada_normal.wav`, `pancada_forte.wav`: ruído filtrado e tons graves secos.
- `disparo_arco.wav`: corda dedilhada sintetizada.
- `impacto_flecha.wav`, `impacto_flecha_forte.wav`: ataque agudo e corpo curto.

WAV PCM mono, 16 bits, 22.050 Hz, entre 0,12 e 0,26 segundos.
Pico limitado a 60% e reprodução a -9 dB no Godot.
O projeto usa os arquivos locais prontos; Node.js só serve para regenerá-los.
Perfurantes reutilizam provisoriamente o par de sons de corte, com configuração
própria em `CATEGORIAS` para permitir substituí-los depois.
