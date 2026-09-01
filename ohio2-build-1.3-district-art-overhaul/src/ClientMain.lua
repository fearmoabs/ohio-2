-- Ohio 2 prototype HUD, notifications, tool input, and weapon effects.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local project = ReplicatedStorage:WaitForChild("Ohio2")
local remotes = project:WaitForChild("Remotes")
local notificationRemote = remotes:WaitForChild("Notification")
local objectiveRemote = remotes:WaitForChild("Objective")
local weaponActionRemote = remotes:WaitForChild("WeaponAction")
local weaponFXRemote = remotes:WaitForChild("WeaponFX")
local weaponFeedbackRemote = remotes:WaitForChild("WeaponFeedback")
local stateActionRemote = remotes:WaitForChild("StateAction")
local phoneActionRemote = remotes:WaitForChild("PhoneAction")
local itemDefinitions = require(project.Shared.ItemDefinitions)
local soundDefinitions = require(project.Shared.SoundDefinitions)

local currentTool
local reloading = false
local sprintToggle = false
local blockToggle = false

local function configureSound(sound, soundName, volumeScale, speedScale)
	local definition = soundDefinitions.Catalog[soundName]
	if not definition or type(definition.SoundId) ~= "string" or definition.SoundId == "" then
		return false
	end
	sound.Name = "Ohio2_" .. soundName
	sound.SoundId = definition.SoundId
	sound.Volume = (definition.Volume or 0.5) * (soundDefinitions.MasterVolume or 1) * (volumeScale or 1)
	sound.PlaybackSpeed = math.max(0.05, (definition.PlaybackSpeed or 1) * (speedScale or 1) + (math.random() - 0.5) * 2 * (definition.SpeedVariance or 0))
	sound.RollOffMode = Enum.RollOffMode.InverseTapered
	sound.RollOffMinDistance = definition.MinDistance or 5
	sound.RollOffMaxDistance = definition.MaxDistance or 90
	return true
end

local function playSpatialSound(soundName, source, volumeScale, speedScale)
	local emitter
	local parent
	if typeof(source) == "Vector3" then
		emitter = Instance.new("Part")
		emitter.Name = "Ohio2AudioEmitter"
		emitter.Size = Vector3.new(0.1, 0.1, 0.1)
		emitter.CFrame = CFrame.new(source)
		emitter.Transparency = 1
		emitter.Anchored = true
		emitter.CanCollide = false
		emitter.CanQuery = false
		emitter.CanTouch = false
		emitter.Parent = workspace
		parent = emitter
	elseif typeof(source) == "Instance" then
		parent = source
	end
	if not parent then
		return
	end
	local sound = Instance.new("Sound")
	if not configureSound(sound, soundName, volumeScale, speedScale) then
		if emitter then
			emitter:Destroy()
		end
		return
	end
	sound.Parent = parent
	sound:Play()
	Debris:AddItem(sound, 8)
	if emitter then
		Debris:AddItem(emitter, 8.1)
	end
	return sound
end

local characterAudioBound = setmetatable({}, {__mode = "k"})
local function bindCharacterAudio(character)
	if characterAudioBound[character] then
		return
	end
	characterAudioBound[character] = true
	task.spawn(function()
		local root = character:WaitForChild("HumanoidRootPart", 10)
		local humanoid = character:WaitForChild("Humanoid", 10)
		if not root or not humanoid or not character.Parent then
			return
		end
		local footsteps = Instance.new("Sound")
		if not configureSound(footsteps, "Footstep") then
			return
		end
		footsteps.Name = "Ohio2SurfaceFootsteps"
		footsteps.Looped = true
		footsteps.Parent = root

		local function muteDefaultRunning(descendant)
			if descendant:IsA("Sound") and descendant.Name == "Running" and descendant ~= footsteps then
				descendant.Volume = 0
			end
		end
		for _, descendant in ipairs(character:GetDescendants()) do
			muteDefaultRunning(descendant)
		end
		character.DescendantAdded:Connect(muteDefaultRunning)

		local function updateFootsteps(speed)
			local floorName = humanoid.FloorMaterial.Name
			local surface = soundDefinitions.SurfaceFootsteps[floorName] or soundDefinitions.SurfaceFootsteps.Default
			local moving = speed > 1.5 and humanoid.FloorMaterial ~= Enum.Material.Air and humanoid.Health > 0 and not humanoid.Sit
			footsteps.Volume = (soundDefinitions.Catalog.Footstep.Volume or 0.34) * (soundDefinitions.MasterVolume or 1) * (surface.Volume or 1)
			footsteps.PlaybackSpeed = (soundDefinitions.Catalog.Footstep.PlaybackSpeed or 1.35) * (surface.Pitch or 1) * math.clamp(speed / 14, 0.78, 1.45)
			if moving and not footsteps.IsPlaying then
				footsteps:Play()
			elseif not moving and footsteps.IsPlaying then
				footsteps:Stop()
			end
		end
		humanoid.Running:Connect(updateFootsteps)
		humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
			updateFootsteps(humanoid.MoveDirection.Magnitude * humanoid.WalkSpeed)
		end)
		humanoid.Died:Connect(function()
			footsteps:Stop()
		end)
	end)
end

local rainPart = Instance.new("Part")
rainPart.Name = "Ohio2LocalRain"
rainPart.Size = Vector3.new(80, 1, 80)
rainPart.Anchored = true
rainPart.CanCollide = false
rainPart.CanTouch = false
rainPart.Transparency = 1
rainPart.Parent = workspace

local rainAttachment = Instance.new("Attachment")
rainAttachment.Parent = rainPart
local rainEmitter = Instance.new("ParticleEmitter")
rainEmitter.Name = "DistrictRain"
rainEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
rainEmitter.Color = ColorSequence.new(Color3.fromRGB(166, 194, 224))
rainEmitter.LightInfluence = 0.55
rainEmitter.Rate = 520
rainEmitter.Lifetime = NumberRange.new(0.65, 0.9)
rainEmitter.Speed = NumberRange.new(52, 68)
rainEmitter.Acceleration = Vector3.new(0, -22, 0)
rainEmitter.EmissionDirection = Enum.NormalId.Bottom
rainEmitter.SpreadAngle = Vector2.new(7, 7)
rainEmitter.Size = NumberSequence.new(0.075)
rainEmitter.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.18),
	NumberSequenceKeypoint.new(0.85, 0.35),
	NumberSequenceKeypoint.new(1, 1),
})
rainEmitter.Shape = Enum.ParticleEmitterShape.Box
rainEmitter.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
rainEmitter.Enabled = false
rainEmitter.Parent = rainAttachment

local function updateWeatherFX()
	rainEmitter.Enabled = workspace:GetAttribute("Weather") == "RAIN"
end

RunService.RenderStepped:Connect(function()
	local camera = workspace.CurrentCamera
	if camera then
		rainPart.CFrame = CFrame.new(camera.CFrame.Position + Vector3.new(0, 26, 0))
	end
end)

local function corner(parent, radius)
	local value = Instance.new("UICorner")
	value.CornerRadius = UDim.new(0, radius)
	value.Parent = parent
	return value
end

local function stroke(parent, color, transparency)
	local value = Instance.new("UIStroke")
	value.Color = color
	value.Transparency = transparency or 0
	value.Thickness = 1
	value.Parent = parent
	return value
end

local function label(parent, text, size, position, font, color, alignment)
	local value = Instance.new("TextLabel")
	value.BackgroundTransparency = 1
	value.Text = text
	value.Size = size
	value.Position = position or UDim2.new()
	value.Font = font or Enum.Font.Gotham
	value.TextColor3 = color or Color3.new(1, 1, 1)
	value.TextSize = 14
	value.TextXAlignment = alignment or Enum.TextXAlignment.Left
	value.Parent = parent
	return value
end

local gui = Instance.new("ScreenGui")
gui.Name = "Ohio2HUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local phoneOpenButton = Instance.new("TextButton")
phoneOpenButton.Name = "PhoneButton"
phoneOpenButton.AnchorPoint = Vector2.new(1, 1)
phoneOpenButton.Size = UDim2.fromOffset(138, 42)
phoneOpenButton.Position = UDim2.new(1, -18, 1, -166)
phoneOpenButton.BackgroundColor3 = Color3.fromRGB(32, 38, 47)
phoneOpenButton.Text = "PHONE  [P]"
phoneOpenButton.TextColor3 = Color3.fromRGB(235, 239, 245)
phoneOpenButton.TextSize = 13
phoneOpenButton.Font = Enum.Font.GothamBold
phoneOpenButton.Parent = gui
corner(phoneOpenButton, 10)
stroke(phoneOpenButton, Color3.fromRGB(92, 130, 173), 0.2)

local phonePanel = Instance.new("Frame")
phonePanel.Name = "Phone"
phonePanel.AnchorPoint = Vector2.new(1, 0.5)
phonePanel.Size = UDim2.fromOffset(360, 510)
phonePanel.Position = UDim2.new(1, -18, 0.5, 0)
phonePanel.BackgroundColor3 = Color3.fromRGB(11, 13, 17)
phonePanel.BackgroundTransparency = 0.03
phonePanel.Visible = false
phonePanel.Parent = gui
corner(phonePanel, 18)
stroke(phonePanel, Color3.fromRGB(76, 86, 102), 0.12)

