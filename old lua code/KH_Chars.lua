//This is for all the character-specific data

local BASEHP = 20 //Starting HP
local EMERALDBONUS = 10 //HP gained from collecting an Emerald
local BOSSBONUS = 10 //HP gained from beating a Boss
local POINTBONUS = 5 //HP gained from 'leveling up'
local POINTSTOGETBONUS = 60000 //Points needed to 'level up'

rawset(_G, "healthdata", setmetatable({
	["sora"] = {20, 7, 8, 5, 40000},
	["sonic"] = {22, 12, 5, 4, 40000},
	["tails"] = {15, 8, 8, 6, 64000},
	["knuckles"] = {30, 10, 10, 10, 76000},
	["amy"] = {16, 5, 10, 3, 22000},
	["fang"] = {10, 4, 4, 5, 50000},
	["metalsonic"] = {25, 5, 0, 7, 44000},
	["flicky"] = {5, 5, 5, 2, 22000},
	["hedgie"] = {10, 10, 10, 5, 40000},
	["sms"] = {50, 0, 15, 5, 40000},
	["advancecream"] = {16, 8, 5, 5, 40000},
	["werehog"] = {30, 0, 10, 2, 25000},
	["eggman"] = {40, 10, 0, 4, 35000}
}, {__index = function() return {BASEHP, EMERALDBONUS, BOSSBONUS, POINTBONUS, POINTSTOGETBONUS} end}))

local BASERP = 4 //Starting RP (MP)
local EMERALDRPBONUS = 1 //Bonus RP for each Emerald
local BOSSRPBONUS = 1 //Bonus RP for defeating a Boss
local POINTSTOGETEXTRARP = 100000 //Points needed to gain another RP

rawset(_G, "ringdata", setmetatable({
	["sora"] = {4, 1, 1, 108000},
	["sonic"] = {4, 2, 0, 200000},
	["tails"] = {4, 1, 1, 70000},
	["knuckles"] = {1, 2, 1, 140000},
	["amy"] = {5, 1, 1, 92000},
	["fang"] = {2, 2, 0, 102000},
	["metalsonic"] = {0, 3, 0, -1},
	["flicky"] = {8, 1, 0, 60000},
	["hedgie"] = {8, 1, 2, 200000},
	["sms"] = {5, 1, 1, -1},
	["advancecream"] = {6, 1, 0, 60000},
	["werehog"] = {20, 0, 0, -1},
	["eggman"] = {0, 3, 0, -1}
}, {__index = function() return {BASERP, EMERALDRPBONUS, BOSSRPBONUS, POINTSTOGETEXTRARP} end}))


rawset(_G, "khStartingStr", setmetatable({
	["sonic"] = 4,
	["tails"] = 3,
	["knuckles"] = 6,
	["amy"] = 3,
	["fang"] = 4,
	["metalsonic"] = 4,
	["flicky"] = 2,
	["hedgie"] = 3,
	["sms"] = 10,
	["advancecream"] = 2,
	["werehog"] = 7,
	["eggman"] = 2
}, {__index = function() return 4 end}))

rawset(_G, "khStrIncreases", setmetatable({
	["sonic"] = {[2] = 1, [5] = 1, [10] = 1, [20] = 1, [25] = 1, [30] = 1, [40] = 1, [45] = 1, [50] = 1, [60] = 1, [65] = 1, [70] = 1, [80] = 1, [85] = 1, [90] = 1, [99] = 1},
	["SMS"] = {[20] = 1, [40] = 1, [60] = 1, [75] = 1, [99] = 6},
	["advancecream"] = {[2] = 1, [5] = 1, [10] = 1, [20] = 1, [25] = 1, [30] = 1, [40] = 1, [45] = 1, [50] = 1, [60] = 1, [65] = 1, [70] = 1, [80] = 1, [85] = 1, [90] = 1, [99] = 1},
	["eggman"] = {[2] = 2, [5] = 1, [7] = 1, [10] = 2, [15] = 1, [20] = 1, [25] = 2, [40] = 2, [50] = 2, [60] = 1, [75] = 1, [80] = 1, [99] = 2}
}, {__index = function() return {[10] = 1, [20] = 2, [30] = 1, [40] = 2, [50] = 1, [60] = 2, [70] = 1, [80] = 2, [90] = 1, [99] = 2} end}))

