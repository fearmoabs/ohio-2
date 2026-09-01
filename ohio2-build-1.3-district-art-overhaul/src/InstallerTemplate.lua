-- OHIO 2 PLAYABLE PROTOTYPE INSTALLER
-- Paste this entire file into Roblox Studio's Command Bar while NOT play-testing,
-- then press Ctrl+Enter or click the Command Bar's Run button.

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local StarterPlayer = game:GetService("StarterPlayer")

ChangeHistoryService:SetWaypoint("Before Ohio2 prototype install")

local function removeNamed(parent, name)
	local existing = parent:FindFirstChild(name)
	if existing then
		existing:Destroy()
	end
end

removeNamed(ReplicatedStorage, "Ohio2")
removeNamed(ServerScriptService, "Ohio2Server")
removeNamed(ServerScriptService, "Ohio2AdminServer")
removeNamed(ServerStorage, "Ohio2Tools")
removeNamed(ServerStorage, "Ohio2Police")
removeNamed(ServerStorage, "Ohio2CivilianTemplates")
removeNamed(ServerStorage, "Ohio2VehicleTemplates")
removeNamed(ServerStorage, "Ohio2AdminConfig")
removeNamed(ServerStorage, "Ohio2AdminBridge")
removeNamed(StarterPlayer.StarterPlayerScripts, "Ohio2Client")
removeNamed(StarterPlayer.StarterPlayerScripts, "Ohio2AdminClient")
removeNamed(workspace, "Ohio2Map")
removeNamed(workspace, "Ohio2Drops")
removeNamed(workspace, "Ohio2NPCs")
removeNamed(workspace, "Ohio2Vehicles")

local project = Instance.new("Folder")
project.Name = "Ohio2"
project.Parent = ReplicatedStorage

local shared = Instance.new("Folder")
shared.Name = "Shared"
shared.Parent = project

local remotes = Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = project
for _, name in ipairs({"Notification", "Objective", "WeaponAction", "WeaponFX", "WeaponFeedback", "StateAction", "PhoneAction", "AdminCommand", "AdminFeedback"}) do
	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = remotes
end

local itemDefinitions = Instance.new("ModuleScript")
itemDefinitions.Name = "ItemDefinitions"
itemDefinitions.Source = [==[
__ITEM_DEFINITIONS_SOURCE__
]==]
itemDefinitions.Parent = shared

local soundDefinitions = Instance.new("ModuleScript")
soundDefinitions.Name = "SoundDefinitions"
soundDefinitions.Source = [==[
__SOUND_DEFINITIONS_SOURCE__
]==]
soundDefinitions.Parent = shared

local adminConfig = Instance.new("Configuration")
adminConfig.Name = "Ohio2AdminConfig"
adminConfig.Parent = ServerStorage

local adminUserIds = Instance.new("StringValue")
adminUserIds.Name = "AdminUserIds"
adminUserIds.Value = ""
adminUserIds.Parent = adminConfig

local creatorIsAdmin = Instance.new("BoolValue")
creatorIsAdmin.Name = "CreatorIsAdmin"
creatorIsAdmin.Value = true
creatorIsAdmin.Parent = adminConfig

local studioPlayersAreAdmin = Instance.new("BoolValue")
studioPlayersAreAdmin.Name = "StudioPlayersAreAdmin"
studioPlayersAreAdmin.Value = true
studioPlayersAreAdmin.Parent = adminConfig

local adminBridge = Instance.new("BindableEvent")
adminBridge.Name = "Ohio2AdminBridge"
adminBridge.Parent = ServerStorage

local serverMain = Instance.new("Script")
serverMain.Name = "Ohio2Server"
serverMain.Source = [==[
__SERVER_MAIN_SOURCE__
]==]
serverMain.Parent = ServerScriptService

local adminServer = Instance.new("Script")
adminServer.Name = "Ohio2AdminServer"
adminServer.Source = [==[
__ADMIN_SERVER_SOURCE__
]==]
adminServer.Parent = ServerScriptService

local clientMain = Instance.new("LocalScript")
clientMain.Name = "Ohio2Client"
clientMain.Source = [==[
__CLIENT_MAIN_SOURCE__
]==]
clientMain.Parent = StarterPlayer.StarterPlayerScripts

local adminClient = Instance.new("LocalScript")
adminClient.Name = "Ohio2AdminClient"
adminClient.Source = [==[
__ADMIN_CLIENT_SOURCE__
]==]
adminClient.Parent = StarterPlayer.StarterPlayerScripts

local function makePart(parent, name, size, cframe, color, material, anchored)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = anchored ~= false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function makePrompt(part, actionText, objectText, actionType, holdDuration, attributes)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = actionText
	prompt.ObjectText = objectText
	prompt.HoldDuration = holdDuration or 0
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	prompt:SetAttribute("ActionType", actionType)
	for key, value in pairs(attributes or {}) do
		prompt:SetAttribute(key, value)
	end
	prompt.Parent = part
	return prompt
end

local function makeBillboard(part, text, color, width)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Label"
	billboard.Size = UDim2.fromOffset(width or 210, 48)
	billboard.StudsOffset = Vector3.new(0, part.Size.Y * 0.5 + 2, 0)
	billboard.AlwaysOnTop = false
	billboard.MaxDistance = 0
	billboard.Parent = part
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.BackgroundColor3 = Color3.fromRGB(15, 17, 20)
	textLabel.BackgroundTransparency = 0.12
	textLabel.TextColor3 = color or Color3.fromRGB(245, 245, 245)
	textLabel.Text = text
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBlack
	textLabel.Parent = billboard
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 7)
	corner.Parent = textLabel
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.PaddingTop = UDim.new(0, 7)
	padding.PaddingBottom = UDim.new(0, 7)
	padding.Parent = textLabel
	return billboard
end

local function makeSurfaceSign(part, text, color, face, canvasWidth, canvasHeight, doubleSided)
	local selectedFace = face or Enum.NormalId.Back
	local oppositeFaces = {
		[Enum.NormalId.Front] = Enum.NormalId.Back,
		[Enum.NormalId.Back] = Enum.NormalId.Front,
		[Enum.NormalId.Left] = Enum.NormalId.Right,
		[Enum.NormalId.Right] = Enum.NormalId.Left,
		[Enum.NormalId.Top] = Enum.NormalId.Bottom,
		[Enum.NormalId.Bottom] = Enum.NormalId.Top,
	}
	local function addFace(targetFace, suffix)
		local surface = Instance.new("SurfaceGui")
		surface.Name = "PhysicalSign" .. suffix
		surface.Face = targetFace
		surface.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
		surface.CanvasSize = Vector2.new(canvasWidth or 480, canvasHeight or 110)
		surface.AlwaysOnTop = false
		surface.LightInfluence = 0.2
		surface.Brightness = 1.5
		surface.Parent = part
		local background = Instance.new("Frame")
		background.Size = UDim2.fromScale(1, 1)
		background.BackgroundColor3 = Color3.fromRGB(18, 20, 23)
		background.BorderSizePixel = 0
		background.Parent = surface
		local accent = Instance.new("Frame")
		accent.Size = UDim2.new(1, 0, 0, 8)
		accent.BackgroundColor3 = color or Color3.fromRGB(235, 237, 230)
		accent.BorderSizePixel = 0
		accent.Parent = background
		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(1, -28, 1, -24)
		textLabel.Position = UDim2.fromOffset(14, 16)
		textLabel.BackgroundTransparency = 1
		textLabel.Text = text
		textLabel.TextColor3 = color or Color3.fromRGB(235, 237, 230)
		textLabel.TextScaled = true
		textLabel.TextWrapped = true
		textLabel.Font = Enum.Font.GothamBlack
		textLabel.Parent = background
		return surface
	end
	local primary = addFace(selectedFace, "Front")
	if doubleSided ~= false then
		addFace(oppositeFaces[selectedFace], "Back")
	end
	return primary
end

local function weldTo(root, part)
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = part
	weld.Parent = root
end

local tools = Instance.new("Folder")
tools.Name = "Ohio2Tools"
tools.Parent = ServerStorage
local vehicleTemplates = Instance.new("Folder")
vehicleTemplates.Name = "Ohio2VehicleTemplates"
vehicleTemplates.Parent = ServerStorage

local function makeTool(itemId, size, color, gripPosition, gripAngles)
	local tool = Instance.new("Tool")
	tool.Name = itemId
	tool.CanBeDropped = false
	tool.RequiresHandle = true
	tool:SetAttribute("Ohio2Item", itemId)
	tool.ToolTip = "Prototype item — carried gear drops when you die"
	local handle = makePart(tool, "Handle", size, CFrame.new(), color, Enum.Material.SmoothPlastic, false)
	handle.CanCollide = false
	handle.Massless = true
	local position = gripPosition or Vector3.new()
	local angles = gripAngles or Vector3.new()
	tool.Grip = CFrame.new(position) * CFrame.Angles(math.rad(angles.X), math.rad(angles.Y), math.rad(angles.Z))
	tool.Parent = tools
	return tool, handle
end

local function attachToolPart(tool, handle, name, size, cframe, color, material, shape, weldRoot, className)
	local part
	if className and className ~= "Part" then
		part = Instance.new(className)
		part.Name = name
		part.Size = size
		part.CFrame = cframe
		part.Color = color
		part.Material = material or Enum.Material.SmoothPlastic
		part.Anchored = false
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		part.Parent = tool
	else
		part = makePart(tool, name, size, cframe, color, material, false)
	end
	part.CanCollide = false
	part.Massless = true
	if shape and part:IsA("Part") then
		part.Shape = shape
	end
	weldTo(weldRoot or handle, part)
	return part
end

local function attachMotorizedToolPart(tool, handle, name, size, cframe, color, material, motorName)
	local part = makePart(tool, name, size, cframe, color, material, false)
	part.CanCollide = false
	part.Massless = true
	local motor = Instance.new("Motor6D")
	motor.Name = motorName
	motor.Part0 = handle
	motor.Part1 = part
	motor.C0 = cframe
	motor.C1 = CFrame.new()
	motor.Parent = handle
	return part, motor
end

local fists = Instance.new("Tool")
fists.Name = "Fists"
fists.CanBeDropped = false
fists.RequiresHandle = false
fists:SetAttribute("Ohio2Item", "Fists")
fists.ToolTip = "Always available • three-hit combo • F to block"
fists.Parent = tools

local bat, batHandle = makeTool("Bat", Vector3.new(0.42, 1.35, 0.42), Color3.fromRGB(37, 39, 43), Vector3.new(0, -0.42, 0))
batHandle.Material = Enum.Material.Rubber
attachToolPart(bat, batHandle, "Barrel", Vector3.new(3.7, 0.82, 0.82), CFrame.new(0, 2.35, 0) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(157, 105, 61), Enum.Material.Wood, Enum.PartType.Cylinder)
attachToolPart(bat, batHandle, "Taper", Vector3.new(1.2, 0.58, 0.58), CFrame.new(0, 0.92, 0) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(141, 91, 52), Enum.Material.Wood, Enum.PartType.Cylinder)
attachToolPart(bat, batHandle, "Knob", Vector3.new(0.28, 0.62, 0.62), CFrame.new(0, -0.78, 0) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(31, 32, 35), Enum.Material.Rubber, Enum.PartType.Cylinder)
for y = -0.45, 0.3, 0.25 do
	attachToolPart(bat, batHandle, "GripTape", Vector3.new(0.06, 0.47, 0.47), CFrame.new(0, y, 0) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(69, 70, 74), Enum.Material.Fabric, Enum.PartType.Cylinder)
end

local pistol, pistolHandle = makeTool("Pistol", Vector3.new(0.34, 0.72, 0.3), Color3.fromRGB(31, 33, 37), Vector3.new(0, -0.23, 0.1), Vector3.new(-6, 0, 0))
pistol.ToolTip = "Compact 9mm sidearm • 12-round magazine • R to reload"
pistol:SetAttribute("ModelRevision", "1.2")
pistolHandle.Material = Enum.Material.Rubber
attachToolPart(pistol, pistolHandle, "Frame", Vector3.new(0.39, 0.25, 0.7), CFrame.new(0, 0.27, -0.24), Color3.fromRGB(43, 46, 51), Enum.Material.Metal)
local pistolSlide = attachMotorizedToolPart(pistol, pistolHandle, "Slide", Vector3.new(0.42, 0.23, 1.22), CFrame.new(0, 0.48, -0.49), Color3.fromRGB(75, 79, 85), Enum.Material.Metal, "SlideMotor")
attachToolPart(pistol, pistolHandle, "Barrel", Vector3.new(0.88, 0.11, 0.11), CFrame.new(0, 0.47, -0.82) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(22, 23, 26), Enum.Material.Metal, Enum.PartType.Cylinder)
attachToolPart(pistol, pistolHandle, "GuideRod", Vector3.new(0.7, 0.065, 0.065), CFrame.new(0, 0.34, -0.79) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(38, 40, 44), Enum.Material.Metal, Enum.PartType.Cylinder)
attachToolPart(pistol, pistolHandle, "Muzzle", Vector3.new(0.085, 0.17, 0.17), CFrame.new(0, 0.47, -1.245) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(11, 12, 14), Enum.Material.Metal, Enum.PartType.Cylinder)
attachToolPart(pistol, pistolHandle, "EjectionPort", Vector3.new(0.22, 0.025, 0.27), CFrame.new(0.1, 0.61, -0.38), Color3.fromRGB(12, 13, 15), Enum.Material.Metal, nil, pistolSlide)
attachToolPart(pistol, pistolHandle, "FrontSight", Vector3.new(0.055, 0.075, 0.075), CFrame.new(0, 0.655, -1.03), Color3.fromRGB(20, 21, 24), Enum.Material.Metal, nil, pistolSlide)
attachToolPart(pistol, pistolHandle, "FrontDot", Vector3.new(0.018, 0.025, 0.025), CFrame.new(0, 0.686, -1.055), Color3.fromRGB(230, 226, 203), Enum.Material.Neon, nil, pistolSlide)
for _, x in ipairs({-0.12, 0.12}) do
	attachToolPart(pistol, pistolHandle, "RearSight", Vector3.new(0.07, 0.075, 0.075), CFrame.new(x, 0.655, 0.02), Color3.fromRGB(20, 21, 24), Enum.Material.Metal, nil, pistolSlide)
end
for _, side in ipairs({-1, 1}) do
	attachToolPart(pistol, pistolHandle, "GripPanel", Vector3.new(0.025, 0.53, 0.23), CFrame.new(side * 0.174, -0.04, 0.015), Color3.fromRGB(61, 63, 67), Enum.Material.Rubber)
	for serration = 0, 3 do
		attachToolPart(pistol, pistolHandle, "SlideSerration", Vector3.new(0.018, 0.15, 0.032), CFrame.new(side * 0.216, 0.49, -0.05 - serration * 0.075) * CFrame.Angles(math.rad(-12), 0, 0), Color3.fromRGB(32, 34, 38), Enum.Material.Metal, nil, pistolSlide)
	end
end
attachToolPart(pistol, pistolHandle, "TriggerGuard", Vector3.new(0.31, 0.06, 0.33), CFrame.new(0, 0.03, -0.32), Color3.fromRGB(35, 37, 41), Enum.Material.Metal)
attachToolPart(pistol, pistolHandle, "Trigger", Vector3.new(0.045, 0.16, 0.045), CFrame.new(0, 0.02, -0.3) * CFrame.Angles(math.rad(-18), 0, 0), Color3.fromRGB(17, 18, 20), Enum.Material.Metal)
attachToolPart(pistol, pistolHandle, "SlideStop", Vector3.new(0.025, 0.075, 0.15), CFrame.new(-0.21, 0.29, -0.14), Color3.fromRGB(20, 21, 23), Enum.Material.Metal)
attachToolPart(pistol, pistolHandle, "SafetyDot", Vector3.new(0.03, 0.045, 0.045), CFrame.new(-0.22, 0.31, 0.04), Color3.fromRGB(196, 52, 48), Enum.Material.Neon, Enum.PartType.Ball)
local pistolMagazine = attachMotorizedToolPart(pistol, pistolHandle, "Magazine", Vector3.new(0.27, 0.5, 0.22), CFrame.new(0, -0.08, 0.015), Color3.fromRGB(24, 26, 29), Enum.Material.Metal, "MagazineMotor")
attachToolPart(pistol, pistolHandle, "MagazineBase", Vector3.new(0.38, 0.065, 0.33), CFrame.new(0, -0.39, 0.015), Color3.fromRGB(17, 18, 20), Enum.Material.Metal, nil, pistolMagazine)

