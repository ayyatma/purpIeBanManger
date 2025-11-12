---@meta _
---@diagnostic disable: lowercase-global

local mods = rom.mods

-- Global flag to detect keepsake boon offering
local isKeepsakeOffering = false

-- Bit-packed config mappings: which packed var, offset, and bits for each god
configMappings = {
    Aphrodite = {var = "PackedConfig1", offset = 0, bits = 22},
    Artemis = {var = "PackedConfig1", offset = 22, bits = 9},
    Apollo = {var = "PackedConfig2", offset = 0, bits = 22},
    Athena = {var = "PackedConfig2", offset = 22, bits = 8},
    Ares = {var = "PackedConfig3", offset = 0, bits = 22},
    Dionysus = {var = "PackedConfig3", offset = 22, bits = 8},
    Demeter = {var = "PackedConfig4", offset = 0, bits = 22},
    Hades = {var = "PackedConfig4", offset = 22, bits = 8},
    Hephaestus = {var = "PackedConfig5", offset = 0, bits = 22},
    HadesKeepsake = {var = "PackedConfig5", offset = 22, bits = 8},
    Hera = {var = "PackedConfig6", offset = 0, bits = 22},
    Arachne = {var = "PackedConfig6", offset = 22, bits = 8},
    Hestia = {var = "PackedConfig7", offset = 0, bits = 22},
    Narcissus = {var = "PackedConfig7", offset = 22, bits = 9},
    Poseidon = {var = "PackedConfig8", offset = 0, bits = 22},
    Echo = {var = "PackedConfig8", offset = 22, bits = 8},
    Zeus = {var = "PackedConfig9", offset = 0, bits = 22},
    Medea = {var = "PackedConfig9", offset = 22, bits = 8},
    Hermes = {var = "PackedConfig10", offset = 0, bits = 13},
    Circe = {var = "PackedConfig10", offset = 13, bits = 9},
    Selene = {var = "PackedConfig10", offset = 22, bits = 9},
    Axe = {var = "PackedConfig11", offset = 0, bits = 14},
    Torch = {var = "PackedConfig11", offset = 14, bits = 13},
    Staff = {var = "PackedConfig12", offset = 0, bits = 16},
    Lob = {var = "PackedConfig12", offset = 16, bits = 16},
    Suit = {var = "PackedConfig13", offset = 0, bits = 17},
    Dagger = {var = "PackedConfig13", offset = 17, bits = 15},
}

-- Helper to get unpacked config for a god
function getConfig(god)
    local map = configMappings[god]
    if not map then return 0 end
    local packed = config[map.var] or 0
    return bit32.band(bit32.rshift(packed, map.offset), (bit32.lshift(1, map.bits) - 1))
end

-- Helper to set unpacked config for a god
function setConfig(god, mask)
    local map = configMappings[god]
    if not map then return end
    local packed = config[map.var] or 0
    -- Clear the bits for this god
    local clearMask = bit32.bnot(bit32.lshift((bit32.lshift(1, map.bits) - 1), map.offset))
    packed = bit32.band(packed, clearMask)
    -- Set the new bits
    packed = bit32.bor(packed, bit32.lshift(bit32.band(mask, (bit32.lshift(1, map.bits) - 1)), map.offset))
    config[map.var] = packed
end

