--!strict
-- Runtime representation only: locations, NPC schedules and combat values originate in generated JSON.
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local DataIndex = require(ReplicatedStorage.Shared.DataIndex)
local Quest = require(script.Parent.QuestService)
local State = require(script.Parent.StateService)
local Crime = require(script.Parent.CrimeService)
local Trainers = require(script.Parent.TrainerService)

local World = {}
local worldTime = 8
local elapsed = 0
local scheduleClock = 0
local npcModels: {[string]: Model} = {}
local schedules = DataIndex.byId("npc_schedules")
local markers: {[string]: Vector3} = {}
local monsters: {Model} = {}

local function part(parent: Instance, name: string, pos: Vector3, size: Vector3, color: Color3): Part
	local p = Instance.new("Part")
	p.Name, p.Anchored, p.Size, p.Position = name, true, size, pos
	p.Color, p.Material, p.TopSurface, p.BottomSurface = color, Enum.Material.Slate, Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function addPrompt(parent: Instance, actionText: string, objectText: string, callback: (Player) -> ()): ()
	local p = Instance.new("ProximityPrompt")
	p.ActionText, p.ObjectText, p.MaxActivationDistance, p.RequiresLineOfSight = actionText, objectText, 12, true
	p.Parent = parent
	p.Triggered:Connect(callback)
end

local function marker(name: string, pos: Vector3): ()
	markers[name] = pos
end