local phoneTop = Instance.new("Frame")
phoneTop.Size = UDim2.new(1, 0, 0, 62)
phoneTop.BackgroundColor3 = Color3.fromRGB(25, 31, 40)
phoneTop.BorderSizePixel = 0
phoneTop.Parent = phonePanel
corner(phoneTop, 18)

local phoneTitle = label(phoneTop, "OHIO 2 PHONE", UDim2.new(1, -62, 0, 25), UDim2.fromOffset(18, 10), Enum.Font.GothamBlack, Color3.fromRGB(239, 242, 247))
phoneTitle.TextSize = 18
local phoneBuild = label(phoneTop, "CONTRACT NETWORK  •  BUILD 1.0", UDim2.new(1, -62, 0, 18), UDim2.fromOffset(18, 35), Enum.Font.GothamMedium, Color3.fromRGB(126, 170, 218))
phoneBuild.TextSize = 9

local phoneCloseButton = Instance.new("TextButton")
phoneCloseButton.Size = UDim2.fromOffset(36, 36)
phoneCloseButton.Position = UDim2.new(1, -47, 0, 12)
phoneCloseButton.BackgroundColor3 = Color3.fromRGB(61, 67, 78)
phoneCloseButton.Text = "×"
phoneCloseButton.TextColor3 = Color3.fromRGB(245, 245, 245)
phoneCloseButton.TextSize = 23
phoneCloseButton.Font = Enum.Font.GothamBold
phoneCloseButton.Parent = phoneTop
corner(phoneCloseButton, 9)

local phoneTabs = Instance.new("Frame")
phoneTabs.Size = UDim2.new(1, -24, 0, 42)
phoneTabs.Position = UDim2.fromOffset(12, 70)
phoneTabs.BackgroundTransparency = 1
phoneTabs.Parent = phonePanel

local phoneContent = Instance.new("Frame")
phoneContent.Size = UDim2.new(1, -24, 1, -126)
phoneContent.Position = UDim2.fromOffset(12, 116)
phoneContent.BackgroundColor3 = Color3.fromRGB(20, 23, 29)
phoneContent.Parent = phonePanel
corner(phoneContent, 12)
stroke(phoneContent, Color3.fromRGB(57, 64, 76), 0.35)

local phonePages = {}
local phoneTabButtons = {}
local function makePhonePage(name)
	local page = Instance.new("Frame")
	page.Name = name
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.Visible = false
	page.Parent = phoneContent
	phonePages[name] = page
	return page
end

local function makePhoneTab(name, textValue, x)
	local button = Instance.new("TextButton")
	button.Name = name .. "Tab"
	button.Size = UDim2.new(1 / 3, -5, 1, 0)
	button.Position = UDim2.new(x / 3, x == 0 and 0 or 3, 0, 0)
	button.BackgroundColor3 = Color3.fromRGB(43, 49, 59)
	button.Text = textValue
	button.TextColor3 = Color3.fromRGB(190, 196, 207)
	button.TextSize = 10
	button.Font = Enum.Font.GothamBold
	button.Parent = phoneTabs
	corner(button, 8)
	phoneTabButtons[name] = button
	return button
end

local contractPage = makePhonePage("Contract")
local cityPage = makePhonePage("City")
local profilePage = makePhonePage("Profile")
local contractTab = makePhoneTab("Contract", "DAILY", 0)
local cityTab = makePhoneTab("City", "CONTACTS", 1)
local profileTab = makePhoneTab("Profile", "PROFILE", 2)

local dailyKicker = label(contractPage, "TODAY'S CONTRACT", UDim2.new(1, -32, 0, 20), UDim2.fromOffset(16, 18), Enum.Font.GothamBold, Color3.fromRGB(107, 169, 255))
dailyKicker.TextSize = 10
local dailyTitle = label(contractPage, "Loading...", UDim2.new(1, -32, 0, 34), UDim2.fromOffset(16, 43), Enum.Font.GothamBlack, Color3.fromRGB(245, 245, 245))
dailyTitle.TextSize = 22
local dailyDescription = label(contractPage, "", UDim2.new(1, -32, 0, 58), UDim2.fromOffset(16, 82), Enum.Font.GothamMedium, Color3.fromRGB(190, 196, 207))
dailyDescription.TextWrapped = true
dailyDescription.TextYAlignment = Enum.TextYAlignment.Top

local dailyProgressBackground = Instance.new("Frame")
dailyProgressBackground.Size = UDim2.new(1, -32, 0, 16)
dailyProgressBackground.Position = UDim2.fromOffset(16, 157)
dailyProgressBackground.BackgroundColor3 = Color3.fromRGB(48, 53, 62)
dailyProgressBackground.BorderSizePixel = 0
dailyProgressBackground.Parent = contractPage
corner(dailyProgressBackground, 8)
local dailyProgressFill = Instance.new("Frame")
dailyProgressFill.Size = UDim2.fromScale(0, 1)
dailyProgressFill.BackgroundColor3 = Color3.fromRGB(107, 169, 255)
dailyProgressFill.BorderSizePixel = 0
dailyProgressFill.Parent = dailyProgressBackground
corner(dailyProgressFill, 8)

local dailyProgressLabel = label(contractPage, "0 / 1", UDim2.new(1, -32, 0, 24), UDim2.fromOffset(16, 184), Enum.Font.GothamBold, Color3.fromRGB(222, 226, 233), Enum.TextXAlignment.Center)
local dailyRewardLabel = label(contractPage, "$0 BANK REWARD", UDim2.new(1, -32, 0, 30), UDim2.fromOffset(16, 222), Enum.Font.GothamBlack, Color3.fromRGB(110, 232, 154), Enum.TextXAlignment.Center)
dailyRewardLabel.TextSize = 17
local dailyStatusLabel = label(contractPage, "Complete the objective to claim.", UDim2.new(1, -32, 0, 42), UDim2.fromOffset(16, 264), Enum.Font.GothamMedium, Color3.fromRGB(151, 157, 168), Enum.TextXAlignment.Center)
dailyStatusLabel.TextWrapped = true

local dailyClaimButton = Instance.new("TextButton")
dailyClaimButton.Size = UDim2.new(1, -32, 0, 48)
dailyClaimButton.Position = UDim2.new(0, 16, 1, -66)
dailyClaimButton.BackgroundColor3 = Color3.fromRGB(50, 91, 70)
dailyClaimButton.Text = "CLAIM BANK REWARD"
dailyClaimButton.TextColor3 = Color3.fromRGB(239, 246, 241)
dailyClaimButton.TextSize = 13
dailyClaimButton.Font = Enum.Font.GothamBold
dailyClaimButton.Parent = contractPage
corner(dailyClaimButton, 10)

local contactsTitle = label(cityPage, "CITY CONTACTS", UDim2.new(1, -32, 0, 28), UDim2.fromOffset(16, 18), Enum.Font.GothamBlack, Color3.fromRGB(245, 245, 245))
contactsTitle.TextSize = 20
local contactsList = label(cityPage, "QUICK STOP\nRegister robbery, delivery counter, back-room safe, and fuel pump\n\nRUST BELT AUTO\nVehicle sales, personal garage, repairs, tow dispatch, and salvage\n\nCOUNTY CLINIC\nFull treatment and medical courier work\n\nCOUNTY POLICE\nJail, patrol response, and Foundry Road checkpoint", UDim2.new(1, -32, 0, 260), UDim2.fromOffset(16, 58), Enum.Font.GothamMedium, Color3.fromRGB(202, 207, 216))
contactsList.TextSize = 12
contactsList.TextWrapped = true
contactsList.TextYAlignment = Enum.TextYAlignment.Top
local phoneCityStatus = label(cityPage, "CITY STATUS", UDim2.new(1, -32, 0, 70), UDim2.new(0, 16, 1, -88), Enum.Font.GothamBold, Color3.fromRGB(107, 169, 255), Enum.TextXAlignment.Center)
phoneCityStatus.TextWrapped = true

local profileTitle = label(profilePage, "PLAYER PROFILE", UDim2.new(1, -32, 0, 28), UDim2.fromOffset(16, 18), Enum.Font.GothamBlack, Color3.fromRGB(245, 245, 245))
profileTitle.TextSize = 20
local phoneProfileStats = label(profilePage, "", UDim2.new(1, -32, 0, 190), UDim2.fromOffset(16, 64), Enum.Font.GothamBold, Color3.fromRGB(215, 220, 228))
phoneProfileStats.TextSize = 15
phoneProfileStats.TextWrapped = true
phoneProfileStats.TextYAlignment = Enum.TextYAlignment.Top
local phoneProfileObjective = label(profilePage, "", UDim2.new(1, -32, 0, 120), UDim2.fromOffset(16, 262), Enum.Font.GothamMedium, Color3.fromRGB(160, 178, 202))
phoneProfileObjective.TextWrapped = true
phoneProfileObjective.TextYAlignment = Enum.TextYAlignment.Top