-- Function to populate godInfo from game data
local function populateGodInfo()
	godInfo.traitLookup = {}
	
	local function getColor(name)
		local color = {}
		local inGameColor = game.Color.Black
		if name == 'Aphrodite' then
			inGameColor = game.Color.AphroditeDamage
		elseif name == 'Apollo' then
			inGameColor = game.Color.ApolloDamageLight
		elseif name == 'Ares' then
			inGameColor = game.Color.AresDamageLight
		elseif name == 'Athena' then
			inGameColor = game.Color.AthenaDamageLight
		elseif name == 'Demeter' then
			inGameColor = game.Color.DemeterDamage
		elseif name == 'Dionysus' then
			inGameColor = game.Color.DionysusDamage
		elseif name == 'Hera' then
			inGameColor = game.Color.HeraDamage
		elseif name == 'Hestia' then
			inGameColor = game.Color.HestiaDamageLight
		elseif name == 'Hephaestus' then
			inGameColor = game.Color.HephaestusDamage
		elseif name == 'Poseidon' then
			inGameColor = game.Color.PoseidonDamage
		elseif name == 'Zeus' then
			inGameColor = game.Color.ZeusDamageLight
		elseif name == 'Hermes' then
			inGameColor = game.Color.HermesVoice
		elseif name == 'Artemis' then
			inGameColor = game.Color.ArtemisDamage
		elseif name == 'Hades' then
			inGameColor = game.Color.HadesVoice
		elseif name == 'Arachne' then
			inGameColor = game.Color.ArachneVoice
		elseif name == 'Narcissus' then
			inGameColor = game.Color.NarcissusVoice
		elseif name == 'Echo' then
			inGameColor = game.Color.EchoVoice
		elseif name == 'Medea' then
			inGameColor = game.Color.MedeaVoice
		elseif name == 'Circe' then
			inGameColor = game.Color.CirceVoice
		elseif name == 'Selene' then
			inGameColor = game.Color.SeleneVoice
		end
		color[1] = inGameColor[1] / 255
		color[2] = inGameColor[2] / 255
		color[3] = inGameColor[3] / 255
		color[4] = inGameColor[4] / 255
		return color
	end

	-- Helper to add boon with all data
	local function addBoon(god, boonKey, index, hasRarity)
		local traitData = TraitData[boonKey]
		hasRarity = hasRarity or false
		local rarity = traitData and {
			isDuo = hasRarity and traitData.IsDuoBoon,
			isLegendary = hasRarity and traitData.RarityLevels and traitData.RarityLevels.Legendary ~= nil,
			isElemental = hasRarity and traitData.IsElementalTrait
		} or {isDuo = false, isLegendary = false, isElemental = false}
		local boon = {
			Key = boonKey,
			God = god,
			Bit = index,
			Name = game.GetDisplayName({ Text = boonKey }),
			Rarity = rarity
		}
		table.insert(godInfo[god].boons, boon)
		godInfo.traitLookup[boonKey] = {god = god, bit = index}
		-- print ("Added boon: " .. boon.Name .. " for god: " .. god .. " at bit: " .. tostring(index) .. " with key: " .. boonKey)
		-- print ("testing lookup: " .. tostring(godInfo.traitLookup[boonKey]) .. " bit: " .. tostring(godInfo.traitLookup[boonKey].bit))
		-- print ("Current godInfo.traitLookup count: " .. tostring( TableLength( godInfo.traitLookup ) ) )
	end

	-- Dynamically populate god boons from LootSetData for portability
	local godNames = { "Aphrodite", "Apollo", "Ares", "Demeter", "Hephaestus", "Hera", "Hestia", "Poseidon", "Zeus", 
						"Hermes" }
	for _, god in ipairs(godNames) do
		if LootSetData[god] and LootSetData[god][god .. "Upgrade"] then
			local upgradeData = LootSetData[god][god .. "Upgrade"]
			godInfo[god] = { color = getColor(god), boons = {} }
			local index = 0
			if upgradeData.WeaponUpgrades then
				for _, boon in ipairs(upgradeData.WeaponUpgrades) do
					addBoon(god, boon, index)
					index = index + 1
				end
			end
			if upgradeData.Traits then
				for _, boon in ipairs(upgradeData.Traits) do
					addBoon(god, boon, index, true)
					index = index + 1
				end
			end
			godInfo[god].total = #godInfo[god].boons
			local bannedCount = 0
			for _, boon in ipairs(godInfo[god].boons) do
				if bit32.band(getConfig(god), bit32.lshift(1, boon.Bit)) ~= 0 then
					bannedCount = bannedCount + 1
				end
			end
			godInfo[god].banned = bannedCount
		end
	end

	-- Fallback: populate from UnitSetData for entities
	local entityConfigs = {
		Artemis = "NPC_Artemis_Field_01",
		Athena = "NPC_Athena_01",
		Dionysus = "NPC_Dionysus_01",
		Hades = "NPC_Hades_Field_01",
		Arachne = "NPC_Arachne_01",
		Narcissus = "NPC_Narcissus_01",
		Echo = "NPC_Echo_01",
		Medea = "NPC_Medea_01",
		Circe = "NPC_Circe_01",
	}
	local entityNames = { "Artemis", "Athena", "Dionysus", "Hades", 
	"Arachne", "Narcissus", "Echo", "Medea", "Circe" }
	for _, entity in ipairs(entityNames) do
		local npcDataKey = "NPC_" .. entity
		local configKey = entityConfigs[entity]
		if UnitSetData[npcDataKey] and UnitSetData[npcDataKey][configKey] and UnitSetData[npcDataKey][configKey].Traits then
			godInfo[entity] = { color = getColor(entity), boons = {} }
			for i, boon in ipairs(UnitSetData[npcDataKey][configKey].Traits) do
				addBoon(entity, boon, i-1)
			end
			godInfo[entity].total = #godInfo[entity].boons
			local bannedCount = 0
			for _, boon in ipairs(godInfo[entity].boons) do
				if bit32.band(getConfig(entity), bit32.lshift(1, boon.Bit)) ~= 0 then
					bannedCount = bannedCount + 1
				end
			end
			godInfo[entity].banned = bannedCount
		end

	end

	-- Dynamically populate Selene spells
	godInfo["Selene"] = { color = getColor("Selene"), boons = {} }
	local spellNames = {}
	for spellName, _ in pairs(SpellData) do
		table.insert(spellNames, spellName)
	end
	table.sort(spellNames)  -- Sort for consistent order
	local index = 0
	for _, spellName in ipairs(spellNames) do
		local spellData = SpellData[spellName]
		local traitName = spellData.TraitName
		local displayName = game.GetDisplayName({ Text = traitName })
		addBoon("Selene", spellName, index)
		-- Override the name with the trait's display name
		godInfo["Selene"].boons[index + 1].Name = displayName
		-- print ("Added Selene spell: " .. spellName .. ", trait: " .. traitName .. ", display name: " .. displayName)
		index = index + 1
	end
	godInfo["Selene"].total = #godInfo["Selene"].boons
	local bannedCount = 0
	for _, boon in ipairs(godInfo["Selene"].boons) do
		if bit32.band(getConfig("Selene"), bit32.lshift(1, boon.Bit)) ~= 0 then
			bannedCount = bannedCount + 1
		end
	end
	godInfo["Selene"].banned = bannedCount
	-- end

	-- Dynamically populate Daedalus boons from LootSetData.Loot.WeaponUpgrade.Traits
	if LootSetData.Loot and LootSetData.Loot.WeaponUpgrade and LootSetData.Loot.WeaponUpgrade.Traits then
		local daedalusTraits = LootSetData.Loot.WeaponUpgrade.Traits
		local daedalusGroups = {
			Staff = {},
			Dagger = {},
			Axe = {},
			Torch = {},
			Lob = {},
			Suit = {},
		}
		for _, trait in ipairs(daedalusTraits) do
			local group
			if trait:find("^Staff") then
				group = "Staff"
			elseif trait:find("^Dagger") then
				group = "Dagger"
			elseif trait:find("^Axe") then
				group = "Axe"
			elseif trait:find("^Torch") then
				group = "Torch"
			elseif trait:find("^Lob") then
				group = "Lob"
			elseif trait:find("^Suit") then
				group = "Suit"
			end
			if group then
				table.insert(daedalusGroups[group], trait)
			end
		end
		for group, traits in pairs(daedalusGroups) do
			godInfo[group] = { color = getColor(group), boons = {} }
			for i, trait in ipairs(traits) do
				addBoon(group, trait, i-1)
			end
			godInfo[group].total = #godInfo[group].boons
			local bannedCount = 0
			for _, boon in ipairs(godInfo[group].boons) do
				if bit32.band(getConfig(group), bit32.lshift(1, boon.Bit)) ~= 0 then
					bannedCount = bannedCount + 1
				end
			end
			godInfo[group].banned = bannedCount
		end
	end
	
	-- Add Hades Keepsake as separate config
	if godInfo.Hades then
		godInfo.HadesKeepsake = {
			boons = godInfo.Hades.boons,
			color = godInfo.Hades.color,
			banned = 0,
			total = godInfo.Hades.total
		}
		-- Calculate initial banned count for HadesKeepsake
		local bannedCount = 0
		for _, boon in ipairs(godInfo.HadesKeepsake.boons) do
			if bit32.band(getConfig("HadesKeepsake"), bit32.lshift(1, boon.Bit)) ~= 0 then
				bannedCount = bannedCount + 1
			end
		end
		godInfo.HadesKeepsake.banned = bannedCount
	end
	
