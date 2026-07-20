--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataIndex = require(ReplicatedStorage.Shared.DataIndex)
local State = require(script.Parent.StateService)
local Quest = require(script.Parent.QuestService)

local DialogueService = {}
local dialogues = {}
local activeDialogues: {[Player]: {npcId: string, dialogueId: string, nodeId: string}} = {}

-- Load dialogues
for _, name in {"dialogues_neutral", "dialogues_old", "dialogues_new"} do
	for id, d in DataIndex.byId(name) do
		dialogues[id] = d
	end
end

-- Trainers mapping
local trainers = DataIndex.byId("trainers")
local trainersByNpc = {}
for _, t in trainers do
	trainersByNpc[t.npcId] = t
end

-- Quests mapping for hand-in
local questGivers = {
	quest_main_arrival = "npc_old_01",
	quest_main_right = "npc_old_01",
	quest_old_01 = "npc_old_01",
	quest_old_02 = "npc_old_02",
	quest_old_03 = "npc_old_01",
	quest_old_04 = "npc_old_02",
	quest_old_05 = "npc_old_01",
	quest_new_01 = "npc_new_01",
	quest_new_02 = "npc_new_02",
	quest_new_03 = "npc_new_01",
	quest_new_04 = "npc_new_02",
	quest_new_05 = "npc_new_01",
	quest_side_01 = "npc_neutral_02",
	quest_side_02 = "npc_neutral_02",
	quest_side_03 = "npc_neutral_02",
	quest_side_04 = "npc_neutral_02",
	quest_side_05 = "npc_neutral_02",
	quest_side_06 = "npc_neutral_02",
	quest_side_07 = "npc_neutral_02",
	quest_side_08 = "npc_neutral_02",
	quest_side_09 = "npc_neutral_02",
	quest_side_10 = "npc_neutral_02",
}

function DialogueService.get(player: Player)
	return activeDialogues[player]
end

-- Helper to clone a table
local function cloneTable(t: any): any
	if type(t) ~= "table" then return t end
	local out = {}
	for k, v in t do out[k] = cloneTable(v) end
	return out
end

function DialogueService.start(player: Player, npcId: string, dialogueId: string)
	activeDialogues[player] = {
		npcId = npcId,
		dialogueId = dialogueId,
		nodeId = "start"
	}
	DialogueService.sendUpdate(player)
end

function DialogueService.sendUpdate(player: Player)
	local active = activeDialogues[player]
	if not active then return end
	local dlg = dialogues[active.dialogueId]
	if not dlg then return end
	
	local node
	for _, n in dlg.nodes do
		if n.id == active.nodeId then
			node = cloneTable(n)
			break
		end
	end
	if not node then return end
	
	-- Inject dynamic responses
	local s = State.get(player)
	
	-- 1. Faction Choice dynamic response
	if active.nodeId == "start" then
		if (active.npcId == "npc_old_01" and not s.faction) or (active.npcId == "npc_new_01" and not s.faction) then
			-- Count completed faction quests
			local faction = active.npcId == "npc_old_01" and "kordon" or "wolnica"
			local prefix = faction == "kordon" and "quest_old_" or "quest_new_"
			local completedCount = 0
			for qId, qStat in s.quests do
				if qStat == "complete" and string.find(qId, prefix) then
					completedCount += 1
				end
			end
			if completedCount >= 2 and s.quests["quest_main_right"] == "active" then
				table.insert(node.responses, {
					text = "Chcę dołączyć do waszego obozu (" .. (faction == "kordon" and "Kordon Żużla" or "Wolnica") .. ")",
					action = "chooseFaction:" .. faction
				})
			end
		end
		
		-- 2. Quest Hand-In dynamic response
		for qId, qStat in s.quests do
			if qStat == "active" and questGivers[qId] == active.npcId then
				table.insert(node.responses, {
					text = "Zgłoś wykonanie zadania: " .. qId,
					action = "completeQuest:" .. qId
				})
			end
		end
		
		-- 3. Training dynamic response
		local trainer = trainersByNpc[active.npcId]
		if trainer then
			for _, skill in trainer.skills do
				local curVal = s.stats[skill] or s.flags["skill_" .. skill] or 0
				local limit = trainer.limits[skill] or 1
				if curVal < limit then
					local lpCost = 10
					local coinCost = 10
					table.insert(node.responses, {
						text = "Trenuj " .. skill .. " [Poziom " .. curVal .. " -> " .. (curVal + 1) .. "] (Koszt: " .. lpCost .. " PN, " .. coinCost .. " monet)",
						action = "train:" .. skill .. ":" .. limit
					})
				end
			end
		end
	end
	
	ReplicatedStorage.Remotes.GameNotice:FireClient(player, "dialogueUpdate", node)
