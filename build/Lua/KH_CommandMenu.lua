//Command Menu stuff

rawset(_G, "khRingList", {
	[-1] = "",
	[0] = "Normal",
	[1] = "Auto",
	[2] = "Bounce",
	[3] = "Shotgun",
	[4] = "Grenade",
	[5] = "Bomb",
	[6] = "Sniper"
})

local MENU_MAGIC = 0
local MENU_ITEMS = 1
local MENU_RINGS = 2

local function getSpells(p)
	if not p.mo and p.mo.valid return {} end
	local skin = p.mo.skin
	local skinData = characterData[skin]
	local spellList = {}
	local learnlist = skinData.Spells
	local level = 1
	if p.kh and p.kh.level then level = p.kh.level end
	if #learnlist == 0 then return spellList end
	for i = 1, #learnlist do
		local spell = learnlist[i]
		local spellLevel = spell[2]
		if spellLevel > level then break end
		//Add spell to spell list - overriding the spell named if it exists
		local spellName = spell[1]
		local spellToReplace = spell[3]
		if not spellToReplace then
			table.insert(spellList, spellName)
		else
			local replacedSpell = false
			for j = 1, #spellList do
				if spellList[j] == spellToReplace then
					spellList[j] = spellName
					replacedSpell = true
					break
				end
			end
			if not replacedSpell then table.insert(spellList, spellName) end
		end
	end
	return spellList
end

rawset(_G, "getLastSpell", function(p)
	if not p.kh and p.kh.lastMagic return "\x86".."-" end
	
	local commands = p.kh.commandlist
	if #commands == 0 then
		return "\x86".."NO SPELLS"
	else
		local cOption = p.kh.lastMagic
		local spellData = khSpellList[commands[cOption]]
		local spell = "TEST"
		local costString = ""
		local stringPrefix = ""
		if spellData then 
			spell = spellData.Name
			local cost = spellData.Cost
			if spellData.CostType == 1 then //MP
				costString = "\x84"..tostring(spellData.Cost).."MP"
				if spellData.Type == 4 then //Healing Spell
					costString = "\x84".."100%MP"
				end
				if p.mp == 0 then stringPrefix = "\x86"
				elseif (p.mp <= cost) or (spellData.Type == 4) then stringPrefix = "\x85" end
			else //Drive
				costString = "\x82"..tostring(spellData.Cost/50).."DP"
				if p.rings < cost then stringPrefix = "\x86" end
			end
		else
			stringPrefix = "\x86"
		end
		return stringPrefix..spell.." "..costString
	end
end)