local activePhonePage = "Contract"
local function showPhonePage(name)
	activePhonePage = name
	for pageName, page in pairs(phonePages) do
		page.Visible = pageName == name
	end
	for pageName, button in pairs(phoneTabButtons) do
		button.BackgroundColor3 = pageName == name and Color3.fromRGB(65, 105, 151) or Color3.fromRGB(43, 49, 59)
		button.TextColor3 = pageName == name and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(190, 196, 207)
	end
end

local function setPhoneOpen(open)
	phonePanel.Visible = open == true
	phoneOpenButton.BackgroundColor3 = open and Color3.fromRGB(65, 105, 151) or Color3.fromRGB(32, 38, 47)
end

local function phoneMoney(value)
	local formatted = tostring(math.max(0, math.floor(tonumber(value) or 0)))
	while true do
		local replaced, count = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		formatted = replaced
		if count == 0 then break end
	end
	return formatted
end

local function updatePhone()
	local progress = player:GetAttribute("DailyContractProgress") or 0
	local goal = math.max(1, player:GetAttribute("DailyContractGoal") or 1)
	local reward = player:GetAttribute("DailyContractReward") or 0
	local claimed = player:GetAttribute("DailyContractClaimed") == true
	local complete = progress >= goal
	dailyTitle.Text = player:GetAttribute("DailyContractTitle") or "Loading..."
	dailyDescription.Text = player:GetAttribute("DailyContractDescription") or ""
	dailyProgressFill.Size = UDim2.fromScale(math.clamp(progress / goal, 0, 1), 1)
	dailyProgressLabel.Text = progress .. " / " .. goal
	dailyRewardLabel.Text = "$" .. phoneMoney(reward) .. " BANK REWARD"
	if claimed then
		dailyClaimButton.Text = "REWARD CLAIMED"
		dailyClaimButton.BackgroundColor3 = Color3.fromRGB(48, 53, 62)
		dailyStatusLabel.Text = "Come back after the next UTC daily reset."
	elseif complete then
		dailyClaimButton.Text = "CLAIM $" .. phoneMoney(reward)
		dailyClaimButton.BackgroundColor3 = Color3.fromRGB(50, 111, 76)
		dailyStatusLabel.Text = "Contract complete — reward ready."
	else
		dailyClaimButton.Text = "CONTRACT INCOMPLETE"
		dailyClaimButton.BackgroundColor3 = Color3.fromRGB(65, 69, 78)
		dailyStatusLabel.Text = "Complete the objective to claim."
	end

	local phase = workspace:GetAttribute("WorldPhase") or "DAY"
	local weather = workspace:GetAttribute("Weather") or "CLEAR"
	local response = workspace:GetAttribute("PoliceResponse") or "PATROL"
	local officers = workspace:GetAttribute("ActiveOfficerCount") or 0
	phoneCityStatus.Text = phase .. " • " .. weather .. "\n" .. response .. " • " .. officers .. " ACTIVE OFFICERS"

	local heat = player:GetAttribute("Heat") or 0
	local bounty = player:GetAttribute("Bounty") or 0
	local ownsVehicle = player:GetAttribute("OwnsRustCompact") == true
	local vehicleStatus = ownsVehicle and ((player:GetAttribute("VehicleActive") and "SPAWNED" or "STORED") .. " • " .. math.floor(player:GetAttribute("VehicleFuel") or 0) .. "% FUEL • " .. math.floor(player:GetAttribute("VehicleCondition") or 0) .. "% CONDITION") or "NOT OWNED"
	phoneProfileStats.Text = player.DisplayName .. "\n\nWALLET   $" .. phoneMoney(player:GetAttribute("Cash")) .. "\nBANK      $" .. phoneMoney(player:GetAttribute("Bank")) .. "\nWANTED   " .. heat .. "/5\nBOUNTY   $" .. phoneMoney(bounty) .. "\nVEHICLE  " .. vehicleStatus
	phoneProfileObjective.Text = "CURRENT OBJECTIVE\n" .. (player:GetAttribute("Objective") or "Explore the district.")
end

contractTab.Activated:Connect(function() showPhonePage("Contract") end)
cityTab.Activated:Connect(function() showPhonePage("City") end)
profileTab.Activated:Connect(function() showPhonePage("Profile") end)
phoneOpenButton.Activated:Connect(function()
	setPhoneOpen(not phonePanel.Visible)
	updatePhone()
end)
phoneCloseButton.Activated:Connect(function() setPhoneOpen(false) end)
dailyClaimButton.Activated:Connect(function()
	local progress = player:GetAttribute("DailyContractProgress") or 0
	local goal = player:GetAttribute("DailyContractGoal") or 1
	if progress >= goal and player:GetAttribute("DailyContractClaimed") ~= true then
		phoneActionRemote:FireServer("ClaimDailyContract")
	end
end)
showPhonePage("Contract")

local vehiclePanel = Instance.new("Frame")
vehiclePanel.Name = "VehicleStatus"
vehiclePanel.AnchorPoint = Vector2.new(1, 0)
vehiclePanel.Size = UDim2.fromOffset(282, 94)
vehiclePanel.Position = UDim2.new(1, -18, 0, 18)
vehiclePanel.BackgroundColor3 = Color3.fromRGB(14, 17, 22)
vehiclePanel.BackgroundTransparency = 0.06
vehiclePanel.Visible = false
vehiclePanel.Parent = gui
corner(vehiclePanel, 11)
stroke(vehiclePanel, Color3.fromRGB(75, 126, 165), 0.18)

local vehicleHudTitle = label(vehiclePanel, "RUST COMPACT", UDim2.new(1, -24, 0, 21), UDim2.fromOffset(12, 9), Enum.Font.GothamBlack, Color3.fromRGB(226, 232, 239))
vehicleHudTitle.TextSize = 13
local vehicleFuelLabel = label(vehiclePanel, "FUEL 100%", UDim2.fromOffset(122, 22), UDim2.fromOffset(12, 39), Enum.Font.GothamBold, Color3.fromRGB(107, 169, 255))
vehicleFuelLabel.TextSize = 12
local vehicleConditionLabel = label(vehiclePanel, "CONDITION 100%", UDim2.fromOffset(138, 22), UDim2.fromOffset(136, 39), Enum.Font.GothamBold, Color3.fromRGB(110, 232, 154), Enum.TextXAlignment.Right)
vehicleConditionLabel.TextSize = 12
local vehicleAudioHint = label(vehiclePanel, "H  HORN  •  DYNAMIC ENGINE AUDIO", UDim2.new(1, -24, 0, 16), UDim2.fromOffset(12, 68), Enum.Font.GothamMedium, Color3.fromRGB(142, 148, 158))
vehicleAudioHint.TextSize = 9

local function updateVehicleHud()
	local active = player:GetAttribute("VehicleActive") == true
	local fuel = math.clamp(player:GetAttribute("VehicleFuel") or 0, 0, 100)
	local condition = math.clamp(player:GetAttribute("VehicleCondition") or 0, 0, 100)
	vehiclePanel.Visible = active
	vehicleFuelLabel.Text = "FUEL  " .. math.floor(fuel + 0.5) .. "%"
	vehicleConditionLabel.Text = "CONDITION  " .. math.floor(condition + 0.5) .. "%"
	vehicleFuelLabel.TextColor3 = fuel <= 20 and Color3.fromRGB(255, 104, 104) or Color3.fromRGB(107, 169, 255)
	vehicleConditionLabel.TextColor3 = condition <= 35 and Color3.fromRGB(255, 104, 104) or Color3.fromRGB(110, 232, 154)
	if fuel <= 0 then
		vehicleHudTitle.Text = "RUST COMPACT • OUT OF FUEL"
	elseif condition <= 0 then
		vehicleHudTitle.Text = "RUST COMPACT • DISABLED"
	else
		vehicleHudTitle.Text = "RUST COMPACT • ACTIVE"
	end
end

local statsPanel = Instance.new("Frame")
statsPanel.Name = "Stats"
statsPanel.Size = UDim2.fromOffset(300, 126)
statsPanel.Position = UDim2.fromOffset(18, 18)
statsPanel.BackgroundColor3 = Color3.fromRGB(14, 16, 19)
statsPanel.BackgroundTransparency = 0.08
statsPanel.Parent = gui
corner(statsPanel, 10)
stroke(statsPanel, Color3.fromRGB(63, 68, 77), 0.25)

local accent = Instance.new("Frame")
accent.Size = UDim2.new(0, 5, 1, 0)
accent.BackgroundColor3 = Color3.fromRGB(233, 72, 72)
accent.BorderSizePixel = 0
accent.Parent = statsPanel
corner(accent, 10)

local title = label(statsPanel, "OHIO 2", UDim2.new(1, -30, 0, 27), UDim2.fromOffset(18, 9), Enum.Font.GothamBlack, Color3.fromRGB(245, 245, 245))
title.TextSize = 21
local build = label(statsPanel, "WORLD + GUNPLAY  •  BUILD 1.3", UDim2.new(1, -30, 0, 18), UDim2.fromOffset(18, 33), Enum.Font.GothamMedium, Color3.fromRGB(137, 143, 153))
build.TextSize = 10

