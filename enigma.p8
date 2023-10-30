pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
--enigma
--made with ♥
--by athur, lucas and remy

function _init()
	create_plr()
	create_mob1()
	create_mob2()
	init_msg()
	state=0
end


function _update60()
	if (state==0) update_game()
	if (state==1) then
	 update_over()
	end
end


function update_game()
	if not messages[1] then
		update_plr()
		update_mob1()
		update_mob2()
		update_explo()
	end
	update_cam()
	update_msg()
	update_blt()
end



function _draw()
	if (state==0) draw_game()
	if (state==1) draw_over()
end


function draw_game()
	cls()
	draw_map()
	draw_mob1()
	draw_mob2()
	draw_explo()
	draw_blt()
	draw_plr()
	draw_ui()
	draw_msg()
	draw_fog()
end
-->8
--player

local collision_checked=false
local invul_counter = 0 
local invul_duration = 80
local invul=false

function create_plr()
	plr={
		x=49,y=46,
		ox=0,oy=0,
		start_ox=0,start_oy=0,
		anim_t=0,
		sprite=1,
		chest=0,
		key=0,
		life=3
	}
end


function draw_plr()
	spr(plr.sprite,
	plr.x*8,
	plr.y*8,1,1,plr.flip)
end


function update_plr()
	local newx=plr.x
	local newy=plr.y
	if plr.anim_t==0 then
		newox=0
		newoy=0
		if (btn(➡️)) then
		 newx+=1
		 newox=-8
		 plr.sprite=1
		 plr.flip=false
		elseif (btn(⬅️)) then
		 newx-=1
		 newox=8
		 plr.flip=true
		elseif (btn(⬇️)) then 
			newy+=1
			newoy=-8
		elseif (btn(⬆️)) then 
			newy-=1
			newoy=8
		elseif (btnp(❎)) then
			shoot()
			sfx(3)
		end
	end
	interact(newx,newy)

	if not check_flag(0,newx,newy)
	and (plr.x!=newx or plr.y!=newy) then
		plr.x=mid(0,newx,127)
		plr.y=mid(0,newy,63)
		plr.start_ox=newox
		plr.start_oy=newoy
		plr.anim_t=1
	end
	
	--animation
	plr.anim_t=max(plr.anim_t-0.125,0)
	plr.ox=plr.start_ox*plr.anim_t
	plr.oy=plr.start_oy*plr.anim_t
	
	if plr.anim_t >=0.5 then
		plr.sprite=2
	else
		plr.sprite=1
	end
	if not collision_checked
	 and not invul then
		for m1 in all(mob1) do
		 if plr.x==m1.x and plr.y==m1.y then
	     plr.life-=1
	     sfx(6)
	     collsion_checked=true
	     invul=true
	     invul_counter=invul_duration
	  end
	 end
	 for m2 in all(mob2) do
		 if plr.x==m2.x and plr.y==m2.y then
	     plr.life-=1
	     sfx(6)
	     collsion_checked=true
	     invul=true
	     invul_counter=invul_duration
	  end
	 end
	end
	if invul then
		invul_counter-=1
		if invul_counter <=0 then
			invul=false
		end
	end
	if plr.life == 0 then
	 sfx(5)
	 state=1
	end
	collision_checked=false
end


function interact(x,y)
	if check_flag(1,x,y) then
		pick_up_key(x,y)
	elseif check_flag(2,x,y) then
		pick_up_chest(x,y)
	elseif check_flag(3,x,y) then
		open_door(x,y)
	elseif check_flag(4,x,y) then
		open_tree(x,y)
	elseif check_flag(5,x,y) then
	 next_tile(x,y)
	 sfx(8)
	end
	if x==6 and y==2 then
		create_msg("ada", "bienvenue dans enigma !", 
				"il faut nous aider,\nretrouve ma soeur plus au sud", "elle t'en diras plus")
	elseif x==10 and y==5 then
		create_msg("panneau", "direction ⬇️ :\nla prairie paisible")
	elseif x==12 and y==8 then
		create_msg("panneau", "direction ⬆️ :\nla prairie fleurie")
	elseif x==9 and y==9 then
		create_msg("lovelace", "mon papi c'est fait enlever\npar des gobelins rouges", "ils l'ont amene\nsur la montagne infernale", "il te faudra traverser toute\nla region d'enigma", "mais avant il faut deja\nque tu quittes cette prairie", "la clef du donjon\nest a cote de la cascade", "tu pourras y trouver\nde quoi traverser la foret", "bonne chance et\nramene moi mon papi")
	elseif x==30 and y==11 then
		create_msg("panneau", "direction ➡️ :\nle labyrinthe fou")
	elseif x==8 and y==19 then
	 create_msg("savant fou", "essaye ma nouvelle\ninvention !", "la pierre rouge a cote\nest un checkpoint", "a votre contact\nil s'activera", "une fois active\nsi vous mourrez", "vous y re-apparaiterez")
	elseif x==3 and y==3 and not game_started then
		create_msg("tuto", "pour passer les messages\nappuyer sur 🅾️", "pour vous deplacer utiliser\nles fleches directionnelles", "pour tirer appuyer\nsur ❎")
		game_started = true
	end
end
-->8
--map

