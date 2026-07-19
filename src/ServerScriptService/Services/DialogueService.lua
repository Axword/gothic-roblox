--!strict
-- Dialogue graph state stays on the server. JSON nodes are text/conditions/actions; clients only choose a numbered response.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataIndex = require(ReplicatedStorage.Shared.DataIndex)
local Quest = require(script.Parent.QuestService)
local State = require(script.Parent.StateService)
local DialogueService = {}
local dialogues: {[string]: any} = {}
local active: {[Player]: {dialogue: any, nodeId: string}} = {}
for _, source in ipairs({"dialogues_old", "dialogues_new", "dialogues_neutral"}) do
	for id, dialogue in pairs(DataIndex.byId(source)) do dialogues[id] = dialogue end
end
local function node(dialogue: any, id: string): any?
	for _, value in ipairs(dialogue.nodes) do if value.id == id then return value end end
	return nil
end
local function send(player: Player, dialogue: any, nodeId: string): ()
	local value = node(dialogue, nodeId)
	if not value then return end
	active[player] = {dialogue = dialogue, nodeId = nodeId}
	ReplicatedStorage.Remotes.GameNotice:FireClient(player, "dialogueNode", {text = value.text, responses = value.responses})
end
function DialogueService.open(player: Player, dialogueId: string): ()
	local dialogue = dialogues[dialogueId]
	if dialogue then send(player, dialogue, "start") end
end
local function doAction(player: Player, action: string?): string?
	if not action or action == "close" then active[player] = nil; return "close" end
	local verb, id = string.match(action, "^([^:]+):(.+)$")
	if verb == "startQuest" then
		Quest.start(player, id)
		if string.find(id, "quest_old_") or string.find(id, "quest_new_") then
			Quest.complete(player, "quest_main_arrival"); Quest.start(player, "quest_main_right")
		end
	elseif verb == "completeQuest" then Quest.complete(player, id)
	elseif verb == "chooseFaction" then
		if Quest.chooseFaction(player, id) then return "epilogue:" .. id end
	elseif verb == "learnSpell" then
		local state = State.get(player)
		if state.quests.quest_side_09 == "complete" then
			state.skills.spell = math.max(state.skills.spell or 0, id == "spell_frost" and 2 or 1)
			return "learned:" .. id
		end
	elseif verb == "reputation" then
		local faction, amount = string.match(id, "^(%a+),(-?%d+)$")
		if faction and amount then local s = State.get(player); s.reputation[faction] = (s.reputation[faction] or 0) + tonumber(amount) end
	end
	return nil
end
function DialogueService.choose(player: Player, index: number): string?
	local session = active[player]
	if not session or index < 1 or index > 8 then return nil end
	local value = node(session.dialogue, session.nodeId)
	local response = value and value.responses[index]
	if not response then return nil end
	local result = doAction(player, response.action)
	if result == "close" or result and string.find(result, "epilogue:") then active[player] = nil; return result end
	if response.next then send(player, session.dialogue, response.next) else active[player] = nil end
	return result
end
function DialogueService.close(player: Player): () active[player] = nil end
return DialogueService