local cashLabel = label(statsPanel, "$1,000 WALLET", UDim2.fromOffset(132, 25), UDim2.fromOffset(18, 61), Enum.Font.GothamBold, Color3.fromRGB(105, 230, 150))
cashLabel.TextSize = 15
local bankLabel = label(statsPanel, "$0 BANK", UDim2.fromOffset(132, 25), UDim2.fromOffset(157, 61), Enum.Font.GothamBold, Color3.fromRGB(107, 169, 255))
bankLabel.TextSize = 15
local heatLabel = label(statsPanel, "NOT WANTED", UDim2.new(1, -36, 0, 22), UDim2.fromOffset(18, 93), Enum.Font.GothamBold, Color3.fromRGB(170, 175, 185))
heatLabel.TextSize = 12

local vitalsPanel = Instance.new("Frame")
vitalsPanel.Size = UDim2.fromOffset(300, 78)
vitalsPanel.Position = UDim2.fromOffset(18, 153)
vitalsPanel.BackgroundColor3 = Color3.fromRGB(14, 16, 19)
vitalsPanel.BackgroundTransparency = 0.08
vitalsPanel.Parent = gui
corner(vitalsPanel, 10)
stroke(vitalsPanel, Color3.fromRGB(63, 68, 77), 0.25)

local function makeMeter(parent, name, y, color)
	local meterLabel = label(parent, name, UDim2.fromOffset(76, 18), UDim2.fromOffset(12, y), Enum.Font.GothamBold, color)
	meterLabel.TextSize = 10
	local background = Instance.new("Frame")
	background.Size = UDim2.fromOffset(194, 10)
	background.Position = UDim2.fromOffset(92, y + 4)
	background.BackgroundColor3 = Color3.fromRGB(47, 50, 57)
	background.BorderSizePixel = 0
	background.Parent = parent
	corner(background, 5)
	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(1, 1)
	fill.BackgroundColor3 = color
	fill.BorderSizePixel = 0
	fill.Parent = background
	corner(fill, 5)
	return meterLabel, fill
end

local healthMeterLabel, healthFill = makeMeter(vitalsPanel, "HEALTH 100", 10, Color3.fromRGB(110, 232, 154))
local staminaMeterLabel, staminaFill = makeMeter(vitalsPanel, "STAMINA 100", 32, Color3.fromRGB(255, 205, 91))
local stateLabel = label(vitalsPanel, "SPAWN SAFE", UDim2.new(1, -24, 0, 18), UDim2.fromOffset(12, 55), Enum.Font.GothamBold, Color3.fromRGB(107, 169, 255))
stateLabel.TextSize = 10

local objectivePanel = Instance.new("Frame")
objectivePanel.Size = UDim2.new(0, 460, 0, 76)
objectivePanel.AnchorPoint = Vector2.new(0.5, 0)
objectivePanel.Position = UDim2.new(0.5, 0, 0, 18)
objectivePanel.BackgroundColor3 = Color3.fromRGB(14, 16, 19)
objectivePanel.BackgroundTransparency = 0.08
objectivePanel.Parent = gui
corner(objectivePanel, 10)
stroke(objectivePanel, Color3.fromRGB(63, 68, 77), 0.25)

local objectiveTitle = label(objectivePanel, "CURRENT OBJECTIVE", UDim2.new(1, -28, 0, 20), UDim2.fromOffset(14, 10), Enum.Font.GothamBold, Color3.fromRGB(233, 72, 72))
objectiveTitle.TextSize = 11
objectiveTitle.Size = UDim2.fromOffset(190, 20)
local worldLabel = label(objectivePanel, "DUSK • POWER ONLINE", UDim2.fromOffset(235, 20), UDim2.fromOffset(211, 10), Enum.Font.GothamBold, Color3.fromRGB(137, 143, 153), Enum.TextXAlignment.Right)
worldLabel.TextSize = 10
local objectiveLabel = label(objectivePanel, "Find work, buy equipment, or risk a robbery.", UDim2.new(1, -28, 0, 34), UDim2.fromOffset(14, 31), Enum.Font.GothamMedium, Color3.fromRGB(238, 239, 242))
objectiveLabel.TextSize = 14
objectiveLabel.TextWrapped = true
objectiveLabel.TextYAlignment = Enum.TextYAlignment.Top

local inventoryPanel = Instance.new("Frame")
inventoryPanel.Size = UDim2.fromOffset(250, 136)
inventoryPanel.AnchorPoint = Vector2.new(1, 1)
inventoryPanel.Position = UDim2.new(1, -18, 1, -18)
inventoryPanel.BackgroundColor3 = Color3.fromRGB(14, 16, 19)
inventoryPanel.BackgroundTransparency = 0.08
inventoryPanel.Parent = gui
corner(inventoryPanel, 10)
stroke(inventoryPanel, Color3.fromRGB(63, 68, 77), 0.25)

local inventoryTitle = label(inventoryPanel, "CARRIED LOOT", UDim2.new(1, -24, 0, 23), UDim2.fromOffset(12, 9), Enum.Font.GothamBold, Color3.fromRGB(238, 239, 242))
inventoryTitle.TextSize = 12
local inventoryLabel = label(inventoryPanel, "Empty", UDim2.new(1, -24, 0, 69), UDim2.fromOffset(12, 34), Enum.Font.Code, Color3.fromRGB(181, 185, 194))
inventoryLabel.TextSize = 13
inventoryLabel.TextWrapped = true
inventoryLabel.TextYAlignment = Enum.TextYAlignment.Top
local stashLabel = label(inventoryPanel, "SAFE STASH: 0 ITEMS", UDim2.new(1, -24, 0, 20), UDim2.fromOffset(12, 108), Enum.Font.GothamBold, Color3.fromRGB(107, 169, 255))
stashLabel.TextSize = 10

local controls = label(gui, "GUNS LOCK TO CENTER CROSSHAIR   •   CLICK / TAP  FIRE   •   R  RELOAD   •   H  HORN", UDim2.fromOffset(650, 22), UDim2.new(0, 18, 1, -38), Enum.Font.GothamBold, Color3.fromRGB(220, 223, 230))
controls.TextSize = 10

local actionPanel = Instance.new("Frame")
actionPanel.Size = UDim2.fromOffset(224, 48)
actionPanel.Position = UDim2.new(0, 18, 1, -92)
actionPanel.BackgroundTransparency = 1
actionPanel.Parent = gui

local sprintButton = Instance.new("TextButton")
sprintButton.Size = UDim2.fromOffset(106, 42)
sprintButton.BackgroundColor3 = Color3.fromRGB(58, 63, 72)
sprintButton.TextColor3 = Color3.fromRGB(245, 245, 245)
sprintButton.Text = "SHIFT  SPRINT"
sprintButton.TextSize = 11
sprintButton.Font = Enum.Font.GothamBold
sprintButton.Parent = actionPanel
corner(sprintButton, 8)

local blockButton = Instance.new("TextButton")
blockButton.Size = UDim2.fromOffset(106, 42)
blockButton.Position = UDim2.fromOffset(118, 0)
blockButton.BackgroundColor3 = Color3.fromRGB(58, 63, 72)
blockButton.TextColor3 = Color3.fromRGB(245, 245, 245)
blockButton.Text = "F  BLOCK"
blockButton.TextSize = 11
blockButton.Font = Enum.Font.GothamBold
blockButton.Parent = actionPanel
corner(blockButton, 8)

local aimGui = Instance.new("ScreenGui")
aimGui.Name = "Ohio2AimHUD"
aimGui.ResetOnSpawn = false
aimGui.IgnoreGuiInset = true
aimGui.DisplayOrder = 20
aimGui.Parent = player.PlayerGui

local crosshair = Instance.new("Frame")
crosshair.Name = "Crosshair"
crosshair.Size = UDim2.fromOffset(18, 18)
crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
crosshair.Position = UDim2.fromScale(0.5, 0.5)
crosshair.BackgroundTransparency = 1
crosshair.Visible = false
crosshair.Parent = aimGui
local crosshairLines = {}
for _, data in ipairs({
	{UDim2.fromOffset(8, 0), UDim2.fromOffset(2, 6)},
	{UDim2.fromOffset(8, 12), UDim2.fromOffset(2, 6)},
	{UDim2.fromOffset(0, 8), UDim2.fromOffset(6, 2)},
	{UDim2.fromOffset(12, 8), UDim2.fromOffset(6, 2)},
}) do
	local line = Instance.new("Frame")
	line.Position = data[1]
	line.Size = data[2]
	line.BorderSizePixel = 0
	line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	line.Parent = crosshair
	table.insert(crosshairLines, line)
