//Item List

local ITEMT_POTION = 1 //Heals user's HP
local ITEMT_GPOTION = 2 //Heals party's HP
local ITEMT_ETHER = 3 //Recovers user's MP
local ITEMT_GETHER = 4 //Recovers party's MP
local ITEMT_ELIXER = 5 //Recovers user's HP and MP
local ITEMT_GELIXER = 6 //Recovers party's HP and MP
local ITEMT_DRIVE = 7 //Recovers user's Drive
local ITEMT_REVIVE = 8 //Revives nearby party member
local ITEMT_AUTOLIFE = 9 //Adds an AutoLife to the user

rawset(_G, "khItemList", {
	["Potion"] = {
		Name = "Potion", //Name of the item in full
		CName = "Potion", //Command Menu Name
		Description = "Heals 20HP", //Description of the item
		Type = ITEMT_POTION, //Item Type
		PercentHeal = false, //Is this a percentage recover, or a flat recover?
		HealVal = 20 //The percentage or flat value to recover
	},
	["HiPotion"] = {
		Name = "Hi-Potion",
		CName = "H.Potion",
		Description = "Heals 70HP",
		Type = ITEMT_POTION,
		PercentHeal = false,
		HealVal = 70
	},
	["MegaPotion"] = {
		Name = "Mega Potion",
		CName = "M.Potion",
		Description = "Full Heal",
		Type = ITEMT_POTION,
		PercentHeal = true,
		HealVal = 100
	},
	["GroupPotion"] = {
		Name = "Group Potion",
		CName = "G.Potion",
		Description = "Heals 40HP to the Party",
		Type = ITEMT_GPOTION,
		PercentHeal = false,
		HealVal = 40
	},
	["PartyPotion"] = {
		Name = "Party Potion",
		CName = "P.Potion",
		Description = "Heals 90HP to the Party",
		Type = ITEMT_GPOTION,
		PercentHeal = false,
		HealVal = 90
	},
	["Ether"] = {
		Name = "Ether",
		CName = "H.Ether",
		Description = "Restores 25% MP",
		Type = ITEMT_ETHER,
		PercentHeal = true,
		HealVal = 25
	},
	["HiEther"] = {
		Name = "Hi-Ether",
		CName = "H.Ether",
		Description = "Restores 50% MP",
		Type = ITEMT_ETHER,
		PercentHeal = true,
		HealVal = 50
	},
	["MegaEther"] = {
		Name = "Mega Ether",
		CName = "M.Ether",
		Description = "Restores all MP",
		Type = ITEMT_ETHER,
		PercentHeal = true,
		HealVal = 25
	},
	["HiEther"] = {
		Name = "Group Ether",
		CName = "G.Ether",
		Description = "Restores 20 MP to all party members",
		Type = ITEMT_GETHER,
		PercentHeal = false,
		HealVal = 20
	},
	["MegaEther"] = {
		Name = "Party Ether",
		CName = "P.Ether",
		Description = "Restores 60 MP to all party members",
		Type = ITEMT_GETHER,
		PercentHeal = false,
		HealVal = 60
	},
	["Elixer"] = {
		Name = "Elixer",
		CName = "Elixer",
		Description = "Heals 50% HP and 50% MP",
		Type = ITEMT_ELIXER,
		PercentHeal = true, //Ignored for Elixers
		HealVal = 50
	},
	["MegaElixer"] = {
		Name = "Mega Elixer",
		CName = "M.Elixer",
		Description = "Heals all HP and MP",
		Type = ITEMT_ELIXER,
		PercentHeal = true, //Ignored for Elixers
		HealVal = 100
	},
	["PartyElixer"] = {
		Name = "Party Elixer",
		CName = "P.Elixer",
		Description = "Heals all HP and MP for all party members",
		Type = ITEMT_GELIXER,
		PercentHeal = true, //Ignored for Elixers
		HealVal = 100
	},
	["DriveChargerI"] = {
		Name = "Drive Charger I",
		CName = "Drive.I",
		Description = "Restores 50% of a Drive Bar",
		Type = ITEMT_DRIVE,
		PercentHeal = false, // Ignored for Drive Chargers
		HealVal = 25 
	},
	["DriveChargerV"] = {
		Name = "Drive Charger V",
		CName = "Drive.V",
		Description = "Restores one full Drive Bar",
		Type = ITEMT_DRIVE,
		PercentHeal = false, // Ignored for Drive Chargers
		HealVal = 50 
	},
	["DriveChargerW"] = {
		Name = "Drive Charger W",
		CName = "Drive.W",
		Description = "Restores two full Drive Bars",
		Type = ITEMT_DRIVE,
		PercentHeal = false, // Ignored for Drive Chargers
		HealVal = 100 
	},
	["DriveChargerX"] = {
		Name = "Drive Charger X",
		CName = "Drive.X",
		Description = "Restores seven full Drive Bars",
		Type = ITEMT_DRIVE,
		PercentHeal = false, // Ignored for Drive Chargers
		HealVal = 250
	},
	["PhoenixDown"] = {
		Name = "Phoenix Down",
		CName = "P.Down",
		Descriptipn = "Revives a dead party member to 50% HP",
		Type = ITEMT_REVIVE,
		PercentHeal = true, // Ignored for Revival items
		HealVal = 50
	},
	["MegaPhoenixDown"] = {
		Name = "Mega Phoenix Down",
		CName = "M.P.Down",
		Description = "Revives a dead party member to full HP",
		Type = ITEMT_REVIVE,
		PercentHeal = true, // Ignored for Revival items
		HealVal = 100
	},
	["OneUp"] = {
		Name = "One-Up",
		CName = "One Up",
		Description = "Adds an AutoLife",
		Type = ITEMT_AUTOLIFE,
		PercentHeal = false, //Ignored for One Ups
		HealVal = 1 //Also ignored as they only add 1 Extra Life
	}
})

