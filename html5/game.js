/* SANTA MINA — HTML5 playable vertical slice. Original procedural art. No external libraries.
 * Reference: Documento Mestre 3.0 (27/10/2026). This is a TEST build, not the finished game.
 * Brokk is used because Zeno's complete approved character sheet is not provided.
 */
'use strict';
(() => {
const $=id=>document.getElementById(id), sleep=ms=>new Promise(r=>setTimeout(r,ms));
const canvas=$('battleCanvas'),ctx=canvas.getContext('2d');
const CW=1000,CH=600,TILE=86,DX=104,DY=95,X0=190,Y0=264;
let state=null, busy=false, muted=true, hovered=null, particles=[], cameraShake=0, nextUid=0, modalActive=false, diceTimeout=null, toastTimeout=null;
const images={};['brokk','zeno','bandit_archer','bandit_club','goblin_club','goblin_scrap','goblin_archer','goblin_knife','tripa_seca','floresta','mata','passagem','covil'].forEach(n=>{
 const i=new Image();i.src=`assets/${n}.${['floresta','mata','passagem','covil'].includes(n)?'jpg':'png'}`;images[n]=i;
});
const R=(n)=>1+Math.floor(Math.random()*n),roll=(n=20)=>R(n),dice=(n,count=1)=>Array.from({length:count},()=>roll(n));
const clamp=(v,a,b)=>Math.max(a,Math.min(b,v));
const chapters=[
 {title:'O Carregamento Desaparecido',tag:'À SOMBRA DAS ÁRVORES',location:'Estrada antiga · Floresta',background:'floresta',enemies:['archer_bandit','club_bandit'],description:'A estrada está deserta. Dois saqueadores vigiam os destroços de uma caravana.'},
 {title:'Rastros na Mata',tag:'NENHUMA TRILHA É SEGURA',location:'Trilha fechada · Mata',background:'mata',enemies:['club_goblin','scrap_goblin'],description:'As pegadas menores conduzem a uma clareira coberta de armadilhas antigas.'},
 {title:'A Passagem dos Covardes',tag:'O ECO DO PERIGO',location:'Desfiladeiro · Passagem',background:'passagem',enemies:['bow_goblin','knife_goblin'],description:'Uma abertura entre rochas protege os últimos vigias do covil.'},
 {title:'O Covil de Tripa Seca',tag:'O ÚLTIMO COMBATE',location:'Entrada da masmorra · Covil',background:'covil',enemies:['tripa_seca','club_goblin','scrap_goblin'],description:'O chefe goblin surge das sombras, protegido pelos seus últimos lacaios.'}
];
const monsters={
 archer_bandit:{name:'Bandido Arqueiro',sprite:'bandit_archer',hp:6,def:0,dex:1,for:1,ap:3,die:6,count:1,bonus:1,ranged:true,loot:null},
 club_bandit:{name:'Bandido do Porrete',sprite:'bandit_club',hp:8,def:0,dex:1,for:1,ap:3,die:6,count:1,bonus:1,ranged:false,loot:null},
 club_goblin:{name:'Goblin do Porrete',sprite:'goblin_club',hp:6,def:0,dex:1,for:1,ap:3,die:6,count:1,bonus:1,ranged:false,loot:{item:'Porrete gasto',gold:2}},
 scrap_goblin:{name:'Goblin Sucata',sprite:'goblin_scrap',hp:6,def:2,dex:0,for:2,ap:3,die:4,count:1,bonus:2,ranged:false,loot:{item:'Tampa de ferro',gold:2}},
 bow_goblin:{name:'Goblin Tiro Certo',sprite:'goblin_archer',hp:5,def:0,dex:2,for:0,ap:3,die:6,count:1,bonus:-1,ranged:true,loot:{item:'Arco gasto',gold:2}},
 knife_goblin:{name:'Goblin Faca Cega',sprite:'goblin_knife',hp:6,def:0,dex:2,for:0,ap:3,die:4,count:2,bonus:0,ranged:false,freeMove:1,loot:{item:'Facas cegas',gold:2}},
 tripa_seca:{name:'Tripa Seca',sprite:'tripa_seca',hp:13,def:2,dex:2,for:2,ap:4,die:6,count:1,bonus:2,ranged:false,boss:true,loot:{item:'Escudo de madeira e ferro',gold:7}}
};
const cards=[
 {id:'attack',label:'Ataque',cost:3,art:'⚔',desc:'Golpe com a arma equipada'},
 {id:'defend',label:'Defender',cost:1,art:'⛨',desc:'+2 Defesa até o próximo turno'},
 {id:'move',label:'Mover',cost:2,art:'♞',desc:'1 casa, apenas ortogonal'},
 {id:'run',label:'Correr',cost:3,art:'➶',desc:'Até 2 casas, sem atravessar'},
 {id:'advantage',label:'Vantagem',cost:5,art:'✦',desc:'Ataque com 2 dados, vale o maior'}
];
const key='santamina_html5_test_v1';
function initialJourney(){return {isTest:false,chapterIndex:0,hero:{hp:14,maxHp:14,tempHp:0,ap:5,defending:false,usedReroll:false,usedWall:false,wallDebt:0,r:-1,c:-1,init:0},inventory:{'Pão de queijo':2,'Caldo de ovo':1},gold:0,lootCollected:[],checkpoint:null,completed:false};}
function save(){if(!state||state.isTest)return;try{const afterVictory=state.phase==='victory'||state.phase==='interlude';const copy={chapterIndex:afterVictory?state.chapterIndex+1:state.chapterIndex,hero:{...state.hero,r:-1,c:-1,ap:5,defending:false,wallDebt:0},inventory:state.inventory,gold:state.gold,lootCollected:state.lootCollected,completed:state.completed||(afterVictory&&state.chapterIndex===3)};localStorage.setItem(key,JSON.stringify(copy));$('continueBtn').hidden=copy.completed;}catch(e){console.warn('Salvamento local indisponível',e)}}
function load(){try{return JSON.parse(localStorage.getItem(key)||'null')}catch{return null}}
function setScreen(which){$('menuScreen').hidden=which!=='menu';$('gameScreen').hidden=which!=='game'}
function showMenu(){modalClose();setScreen('menu');$('continueBtn').hidden=!load()||!!load().completed;}
function newGame(){state=initialJourney();startChapter()}
function continueGame(){const s=load();if(!s||s.completed||s.chapterIndex>=chapters.length)return newGame();state={...initialJourney(),...s,hero:{...initialJourney().hero,...s.hero}};state.completed=false;startChapter()}
function unitFactory(type){const m=monsters[type];return {id:`enemy${++nextUid}`,type,...m,maxHp:m.hp,hp:m.hp,r:-1,c:-1,init:0,alive:true,defending:false,apLeft:0,dirtyUsed:false,freeUsed:false,visualFlash:0};}
function startChapter(){modalClose();busy=false;const c=chapters[state.chapterIndex];state.enemies=c.enemies.map(unitFactory);state.phase='placement';state.hero.r=-1;state.hero.c=-1;state.hero.ap=5;state.hero.defending=false;state.hero.wallDebt=0;state.chapterLoot=[];state.selected=null;state.round=1;state.order=[];state.cursor=-1;state.actor=null;state.log=[];state.hero.init=roll(20)+1;state.hero.rawInit=state.hero.init-1;for(const enemy of state.enemies){enemy.rawInit=roll(20);enemy.init=enemy.rawInit+enemy.dex;}
 state.order=[state.hero,...state.enemies].sort((a,b)=>b.init-a.init || (a.id==='enemy'?0:1)-(b.id==='enemy'?0:1) || String(a.id||'hero').localeCompare(String(b.id||'hero')));
 // Enemies acting earlier in initiative place before the player, without knowing hero position.
 for(const e of state.order){if(e===state.hero)break;initialEnemyPosition(e,false)}
 particles=[];log(`<strong>Iniciativa:</strong> Brokk ${state.hero.rawInit} +1 = ${state.hero.init}.`,'good');
 for(const e of state.enemies)log(`${e.name}: ${e.rawInit} +${e.dex} = ${e.init}.`);
 $('chapterKicker').textContent=`CAPÍTULO ${String(state.chapterIndex+1).padStart(2,'0')} / 04`;
 $('chapterName').textContent=c.title;
 $('progressDots').innerHTML=chapters.map((_,i)=>`<i class="${i<state.chapterIndex?'done':i===state.chapterIndex?'active':''}"></i>`).join('');
 setScreen('game');render();openModal({eyebrow:c.tag,title:c.title,text:c.description,body:`<div class="modal-details">⚔ <b>Formação e iniciativa</b><br>Brokk: <b>${state.hero.rawInit} + 1 = ${state.hero.init}</b> · ${state.enemies.length} inimigo(s).<br>Na grade, escolha a posição inicial entre as casas <b>realçadas em dourado</b>. O resultado da iniciativa define as colunas permitidas.</div>`,buttons:[{label:'ESCOLHER POSIÇÃO',click:()=>{modalClose();showToast('ESCOLHA UMA CASA',false,1250)}}]});save();}
function occupied(r,c,ignore){if(state.hero!==ignore&&state.hero.hp>0&&state.hero.r===r&&state.hero.c===c)return state.hero;return state.enemies.find(e=>e!==ignore&&e.alive&&e.r===r&&e.c===c)||null}
function allowedStart(){const z=state.hero.init;const cols=z<10?[2]:z<15?[1,2]:[0,1,2];const a=[];for(let r=0;r<3;r++)for(const c of cols)if(!occupied(r,c))a.push({r,c});return a}
function initialEnemyPosition(e,knowsHero){const preferred=e.ranged?[5,4]:[3];const candidates=[];for(const c of preferred)for(let r=0;r<3;r++){if(!occupied(r,c,e))candidates.push({r,c,dist:knowsHero&&state.hero.r>=0?Math.abs(r-state.hero.r):Math.abs(r-1)})}candidates.sort((a,b)=>a.dist-b.dist||a.r-b.r||a.c-b.c);if(candidates.length){e.r=candidates[0].r;e.c=candidates[0].c;}else{for(let c=3;c<6;c++)for(let r=0;r<3;r++)if(!occupied(r,c,e)){e.r=r;e.c=c;return}}}
function placeHero(r,c){if(state.phase!=='placement'||modalActive)return;const allowed=allowedStart().some(x=>x.r===r&&x.c===c);if(!allowed){showToast('POSIÇÃO NÃO PERMITIDA',true);return}state.hero.r=r;state.hero.c=c;for(const e of state.order){if(e===state.hero)continue;if(e.r===-1)initialEnemyPosition(e,true)}state.phase='combat';log(`<strong>Brokk</strong> assumiu a posição ${String.fromCharCode(65+r)}${c+1}.`,'good');render();showToast('O COMBATE COMEÇOU');setTimeout(()=>advanceTurn(),800)}
function currentActor(){return state.order[state.cursor]||null}
function isHeroTurn(){return state&&state.phase==='combat'&&state.actor===state.hero&&!busy&&!modalActive}
function isCellValid(r,c){if(!isHeroTurn()||!state.selected)return false;if(state.selected==='move'||state.selected==='run'){const max=state.selected==='move'?1:2;return !!shortPath(state.hero,{r,c},max)}const target=occupied(r,c);return !!(target&&target!==state.hero&&target.alive&&isMelee(state.hero,target));}
function isMelee(a,b){return Math.max(Math.abs(a.r-b.r),Math.abs(a.c-b.c))<=1}
function orth(a,b){return Math.abs(a.r-b.r)+Math.abs(a.c-b.c)}
function neighbors(r,c){return [[r-1,c],[r+1,c],[r,c-1],[r,c+1]].filter(([rr,cc])=>rr>=0&&rr<3&&cc>=0&&cc<6)}
function shortPath(a,target,max){if(target.r===a.r&&target.c===a.c)return null;if(occupied(target.r,target.c,a))return null;const queue=[{r:a.r,c:a.c,path:[]}],seen=new Set([`${a.r}-${a.c}`]);while(queue.length){const v=queue.shift();if(v.path.length>=max)continue;for(const [r,c] of neighbors(v.r,v.c)){if(seen.has(`${r}-${c}`)||occupied(r,c,a))continue;const path=[...v.path,{r,c}];if(r===target.r&&c===target.c)return path;seen.add(`${r}-${c}`);queue.push({r,c,path})}}return null}
function bestStep(enemy,hero,max){const q=[{r:enemy.r,c:enemy.c,path:[]}],visited=new Set([`${enemy.r}-${enemy.c}`]);let best=null;while(q.length){const cur=q.shift();if(cur.path.length>0){const dist=Math.max(Math.abs(cur.r-hero.r),Math.abs(cur.c-hero.c));if(!best||dist<best.dist||(dist===best.dist&&cur.path.length<best.path.length))best={...cur,dist};}if(cur.path.length>=max)continue;for(const [r,c] of neighbors(cur.r,cur.c)){const id=`${r}-${c}`;if(visited.has(id)||occupied(r,c,enemy))continue;visited.add(id);q.push({r,c,path:[...cur.path,{r,c}]});}}return best?.path||[]}
function enemiesAlive(){return state.enemies.filter(e=>e.alive)}
async function advanceTurn(){if(!state||state.phase!=='combat')return;if(!state.order.some(a=>a===state.hero||a.alive))return;
 let count=0;do{state.cursor=(state.cursor+1)%state.order.length;if(state.cursor===0&&count>=0&&state.actor!==null){state.round++;log(`<strong>Rodada ${state.round}</strong> iniciada.`);}count++;}while(count<=state.order.length&&!((currentActor()===state.hero&&state.hero.hp>0)||(currentActor()!==state.hero&&currentActor().alive)));
 const actor=currentActor();state.actor=actor;if(actor===state.hero){state.hero.defending=false;state.hero.ap=clamp(5-state.hero.wallDebt,0,5);state.hero.wallDebt=0;state.selected='attack';busy=false;log(`<strong>Seu turno!</strong> ${state.hero.ap} pontos de ação disponíveis.`,'good');showToast('SEU TURNO',false,850);render();return}
 state.selected=null;busy=true;render();showToast(`TURNO: ${actor.name}`,true,850);await sleep(510);await enemyTurn(actor);if(state.phase==='combat')await sleep(310);if(state.phase==='combat')advanceTurn();}
function setSelection(card){if(!isHeroTurn())return;const info=cards.find(v=>v.id===card);if(!info||state.hero.ap<info.cost){showToast('PA INSUFICIENTE',true);return}state.selected=card;if(card==='defend'){state.hero.ap-=1;state.hero.defending=true;log('<strong>Brokk defendeu:</strong> +2 Defesa até seu próximo turno.','good');sound('block');showToast('+2 DEFESA');state.selected=null;}render()}
async function clickCell(r,c){if(!state||modalActive)return;if(state.phase==='placement'){placeHero(r,c);return}if(!isHeroTurn()||busy)return;const a=cards.find(x=>x.id===state.selected);if(!a)return;
 if(state.hero.ap<a.cost){showToast('PA INSUFICIENTE',true);return}
 if(state.selected==='move'||state.selected==='run'){
   const path=shortPath(state.hero,{r,c},state.selected==='move'?1:2);if(!path){showToast('CAMINHO INVÁLIDO',true);return}
   state.hero.ap-=a.cost;busy=true;for(const p of path){particles.push({type:'dust',r:state.hero.r,c:state.hero.c,t:performance.now()});state.hero.r=p.r;state.hero.c=p.c;sound('step');render();await sleep(190)}busy=false;log(`Brokk se deslocou para <strong>${String.fromCharCode(65+r)}${c+1}</strong>.`);state.selected=null;render();return;
 }
 if(state.selected==='attack'||state.selected==='advantage'){
   const target=occupied(r,c);if(!target||target===state.hero||!target.alive||!isMelee(state.hero,target)){showToast('ALVO FORA DE ALCANCE',true);return}
   const advantage=state.selected==='advantage';state.hero.ap-=a.cost;state.selected=null;busy=true;render();await heroAttack(target,advantage);busy=false;render();return;
 }
}
function unitXY(u){return {x:X0+u.c*DX+TILE/2,y:Y0+u.r*DY+TILE/2}}
function puff(u,value,bad=false){if(u.r<0)return;particles.push({type:'float',r:u.r,c:u.c,text:value,bad,t:performance.now()});}
function flash(u){if(u)u.visualFlash=performance.now()+330;cameraShake=performance.now()+230}
async function rollDice(title,faces,sides,details){const dp=$('dicePanel');clearTimeout(diceTimeout);dp.hidden=false;$('diceHead').textContent=title;$('diceDetail').textContent='Os dados estão rolando...';const fd=$('diceFaces');fd.innerHTML=faces.map(_=>'<div class="die-face rolling">?</div>').join('');sound('dice');for(let t=0;t<5;t++){await sleep(60);fd.querySelectorAll('.die-face').forEach(el=>el.textContent=R(sides));}
 fd.innerHTML=faces.map(v=>`<div class="die-face">${v}</div>`).join('');$('diceDetail').textContent=details||`Dado d${sides}`;await sleep(460);dp.hidden=true;}
async function heroAttack(target,advantage){const hero=state.hero;
 if(target.boss&&!target.dirtyUsed){target.dirtyUsed=true;const answer=await ask({eyebrow:'REAÇÃO DO CHEFE · 1 VEZ',title:'Golpe Sujo!',text:'Tripa Seca tenta impedir o seu golpe corpo a corpo. Escolha um teste para resistir (CD 12). O PA do ataque já foi consumido.',buttons:[{label:'TESTAR DESTREZA (+1)',value:'dex'},{label:'TESTAR SABEDORIA (+1)',value:'wis'}]});
 const n=roll(20);await rollDice('TESTE DE RESISTÊNCIA',[n],20,`${n} +1 contra CD 12`);if(n+1<12){log('<strong>Golpe Sujo:</strong> Brokk falhou no teste; o ataque errou.','warn');showToast('GOLPE ANULADO',true);return}log('Brokk resistiu ao <strong>Golpe Sujo</strong>!','good');}
 let rolls=dice(6,advantage?2:1);await rollDice(advantage?'ATAQUE COM VANTAGEM':'ATAQUE',[...rolls],6,advantage?'O maior resultado foi selecionado.':'Dado de arma: 1d6');let natural=advantage?Math.max(...rolls):rolls[0];
 if(!hero.usedReroll){const use=await ask({eyebrow:'TALENTO · MESTRE DAS ARMAS',title:`Resultado: ${natural} no d6`,text:'Você pode manter o dado ou gastar sua única repetição de ataque deste combate (0 PA). A nova rolagem será obrigatória.',buttons:[{label:'MANTER RESULTADO',value:false},{label:'REPETIR O DADO',value:true,secondary:true}]});if(use===true){hero.usedReroll=true;const replacement=roll(6);await rollDice('MESTRE DAS ARMAS',[replacement],6,'Novo resultado obrigatório');natural=replacement;log(`<strong>Mestre das Armas:</strong> resultado substituído por ${replacement}.`,'good')}}
 if(natural===1){log(`<strong>Brokk</strong> errou o ataque contra ${target.name} (1 natural).`,'warn');showToast('ATAQUE ERROU',true);sound('miss');return}
 let damage=natural+3+(natural===6?2:0);const after=Math.max(0,damage-target.def-(target.defending?2:0));
 log(`Brokk golpeou <strong>${target.name}</strong>: ${natural}+3${natural===6?'+2 bônus de machado':''} − ${target.def} DEF = <strong>${after} dano</strong>.`,'damage');
 if(after===0){showToast('BLOQUEADO',true);sound('block');return}await applyDamage(target,after,hero);}
function arrowInterceptor(shooter,target){const others=[state.hero,...state.enemies].filter(e=>e!==shooter&&e!==target&&e.hp>0&&e.alive!==false&&e.r>=0);const dr=target.r-shooter.r,dc=target.c-shooter.c,L=dr*dr+dc*dc;if(L===0)return null;const q=[];for(const u of others){const ur=u.r-shooter.r,uc=u.c-shooter.c,t=(ur*dr+uc*dc)/L;if(t<=0||t>=1)continue;const dd=Math.abs(ur*dc-uc*dr)/Math.sqrt(L);if(dd<.11)q.push({u,t});}q.sort((a,b)=>a.t-b.t);return q[0]?.u||null}
async function enemyAttack(enemy){const hero=state.hero;let rolls=dice(enemy.die,1);const adjacentOrth=orth(enemy,hero)===1;if(enemy.ranged&&adjacentOrth)rolls=dice(enemy.die,2);await rollDice(`${enemy.name.toUpperCase()} ATACA`,rolls,enemy.die,enemy.ranged&&adjacentOrth?'Arco adjacente ortogonal: desvantagem':'Dado de ataque da arma');const natural=rolls.length===2?Math.min(...rolls):rolls[0];
 let target=hero;if(enemy.ranged&&natural<=2){const intercepted=arrowInterceptor(enemy,hero);if(intercepted){target=intercepted;log(`<strong>FOGO AMIGO!</strong> Flecha de ${enemy.name} acertou ${target.name} (dado ${natural}).`,'warn');}}
 if(natural===1&&target===hero){log(`${enemy.name} errou o ataque: 1 natural.`,'good');showToast('INIMIGO ERROU');sound('miss');return}
 const raw=target===hero||target!==hero?dice(enemy.die,enemy.count):[];
 const base=raw.reduce((a,b)=>a+b,0)+enemy.bonus;
 // Friendly fire uses a new damage roll; normal attacks likewise have separate damage roll.
 const df=defense(target,natural);const damage=Math.max(0,base-df);
 log(`${enemy.name}: ataque ${natural}, dano ${raw.join('+')}${enemy.bonus>=0?'+':''}${enemy.bonus} − DEF ${df} = <strong>${damage}</strong> em ${target===hero?'Brokk':target.name}.`,'damage');if(!damage){showToast('DEFESA!',false,650);sound('block');return}
 if(target===hero&&!hero.usedWall){const wall=await ask({eyebrow:'REAÇÃO DE GUERREIRO · 1 VEZ',title:'Muralha de Ferro',text:`Você receberia ${damage} dano físico. Ativar reduz esse dano pela metade (arredondado para baixo), mas desconta 1 PA do seu próximo turno.`,buttons:[{label:'RECEBER O DANO',value:false,secondary:true},{label:'USAR MURALHA DE FERRO',value:true}]});if(wall){hero.usedWall=true;hero.wallDebt=1;const reduced=Math.floor(damage/2);log(`<strong>Muralha de Ferro:</strong> ${damage} → ${reduced} dano. −1 PA no próximo turno.`,'good');await applyDamage(target,reduced,enemy);return;}}
 await applyDamage(target,damage,enemy);}
function defense(target,attackNatural){if(target===state.hero)return (target.hp>7?1:0)+(target.defending?2:0)+((attackNatural===2||attackNatural===3)?2:0);
 return target.def+(target.defending?2:0)}
async function applyDamage(target,amount,attacker){if(amount<=0)return;
 if(target.boss&&attacker===state.hero&&(amount>=5||amount>=target.hp)){
  const nearby=state.enemies.filter(e=>e!==target&&e.alive&&isMelee(e,target)).sort((a,b)=>b.hp-a.hp||a.id.localeCompare(b.id));if(nearby.length){const guard=nearby[0];log(`<strong>ME PROTEJAM!</strong> ${guard.name} interceptou ${amount} de dano do chefe.`,'warn');target=guard;showToast('ME PROTEJAM!',true);await sleep(360);}}
 if(target===state.hero&&target.tempHp>0){const tempLost=Math.min(target.tempHp,amount);target.tempHp-=tempLost;amount-=tempLost;if(tempLost)log(`${tempLost} de dano absorvido por PV temporários.`,'good');}
 if(amount>0){target.hp=Math.max(0,target.hp-amount);puff(target,`−${amount}`,true);flash(target);sound('hit');}else{puff(target,'ABSORVIDO')}
 if(target!==state.hero&&target.hp===0&&target.alive){target.alive=false;log(`<strong>${target.name} foi derrotado!</strong>`,'good');puff(target,'DERROTADO');sound('win');}
 render();await sleep(260);
 if(state.hero.hp<=0){onDefeat();return}
 if(!enemiesAlive().length){onVictory();return;}}
async function enemyTurn(enemy){if(state.phase!=='combat'||!enemy.alive)return;enemy.apLeft=enemy.ap;log(`<strong>${enemy.name}</strong> age (${enemy.apLeft} PA).`);render();
 if(enemy.freeMove&& !isMelee(enemy,state.hero)){const path=bestStep(enemy,state.hero,1);if(path.length){enemy.r=path[0].r;enemy.c=path[0].c;log(`${enemy.name} usou movimento gratuito.`);particles.push({type:'dust',r:enemy.r,c:enemy.c,t:performance.now()});await sleep(360)}}
 if(enemy.hp<=0||state.phase!=='combat')return;
 if((enemy.ranged||isMelee(enemy,state.hero))&&enemy.apLeft>=3){enemy.apLeft-=3;await enemyAttack(enemy);return}
 const max=enemy.apLeft>=3?2:enemy.apLeft>=2?1:0;let path=max?bestStep(enemy,state.hero,max):[];
 // Don't run into melee contact if a single step permits a cheaper move, but prioritize approaching.
 if(path.length){const cost=path.length>=2?3:2;enemy.apLeft-=cost;for(const cell of path){particles.push({type:'dust',r:enemy.r,c:enemy.c,t:performance.now()});enemy.r=cell.r;enemy.c=cell.c;sound('step');render();await sleep(330)}log(`${enemy.name} avançou até ${String.fromCharCode(65+enemy.r)}${enemy.c+1}.`);}
 else{log(`${enemy.name} manteve posição.`)} }
function onDefeat(){if(state.phase!=='combat')return;state.phase='defeat';state.actor=null;render();sound('lose');openModal({eyebrow:'FIM DE COMBATE',title:'Brokk caiu em batalha',text:'Sua jornada de testes terminou neste encontro. Não há permadeath neste protótipo.',body:`<div class="modal-details">Capítulo ${state.chapterIndex+1}: ${chapters[state.chapterIndex].title}<br>É possível tentar novamente com a vida restaurada para testar as mecânicas.</div>`,buttons:[{label:'TENTAR NOVAMENTE',click:()=>{state.hero.hp=14;state.hero.tempHp=0;startChapter()}},{label:'VOLTAR AO MENU',secondary:true,click:()=>showMenu()}]})}
function onVictory(){if(state.phase!=='combat')return;state.phase='victory';state.actor=null;let earned=0;const items=[];for(const e of state.enemies){if(e.loot){earned+=e.loot.gold;items.push(e.loot.item);}}
 state.gold+=earned;items.forEach(it=>{state.lootCollected.push(it);state.inventory[it]=(state.inventory[it]||0)+1});if(state.chapterIndex===3){for(const it of ['Espada de ferro','Arco curto','Poção comum (efeito pendente)']){state.inventory[it]=(state.inventory[it]||0)+1;state.lootCollected.push(it)}}
 sound('win');render();const text=items.length?items.map(it=>`<div class="loot-line">✦ ${it}</div>`).join(''):'<div class="loot-line">Nenhum saque definido para estes bandidos.</div>';
 openModal({eyebrow:`CAPÍTULO ${state.chapterIndex+1} CONCLUÍDO`,title:state.chapterIndex===3?'O covil foi vencido!':'Vitória no combate!',text:'Todos os inimigos foram derrotados. Os saques são recolhidos uma única vez, após a vitória.',body:`<div class="modal-details"><b>+${earned} coroas</b> · Total: <b>${state.gold} coroas</b>${text}${state.chapterIndex===3?'<div class="loot-line">✦ Espada de ferro, arco curto e poção comum (efeito a definir)</div>':''}</div>`,buttons:[{label:state.chapterIndex===3?'VER RESULTADO FINAL':'CONTINUAR JORNADA',click:()=>state.chapterIndex===3?finishGame():interlude()}]});save();}
function finishGame(){state.completed=true;save();openModal({eyebrow:'DEMONSTRAÇÃO CONCLUÍDA',title:'O Covil de Tripa Seca',text:'Você concluiu os quatro capítulos da minicampanha de testes. Parabéns por sobreviver aos perigos da Santa Mina!',body:`<div class="modal-details">✦ <b>4 capítulos concluídos</b><br>✦ <b>${state.gold} coroas</b> recolhidas (total histórico esperado: 19)<br>✦ <b>${state.hero.hp}/${state.hero.maxHp} PV</b> restantes<br>✦ Cartas especiais, exploração aberta e ficha completa de Zeno permanecem para futuras versões.</div>`,buttons:[{label:'JOGAR NOVAMENTE',click:newGame},{label:'VOLTAR AO MENU',secondary:true,click:showMenu}]})}
function interlude(){state.phase='interlude';render();renderInterlude()}
function restOptions(){return Object.entries(state.inventory).filter(([name,n])=>n>0&&['Pão de queijo','Caldo de ovo'].includes(name));}
function renderInterlude(){const protectedSite=state.chapterIndex<2;const food=restOptions();const foodHTML=food.length?`<select id="restFood">${food.map(([n,c])=>`<option value="${n}">${n} (${c})</option>`).join('')}</select>`:'<p>Você está sem alimentos ou bebidas disponíveis.</p>';
 const canShort=state.hero.usedReroll||state.hero.usedWall;
 const body=`<div class="modal-details">Brokk: <b>${state.hero.hp}/${state.hero.maxHp} PV</b> · ${state.hero.tempHp} PV temporários · <b>${state.gold} coroas</b><br>${protectedSite?'⛺ Acampamento protegido de testes.':'⛏ A passagem dá acesso à masmorra. Descanso longo indisponível.'}</div><p>Escolha um alimento para descansar. O descanso curto recupera exatamente uma habilidade de classe; o longo recupera todas e até <b>10 PV</b> de Brokk. O alimento também aplica seu efeito.</p>${foodHTML}<p class="small-note">Os alimentos iniciais deste protótipo são uma provisão de testes; não são um inventário inicial canônico.</p>`;
 openModal({eyebrow:'INTERVALO ENTRE CAPÍTULOS',title:'Uma breve trégua',text:`Próximo: ${chapters[state.chapterIndex+1].title}`,body,buttons:[{label:'DESCANSO CURTO',secondary:true,disabled:!food.length||!canShort,click:()=>doRest('short')},{label:'DESCANSO LONGO',secondary:true,disabled:!food.length||!protectedSite,click:()=>doRest('long')},{label:'PRÓXIMO CAPÍTULO',click:()=>{state.chapterIndex++;startChapter()}}]});save()}
function doRest(kind){const f=$('restFood')?.value;if(!f||!(state.inventory[f]>0))return;state.inventory[f]--;
 if(kind==='short'){if(state.hero.usedReroll)state.hero.usedReroll=false;else if(state.hero.usedWall)state.hero.usedWall=false;}
 else{state.hero.usedReroll=false;state.hero.usedWall=false;state.hero.hp=Math.min(14,state.hero.hp+10)}
 if(f==='Pão de queijo')state.hero.tempHp+=2;
 if(f==='Caldo de ovo')state.hero.hp=Math.min(14,state.hero.hp+1);
 save();render();showToast(kind==='long'?'DESCANSO LONGO':'DESCANSO CURTO');renderInterlude();}
function log(text,type=''){if(!state)return;state.log.unshift({text,type});state.log=state.log.slice(0,25);if(!$('gameScreen').hidden)renderLog()}
function renderLog(){$('combatLog').innerHTML=(state?.log||[]).slice(0,13).map(e=>`<div class="log-entry ${e.type}">${e.text}</div>`).join('')}
function render(){if(!state)return;const h=state.hero;const playerTurn=isHeroTurn();$('hpText').textContent=`${h.hp} / 14`;$('hpBar').style.width=`${100*h.hp/14}%`;$('tempHP').textContent=h.tempHp>0?`✧ +${h.tempHp} PV temporários`:' ';
 $('apText').textContent=`${h.ap} / 5`;$('apPips').innerHTML=Array.from({length:5},(_,i)=>`<i class="${i<h.ap?'on':''}"></i>`).join('');$('defText').textContent=(h.hp>7?1:0)+(h.defending?2:0);
 $('skillsArea').innerHTML=`<div class="skill"><div><b>⚔ Mestre das Armas</b><small>1 repetição de dado por combate</small></div><span class="${h.usedReroll?'used':'ready'}">${h.usedReroll?'USADO':'PRONTO'}</span></div><div class="skill"><div><b>◈ Muralha de Ferro</b><small>Metade do dano físico; −1 PA seguinte</small></div><span class="${h.usedWall?'used':'ready'}">${h.usedWall?'USADO':'PRONTO'}</span></div>`;
 $('enemyList').innerHTML=state.enemies.map(e=>`<div class="enemy-item ${e.alive?'':'dead'} ${state.actor===e?'active':''}"><img src="assets/${e.sprite}.png" alt=""><div class="enemy-info"><b>${e.name}</b><small>${e.hp}/${e.maxHp} PV · ${e.def} DEF · ${e.ap} PA</small><div class="tiny-meter"><i style="width:${100*e.hp/e.maxHp}%"></i></div></div></div>`).join('');
 $('initiativeList').innerHTML=state.order.map((u,i)=>`<div class="initiative-row ${state.actor===u?'current':''}"><span class="turnnumber">${i+1}.</span><span class="initname">${u===h?'Brokk':u.name}${u!==h&&!u.alive?' †':''}</span><b>${u.init}</b></div>`).join('');
 $('turnBadge').textContent=state.phase==='placement'?'ESCOLHA SUA POSIÇÃO':state.phase==='combat'?(state.actor===h?'✦ TURNO DO HERÓI':'⚔ TURNO DO INIMIGO'):'CAMINHO ADIANTE';$('turnBadge').classList.toggle('enemy',state.phase==='combat'&&state.actor!==h);
 $('contextHelp').textContent=state.phase==='placement'?'Clique em uma das casas douradas para posicionar Brokk.':playerTurn?'Escolha uma carta e clique em uma casa válida.':'Acompanhe a iniciativa e os movimentos.';
 $('phaseInfo').textContent=state.phase==='placement'?'POSICIONAMENTO INICIAL':state.phase==='combat'?(state.actor===h?'SUA VEZ DE AGIR':'MOVIMENTO INIMIGO'):'COMBATE ENCERRADO';$('roundInfo').textContent=`Rodada ${state.round||1} · ${chapters[state.chapterIndex].location}`;
 $('endTurnBtn').disabled=!playerTurn;$('actionHint').textContent=playerTurn&&state.selected?'Casas verdes: destinos e alvos possíveis':'Selecione uma carta e clique em uma casa válida';
 $('actionCards').innerHTML=cards.map((c,i)=>`<button class="action-card ${state.selected===c.id?'selected':''}" data-card="${c.id}" ${!playerTurn||h.ap<c.cost?'disabled':''} title="Atalho ${i+1}"><span class="cost-badge">${c.cost}</span><span class="card-art">${c.art}</span><span class="card-name">${c.label}</span><span class="card-desc">${c.desc}</span></button>`).join('');
 $('actionCards').querySelectorAll('.action-card').forEach(b=>b.addEventListener('click',()=>setSelection(b.dataset.card)));renderLog();}
function showToast(msg,error=false,time=950){const t=$('stageToast');t.textContent=msg;t.hidden=false;t.classList.toggle('error',error);clearTimeout(toastTimeout);toastTimeout=setTimeout(()=>t.hidden=true,time)}
function openModal(data){modalActive=true;const dst=$('modalContent');dst.innerHTML=`<div class="modal-eyebrow">${data.eyebrow||'SANTA MINA'}</div><h2>${data.title}</h2>${data.text?`<p>${data.text}</p>`:''}${data.body||''}<div class="modal-actions"></div>`;const actions=dst.querySelector('.modal-actions');for(const b of data.buttons||[]){const el=document.createElement('button');el.className='modal-btn'+(b.secondary?' secondary':'');el.textContent=b.label;el.disabled=!!b.disabled;el.addEventListener('click',b.click);actions.appendChild(el)}$('modalBackdrop').hidden=false;}
function modalClose(){modalActive=false;$('modalBackdrop').hidden=true;}
function ask(data){return new Promise(resolve=>openModal({...data,buttons:data.buttons.map(b=>({...b,click:()=>{modalClose();resolve(b.value)}}))}))}
function sound(which){if(muted)return;try{const AC=window.AudioContext||window.webkitAudioContext;if(!AC)return;window.__smAudio??=new AC();const ac=window.__smAudio,t=ac.currentTime;const o=ac.createOscillator(),g=ac.createGain();o.connect(g);g.connect(ac.destination);o.type=which==='block'?'triangle':'square';const notes={step:[180,100],hit:[220,90],miss:[310,270],dice:[370,250],win:[560,800],lose:[170,90],block:[270,210]};const [a,b]=notes[which]||[350,170];o.frequency.setValueAtTime(a,t);o.frequency.exponentialRampToValueAtTime(Math.max(40,b),t+.16);g.gain.setValueAtTime(.025,t);g.gain.exponentialRampToValueAtTime(.001,t+.2);o.start(t);o.stop(t+.23);}catch{}}
function tileTop(r,c){return {x:X0+c*DX,y:Y0+r*DY}}
function draw(now){requestAnimationFrame(draw);if($('gameScreen').hidden||!state)return;
 ctx.save();ctx.clearRect(0,0,CW,CH);const bg=images[chapters[state.chapterIndex].background];if(bg?.complete&&bg.naturalWidth)ctx.drawImage(bg,0,0,CW,CH);else{ctx.fillStyle='#1a2b31';ctx.fillRect(0,0,CW,CH)}
 ctx.fillStyle='rgba(6,18,23,.29)';ctx.fillRect(0,0,CW,CH);
 // blue cold-to-warm lighting, vignette
 const aura=ctx.createRadialGradient(760,160,15,760,160,470);aura.addColorStop(0,'rgba(235,172,90,.1)');aura.addColorStop(1,'rgba(14,18,23,.15)');ctx.fillStyle=aura;ctx.fillRect(0,0,CW,CH);
 if(cameraShake>now)ctx.translate((Math.random()-.5)*7,(Math.random()-.5)*5);
 // title and fog band behind tile field
 const floor=ctx.createLinearGradient(0,225,0,600);floor.addColorStop(0,'rgba(9,14,18,0)');floor.addColorStop(.25,'rgba(8,17,20,.24)');floor.addColorStop(1,'rgba(8,11,13,.45)');ctx.fillStyle=floor;ctx.fillRect(0,190,1000,410);
 ctx.font='bold 14px Georgia';ctx.fillStyle='#edc998';ctx.textAlign='center';ctx.fillText(chapters[state.chapterIndex].location.toUpperCase(),500,48);ctx.font='11px system-ui';ctx.fillStyle='#d0dbd1bb';ctx.fillText('COMBATE TÁTICO · 3 × 6',500,68);
 for(let r=0;r<3;r++)for(let c=0;c<6;c++){
  const {x,y}=tileTop(r,c);const highlighted=state.phase==='placement'?allowedStart().some(p=>p.r===r&&p.c===c):isHeroTurn()&&isCellValid(r,c);
  const h=hovered?.r===r&&hovered?.c===c,playerSide=c<3;
  ctx.fillStyle='#060e13a0';roundRect(ctx,x+4,y+8,TILE,TILE,5);ctx.fill();
  const tone=(r+c)%2===0;ctx.fillStyle=highlighted?(h?'#b5a064c9':'#836b42aa'):(playerSide?(tone?'#294a4bba':'#294040ba'):(tone?'#4d3d36c1':'#443931c1'));
  roundRect(ctx,x,y,TILE,TILE,4);ctx.fill();ctx.strokeStyle=highlighted?'#ebd18d':h?'#cfba7b77':'#aab4a333';ctx.lineWidth=highlighted?3:1;ctx.stroke();
  ctx.beginPath();ctx.moveTo(x+8,y+15);ctx.lineTo(x+TILE-8,y+15);ctx.strokeStyle=highlighted?'#f4d49a44':'#ffffff12';ctx.lineWidth=1;ctx.stroke();
  if(highlighted){ctx.strokeStyle='#f6d18d';ctx.lineWidth=2;ctx.strokeRect(x+3,y+3,TILE-6,TILE-6)}
  ctx.font='10px ui-monospace,monospace';ctx.textAlign='left';ctx.fillStyle=highlighted?'#fff0c1':'#d8e0d066';ctx.fillText(String.fromCharCode(65+r)+(c+1),x+7,y+TILE-8);
 }
 // boundary painted on gap between hero side and enemy side
 ctx.save();ctx.strokeStyle='#d5b77e77';ctx.setLineDash([7,12]);ctx.lineWidth=2;ctx.beginPath();ctx.moveTo(X0+DX*3-10,Y0-6);ctx.lineTo(X0+DX*3-10,Y0+DY*2+TILE+6);ctx.stroke();ctx.restore();
 // sort by row then position
 const drawUnits=[...state.enemies.filter(e=>e.alive&&e.r>=0),...(state.hero.r>=0&&state.hero.hp>0?[state.hero]:[])].sort((a,b)=>a.r-b.r||a.c-b.c);
 for(const u of drawUnits){const isHero=u===state.hero;const {x,y}=unitXY(u);const bob=Math.sin(now/550+u.c*3)*2;ctx.fillStyle='#030b0db0';ctx.beginPath();ctx.ellipse(x,y+24,35,11,0,0,Math.PI*2);ctx.fill();
  const im=images[isHero?'brokk':u.sprite];if(im?.complete&&im.naturalWidth){ctx.save();if(!isHero){ctx.translate(x,0);ctx.scale(-1,1);ctx.translate(-x,0)}const size=isHero?139:(u.boss?153:125);const w=isHero?99:(u.boss?109:92);ctx.shadowColor='#010509';ctx.shadowBlur=9;ctx.drawImage(im,x-w/2,y-size+39+bob,w,size);ctx.restore();}
  if(u.visualFlash>now){ctx.fillStyle='#ffbd7599';ctx.fillRect(x-25,y-70,50,70)}
  const name=isHero?'BROKK':u.name.toUpperCase();ctx.textAlign='center';ctx.font='bold 10px system-ui';ctx.fillStyle='#0a0e12';ctx.fillText(name,x+1,y-92+bob+1);ctx.fillStyle=isHero?'#f6d999':'#f3d5c0';ctx.fillText(name,x,y-92+bob);
  const ww=68;ctx.fillStyle='#111b1f';ctx.fillRect(x-ww/2,y-85+bob,ww,8);ctx.fillStyle=isHero?'#78ba98':'#cf7962';ctx.fillRect(x-ww/2+1,y-84+bob,(ww-2)*u.hp/(u.maxHp||14),6);
  if(isHero&&u.tempHp){ctx.fillStyle='#a7dbe1';ctx.fillRect(x-ww/2+1,y-81+bob,Math.min(ww-2,ww*u.tempHp/14),3)}
 }
 // short floating damage and terrain particles
 particles=particles.filter(e=>now-e.t<980);for(const p of particles){const a=1-(now-p.t)/980,xy=unitXY(p),x=xy.x,y=xy.y;if(p.type==='float'){ctx.textAlign='center';ctx.font='bold 22px Georgia';ctx.globalAlpha=a;ctx.shadowColor='#030709';ctx.shadowBlur=5;ctx.fillStyle=p.bad?'#ffb39a':'#e9da9a';ctx.fillText(p.text,x,y-105-a*33);ctx.shadowBlur=0;ctx.globalAlpha=1;}else{ctx.fillStyle=`rgba(211,192,151,${a*.5})`;for(let k=0;k<6;k++)ctx.fillRect(x-20+(k*9),y+21-(k%3)*4+(1-a)*18,4,4)}}
 ctx.restore();}
function roundRect(c,x,y,w,h,r){c.beginPath();c.moveTo(x+r,y);c.arcTo(x+w,y,x+w,y+h,r);c.arcTo(x+w,y+h,x,y+h,r);c.arcTo(x,y+h,x,y,r);c.arcTo(x,y,x+w,y,r);c.closePath()}
function mouseCell(e){const box=canvas.getBoundingClientRect();const x=(e.clientX-box.left)*CW/box.width,y=(e.clientY-box.top)*CH/box.height;for(let r=0;r<3;r++)for(let c=0;c<6;c++){const p=tileTop(r,c);if(x>=p.x&&x<=p.x+TILE&&y>=p.y&&y<=p.y+TILE)return {r,c}}return null}
canvas.addEventListener('mousemove',e=>{hovered=mouseCell(e);canvas.style.cursor=hovered?'pointer':'crosshair'});canvas.addEventListener('mouseleave',()=>hovered=null);canvas.addEventListener('click',e=>{const v=mouseCell(e);if(v)clickCell(v.r,v.c)});
$('newGameBtn').addEventListener('click',newGame);$('continueBtn').addEventListener('click',continueGame);$('menuBtn').addEventListener('click',showMenu);$('endTurnBtn').addEventListener('click',()=>{if(!isHeroTurn())return;state.selected=null;busy=true;render();advanceTurn()});
$('soundBtn').addEventListener('click',()=>{muted=!muted;$('soundBtn').innerHTML=muted?'♫ <span>Som</span>':'♪ <span>Som ligado</span>';if(!muted)sound('win')});
function rules(){openModal({eyebrow:'GUIA DE SOBREVIVÊNCIA',title:'Como jogar',body:`<div class="rules-body"><h3>Objetivo</h3><p>Vença os quatro encontros. O tabuleiro possui 3 linhas (A–C) e 6 colunas (1–6). Brokk tem 14 PV e 5 PA por turno, inimigos comuns têm 3 PA, e Tripa Seca possui 4 PA.</p><h3>As cinco cartas</h3><ul><li><b>1 · Ataque (3 PA):</b> clique num inimigo adjacente (diagonal conta).</li><li><b>2 · Defender (1 PA):</b> +2 Defesa até o início do próximo turno.</li><li><b>3 · Mover (2 PA):</b> 1 casa ortogonal livre.</li><li><b>4 · Correr (3 PA):</b> até 2 casas ortogonais, sem atravessar criaturas.</li><li><b>5 · Ataque com Vantagem (5 PA):</b> 2d6, vale o maior.</li></ul><h3>Dados e habilidades</h3><p>Brokk usa machado 1d6 +3 de FOR (natural 6 adiciona +2). Natural 1 erra. O dano é reduzido pela Defesa. Sua Pele de Rocha concede +1 Defesa enquanto tiver mais de 7 PV. Seu escudo adiciona +2 se o dado natural de ataque do inimigo for 2 ou 3.</p><p><b>Mestre das Armas:</b> repetir um dado de ataque uma vez por luta. <b>Muralha de Ferro:</b> reduzir pela metade um ataque físico uma vez por luta, com -1 PA no próximo turno.</p><h3>Boss, saque e descanso</h3><p>Tripa Seca pode usar Golpe Sujo uma vez por combate e transferir dano alto a um goblin adjacente. Após cada vitória, recolha os saques. Em um acampamento protegido, descanso longo consome 1 comida, devolve 10 PV e recupera todas as habilidades. Descanso curto recupera uma habilidade, mas não PV diretamente. Cada alimento concede seu próprio efeito.</p><p><b>Versão de teste:</b> números não confirmados para Zeno, animações avançadas, exploração aberta, baralho especial e dados físicos 3D reais não fazem parte desta build.</p></div>`,buttons:[{label:'ENTENDI',click:modalClose}]})}
$('helpBtn').addEventListener('click',rules);$('menuRulesBtn').addEventListener('click',rules);
$('chapterTestBtn').addEventListener('click',()=>{openModal({eyebrow:'LABORATÓRIO DE COMBATE',title:'Escolha um capítulo',text:'Inicia diretamente o combate selecionado com Brokk recuperado e provisões iniciais. Esta opção existe apenas para testar inimigos e habilidades, sem alterar o progresso salvo.',body:`<div class="modal-details">${chapters.map((c,i)=>`<div class="loot-line"><b>${i+1}.</b> ${c.title}</div>`).join('')}</div>`,buttons:chapters.map((c,i)=>({label:`${i+1}. ${c.title}`,click:()=>{state=initialJourney();state.chapterIndex=i;state.isTest=true;startChapter()}}))})});
document.addEventListener('keydown',e=>{if(e.key==='Escape'&&!modalActive&&state?.phase==='combat'){state.selected=null;render()}if(modalActive||!state||!isHeroTurn())return;if(e.key>='1'&&e.key<='5'){e.preventDefault();setSelection(cards[Number(e.key)-1].id)}if(e.key==='Enter'){e.preventDefault();state.selected=null;busy=true;render();advanceTurn();}});
$('continueBtn').hidden=!load()||!!load().completed;requestAnimationFrame(draw);
window.__santaMinaTest={getState:()=>state?JSON.parse(JSON.stringify({phase:state.phase,chapterIndex:state.chapterIndex,hero:state.hero,enemies:state.enemies,round:state.round,gold:state.gold,inventory:state.inventory,actor:state.actor===state.hero?'hero':state.actor?.name,selected:state.selected})):null,newGame,placeHero,selectCard:setSelection,clickCell,endTurn:()=>{$('endTurnBtn').click()},clearSave:()=>localStorage.removeItem(key)};
})();
