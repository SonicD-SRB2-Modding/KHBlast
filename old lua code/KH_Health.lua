//This deals with the HP, RP and DP stuff

freeslot("sfx_cmdsel", "sfx_cmdbak", "sfx_cmderr")

rawset(_G, "khBlast", true)
rawset(_G, "khBlastVersion", "RC 1.5")
rawset(_G, "khBlastDiff", 1)
local nextKHBlastDiff = 1
local marathonDiff = 1

local pboss
rawset(_G, "khBlastcleargame", false)


local bossnames = {
	-- Vanilla SRB2
	[MT_EGGMOBILE] = "the Egg Mobile",
	[MT_EGGMOBILE2] = "the Egg Slimer",
	[MT_EGGMOBILE3] = "the Sea Egg",
	[MT_EGGMOBILE4] = "the Egg Coliseum",
	[MT_FANG] = "Fang",
	[MT_METALSONIC_BATTLE] = "Metal Sonic",
	[MT_CYBRAKDEMON] = "Black Eggman",
	[MT_BLACKEGGMAN] = "Black Eggman",
}

local addonbosses = {
	-- SUGOI
	MT_SILVER_318 = "Silver",
	MT_TURRETMOBILE = "the Turret Mobile",
	-- SUBARASHII
	MT_EGGDOMINATOR = "the Egg Dominator",
	-- KIMOKAWAIII
	MT_EGGGUNNER = "the Egg Gunner",
	MT_BOUNCYBOI = "BoBo the Bouncy Boi",
	MT_CYBERDETON = "the Cyber Deton",
	MT_POINTYEGG = "the Pointy Egg",
	MT_LJSONIC = "LJ Sonic",
	MT_CONFLEGGRATOR = "the Confleggrator",
	MT_AALPBOSS = "the Egg Robo",
	MT_DARKSTABOT = "the Dark Stabot",
	MT_EGGLAS = "the Egg Lasershow",
	MT_PROTAGONIST = "the True Protagonist",
	-- (potential) character bosses
	MT_SONIC = "Sonic",
	MT_TAILS = "Tails",
	MT_KNUCKLES = "Knuckles",
	MT_AMY = "Amy Rose",
	MT_SHADOW = "Shadow",
	MT_SILVER = "Silver",
	-- Misc levels
	MT_EGGMOBILE7 = "the Egg Boiler", -- True Arena name, I'd like to know if FuriousFox had an official name for this
	MT_STRAYBOLTS_BOSS = "the Stray-Bolts",
	MT_OLDK = "K.T.E.",
	MT_ANASTASIA = "Anastasia",
	MT_BOSSRIDE = "Player", -- this one never gets used, included anyway to tell the game you have it loaded
	-- True Arena's ports
	MT_SANDSUB_326 = "the Egg Sand Sub",
	MT_GREENHILLBOSS = "the Egg Ball & Chain",
	MT_SUPERHOOD = "Super Robo-Hood",
	MT_INFINITE_318 = "Infinite",
}

local function isMobjTypeValid(mt)
	if (pcall(do return _G[mt] end))
		return _G[mt]
	else
		return nil
	end
end

local function mapSet()
	for k,v in pairs(addonbosses)
		local mt = isMobjTypeValid(k)
		if not (mt) continue end
		bossnames[mt] = v
	end
end

rawset(_G, "getbossname", function(boss)
	if boss and (bossnames[boss.type]) then
		local name = bossnames[boss.type]
		if (isMobjTypeValid("MT_BOSSRIDE"))
			if (_G["MT_BOSSRIDE"] == boss.type)
			and ((boss.rider and boss.rider.valid)
			and (boss.rider.player and boss.rider.player.valid))
				name = boss.rider.player.name
			end
		end
		return name
	end
end)

addHook("NetVars", function(net)
	khBlastDiff = net(khBlastDiff)
	nextKHBlastDiff = net(nextKHBlastDiff)
	pboss = net(pboss)
	khBlastcleargame = net(khBlastcleargame)
end)

local function changeDiff(newDiff)
	if ultimatemode then nextKHBlastDiff = 5
	elseif newDiff == "BEGINNER" or newDiff == "0" or newDiff == 0 then nextKHBlastDiff = 0
	elseif newDiff == "STANDARD" or newDiff == "1" or newDiff == 1 then nextKHBlastDiff = 1
	elseif newDiff == "PROUD" or newDiff == "2" or newDiff == 2 then nextKHBlastDiff = 2
	elseif newDiff == "CRITICAL" or newDiff == "3" or newDiff == 3 then nextKHBlastDiff = 3
	elseif newDiff == "EXP ZERO" or newDiff == "4" or newDiff == 4 then nextKHBlastDiff = 4
	else
		return false
	end
	khBlastDiff = nextKHBlastDiff
	for player in players.iterate do
		player.kh.diff = nextKHBlastDiff
	end
	khBlastLuaBank[DIFFLUABANK] = khBlastDiff
	return true
end

rawset(_G, "khBlastDiffTable", {
	//Difficulty Text, Foe Damage Mod (2 = 100%), maxHP Mod (4 = 100%), description, expZero
	[0] = {"Beginner", 1, 5, "\x83".."For casual players.\n\n".."\x80".."Damage recieved reduced by 50%\n\nMax HP increased by 25%\nFoe HP reduced by 25%", false},
	[1] = {"Standard", 2, 4, "\x84".."For normal players.\n\n".."\x80".."Normal damage and Max HP.", false},
	[2] = {"Proud", 3, 4, "\x82".."For advanced players.\n\n".."\x80".."Damage recieved increased by 50%\n\nMax HP unaltered.\nFoe HP increased by 50%", false},
	[3] = {"Critical", 4, 3, "\x87".."For expert players.\n\n".."\x80".."Damage recieved is doubled.\n\nMax HP reduced by 25%\nFoe HP increased by 100%", false},
	[4] = {"EXP Zero", 4, 3, "\x85".."For master players.\n\n".."\x80".."Damage recieved is doubled.\n\nMax HP reduced by 25%\nFoe HP increased by 100%\n".."\x85".."No EXP gains to HP or RP!", true},
	[5] = {"ULTIMATE", 5, 2, "\x85".."DIFFICULTY LOCKED TO ULTIMATE.\n".."\x80".."Damage recieved increased to 250%\nMax HP reduced by 50%\nFoe HP increased by 100%\nNo Rings, No AutoLives, No Continues.\nCure, Aero and Revive disabled.\n".."\x85".."No EXP gains to HP or RP!", true}
})

rawset(_G, "MATCHXPMOD", 100)
rawset(_G, "RATTACKXPMOD", 10)

local REVIVETIME = (TICRATE * 20)

local BOSSHPMOD = 20

local RPCAP = 20 //Max cap of RP [100 Rings]

rawset(_G, "getEmeraldCount", function(flags)
	local numEmeralds = 0
	if All7Emeralds(flags) then return 7 end
	local i
	local j = flags
	for i = 1, 7 do
		if (j % 2) == 1 then numEmeralds = $ + 1 end
		j = j / 2
		if j == 0 then return numEmeralds end
	end
	return numEmeralds
end)

