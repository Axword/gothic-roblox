--!strict
local Lighting=game:GetService("Lighting");local ReplicatedStorage=game:GetService("ReplicatedStorage")
local DataIndex=require(ReplicatedStorage.Shared.DataIndex)
local State=require(script.Parent.StateService);local Quest=require(script.Parent.QuestService)
local World={}; local worldTime=8
local function part(parent:Instance,name:string,pos:Vector3,size:Vector3,color:Color3):Part
 local p=Instance.new("Part");p.Name=name;p.Anchored=true;p.Size=size;p.Position=pos;p.Color=color;p.Material=Enum.Material.Slate;p.Parent=parent;return p
end
local function prompt(parent:Instance,action:string,object:string,callback:(Player)->()):()
 local p=Instance.new("ProximityPrompt");p.ActionText=action;p.ObjectText=object;p.MaxActivationDistance=12;p.RequiresLineOfSight=true;p.Parent=parent;p.Triggered:Connect(callback)
end
function World.build()
 local folder=Instance.new("Folder");folder.Name="AshBorder";folder.Parent=workspace
 local ground=part(folder,"Ground",Vector3.new(120,-4,0),Vector3.new(700,8,500),Color3.fromRGB(48,45,40));ground.Material=Enum.Material.Ground
 for _,loc in DataIndex.records("world_locations") do
  local pos=Vector3.new(loc.position[1],4,loc.position[3]);local landmark=part(folder,loc.id,pos,Vector3.new(38,8,30),loc.kind=="settlement" and Color3.fromRGB(74,61,47) or Color3.fromRGB(52,68,48));landmark:SetAttribute("LocationId",loc.id)
  if loc.kind=="settlement" then for j=1,4 do part(folder,"hut",pos+Vector3.new(j*9,9,12),Vector3.new(8,14,8),Color3.fromRGB(63,43,31)) end end
 end
 -- three vertical-slice NPCs are interactive; remaining data supports expansion and safe schedule state.
 local npcData=DataIndex.byId("npcs")
 for _,id in {"npc_old_01","npc_new_01","npc_neutral_02"} do
  local n=npcData[id];local model=Instance.new("Model");model.Name=n.name;model:SetAttribute("NpcId",id);model:SetAttribute("Faction",n.faction);model.Parent=folder
  local base= id=="npc_old_01" and Vector3.new(0,6,0) or (id=="npc_new_01" and Vector3.new(300,6,0) or Vector3.new(145,6,-35));local body=part(model,"HumanoidRootPart",base,Vector3.new(3,6,3),n.faction=="kordon" and Color3.fromRGB(80,72,58) or Color3.fromRGB(72,52,48));body.Anchored=true
  local h=Instance.new("Humanoid");h.MaxHealth=n.stats.hp;h.Health=n.stats.hp;h.Parent=model;prompt(body,"Rozmawiaj",n.name,function(player) if id=="npc_old_01" then Quest.start(player,"quest_main_arrival") end; ReplicatedStorage.Remotes.GameNotice:FireClient(player,"dialogue",n.dialogueId) end)
 end
 local chest=part(folder,"LockedChest",Vector3.new(62,3,28),Vector3.new(5,5,4),Color3.fromRGB(86,56,25));chest:SetAttribute("ChestId","chest_tutorial");prompt(chest,"Otwórz (zamek I)","Skrzynia poborcy",function(player) ReplicatedStorage.Remotes.GameNotice:FireClient(player,"lock","chest_tutorial") end)
 local monster=Instance.new("Model");monster.Name="Żarłacz trzcin";monster:SetAttribute("MonsterId","monster_zarlacz");monster.Parent=folder;local mb=part(monster,"HumanoidRootPart",Vector3.new(92,5,48),Vector3.new(5,5,7),Color3.fromRGB(49,76,55));mb.Anchored=true;local mh=Instance.new("Humanoid");mh.MaxHealth=42;mh.Health=42;mh.Parent=monster
 Lighting.ClockTime=worldTime;Lighting.Brightness=1.4;Lighting.OutdoorAmbient=Color3.fromRGB(74,69,72)
end
function World.tick(dt:number) worldTime=(worldTime+dt*0.05)%24;Lighting.ClockTime=worldTime end
return World
