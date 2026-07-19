--!strict
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Formulae=require(ReplicatedStorage.Shared.Formulae)
local DataIndex=require(ReplicatedStorage.Shared.DataIndex)
local State=require(script.Parent.StateService)
local Quest=require(script.Parent.QuestService)
local Combat={};local swords=DataIndex.byId("items_weapons_swords");local bows=DataIndex.byId("items_weapons_bows");local spells=DataIndex.byId("spells")
local lastAttack:{[Player]:number}={};local combo:{[Player]:number}={}
local function root(model:Model):BasePart? return model:FindFirstChild("HumanoidRootPart") :: BasePart? end
function Combat.setBlock(player:Player,enabled:boolean):boolean
 local char=player.Character;local state=State.get(player);if not char or state.stats.stamina<=0 then return false end
 char:SetAttribute("Blocking",enabled);return true
end
function Combat.dodge(player:Player):boolean
 local char=player.Character;local hrp=char and root(char);local state=State.get(player)
 if not hrp or state.stats.stamina<25 then return false end
 state.stats.stamina-=25;char:SetAttribute("Dodging",true);hrp.CFrame+=hrp.CFrame.LookVector*9;task.delay(.35,function() if char then char:SetAttribute("Dodging",false) end end);return true
end
function Combat.damageTarget(player:Player,target:Model,style:string,id:string):boolean
 local now=os.clock();local elapsed=now-(lastAttack[player] or 0);if elapsed<.22 then return false end;lastAttack[player]=now
 local char=player.Character;local hrp=char and root(char);local tr=root(target);local hum=target:FindFirstChildOfClass("Humanoid")
 local baseStyle=style=="sword_heavy" and "sword" or style
 if not hrp or not tr or not hum or hum.Health<=0 or (hrp.Position-tr.Position).Magnitude>(baseStyle=="sword" and 10 or 80) then return false end
 if target:GetAttribute("Faction")==State.get(player).faction then return false end
 local s=State.get(player);local damage=0
 if baseStyle=="sword" then
  local weapon=swords[id];if not weapon or (s.inventory[id] or 0)<1 then return false end
  combo[player]=elapsed<.85 and math.min((combo[player] or 0)+1,3) or 1
  local heavy=style=="sword_heavy";local stamina=heavy and 30 or 12;if s.stats.stamina<stamina then return false end;s.stats.stamina-=stamina
  damage=Formulae.swordDamage(weapon.damage,s.stats.strength)*(heavy and 1.75 or (1+(combo[player] or 1)*.08))
 elseif baseStyle=="bow" then local weapon=bows[id];if not weapon or (s.inventory.arrow_iron or 0)<1 then return false end;s.inventory.arrow_iron-=1;damage=Formulae.bowDamage(weapon.damage,s.stats.dexterity)
 elseif baseStyle=="spell" then local spell=spells[id];local requiredRank=(id=="spell_frost" and 2 or 1);if not spell or (s.skills.spell or 0)<requiredRank or s.stats.mana<spell.manaCost then return false end;s.stats.mana-=spell.manaCost;damage=spell.damage
 else return false end
 hum:TakeDamage(damage);if hum.Health<=0 then State.addXp(player,25);local monsterId=target:GetAttribute("MonsterId");if type(monsterId)=="string" then Quest.objective(player,monsterId) end end;return true
end
function Combat.skinTarget(player:Player,target:Model): (boolean,string)
 local char=player.Character;local hrp=char and root(char);local tr=root(target);local hum=target:FindFirstChildOfClass("Humanoid");local monsterId=target:GetAttribute("MonsterId")
 if not hrp or not tr or not hum or type(monsterId)~="string" or hum.Health>0 or (hrp.Position-tr.Position).Magnitude>10 then return false,"Nie masz czego skórować." end
 local s=State.get(player);if (s.skills.skinning or 0)<1 then return false,"Wiesz tylko, jak narobić bałaganu. Znajdź łowcę." end
 local spawnId = target:GetAttribute("SpawnId");if type(spawnId)~="string" then return false,"Nie da się oznaczyć tej zdobyczy." end
 if s.defeated[spawnId] then return false,"Zostały już tylko muchy." end;s.defeated[spawnId]=true;State.addItem(player,"trophy_hide",1);State.addItem(player,"trophy_fang",1);return true,"Pozyskałeś skórę i kieł."
end
function Combat.regenerate(player:Player,dt:number):() local s=State.get(player);s.stats.stamina=math.min(s.stats.maxStamina,s.stats.stamina+dt*18) end
return Combat