end
local crosshairDot = Instance.new("Frame")
crosshairDot.Name = "CenterDot"
crosshairDot.AnchorPoint = Vector2.new(0.5, 0.5)
crosshairDot.Size = UDim2.fromOffset(3, 3)
crosshairDot.Position = UDim2.fromScale(0.5, 0.5)
crosshairDot.BorderSizePixel = 0
crosshairDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
crosshairDot.Parent = crosshair
corner(crosshairDot, 3)
local crosshairHint = label(aimGui, "CENTER AIM", UDim2.fromOffset(120, 18), UDim2.new(0.5, -60, 0.5, 20), Enum.Font.GothamBold, Color3.fromRGB(205, 210, 218), Enum.TextXAlignment.Center)
crosshairHint.TextSize = 9
crosshairHint.Visible = false

local ammoPanel = Instance.new("Frame")
ammoPanel.Size = UDim2.fromOffset(245, 54)
ammoPanel.AnchorPoint = Vector2.new(0.5, 1)
ammoPanel.Position = UDim2.new(0.5, 0, 1, -18)
ammoPanel.BackgroundColor3 = Color3.fromRGB(14, 16, 19)
ammoPanel.BackgroundTransparency = 0.06
ammoPanel.Visible = false
ammoPanel.Parent = gui
corner(ammoPanel, 9)
stroke(ammoPanel, Color3.fromRGB(63, 68, 77), 0.2)

local ammoLabel = label(ammoPanel, "12 / 36", UDim2.fromOffset(122, 36), UDim2.fromOffset(13, 9), Enum.Font.GothamBlack, Color3.fromRGB(245, 245, 245))
ammoLabel.TextSize = 23
local reloadButton = Instance.new("TextButton")
reloadButton.Size = UDim2.fromOffset(98, 34)
reloadButton.Position = UDim2.fromOffset(137, 10)
reloadButton.BackgroundColor3 = Color3.fromRGB(196, 58, 58)
reloadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
reloadButton.Text = "R  RELOAD"
reloadButton.TextSize = 11
reloadButton.Font = Enum.Font.GothamBold
reloadButton.AutoButtonColor = true
reloadButton.Parent = ammoPanel
corner(reloadButton, 7)

local hitmarker = label(gui, "✕", UDim2.fromOffset(60, 60), UDim2.new(0.5, -30, 0.5, -30), Enum.Font.GothamBlack, Color3.fromRGB(245, 245, 245), Enum.TextXAlignment.Center)
hitmarker.TextSize = 31
hitmarker.TextTransparency = 1
hitmarker.TextYAlignment = Enum.TextYAlignment.Center

local downedOverlay = Instance.new("Frame")
downedOverlay.Size = UDim2.fromScale(1, 1)
downedOverlay.BackgroundColor3 = Color3.fromRGB(115, 12, 16)
downedOverlay.BackgroundTransparency = 0.68
downedOverlay.Visible = false
downedOverlay.ZIndex = 20
downedOverlay.Parent = gui
local downedTitle = label(downedOverlay, "YOU ARE DOWNED", UDim2.new(1, 0, 0, 58), UDim2.new(0, 0, 0.5, -62), Enum.Font.GothamBlack, Color3.fromRGB(255, 235, 235), Enum.TextXAlignment.Center)
downedTitle.TextSize = 34
downedTitle.ZIndex = 21
local downedHelp = label(downedOverlay, "Another player can hold the revive prompt. Police can arrest you while wanted.", UDim2.new(1, -40, 0, 48), UDim2.new(0, 20, 0.5, 2), Enum.Font.GothamBold, Color3.fromRGB(255, 200, 200), Enum.TextXAlignment.Center)
downedHelp.TextSize = 14
downedHelp.TextWrapped = true
downedHelp.ZIndex = 21

local mouseLockActive = false
local previousMouseBehavior = Enum.MouseBehavior.Default
local previousMouseIconEnabled = true

local function currentItemDefinition()
	local itemId = currentTool and currentTool:GetAttribute("Ohio2Item")
	return itemId, itemId and itemDefinitions[itemId] or nil
end

local function getCenterAimRay()
	local camera = workspace.CurrentCamera
	if not camera then
		return nil, nil
	end
	local point = camera.ViewportSize * 0.5
	local ray = camera:ViewportPointToRay(point.X, point.Y)
	return ray.Origin, ray.Direction.Unit
end

local function humanoidFromHitPart(part)
	local ancestor = part
	while ancestor and ancestor ~= workspace do
		if ancestor:IsA("Model") then
			local humanoid = ancestor:FindFirstChildOfClass("Humanoid")
			if humanoid then
				return humanoid
			end
		end
		ancestor = ancestor.Parent
	end
end

local function setCrosshairColor(color)
	for _, line in ipairs(crosshairLines) do
		line.BackgroundColor3 = color
	end
	crosshairDot.BackgroundColor3 = color
end

RunService:BindToRenderStep("Ohio2CenteredGunAim", Enum.RenderPriority.Camera.Value + 1, function(deltaTime)
	local _, item = currentItemDefinition()
	local gunEquipped = item and item.Kind == "Gun" and currentTool and currentTool.Parent ~= nil
	local aiming = gunEquipped and player:GetAttribute("Downed") ~= true and not phonePanel.Visible
	crosshair.Visible = aiming
	crosshairHint.Visible = aiming

	local desktopAim = aiming and UserInputService.MouseEnabled
	if desktopAim then
		if not mouseLockActive then
			previousMouseBehavior = UserInputService.MouseBehavior
			previousMouseIconEnabled = UserInputService.MouseIconEnabled
			mouseLockActive = true
		end
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		UserInputService.MouseIconEnabled = false
	elseif mouseLockActive then
		mouseLockActive = false
		UserInputService.MouseBehavior = previousMouseBehavior
		UserInputService.MouseIconEnabled = previousMouseIconEnabled
	end

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local camera = workspace.CurrentCamera
	if humanoid then
		local desiredOffset = aiming and Vector3.new(1.45, 0.3, 0) or Vector3.zero
		humanoid.CameraOffset = humanoid.CameraOffset:Lerp(desiredOffset, math.clamp(deltaTime * 10, 0, 1))
		if desktopAim and root and camera and not humanoid.Sit then
			local flatLook = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)
			if flatLook.Magnitude > 0.01 then
				humanoid.AutoRotate = false
				root.CFrame = root.CFrame:Lerp(CFrame.lookAt(root.Position, root.Position + flatLook.Unit), math.clamp(deltaTime * 16, 0, 1))
			end
		elseif not aiming then
			humanoid.AutoRotate = true
		end
	end

	if aiming and camera then
		local origin, direction = getCenterAimRay()
		if origin and direction then
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = character and {character} or {}
			params.IgnoreWater = true
			local result = workspace:Raycast(origin, direction * 500, params)
			local targetHumanoid = result and humanoidFromHitPart(result.Instance)
			setCrosshairColor(targetHumanoid and targetHumanoid.Health > 0 and Color3.fromRGB(255, 112, 105) or Color3.fromRGB(245, 247, 250))
		end
	end
end)

local toastHolder = Instance.new("Frame")
toastHolder.Size = UDim2.fromOffset(420, 210)
toastHolder.AnchorPoint = Vector2.new(0.5, 1)
toastHolder.Position = UDim2.new(0.5, 0, 1, -55)
toastHolder.BackgroundTransparency = 1
toastHolder.Parent = gui

local toastLayout = Instance.new("UIListLayout")
toastLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
toastLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
toastLayout.Padding = UDim.new(0, 7)
toastLayout.Parent = toastHolder

local function formatNumber(number)
	local formatted = tostring(math.floor(number or 0))
	repeat
		local replacements
		formatted, replacements = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
	until replacements == 0
	return formatted
end

local function updateVitals()
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	local health = humanoid and humanoid.Health or 0
	local maxHealth = humanoid and humanoid.MaxHealth or 100
	local stamina = player:GetAttribute("Stamina") or 0
	healthFill.Size = UDim2.fromScale(math.clamp(health / math.max(1, maxHealth), 0, 1), 1)
	staminaFill.Size = UDim2.fromScale(math.clamp(stamina / 100, 0, 1), 1)
	healthMeterLabel.Text = "HEALTH " .. math.ceil(health)
	staminaMeterLabel.Text = "STAMINA " .. math.floor(stamina)

	local blocking = player:GetAttribute("Blocking") == true
	local sprinting = player:GetAttribute("Sprinting") == true
	local spawnProtected = player:GetAttribute("SpawnProtected") == true
	local balloonEquipped = player:GetAttribute("BalloonEquipped") == true
	if player:GetAttribute("Downed") then
		stateLabel.Text = "DOWNED • REVIVE NEEDED"
		stateLabel.TextColor3 = Color3.fromRGB(255, 104, 104)
	elseif spawnProtected then
		stateLabel.Text = "SPAWN SAFE • ATTACKING ENDS PROTECTION"
		stateLabel.TextColor3 = Color3.fromRGB(107, 169, 255)
	elseif blocking then
		stateLabel.Text = "BLOCKING • 65% MELEE DAMAGE REDUCTION"
		stateLabel.TextColor3 = Color3.fromRGB(107, 169, 255)
	elseif sprinting then
		stateLabel.Text = "SPRINTING"
		stateLabel.TextColor3 = Color3.fromRGB(255, 205, 91)
	elseif balloonEquipped then
		stateLabel.Text = "BALLOON LIFT • HIGH JUMP ACTIVE"
		stateLabel.TextColor3 = Color3.fromRGB(255, 112, 137)
	else
		stateLabel.Text = "READY"
		stateLabel.TextColor3 = Color3.fromRGB(170, 175, 185)
	end
	sprintButton.BackgroundColor3 = sprinting and Color3.fromRGB(196, 137, 52) or Color3.fromRGB(58, 63, 72)
	blockButton.BackgroundColor3 = blocking and Color3.fromRGB(60, 112, 179) or Color3.fromRGB(58, 63, 72)
