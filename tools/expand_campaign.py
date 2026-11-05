"""Deterministic candidate search; retains only solvable, mechanically relevant layouts."""
import random,json,time
from pathlib import Path
from audit_routes import solve,D
rng=random.Random(204873)
def arrow_checks(rows,enemies,route):
    for y,row in enumerate(rows):
        for x,c in enumerate(row):
            if c not in D:continue
            b=rows[:];b[y]=row[:x]+'.'+row[x+1:]
            r=solve(b,enemies)
            if r and len(r)<=len(route):return False
    return True

def safe_spawn(rows,e):
    x,y,k=e;dx,dy=D[k]
    for n in range(1,4):
        c=rows[y+dy*n][x+dx*n]
        if c in '#B':break
        if c=='P':return False
    return True

def make(level):
    for attempt in range(150000):
        b=[list('#'*12)]+[list('#'+'.'*10+'#') for _ in range(7)]+[list('#'*12)]
        spots=[(x,y) for y in range(1,8) for x in range(1,11)];rng.shuffle(spots)
        tokens=['#']*rng.randint(10,17)+['X']*(2 if level<14 else 3)+['B']*(1+level%3)+['P','G','*','*','*']
        for c in tokens:
            x,y=spots.pop();b[y][x]=c
        for _ in range(2 if level<12 else 3):
            x,y=spots.pop();possible=[k for k,(dx,dy) in D.items() if b[y+dy][x+dx] not in '#X']
            if possible:b[y][x]=rng.choice(possible)
        rows=[''.join(r) for r in b]
        r=solve(rows,forbid_loops=True)
        if not r or not (7 if level<12 else 9)<=len(r)<=17:continue
        if not arrow_checks(rows,[],r):continue
        candidates=[(x,y,k) for x,y in spots for k in D if safe_spawn(rows,(x,y,k))];rng.shuffle(candidates)
        enemies=[];route=r
        for e in candidates[:100]:
            rr=solve(rows,[e],True,True)
            if rr and rr[2]==1 and len(route)<len(rr[0])<=22 and arrow_checks(rows,[e],rr[0]):
                enemies=[e];route=rr[0];break
        if not enemies:continue
        if level>=14:
            for e in candidates[:150]:
                if e[:2]==enemies[0][:2]:continue
                rr=solve(rows,enemies+[e],True,True)
                if not rr or rr[2]!=3 or not len(route)<len(rr[0])<=25:continue
                if not arrow_checks(rows,enemies+[e],rr[0]):continue
                without_first=solve(rows,[e])
                if not without_first or len(without_first)>=len(rr[0]):continue
                enemies.append(e);route=rr[0];break
            if len(enemies)!=2:continue
        exact=solve(rows,enemies)
        if len(exact)!=len(route) or not arrow_checks(rows,enemies,exact):continue
        return {'rows':rows,'enemies':enemies,'route':route,'attempts':attempt}
    raise RuntimeError('No candidate for '+str(level))

if __name__=='__main__':
    output=Path(__file__).with_name('campaign_expansion.json')
    result=json.loads(output.read_text()) if output.exists() else []
    for level in range(7+len(result),21):
        entry=make(level);result.append(entry);output.write_text(json.dumps(result,indent=2)+'\n')
        print('Level',level,'moves',len(entry['route']),'enemies',len(entry['enemies']),'attempts',entry['attempts'],flush=True)