end

-- Populate the godInfo
populateGodInfo()



-- Helper function to wrap NPC choice functions
local function wrapNPCChoice(funcName)
	modutil.mod.Path.Wrap(funcName, function(base, source, args, screen)
		if config.BanManager and args.UpgradeOptions then
			local filtered = {}
			for _, option in ipairs(args.UpgradeOptions) do
				local info = godInfo.traitLookup[option.ItemName]
				local traitEnabled = (info == nil) or (bit32.band(getConfig(info.god), bit32.lshift(1, info.bit or 0)) == 0)
				if traitEnabled then
					table.insert(filtered, option)
				end
			end
			if #filtered > 0 then
				args.UpgradeOptions = filtered
			end
		end
		local result = base(source, args, screen)
		return result
	end)
end

-- Wrap NPC choice functions
wrapNPCChoice("ArachneCostumeChoice")
wrapNPCChoice("NarcissusBenefitChoice")
wrapNPCChoice("EchoChoice")
wrapNPCChoice("MedeaCurseChoice")
wrapNPCChoice("CirceBlessingChoice")


modutil.mod.Path.Wrap("GetEligibleSpells", function(base, screen, args)
	local eligible = base(screen, args)
	if not config.BanManager then
		return eligible
	end

	local filtered = {}
	for _, spellName in ipairs(eligible) do
		local info = godInfo.traitLookup[spellName]

		local traitEnabled = (info == nil) or (bit32.band(getConfig(info.god), bit32.lshift(1, info.bit or 0)) == 0)
		-- local condition1 = not (CurrentRun and CurrentRun.BannedTraits and CurrentRun.BannedTraits[spellName] ~= nil)
		
		-- if (condition1 ~= condition2) then
		-- 	local hasCurrentRun = CurrentRun ~= nil
		-- 	local hasBannedTraits = CurrentRun and CurrentRun.BannedTraits ~= nil
		-- 	local hasSpellBanned = CurrentRun and CurrentRun.BannedTraits and CurrentRun.BannedTraits[spellName] ~= nil

		-- 	local hasInfo = info ~= nil
		-- 	local bitCheck = hasInfo and bit32.band(config[info.god .. "Config"] or 0, bit32.lshift(1, info.bit or 0)) == 0 

		-- 	print(
		-- 		"Spell: " .. spellName ..
		-- 		" | CurrentRun exists: " .. tostring(hasCurrentRun) ..
		-- 		" | BannedTraits exists: " .. tostring(hasBannedTraits) ..
		-- 		" | Spell banned in CurrentRun: " .. tostring(hasSpellBanned) ..
		-- 		" | Condition1: ! (A & B & C) : " .. tostring(condition1) ..
		-- 		" | Info exists: " .. tostring(hasInfo) ..
		-- 		" | Bit check passed: " .. tostring(bitCheck) ..
		-- 		" | condition2: A | B" .. tostring(condition2)
		-- 	)
		-- 	print ("Spell condition mismatch")
		-- end
		if traitEnabled then
			table.insert(filtered, spellName)
		end
	end
	if #filtered > 0 then
		return filtered
	end
	return eligible
end)

