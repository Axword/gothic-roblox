--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Constants = require(ReplicatedStorage.Shared.Constants)
local DataIndex = require(ReplicatedStorage.Shared.DataIndex)
local State = require(script.Services.StateService)
local Save = require(script.Services.SaveService)
local Combat = require(script.Services.CombatService)
local World = require(script.Services.WorldService)
local Dialogue = require(script.Services.DialogueService)

local remotes = Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = ReplicatedStorage

local action = Instance.new("RemoteEvent")
action.Name = "GameAction"
action.Parent = remotes

local notice = Instance.new("RemoteEvent")
notice.Name = "GameNotice"
notice.Parent = remotes

World.build()

local rate: {[Player]: {t: number, n: number}} = {}
local locks: {[Player]: number} = {}
local activeChests: {[Player]: string} = {}

local chests = {
	chest_tutorial = { difficulty = 1, sequence = {"left", "right", "left"}, lootTable = "loot_starter_chest" },
	chest_medium = { difficulty = 2, sequence = {"left", "left", "right", "left", "right"}, lootTable = "loot_starter_chest" },
	chest_hard = { difficulty = 3, sequence = {"right", "left", "right", "right", "left", "right", "left"}, lootTable = "loot_starter_chest" }
}

local function allowed(p: Player): boolean
	local now = os.clock()
	local r = rate[p] or {t = now, n = 0}
	if now - r.t > 1 then r = {t = now, n = 0} end
	r.n += 1
	rate[p] = r
	return r.n <= Constants.MAX_ACTIONS_PER_SECOND
end

local function targetById(id: string): Model?
	for _, x in workspace.AshBorder:GetChildren() do
		if x:IsA("Model") and (x:GetAttribute("MonsterId") == id or x:GetAttribute("NpcId") == id) then
			return x
		end
	end
	return nil
end

local lootTables = DataIndex.byId("loot_tables")
local function rollLoot(player: Player, lootTableId: string)
	local tbl = lootTables[lootTableId]
	if not tbl then return end
	for _, roll in tbl.rolls do
		if math.random() <= roll.chance then
			local qty = roll.quantity or 1
			State.addItem(player, roll.itemId, qty)
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	Save.load(player)
	player.CharacterAdded:Connect(function(char)
		task.wait()
		local h = char:FindFirstChildOfClass("Humanoid")
		if h then
			h.MaxHealth = State.get(player).stats.maxHp
			h.Health = h.MaxHealth
		end
	end)
end)

Players.PlayerRemoving:Connect(function(p)
	Save.save(p)
	rate[p] = nil
	locks[p] = nil
	activeChests[p] = nil
end)

action.OnServerEvent:Connect(function(player, kind: string, payload: any)
	if not allowed(player) or type(kind) ~= "string" then return end
	
	if kind == "attack" and type(payload) == "table" and type(payload.targetId) == "string" and type(payload.style) == "string" and type(payload.itemId) == "string" then
		local target = targetById(payload.targetId)
		if target then
			Combat.damageTarget(player, target, payload.style, payload.itemId)
		end
	elseif kind == "lockStart" and type(payload) == "string" then
		local chest = chests[payload]
		if chest then
			activeChests[player] = payload
			locks[player] = 1
			notice:FireClient(player, "lockStep", chest.sequence[1])
		end
	elseif kind == "lockInput" and (payload == "left" or payload == "right") then
		local step = locks[player]
		local chestId = activeChests[player]
		if not step or not chestId then return end
		local chest = chests[chestId]
		if not chest then return end
		
		if payload == chest.sequence[step] then
			step += 1
			locks[player] = step
			if step > #chest.sequence then
				rollLoot(player, chest.lootTable)
				State.get(player).openedChests[chestId] = true
				locks[player] = nil
				activeChests[player] = nil
				notice:FireClient(player, "toast", "Skrzynia otwarta.")
			else
				notice:FireClient(player, "lockStep", chest.sequence[step])
			end
		else
			local s = State.get(player)
			s.inventory.lockpick = math.max(0, (s.inventory.lockpick or 0) - 1)
			locks[player] = nil
			activeChests[player] = nil
			notice:FireClient(player, "toast", "Wytrych pękł.")
		end
	elseif kind == "dialogueChoose" and type(payload) == "number" then
		Dialogue.choose(player, payload)
	elseif kind == "dialogueClose" then
		Dialogue.close(player)
	elseif kind == "steal" and type(payload) == "table" and type(payload.npcId) == "string" then
		local s = State.get(player)
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
		local pos = hrp and hrp.Position or Vector3.new()
		
		-- Find witnesses
		local witness = nil
		for _, npc in workspace.AshBorder:GetChildren() do
			if npc:IsA("Model") and npc:GetAttribute("NpcId") and npc:GetAttribute("NpcId") ~= payload.npcId then
				local nhrp = npc:FindFirstChild("HumanoidRootPart") :: BasePart?
				if nhrp and (nhrp.Position - pos).Magnitude < 30 then
					witness = npc
					break
				end
			end
		end
		
		local theftSkill = s.flags["skill_theft"] or 0
		if witness and theftSkill < 3 then
			notice:FireClient(player, "toast", "Świadek " .. witness.Name .. " przyłapał cię na kradzieży!")
			local faction = witness:GetAttribute("Faction")
			if type(faction) == "string" then
				s.reputation[faction] = math.max(-100, (s.reputation[faction] or 0) - 10)
			end
		else
			State.addItem(player, "coin_zuzel", 5)
			notice:FireClient(player, "toast", "Kradzież udana! Zdobyłeś 5 monet.")
		end
	elseif kind == "skin" and type(payload) == "table" and type(payload.targetId) == "string" then
		local s = State.get(player)
		local isSkinningLearned = s.flags["skill_skinning"] and s.flags["skill_skinning"] >= 1
		if not isSkinningLearned then
			notice:FireClient(player, "toast", "Musisz najpierw nauczyć się skórowania, by pozyskać trofea!")
		else
			if s.defeated[payload.targetId] then
				notice:FireClient(player, "toast", "Potwór został już oskórowany.")
			else
				s.defeated[payload.targetId] = true
				rollLoot(player, "loot_beast")
				notice:FireClient(player, "toast", "Pozyskano trofea z potwora.")
			end
		end
	elseif kind == "selectSlot" and type(payload) == "number" then
		Save.setSlot(player, payload)
		Save.load(player)
		notice:FireClient(player, "toast", "Wczytano slot zapisu: " .. payload)
	elseif kind == "save" then
		notice:FireClient(player, "toast", Save.save(player) and "Zapisano slot " .. Save.getSlot(player) .. "." or "Błąd zapisu.")
	end
end)

RunService.Heartbeat:Connect(function(dt)
	World.tick(dt)
end)