local shotgun, shotgunHandle = makeTool("Shotgun", Vector3.new(0.5, 0.52, 0.78), Color3.fromRGB(43, 46, 51), Vector3.new(0, -0.23, 0.67), Vector3.new(-3, 0, 0))
shotgun.ToolTip = "Avatar-scale 12-gauge pump shotgun • 6 shells • R to reload"
shotgun:SetAttribute("ModelRevision", "1.2")
shotgunHandle.Material = Enum.Material.Metal
attachToolPart(shotgun, shotgunHandle, "ReceiverTop", Vector3.new(0.53, 0.18, 0.88), CFrame.new(0, 0.29, -0.02), Color3.fromRGB(61, 64, 69), Enum.Material.Metal)
attachToolPart(shotgun, shotgunHandle, "ReceiverBottom", Vector3.new(0.44, 0.13, 0.48), CFrame.new(0, -0.3, 0.04), Color3.fromRGB(33, 35, 39), Enum.Material.Metal)
attachToolPart(shotgun, shotgunHandle, "Barrel", Vector3.new(2.22, 0.14, 0.14), CFrame.new(0, 0.29, -1.5) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(27, 29, 32), Enum.Material.Metal, Enum.PartType.Cylinder)
attachToolPart(shotgun, shotgunHandle, "Muzzle", Vector3.new(0.09, 0.2, 0.2), CFrame.new(0, 0.29, -2.64) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(10, 11, 13), Enum.Material.Metal, Enum.PartType.Cylinder)
attachToolPart(shotgun, shotgunHandle, "MagazineTube", Vector3.new(1.92, 0.12, 0.12), CFrame.new(0, -0.01, -1.35) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(36, 39, 43), Enum.Material.Metal, Enum.PartType.Cylinder)
attachToolPart(shotgun, shotgunHandle, "VentRib", Vector3.new(0.1, 0.035, 2.02), CFrame.new(0, 0.405, -1.52), Color3.fromRGB(35, 37, 40), Enum.Material.Metal)
local pump = attachMotorizedToolPart(shotgun, shotgunHandle, "Pump", Vector3.new(0.55, 0.37, 0.7), CFrame.new(0, -0.03, -1.35), Color3.fromRGB(100, 65, 40), Enum.Material.WoodPlanks, "PumpMotor")
for _, x in ipairs({-0.2, -0.1, 0, 0.1, 0.2}) do
	attachToolPart(shotgun, shotgunHandle, "PumpGroove", Vector3.new(0.025, 0.39, 0.72), CFrame.new(x, -0.03, -1.35), Color3.fromRGB(62, 41, 27), Enum.Material.Wood, nil, pump)
end
for _, x in ipairs({-0.21, 0.21}) do
	attachToolPart(shotgun, shotgunHandle, "ActionBar", Vector3.new(0.035, 0.055, 1.22), CFrame.new(x, -0.03, -0.72), Color3.fromRGB(74, 77, 80), Enum.Material.Metal, nil, pump)
end
attachToolPart(shotgun, shotgunHandle, "Stock", Vector3.new(0.62, 0.66, 1.42), CFrame.new(0, -0.01, 1.13) * CFrame.Angles(math.rad(-5), 0, 0), Color3.fromRGB(96, 62, 39), Enum.Material.WoodPlanks, nil, nil, "WedgePart")
attachToolPart(shotgun, shotgunHandle, "StockComb", Vector3.new(0.54, 0.2, 1.18), CFrame.new(0, 0.34, 1.05) * CFrame.Angles(math.rad(-5), 0, 0), Color3.fromRGB(112, 73, 44), Enum.Material.WoodPlanks)
attachToolPart(shotgun, shotgunHandle, "ButtPad", Vector3.new(0.66, 0.71, 0.1), CFrame.new(0, -0.06, 1.88) * CFrame.Angles(math.rad(-5), 0, 0), Color3.fromRGB(28, 29, 32), Enum.Material.Rubber)
attachToolPart(shotgun, shotgunHandle, "PistolGrip", Vector3.new(0.34, 0.57, 0.34), CFrame.new(0, -0.48, 0.42) * CFrame.Angles(math.rad(-20), 0, 0), Color3.fromRGB(83, 54, 35), Enum.Material.WoodPlanks)
attachToolPart(shotgun, shotgunHandle, "EjectionPort", Vector3.new(0.025, 0.18, 0.35), CFrame.new(0.265, 0.14, -0.16), Color3.fromRGB(11, 12, 14), Enum.Material.Metal)
attachToolPart(shotgun, shotgunHandle, "LoadingGate", Vector3.new(0.28, 0.025, 0.4), CFrame.new(0, -0.34, 0.02), Color3.fromRGB(18, 19, 22), Enum.Material.Metal)
for _, z in ipairs({-0.22, 0.17}) do
	attachToolPart(shotgun, shotgunHandle, "ReceiverPin", Vector3.new(0.035, 0.07, 0.07), CFrame.new(-0.27, 0, z) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(17, 18, 20), Enum.Material.Metal, Enum.PartType.Cylinder)
end
attachToolPart(shotgun, shotgunHandle, "TriggerGuard", Vector3.new(0.34, 0.055, 0.32), CFrame.new(0, -0.29, 0.2), Color3.fromRGB(28, 30, 33), Enum.Material.Metal)
attachToolPart(shotgun, shotgunHandle, "Trigger", Vector3.new(0.04, 0.17, 0.04), CFrame.new(0, -0.24, 0.2) * CFrame.Angles(math.rad(-16), 0, 0), Color3.fromRGB(15, 16, 18), Enum.Material.Metal)
attachToolPart(shotgun, shotgunHandle, "BeadSight", Vector3.new(0.06, 0.06, 0.06), CFrame.new(0, 0.45, -2.45), Color3.fromRGB(222, 191, 84), Enum.Material.Neon, Enum.PartType.Ball)

local medkit, medkitHandle = makeTool("Medkit", Vector3.new(1.65, 1.35, 0.75), Color3.fromRGB(191, 48, 48), Vector3.new())
local crossA = makePart(medkit, "CrossA", Vector3.new(0.25, 0.85, 0.78), CFrame.new(0, 0, -0.01), Color3.fromRGB(245, 245, 245), Enum.Material.SmoothPlastic, false)
local crossB = makePart(medkit, "CrossB", Vector3.new(0.85, 0.25, 0.78), CFrame.new(0, 0, -0.01), Color3.fromRGB(245, 245, 245), Enum.Material.SmoothPlastic, false)
for _, crossPart in ipairs({crossA, crossB}) do
	crossPart.CanCollide = false
	crossPart.Massless = true
	weldTo(medkitHandle, crossPart)
end

