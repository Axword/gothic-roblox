--!strict
-- Runtime representation only: locations, NPC schedules and combat values originate in generated JSON.
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataIndex = require(ReplicatedStorage.Shared.DataIndex)
local Quest = require(script.Parent.QuestService)
local State = require(script.Parent.StateService)
local Crime = require(script.Parent.CrimeService)
local Trainers = require(script.Parent.TrainerService)
local Dialogues = require(script.Parent.DialogueService)
local Routines = require(script.Parent.RoutineService)

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
		local fallback = markers["safe_" .. tostring(model:GetAttribute("Faction"))] or destination
		Routines.move(model, destination, fallback)
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
		Dialogues.open(player, data.dialogueId)
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
	for _, entry in ipairs(DataIndex.records("world_interactables")) do
		local position = Vector3.new(entry.position[1], entry.position[2], entry.position[3])
		if entry.lockDifficulty then
			local chest = part(folder, "LockedChest", position, Vector3.new(5, 5, 4), Color3.fromRGB(86, 56, 25))
			chest:SetAttribute("ChestId", entry.id)
			addPrompt(chest, "Otwórz (zamek " .. tostring(entry.lockDifficulty) .. ")", entry.name, function(player)
				ReplicatedStorage.Remotes.GameNotice:FireClient(player, "lock", entry.id)
			end)
		elseif entry.kind == "questObjective" then
			local clue = part(folder, "QuestClue", position, Vector3.new(2, 3, 2), Color3.fromRGB(135, 112, 53))
			clue:SetAttribute("ObjectiveId", entry.id)
			addPrompt(clue, "Zbadaj", entry.name, function(player)
				local ok,message = Quest.objective(player, entry.id)
				ReplicatedStorage.Remotes.GameNotice:FireClient(player, "toast", message or (ok and "Zapisano." or "To nie jest teraz twoja sprawa."))
			end)
		end
	end
	-- Gatherable flora comes from item JSON; each visual is deliberately a different color/height.
	for index, plantData in ipairs(DataIndex.records("items_plants")) do
		local herb = part(folder, "GatherablePlant", Vector3.new(90 + index * 11, 1.5, 76 + (index % 3) * 9), Vector3.new(1.2, 1 + (index % 3), 1.2), Color3.fromHSV(index / 14, .42, .52 + (index % 2) * .15))
		herb:SetAttribute("ItemId", plantData.id)
		addPrompt(herb, "Zbierz", plantData.name, function(player)
			State.addItem(player, plantData.id, 1)
			ReplicatedStorage.Remotes.GameNotice:FireClient(player, "toast", "Zebrano: " .. plantData.name)
			herb:Destroy()
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
	local locations = DataIndex.byId("world_locations")
	local monsterData = DataIndex.byId("monsters")
	local silhouettes = {pack = {Color3.fromRGB(49,76,55), Vector3.new(5,5,7)}, tank = {Color3.fromRGB(69,62,43), Vector3.new(8,7,8)}, ranged = {Color3.fromRGB(71,81,100), Vector3.new(4,7,4)}, nocturnal = {Color3.fromRGB(31,28,48), Vector3.new(4,6,6)}, ambush = {Color3.fromRGB(91,71,55), Vector3.new(7,5,5)}, caster = {Color3.fromRGB(105,50,110), Vector3.new(5,8,5)}}
	for _, spawn in ipairs(DataIndex.records("monster_spawns")) do
		local definition = monsterData[spawn.monsterId]
		local location = locations[spawn.locationId]
		if definition and location then
			local base = Vector3.new(location.position[1], 5, location.position[3])
			local visual = silhouettes[definition.behavior] or silhouettes.pack
			for count = 1, spawn.count do
				local monster = Instance.new("Model")
				monster.Name = definition.name
				monster:SetAttribute("MonsterId", definition.id)
				monster:SetAttribute("SpawnId", spawn.id .. "_" .. tostring(count))
				monster:SetAttribute("Behavior", definition.behavior)
				monster:SetAttribute("Faction", "beast")
				monster.Parent = folder
				local body = part(monster, "HumanoidRootPart", base + Vector3.new(count * 7, 0, count * 4), visual[2], visual[1])
				local hum = Instance.new("Humanoid"); hum.MaxHealth, hum.Health = definition.hp, definition.hp; hum.Parent = monster
				table.insert(monsters, monster)
			end
		end
	end
	-- Hand-built low-poly dressing: trunks, crowns, quarry rocks and a dark coast make biome silhouettes readable without external assets.
	for i = 1, 32 do
		local x,z = -70 + (i * 31) % 430, 55 + (i * 47) % 190
		local trunk = part(folder,"TreeTrunk",Vector3.new(x,5,z),Vector3.new(2,10,2),Color3.fromRGB(55,40,29));trunk.Material=Enum.Material.Wood
		local crown = part(folder,"TreeCrown",Vector3.new(x,12,z),Vector3.new(9,7,9),Color3.fromRGB(38,62,42));crown.Shape=Enum.PartType.Ball
	end
	for i = 1, 18 do local rock=part(folder,"QuarryRock",Vector3.new(-145+(i%6)*13,3,86+math.floor(i/6)*14),Vector3.new(5+(i%3),5,4+(i%2)),Color3.fromRGB(69,67,61));rock.Orientation=Vector3.new(i*9,i*17,0) end
	local sea=part(folder,"ColdSea",Vector3.new(350,-1,-115),Vector3.new(130,2,110),Color3.fromRGB(34,61,73));sea.Material=Enum.Material.Glass;sea.Transparency=.25
	local mistAnchor=part(folder,"SwampMist",Vector3.new(230,4,130),Vector3.new(1,1,1),Color3.fromRGB(0,0,0));mistAnchor.Transparency=1
	local mist=Instance.new("ParticleEmitter");mist.Texture="rbxasset://textures/particles/smoke_main.dds";mist.Color=ColorSequence.new(Color3.fromRGB(130,145,125));mist.Rate=9;mist.Lifetime=NumberRange.new(5,9);mist.Speed=NumberRange.new(.4,1.2);mist.Size=NumberSequence.new(5);mist.Parent=mistAnchor
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
	if not closest then return end
	local behavior = monster:GetAttribute("Behavior")
	if behavior == "nocturnal" and worldTime > 5 and worldTime < 20 then return end
	local targetHum = closest.Parent and closest.Parent:FindFirstChildOfClass("Humanoid")
	if behavior == "ranged" then
		if distance > 28 then root.Position = root.Position:Lerp(closest.Position, math.min(dt * .22, 1))
		elseif distance > 8 and targetHum and not closest.Parent:GetAttribute("Dodging") then targetHum:TakeDamage(closest.Parent:GetAttribute("Blocking") and 1 or 3) end
	elseif distance > 5 then
		local speed = behavior == "tank" and .13 or .35
		root.Position = root.Position:Lerp(closest.Position, math.min(dt * speed, 1))
	elseif targetHum and not closest.Parent:GetAttribute("Dodging") then
		targetHum:TakeDamage(closest.Parent:GetAttribute("Blocking") and 1 or (behavior == "tank" and 7 or 4))
	end
end

function World.tick(dt: number)
	worldTime = (worldTime + dt * 0.05) % 24; Lighting.ClockTime = worldTime
	elapsed += dt; scheduleClock += dt
	if scheduleClock >= 8 then scheduleClock = 0; for npcId in pairs(npcModels) do applySchedule(npcId) end end
	if elapsed >= .25 then
		for _, monster in ipairs(monsters) do tickMonster(monster, elapsed) end
		-- Alarmed guards are local and faction-specific; they only strike a nearby wanted player.
		for _,player in ipairs(Players:GetPlayers()) do
			local char=player.Character;local playerRoot=char and char:FindFirstChild("HumanoidRootPart") :: BasePart?;local playerHum=char and char:FindFirstChildOfClass("Humanoid")
			if playerRoot and playerHum then for _,npc in pairs(npcModels) do local faction=npc:GetAttribute("Faction");local npcRoot=npc:FindFirstChild("HumanoidRootPart") :: BasePart?;if type(faction)=="string" and State.get(player).flags["wanted_"..faction] and npcRoot and (npcRoot.Position-playerRoot.Position).Magnitude<10 then playerHum:TakeDamage(3) end end end
		end
		elapsed = 0
	end
end
return World
