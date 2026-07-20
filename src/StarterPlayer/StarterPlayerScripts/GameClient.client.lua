--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local action = remotes:WaitForChild("GameAction") :: RemoteEvent
local notice = remotes:WaitForChild("GameNotice") :: RemoteEvent

local gui = Instance.new("ScreenGui")
gui.Name = "AshBorderUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function label(name: string, pos: UDim2, size: UDim2, text: string): TextLabel
	local x = Instance.new("TextLabel")
	x.Name = name
	x.Position = pos
	x.Size = size
	x.BackgroundColor3 = Color3.fromRGB(18, 17, 18)
	x.BackgroundTransparency = 0.15
	x.TextColor3 = Color3.fromRGB(226, 214, 181)
	x.Font = Enum.Font.Gotham
	x.TextScaled = true
	x.TextXAlignment = Enum.TextXAlignment.Left
	x.TextYAlignment = Enum.TextYAlignment.Top
	x.Text = text
	x.Parent = gui
	return x
end

-- UI Labels/Panels
local hpLabel = label("HP", UDim2.fromOffset(20, 20), UDim2.fromOffset(300, 40), "HP: 100/100 | Mana: 20/20")
local toastLabel = label("Toast", UDim2.new(0.25, 0, 0.82, 0), UDim2.new(0.5, 0, 0, 40), "Witaj w Pograniczu Popiołu.")
toastLabel.TextXAlignment = Enum.TextXAlignment.Center
toastLabel.Visible = false

local dialogLabel = label("Dialogue", UDim2.new(0.15, 0, 0.55, 0), UDim2.new(0.7, 0, 0, 180), "")
dialogLabel.Visible = false

local panelLabel = label("Panel", UDim2.new(0.2, 0, 0.15, 0), UDim2.new(0.6, 0, 0, 250), "")
panelLabel.Visible = false

local function toast(t: string)
	toastLabel.Text = t
	toastLabel.Visible = true
	task.delay(3, function()
		if toastLabel.Text == t then
			toastLabel.Visible = false
		end
	end)
end

local currentResponses = {}

-- Handle server events
notice.OnClientEvent:Connect(function(kind: string, value: any)
	if kind == "toast" then
		toast(value)
	elseif kind == "dialogue" then
		-- Legacy fallback
		dialogLabel.Text = "Rozmowa: " .. tostring(value) .. "\n[1] pytaj  [2] przyjmij pracę  [Esc] odejdź"
		dialogLabel.Visible = true
	elseif kind == "dialogueUpdate" then
		local data = value
		currentResponses = data.responses or {}
		local t = "Rozmówca: " .. tostring(data.text) .. "\n\n"
		for i, r in ipairs(currentResponses) do
			t = t .. "[" .. i .. "] " .. r.text .. "\n"
		end
		t = t .. "\n[Esc] Wyjdź z rozmowy"
		dialogLabel.Text = t
		dialogLabel.Visible = true
	elseif kind == "dialogueClose" then
		dialogLabel.Visible = false
		currentResponses = {}
	elseif kind == "lock" then
		action:FireServer("lockStart", value)
		toast("Zamek: czekaj na sekwencję.")
	elseif kind == "lockStep" then
		toast("Zamek: naciśnij " .. (value == "left" and "A (W lewo)" or "D (W prawo)"))
	end
end)

local function choose(index: number)
	if dialogLabel.Visible and currentResponses[index] then
		action:FireServer("dialogueChoose", index)
	end
end

-- Dynamic help panel info
local function showHelp()
	panelLabel.Text = [[
=== POGRANICZE POPIOŁU — POMOC ===
[Sterowanie i Skróty Klawiszowe]:
E — Rozmowa z NPC / Otwarcie skrzyni (ProximityPrompt)
A / D — Kierunek w minigrze zamków (A: Lewo, D: Prawo)
F5 — Szybki zapis gry
F1 / F2 / F3 — Wybór slotu zapisu (Slot 1, 2, 3)
I — Ekwipunek (Wyświetl przedmioty)
J — Dziennik zadań (Wyświetl questy)
K — Karta Postaci (Statystyki, Poziom, XP, LP)
H — Zamknij ten pomocnik
]]
	panelLabel.Visible = not panelLabel.Visible
end

-- Actions Binding
ContextActionService:BindAction("LockLeft", function(_, s)
	if s == Enum.UserInputState.Begin then action:FireServer("lockInput", "left") end
	return Enum.ContextActionResult.Pass
end, false, Enum.KeyCode.A)

ContextActionService:BindAction("LockRight", function(_, s)
	if s == Enum.UserInputState.Begin then action:FireServer("lockInput", "right") end
	return Enum.ContextActionResult.Pass
end, false, Enum.KeyCode.D)

ContextActionService:BindAction("Save", function(_, s)
	if s == Enum.UserInputState.Begin then action:FireServer("save") end
	return Enum.ContextActionResult.Pass
end, false, Enum.KeyCode.F5)

ContextActionService:BindAction("CloseDialog", function(_, s)
	if s == Enum.UserInputState.Begin then
		if dialogLabel.Visible then
			dialogLabel.Visible = false
			action:FireServer("dialogueClose")
		end
	end
	return Enum.ContextActionResult.Sink
end, false, Enum.KeyCode.Escape)

-- Dialogue Choices
local keys = { Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four }
for i = 1, 4 do
	ContextActionService:BindAction("Choose" .. i, function(_, s)
		if s == Enum.UserInputState.Begin then choose(i) end
		return Enum.ContextActionResult.Pass
	end, false, keys[i])
end

-- Extra panels (simulated UI)
ContextActionService:BindAction("ShowHelp", function(_, s)
	if s == Enum.UserInputState.Begin then showHelp() end
	return Enum.ContextActionResult.Pass
end, false, Enum.KeyCode.H)

-- Save Slots
ContextActionService:BindAction("SelectSlot1", function(_, s)
	if s == Enum.UserInputState.Begin then action:FireServer("selectSlot", 1) end
	return Enum.ContextActionResult.Pass
end, false, Enum.KeyCode.F1)

ContextActionService:BindAction("SelectSlot2", function(_, s)
	if s == Enum.UserInputState.Begin then action:FireServer("selectSlot", 2) end
	return Enum.ContextActionResult.Pass
end, false, Enum.KeyCode.F2)

ContextActionService:BindAction("SelectSlot3", function(_, s)
	if s == Enum.UserInputState.Begin then action:FireServer("selectSlot", 3) end
	return Enum.ContextActionResult.Pass
end, false, Enum.KeyCode.F3)

-- Display initial prompt
toast("Naciśnij [H] aby wyświetlić pomoc i sterowanie.")
