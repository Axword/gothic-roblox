--!strict
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local State = require(script.Parent.StateService)
local store = DataStoreService:GetDataStore("PopiolowePogranicze_Save_v1")

local SaveService = {}
local activeSlots: {[Player]: number} = {}

function SaveService.getSlot(player: Player): number
	return activeSlots[player] or 1
end

function SaveService.setSlot(player: Player, slot: number)
	activeSlots[player] = slot
end

local function sanitize(raw: any): any
	if type(raw) ~= "table" or raw.schemaVersion ~= 1 then return State.default() end
	local default = State.default()
	for key, value in default do
		if raw[key] == nil then
			raw[key] = value
		end
	end
	return raw
end

function SaveService.load(player: Player): boolean
	local slot = SaveService.getSlot(player)
	local ok, data = pcall(function() return store:GetAsync("p_" .. player.UserId .. "_slot_" .. slot) end)
	local state = sanitize(ok and data or nil)
	State.set(player, state)
	
	-- Synchronize character position and lighting
	task.spawn(function()
		local char = player.Character or player.CharacterAdded:Wait()
		local hrp = char:WaitForChild("HumanoidRootPart", 5) :: BasePart?
		if hrp and state.position then
			hrp.Position = Vector3.new(state.position[1], state.position[2], state.position[3])
		end
	end)
	
	if state.worldTime then
		Lighting.ClockTime = state.worldTime
	end
	return ok
end

function SaveService.save(player: Player): boolean
	local snapshot = State.get(player)
	
	-- Capture player position and world time
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if hrp then
		snapshot.position = { hrp.Position.X, hrp.Position.Y, hrp.Position.Z }
	end
	snapshot.worldTime = Lighting.ClockTime
	
	local slot = SaveService.getSlot(player)
	local ok = pcall(function()
		store:UpdateAsync("p_" .. player.UserId .. "_slot_" .. slot, function() return snapshot end)
	end)
	return ok
end

function SaveService.exampleJson(player: Player): string
	return HttpService:JSONEncode(State.get(player))
end

return SaveService
