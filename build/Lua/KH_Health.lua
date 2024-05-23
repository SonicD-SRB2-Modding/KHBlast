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

rawset(_G, "khFoeStats", setmetatable({ 
	[MT_BLUECRAWLA] = {baseHP = 8, baseATK = 1, baseXP = 1},
	[MT_REDCRAWLA] = {baseHP = 14, baseATK = 2, baseXP = 1},
	[MT_GFZFISH] = {baseHP = 1, baseATK = 0}, //Stupid Fish only has 1HP and 0 ATK, and doesn't even give XP!
	[MT_GOLDBUZZ] = {baseHP = 4, baseATK = 1, baseXP = 1},
	[MT_REDBUZZ] = {baseHP = 8, baseATK = 2, baseXP = 1},
	[MT_DETON] = {baseHP = 1, baseATK = 4, baseXP = 1},
	[MT_TURRET] = {baseHP = 20, baseATK = 2, baseXP = 1},
	[MT_POPUPTURRET] = {baseHP = 20, baseATK = 4, baseXP = 1},
	[MT_SPRINGSHELL] = {baseHP = 1, baseATK = 1, baseXP = 1},
	[MT_YELLOWSHELL] = {baseHP = 1, baseATK = 2, baseXP = 1},
	[MT_SKIM] = {baseHP = 8, baseATK = 3, baseXP = 1},
	[MT_JETJAW] = {baseHP = 12, baseATK = 2, baseXP = 1},
	[MT_CRUSHSTACEAN] = {baseHP = 10, baseATK = 4, baseXP = 1},
	[MT_BANPYURA] = {baseHP = 8, baseATK = 3, baseXP = 1},
	[MT_ROBOHOOD] = {baseHP = 24, baseATK = 4, baseXP = 1},
	[MT_FACESTABBER] = {baseHP = 32, baseATK = 5, baseXP = 1},
	[MT_SUSPICIOUSFACESTABBERSTATUE] = {baseHP = 32, baseATK = 0},
	[MT_EGGGUARD] = {baseHP = 16, baseATK = 1, baseXP = 1},
	[MT_VULTURE] = {baseHP = 12, baseATK = 3, baseXP = 1},
	[MT_GSNAPPER] = {baseHP = 8, baseATK = 4, baseXP = 1},
	[MT_MINUS] = {baseHP = 10, baseATK = 3, baseXP = 1},
	[MT_CANARIVORE] = {baseHP = 6, baseATK = 1, baseXP = 1},
	[MT_UNIDUS] = {baseHP = 6, baseATK = 2, baseXP = 1},
	[MT_PYREFLY] = {baseHP = 4, baseATK = 3, baseXP = 1},
	[MT_JETTBOMBER] = {baseHP = 20, baseATK = 4, baseXP = 1},
	[MT_JETTGUNNER] = {baseHP = 22, baseATK = 5, baseXP = 1},
	[MT_SPINCUSHION] = {baseHP = 16, baseATK = 6, baseXP = 1},
	[MT_SNAILER] = {baseHP = 18, baseATK = 6, baseXP = 1},
	[MT_PENGUINATOR] = {baseHP = 4, baseATK = 2, baseXP = 1},
	[MT_POPHAT] = {baseHP = 8, baseATK = 3, baseXP = 1},
	[MT_CRAWLACOMMANDER] = {baseHP = 32, baseATK = 3, baseXP = 1},
	[MT_SPINBOBERT] = {baseHP = 4, baseATK = 2, baseXP = 1},
	[MT_CACOLANTERN] = {baseHP = 4, baseATK = 3, baseXP = 1},
	[MT_HANGSTER] = {baseHP = 6, baseATK = 1, baseXP = 1},
	[MT_HIVEELEMENTAL] = {baseHP = 12, baseATK = 1, baseXP = 1},
	[MT_BUMBLEBORE] = {baseHP = 1, baseATK = 3, baseXP = 1},
	[MT_POINTY] = {baseHP = 8, baseATK = 2, baseXP = 1},
	[MT_EGGMOBILE] = {baseHP = 14*8, hpUnits = 14, baseATK = 4},
	[MT_EGGMOBILE2] = {baseHP = 16*8, hpUnits = 16, baseATK = 5},
	[MT_EGGMOBILE3] = {baseHP = 18*8, hpUnits = 18, baseATK = 6},
	[MT_FAKEMOBILE] = {baseHP = 18, hpUnits = 18, baseATK = 2},
	[MT_EGGMOBILE4] = {baseHP = 20*8, hpUnits = 20, baseATK = 7},
	[MT_EGGROBO1] = {baseHP = 100, baseATK = 20, baseXP = 1},
	[MT_FANG] = {baseHP = 10*8, hpUnits = 10, baseATK = 5},
	[MT_BLACKEGGMAN] = {baseHP = 25*12, hpUnits = 25, baseATK = 8},
	[MT_METALSONIC_RACE] = {baseHP = 8*8, baseATK = 2},
	[MT_METALSONIC_BATTLE] = {baseHP = 8*8, hpUnits = 8, baseATK = 9},
	[MT_CYBRAKDEMON] = {baseHP = 25*12, hpUnits = 25, baseATK = 12},
	[MT_GOOMBA] = {baseHP = 1, baseATK = 1, baseXP = 1},
	[MT_BLUEGOOMBA] = {baseHP = 1, baseATK = 2, baseXP = 1},
	[MT_PUMA] = {baseHP = 1, baseATK = 3, baseXP = 1},
	[MT_KOOPA] = {baseHP = 20, baseATK = 5, baseXP = 1},
	[MT_BIGMINE] = {baseHP = 1, baseATK = 3, baseXP = 1},
	[MT_SPIKE] = {baseHP = nil, baseATK = 2},
	[MT_WALLSPIKE] = {baseHP = nil, baseATK = 2},
}, {__index = function() return {baseHP = 10, baseATK = 1, baseXP = 1} end}))

