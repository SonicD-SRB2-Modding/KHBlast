rawset(_G, "khheadpatch", setmetatable({
	//Each character will have (up to) five HUD sprites, in this order:
	//Normal, Low Health, KOed, Super and Special
	["sora"] = {"KH_SORA"},
	["sonic"] = {"KH_SONIC", "KL_SONIC"},
	["tails"] = {"KH_TAILS", "KL_TAILS"},
	["knuckles"] = {"KH_KNUX", "KL_KNUX"},
	["amy"] = {"KH_AMY", "KL_AMY"},
	["fang"] = {"KH_FANG", "KL_FANG"},
	["metalsonic"] = {"KH_METAL", "KL_METAL"},
	["hedgie"] = {"KH_CALLI"},
	["flicky"] = {"KH_FLICKY"},
	["advancecream"] = {"KH_CREAM"},
	["werehog"] = {"KH_WRHOG"}
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
	if (p.realtime < TICRATE*10) or (p.kh.infotimer and (p.kh.infotimer <= TICRATE * 8)) then
		//Draw the level information details
		local infostring = "Reach the goal!"
		if (mapheaderinfo[gamemap].levelflags & LF_WARNINGTITLE) then
			local name = getbossname(p.kh.target)
			if name then
				infostring = "Defeat "..name.."!"
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
		if (p.kh.infotext ~= nil) and (p.kh.infotext ~= "") then infostring = p.kh.infotext end
		local stringlen = v.stringWidth(infostring, nil, "small")
		local x = ox - 2
		local barx = x - max(stringlen + 2, 86)
		local time
		if p.kh.infotimer then time = (10*TICRATE - p.kh.infotimer) else time = p.realtime end
		if time < 0 then return end
		if time > TICRATE*5 then x = $ + time - (TICRATE*5) end
		if x > 325 + stringlen then return end
		v.drawStretched(ox*FRACUNIT, y*FRACUNIT, (ox-barx)*FRACUNIT, FRACUNIT, v.cachePatch("IN_SBAR"), healthflags)
		v.draw(barx, y, v.cachePatch("IN_SBRC"), healthflags)
		v.draw(ox, y, v.cachePatch("IN_INTB"), healthflags)
		v.draw(ox, y, v.cachePatch("IN_INTX"), healthflags)
		v.drawString(x, y+1, infostring, healthflags, "small-right")
	elseif p.kh.itempickuptimer then
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
	local formgauge = p.kh.lastdp
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
			if hudpatch[2] and (p.hp * 5) <= p.maxHP then
				v.drawScaled(x*FRACUNIT, y*FRACUNIT, FRACUNIT/2, v.cachePatch(hudpatch[2]), playerhealthflags, v.getColormap(p.mo.skin, p.mo.color))
			else
				v.drawScaled(x*FRACUNIT, y*FRACUNIT, FRACUNIT/2, v.cachePatch(hudpatch[1]), playerhealthflags, v.getColormap(p.mo.skin, p.mo.color))
			end
		end
		if hpBarPercent == 0 and p.hp then hpBarPercent = 1 end
		drawHPBar(v, p, hpBarLength, hpBarState, hpBarPercent, x-8, y+2, playerhealthflags, true)
	else
		if hudpatch then //This draws the player icon
			v.drawScaled(x*FRACUNIT, y*FRACUNIT, FRACUNIT/2, v.cachePatch(hudpatch[1]), playerhealthflags, v.getColormap(p.mo.skin, p.mo.color))
		end
	end
	if p.kh.maxRP then
		local rpBarLength = p.kh.maxRP
		local rpBarPercent = min(p.kh.rp, p.kh.maxRP)
		if p.kh.rp == 0 then
			v.drawStretched((x-29)*FRACUNIT, ((y-5)*FRACUNIT)-(FRACUNIT/2), rpBarLength*FRACUNIT, FRACUNIT/2, v.cachePatch("KHP_BAR"), playerhealthflags, v.getColormap("sonic", SKINCOLOR_GREY))
			if p.kh.rpcharge then
				v.drawStretched((x-29)*FRACUNIT, ((y-5)*FRACUNIT), FRACUNIT, (p.kh.rpcharge*FRACUNIT)/10, v.cachePatch("KRP_CHA"), playerhealthflags, v.getColormap("sonic", SKINCOLOR_YELLOW))
			end
		else
			v.drawStretched((x-29)*FRACUNIT, ((y-5)*FRACUNIT)-(FRACUNIT/2), rpBarPercent*FRACUNIT, FRACUNIT/2, v.cachePatch("KHP_BAR"), playerhealthflags, v.getColormap("sonic", SKINCOLOR_BLUE))
			if rpBarPercent < rpBarLength then
				v.drawStretched((x-(29+rpBarPercent))*FRACUNIT, ((y-5)*FRACUNIT)-(FRACUNIT/2), (rpBarLength-rpBarPercent)*FRACUNIT, FRACUNIT/2, v.cachePatch("KHP_BAR"), playerhealthflags, v.getColormap("sonic", SKINCOLOR_GREY))
				if p.kh.rpcharge then
					v.drawStretched((x-(29+rpBarPercent))*FRACUNIT, ((y-5)*FRACUNIT), FRACUNIT, (p.kh.rpcharge*FRACUNIT)/10, v.cachePatch("KRP_CHA"), playerhealthflags, v.getColormap("sonic", SKINCOLOR_YELLOW))
				end
			end
		end
		v.draw(x-29, y-6, v.cachePatch("KSB_ENN"), playerhealthflags)
		if rpBarLength > 2 then
			v.drawStretched((x-(rpBarLength+28))*FRACUNIT, (y-6)*FRACUNIT, (rpBarLength-2)*FRACUNIT, FRACUNIT,  v.cachePatch("KSB_MDN"), playerhealthflags)
		end
		v.draw(x-(rpBarLength+31), y-6, v.cachePatch("KSB_STN"), playerhealthflags)
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
					if hudpatch[2] and (p.hp * 5) <= p.maxHP then
						v.drawScaled(x*FRACUNIT, y*FRACUNIT, FRACUNIT/2, v.cachePatch(hudpatch[2]), playerhealthflags, v.getColormap(p.mo.skin, p.mo.color))
					else
						v.drawScaled(x*FRACUNIT, y*FRACUNIT, FRACUNIT/2, v.cachePatch(hudpatch[1]), playerhealthflags, v.getColormap(p.mo.skin, p.mo.color))
					end
				end
				drawHPBar(v, p, hpBarLength, hpBarState, hpBarPercent, x-22, y+2, playerhealthflags, false)
			else
				if hudpatch then //This draws the player icon
					v.drawScaled(x*FRACUNIT, y*FRACUNIT, FRACUNIT/2, v.cachePatch(hudpatch[1]), playerhealthflags, v.getColormap(p.mo.skin, p.mo.color))
				end
			end
			//Draw the player's RP bar
			if p.kh.maxRP then
				local rpBarLength = p.kh.maxRP * 5
				local rpfilledLength = p.kh.rp * 5
				if p.kh.rp then 
					v.drawStretched((x-22)*FRACUNIT, (y+10)*FRACUNIT, (rpfilledLength*FRACUNIT)/2, FRACUNIT/2, v.cachePatch("KHP_BAR"), playerhealthflags, v.getColormap("sonic", SKINCOLOR_BLUE))
				end
				if (p.kh.rp < p.kh.maxRP) then
					v.drawStretched((x*FRACUNIT)-(((rpfilledLength+44)*FRACUNIT)/2), (y+10)*FRACUNIT, ((rpBarLength - rpfilledLength)*FRACUNIT)/2, FRACUNIT/2, v.cachePatch("KHP_BAR"), playerhealthflags, v.getColormap("sonic", SKINCOLOR_GREY))
					if p.kh.rpcharge then 
						v.drawStretched((x*FRACUNIT)-(((rpfilledLength+44)*FRACUNIT)/2), (y+10)*FRACUNIT, (p.kh.rpcharge*FRACUNIT)/2, FRACUNIT/2, v.cachePatch("KHP_BAR"), playerhealthflags, v.getColormap("sonic", SKINCOLOR_YELLOW))
					end
				end
				v.draw(x-7, y+9, v.cachePatch("KRP_END"), playerhealthflags)
				local i
				for i = 1, p.kh.maxRP do
					v.drawStretched((x*FRACUNIT)-(((44+(i*5))*FRACUNIT)/2), (y+9)*FRACUNIT, FRACUNIT/2, FRACUNIT, v.cachePatch("KRP_UNI"), playerhealthflags)
				end
				v.drawStretched((x*FRACUNIT)-(((rpBarLength+46)*FRACUNIT)/2), (y+9)*FRACUNIT, FRACUNIT/2, FRACUNIT, v.cachePatch("KRP_STA"), playerhealthflags)
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

local function drawKHXPBar (v, p, x, y)
	if healthdata == nil then return end
	if not p.mo then return end
	local xp = p.score
	if khBlastDiffTable[khBlastDiff][5] then xp = 0 end
	if modeattacking then xp = $ * RATTACKXPMOD
	elseif not ((gametype == GT_COOP) or (gametype == GT_COMPETITION) or (gametype == GT_RACE)) then xp = $ * MATCHXPMOD end
	local levelxp = healthdata[p.mo.skin][5]
	if mapheaderinfo[gamemap].dungeon then levelxp = $ / 25 end
	local toNextLevel = xp % levelxp
	local level = min(1 + (xp / levelxp), 99)
	if p.kh.level then level = min(p.kh.level, 99) end
	local xppercent = (toNextLevel * 100) / levelxp
	
	if not splitscreen then
		v.drawStretched(((x+2)*FRACUNIT), (y+1)*FRACUNIT, (xppercent*FRACUNIT)/2, FRACUNIT/2, v.cachePatch("KXP_FIL"), playerhudflags, v.getColormap("sonic", SKINCOLOR_CYAN))
		if khBlastDiffTable[khBlastDiff][5] then
			v.drawStretched((x+2)*FRACUNIT, (y+1)*FRACUNIT, (100*FRACUNIT)/2, FRACUNIT/2, v.cachePatch("KXP_FIL"), playerhudflags, v.getColormap("sonic", SKINCOLOR_CARBON))
		else
			v.drawStretched(((x+2)*FRACUNIT)+((xppercent*FRACUNIT)/2), (y+1)*FRACUNIT, ((100-xppercent)*FRACUNIT)/2, FRACUNIT/2, v.cachePatch("KXP_FIL"), playerhudflags, v.getColormap("sonic", SKINCOLOR_GREY))
		end
		v.draw(x, y, v.cachePatch("KXP_BAR"), playerhudflags)
		if not (mapheaderinfo[gamemap].typeoflevel & TOL_NIGHTS) then
			if modeattacking then
				v.drawString(x+4, y+1, "\x82".."SCORE: ".."\x88"..tostring(p.score), playerhudflags, "small")
				v.drawString(x, y-6, "\x82".."LV: ".."\x88"..string.format("%02d",tostring(level)).."\x80 - ".."\x82".."RINGS: ".."\x88"..tostring(p.rings), playerhudflags, "small")
			elseif not (G_GametypeUsesLives() or G_IsSpecialStage() or (gametype == GT_RACE)) then
				local ringsstring = "\x82".."RINGS: ".."\x88"..tostring(p.rings)
				if p.currentweapon then
					ringsstring = $.." ("..p.powers[pw_infinityring + p.currentweapon]..")"
				elseif p.powers[pw_infinityring] then
					ringsstring = "\x82".."RINGS: ".."\x85"..tostring(p.rings + p.powers[pw_infinityring])
				end
				v.drawString(x, y-6, ringsstring, playerhudflags, "small")
				v.drawString(x+4, y+1, "\x82".."LV: ".."\x88"..tostring(level), playerhudflags, "small")
			elseif (not khBlastDiffTable[khBlastDiff][5]) then
				v.drawString(x, y-6, "\x82".."LV: ".."\x88"..string.format("%02d",tostring(level)).."\x80 - ".."\x82".."XP: ".."\x88"..tostring(xp), playerhudflags, "small")
				if level == 99 then
					v.drawString(x+4, y+1, "\x82".."TNL: ".."\x88".."MAX", playerhudflags, "small")
				else
					v.drawString(x+4, y+1, "\x82".."TNL: ".."\x88"..tostring(levelxp-toNextLevel), playerhudflags, "small")
				end
			else
				v.drawString(x, y-6, "\x82".."LV: ".."\x88"..string.format("%02d",tostring(1)).."\x80 - ".."\x82".."SCORE: ".."\x88"..tostring(p.score), playerhudflags, "small")
			end
		end
	
	else
		local xpPercentText = "\x82".."TNL: ".."\x88"..tostring(xppercent).."%"
		if level == 99 then  xpPercentText = "\x82".."TNL: ".."\x88".."MAX" end
		if not (mapheaderinfo[gamemap].typeoflevel & TOL_NIGHTS) and not (G_GametypeUsesLives() or G_IsSpecialStage() or (gametype == GT_RACE)) then
			local ringsstring = "\x82".."RINGS: ".."\x88"..tostring(p.rings)
			if p.currentweapon then
				ringsstring = $.." ("..p.powers[pw_infinityring + p.currentweapon]..")"
			elseif p.powers[pw_infinityring] then
				ringsstring = "\x82".."RINGS: ".."\x85"..tostring(p.rings + p.powers[pw_infinityring])
			end
			v.drawString(x, y, ringsstring, playerhudflags, "small")
			v.drawString(x, y+5, "\x82".."LV: ".."\x88"..tostring(level).."\x80 - "..xpPercentText, playerhudflags, "small")
		elseif (not khBlastDiffTable[khBlastDiff][5]) then
			v.drawString(x, y, "\x82".."LV: ".."\x88"..string.format("%02d",tostring(level)).."\x80 - ".."\x82".."XP: ".."\x88"..tostring(xp), playerhudflags, "small")
			if level == 99 then
				v.drawString(x, y+5, "\x82".."TNL: ".."\x88".."MAX", playerhudflags, "small")
			else
				v.drawString(x, y+5, "\x82".."TNL: ".."\x88"..tostring(levelxp-toNextLevel).. " ("..tostring(xppercent).."%)", playerhudflags, "small")
			end
		else
			v.drawString(x, y, "\x82".."LV: ".."\x88"..string.format("%02d",tostring(1)), playerhudflags, "small")
			v.drawString(x, y+5, "Points: ".."\x88"..tostring(p.score), playerhudflags, "small")
		end
	end
end

local function drawCommandMenu(v, p, x, y)
	if not p.kh then return end
	if p.kh.cOption == nil then
		print("Where's cOption?")
		return
	end
	local colormap = p.skincolor
	if (mapheaderinfo[gamemap].levelflags & LF_WARNINGTITLE) or ultimatemode then colormap = SKINCOLOR_RED end
	if not splitscreen then
		v.drawScaled(x*FRACUNIT, y*FRACUNIT, (3*FRACUNIT)/4, v.cachePatch("KH_CMDS"), playerhudflags, v.getColormap("sonic", colormap))
	else
		v.drawScaled(x*FRACUNIT, y*FRACUNIT, FRACUNIT / 2, v.cachePatch("KH_CMDL"), playerhudflags, v.getColormap("sonic", colormap))
	end
	
	local cPrior = p.kh.cOption - 1
	if (p.kh.menuMode == 0) and (cPrior < 1) then cPrior = #khCommandList 
	elseif (p.kh.menuMode == 1) and (cPrior < 1) then 
		if #p.kh.itemlist > 1 then cPrior = #p.kh.itemlist else cPrior = 0 end
	elseif (p.kh.menuMode == 2) and (cPrior < 0) then cPrior = WEP_RAIL
	end
	
	local cOption = p.kh.cOption
	
	local cNext = p.kh.cOption + 1
	if (p.kh.menuMode == 0) and (cNext > #khCommandList) then cNext = 1 
	elseif (p.kh.menuMode == 1) and (cNext > #p.kh.itemlist) then 
		if #p.kh.itemlist > 1 then cNext = 1 else cNext = 0 end
	elseif (p.kh.menuMode == 2) and (cNext == NUM_WEAPONS) then cNext = 0
	end
	
	local priorslot
	local currentslot
	local nextslot
	local headerpatch
	local headername = "KH_CMD"
	if not splitscreen then headername = "KH_CDS" end
	
	if p.kh.menuMode == 0 then //Magic
		priorslot = "\x86"..khCommandList[cPrior][1]
		currentslot = khCommandList[cOption][1].." ".."\x84"..tostring(khCommandList[cOption][2]).."RP"
		if (khCommandList[cOption][2] > p.kh.rp) or (ultimatemode and ((cOption == 7) or (cOption == 4) or (cOption == 5))) then currentslot = "\x86"..$ end
		nextslot = "\x86"..khCommandList[cNext][1]
		if (mapheaderinfo[gamemap].levelflags & LF_WARNINGTITLE) or ultimatemode then
			headerpatch = v.cachePatch(headername.."MB")
		else
			headerpatch = v.cachePatch(headername.."M")
		end
	elseif p.kh.menuMode == 1 then //Items
		if cPrior > 0 then
			priorslot = "\x86"..khItemList[p.kh.itemlist[cPrior]][1]
		else
			priorslot = ""
		end
		if #p.kh.itemlist > 0 then
			currentslot = khItemList[p.kh.itemlist[cOption]][1]
			if p.kh.items[cOption] == 0 then
				currentslot = "\x86"..$
			else
				currentslot = $.." x"..p.kh.items[cOption]
			end
		else
			currentslot = "Nothing"
		end
		if cNext > 0 then
			nextslot = "\x86"..khItemList[p.kh.itemlist[cNext]][1]
		else
			nextslot = ""
		end
		if (mapheaderinfo[gamemap].levelflags & LF_WARNINGTITLE) or ultimatemode then
			headerpatch = v.cachePatch(headername.."IB")
		else
			headerpatch = v.cachePatch(headername.."I")
		end
	elseif p.kh.menuMode == 2 then //Rings
		priorslot = "\x86"..khRingList[cPrior]
		currentslot = khRingList[cOption]
		if cOption == 0 and p.powers[pw_infinityring] then currentslot = "INFINITY" end
		nextslot = "\x86"..khRingList[cNext]
		headerpatch = v.cachePatch(headername.."R")
	end
	
	//Auto-Life (SP/Co-Op)
	local bottomstring
	if G_GametypeUsesLives() then
		if ultimatemode then
			bottomstring = "\x85".."ULTIMATE"
		else
			bottomstring = "\x82".."A.Life".."\x80".." x ".."\x82"..string.format("%02d",tostring(min(max(p.lives - 1, 0),99)))
		end
	elseif p.kh.menuMode == 2 then
		bottomstring = khCommandList[p.kh.lastMagic][1].." ".."\x84"..tostring(khCommandList[p.kh.lastMagic][2])
		if khCommandList[p.kh.lastMagic][2] > p.kh.rp then bottomstring = "\x86"..$ end
	else
		bottomstring = khRingList[p.currentweapon]
		if p.currentweapon == 0 and p.powers[pw_infinityring] then bottomstring	 = "INFINITY" end
	end
	
	if not splitscreen then
		v.drawScaled(x*FRACUNIT, y*FRACUNIT,  (3*FRACUNIT)/4, headerpatch,  playerhudflags)
		
		//Top
		v.drawString(x+6,y-24, priorslot, V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_ALLOWLOWERCASE|V_HUDTRANS, "small")
		//Middle
		v.drawString(x+6,y-15, currentslot, V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_ALLOWLOWERCASE|V_HUDTRANS, "small")
		//Bottom
		v.drawString(x+6,y-6, nextslot, V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_ALLOWLOWERCASE|V_HUDTRANS, "small")
	
		v.drawString(x+6,y+3, bottomstring, V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_ALLOWLOWERCASE|V_HUDTRANS, "small")
	else
		v.drawScaled(x*FRACUNIT, y*FRACUNIT, FRACUNIT / 2, headerpatch,  playerhudflags)
		
		//Top
		v.drawString(x+4,y-17, priorslot, V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_ALLOWLOWERCASE|V_HUDTRANS, "small")
		//Middle
		v.drawString(x+4,y-11, currentslot, V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_ALLOWLOWERCASE|V_HUDTRANS, "small")
		//Bottom
		v.drawString(x+4,y-5, nextslot, V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_ALLOWLOWERCASE|V_HUDTRANS, "small")
	
		v.drawString(x+4,y+1, bottomstring, V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_ALLOWLOWERCASE|V_HUDTRANS, "small")
	end
	
end

local function drawDiffMenus(v, p)
	local menuToDraw = v.cachePatch("KH_MU" .. tostring(p.difselmenu))
	v.draw(160, 100, menuToDraw, V_HUDTRANS)
	local menutext = "\x82" .. "Select Difficulty:"
	local optiony = 82 + (18 * p.diffopt)
	if p.difselmenu == 2 then 
		menutext = "\x82" .. khBlastDiffTable[p.diffopt][1] .. " Mode"
		optiony = 154 - (18 * p.diffcon)
	end
	v.drawString(160, 45, menutext, V_ALLOWLOWERCASE|V_HUDTRANS, "center")
	local optionpatch = v.cachePatch("KH_MO" .. tostring(((p.realtime % 16) / 4) + 1))
	v.draw(160, optiony, optionpatch, V_HUDTRANS)
	if p.difselmenu == 1 then
		local i
		for i = 0, 4 do
			local stringToDraw = khBlastDiffTable[i][1]
			if i >= 3 and (not (gamecomplete or khBlastcleargame or marathonmode)) then
				stringToDraw = "\x86" .. $
			elseif i == p.diffopt then
				stringToDraw = "\x82" .. $
			end
			v.drawString(160, 68 + (18 * i), stringToDraw, V_ALLOWLOWERCASE|V_HUDTRANS, "center")
		end
	elseif p.difselmenu == 2 then
		local stringComfirm = "Yes"
		local stringCancel = "No"
		if ultimatemode then
			stringComfirm = "Thou Must!"
			stringCancel = "\x86".."No..."
		end
		if p.diffcon then
			stringComfirm = "\x82" .. $
		elseif not ultimatemode then
			stringCancel = "\x82" .. $
		end
		
		v.drawString(160, 124, stringComfirm, V_ALLOWLOWERCASE|V_HUDTRANS, "center")
		v.drawString(160, 142, stringCancel, V_ALLOWLOWERCASE|V_HUDTRANS, "center")
		v.drawString(90, 55, khBlastDiffTable[p.diffopt][4], V_ALLOWLOWERCASE|V_HUDTRANS, "small")
		v.drawString(90, 100, "Are you happy with this Difficulty?\n\nYou can ".."\x85".."NOT".."\x80".." change it later!", V_ALLOWLOWERCASE|V_HUDTRANS, "small")
	end
	v.drawString(160, 160, "Move Forward/Next Weapon: Up", V_ALLOWLOWERCASE|V_HUDTRANS, "center")
	v.drawString(160, 170, "Move Backwards/Prior Weapon: Down", V_ALLOWLOWERCASE|V_HUDTRANS, "center")
	v.drawString(160, 180, "Jump: Comfirm", V_ALLOWLOWERCASE|V_HUDTRANS, "center")
	v.drawString(160, 190, "Spin: Cancel", V_ALLOWLOWERCASE|V_HUDTRANS, "center")
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
	
	if (player.difsel == true) then
		if (((not netgame) and (player == players[0])) or (netgame and ((player == server) or IsPlayerAdmin(player)))) then
			drawDiffMenus(v, player)
		elseif (not (splitscreen and player == secondarydisplayplayer)) and (not player.bot) then
			if not netgame then
				v.drawString(160, 87, players[0].name .. " is currently", nil, "center")
			else
				v.drawString(160, 87, server.name .. " is currently", nil, "center")
			end
			v.drawString(160, 96, "selecting the game difficulty", nil, "center")
			v.drawString(160, 105, "Please wait...", nil, "center")
		end
		return
	end
	
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
				drawKHXPBar(v, p, 2, py)
				if p.kh.target then
					drawKHFoeHealthNew(v, p, 318, py - 84)
					drawKHInfoBar(v, p, 320, py - 68)
				else
					drawKHInfoBar(v, p, 320, py - 80)
				end
				if not ((mapheaderinfo[gamemap].typeoflevel & TOL_NIGHTS) or G_IsSpecialStage()) then
					drawCommandMenu(v, p, 2, py - 7)
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
					drawKHXPBar(v, p, 2, 150)
				elseif not tutorialmode then
					drawKHXPBar(v, p, 2, 190)
				end
				if not ((mapheaderinfo[gamemap].typeoflevel & TOL_NIGHTS) or G_IsSpecialStage()) then
					if tutorialmode then
						drawCommandMenu(v, p, 2, 136)
					elseif modeattacking then
						drawCommandMenu(v, p, 2, 134)
					else
						drawCommandMenu(v, p, 2, 174)
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