//This will deal with the LuaBanks

rawset(_G, "DIFFLUABANK", 0)
rawset(_G, "BOSSLUABANK", 1)
rawset(_G, "ITEMLUABANKPOTION", 3)
rawset(_G, "ITEMLUABANKETHER", 4)
rawset(_G, "ITEMLUABANKELIXER", 5)
rawset(_G, "GAMECLEARLUABANK", 6)

rawset(_G, "khBlastLuaBank", reserveLuabanks()) //Here's our luaBank

/*
1 Bit - Stores up to 1 Item
2 Bits - Stores up to 3 Items
3 Bits - Stores up to 7 Items
4 Bits - Stores up to 15 Items
5 Bits - Stores up to 31 Items [25]
6 Bits - Stores up to 63 Items [49]
7 Bits - Stores up to 127 Items [99]
*/

rawset(_G, "khBlastItemBankIn", function(p)
	local itemstostore = p.kh.items
	local i = 1
	while i < 14 do
		if itemstostore[i] > 25 and ((i > 9) or (i == 5)) then itemstostore[i] = 25
		elseif itemstostore[i] > 49 and ((i == 4) or (i == 9)) then itemstostore[i] = 49
		elseif itemstostore[i] > 99 then itemstostore[i] = 99 end
		i = $ + 1
	end
	khBlastLuaBank[ITEMLUABANKPOTION] = itemstostore[1] + (itemstostore[2]<<7) + (itemstostore[3]<<14) + (itemstostore[4]<<21) + (itemstostore[5]<<27)
	khBlastLuaBank[ITEMLUABANKETHER] = itemstostore[6] + (itemstostore[7]<<7) + (itemstostore[8]<<14) + (itemstostore[9]<<21) + (itemstostore[10]<<27)
	khBlastLuaBank[ITEMLUABANKELIXER] = itemstostore[11] + (itemstostore[12]<<5) + (itemstostore[13]<<10)
end)

rawset(_G, "khBlastItemBankOut", function(p)
	local itemstoreturn = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	local i = 1
	local potionBank = khBlastLuaBank[ITEMLUABANKPOTION]
	local etherBank = khBlastLuaBank[ITEMLUABANKETHER]
	local elixerBank = khBlastLuaBank[ITEMLUABANKELIXER]
	while i < 6 do
		if i < 4 then
			itemstoreturn[i] = potionBank % 128
			itemstoreturn[i+5] = etherBank % 128
			itemstoreturn[i+10] = elixerBank % 32
			potionBank = $ / 128
			etherBank = $ / 128
			elixerBank = $ / 32
		elseif i == 4 then
			itemstoreturn[i] = potionBank % 64
			itemstoreturn[i+5] = etherBank % 64
			potionBank = $ / 64
			etherBank = $ / 64
		else //i = 5
			itemstoreturn[i] = potionBank % 32
			itemstoreturn[i+5] = etherBank % 32
		end
		i = $ + 1
	end
	return itemstoreturn
end)