end

function DialogueService.choose(player: Player, index: number)
	local active = activeDialogues[player]
	if not active then return end
	local dlg = dialogues[active.dialogueId]
	if not dlg then return end
	
	local node
	for _, n in dlg.nodes do
		if n.id == active.nodeId then
			node = n
			break
		end
	end
	if not node then return end
	
	-- We must construct the dynamic responses list the same way to match index
	local responses = cloneTable(node.responses)
	local s = State.get(player)
	
	if active.nodeId == "start" then
		if (active.npcId == "npc_old_01" and not s.faction) or (active.npcId == "npc_new_01" and not s.faction) then
			local faction = active.npcId == "npc_old_01" and "kordon" or "wolnica"
			local prefix = faction == "kordon" and "quest_old_" or "quest_new_"
			local completedCount = 0
			for qId, qStat in s.quests do
				if qStat == "complete" and string.find(qId, prefix) then
					completedCount += 1
				end
			end
			if completedCount >= 2 and s.quests["quest_main_right"] == "active" then
				table.insert(responses, {
					text = "Chcę dołączyć do waszego obozu (" .. (faction == "kordon" and "Kordon" or "Wolnica") .. ")",
					action = "chooseFaction:" .. faction
				})
			end
		end
		
		for qId, qStat in s.quests do
			if qStat == "active" and questGivers[qId] == active.npcId then
				table.insert(responses, {
					text = "Zgłoś wykonanie zadania: " .. qId,
					action = "completeQuest:" .. qId
				})
			end
		end
		
		local trainer = trainersByNpc[active.npcId]
		if trainer then
			for _, skill in trainer.skills do
				local curVal = s.stats[skill] or s.flags["skill_" .. skill] or 0
				local limit = trainer.limits[skill] or 1
				if curVal < limit then
					table.insert(responses, {
						text = "Trenuj " .. skill,
						action = "train:" .. skill .. ":" .. limit
					})
				end
			end
		end
	end
	
	local resp = responses[index]
	if not resp then return end
	
	-- Process Action
	local actionStr = resp.action
	if actionStr then
		if actionStr == "close" then
			DialogueService.close(player)
			return
		elseif string.find(actionStr, "startQuest:") then
			local qId = string.sub(actionStr, 12)
			Quest.start(player, qId)
			ReplicatedStorage.Remotes.GameNotice:FireClient(player, "toast", "Rozpoczęto zadanie.")
		elseif string.find(actionStr, "completeQuest:") then
			local qId = string.sub(actionStr, 15)
			if Quest.complete(player, qId) then
				ReplicatedStorage.Remotes.GameNotice:FireClient(player, "toast", "Ukończono zadanie.")
			else
				ReplicatedStorage.Remotes.GameNotice:FireClient(player, "toast", "Nie udało się ukończyć zadania.")
			end
		elseif string.find(actionStr, "chooseFaction:") then
			local faction = string.sub(actionStr, 15)
			if Quest.chooseFaction(player, faction) then
				ReplicatedStorage.Remotes.GameNotice:FireClient(player, "toast", "Dołączyłeś do frakcji: " .. faction:upper())
			else
				ReplicatedStorage.Remotes.GameNotice:FireClient(player, "toast", "Nie spełniasz wymagań.")
			end
		elseif string.find(actionStr, "train:") then
			local parts = string.split(actionStr, ":")
			local skill = parts[2]
			local limit = tonumber(parts[3]) or 1
			
			local curVal = s.stats[skill] or s.flags["skill_" .. skill] or 0
			if curVal < limit then
				local lpCost = 10
				local coinCost = 10
				if s.stats.learningPoints >= lpCost and (s.inventory.coin_zuzel or 0) >= coinCost then
					s.stats.learningPoints -= lpCost
					s.inventory.coin_zuzel -= coinCost
					if s.stats[skill] ~= nil then
						if skill == "mana" then
							s.stats.mana += 10
						else
							s.stats[skill] += 5
						end
					else
						s.flags["skill_" .. skill] = curVal + 1
					end
					ReplicatedStorage.Remotes.GameNotice:FireClient(player, "toast", "Trening pomyślny: " .. skill)
				else
					ReplicatedStorage.Remotes.GameNotice:FireClient(player, "toast", "Brak punktów nauki (PN) lub monet.")
				end
			end
		end
	end
	
	-- Process Next Node
	if resp.next then
		active.nodeId = resp.next
		DialogueService.sendUpdate(player)
	else
		-- If there's no next node, close dialogue
		DialogueService.close(player)
	end
end

function DialogueService.close(player: Player)
	activeDialogues[player] = nil
	ReplicatedStorage.Remotes.GameNotice:FireClient(player, "dialogueClose")
end

return DialogueService