rawset(_G, "khBlastSetFoeHealth", function(m, healthmod, reset)
	if m.maxHP and not reset then return end

	if (m.flags & MF_BOSS) or (m.flags & MF_ENEMY) or (m.type == MT_SUSPICIOUSFACESTABBERSTATUE) then
		local startingHP = khFoeStats[m.type].baseHP
		if startingHP == nil then return end
		m.maxHP = max((startingHP*healthmod)/100,1) //Must have at least 1HP
		m.hp = m.maxHP
		if khFoeStats[m.type].hpUnits then
			m.hpUnit = max((khFoeStats[m.type].hpUnits*healthmod)/100,1)
		else
			m.hpUnit = m.maxHP
		end
	end
end)

local pboss = nil

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
	end
	
	local healthmod = khBlastDifficulties[khBlastDiff].foeHP
	if mapheaderinfo[gamemap].superboss
	and ((tonumber(mapheaderinfo[gamemap].superboss) == 1) and All7Emeralds(emeralds)) or (tonumber(mapheaderinfo[gamemap].superboss) == 2) then //BCZ3 is buffed if all emeralds are obtained
		healthmod = $ + 200 //300% Standard, 350% Proud, 400% Critical, EXP Zero or Ultimate
		if khBlastDiff == 0 then healthmod = $ - 75 end //200% Easy
	end
	
	for m in mobjs.iterate()
		khBlastSetFoeHealth(m, healthmod, true)
	end
	
	if mapheaderinfo[gamemap].superboss
	and ((tonumber(mapheaderinfo[gamemap].superboss) == 1) and All7Emeralds(emeralds)) or (tonumber(mapheaderinfo[gamemap].superboss) == 2) then //BCZ3 has a little bonus if you have all the Emeralds.
		local emeraldsspawn = (tonumber(mapheaderinfo[gamemap].superboss) == 2)
		for p in players.iterate do
			if p.bot then continue end
			P_GivePlayerRings(p, 7*50)
			if modeattacking and (tonumber(mapheaderinfo[gamemap].superboss) == 2) and (not emeraldsspawn) then
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
rawset(_G, "updateStats", function(p, oldlevel, silent)
	if not p.kh then return end
	local newlevel = p.kh.level
	local levelchange = newlevel - oldlevel
	if levelchange <= 0 then return end
	local skin = p.mo.skin
	local data = characterData[skin]
	
	local hpMod = levelchange * data.HPIncrease[1]
	local mpMod = 0
	local strMod = 0
	local magMod = 0
	p.maxHP = $ + hpMod
	p.hp = p.maxHP
	for l = oldlevel + 1, newlevel do
		if (l >= data.MPIncrease[2]) and (((l - data.MPIncrease[2]) % data.MPIncrease[3]) == 0) then
			mpMod = $ + data.MPIncrease[1]
		end
		if data.STRBoosts[l] then strMod = $ + data.STRBoosts[l] end
		if data.MAGBoosts[l] then magMod = $ + data.MAGBoosts[l] end
	end
	p.maxHP = $ + hpMod
	p.hp = p.maxHP
	p.maxMP = $ + mpMod
	p.kh.str = $ + strMod
	p.kh.mag = $ + magMod
	p.kh.commandlist = getSpells(p)
	if (not silent) then
		local bonusString = "Level " .. p.kh.level .. "!"
		if (hpMod > 0) then 
			bonusString = $ .. " +" .. hpMod .. " Max HP" .. (((strMod > 0) or (magMod > 0) or (mpMod > 0)) and "," or "!")
		end
		if (mpMod > 0) then 
			bonusString = $ .. " +" .. mpMod .. " Max MP" .. (((strMod > 0) or (magMod > 0)) and "," or "!")
		end
		if (strMod > 0) then 
			bonusString = $ .. " +" .. strMod .. "STR" .. ((magMod > 0) and "," or "!")
		end
		if (magMod > 0) then 
			bonusString = $ .. " +" .. magMod .. "MAG!"
		end
		p.kh.infotimer = 8*TICRATE
		p.kh.infotext = bonusString
	end
end)

