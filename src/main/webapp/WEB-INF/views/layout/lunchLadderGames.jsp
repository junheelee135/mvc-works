<%-- lunchLadderGames.jsp --%>
<%@ page contentType="text/html; charset=UTF-8" %>
<%-- ========== MODAL 1: 사다리 타기 ========== --%>
<div id="modal-ladder" class="ll-overlay" onclick="if(event.target===this)closeModal('ladder')">
  <div class="ll-modal">
    <div class="ll-mheader">
      <div>
        <div class="ll-mtitle">사다리 타기</div>
        <div class="ll-msub">오늘의 점심 쏘기 당첨자는 ??</div>
      </div>
      <button class="ll-mclose" onclick="closeModal('ladder')">x</button>
    </div>

    <div id="ld-setup" class="ll-mbody">
      <div class="ll-section">
        <div class="ll-slabel">인원 <span id="ld-pcount">0 / 8</span></div>
        <div class="ll-tags" id="ld-tags"></div>
        <div class="ll-irow">
          <input id="ld-pinp" maxlength="8" placeholder="이름 입력 후 Enter" />
          <button class="ll-badd" onclick="ldAddP()">추가</button>
        </div>
      </div>
      <div class="ll-section">
        <div class="ll-slabel">규칙 정하기</div>
        <div id="ld-plist" style="display:flex;flex-direction:column;gap:5px;margin-bottom:8px;"></div>
        <div class="ll-irow">
          <input id="ld-zinp" maxlength="12" placeholder="예: 점심 사기, 커피 사기" />
          <button class="ll-badd" onclick="ldAddZ()">추가</button>
        </div>
      </div>
      <button id="ld-btnstart" class="ll-bprimary" disabled onclick="ldStart()">시작!</button>
    </div>

    <div id="ld-game" class="ll-mbody" style="display:none;">
      <div class="ll-cwrap"><canvas id="ld-cv"></canvas></div>
      <div id="ld-result" class="ll-result" style="display:none;">
        <div class="ll-rlabel">당첨!!!</div>
        <div class="ll-rname" id="ld-rname"></div>
      </div>
      <div class="ll-brow">
        <button class="ll-bsec" onclick="ldReset()">리셋</button>
        <button id="ld-btntrace" class="ll-bprimary" onclick="ldTrace()">결과 보기</button>
      </div>
    </div>
  </div>
</div>

<%-- ========== MODAL 2: 돌림판 ========== --%>
<div id="modal-roulette" class="ll-overlay" onclick="if(event.target===this)closeModal('roulette')">
  <div class="ll-modal">
    <div class="ll-mheader">
      <div>
        <div class="ll-mtitle">돌림판</div>
        <div class="ll-msub">돌림판을 돌려 운명을 결정하세요</div>
      </div>
      <button class="ll-mclose" onclick="closeModal('roulette')">x</button>
    </div>
    <div class="ll-mbody">
      <div class="ll-section">
        <div class="ll-slabel">인원 <span id="rl-pcount">0 / 8</span></div>
        <div class="ll-tags" id="rl-tags"></div>
        <div class="ll-irow">
          <input id="rl-pinp" maxlength="8" placeholder="이름 입력 후 Enter" />
          <button class="ll-badd" onclick="rlAddP()">추가</button>
        </div>
      </div>
      <div class="roulette-wrap">
        <canvas id="rouletteCanvas" width="280" height="280"></canvas>
        <button id="rl-spinbtn" class="spin-btn" onclick="rlSpin()">돌리기!</button>
      </div>
      <div id="rl-result" class="roulette-result" style="display:none;">
        <div class="ll-rlabel">당첨!</div>
        <div class="ll-rname" id="rl-rname"></div>
      </div>
    </div>
  </div>
</div>

