rawset(_G, "khBlast", true)
rawset(_G, "khBlastVersion", "RC 2")
rawset(_G, "khBlastDiff", 1)
rawset(_G, "khBlastcleargame", false)
rawset(_G, "MATCHXPMOD", 100)
rawset(_G, "RATTACKXPMOD", 10)
rawset(_G, "nextKHBlastDiff", 1)
rawset(_G, "marathonDiff", 1)
rawset(_G, "REVIVETIME", (TICRATE * 20))

freeslot("sfx_cmdsel", "sfx_cmdbak", "sfx_cmderr", "sfx_lvlup")

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

rawset (_G, "setupKHStuff", function(p)
	if not p.kh then
		p.kh = {
			itemlist = {},
			commandlist = {},
			lastWpn = 0,
			lastMagic = 1,
			cOption = 1,
			comButton = false,
			lastOption = -1,
			menuMode = 0,
			xp = 0,
			level = 1,
			str = 4,
			mag = 4,
			cList = {"", "", ""},
			itempickuptimer = 0,
			itempickuptext = "",
			emeraldCount = 0,
			target = nil,
			lasthp = p.hp,
			down = false,
			revivalTimer = REVIVETIME,
			xpToAdd = 0
		}
		p.lives = 1
		return true //Just set them up
	end
	return false //Already set up
end)

COM_AddCommand("changeKHDiffMarathon", function(player, newDiff)
	if newDiff == nil
		CONS_Printf(player, "This command allows you to set the difficulty level as the default for marathons.")
	elseif marathonmode then
		CONS_Printf(player, "Hey! You can't change the marathon difficulty during a marathon! Also, #SaveTheFramesKillTheFlickys.")
	elseif (tonumber(newDiff) > -1) and (tonumber(newDiff) < 5) then
		marathonDiff = newDiff
		CONS_Printf(player, "The default marathon mode difficulty has been changed to "..(khBlastDifficulties[marathonDiff].name).."!")
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
			CONS_Printf(player, "The default difficulty has been changed to "..(khBlastDifficulties[marathonDiff].name).."!")
		else
			CONS_Printf(player, "Error - " .. newDiff .. " is not a valid Difficulty value")
		end
	end
end, 1)

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
	//khBlastLuaBank[DIFFLUABANK] = khBlastDiff
	return true
end

/*COM_AddCommand("changeKHDiff", function(player, newDiff)
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
end, 1)*/

addHook("ThinkFrame", function()
	//Temp deets for testing
	for p in players.iterate do
		if p.hp == nil then
			if not (p.mo and p.mo.skin) continue end
			local skin = p.mo.skin
			local data = characterData[skin]
			p.hp = data.StartingHP
			p.maxHP = data.StartingHP
			p.mp = data.StartingMP
			p.maxMP = data.StartingMP
			p.mpRecharge = 0
			p.mpTic = 50
			setupKHStuff(p)
			p.kh.str = data.StartingSTR
			p.kh.mag = data.StartingMAG
		end
	end
end)

rawset(_G, "khBlastDifficulties", {
	[0] = {
		name = "Beginner",
		foeDam = 50,
		foeHP = 75,
		playerHP = 125,
		playerMP = 100,
		playerXPRate = 90,
		description = "\x83".."For casual players.\n\n".."\x80".."Damage recieved reduced by 50%\n\nMax HP increased by 25%\nFoe HP reduced by 25%"
	},
	[1] = {
		name = "Standard",
		foeDam = 100,
		foeHP = 100,
		playerHP = 100,
		playerMP = 100,
		playerXPRate = 100,
		description = "\x84".."For normal players.\n\n".."\x80".."Normal damage and Max HP."
	},
	[2] = {
		name = "Proud",
		foeDam = 150,
		foeHP = 150,
		playerHP = 100,
		playerMP = 100,
		playerXPRate = 110,
		description = "\x82".."For advanced players.\n\n".."\x80".."Damage recieved increased by 50%\n\nMax HP unaltered.\nFoe HP increased by 50%"
	},
	[3] = {
		name = "Critical",
		foeDam = 200,
		foeHP = 200,
		playerHP = 75,
		playerXPRate = 120,
		description = "\x87".."For expert players.\n\n".."\x80".."Damage recieved increased by 100%.\n\nMax HP reduced by 25%\nFoe HP increased by 100%"
	},
	[4] = {
		name = "EXP Zero",
		foeDam = 200,
		foeHP = 200,
		playerHP = 75,
		playerMP = 100,
		playerXPRate = 0,
		description = "\x85".."For master players.\n\n".."\x80".."Damage recieved increased by 100%.\n\nMax HP reduced by 25%\nFoe HP increased by 100%".."\x85".."No EXP from foes!"
	},
	[5] = {
		name = "ULTIMATE",
		foeDam = 250,
		foeHP = 250,
		playerHP = 50,
		playerMP = 50,
		playerXPRate = 0,
		description = "\x85".."DIFFICULTY LOCKED TO ULTIMATE.\n".."\x80".."Damage recieved increased by 150%.\n\nMax HP and MP reduced by 50%\nFoe HP increased by 100%\nNo Rings, AutoLives, Continues, or Healing.\n".."\x85".."No EXP from foes!"
	}
})

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

//Code for the linedef that triggers at the start of the Station
addHook("LinedefExecute", function(line, mo) 
	if mo.player then
		if ultimatemode then
			local p = mo.player
			p.difsel = true
			p.difselmenu = 2
			p.diffopt = 5
			p.diffcon = 0
			//if marathonmode then print(marathonmode) end
		elseif marathonmode then
			p.difsel = true
			p.difselmenu = 2
			p.diffopt = marathonDiff
			p.diffcon = 0
			//print(marathonmode)
		else
			local p = mo.player
			p.difsel = true
			p.difselmenu = 1
			p.diffopt = 1
			p.diffcon = 0
		end
	end
end, "KHDSEL")

addHook("ThinkFrame", function()
	for p in players.iterate do
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
	end
end)