local function xpBoost(p, xp)
	local xpMod = khBlastDifficulties[khBlastDiff].playerXPRate
	if xpMod == 0 then return end
	
	local xpToAdd = xp * xpMod
	if (xpToAdd % 100) >= 50 then
		xpToAdd = ($ / 100) + 1
	elseif xpToAdd < 100 then
		xpToAdd = 1
	else
		xpToAdd = ($ / 100)
	end
	
	p.kh.xpToAdd = $ + xpToAdd
	
	//Spawn an mobj to show the XP gained
	
end

local function xpAdd(p)
	local newXP = p.kh.xp + p.kh.xpToAdd
	p.kh.xp = newXP
	local oldLevel = p.kh.level
	if oldLevel >= 99 then return end
	local xpBarrier = needEXP[oldLevel]
	if newXP >= xpBarrier then
		while newXP >= xpBarrier do
			p.kh.level = $ + 1
			xpBarrier = needEXP[p.kh.level]
			if p.kh.level == 99 then break end
		end
		updateStats(p, oldLevel)
	end
	p.kh.xpToAdd = 0
end

local function emeraldBoost(mo, touch)
	if mo.valid and touch.valid and touch.player then
		local p = touch.player
		local data = characterData[mo.skin]
		local hpMod = data.HPIncrease[3]
		if (getEmeraldCount(p.powers[pw_emeralds]) == 6) then hpMod = $ + data.HPIncrease[4] end
		local mpMod = data.MPIncrease[4]
		if (getEmeraldCount(p.powers[pw_emeralds]) == 6) then mpMod = $ + data.MPIncrease[5] end
		p.maxHP = $ + hpMod
		p.maxMP = $ + moMod
		if (p.hp * 2) >= p.maxHP then
			p.hp = p.maxHP
		else
			p.hp = $ + (p.maxHP / 2)
		end
		p.mp = p.maxMP
		p.kh.itempickuptimer = TICRATE * 6
		p.kh.itempickuptext = "a Chaos Emerald!"
		p.lastEmeralds = getEmeraldCount(p.powers[pw_emeralds]) + 1
		return false
	end
end

addHook("ThinkFrame", function()
	for p in players.iterate do
		if p.kh.xpToAdd > 0 then xpAdd(p) end
	end
end)

addHook("TouchSpecial", function(mo, touch)
	return emeraldBoost(mo, touch)
end, MT_EMERALD1)