end

local function updateStats()
	local cash = player:GetAttribute("Cash") or 0
	local bank = player:GetAttribute("Bank") or 0
	local heat = player:GetAttribute("Heat") or 0
	local bounty = player:GetAttribute("Bounty") or 0
	cashLabel.Text = "$" .. formatNumber(cash) .. " WALLET"
	bankLabel.Text = "$" .. formatNumber(bank) .. " BANK"
	if heat > 0 then
		heatLabel.Text = "WANTED  " .. string.rep("★", heat) .. string.rep("☆", 5 - heat) .. "  •  $" .. formatNumber(bounty) .. " BOUNTY"
		heatLabel.TextColor3 = Color3.fromRGB(255, 96, 96)
	elseif bounty > 0 then
		heatLabel.Text = "$" .. formatNumber(bounty) .. " BOUNTY • OTHER PLAYERS CAN CLAIM IT"
		heatLabel.TextColor3 = Color3.fromRGB(255, 160, 84)
	else
		heatLabel.Text = "NOT WANTED"
		heatLabel.TextColor3 = Color3.fromRGB(170, 175, 185)
	end
end

local function updateWorldState()
	local phase = workspace:GetAttribute("WorldPhase") or "DUSK"
	local weather = workspace:GetAttribute("Weather") or "CLEAR"
	local blackout = workspace:GetAttribute("Blackout") == true
	local armoredTruck = workspace:GetAttribute("ArmoredTruckActive") == true
	local storeAlarm = workspace:GetAttribute("QuickStopAlarm") == true
	local response = workspace:GetAttribute("PoliceResponse") or "PATROL"
	local officers = workspace:GetAttribute("ActiveOfficerCount") or 0
	local civilians = workspace:GetAttribute("CivilianCount") or 0
	if armoredTruck and blackout then
		worldLabel.Text = "ARMORED TRUCK • BLACKOUT"
		worldLabel.TextColor3 = Color3.fromRGB(255, 104, 104)
	elseif armoredTruck then
		worldLabel.Text = "ARMORED TRUCK • " .. response
		worldLabel.TextColor3 = Color3.fromRGB(255, 104, 104)
	elseif storeAlarm then
		worldLabel.Text = "QUICK STOP ALARM • " .. response .. " • " .. officers .. " UNITS"
		worldLabel.TextColor3 = Color3.fromRGB(255, 104, 104)
	elseif blackout then
		worldLabel.Text = phase .. " • " .. weather .. " • CITYWIDE BLACKOUT"
		worldLabel.TextColor3 = Color3.fromRGB(151, 173, 255)
	elseif response ~= "PATROL" then
		worldLabel.Text = response .. " • " .. officers .. " OFFICERS • " .. weather
		worldLabel.TextColor3 = response == "MAXIMUM RESPONSE" and Color3.fromRGB(255, 104, 104) or Color3.fromRGB(255, 174, 91)
	else
		worldLabel.Text = phase .. " • " .. weather .. " • " .. civilians .. " CIVILIANS"
		worldLabel.TextColor3 = phase == "NIGHT" and Color3.fromRGB(151, 173, 255) or Color3.fromRGB(137, 143, 153)
	end
end

local function containerTotal(container)
	local total = 0
	if container then
		for _, value in ipairs(container:GetChildren()) do
			if value:IsA("IntValue") then
				total = total + value.Value
			end
		end
	end
	return total
end

local function updateAmmo()
	local itemId = currentTool and currentTool:GetAttribute("Ohio2Item")
	local item = itemId and itemDefinitions[itemId]
	if not item or item.Kind ~= "Gun" or not currentTool.Parent then
		ammoPanel.Visible = false
		return
	end
	local inventory = player:FindFirstChild("Inventory")
	local reserveValue = inventory and inventory:FindFirstChild(item.AmmoItem)
	local reserve = reserveValue and reserveValue.Value or 0
	local magazine = player:GetAttribute("Magazine_" .. itemId) or 0
	ammoPanel.Visible = true
	ammoLabel.Text = tostring(magazine) .. " / " .. tostring(reserve)
	ammoLabel.TextColor3 = magazine <= 0 and Color3.fromRGB(255, 104, 104) or Color3.fromRGB(245, 245, 245)
	reloadButton.Text = reloading and "RELOADING..." or "R  RELOAD"
	reloadButton.BackgroundColor3 = reloading and Color3.fromRGB(91, 95, 105) or Color3.fromRGB(196, 58, 58)
end

local function requestReload()
	local itemId = currentTool and currentTool:GetAttribute("Ohio2Item")
	local item = itemId and itemDefinitions[itemId]
	if item and item.Kind == "Gun" and not reloading then
		weaponActionRemote:FireServer("Reload")
	end
end

local function updateInventory()
	local inventory = player:FindFirstChild("Inventory")
	local stash = player:FindFirstChild("Stash")
	local lines = {}
	if inventory then
		for _, value in ipairs(inventory:GetChildren()) do
			local definition = itemDefinitions[value.Name]
			if value:IsA("IntValue") and definition and value.Value > 0 then
				table.insert(lines, "• " .. definition.DisplayName .. (value.Value > 1 and ("  x" .. value.Value) or ""))
			end
		end
	end
	table.sort(lines)
	inventoryLabel.Text = #lines > 0 and table.concat(lines, "\n") or "Empty — carried items drop on death"
	stashLabel.Text = "SAFE STASH: " .. containerTotal(stash) .. " ITEM(S)"
	updateAmmo()
end

local function watchContainer(container)
	local function watchValue(value)
		if value:IsA("IntValue") then
			value:GetPropertyChangedSignal("Value"):Connect(updateInventory)
		end
	end
	for _, value in ipairs(container:GetChildren()) do
		watchValue(value)
	end
	container.ChildAdded:Connect(function(value)
		watchValue(value)
		updateInventory()
	end)
	container.ChildRemoved:Connect(updateInventory)
	updateInventory()
end

local function showNotification(text, color)
	local toast = Instance.new("TextLabel")
	toast.Size = UDim2.fromOffset(390, 42)
	toast.BackgroundColor3 = Color3.fromRGB(17, 19, 23)
	toast.BackgroundTransparency = 1
	toast.TextTransparency = 1
	toast.Text = tostring(text)
	toast.TextColor3 = color or Color3.new(1, 1, 1)
	toast.TextSize = 13
	toast.Font = Enum.Font.GothamBold
	toast.TextWrapped = true
	toast.Parent = toastHolder
	corner(toast, 8)
	stroke(toast, color or Color3.fromRGB(95, 101, 112), 0.35)

	TweenService:Create(toast, TweenInfo.new(0.18), {BackgroundTransparency = 0.08, TextTransparency = 0}):Play()
	task.delay(3.4, function()
		if not toast.Parent then
			return
		end
		local tween = TweenService:Create(toast, TweenInfo.new(0.25), {BackgroundTransparency = 1, TextTransparency = 1})
		tween:Play()
		tween.Completed:Wait()
		toast:Destroy()
	end)
end

notificationRemote.OnClientEvent:Connect(showNotification)
objectiveRemote.OnClientEvent:Connect(function(text)
	objectiveLabel.Text = tostring(text)
end)
local impactColors = {
	Metal = Color3.fromRGB(255, 188, 86),
	DiamondPlate = Color3.fromRGB(255, 188, 86),
	Wood = Color3.fromRGB(151, 105, 67),
	WoodPlanks = Color3.fromRGB(151, 105, 67),
	Grass = Color3.fromRGB(92, 111, 67),
	Ground = Color3.fromRGB(117, 91, 66),
	Sand = Color3.fromRGB(176, 156, 112),
	Concrete = Color3.fromRGB(143, 146, 148),
	Brick = Color3.fromRGB(137, 79, 66),
}

