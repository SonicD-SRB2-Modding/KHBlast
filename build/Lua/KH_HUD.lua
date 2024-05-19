//Hud Stuff

rawset(_G, "khheadpatch", setmetatable({
	//Each character will have (up to) five HUD sprites, in this order:
	//Normal, Low Health, KOed, Damaged, Super and Unique
	//KH_CHARA, KL_CHARA, KK_CHARA, KD_CHARA, KS_CHARA, KU_CHARA
	["sonic"] = {"KH_SONIC", "KL_SONIC"},
	["tails"] = {"KH_TAILS", "KL_TAILS"},
	["knuckles"] = {"KH_KNUX", "KL_KNUX"},
	["amy"] = {"KH_AMY", "KL_AMY"},
	["fang"] = {"KH_FANG", "KL_FANG"},
	["metalsonic"] = {"KH_METAL", "KL_METAL"}
}, {__index = function() return {"KH_BASE"} end}))

local hpbarskin = {
	[0] = SKINCOLOR_GREY,
	[1] = SKINCOLOR_GREEN,
	[2] = SKINCOLOR_LIME,
	[3] = SKINCOLOR_BLUE,
	[4] = SKINCOLOR_ORANGE,
	[5] = SKINCOLOR_ROSY,
	[6] = SKINCOLOR_AQUA,
	[7] = SKINCOLOR_FLAME,
}

local mpbarskin = SKINCOLOR_BLUE

//Flags for HUD stuff
local healthflags = V_SNAPTORIGHT|V_SNAPTOTOP|V_HUDTRANS
local playerhealthflags = V_SNAPTORIGHT|V_SNAPTOBOTTOM|V_HUDTRANS
local playerhudflags = V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_HUDTRANS

local shieldskin = {
	[SH_NONE] = SKINCOLOR_BLACK,
	[SH_PITY] = SKINCOLOR_BONE,
	[SH_WHIRLWIND] = SKINCOLOR_AZURE,
	[SH_ARMAGEDDON] = SKINCOLOR_CRIMSON,
	[SH_PINK] = SKINCOLOR_ROSY,
	[SH_FORCE] = SKINCOLOR_CORNFLOWER,
	[SH_FORCE + 1] = SKINCOLOR_BLUE,
	[SH_FORCE + 2] = SKINCOLOR_COBALT,
	[SH_FIREFLOWER] = SKINCOLOR_WHITE,
	[SH_FLAMEAURA] = SKINCOLOR_FLAME,
	[SH_BUBBLEWRAP] = SKINCOLOR_WAVE,
	[SH_ELEMENTAL] = SKINCOLOR_RUBY,
	[SH_ATTRACT] = SKINCOLOR_YELLOW,
	[SH_THUNDERCOIN] = SKINCOLOR_GOLD,
}

local function getshieldskin(p)
	local shield = p.powers[pw_shield]
	if shieldskin[shield] then return shieldskin[shield]
	elseif (shield & SH_FORCE) then return shieldskin[SH_FORCE + 2]
	elseif (shield & SH_FIREFLOWER) then
		shield = $ & (~SH_FIREFLOWER)
		if shieldskin[shield] then return shieldskin[shield]
		elseif (shield & SH_FORCE) then return shieldskin[SH_FORCE + 2]
		else
			return SKINCOLOR_EMERALD //For custom shields
		end
	else
		return SKINCOLOR_EMERALD //For custom shields
	end
	
end

