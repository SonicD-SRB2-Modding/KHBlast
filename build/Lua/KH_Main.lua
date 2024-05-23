addHook("ThinkFrame", function()
	local clientplayer
	if netgame then
		if server.mo and server.mo.valid then
			clientplayer = server
		else
			for p in players.iterate do
				if IsPlayerAdmin(p) and p.mo and p.mo.valid then
					clientplayer = p
					break
				end
			end
		end
	else
		clientplayer = players[0]
	end
	
	for p in players.iterate do
	
		if p.bot then
			if clientplayer.powers[pw_super] and not (p.powers[pw_super]) then
				P_DoSuperTransformation(p, false)
			end
			p.rings = clientplayer.rings
		end
		
		if p.kh.infotimer and (p.kh.infotimer > 0) then p.kh.infotimer = $ - 1 end
		
		if p.kh.target then
			if not p.kh.target.valid then p.kh.target = nil end
		elseif pboss and pboss.valid then
			p.kh.target = pboss
		end
		
		if p.bot and (p.mo.health > 0) and (not p.kh.down) and (p.hp <= 0) then p.hp = p.maxHP end //Heals up Tails when he respawns
		
		//Check for skin changes, and change stats accordingly
		
		if p.lastEmeralds == nil then p.lastEmeralds = 0 end
		
		if p.kh.down then
			p.pflags = $ | PF_FULLSTASIS //They can't move at all
			p.kh.revivalTimer = $ - 1
			p.powers[pw_underwater] = p.kh.revivalTimer
			if p.kh.revivetimer == 0 then
				p.mo.health = 0 
				p.hp = 0
				p.kh.down = false //Dead, not Downed
				P_DamageMobj(mobj, null, null, 1, DMG_SPACEDROWN)
			end
		elseif p.kh.revivalTimer != REVIVETIME then 
			p.kh.revivalTimer = REVIVETIME
		end
		
		if p.kh.lasthp and p.kh.lasthp > p.hp then
			p.kh.lasthp = $ - 1
		elseif (not p.kh.lasthp) or (p.kh.lasthp and p.kh.lasthp < p.hp) then
			p.kh.lasthp = p.hp
		end
		if p.kh.itempickuptimer > 0 then 
			p.kh.itempickuptimer = $ - 1 
			if p.kh.itempickuptimer == 0 and p.kh.itempickuptext then p.kh.itempickuptext = nil end
		end
		
		//Mana regen
		if p.mp == 0 then
			p.mpTic = $ - 12 //MP recharges 12x faster when in MP Recharge
			if p.mpTic <= 0 then
				p.mpTic = $ + 50
				p.mpRecharge = $ + 1
				if p.mpRecharge == p.maxMP then
					p.mp = p.maxMP
					p.mpRecharge = 0
					p.mpTic = 50
				end
			end
		elseif p.mp < p.maxMP then
			p.mpTic = $ - 1
			if p.mpTic <= 0 then
				p.mpTic = $ + 50
				p.mp = $ + 1
				if p.mp == p.maxMP then
					p.mpTic = 50
				end
			end
		end
		
	end
	
end)

addHook("TouchSpecial", function(mo, touch)
	if mo.valid and touch.valid and touch.player then
		local p = touch.player
		if p.mp == 0 then
			p.mpRecharge = $ + 5
			if p.mpRecharge >= p.maxMP then
				p.mp = p.maxMP
				p.mpRecharge = 0
				p.mpTic = 50
			end
		elseif p.mp < p.maxMP then
			p.mp = min(p.maxMP, $ + 5) //Special Stage Tokens always grant 5 Rings of RP charge
			if p.mp == p.maxMP then
				p.mpTic = 50
			end
		end
		p.kh.itempickuptimer = TICRATE * 6
		if All7Emeralds(emeralds) then //Tokens give 50 Rings, and a Continue (but only if the player has less than 7 of them) if all emeralds are collected
			p.kh.itempickuptext = "a Drive Token!"
			P_GivePlayerRings(p, 50)
			if p.kh.lastdp > p.rings and p.powers[pw_super] then 
				p.kh.lastdp = $ + 50
			end
			if p.continues > 6 or p.bot then
				S_StartSound(p.mo, sfx_token)
				P_KillMobj(mo, touch, touch)
				return true
			end
		else
			p.kh.itempickuptext = "a Special Stage Token!"
		end
	end
	return false
end, MT_TOKEN)

addHook("TouchSpecial", function(mo, touch)
	if mo.valid and touch.valid and touch.player then
		local p = touch.player
		if not p.powers[pw_super] then P_GivePlayerRings(p, 1) end
		if p.mp == 0 then
			p.mpRecharge = $ + 1
			if p.mpRecharge >= p.maxMP then
				p.mp = p.maxMP
				p.mpRecharge = 0
				p.mpTic = 50
			end
		elseif p.mp < p.maxMP then
			p.mp = min(p.maxMP, $ + 1)
			if p.mp == p.maxMP then
				p.mpTic = 50
			end
		end
		S_StartSound(mo, sfx_s3k33)
		if (mapheaderinfo[gamemap].typeoflevel & TOL_NIGHTS) then P_DoNightsScore(p) end
		P_KillMobj(mo, touch, touch)
		return true
	end
end, MT_RING)

addHook("TouchSpecial", function(mo, touch)
	if mo.valid and touch.valid and touch.player then
		local p = touch.player
		if not p.powers[pw_super] then P_GivePlayerRings(p, 1) end
		if p.mp == 0 then
			p.mpRecharge = $ + 1
			if p.mpRecharge >= p.maxMP then
				p.mp = p.maxMP
				p.mpRecharge = 0
				p.mpTic = 50
			end
		elseif p.mp < p.maxMP then
			p.mp = min(p.maxMP, $ + 1)
			if p.mp == p.maxMP then
				p.mpTic = 50
			end
		end
		S_StartSound(mo, sfx_mario4)
		if (mapheaderinfo[gamemap].typeoflevel & TOL_NIGHTS) then P_DoNightsScore(p) end
		P_KillMobj(mo, touch, touch)
		return true
	end
end, MT_COIN)