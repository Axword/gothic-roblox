--!strict
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataIndex = require(ReplicatedStorage.Shared.DataIndex)
local State = require(script.Parent.StateService)
local Quest = require(script.Parent.QuestService)
local Dialogue = require(script.Parent.DialogueService)

local World = {}
local worldTime = 8

local function part(parent: Instance, name: string, pos: Vector3, size: Vector3, color: Color3): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.Size = size
	p.Position = pos
	p.Color = color
	p.Material = Enum.Material.Slate
	p.Parent = parent
	return p
end

local function prompt(parent: Instance, action: string, object: string, callback: (Player) -> ()): ProximityPrompt
	local p = Instance.new("ProximityPrompt")
	p.ActionText = action
	p.ObjectText = object
	p.MaxActivationDistance = 12
	p.RequiresLineOfSight = true
	p.Parent = parent
	p.Triggered:Connect(callback)
	return p
end

local function getBiomeVisuals(kind: string): (Color3, Enum.Material)
	if kind == "settlement" then
		return Color3.fromRGB(74, 61, 47), Enum.Material.Slate
	elseif kind == "forest" then
		return Color3.fromRGB(34, 76, 35), Enum.Material.Grass
	elseif kind == "swamp" then
		return Color3.fromRGB(49, 58, 41), Enum.Material.Mud
	elseif kind == "quarry" then
		return Color3.fromRGB(90, 95, 99), Enum.Material.Rock
	elseif kind == "coast" then
		return Color3.fromRGB(219, 201, 161), Enum.Material.Sand
	elseif kind == "threat" then
		return Color3.fromRGB(130, 20, 130), Enum.Material.CorrodedMetal
	else
		return Color3.fromRGB(60, 50, 45), Enum.Material.Ground
	end
end