local function doPlayerHPHeal(p, itemData)
	if p.hp <= 0 then return false end
	if p.hp < p.maxHP then //Heal HP
		if itemData.PercentHeal then
			p.hp = min(p.maxHP, $ + ((itemData.HealVal * 100) / maxHP))
		else
			p.hp = min(p.maxHP, $ + itemData.HealVal)
		end
		return true
	end
	return false
end

local function doPlayerMPHeal(p, itemData)
	if p.hp <= 0 then return false end
	if p.mp == 0 then //Mana Recharge
		if itemData.PercentHeal then
			p.mpRecharge = min(p.maxMP, $ + ((itemData.HealVal * 100) / maxMP))
		else
			p.mpRecharge = min(p.maxMP, $ + itemData.HealVal)
		end
		if p.mpRecharge >= p.maxMP then //MP fully recharged
			p.mp = p.maxMP
			p.mpRecharge = 0
		end
		return true
	elseif p.mp < p.maxMP then //Heal MP
		if itemData.PercentHeal then
			p.mp = min(p.maxMP, $ + ((itemData.HealVal * 100) / maxMP))
		else
			p.mp = min(p.maxMP, $ + itemData.HealVal)
		end
		return true
	end
	return false
end

local function doPlayerElixer(p, itemData)
	local healHP = doPlayerHPHeal(p, itemData)
	local healMP = doPlayerMPHeal(p, itemData)
	return healHP or healMP
end

rawset(_G, "useKHItem", function(p, item)
	local itemData = khItemList[item]
	if not itemData then return false end
	local itemType = itemData.Type
	local isHealed = false
	if itemType == ITEMT_AUTOLIFE then
		p.lives = $ + 1
		P_PlayLivesJingle(p)
		return true
	elseif itemType == ITEMT_REVIVE then
		return false //Not coded in yet
	elseif itemType == ITEMT_DRIVE then
		p.rings = $ + itemData.HealVal
		return true
	elseif (itemType == ITEMT_POTION) then
		isHealed = doPlayerHPHeal(p, itemData)
	elseif (itemType == ITEMT_GPOTION) then
		for play in players.iterate do
			if doPlayerHPHeal(play, itemData) then isHealed = true end
		end
	elseif (itemType == ITEMT_ETHER) then
		isHealed = doPlayerMPHeal(p, itemData)
	elseif itemType == ITEMT_GETHER then
		for play in players.iterate do
			if doPlayerMPHeal(play, itemData) then isHealed = true end
		end
	elseif (itemType == ITEMT_ELIXER) then
		isHealed = doPlayerElixer(p, itemData)
	elseif (itemType == ITEMT_GELIXER) then
		for play in players.iterate do
			if doPlayerElixer(play, itemData) then isHealed = true end
		end
	end
	return isHealed
end)