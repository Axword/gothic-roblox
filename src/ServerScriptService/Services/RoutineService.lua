--!strict
-- Server-owned schedules with path calculation and a safe recovery path for procedural NPC proxies.
local PathfindingService=game:GetService("PathfindingService")
local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local RoutineService={}
local function watched(position:Vector3):boolean
 for _,player in ipairs(Players:GetPlayers()) do local char=player.Character;local root=char and char:FindFirstChild("HumanoidRootPart") :: BasePart?;if root and (root.Position-position).Magnitude<70 then return true end end
 return false
end
function RoutineService.move(model:Model,destination:Vector3,fallback:Vector3):()
 local root=model:FindFirstChild("HumanoidRootPart") :: BasePart?;if not root then return end
 local start=root.Position
 local ok,path=pcall(function() local p=PathfindingService:CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=true});p:ComputeAsync(start,destination);return p end)
 local points=(ok and path.Status==Enum.PathStatus.Success) and path:GetWaypoints() or {}
 if #points==0 then
  if not watched(start) then root.Position=fallback else TweenService:Create(root,TweenInfo.new(1.2),{Position=fallback}):Play() end
  model:SetAttribute("RoutineRecovery",true);return
 end
 model:SetAttribute("RoutineRecovery",false)
 -- Advance one waypoint per scheduler pass; this avoids stacked Tween writes and keeps ownership server-side.
 local waypoint=points[math.min(2,#points)]
 local distance=(start-waypoint.Position).Magnitude
 TweenService:Create(root,TweenInfo.new(math.clamp(distance/10,.15,1.5),Enum.EasingStyle.Linear),{Position=waypoint.Position}):Play()
end
return RoutineService