function draw_map()
	map(0,0,0,0,128,64)
end


function check_flag(flag,x,y)
	local sprite=mget(x,y)
	return fget(sprite,flag)
end


function update_cam()
				camspeed = 0.5 
    local zonex = flr(plr.x / 32) * 32
    local zoney = flr(plr.y / 32) * 32

    local camtargetx = plr.x * 8
    local camtargety = plr.y * 8

    -- interpolation pour un deplacement fluide
    camtargetx = lerp(camtargetx, camtargetx + plr.ox, camspeed)
    camtargety = lerp(camtargety, camtargety + plr.oy, camspeed)

    local camx = mid(zonex, (camtargetx - 64) / 8, zonex + 16)
    local camy = mid(zoney, (camtargety - 64) / 8, zoney + 16)

    camera(camx * 8, camy * 8)
end

function lerp(a, b, t)
    return a + (b - a) * t
end




function next_tile(x,y)
	sprite=mget(x,y)
	mset(x,y,sprite+1)
end


function pick_up_key(x,y)
	next_tile(x,y)
	plr.key+=1
	sfx(0)
end


function pick_up_chest(x,y)
	next_tile(x,y)
	plr.chest+=1
	create_msg("coffre", "vous avez ramasse\nune hache", "faites en bon usage\nelle va bientot se casser")
	sfx(1)
end


function open_door(x,y)
	if (plr.key > 0) then
		next_tile(x,y)
		sfx(2)
		plr.key-=1
	end	
end


function open_tree(x,y)
	if (plr.chest > 0) then
		next_tile(x,y)
		sfx(4)
		plr.chest-=1
		create_msg("tronc","votre hache c'est cassee")
	end	
end
-->8
--ui

function draw_ui()
	camera()
	palt(0,false)
	palt(12,true)
	spr(0,2,1)
	print_outline("X"..plr.key,10,2,7)
	spr(16,22,0)
	print_outline("X"..plr.chest,30,2,7)
	spr(32,2,7)
	print_outline("X"..plr.life,10,9,7)
	palt()
end

function print_outline(text,x,y)
	print(text,x-1,y,0)
	print(text,x+1,y,0)
	print(text,x,y-1,0)
	print(text,x,y+1,0)
	print(text,x,y,7)
end
-->8
--messages

function init_msg()
	messages={}
end

function create_msg(name,...)
	msg_title=name
	messages={...}
end


function update_msg()
	if (btnp(🅾️)) then
		deli(messages,1)
	end
end