local balloon, balloonHandle = makeTool("Balloon", Vector3.new(0.42, 0.72, 0.42), Color3.fromRGB(61, 63, 69), Vector3.new(0, -0.25, 0))
balloon.ToolTip = "Lift balloon • equip it for a higher jump"
balloonHandle.Material = Enum.Material.Rubber
attachToolPart(balloon, balloonHandle, "String", Vector3.new(0.08, 4.4, 0.08), CFrame.new(0, 2.45, 0), Color3.fromRGB(220, 220, 214), Enum.Material.SmoothPlastic)
local balloonBody = attachToolPart(balloon, balloonHandle, "BalloonBody", Vector3.new(3.15, 3.65, 3.15), CFrame.new(0, 5.75, 0), Color3.fromRGB(235, 72, 92), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
balloonBody.Reflectance = 0.08
attachToolPart(balloon, balloonHandle, "BalloonKnot", Vector3.new(0.35, 0.35, 0.35), CFrame.new(0, 3.94, 0), Color3.fromRGB(201, 50, 69), Enum.Material.SmoothPlastic)

local police = Instance.new("Model")
police.Name = "Ohio2Police"
local root = makePart(police, "HumanoidRootPart", Vector3.new(2, 2, 1), CFrame.new(0, 3, 0), Color3.fromRGB(0, 0, 0), Enum.Material.SmoothPlastic, false)
root.Transparency = 1
root.CanCollide = false
local torso = makePart(police, "Torso", Vector3.new(2, 2, 1), CFrame.new(0, 3, 0), Color3.fromRGB(35, 71, 125), Enum.Material.SmoothPlastic, false)
local head = makePart(police, "Head", Vector3.new(2, 1, 1), CFrame.new(0, 4.5, 0), Color3.fromRGB(224, 184, 144), Enum.Material.SmoothPlastic, false)
local leftArm = makePart(police, "Left Arm", Vector3.new(1, 2, 1), CFrame.new(-1.5, 3, 0), Color3.fromRGB(35, 71, 125), Enum.Material.SmoothPlastic, false)
local rightArm = makePart(police, "Right Arm", Vector3.new(1, 2, 1), CFrame.new(1.5, 3, 0), Color3.fromRGB(35, 71, 125), Enum.Material.SmoothPlastic, false)
local leftLeg = makePart(police, "Left Leg", Vector3.new(1, 2, 1), CFrame.new(-0.5, 1, 0), Color3.fromRGB(24, 29, 38), Enum.Material.SmoothPlastic, false)
local rightLeg = makePart(police, "Right Leg", Vector3.new(1, 2, 1), CFrame.new(0.5, 1, 0), Color3.fromRGB(24, 29, 38), Enum.Material.SmoothPlastic, false)
for _, bodyPart in ipairs({torso, head, leftArm, rightArm, leftLeg, rightLeg}) do
	bodyPart.CanCollide = bodyPart == leftLeg or bodyPart == rightLeg
	bodyPart.Massless = bodyPart ~= leftLeg and bodyPart ~= rightLeg
	weldTo(root, bodyPart)
end
local officerVest = makePart(police, "TacticalVest", Vector3.new(2.12, 1.65, 0.34), CFrame.new(0, 3.1, -0.57), Color3.fromRGB(25, 29, 36), Enum.Material.Fabric, false)
local officerBadge = makePart(police, "Badge", Vector3.new(0.32, 0.42, 0.08), CFrame.new(-0.52, 3.42, -0.78), Color3.fromRGB(224, 186, 72), Enum.Material.Metal, false)
local officerBelt = makePart(police, "DutyBelt", Vector3.new(2.18, 0.26, 1.08), CFrame.new(0, 2.12, 0), Color3.fromRGB(22, 23, 27), Enum.Material.Fabric, false)
local officerCap = makePart(police, "PatrolCap", Vector3.new(2.05, 0.38, 1.1), CFrame.new(0, 5.12, 0), Color3.fromRGB(26, 48, 82), Enum.Material.Fabric, false)
local officerRadio = makePart(police, "Radio", Vector3.new(0.32, 0.58, 0.24), CFrame.new(0.72, 3.5, -0.72), Color3.fromRGB(18, 19, 22), Enum.Material.Metal, false)
local officerSidearm = makePart(police, "Sidearm", Vector3.new(0.25, 0.68, 0.22), CFrame.new(1.18, 2.45, 0), Color3.fromRGB(20, 21, 24), Enum.Material.Metal, false)
for _, detail in ipairs({officerVest, officerBadge, officerBelt, officerCap, officerRadio, officerSidearm}) do
	detail.CanCollide = false
	detail.Massless = true
	weldTo(root, detail)
end
local humanoid = Instance.new("Humanoid")
humanoid.DisplayName = "POLICE"
humanoid.MaxHealth = 150
humanoid.Health = 150
humanoid.WalkSpeed = 15
humanoid.HipHeight = 1
humanoid.RequiresNeck = false
humanoid.Parent = police
local officerLabel = makeBillboard(head, "POLICE", Color3.fromRGB(105, 169, 255), 110)
officerLabel.StudsOffset = Vector3.new(0, 2.4, 0)
police.PrimaryPart = root
police.Parent = ServerStorage

local civilianTemplates = Instance.new("Folder")
civilianTemplates.Name = "Ohio2CivilianTemplates"
civilianTemplates.Parent = ServerStorage

local function makeCivilianTemplate(name, shirtColor, pantsColor, skinColor, hairColor)
	local civilian = Instance.new("Model")
	civilian.Name = name
	civilian:SetAttribute("Ohio2Civilian", true)
	local civilianRoot = makePart(civilian, "HumanoidRootPart", Vector3.new(2, 2, 1), CFrame.new(0, 3, 0), Color3.fromRGB(0, 0, 0), Enum.Material.SmoothPlastic, false)
	civilianRoot.Transparency = 1
	civilianRoot.CanCollide = false
	local civilianTorso = makePart(civilian, "Torso", Vector3.new(2, 2, 1), CFrame.new(0, 3, 0), shirtColor, Enum.Material.Fabric, false)
	local civilianHead = makePart(civilian, "Head", Vector3.new(2, 1, 1), CFrame.new(0, 4.5, 0), skinColor, Enum.Material.SmoothPlastic, false)
	local civilianLeftArm = makePart(civilian, "Left Arm", Vector3.new(1, 2, 1), CFrame.new(-1.5, 3, 0), skinColor, Enum.Material.SmoothPlastic, false)
	local civilianRightArm = makePart(civilian, "Right Arm", Vector3.new(1, 2, 1), CFrame.new(1.5, 3, 0), skinColor, Enum.Material.SmoothPlastic, false)
	local civilianLeftLeg = makePart(civilian, "Left Leg", Vector3.new(1, 2, 1), CFrame.new(-0.5, 1, 0), pantsColor, Enum.Material.Fabric, false)
	local civilianRightLeg = makePart(civilian, "Right Leg", Vector3.new(1, 2, 1), CFrame.new(0.5, 1, 0), pantsColor, Enum.Material.Fabric, false)
	local hair = makePart(civilian, "Hair", Vector3.new(2.08, 0.42, 1.08), CFrame.new(0, 5.08, 0), hairColor, Enum.Material.SmoothPlastic, false)
	for _, bodyPart in ipairs({civilianTorso, civilianHead, civilianLeftArm, civilianRightArm, civilianLeftLeg, civilianRightLeg, hair}) do
		bodyPart.CanCollide = false
		bodyPart.Massless = true
		weldTo(civilianRoot, bodyPart)
	end
	local civilianHumanoid = Instance.new("Humanoid")
	civilianHumanoid.DisplayName = name
	civilianHumanoid.MaxHealth = 80
	civilianHumanoid.Health = 80
	civilianHumanoid.WalkSpeed = 10
	civilianHumanoid.HipHeight = 1
	civilianHumanoid.RequiresNeck = false
	civilianHumanoid.Parent = civilian
	civilian.PrimaryPart = civilianRoot
	civilian.Parent = civilianTemplates
	return civilian
end

makeCivilianTemplate("Maya", Color3.fromRGB(164, 75, 69), Color3.fromRGB(44, 52, 68), Color3.fromRGB(205, 155, 116), Color3.fromRGB(52, 35, 28))
makeCivilianTemplate("Darius", Color3.fromRGB(61, 102, 138), Color3.fromRGB(48, 48, 50), Color3.fromRGB(112, 75, 57), Color3.fromRGB(28, 25, 24))
makeCivilianTemplate("Riley", Color3.fromRGB(76, 128, 88), Color3.fromRGB(73, 61, 50), Color3.fromRGB(231, 190, 151), Color3.fromRGB(113, 72, 41))
makeCivilianTemplate("Jordan", Color3.fromRGB(132, 91, 151), Color3.fromRGB(38, 45, 56), Color3.fromRGB(169, 118, 88), Color3.fromRGB(36, 28, 25))

local map = Instance.new("Model")
map.Name = "Ohio2Map"
map:SetAttribute("ArtRevision", "1.3")
map.Parent = workspace

local drops = Instance.new("Folder")
drops.Name = "Ohio2Drops"
drops.Parent = workspace
local npcs = Instance.new("Folder")
npcs.Name = "Ohio2NPCs"
npcs.Parent = workspace
local vehicles = Instance.new("Folder")
vehicles.Name = "Ohio2Vehicles"
vehicles.Parent = workspace

local baseplate = workspace:FindFirstChild("Baseplate")
if baseplate and baseplate:IsA("BasePart") then
	baseplate.Size = Vector3.new(900, 1, 900)
	baseplate.CFrame = CFrame.new(0, -0.5, 0)
	baseplate.Color = Color3.fromRGB(70, 88, 62)
	baseplate.Material = Enum.Material.Grass
else
	baseplate = makePart(workspace, "Baseplate", Vector3.new(900, 1, 900), CFrame.new(0, -0.5, 0), Color3.fromRGB(70, 88, 62), Enum.Material.Grass)
end

Lighting.ClockTime = 16.15
Lighting.Brightness = 2.25
Lighting.GlobalShadows = true
Lighting.ShadowSoftness = 0.28
Lighting.ExposureCompensation = 0.02
Lighting.Ambient = Color3.fromRGB(96, 100, 108)
Lighting.OutdoorAmbient = Color3.fromRGB(122, 125, 130)
Lighting.EnvironmentDiffuseScale = 0.42
Lighting.EnvironmentSpecularScale = 0.3
pcall(function()
	Lighting.Technology = Enum.Technology.Future
end)

local colorCorrection = Lighting:FindFirstChild("Ohio2Color") or Instance.new("ColorCorrectionEffect")
colorCorrection.Name = "Ohio2Color"
colorCorrection.Brightness = 0.01
colorCorrection.Contrast = 0.09
colorCorrection.Saturation = -0.07
colorCorrection.TintColor = Color3.fromRGB(255, 246, 232)
colorCorrection.Parent = Lighting

local atmosphere = Lighting:FindFirstChild("Ohio2Atmosphere") or Instance.new("Atmosphere")
atmosphere.Name = "Ohio2Atmosphere"
atmosphere.Density = 0.18
atmosphere.Haze = 1.05
atmosphere.Color = Color3.fromRGB(218, 220, 218)
atmosphere.Decay = Color3.fromRGB(126, 119, 109)
atmosphere.Parent = Lighting

local bloom = Lighting:FindFirstChild("Ohio2Bloom") or Instance.new("BloomEffect")
bloom.Name = "Ohio2Bloom"
bloom.Intensity = 0.18
bloom.Size = 22
bloom.Threshold = 1.45
bloom.Parent = Lighting

local sunRays = Lighting:FindFirstChild("Ohio2SunRays") or Instance.new("SunRaysEffect")
sunRays.Name = "Ohio2SunRays"
sunRays.Intensity = 0.035
sunRays.Spread = 0.75
sunRays.Parent = Lighting

local clouds = workspace.Terrain:FindFirstChild("Ohio2Clouds") or Instance.new("Clouds")
clouds.Name = "Ohio2Clouds"
clouds.Cover = 0.36
clouds.Density = 0.28
clouds.Color = Color3.fromRGB(226, 225, 218)
clouds.Parent = workspace.Terrain

local roadColor = Color3.fromRGB(43, 45, 48)
local sidewalkColor = Color3.fromRGB(126, 126, 122)
local laneColor = Color3.fromRGB(222, 183, 70)

local function makeRoad(name, center, length, vertical)
	local roadSize = vertical and Vector3.new(48, 0.35, length) or Vector3.new(length, 0.35, 48)
	makePart(map, name, roadSize, CFrame.new(center.X, 0.03, center.Z), roadColor, Enum.Material.Asphalt)
	for _, side in ipairs({-1, 1}) do
		local gutterCenter = vertical and Vector3.new(center.X + side * 24.7, 0.12, center.Z) or Vector3.new(center.X, 0.12, center.Z + side * 24.7)
		local gutterSize = vertical and Vector3.new(1.4, 0.18, length) or Vector3.new(length, 0.18, 1.4)
		makePart(map, name .. "Gutter", gutterSize, CFrame.new(gutterCenter), Color3.fromRGB(82, 83, 82), Enum.Material.Concrete)
		local curbCenter = vertical and Vector3.new(center.X + side * 25.8, 0.38, center.Z) or Vector3.new(center.X, 0.38, center.Z + side * 25.8)
		local curbSize = vertical and Vector3.new(0.8, 0.75, length) or Vector3.new(length, 0.75, 0.8)
		makePart(map, name .. "Curb", curbSize, CFrame.new(curbCenter), Color3.fromRGB(148, 146, 139), Enum.Material.Concrete)
		local walkCenter = vertical and Vector3.new(center.X + side * 28.5, 0.17, center.Z) or Vector3.new(center.X, 0.17, center.Z + side * 28.5)
		local walkSize = vertical and Vector3.new(9, 0.55, length) or Vector3.new(length, 0.55, 9)
		makePart(map, name .. "Sidewalk", walkSize, CFrame.new(walkCenter), sidewalkColor, Enum.Material.Concrete)
	end
	for distance = -length * 0.5 + 16, length * 0.5 - 16, 28 do
		local markPosition = vertical and Vector3.new(center.X, 0.25, center.Z + distance) or Vector3.new(center.X + distance, 0.25, center.Z)
		local markSize = vertical and Vector3.new(0.62, 0.06, 10) or Vector3.new(10, 0.06, 0.62)
		local mark = makePart(map, name .. "LaneMark", markSize, CFrame.new(markPosition), laneColor, Enum.Material.SmoothPlastic)
		mark.Transparency = math.abs(math.floor(distance / 28)) % 5 == 0 and 0.42 or 0.16
		mark.CanCollide = false
	end
end

makeRoad("CentralAvenue", Vector3.new(0, 0, 0), 840, false)
makeRoad("MarketStreet", Vector3.new(52, 0, 0), 840, true)
makeRoad("FoundryRoad", Vector3.new(0, 0, -240), 840, false)
makeRoad("SouthlineRoad", Vector3.new(0, 0, 240), 840, false)
makeRoad("WestEndStreet", Vector3.new(-250, 0, 0), 840, true)
makeRoad("EastIndustrial", Vector3.new(300, 0, 0), 840, true)

for _, intersection in ipairs({
	Vector3.new(52, 0, 0), Vector3.new(-250, 0, 0), Vector3.new(300, 0, 0),
	Vector3.new(52, 0, -240), Vector3.new(-250, 0, -240), Vector3.new(300, 0, -240),
	Vector3.new(52, 0, 240), Vector3.new(-250, 0, 240), Vector3.new(300, 0, 240),
}) do
	for offset = -18, 18, 6 do
		makePart(map, "CrosswalkStripe", Vector3.new(3.4, 0.09, 10), CFrame.new(intersection + Vector3.new(offset, 0.27, -18)), Color3.fromRGB(218, 218, 210), Enum.Material.SmoothPlastic)
	end
end

local function makeBuilding(name, center, width, depth, height, wallColor, signText, signColor)
	local building = Instance.new("Model")
	building.Name = name
	building.Parent = map
	local floor = makePart(building, "Floor", Vector3.new(width, 0.5, depth), CFrame.new(center.X, 0.25, center.Z), Color3.fromRGB(91, 91, 88), Enum.Material.Concrete)
	makePart(building, "FoundationFront", Vector3.new(width + 1.4, 0.8, 1.2), CFrame.new(center.X, 0.4, center.Z + depth * 0.5), Color3.fromRGB(83, 82, 78), Enum.Material.Concrete)
	makePart(building, "FoundationBack", Vector3.new(width + 1.4, 0.8, 1.2), CFrame.new(center.X, 0.4, center.Z - depth * 0.5), Color3.fromRGB(83, 82, 78), Enum.Material.Concrete)
	makePart(building, "FoundationLeft", Vector3.new(1.2, 0.8, depth), CFrame.new(center.X - width * 0.5, 0.4, center.Z), Color3.fromRGB(83, 82, 78), Enum.Material.Concrete)
	makePart(building, "FoundationRight", Vector3.new(1.2, 0.8, depth), CFrame.new(center.X + width * 0.5, 0.4, center.Z), Color3.fromRGB(83, 82, 78), Enum.Material.Concrete)
	local y = height * 0.5
	makePart(building, "BackWall", Vector3.new(width, height, 1), CFrame.new(center.X, y, center.Z - depth * 0.5), wallColor, Enum.Material.Brick)
	makePart(building, "LeftWall", Vector3.new(1, height, depth), CFrame.new(center.X - width * 0.5, y, center.Z), wallColor, Enum.Material.Brick)
	makePart(building, "RightWall", Vector3.new(1, height, depth), CFrame.new(center.X + width * 0.5, y, center.Z), wallColor, Enum.Material.Brick)
	local frontZ = center.Z + depth * 0.5
	local frontSegment = (width - 9) * 0.5
	makePart(building, "FrontLeft", Vector3.new(frontSegment, height, 1), CFrame.new(center.X - (width + 9) * 0.25, y, frontZ), wallColor, Enum.Material.Brick)
	makePart(building, "FrontRight", Vector3.new(frontSegment, height, 1), CFrame.new(center.X + (width + 9) * 0.25, y, frontZ), wallColor, Enum.Material.Brick)
	makePart(building, "DoorHeader", Vector3.new(9, math.max(1, height - 8), 1), CFrame.new(center.X, 8 + (height - 8) * 0.5, frontZ), wallColor, Enum.Material.Brick)
	local roof = makePart(building, "Roof", Vector3.new(width + 1.5, 0.7, depth + 1.5), CFrame.new(center.X, height + 0.35, center.Z), Color3.fromRGB(47, 48, 51), Enum.Material.Concrete)
	makePart(building, "RoofTrimFront", Vector3.new(width + 2.2, 1.1, 0.9), CFrame.new(center.X, height + 0.55, frontZ + 0.25), Color3.fromRGB(56, 57, 60), Enum.Material.Concrete)
	makePart(building, "RoofTrimBack", Vector3.new(width + 2.2, 1.1, 0.9), CFrame.new(center.X, height + 0.55, center.Z - depth * 0.5 - 0.25), Color3.fromRGB(56, 57, 60), Enum.Material.Concrete)
	makePart(building, "RoofTrimLeft", Vector3.new(0.9, 1.1, depth + 2.2), CFrame.new(center.X - width * 0.5 - 0.25, height + 0.55, center.Z), Color3.fromRGB(56, 57, 60), Enum.Material.Concrete)
	makePart(building, "RoofTrimRight", Vector3.new(0.9, 1.1, depth + 2.2), CFrame.new(center.X + width * 0.5 + 0.25, height + 0.55, center.Z), Color3.fromRGB(56, 57, 60), Enum.Material.Concrete)
	local door = makePart(building, "FrontDoor", Vector3.new(7.2, 7.2, 0.28), CFrame.new(center.X, 3.6, frontZ + 0.18), Color3.fromRGB(74, 105, 115), Enum.Material.Glass)
	door.Transparency = 0.42
	door.CanCollide = false
	local rows = height >= 28 and {8, 18} or {7}
	for _, rowY in ipairs(rows) do
		for x = center.X - width * 0.5 + 7, center.X + width * 0.5 - 7, 12 do
			if math.abs(x - center.X) > 7 or rowY > 10 then
				local window = makePart(building, "Window", Vector3.new(6.2, 4.2, 0.18), CFrame.new(x, rowY, frontZ + 0.56), Color3.fromRGB(92, 126, 137), Enum.Material.Glass)
				window.Transparency = 0.35
				window.CanCollide = false
				makePart(building, "WindowTopTrim", Vector3.new(6.8, 0.28, 0.28), CFrame.new(x, rowY + 2.22, frontZ + 0.68), Color3.fromRGB(42, 44, 48), Enum.Material.Metal).CanCollide = false
				makePart(building, "WindowSill", Vector3.new(6.8, 0.3, 0.55), CFrame.new(x, rowY - 2.2, frontZ + 0.72), Color3.fromRGB(119, 117, 110), Enum.Material.Concrete).CanCollide = false
				makePart(building, "WindowMullion", Vector3.new(0.16, 4.05, 0.24), CFrame.new(x, rowY, frontZ + 0.7), Color3.fromRGB(43, 46, 49), Enum.Material.Metal).CanCollide = false
			end
		end
	end
	for _, side in ipairs({-1, 1}) do
		for z = center.Z - depth * 0.5 + 8, center.Z + depth * 0.5 - 8, 14 do
			local sideWindow = makePart(building, "SideWindow", Vector3.new(0.18, 3.7, 5.4), CFrame.new(center.X + side * (width * 0.5 + 0.56), 8, z), Color3.fromRGB(83, 113, 124), Enum.Material.Glass)
			sideWindow.Transparency = 0.48
			sideWindow.CanCollide = false
		end
		local downspout = makePart(building, "Downspout", Vector3.new(0.38, math.max(8, height - 2), 0.38), CFrame.new(center.X + side * (width * 0.5 + 0.62), height * 0.5, frontZ - 2), Color3.fromRGB(66, 68, 69), Enum.Material.Metal)
		downspout.CanCollide = false
	end
	if height <= 27 then
		local awning = makePart(building, "EntryAwning", Vector3.new(math.min(18, width * 0.38), 0.32, 4.4), CFrame.new(center.X, 9.1, frontZ + 2) * CFrame.Angles(math.rad(-6), 0, 0), signColor, Enum.Material.Fabric)
		awning.CanCollide = false
		for _, x in ipairs({-1, 1}) do
			makePart(building, "AwningBrace", Vector3.new(0.18, 3.8, 0.18), CFrame.new(center.X + x * math.min(7.5, width * 0.16), 7.1, frontZ + 3.75), Color3.fromRGB(57, 59, 61), Enum.Material.Metal).CanCollide = false
		end
	end
	local hvac = makePart(building, "RoofHVAC", Vector3.new(6, 2.8, 5), CFrame.new(center.X + width * 0.25, height + 2.1, center.Z), Color3.fromRGB(94, 98, 101), Enum.Material.Metal)
	for x = -2.1, 2.1, 1.4 do
		makePart(building, "HVACVent", Vector3.new(0.18, 1.8, 5.08), CFrame.new(hvac.Position + Vector3.new(x, 0, 0)), Color3.fromRGB(61, 64, 68), Enum.Material.Metal).CanCollide = false
	end
	local sign = makePart(building, "Sign", Vector3.new(math.min(width - 8, 32), 3, 0.7), CFrame.new(center.X, height - 2.5, frontZ + 0.9), Color3.fromRGB(24, 25, 29), Enum.Material.Metal)
	makeSurfaceSign(sign, signText, signColor, Enum.NormalId.Back, 620, 120, true)
	return building, floor, roof
end

local function makeFacade(name, center, width, depth, height, wallColor, trimColor, shopText)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = map
	makePart(model, "Shell", Vector3.new(width, height, depth), CFrame.new(center.X, height * 0.5, center.Z), wallColor, Enum.Material.Brick)
	local frontZ = center.Z + depth * 0.5
	makePart(model, "StoneBase", Vector3.new(width + 0.3, 2.2, 0.5), CFrame.new(center.X, 1.1, frontZ + 0.27), Color3.fromRGB(89, 87, 82), Enum.Material.Concrete)
	for floorY = 7, height - 5, 10 do
		for x = center.X - width * 0.5 + 5, center.X + width * 0.5 - 5, 9 do
			local window = makePart(model, "RecessedWindow", Vector3.new(5.2, 4.8, 0.22), CFrame.new(x, floorY, frontZ + 0.35), Color3.fromRGB(64, 91, 102), Enum.Material.Glass)
			window.Transparency = 0.38
			window.CanCollide = false
			makePart(model, "WindowLintel", Vector3.new(6, 0.38, 0.55), CFrame.new(x, floorY + 2.65, frontZ + 0.45), trimColor, Enum.Material.Concrete).CanCollide = false
			makePart(model, "WindowSill", Vector3.new(6, 0.3, 0.62), CFrame.new(x, floorY - 2.65, frontZ + 0.48), trimColor, Enum.Material.Concrete).CanCollide = false
		end
	end
	for _, x in ipairs({-1, 1}) do
		makePart(model, "CornerPilaster", Vector3.new(1.25, height + 1.4, 1.25), CFrame.new(center.X + x * (width * 0.5 - 0.4), height * 0.5, frontZ + 0.16), trimColor, Enum.Material.Concrete)
	end
	makePart(model, "ParapetFront", Vector3.new(width + 1.8, 2, 1.2), CFrame.new(center.X, height + 1, center.Z + depth * 0.5), trimColor, Enum.Material.Concrete)
	makePart(model, "ParapetBack", Vector3.new(width + 1.8, 2, 1.2), CFrame.new(center.X, height + 1, center.Z - depth * 0.5), trimColor, Enum.Material.Concrete)
	makePart(model, "ParapetLeft", Vector3.new(1.2, 2, depth), CFrame.new(center.X - width * 0.5, height + 1, center.Z), trimColor, Enum.Material.Concrete)
	makePart(model, "ParapetRight", Vector3.new(1.2, 2, depth), CFrame.new(center.X + width * 0.5, height + 1, center.Z), trimColor, Enum.Material.Concrete)
	makePart(model, "RoofCap", Vector3.new(width + 2.4, 0.35, depth + 2.4), CFrame.new(center.X, height + 1.65, center.Z), Color3.fromRGB(48, 49, 51), Enum.Material.Concrete)
	if shopText then
		local shopSign = makePart(model, "HangingShopSign", Vector3.new(math.min(22, width - 5), 2.8, 0.5), CFrame.new(center.X, 5.8, frontZ + 0.8), Color3.fromRGB(30, 32, 35), Enum.Material.Metal)
		makeSurfaceSign(shopSign, shopText, trimColor, Enum.NormalId.Back, 520, 105, true)
	end
	return model
end

local function makeRowHouse(name, center, bodyColor, doorColor)
	local house = Instance.new("Model")
	house.Name = name
	house.Parent = map
	makePart(house, "Foundation", Vector3.new(28, 1.1, 37), CFrame.new(center.X, 0.55, center.Z), Color3.fromRGB(90, 88, 82), Enum.Material.Concrete)
	makePart(house, "HouseBody", Vector3.new(26, 20, 34), CFrame.new(center.X, 10.5, center.Z), bodyColor, Enum.Material.WoodPlanks)
	makePart(house, "FrontGable", Vector3.new(27, 2.2, 3), CFrame.new(center.X, 21.2, center.Z + 15.7) * CFrame.Angles(math.rad(-18), 0, 0), Color3.fromRGB(62, 62, 60), Enum.Material.Slate)
	makePart(house, "Roof", Vector3.new(29, 1.25, 37), CFrame.new(center.X, 21.5, center.Z) * CFrame.Angles(0, 0, math.rad(2)), Color3.fromRGB(52, 53, 54), Enum.Material.Slate)
	local porch = makePart(house, "Porch", Vector3.new(20, 0.75, 8), CFrame.new(center.X, 1.25, center.Z + 20), Color3.fromRGB(105, 89, 70), Enum.Material.WoodPlanks)
	for _, x in ipairs({-8, 8}) do
		makePart(house, "PorchPost", Vector3.new(0.55, 8, 0.55), CFrame.new(center.X + x, 5.2, center.Z + 22.4), Color3.fromRGB(213, 207, 190), Enum.Material.Wood)
	end
	makePart(house, "PorchRoof", Vector3.new(21, 0.65, 9), CFrame.new(center.X, 9.2, center.Z + 20.3) * CFrame.Angles(math.rad(-5), 0, 0), Color3.fromRGB(57, 58, 58), Enum.Material.Slate)
	makePart(house, "FrontDoor", Vector3.new(4.4, 7.4, 0.32), CFrame.new(center.X, 4.8, center.Z + 17.15), doorColor, Enum.Material.WoodPlanks).CanCollide = false
	for _, x in ipairs({-7, 7}) do
		for _, y in ipairs({6, 15}) do
			local window = makePart(house, "Window", Vector3.new(5.1, 4.5, 0.2), CFrame.new(center.X + x, y, center.Z + 17.2), Color3.fromRGB(89, 122, 132), Enum.Material.Glass)
			window.Transparency = 0.35
			window.CanCollide = false
			makePart(house, "WindowTrim", Vector3.new(5.8, 0.35, 0.4), CFrame.new(center.X + x, y - 2.45, center.Z + 17.35), Color3.fromRGB(220, 214, 195), Enum.Material.Wood).CanCollide = false
		end
	end
	porch.CanCollide = true
	return house
end

local function makeSearchContainer(name, position, tier, containerType)
	local rare = tier == "Rare"
	local size = containerType == "Dumpster" and Vector3.new(6, 3.4, 4) or (containerType == "Safe" and Vector3.new(4, 5, 3) or Vector3.new(5, 5, 5))
	local color = rare and Color3.fromRGB(78, 85, 98) or (containerType == "Dumpster" and Color3.fromRGB(53, 87, 65) or Color3.fromRGB(118, 80, 44))
	local material = containerType == "Crate" and Enum.Material.WoodPlanks or Enum.Material.Metal
	local container = makePart(map, name, size, CFrame.new(position), color, material)
	if containerType == "Dumpster" then
		local lid = makePart(map, name .. "Lid", Vector3.new(6.3, 0.35, 4.3), CFrame.new(position + Vector3.new(0, 1.85, 0)), Color3.fromRGB(42, 68, 51), Enum.Material.Metal)
		lid.CanCollide = false
	elseif containerType == "Safe" then
		local door = makePart(map, name .. "Door", Vector3.new(3.25, 4.15, 0.25), CFrame.new(position + Vector3.new(0, 0, 1.63)), Color3.fromRGB(52, 57, 67), Enum.Material.Metal)
		door.CanCollide = false
	end
	local cooldown = rare and 600 or 300
	local resetText = rare and "10 minute reset" or "5 minute reset"
	makePrompt(container, "Search " .. containerType, (rare and "Rare" or "Street") .. " loot • " .. resetText, "SearchContainer", rare and 2.3 or 1.4, {
		LootTier = tier,
		Cooldown = cooldown,
	})
	makeSurfaceSign(container, rare and "RARE SEARCH SPOT" or "SEARCHABLE", rare and Color3.fromRGB(255, 205, 91) or Color3.fromRGB(110, 232, 154), Enum.NormalId.Back, 420, 100, true)
	return container
end

local store = makeBuilding("QuickStop", Vector3.new(-70, 0, -69), 70, 48, 18, Color3.fromRGB(184, 176, 151), "QUICK STOP", Color3.fromRGB(235, 76, 76))
for row = 0, 2 do
	local shelfZ = -79 + row * 10
	makePart(store, "Shelf", Vector3.new(26, 3.2, 2.5), CFrame.new(-78, 1.85, shelfZ), Color3.fromRGB(103, 79, 58), Enum.Material.WoodPlanks)
	for itemIndex = 0, 7 do
		local productColor = itemIndex % 3 == 0 and Color3.fromRGB(197, 64, 55) or (itemIndex % 3 == 1 and Color3.fromRGB(224, 178, 65) or Color3.fromRGB(74, 128, 174))
		local product = makePart(store, "ShelfProduct", Vector3.new(1.55, 1.25, 1.4), CFrame.new(-89 + itemIndex * 3.1, 3.65, shelfZ), productColor, Enum.Material.SmoothPlastic)
		product.CanCollide = false
	end
end
local cooler = makePart(store, "DrinkCooler", Vector3.new(14, 7, 2.5), CFrame.new(-86, 3.5, -91), Color3.fromRGB(63, 76, 82), Enum.Material.Metal)
for x = -91, -81, 5 do
	local coolerDoor = makePart(store, "CoolerDoor", Vector3.new(4.5, 6.2, 0.25), CFrame.new(x, 3.5, -89.62), Color3.fromRGB(104, 146, 158), Enum.Material.Glass)
	coolerDoor.Transparency = 0.38
	coolerDoor.CanCollide = false
end
local robberyCounter = makePart(store, "RobberyRegister", Vector3.new(8, 3.5, 3), CFrame.new(-47, 1.75, -57), Color3.fromRGB(152, 47, 47), Enum.Material.Metal)
makePrompt(robberyCounter, "Rob Register", "Quick Stop Register • unlocks back-room safe", "RobStore", 6)
makeSurfaceSign(robberyCounter, "RISKY: ROB STORE", Color3.fromRGB(255, 105, 105), Enum.NormalId.Back, 460, 110, true)
local backroomSafe = makePart(store, "QuickStopBackroomSafe", Vector3.new(5.2, 5.6, 3.6), CFrame.new(-96, 2.8, -57), Color3.fromRGB(48, 53, 61), Enum.Material.Metal)
local safeDoor = makePart(store, "QuickStopSafeDoor", Vector3.new(4.35, 4.7, 0.3), CFrame.new(-96, 2.8, -55.05), Color3.fromRGB(63, 69, 78), Enum.Material.Metal)
safeDoor.CanCollide = false
local safeWheel = makePart(store, "QuickStopSafeWheel", Vector3.new(0.4, 1.35, 1.35), CFrame.new(-96, 2.8, -54.82) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(32, 35, 40), Enum.Material.Metal)
safeWheel.Shape = Enum.PartType.Cylinder
safeWheel.CanCollide = false
makePrompt(backroomSafe, "Crack Safe", "Requires register manager code • $1,200–$1,800", "RobStoreSafe", 10)
makeSurfaceSign(backroomSafe, "BACK-ROOM SAFE", Color3.fromRGB(255, 118, 118), Enum.NormalId.Back, 420, 110, true)
local alarmBeacon = makePart(store, "QuickStopAlarmBeacon", Vector3.new(1.25, 1.25, 1.25), CFrame.new(-47, 10.2, -44.25), Color3.fromRGB(230, 45, 45), Enum.Material.Neon)
alarmBeacon.Shape = Enum.PartType.Ball
alarmBeacon.Transparency = 0.65
alarmBeacon.CanCollide = false
local alarmLight = Instance.new("PointLight")
alarmLight.Color = Color3.fromRGB(255, 44, 44)
alarmLight.Range = 34
alarmLight.Brightness = 2.8
alarmLight.Enabled = false
alarmLight.Parent = alarmBeacon
local deliveryCounter = makePart(store, "DeliveryCounter", Vector3.new(8, 2.2, 3), CFrame.new(-59, 1.1, -57), Color3.fromRGB(53, 156, 91), Enum.Material.Metal)
makePrompt(deliveryCounter, "Deliver Package", "Quick Stop Delivery", "CompleteDelivery", 0.5)
makeSurfaceSign(deliveryCounter, "DELIVERY DROP-OFF", Color3.fromRGB(110, 232, 154), Enum.NormalId.Back, 460, 110, true)

local fuelPump = makePart(map, "QuickStopFuelPump", Vector3.new(3.8, 5.4, 3.2), CFrame.new(-102, 2.7, -39), Color3.fromRGB(190, 52, 47), Enum.Material.Metal)
local fuelScreen = makePart(map, "FuelPumpScreen", Vector3.new(2.4, 1.4, 0.18), CFrame.new(-102, 3.3, -37.32), Color3.fromRGB(51, 66, 73), Enum.Material.Glass)
fuelScreen.CanCollide = false
makePrompt(fuelPump, "Fill Owned Vehicle", "$3 per missing fuel unit", "RefuelPersonalVehicle", 1)
makeSurfaceSign(fuelPump, "QUICK STOP FUEL\n$3 / UNIT", Color3.fromRGB(255, 211, 112), Enum.NormalId.Back, 360, 180, true)
for _, x in ipairs({-2.2, 2.2}) do
	local bollard = makePart(map, "FuelPumpBollard", Vector3.new(0.55, 3.2, 0.55), CFrame.new(-102 + x, 1.6, -39), Color3.fromRGB(227, 187, 49), Enum.Material.Metal)
	bollard.Shape = Enum.PartType.Cylinder
end

local warehouse = makeBuilding("Warehouse", Vector3.new(125, 0, -75), 64, 52, 22, Color3.fromRGB(115, 119, 123), "COUNTY COURIER", Color3.fromRGB(255, 157, 72))
local jobDesk = makePart(warehouse, "JobDesk", Vector3.new(10, 3, 4), CFrame.new(125, 1.5, -55), Color3.fromRGB(205, 112, 45), Enum.Material.Metal)
makePrompt(jobDesk, "Start Delivery", "Legal Job • Pays $350", "StartDelivery", 0.6)
makeSurfaceSign(jobDesk, "START LEGAL JOB", Color3.fromRGB(255, 174, 91), Enum.NormalId.Back, 460, 110, true)
for x = 107, 143, 18 do
	makePart(warehouse, "Crate", Vector3.new(7, 7, 7), CFrame.new(x, 3.5, -79), Color3.fromRGB(122, 82, 45), Enum.Material.WoodPlanks)
end

local safehouse = makeBuilding("Safehouse", Vector3.new(-57, 0, 82), 58, 44, 17, Color3.fromRGB(91, 78, 70), "SAFEHOUSE", Color3.fromRGB(107, 169, 255))
local stashDeposit = makePart(safehouse, "StashDeposit", Vector3.new(5, 6, 2), CFrame.new(-70, 3, 95), Color3.fromRGB(50, 75, 107), Enum.Material.Metal)
makePrompt(stashDeposit, "Stash All Gear", "Safe Locker", "DepositStash", 0.5)
makeSurfaceSign(stashDeposit, "STASH GEAR", Color3.fromRGB(107, 169, 255), Enum.NormalId.Back, 360, 120, true)
local stashWithdraw = makePart(safehouse, "StashWithdraw", Vector3.new(5, 6, 2), CFrame.new(-57, 3, 95), Color3.fromRGB(52, 92, 73), Enum.Material.Metal)
makePrompt(stashWithdraw, "Withdraw All Gear", "Safe Locker", "WithdrawStash", 0.5)
makeSurfaceSign(stashWithdraw, "GET GEAR", Color3.fromRGB(110, 232, 154), Enum.NormalId.Back, 360, 120, true)
local atmDeposit = makePart(safehouse, "ATMDeposit", Vector3.new(4, 6, 2), CFrame.new(-44, 3, 95), Color3.fromRGB(55, 58, 67), Enum.Material.Metal)
makePrompt(atmDeposit, "Deposit Up To $500", "ATM • Bank cash is safe", "DepositBank", 0.4)
makeSurfaceSign(atmDeposit, "DEPOSIT", Color3.fromRGB(107, 169, 255), Enum.NormalId.Back, 300, 120, true)
local atmWithdraw = makePart(safehouse, "ATMWithdraw", Vector3.new(4, 6, 2), CFrame.new(-35, 3, 95), Color3.fromRGB(55, 58, 67), Enum.Material.Metal)
makePrompt(atmWithdraw, "Withdraw Up To $500", "ATM", "WithdrawBank", 0.4)
makeSurfaceSign(atmWithdraw, "WITHDRAW", Color3.fromRGB(245, 245, 245), Enum.NormalId.Back, 300, 120, true)

local pawn = makeBuilding("PawnShop", Vector3.new(-148, 0, 82), 54, 44, 17, Color3.fromRGB(116, 101, 75), "PAWN & TOOL", Color3.fromRGB(255, 205, 91))
local productInfo = {
	{Id = "Bat", Label = "BAT", X = -169, Color = Color3.fromRGB(132, 91, 55)},
	{Id = "Pistol", Label = "PISTOL", X = -160, Color = Color3.fromRGB(56, 60, 68)},
	{Id = "PistolAmmo", Label = "9MM AMMO", X = -151, Color = Color3.fromRGB(190, 159, 75)},
	{Id = "Shotgun", Label = "SHOTGUN", X = -142, Color = Color3.fromRGB(74, 59, 48)},
	{Id = "Shells", Label = "SHELLS", X = -133, Color = Color3.fromRGB(174, 48, 44)},
	{Id = "Medkit", Label = "MEDKIT", X = -124, Color = Color3.fromRGB(191, 48, 48)},
}
local displayedPrices = {Bat = 150, Pistol = 500, PistolAmmo = 60, Shotgun = 950, Shells = 90, Medkit = 100}
for _, product in ipairs(productInfo) do
	local stand = makePart(pawn, product.Id .. "Stand", Vector3.new(7.5, 3, 5), CFrame.new(product.X, 1.5, 94), product.Color, Enum.Material.Metal)
	makePrompt(stand, "Buy " .. product.Label, "$" .. displayedPrices[product.Id], "BuyItem", 0.4, {ItemId = product.Id})
	makeSurfaceSign(stand, product.Label .. "  $" .. displayedPrices[product.Id], Color3.fromRGB(255, 222, 118), Enum.NormalId.Top, 320, 180, false)
end

local policeStation = makeBuilding("PoliceStation", Vector3.new(128, 0, 84), 72, 48, 21, Color3.fromRGB(91, 104, 123), "COUNTY POLICE", Color3.fromRGB(105, 169, 255))
local policeSpawn1 = makePart(map, "PoliceSpawn1", Vector3.new(2, 1, 2), CFrame.new(110, 0.5, 104), Color3.fromRGB(65, 113, 179), Enum.Material.Neon)
policeSpawn1.Transparency = 1
policeSpawn1.CanCollide = false
local policeSpawn2 = makePart(map, "PoliceSpawn2", Vector3.new(2, 1, 2), CFrame.new(146, 0.5, 104), Color3.fromRGB(65, 113, 179), Enum.Material.Neon)
policeSpawn2.Transparency = 1
policeSpawn2.CanCollide = false
for index, position in ipairs({
	Vector3.new(-30, 0.5, -110),
	Vector3.new(52, 0.5, -190),
	Vector3.new(-222, 0.5, 160),
	Vector3.new(272, 0.5, 160),
}) do
	local responseSpawn = makePart(map, "PoliceResponseSpawn" .. (index + 2), Vector3.new(2, 1, 2), CFrame.new(position), Color3.fromRGB(65, 113, 179), Enum.Material.Neon)
	responseSpawn.Transparency = 1
	responseSpawn.CanCollide = false
end
local jailSpawn = makePart(map, "JailSpawn", Vector3.new(3, 0.5, 3), CFrame.new(128, 0.25, 78), Color3.fromRGB(105, 169, 255), Enum.Material.Neon)
jailSpawn.Transparency = 0.65
jailSpawn.CanCollide = false
for x = 117, 139, 2.75 do
	if math.abs(x - 128) > 3 then
		makePart(policeStation, "JailBar", Vector3.new(0.3, 9, 0.3), CFrame.new(x, 4.5, 92), Color3.fromRGB(74, 79, 88), Enum.Material.Metal)
	end
end
makeSurfaceSign(jailSpawn, "COUNTY JAIL", Color3.fromRGB(105, 169, 255), Enum.NormalId.Top, 360, 100, false)

local checkpoint = Instance.new("Model")
checkpoint.Name = "FoundryRoadPoliceCheckpoint"
checkpoint.Parent = map
for _, x in ipairs({39, 65}) do
	local barrier = makePart(checkpoint, "CheckpointBarrier", Vector3.new(15, 1.25, 0.8), CFrame.new(x, 1.1, -190), Color3.fromRGB(226, 226, 216), Enum.Material.Metal)
	makePart(checkpoint, "BarrierStripe", Vector3.new(15.1, 0.3, 0.84), CFrame.new(x, 1.1, -190.03), Color3.fromRGB(207, 54, 50), Enum.Material.Neon).CanCollide = false
	for _, legX in ipairs({-5.5, 5.5}) do
		makePart(checkpoint, "BarrierLeg", Vector3.new(0.55, 2, 1.8), CFrame.new(x + legX, 0.75, -190), Color3.fromRGB(54, 57, 62), Enum.Material.Metal)
	end
	barrier.CanCollide = true
end
local checkpointBooth = makePart(checkpoint, "CheckpointBooth", Vector3.new(8, 8, 7), CFrame.new(82, 4, -190), Color3.fromRGB(61, 76, 93), Enum.Material.Metal)
makeSurfaceSign(checkpointBooth, "POLICE CHECKPOINT", Color3.fromRGB(126, 181, 255), Enum.NormalId.Front, 440, 150, true)
for _, coneX in ipairs({48, 56}) do
	local cone = makePart(checkpoint, "TrafficCone", Vector3.new(1.2, 2.5, 1.2), CFrame.new(coneX, 1.25, -183), Color3.fromRGB(232, 111, 35), Enum.Material.SmoothPlastic)
	cone.CanCollide = false
end

local function makeParkingLot(name, center, width, depth, spaces)
	local lot = makePart(map, name, Vector3.new(width, 0.22, depth), CFrame.new(center.X, 0.04, center.Z), Color3.fromRGB(55, 57, 60), Enum.Material.Asphalt)
	for index = 0, spaces - 1 do
		local x = center.X - width * 0.5 + 6 + index * ((width - 12) / math.max(1, spaces - 1))
		makePart(map, name .. "Stripe", Vector3.new(0.22, 0.06, math.min(16, depth - 4)), CFrame.new(x, 0.18, center.Z), Color3.fromRGB(218, 214, 193), Enum.Material.SmoothPlastic)
	end
	return lot
end

local function makeFenceRectangle(name, center, width, depth)
	for x = center.X - width * 0.5, center.X + width * 0.5, 12 do
		for _, z in ipairs({center.Z - depth * 0.5, center.Z + depth * 0.5}) do
			makePart(map, name .. "Post", Vector3.new(0.25, 6, 0.25), CFrame.new(x, 3, z), Color3.fromRGB(85, 88, 91), Enum.Material.Metal)
		end
	end
	for z = center.Z - depth * 0.5, center.Z + depth * 0.5, 12 do
		for _, x in ipairs({center.X - width * 0.5, center.X + width * 0.5}) do
			makePart(map, name .. "Post", Vector3.new(0.25, 6, 0.25), CFrame.new(x, 3, z), Color3.fromRGB(85, 88, 91), Enum.Material.Metal)
		end
	end
	for _, z in ipairs({center.Z - depth * 0.5, center.Z + depth * 0.5}) do
		for _, y in ipairs({1.1, 3.1, 5.1}) do
			makePart(map, name .. "Rail", Vector3.new(width, 0.12, 0.12), CFrame.new(center.X, y, z), Color3.fromRGB(108, 111, 113), Enum.Material.Metal).CanCollide = false
		end
	end
	for _, x in ipairs({center.X - width * 0.5, center.X + width * 0.5}) do
		for _, y in ipairs({1.1, 3.1, 5.1}) do
			makePart(map, name .. "Rail", Vector3.new(0.12, 0.12, depth), CFrame.new(x, y, center.Z), Color3.fromRGB(108, 111, 113), Enum.Material.Metal).CanCollide = false
		end
	end
end

local function makeWreck(name, position, color)
	local wreck = Instance.new("Model")
	wreck.Name = name
	wreck.Parent = map
	local body = makePart(wreck, "RustedBody", Vector3.new(6.8, 2.1, 10.5), CFrame.new(position + Vector3.new(0, 1.65, 0)), color, Enum.Material.CorrodedMetal)
	makePart(wreck, "Cabin", Vector3.new(6.1, 2.2, 5.1), CFrame.new(position + Vector3.new(0, 3.4, 0.5)), Color3.fromRGB(75, 84, 86), Enum.Material.CorrodedMetal)
	for _, offset in ipairs({Vector3.new(-3.55, 0.9, -3.3), Vector3.new(3.55, 0.9, -3.3), Vector3.new(-3.55, 0.9, 3.3), Vector3.new(3.55, 0.9, 3.3)}) do
		local tire = makePart(wreck, "FlatTire", Vector3.new(1.15, 2.6, 2.6), CFrame.new(position + offset) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(24, 24, 25), Enum.Material.Rubber)
		tire.Shape = Enum.PartType.Cylinder
	end
	return body
end

local function makeCargoContainer(name, position, color)
	local container = makePart(map, name, Vector3.new(8, 8, 20), CFrame.new(position + Vector3.new(0, 4, 0)), color, Enum.Material.Metal)
	for x = -3, 3, 1.5 do
		makePart(map, name .. "Rib", Vector3.new(0.16, 7.8, 20.1), CFrame.new(position + Vector3.new(x, 4, 0)), Color3.fromRGB(55, 57, 60), Enum.Material.Metal).CanCollide = false
	end
	makePart(map, name .. "DoorLine", Vector3.new(7.6, 0.16, 0.18), CFrame.new(position + Vector3.new(0, 4, 10.08)), Color3.fromRGB(36, 38, 41), Enum.Material.Metal).CanCollide = false
	return container
end

local function makeStreetSign(position, lineOne, lineTwo)
	local post = makePart(map, "StreetSignPost", Vector3.new(0.35, 9, 0.35), CFrame.new(position + Vector3.new(0, 4.5, 0)), Color3.fromRGB(56, 59, 62), Enum.Material.Metal)
	local sign = makePart(map, "StreetSign", Vector3.new(8, 1.6, 0.35), CFrame.new(position + Vector3.new(0, 8.3, 0)), Color3.fromRGB(38, 82, 60), Enum.Material.Metal)
	makeSurfaceSign(sign, lineOne .. "\n" .. lineTwo, Color3.fromRGB(239, 242, 235), Enum.NormalId.Back, 440, 120, true)
	return post
end

local function makeRoadsideBillboard(name, position, rotation, headline, message, accentColor)
	local structure = Instance.new("Model")
	structure.Name = name
	structure.Parent = map
	local baseCFrame = CFrame.new(position) * CFrame.Angles(0, math.rad(rotation or 0), 0)
	for _, x in ipairs({-8.5, 8.5}) do
		makePart(structure, "ConcreteFooting", Vector3.new(2.4, 1.2, 2.4), baseCFrame * CFrame.new(x, 0.6, 0), Color3.fromRGB(110, 110, 105), Enum.Material.Concrete)
		makePart(structure, "SteelPost", Vector3.new(0.8, 12, 0.8), baseCFrame * CFrame.new(x, 6.5, 0), Color3.fromRGB(59, 62, 65), Enum.Material.Metal)
	end
	local board = makePart(structure, "BillboardFace", Vector3.new(28, 11, 0.85), baseCFrame * CFrame.new(0, 13.5, 0), Color3.fromRGB(24, 26, 29), Enum.Material.Metal)
	makePart(structure, "BillboardTopTrim", Vector3.new(29, 0.7, 1.1), baseCFrame * CFrame.new(0, 19.2, 0), accentColor, Enum.Material.Metal)
	makeSurfaceSign(board, headline .. "\n" .. message, accentColor, Enum.NormalId.Front, 900, 350, true)
	return structure
end

local function makeUtilityLine(name, positions)
	local previousAttachments
	for index, position in ipairs(positions) do
		local poleModel = Instance.new("Model")
		poleModel.Name = name .. "Pole" .. index
		poleModel.Parent = map
		makePart(poleModel, "Pole", Vector3.new(0.72, 23, 0.72), CFrame.new(position + Vector3.new(0, 11.5, 0)), Color3.fromRGB(78, 57, 43), Enum.Material.Wood)
		local crossarm = makePart(poleModel, "Crossarm", Vector3.new(8.4, 0.42, 0.5), CFrame.new(position + Vector3.new(0, 21.2, 0)), Color3.fromRGB(64, 48, 38), Enum.Material.Wood)
		local attachments = {}
		for wireIndex, x in ipairs({-3, 0, 3}) do
			local insulator = makePart(poleModel, "Insulator", Vector3.new(0.32, 0.65, 0.32), CFrame.new(position + Vector3.new(x, 21.75, 0)), Color3.fromRGB(148, 154, 150), Enum.Material.Glass)
			insulator.Shape = Enum.PartType.Cylinder
			insulator.CanCollide = false
			local attachment = Instance.new("Attachment")
			attachment.Name = "WireAttachment" .. wireIndex
			attachment.Position = Vector3.new(0, 0.32, 0)
			attachment.Parent = insulator
			attachments[wireIndex] = attachment
			if previousAttachments then
				local wire = Instance.new("Beam")
				wire.Name = name .. "Wire"
				wire.Attachment0 = previousAttachments[wireIndex]
				wire.Attachment1 = attachment
				wire.Color = ColorSequence.new(Color3.fromRGB(38, 39, 40))
				wire.Width0 = 0.08
				wire.Width1 = 0.08
				wire.Segments = 12
				wire.CurveSize0 = -2.2
				wire.CurveSize1 = 2.2
				wire.FaceCamera = true
				wire.Parent = crossarm
			end
		end
		previousAttachments = attachments
	end
end

local function makePlanter(name, position, length)
	local planter = Instance.new("Model")
	planter.Name = name
	planter.Parent = map
	makePart(planter, "ConcreteBox", Vector3.new(length, 2.2, 4), CFrame.new(position + Vector3.new(0, 1.1, 0)), Color3.fromRGB(113, 109, 101), Enum.Material.Concrete)
	makePart(planter, "Soil", Vector3.new(length - 0.8, 0.25, 3.2), CFrame.new(position + Vector3.new(0, 2.28, 0)), Color3.fromRGB(67, 49, 34), Enum.Material.Ground).CanCollide = false
	for x = -length * 0.35, length * 0.35, math.max(2.8, length * 0.35) do
		local shrub = makePart(planter, "Shrub", Vector3.new(3.4, 3.2, 3.4), CFrame.new(position + Vector3.new(x, 3.45, 0)), Color3.fromRGB(62, 101, 58), Enum.Material.Grass)
		shrub.Shape = Enum.PartType.Ball
		shrub.CanCollide = false
	end
end

-- Authored infill establishes distinct downtown, residential, and industrial blocks.
makeFacade("UnionPharmacy", Vector3.new(210, 0, -82), 52, 42, 30, Color3.fromRGB(143, 119, 95), Color3.fromRGB(214, 207, 187), "UNION PHARMACY")
makeFacade("LakeviewHardware", Vector3.new(210, 0, 84), 52, 42, 26, Color3.fromRGB(116, 90, 73), Color3.fromRGB(208, 177, 115), "LAKEVIEW HARDWARE")
makeFacade("OldBrickOffices", Vector3.new(-195, 0, -72), 34, 38, 32, Color3.fromRGB(122, 77, 62), Color3.fromRGB(190, 169, 140), "VACANCY")
makeFacade("CanalSupply", Vector3.new(-195, 0, 82), 34, 40, 24, Color3.fromRGB(99, 94, 80), Color3.fromRGB(204, 151, 71), "CANAL SUPPLY")
makeFacade("HuronMachineWorks", Vector3.new(220, 0, -145), 52, 48, 22, Color3.fromRGB(92, 96, 94), Color3.fromRGB(154, 159, 154), "HURON MACHINE WORKS")
makeFacade("EastOhioStorage", Vector3.new(382, 0, -340), 68, 50, 24, Color3.fromRGB(102, 91, 76), Color3.fromRGB(171, 126, 66), "EAST OHIO STORAGE")

makeRowHouse("WestEndHouseA", Vector3.new(-310, 0, 57), Color3.fromRGB(132, 119, 96), Color3.fromRGB(89, 63, 48))
makeRowHouse("WestEndHouseB", Vector3.new(-310, 0, 190), Color3.fromRGB(111, 126, 122), Color3.fromRGB(65, 83, 78))
makeRowHouse("WestEndHouseC", Vector3.new(-195, 0, 145), Color3.fromRGB(139, 105, 88), Color3.fromRGB(92, 57, 48))
makeRowHouse("WestEndHouseD", Vector3.new(-195, 0, 190), Color3.fromRGB(112, 116, 132), Color3.fromRGB(55, 66, 86))

makePlanter("CivicPlanterA", Vector3.new(-8, 0, 74), 13)
makePlanter("CivicPlanterB", Vector3.new(12, 0, 74), 13)
makeUtilityLine("WestEndPower", {
	Vector3.new(-291, 0, -395), Vector3.new(-291, 0, -270), Vector3.new(-291, 0, -145),
	Vector3.new(-291, 0, -20), Vector3.new(-291, 0, 105), Vector3.new(-291, 0, 230), Vector3.new(-291, 0, 355),
})
makeUtilityLine("IndustrialPower", {
	Vector3.new(330, 0, -395), Vector3.new(330, 0, -270), Vector3.new(330, 0, -145),
	Vector3.new(330, 0, -20), Vector3.new(330, 0, 105), Vector3.new(330, 0, 230), Vector3.new(330, 0, 355),
})

local clinic = makeBuilding("CountyClinic", Vector3.new(-140, 0, -145), 80, 56, 22, Color3.fromRGB(178, 184, 181), "COUNTY CLINIC", Color3.fromRGB(255, 103, 103))
makeParkingLot("ClinicParking", Vector3.new(-140, 0, -105), 78, 24, 8)
local clinicDesk = makePart(clinic, "ClinicDesk", Vector3.new(12, 3.2, 3), CFrame.new(-140, 1.6, -120), Color3.fromRGB(78, 111, 116), Enum.Material.Metal)
makePrompt(clinicDesk, "Receive Treatment", "County Clinic • Full heal $75", "ClinicHeal", 1.2)
makeSurfaceSign(clinicDesk, "MEDICAL TREATMENT  $75", Color3.fromRGB(255, 130, 130), Enum.NormalId.Back, 480, 110, true)
local medicalCourierDesk = makePart(clinic, "MedicalCourierDesk", Vector3.new(8, 2.5, 3), CFrame.new(-121, 1.25, -120), Color3.fromRGB(60, 126, 102), Enum.Material.Metal)
makePrompt(medicalCourierDesk, "Take Medical Run", "Deliver supplies to Fire Station 17 • $575", "StartRouteJob", 0.8, {
	JobId = "MedicalRun",
	JobName = "Medical supply run",
	ObjectiveText = "MEDICAL RUN: Deliver the emergency supplies to Fire Station 17 in the west district.",
	Reward = 575,
})
makeSurfaceSign(medicalCourierDesk, "MEDICAL COURIER  $575", Color3.fromRGB(110, 232, 154), Enum.NormalId.Back, 480, 110, true)
makePart(clinic, "ClinicCrossVertical", Vector3.new(2.2, 8, 0.7), CFrame.new(-140, 15, -116.4), Color3.fromRGB(203, 55, 55), Enum.Material.Neon).CanCollide = false
makePart(clinic, "ClinicCrossHorizontal", Vector3.new(7, 2.2, 0.72), CFrame.new(-140, 15, -116.35), Color3.fromRGB(203, 55, 55), Enum.Material.Neon).CanCollide = false
for x = -165, -115, 25 do
	local bed = makePart(clinic, "TreatmentBed", Vector3.new(8, 1.2, 3.4), CFrame.new(x, 1.1, -147), Color3.fromRGB(215, 218, 213), Enum.Material.Fabric)
	makePart(clinic, "Pillow", Vector3.new(1.8, 0.55, 3), CFrame.new(bed.Position + Vector3.new(-2.6, 0.82, 0)), Color3.fromRGB(235, 236, 229), Enum.Material.Fabric)
	local monitor = makePart(clinic, "PatientMonitor", Vector3.new(0.6, 3.6, 2.2), CFrame.new(x + 5.2, 2.1, -147), Color3.fromRGB(55, 61, 66), Enum.Material.Metal)
	makeSurfaceSign(monitor, "♥  76\nO₂  98", Color3.fromRGB(101, 236, 158), Enum.NormalId.Right, 240, 260, false)
end
for x = -152.5, -127.5, 25 do
	local curtain = makePart(clinic, "PrivacyCurtain", Vector3.new(0.18, 7, 16), CFrame.new(x, 3.5, -147), Color3.fromRGB(179, 207, 205), Enum.Material.Fabric)
	curtain.Transparency = 0.2
	curtain.CanCollide = false
end

local motel = makeBuilding("RiversideMotel", Vector3.new(-125, 0, -335), 102, 58, 27, Color3.fromRGB(155, 137, 116), "RIVERSIDE MOTOR LODGE", Color3.fromRGB(255, 183, 91))
makeParkingLot("MotelParking", Vector3.new(-125, 0, -294), 100, 24, 10)
local balcony = makePart(motel, "SecondFloorBalcony", Vector3.new(98, 0.65, 7), CFrame.new(-125, 13.5, -302.5), Color3.fromRGB(93, 92, 87), Enum.Material.Concrete)
for x = -168, -82, 14.3 do
	makePart(motel, "RoomDoor", Vector3.new(5.2, 7.3, 0.3), CFrame.new(x, 17, -305.7), Color3.fromRGB(63, 89, 91), Enum.Material.WoodPlanks).CanCollide = false
	makePart(motel, "BalconyPost", Vector3.new(0.28, 13, 0.28), CFrame.new(x + 5.8, 7, -300), Color3.fromRGB(75, 76, 77), Enum.Material.Metal)
end
makeSurfaceSign(balcony, "ROOMS • ROOFTOP VANTAGE", Color3.fromRGB(255, 197, 114), Enum.NormalId.Front, 620, 110, true)

local foundry = makeBuilding("BuckeyeFoundry", Vector3.new(165, 0, -340), 118, 72, 34, Color3.fromRGB(105, 91, 78), "BUCKEYE FOUNDRY", Color3.fromRGB(255, 132, 76))
makeParkingLot("FoundryLoadingLot", Vector3.new(165, 0, -290), 115, 26, 9)
local foundryDispatch = makePart(foundry, "FoundryDispatch", Vector3.new(11, 3, 4), CFrame.new(165, 1.5, -307), Color3.fromRGB(170, 91, 48), Enum.Material.Metal)
makePrompt(foundryDispatch, "Take Rail Freight", "Haul foundry parts to Southline Rail Yard • $700", "StartRouteJob", 0.8, {
	JobId = "FoundryFreight",
	JobName = "Foundry freight haul",
	ObjectiveText = "FREIGHT HAUL: Deliver the foundry parts to the orange receiver at Southline Rail Yard.",
	Reward = 700,
})
makeSurfaceSign(foundryDispatch, "FOUNDRY FREIGHT  $700", Color3.fromRGB(255, 153, 84), Enum.NormalId.Back, 480, 110, true)
for x = 130, 200, 35 do
	local stack = makePart(foundry, "SmokeStack", Vector3.new(24, 5.5, 5.5), CFrame.new(x, 45, -350) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(74, 65, 59), Enum.Material.Brick)
	stack.Shape = Enum.PartType.Cylinder
	local smoke = Instance.new("Smoke")
	smoke.Color = Color3.fromRGB(88, 85, 82)
	smoke.Opacity = 0.18
	smoke.RiseVelocity = 3
	smoke.Size = 7
	smoke.Parent = stack
end
for x = 120, 210, 30 do
	makePart(foundry, "Machine", Vector3.new(12, 7, 9), CFrame.new(x, 3.5, -344), Color3.fromRGB(72, 76, 77), Enum.Material.CorrodedMetal)
end

local autoShop = makeBuilding("RustBeltAuto", Vector3.new(375, 0, -135), 78, 60, 23, Color3.fromRGB(121, 125, 123), "RUST BELT AUTO", Color3.fromRGB(102, 192, 255))
makeParkingLot("AutoShopLot", Vector3.new(375, 0, -91), 76, 26, 7)
local salvageReceiver = makePart(autoShop, "SalvageReceiver", Vector3.new(10, 3, 4), CFrame.new(375, 1.5, -108), Color3.fromRGB(70, 116, 145), Enum.Material.Metal)
makePrompt(salvageReceiver, "Deliver Salvage", "Rust Belt Auto receiving bay", "CompleteRouteJob", 0.8, {
	JobId = "SalvageRun",
})
makeSurfaceSign(salvageReceiver, "SALVAGE DROP-OFF", Color3.fromRGB(107, 169, 255), Enum.NormalId.Back, 460, 110, true)
local towDispatch = makePart(autoShop, "TowDispatch", Vector3.new(10, 3, 4), CFrame.new(354, 1.5, -108), Color3.fromRGB(181, 113, 48), Enum.Material.Metal)
makePrompt(towDispatch, "Start Tow Call", "Recover a disabled vehicle • $650–$750", "StartTowJob", 0.8)
makeSurfaceSign(towDispatch, "TOW DISPATCH", Color3.fromRGB(255, 187, 91), Enum.NormalId.Back, 460, 110, true)
local towReceiver = makePart(map, "TowReturnBay", Vector3.new(13, 1.1, 9), CFrame.new(340, 0.55, -83), Color3.fromRGB(57, 111, 151), Enum.Material.Metal)
makePrompt(towReceiver, "Deliver Disabled Car", "Rust Belt Auto tow return", "CompleteTowJob", 1.2)
makeSurfaceSign(towReceiver, "TOW RETURN BAY", Color3.fromRGB(123, 190, 255), Enum.NormalId.Top, 520, 220, false)
for x = 350, 400, 25 do
	local garageDoor = makePart(autoShop, "GarageDoor", Vector3.new(19, 12, 0.35), CFrame.new(x, 6, -104.6), Color3.fromRGB(78, 83, 87), Enum.Material.Metal)
	for y = 1.5, 10.5, 1.5 do
		makePart(autoShop, "GarageDoorSeam", Vector3.new(19.1, 0.12, 0.4), CFrame.new(x, y, -104.82), Color3.fromRGB(45, 48, 51), Enum.Material.Metal).CanCollide = false
	end
	garageDoor.CanCollide = false
end
makeWreck("MechanicProjectCar", Vector3.new(376, 0, -137), Color3.fromRGB(88, 46, 39))
for _, liftX in ipairs({361, 389}) do
	for _, offsetX in ipairs({-4.2, 4.2}) do
		makePart(autoShop, "VehicleLiftPost", Vector3.new(0.8, 8, 0.8), CFrame.new(liftX + offsetX, 4, -139), Color3.fromRGB(63, 91, 111), Enum.Material.Metal)
	end
	makePart(autoShop, "VehicleLiftArm", Vector3.new(10, 0.45, 1), CFrame.new(liftX, 1.1, -139), Color3.fromRGB(84, 119, 143), Enum.Material.Metal)
end
for x = 345, 405, 20 do
	local cabinet = makePart(autoShop, "ToolCabinet", Vector3.new(6, 5.5, 2), CFrame.new(x, 2.75, -156), Color3.fromRGB(151, 43, 40), Enum.Material.Metal)
	makeSurfaceSign(cabinet, "TOOLS", Color3.fromRGB(245, 215, 175), Enum.NormalId.Back, 260, 180, false)
end
local vehicleSalesTerminal = makePart(autoShop, "VehicleSalesTerminal", Vector3.new(5, 4.2, 2.4), CFrame.new(343, 2.1, -126), Color3.fromRGB(52, 96, 126), Enum.Material.Metal)
makePrompt(vehicleSalesTerminal, "Buy Rust Compact", "$3,500 wallet cash • permanent ownership", "BuyPersonalVehicle", 1)
makeSurfaceSign(vehicleSalesTerminal, "VEHICLE SALES\nRUST COMPACT  $3,500", Color3.fromRGB(126, 198, 255), Enum.NormalId.Right, 420, 220, true)
local personalGarageTerminal = makePart(autoShop, "PersonalGarageTerminal", Vector3.new(5, 4.2, 2.4), CFrame.new(343, 2.1, -138), Color3.fromRGB(54, 117, 85), Enum.Material.Metal)
makePrompt(personalGarageTerminal, "Spawn / Store Vehicle", "Personal garage terminal", "GaragePersonalVehicle", 0.8)
makeSurfaceSign(personalGarageTerminal, "PERSONAL GARAGE\nSPAWN / STORE", Color3.fromRGB(110, 232, 154), Enum.NormalId.Right, 420, 220, true)
local repairTerminal = makePart(autoShop, "VehicleRepairTerminal", Vector3.new(5, 4.2, 2.4), CFrame.new(343, 2.1, -150), Color3.fromRGB(151, 72, 48), Enum.Material.Metal)
makePrompt(repairTerminal, "Repair Owned Vehicle", "$8 per missing condition • $50 minimum", "RepairPersonalVehicle", 1.2)
makeSurfaceSign(repairTerminal, "SERVICE BAY\nFULL REPAIR", Color3.fromRGB(255, 174, 91), Enum.NormalId.Right, 420, 220, true)
local personalVehicleSpawn = makePart(map, "PersonalVehicleSpawn", Vector3.new(13, 0.5, 22), CFrame.new(375, 0.25, -73) * CFrame.Angles(0, math.rad(180), 0), Color3.fromRGB(68, 130, 176), Enum.Material.Neon)
personalVehicleSpawn.Transparency = 0.62
personalVehicleSpawn.CanCollide = false
makeSurfaceSign(personalVehicleSpawn, "PERSONAL VEHICLE SPAWN", Color3.fromRGB(151, 211, 255), Enum.NormalId.Top, 520, 180, false)

for _, towData in ipairs({
	{Id = "Motel", Name = "Riverside Motel parking lot", Position = Vector3.new(-164, 0, -292), Color = Color3.fromRGB(99, 68, 50)},
	{Id = "Apartments", Name = "West End Apartments parking lot", Position = Vector3.new(-398, 0, 178), Color = Color3.fromRGB(70, 79, 92)},
	{Id = "Clinic", Name = "County Clinic parking lot", Position = Vector3.new(-110, 0, -105), Color = Color3.fromRGB(91, 86, 65)},
}) do
	local towBody = makeWreck("TowTarget" .. towData.Id, towData.Position, towData.Color)
	makePrompt(towBody, "Secure Tow Cable", towData.Name, "RecoverTowVehicle", 2.2, {
		TargetId = towData.Id,
		LocationName = towData.Name,
	})
	makeSurfaceSign(towBody, "DISABLED VEHICLE", Color3.fromRGB(255, 174, 91), Enum.NormalId.Top, 420, 120, false)
end

local fireStation = makeBuilding("FireStation", Vector3.new(-365, 0, -125), 86, 62, 25, Color3.fromRGB(160, 68, 59), "FIRE STATION 17", Color3.fromRGB(255, 231, 169))
makeParkingLot("FireStationApron", Vector3.new(-365, 0, -80), 84, 28, 6)
local medicalReceiver = makePart(fireStation, "MedicalReceiver", Vector3.new(10, 3, 4), CFrame.new(-365, 1.5, -98), Color3.fromRGB(173, 57, 53), Enum.Material.Metal)
makePrompt(medicalReceiver, "Deliver Supplies", "Fire Station 17 emergency receiving", "CompleteRouteJob", 0.8, {
	JobId = "MedicalRun",
})
makeSurfaceSign(medicalReceiver, "MEDICAL DROP-OFF", Color3.fromRGB(255, 130, 130), Enum.NormalId.Back, 460, 110, true)
for x = -385, -345, 40 do
	local bay = makePart(fireStation, "ApparatusBay", Vector3.new(28, 15, 0.32), CFrame.new(x, 7.5, -93.6), Color3.fromRGB(80, 84, 86), Enum.Material.Metal)
	bay.CanCollide = false
	for y = 1.5, 13.5, 2 do
		makePart(fireStation, "BaySeam", Vector3.new(28.2, 0.13, 0.38), CFrame.new(x, y, -93.82), Color3.fromRGB(43, 45, 48), Enum.Material.Metal).CanCollide = false
	end
end

local apartments = makeBuilding("WestEndApartments", Vector3.new(-355, 0, 125), 108, 72, 44, Color3.fromRGB(130, 112, 96), "WEST END APARTMENTS", Color3.fromRGB(214, 190, 159))
makeParkingLot("ApartmentParking", Vector3.new(-355, 0, 177), 104, 27, 11)
for floorY = 10, 34, 12 do
	local landing = makePart(apartments, "FireEscapeLanding", Vector3.new(18, 0.5, 5), CFrame.new(-402, floorY, 164), Color3.fromRGB(55, 58, 60), Enum.Material.Metal)
	for index = 0, 6 do
		makePart(apartments, "FireEscapeRail", Vector3.new(0.18, 3.5, 0.18), CFrame.new(-410 + index * 2.7, floorY + 1.75, 166.3), Color3.fromRGB(67, 70, 72), Enum.Material.Metal).CanCollide = false
	end
	landing.CanCollide = true
end

local junkOffice = makeBuilding("EastSideSalvage", Vector3.new(382, 0, 105), 52, 38, 18, Color3.fromRGB(104, 98, 84), "EASTSIDE SALVAGE", Color3.fromRGB(255, 191, 83))
local salvageDesk = makePart(junkOffice, "SalvageDispatch", Vector3.new(10, 3, 4), CFrame.new(382, 1.5, 120), Color3.fromRGB(133, 91, 47), Enum.Material.Metal)
makePrompt(salvageDesk, "Take Salvage Run", "Deliver recovered parts to Rust Belt Auto • $500", "StartRouteJob", 0.8, {
	JobId = "SalvageRun",
	JobName = "Salvage parts run",
	ObjectiveText = "SALVAGE RUN: Deliver the recovered parts to the blue receiver at Rust Belt Auto.",
	Reward = 500,
})
makeSurfaceSign(salvageDesk, "SALVAGE JOB  $500", Color3.fromRGB(255, 191, 83), Enum.NormalId.Back, 460, 110, true)
makeFenceRectangle("JunkyardFence", Vector3.new(385, 0, 135), 100, 150)
for index, wreckData in ipairs({
	{Vector3.new(348, 0, 85), Color3.fromRGB(102, 55, 45)},
	{Vector3.new(410, 0, 126), Color3.fromRGB(75, 82, 70)},
	{Vector3.new(358, 0, 176), Color3.fromRGB(65, 73, 89)},
	{Vector3.new(415, 0, 190), Color3.fromRGB(101, 80, 48)},
}) do
	makeWreck("SalvageWreck" .. index, wreckData[1], wreckData[2])
end
for x = 344, 416, 24 do
	makePart(map, "ScrapPile", Vector3.new(12, math.random(5, 9), 10), CFrame.new(x, 3.5, 151), Color3.fromRGB(91, 85, 75), Enum.Material.CorrodedMetal)
end

local court = makePart(map, "SouthlineBasketballCourt", Vector3.new(104, 0.25, 62), CFrame.new(-120, 0.06, 334), Color3.fromRGB(83, 91, 91), Enum.Material.Asphalt)
makePart(map, "CourtCenterLine", Vector3.new(0.3, 0.06, 60), CFrame.new(-120, 0.22, 334), Color3.fromRGB(224, 219, 191), Enum.Material.SmoothPlastic)
makePart(map, "CourtCenterCircle", Vector3.new(0.3, 18, 18), CFrame.new(-120, 0.25, 334) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(224, 219, 191), Enum.Material.SmoothPlastic).Shape = Enum.PartType.Cylinder
for _, x in ipairs({-166, -74}) do
	local hoopPost = makePart(map, "HoopPost", Vector3.new(0.6, 11, 0.6), CFrame.new(x, 5.5, 334), Color3.fromRGB(54, 57, 60), Enum.Material.Metal)
	local board = makePart(map, "Backboard", Vector3.new(0.35, 6, 10), CFrame.new(x, 10.5, 334), Color3.fromRGB(221, 224, 218), Enum.Material.SmoothPlastic)
	board.Transparency = 0.15
	makeSurfaceSign(board, "SOUTHLINE COURTS", Color3.fromRGB(255, 205, 91), Enum.NormalId.Right, 420, 180, true)
end

local balloonKiosk = makePart(map, "BalloonKiosk", Vector3.new(9, 3.5, 5), CFrame.new(-120, 1.75, 295), Color3.fromRGB(42, 47, 56), Enum.Material.Metal)
makePrompt(balloonKiosk, "Buy Lift Balloon", "Court vendor • Higher jump • $200", "BuyItem", 0.35, {ItemId = "Balloon"})
makeSurfaceSign(balloonKiosk, "LIFT BALLOON  $200", Color3.fromRGB(255, 112, 137), Enum.NormalId.Back, 520, 140, true)
for index, balloonData in ipairs({
	{Offset = Vector3.new(-2.6, 8.5, 0), Color = Color3.fromRGB(235, 72, 92)},
	{Offset = Vector3.new(0, 10, 0.4), Color = Color3.fromRGB(87, 157, 235)},
	{Offset = Vector3.new(2.6, 8.8, -0.2), Color = Color3.fromRGB(255, 197, 78)},
}) do
	local stringPart = makePart(map, "KioskBalloonString" .. index, Vector3.new(0.08, balloonData.Offset.Y - 3.5, 0.08), CFrame.new(-120 + balloonData.Offset.X, (balloonData.Offset.Y + 3.5) * 0.5, 295 + balloonData.Offset.Z), Color3.fromRGB(214, 214, 208), Enum.Material.SmoothPlastic)
	stringPart.CanCollide = false
	local displayBalloon = makePart(map, "KioskBalloon" .. index, Vector3.new(3.3, 3.8, 3.3), CFrame.new(-120, 0, 295) + balloonData.Offset, balloonData.Color, Enum.Material.SmoothPlastic)
	displayBalloon.Shape = Enum.PartType.Ball
	displayBalloon.CanCollide = false
	displayBalloon.Reflectance = 0.08
end

for _, railZ in ipairs({324, 344}) do
	makePart(map, "Rail", Vector3.new(196, 0.28, 0.3), CFrame.new(166, 0.28, railZ), Color3.fromRGB(72, 73, 74), Enum.Material.Metal)
end
for x = 70, 262, 6 do
	makePart(map, "RailTie", Vector3.new(0.55, 0.3, 24), CFrame.new(x, 0.13, 334), Color3.fromRGB(87, 59, 39), Enum.Material.WoodPlanks)
end
makeCargoContainer("RailContainerRed", Vector3.new(105, 0, 365), Color3.fromRGB(135, 58, 48))
makeCargoContainer("RailContainerBlue", Vector3.new(145, 0, 365), Color3.fromRGB(55, 88, 111))
makeCargoContainer("RailContainerGreen", Vector3.new(185, 0, 365), Color3.fromRGB(61, 99, 75))
makeCargoContainer("RailContainerGold", Vector3.new(225, 0, 365), Color3.fromRGB(145, 105, 48))
local railYardMarker = makePart(map, "RailYardMarker", Vector3.new(10, 2.5, 4), CFrame.new(166, 1.25, 382), Color3.fromRGB(166, 83, 43), Enum.Material.Metal)
makePrompt(railYardMarker, "Deliver Freight", "Southline Rail Yard receiving", "CompleteRouteJob", 0.8, {
	JobId = "FoundryFreight",
})
makeSurfaceSign(railYardMarker, "SOUTHLINE RAIL YARD", Color3.fromRGB(255, 174, 91), Enum.NormalId.Back, 520, 110, true)

local towerBase = Vector3.new(385, 0, 345)
for _, offset in ipairs({Vector3.new(-6, 0, -6), Vector3.new(6, 0, -6), Vector3.new(-6, 0, 6), Vector3.new(6, 0, 6)}) do
	makePart(map, "WaterTowerLeg", Vector3.new(0.8, 42, 0.8), CFrame.new(towerBase + offset + Vector3.new(0, 21, 0)) * CFrame.Angles(math.rad(offset.Z * 0.45), 0, math.rad(-offset.X * 0.45)), Color3.fromRGB(79, 82, 84), Enum.Material.Metal)
end
local tank = makePart(map, "WaterTowerTank", Vector3.new(14, 24, 24), CFrame.new(towerBase + Vector3.new(0, 46, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(113, 119, 119), Enum.Material.Metal)
tank.Shape = Enum.PartType.Cylinder
makeSurfaceSign(tank, "OHIO COUNTY WATER", Color3.fromRGB(235, 237, 229), Enum.NormalId.Front, 520, 140, true)

makeStreetSign(Vector3.new(-218, 0, -208), "WEST END ST", "FOUNDRY RD")
makeStreetSign(Vector3.new(268, 0, -208), "INDUSTRIAL BLVD", "FOUNDRY RD")
makeStreetSign(Vector3.new(-218, 0, 208), "WEST END ST", "SOUTHLINE RD")
makeStreetSign(Vector3.new(268, 0, 208), "INDUSTRIAL BLVD", "SOUTHLINE RD")
makeRoadsideBillboard("ClinicRoadsideBillboard", Vector3.new(-365, 0, 39), 0, "COUNTY CLINIC", "FULL TREATMENT • $75", Color3.fromRGB(255, 111, 111))
makeRoadsideBillboard("AutoRoadsideBillboard", Vector3.new(390, 0, -39), 0, "RUST BELT AUTO", "SALVAGE RUNS WELCOME", Color3.fromRGB(107, 169, 255))
makeRoadsideBillboard("FoundryRoadsideBillboard", Vector3.new(92, 0, -395), 90, "BUCKEYE FOUNDRY", "HONEST WORK • $700", Color3.fromRGB(255, 145, 78))
makeRoadsideBillboard("PawnRoadsideBillboard", Vector3.new(12, 0, 395), 90, "PAWN & TOOL", "GEAR UP BEFORE DARK", Color3.fromRGB(255, 205, 91))

makeSearchContainer("QuickStopDumpster", Vector3.new(-98, 1.7, -98), "Common", "Dumpster")
makeSearchContainer("PawnDumpster", Vector3.new(-165, 1.7, 55), "Common", "Dumpster")
makeSearchContainer("SafehouseDumpster", Vector3.new(-91, 1.7, 82), "Common", "Dumpster")
makeSearchContainer("WarehouseCrate", Vector3.new(98, 2.5, -78), "Common", "Crate")
makeSearchContainer("AlleyCrate", Vector3.new(6, 2.5, -82), "Common", "Crate")
makeSearchContainer("WarehouseSafe", Vector3.new(164, 2.5, -92), "Rare", "Safe")
makeSearchContainer("PoliceEvidenceCrate", Vector3.new(171, 2.5, 84), "Rare", "Crate")
makeSearchContainer("ClinicDumpster", Vector3.new(-184, 1.7, -163), "Common", "Dumpster")
makeSearchContainer("MotelDumpster", Vector3.new(-180, 1.7, -350), "Common", "Dumpster")
makeSearchContainer("FoundryCrate", Vector3.new(112, 2.5, -367), "Rare", "Crate")
makeSearchContainer("AutoShopCrate", Vector3.new(414, 2.5, -154), "Common", "Crate")
makeSearchContainer("FireStationLocker", Vector3.new(-405, 2.5, -140), "Rare", "Safe")
makeSearchContainer("ApartmentDumpster", Vector3.new(-410, 1.7, 102), "Common", "Dumpster")
makeSearchContainer("JunkyardSafe", Vector3.new(425, 2.5, 78), "Rare", "Safe")
makeSearchContainer("RailYardCrate", Vector3.new(250, 2.5, 370), "Rare", "Crate")

local spawn = Instance.new("SpawnLocation")
spawn.Name = "SpawnLocation"
spawn.Size = Vector3.new(8, 1, 8)
spawn.CFrame = CFrame.new(-4, 0.5, 42)
spawn.Color = Color3.fromRGB(233, 72, 72)
spawn.Material = Enum.Material.Neon
spawn.Transparency = 0.25
spawn.Neutral = true
spawn.Anchored = true
spawn.Parent = map
makeSurfaceSign(spawn, "SPAWN • READ THE DISTRICT DIRECTORY", Color3.fromRGB(245, 245, 245), Enum.NormalId.Top, 520, 120, false)
local directoryBoard = makePart(map, "DistrictDirectory", Vector3.new(18, 10, 0.7), CFrame.new(-18, 5, 57), Color3.fromRGB(31, 34, 38), Enum.Material.Metal)
makeSurfaceSign(directoryBoard, "DISTRICT DIRECTORY\nJOBS: CLINIC / FOUNDRY / JUNKYARD / AUTO TOW\nCRIME: QUICK STOP REGISTER + BACK-ROOM SAFE\nN: CLINIC / FOUNDRY / MOTEL / POLICE CHECKPOINT\nS: APARTMENTS / RAIL YARD / COURTS\nE: AUTO SHOP / JUNKYARD\nW: FIRE STATION", Color3.fromRGB(225, 229, 221), Enum.NormalId.Front, 680, 380, true)
local phoneKiosk = makePart(map, "PhoneHelpKiosk", Vector3.new(8, 6, 1.2), CFrame.new(10, 3, 57), Color3.fromRGB(31, 39, 50), Enum.Material.Metal)
makeSurfaceSign(phoneKiosk, "CITY PHONE NETWORK\nPRESS P OR TAP PHONE\nDAILY CONTRACT • CONTACTS • PROFILE", Color3.fromRGB(126, 181, 255), Enum.NormalId.Front, 480, 300, true)

local function makeStreetLight(position)
	local pole = makePart(map, "StreetLight", Vector3.new(0.7, 13, 0.7), CFrame.new(position.X, 6.5, position.Z), Color3.fromRGB(47, 49, 53), Enum.Material.Metal)
	makePart(map, "LampArm", Vector3.new(4.2, 0.38, 0.38), CFrame.new(position.X + 1.75, 12.7, position.Z), Color3.fromRGB(47, 49, 53), Enum.Material.Metal)
	local lamp = makePart(map, "Lamp", Vector3.new(2.4, 0.48, 1.15), CFrame.new(position.X + 3.5, 12.55, position.Z), Color3.fromRGB(255, 229, 169), Enum.Material.Neon)
	local light = Instance.new("PointLight")
	light.Range = 25
	light.Brightness = 1.45
	light.Shadows = true
	light.Color = Color3.fromRGB(255, 221, 163)
	light.Parent = lamp
	return pole
end
for _, position in ipairs({
	Vector3.new(-120, 0, -28), Vector3.new(-30, 0, -28), Vector3.new(120, 0, -28),
	Vector3.new(-120, 0, 28), Vector3.new(-30, 0, 28), Vector3.new(120, 0, 28),
	Vector3.new(24, 0, -125), Vector3.new(80, 0, -125), Vector3.new(24, 0, 125), Vector3.new(80, 0, 125),
	Vector3.new(-390, 0, -212), Vector3.new(-140, 0, -212), Vector3.new(130, 0, -212), Vector3.new(380, 0, -212),
	Vector3.new(-390, 0, -268), Vector3.new(-140, 0, -268), Vector3.new(130, 0, -268), Vector3.new(380, 0, -268),
	Vector3.new(-390, 0, 212), Vector3.new(-140, 0, 212), Vector3.new(130, 0, 212), Vector3.new(380, 0, 212),
	Vector3.new(-390, 0, 268), Vector3.new(-140, 0, 268), Vector3.new(130, 0, 268), Vector3.new(380, 0, 268),
	Vector3.new(-278, 0, -360), Vector3.new(-222, 0, -120), Vector3.new(-278, 0, 120), Vector3.new(-222, 0, 360),
	Vector3.new(272, 0, -360), Vector3.new(328, 0, -120), Vector3.new(272, 0, 120), Vector3.new(328, 0, 360),
}) do
	makeStreetLight(position)
end

local function makeBench(name, position, rotation)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = map
	local baseCFrame = CFrame.new(position) * CFrame.Angles(0, math.rad(rotation or 0), 0)
	makePart(model, "Seat", Vector3.new(6.4, 0.42, 2), baseCFrame * CFrame.new(0, 2, 0), Color3.fromRGB(100, 68, 43), Enum.Material.WoodPlanks)
	makePart(model, "Back", Vector3.new(6.4, 2.3, 0.38), baseCFrame * CFrame.new(0, 3.15, 0.82) * CFrame.Angles(math.rad(-8), 0, 0), Color3.fromRGB(91, 61, 39), Enum.Material.WoodPlanks)
	for _, x in ipairs({-2.35, 2.35}) do
		makePart(model, "Leg", Vector3.new(0.38, 2, 0.38), baseCFrame * CFrame.new(x, 1, 0), Color3.fromRGB(54, 57, 60), Enum.Material.Metal)
		makePart(model, "Foot", Vector3.new(1.2, 0.25, 2.4), baseCFrame * CFrame.new(x, 0.2, 0), Color3.fromRGB(54, 57, 60), Enum.Material.Metal)
	end
end

local function makeHydrant(name, position)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = map
	local body = makePart(model, "Body", Vector3.new(2.7, 1.25, 1.25), CFrame.new(position + Vector3.new(0, 1.45, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(176, 46, 43), Enum.Material.Metal)
	body.Shape = Enum.PartType.Cylinder
	local top = makePart(model, "Top", Vector3.new(0.55, 1.65, 1.65), CFrame.new(position + Vector3.new(0, 2.86, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(194, 53, 48), Enum.Material.Metal)
	top.Shape = Enum.PartType.Cylinder
	for _, x in ipairs({-0.82, 0.82}) do
		local nozzle = makePart(model, "Nozzle", Vector3.new(0.7, 0.7, 0.7), CFrame.new(position + Vector3.new(x, 1.65, 0)), Color3.fromRGB(201, 61, 55), Enum.Material.Metal)
		nozzle.Shape = Enum.PartType.Cylinder
	end
end

makeBench("ClinicBench", Vector3.new(-168, 0, -109), 0)
makeBench("CourtBench", Vector3.new(-120, 0, 300), 0)
makeBench("MotelBench", Vector3.new(-125, 0, -296), 0)
makeBench("DirectoryBench", Vector3.new(5, 0, 56), 180)
for index, position in ipairs({
	Vector3.new(-102, 0, -30), Vector3.new(145, 0, 30), Vector3.new(-220, 0, 210),
	Vector3.new(270, 0, -210), Vector3.new(-278, 0, -80), Vector3.new(328, 0, 270),
}) do
	makeHydrant("FireHydrant" .. index, position)
end
for index, patchData in ipairs({
	{Vector3.new(-155, 0.24, -7), Vector3.new(22, 0.05, 11), 12},
	{Vector3.new(195, 0.24, 8), Vector3.new(16, 0.05, 9), -8},
	{Vector3.new(42, 0.24, -155), Vector3.new(10, 0.05, 20), 4},
	{Vector3.new(61, 0.24, 145), Vector3.new(12, 0.05, 24), -5},
	{Vector3.new(-330, 0.24, -232), Vector3.new(20, 0.05, 9), 6},
	{Vector3.new(235, 0.24, 249), Vector3.new(18, 0.05, 10), -9},
}) do
	local patchPart = makePart(map, "RoadRepair" .. index, patchData[2], CFrame.new(patchData[1]) * CFrame.Angles(0, math.rad(patchData[3]), 0), Color3.fromRGB(34, 36, 38), Enum.Material.Asphalt)
	patchPart.CanCollide = false
end

local function makeTree(position)
	local tree = Instance.new("Model")
	tree.Name = "StreetTree"
	tree.Parent = map
	local trunk = makePart(tree, "Trunk", Vector3.new(9.5, 1.5, 1.5), CFrame.new(position.X, 4.75, position.Z) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(82, 58, 42), Enum.Material.Wood)
	trunk.Shape = Enum.PartType.Cylinder
	for _, branchData in ipairs({
		{Vector3.new(-1.2, 8.4, 0), -28}, {Vector3.new(1.1, 8.1, 0.5), 31},
	}) do
		local branch = makePart(tree, "Branch", Vector3.new(5.2, 0.75, 0.75), CFrame.new(position + branchData[1]) * CFrame.Angles(0, 0, math.rad(branchData[2])), Color3.fromRGB(78, 55, 40), Enum.Material.Wood)
		branch.Shape = Enum.PartType.Cylinder
		branch.CanCollide = false
	end
	for index, crownData in ipairs({
		{Vector3.new(-2.3, 10.2, 0.5), Vector3.new(7.8, 7.2, 6.8)},
		{Vector3.new(2.1, 10.6, -0.6), Vector3.new(8.3, 7.6, 7.2)},
		{Vector3.new(0, 13.2, 0.2), Vector3.new(8.8, 7.1, 8.2)},
	}) do
		local crown = makePart(tree, "Canopy" .. index, crownData[2], CFrame.new(position + crownData[1]), Color3.fromRGB(50 + index * 4, 82 + index * 5, 47 + index * 3), Enum.Material.Grass)
		crown.Shape = Enum.PartType.Ball
		crown.CanCollide = false
	end
	return trunk
end
for _, position in ipairs({
	Vector3.new(-205, 0, -65), Vector3.new(-205, 0, 70), Vector3.new(-105, 0, 155),
	Vector3.new(-10, 0, 150), Vector3.new(185, 0, 150), Vector3.new(200, 0, -100),
	Vector3.new(-425, 0, -40), Vector3.new(-425, 0, 45), Vector3.new(-330, 0, -205),
	Vector3.new(-190, 0, -405), Vector3.new(-45, 0, -405), Vector3.new(45, 0, -335),
	Vector3.new(260, 0, -405), Vector3.new(425, 0, -285), Vector3.new(425, 0, -35),
	Vector3.new(-420, 0, 290), Vector3.new(-315, 0, 350), Vector3.new(-210, 0, 405),
	Vector3.new(-35, 0, 405), Vector3.new(285, 0, 405), Vector3.new(430, 0, 285),
}) do
	makeTree(position)
end

local function makeSimpleBench(position, rotation)
	local cframe = CFrame.new(position) * CFrame.Angles(0, math.rad(rotation or 0), 0)
	makePart(map, "BenchSeat", Vector3.new(7, 0.45, 2), cframe * CFrame.new(0, 2, 0), Color3.fromRGB(115, 78, 49), Enum.Material.WoodPlanks)
	makePart(map, "BenchBack", Vector3.new(7, 2.5, 0.4), cframe * CFrame.new(0, 3.1, 0.85) * CFrame.Angles(math.rad(-8), 0, 0), Color3.fromRGB(115, 78, 49), Enum.Material.WoodPlanks)
	for _, x in ipairs({-2.5, 2.5}) do
		makePart(map, "BenchLeg", Vector3.new(0.35, 2, 0.35), cframe * CFrame.new(x, 1, 0), Color3.fromRGB(47, 49, 52), Enum.Material.Metal)
	end
end
makeSimpleBench(Vector3.new(-155, 0, 305), 0)
makeSimpleBench(Vector3.new(-85, 0, 305), 180)
makeSimpleBench(Vector3.new(-185, 0, -270), 0)
makeSimpleBench(Vector3.new(225, 0, 285), 180)

local function makeTrafficSignal(position)
	local pole = makePart(map, "TrafficSignalPole", Vector3.new(0.65, 15, 0.65), CFrame.new(position + Vector3.new(0, 7.5, 0)), Color3.fromRGB(49, 51, 54), Enum.Material.Metal)
	makePart(map, "SignalArm", Vector3.new(8, 0.42, 0.42), CFrame.new(position + Vector3.new(3.7, 14.1, 0)), Color3.fromRGB(49, 51, 54), Enum.Material.Metal)
	local housing = makePart(map, "SignalHousing", Vector3.new(1.4, 4.6, 1.2), CFrame.new(position + Vector3.new(7.1, 12.2, 0)), Color3.fromRGB(33, 35, 37), Enum.Material.Metal)
	for index, lightColor in ipairs({Color3.fromRGB(214, 52, 52), Color3.fromRGB(227, 181, 51), Color3.fromRGB(62, 185, 91)}) do
		local signal = makePart(map, "SignalLight", Vector3.new(0.34, 0.75, 0.75), CFrame.new(housing.Position + Vector3.new(0.72, 1.45 - (index - 1) * 1.45, 0)) * CFrame.Angles(0, 0, math.rad(90)), lightColor, Enum.Material.Neon)
		signal.Shape = Enum.PartType.Cylinder
		signal.CanCollide = false
	end
	return pole
end
for _, position in ipairs({Vector3.new(20, 0, -32), Vector3.new(270, 0, -32), Vector3.new(-280, 0, -272), Vector3.new(270, 0, 208)}) do
	makeTrafficSignal(position)
end

local car = Instance.new("Model")
car.Name = "StarterCar"
car.Parent = map
local carPosition = Vector3.new(53, 1.95, 58)
local carPaint = Color3.fromRGB(83, 101, 111)
local carPaintDark = Color3.fromRGB(64, 78, 86)
local carTrim = Color3.fromRGB(45, 48, 51)
local carGlass = Color3.fromRGB(72, 101, 113)
local chassis = makePart(car, "Chassis", Vector3.new(6.15, 0.82, 10.35), CFrame.new(carPosition), Color3.fromRGB(40, 42, 44), Enum.Material.Metal, false)
chassis.CustomPhysicalProperties = PhysicalProperties.new(2, 0.65, 0.1, 100, 1)
local function attachCarPart(name, size, cframe, color, material, transparency)
	local part = makePart(car, name, size, cframe, color, material, false)
	part.CanCollide = false
	part.Massless = true
	part.Transparency = transparency or 0
	weldTo(chassis, part)
	return part
end
local body = makePart(car, "Body", Vector3.new(6.25, 1.18, 7.75), CFrame.new(carPosition + Vector3.new(0, 1.05, 0.15)), carPaint, Enum.Material.Metal, false)
body.CanCollide = false
body.Massless = true
weldTo(chassis, body)
attachCarPart("FrontValance", Vector3.new(6.1, 0.9, 2.6), CFrame.new(carPosition + Vector3.new(0, 0.82, -4.05)), carPaintDark, Enum.Material.Metal)
attachCarPart("RearValance", Vector3.new(6.1, 0.95, 2.25), CFrame.new(carPosition + Vector3.new(0, 0.86, 4.16)), carPaintDark, Enum.Material.Metal)
for _, x in ipairs({-2.96, 2.96}) do
	attachCarPart("RockerPanel", Vector3.new(0.32, 0.68, 6.6), CFrame.new(carPosition + Vector3.new(x, 0.58, 0.25)), carTrim, Enum.Material.Metal)
	attachCarPart("FrontQuarterPanel", Vector3.new(0.34, 1.55, 2.65), CFrame.new(carPosition + Vector3.new(x, 1.18, -3.65)), carPaint, Enum.Material.Metal)
	attachCarPart("RearQuarterPanel", Vector3.new(0.34, 1.55, 2.45), CFrame.new(carPosition + Vector3.new(x, 1.18, 3.65)), carPaint, Enum.Material.Metal)
end
local seat = Instance.new("VehicleSeat")
seat.Name = "DriverSeat"
seat.Size = Vector3.new(1.8, 0.8, 1.85)
seat.CFrame = CFrame.new(carPosition + Vector3.new(-1.25, 2.15, 0.4))
seat.Color = Color3.fromRGB(43, 45, 48)
seat.Material = Enum.Material.Fabric
seat.Anchored = false
seat.CanCollide = false
seat.Massless = true
seat.Parent = car
weldTo(chassis, seat)
for _, passengerOffset in ipairs({Vector3.new(1.25, 2.05, 0.4), Vector3.new(-1.25, 2.05, 2.15), Vector3.new(1.25, 2.05, 2.15)}) do
	attachCarPart("PassengerSeat", Vector3.new(1.65, 0.68, 1.6), CFrame.new(carPosition + passengerOffset), Color3.fromRGB(48, 50, 52), Enum.Material.Fabric)
end
attachCarPart("Dashboard", Vector3.new(5.45, 0.72, 0.85), CFrame.new(carPosition + Vector3.new(0, 2.55, -1.62)) * CFrame.Angles(math.rad(-8), 0, 0), Color3.fromRGB(39, 42, 44), Enum.Material.SmoothPlastic)
local steeringWheel = attachCarPart("SteeringWheel", Vector3.new(0.34, 1.35, 1.35), CFrame.new(carPosition + Vector3.new(-1.25, 2.82, -1.05)) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(29, 31, 33), Enum.Material.SmoothPlastic)
steeringWheel.Shape = Enum.PartType.Cylinder
for _, offset in ipairs({Vector3.new(-3.18, -0.42, -3.35), Vector3.new(3.18, -0.42, -3.35), Vector3.new(-3.18, -0.42, 3.35), Vector3.new(3.18, -0.42, 3.35)}) do
	local wheel = makePart(car, "Wheel", Vector3.new(1.02, 2.35, 2.35), CFrame.new(carPosition + offset) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(24, 25, 27), Enum.Material.Rubber, false)
	wheel.Shape = Enum.PartType.Cylinder
	wheel.CanCollide = false
	wheel.Massless = true
	weldTo(chassis, wheel)
	local hub = attachCarPart("WheelHub", Vector3.new(1.08, 1.25, 1.25), CFrame.new(carPosition + offset) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(131, 134, 134), Enum.Material.Metal)
	hub.Shape = Enum.PartType.Cylinder
end
attachCarPart("Hood", Vector3.new(6.15, 0.38, 3.25), CFrame.new(carPosition + Vector3.new(0, 1.55, -4.05)) * CFrame.Angles(math.rad(-2), 0, 0), carPaint, Enum.Material.Metal)
attachCarPart("HoodCenterPress", Vector3.new(2.8, 0.12, 2.85), CFrame.new(carPosition + Vector3.new(0, 1.79, -4.02)) * CFrame.Angles(math.rad(-2), 0, 0), carPaintDark, Enum.Material.Metal)
attachCarPart("TrunkLid", Vector3.new(6.12, 0.4, 2.15), CFrame.new(carPosition + Vector3.new(0, 1.55, 4.3)) * CFrame.Angles(math.rad(1.5), 0, 0), carPaint, Enum.Material.Metal)
attachCarPart("CabinHeadliner", Vector3.new(5.68, 0.55, 4.4), CFrame.new(carPosition + Vector3.new(0, 3.72, 0.3)), carPaintDark, Enum.Material.Metal)
local windshield = attachCarPart("Windshield", Vector3.new(5.55, 2.05, 0.22), CFrame.new(carPosition + Vector3.new(0, 2.95, -2.02)) * CFrame.Angles(math.rad(-22), 0, 0), carGlass, Enum.Material.Glass, 0.32)
local rearGlass = attachCarPart("RearWindshield", Vector3.new(5.52, 1.85, 0.22), CFrame.new(carPosition + Vector3.new(0, 3.0, 2.55)) * CFrame.Angles(math.rad(23), 0, 0), carGlass, Enum.Material.Glass, 0.34)
for _, x in ipairs({-2.91, 2.91}) do
	for _, windowData in ipairs({{-0.92, 2.1}, {1.35, 1.9}}) do
		local sideWindow = attachCarPart("SideWindow", Vector3.new(0.16, 1.65, windowData[2]), CFrame.new(carPosition + Vector3.new(x, 3.03, windowData[1])), carGlass, Enum.Material.Glass, 0.34)
		sideWindow.CanCollide = false
	end
	attachCarPart("B-Pillar", Vector3.new(0.24, 2.15, 0.34), CFrame.new(carPosition + Vector3.new(x, 3.02, 0.18)), carTrim, Enum.Material.Metal)
	attachCarPart("FrontDoorSkin", Vector3.new(0.2, 1.65, 2.45), CFrame.new(carPosition + Vector3.new(x * 1.02, 1.95, -0.98)), carPaint, Enum.Material.Metal)
	attachCarPart("RearDoorSkin", Vector3.new(0.2, 1.65, 2.35), CFrame.new(carPosition + Vector3.new(x * 1.02, 1.95, 1.48)), carPaint, Enum.Material.Metal)
	attachCarPart("FrontDoorHandle", Vector3.new(0.2, 0.18, 0.62), CFrame.new(carPosition + Vector3.new(x * 1.06, 2.46, -0.35)), Color3.fromRGB(177, 179, 176), Enum.Material.Metal)
	attachCarPart("RearDoorHandle", Vector3.new(0.2, 0.18, 0.62), CFrame.new(carPosition + Vector3.new(x * 1.06, 2.46, 2.1)), Color3.fromRGB(177, 179, 176), Enum.Material.Metal)
	attachCarPart("Mirror", Vector3.new(0.6, 0.45, 0.78), CFrame.new(carPosition + Vector3.new(x * 1.12, 2.95, -1.58)), carTrim, Enum.Material.Metal)
end
attachCarPart("FrontBumper", Vector3.new(6.55, 0.44, 0.48), CFrame.new(carPosition + Vector3.new(0, 0.92, -5.38)), Color3.fromRGB(91, 94, 94), Enum.Material.Metal)
attachCarPart("RearBumper", Vector3.new(6.55, 0.44, 0.48), CFrame.new(carPosition + Vector3.new(0, 0.92, 5.38)), Color3.fromRGB(91, 94, 94), Enum.Material.Metal)
attachCarPart("Grille", Vector3.new(3.45, 0.72, 0.18), CFrame.new(carPosition + Vector3.new(0, 1.38, -5.25)), Color3.fromRGB(27, 29, 31), Enum.Material.Metal)
for x = -1.35, 1.35, 0.68 do
	attachCarPart("GrilleBar", Vector3.new(0.12, 0.68, 0.21), CFrame.new(carPosition + Vector3.new(x, 1.38, -5.36)), Color3.fromRGB(120, 123, 122), Enum.Material.Metal)
end
for _, x in ipairs({-2.18, 2.18}) do
	local headlight = attachCarPart("Headlight", Vector3.new(1.28, 0.64, 0.2), CFrame.new(carPosition + Vector3.new(x, 1.55, -5.28)), Color3.fromRGB(255, 235, 184), Enum.Material.Glass)
	local light = Instance.new("SpotLight")
	light.Face = Enum.NormalId.Front
	light.Range = 28
	light.Angle = 55
	light.Brightness = 1.2
	light.Color = Color3.fromRGB(255, 235, 190)
	light.Parent = headlight
	attachCarPart("TurnSignal", Vector3.new(0.5, 0.3, 0.22), CFrame.new(carPosition + Vector3.new(x + (x > 0 and 0.76 or -0.76), 1.52, -5.3)), Color3.fromRGB(242, 156, 54), Enum.Material.Neon)
	attachCarPart("TailLight", Vector3.new(1.3, 0.62, 0.2), CFrame.new(carPosition + Vector3.new(x, 1.5, 5.27)), Color3.fromRGB(196, 42, 42), Enum.Material.Neon)
end
local frontPlate = attachCarPart("FrontPlate", Vector3.new(1.65, 0.62, 0.12), CFrame.new(carPosition + Vector3.new(0, 0.92, -5.65)), Color3.fromRGB(224, 224, 217), Enum.Material.Metal)
local rearPlate = attachCarPart("RearPlate", Vector3.new(1.65, 0.62, 0.12), CFrame.new(carPosition + Vector3.new(0, 1.05, 5.65)), Color3.fromRGB(224, 224, 217), Enum.Material.Metal)
makeSurfaceSign(frontPlate, "OHIO", Color3.fromRGB(42, 61, 95), Enum.NormalId.Front, 240, 90, false)
makeSurfaceSign(rearPlate, "OHIO 2", Color3.fromRGB(42, 61, 95), Enum.NormalId.Back, 240, 90, false)
local exhaust = attachCarPart("Exhaust", Vector3.new(1.1, 0.28, 0.28), CFrame.new(carPosition + Vector3.new(2.1, 0.55, 5.42)) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(75, 77, 77), Enum.Material.Metal)
exhaust.Shape = Enum.PartType.Cylinder
car.PrimaryPart = chassis
car:SetAttribute("OwnerUserId", 0)
car:SetAttribute("Fuel", 100)
car:SetAttribute("MaxFuel", 100)
car:SetAttribute("Condition", 100)
car:SetAttribute("MaxCondition", 100)
car:SetAttribute("VehicleDisabled", false)
local vehicleController = Instance.new("Script")
vehicleController.Name = "VehicleController"
vehicleController.Source = [==[
__VEHICLE_CONTROLLER_SOURCE__
]==]
vehicleController.Parent = car
local rustCompactTemplate = car:Clone()
rustCompactTemplate.Name = "RustCompact"
rustCompactTemplate.Parent = vehicleTemplates

local garageCar = car:Clone()
garageCar.Name = "GarageTestCar"
garageCar.Parent = map
garageCar:PivotTo(CFrame.new(410, 2.2, -80) * CFrame.Angles(0, math.rad(180), 0))

local function makeParkedSedan(name, cframe, paintColor)
	local parked = car:Clone()
	parked.Name = name
	local controller = parked:FindFirstChild("VehicleController")
	if controller then
		controller:Destroy()
	end
	local parkedSeat = parked:FindFirstChild("DriverSeat")
	if parkedSeat then
		parkedSeat:Destroy()
	end
	for _, descendant in ipairs(parked:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = descendant.Name == "Chassis"
			if descendant.Name == "Body" or descendant.Name == "Hood" or descendant.Name == "TrunkLid" or descendant.Name == "FrontDoorSkin" or descendant.Name == "RearDoorSkin" or descendant.Name == "FrontQuarterPanel" or descendant.Name == "RearQuarterPanel" then
				descendant.Color = paintColor
			end
		end
	end
	parked.Parent = map
	parked:PivotTo(cframe)
	return parked
end

makeParkedSedan("ClinicVisitorCar", CFrame.new(-156, 1.95, -105) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(110, 90, 71))
makeParkedSedan("MotelGuestCar", CFrame.new(-125, 1.95, -294) * CFrame.Angles(0, math.rad(-90), 0), Color3.fromRGB(82, 91, 113))
makeParkedSedan("ApartmentResidentCar", CFrame.new(-355, 1.95, 177) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(102, 103, 97))

for _, wallData in ipairs({
	{Vector3.new(900, 70, 2), CFrame.new(0, 35, -450)},
	{Vector3.new(900, 70, 2), CFrame.new(0, 35, 450)},
	{Vector3.new(2, 70, 900), CFrame.new(-450, 35, 0)},
	{Vector3.new(2, 70, 900), CFrame.new(450, 35, 0)},
}) do
	local boundary = makePart(map, "MapBoundary", wallData[1], wallData[2], Color3.fromRGB(0, 0, 0), Enum.Material.SmoothPlastic)
	boundary.Transparency = 1
	boundary.CanCollide = true
end

ChangeHistoryService:SetWaypoint("Installed Ohio2 World and Gunplay 1.3")
print("====================================================")
print("OHIO 2 WORLD + GUNPLAY 1.3 INSTALLED SUCCESSFULLY")
print("Press Play to test. Admins open CMDR with F2 or semicolon.")
print("====================================================")