rawset(_G, "getMaxHP", function(player)
	if not player.mo then return 0 end
	if (not (modeattacking or tutorialmode)) and khBlastLuaBank[DIFFLUABANK] != khBlastDiff then khBlastDiff = khBlastLuaBank[DIFFLUABANK] end
	local hpdata = healthdata[player.mo.skin]
	local maxHP = hpdata[1]
	
	//Check to see how many Emeralds they have
	local numEmeralds 
	if gametype == GT_COOP then
		numEmeralds = getEmeraldCount(emeralds)
	else
		if not player.lastEmeralds then player.lastEmeralds = 0 end
		numEmeralds = getEmeraldCount(player.powers[pw_emeralds])
		if numEmeralds > player.lastEmeralds then player.lastEmeralds = numEmeralds
		elseif numEmeralds < player.lastEmeralds then numEmeralds = player.lastEmeralds end
	end
	if numEmeralds > 0 then maxHP = $ + (numEmeralds * hpdata[2]) end
	
	if player.kh.boss > 0 then maxHP = $ + (player.kh.boss * hpdata[3]) end
	
	if mapheaderinfo[gamemap].dungeon and not mapheaderinfo[gamemap].minidungeon then
		if (not khBlastDiffTable[khBlastDiff][5]) and (player.score*25) >= hpdata[5] then 
			player.kh.level = min(1 + ((player.score*25) / hpdata[5]), 99)
			maxHP = $ + ((player.kh.level - 1) * hpdata[4])
		else
			player.kh.level = 1
		end
	elseif G_GametypeUsesLives() or G_IsSpecialStage() or (mapheaderinfo[gamemap].typeoflevel & TOL_NIGHTS) or (gametype == GT_RACE) then
		if (not khBlastDiffTable[khBlastDiff][5]) and player.score >= hpdata[5] then 
			player.kh.level = min(1 + (player.score / hpdata[5]), 99)
			maxHP = $ + ((player.kh.level - 1) * hpdata[4])
		else
			player.kh.level = 1
		end
	elseif modeattacking then
		local level = ((player.score * RATTACKXPMOD) / hpdata[5])
		if mapheaderinfo[gamemap].ralevel then
			level = $ + tonumber(mapheaderinfo[gamemap].ralevel)
		else
			level = $ + 1
		end
		player.kh.level = level
		if (not khBlastDiffTable[khBlastDiff][5]) and (level > 1) then maxHP = $ + ((level-1) * hpdata[4]) end
	else
		if (not khBlastDiffTable[khBlastDiff][5]) and (player.score * MATCHXPMOD) >= hpdata[5] then maxHP = $ + (((player.score * MATCHXPMOD) / hpdata[5]) * hpdata[4]) end
	end
	
	maxHP = ($ * khBlastDiffTable[khBlastDiff][3]) / 4
	
	return maxHP
end)

rawset(_G, "getMaxRP", function(player)
	if not player.mo then return 0 end
	local rpdata = ringdata[player.mo.skin]
	local maxRP = rpdata[1]
	
	local numEmeralds 
	if gametype == GT_COOP then
		numEmeralds = getEmeraldCount(emeralds)
	else
		if not player.lastEmeralds then player.lastEmeralds = 0 end
		numEmeralds = getEmeraldCount(player.powers[pw_emeralds])
		if numEmeralds > player.lastEmeralds then player.lastEmeralds = numEmeralds
		elseif numEmeralds < player.lastEmeralds then numEmeralds = player.lastEmeralds end
	end
	if numEmeralds > 0 then maxRP = $ + (numEmeralds * rpdata[2]) end
	
	if player.kh.boss > 0 then maxRP = $ + (player.kh.boss * rpdata[3]) end
	
	if mapheaderinfo[gamemap].dungeon and not mapheaderinfo[gamemap].minidungeon then
		if (not khBlastDiffTable[khBlastDiff][5]) and (rpdata[4] != -1) and (player.score*25) >= rpdata[4] then
			maxRP = $ + ((player.score*25) / rpdata[4])
		end
	elseif G_GametypeUsesLives() or G_IsSpecialStage() or (mapheaderinfo[gamemap].typeoflevel & TOL_NIGHTS) or (gametype == GT_RACE) then
		if (not khBlastDiffTable[khBlastDiff][5]) and (rpdata[4] != -1) and player.score >= rpdata[4] then
			maxRP = $ + (player.score / rpdata[4])
		end
	elseif modeattacking then
		local rpscore = player.score * RATTACKXPMOD
		if mapheaderinfo[gamemap].ralevel then
			rpscore = $ + (tonumber(mapheaderinfo[gamemap].ralevel) * healthdata[player.mo.skin][5])
		end
		local rpbonus = (rpscore / rpdata[4])
		if (not khBlastDiffTable[khBlastDiff][5]) and (rpdata[4] != -1) and (rpbonus > 0) then maxRP = $ + rpbonus end
	else
		if (not khBlastDiffTable[khBlastDiff][5]) and (rpdata[4] != -1) and (player.score * MATCHXPMOD) >= rpdata[4] then maxRP = $ + ((player.score * MATCHXPMOD) / rpdata[4]) end
	end
	
	if maxRP > RPCAP then return RPCAP end
	return maxRP
end)

local function setupkhstuff(p, client)
	p.kh = {}
	p.kh.lasthp = 0
	p.kh.rp = 0
	p.kh.rpcharge = 0
	p.kh.down = false
	p.kh.downedhp = 3
	p.kh.revivehp = 0
	p.kh.revivetimer = REVIVETIME
	p.kh.lastdp = 0
	p.kh.cOption = 1
	p.kh.menuMode = 0
	p.kh.lastMagic = 1
	if tutorialmode then
		p.kh.diff = 0
		p.kh.boss = 0
		p.kh.items = {3, 0, 0, 0, 0, 5, 0, 0, 0, 0, 3, 0, 0}
	elseif modeattacking then
		p.kh.diff = 1
		p.kh.boss = 0
		p.kh.items = {3, 0, 0, 0, 0, 2, 0, 0, 0, 0, 1, 0, 0}
	elseif marathonmode then
		p.kh.diff = khBlastLuaBank[DIFFLUABANK]
		p.kh.boss = khBlastLuaBank[BOSSLUABANK]
		local items = {2, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0}
		local itemBankItems = khBlastItemBankOut(p)
		for i = 1, #items do
			if itemBankItems[i] > items[i] then items[i] = itemBankItems[i] end
		end
		p.kh.items = items
	else
		p.kh.diff = khBlastLuaBank[DIFFLUABANK]
		p.kh.boss = khBlastLuaBank[BOSSLUABANK]
		if client then p.kh.items = khBlastItemBankOut(p) else p.kh.items = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0} end
	end
	p.kh.itempickup = 0
	p.kh.itempickuptimer = 0
	//if p.mo then p.lastskin = p.mo.skin end
	p.kh.target = nil
	p.kh.level = 1
	p.kh.infotimer = 0
	p.kh.infotext = ""
	p.kh.itempickuptext = nil
end

