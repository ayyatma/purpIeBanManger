---@meta _
---@diagnostic disable

local function renderGodSection(godName)
	local function writeBoonRarity(rarity)
		if rarity.isDuo then
			rom.ImGui.SameLine()
			rom.ImGui.TextColored(0.82, 1, 0.38, 1, '(D)')
		elseif rarity.isLegendary then
			rom.ImGui.SameLine()
			rom.ImGui.TextColored(1, 0.56, 0, 1, '(L)')
		elseif rarity.isElemental then
			rom.ImGui.SameLine()
			rom.ImGui.TextColored(1, 0.29, 1, 1, '(I)')
		end
	end

	local godData = godInfo[godName]
	local displayGod = godName
	local color = godData.color

	displayGod = displayGod 

	rom.ImGui.PushStyleColor(rom.ImGuiCol.Header, color[1], color[2], color[3], 0.2)
	rom.ImGui.PushStyleColor(rom.ImGuiCol.HeaderHovered, color[1], color[2], color[3], 0.5)
	rom.ImGui.PushStyleColor(rom.ImGuiCol.HeaderActive, color[1], color[2], color[3], 0.7)
	local openGod = rom.ImGui.CollapsingHeader(displayGod)
	rom.ImGui.PopStyleColor(3)

	rom.ImGui.SameLine()
	rom.ImGui.Text(tostring(godData.banned) .. " / " .. tostring(godData.total) .. " banned")

	if openGod then
		
		rom.ImGui.Separator()
		-- rom.ImGui.BeginChild("BoonScrolling" .. godName, 0, 300)
		for _, boon in ipairs(godData.boons) do
			local mask = bit32.lshift(1, boon.Bit)
			local current = (bit32.band(getConfig(godName), mask) ~= 0)
			local label = boon.Name

			rom.ImGui.PushStyleColor(rom.ImGuiCol.FrameBg, color[1], color[2], color[3], 0.5)
			rom.ImGui.PushStyleColor(rom.ImGuiCol.FrameBgHovered, color[1], color[2], color[3], 0.7)
			rom.ImGui.PushStyleColor(rom.ImGuiCol.CheckMark, 1, 1, 1, 1)
			local value, changed = rom.ImGui.Checkbox(label, current)
			writeBoonRarity(boon.Rarity)
			rom.ImGui.PopStyleColor(3)
			
			if changed then
				local currentMask = getConfig(godName)
				if value then
					currentMask = bit32.bor(currentMask, mask)
					godData.banned = godData.banned + 1
				else
					currentMask = bit32.band(currentMask, bit32.bnot(mask))
					godData.banned = godData.banned - 1
				end
				setConfig(godName, currentMask)
				print(boon.God .. " - " .. boon.Name .. " ban set to " .. tostring(value))
			end
		end

		rom.ImGui.Separator()

		if rom.ImGui.Button("Reset Bans for " .. godName) then
			ResetGodBans(godName)
		end
		-- rom.ImGui.EndChild()
	end
	
	return openGod
end
local openGodName = nil

local function BanManagerUI()
	if not config.BanManager then
		return
	end

	local epicValue, epicChecked = rom.ImGui.Checkbox("Force First Boon to be Epic", config.ForceFirstBoonEpic)
	if epicChecked then
		config.ForceFirstBoonEpic = epicValue
	end

	-- rom.ImGui.SameLine()

	rom.ImGui.Spacing()

	local groups = {
		{ label = "Core", gods = {"Aphrodite", "Apollo", "Ares", "Demeter", "Hephaestus", "Hera", "Hestia", "Poseidon", "Zeus"} },
		{ label = "Bonus", gods = {"Hermes", "Artemis", "Athena", "Dionysus", "Selene"} },
		{ label = "NPC", gods = {"Medea", "Circe", "Arachne", "Narcissus", "Echo", "Hades"} },
		{ label = "Keepsakes", gods = {"HadesKeepsake"} },
		{ label = "Daedalus Hammer", gods = {"Staff", "Dagger", "Axe", "Torch", "Lob", "Suit"} },
	}

	

	for _, group in ipairs(groups) do
		if not openGodName then
			rom.ImGui.Text(group.label)
		end
		for _, godName in ipairs(group.gods) do
			if not openGodName then
				local openGod = renderGodSection(godName)
				if openGod then
					openGodName = godName
				end
			elseif openGodName == godName then
				local openGod = renderGodSection(godName)
				if not openGod then
					openGodName = nil
				end
			end
		end
		if not openGodName then
			rom.ImGui.Separator()
		end
	end
	
	if rom.ImGui.Button("Reset All Bans") then
		ResetAllBans()
	end

end


local function drawModMenu()
	local value, checked = rom.ImGui.Checkbox("Enable BanManager", config.BanManager)

	if checked then
		config.BanManager = value
	end


	BanManagerUI()
end

rom.gui.add_imgui(function()
	if rom.ImGui.Begin("BanManager") then
		drawModMenu()
		rom.ImGui.End()
	end
end)

rom.gui.add_to_menu_bar(function()
	if rom.ImGui.BeginMenu("Configure") then
		drawModMenu()
		rom.ImGui.EndMenu()
	end
end)


