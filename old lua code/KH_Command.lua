//This deals with the Command Menu

freeslot("S_BZRDF", "S_BZRDR", "S_BZRDH", "MT_BLIZARD_SHOT", "sfx_itmget")

rawset(_G, "khCommandList", {
	//{"Name" (Max 7 characters), (Base) RP cost, Use function
	[1] = {"Fire", 1, function(p)
		if p.kh.rp < khCommandList[1][2] then return false end
		local mobj = P_SpawnPlayerMissile(p.mo, MT_FIREBALL, MF2_EXPLOSION)
		if not mobj then return false end //How the heck did that even happen...?
		mobj.basedamage = 4
		if p.kh.mag then mobj.basedamage = p.kh.mag + 2 end
		S_StartSound(nil, sfx_s3k43, p)
		p.kh.rp = $ - khCommandList[1][2]
		return true
	end}, //Shoots a fireball in the direction of the camera
	[2] = {"Thunder", 2, function(p)
		if p.kh.rp < khCommandList[2][2] then return false end
		p.kh.rp = $ - khCommandList[2][2]
		S_StartSound(nil, sfx_kc49, p)
		P_RadiusAttack(p.mo, p.mo, 512*FRACUNIT, DMG_ELECTRIC)
		return true
	end}, //Unleashes a lighting bolt which hits all targets within a given distance
	/*[3] = {"Blizard", 2, function(p)
		if p.kh.rp < khCommandList[3][2] then return false end
		return false //Not yet coded in
	end}, //Shoots three iceicles in a fan pattern */
	[3] = {"Cure", 2, function(player)
		if player.kh.rp < khCommandList[3][2] then return false end
		if ultimatemode then return false end
		local cost = min(player.kh.rp, 10)
		local doesheal = false
		if player.hp < player.maxHP then
			local healval = (player.maxHP * cost) / 10
			if player.kh.mag then healval = $ + player.kh.mag end
			player.hp = min($ + healval, player.maxHP)
			doesheal = true
		end
		for p in players.iterate do
			if p == player then continue end
			if P_AproxDistance(abs(p.mo.x - player.mo.x), abs(p.mo.y - player.mo.y)) <= 768*FRACUNIT then
				if p.hp > 0 then
					if p.hp < p.maxHP then
						local healval = (p.maxHP * cost * 2) / 15
						if player.kh.mag then healval = $ + player.kh.mag end
						p.hp = min($ + healval, p.maxHP)
						S_StartSound(nil, sfx_kc42, p)
						doesheal = true
					end
				else
					p.kh.revivehp = $ + cost
					if player.kh.mag then p.kh.revivehp = $ + (player.kh.mag / 5) end
					doesheal = true
					if p.kh.revivehp >= 10 then
						p.hp = min((p.kh.revivehp * p.maxHP) / 20, p.maxHP)
						p.kh.down = false
						p.kh.downedhp = 3
						p.kh.revivehp = 0
						P_PlayLivesJingle(p)
					else
						S_StartSound(nil, sfx_kc42, p)
					end
				end
			end
		end
		if doesheal then
			player.kh.rp = $ - cost
			S_StartSound(nil, sfx_kc42, player)
		end
		return doesheal
	end}, //Heals yourself and nearby allies. Can use up to 10RP for greater effectivness
	[4] = {"Aero", 3, function(p)
		if p.kh.rp < khCommandList[4][2] then return false end
		if ultimatemode then return false end
		if (p.powers[pw_shield] == SH_WHIRLWIND) or (p.powers[pw_shield] == SH_THUNDERCOIN) then return false end
		p.kh.rp = $ - khCommandList[4][2]
		if (p.powers[pw_shield] & SH_PROTECTELECTRIC) then
			p.powers[pw_shield] = SH_THUNDERCOIN
			S_StartSound(nil, sfx_s3k41, p)
		else
			p.powers[pw_shield] = SH_WHIRLWIND
			S_StartSound(nil, sfx_shield, p)
		end
		P_SpawnShieldOrb(p)
		return true
	end}, //Grants a Whirlwind Shield
	[5] = {"Haste", 3, function(p)
		if p.kh.rp < khCommandList[5][2] then return false end
		if p.powers[pw_sneakers] then return false end
		p.kh.rp = $ - khCommandList[5][2]
		p.powers[pw_sneakers] = TICRATE * 20
		S_ChangeMusic("_shoes", false, p)
		return true
	end}, //Grants Super Sneakers
	[6] = {"Revive", 6, function(p)
		if p.kh.rp < khCommandList[6][2] then return false end
		if ultimatemode then return false end
		local getreviveplayer = false
		for player in players.iterate do
			if p == player then continue end
			if P_AproxDistance(abs(p.mo.x - player.mo.x), abs(p.mo.y - player.mo.y)) <= 768*FRACUNIT then
				if player.hp <= 0 then
					local healval = (player.kh.revivehp + 10)
					if player.kh.mag then healval = $ + (player.kh.mag /5 ) end
					local healrate = (healval * player.maxHP) / 20
					if player.kh.mag then healrate = $ + player.kh.mag end
					player.hp = min(healrate, p.maxHP)
					player.kh.down = false
					player.kh.downedhp = 3
					player.kh.revivehp = 0
					getreviveplayer = true
					P_PlayLivesJingle(player)
				end
			end
		end
		if p.kh.rp == 20 then 
			p.kh.rp = 0
			p.lives = $ + 1
			P_PlayLivesJingle(p)
			return true
		elseif getreviveplayer then
			p.kh.rp = $ - khCommandList[7][2]
			S_StartSound(nil, sfx_kc42, player)
			return true
		else
			return false
		end
	end} //Revives a dying player, and/or (at the cost of 20RP) grant a free Auto-Life
})