local function drawHPBar(v, p, length, tier, fillpercent, sx, sy, flags, party)
	local lasttier = min(max(tier - 1, 0), 7)
	local colormap
	local lastcolormap
	local redcolormap = v.getColormap("sonic", SKINCOLOR_RED)
	local y = sy*FRACUNIT
	if party then y = $ - (FRACUNIT/2) end
	if tier < 0 then
		colormap = v.getColormap("sonic", SKINCOLOR_GREEN)
		if tier < -1 then
			lastcolormap = v.getColormap("sonic", SKINCOLOR_FOREST)
		else
			lastcolormap = v.getColormap("sonic", hpbarskin[0])
		end
	else
		colormap = v.getColormap("sonic", hpbarskin[tier])
		lastcolormap = v.getColormap("sonic", hpbarskin[lasttier])
	end
	if lasttier == 7 then
		v.drawStretched(sx*FRACUNIT, y, (length*FRACUNIT)/2, FRACUNIT/2, v.cachePatch("KHP_BAR"), flags, lastcolormap)
	elseif fillpercent <= 0 then
		colormap = v.getColormap("sonic", hpbarskin[0])
		v.drawStretched(sx*FRACUNIT, y, (length*FRACUNIT)/2, FRACUNIT/2, v.cachePatch("KHP_BAR"), flags, colormap)
	else
		v.drawStretched(sx*FRACUNIT, y, (fillpercent*FRACUNIT)/2, FRACUNIT/2, v.cachePatch("KHP_BAR"), flags, colormap)
		if fillpercent < length then
			v.drawStretched((sx*FRACUNIT)-((fillpercent*FRACUNIT)/2), y, (length*(FRACUNIT/2))-(fillpercent*(FRACUNIT/2)), FRACUNIT/2, v.cachePatch("KHP_BAR"), flags, lastcolormap)
		end
	end
	
	local hudstag = "KHP"
	if p then
		if p.powers[pw_shield] then
			hudstag = "KHS"
			colormap =  v.getColormap("sonic", getshieldskin(p))
		end
	end
	
	if party then
		local hudtags = "N"
		if p.powers[pw_shield] then
			hudtags = "S"
		end
		v.draw(sx, sy-1, v.cachePatch("KSB_EN"..hudtags), flags, colormap)
		v.drawStretched((sx*FRACUNIT)-((length-2)*(FRACUNIT/2)), (sy-1)*FRACUNIT, (length-4)*(FRACUNIT/2), FRACUNIT,  v.cachePatch("KSB_MD"..hudtags), flags, colormap)
		v.drawStretched((sx*FRACUNIT)-((length+4)*(FRACUNIT/2)), (sy-1)*FRACUNIT, FRACUNIT, FRACUNIT, v.cachePatch("KSB_ST"..hudtags), flags, colormap)
	else
		v.draw(sx+15, sy-1, v.cachePatch(hudstag.."_END"), flags, colormap)
		v.drawStretched((sx*FRACUNIT)-((length-2)*(FRACUNIT/2)), (sy-1)*FRACUNIT, (length-4)*(FRACUNIT/2), FRACUNIT,  v.cachePatch(hudstag.."_MID"), flags, colormap)
		v.drawStretched((sx*FRACUNIT)-((length+4)*(FRACUNIT/2)), (sy-1)*FRACUNIT, FRACUNIT, FRACUNIT, v.cachePatch(hudstag.."_STA"), flags, colormap)
	end
end

local MAXHPBARS = 7

local MAXFOEHEALTHBAR = 100

local function drawKHFoeHealthNew(v, p, x, y)
	if not p.kh then return 0 end
	if not p.kh.target then return 0 end
	local targethealth
	local targetmaxhealth
	local healthbarlen
	if p.kh.target.maxHP then 
		targethealth = p.kh.target.hp
		targetmaxhealth = p.kh.target.maxHP
		if targetmaxhealth < MAXFOEHEALTHBAR then
			healthbarlen = targetmaxhealth
		else
			if ((targethealth-1) / MAXFOEHEALTHBAR) == (targetmaxhealth / MAXFOEHEALTHBAR) then
				healthbarlen = (targetmaxhealth % MAXFOEHEALTHBAR)
				if healthbarlen == 0 then healthbarlen = MAXFOEHEALTHBAR end
			else
				healthbarlen = MAXFOEHEALTHBAR
			end
		end
	else return 0 end
	local targetHPunits = 0
	local healthbarmaxpercent = targetmaxhealth
	local healthbarpercent = targethealth % MAXFOEHEALTHBAR
	if (targethealth > 0) and (healthbarpercent == 0) then healthbarpercent = MAXFOEHEALTHBAR end
	while healthbarmaxpercent > MAXFOEHEALTHBAR do
		targetHPunits = $ + 1
		healthbarmaxpercent = $ - MAXFOEHEALTHBAR
	end
	local sx = x-1
	local sy = y*FRACUNIT
	
	if healthbarpercent <= 0 then
		v.drawStretched(sx*FRACUNIT, sy, (healthbarlen*FRACUNIT), FRACUNIT, v.cachePatch("HPB_EMP"), healthflags)
	else
		v.drawStretched(sx*FRACUNIT, sy, (healthbarpercent*FRACUNIT), FRACUNIT, v.cachePatch("HPB_FIL"), healthflags)
		if healthbarpercent < healthbarlen then
			local patch = targethealth > MAXFOEHEALTHBAR and v.cachePatch("HPB_NXT") or v.cachePatch("HPB_EMP")
			v.drawStretched((sx*FRACUNIT)-(healthbarpercent*(FRACUNIT)), sy, (healthbarlen*(FRACUNIT))-(healthbarpercent*(FRACUNIT)), FRACUNIT, patch, healthflags)
		end
	end
	v.draw(x, y, v.cachePatch("HPB_END"), healthflags)
	v.drawStretched(sx*FRACUNIT, sy, (healthbarlen)*(FRACUNIT), FRACUNIT,  v.cachePatch("HPB_BAR"), healthflags)
	v.drawStretched((sx*FRACUNIT)-(healthbarlen*(FRACUNIT)), sy, FRACUNIT, FRACUNIT, v.cachePatch("HPB_STA"), healthflags)
	
	local i = 1
	while i <= targetHPunits do
		if targethealth > (MAXFOEHEALTHBAR*i) then
			v.draw(x-((i+1)*7), y, v.cachePatch("HPB_UHF"), healthflags)
		else
			v.draw(x-((i+1)*7), y, v.cachePatch("HPB_UHE"), healthflags)
		end
		i = $ + 1
	end
	v.draw(x-((i+1)*7), y, v.cachePatch("HPB_UHS"), healthflags)
	return targetHPunits