rawset(_G, "khFoeHealth", setmetatable({ //Sets how much HP each enemy has
	[MT_BLUECRAWLA] = {8, 8},
	[MT_REDCRAWLA] = {14, 14},
	[MT_GFZFISH] = {1, 1}, //Stupid Fish only has 1HP!
	[MT_GOLDBUZZ] = {4, 4},
	[MT_REDBUZZ] = {8, 8},
	[MT_DETON] = {1, 1},
	[MT_TURRET] = {20, 20},
	[MT_POPUPTURRET] = {20, 20},
	[MT_SPRINGSHELL] = {1, 1},
	[MT_YELLOWSHELL] = {1, 1},
	[MT_SKIM] = {8, 8},
	[MT_JETJAW] = {12, 12},
	[MT_CRUSHSTACEAN] = {10, 10},
	[MT_BANPYURA] = {8, 8},
	[MT_ROBOHOOD] = {24, 24},
	[MT_FACESTABBER] = {32, 32},
	[MT_SUSPICIOUSFACESTABBERSTATUE] = {32,32},
	[MT_EGGGUARD] = {16, 16},
	[MT_VULTURE] = {12, 12},
	[MT_GSNAPPER] = {8, 8},
	[MT_MINUS] = {10, 10},
	[MT_CANARIVORE] = {6, 6},
	[MT_UNIDUS] = {6, 6},
	[MT_PYREFLY] = {4, 4},
	[MT_JETTBOMBER] = {20, 20},
	[MT_JETTGUNNER] = {22, 22},
	[MT_SPINCUSHION] = {16, 16},
	[MT_SNAILER] = {18, 18},
	[MT_PENGUINATOR] = {4, 4},
	[MT_POPHAT] = {8, 8},
	[MT_CRAWLACOMMANDER] = {32, 16},
	[MT_SPINBOBERT] = {4, 4},
	[MT_CACOLANTERN] = {4, 4},
	[MT_HANGSTER] = {6, 6},
	[MT_HIVEELEMENTAL] = {12, 12},
	[MT_BUMBLEBORE] = {1, 1},
	[MT_POINTY] = {8, 8},
	[MT_EGGMOBILE] = {14*8, 14},
	[MT_EGGMOBILE2] = {16*8, 16},
	[MT_EGGMOBILE3] = {18*8, 18},
	[MT_FAKEMOBILE] = {18, 18},
	[MT_EGGMOBILE4] = {20*8, 20},
	[MT_EGGROBO1] = {100, 100},
	[MT_FANG] = {10*8, 10},
	[MT_BLACKEGGMAN] = {25*12, 25},
	[MT_METALSONIC_RACE] = {8*8, 8*8},
	[MT_METALSONIC_BATTLE] = {8*8, 8},
	[MT_CYBRAKDEMON] = {25*12, 25},
	[MT_GOOMBA] = {1, 1},
	[MT_BLUEGOOMBA] = {1, 1},
	[MT_PUMA] = {1, 1},
	[MT_KOOPA] = {20, 20},
	[MT_BIGMINE] = {1, 1}
}, {__index = function() return {10, 10} end}))

rawset(_G, "khBlastSetFoeHealth", function(m, healthmod, reset)
	if m.maxHP and not reset then return end
	if not healthmod then
		healthmod = 100 //100% Standard
		if khBlastDiff == 0 then healthmod = $ - 25 end //75% Easy
		if khBlastDiff > 1 then healthmod = $ + 50 end //150% Proud
		if khBlastDiff > 2 then healthmod = $ + 50 end //200% Critical, EXP Zero or Ultimate
		if mapheaderinfo[gamemap].superboss
		and ((tonumber(mapheaderinfo[gamemap].superboss) == 1) and All7Emeralds(emeralds)) or (tonumber(mapheaderinfo[gamemap].superboss) == 2) then //BCZ3 is buffed if all emeralds are obtained
			healthmod = $ + 200 //300% Standard, 350% Proud, 400% Critical, EXP Zero or Ultimate
			if khBlastDiff == 0 then healthmod = $ - 75 end //200% Easy
		end
	end

	if (m.flags & MF_BOSS) or (m.flags & MF_ENEMY) or (m.type == MT_SUSPICIOUSFACESTABBERSTATUE) then
		local startingHP = khFoeHealth[m.type][1]
		m.maxHP = max((startingHP*healthmod)/100,1) //Must have at least 1HP
		m.hp = m.maxHP
		m.hpUnit = max((khFoeHealth[m.type][2]*healthmod)/100,1)
	end
end)

addHook("MapLoad", do
	mapSet()
	if pboss then pboss = nil end
	if tutorialmode then
		khBlastDiff = 0 //Always Beginner in the Tutorial
	elseif modeattacking or not (gametyperules & GTR_CAMPAIGN)  then
		khBlastDiff = 1 //Always Standard outside of the campaign
	else
		khBlastDiff = khBlastLuaBank[DIFFLUABANK]
	end
	for p in players.iterate do
		if gamemap <= 1000 then
			if p.difsel then p.difsel = false end
		end
		if not (G_GametypeUsesLives() or G_IsSpecialStage() or (mapheaderinfo[gamemap].typeoflevel & TOL_NIGHTS)) then 
			p.kh.lastscore = nil
		end
	end
	
	local healthmod = 100 //100% Standard
	if khBlastDiff == 0 then healthmod = $ - 25 end //75% Easy
	if khBlastDiff > 1 then healthmod = $ + 50 end //150% Proud
	if khBlastDiff > 2 then healthmod = $ + 50 end //200% Critical, EXP Zero or Ultimate
	if mapheaderinfo[gamemap].superboss
	and ((tonumber(mapheaderinfo[gamemap].superboss) == 1) and All7Emeralds(emeralds)) or (tonumber(mapheaderinfo[gamemap].superboss) == 2) then //BCZ3 is buffed if all emeralds are obtained
		healthmod = $ + 200 //300% Standard, 350% Proud, 400% Critical, EXP Zero or Ultimate
		if khBlastDiff == 0 then healthmod = $ - 75 end //200% Easy
	end
	
	for m in mobjs.iterate()
		if (m.flags & MF_BOSS) or (m.flags & MF_ENEMY) or (m.type == MT_SUSPICIOUSFACESTABBERSTATUE) then
			khBlastSetFoeHealth(m, healthmod)
		end
	end
	
	if mapheaderinfo[gamemap].superboss
	and ((tonumber(mapheaderinfo[gamemap].superboss) == 1) and All7Emeralds(emeralds)) or (tonumber(mapheaderinfo[gamemap].superboss) == 2) then //BCZ3 has a little bonus if you have all the Emeralds.
		local emeraldsspawn = false
		for p in players.iterate do
			if p.bot then continue end
			P_GivePlayerRings(p, 350)
			if modeattacking and (gamemap == 28) and (not emeraldsspawn) then
				P_SpawnMobj(p.mo.x, p.mo.y, p.mo.z, MT_EMERALD1)
				P_SpawnMobj(p.mo.x, p.mo.y, p.mo.z, MT_EMERALD2)
				P_SpawnMobj(p.mo.x, p.mo.y, p.mo.z, MT_EMERALD3)
				P_SpawnMobj(p.mo.x, p.mo.y, p.mo.z, MT_EMERALD4)
				P_SpawnMobj(p.mo.x, p.mo.y, p.mo.z, MT_EMERALD5)
				P_SpawnMobj(p.mo.x, p.mo.y, p.mo.z, MT_EMERALD6)
				P_SpawnMobj(p.mo.x, p.mo.y, p.mo.z, MT_EMERALD7)
				emeraldsspawn = true
			end
		end
	end
end)

