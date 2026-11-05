"""Puzzle solver including removable wood, armed sentries and chart collection."""
from collections import deque
D = {'>':(1,0), '<':(-1,0), '^':(0,-1), 'v':(0,1)}
def solve(rows, enemies=(), trace=False, forbid_loops=False):
    charts={(x,y):i for i,(x,y) in enumerate(( (x,y) for y,r in enumerate(rows) for x,c in enumerate(r) if c=='*'))}
    wood=[(x,y) for y,r in enumerate(rows) for x,c in enumerate(r) if c=='B']
    start=next((x,y) for y,r in enumerate(rows) for x,c in enumerate(r) if c=='P')
    def tile(p):return rows[p[1]][p[0]]
    q=deque([(start,0,0,0,'',[])])
    seen=set()
    while q:
        pos,mask,broken,sunk,route,path=q.popleft()
        state=pos,mask,broken,sunk
        if state in seen:continue
        seen.add(state)
        for key,(dx,dy) in D.items():
            x,y=pos;m=mask;b=broken;s=sunk;vis=set();walk=[];out=''
            while (x,y,dx,dy) not in vis:
                vis.add((x,y,dx,dy));p=(x+dx,y+dy);c=tile(p)
                if c=='#':break
                if p in wood and not b>>wood.index(p)&1:b|=1<<wood.index(p);break
                x,y=p;walk.append((x,y,dx,dy))
                for i,(ex,ey,face) in enumerate(enemies):
                    if (ex,ey)==p:s|=1<<i
                if p in charts:m|=1<<charts[p]
                danger=False
                for i,(ex,ey,face) in enumerate(enemies):
                    if s>>i&1:continue
                    ax,ay=D[face]
                    for dist in range(1,4):
                        target=(ex+ax*dist,ey+ay*dist)
                        if tile(target)=='#' or (target in wood and not b>>wood.index(target)&1):break
                        if p==target:danger=True
                if c=='X' or danger:out='X';break
                if c=='G':out='G';break
                if c in D:dx,dy=D[c]
            else:
                if forbid_loops: out='X'
            if out=='G':
                if m==7:return (route+key,path+walk,s) if trace else route+key
            elif out!='X':q.append(((x,y),m,b,s,route+key,path+walk))
    return None