modutil.mod.Path.Wrap("IsTraitEligible", function(base, traitData, args)
	if config.BanManager then
		local info = godInfo.traitLookup[traitData.Name]
		if info then
			local god = info.god
			if isKeepsakeOffering and god == "Hades" then
				god = "HadesKeepsake"
			end
			if bit32.band(getConfig(god), bit32.lshift(1, info.bit or 0)) ~= 0 then
				return false
			end
		end
	end
	return base(traitData, args)
end)

-- Wrap GiveRandomHadesBoonAndBoostBoons to set flag for keepsake context
modutil.mod.Path.Wrap("GiveRandomHadesBoonAndBoostBoons", function(base, args)
	isKeepsakeOffering = true
	local result = base(args)
	isKeepsakeOffering = false
	return result
end)


-- Function to reset all bans (enable all boons/hexes)
function ResetAllBans()
	for god, _ in pairs(godInfo) do
		ResetGodBans(god)
	end
	-- print("All bans have been reset. All boons and hexes are now enabled.")
end

-- Function to reset bans for a specific god (enable all boons/hexes for that god)
function ResetGodBans(god)
	if configMappings[god] and godInfo[god] then
		setConfig(god, 0)
		godInfo[god].banned = 0
		-- print("Bans for " .. god .. " have been reset.")
	-- else
	--  print("Invalid god name: " .. tostring(god))
	end
end
	-- print("Current Rarity Chance is: " .. lootData.RarityChances.Common .. ", " .. lootData.RarityChances.Rare .. ", " .. lootData.RarityChances.E)

-- Wrap StartNewRun to set force epic flag
modutil.mod.Path.Wrap("StartNewRun", function(base, prevRun, args)
	local result = base(prevRun, args)
	if config.BanManager and config.ForceFirstBoonEpic then
		CurrentRun.ForceEpicFirstBoon = true
	end
	return result
end)

-- Wrap GetRarityChances to modify for first boon
modutil.mod.Path.Wrap("GetRarityChances", function(base, loot)
	local rarityChances = base(loot)
	if CurrentRun.ForceEpicFirstBoon and loot.GodLoot then
		rarityChances.Common = 0
		rarityChances.Rare = 0
		rarityChances.Epic = 1
		rarityChances.Heroic = 1
	end
	return rarityChances
end)

-- Wrap AddTraitToHero to reset flag after first god boon is added
modutil.mod.Path.Wrap("AddTraitToHero", function(base, args)
	local result = base(args)
	local traitData = args.TraitData or (args.TraitName and TraitData[args.TraitName])
	if CurrentRun.ForceEpicFirstBoon and traitData and IsGodTrait(traitData.Name) then
		CurrentRun.ForceEpicFirstBoon = false
		print("ForceEpicFirstBoon flag reset after first god boon added to hero")
	end
	return result
end)


