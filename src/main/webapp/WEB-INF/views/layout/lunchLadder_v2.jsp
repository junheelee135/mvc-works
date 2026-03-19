<%-- Lunch Ladder v2 - Place below notice nav-link in sidebar.jsp --%>

<%-- sidebar menu item --%>
<a href="#" class="nav-link" id="llMenuBtn">
    <i class="fas fa-dice"></i> Lunch Ladder
</a>

<%-- modal --%>
<div id="llOverlay" style="display:none;position:fixed;inset:0;z-index:9999;background:rgba(0,0,0,.45);display:none;align-items:center;justify-content:center;">
  <div id="llModal" style="background:#fff;border-radius:16px;width:min(560px,94vw);max-height:90vh;overflow-y:auto;box-shadow:0 20px 60px rgba(0,0,0,.2);">

    <div style="display:flex;align-items:flex-start;justify-content:space-between;padding:1.25rem 1.5rem 0;">
      <div>
        <div style="font-size:17px;font-weight:700;color:#111827;">Lunch Ladder</div>
        <div style="font-size:13px;color:#6b7280;margin-top:2px;">Who pays for lunch today?</div>
      </div>
      <button id="llClose" style="background:none;border:none;cursor:pointer;color:#9ca3af;font-size:18px;line-height:1;padding:2px 6px;">x</button>
    </div>

    <%-- setup --%>
    <div id="llSetup" style="padding:1.25rem 1.5rem 1.5rem;display:flex;flex-direction:column;gap:12px;">

      <div style="background:#f9fafb;border-radius:10px;border:1px solid #e5e7eb;padding:1rem 1.125rem;">
        <div style="display:flex;align-items:center;margin-bottom:10px;">
          <div style="font-size:11px;font-weight:700;color:#6b7280;text-transform:uppercase;letter-spacing:.06em;">Participants</div>
          <div id="llPCount" style="font-size:11px;color:#9ca3af;margin-left:auto;">0 / 8</div>
        </div>
        <div id="llTags" style="display:flex;flex-wrap:wrap;gap:6px;margin-bottom:10px;min-height:28px;"></div>
        <div style="display:flex;gap:6px;">
          <input id="llPInp" maxlength="8" placeholder="Enter name + Enter"
            style="flex:1;padding:7px 10px;font-size:13px;border:1px solid #d1d5db;border-radius:8px;background:#fff;color:#111827;outline:none;" />
          <button onclick="llAddP()" style="padding:7px 14px;font-size:13px;font-weight:600;background:#E24B4A;color:#fff;border:none;border-radius:8px;cursor:pointer;">Add</button>
        </div>
      </div>

      <div style="background:#f9fafb;border-radius:10px;border:1px solid #e5e7eb;padding:1rem 1.125rem;">
        <div style="display:flex;align-items:center;margin-bottom:10px;">
          <div style="font-size:11px;font-weight:700;color:#6b7280;text-transform:uppercase;letter-spacing:.06em;">Prize</div>
          <span style="font-size:11px;color:#9ca3af;margin-left:6px;">leave blank = default</span>
        </div>
        <div id="llPrizeList" style="display:flex;flex-direction:column;gap:5px;margin-bottom:8px;"></div>
        <div style="display:flex;gap:6px;">
          <input id="llZInp" maxlength="12" placeholder="e.g. Buy lunch, Buy coffee"
            style="flex:1;padding:7px 10px;font-size:13px;border:1px solid #d1d5db;border-radius:8px;background:#fff;color:#111827;outline:none;" />
          <button onclick="llAddZ()" style="padding:7px 14px;font-size:13px;font-weight:600;background:#E24B4A;color:#fff;border:none;border-radius:8px;cursor:pointer;">Add</button>
        </div>
      </div>

      <button id="llBtnStart" disabled onclick="llStartGame()"
        style="width:100%;padding:11px;font-size:15px;font-weight:600;background:#E24B4A;color:#fff;border:none;border-radius:10px;cursor:pointer;">
        Start!
      </button>
    </div>

    <%-- game --%>
    <div id="llGame" style="display:none;padding:1.25rem 1.5rem 1.5rem;flex-direction:column;gap:12px;">
      <div style="background:#f9fafb;border-radius:10px;border:1px solid #e5e7eb;padding:6px;overflow:hidden;">
        <canvas id="llCv" style="display:block;width:100%;"></canvas>
      </div>
      <div id="llResult" style="display:none;background:#fff5f5;border:1px solid #fecaca;border-radius:12px;padding:1.25rem;text-align:center;">
        <div style="font-size:12px;color:#9ca3af;margin-bottom:6px;">Today's victim</div>
        <div id="llRName" style="font-size:28px;font-weight:700;color:#E24B4A;margin-bottom:4px;"></div>
        <div id="llRMsg"  style="font-size:14px;color:#6b7280;"></div>
      </div>
      <div style="display:flex;gap:8px;">
        <button onclick="llGoSetup()"
          style="flex:1;padding:10px;font-size:14px;background:#f3f4f6;color:#374151;border:1px solid #e5e7eb;border-radius:10px;cursor:pointer;">
          Reset
        </button>
        <button id="llBtnTrace" onclick="llDoTrace()"
          style="flex:1;padding:10px;font-size:14px;font-weight:600;background:#E24B4A;color:#fff;border:none;border-radius:10px;cursor:pointer;">
          Show Result
        </button>
      </div>
    </div>

  </div>