rawset(_G, "createMenu", function(p) //Returns the items that should be in the three menu slots - prior, current and next
	local cPrior = 0
	local commands = p.kh.commandlist
	if p.kh and p.kh.cOption then
		cPrior = p.kh.cOption - 1
		if (p.kh.menuMode == 0) and (cPrior < 1) then
			if (#commands > 1) then cPrior = #commands else cPrior = 0 end
		elseif (p.kh.menuMode == 1) and (cPrior < 1) then 
			if #p.kh.itemlist > 1 then cPrior = #p.kh.itemlist else cPrior = 0 end
		elseif (p.kh.menuMode == 2) and (cPrior < 0) then cPrior = WEP_RAIL
		end
	end
	
	local cOption = 1
	if p.kh.cOption then cOption = p.kh.cOption end
	
	local cNext = 0
	if p.kh and p.kh.cOption then
		cNext = p.kh.cOption + 1
		if (p.kh.menuMode == 0) and (cNext > #commands) then 
			if (#commands > 1) then cNext = 1 else cNext = 0 end
		elseif (p.kh.menuMode == 1) and (cNext > #p.kh.itemlist) then 
			if #p.kh.itemlist > 1 then cNext = 1 else cNext = 0 end
		elseif (p.kh.menuMode == 2) and (cNext == NUM_WEAPONS) then cNext = 0
		end
	end
	
	if p.kh.menuMode == MENU_MAGIC then //Magic Menu
		if p.kh and p.kh.cOption then
			if #commands == 0 then
				return "", "\x86".."NO SPELLS", ""
			elseif	#commands == 1 then
				local spell = "TEST"
				local costString = ""
				local stringPrefix = ""
				local spellData = khSpellList[commands[1]]
				if spellData then 
					spell = spellData.Name
					local cost = spellData.Cost
					if spellData.CostType == 1 then //MP
						costString = "\x84"..tostring(spellData.Cost).."MP"
						if spellData.Type == 4 then //Healing Spell
							costString = "\x84".."100%MP"
						end
						if p.mp == 0 then stringPrefix = "\x86"
						elseif (p.mp <= cost) or (spellData.Type == 4) then stringPrefix = "\x85" end
					else //Drive
						costString = "\x82"..tostring(spellData.Cost/50).."DP"
						if p.rings < cost then stringPrefix = "\x86" end
					end
				else
					stringPrefix = "\x86"
				end
				
				return "", stringPrefix..spell.." "..costString, ""
			else
				local priorSpell = "TEST"
				local currentSpell = "TEST"
				local nextSpell = "TEST"
				local costString = ""
				local stringPrefix = ""
				
				local priorSpellData = khSpellList[commands[cPrior]]
				local currentSpellData = khSpellList[commands[cOption]]
				local nextSpellData = khSpellList[commands[cNext]]
				
				if priorSpellData then
					priorSpell = "\x86"..priorSpellData.Name
				end
						
				if currentSpellData then
					currentSpell = currentSpellData.Name
					local cost = currentSpellData.Cost
					if currentSpellData.CostType == 1 then //MP
						costString = "\x84"..tostring(currentSpellData.Cost).."MP"
						if currentSpellData.Type == 4 then //Healing Spell
							costString = "\x84".."100%MP"
						end
						if p.mp == 0 then stringPrefix = "\x86"
						elseif (p.mp <= cost) or (currentSpellData.Type == 4) then stringPrefix = "\x85" end
					else //Drive
						costString = "\x82"..tostring(currentSpellData.Cost/50).."DP"
						if p.rings < cost then stringPrefix = "\x86" end
					end
				end
				
				if nextSpellData then
					nextSpell = "\x86"..nextSpellData.Name
				end
				
				return priorSpell, stringPrefix..currentSpell.." "..costString, nextSpell
			end
		else
			return "", "\x86".."-", ""
		end
	elseif p.kh.menuMode == MENU_ITEMS then //Item Menu - Items aren't in the current build
		if p.kh and p.kh.cOption then
			local commands = p.kh.itemlist
			if #commands == 0 then
				return "", "\x86".."NO ITEMS", ""
			elseif #commands == 1 then
				local item = "TEST"
				
				return "", item, ""
			else
				local priorItem = "TEST"
				local currentItem = "TEST"
				local nextItem = "TEST"
				
				return priorItem, currentItem, nextItem
			end
		else
			return "", "\x86".."-", ""
		end
	elseif p.kh.menuMode == MENU_RINGS then //Rings Menu
		local priorslot = "\x86"..khRingList[cPrior]
		local currentslot = khRingList[cOption]
		if cOption == 0 and p.powers[pw_infinityring] then currentslot = "INFINITY" end
		local nextslot = "\x86"..khRingList[cNext]
		return priorslot, currentslot, nextslot
	else //No menu given
		return "", "\x86".."-", ""
	end
end)

addHook("ThinkFrame", function()
	if (mapheaderinfo[gamemap].typeoflevel & TOL_NIGHTS) or G_IsSpecialStage() then return end //Commands disabled in NiGHTS stages and MP Special Stages
	for p in players.iterate do
		if p.difsel == true then continue end //Skip this if the player is selecting a difficulty
		if p.kh != nil then
			if p.kh.itemlist == nil then p.kh.itemlist = {} end
			if p.kh.commandlist == nil then p.kh.commandlist = {} end
			if p.kh.lastWpn == nil then p.kh.lastWpn = 0 end
			if p.kh.cOption == nil then p.kh.cOption = 1 end
			if p.kh.comButton == nil then p.kh.comButton = false end
			if (p.cmd.buttons & BT_WEAPONNEXT) then
				if not p.kh.comButton then
					if p.kh.menuMode == 0 then
						p.currentweapon = p.kh.lastWpn 
						if #p.kh.commandlist > 1 then
							p.kh.cOption = $ + 1
							if p.kh.cOption > #p.kh.commandlistthen p.kh.cOption = 1 end
							S_StartSound(nil, sfx_menu1, p)
						else
							S_StartSound(nil, sfx_cmderr, p)
						end
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
						if #p.kh.commandlist > 1 then
							p.kh.cOption = $ - 1
							if p.kh.cOption < 1 then p.kh.cOption = #p.kh.commandlist end
							S_StartSound(nil, sfx_menu1, p)
						else
							S_StartSound(nil, sfx_cmderr, p)
						end
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
			elseif (p.cmd.buttons & BT_WEAPONMASK) and ((p.cmd.buttons & BT_WEAPONMASK) <= #p.kh.commandlist) then
				if (not p.kh.comButton) then
					if ((p.kh.menuMode == 0) and #p.kh.commandlist >= (p.cmd.buttons & BT_WEAPONMASK)) 
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
							if p.kh.items[item] > 0 then
							commandused = useKHItem(p, item)
								if commandused then
									p.kh.items[item] = $ - 1
									if p.kh.items[item] == 0 then
										table.remove(p.kh.itemlist, p.kh.cOption)
										if #p.kh.itemlist == 0 then
											p.kh.menuMode = 0
											p.kh.cOption = p.kh.lastMagic
										elseif p.kh.cOption > #p.kh.itemlist then
											p.kh.cOption = #p.kh.itemlist
										end
									end
								else
									S_StartSound(nil, sfx_cmderr, p)
								end
							else
								commandused = false
							end
						else
							commandused = false
						end
					else
						local command
						if #p.kh.commandlist > 0 then
							if p.kh.menuMode == 0 then command = khSpellList[p.kh.commandlist[p.kh.cOption]].Func
							elseif p.kh.menuMode == 2 then command = khSpellList[p.kh.commandlist[p.kh.lastMagic]].Func end
							if command ~= nil then
								commandused = command(p)
							else
								commandused = false
							end
						else
							commandused = false
						end
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