//Character info

local DEFAULTSETTINGS = {
	StartingHP = 20,
	StartingMP = 100,
	StartingSTR = 4,
	StartingMAG = 4,
	STRBoosts = {[10] = 1, [20] = 2, [30] = 1, [40] = 2, [50] = 1, [60] = 2, [70] = 1, [80] = 2, [90] = 1, [99] = 2},
	MAGBoosts = {[10] = 1, [20] = 2, [30] = 1, [40] = 2, [50] = 1, [60] = 2, [70] = 1, [80] = 2, [90] = 1, [99] = 2},
	HPIncrease = {5, 10, 10, 30}, //Level HP increase, Boss HP increase, Emerald HP increase, All Emeralds Bonus HP
	MPIncrease = {0, 100, 100, 0, 5, 15}, //Level MP increase, First MP Increase Level, MP increase steps, Boss MP increase, Emerald MP increase, All Emeralds Bonus MP
	Spells = {} //Spell, Level Learned, Replaces this Spell
}

-- Generate EXP table - Borrowed code from SRB2P to help with this
local basexp = 25
local totalxp = 10
rawset(_G, "needEXP", {})

needEXP[0] = 0
for i = 1, 98
	needEXP[i] = totalxp
	totalxp = ($1 + (basexp*i)*38/100)
end
needEXP[99] = -1 //99 is max level

rawset(_G, "characterData", setmetatable({
	["sonic"] = {
		StartingHP = 22,
		StartingMP = 50,
		StartingSTR = 4,
		StartingMAG = 4,
		STRBoosts = {[2] = 1, [5] = 1, [10] = 1, [20] = 1, [25] = 1, [30] = 1, [40] = 1, [45] = 1, [50] = 1, [60] = 1, [65] = 1, [70] = 1, [80] = 1, [85] = 1, [90] = 1, [99] = 1},
		MAGBoosts = {[2] = 1, [10] = 1, [15] = 1, [20] = 1, [30] = 1, [35] = 1, [40] = 1, [50] = 1, [55] = 1, [60] = 1, [70] = 1, [75] = 1, [80] = 1, [90] = 1, [95] = 1, [99] = 1},
		HPIncrease = {4, 5, 12, 36}, //Level HP increase, Boss HP increase, Emerald HP increase, All Emeralds Bonus HP
		MPIncrease = {0, 100, 100, 0, 5, 15}, //Level MP increase, First MP Increase Level, MP increase steps, Boss MP increase, Emerald MP increase, All Emeralds Bonus MP
		Spells = {{"Fire", 2}, {"Cure", 4}, {"Haste", 4}, {"Aero", 6}, {"Thunder", 11}, {"Fira", 14, "Fire"}, {"Cura", 15, "Cure"}, {"Thundara", 21, "Thunder"}, {"Auto-Life", 30}, {"Curaga", 42, "Cura"}} //Spell, Level Learned, Replaces this Spell
	},
	["tails"] = {
		StartingHP = 15,
		StartingMP = 25,
		StartingSTR = 3,
		StartingMAG = 6,
		STRBoosts = {[10] = 1, [20] = 2, [30] = 1, [40] = 2, [50] = 1, [60] = 2, [70] = 1, [80] = 2, [90] = 1, [99] = 2},
		MAGBoosts = {[10] = 1, [20] = 2, [30] = 1, [40] = 2, [50] = 1, [60] = 2, [70] = 1, [80] = 2, [90] = 1, [99] = 2},
		HPIncrease = {3, 8, 6, 8}, //Level HP increase, Boss HP increase, Emerald HP increase, All Emeralds Bonus HP
		MPIncrease = {5, 4, 5, 0, 0, 0}, //Level MP increase, First MP Increase Level, MP increase steps, Boss MP increase, Emerald MP increase, All Emeralds Bonus MP
		Spells = {{"Cure", 1}, {"Aero", 3}, {"Thunder", 5}, {"Cura", 12, "Cure"}, {"Thundara", 16, "Thunder"}, {"Curaga", 32, "Cura"}} //Spell, Level Learned, Replaces this Spell
	},
	["knuckles"] = {
		StartingHP = 30,
		StartingMP = 10,
		StartingSTR = 6,
		StartingMAG = 1,
		STRBoosts = {[10] = 1, [20] = 2, [30] = 1, [40] = 2, [50] = 1, [60] = 2, [70] = 1, [80] = 2, [90] = 1, [99] = 2},
		MAGBoosts = {[10] = 1, [20] = 2, [30] = 1, [40] = 2, [50] = 1, [60] = 2, [70] = 1, [80] = 2, [90] = 1, [99] = 2},
		HPIncrease = {6, 10, 10, 0}, //Level HP increase, Boss HP increase, Emerald HP increase, All Emeralds Bonus HP
		MPIncrease = {0, 100, 100, 0, 10, 20}, //Level MP increase, First MP Increase Level, MP increase steps, Boss MP increase, Emerald MP increase, All Emeralds Bonus MP
		Spells = {} //Spell, Level Learned, Replaces this Spell
	}
}, {__index = function() return DEFAULTSETTINGS end}))

rawset(_G, "khheadpatch", setmetatable({
	//Each character will have (up to) five HUD sprites, in this order:
	//Normal, Low Health, KOed, Damaged, Super and Unique
	//KCH_CHARA, KCL_CHARA, KCK_CHARA, KCD_CHARA, KCS_CHARA, KCU_CHARA
	["sonic"] = {"KCH_SONIC", "KCL_SONIC"},
	["tails"] = {"KCH_TAILS", "KCL_TAILS"},
	["knuckles"] = {"KCH_KNUX", "KCL_KNUX"},
	["amy"] = {"KCH_AMY", "KCL_AMY"},
	["fang"] = {"KCH_FANG", "KCL_FANG"},
	["metalsonic"] = {"KCH_METAL", "KCL_METAL"}
}, {__index = function() return {"KH_BASE"} end}))
