pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--shoot

function _init()
 init_stars()
 init_ship()
end

function _update()
 update_shots()
 update_explosions()
 update_ship()
 update_enemies()
	update_stars()
end

function _draw()
	cls(0)
	draw_stars()
	draw_shots()
	draw_enemies()
	draw_explosions()
	draw_ship()
end

-->8
--stars

nstars=100
stars={}

function init_stars()
 for i=1,nstars do
  local s={}
  s.x=rnd(128)
  s.y=rnd(128)
  s.s=rnd(3)
  s.c=true
  stars[i]=s
 end
end

function update_stars()
 for s in all(stars) do
  s.x=s.x-s.s
  if rnd(10)<1 then
   s.c=not s.c
  end
  if s.x<0 then
   s.x=128
   s.y=rnd(128)
   s.s=rnd(3)
  end
 end
end

function draw_stars()
 for s in all(stars) do
  if s.c then
   pset(s.x,s.y,6)
  else
   pset(s.x,s.y,7)
  end
 end
end

-->8
--ship

live = true
ship = {x=10,y=64}
acc = 0.5
dacc = acc / 2
sy = 0
maxs = 3
shipspr = 0
exhspr = 4

function init_ship()
end

function update_ship()
 if live then
		if btn(⬆️) then
		 sy=sy-acc
		 shipspr=2
		elseif btn(⬇️) then
		 sy=sy+acc
		 shipspr=1
		else
		 if sy > 0 then
		  sy=sy-dacc
		 elseif sy < 0 then
		  sy=sy+dacc
		 end
		 shipspr=0
		end
		if btn(❎) then
		 add_shot(ship.x+6,ship.y,2,0,12,true,0)
		end
		if sy > maxs then sy=maxs end
		if sy < -maxs then sy=-maxs end
		ship.y = ship.y + sy
		
		if ship.y<=0 or ship.y>=122 then
		 live=false
		 add_explosion(ship.x,ship.y)
		end
		
		if live then
			for s in all(shots) do
			 if not s.f then
			  if collide(s,ship) then
			   live=false
			   add_explosion(ship.x,ship.y)
			  end
			 end
			end
		end
		
		exhspr=exhspr+1
		if exhspr>7 then
		 exhspr=4
		end
	end
end

function draw_ship()
 if live then
		spr(shipspr,ship.x,ship.y)
		spr(exhspr,ship.x-8,ship.y)
	end
end

-->8
--explosions

expls={}

function add_explosion(x,y)
 local e={x=x,y=y,s=0}
 add(expls,e)
 sfx(2)
end

function update_explosions()
 local d={}
 for e in all(expls) do
  e.s=e.s+1
  if e.s>=4 then
   add(d,e)
  end
 end
 for e in all(d) do
  del(expls,e)
 end
end

function draw_explosions()
 for e in all(expls) do
  spr(8,e.x,e.y)
 end
end

-->8
--shots

shots={}
next_shot=0

function add_shot(x,y,sx,sy,s,f,fx)
 if f then
  if next_shot>0 then return end
  next_shot=10
 end
 local s={a=0,x=x,y=y,sx=sx,sy=sy,s=s,o=0,f=f}
 add(shots,s)
	sfx(fx)
end

function update_shots()
 next_shot=next_shot-1
 
 local d={}
 for s in all(shots) do
  s.x=s.x+s.sx
  s.y=s.y+s.sy
  s.a=s.a+1
  if s.a>64 then
   add(d,s)
  end
  s.o=s.o+1
  if s.o>1 then
   s.o=0
  end
 end
 for s in all(d) do
  del(shots,s)
 end
end

function draw_shots()
 for s in all(shots) do
  spr(s.s+s.o,s.x,s.y)
 end
end

-->8
--enemies

espeed=2
enemies={}

function add_enemy(x,y,s)
 local e={x=x,y=y,s=s,o=0}
 add(enemies,e)
end

function update_enemies()
 local d={}
 for e in all(enemies) do
  e.x=e.x-espeed
  if e.x<-7 then
   add(d,e)
  else
   for s in all(shots) do
    if s.f and collide(s,e) then
     add(d,e)
     add_explosion(e.x,e.y)
     del(shots,s)
     break
    end
   end
  end
  e.o=e.o+1
  if e.o>1 then
   e.o=0
  end
 end
 for e in all(d) do
  del(enemies,e)
 end
 
 for e in all(enemies) do
  if rnd(30)<1 then
   local dy=0
   if ship.y<e.y-10 then
    dy=-1
   elseif ship.y>e.y+10 then
    dy=1
   end
   add_shot(e.x,e.y,-3,dy,14,false,1)
  end
 end
 
 if rnd(50)<1 then
  add_enemy(128,rnd(128),16)
 end
end

function draw_enemies()
 for e in all(enemies) do
  spr(e.s+e.o,e.x,e.y)
 end
end

-->8
--collision

function collide(a,b)
 x1=a.x
 y1=a.y
 x2=b.x
 y2=b.y
 if x1+8<x2 then return false end
 if x1>x2+8 then return false end
 if y1+8<y2 then return false end
 if y1>y2+8 then return false end
 return true
end

__gfx__
000000000000000000000000000000000000000000000000000000000a0000000000000000000000909999990000990000000000000000000000000000000000
00000000000000007700000000000000000000000a00000000090700009900000000000009990090999999a90009990000000000000000000000000000000000
770000000000000077770000000000000090a9090090a09909a70090a0a97a99000a000009aaaaa099aaaaa90999900000000000000000000000000000000000
77777000777700007777770000000000000a079900909a99009a9aa9097a0a990a0aa000000a00a090aaaa990999990000000000000000000008000000008000
7777777777777777777777770000000000900000000900000009a00a00a00900000000000a0a9a9090aaa0a90900999000c0cc770cc0c7c70000800000080000
000000007777700000000000000000000000900000a00900009090000a090000000a00a0099990a099a9aa990099990000000000000000000000000000000000
00000000777000000000000000000000000000000000000000000000000000000000000009990900999909990090009000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000009009990000000000000000000000000000000000000000
00eeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e2222e000eeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e282282e0e2282e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e228822e0e8882e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e228822e0e2888e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e282282e0e2822e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e2222e000eeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00eeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100002d35028350243501d350173500f3500c3502150023500255001e5002550012500255002450020500175001650016500155000c500165001750019500165000f5000e5000d5000d5001a4000e00000000
0001000015050250502e05035050260501b0500f05004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000266502a65025650216501e6502d6502865024650216501f6501d650296502565025650226501c6501965021650206501c650196501865000000000000000000000000000000000000000000000000000
