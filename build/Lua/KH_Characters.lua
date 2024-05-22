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
local basexp = 20
local totalxp = basexp
rawset(_G, "needEXP", {})

needEXP[0] = 0
for i = 1, 98
	needEXP[i] = totalxp
	totalxp = ($1 + (basexp*i)*38/100)
end
needEXP[99] = -1 //99 is max level

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

rawset(_G, "khBlastDiffTable", {
	//Difficulty Text, Foe Damage Mod (2 = 100%), maxHP Mod (4 = 100%), description, expZero
	[0] = {"Beginner", 1, 5, "\x83".."For casual players.\n\n".."\x80".."Damage recieved reduced by 50%\n\nMax HP increased by 25%\nFoe HP reduced by 25%", false},
	[1] = {"Standard", 2, 4, "\x84".."For normal players.\n\n".."\x80".."Normal damage and Max HP.", false},
	[2] = {"Proud", 3, 4, "\x82".."For advanced players.\n\n".."\x80".."Damage recieved increased by 50%\n\nMax HP unaltered.\nFoe HP increased by 50%", false},
	[3] = {"Critical", 4, 3, "\x87".."For expert players.\n\n".."\x80".."Damage recieved is doubled.\n\nMax HP reduced by 25%\nFoe HP increased by 100%", false},
	[4] = {"EXP Zero", 4, 3, "\x85".."For master players.\n\n".."\x80".."Damage recieved is doubled.\n\nMax HP reduced by 25%\nFoe HP increased by 100%\n".."\x85".."No EXP gains to HP or RP!", true},
	[5] = {"ULTIMATE", 5, 2, "\x85".."DIFFICULTY LOCKED TO ULTIMATE.\n".."\x80".."Damage recieved increased to 250%\nMax HP reduced by 50%\nFoe HP increased by 100%\nNo Rings, No AutoLives, No Continues.\nCure, Aero and Revive disabled.\n".."\x85".."No EXP gains to HP or RP!", true}
})

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
		Spells = {} //Spell, Level Learned, Replaces this Spell
	},
	["tails"] = {
		StartingHP = 15,
		StartingMP = 25,
		StartingSTR = 3,
		StartingMAG = 6,
		STRBoosts = {[10] = 1, [20] = 2, [30] = 1, [40] = 2, [50] = 1, [60] = 2, [70] = 1, [80] = 2, [90] = 1, [99] = 2},
		MAGBoosts = {[10] = 1, [20] = 2, [30] = 1, [40] = 2, [50] = 1, [60] = 2, [70] = 1, [80] = 2, [90] = 1, [99] = 2},
		HPIncrease = {8, 8, 6, 8}, //Level HP increase, Boss HP increase, Emerald HP increase, All Emeralds Bonus HP
		MPIncrease = {5, 4, 5, 0, 0, 0}, //Level MP increase, First MP Increase Level, MP increase steps, Boss MP increase, Emerald MP increase, All Emeralds Bonus MP
		Spells = {} //Spell, Level Learned, Replaces this Spell
	},
	["knuckles"] = {
		StartingHP = 30,
		StartingMP = 10,
		StartingSTR = 6,
		StartingMAG = 1,
		STRBoosts = {[10] = 1, [20] = 2, [30] = 1, [40] = 2, [50] = 1, [60] = 2, [70] = 1, [80] = 2, [90] = 1, [99] = 2},
		MAGBoosts = {[10] = 1, [20] = 2, [30] = 1, [40] = 2, [50] = 1, [60] = 2, [70] = 1, [80] = 2, [90] = 1, [99] = 2},
		HPIncrease = {10, 10, 10, 0}, //Level HP increase, Boss HP increase, Emerald HP increase, All Emeralds Bonus HP
		MPIncrease = {0, 100, 100, 0, 10, 20}, //Level MP increase, First MP Increase Level, MP increase steps, Boss MP increase, Emerald MP increase, All Emeralds Bonus MP
		Spells = {} //Spell, Level Learned, Replaces this Spell
	}
}, {__index = function() return DEFAULTSETTINGS end}))