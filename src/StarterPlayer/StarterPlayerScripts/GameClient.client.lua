--!strict
local Players=game:GetService("Players");local ReplicatedStorage=game:GetService("ReplicatedStorage");local ContextActionService=game:GetService("ContextActionService")
local player=Players.LocalPlayer;local remotes=ReplicatedStorage:WaitForChild("Remotes");local action=remotes:WaitForChild("GameAction") :: RemoteEvent;local notice=remotes:WaitForChild("GameNotice") :: RemoteEvent
local gui=Instance.new("ScreenGui");gui.Name="AshBorderUI";gui.ResetOnSpawn=false;gui.Parent=player:WaitForChild("PlayerGui")
local function label(name:string,pos:UDim2,size:UDim2,text:string):TextLabel local x=Instance.new("TextLabel");x.Name=name;x.Position=pos;x.Size=size;x.BackgroundColor3=Color3.fromRGB(18,17,18);x.BackgroundTransparency=.2;x.TextColor3=Color3.fromRGB(226,214,181);x.Font=Enum.Font.Gotham;x.TextScaled=true;x.Text=text;x.Parent=gui;return x end
local hp=label("HP",UDim2.fromOffset(20,20),UDim2.fromOffset(220,30),"HP — oddech jeszcze jest");local status=label("Status",UDim2.new(.25,0,.84,0),UDim2.new(.5,0,0,36),"Przybyłeś do Pogranicza Popiołu.");status.Visible=false
local dialog=label("Dialogue",UDim2.new(.15,0,.62,0),UDim2.new(.7,0,0,150),"");dialog.Visible=false
local function toast(t:string) status.Text=t;status.Visible=true;task.delay(3,function() status.Visible=false end) end
notice.OnClientEvent:Connect(function(kind:string,value:string)
 if kind=="toast" then toast(value)
 elseif kind=="dialogue" then dialog.Text="Rozmowa: "..value.."\n[1] pytaj  [2] przyjmij pracę  [Esc] odejdź";dialog.Visible=true
 elseif kind=="lock" then action:FireServer("lockStart",value);toast("Zamek: czekaj na kierunek.")
 elseif kind=="lockStep" then toast("Zamek: naciśnij "..(value=="left" and "A" or "D")) end
end)
ContextActionService:BindAction("LockLeft",function(_,s)if s==Enum.UserInputState.Begin then action:FireServer("lockInput","left") end return Enum.ContextActionResult.Pass end,false,Enum.KeyCode.A)
ContextActionService:BindAction("LockRight",function(_,s)if s==Enum.UserInputState.Begin then action:FireServer("lockInput","right") end return Enum.ContextActionResult.Pass end,false,Enum.KeyCode.D)
ContextActionService:BindAction("Save",function(_,s)if s==Enum.UserInputState.Begin then action:FireServer("save") end return Enum.ContextActionResult.Pass end,false,Enum.KeyCode.F5)
ContextActionService:BindAction("CloseDialog",function(_,s)if s==Enum.UserInputState.Begin then dialog.Visible=false end return Enum.ContextActionResult.Sink end,false,Enum.KeyCode.Escape)
