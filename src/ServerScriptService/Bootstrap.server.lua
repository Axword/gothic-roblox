--!strict
local Players=game:GetService("Players");local ReplicatedStorage=game:GetService("ReplicatedStorage");local RunService=game:GetService("RunService")
local Constants=require(ReplicatedStorage.Shared.Constants);local State=require(script.Services.StateService);local Save=require(script.Services.SaveService);local Combat=require(script.Services.CombatService);local World=require(script.Services.WorldService)
local remotes=Instance.new("Folder");remotes.Name="Remotes";remotes.Parent=ReplicatedStorage
local action=Instance.new("RemoteEvent");action.Name="GameAction";action.Parent=remotes
local notice=Instance.new("RemoteEvent");notice.Name="GameNotice";notice.Parent=remotes
World.build()
local rate:{[Player]:{t:number,n:number}}={};local locks:{[Player]:number}={}
local function allowed(p:Player):boolean local now=os.clock();local r=rate[p] or {t=now,n=0};if now-r.t>1 then r={t=now,n=0} end;r.n+=1;rate[p]=r;return r.n<=Constants.MAX_ACTIONS_PER_SECOND end
local function targetById(id:string):Model? for _,x in workspace.AshBorder:GetChildren() do if x:IsA("Model") and (x:GetAttribute("MonsterId")==id or x:GetAttribute("NpcId")==id) then return x end end;return nil end
Players.PlayerAdded:Connect(function(player) Save.load(player);player.CharacterAdded:Connect(function(char) task.wait();local h=char:FindFirstChildOfClass("Humanoid");if h then h.MaxHealth=State.get(player).stats.maxHp;h.Health=h.MaxHealth end end) end)
Players.PlayerRemoving:Connect(function(p) Save.save(p);rate[p]=nil;locks[p]=nil end)
action.OnServerEvent:Connect(function(player,kind:string,payload:any)
 if not allowed(player) or type(kind)~="string" then return end
 if kind=="attack" and type(payload)=="table" and type(payload.targetId)=="string" and type(payload.style)=="string" and type(payload.itemId)=="string" then local target=targetById(payload.targetId);if target then Combat.damageTarget(player,target,payload.style,payload.itemId) end
 elseif kind=="lockStart" and payload=="chest_tutorial" then locks[player]=1;notice:FireClient(player,"lockStep","left")
 elseif kind=="lockInput" and (payload=="left" or payload=="right") then local step=locks[player];local seq={"left","right","left"};if not step then return end;if payload==seq[step] then step+=1;locks[player]=step;if step>3 then State.addItem(player,"sword_01",1);State.addItem(player,"potion_01",1);State.get(player).openedChests.chest_tutorial=true;locks[player]=nil;notice:FireClient(player,"toast","Skrzynia otwarta.") else notice:FireClient(player,"lockStep",seq[step]) end else local s=State.get(player);s.inventory.lockpick=math.max(0,(s.inventory.lockpick or 0)-1);locks[player]=nil;notice:FireClient(player,"toast","Wytrych pękł.") end
 elseif kind=="save" then notice:FireClient(player,"toast",Save.save(player) and "Zapisano." or "Błąd zapisu.")
 end
end)
RunService.Heartbeat:Connect(function(dt) World.tick(dt) end)
