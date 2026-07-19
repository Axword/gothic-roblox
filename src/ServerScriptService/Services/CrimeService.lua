--!strict
-- Witnesses are local: a crime is not globally known unless an NPC is near and has line of sight.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local State = require(script.Parent.StateService)
local CrimeService = {}

local function canSee(from: BasePart, target: Vector3): boolean
	if (from.Position - target).Magnitude > 28 then return false end
	local direction = target - from.Position
	local result = workspace:Raycast(from.Position + Vector3.new(0, 2, 0), direction)
	return result == nil or result.Distance >= direction.Magnitude - 2
end

function CrimeService.reportTheft(player: Player, position: Vector3, ownerFaction: string): string
	local witnesses = 0
	local area = workspace:FindFirstChild("AshBorder")
	if area then
		for _, object in ipairs(area:GetChildren()) do
			if object:IsA("Model") and object:GetAttribute("Faction") == ownerFaction then
				local root = object:FindFirstChild("HumanoidRootPart") :: BasePart?
				if root and canSee(root, position) then witnesses += 1 end
			end
		end
	end
	if witnesses == 0 then return "Nikt nie zauważył. To nie znaczy, że było mądre." end
	local state = State.get(player)
	state.reputation[ownerFaction] = math.max(-100, (state.reputation[ownerFaction] or 0) - witnesses * 5)
	if witnesses >= 2 then return "Alarm. Za dużo oczu, za mało rozumu." end
	return "Ostrzeżenie. Oddaj rzecz albo licz się z grzywną."
end
return CrimeService
