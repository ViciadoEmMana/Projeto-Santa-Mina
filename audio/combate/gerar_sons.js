// Sons originais sintetizados localmente, sem gravações ou bibliotecas externas.
// Regeneração opcional: node audio/combate/gerar_sons.js
// O jogo usa apenas os WAV prontos; não depende de Node.js.
const fs = require('fs');
const path = require('path');
const taxa = 22050;
const configuracoes = {
  escudo: [0.26, 'metal', 1],
  corte_normal: [0.15, 'corte', 0.65],
  corte_forte: [0.23, 'corte', 1],
  pancada_normal: [0.14, 'madeira', 0.7],
  pancada_forte: [0.22, 'madeira', 1],
  disparo_arco: [0.18, 'corda', 0.8],
  impacto_flecha: [0.12, 'flecha', 0.65],
  impacto_flecha_forte: [0.19, 'flecha', 1],
};
let estado = 7429;
function ruido() {
  estado = (Math.imul(estado, 1664525) + 1013904223) >>> 0;
  return estado / 2147483648 - 1;
}
for (const [nome, [duracao, tipo, intensidade]] of Object.entries(configuracoes)) {
  const quantidade = Math.ceil(taxa * duracao);
  const amostras = [];
  let filtrado = 0;
  let anterior = 0;
  for (let i = 0; i < quantidade; i++) {
    const t = i / taxa;
    const n = ruido();
    filtrado = 0.84 * filtrado + 0.16 * n;
    const agudo = n - anterior;
    anterior = n;
    const seno = hz => Math.sin(2 * Math.PI * hz * t);
    let valor;
    if (tipo === 'metal') {
      valor = (0.42 * seno(740) + 0.26 * seno(1193) + 0.16 * seno(1867)) * Math.exp(-17 * t)
        + 0.4 * agudo * Math.exp(-85 * t);
    } else if (tipo === 'madeira') {
      valor = (0.85 * seno(intensidade === 1 ? 105 : 145) + 0.3 * seno(270)) * Math.exp(-37 * t)
        + 1.6 * filtrado * Math.exp(-55 * t);
    } else if (tipo === 'corte') {
      valor = 0.65 * agudo * Math.sin(Math.PI * t / duracao) * Math.exp(-8 * t)
        + 0.5 * seno(155) * Math.exp(-38 * Math.abs(t - 0.045));
    } else if (tipo === 'corda') {
      valor = (0.55 * seno(330) + 0.25 * seno(660) + 0.16 * seno(990)) * Math.exp(-30 * t)
        + 0.22 * agudo * Math.exp(-52 * t);
    } else {
      valor = 0.75 * agudo * Math.exp(-65 * t) + 0.55 * seno(210) * Math.exp(-40 * t);
    }
    const borda = Math.min(1, t / 0.002, (duracao - t) / 0.008);
    amostras.push(valor * intensidade * Math.max(0, borda));
  }
  const pico = Math.max(...amostras.map(Math.abs));
  const wav = Buffer.alloc(44 + quantidade * 2);
  wav.write('RIFF', 0); wav.writeUInt32LE(wav.length - 8, 4); wav.write('WAVEfmt ', 8);
  wav.writeUInt32LE(16, 16); wav.writeUInt16LE(1, 20); wav.writeUInt16LE(1, 22);
  wav.writeUInt32LE(taxa, 24); wav.writeUInt32LE(taxa * 2, 28);
  wav.writeUInt16LE(2, 32); wav.writeUInt16LE(16, 34);
  wav.write('data', 36); wav.writeUInt32LE(quantidade * 2, 40);
  amostras.forEach((v, i) => wav.writeInt16LE(Math.round(v / Math.max(1, pico) * 0.6 * 32767), 44 + i * 2));
  fs.writeFileSync(path.join(__dirname, nome + '.wav'), wav);
}