<%-- ========== MODAL 3: 카드 뽑기 ========== --%>
<div id="modal-luckydraw" class="ll-overlay" onclick="if(event.target===this)closeModal('luckydraw')">
  <div class="ll-modal">
    <div class="ll-mheader">
      <div>
        <div class="ll-mtitle">카드 뽑기</div>
        <div class="ll-msub">카드를 골라 운명을 확인하세요</div>
      </div>
      <button class="ll-mclose" onclick="closeModal('luckydraw')">x</button>
    </div>
    <div class="ll-mbody">
      <div class="ll-section">
        <div class="ll-slabel">인원 <span id="lk-pcount">0 / 8</span></div>
        <div class="ll-tags" id="lk-tags"></div>
        <div class="ll-irow">
          <input id="lk-pinp" maxlength="8" placeholder="이름 입력 후 Enter" />
          <button class="ll-badd" onclick="lkAddP()">추가</button>
        </div>
      </div>
      <div id="lk-dealwrap" style="display:none;">
        <div style="font-size:13px;color:#6b7280;margin-bottom:10px;text-align:center;">카드를 골라보세요!</div>
        <div class="card-grid" id="lk-cardgrid"></div>
      </div>
      <div id="lk-result" class="lucky-result" style="display:none;">
        <div class="ll-rlabel">당첨!</div>
        <div class="ll-rname" id="lk-rname"></div>
        <div class="ll-rmsg"  id="lk-rmsg"></div>
      </div>
      <div class="ll-brow">
        <button class="ll-bsec" onclick="lkReset()">리셋</button>
        <button id="lk-btnstart" class="ll-bprimary" disabled onclick="lkDeal()">카드 나눠주기</button>
      </div>
    </div>
  </div>
</div>