local ITEM_POTION = 1
local ITEM_HIPOTION = 2
local ITEM_MEGAPOTION = 3
local ITEM_GROUPPOTION = 4
local ITEM_PARTYPOTION = 5
local ITEM_ETHER = 6
local ITEM_HIETHER = 7
local ITEM_MEGAETHER = 8
local ITEM_GROUPETHER = 9
local ITEM_PARTYETHER = 10
local ITEM_ELIXER = 11
local ITEM_MEGAELIXER = 12
local ITEM_PARTYELIXER = 13

rawset(_G, "khItemList", {
	//Name, Description, Closes menu when used?, Command Function, Full Name
	[1] = {"Potion", "Heals 20HP", false, function(p)
			if ultimatemode then p.hp = min(p.maxHP, $ + 10)
			else p.hp = min(p.maxHP, $ + 20) end
			S_StartSound(nil, sfx_kc42, p)
		end, "Potion"},
	[2] = {"H.Potion", "Heals 70HP", true, function(p)
			if ultimatemode then p.hp = min(p.maxHP, $ + 35)
			else p.hp = min(p.maxHP, $ + 70) end
			S_StartSound(nil, sfx_kc42, p)
		end, "Hi-Potion"},
	[3] = {"M.Potion", "Full Heal", true, function(p)
			if ultimatemode then p.hp = min(p.maxHP, $ + (p.maxHP/2))
			else p.hp = p.maxHP end
			S_StartSound(nil, sfx_kc42, p)
		end, "Mega-Potion"},
	[4] = {"G.Potion", "Heals 40HP to party", true, function(unused) 
			for p in players.iterate do
				if p.hp > 0 then
					if ultimatemode then p.hp = min(p.maxHP, $ + 20)
					else p.hp = min(p.maxHP, $ + 40) end
					S_StartSound(nil, sfx_kc42, p)
				elseif not ultimatemode then
					p.kh.revivehp = $ + 4
					if p.kh.revivehp >= 10 then
						p.hp = (p.kh.revivehp * p.maxHP) / 20
						p.kh.down = false
						p.kh.downedhp = 3
						p.kh.revivehp = 0
						P_PlayLivesJingle(p)
					else
						S_StartSound(nil, sfx_kc42, p)
					end
				end
			end
		end, "Group Potion"},
	[5] = {"P.Potion", "Heals 90HP to party", true, function(unused) 
			for p in players.iterate do
				if p.hp > 0 then
					if ultimatemode then p.hp = min(p.maxHP, $ + 45)
					else p.hp = min(p.maxHP, $ + 90) end
					S_StartSound(nil, sfx_kc42, p)
				elseif not ultimatemode then
					p.kh.revivehp = $ + 9
					if p.kh.revivehp >= 10 then
						p.hp = (p.kh.revivehp * p.maxHP) / 20
						p.kh.down = false
						p.kh.downedhp = 3
						p.kh.revivehp = 0
						P_PlayLivesJingle(p)
					else
						S_StartSound(nil, sfx_kc42, p)
					end
				end
			end
		end, "Party Potion"},
	[6] = {"Ether", "Restores 2RP", false, function(p) 
			if ultimatemode then p.kh.rp = min(p.kh.maxRP, $ + 1)
			else p.kh.rp = min(p.kh.maxRP, $ + 2) end
			if p.kh.rp == p.kh.maxRP then p.kh.rpcahrge = 0 end
			S_StartSound(nil, sfx_kc42, p)
		end, "Ether"},
	[7] = {"H.Ether", "Restores 10RP", true, function(p) 
			if ultimatemode then p.kh.rp = min(p.kh.maxRP, $ + 5)
			else p.kh.rp = min(p.kh.maxRP, $ + 10) end
			if p.kh.rp == p.kh.maxRP then p.kh.rpcahrge = 0 end
			S_StartSound(nil, sfx_kc42, p)
		end, "Hi-Ether"},
	[8] = {"M.Ether", "Fully restores RP", true, function(p) 
			if ultimatemode then
				p.kh.rp = min(p.kh.maxRP, $ + (p.kh.maxRP/2))
				if (p.kh.maxRP % 2) == 1 then p.kh.rpcahrge = $ + 2 end
				if p.kh.rpcharge >= 5 and p.kh.rp < p.kh.maxRP then
					p.kh.rp = $ + 1
					p.kh.rpcharge = $ - 5
				end
				if p.kh.rp == p.kh.maxRP then p.kh.rpcharge = 0 end
			else
				p.kh.rp = p.kh.maxRP
				p.kh.rpcahrge = 0
			end
			S_StartSound(nil, sfx_kc42, p)
		end, "Mega-Ether"},
	[9] = {"G.Ether", "Restores 4RP to party", true, function(unused) 
			for p in players.iterate do
				if p.hp > 0 then
					if ultimatemode then p.kh.rp = min(p.kh.maxRP, $ + 2)
					else p.kh.rp = min(p.kh.maxRP, $ + 4) end
					if p.kh.rp == p.kh.maxRP then p.kh.rpcahrge = 0 end
					S_StartSound(nil, sfx_kc42, p)
				end
			end
		end, "Group Ether"},
	[10] = {"P.Ether", "Restores 12RP to party", true, function(unused) 
			for p in players.iterate do
				if p.hp > 0 then
					if ultimatemode then p.kh.rp = min(p.kh.maxRP, $ + 6)
					else p.kh.rp = min(p.kh.maxRP, $ + 12) end
					if p.kh.rp == p.kh.maxRP then p.kh.rpcahrge = 0 end
					S_StartSound(nil, sfx_kc42, p)
				end
			end
		end, "Party Ether"},
	[11] = {"Elixer", "Heals 50HP and restores 5RP", true, function(p) 
			if ultimatemode then
				p.hp = min(p.maxHP, $ + 25)
				p.kh.rp = min(p.kh.maxRP, $ + 2)
				p.kh.rpcahrge = $ + 2
				if p.kh.rpcharge >= 5 and p.kh.rp < p.kh.maxRP then
					p.kh.rp = $ + 1
					p.kh.rpcharge = $ - 5
				end
			else
				p.hp = min(p.maxHP, $ + 50)
				p.kh.rp = min(p.kh.maxRP, $ + 5)
			end
			if p.kh.rp == p.kh.maxRP then p.kh.rpcahrge = 0 end
			S_StartSound(nil, sfx_kc42, p)
		end, "Elixer"},
	[12] = {"M.Elixer", "Full Heal and RP restoration", true, function(p) 
			if ultimatemode then
				p.hp = min(p.maxHP, $ + (p.maxHP/2))
				p.kh.rp = min(p.kh.maxRP, $ + (p.kh.maxRP/2))
				if (p.kh.maxRP % 2) == 1 then p.kh.rpcahrge = $ + 2 end
				if p.kh.rpcharge >= 5 and p.kh.rp < p.kh.maxRP then
					p.kh.rp = $ + 1
					p.kh.rpcharge = $ - 5
				end
				if p.kh.rp == p.kh.maxRP then p.kh.rpcharge = 0 end
			else
				p.hp = p.maxHP
				p.kh.rp = p.kh.maxRP
				p.kh.rpcahrge = 0
			end
			S_StartSound(nil, sfx_kc42, p)
		end, "Megalixer"},
	[13] = {"P.Elixer", "Full Heal and RP restoration to party", true, function(unused) 
			for p in players.iterate do
				if p.hp > 0 then
					if ultimatemode then p.hp = min(p.maxHP, $ + (p.maxHP/2))
					else p.hp = p.maxHP end
					S_StartSound(nil, sfx_kc42, p)
				elseif not ultimatemode then
					p.hp = ((p.kh.revivehp + 10) * p.maxHP) / 20
					p.kh.down = false
					p.kh.downedhp = 3
					p.kh.revivehp = 0
					P_PlayLivesJingle(p)
				else
					continue
				end
				if ultimatemode then
					p.kh.rp = min(p.kh.maxRP, $ + (p.kh.maxRP/2))
					if (p.kh.maxRP % 2) == 1 then p.kh.rpcahrge = $ + 2 end
					if p.kh.rpcharge >= 5 and p.kh.rp < p.kh.maxRP then
						p.kh.rp = $ + 1
						p.kh.rpcharge = $ - 5
					end
					if p.kh.rp == p.kh.maxRP then p.kh.rpcharge = 0 end
				else
					p.kh.rp = p.kh.maxRP
					p.kh.rpcahrge = 0
				end
			end
		end, "Party Megalixer"}
})

