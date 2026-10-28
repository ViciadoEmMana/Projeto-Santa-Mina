// Síntese própria e determinística, sem amostras externas. Godot usa os WAV prontos.
const fs = require('node:fs');
const path = require('node:path');
const taxa = 22050;
let estado = 91267;
function ruido() { estado = (Math.imul(estado,1664525)+1013904223)>>>0; return estado/2147483648-1; }
const sons={passo_pedra:[0.14,'passo'],passo_terra:[0.13,'terra'],carta:[0.12,'carta'],dados:[0.55,'dados'],vento_caverna:[6,'caverna'],vento_floresta:[6,'floresta']};
for (const [nome,[duracao,tipo]] of Object.entries(sons)) {
 const n=Math.ceil(taxa*duracao), a=new Float32Array(n);let filtro=0;
 for(let i=0;i<n;i++) {
  const t=i/taxa, r=ruido();filtro=0.94*filtro+0.06*r;
  let v=0;
  if(tipo==='passo'||tipo==='terra') v=(0.6*Math.sin(2*Math.PI*(tipo==='terra'?105:155)*t)+r*0.22+filtro*0.7)*Math.exp(-44*t);
  else if(tipo==='carta') v=(r-filtro)*Math.sin(Math.PI*t/duracao)*0.3;
  else if(tipo==='dados') { for(const inicio of [0,0.085,0.19,0.32,0.42]) {const d=t-inicio;if(d>=0)v+=(0.3*r+0.3*Math.sin(2*Math.PI*950*d)+0.2*Math.sin(2*Math.PI*1430*d))*Math.exp(-105*d);} }
  else { const ciclo=2*Math.PI*t/duracao;v=filtro*(0.30+0.05*Math.sin(ciclo))+(tipo==='caverna'?0.015*Math.sin(ciclo*142):0.012*Math.sin(ciclo*719))*Math.pow(Math.sin(ciclo/2),2); }
  const borda=Math.max(0,Math.min(1,t/(duracao>1?0.6:0.003),(duracao-t)/(duracao>1?0.6:0.015)));
  a[i]=v*borda;
 }
 const wav=Buffer.alloc(44+n*2);wav.write('RIFF');wav.writeUInt32LE(wav.length-8,4);wav.write('WAVEfmt ',8);wav.writeUInt32LE(16,16);wav.writeUInt16LE(1,20);wav.writeUInt16LE(1,22);wav.writeUInt32LE(taxa,24);wav.writeUInt32LE(taxa*2,28);wav.writeUInt16LE(2,32);wav.writeUInt16LE(16,34);wav.write('data',36);wav.writeUInt32LE(n*2,40);
 let pico=0;for(let i=0;i<n;i++){pico=Math.max(pico,Math.abs(a[i]));wav.writeInt16LE(Math.round(Math.max(-0.8,Math.min(0.8,a[i]))*32767),44+i*2);}
 fs.writeFileSync(path.join(__dirname,nome+'.wav'),wav);
 console.log(`${nome}: ${duracao}s, pico ${pico.toFixed(3)}, PCM mono 22050 Hz.`);
}
