--!strict
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Formulae=require(ReplicatedStorage.Shared.Formulae)
local DataIndex=require(ReplicatedStorage.Shared.DataIndex)
local State=require(script.Parent.StateService)
local Combat={};local swords=DataIndex.byId("items_weapons_swords");local bows=DataIndex.byId("items_weapons_bows");local spells=DataIndex.byId("spells")
local function root(model:Model):BasePart? return model:FindFirstChild("HumanoidRootPart") :: BasePart? end
function Combat.damageTarget(player:Player,target:Model,style:string,id:string):boolean
 local char=player.Character;local hrp=char and root(char);local tr=root(target);local hum=target:FindFirstChildOfClass("Humanoid")
 if not hrp or not tr or not hum or hum.Health<=0 or (hrp.Position-tr.Position).Magnitude>(style=="sword" and 10 or 80) then return false end
 if target:GetAttribute("Faction")==State.get(player).faction then return false end
 local s=State.get(player);local damage=0
 if style=="sword" then local weapon=swords[id];if not weapon or s.inventory[id]~=1 then return false end;damage=Formulae.swordDamage(weapon.damage,s.stats.strength)
 elseif style=="bow" then local weapon=bows[id];if not weapon or (s.inventory.arrow_iron or 0)<1 then return false end;s.inventory.arrow_iron-=1;damage=Formulae.bowDamage(weapon.damage,s.stats.dexterity)
 elseif style=="spell" then local spell=spells[id];if not spell or s.stats.mana<spell.manaCost then return false end;s.stats.mana-=spell.manaCost;damage=spell.damage
 else return false end
 hum:TakeDamage(damage);if hum.Health<=0 then State.addXp(player,25) end;return true
end
return Combat