rawset(_G, "khRingList", {
	[0] = "Normal",
	[1] = "Auto",
	[2] = "Bounce",
	[3] = "Shotgun",
	[4] = "Grenade",
	[5] = "Bomb",
	[6] = "Sniper"
})

addHook("ThinkFrame", function()
	if (mapheaderinfo[gamemap].typeoflevel & TOL_NIGHTS) or G_IsSpecialStage() then return end //Commands disabled in NiGHTS stages and MP Special Stages
	for p in players.iterate do
		if p.difsel == true then continue end //Skip this if the player is selecting a difficulty
		if p.kh != nil then
			if p.kh.itemlist == nil then p.kh.itemlist = {} end
			if p.kh.lastWpn == nil then p.kh.lastWpn = 0 end
			if p.kh.cOption == nil then p.kh.cOption = 1 end
			if p.kh.comButton == nil then p.kh.comButton = false end
			if (p.cmd.buttons & BT_WEAPONNEXT) then
				if not p.kh.comButton then
					if p.kh.menuMode == 0 then
						p.currentweapon = p.kh.lastWpn 
						p.kh.cOption = $ + 1
						if p.kh.cOption > #khCommandList then p.kh.cOption = 1 end
						S_StartSound(nil, sfx_menu1, p)
					elseif p.kh.menuMode == 1 then
						p.currentweapon = p.kh.lastWpn 
						if #p.kh.itemlist > 1 then
							p.kh.cOption = $ + 1
							if p.kh.cOption > #p.kh.itemlist then p.kh.cOption = 1 end
							S_StartSound(nil, sfx_menu1, p)
						else
							S_StartSound(nil, sfx_cmderr, p)
						end
					else
						S_StartSound(nil, sfx_menu1, p)
					end
				end
				p.kh.comButton = true
			elseif (p.cmd.buttons & BT_WEAPONPREV) then
				if not p.kh.comButton then
					if p.kh.menuMode == 0 then
						p.currentweapon = p.kh.lastWpn
						p.kh.cOption = $ - 1
						if p.kh.cOption < 1 then p.kh.cOption = #khCommandList end
						S_StartSound(nil, sfx_menu1, p)
					elseif p.kh.menuMode == 1 then
						p.currentweapon = p.kh.lastWpn 
						if #p.kh.itemlist > 1 then
							p.kh.cOption = $ - 1
							if p.kh.cOption < 1 then p.kh.cOption = #p.kh.itemlist end
							S_StartSound(nil, sfx_menu1, p)
						else
							S_StartSound(nil, sfx_cmderr, p)
						end
					else
						S_StartSound(nil, sfx_menu1, p)
					end
				end
				p.kh.comButton = true
			elseif (p.cmd.buttons & BT_WEAPONMASK) and ((p.cmd.buttons & BT_WEAPONMASK) <= #khCommandList) then
				if (not p.kh.comButton) then
					if ((p.kh.menuMode == 0) and #khCommandList >= (p.cmd.buttons & BT_WEAPONMASK)) 
					or ((p.kh.menuMode == 1) and #p.kh.itemlist >= (p.cmd.buttons & BT_WEAPONMASK)) then
						p.kh.cOption = (p.cmd.buttons & BT_WEAPONMASK)
						S_StartSound(nil, sfx_menu1, p)
					elseif p.kh.menuMode == 2 then
						S_StartSound(nil, sfx_menu1, p)
					else
						S_StartSound(nil, sfx_cmderr, p)
					end
				end
				p.kh.comButton = true
			elseif (p.cmd.buttons & BT_CUSTOM1) then
				if not p.kh.comButton then
					local command
					local commandused
					if p.kh.menuMode == 1 then 
						if #p.kh.itemlist > 0 then
							local item = p.kh.itemlist[p.kh.cOption]
							command = khItemList[item][4]
							if p.kh.items[item] > 0 then
								p.kh.items[item] = $ - 1
								command(p)
								if p.kh.items[item] == 0 then
									table.remove(p.kh.itemlist, p.kh.cOption)
									if #p.kh.itemlist == 0 then
										p.kh.menuMode = 0
										p.kh.cOption = p.kh.lastMagic
									elseif p.kh.cOption > #p.kh.itemlist then
										p.kh.cOption = #p.kh.itemlist
									end
								end
								if khItemList[item][3] then
									p.kh.menuMode = 0
									p.kh.cOption = p.kh.lastMagic
								end
								commandused = true
							else
								commandused = false
							end
						else
							commandused = false
						end
					else
						if p.kh.menuMode == 0 then command = khCommandList[p.kh.cOption][3]
						elseif p.kh.menuMode == 2 then command = khCommandList[p.kh.lastMagic][3] end
						commandused = command(p)
					end
					if not commandused then 
						S_StartSound(nil, sfx_cmderr, p) //Nope, can't be done!
					end
				end
				p.kh.comButton = true
			elseif (p.cmd.buttons & BT_CUSTOM2) then
				if not p.kh.comButton then
					if p.kh.menuMode == 2 or (p.kh.menuMode == 1 and not G_RingSlingerGametype()) then 
						p.kh.menuMode = 0
						p.kh.cOption = p.kh.lastMagic
					elseif (gametype == GT_COOP) and (p.kh.menuMode != 1) then
						p.kh.menuMode = 1
						p.kh.lastMagic = p.kh.cOption
						p.kh.cOption = 1
					elseif G_RingSlingerGametype() then
						if p.kh.menuMode == 0 then
							p.kh.lastMagic = p.kh.cOption
						end
						p.kh.menuMode = 2
						p.kh.cOption = p.currentweapon
					else
						S_StartSound(nil, sfx_cmderr, p)
					end
				end
				p.kh.comButton = true
			elseif p.kh.comButton then
				p.kh.comButton = false
			end
		end
		p.kh.lastWpn = p.currentweapon
		if p.kh.menuMode == 2 then p.kh.cOption = p.currentweapon end
	end
end)

rawset(_G, "khDropTable", setmetatable({
	//There are two parts to each entry: the possible drops, and the chance of anything dropping (as a fraction modified by FRACUNIT)
	//Each drop is designated by a 'constant'
	//The number of entries in the table defines the drop chances of each with equal chance
	//This will be altered to have a better item distrubution.
	[MT_BLUECRAWLA] = {{1, 1, 1, 2}, FRACUNIT/4},
	[MT_REDCRAWLA] = {{1, 1, 1, 2, 2, 3, 4}, FRACUNIT/4},
	[MT_GOLDBUZZ] = {{1, 1, 1, 6, 6}, FRACUNIT/5},
	[MT_REDBUZZ] = {{2, 6, 7, 9}, FRACUNIT/4},
	[MT_DETON] = {{3}, FRACUNIT/5},
	[MT_SKIM] = {{4, 9}, FRACUNIT/4},
	[MT_JETJAW] = {{7}, FRACUNIT/4},
	[MT_CRUSHSTACEAN] = {{2, 6, 6}, FRACUNIT/5},
	[MT_BANPYURA] = {{4, 9}, FRACUNIT/5},
	[MT_ROBOHOOD] = {{3, 3, 7, 7, 11}, FRACUNIT/3},
	[MT_FACESTABBER] = {{2, 6}, FRACUNIT/4},
	[MT_EGGGUARD] = {{3, 4, 6}, FRACUNIT/4},
	[MT_VULTURE] = {{2, 3, 6}, FRACUNIT/4},
	[MT_GSNAPPER] = {{2, 2, 3, 5}, FRACUNIT/3},
	[MT_MINUS] = {{2, 2, 2, 3, 3}, FRACUNIT/4},
	[MT_CANARIVORE] = {{2, 3, 6}, FRACUNIT/4},
	[MT_UNIDUS] = {{2, 2, 7}, FRACUNIT/4},
	[MT_PYREFLY] = {{3, 3, 4}, FRACUNIT/5},
	[MT_JETTBOMBER] = {{6, 6, 6, 9}, FRACUNIT/5},
	[MT_JETTGUNNER] = {{4, 4, 9}, FRACUNIT/5},
	[MT_SNAILER] = {{4, 4, 7}, FRACUNIT/4},
	[MT_PENGUINATOR] = {{1, 1, 2}, FRACUNIT/4},
	[MT_POPHAT] = {{1, 1, 1, 2, 2, 6}, FRACUNIT/4},
	[MT_CRAWLACOMMANDER] = {{2, 2, 3, 4, 5}, FRACUNIT/4},
	[MT_SPINBOBERT] = {{1, 1, 2, 4}, FRACUNIT/4},
	[MT_CACOLANTERN] = {{1, 2, 4}, FRACUNIT/4},
	[MT_HANGSTER] = {{1, 2, 4}, FRACUNIT/4},
	[MT_HIVEELEMENTAL] = {{1, 2, 4}, FRACUNIT/4},
	[MT_BUMBLEBORE] = {{1, 2, 4}, FRACUNIT/4},
	[MT_POINTY] = {{1, 2, 4}, FRACUNIT/4},
	[MT_FANG] = {{5, 5, 5, 5, 13}, FRACUNIT},
	[MT_METALSONIC_BATTLE] = {{13}, FRACUNIT},
	[MT_GOOMBA] = {{1, 1, 2, 6}, FRACUNIT/4},
	[MT_BLUEGOOMBA] = {{1, 1, 2, 2, 3, 4, 6}, FRACUNIT/4},
	[MT_PUMA] = {{7}, FRACUNIT/4}
}, {__index = function() return {{0}, 0} end}))

addHook("MobjDeath", function(victim, cause, killer)
	if (mapheaderinfo[gamemap].typeoflevel & TOL_NIGHTS) then return false end //No drops in NiGHTS stages
	if not killer then return false end
	if killer.player then
		local p = killer.player
		local drops = khDropTable[victim.type]
		local droptable = drops[1] 
		local drop = droptable[P_RandomKey(#droptable) + 1]
		local dropchance = drops[2]
		if ultimatemode and (dropchance != FRACUNIT) then dropchance = $ / 2 end //Less drops in Ultimate Mode!
		if P_RandomChance(dropchance) then
			p.kh.items[drop] = $ + 1
			p.kh.itempickup = drop
			p.kh.itempickuptimer = TICRATE * 6
			p.kh.itempickuptext = nil
			S_StartSound(nil, sfx_itmget, player)
			local numitems = #p.kh.itemlist
			if numitems > 0 then
				for i = 1, numitems do //Is it in the table?
					if p.kh.itemlist[i] == drop then return false end //Yes, so we're done here.
				end
			end
			//No, so add it and sort the table.
			table.insert(p.kh.itemlist, drop)
			local itemoption
			if p.kh.menuMode == 1 then
				itemoption = p.kh.itemlist[p.kh.cOption]
			end
			table.sort(p.kh.itemlist)
			if itemoption ~= nil and itemoption ~= p.kh.itemlist[p.kh.cOption] then
				p.kh.cOption = $ + 1
			end
		end
	end
	return false
end)