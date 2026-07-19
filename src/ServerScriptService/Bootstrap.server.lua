--!strict
local Players=game:GetService("Players");local ReplicatedStorage=game:GetService("ReplicatedStorage");local RunService=game:GetService("RunService")
local Constants=require(ReplicatedStorage.Shared.Constants);local DataIndex=require(ReplicatedStorage.Shared.DataIndex);local State=require(script.Services.StateService);local Save=require(script.Services.SaveService);local Combat=require(script.Services.CombatService);local Trainers=require(script.Services.TrainerService);local Dialogues=require(script.Services.DialogueService);local World=require(script.Services.WorldService)
local chests=DataIndex.byId("world_interactables")
local remotes=Instance.new("Folder");remotes.Name="Remotes";remotes.Parent=ReplicatedStorage
local action=Instance.new("RemoteEvent");action.Name="GameAction";action.Parent=remotes
local notice=Instance.new("RemoteEvent");notice.Name="GameNotice";notice.Parent=remotes
World.build()
local rate:{[Player]:{t:number,n:number}}={};local locks:{[Player]:any}={}
local function allowed(p:Player):boolean local now=os.clock();local r=rate[p] or {t=now,n=0};if now-r.t>1 then r={t=now,n=0} end;r.n+=1;rate[p]=r;return r.n<=Constants.MAX_ACTIONS_PER_SECOND end
local function targetById(id:string):Model? for _,x in ipairs(workspace.AshBorder:GetChildren()) do if x:IsA("Model") and (x:GetAttribute("MonsterId")==id or x:GetAttribute("NpcId")==id) then return x end end;return nil end
local function sync(player:Player):() notice:FireClient(player,"state",State.get(player)) end
Players.PlayerAdded:Connect(function(player) Save.load(player);player.CharacterAdded:Connect(function(char) task.wait();local h=char:FindFirstChildOfClass("Humanoid");if h then h.MaxHealth=State.get(player).stats.maxHp;h.Health=h.MaxHealth end;sync(player) end) end)
Players.PlayerRemoving:Connect(function(p) Save.save(p);rate[p]=nil;locks[p]=nil end)
action.OnServerEvent:Connect(function(player,kind:string,payload:any)
 if not allowed(player) or type(kind)~="string" then return end
 if kind=="attack" and type(payload)=="table" and type(payload.targetId)=="string" and type(payload.style)=="string" and type(payload.itemId)=="string" then local target=targetById(payload.targetId);if target then Combat.damageTarget(player,target,payload.style,payload.itemId) end
 elseif kind=="skin" and type(payload)=="string" then local target=targetById(payload);if target then local _,message=Combat.skinTarget(player,target);notice:FireClient(player,"toast",message) end
 elseif kind=="lockStart" and type(payload)=="string" and chests[payload] and chests[payload].lockDifficulty then local chest=chests[payload];local s=State.get(player);if s.openedChests[payload] then notice:FireClient(player,"toast","Skrzynia jest pusta.") elseif (s.skills.lockpick or 0)<chest.lockDifficulty then notice:FireClient(player,"toast","Nie rozumiesz tego zamka.") else locks[player]={id=payload,step=1};notice:FireClient(player,"lockStep",chest.sequence[1]) end
 elseif kind=="lockInput" and (payload=="left" or payload=="right") then local lock=locks[player];if not lock then return end;local chest=chests[lock.id];local seq=chest.sequence;if payload==seq[lock.step] then lock.step+=1;if lock.step>#seq then for _,roll in ipairs(DataIndex.byId("loot_tables")[chest.lootTableId].rolls) do if roll.chance>=1 then State.addItem(player,roll.itemId,roll.quantity or 1) end end;State.get(player).openedChests[lock.id]=true;locks[player]=nil;notice:FireClient(player,"toast","Skrzynia otwarta.") else notice:FireClient(player,"lockStep",seq[lock.step]) end else local s=State.get(player);s.inventory.lockpick=math.max(0,(s.inventory.lockpick or 0)-1);locks[player]=nil;notice:FireClient(player,"toast","Wytrych pękł.") end
 elseif kind=="dialogueChoice" and type(payload)=="number" then local result=Dialogues.choose(player,math.floor(payload));if result and string.find(result,"epilogue:") then notice:FireClient(player,"epilogue",result) elseif result and string.find(result,"learned:") then notice:FireClient(player,"toast","Nauczyłeś się: "..string.gsub(result,"learned:","")) end
 elseif kind=="dialogueClose" then Dialogues.close(player)
 elseif kind=="train" and type(payload)=="table" and type(payload.trainerId)=="string" and type(payload.skill)=="string" then local ok,message=Trainers.train(player,payload.trainerId,payload.skill);notice:FireClient(player,"toast",message)
 elseif kind=="save" then notice:FireClient(player,"toast",Save.save(player) and "Zapisano." or "Błąd zapisu.")
 elseif kind=="state" then -- explicitly requested snapshot; all data remains server-owned
 end
 sync(player)
end)
RunService.Heartbeat:Connect(function(dt) World.tick(dt) end)