local function collectEmerald(mo, touch)
	if mo.valid and touch.valid and touch.player then
		local p = touch.player
		p.maxHP = getMaxHP(p)
		if (p.hp * 2) >= p.maxHP then
			p.hp = p.maxHP
		else
			p.hp = $ + (p.maxHP / 2)
		end
		p.kh.lasthp = p.hp
		p.kh.maxRP = getMaxRP(p)
		p.kh.itempickuptimer = TICRATE * 6
		p.kh.itempickuptext = "a Chaos Emerald!"
		return false
	end
end

addHook("TouchSpecial", function(mo, touch)
	return collectEmerald(mo, touch)
end, MT_EMERALD1)

addHook("TouchSpecial", function(mo, touch)
	return collectEmerald(mo, touch)
end, MT_EMERALD2)

addHook("TouchSpecial", function(mo, touch)
	return collectEmerald(mo, touch)
end, MT_EMERALD3)

addHook("TouchSpecial", function(mo, touch)
	return collectEmerald(mo, touch)
end, MT_EMERALD4)

addHook("TouchSpecial", function(mo, touch)
	return collectEmerald(mo, touch)
end, MT_EMERALD5)

addHook("TouchSpecial", function(mo, touch)
	return collectEmerald(mo, touch)
end, MT_EMERALD6)

addHook("TouchSpecial", function(mo, touch)
	return collectEmerald(mo, touch)
end, MT_EMERALD7)

addHook("MapChange", do
	for p in players.iterate do
		if not p.valid then continue end
		if netgame then
			if IsPlayerAdmin(p) or p == server then
				setupkhstuff(p, true)
			else
				setupkhstuff(p, false)
			end
		else
			if p.kh == nil then setupkhstuff(p, true) end
		end
		if p.maxHP then p.hp = p.maxHP end
		if p.maxRP ~= nil then p.kh.rp = min($, p.maxRP) end
		p.kh.lasthp = p.hp
		p.kh.rpcharge = 0
		p.kh.down = false
		p.kh.downedhp = 3
		p.kh.revivehp = 0
		p.kh.revivetimer = REVIVETIME
		p.kh.lastdp = 0
		p.difsel = false
		if p.lastEmeralds then p.lastEmeralds = 0 end
		p.kh.target = nil
		p.kh.infotimer = 0
		p.kh.infotext = ""
		p.kh.itempickuptext = nil
	end
	khBlastcleargame = $ or gamecomplete or (khBlastLuaBank[GAMECLEARLUABANK] == 1)
end)

local function selectDiffMenu(p)
	if p.difselmenu == 1 then
		if (p.cmd.buttons & BT_WEAPONPREV) or (p.cmd.forwardmove < 0) then
			if not p.kh.comButton then
				p.diffopt = $ + 1
				S_StartSound(nil, sfx_menu1, p)
				if p.diffopt == 5 then p.diffopt = 0 end
			end
			p.kh.comButton = true
		elseif (p.cmd.buttons & BT_WEAPONNEXT) or (p.cmd.forwardmove > 0) then
			if not p.kh.comButton then
				p.diffopt = $ - 1
				S_StartSound(nil, sfx_menu1, p)
				if p.diffopt == -1 then p.diffopt = 4 end
			end
			p.kh.comButton = true
		elseif (p.cmd.buttons & BT_JUMP) then
			if not p.kh.comButton and not (p.diffopt > 2 and not (khBlastcleargame or marathonmode)) then
				S_StartSound(nil, sfx_cmdsel, p)
				p.difselmenu = 2
			elseif not p.kh.comButton then
				S_StartSound(nil, sfx_cmderr, p)
			end
			p.kh.comButton = true
		elseif p.kh.comButton then
			p.kh.comButton = false
		end
	elseif p.difselmenu == 2 then
		if (p.cmd.buttons & BT_WEAPONNEXT) or (p.cmd.forwardmove != 0) or (p.cmd.buttons & BT_WEAPONPREV) then
			if not p.kh.comButton then
				p.diffcon = $ + 1
				S_StartSound(nil, sfx_menu1, p)
				if p.diffcon == 2 then p.diffcon = 0 end
			end
			p.kh.comButton = true
		elseif (p.cmd.buttons & BT_JUMP) and p.diffcon == 1 then 
			if not p.kh.comButton then
				changeDiff(p.diffopt)
				G_ExitLevel() //We can leave the level now
			end
		elseif (p.cmd.buttons & BT_USE) or ((p.cmd.buttons & BT_JUMP) and p.diffcon == 0) then
			if not p.kh.comButton then
				if ultimatemode then
					S_StartSound(nil, sfx_cmderr, p)
				else
					p.difselmenu = 1
					S_StartSound(nil, sfx_cmdbak, p)
				end
			end
			p.kh.comButton = true
		elseif p.kh.comButton then
			p.kh.comButton = false
		end
	end