<script>
(function(){

/* ============================================================
   SHARED
   ============================================================ */
window.closeModal = function(type) {
    document.getElementById('modal-'+type).style.display = 'none';
};

var COLS = ['#E24B4A','#378ADD','#1D9E75','#EF9F27','#7F77DD','#D85A30','#639922','#D4537E'];

function shuffle(a) {
    var b = a.slice();
    for (var i = b.length-1; i > 0; i--) {
        var j = Math.floor(Math.random()*(i+1));
        var t = b[i]; b[i] = b[j]; b[j] = t;
    }
    return b;
}

function mkTagHTML(p, i) {
    return '<span class="ll-tag" data-i="'+i+'">'+p+'<span class="ll-tagx">x</span></span>';
}

/* ============================================================
   GAME 1 : LADDER
   ============================================================ */
var ldP = ['1','2','3','4'];
var ldZ = [];
var ldData = null, ldAnimId = null, ldBusy = false;
var PT=52, PB=52, PS=40;

function ldRenderP() {
    var el = document.getElementById('ld-tags');
    el.innerHTML = ldP.map(mkTagHTML).join('');
    el.querySelectorAll('.ll-tag').forEach(function(t){
        t.onclick = function(){ ldP.splice(+t.dataset.i,1); ldRenderP(); };
    });
    document.getElementById('ld-pcount').textContent = ldP.length+' / 8';
    var btn = document.getElementById('ld-btnstart');
    btn.disabled = ldP.length < 2;
    btn.style.opacity = ldP.length < 2 ? '0.45' : '1';
}
function ldRenderZ() {
    var el = document.getElementById('ld-plist');
    el.innerHTML = ldZ.map(function(p,i){
        return '<div style="display:flex;align-items:center;justify-content:space-between;background:#fff;border:1px solid #e5e7eb;border-radius:8px;padding:6px 12px;font-size:13px;color:#374151;">'
            +'<span>'+p+'</span>'
            +'<span data-i="'+i+'" style="font-size:11px;color:#9ca3af;cursor:pointer;padding:2px 4px;">x</span></div>';
    }).join('');
    el.querySelectorAll('span[data-i]').forEach(function(t){
        t.onclick = function(){ ldZ.splice(+t.dataset.i,1); ldRenderZ(); };
    });
}
window.ldAddP = function(){
    var v = document.getElementById('ld-pinp').value.trim();
    if(v && ldP.indexOf(v)<0 && ldP.length<8){ ldP.push(v); document.getElementById('ld-pinp').value=''; ldRenderP(); }
};
window.ldAddZ = function(){
    var v = document.getElementById('ld-zinp').value.trim();
    if(v && ldZ.length<8){ ldZ.push(v); document.getElementById('ld-zinp').value=''; ldRenderZ(); }
};
document.getElementById('ld-pinp').onkeydown = function(e){ if(e.key==='Enter') ldAddP(); };
document.getElementById('ld-zinp').onkeydown = function(e){ if(e.key==='Enter') ldAddZ(); };

function ldBuild(n) {
    var ROWS = Math.max(10, n*4);
    var grid = [];
    for(var r=0; r<ROWS; r++){
        var row = [];
        for(var c=0; c<n-1; c++){
            var ok = (c===0||!row[c-1]);
            row[c] = ok && Math.random()<0.45;
        }
        grid.push(row);
    }
    return grid;
}
function ldTracePath(start, grid, n) {
    var col = start;
    var pts = [{col:col,row:0}];
    for(var r=0; r<grid.length; r++){
        if(col<n-1 && grid[r][col]){ pts.push({col:col,row:r}); col++; pts.push({col:col,row:r}); }
        else if(col>0 && grid[r][col-1]){ pts.push({col:col,row:r}); col--; pts.push({col:col,row:r}); }
        pts.push({col:col,row:r+1});
    }
    return pts;
}
function ldColX(c,W,n){ return PS+c*(W-PS*2)/(n-1); }
function ldRowY(r,ROWS){ return PT+r*(320-PT-PB)/ROWS; }

function ldDraw(hl) {
    var cv = document.getElementById('ld-cv');
    if(!cv||!ldData) return;
    var n=ldData.n, grid=ldData.grid, ROWS=grid.length;
    var W=cv.offsetWidth||500, dpr=window.devicePixelRatio||1;
    cv.width=W*dpr; cv.height=320*dpr; cv.style.height='320px';
    var ctx=cv.getContext('2d'); ctx.scale(dpr,dpr);
    ctx.clearRect(0,0,W,320);
    ctx.lineWidth=1.5; ctx.strokeStyle='rgba(0,0,0,0.13)'; ctx.lineCap='round';
    for(var c=0;c<n;c++){
        ctx.beginPath(); ctx.moveTo(ldColX(c,W,n),PT); ctx.lineTo(ldColX(c,W,n),ldRowY(ROWS,ROWS)); ctx.stroke();
    }
    for(var r=0;r<ROWS;r++){
        for(var c=0;c<n-1;c++){
            if(grid[r][c]){
                var ry=ldRowY(r,ROWS)+(ldRowY(r+1,ROWS)-ldRowY(r,ROWS))*0.5;
                ctx.beginPath(); ctx.moveTo(ldColX(c,W,n),ry); ctx.lineTo(ldColX(c+1,W,n),ry); ctx.stroke();
            }
        }
    }
    if(hl){
        hl.forEach(function(h){
            var pts=h.pts, till=Math.ceil(pts.length*h.p);
            if(till<2) return;
            ctx.strokeStyle=h.color; ctx.lineWidth=3; ctx.globalAlpha=0.88;
            ctx.beginPath(); ctx.moveTo(ldColX(pts[0].col,W,n),ldRowY(pts[0].row,ROWS));
            for(var i=1;i<till;i++){
                var pr=pts[i-1],cu=pts[i];
                if(pr.col!==cu.col) ctx.lineTo(ldColX(pr.col,W,n),ldRowY(cu.row,ROWS));
                ctx.lineTo(ldColX(cu.col,W,n),ldRowY(cu.row,ROWS));
            }
            ctx.stroke(); ctx.globalAlpha=1;
        });
        ctx.lineWidth=1.5;
    }
    /* 상단 이름 */
    ctx.font='500 13px Pretendard,-apple-system,sans-serif'; ctx.textAlign='center'; ctx.fillStyle='rgba(0,0,0,0.7)';
    for(var c=0;c<n;c++) ctx.fillText(ldP[c],ldColX(c,W,n),30);
    /* 하단 O/X - 애니메이션 완료 후에만 표시 */
    var done = hl && hl[0] && hl[0].p >= 1;
    if(done){
        ctx.font='bold 16px Pretendard,-apple-system,sans-serif';
        for(var c=0;c<n;c++){
            var isWinner = (ldData.results[c] === 0);
            ctx.fillStyle = isWinner ? '#E24B4A' : '#9ca3af';
            ctx.fillText(isWinner ? 'O' : 'X', ldColX(c,W,n), 313);
        }
    }
    /* 도트 */
    for(var c=0;c<n;c++){
        [PT,ldRowY(ROWS,ROWS)].forEach(function(y){
            ctx.beginPath(); ctx.arc(ldColX(c,W,n),y,5,0,Math.PI*2); ctx.fillStyle=COLS[c%COLS.length]; ctx.fill();
        });
    }
}
window.ldStart = function(){
    var n=ldP.length, grid=ldBuild(n);
    var routes=[], i;
    for(i=0;i<n;i++) routes.push(ldTracePath(i,grid,n));
    var results=routes.map(function(r){ return r[r.length-1].col; });
    ldData={n:n,grid:grid,routes:routes,results:results,winnerIdx:results.indexOf(0)};
    document.getElementById('ld-setup').style.display='none';
    document.getElementById('ld-game').style.display='flex';
    document.getElementById('ld-result').style.display='none';
    document.getElementById('ld-btntrace').textContent='결과 보기';
    document.getElementById('ld-btntrace').disabled=false;
    ldBusy=false;
    setTimeout(function(){ ldDraw(null); },30);
};
window.ldReset = function(){
    if(ldAnimId) cancelAnimationFrame(ldAnimId);
    ldBusy=false;
    document.getElementById('ld-game').style.display='none';
    document.getElementById('ld-setup').style.display='flex';
    document.getElementById('ld-result').style.display='none';
    ldRenderP(); ldRenderZ();
};
window.ldTrace = function(){
    if(ldBusy) return;
    ldBusy=true;
    var btn=document.getElementById('ld-btntrace');
    btn.disabled=true; btn.textContent='추적중.....';
    document.getElementById('ld-result').style.display='none';
    var start=performance.now(), dur=1600;
    function step(now){
        var raw=Math.min(1,(now-start)/dur);
        var t=raw<0.5?2*raw*raw:-1+(4-2*raw)*raw;
        ldDraw(ldData.routes.map(function(pts,i){ return {pts:pts,color:COLS[i%COLS.length],p:t}; }));
        if(raw<1){ ldAnimId=requestAnimationFrame(step); }
        else {
            var wi=ldData.winnerIdx;
            document.getElementById('ld-rname').textContent=ldP[wi]+'!';
            document.getElementById('ld-result').style.display='block';
            btn.textContent='다시보기'; btn.disabled=false; ldBusy=false;
        }
    }
    ldAnimId=requestAnimationFrame(step);
};

/* ============================================================
   GAME 2 : ROULETTE
   ============================================================ */
var rlP = ['1','2','3','4'];
var rlAngle = 0, rlSpinning = false;

function rlRenderP(){
    var el=document.getElementById('rl-tags');
    el.innerHTML=rlP.map(mkTagHTML).join('');
    el.querySelectorAll('.ll-tag').forEach(function(t){
        t.onclick=function(){ rlP.splice(+t.dataset.i,1); rlRenderP(); rlDraw(rlAngle); };
    });
    document.getElementById('rl-pcount').textContent=rlP.length+' / 8';
    document.getElementById('rl-spinbtn').disabled=rlP.length<2;
    rlDraw(rlAngle);
}
window.rlAddP=function(){
    var v=document.getElementById('rl-pinp').value.trim();
    if(v && rlP.indexOf(v)<0 && rlP.length<8){ rlP.push(v); document.getElementById('rl-pinp').value=''; rlRenderP(); }
};
document.getElementById('rl-pinp').onkeydown=function(e){ if(e.key==='Enter') rlAddP(); };

function rlDraw(angle){
    var cv=document.getElementById('rouletteCanvas');
    if(!cv) return;
    var n=rlP.length; if(n<1) return;
    var W=cv.width, H=cv.height, cx=W/2, cy=H/2, R=cx-10;
    var dpr=window.devicePixelRatio||1;
    var ctx=cv.getContext('2d'); ctx.clearRect(0,0,W,H);
    var slice=(2*Math.PI)/n;
    for(var i=0;i<n;i++){
        var start=angle+i*slice, end=start+slice;
        ctx.beginPath(); ctx.moveTo(cx,cy);
        ctx.arc(cx,cy,R,start,end); ctx.closePath();
        ctx.fillStyle=COLS[i%COLS.length]; ctx.fill();
        ctx.strokeStyle='#fff'; ctx.lineWidth=2; ctx.stroke();
        ctx.save(); ctx.translate(cx,cy);
        ctx.rotate(start+slice/2);
        ctx.textAlign='right'; ctx.fillStyle='#fff';
        ctx.font='bold 12px Pretendard,-apple-system,sans-serif';
        ctx.fillText(rlP[i], R-10, 4);
        ctx.restore();
    }
    /* pointer */
    ctx.beginPath(); ctx.moveTo(cx+14,8); ctx.lineTo(cx-14,8); ctx.lineTo(cx,28); ctx.closePath();
    ctx.fillStyle='#111827'; ctx.fill();
}

window.rlSpin=function(){
    if(rlSpinning||rlP.length<2) return;
    rlSpinning=true;
    document.getElementById('rl-result').style.display='none';
    document.getElementById('rl-spinbtn').disabled=true;
    var n=rlP.length;
    var slice=(2*Math.PI)/n;
    var winnerIdx=Math.floor(Math.random()*n);
    var targetAngle = -Math.PI/2 - (winnerIdx*slice + slice/2);
    var fullSpins = (5+Math.floor(Math.random()*4)) * Math.PI*2;
    var extra = fullSpins + (targetAngle - (rlAngle % (Math.PI*2)));
    if(extra < Math.PI*2) extra += Math.PI*2;
    var startAngle=rlAngle;
    var startTime=performance.now(), dur=3500+Math.random()*1000;
    function step(now){
        var raw=Math.min(1,(now-startTime)/dur);
        var ease=1-Math.pow(1-raw,3);
        var cur=startAngle+extra*ease;
        rlDraw(cur);
        if(raw<1){ requestAnimationFrame(step); }
        else {
            rlAngle=cur;
            document.getElementById('rl-rname').textContent=rlP[winnerIdx]+'!';
            document.getElementById('rl-result').style.display='block';
            document.getElementById('rl-spinbtn').disabled=false;
            rlSpinning=false;
        }
    }
    requestAnimationFrame(step);
};

/* ============================================================
   GAME 3 : LUCKY DRAW
   ============================================================ */
var lkP=['1','2','3','4'];
var lkDealt=false, lkWinner=-1;

function lkRenderP(){
    var el=document.getElementById('lk-tags');
    el.innerHTML=lkP.map(mkTagHTML).join('');
    el.querySelectorAll('.ll-tag').forEach(function(t){
        t.onclick=function(){ if(lkDealt) return; lkP.splice(+t.dataset.i,1); lkRenderP(); };
    });
    document.getElementById('lk-pcount').textContent=lkP.length+' / 8';
    var btn=document.getElementById('lk-btnstart');
    btn.disabled=lkP.length<2;
    btn.style.opacity=lkP.length<2?'0.45':'1';
}
window.lkAddP=function(){
    var v=document.getElementById('lk-pinp').value.trim();
    if(v && lkP.indexOf(v)<0 && lkP.length<8){ lkP.push(v); document.getElementById('lk-pinp').value=''; lkRenderP(); }
};
document.getElementById('lk-pinp').onkeydown=function(e){ if(e.key==='Enter') lkAddP(); };

window.lkDeal=function(){
    lkDealt=true;
    lkWinner=Math.floor(Math.random()*lkP.length);
    var grid=document.getElementById('lk-cardgrid');
    grid.innerHTML=lkP.map(function(p,i){
        return '<div class="draw-card" id="lk-card-'+i+'" onclick="lkFlip('+i+')">'
            +'<div class="draw-card-inner">'
            +'<div class="draw-card-front">?</div>'
            +'<div class="draw-card-back '+(i===lkWinner?'winner':'safe')+'">'
            +(i===lkWinner?'<div style="font-size:18px;">!</div><div>'+p+'</div>':'<div style="font-size:18px;">OK</div><div>'+p+'</div>')
            +'</div></div></div>';
    }).join('');
    document.getElementById('lk-dealwrap').style.display='block';
    document.getElementById('lk-result').style.display='none';
    document.getElementById('lk-btnstart').textContent='리셋';
    document.getElementById('lk-btnstart').onclick=lkReset;
};
window.lkFlip=function(i){
    if(!lkDealt) return;
    var card=document.getElementById('lk-card-'+i);
    if(!card||card.classList.contains('flipped')) return;
    card.classList.add('flipped');
    if(i===lkWinner){
        setTimeout(function(){
            document.getElementById('lk-rname').textContent=lkP[i]+'!';
            document.getElementById('lk-rmsg').textContent='다음 기회에~~ :)';
            document.getElementById('lk-result').style.display='block';
        },400);
    }
};
window.lkReset=function(){
    lkDealt=false; lkWinner=-1;
    document.getElementById('lk-dealwrap').style.display='none';
    document.getElementById('lk-result').style.display='none';
    document.getElementById('lk-cardgrid').innerHTML='';
    var btn=document.getElementById('lk-btnstart');
    btn.textContent='카드 나눠주기'; btn.onclick=lkDeal;
    lkRenderP();
};

/* ============================================================
   INIT
   ============================================================ */
ldRenderP(); ldRenderZ();
rlRenderP(); rlDraw(0);
lkRenderP();

})();
</script>