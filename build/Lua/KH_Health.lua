//Health sutff

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
		//khBlastDiff = khBlastLuaBank[DIFFLUABANK]
		khBlastDiff = 1
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

//Sorts out Health and Mana
rawset(_G, "updateStats", function(p, oldlevel)
	if not p.kh then return end
	local newlevel = p.kh.level
	local levelchange = newlevel - oldlevel
	if levelchange < 0 then return end
	local skin = p.mo.skin
	local data = characterData[skin]
	
	local hpMod = levelchange * data.HPIncrease[1]
	p.maxHP = $ + hpMod
	p.hp = p.maxHP
	for l = oldlevel + 1, newlevel do
		if (l >= data.MPIncrease[2]) and (((l - data.MPIncrease[2]) % data.MPIncrease[3]) == 0) then
			p.maxMP = $ + data.MPIncrease[1]
		end
		if data.STRBoosts[l] then p.kh.str = $ + data.STRBoosts[l] end
		if data.MAGBoosts[l] then p.kh.mag = $ + data.MAGBoosts[l] end
	end
end)