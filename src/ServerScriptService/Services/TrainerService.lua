--!strict
-- Training is paid and authoritative; the client supplies an intention, never a new stat value.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataIndex = require(ReplicatedStorage.Shared.DataIndex)
local State = require(script.Parent.StateService)
local TrainerService = {}
local trainers = DataIndex.byId("trainers")

local function nearTrainer(player: Player, npcId: string): boolean
	local char = player.Character
	local playerRoot = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	local area = workspace:FindFirstChild("AshBorder")
	if not playerRoot or not area then return false end
	for _, object in ipairs(area:GetChildren()) do
		if object:IsA("Model") and object:GetAttribute("NpcId") == npcId then
			local root = object:FindFirstChild("HumanoidRootPart") :: BasePart?
			return root ~= nil and (root.Position - playerRoot.Position).Magnitude <= 14
		end
	end
	return false
end

function TrainerService.train(player: Player, trainerId: string, skill: string): (boolean, string)
	local trainer = trainers[trainerId]
	if not trainer then return false, "Nie ma takiego nauczyciela." end
	if not table.find(trainer.skills, skill) or not nearTrainer(player, trainer.npcId) then return false, "Nauczyciel nie ma cię teraz na oku." end
	local state = State.get(player)
	local current = 0
	if skill == "strength" then current = state.stats.strength elseif skill == "mana" then current = state.stats.mana else current = state.skills[skill] or 0 end
	local limit = trainer.limits[skill]
	if type(limit) ~= "number" or current >= limit then return false, "Tego już cię nie nauczy." end
	local lp = trainer.learningPointCost or 1
	local coins = trainer.currencyCost or 0
	if state.stats.learningPoints < lp or (state.inventory.coin_zuzel or 0) < coins then return false, "Brakuje ci punktów nauki albo żużlu." end
	state.stats.learningPoints -= lp
	state.inventory.coin_zuzel -= coins
	if skill == "strength" then
		state.stats.strength = current + 1
	elseif skill == "mana" then
		state.stats.mana = current + 1
	else
		state.skills[skill] = current + 1
	end
	return true, "Nauka boli. To znaczy, że weszła."
end

function TrainerService.forNpc(npcId: string): any?
	for _, trainer in pairs(trainers) do if trainer.npcId == npcId then return trainer end end
	return nil
end
return TrainerService
