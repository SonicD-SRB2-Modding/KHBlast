//Spell List

local TYPE_MP = 1 //Spells that cost Magic Points to cast
local TYPE_DRIVE = 2 //Spells that uses the Drive Gauge to cast - must have enough Drive charge to use

local SPELL_OFFENSE = 1 //Offensive spells - can be cast even if lacking in MP
local SPELL_DEFENSE = 2 //Spells to protect - must have enough MP to cast
local SPELL_SUPPORT = 3 //Spells to buff - must have enough MP to cast
local SPELL_HEALING = 4 //Spells to heal or revive - often uses all MP

//Name, Cost, Cost Type, Spell Type, Function

rawset(_G, "khSpellList", {
	["Fire"] = {
		Name = "Fire",
		Cost = 10,
		CostType = TYPE_MP,
		Type = SPELL_OFFENSE,
		Func = function(p)
		if p.mp == 0 then return false end
			local mobj = P_SpawnPlayerMissile(p.mo, MT_FIREBALL, MF2_EXPLOSION)
			if not mobj then return false end //How the heck did that even happen...?
			mobj.basedamage = 4
			if p.kh and p.kh.mag then mobj.basedamage = p.kh.mag + 2 end
			S_StartSound(nil, sfx_s3k43, p)
			p.mp = max($ - 10, 0)
			return true
		end
	},
	["Fira"] = {
		Name = "Fira",
		Cost = 10,
		CostType = TYPE_MP,
		Type = SPELL_OFFENSE,
		Func = function(p)
			if p.mp == 0 then return false end
			local mobj = P_SpawnPlayerMissile(p.mo, MT_FIREBALL, MF2_EXPLOSION)
			if not mobj then return false end //How the heck did that even happen...?
			mobj.basedamage = 8
			if p.kh and p.kh.mag then mobj.basedamage = p.kh.mag + 6 end
			S_StartSound(nil, sfx_s3k43, p)
			p.mp = max($ - 10, 0)
			return true
		end
	},
	["Firaga"] = {
		Name = "Firaga",
		Cost = 10,
		CostType = TYPE_MP,
		Type = SPELL_OFFENSE,
		Func = function(p)
			if p.mp == 0 then return false end
			local mobj = P_SpawnPlayerMissile(p.mo, MT_FIREBALL, MF2_EXPLOSION)
			if not mobj then return false end //How the heck did that even happen...?
			mobj.basedamage = 8
			if p.kh and p.kh.mag then mobj.basedamage = p.kh.mag + 6 end
			S_StartSound(nil, sfx_s3k43, p)
			p.mp = max($ - 10, 0)
			return true
		end
	},
	["Thunder"] = {
		Name = "Thunder",
		Cost = 25,
		CostType = TYPE_MP,
		Type = SPELL_OFFENSE,
		Func = function(p)
			if p.mp == 0 then return false end
			p.mp  = max($ - 25, 0)
			S_StartSound(nil, sfx_kc49, p)
			P_RadiusAttack(p.mo, p.mo, 512*FRACUNIT, DMG_ELECTRIC)
			return true
		end
	},
	["Thundara"] = {
		Name = "Thundara",
		Cost = 25,
		CostType = TYPE_MP,
		Type = SPELL_OFFENSE,
		Func = function(p)
			if p.mp == 0 then return false end
			p.mp  = max($ - 25, 0)
			S_StartSound(nil, sfx_kc49, p)
			P_RadiusAttack(p.mo, p.mo, 768*FRACUNIT, DMG_ELECTRIC)
			return true
		end
	},
	["Thundaga"] = {
		Name = "Thundaga",
		Cost = 25,
		CostType = TYPE_MP,
		Type = SPELL_OFFENSE,
		Func = function(p)
			if p.mp == 0 then return false end
			p.mp  = max($ - 25, 0)
			S_StartSound(nil, sfx_kc49, p)
			P_RadiusAttack(p.mo, p.mo, 1024*FRACUNIT, DMG_ELECTRIC)
			return true
		end
	},
	["Blizzard"] = {
		Name = "Blizzard",
		Cost = 20,
		CostType = TYPE_MP,
		Type = SPELL_OFFENSE,
		Func = function(p)
			if p.mp == 0 then return false end
			//p.mp  = max($ - 20, 0)
			return false //Not coded in yet
		end
	},
	["Blizzara"] = {
		Name = "Blizzara",
		Cost = 20,
		CostType = TYPE_MP,
		Type = SPELL_OFFENSE,
		Func = function(p)
			if p.mp == 0 then return false end
			//p.mp  = max($ - 20, 0)
			return false //Not coded in yet
		end
	},
	["Blizzaga"] = {
		Name = "Blizzaga",
		Cost = 20,
		CostType = TYPE_MP,
		Type = SPELL_OFFENSE,
		Func = function(p)
			if p.mp == 0 then return false end
			//p.mp  = max($ - 20, 0)
			return false //Not coded in yet
		end
	},
	["Cure"] = {
		Name = "Cure",
		Cost = -1, //Cost is all remaining MP, but needs at least 1MP to cast
		CostType = TYPE_MP,
		Type = SPELL_HEALING,
		Func = function(p)
			if p.mp == 0 then return false end
			if ultimatemode then return false end
			local cost = p.mp
			local modifier = 200
			local othermod = 160
			local doesheal = false
			if p.hp < p.maxHP then
				local healval = (p.maxHP * cost) / modifier
				p.hp = min($ + healval, p.maxHP)
				doesheal = true
			end
			for player in players.iterate do
				if p == player then continue end
				if P_AproxDistance(abs(p.mo.x - player.mo.x), abs(p.mo.y - player.mo.y)) <= 768*FRACUNIT then
					if player.hp > 0 then
						if player.hp < player.maxHP then
							local healval = (player.maxHP * cost) / othermod
							if p.kh and p.kh.mag then healval = $ + p.kh.mag end
							player.hp = min($ + healval, player.maxHP)
							S_StartSound(nil, sfx_kc42, p)
							doesheal = true
						end
					else
						//Revive
					end
				end
			end
			if doesheal then
				p.mp = 0
				S_StartSound(nil, sfx_kc42, player)
			end
			return doesheal
		end
	},
	["Cura"] = {
		Name = "Cura",
		Cost = -1, //Cost is all remaining MP, but needs at least 1MP to cast
		CostType = TYPE_MP,
		Type = SPELL_HEALING,
		Func = function(p)
			if p.mp == 0 then return false end
			if ultimatemode then return false end
			local cost = p.mp
			local modifier = 100
			local othermod = 80
			local doesheal = false
			if p.hp < p.maxHP then
				local healval = (p.maxHP * cost) / modifier
				p.hp = min($ + healval, p.maxHP)
				doesheal = true
			end
			for player in players.iterate do
				if p == player then continue end
				if P_AproxDistance(abs(p.mo.x - player.mo.x), abs(p.mo.y - player.mo.y)) <= 768*FRACUNIT then
					if player.hp > 0 then
						if player.hp < player.maxHP then
							local healval = (player.maxHP * cost) / othermod
							if p.kh and p.kh.mag then healval = $ + p.kh.mag end
							player.hp = min($ + healval, player.maxHP)
							S_StartSound(nil, sfx_kc42, p)
							doesheal = true
						end
					else
						//Revive
					end
				end
			end
			if doesheal then
				p.mp = 0
				S_StartSound(nil, sfx_kc42, player)
			end
			return doesheal
		end
	},
	["Curaga"] = {
		Name = "Curaga",
		Cost = -1, //Cost is all remaining MP, but needs at least 1MP to cast
		CostType = TYPE_MP,
		Type = SPELL_HEALING,
		Func = function(p)
			if p.mp == 0 then return false end
			if ultimatemode then return false end
			local cost = p.mp
			local modifier = 50
			local othermod = 40
			local doesheal = false
			if p.hp < p.maxHP then
				local healval = (p.maxHP * cost) / modifier
				p.hp = min($ + healval, p.maxHP)
				doesheal = true
			end
			for player in players.iterate do
				if p == player then continue end
				if P_AproxDistance(abs(p.mo.x - player.mo.x), abs(p.mo.y - player.mo.y)) <= 768*FRACUNIT then
					if player.hp > 0 then
						if player.hp < player.maxHP then
							local healval = (player.maxHP * cost) / othermod
							if p.kh and p.kh.mag then healval = $ + p.kh.mag end
							player.hp = min($ + healval, player.maxHP)
							S_StartSound(nil, sfx_kc42, p)
							doesheal = true
						end
					else
						//Revive
					end
				end
			end
			if doesheal then
				p.mp = 0
				S_StartSound(nil, sfx_kc42, player)
			end
			return doesheal
		end
	},
	["Areo"] = {
		Name = "Aero",
		Cost = 35,
		CostType = TYPE_MP,
		Type = SPELL_DEFENSE,
		Func = function (p)
			if p.mp < 35 then return false end
			if ultimatemode then return false end
			if (p.powers[pw_shield] == SH_WHIRLWIND) or (p.powers[pw_shield] == SH_THUNDERCOIN) then return false end
			p.mp= $ - 35
			if (p.powers[pw_shield] & SH_PROTECTELECTRIC) then
				p.powers[pw_shield] = SH_THUNDERCOIN
				S_StartSound(nil, sfx_s3k41, p)
			else
				p.powers[pw_shield] = SH_WHIRLWIND
				S_StartSound(nil, sfx_shield, p)
			end
			P_SpawnShieldOrb(p)
			return true
		end
	},
	["Haste"] = {
		Name = "Haste",
		Cost = 40,
		CostType = TYPE_MP,
		Type = SPELL_SUPPORT,
		Func = function (p)
			if p.mp < 40 then return false end
			if p.powers[pw_sneakers] then return false end
			p.mp= $ - 40
			p.powers[pw_sneakers] = TICRATE * 20
			S_ChangeMusic("_shoes", false, p)
			return true
		end
	},
	["Auto-Life"] = {
		Name = "Auto-Life",
		Cost = 100,
		CostType = TYPE_DRIVE,
		Type = SPELL_SUPPORT,
		Func = function (p)
			if p.rings < 100 then return false end
			p.rings = $ - 100
			p.lives = $ + 1
			P_PlayLivesJingle(p)
			return true
		end
	}
})