rawset(_G, "khStartingMag", setmetatable({
	["sonic"] = 4,
	["tails"] = 6,
	["knuckles"] = 1,
	["amy"] = 5,
	["fang"] = 2,
	["metalsonic"] = 2,
	["flicky"] = 5,
	["hedgie"] = 5,
	["SMS"] = 10,
	["advancecream"] = 5,
	["werehog"] = 0,
	["eggman"] = 2
}, {__index = function() return 4 end}))

rawset(_G, "khMagIncreases", setmetatable({
	["sonic"] = {[2] = 1, [10] = 1, [15] = 1, [20] = 1, [30] = 1, [35] = 1, [40] = 1, [50] = 1, [55] = 1, [60] = 1, [70] = 1, [75] = 1, [80] = 1, [90] = 1, [95] = 1, [99] = 1},
	["SMS"] = {[10] = 1, [30] = 1, [50] = 1, [70] = 1, [90] = 1, [99] = 5},
	["advancecream"] = {[2] = 1, [5] = 1, [10] = 1, [20] = 1, [25] = 1, [30] = 1, [40] = 1, [45] = 1, [50] = 1, [60] = 1, [65] = 1, [70] = 1, [80] = 1, [85] = 1, [90] = 1, [99] = 1},
	["werehog"] = {},
	["eggman"] = {[2] = 1, [5] = 1, [7] = 2, [10] = 1, [25] = 2, [40] = 2, [50] = 2, [60] = 1, [75] = 1, [80] = 1, [99] = 2}
}, {__index = function() return {[10] = 1, [20] = 2, [30] = 1, [40] = 2, [50] = 1, [60] = 2, [70] = 1, [80] = 2, [90] = 1, [99] = 2} end}))


rawset(_G, "getstr", function(p)
	if not p then return end
	if not p.mo then return end
	if not p.mo.skin then return end
	if not p.kh then return end
	local skin = p.mo.skin
	local str = khStartingStr[skin]
	local level
	if not p.kh.level or khBlastDiffTable[khBlastDiff][5] then
		level = 1
	else
		level = p.kh.level
	end
	local i = 1
	for i = 1, min(99, level)
		if khStrIncreases[skin][i]
			str = $ + khStrIncreases[skin][i]
		end
	end
	return str
end)

rawset(_G, "getmag", function(p)
	if not p then return end
	if not p.mo then return end
	if not p.mo.skin then return end
	if not p.kh then return end
	local skin = p.mo.skin
	local mag = khStartingMag[skin]
	local level
	if not p.kh.level or khBlastDiffTable[khBlastDiff][5] then
		level = 1
	else
		level = p.kh.level
	end
	local i = 1
	for i = 1, min(99, level)
		if khMagIncreases[skin][i]
			mag = $ + khMagIncreases[skin][i]
		end
	end
	return mag
end)

addHook("PlayerThink", function(player)
    //Enable Drive Forms
	if not (player.charflags & SF_SUPER) then 
		player.charflags = $|SF_SUPER
	end
	
	if player.mo and player.mo.skin == "sonic"
        if player.powers[pw_super]
        and player.cmd.buttons & BT_USE
            player.charability = CA_THOK
        else
            player.charability = CA_HOMINGTHOK
        end
    end
end)

//addHook("ThinkFrame", do
	//for player in players.iterate do
		//Make sure characters can't attack using jumping
		/*
		if not (player.charflags & (SF_NOJUMPSPIN|SF_NOJUMPDAMAGE)) then 
			player.charflags = $|SF_NOJUMPSPIN|SF_NOJUMPDAMAGE
		end
		*/
		
		//Limit abilities to JumpThok, Swim, JumpBoost and DoubleJump
		/*
		if (player.charability == CA_THOK) or (player.charability == CA_HOMINGTHOK) or (player.charability == CA_JUMPTHOK) then
			player.charability = CA_JUMPTHOK
		elseif (player.charability == CA_SWIM) or (player.charability == CA_FLY) then
			player.charability = CA_SWIM
		elseif (player.charability != CA_DOUBLEJUMP) and (player.charability != CA_JUMPBOOST) then
			player.charability = CA_DOUBLEJUMP
		end
		
		if player.charability2 == CA2_NONE then //Make sure they can still attack on the ground though
			player.charability2 = CA2_MELEE
		end
		*/
	//end
//end)