end

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
		
		if p.kh.infotimer > 0 then p.kh.infotimer = $ - 1 end
		
		if p.difsel == true then
			p.mo.momx = 0
			p.mo.momy = 0
			p.mo.reactiontime = 1
			if ((not netgame) and (p == players[0]))
				or (netgame and ((p == server) or IsPlayerAdmin(p))) then
				selectDiffMenu(p)
			end
			continue
		end
		
		if p.kh == nil then setupkhstuff(p, p == clientplayer) end
		if p.mo then
			if not p.kh.str then
				p.kh.str = getstr(p)
			end
			if not p.kh.mag then
				p.kh.mag = getmag(p)
			end
		end
		if p.kh.target then
			if not p.kh.target.valid then p.kh.target = nil end
		elseif pboss and pboss.valid then
			p.kh.target = pboss
		end
		
		if p == clientplayer and p.kh.diff then
			if p.kh.diff != khBlastDiff then khBlastDiff = p.kh.diff end
		end
		if p.maxHP == nil then 
			p.maxHP = getMaxHP(p)
			p.hp = p.maxHP
		end
		if p.bot and (p.mo.health > 0) and (not p.kh.down) and (p.hp <= 0) then p.hp = p.maxHP end //Heals up Tails when he respawns
		if p.kh.maxRP == nil then
			p.kh.maxRP = getMaxRP(p)
			p.kh.rp = 0
			p.kh.rpcharge = 0
		end
		if p.mo then
			if p.mo.skin and p.lastskin != p.mo.skin then //Character Change
				p.lastskin = p.mo.skin
				local oldmaxHP = p.maxHP
				p.maxHP = getMaxHP(p)
				p.hp = min(p.maxHP, max(($*p.maxHP)/oldmaxHP,1))
				p.kh.maxRP = getMaxRP(p)
				if p.kh.rp >= p.kh.maxRP then
					p.kh.rp = p.kh.maxRP
					p.kh.rpcharge = 0
				end
			end
		end
		if (p.kh.lastscore == nil) or ultimatemode then
			p.kh.lastscore = p.score
		elseif p.kh.lastscore > p.score and not (G_GametypeUsesLives() or G_IsSpecialStage() or (mapheaderinfo[gamemap].typeoflevel & TOL_NIGHTS)) then
			p.kh.lastscore = p.score
		elseif p.score ~= p.kh.lastscore then
			local score = max(p.score, p.kh.lastscore)
			local lastscore = (p.score > 0) and p.kh.lastscore or 0
			local unmodscore = score
			p.score = max(score, $)
			if mapheaderinfo[gamemap].dungeon and not mapheaderinfo[gamemap].minidungeon
				score = $ * 25
				lastscore = $ * 25
			elseif modeattacking then
				score = $ * RATTACKXPMOD
				lastscore = $ * RATTACKXPMOD
			elseif not (G_GametypeUsesLives() or (mapheaderinfo[gamemap].typeoflevel & TOL_NIGHTS) or (gametype == GT_RACE)) then
				score = $ * MATCHXPMOD
				lastscore = $ * MATCHXPMOD
			end
			local hpPlus = 0
			local strPlus = 0
			local magPlus = 0
			local rpPlus = 0
			if (score / healthdata[p.mo.skin][5]) > (lastscore / healthdata[p.mo.skin][5]) then
				hpPlus = p.maxHP
				p.maxHP = getMaxHP(p)
				hpPlus = p.maxHP - $
				if (p.hp * 2) >= p.maxHP then
					p.hp = p.maxHP
				else
					p.hp = $ + (p.maxHP / 2)
				end
				strPlus = p.kh.str
				p.kh.str = getstr(p)
				strPlus = p.kh.str - $
				magPlus = p.kh.mag
				p.kh.mag = getmag(p)
				magPlus = p.kh.mag - $
			end
			if (score / ringdata[p.mo.skin][4]) > (lastscore / ringdata[p.mo.skin][4]) then
				rpPlus = p.kh.maxRP
				p.kh.maxRP = getMaxRP(p)
				rpPlus = p.kh.maxRP - $
			end
			if ((hpPlus > 0) or (strPlus > 0) or (magPlus > 0) or (rpPlus > 0)) and (unmodscore > 0) then
				local bonusString
				if (score / healthdata[p.mo.skin][5]) > (lastscore / healthdata[p.mo.skin][5]) then
					bonusString = "Level " .. p.kh.level .. "!"
					if (hpPlus > 0) then 
						bonusString = $ .. " +" .. hpPlus .. " Max HP" .. (((strPlus > 0) or (magPlus > 0) or (rpPlus > 0)) and "," or "!")
					end
					if (strPlus > 0) then 
						bonusString = $ .. " +" .. strPlus .. "STR" .. (((magPlus > 0) or (rpPlus > 0)) and "," or "!")
					end
					if (magPlus > 0) then 
						bonusString = $ .. " +" .. magPlus .. "MAG" .. ((rpPlus > 0) and "," or "!")
					end
					if (rpPlus > 0) then 
						bonusString = $ .. " +" .. rpPlus .. " Max RP!"
					end
				else
					bonusString = "Max RP has been increased by " .. rpPlus .. "!"
				end
				p.kh.infotimer = 8*TICRATE
				p.kh.infotext = bonusString
			end
			p.kh.lastscore = p.score
		end
		if p.lastEmeralds == nil then p.lastEmeralds = 0 end
		if (not (G_GametypeUsesLives() or G_IsSpecialStage() or (mapheaderinfo[gamemap].typeoflevel & TOL_NIGHTS))) and (getEmeraldCount(p.powers[pw_emeralds]) > p.lastEmeralds) then
			p.maxHP = getMaxHP(p)
			if (p.hp * 2) >= p.maxHP then
				p.hp = p.maxHP
			else
				p.hp = $ + (p.maxHP / 2)
			end
			p.kh.maxRP = getMaxRP(p)
		end
		if p.kh.down then
			p.pflags = $ | PF_FULLSTASIS //They can't move at all
			p.powers[pw_underwater] = p.kh.revivetimer - 1
			p.kh.revivetimer = $ - 1
			if p.kh.revivetimer == 0 then
				p.mo.health = 0 
				p.kh.down = false //Dead, not Downed
				P_DamageMobj(mobj, null, null, 1, DMG_SPACEDROWN)
			end
		end
		if p.kh.lastdp != p.rings and not p.powers[pw_super] then
			p.kh.lastdp = p.rings
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
	end
end)

addHook("PlayerSpawn", function(p)
	if p.kh == nil then setupkhstuff(p) end
	if p.kh.lastscore and not (G_GametypeUsesLives() or G_IsSpecialStage() or (mapheaderinfo[gamemap].typeoflevel & TOL_NIGHTS)) then p.score = p.kh.lastscore end
	p.maxHP = getMaxHP(p)
	p.hp = p.maxHP
	p.kh.lasthp = p.hp
	p.kh.maxRP = getMaxRP(p)
	p.kh.rpcharge = 0
	p.kh.down = false
	p.kh.downedhp = 3
	p.kh.revivehp = 0
	p.kh.revivetimer = REVIVETIME
	p.kh.lastdp = 0
	p.kh.target = nil
end)

addHook("TouchSpecial", function(mo, touch)
	if mo.valid and touch.valid and touch.player then
		local p = touch.player
		if not p.powers[pw_super] then P_GivePlayerRings(p, 1) end
		if p.kh.rp < p.kh.maxRP then
			p.kh.rpcharge = $ + 1
			if p.kh.rpcharge == 5 then
				p.kh.rpcharge = 0
				p.kh.rp = $ + 1
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
		if p.kh.rp < p.kh.maxRP and P_RandomChance(FRACUNIT/10) then //10% chance of increasing RP
			p.kh.rp = $ + 1
			if p.kh.rp == p.kh.maxRP then p.kh.rpcharge = 0 end
		end
		S_StartSound(mo, sfx_mario4)
		if (mapheaderinfo[gamemap].typeoflevel & TOL_NIGHTS) then P_DoNightsScore(p) end
		P_KillMobj(mo, touch, touch)
		return true
	end
end, MT_COIN)

