-- Ohio 2 admin console UI. The server independently checks every command.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Ohio2"):WaitForChild("Remotes")
local commandRemote = remotes:WaitForChild("AdminCommand")
local feedbackRemote = remotes:WaitForChild("AdminFeedback")

local gui = Instance.new("ScreenGui")
gui.Name = "Ohio2Cmdr"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 20
gui.Parent = player:WaitForChild("PlayerGui")

local openButton = Instance.new("TextButton")
openButton.Name = "OpenCmdr"
openButton.Size = UDim2.fromOffset(96, 34)
openButton.AnchorPoint = Vector2.new(1, 0)
openButton.Position = UDim2.new(1, -18, 0, 18)
openButton.BackgroundColor3 = Color3.fromRGB(34, 39, 47)
openButton.Text = "CMDR  [F2]"
openButton.TextColor3 = Color3.fromRGB(239, 241, 244)
openButton.TextSize = 12
openButton.Font = Enum.Font.GothamBold
openButton.Visible = false
openButton.Parent = gui
Instance.new("UICorner", openButton).CornerRadius = UDim.new(0, 8)
local buttonStroke = Instance.new("UIStroke")
buttonStroke.Color = Color3.fromRGB(92, 107, 129)
buttonStroke.Transparency = 0.2
buttonStroke.Parent = openButton

local panel = Instance.new("Frame")
panel.Name = "Console"
panel.Size = UDim2.new(0, 650, 0, 250)
panel.AnchorPoint = Vector2.new(0.5, 0)
panel.Position = UDim2.new(0.5, 0, 0, 66)
panel.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
panel.BackgroundTransparency = 0.03
panel.Visible = false
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)
local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(86, 102, 126)
panelStroke.Transparency = 0.12
panelStroke.Parent = panel

local accent = Instance.new("Frame")
accent.Size = UDim2.new(1, 0, 0, 4)
accent.BackgroundColor3 = Color3.fromRGB(94, 151, 235)
accent.BorderSizePixel = 0
accent.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 0, 28)
title.Position = UDim2.fromOffset(15, 10)
title.BackgroundTransparency = 1
title.Text = "OHIO 2 CMDR  •  SERVER-AUTHORIZED ADMIN"
title.TextColor3 = Color3.fromRGB(235, 239, 245)
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.Parent = panel

local output = Instance.new("TextLabel")
output.Size = UDim2.new(1, -30, 0, 126)
output.Position = UDim2.fromOffset(15, 43)
output.BackgroundColor3 = Color3.fromRGB(20, 23, 29)
output.BackgroundTransparency = 0.08
output.Text = "Ready. Type help for commands. Targets support me, all, others, names, and user IDs."
output.TextColor3 = Color3.fromRGB(178, 189, 205)
output.TextSize = 13
output.TextWrapped = true
output.TextXAlignment = Enum.TextXAlignment.Left
output.TextYAlignment = Enum.TextYAlignment.Top
output.Font = Enum.Font.Code
output.Parent = panel
Instance.new("UICorner", output).CornerRadius = UDim.new(0, 6)
local outputPadding = Instance.new("UIPadding")
outputPadding.PaddingLeft = UDim.new(0, 10)
outputPadding.PaddingRight = UDim.new(0, 10)
outputPadding.PaddingTop = UDim.new(0, 8)
outputPadding.PaddingBottom = UDim.new(0, 8)
outputPadding.Parent = output

local hint = Instance.new("TextLabel")
hint.Size = UDim2.new(1, -30, 0, 18)
hint.Position = UDim2.fromOffset(15, 174)
hint.BackgroundTransparency = 1
hint.Text = "Examples: heal me  •  give me Balloon  •  cash all 500  •  event truck  •  civilians respawn"
hint.TextColor3 = Color3.fromRGB(119, 130, 147)
hint.TextSize = 11
hint.TextXAlignment = Enum.TextXAlignment.Left
hint.Font = Enum.Font.Gotham
hint.Parent = panel

local commandBox = Instance.new("TextBox")
commandBox.Name = "Command"
commandBox.Size = UDim2.new(1, -30, 0, 40)
commandBox.Position = UDim2.fromOffset(15, 199)
commandBox.BackgroundColor3 = Color3.fromRGB(30, 35, 43)
commandBox.ClearTextOnFocus = false
commandBox.PlaceholderText = "; type a command and press Enter"
commandBox.PlaceholderColor3 = Color3.fromRGB(117, 126, 141)
commandBox.Text = ""
commandBox.TextColor3 = Color3.fromRGB(241, 243, 247)
commandBox.TextSize = 15
commandBox.TextXAlignment = Enum.TextXAlignment.Left
commandBox.Font = Enum.Font.Code
commandBox.Parent = panel
Instance.new("UICorner", commandBox).CornerRadius = UDim.new(0, 7)
local boxPadding = Instance.new("UIPadding")
boxPadding.PaddingLeft = UDim.new(0, 12)
boxPadding.PaddingRight = UDim.new(0, 12)
boxPadding.Parent = commandBox

local history = {output.Text}

local function addLine(text)
	table.insert(history, tostring(text))
	while #history > 7 do table.remove(history, 1) end
	output.Text = table.concat(history, "\n")
end

local function setOpen(open)
	if not player:GetAttribute("Ohio2Admin") then open = false end
	panel.Visible = open
	if open then
		commandBox:CaptureFocus()
	else
		commandBox:ReleaseFocus()
	end
end

local function refreshPermission()
	local allowed = player:GetAttribute("Ohio2Admin") == true
	openButton.Visible = allowed
	if not allowed then setOpen(false) end
end

openButton.Activated:Connect(function() setOpen(not panel.Visible) end)
commandBox.FocusLost:Connect(function(enterPressed)
	if not enterPressed then return end
	local line = string.gsub(commandBox.Text, "^%s*[;:]%s*", "")
	line = string.gsub(line, "^%s+", "")
	line = string.gsub(line, "%s+$", "")
	commandBox.Text = ""
	if line ~= "" then
		addLine("> " .. line)
		commandRemote:FireServer(line)
	end
	if panel.Visible then task.defer(function() commandBox:CaptureFocus() end) end
end)

feedbackRemote.OnClientEvent:Connect(function(success, message)
	addLine((success and "OK  " or "ERR ") .. tostring(message))
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if input.KeyCode == Enum.KeyCode.Escape and panel.Visible then
		setOpen(false)
		return
	end
	if processed or not player:GetAttribute("Ohio2Admin") then return end
	if input.KeyCode == Enum.KeyCode.F2 or input.KeyCode == Enum.KeyCode.Semicolon then
		setOpen(not panel.Visible)
	end
end)

player:GetAttributeChangedSignal("Ohio2Admin"):Connect(refreshPermission)
refreshPermission()
