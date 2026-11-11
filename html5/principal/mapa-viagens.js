/* Santa Mina — módulo experimental de viagem pelo mapa (HTML5).
   Não altera o combate; pronto para integração na tela de exploração.
   Coordenadas em pixels do mapa original 1364x1119. */
(function(global){
"use strict";
const locais=[
["santa","Santa Mina",680,240],["porto","Porto",422,87],["escravos","Vila dos Escravos",181,41],
["mina_santa","Mina de Santa Mina",877,160],["forja_velha","Forja Velha",523,436],
["carvalho","Carvalho Torto",194,483],["brejo","Brejo Fundo",278,531],["canavial","Canavial",306,657],
["porcos","Vila dos Porcos",468,638],["madeira","Vila da Madeira",701,652],
["ferro_cidade","Cidade do Ferro",966,653],["mina_ferro","Mina do Ferro",1153,431],
["toca","Toca do Lagarto",1280,608],["goblins","Caverna dos Goblins",1053,779],
["assombrada","Mina Assombrada",1161,898],["bosque","Bosque Fechado",722,874],
["sapos","Poço dos Sapos",867,1020],["fantasma","Cidade Fantasma",602,1049],
["forja_nova","Forja Nova",92,888]
].map(([id,nome,x,y])=>({id,nome,x,y}));
const pontos=Object.fromEntries(locais.map(l=>[l.id,l]));
const caminhos=[
["santa","porto",[[580,219],[480,220],[432,189]]],["porto","escravos",[[379,170],[304,172],[242,112]]],
["santa","mina_santa",[[773,216],[826,191]]],["santa","forja_velha",[[585,315],[523,375]]],
["forja_velha","carvalho",[[430,460],[350,477],[268,490]]],
["carvalho","brejo",[[223,517],[254,542]]],
["brejo","canavial",[[258,589]]],["canavial","forja_nova",[[258,727],[206,803],[153,844]]],
["forja_velha","porcos",[[521,514],[485,579]]],
["porcos","madeira",[[543,630],[614,633]]],
["madeira","ferro_cidade",[[779,676],[871,680]]],
["madeira","bosque",[[692,742],[704,811]]],
["bosque","fantasma",[[688,943],[644,1009]]],
["bosque","sapos",[[759,929],[814,982]]],
["ferro_cidade","goblins",[[997,711],[1025,746]]],
["goblins","assombrada",[[1092,842]]],
["ferro_cidade","mina_ferro",[[985,570],[1055,511]]],
["mina_ferro","toca",[[1230,497]]],
["goblins","toca",[[1136,725],[1237,655]]],
["fantasma","forja_nova",[[485,1048],[384,973],[294,927],[184,890]]]
].map(([a,b,meio])=>({a,b,coordenadas:[[pontos[a].x,pontos[a].y],...meio,[pontos[b].x,pontos[b].y]]}));
const distancia=(a,b)=>Math.hypot(a[0]-b[0],a[1]-b[1]);
const comprimento=ps=>ps.slice(1).reduce((sum,p,i)=>sum+distancia(ps[i],p),0);
const grafo=Object.fromEntries(locais.map(l=>[l.id,[]]));
for(const e of caminhos){const len=comprimento(e.coordenadas);grafo[e.a].push({id:e.b,len,e,reverso:false});grafo[e.b].push({id:e.a,len,e,reverso:true});}
function rota(origem,destino){
if(!pontos[origem]||!pontos[destino])throw Error("Localidade desconhecida");
if(origem===destino)return {locais:[origem],coordenadas:[[pontos[origem].x,pontos[origem].y]],distancia:0};
const dist=Object.fromEntries(locais.map(l=>[l.id,Infinity])),anterior={};dist[origem]=0;
const pendentes=new Set(locais.map(l=>l.id));
while(pendentes.size){const u=[...pendentes].reduce((a,b)=>dist[a]<dist[b]?a:b);if(!Number.isFinite(dist[u]))break;pendentes.delete(u);if(u===destino)break;
for(const v of grafo[u])if(pendentes.has(v.id)&&dist[u]+v.len<dist[v.id]){dist[v.id]=dist[u]+v.len;anterior[v.id]={de:u,trecho:v};}}
if(!anterior[destino])return null;
const etapas=[],localidades=[destino];let atual=destino;
while(atual!==origem){const {de,trecho}=anterior[atual];etapas.unshift(trecho);localidades.unshift(de);atual=de;}
const coordenadas=[];for(const etapa of etapas){const c=etapa.reverso?[...etapa.e.coordenadas].reverse():etapa.e.coordenadas;coordenadas.push(...(coordenadas.length?c.slice(1):c));}
return {locais:localidades,coordenadas,distancia:comprimento(coordenadas)};
}
const referencia=rota("santa","forja_nova").distancia;
function dias(origem,destino,meio="pe"){if(!["pe","carroca"].includes(meio))throw Error("Meio de transporte inválido");
const r=rota(origem,destino);return r.distancia===0?0:Math.max(1,Math.round((r.distancia/referencia)*(meio==="carroca"?3:6)));}
function posicao(coordenadas,progresso){if(!coordenadas.length)throw Error("Trajeto vazio");
const p=Math.max(0,Math.min(1,progresso));let restante=comprimento(coordenadas)*p;
for(let i=1;i<coordenadas.length;i++){const anterior=coordenadas[i-1],atual=coordenadas[i],len=distancia(anterior,atual);
if(restante<=len||i===coordenadas.length-1){const t=len?Math.min(1,restante/len):0;return {x:anterior[0]+(atual[0]-anterior[0])*t,y:anterior[1]+(atual[1]-anterior[1])*t};}restante-=len;}
const ultimo=coordenadas.at(-1);return {x:ultimo[0],y:ultimo[1]};
}
// O relógio é determinado pela simulação, nunca por tempo real obrigatório.
function iniciarViagem(origem,destino,meio="pe"){const trajeto=rota(origem,destino);return {...trajeto,origem,destino,meio,dias:dias(origem,destino,meio),progresso:0};}
function avancar(viagem,fracao){viagem.progresso=Math.max(0,Math.min(1,viagem.progresso+fracao));return {posicao:posicao(viagem.coordenadas,viagem.progresso),diasDecorridos:viagem.dias*viagem.progresso,chegou:viagem.progresso>=1};}
global.SantaMinaViagens=Object.freeze({locais,caminhos,rota,dias,posicao,iniciarViagem,avancar,referencia});
})(typeof window!=="undefined"?window:globalThis);