local function scheduleEntry(npcId: string): any?
	local schedule = schedules["schedule_" .. npcId]
	if not schedule then return nil end
	for _, entry in ipairs(schedule.entries) do
		if worldTime >= entry.from and worldTime < entry.to then return entry end
	end
	return schedule.entries[#schedule.entries]
end

local function applySchedule(npcId: string): ()
	local model = npcModels[npcId]
	local entry = scheduleEntry(npcId)
	if not model or not entry then return end
	local root = model:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then return end
	model:SetAttribute("Activity", entry.activity)
	model:SetAttribute("ScheduleMarker", entry.marker)
	local destination = markers[entry.marker] or markers["safe_" .. tostring(model:GetAttribute("Faction"))]
	if not destination then return end
	-- Small server-owned move, not client navigation. A failed/missing marker goes to faction-safe fallback.
	if (root.Position - destination).Magnitude > 4 then
		TweenService:Create(root, TweenInfo.new(1.8, Enum.EasingStyle.Linear), {Position = destination}):Play()
	end
end

local function spawnNpc(folder: Folder, data: any, index: number): ()
	local model = Instance.new("Model")
	model.Name = data.name
	model:SetAttribute("NpcId", data.id)
	model:SetAttribute("Faction", data.faction)
	model:SetAttribute("DialogueId", data.dialogueId)
	model.Parent = folder
	local factionOrigin = data.faction == "kordon" and Vector3.new(0, 6, 0) or (data.faction == "wolnica" and Vector3.new(300, 6, 0) or Vector3.new(145, 6, -35))
	local offset = Vector3.new((index % 5) * 4, 0, (math.floor(index / 5) % 4) * 4)
	local tone = data.faction == "kordon" and Color3.fromRGB(80, 72, 58) or (data.faction == "wolnica" and Color3.fromRGB(82, 48, 45) or Color3.fromRGB(65, 61, 54))
	local root = part(model, "HumanoidRootPart", factionOrigin + offset, Vector3.new(2.5, 5, 2.5), tone)
	local head = part(model, "Head", root.Position + Vector3.new(0, 3.2, 0), Vector3.new(2, 1.5, 2), Color3.fromRGB(166, 126, 96))
	local hum = Instance.new("Humanoid")
	hum.MaxHealth, hum.Health, hum.DisplayName = data.stats.hp, data.stats.hp, data.name
	hum.Parent = model
	npcModels[data.id] = model
	addPrompt(root, "Rozmawiaj", data.name, function(player)
		if data.id == "npc_old_01" then Quest.start(player, "quest_main_arrival") end
		local trainer = Trainers.forNpc(data.id)
		if trainer then ReplicatedStorage.Remotes.GameNotice:FireClient(player, "trainer", trainer) end
		ReplicatedStorage.Remotes.GameNotice:FireClient(player, "dialogue", data.dialogueId)
	end)
end

function World.build()
	local old = workspace:FindFirstChild("AshBorder")
	if old then old:Destroy() end
	local folder = Instance.new("Folder")
	folder.Name = "AshBorder"
	folder.Parent = workspace
	local ground = part(folder, "Ground", Vector3.new(120, -4, 0), Vector3.new(700, 8, 500), Color3.fromRGB(48, 45, 40))
	ground.Material = Enum.Material.Ground
	for _, loc in ipairs(DataIndex.records("world_locations")) do
		local pos = Vector3.new(loc.position[1], 4, loc.position[3])
		local landmark = part(folder, loc.id, pos, Vector3.new(38, 8, 30), loc.kind == "settlement" and Color3.fromRGB(74, 61, 47) or Color3.fromRGB(52, 68, 48))
		landmark:SetAttribute("LocationId", loc.id)
		if loc.kind == "settlement" then
			for j = 1, 4 do part(folder, "hut", pos + Vector3.new(j * 9, 9, 12), Vector3.new(8, 14, 8), Color3.fromRGB(63, 43, 31)) end
		end
	end
	-- Markers turn schedule JSON into stable runtime targets. They also provide an explicit fallback.
	marker("work_kordon", Vector3.new(8, 6, 10)); marker("mess", Vector3.new(3, 6, 20)); marker("fire_kordon", Vector3.new(-8, 6, 14)); marker("bed_kordon", Vector3.new(-13, 6, 5)); marker("safe_kordon", Vector3.new(0, 6, 0))
	marker("work_wolnica", Vector3.new(308, 6, 10)); marker("fire_wolnica", Vector3.new(292, 6, 14)); marker("bed_wolnica", Vector3.new(287, 6, 5)); marker("safe_wolnica", Vector3.new(300, 6, 0))
	marker("work_neutral", Vector3.new(145, 6, -25)); marker("fire_neutral", Vector3.new(150, 6, -35)); marker("bed_neutral", Vector3.new(140, 6, -42)); marker("safe_neutral", Vector3.new(145, 6, -35))
	for i, npc in ipairs(DataIndex.records("npcs")) do spawnNpc(folder, npc, i) end
	for _, chestData in ipairs(DataIndex.records("world_interactables")) do
		local chest = part(folder, "LockedChest", Vector3.new(chestData.position[1], chestData.position[2], chestData.position[3]), Vector3.new(5, 5, 4), Color3.fromRGB(86, 56, 25))
		chest:SetAttribute("ChestId", chestData.id)
		addPrompt(chest, "Otwórz (zamek " .. tostring(chestData.lockDifficulty) .. ")", chestData.name, function(player)
			ReplicatedStorage.Remotes.GameNotice:FireClient(player, "lock", chestData.id)
		end)
	end
	-- An owned object is a concrete witness/ownership test, rather than a global crime flag.
	local ownedPlant = part(folder, "KordonHerb", Vector3.new(12, 2, 16), Vector3.new(1, 2, 1), Color3.fromRGB(113, 136, 61))
	ownedPlant:SetAttribute("OwnerFaction", "kordon")
	addPrompt(ownedPlant, "Zabierz", "Cudzy krwawnik", function(player)
		State.addItem(player, "plant_01", 1)
		ReplicatedStorage.Remotes.GameNotice:FireClient(player, "toast", Crime.reportTheft(player, ownedPlant.Position, "kordon"))
		ownedPlant:Destroy()
	end)
	local monster = Instance.new("Model")
	monster.Name = "Żarłacz trzcin"; monster:SetAttribute("MonsterId", "monster_zarlacz"); monster:SetAttribute("Faction", "beast"); monster.Parent = folder
	local body = part(monster, "HumanoidRootPart", Vector3.new(92, 5, 48), Vector3.new(5, 5, 7), Color3.fromRGB(49, 76, 55))
	local hum = Instance.new("Humanoid"); hum.MaxHealth, hum.Health = 42, 42; hum.Parent = monster
	table.insert(monsters, monster)
	Lighting.ClockTime, Lighting.Brightness, Lighting.OutdoorAmbient = worldTime, 1.4, Color3.fromRGB(74, 69, 72)
	for npcId in pairs(npcModels) do applySchedule(npcId) end
end

local function tickMonster(monster: Model, dt: number): ()
	local root = monster:FindFirstChild("HumanoidRootPart") :: BasePart?
	local hum = monster:FindFirstChildOfClass("Humanoid")
	if not root or not hum or hum.Health <= 0 then return end
	local closest: BasePart?; local distance = 45
	for _, player in Players:GetPlayers() do
		local char = player.Character; local candidate = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
		if candidate and (candidate.Position - root.Position).Magnitude < distance then closest, distance = candidate, (candidate.Position - root.Position).Magnitude end
	end
	if closest then
		if distance > 5 then root.CFrame = root.CFrame:Lerp(CFrame.new(root.Position:Lerp(closest.Position, math.min(dt * 0.35, 1))), math.min(dt * 2, 1))
		else local targetHum = closest.Parent and closest.Parent:FindFirstChildOfClass("Humanoid"); if targetHum then targetHum:TakeDamage(4) end end
	end
end

function World.tick(dt: number)
	worldTime = (worldTime + dt * 0.05) % 24; Lighting.ClockTime = worldTime
	elapsed += dt; scheduleClock += dt
	if scheduleClock >= 8 then scheduleClock = 0; for npcId in pairs(npcModels) do applySchedule(npcId) end end
	if elapsed >= .25 then for _, monster in ipairs(monsters) do tickMonster(monster, elapsed) end; elapsed = 0 end
end
return World