function draw_msg()
	if messages[1] then
		local y = 100
		--title
		rectfill(7,y,11+#msg_title*4,y+7,2)
		print(msg_title,10,y+2,9)
		--message
		rectfill(3,y+8,124,y+24,4)
		rect(3,y+8,124,y+24,2)
		print(messages[1],6,y+11,15)	
	end
end
-->8
--bullets

local blt={}

function shoot()
	local new_blt={
	 x=plr.x,
	 y=plr.y,
	 direction=plr.flip and -1 or 1,
  sprite=33,
  speed=0.7,
  timer=60
 }
 add(blt, new_blt)
end


function update_blt()
	for b in all(blt) do
  b.x = b.x + b.direction * b.speed
  b.timer-=1
  if b.timer <= 0 then
  	del(blt, b)
  end
 end
end


function draw_blt()
	for b in all(blt) do
			spr(b.sprite,b.x*8,b.y*8)
	end
end

-->8
--game over

function update_over()
	if (btn(🅾️)) _init()
end

function draw_over()
 rect(20, 35, 115, 70, 1)
 rectfill(19, 34, 114, 69, 6)

 camera(0, 0)
 print("you die ☉", 45, 40, 8)
 print("nice try", 25, 50, 7)
 print("press 🅾️/c to continue", 25, 58, 7)
 camera()
end



-->8
--mobs



--mob1

local mobcounter1=0

function add_mob1(m1x,m1y)
 m1={
  x=m1x,y=m1y,
  life=3,
  speed=30,
  sprite=43
 }
 add(mob1,m1)
end



function create_mob1()
	mob1={}
	add_mob1(13, 24)
	add_mob1(69,28)
	add_mob1(79,27)
	add_mob1(83,20)
 add_mob1(75,15)
 add_mob1(85,6)
 add_mob1(75,13)
 add_mob1(68,12)
 add_mob1(75,3)
 add_mob1(79,6)
end


function draw_mob1()
 for m1 in all(mob1) do
		spr(m1.sprite,
		m1.x*8,
		m1.y*8)
	end
end

function update_mob1()
	mobcounter1+= 1
	local lerp = 1/m1.speed
	if mobcounter1 >= m1.speed then
		mobcounter1 = 0
		for m1 in all(mob1) do
			local newx=m1.x
			local newy=m1.y
			local direction = flr(rnd(4))
			if direction == 0 then
				newy-=1
			elseif direction == 1 then
				newy+=1
			elseif direction == 2 then
				newx-=1
			elseif direction == 3 then
				newx+=1
			end
	
			m1.x = mid(0, m1.x, 127)
			m1.y = mid(0, m1.y, 127)
			if not check_flag(0,newx,newy) then
				m1.x=mid(0,newx,127)
				m1.y=mid(0,newy,63)
			end
			for b in all(blt) do
				if collision(m1,b) then
					del(blt,b)
					m1.life-=1
					create_explo(b.x+4,b.y+2)
					if m1.life == 0 then
						del(mob1,m1)
					end
				end
			end
		end
	end
end

--mob2

local mobcounter2 = 0

function add_mob2(m2x,m2y)
 m2={
  x=m2x,y=m2y,
  life=3,
  speed=30,
  sprite=45
 }
 add(mob2,m2)
end



function create_mob2()
	mob2={}
	add_mob2(10, 22)
	add_mob2(77,10)
	add_mob2(85,6)
 add_mob2(80,2)
 add_mob2(69,21)
 add_mob2(76,20)
 add_mob2(83,24)
 add_mob2(71,25)
end


function draw_mob2()
 for m2 in all(mob2) do
		spr(m2.sprite,
		m2.x*8,
		m2.y*8)
	end
end

function update_mob2()
	mobcounter2 += 1
	local lerp = 1/m2.speed
	if mobcounter2 >= m2.speed then
		mobcounter2 = 0
		for m2 in all(mob2) do
			local newx=m2.x
			local newy=m2.y
			local direction = flr(rnd(4))
			if direction == 0 then
				newy-=1
			elseif direction == 1 then
				newy+=1
			elseif direction == 2 then
				newx-=1
			elseif direction == 3 then
				newx+=1
			end
	
			m2.x = mid(0, m2.x, 127)
			m2.y = mid(0, m2.y, 127)
			if not check_flag(0,newx,newy) then
				m2.x=mid(0,newx,127)
				m2.y=mid(0,newy,63)
			end
			for b in all(blt) do
				if collision(m2,b) then
					del(blt,b)
					m2.life-=1
					create_explo(b.x+4,b.y+2)
					if m2.life == 0 then
						del(mob2,m2)
					end
				end
			end
		end
	end
end
-->8
--collision

function  collision(a, b)

	if a.x+8 > b.x and a.x<b.x
	and a.y+8 > b.y and a.y < b.y+8 then	
		return true
	else
		return false
	end
end
-->8
--explosions

local explo={}

function create_explo(x, y)
	sfx(7)
	new_explo={
		x=x,
		y=y,
		timer=0
		}
	add(explo, new_explo)
end

function update_explo()

	for e in all(explo) do
		e.timer += 1
		if e.timer == 13 then
			del(explo, e)
			end
		end
end


function draw_explo()
	for e in all(explo) do
		circ(e.x, e.y, 
						e.timer/3, 8+e.timer%3)
	end
end



-->8
--fog

local fog = {}

function rectfill2(_x,_y,_w,_h,_c)
 rectfill(_x,_y,_x+max(_w-1,0),_y+max(_h-1,0),_c)
end


function blankmap()
   local ret={}
   local plrx=plr.x
   local plry=plr.y
 if plry > 8 and plry < 25 then
  plry = 8
 end
 
 if plry > 24 then 
  plry-=16
 end

 if plrx>33 and plrx<64
 and plry<33 and plry>-1 then
      for x=0,15 do
       if x<plrx-2 or x>plrx+2 then 
        ret[x]={}
         for y=0,15 do
          if y<plry-2 or y>plry+2 then
           ret[x][y]=1
          else
           ret[x][y]=0
          end
         end
       end
   end
    end
    return ret
end


function draw_fog()
 if plr.x>33 and plr.x<64
 and plr.y<33 and plr.y>-1 then
  fog = blankmap() 
     for x = 0, 15 do
   for y = 0, 15 do
    if fog[x] and fog[x][y] == 1 then
     rectfill2(x * 8, y * 8, 8, 8, 0)
    end
   end
  end
 end
end

__gfx__
cccccccc8804444400044444333aa333333443333333333333333333333333333b3333333333333333333333333333330000000033bbbb3333bbbb33dddddddd
cc0ccccc008888400088884033aaaa33334444333bb33333333333333333333333b33333333333333333333333333333000000003b8bbbb33b8bbbb3dddddddd
c0a0000c004471f0884471f0aaffffa344ffff4333bb33333333bb333333333333b33333333333333333333333333333000000003b3bb8133b33b813dddddddd
0a0aaaa0004ffff0004ffff0aaf1f1a344f1f143333b33b3333bb333333333b3333333333333333333373333333a3333000000003b3833133b3bb313dddddddd
c0a000a00011666600116666aaffffa344ffff4333333b33333b333333333b33333333bb333333333378733333a9a3330000000031bb3b1331bb3b13dddddddd
cc0ccc0c0011516500115165335575333355753333333b33333333333bb33b3333333bb33339333333373333333a3333000000003311113333111133dddddddd
cccccccc0091919000919190399999933cccccc3333333333333333333bb333333333b33339893333333333333333333000000003332233333322333dddddddd
cccccccc000d0010000100d033733733337337333333333333333333333b333333333333333933333333333333333333000000003344423333444233dddddddd
cccccccc11444411114200013333333333333333333333333333b33333333333333333333333333333333333333333333333333333bbbb3333bbbb3333555333
00000000140505011452000033333a333333333333333bb3333b33333333003333333333333333333333b33333333333333333333bbbaab33bb33bb335555533
0444444094050504955200003aaaa3a3333333333333bb33333b3333333099033333333333333333333b7b3332333333333333333bb3ba133b3bb31335ffff33
022aa22094444444954200004a444a44444444443b33b333333333333309a9903333a333333333a33333b3332e233333333733333b3b33133b3b3b1333f1f133
042222401444441144420000444444444444444433b3333333333333309aa890333a333333333a9a3333333332333333337a733331bb3b1331b33b1333777733
044444409444447494420000322222233222222333b333333b33333330989a9033a9a333333333a333133333333333e333373333331111333311113333766733
06666660942444419420000033333333333333333333333333333333308989033a989a333333333331c1333333333e8e33333333333223333332233333677633
0000000012212121420000003333333333333333333333333333333333000033a98889a33333333333133333333333e333333333334442333344423333d33d33
cccccccc000000009999999911111111444444444ffffff433333333333333333336663333366333333333330000000000000000008888000088880016666666
cc0cc0cc000000004444444411111111444444444f4f44443333333333333333336055633365063333333333080000800800008008a88a8008a88a8016666666
c080080c000000002224422411111111cccccccc4ffffff43393333333333333365a506336005633333333330888888008888880088888800888888016666666
08887780000cccc04444444411111111111111114f44fff4339a66333333393365059006650555633366633308a88a8008a88a80000880060008800616666666
08888780000000004224242211111111111111114ffffff436950563663693336550590665500556665006638289982882899828056556560565565616666666
c0888800000cccc0444444441111111111111111444f444460595056006a96360500995605550056055500568029920880299208665555866655558616666666
cc0880cc00000000323b332311111111111111114ffffff405a905055505896050559a55505055005050550000a2280000822a00665005086650050816666666
ccc00ccc000000003433334b11111111111111114444f4f450985505505559a500098950505550055055500500a0080000800a0000a0080000800a0016666666
566666655666666599999999c1c1c1c167767667332422333333333344444444000000001d1111d1ddddddddddddddddddd66ddddddddddddddddddd16666666
6588885665bbbb5644444444c1c1c1c11111111133424433333333332224422222200222111d1111dddddddddddddddddddddddddddddadddddddddd16666666
685555866b3bb3b622244224c1c1c1c1111111113342243333333333442222444420024411111111ddddddddddd66dddddd66ddddaaaadaddddddddd11666666
685995866bb33bb644444444c1c1c1c1111111113344423333333333442aa244442002441d111d11d6d6d6d6dd6556dddddddddd4a444a444444444451666666
685995866bb33bb642242422c1c1c1c1111111113342243333333333442222444422224411111111d6d6d6d6dd6556ddddd66ddd444444444444444451166666
685555866b3bb3b644444444c1c1c1c1111111113324443333333333444444444444444411d11111ddddddddddd66dddddddddddd222222dd222222d55116666
6588885665bbbb5632333323c1c1c1c11111111133422433333333334444444444444444d111d11dddddddddddddddddddd66ddddddddddddddddddd55511666
56666665566666653433334376677776111111113424424333333333666666666666666611111111dddddddddddddddddddddddddddddddddddddddd55555111
0000000000444400004449000000000066666666ccccccc66ccccccc77777777cccccbbb333333333333333b3333733bccccccc124335411112122120a4aa990
0000000000544600004544000000000066666666ccccccc66ccccccc77777777ccbbbb3333733333333733bb3333333bccccccc1332b34411451144109b3a9a0
0069440000694400446944554469445566666666cccccc6666cccccc77777777cbb333333333333333333bbc373333bbcccccc115222b452444244520a39aa40
0069460000694600666946646669466466666666cccccc6666cccccc77777777cb3333733333733333333bbc333333bbcccccc152442421153b4333b0499a340
0044440000444400444444494444444966666666cccccc6666cccccc77777777cb3333333333337333333bbc337333bbcccccc15424434123b22453404494320
0044550000445500994455449944554466666666ccccc666666ccccc77777777bb33333333333333373333bc33333bbbccccc1153bb5344232244b440aaa9aa0
0066440000000000000000000000000066666666cc666666666666cc77777777b333733333333333333373bb33bbbbbbcc1111552243354143242b220a239aa0
0044440000000000000000000000000066666666666666666666666677777777b3333333333333333333333bbbbbbbbb111555554244b2122352432402934990
00000000000000000000000000444400555555556666666666666666bbbb6666bbbbccccbbccccbbb3373333b337333366666bbb212b4424aa3aa99a42342532
0000000000000000000000000054460055555555cc666666666666cc333bbb66333bbbcc3bbbbbb3bb333333b333333366bbbb33145334229934a9aa22b24234
0069445544694400446944550069440055555555ccccc666666ccccc33333bb633333bbc333bbb33cbb33333bb3333336bb3333324435bb3aa49aa3444b44223
0069466466694600666946640069460055555555cccccc6666cccccc333333b6333333bc33333333cbb33333bb3337336b33333321434424a399a432435422b3
0044444944444400444444490044440055555555cccccc6666cccccc337333bb337333bb73333373cbb33373bb3333336b373333112424424b394422b3334b35
0044554499445500994455440044550055555555cccccc6666cccccc3333333b3333333b33333333cb333333bbb33333bb333373254b2225aaaa9aaa25442444
0000000000000000004494000066440055555555ccccccc66ccccccc3333333b3337333b33337333bb337333bbbbbb33b33333331443b233aa249aa914411541
0000000000000000004644000044440055555555ccccccc66ccccccc3337333b3333333b33333333b3333333bbbbbbbbb3333333114533429294499921221211
00444900004449000000000000000000b3bb3bbbccccccc66ccccccc5555555855555555333333333333733bcccccccc66666661555555556666666111155555
004544000045440000000000000000003f33f333cccccc6666cccccc55555595555a999573333733333333bbcccccccc666666615d5445d56666666166111555
006944554469440000445444449444004fff6444cccccc6666cccccc5555958555a5955533333333333333bbcccccccc66666611d6d22d6d6666666166661115
006946646669460000944446466645004ffff444cccccc6666cccccc5559555559555aa933333333337333bbcccccccc66666615542552456666666166666615
004444494444440000964944444444004ffff444cccccc6666cccccc555a55555595595933337333333333bbcccccccc66666615542552456666666166666615
004455449944550000464444444964004ffff444cccccc6666cccccc55a595555a85855a33333333333333bbcccccccc66666115d6d22d6d6666666166666611
004444000046440000445400004544004ffff444cccccc6666cccccc55a5555555aa58553bbbbb333333333bc111111c661111555d5445d56666666166666661
00544400004644000044940000459900d6677dddccccccc66ccccccc5555555555558595bbbbbbbb3333373b1155551111155555555555556666666166666661
55555555555555550046540000644400cccccccc66666666cccccccc3b6666663bccccccbbbbbbbbb33333336666666644444444444444441111111155551111
566666655d5445d50046640000645500ccccccccc666666cccccccccbb666666bbcccccc33bbbbb3bb3333336666666644444a44444444446666666655511666
56066065d5d55d5d0044449444444400ccccccccccccccccccccccccb6666666bccccccc33333333bb337333666666664aaaa4a4444444446666666655116666
5dddddd5545555450059466644469400ccccccccccccccccccccccccb6666666bccccccc33733333bb333333666666665a555a55555555556666666651166666
55d00d55545555450054444494449400ccccccccccccccccccccccccbb666666bbcccccc33333333bb3333336666666655555555555555556666666651666666
50dddd05d5d55d5d0046449464544400ccccccccccccccccccccccccbb666666bbcccccc33373333bb3333736666666642222224422222246666666611666666
500000055d5445d50000000000000000ccccccccccccccccc666666c3b6666663bcccccc33333373bb3333336111111644444444444444446666666616666666
55555555555555550000000000000000cccccccccccccccc666666663b6666663bcccccc33333333b33733331155551144444444444444446666666616666666
00660666060006666660006066666666666600060000000000001a1a1a1a1a1a2a49494927343434343434343434243424342434343434343434243434343434
06500655650005555560005666666666660008060000000019000000000000190000000000000000000000000000000000000000000000000000000000000000
05000055500000555500000566666666660aaa060000000000001a1a1a1a1a1a4949494949494949494949494949494949494949494949494949494949494918
00066005000066055000660066666666660899060000000019000000000000190000000000000000000000000000000000000000000000000000000000000000
06065500060055000005566066666666660890060000000000000000001a2a1a4949494949494949181818181818281849494949491849080808181818181818
65005006056050066000505666666666660000660000000019000000000000190000000000000000000000000000000000000000000000000000000000000000
6550006505500065566600556666666666666666000000000000000000002a4949494949494908181818181818282828494949494908080808f7e7e7e7f61818
65506655055000555556005511111111666666660000000019000000000000190000000000000000000000000000000000000000000000000000000000000000
65555065666666660556056016666666aa99aa8800000000000000000000004949494949490808f7e7e7e7e7e7f62828284949490909f7e7e719191919e62929
000000006666666600560560166666669aa990a60000001919000000000000190000000000000000000000000000000000000000000000000000000000000000
65006555666666665600000016666666aa9988aa000000000000000000000000494949490808f719194819484819f6282849490909f719191919481948e62929
65506555666666665556005616666666aa8988aa0000001919000000000000190000000000000000000000000000000000000000000000000000000000001919
6500065566666666000005601666666698888a980000000000000000000000004949490908f7191919193819194819f628284928f74819194819191919e62828
000000656666666605600560166666669088a0990000196b19000000000000190000000000000000000000000000000000000019001900191900000000190019
655500006666666605560556166666668aaaaaaa00000000000000000000000049490909f719481919c6293a19191919f62828283a1919481919193819e62828
065065556666666605560000166666669688988a0000196b19000000000000190000000000000000000000000000000000001900000000000000190019000000
0006555500000555555660001666666600000000000000000000000000000000494909f719484819c62929293a19194819f62828093919191938c6183919f628
55006650055506655560005516666666000000000000006b196b6b6b000000190000000000000000000000000000000019000000000000000000001900001900
500056500665500656000056166666660000000000000000000000000000000049490939191919e629292929293a19191919f62809394819c6181818394819f6
65065060000560000000500016666666000000000000006b6b191919191919190000000000000000000000000000190000000000001919000000191900000000
060060650006000000055600116666660000000000000000000000000000000049490939191919e629292929292939194819e618093919e6181849183a191919
055000065500055505006656511166660000000000006b6b6b191919191919190000000000000000000000000000000000000000191900000000000000001900
655506556500055605500566555511660000000000000000000000000000000049490939194819e629294949292939194819c618093919e629294928283a1919
666500650605066005660600555555110000000000006b0000000000001919190000000000000000000000000000000000001900000000001900001900190000
000000000000000000000000000000000000000000000000000018181818181809090939191919e629294949292939484819181809391919f618184949283a19
00000000000000000000000000000000000000000000000000000000000019190000000000000000000000001900001900000000190000190000000000190000
00000000000000000000000000000000000000000000000000000018181818181809f719194819e629292949292939191919f60a0a3a194819f628284949283a
28000000000000000000000000000000000000000000000000000000000019190000000000000000000000001900000000000000000019000000001919190000
000000000000000000000000000000000000000000000000000000181818181808f719194819481929292929292939191919e60a0a0a3a194819f62828282828
28000000000000000000000000000000000000000000000000000000000019190000000000000000001919000000000000000000191900000000000019000000
0000000000000000000000000000000000000000000000000000001818181818f7194819191919c62929292929293a194819e62949290939191919f628282828
00000000000000000000000000000000000000000000000000000000000019190000000000000000000000000000000000000000190000000000191900000000
0000000000000000000000000000000000000000000000000000000000000000191919191948e62929292949292929391919e62929290939191948e628282828
00000000000000000000000000000000000000000000000000000000000019190000000000190000001900000000000000000000191900000000000000000000
0000000000000000000000000000000000000000000000000000000000000000194819481919e62929292949292929391919e62929290939191948e629292928
28000000000000000000000000000000000000000000000000000000000019190000190000000019191919191919191919191919000019190000000000000000
0000000000000000000000000000000000000000000000000000000000000000191919191919c62929494949292929391919e62929290939481919c629292929
00000000000000000000000000000000000000000000000000000000000019190019000000000000001900000000001919000019000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001919191919e6292929494949492929391948e629294909391919e62929494929
00000000000000000000000000000000000000000000000000000000001919190019000000190000191900001919191900000019000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000003a19191919e6292929294949292929394819e629292909394819e62929492929
00000000000000000000000000000000000000000000000019191919191919190019000000190000191919191900000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000001a1a1a1a1a0a3a191919e62929494929292929f7191919e629290a0a3a1919e62929292929
00000000000000000000000000000000000000000000000000000000001919190019001900191919000000000000191919000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000490a3a1919e6292949094929292939191919e62929090a093919e62929494949
00000000000000000000000000000000000000000000000000000000001919190000000000001900001919190019190000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000049490a3919e6292929292909092939191919e629280929093a1919f629292929
00000000000000000000000000000000000000000000000000000000001919190000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000004949093919c629292929290a0a293a19191919f62928490a093a1948f6292929
00000000000000000000000000000000000000000000000000000000191919190000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000049490839e62929490a0a0a0a0a292948191919e62828490a0a09f21919f62929
00000000000000000000000000000000000000000000000000000000191919190000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000004908f719e6292949490a0a0a0a29293a191919e6282828180808f21948e62a2a
00000000000000000000000000000000000000000000000000000000191919190000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000001a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a09f71948e6292a492a2a490a0a0a290a3a191948f628181818f7191919e62a2a
00000000000000000000000000000000000000000000000000000000191919190000000000000000000000000000000000000000000000000000000000000000
00000000000000000000001a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a09391948e62a2a2a2a4949490a490a0a0a3a191919e7e7e7e719481938c62a2a
00000000000000000000000000000000000000000000000000000000191919190000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000009391919c62a2a2a2a2a2a492a49492a0a0a3a3819481919191938c62a2a2a2a
00000000000000000000000000000000000000000000000000000000191919190000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000093919c62a2a2a49492a2a2a2a2a2a2a2a0a0a0a3a38383838c61a1a2a49492a
00000000000000000000000000000000000000000000000000000000191919190000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000009f3c62a2a2a2a4949494949492a2a2a2a4949491a1a1a1a1a1a2a2a2a2a4949
19191919191919191919191919191919191919191919191919191919191919190000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000101000000000000000001010001090002000000000000000000010101110001010100010101010102020202002000010101110005000100000002000001010101010101010000000000010101010101010101010000000000000100010101010101010100000000000000000000000101010101010100000002000000
0000000000000001000000010000000100000000000000010000000100000001000000000000000000000000000000000000000000000000000000000000000000000001000000010000000100000001000000010000000100000001000000010000000000000000000000000000000000000000000000000000000000000000
__map__
0d1d1e1d1d1e0d0e1e1d0d1e1e0e1e0d1e0e1d0d1e1d0d1e1e33333333131b1d0562434343434352434343514343524343434343434343434343434343434343634e4e4e4e4e4e4e4e4e0c0c0c4e4e4e4e4e4e4e4e4e4e4d36363636919191914444474747474747444444444444444444444444444444444444445b4917091a
0d1e0d090d0d1e19091b3605360a09361a361b091e0d0e1d1e343434340d1c1e1d53707171717053707171717170537071705043436371707153717171717c71535d716d6d6d7171715d0c0c0c4d7171716d6d6d6d6d714d36363636919136444747474744444747474444444444445c797979795744444444444464645b490b
1d1e05161b360436361609361a363616361b36160b050b0d1d2323232307361e1e53715043434373715043434343737140717171705371407153715043434343615d6d6d706d6d71715d0c0c0c4d7171716d7070706d714d363636363636364447474444444447444444444444445c1708494949497979574444444444645b49
0d0d1919363636360536360a36191c361a360b0a091b1c090e2323231e360e1d0e53707171717171707171707171717060435251715371537153707171717171535d6d703d706d71715d5f5f5f4d7171716d703d706d714d363636363636364444444444444444444444445c797949054949494949490549574444444444647a
1e1d0a1a16360a19360a363609161a36190a363636151c1e2423231e0d0b361d1d53716243434343434363716243434373705370715371537160434343435171535d6d6d706d6d717171717171717171716d7070706d714d363636363636364444444444445c7979797979494949494949494916494949496a4444444444445b
1e1d0d1b361c09361a362236361b0a360936161a361c09242323231d1a1d070e0e53715370717171717153715370717171717263714171537153707171717170535d716d6d6d71717171717171717171716d6d6d6d6d714d36363636363636444444445c79494949494949494949494949164932494949494b44444747474464
0d1d082424241b0a24242425242424242424360b0a1b242323230d1d1e0d361d1e5371533636360b3636537053716243637170537071705371724343434351715d5f4e4e4e4e4e4e4e4f7171714f4e4e4e4e4d717171714d363636363636364444445c49494949494949494949054949696925694908494b6447474747444444
1d2424232323242423232325232323232323242424242323233636363636360d1d417041367136367136724373704171726371724343436170717171717171705d71717171717171714f7171714f717171714d717171714d3636363636363644445c494949494949494908494949694b646425645b4b64644447474747444444
2423230d1e23232323233636323636362323232323232323363607360d1d1e1e080d367136713671713670361b713671365370717171707243434343434343515d71717171717171714f7071704f717171715d4e4e4e4e4d4e363636363636495c4949494949494949696969694b646444472544646444444747474747474456
23231d36363615363603363636360836363636363636363636363636360d0e070e1e703636361b36713636367171710b6242434343637170117171717170711171717171717171717170712f717071717171116d116d116d113636363636364949494949174949494b6464646464444447472555444444444747474747474466
0d1d0e36363636363636363636363636363636073636363606363636360d1e0d1e07707171713671707171717171700b537071717153716251717150517162515d7171717171717171712f702f71717171715d5f5f5f5f4d4e363636363636494949494949494b64644444444444444456752558554444444747474747444466
1e1e3636363636363636363606363636363636363636363636363636361d320e3616703636360a71710a0a717171707172637140705371537171717171705370405d7171717171717170712f7170717171715d0c0c0c0c4d363636363636364949494949496a644444474756757575757448256a654444444447474744444466
0e3636360736363616363636363636363636363636363636363636363636363536197036367171710a3671713671717171537160437371537071717162437371535d717171717171714f7071704f717171715d0c0c0c0c4d363636363636364949494949496a77444447567474485959590c494b654444444444444444445674
1d16363636363636363636363608363636363636363636361636363636360d1e190a7036160a3671713671713671367115537153717171724343434373707171535d717171717171714f7171714f717171715d0c0c0c0c4d3636363636363649494949490d495744444466744849051609494b64745544474747444444567448
0e0d3636363636363636363636363636363636360636363636363636360d1e1d1e0d703636367171361b36717170713615537153704071717171717171716243615f5f5f5f5f5f5f4d4f7171714f5d5f5f5f4d0c0c0c0c4d3636363636363649494949491d1e6a44444466481b490a49494b6474747455474747444456744849
0d1e1d36363636363636063636363636163636363636363636363636361d1e0e1d1d363636717170713671363671367171537072436170624363704070627370530c0c0c0c0c0c0c5d71717171714d0c0c0c0c0c0c0c0c4d3636363636363649494949490d1d6a444456745a494949054b647474747474554747475674745a49
1d1b0d073636363636363636363636363636363636363636363636360e1e070e1a1e1d0a361b3671197136717171367136537171717243737060436171537171530c0c0c0c0c0c0c5d71717171714d0c0c0c0c0c0c0c0c4d3636363636363617494949220d494b445674745a0c490d1d64747474485958745544446674484949
1e1a080d3636360736363636363636363636363636363636363636070d1d1c1a091e0d1515367171717136711b36717071604351707170717153705371537062730c0c0c0c0c0c0c5d71717171714d0c0c0c0c0c0c0c0c4d36363636363636494949490d1d6a644466744849491e0d0d747474745a054a7474554466745a4949
0e1d1d0e3636363636363607363636363636360736363636363636360d1e0b1c190d1e36153619367136367171717171715371717171407171537153715371530c0c0c0c0c0c0c0c5d71717171714d0c0c0c0c0c0c0c0c4d3636363636363649491e1e1d1d4b4456740d1b49490d1d0d747474745a49495958747574745a494b
39393939393936301f363636363636363639393939393936063636361e1e0d1a0d1d1d36713636363636713636157171365370504343425171537153714171530c0c0c0c0c0c0c0c5d71717171714d0c0c0c0c0c0c0c0c4d363636363636361d1e1d69694b644466745a49051a0d1e64747474745a4918494958747448494b64
390f0f0f3c393939393636363636393939390f3c0f0f3936363636360d0d1d1e1e0d3671713636711515157136157171175371717071717170417153717071530c4e4e4e4e4e4e4e707171717171704e4e4e4e4e4e4e4e4d36363636363636446464646464444466745a491e256464747474485949494949694b74745b4b6474
393a3a3a3b3a3a3a393939113939393a3a3a3a3b3a3a393636363636360d1d1d0d7015717036711b7162434343434343434243434343435171717072435170530c5d7171717171717171717171717171717171717171714d36363636363636444444444444474746741d4b6425747474744849054949694b6464747464647474
390f0f0f3c0f0f0f0f0f0f3c0f0f0f0f0f0f0f3c0f0f39363607363636360d0e1d193671713671361553707171717171717171717071717170407171717071530c5d7171717171717171717171717171717171717171714d36363636363636444444474747474744666464742574747448494949494b64647474747448587474
390f0f0f3c0f0f0f0f0f0f3c0f0f0f0f0f0f0f3c0f0f39363636363636360e1e1e0d3636717171363653715043434343434343435243434343434343435171530c5d7171717171715d4e4e4e4e4e4d71717171717171714d363636363636364444474747474747476674747425744859494949494b64747476747448694b7474
390f0f0f3c0f0f0f0f0f0f3c0f0f0f0f0f0f0f3c0f0f39363636053606360e1e1d1d367171713609705370717171717171717170537170717171717171707172635d7171717171715d0c0c0c0c0c4d71717171717171714d3636363636363644474747474444445674747448255949494949494b647474454446746464647474
393939393b3a3a3a3a3a3a3b3a3a3a3a3a3a3a3b3a3a393939363636361e1d0e1d1e710936717171624263705043434343436371537162435243517062517170535d71716d706d715d0c0c0c0c0c4d71716d7070706d714d363636363636364447474747444456747474745a4949494949694b647445444747446674746b6b4c
390f0f0f3c0f0f0f0f0f0f3c0f0f0f0f0f0f0f3c0f0f393739063636361d080d6243434343435243617153717171717171705371537153705371717153707150615d716d706d706d5d0c0c0c0c0c4d7171706d6d6d70714d3636363636363644474747444456747448595949494949694b646474454447474756746b4c545454
390f0f0f390f0f0f0f0f0f3c0f0f0f0f0f0f0f3c0f0f390f39363636360d1e1d5371717171705370537153705043524343437371537060436170624342637170535d71706d3d6d705d0c0c0c0c0c4d7171706d3d6d70714d363636363636364447475675757474484949494949694b646474744544474747476b4c5454545468
393d0f0f39393939390f0f3c0f0f0f0f0f0f0f3c0f0f110f39361d3606161d0d5371407140715371417172434343617071717170724361704171537170537150615d716d706d706d5d0c0c0c0c0c4d7171706d6d6d70714d36363636363636447575744859595949494949494b6464747445444444447b7b6c54685454675454
39393939393636053939393939393939393939393939393939051d1d1c1b081d5371537053715371717071717170417140714071717053717171537162537170535d71716d706d715d0c0c0c0c0c4d71716d7070706d714d363636363636364448595949494949494949494b6474747445474747476c54545467545454545454
06173636363636363606363617363636360536361736363636360d1e1d1e0e1e5370537c53717243434343435171717153716043434373715043617172425171535d7171717171715d0c0c0c0c0c4d71717171717171714d3636363636363644444949494949494949496a64747447474447477b6c5454545454685454546754
2726282a272a2a2826292a272a282a262a27292a262a28292a2628272a292a287243424361717171717171717171624361715370717171717170537071717171535f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f3636363636363644494949494949494949494b744547474444446c54546854545467545454545454
__sfx__
00030000207402574026740227402870025700157001f7001c7001570014700127000170000700007003e7001570000700227001a7002e7003170022700337003070000700257000070000700007000070000700
000400001a1501b1501a1501a150191501a1501a1501c1501e1501e1501e100000000f00000000280000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000000200142501525015250122501225000200002001a2501b25019250142501120000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
000100002c6502a650236501c6501965013650106500f6500e6500c6500b6500a6500a65006600056000460004600006000160018600000000000000000000000000000000000000000000000000000000000000
00030000004001445014450144500b450004500040000400004001145013450134500040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
000a0000000001d0501c0501a050170501405013050100500e0500c05009050060500305001050010500005000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000000000210501a050140500e0500b0500805006050040500305001050010000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000026150241501f1501a15019100211001b10014150151501515013150111500d1500c1500c1501410018100191001d100241002410002100061001e1000d1500a1500815006150071502b1000910000100
000400000115004150081500b1500d1500f10015100000001015014150171501a1501a150191001a1001c1002015023150261502715028150000000000026100281002d100311003610037100000000000000000