end

local function drawKHFoeHealth(v, p, x, y)
	if not p.kh then return end
	if not p.kh.target then return end
	local targethealth
	local targetmaxhealth
	local healthbarlen
	if p.kh.target.maxHP then 
		targethealth = p.kh.target.hp
		targetmaxhealth = p.kh.target.maxHP
		healthbarlen = min(targetmaxhealth, MAXFOEHEALTHBAR)
	else return end
	local targetHPunits = 0
	local healthbarmaxpercent = targetmaxhealth
	local healthbarpercent = targethealth % MAXFOEHEALTHBAR
	if (targethealth > 0) and (healthbarpercent == 0) then healthbarpercent = MAXFOEHEALTHBAR end
	while healthbarmaxpercent > MAXFOEHEALTHBAR do
		targetHPunits = $ + 1
		healthbarmaxpercent = $ - MAXFOEHEALTHBAR
	end
	local b = -1
	if targethealth > MAXFOEHEALTHBAR then b = -2 end
	
	drawHPBar(v, nil, healthbarlen, b, healthbarpercent, x-22, y+2, healthflags, false)
	local i = 1
	while i <= targetHPunits do
		if targethealth > (MAXFOEHEALTHBAR*i) then
			v.drawScaled((x-((i*6)+20))*FRACUNIT, (y+8)*FRACUNIT, (3*FRACUNIT)/4, v.cachePatch("KB_BARF"), healthflags)
		elseif healthbarredpercent > 100 then
			v.drawScaled((x-((i*6)+20))*FRACUNIT, (y+8)*FRACUNIT, (3*FRACUNIT)/4, v.cachePatch("KB_BARR"), healthflags)
		else
			v.drawScaled((x-((i*6)+20))*FRACUNIT, (y+8)*FRACUNIT, (3*FRACUNIT)/4, v.cachePatch("KB_BARE"), healthflags)
		end
		i = $ + 1
	end
	return targetHPunits
end

rawset(_G, "khBlastlevelinfo", {
	[1]   = "Make your way to Greenflower Mountain!",
	[2]   = "Make your way to Greenflower Mountain!",
	[4]   = "Head to Eggman's factory!",
	[5]   = "Make your way through the factory!",
	[7]   = "Head to the underwater temple!",
	[8]   = "Head to the underwater temple!",
	[10]  = "Make your way to Castle Eggman!",
	[11]  = "Make your way through the Castle!",
	[13]  = "Head through the canyon!",
	[14]  = "Catch up with that train!",
	[16]  = "Reach the rocket!",
	[22]  = "Head through the Egg Rock!",
	[23]  = "Make your way to the Black Core!",
	[25]  = "Beat Metal Sonic to the goal!",
	[30]  = "Find Amy Rose!",
	[31]  = "Get to the castle!",
	[32]  = "Get through the classic Forest!",
	[33]  = "Get through the classic Factory!",
	[40]  = "Get through these haunted heights!",
	[41]  = "Get to the Starlight Palace!",
	[42]  = "Make your way through the submerged temple!",
	[50]  = "Rescue the Green Chaos Emerald!",
	[51]  = "Rescue the Purple Chaos Emerald!",
	[52]  = "Rescue the Blue Chaos Emerald!",
	[53]  = "Rescue the Light Blue Chaos Emerald!",
	[54]  = "Rescue the Orange Chaos Emerald!",
	[55]  = "Rescue the Red Chaos Emerald!",
	[56]  = "Rescue the Gray Chaos Emerald!",
	[57]  = "Rescue the Wireframe Chaos Emerald!",
	[1000]= "Learn how to play with Amy Rose!"
})