addHook("TouchSpecial", function(mo, touch)
	return emeraldBoost(mo, touch)
end, MT_EMERALD2)

addHook("TouchSpecial", function(mo, touch)
	return emeraldBoost(mo, touch)
end, MT_EMERALD3)

addHook("TouchSpecial", function(mo, touch)
	return emeraldBoost(mo, touch)
end, MT_EMERALD4)

addHook("TouchSpecial", function(mo, touch)
	return emeraldBoost(mo, touch)
end, MT_EMERALD5)

addHook("TouchSpecial", function(mo, touch)
	return emeraldBoost(mo, touch)
end, MT_EMERALD6)

addHook("TouchSpecial", function(mo, touch)
	return emeraldBoost(mo, touch)
end, MT_EMERALD7)

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
		khBlastSetFoeHealth(mobj, khBlastDifficulties[khBlastDiff].foeHP)
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

local function damagePlayer(p, damageType, attacker, source)
	if p.hp and not (p.powers[pw_super]) and not (p.kh.down) then
		if p.powers[pw_shield] then
			P_DoPlayerPain(p, attacker, source)
			S_StartSound(p.mo, sfx_s3k35)
			if p.powers[pw_shield] & SH_FORCE then
				if (p.powers[pw_shield] & SH_FORCEHP) then
					p.powers[pw_shield] = $ - 1
				else
					P_RemoveShield(p)
					P_PlayerFlagBurst(p)
				end
			else
				P_RemoveShield(p)
				P_PlayerFlagBurst(p)
			end
		else
			local damage
			local edam = false
			if attacker then
				if attacker.type == MT_PLAYER then
					local ringtype = source.type
						if (ringtype == MT_REDRING) and (source.flags2 & MF2_RAILRING) then damage = 8
						elseif (ringtype == MT_CORK) or (ringtype == MT_REDRING) then damage = 2 //Base Damage
						elseif (ringtype == MT_THROWNINFINITY) or (ringtype == MT_THROWNAUTOMATIC) then damage = 1 //Half Damage
						elseif (ringtype == MT_THROWNBOUNCE) or (ringtype == MT_THROWNSCATTER) then damage = 3 //50% More Damage
						elseif (ringtype == MT_THROWNEXPLOSION) or (ringtype == MT_THROWNGRENADE) then damage = 5 //150% More Damage
						elseif (ringtype == MT_FIREBALL) then 
							damage = source.basedamage
						elseif damageType == DMG_ELECTRIC then
							damage = 5 
							if attacker.player.kh.mag then damage = $ + ((2*attacker.player.kh.mag) / 3) end
						else
							damage = 2 //Need to find what Weapon Ring or Magic was used
						end
				else
					damage = (khFoeStats[attacker.type].baseATK * khBlastDifficulties[khBlastDiff].foeDam)/50
					damage = ($ / 2) + ($ % 2)
				end
			else
				if damageType == DMG_FIRE then damage = khBlastDifficulties[khBlastDiff].foeDam / 20
				elseif damageType == DMG_ELECTRIC then damage = khBlastDifficulties[khBlastDiff].foeDam / 25
				elseif damageType == DMG_WATER or damageType == DMG_SPIKE then damage = khBlastDifficulties[khBlastDiff].foeDam / 50
				elseif damageType == DMG_NUKE then damage = (3 * khBlastDifficulties[khBlastDiff].foeDam) / 50
				else damage = max(1, khBlastDifficulties[khBlastDiff].foeDam / 100) //DMG_NORMAL
				end
				edam = true
			end
			if p.endure then
				p.hp = max($ - damage, 1)
				if p.hp == 1 then p.endure = false end
			else
				p.hp = max($ - damage, 0)
			end
			P_PlayerEmeraldBurst(p)
			P_PlayerWeaponAmmoBurst(p)
			P_PlayerFlagBurst(p)
			if p.hp > 0 then
				if not (skins[p.mo.skin].soundsid[SKSPLPAN1] == skins["sonic"].soundsid[SKSPLPAN1]) then
					S_StartSound(p.mo,sfx_altow1)
				else
					S_StartSound(p.mo,sfx_s3k35)
				end
				P_DoPlayerPain(p, attacker, source)	// Set knockback
				if G_GametypeUsesLives() or (gametype == GT_RACE) or edam then
					p.powers[pw_flashing] = 50	// Set invuln flashing
				else
					p.powers[pw_flashing] = 25
				end
			else
				if p.bot or (not multiplayer) then //TailsBot can't be revived, and you can't revive in SP
					p.mo.health = 0
					P_KillMobj(p.mo, source, attacker) //Non-shield fatal damage
				else
					p.kh.down = true
					P_DoPlayerPain(p, attacker, source)
					S_StartSound(p.mo,sfx_kc31)
				end
			end
		end
		if attacker then
			if attacker.player then
				if p.hp > 0 then
					P_AddPlayerScore(attacker.player, 50)
				else
					P_AddPlayerScore(attacker.player, 100)
				end
			end
		end
		return true
	elseif p.kh.down then
		if p.powers[pw_shield] then
			if p.powers[pw_shield] & SH_FORCE then
				if (p.powers[pw_shield] & SH_FORCEHP) then
					p.powers[pw_shield] = $ - 1
				else
					P_RemoveShield(p)
				end
			else
				P_RemoveShield(p)
			end
		end
		return ture
	else
		return false
	end