local function spawnMuzzleFlash(position, itemId)
	local emitter = Instance.new("Part")
	emitter.Name = "Ohio2MuzzleFlash"
	emitter.Shape = Enum.PartType.Ball
	emitter.Size = itemId == "Shotgun" and Vector3.new(0.22, 0.22, 0.22) or Vector3.new(0.13, 0.13, 0.13)
	emitter.CFrame = CFrame.new(position)
	emitter.Color = Color3.fromRGB(255, 206, 94)
	emitter.Material = Enum.Material.Neon
	emitter.Transparency = 0.08
	emitter.Anchored = true
	emitter.CanCollide = false
	emitter.CanQuery = false
	emitter.CanTouch = false
	emitter.Parent = workspace
	local attachment = Instance.new("Attachment")
	attachment.Parent = emitter
	local sparks = Instance.new("ParticleEmitter")
	sparks.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparks.Color = ColorSequence.new(Color3.fromRGB(255, 218, 126), Color3.fromRGB(255, 91, 34))
	sparks.LightEmission = 1
	sparks.Lifetime = NumberRange.new(0.035, 0.075)
	sparks.Speed = itemId == "Shotgun" and NumberRange.new(8, 14) or NumberRange.new(5, 9)
	sparks.SpreadAngle = Vector2.new(38, 38)
	sparks.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, itemId == "Shotgun" and 0.18 or 0.1),
		NumberSequenceKeypoint.new(1, 0),
	})
	sparks.Parent = attachment
	sparks:Emit(itemId == "Shotgun" and 11 or 6)
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 181, 72)
	light.Range = itemId == "Shotgun" and 12 or 7
	light.Brightness = itemId == "Shotgun" and 4 or 2.4
	light.Shadows = true
	light.Parent = emitter
	Debris:AddItem(emitter, 0.085)
end

local function spawnImpact(position, normal, materialName)
	if typeof(normal) ~= "Vector3" or normal.Magnitude < 0.5 then
		return
	end
	local color = impactColors[materialName] or Color3.fromRGB(132, 134, 138)
	local mark = Instance.new("Part")
	mark.Name = "Ohio2BulletMark"
	mark.Size = Vector3.new(0.12, 0.12, 0.018)
	mark.CFrame = CFrame.lookAt(position + normal * 0.012, position + normal)
	mark.Color = color:Lerp(Color3.fromRGB(18, 18, 20), 0.72)
	mark.Material = Enum.Material.SmoothPlastic
	mark.Anchored = true
	mark.CanCollide = false
	mark.CanQuery = false
	mark.CanTouch = false
	mark.Parent = workspace
	Debris:AddItem(mark, 12)

	local attachment = Instance.new("Attachment")
	attachment.Parent = mark
	local particles = Instance.new("ParticleEmitter")
	particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particles.Color = ColorSequence.new(color)
	local sparksOnMetal = materialName == "Metal" or materialName == "DiamondPlate"
	particles.LightEmission = sparksOnMetal and 0.9 or 0.12
	particles.Lifetime = NumberRange.new(0.12, 0.28)
	particles.Speed = NumberRange.new(2.5, 6.5)
	particles.Drag = 7
	particles.Acceleration = Vector3.new(0, -18, 0)
	particles.SpreadAngle = Vector2.new(65, 65)
	particles.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.06), NumberSequenceKeypoint.new(1, 0)})
	particles.Parent = attachment
	particles:Emit(sparksOnMetal and 8 or 4)
end

weaponFXRemote.OnClientEvent:Connect(function(origin, hitPosition, itemId, playReport, hitNormal, materialName, playImpact)
	if typeof(origin) ~= "Vector3" or typeof(hitPosition) ~= "Vector3" then
		return
	end
	local length = (hitPosition - origin).Magnitude
	if length <= 0 then
		return
	end
	local tracer = Instance.new("Part")
	tracer.Name = "Ohio2Tracer"
	tracer.Anchored = true
	tracer.CanCollide = false
	tracer.CanQuery = false
	tracer.CanTouch = false
	tracer.Material = Enum.Material.Neon
	tracer.Color = itemId == "Shotgun" and Color3.fromRGB(255, 193, 98) or Color3.fromRGB(255, 225, 151)
	tracer.Transparency = 0.22
	tracer.Size = Vector3.new(0.026, 0.026, length)
	tracer.CFrame = CFrame.lookAt((origin + hitPosition) * 0.5, hitPosition)
	tracer.Parent = workspace
	Debris:AddItem(tracer, 0.045)
	if playReport then
		spawnMuzzleFlash(origin, itemId)
	end
	if playImpact then
		spawnImpact(hitPosition, hitNormal, materialName)
		playSpatialSound("BulletImpact", hitPosition, materialName == "Metal" and 1.15 or 0.8, materialName == "Wood" and 0.82 or 1)
	end
end)

local hitmarkerSequence = 0
local function showHitmarker(text, color, duration)
	hitmarkerSequence = hitmarkerSequence + 1
	local sequence = hitmarkerSequence
	hitmarker.Text = text
	hitmarker.TextColor3 = color
	hitmarker.TextTransparency = 0
	hitmarker.TextSize = text == "✕" and 31 or 19
	task.delay(duration or 0.16, function()
		if hitmarkerSequence == sequence then
			TweenService:Create(hitmarker, TweenInfo.new(0.12), {TextTransparency = 1}):Play()
		end
	end)
end

local function getMotorBase(motor)
	local base = motor:GetAttribute("Ohio2BaseC0")
	if typeof(base) ~= "CFrame" then
		base = motor.C0
		motor:SetAttribute("Ohio2BaseC0", base)
	end
	return base
end

local function ejectCasing(tool, itemId)
	local ejectionPort = tool and tool:FindFirstChild("EjectionPort")
	if not ejectionPort or not ejectionPort:IsA("BasePart") then
		return
	end
	local casing = Instance.new("Part")
	casing.Name = "Ohio2SpentCasing"
	casing.Shape = Enum.PartType.Cylinder
	casing.Size = itemId == "Shotgun" and Vector3.new(0.36, 0.12, 0.12) or Vector3.new(0.22, 0.075, 0.075)
	casing.CFrame = ejectionPort.CFrame * CFrame.new(0.26, 0.1, 0) * CFrame.Angles(0, 0, math.rad(90))
	casing.Color = itemId == "Shotgun" and Color3.fromRGB(159, 43, 37) or Color3.fromRGB(190, 151, 66)
	casing.Material = Enum.Material.Metal
	casing.CanCollide = false
	casing.CanQuery = false
	casing.CanTouch = false
	casing.Parent = workspace
	casing.AssemblyLinearVelocity = ejectionPort.CFrame.RightVector * 6.5 + Vector3.new(0, 5.5, 0) + ejectionPort.CFrame.LookVector * math.random(-2, 1)
	casing.AssemblyAngularVelocity = Vector3.new(math.random(-9, 9), math.random(-9, 9), math.random(-9, 9))
	Debris:AddItem(casing, 1.6)
end