</div>

<script>
(function(){
  var P=['Member1','Member2','Member3','Member4'];
  var Z=[];
  var DEF=['Buy Lunch','Buy Coffee','Buy Snacks','Pay Parking','Plan Dinner','Buy Drinks','Prep Snacks','Buy Late Snack'];
  var COLS=['#E24B4A','#378ADD','#1D9E75','#EF9F27','#7F77DD','#D85A30','#639922','#D4537E'];
  var LD=null, animId=null, busy=false;
  var PT=52,PB=52,PS=40;

  var overlay  = document.getElementById('llOverlay');
  var btnStart = document.getElementById('llBtnStart');
  var btnTrace = document.getElementById('llBtnTrace');

  document.getElementById('llMenuBtn').addEventListener('click',function(e){
    e.preventDefault();
    overlay.style.display='flex';
    llRenderP(); llRenderZ();
  });
  document.getElementById('llClose').addEventListener('click',function(){ overlay.style.display='none'; if(animId)cancelAnimationFrame(animId); });
  overlay.addEventListener('click',function(e){ if(e.target===overlay){ overlay.style.display='none'; if(animId)cancelAnimationFrame(animId); } });
  document.getElementById('llPInp').addEventListener('keydown',function(e){ if(e.key==='Enter') llAddP(); });
  document.getElementById('llZInp').addEventListener('keydown',function(e){ if(e.key==='Enter') llAddZ(); });

  function llRenderP(){
    var el=document.getElementById('llTags');
    el.innerHTML=P.map(function(p,i){
      return '<span data-i="'+i+'" style="display:inline-flex;align-items:center;gap:4px;background:#fff;border:1px solid #d1d5db;border-radius:20px;padding:4px 10px;font-size:13px;color:#374151;cursor:pointer;">'+p+'<span style="font-size:10px;color:#9ca3af;">x</span></span>';
    }).join('');
    el.querySelectorAll('span[data-i]').forEach(function(t){
      t.addEventListener('click',function(){ P.splice(+t.dataset.i,1); llRenderP(); });
    });
    document.getElementById('llPCount').textContent=P.length+' / 8';
    btnStart.disabled=P.length<2;
    btnStart.style.opacity=P.length<2?'0.45':'1';
    btnStart.style.cursor=P.length<2?'not-allowed':'pointer';
  }

  function llRenderZ(){
    var el=document.getElementById('llPrizeList');
    el.innerHTML=Z.map(function(p,i){
      return '<div style="display:flex;align-items:center;justify-content:space-between;background:#fff;border:1px solid #e5e7eb;border-radius:8px;padding:6px 12px;font-size:13px;color:#374151;">'
        +'<span>'+p+'</span>'
        +'<span data-i="'+i+'" style="font-size:11px;color:#9ca3af;cursor:pointer;padding:2px 4px;">x Remove</span>'
        +'</div>';
    }).join('');
    el.querySelectorAll('span[data-i]').forEach(function(t){
      t.addEventListener('click',function(){ Z.splice(+t.dataset.i,1); llRenderZ(); });
    });
  }

  window.llAddP=function(){
    var v=document.getElementById('llPInp').value.trim();
    if(v&&P.indexOf(v)<0&&P.length<8){ P.push(v); document.getElementById('llPInp').value=''; llRenderP(); }
  };
  window.llAddZ=function(){
    var v=document.getElementById('llZInp').value.trim();
    if(v&&Z.length<8){ Z.push(v); document.getElementById('llZInp').value=''; llRenderZ(); }
  };

  function shuffle(a){ var b=a.slice(); for(var i=b.length-1;i>0;i--){ var j=Math.floor(Math.random()*(i+1)); var t=b[i];b[i]=b[j];b[j]=t; } return b; }

  function getActivePrizes(n){
    var base=Z.length?Z.slice():[];
    var extra=DEF.filter(function(d){ return base.indexOf(d)<0; });
    return shuffle(base.concat(extra)).slice(0,n);
  }

  function buildLadder(n){
    var ROWS=Math.max(10,n*4);
    var grid=[];
    for(var r=0;r<ROWS;r++){
      var row=[];
      for(var c=0;c<n-1;c++){
        var canPlace=(c===0||!row[c-1]);
        row[c]=canPlace&&(Math.random()<0.45);
      }
      grid.push(row);
    }
    return grid;
  }

  function traceRoute(start,grid,n){
    var col=start;
    var pts=[{col:col,row:0}];
    for(var r=0;r<grid.length;r++){
      if(col<n-1&&grid[r][col]){
        pts.push({col:col,row:r}); col++;
        pts.push({col:col,row:r});
      } else if(col>0&&grid[r][col-1]){
        pts.push({col:col,row:r}); col--;
        pts.push({col:col,row:r});
      }
      pts.push({col:col,row:r+1});
    }
    return pts;
  }

  function colX(c,W,n){ return PS+c*(W-PS*2)/(n-1); }
  function rowY(r,ROWS){ return PT+r*(320-PT-PB)/ROWS; }

  function drawFrame(highlight){
    var cv=document.getElementById('llCv');
    if(!cv||!LD) return;
    var n=LD.n, grid=LD.grid, prizes=LD.prizes;
    var ROWS=grid.length;
    var W=cv.offsetWidth||500;
    var dpr=window.devicePixelRatio||1;
    cv.width=W*dpr; cv.height=320*dpr;
    cv.style.height='320px';
    var ctx=cv.getContext('2d');
    ctx.scale(dpr,dpr);
    ctx.clearRect(0,0,W,320);

    ctx.lineWidth=1.5; ctx.strokeStyle='rgba(0,0,0,0.13)'; ctx.lineCap='round';
    for(var c=0;c<n;c++){
      ctx.beginPath();
      ctx.moveTo(colX(c,W,n),PT);
      ctx.lineTo(colX(c,W,n),rowY(ROWS,ROWS));
      ctx.stroke();
    }
    for(var r=0;r<ROWS;r++){
      for(var c=0;c<n-1;c++){
        if(grid[r][c]){
          var ry=rowY(r,ROWS)+(rowY(r+1,ROWS)-rowY(r,ROWS))*0.5;
          ctx.beginPath();
          ctx.moveTo(colX(c,W,n),ry);
          ctx.lineTo(colX(c+1,W,n),ry);
          ctx.stroke();
        }
      }
    }

    if(highlight){
      highlight.forEach(function(h){
        var pts=h.pts;
        var till=Math.ceil(pts.length*h.p);
        if(till<2) return;
        ctx.strokeStyle=h.color; ctx.lineWidth=3; ctx.globalAlpha=0.88;
        ctx.beginPath();
        ctx.moveTo(colX(pts[0].col,W,n),rowY(pts[0].row,ROWS));
        for(var i=1;i<till;i++){
          var pr=pts[i-1],cu=pts[i];
          if(pr.col!==cu.col) ctx.lineTo(colX(pr.col,W,n),rowY(cu.row,ROWS));
          ctx.lineTo(colX(cu.col,W,n),rowY(cu.row,ROWS));
        }
        ctx.stroke();
        ctx.globalAlpha=1;
      });
      ctx.lineWidth=1.5;
    }

    ctx.font='500 13px Pretendard,-apple-system,sans-serif';
    ctx.textAlign='center'; ctx.fillStyle='rgba(0,0,0,0.7)';
    for(var c=0;c<n;c++) ctx.fillText(P[c],colX(c,W,n),30);

    ctx.font='12px Pretendard,-apple-system,sans-serif';
    ctx.fillStyle='rgba(0,0,0,0.5)';
    for(var c=0;c<n;c++) ctx.fillText(prizes[c],colX(c,W,n),313);

    for(var c=0;c<n;c++){
      [PT,rowY(ROWS,ROWS)].forEach(function(y){
        ctx.beginPath(); ctx.arc(colX(c,W,n),y,5,0,Math.PI*2);
        ctx.fillStyle=COLS[c%COLS.length]; ctx.fill();
      });
    }
  }

  window.llStartGame=function(){
    var n=P.length;
    var grid=buildLadder(n);
    var ap=getActivePrizes(n);
    var routes=[];
    for(var i=0;i<n;i++) routes.push(traceRoute(i,grid,n));
    var results=routes.map(function(r){ return r[r.length-1].col; });
    var winnerIdx=results.indexOf(0);
    LD={n:n,grid:grid,routes:routes,results:results,prizes:ap,winnerIdx:winnerIdx};

    document.getElementById('llSetup').style.display='none';
    var g=document.getElementById('llGame'); g.style.display='flex';
    document.getElementById('llResult').style.display='none';
    btnTrace.textContent='Show Result'; btnTrace.disabled=false;
    busy=false;
    setTimeout(function(){ drawFrame(null); },30);
  };

  window.llGoSetup=function(){
    if(animId) cancelAnimationFrame(animId);
    busy=false;
    document.getElementById('llGame').style.display='none';
    document.getElementById('llSetup').style.display='flex';
    document.getElementById('llResult').style.display='none';
    llRenderP(); llRenderZ();
  };

  window.llDoTrace=function(){
    if(busy) return;
    busy=true;
    btnTrace.disabled=true; btnTrace.textContent='Tracing...';
    document.getElementById('llResult').style.display='none';
    var start=performance.now(), dur=1600;
    function step(now){
      var raw=Math.min(1,(now-start)/dur);
      var t=raw<0.5?2*raw*raw:-1+(4-2*raw)*raw;
      drawFrame(LD.routes.map(function(pts,i){ return {pts:pts,color:COLS[i%COLS.length],p:t}; }));
      if(raw<1){ animId=requestAnimationFrame(step); }
      else {
        var wi=LD.winnerIdx;
        document.getElementById('llRName').textContent=P[wi]+'!';
        document.getElementById('llRMsg').textContent='"'+LD.prizes[0]+'" Winner :)';
        document.getElementById('llResult').style.display='block';
        btnTrace.textContent='Retrace'; btnTrace.disabled=false;
        busy=false;
      }
    }
    animId=requestAnimationFrame(step);
  };

  llRenderP(); llRenderZ();
})();
</script>
