--!strict
local Generated = script.Parent.Parent.Data.Generated
local DataIndex = {}
function DataIndex.records(moduleName: string): {any}
	local source = require(Generated:WaitForChild(moduleName))
	return source.records or source
end
function DataIndex.byId(moduleName: string): {[string]: any}
	local out = {}
	for _, record in ipairs(DataIndex.records(moduleName)) do out[record.id] = record end
	return out
end
return DataIndex
