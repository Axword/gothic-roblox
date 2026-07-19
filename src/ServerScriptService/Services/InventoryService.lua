--!strict
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local DataIndex=require(ReplicatedStorage.Shared.DataIndex)
local State=require(script.Parent.StateService)
local InventoryService={};local items:{[string]:any}={}
for _,source in ipairs({"items_weapons_swords","items_weapons_bows","items_armors","items_plants","items_potions","items_trophies","items_misc"}) do for id,item in pairs(DataIndex.byId(source)) do items[id]=item end end
function InventoryService.activate(player:Player,itemId:string):(boolean,string)
 local state=State.get(player);local item=items[itemId]
 if not item or (state.inventory[itemId] or 0)<1 then return false,"Nie masz tego przedmiotu." end
 if item.questProtected then return false,"Tego nie wolno wyrzucić ani zużyć." end
 if item.category=="sword" or item.category=="bow" or item.armor then state.equipped=itemId;return true,"Wyposażono: "..item.name end
 if item.category=="potion" then
  local character=player.Character;local hum=character and character:FindFirstChildOfClass("Humanoid")
  if item.effect=="hp+45" and hum then hum.Health=math.min(hum.MaxHealth,hum.Health+45)
  elseif item.effect=="mana+35" then state.stats.mana+=35
  elseif item.effect=="armor+10" then state.flags.stone_skin=true
  elseif item.effect=="night_vision" then state.flags.night_vision=true end
  state.inventory[itemId]-=1;return true,"Użyto: "..item.name
 end
 if item.category=="plant" then state.inventory[itemId]-=1;return true,"Przeżułeś "..item.name..". Smakuje jak błąd." end
 return false,"Nie da się tego teraz użyć."
end
return InventoryService