function World.build()
	local folder = Instance.new("Folder")
	folder.Name = "AshBorder"
	folder.Parent = workspace
	
	-- Vast open RPG world ground
	local ground = part(folder, "Ground", Vector3.new(120, -4, 0), Vector3.new(1200, 8, 1000), Color3.fromRGB(48, 45, 40))
	ground.Material = Enum.Material.Ground
	
	for _, loc in DataIndex.records("world_locations") do
		local pos = Vector3.new(loc.position[1], 4, loc.position[3])
		local color, material = getBiomeVisuals(loc.kind)
		
		-- Procedural landmark for biome region
		local landmark = part(folder, loc.id, pos, Vector3.new(60, 8, 50), color)
		landmark.Material = material
		landmark:SetAttribute("LocationId", loc.id)
		
		-- Biome-specific decor generation
		if loc.kind == "settlement" then
			-- Spawns wooden huts
			for j = 1, 4 do
				part(folder, "Hut_" .. loc.id .. "_" .. j, pos + Vector3.new(j * 11, 9, 15), Vector3.new(10, 14, 10), Color3.fromRGB(63, 43, 31))
			end
		elseif loc.kind == "forest" then
			-- Spawns procedural wooden trunks (trees)
			for j = 1, 5 do
				local tree = part(folder, "Tree_" .. j, pos + Vector3.new(j * 8 - 20, 12, math.sin(j)*15), Vector3.new(4, 20, 4), Color3.fromRGB(70, 50, 30))
				tree.Material = Enum.Material.Wood
				local leaves = part(folder, "Leaves_" .. j, tree.Position + Vector3.new(0, 12, 0), Vector3.new(12, 8, 12), Color3.fromRGB(30, 90, 40))
				leaves.Material = Enum.Material.Grass
			end
		elseif loc.kind == "swamp" then
			-- Spawns slimy vegetation columns
			for j = 1, 3 do
				local slime = part(folder, "SlimePile_" .. j, pos + Vector3.new(j * 10 - 20, 6, math.cos(j)*10), Vector3.new(6, 10, 6), Color3.fromRGB(24, 48, 20))
				slime.Material = Enum.Material.Mud
			end
		elseif loc.kind == "quarry" then
			-- Spawns massive rock blocks/boulders
			for j = 1, 3 do
				local boulder = part(folder, "Boulder_" .. j, pos + Vector3.new(j * 12 - 24, 10, j * 5), Vector3.new(14, 18, 14), Color3.fromRGB(110, 115, 115))
				boulder.Material = Enum.Material.Rock
			end
		elseif loc.kind == "coast" then
			-- Spawns water surface parts alongside beach
			local water = part(folder, "WaterBorder", pos + Vector3.new(0, 0, -25), Vector3.new(60, 2, 20), Color3.fromRGB(30, 80, 120))
			water.Material = Enum.Material.Glass
			water.Transparency = 0.4
		elseif loc.kind == "threat" then
			-- Spawns dangerous purple glowing spikes representing Vacuum Maw
			for j = 1, 3 do
				local spike = part(folder, "VoidSpike_" .. j, pos + Vector3.new(j * 12 - 24, 12, j * 2), Vector3.new(4, 24, 4), Color3.fromRGB(180, 50, 250))
				spike.Material = Enum.Material.Neon
			end
		end
	end
	
	-- Three vertical-slice NPCs are interactive
	local npcData = DataIndex.byId("npcs")
	for _, id in {"npc_old_01", "npc_new_01", "npc_neutral_02"} do
		local n = npcData[id]
		local model = Instance.new("Model")
		model.Name = n.name
		model:SetAttribute("NpcId", id)
		model:SetAttribute("Faction", n.faction)
		model.Parent = folder
		
		local base = id == "npc_old_01" and Vector3.new(0, 6, 0) or (id == "npc_new_01" and Vector3.new(300, 6, 0) or Vector3.new(145, 6, -35))
		local body = part(model, "HumanoidRootPart", base, Vector3.new(3, 6, 3), n.faction == "kordon" and Color3.fromRGB(80, 72, 58) or Color3.fromRGB(72, 52, 48))
		body.Anchored = true
		
		local h = Instance.new("Humanoid")
		h.MaxHealth = n.stats.hp
		h.Health = n.stats.hp
		h.Parent = model
		
		prompt(body, "Rozmawiaj", n.name, function(player)
			Dialogue.start(player, id, n.dialogueId)
		end)
		
		prompt(body, "Okradnij kieszenie", n.name, function(player)
			ReplicatedStorage.Remotes.GameAction:FireServer("steal", { npcId = id })
		end)
	end
	
	-- Chests with three difficulty levels
	local chest1 = part(folder, "LockedChestEasy", Vector3.new(62, 3, 28), Vector3.new(5, 5, 4), Color3.fromRGB(86, 56, 25))
	chest1:SetAttribute("ChestId", "chest_tutorial")
	prompt(chest1, "Otwórz (zamek I)", "Skrzynia poborcy", function(player)
		ReplicatedStorage.Remotes.GameNotice:FireClient(player, "lock", "chest_tutorial")
	end)
	
	local chest2 = part(folder, "LockedChestMedium", Vector3.new(80, 3, 28), Vector3.new(5, 5, 4), Color3.fromRGB(86, 56, 25))
	chest2:SetAttribute("ChestId", "chest_medium")
	prompt(chest2, "Otwórz (zamek II)", "Skrzynia kupca", function(player)
		ReplicatedStorage.Remotes.GameNotice:FireClient(player, "lock", "chest_medium")
	end)
	
	local chest3 = part(folder, "LockedChestHard", Vector3.new(100, 3, 28), Vector3.new(5, 5, 4), Color3.fromRGB(86, 56, 25))
	chest3:SetAttribute("ChestId", "chest_hard")
	prompt(chest3, "Otwórz (zamek III)", "Skrzynia strażnika", function(player)
		ReplicatedStorage.Remotes.GameNotice:FireClient(player, "lock", "chest_hard")
	end)
	
	-- Monster with skinning prompt
	local monster = Instance.new("Model")
	monster.Name = "Żarłacz trzcin"
	monster:SetAttribute("MonsterId", "monster_zarlacz")
	monster.Parent = folder
	
	local mb = part(monster, "HumanoidRootPart", Vector3.new(92, 5, 48), Vector3.new(5, 5, 7), Color3.fromRGB(49, 76, 55))
	mb.Anchored = true
	
	local mh = Instance.new("Humanoid")
	mh.MaxHealth = 42
	mh.Health = 42
	mh.Parent = monster
	
	prompt(mb, "Skóruj", "Żarłacz trzcin", function(player)
		local actionEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("GameAction") :: RemoteEvent
		actionEvent:FireServer("skin", { targetId = "monster_zarlacz" })
	end)
	
	Lighting.ClockTime = worldTime
	Lighting.Brightness = 1.4
	Lighting.OutdoorAmbient = Color3.fromRGB(74, 69, 72)
end

function World.tick(dt: number)
	worldTime = (worldTime + dt * 0.05) % 24
	Lighting.ClockTime = worldTime
end

return World
