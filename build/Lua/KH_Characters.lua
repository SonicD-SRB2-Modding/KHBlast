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

for i = 1, 100
	needEXP[i] = totalxp
	totalxp = ($1 + (basexp*i)*38/100)
end

