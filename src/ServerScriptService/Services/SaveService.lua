--!strict
local DataStoreService=game:GetService("DataStoreService")
local HttpService=game:GetService("HttpService")
local State=require(script.Parent.StateService)
local store=DataStoreService:GetDataStore("PopiolowePogranicze_Save_v1")
local SaveService={}
local function sanitize(raw:any):any
 if type(raw)~="table" or raw.schemaVersion~=1 then return State.default() end
 local default=State.default(); for key,value in pairs(default) do if raw[key]==nil then raw[key]=value end end; return raw
end
function SaveService.load(player:Player):boolean
 local ok,data=pcall(function() return store:GetAsync("p_"..player.UserId) end)
 State.set(player,sanitize(ok and data or nil)); return ok
end
function SaveService.save(player:Player):boolean
 local snapshot=State.get(player); local ok=pcall(function() store:UpdateAsync("p_"..player.UserId,function() return snapshot end) end); return ok
end
function SaveService.exampleJson(player:Player):string return HttpService:JSONEncode(State.get(player)) end
return SaveService