local function drawKHInfoBar(v, p, ox, oy)
	
	local y = oy
	if (p.realtime < TICRATE*10) or (p.kh and p.kh.infotimer and (p.kh.infotimer <= TICRATE * 8)) then
		//Draw the level information details
		local infostring = "Reach the goal!"
		if (mapheaderinfo[gamemap].levelflags & LF_WARNINGTITLE) then
			if p.kh then
				local name = getbossname(p.kh.target)
				if name then
					infostring = "Defeat "..name.."!"
				else
					infostring = "Defeat the boss!"
				end
			else
				infostring = "Defeat the boss!"
			end
		end
		
		if (mapheaderinfo[gamemap].typeoflevel & TOL_NIGHTS) or G_IsSpecialStage() then
			y = $ + 36
			if G_IsSpecialStage() then
				infostring = "Rescue the Chaos Emerald!"
			else
				infostring = "Rescue the Ideya(s)!"
			end
		end
		
		//Custom level information stuff for certain levels
		if khBlastlevelinfo[gamemap] ~= nil then infostring = khBlastlevelinfo[gamemap] end
		
		if mapheaderinfo[gamemap].dungeon and DNG and DNGLVL then
			if (DNGLVL == #DNG.levels) then
				infostring = "Find and defeat Eggman!"
			elseif DNG.levels[DNGLVL].hasMiniboss then
				infostring = "Find and defeat the miniboss!"
			elseif DNG.levels[DNGLVL].hasKey then
				infostring = "Find the key!"
			elseif DNG.levels[DNGLVL].hasEmerald and not DNG.levels[DNGLVL].emeraldGot then
				infostring = "Find the Chaos Emerald!"
			else
				infostring = "Find the exit spring!"
			end
		end
		
		if gametype == GT_MATCH then
			infostring = "Defeat the other players!"
		elseif gametype == GT_COMPETITION then
			infostring = "Compete for the best score, time and rings!"
		elseif gametype == GT_RACE then
			if mapheaderinfo[gamemap].numlaps then
				infostring = "Race around the circuit and beat the other players!"
			else
				infostring = "Beat the other players to the goal!"
			end
		elseif gametype == GT_TEAMMATCH then
			infostring = "Work together to defeat the other team!"
		elseif gametype == GT_TAG then
			if (p.pflags & PF_TAGIT) then
				infostring = "Tag the other players!"
			else
				infostring = "Don't get tagged!"
			end
		elseif gametype == GT_HIDEANDSEEK then
			if (p.pflags & PF_TAGIT) then
				infostring = "Seek the other players!"
			else
				infostring = "Hide and don't get caught!"
			end
		elseif gametype == GT_CTF then
			infostring = "Capture the other team's flag!"
		end
		if p.kh and (p.kh.infotext ~= nil) and (p.kh.infotext ~= "") then infostring = p.kh.infotext end
		local stringlen = v.stringWidth(infostring, nil, "small")
		local x = ox - 2
		local barx = x - max(stringlen + 2, 86)
		local time
		if p.kh and p.kh.infotimer then time = (10*TICRATE - p.kh.infotimer) else time = p.realtime end
		if time < 0 then return end
		if time > TICRATE*5 then x = $ + time - (TICRATE*5) end
		if x > 325 + stringlen then return end
		v.drawStretched(ox*FRACUNIT, y*FRACUNIT, (ox-barx)*FRACUNIT, FRACUNIT, v.cachePatch("IN_SBAR"), healthflags)
		v.draw(barx, y, v.cachePatch("IN_SBRC"), healthflags)
		v.draw(ox, y, v.cachePatch("IN_INTB"), healthflags)
		v.draw(ox, y, v.cachePatch("IN_INTX"), healthflags)
		v.drawString(x, y+1, infostring, healthflags, "small-right")
	elseif p.kh and p.kh.itempickuptimer then
		local string
		if p.kh.itempickuptext ~= nil and p.kh.itempickuptext ~= "" then
			string = "Obtained "..p.kh.itempickuptext
		elseif khItemList[p.kh.itempickup] then
			local itemget = khItemList[p.kh.itempickup]
			string = "Obtained "..itemget[5].." - "..itemget[2]
		else return end
		local stringlen = v.stringWidth(string, nil, "small")
		//Example String: "Obtained Potion - Heals 20HP
		local x = ox - 2
		local barx = x - max(stringlen + 2, 67)
		if p.kh.itempickuptimer < TICRATE*5 then x = $ + (5*TICRATE) - p.kh.itempickuptimer end
		if x > 325 + stringlen then return end
		v.drawStretched(ox*FRACUNIT, y*FRACUNIT, (ox-barx)*FRACUNIT, FRACUNIT, v.cachePatch("IN_SBAR"), healthflags)
		v.draw(barx, y, v.cachePatch("IN_SBRC"), healthflags)
		v.draw(ox, y, v.cachePatch("IN_ITTB"), healthflags)
		v.draw(ox, y, v.cachePatch("IN_ITTX"), healthflags)
		v.drawString(x, y+1, string, healthflags, "small-right")
	end
end

local function drawKHDriveBar(v, p, x, y)
	local driveCharge = p.rings % 50
	local dp = p.rings / 50
	local formgauge
	if p.kh and p.kh.lastdp then formgauge = p.kh.lastdp else formgauge = 1 end
	local gaugefill
	local barpatch = "KDP_BAR"
	local colormap = v.getColormap("sonic", SKINCOLOR_GREY)
	if p.powers[pw_super] then
		gaugefill = (p.rings * 100) / formgauge
		if gaugefill > 100 then gaugefill = 100 end
		barpatch = "KDP_DF"..tostring(1+((p.realtime % 20)/4))
	elseif not ((gametype == GT_COOP) or (gametype == GT_COMPETITION)) then
		if p.powers[0] and (p.powers[0] == p.powers[1]) then
			gaugefill = min((p.powers[0]*5)/TICRATE, 100)
			dp = (gaugefill*7) / 100
			barpatch = "KDP_DF"..tostring(1+((p.realtime % 20)/4))
		else
			dp = getEmeraldCount(p.powers[pw_emeralds])
			gaugefill = (dp * 100) / 7
		end
	else
		gaugefill = driveCharge * 2
		if dp > 0 then
			colormap = v.getColormap("sonic", SKINCOLOR_GOLD)
		end
	end
	if gaugefill < 100 then
		v.drawStretched(((x-3)*FRACUNIT)-((gaugefill*FRACUNIT)/2), (y+1)*FRACUNIT, (50*FRACUNIT)-(gaugefill*(FRACUNIT/2)), FRACUNIT/2, v.cachePatch("KHP_BAR"), playerhealthflags, colormap)
	end
	if p.powers[pw_super] then
		colormap = v.getColormap("sonic", p.mo.color)
	else
		colormap = v.getColormap("sonic", SKINCOLOR_YELLOW)
	end
	v.drawStretched((x-3)*FRACUNIT, (y+1)*FRACUNIT, (gaugefill*FRACUNIT)/2, FRACUNIT/2, v.cachePatch("KHP_BAR"), playerhealthflags, colormap)
	v.draw(x, y, v.cachePatch(barpatch), playerhealthflags)
	v.drawScaledNameTag((x-(37+(v.nameTagWidth(tostring(dp))/2)))*FRACUNIT, (y-11)*FRACUNIT, tostring(dp), playerhealthflags, FRACUNIT / 2, SKINCOLOR_YELLOW)
end

local function drawPartyHPHUD(v, p, x, y)
	local hudpatch = khheadpatch[p.mo.skin]
	//If Super or Hyper, change the hudpatch if they have one
	v.drawScaled(x*FRACUNIT, y*FRACUNIT, FRACUNIT/2, v.cachePatch("KH_BASE"), playerhealthflags, v.getColormap(p.mo.skin, p.skincolor))
	local playerpatch = "KH_PUN"
	if p.bot == 1 then
		playerpatch = "KH_PBOT"
	elseif p.bot > 1 then
		playerpatch = "KH_P"..tostring(p.bot)
	elseif v.patchExists("KH_P"..tostring(#p+1)) then
		playerpatch = "KH_P"..tostring(#p+1)
	end
	v.draw(x-31, y-14, v.cachePatch(playerpatch), playerhealthflags, v.getColormap(p.mo.skin, p.mo.color))
	if p.maxHP then
		local hpBarLength = min(p.maxHP, 100)
		local hpBarPercent = p.hp
		local hpBarState = 1
		while hpBarPercent > 100 do
			hpBarState = $ + 1
			hpBarPercent = $ - 100
			if hpBarState > MAXHPBARS then
				hpBarState = MAXHPBARS 
				hpBarPercent = 100
			end
		end
		local healthbarredpercent = hpBarPercent + (p.kh.lasthp -  p.hp)
		if hpBarState == MAXHPBARS then healthbarredpercent = 100 end
		if hudpatch then //This draws the player icon
			if p.powers[pw_super] and hudpatch[5] then
				v.drawScaled(x*FRACUNIT, y*FRACUNIT, FRACUNIT/2, v.cachePatch(hudpatch[5]), playerhealthflags, v.getColormap(p.mo.skin, p.mo.color))
			elseif hudpatch[4] and p.hp <= 0 then
			`v.drawScaled(x*FRACUNIT, y*FRACUNIT, FRACUNIT/2, v.cachePatch(hudpatch[4]), playerhealthflags, v.getColormap(p.mo.skin, p.mo.color))
			elseif hudpatch[3] and p.recentdamaged then
			`v.drawScaled(x*FRACUNIT, y*FRACUNIT, FRACUNIT/2, v.cachePatch(hudpatch[3]), playerhealthflags, v.getColormap(p.mo.skin, p.mo.color))
			elseif hudpatch[2] and (p.hp * 5) <= p.maxHP then
				v.drawScaled(x*FRACUNIT, y*FRACUNIT, FRACUNIT/2, v.cachePatch(hudpatch[2]), playerhealthflags, v.getColormap(p.mo.skin, p.mo.color))
			else
				v.drawScaled(x*FRACUNIT, y*FRACUNIT, FRACUNIT/2, v.cachePatch(hudpatch[1]), playerhealthflags, v.getColormap(p.mo.skin, p.mo.color))
			end
		end
		if hpBarPercent == 0 and p.hp then hpBarPercent = 1 end
		drawHPBar(v, p, hpBarLength, hpBarState, hpBarPercent, x-8, y+2, playerhealthflags, true)
	else
		if hudpatch then //This draws the player icon
			if p.powers[pw_super] and hudpatch[5] then
				v.drawScaled(x*FRACUNIT, y*FRACUNIT, FRACUNIT/2, v.cachePatch(hudpatch[5]), playerhealthflags, v.getColormap(p.mo.skin, p.mo.color))
			else
				v.drawScaled(x*FRACUNIT, y*FRACUNIT, FRACUNIT/2, v.cachePatch(hudpatch[1]), playerhealthflags, v.getColormap(p.mo.skin, p.mo.color))
			end
		end
	end
end

local function drawKHHPHud(v, p, player, x, sy, playerone, playertwo, ally, split)
	if p.mo
		local y = sy
		if p == player and (not p.bot) then //Current Player
			if playertwo and p == playerone then
				y = $ - 100
			end
			local hudpatch = khheadpatch[p.mo.skin]
			
			//If Super or Hyper, change the hudpatch if they have one
			v.drawScaled(x*FRACUNIT, y*FRACUNIT, FRACUNIT/2, v.cachePatch("KH_BASE"), playerhealthflags, v.getColormap(p.mo.skin, p.skincolor))
			
			//Draw the player's HP bar
			if p.maxHP then
				local hpBarLength = min(p.maxHP, 100)
				local hpBarPercent = max(p.hp, 0)
				local hpBarState = 1
				while hpBarPercent > 100 do
					hpBarState = $ + 1
					if hpBarState > MAXHPBARS then
						hpBarState = MAXHPBARS 
						hpBarPercent = 100
					else
						hpBarPercent = $ - 100
					end
				end
				local healthbarredpercent = hpBarPercent + (p.kh.lasthp -  p.hp)
				if hpBarState == MAXHPBARS then healthbarredpercent = 100 end
				if hpBarPercent == 0 and p.hp then hpBarPercent = 1 end
				if hudpatch then //This draws the player icon
					if p.powers[pw_super] and hudpatch[5] then
						v.drawScaled(x*FRACUNIT, y*FRACUNIT, FRACUNIT/2, v.cachePatch(hudpatch[5]), playerhealthflags, v.getColormap(p.mo.skin, p.mo.color))
					elseif hudpatch[4] and p.hp <= 0 then
						v.drawScaled(x*FRACUNIT, y*FRACUNIT, FRACUNIT/2, v.cachePatch(hudpatch[4]), playerhealthflags, v.getColormap(p.mo.skin, p.mo.color))
					elseif hudpatch[3] and p.recentdamaged then
						v.drawScaled(x*FRACUNIT, y*FRACUNIT, FRACUNIT/2, v.cachePatch(hudpatch[3]), playerhealthflags, v.getColormap(p.mo.skin, p.mo.color))
					elseif hudpatch[2] and (p.hp * 5) <= p.maxHP then
						v.drawScaled(x*FRACUNIT, y*FRACUNIT, FRACUNIT/2, v.cachePatch(hudpatch[2]), playerhealthflags, v.getColormap(p.mo.skin, p.mo.color))
					else
						v.drawScaled(x*FRACUNIT, y*FRACUNIT, FRACUNIT/2, v.cachePatch(hudpatch[1]), playerhealthflags, v.getColormap(p.mo.skin, p.mo.color))
					end
				end
				drawHPBar(v, p, hpBarLength, hpBarState, hpBarPercent, x-22, y+2, playerhealthflags, false)
			else
				if hudpatch then //This draws the player icon
					if p.powers[pw_super] and hudpatch[5] then
						v.drawScaled(x*FRACUNIT, y*FRACUNIT, FRACUNIT/2, v.cachePatch(hudpatch[5]), playerhealthflags, v.getColormap(p.mo.skin, p.mo.color))
					else
						v.drawScaled(x*FRACUNIT, y*FRACUNIT, FRACUNIT/2, v.cachePatch(hudpatch[1]), playerhealthflags, v.getColormap(p.mo.skin, p.mo.color))
					end
				end
			end
			//Draw the player's Drive Bar
			if not (mapheaderinfo[gamemap].typeoflevel & TOL_NIGHTS) then drawKHDriveBar(v, p, x-31, y-8) end
		elseif not playerone then 
			//Draw the party member's HP bar if they are able to be shown
			local px = x
			local py = y - ((32 * ally))
			drawPartyHPHUD(v, p, px, py)
		end
	end
end

hud.add(function(v, player)
	if rawget(_G, "warioHUD") then
		warioHUD = false
	end
	hud.disable("rings")
	hud.disable("score")
	hud.disable("lives")
	hud.disable("time")
	hud.disable("weaponrings")
	hud.disable("powerstones")
	local x = 318
	local y = 90
	local ally
	ally = 0 //Ally position
	local showtext
	showtext = true
	
	for p in players.iterate
		if p.spectator then continue end
		if splitscreen then
			if showtext then
				v.drawString(240, 0, khBlastDiffTable[khBlastDiff][1].." Mode", V_SNAPTOTOP|V_HUDTRANSHALF,"small-right")
				v.drawString(240, 100, khBlastDiffTable[khBlastDiff][1].." Mode", V_HUDTRANSHALF,"small-right")
				showtext = false
			end
			if p == player and ((p == displayplayer) or (p == secondarydisplayplayer)) then
				drawKHHPHud(v, p, p, x, y+92, displayplayer, secondarydisplayplayer, nil, true)
				local py = y
				if (p == secondarydisplayplayer) then py = $ + 100 end
				//drawKHXPBar(v, p, 2, py)
				if p.kh.target then
					drawKHFoeHealthNew(v, p, 318, py - 84)
					drawKHInfoBar(v, p, 320, py - 68)
				else
					drawKHInfoBar(v, p, 320, py - 80)
				end
				if not ((mapheaderinfo[gamemap].typeoflevel & TOL_NIGHTS) or G_IsSpecialStage()) then
					//drawCommandMenu(v, p, 2, py - 7)
					local redtime = false
					local time = p.realtime
					if (gametyperules & GTR_TIMELIMIT) and (timelimit > 0) then
						local limit = timelimit*60*TICRATE
						time = max(limit - leveltime, 0)
						if (time <= 30*TICRATE) and (((leveltime/2) % 15) < 5) and (not p.exiting) then
							redtime = true
						end
					elseif (mapheaderinfo[gamemap].countdown > 0)
						and (((mapheaderinfo[gamemap].countdown - 30) * TICRATE) > p.realtime)
						and (((leveltime/2) % 15) < 5) and (not p.exiting) then	
						redtime = true
					end
					local timerstring
					if (CV_FindVar("timerres").string == "Tics") then
						timerstring = tostring(time)
					else
						timerstring = string.format("%02d",G_TicsToMinutes(time,full)) .. ":" .. string.format("%02d",G_TicsToSeconds(time))
						if (CV_FindVar("timerres").string == "Centiseconds" or CV_FindVar("timerres").string == "Mania") then
							timerstring = $ .. "." .. string.format("%02d", G_TicsToCentiseconds(time))
						end
					end
					v.drawString(2, py - 88, "\x82".."TIME: ".."\x80"..timerstring, V_SNAPTOTOP|V_SNAPTOLEFT|V_HUDTRANS|(redtime and V_REDMAP or 0), "small")
				end
			end
		else
			if showtext then
				v.drawString(160, 0, khBlastDiffTable[khBlastDiff][1].." Mode", V_SNAPTOTOP|V_HUDTRANSHALF,"center")
				showtext = false
			end
			if not ((gametype == GT_COOP) or (p.bot) or (G_GametypeHasTeams() and p.ctfteam == player.ctfteam)) then continue end
			
			if p == player then
				if (modeattacking and not (mapheaderinfo[gamemap].typeoflevel & TOL_NIGHTS)) then
					//drawKHXPBar(v, p, 2, 150)
				elseif not tutorialmode then
					//drawKHXPBar(v, p, 2, 190)
				end
				if not ((mapheaderinfo[gamemap].typeoflevel & TOL_NIGHTS) or G_IsSpecialStage()) then
					if tutorialmode then
						//drawCommandMenu(v, p, 2, 136)
					elseif modeattacking then
						//drawCommandMenu(v, p, 2, 134)
					else
						//drawCommandMenu(v, p, 2, 174)
					end
					local redtime = false
					local time = p.realtime
					if (mapheaderinfo[gamemap].countdown > 0) 
						and ((mapheaderinfo[gamemap].countdown*TICRATE) - time <= 30*TICRATE)
						and (((leveltime/2) % 15) < 5) and (not p.exiting) then
							redtime = true
					elseif (gametyperules & GTR_TIMELIMIT) and (timelimit > 0) then
						local limit = timelimit*60*TICRATE
						time = max(limit - leveltime, 0)
						if (time <= 30*TICRATE) and (((leveltime/2) % 15) < 5) and (not p.exiting) then
							redtime = true
						end
					end
					local timerstring
					if (CV_FindVar("timerres").string == "Tics") then
						timerstring = tostring(time)
					else
						timerstring = string.format("%02d",G_TicsToMinutes(time,full)) .. ":" .. string.format("%02d",G_TicsToSeconds(time))
						if (CV_FindVar("timerres").string == "Centiseconds" or CV_FindVar("timerres").string == "Mania") then
							timerstring = $ .. "." .. string.format("%02d", G_TicsToCentiseconds(time))
						end
					end
					v.drawString(4, 4, "\x82".."TIME: ".."\x80"..timerstring, V_SNAPTOTOP|V_SNAPTOLEFT|V_HUDTRANS|(redtime and V_REDMAP or 0))
				end
				if tutorialmode then
					drawKHHPHud(v, p, p, x, y+40, nil, nil, 0, false)
				elseif (modeattacking and (mapheaderinfo[gamemap].typeoflevel & TOL_NIGHTS)) then
					drawKHHPHud(v, p, p, x, y+72, nil, nil, 0, false)
				else
					drawKHHPHud(v, p, p, x, y+92, nil, nil, 0, false)
				end
				if p.kh.target then
					local up = drawKHFoeHealthNew(v, p, 318, 8)
					if up > 0 then
						drawKHInfoBar(v, p, 320, 32)
					else
						drawKHInfoBar(v, p, 320, 26)
					end
				else
					drawKHInfoBar(v, p, 320, 12)
				end
			else
				ally = $ + 1
				drawKHHPHud(v, p, player, x, y+92, nil, nil, ally, false)
			end
		end
	end
end, "game")

hud.add(function(v)
	//SonicD Icon
	v.drawScaled(320*FRACUNIT, 0, FRACUNIT/2, v.cachePatch("SDICON"), V_SNAPTORIGHT|V_SNAPTOTOP|V_20TRANS)
	v.drawString(312, 34, "A SonicD Mod", V_ALLOWLOWERCASE|V_SNAPTORIGHT|V_SNAPTOTOP|V_20TRANS, "small-right")
end, "title")