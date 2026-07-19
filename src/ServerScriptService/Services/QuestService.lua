--!strict
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local DataIndex=require(ReplicatedStorage.Shared.DataIndex)
local State=require(script.Parent.StateService)
local QuestService={}; local quests:{[string]:any}={}
for _, name in {"quests_main","quests_old_faction","quests_new_faction","quests_side"} do for id,q in pairs(DataIndex.byId(name)) do quests[id]=q end end
function QuestService.start(player:Player,id:string):boolean
 local s=State.get(player); if not quests[id] or s.quests[id] then return false end; s.quests[id]="active"; return true
end
function QuestService.complete(player:Player,id:string):boolean
 local s=State.get(player);local q=quests[id];if not q or s.quests[id]~="active" then return false end
 s.quests[id]="complete"; State.addXp(player,(q.rewards and q.rewards.xp) or 0); if q.rewards and q.rewards.coin_zuzel then State.addItem(player,"coin_zuzel",q.rewards.coin_zuzel) end; return true
end
function QuestService.chooseFaction(player:Player,faction:string):boolean
 local s=State.get(player);if s.faction or (faction~="kordon" and faction~="wolnica") then return false end
 local count=0;for id,status in pairs(s.quests) do if status=="complete" and string.find(id,"quest_"..(faction=="kordon" and "old" or "new")) then count+=1 end end
 if count<2 then return false end;s.faction=faction;s.flags["faction_locked"]=true;QuestService.complete(player,"quest_main_right");return true
end
return QuestService