end

local function damageEnemy(mobj, source, attacker, nordam, damageType)
	if attacker and attacker.valid then
		if attacker.player then
			if (mobj.flags & MF_BOSS) then //Bosses
				local p = attacker.player
				if p.mp < p.maxMP then //Restore 2.5 MP per hit
					p.mpTic = $ - 25
					p.mp = min(p.maxMP, $ + 2)
					if p.mpTic <= 0 then
						p.mpTic = $ + 50
						p.mp = $ + 1
					end
					if p.mp >= p.maxMP then
						p.mp = p.maxMP
						p.mpTic = 50
					end
				end
			elseif not(attacker.player.powers[pw_super]) and (not ultimatemode) then
				P_GivePlayerRings(attacker.player, max(1, ((khFoeStats[mobj.type].baseATK)/2))) //Rings = Drive
			elseif ultimatemode then
				local p = attacker.player
				if p.mp < p.maxMP then //Restore 2.5 MP per hit
					p.mpTic = $ - 25
					p.mp = min(p.maxMP, $ + 2)
					if p.mpTic <= 0 then
						p.mpTic = $ + 50
						p.mp = $ + 1
					end
					if p.mp >= p.maxMP then
						p.mp = p.maxMP
						p.mpTic = 50
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
					if khFoeStats[mobj.type].baseXP then //Grant XP if they would give XP
						if p.bot then
							xpBoost(players[0], khFoeStats[mobj.type].baseXP)
						else
							xpBoost(p, khFoeStats[mobj.type].baseXP)
						end
					end
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

addHook("MobjDamage", function(mobj, source, attacker, nordam, damageType)
	if not mobj.valid then return false end
	if (mapheaderinfo[gamemap].typeoflevel & TOL_NIGHTS) then return false end //NiGHTS stages remain as normal
	if damageType then
		if (damageType & DMG_DEATHMASK) then
			if mobj.type == MT_PLAYER then
				mobj.player.hp = 0
			end
			P_KillMobj(mobj, source, attacker)
			return true
		end //Insta-kills are ignored
	end
	if mobj.type == MT_PLAYER then
		return damagePlayer(mobj.player, damageType, attacker, source)
	else
		return damageEnemy(mobj, source, attacker, nordam, damageType)
	end
end)

addHook("PlayerSpawn", function(p)
	local skin = p.mo.skin
	local data = characterData[skin]
	if not p.hp then
		p.hp = data.StartingHP
		p.maxHP = data.StartingHP
		p.maxMP = data.StartingMP
		p.mpRecharge = 0
		p.mpTic = 50
		if p.kh == nil then 
			setupKHStuff(p) 
		end
		p.kh.str = data.StartingSTR
		p.kh.mag = data.StartingMAG
		if p.kh.level > 1 then
			updateStats(p, 1, true)
		end
	end
	p.mp = p.maxMP
	p.mpRecharge = 0
	p.mpTic = 50
end)