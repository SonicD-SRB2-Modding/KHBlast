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
	local switch
	if p.kh and p.kh.menuMode then switch = p.kh.menuMode else switch = 2 end
	
	local cPrior = -1
	if p.kh and p.kh.cOption then
		cPrior = p.kh.cOption - 1
		if (p.kh.menuMode == 0) and (cPrior < 1) then cPrior = #p.kh.commandlist 
		elseif (p.kh.menuMode == 1) and (cPrior < 1) then 
			if #p.kh.itemlist > 1 then cPrior = #p.kh.itemlist else cPrior = 0 end
		elseif (p.kh.menuMode == 2) and (cPrior < 0) then cPrior = WEP_RAIL
		end
	end
	
	local cOption = 1
	if p.kh.cOption then cOption = p.kh.cOption end
	
	local cNext = -1
	if p.kh and p.kh.cOption then
		cNext = p.kh.cOption + 1
		if (p.kh.menuMode == 0) and (cNext > #p.kh.commandlist) then cNext = 1 
		elseif (p.kh.menuMode == 1) and (cNext > #p.kh.itemlist) then 
			if #p.kh.itemlist > 1 then cNext = 1 else cNext = 0 end
		elseif (p.kh.menuMode == 2) and (cNext == NUM_WEAPONS) then cNext = 0
		end
	end
	
	if switch == MENU_MAGIC then //Magic Menu
		if p.kh and p.kh.cOption then
			local commands = p.kh.commandlist
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
				
				return priorSpell, currentSpell, nextSpell
			end
		else
			return "", "\x86".."-", ""
		end
	elseif switch == MENU_ITEMS then //Item Menu
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
	elseif switch == MENU_RINGS then //Rings Menu
		local priorslot = "\x86"..khRingList[cPrior]
		local currentslot = khRingList[cOption]
		if cOption == 0 and p.powers[pw_infinityring] then currentslot = "INFINITY" end
		local nextslot = "\x86"..khRingList[cNext]
		return priorslot, currentslot, nextslot
	else //No menu given
		return "", "\x86".."-", ""
	end
end)