addHook("TouchSpecial", function(mo, touch)
	if mo.valid and touch.valid and touch.player then
		local p = touch.player
		if p.kh.rp < p.kh.maxRP then
			p.kh.rp = $ + 1 //Special Stage Tokens always grant 5 Rings of RP charge
			if p.kh.rp == p.kh.maxRP then
				p.kh.rpcharge = 0
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

rawset(_G, "khFoeDamage", setmetatable({ //Sets how much HP of damage each enemy can deal
	[MT_BLUECRAWLA] = 1,
	[MT_REDCRAWLA] = 2,
	[MT_GFZFISH] = 0, //Stupid Fish don't do any damage to the player! Except on Proud and higher...
	[MT_GOLDBUZZ] = 1,
	[MT_REDBUZZ] = 2,
	[MT_DETON] = 4,
	[MT_TURRET] = 2,
	[MT_POPUPTURRET] = 4,
	[MT_SPRINGSHELL] = 1,
	[MT_YELLOWSHELL] = 2,
	[MT_SKIM] = 3,
	[MT_JETJAW] = 2,
	[MT_CRUSHSTACEAN] = 4,
	[MT_BANPYURA] = 3,
	[MT_ROBOHOOD] = 4,
	[MT_FACESTABBER] = 5,
	[MT_EGGGUARD] = 1,
	[MT_VULTURE] = 3,
	[MT_GSNAPPER] = 4,
	[MT_MINUS] = 3,
	[MT_CANARIVORE] = 1,
	[MT_UNIDUS] = 2,
	[MT_PYREFLY] = 3,
	[MT_JETTBOMBER] = 4,
	[MT_JETTGUNNER] = 5,
	[MT_SPINCUSHION] = 6,
	[MT_SNAILER] = 6,
	[MT_PENGUINATOR] = 2,
	[MT_POPHAT] = 3,
	[MT_CRAWLACOMMANDER] = 3,
	[MT_SPINBOBERT] = 2,
	[MT_CACOLANTERN] = 3,
	[MT_HANGSTER] = 1,
	[MT_HIVEELEMENTAL] = 1,
	[MT_BUMBLEBORE] = 3,
	[MT_POINTY] = 2,
	[MT_EGGMOBILE] = 4,
	[MT_EGGMOBILE2] = 5,
	[MT_EGGMOBILE3] = 6,
	[MT_FAKEMOBILE] = 2,
	[MT_EGGMOBILE4] = 7,
	[MT_EGGROBO1] = 20, //SMASH ATTACK!
	[MT_FANG] = 5,
	[MT_BLACKEGGMAN] = 8,
	[MT_METALSONIC_RACE] = 2,
	[MT_METALSONIC_BATTLE] = 9,
	[MT_CYBRAKDEMON] = 12,
	[MT_GOOMBA] = 1,
	[MT_BLUEGOOMBA] = 2,
	[MT_PUMA] = 3,
	[MT_KOOPA] = 5,
	[MT_SPIKE] = 2,
	[MT_WALLSPIKE] = 2,
	[MT_BIGMINE] = 3
}, {__index = function() return 1 end})) //Default damage is 1

addHook("BossThinker", function(mo)
	if (mo.health <= 0) return end
	
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
	
	if not ((clientplayer and clientplayer.valid) -- without client player, we'd have to iterate everyone TWICE AAA :v
	and (clientplayer.mo and clientplayer.mo.valid))
		return
	end 
	
	if (P_CheckSight(mo, clientplayer.mo))
		if ((pboss and pboss.valid) and not (P_CheckSight(pboss, clientplayer.mo))) -- boss exists, but not in line of sight?
		or not (pboss and pboss.valid) -- or the boss just doesn't exist
			pboss = mo
		end
	end
end)

addHook("MobjThinker", function(mo)
	if not ((mo.flags & MF_BOSS) or (mo.flags & MF_ENEMY) or (mo.type == MT_SUSPICIOUSFACESTABBERSTATUE)) then return end
	if not mo.miniboss return end
	if (mo.health <= 0) return end
	
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
	
	if not ((clientplayer and clientplayer.valid) -- without client player, we'd have to iterate everyone TWICE AAA :v
	and (clientplayer.mo and clientplayer.mo.valid))
		return
	end 
	
	if (P_CheckSight(mo, clientplayer.mo))
		if ((pboss and pboss.valid) and not (P_CheckSight(pboss, clientplayer.mo))) -- boss exists, but not in line of sight?
		or not (pboss and pboss.valid) -- or the boss just doesn't exist
			pboss = mo
		end
	end
end)

addHook("BossDeath", function(mobj)
	local oldmaxHP
	for p in players.iterate() do
		if mapheaderinfo[gamemap].superboss
		and ((tonumber(mapheaderinfo[gamemap].superboss) == 1) and All7Emeralds(emeralds)) or (tonumber(mapheaderinfo[gamemap].superboss) == 2) then
			P_GivePlayerRings(p, 10)
			if p.timeshit == 4 then P_AddPlayerScore(p, 100 + (100 * p.rings))
			elseif p.timeshit == 3 then P_AddPlayerScore(p, 500 + (100 * p.rings))
			elseif p.timeshit == 2 then P_AddPlayerScore(p, 1000 + (100 * p.rings))
			elseif p.timeshit == 1 then P_AddPlayerScore(p, 5000 + (100 * p.rings))
			elseif p.timeshit == 0 then P_AddPlayerScore(p, 10000 + (100 * p.rings))
			else P_AddPlayerScore(p, 100 * p.rings) end
			p.maxHP = getMaxHP(p)
			p.hp = p.maxHP
			p.kh.lasthp = p.hp
			khBlastLuaBank[GAMECLEARLUABANK] = 1
			khBlastcleargame = true
			continue
		elseif mapheaderinfo[gamemap].superboss
		and (tonumber(mapheaderinfo[gamemap].superboss) == 1)
		or mapheaderinfo[gamemap].finalboss then
			if p.timeshit == 4 then P_AddPlayerScore(p, 1100)
			elseif p.timeshit == 3 then P_AddPlayerScore(p, 1500)
			elseif p.timeshit == 2 then P_AddPlayerScore(p, 2000)
			elseif p.timeshit == 1 then P_AddPlayerScore(p, 6000)
			elseif p.timeshit == 0 then P_AddPlayerScore(p, 11000)
			else P_AddPlayerScore(p, 1000) end
			p.maxHP = getMaxHP(p)
			p.hp = p.maxHP
			p.kh.lasthp = p.hp
			khBlastLuaBank[GAMECLEARLUABANK] = 1
			khBlastcleargame = true
			continue
		else
			if p.kh.boss != nil then p.kh.boss = $ + 1 else p.kh.boss = 1 end
			oldmaxHP = p.maxHP
			p.maxHP = getMaxHP(p)
			p.hp = min(p.maxHP, $ + (p.maxHP / 2))
			p.kh.lasthp = p.hp
			p.kh.maxRP = getMaxRP(p)
		end
	end
	if not modeattacking then
		khBlastLuaBank[BOSSLUABANK] = $ + 1
	
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
			if gamemap == 28 or gamemap == 27 then
				p.kh.infotext = "Escape the Black Core!"
				p.kh.infotimer = 12*TICRATE
			elseif gamemap == 26 then
				p.kh.infotext = "Confront Eggman!"
				p.kh.infotimer = 16*TICRATE
			else
				p.kh.infotext = "Bust open the Egg Capsule!"
				p.kh.infotimer = 8*TICRATE
			end
		end
		khBlastItemBankIn(clientplayer)
	end
	return false //This just grants all the players the Boss Level Up bonuses and saves the items
end)

addHook("ShouldDamage", function(mobj, source, attacker, nordam)
	if not ((mobj.flags & MF_BOSS) or (mobj.flags & MF_ENEMY) or (mobj.type == MT_SUSPICIOUSFACESTABBERSTATUE)) then return nil end
	if G_IsSpecialStage() return nil end
	if mobj.recenthit and (mobj.recenthit > 0) then
		return false
	elseif (mobj.type == MT_CRUSHSTACEAN) or (mobj.type == MT_CRUSHCLAW) or (mobj.type == MT_CRUSHCHAIN) 
		or (mobj.type == MT_GSNAPPER) or (mobj.type == MT_SNAPPER_LEG) or (mobj.type == MT_SNAPPER_HEAD) then
		if (source.type == MT_FIREBALL) then
			P_KillMobj(source, mobj, mobj)
			return false //Crushtaceans are immune to Fire attacks!
		elseif source.type == MT_FIREBALLTRAIL then
			return false
		else
			return nil
		end
	elseif source and source.player and source.player.dashspeed
	and (source.player.dashspeed >= source.player.maxdash) then
		//Can't spindash for too long, otherwise you'll get hurt!
		P_DamageMobj(source, mobj, mobj)
		return false
	else
		return nil
	end //Ignore multihits
end)

addHook("MobjThinker", function(mobj)
	if not mobj.maxHP then
		khBlastSetFoeHealth(mobj)
	end
end, MT_FACESTABBER)

addHook("MobjThinker", function(mobj)
	if not ((mobj.flags & MF_BOSS) or (mobj.flags & MF_ENEMY) or (mobj.type == MT_SUSPICIOUSFACESTABBERSTATUE)) then return nil end
	if G_IsSpecialStage() return nil end
	if not mobj.recenthit then 
		if mobj.lasthp then
			if mobj.lasthp > mobj.hp then
				mobj.lasthp = $ - 1
			end
		else
			mobj.lasthp = mobj.hp
		end
		return false
	elseif mobj.recenthit > 1 then
		mobj.recenthit = $ - 1
		mobj.flags2 = MF2_FRET | $
	else //mobj.recenthit == 1
		mobj.recenthit = nil
		mobj.flags2 = !MF2_FRET & $
	end
	return false
end)

addHook("MobjDamage", function(mobj, source, attacker, nordam, damageType)
	if not mobj.valid then return false end
	if (mapheaderinfo[gamemap].typeoflevel & TOL_NIGHTS) then return false end //NiGHTS stages remain as normal
	if damageType then
		if (damageType & DMG_DEATHMASK) then 
			P_KillMobj(mobj, source, attacker)
			return true
		end //Insta-kills are ignored
	end
	if mobj.type == MT_PLAYER then
		if (mobj.player.hp) and not (mobj.player.powers[pw_super]) and not (mobj.player.kh.down) then
			if (mobj.player.powers[pw_shield]) then	// Shield damage
				P_DoPlayerPain(mobj.player, attacker, source)	// Do knockback stuff
				S_StartSound(mobj, sfx_s3k35)
				P_RemoveShield(mobj.player)
				P_PlayerFlagBurst(mobj.player)
			else
				// Inflict damage and remove items
				local damage
				local edam = false
				if attacker then 
					if attacker.type == MT_PLAYER then
						local ringtype = source.type
						if (ringtype == MT_REDRING) and (source.flags2 & MF2_RAILRING) then damage = khBlastDiffTable[khBlastDiff][2] * 4
						elseif (ringtype == MT_CORK) or (ringtype == MT_REDRING) then damage = khBlastDiffTable[khBlastDiff][2] //Base Damage
						elseif (ringtype == MT_THROWNINFINITY) or (ringtype == MT_THROWNAUTOMATIC) then damage = max(khBlastDiffTable[khBlastDiff][2] / 2, 1) //Half Damage
						elseif (ringtype == MT_THROWNBOUNCE) or (ringtype == MT_THROWNSCATTER) then damage = (khBlastDiffTable[khBlastDiff][2] * 3) / 2 //50% More Damage
						elseif (ringtype == MT_THROWNEXPLOSION) or (ringtype == MT_THROWNGRENADE) then damage = (khBlastDiffTable[khBlastDiff][2] * 5) / 2 //150% More Damage
						elseif (ringtype == MT_FIREBALL) then 
							damage = source.basedamage
						elseif damageType == DMG_ELECTRIC then
							damage = 5 
							if attacker.player.kh.mag then damage = $ + ((2*attacker.player.kh.mag) / 3) end
						else
							damage = 2 //Need to find what Weapon Ring or Magic was used
						end
					else
						damage = (khFoeDamage[attacker.type] * khBlastDiffTable[khBlastDiff][2]) / 2 
						if damage == 0 then
							if khBlastDiffTable[khBlastDiff][2] == 1 then damage = khFoeDamage[attacker.type]
							elseif khBlastDiffTable[khBlastDiff][2] >= 2 then damage = khBlastDiffTable[khBlastDiff][2] / 2
							end
						end
					end
				else
					if damageType == DMG_FIRE then damage = (5 * khBlastDiffTable[khBlastDiff][2]) / 2
					elseif damageType == DMG_ELECTRIC then damage = 2 * khBlastDiffTable[khBlastDiff][2]
					elseif damageType == DMG_WATER or damageType == DMG_SPIKE then damage = khBlastDiffTable[khBlastDiff][2]
					elseif damageType == DMG_NUKE then damage = 3 * khBlastDiffTable[khBlastDiff][2]
					else damage = max(1, khBlastDiffTable[khBlastDiff][2] / 2) //DMG_NORMAL
					end
					edam = true
				end
				mobj.player.hp = $1 - damage
				P_PlayerEmeraldBurst(mobj.player)
				P_PlayerWeaponAmmoBurst(mobj.player)
				P_PlayerFlagBurst(mobj.player)
				if mobj.player.hp > 0 then // Non-shield non-fatal damage
					if not (skins[mobj.skin].soundsid[SKSPLPAN1] == skins["sonic"].soundsid[SKSPLPAN1]) then
						S_StartSound(mobj,sfx_altow1)
					else
						S_StartSound(mobj,sfx_s3k35)
					end
					P_DoPlayerPain(mobj.player, attacker, source)	// Set knockback
					if G_GametypeUsesLives() or (gametype == GT_RACE) or edam then
						mobj.player.powers[pw_flashing] = 50	// Set invuln flashing
					else
						mobj.player.powers[pw_flashing] = 25
					end
				else
					if mobj.player.bot or (not multiplayer) then //TailsBot can't be revived, and you can't revive in SP
						mobj.health = 0
						P_KillMobj(mobj, source, attacker) //Non-shield fatal damage
					else
						mobj.player.kh.down = true
						mobj.player.kh.revivetimer = REVIVETIME
						P_DoPlayerPain(mobj.player, attacker, source)
						S_StartSound(mobj,sfx_kc31)
					end
				end
			end
			if attacker then
				if attacker.player then
					if mobj.player.hp > 0 then
						P_AddPlayerScore(attacker.player, 50)
					else
						P_AddPlayerScore(attacker.player, 100)
					end
				end
			end
			// -------------------------------------
			// We're done here!
			return true
		elseif mobj.player.kh.down then
			if (mobj.player.powers[pw_shield]) then	// Shield damage
				S_StartSound(mobj, sfx_s3k35)
				P_RemoveShield(mobj.player)
			end
			mobj.player.kh.downedhp = $ - 1
			if mobj.player.kh.downedhp == 0 then
				if attacker then
					if attacker.player then
						P_AddPlayerScore(attacker.player, 250)
					end
				end
				mobj.health = 0
				mobj.player.kh.down = false //Dead, not Downed
				P_KillMobj(mobj, source, attacker)
			else
				if attacker then
					if attacker.player then
						P_AddPlayerScore(attacker.player, 50)
					end
				end
				if not (skins[mobj.skin].soundsid[SKSPLPAN1] == skins["sonic"].soundsid[SKSPLPAN1]) then
					S_StartSound(mobj,sfx_altow1)
				else
					S_StartSound(mobj, sfx_s3k35)
				end
				P_DoPlayerPain(mobj.player, attacker, source)
				if G_GametypeUsesLives() or (gametype == GT_RACE) or (not attacker) then
					mobj.player.powers[pw_flashing] = 50	// Set invuln flashing
				else
					mobj.player.powers[pw_flashing] = 25
				end
			end
			return true
		else
			return false
		end
	else
		if attacker and attacker.valid then
			if attacker.player then
				if (mobj.flags & MF_BOSS) then //Bosses
					local p = attacker.player
					if p.kh.rp < p.kh.maxRP then
						p.kh.rpcharge = $ + 3
						if p.kh.rpcharge >= 5 then
							p.kh.rpcharge = $ - 5
							p.kh.rp = $ + 1
							if p.kh.rp == p.kh.maxRP then
								p.kh.rpcharge = 0
							end
						end
					end
				elseif not(attacker.player.powers[pw_super]) and (not ultimatemode) then
					P_GivePlayerRings(attacker.player, max(1, (khFoeDamage[mobj.type]/2))) //Rings = Drive
				elseif ultimatemode then
					local p = attacker.player
					if p.kh.rp < p.kh.maxRP then
						p.kh.rpcharge = $ + max(1, (khFoeDamage[mobj.type]/2))
						while p.kh.rpcharge >= 5 do
							p.kh.rpcharge = $ - 5
							p.kh.rp = $ + 1
							if p.kh.rp == p.kh.maxRP then
								p.kh.rpcharge = 0
							end
						end
					end
				end
				if not mobj.hp then
					attacker.player.kh.target = nil
					return false
				else
					local damage = 4
					local p = attacker.player
					if source and source.basedamage then damage = source.basedamage
					elseif (damageType == DMG_ELECTRIC) then
						damage = 5 
						if p.kh.mag then damage = $ + ((2*p.kh.mag) / 3) end
					elseif p.kh.str then damage = p.kh.str end
					if p.powers[pw_super] then
						damage = ($ * 5) / 2 //250% Damage when Super
					elseif (damageType == DMG_NUKE) then
						damage = max(mobj.hpUnit, $) //Nukes deal at least 1 health of damage
					elseif mobj.def then damage = $ - mobj.def end
					mobj.hp = $ - max(damage, 0)
					if mobj.hp <= 0 then
						p.kh.target = nil
						mobj.health = 0
						P_KillMobj(mobj, source, attacker)
					elseif damage > 0 then
						p.kh.target = mobj
						if mobj.hpUnit != nil and (mobj.hp <= ((mobj.health-1) * mobj.hpUnit)) then
							if (mobj.hp % mobj.hpUnit) == 0 then
								mobj.health = (mobj.hp / mobj.hpUnit)
							else
								mobj.health = 1 + (mobj.hp / mobj.hpUnit)
							end
							S_StartSound(mobj, sfx_dmpain)
							if (mobj.flags & MF_BOSS) then P_AddPlayerScore(p, 100) end
						else
							S_StartSound(mobj, sfx_cybdth)
						end
						//Bounce the player away from the target if they were in contact with it
						A_KnockBack(mobj, 1)
						
						//Finally, make the target immune to damage for half a second
						mobj.recenthit = TICRATE / 2
						mobj.flags2 = MF2_FRET | $
					end
					return true
				end
			end
		end
	end
end)

COM_AddCommand("changeKHDiffMarathon", function(player, newDiff)
	if newDiff == nil
		CONS_Printf(player, "This command allows you to set the difficulty level as the default for marathons.")
	elseif (tonumber(newDiff) > -1) and (tonumber(newDiff) < 5) then
		marathonDiff = newDiff
		CONS_Printf(player, "The default difficulty has been changed to "..khBlastDiffTable[marathonDiff][1].."!")
	else
		local diffStr = string.upper(newDiff)
		if diffStr == "BEGINNER" or diffStr == "STANDARD" or diffStr == "PROUD" or diffStr == "CRITICAL" or diffStr == "EXP ZERO" then
			if diffStr == "BEGINNER" then
				marathonDiff = 0
			elseif diffStr == "STANDARD" then
				marathonDiff = 1
			elseif diffStr == "PROUD" then
				marathonDiff = 2
			elseif diffStr == "CRITICAL" then
				marathonDiff = 3
			elseif diffStr == "EXP ZERO" then
				marathonDiff = 4
			end
			CONS_Printf(player, "The default difficulty has been changed to "..khBlastDiffTable[marathonDiff][1].."!")
		else
			CONS_Printf(player, "Error - " .. newDiff .. " is not a valid Difficulty value")
		end
	end
end, 1)

COM_AddCommand("changeKHDiff", function(player, newDiff)
	if newDiff == nil
		CONS_Printf(player, "This command allows you to change the difficulty level.")
	elseif not (modeattacking or tutorialmode or marathonmode or ultimatemode) then
		local diffStr = string.upper(newDiff)
		if not changeDiff(diffStr) then
			CONS_Printf(player, "Error - " .. newDiff .. " is not a valid Difficulty value")
		else
			for p in players.iterate do
				local lastMaxHP = p.maxHP
				p.maxHP = getMaxHP(p)
				if p.maxHP != lastMaxHP then
					local newHP = (p.hp * p.maxHP * 2) / lastMaxHP
					if (newHP % 2) == 1 then newHP = $ + 1 end
					newHP = $ / 2
					if newHP > p.maxHP then newHP = p.maxHP
					elseif (p.hp > 0 and newHP == 0) then newHP = 1
					end
					p.hp = newHP
				end
				CONS_Printf(p, "The difficulty has been changed to "..khBlastDiffTable[khBlastDiff][1].."!")
			end
		end
	elseif marathonmode then
		CONS_Printf(player, "Hey! No cheezing in marathons! Also, #SaveTheFlickysKillTheFrames.")
	elseif ultimatemode then
		CONS_Printf(player, "What part of 'The difficulty is locked to Ultimate' did you not understand?")
	elseif not tutorialmode then
		CONS_Printf(player, "You can't change the difficulty in Record or NiGHTS attack!")
	else
		CONS_Printf(player, "Hey! I never taught you to use this!")
	end
end, 1)

addHook("LinedefExecute", function(line, mo) 
	if mo.player then
		if ultimatemode then
			local p = mo.player
			p.difsel = true
			p.difselmenu = 2
			p.diffopt = 5
			p.diffcon = 0
			if marathonmode then print(marathonmode) end
		elseif marathonmode then
			p.difsel = true
			p.difselmenu = 2
			p.diffopt = marathonDiff
			p.diffcon = 0
			print(marathonmode)
		else
			local p = mo.player
			p.difsel = true
			p.difselmenu = 1
			p.diffopt = 1
			p.diffcon = 0
		end
	end
end, "KHDSEL")