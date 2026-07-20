--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Formulae = require(ReplicatedStorage.Shared.Formulae)
export type PlayerState = {schemaVersion:number, stats:{level:number,xp:number,learningPoints:number,strength:number,dexterity:number,mana:number,maxHp:number,vitality:number}, inventory:{[string]:number}, equipped:string?, quests:{[string]:string}, flags:{[string]:boolean}, reputation:{[string]:number}, openedChests:{[string]:boolean}, defeated:{[string]:boolean}, faction:string?, worldTime:number}
local StateService = {}; local states:{[Player]:PlayerState} = {}
function StateService.default(): PlayerState
	return {schemaVersion=1, stats={level=1,xp=0,learningPoints=0,strength=5,dexterity=5,mana=20,maxHp=Formulae.maxHp(1,0),vitality=0},inventory={sword_01=1,lockpick=3,coin_zuzel=25},equipped="sword_01",quests={},flags={},reputation={kordon=0,wolnica=0},openedChests={},defeated={},worldTime=8}
end
function StateService.get(player:Player):PlayerState return states[player] or StateService.default() end
function StateService.set(player:Player, state:PlayerState) states[player]=state end
function StateService.remove(player:Player) states[player]=nil end
function StateService.addItem(player:Player,id:string,count:number) local s=StateService.get(player); s.inventory[id]=(s.inventory[id] or 0)+count end
function StateService.addXp(player:Player, amount:number)
 local s=StateService.get(player); s.stats.xp+=amount; local old=s.stats.level; local new=Formulae.levelForXp(s.stats.xp)
 if new>old then
  s.stats.learningPoints+=(new-old)*10;s.stats.level=new;s.stats.maxHp=Formulae.maxHp(new,s.stats.vitality)
  pcall(function()
   local char=player.Character; if char then local h=char:FindFirstChildOfClass("Humanoid"); if h then h.MaxHealth=s.stats.maxHp; h.Health=math.min(h.Health + (new-old)*12, s.stats.maxHp) end end
  end)
 end
end
Players.PlayerRemoving:Connect(StateService.remove)
return StateService
