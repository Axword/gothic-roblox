--!strict
local DataStoreService=game:GetService("DataStoreService")
local HttpService=game:GetService("HttpService")
local State=require(script.Parent.StateService)
local store=DataStoreService:GetDataStore("PopiolowePogranicze_Save_v1")
local SaveService={}
local function slotKey(player:Player, slot:number):string return "p_"..player.UserId.."_slot_"..slot end
local function validSlot(slot:any):number return type(slot)=="number" and math.clamp(math.floor(slot),1,3) or 1 end
local function sanitize(raw:any):any
 if type(raw)~="table" or raw.schemaVersion~=1 then return State.default() end
 local default=State.default(); for key,value in pairs(default) do if raw[key]==nil then raw[key]=value end end
 for key,value in pairs(default.stats) do if raw.stats[key]==nil then raw.stats[key]=value end end
 for key,value in pairs(default.skills) do if raw.skills[key]==nil then raw.skills[key]=value end end
 return raw
end
function SaveService.load(player:Player, slot:any?):boolean
 local ok,data=pcall(function() return store:GetAsync(slotKey(player,validSlot(slot))) end)
 State.set(player,sanitize(ok and data or nil)); return ok
end
function SaveService.save(player:Player, slot:any?):boolean
 local snapshot=State.get(player); local key=slotKey(player,validSlot(slot))
 local ok=pcall(function() store:UpdateAsync(key,function() return snapshot end) end); return ok
end
function SaveService.exampleJson(player:Player):string return HttpService:JSONEncode(State.get(player)) end
return SaveService
