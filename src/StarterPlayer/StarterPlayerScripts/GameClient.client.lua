--!strict
-- Presentation and input only. The server validates every state-changing action.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local ContextActionService=game:GetService("ContextActionService")
local player=Players.LocalPlayer;local mouse=player:GetMouse()
local remotes=ReplicatedStorage:WaitForChild("Remotes");local action=remotes:WaitForChild("GameAction") :: RemoteEvent;local notice=remotes:WaitForChild("GameNotice") :: RemoteEvent
local gui=Instance.new("ScreenGui");gui.Name="AshBorderUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.Parent=player:WaitForChild("PlayerGui")
local function label(name:string,pos:UDim2,size:UDim2,text:string):TextLabel
 local x=Instance.new("TextLabel");x.Name=name;x.Position=pos;x.Size=size;x.BackgroundColor3=Color3.fromRGB(18,17,18);x.BackgroundTransparency=.15;x.TextColor3=Color3.fromRGB(226,214,181);x.Font=Enum.Font.Gotham;x.TextScaled=true;x.TextWrapped=true;x.Text=text;x.Parent=gui;return x
end
local hp=label("HP",UDim2.fromOffset(20,20),UDim2.fromOffset(260,32),"HP — oddech jeszcze jest")
local status=label("Status",UDim2.new(.25,0,.84,0),UDim2.new(.5,0,0,36),"Przybyłeś do Pogranicza Popiołu.");status.Visible=false
local dialog=label("Dialogue",UDim2.new(.15,0,.62,0),UDim2.new(.7,0,0,150),"");dialog.Visible=false
local panel=label("Panel",UDim2.new(.61,0,.08,0),UDim2.new(.36,0,.55,0),"");panel.Visible=false
local state:any=nil;local style="sword";local itemId="sword_01"
local function toast(t:string) status.Text=t;status.Visible=true;task.delay(3,function() status.Visible=false end) end
local function showInventory()
 if not state then return end
 local lines={"EKWIPUNEK  [I]", "Wyposażono: "..tostring(state.equipped or itemId), ""}
 for id,count in pairs(state.inventory or {}) do table.insert(lines,id.." ×"..tostring(count)) end
 panel.Text=table.concat(lines,"\n");panel.Visible=not panel.Visible
end
local function showJournal()
 if not state then return end
 local lines={"DZIENNIK  [J]"}
 for id,stage in pairs(state.quests or {}) do table.insert(lines,"• "..id..": "..stage) end
 if #lines==1 then table.insert(lines,"Brudny papier jeszcze pusty.") end
 panel.Text=table.concat(lines,"\n");panel.Visible=not panel.Visible
end
local function showCharacter()
 if not state then return end
 local s=state.stats;panel.Text=string.format("POSTAĆ  [C]\nPoziom %d | XP %d | PN %d\nHP %d | Mana %d\nSiła %d | Zręczność %d",s.level,s.xp,s.learningPoints,s.maxHp,s.mana,s.strength,s.dexterity);panel.Visible=not panel.Visible
end
local function targetId():string?
 local hit=mouse.Target;if not hit then return nil end;local model=hit:FindFirstAncestorOfClass("Model");if not model then return nil end
 return (model:GetAttribute("MonsterId") or model:GetAttribute("NpcId")) :: string?
end
notice.OnClientEvent:Connect(function(kind:string,value:any)
 if kind=="state" then state=value;local s=value.stats;hp.Text=string.format("HP %d | Mana %d | Lvl %d | %s",s.maxHp,s.mana,s.level,style);return end
 if kind=="toast" then toast(value)
 elseif kind=="dialogue" then dialog.Text="Rozmowa: "..value.."\n[1] pytaj  [2] przyjmij pracę  [Esc] odejdź";dialog.Visible=true
 elseif kind=="lock" then action:FireServer("lockStart",value);toast("Zamek: czekaj na kierunek.")
 elseif kind=="lockStep" then toast("Zamek: naciśnij "..(value=="left" and "A" or "D")) end
end)
local function bind(name:string,key:Enum.KeyCode,fn:()->()):() ContextActionService:BindAction(name,function(_,s)if s==Enum.UserInputState.Begin then fn() end return Enum.ContextActionResult.Sink end,false,key) end
bind("LockLeft",Enum.KeyCode.A,function() action:FireServer("lockInput","left") end)
bind("LockRight",Enum.KeyCode.D,function() action:FireServer("lockInput","right") end)
bind("Save",Enum.KeyCode.F5,function() action:FireServer("save") end)
bind("CloseDialog",Enum.KeyCode.Escape,function() dialog.Visible=false;panel.Visible=false end)
bind("Inventory",Enum.KeyCode.I,showInventory);bind("Journal",Enum.KeyCode.J,showJournal);bind("Character",Enum.KeyCode.C,showCharacter)
bind("Sword",Enum.KeyCode.One,function() style="sword";itemId="sword_01";toast("Miecz gotów.") end)
bind("Bow",Enum.KeyCode.Two,function() style="bow";itemId="bow_01";toast("Łuk gotów.") end)
bind("Spell",Enum.KeyCode.Three,function() style="spell";itemId="spell_ember";toast("Żarzący Grot gotów.") end)
bind("Attack",Enum.KeyCode.F,function() local id=targetId();if id then action:FireServer("attack",{targetId=id,style=style,itemId=itemId}) else toast("Nie masz celu.") end end)
action:FireServer("state")