local function playWeaponEffect(itemId)
	local tool = currentTool
	if not tool or tool:GetAttribute("Ohio2Item") ~= itemId then
		return
	end
	if itemId == "Pistol" then
		local motor = tool:FindFirstChild("SlideMotor", true)
		if motor and motor:IsA("Motor6D") then
			local base = getMotorBase(motor)
			motor.C0 = base * CFrame.new(0, 0, 0.17)
			TweenService:Create(motor, TweenInfo.new(0.085, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {C0 = base}):Play()
		end
		ejectCasing(tool, itemId)
	elseif itemId == "Shotgun" then
		local motor = tool:FindFirstChild("PumpMotor", true)
		task.delay(0.12, function()
			if not tool.Parent or not motor or not motor:IsA("Motor6D") then
				return
			end
			local base = getMotorBase(motor)
			local back = TweenService:Create(motor, TweenInfo.new(0.11, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {C0 = base * CFrame.new(0, 0, 0.48)})
			back:Play()
			back.Completed:Connect(function()
				ejectCasing(tool, itemId)
				TweenService:Create(motor, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {C0 = base}):Play()
			end)
		end)
	end
end

local function animateReload(itemId, duration)
	local tool = currentTool
	if not tool or tool:GetAttribute("Ohio2Item") ~= itemId then
		return
	end
	if itemId == "Pistol" then
		local motor = tool:FindFirstChild("MagazineMotor", true)
		if motor and motor:IsA("Motor6D") then
			local base = getMotorBase(motor)
			TweenService:Create(motor, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {C0 = base * CFrame.new(0, -0.68, 0.05)}):Play()
			task.delay(math.max(0.45, (duration or 1.45) * 0.62), function()
				if motor.Parent then
					TweenService:Create(motor, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {C0 = base}):Play()
				end
			end)
		end
	elseif itemId == "Shotgun" then
		local motor = tool:FindFirstChild("PumpMotor", true)
		if motor and motor:IsA("Motor6D") then
			local base = getMotorBase(motor)
			TweenService:Create(motor, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {C0 = base * CFrame.new(0, 0, 0.32)}):Play()
			task.delay(math.max(0.5, (duration or 2.1) * 0.68), function()
				if motor.Parent then
					TweenService:Create(motor, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {C0 = base}):Play()
				end
			end)
		end
	end
end

weaponFeedbackRemote.OnClientEvent:Connect(function(feedback, itemId, extra)
	local character = player.Character
	local audioSource = currentTool and currentTool:FindFirstChild("Handle") or (character and character:FindFirstChild("HumanoidRootPart"))
	if feedback == "Shot" then
		playWeaponEffect(itemId)
		local camera = workspace.CurrentCamera
		local recoil = tonumber(extra) or 1
		camera.CFrame = camera.CFrame * CFrame.Angles(math.rad(-recoil), math.rad((math.random() - 0.5) * recoil * 0.35), 0)
	elseif feedback == "Hit" then
		showHitmarker("✕", Color3.fromRGB(245, 245, 245), 0.13)
		local definition = itemDefinitions[itemId]
		if definition and definition.Kind == "Melee" then
			playSpatialSound(itemId == "Bat" and "BatHit" or "PunchHit", audioSource)
		end
	elseif feedback == "Punch" then
		local combo = tonumber(extra) or 1
		showHitmarker(combo == 3 and "HEAVY" or ("COMBO " .. combo), combo == 3 and Color3.fromRGB(255, 205, 91) or Color3.fromRGB(210, 214, 222), 0.18)
	elseif feedback == "MeleeSwing" then
		-- The server sends this before checking the melee overlap. Hit audio only plays after a validated contact.
	elseif feedback == "Headshot" then
		showHitmarker("HEADSHOT", Color3.fromRGB(255, 205, 91), 0.3)
	elseif feedback == "Downed" then
		showHitmarker("DOWNED", Color3.fromRGB(255, 104, 104), 0.38)
	elseif feedback == "Blocked" then
		showHitmarker("BLOCKED", Color3.fromRGB(107, 169, 255), 0.28)
		playSpatialSound("PunchHit", audioSource, 0.48, 0.78)
	elseif feedback == "Protected" then
		showHitmarker("SPAWN SAFE", Color3.fromRGB(107, 169, 255), 0.32)
	elseif feedback == "Empty" then
		ammoLabel.TextColor3 = Color3.fromRGB(255, 104, 104)
		playSpatialSound("DryFire", audioSource)
	elseif feedback == "Reloading" then
		reloading = true
		updateAmmo()
		animateReload(itemId, tonumber(extra) or 2)
		playSpatialSound("ReloadStart", audioSource, itemId == "Shotgun" and 1.15 or 0.9, itemId == "Shotgun" and 0.82 or 1)
		local expectedItem = itemId
		task.delay((tonumber(extra) or 2) + 0.5, function()
			if reloading and currentTool and currentTool:GetAttribute("Ohio2Item") == expectedItem then
				reloading = false
				updateAmmo()
			end
		end)
	elseif feedback == "Reloaded" then
		reloading = false
		updateAmmo()
		playSpatialSound("ReloadComplete", audioSource, itemId == "Shotgun" and 1.2 or 0.85, itemId == "Shotgun" and 0.82 or 1)
	end
end)

local healthConnections = {}
local function bindCharacterVitals(character)
	for _, connection in ipairs(healthConnections) do
		connection:Disconnect()
	end
	table.clear(healthConnections)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if humanoid then
		table.insert(healthConnections, humanoid.HealthChanged:Connect(updateVitals))
		table.insert(healthConnections, humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(updateVitals))
	end
	updateVitals()
end

for _, attribute in ipairs({"Cash", "Bank", "Heat", "Bounty"}) do
	player:GetAttributeChangedSignal(attribute):Connect(updateStats)
	player:GetAttributeChangedSignal(attribute):Connect(updatePhone)
end
for _, attribute in ipairs({"Stamina", "Blocking", "Sprinting", "SpawnProtected", "BalloonEquipped"}) do
	player:GetAttributeChangedSignal(attribute):Connect(updateVitals)
end
for _, attribute in ipairs({"WorldPhase", "Weather", "Blackout", "ArmoredTruckActive", "QuickStopAlarm", "PoliceResponse", "ActiveOfficerCount", "CivilianCount"}) do
	workspace:GetAttributeChangedSignal(attribute):Connect(updateWorldState)
end
workspace:GetAttributeChangedSignal("Weather"):Connect(updateWeatherFX)
for _, attribute in ipairs({"WorldPhase", "Weather", "PoliceResponse", "ActiveOfficerCount"}) do
	workspace:GetAttributeChangedSignal(attribute):Connect(updatePhone)
end
for _, attribute in ipairs({"DailyContractTitle", "DailyContractDescription", "DailyContractProgress", "DailyContractGoal", "DailyContractReward", "DailyContractClaimed"}) do
	player:GetAttributeChangedSignal(attribute):Connect(updatePhone)
end
for _, attribute in ipairs({"OwnsRustCompact", "VehicleFuel", "VehicleCondition", "VehicleActive"}) do
	player:GetAttributeChangedSignal(attribute):Connect(updatePhone)
	player:GetAttributeChangedSignal(attribute):Connect(updateVehicleHud)
end
player:GetAttributeChangedSignal("Blocking"):Connect(function()
	if not player:GetAttribute("Blocking") then
		blockToggle = false
	end
end)
for itemId, item in pairs(itemDefinitions) do
	if item.Kind == "Gun" then
		player:GetAttributeChangedSignal("Magazine_" .. itemId):Connect(updateAmmo)
	end
end
player:GetAttributeChangedSignal("Downed"):Connect(function()
	local isDowned = player:GetAttribute("Downed") == true
	downedOverlay.Visible = isDowned
	if isDowned then
		currentTool = nil
		reloading = false
		sprintToggle = false
		blockToggle = false
		updateAmmo()
	end
	updateVitals()
end)
player:GetAttributeChangedSignal("Objective"):Connect(function()
	objectiveLabel.Text = player:GetAttribute("Objective") or objectiveLabel.Text
	updatePhone()
end)

local boundTools = setmetatable({}, {__mode = "k"})
local function bindTool(tool)
	if not tool:IsA("Tool") or not tool:GetAttribute("Ohio2Item") or boundTools[tool] then
		return
	end
	boundTools[tool] = true
	tool.Equipped:Connect(function()
		currentTool = tool
		updateAmmo()
	end)
	tool.Unequipped:Connect(function()
		if currentTool == tool then
			currentTool = nil
		end
		updateAmmo()
	end)
	tool.Activated:Connect(function()
		local cameraOrigin, aimDirection = getCenterAimRay()
		if cameraOrigin and aimDirection then
			weaponActionRemote:FireServer("Activate", cameraOrigin, aimDirection)
		end
	end)
end

reloadButton.Activated:Connect(requestReload)
sprintButton.Activated:Connect(function()
	sprintToggle = not sprintToggle
	stateActionRemote:FireServer(sprintToggle and "SprintStart" or "SprintEnd")
end)
blockButton.Activated:Connect(function()
	blockToggle = not blockToggle
	stateActionRemote:FireServer(blockToggle and "BlockStart" or "BlockEnd")
end)
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.KeyCode == Enum.KeyCode.R then
		requestReload()
	elseif input.KeyCode == Enum.KeyCode.P then
		setPhoneOpen(not phonePanel.Visible)
		updatePhone()
	elseif input.KeyCode == Enum.KeyCode.H then
		stateActionRemote:FireServer("VehicleHorn")
	elseif input.KeyCode == Enum.KeyCode.LeftShift then
		stateActionRemote:FireServer("SprintStart")
	elseif input.KeyCode == Enum.KeyCode.F then
		stateActionRemote:FireServer("BlockStart")
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		stateActionRemote:FireServer("SprintEnd")
	elseif input.KeyCode == Enum.KeyCode.F then
		stateActionRemote:FireServer("BlockEnd")
	end
end)

local function watchToolContainer(container)
	for _, child in ipairs(container:GetChildren()) do
		bindTool(child)
	end
	container.ChildAdded:Connect(bindTool)
end

watchToolContainer(player:WaitForChild("Backpack"))
player.CharacterAdded:Connect(function(character)
	currentTool = nil
	reloading = false
	sprintToggle = false
	blockToggle = false
	crosshair.Visible = false
	updateAmmo()
	watchToolContainer(character)
	task.spawn(bindCharacterVitals, character)
end)
if player.Character then
	watchToolContainer(player.Character)
	task.spawn(bindCharacterVitals, player.Character)
end

local function watchPlayerAudio(otherPlayer)
	if otherPlayer.Character then
		bindCharacterAudio(otherPlayer.Character)
	end
	otherPlayer.CharacterAdded:Connect(bindCharacterAudio)
end
for _, otherPlayer in ipairs(Players:GetPlayers()) do
	watchPlayerAudio(otherPlayer)
end
Players.PlayerAdded:Connect(watchPlayerAudio)

local inventory = player:WaitForChild("Inventory")
local stash = player:WaitForChild("Stash")
watchContainer(inventory)
watchContainer(stash)
updateStats()
updateWorldState()
updateWeatherFX()
updatePhone()
updateVehicleHud()
updateAmmo()
updateVitals()
downedOverlay.Visible = player:GetAttribute("Downed") == true
objectiveLabel.Text = player:GetAttribute("Objective") or objectiveLabel.Text

task.delay(2, function()
showNotification("Build 1.3 ready: centered gun aiming, replicated reports, slower events, and an authored district art pass.", Color3.fromRGB(107, 169, 255))
end)

print("[Ohio2] Build 1.3 world and gunplay client loaded")
