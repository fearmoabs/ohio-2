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
-- Shared item data. Both the server and HUD read this module.
return {
	Fists = {
		DisplayName = "Fists",
		Price = 0,
		Color = Color3.fromRGB(224, 184, 144),
		Kind = "Melee",
		Damage = 10,
		ComboDamage = {10, 12, 18},
		Cooldown = 0.38,
		ComboReset = 1.1,
		Range = 4.2,
		HeavyKnockback = 28,
		Permanent = true,
	},
	Bat = {
		DisplayName = "Baseball Bat",
		Price = 150,
		Color = Color3.fromRGB(121, 85, 58),
		Kind = "Melee",
		Damage = 35,
		Cooldown = 0.7,
		Range = 5.5,
	},
	Pistol = {
		DisplayName = "9mm Pistol",
		Price = 500,
		Color = Color3.fromRGB(45, 48, 55),
		Kind = "Gun",
		Damage = 26,
		Cooldown = 0.28,
		Range = 250,
		MagazineSize = 12,
		AmmoItem = "PistolAmmo",
		StarterAmmo = 36,
		ReloadTime = 1.45,
		HeadshotMultiplier = 1.65,
		Recoil = 1.25,
		Pellets = 1,
		Spread = 0,
	},
	PistolAmmo = {
		DisplayName = "9mm Ammunition",
		Price = 60,
		Color = Color3.fromRGB(190, 159, 75),
		Kind = "Ammo",
		Bundle = 24,
	},
	Shotgun = {
		DisplayName = "Pump Shotgun",
		Price = 950,
		Color = Color3.fromRGB(74, 59, 48),
		Kind = "Gun",
		Damage = 10,
		Cooldown = 0.9,
		Range = 130,
		MagazineSize = 6,
		AmmoItem = "Shells",
		StarterAmmo = 18,
		ReloadTime = 2.1,
		HeadshotMultiplier = 1.35,
		Recoil = 3.4,
		Pellets = 8,
		Spread = 0.065,
	},
	Shells = {
		DisplayName = "12-Gauge Shells",
		Price = 90,
		Color = Color3.fromRGB(174, 48, 44),
		Kind = "Ammo",
		Bundle = 12,
	},
	Medkit = {
		DisplayName = "Medkit",
		Price = 100,
		Color = Color3.fromRGB(205, 48, 48),
		Kind = "Consumable",
		Heal = 45,
		Cooldown = 1.0,
	},
	Balloon = {
		DisplayName = "Lift Balloon",
		Price = 200,
		Color = Color3.fromRGB(235, 72, 92),
		Kind = "Utility",
		JumpPower = 82,
		JumpHeight = 13,
	},
}
]==]
itemDefinitions.Parent = shared

local soundDefinitions = Instance.new("ModuleScript")
soundDefinitions.Name = "SoundDefinitions"
soundDefinitions.Source = [==[
-- Shared, editable audio catalog for Ohio 2 build 1.3.
-- Replace any SoundId with audio uploaded or explicitly licensed for your experience.

return {
	MasterVolume = 0.82,
	Catalog = {
		PistolShot = {
			SoundId = "rbxassetid://9114727327",
			Volume = 0.82,
			PlaybackSpeed = 1.06,
			SpeedVariance = 0.035,
			MinDistance = 8,
			MaxDistance = 260,
		},
		ShotgunShot = {
			SoundId = "rbxassetid://5656322299",
			Volume = 0.95,
			PlaybackSpeed = 0.96,
			SpeedVariance = 0.025,
			MinDistance = 10,
			MaxDistance = 330,
		},
		BulletImpact = {
			SoundId = "rbxassetid://9113632396",
			Volume = 0.42,
			PlaybackSpeed = 1.05,
			SpeedVariance = 0.12,
			MinDistance = 4,
			MaxDistance = 85,
		},
		PunchHit = {
			SoundId = "rbxassetid://9117969717",
			Volume = 0.58,
			PlaybackSpeed = 1.08,
			SpeedVariance = 0.09,
			MinDistance = 4,
			MaxDistance = 55,
		},
		BatHit = {
			SoundId = "rbxassetid://4529474217",
			Volume = 0.68,
			PlaybackSpeed = 1,
			SpeedVariance = 0.055,
			MinDistance = 5,
			MaxDistance = 75,
		},
		DryFire = {
			SoundId = "rbxasset://sounds/electronicpingshort.wav",
			Volume = 0.28,
			PlaybackSpeed = 1.8,
			SpeedVariance = 0.035,
			MinDistance = 3,
			MaxDistance = 32,
		},
		ReloadStart = {
			SoundId = "rbxasset://sounds/action_get_up.mp3",
			Volume = 0.26,
			PlaybackSpeed = 1.75,
			SpeedVariance = 0.025,
			MinDistance = 3,
			MaxDistance = 38,
		},
		ReloadComplete = {
			SoundId = "rbxasset://sounds/action_jump_land.mp3",
			Volume = 0.2,
			PlaybackSpeed = 2.1,
			SpeedVariance = 0.025,
			MinDistance = 3,
			MaxDistance = 34,
		},
		Footstep = {
			SoundId = "rbxasset://sounds/action_footsteps_plastic.mp3",
			Volume = 0.34,
			PlaybackSpeed = 1.35,
			SpeedVariance = 0,
			MinDistance = 4,
			MaxDistance = 48,
		},
		VehicleEngine = {
			SoundId = "rbxassetid://338224404",
			Volume = 0.38,
			PlaybackSpeed = 0.72,
			SpeedVariance = 0,
			MinDistance = 8,
			MaxDistance = 125,
		},
		VehicleCrash = {
			SoundId = "rbxassetid://9120389019",
			Volume = 0.78,
			PlaybackSpeed = 1,
			SpeedVariance = 0.08,
			MinDistance = 6,
			MaxDistance = 145,
		},
		VehicleHorn = {
			SoundId = "rbxassetid://9113072516",
			Volume = 0.56,
			PlaybackSpeed = 1.12,
			SpeedVariance = 0,
			MinDistance = 8,
			MaxDistance = 170,
		},
	},
	SurfaceFootsteps = {
		Asphalt = {Pitch = 0.94, Volume = 0.94},
		Concrete = {Pitch = 1, Volume = 1},
		Brick = {Pitch = 1.02, Volume = 1},
		Cobblestone = {Pitch = 0.9, Volume = 1.05},
		Metal = {Pitch = 1.16, Volume = 0.78},
		DiamondPlate = {Pitch = 1.13, Volume = 0.82},
		Wood = {Pitch = 0.84, Volume = 0.9},
		WoodPlanks = {Pitch = 0.86, Volume = 0.9},
		Grass = {Pitch = 0.72, Volume = 0.7},
		Ground = {Pitch = 0.76, Volume = 0.73},
		Sand = {Pitch = 0.68, Volume = 0.67},
		Fabric = {Pitch = 0.74, Volume = 0.58},
		Default = {Pitch = 1, Volume = 0.86},
	},
}
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
-- Ohio 2 prototype: server-authoritative gameplay foundation.
-- Replace the placeholder map and balance values as the project grows.

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local PathfindingService = game:GetService("PathfindingService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

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

local toolTemplates = ServerStorage:WaitForChild("Ohio2Tools")
local policeTemplate = ServerStorage:WaitForChild("Ohio2Police")
local civilianTemplates = ServerStorage:WaitForChild("Ohio2CivilianTemplates")
local vehicleTemplates = ServerStorage:WaitForChild("Ohio2VehicleTemplates")
local adminBridge = ServerStorage:WaitForChild("Ohio2AdminBridge")
local map = workspace:WaitForChild("Ohio2Map")
local dropsFolder = workspace:WaitForChild("Ohio2Drops")
local npcFolder = workspace:WaitForChild("Ohio2NPCs")
local vehiclesFolder = workspace:WaitForChild("Ohio2Vehicles")
local playerStore = DataStoreService:GetDataStore("Ohio2Prototype_PlayerData_v1")

local DEFAULT_CASH = 1000
local WORLD_ROBBERY_COOLDOWN = 600
local MAX_HEAT = 5
local MAX_STAMINA = 100
local WALK_SPEED = 16
local SPRINT_SPEED = 23
local BLOCK_SPEED = 9
local ROBBERY_BOUNTY = 500
local PLAYER_DOWN_BOUNTY = 200
local BOUNTY_CREDIT_WINDOW = 30
local TOW_BASE_REWARD = 650
local TOW_TARGETS = {
	{Id = "Motel", Location = "Riverside Motel parking lot"},
	{Id = "Apartments", Location = "West End Apartments parking lot"},
	{Id = "Clinic", Location = "County Clinic parking lot"},
}
local POLICE_BASE_OFFICERS = 2
local POLICE_MAX_OFFICERS = 6
local POLICE_RANGED_MIN_HEAT = 3
local STORE_SAFE_COOLDOWN = 1200
local WEATHER_STATES = {"CLEAR", "OVERCAST", "RAIN"}
local SUPPLY_FIRST_DELAY = {480, 720}
local SUPPLY_REPEAT_DELAY = {900, 1500}
local ARMORED_FIRST_DELAY = {720, 1080}
local ARMORED_REPEAT_DELAY = {1500, 2400}
local WEATHER_FIRST_DELAY = {300, 480}
local WEATHER_REPEAT_DELAY = {600, 900}
local BLACKOUT_FIRST_DELAY = {900, 1500}
local BLACKOUT_REPEAT_DELAY = {1800, 3000}
local VEHICLE_PRICE = 3500
local VEHICLE_MAX_FUEL = 100
local VEHICLE_MAX_CONDITION = 100
local REFUEL_PRICE_PER_UNIT = 3
local REPAIR_PRICE_PER_POINT = 8
local DAILY_CONTRACTS = {
	{
		Id = "TowShift",
		Title = "Tow Shift",
		Description = "Complete one Rust Belt Auto tow call.",
		Goal = 1,
		Reward = 900,
	},
	{
		Id = "HonestWork",
		Title = "Honest Work",
		Description = "Complete two legal delivery or route jobs.",
		Goal = 2,
		Reward = 1100,
	},
	{
		Id = "StreetScavenger",
		Title = "Street Scavenger",
		Description = "Search five fresh dumpsters, crates, lockers, or safes.",
		Goal = 5,
		Reward = 850,
	},
	{
		Id = "EscapeArtist",
		Title = "Escape Artist",
		Description = "Lose a wanted level after escaping police contact.",
		Goal = 1,
		Reward = 1250,
	},
}

local activeJobs = {}
local worldCooldowns = {}
local weaponCooldowns = {}
local reloadStates = {}
local comboStates = {}
local sprintStates = {}
local blockStates = {}
local downedStates = {}
local arrestStates = {}
local lootBags = {}
local supplyDrops = {}
local armoredTruckEvent
local blackoutState = {Active = false}
local dataWarnings = {}
local npcCrimeCooldowns = {}
local storeRobberies = {}
local storeAlarmToken = 0
local officerSlots = {}
local officerRespawnAt = {}
local currentWeather = "CLEAR"
local dailyContracts = {}
local activeVehicles = {}
local vehicleHornCooldowns = {}
local respawnAllCivilians
local spawnOfficer
local setWeather

local function notify(player, text, color)
	if player and player.Parent then
		notificationRemote:FireClient(player, text, color or Color3.fromRGB(255, 255, 255))
	end
end

local function formatWait(seconds)
	seconds = math.max(0, math.ceil(seconds or 0))
	if seconds >= 120 then
		local minutes = math.ceil(seconds / 60)
		return minutes .. (minutes == 1 and " minute" or " minutes")
	end
	return seconds .. (seconds == 1 and " second" or " seconds")
end

local function playConfiguredWorldSound(soundName, parent, volumeScale, speedScale)
	local definition = soundDefinitions.Catalog[soundName]
	if not definition or not parent or type(definition.SoundId) ~= "string" or definition.SoundId == "" then
		return
	end
	local sound = Instance.new("Sound")
	sound.Name = "Ohio2_" .. soundName
	sound.SoundId = definition.SoundId
	sound.Volume = (definition.Volume or 0.5) * (soundDefinitions.MasterVolume or 1) * (volumeScale or 1)
	local speedVariance = definition.SpeedVariance or 0
	local randomizedSpeed = 1 + (math.random() * 2 - 1) * speedVariance
	sound.PlaybackSpeed = math.max(0.05, (definition.PlaybackSpeed or 1) * (speedScale or 1) * randomizedSpeed)
	sound.RollOffMode = Enum.RollOffMode.InverseTapered
	sound.RollOffMinDistance = definition.MinDistance or 5
	sound.RollOffMaxDistance = definition.MaxDistance or 90
	sound.Parent = parent
	sound:Play()
	Debris:AddItem(sound, 8)
	return sound
end

local function setObjective(player, text)
	player:SetAttribute("Objective", text)
	objectiveRemote:FireClient(player, text)
end

local function getContainer(player, name)
	return player:FindFirstChild(name)
end

local function getItemCount(player, containerName, itemId)
	local container = getContainer(player, containerName)
	local value = container and container:FindFirstChild(itemId)
	return value and value.Value or 0
end

local function setItemCount(player, containerName, itemId, amount)
	local container = getContainer(player, containerName)
	if not container or not itemDefinitions[itemId] then
		return
	end

	local value = container:FindFirstChild(itemId)
	amount = math.max(0, math.floor(tonumber(amount) or 0))
	if amount <= 0 then
		if value then
			value:Destroy()
		end
		return
	end

	if not value then
		value = Instance.new("IntValue")
		value.Name = itemId
		value.Parent = container
	end
	value.Value = amount
end

local function addItem(player, containerName, itemId, amount)
	setItemCount(player, containerName, itemId, getItemCount(player, containerName, itemId) + amount)
end

local function magazineAttribute(itemId)
	return "Magazine_" .. itemId
end

local function getMagazine(player, itemId)
	return math.max(0, math.floor(player:GetAttribute(magazineAttribute(itemId)) or 0))
end

local function setMagazine(player, itemId, amount)
	local item = itemDefinitions[itemId]
	if not item or item.Kind ~= "Gun" then
		return
	end
	player:SetAttribute(magazineAttribute(itemId), math.clamp(math.floor(amount or 0), 0, item.MagazineSize))
end

local function unloadMagazines(player)
	for itemId, item in pairs(itemDefinitions) do
		if item.Kind == "Gun" then
			local loaded = getMagazine(player, itemId)
			if loaded > 0 and getItemCount(player, "Inventory", itemId) > 0 then
				addItem(player, "Inventory", item.AmmoItem, loaded)
			end
			setMagazine(player, itemId, 0)
		end
	end
end

local function clearPrototypeTools(player)
	local locations = {player:FindFirstChildOfClass("Backpack"), player.Character}
	for _, location in ipairs(locations) do
		if location then
			for _, child in ipairs(location:GetChildren()) do
				if child:IsA("Tool") and child:GetAttribute("Ohio2Item") then
					child:Destroy()
				end
			end
		end
	end
end

local function rebuildTools(player)
	if not player:GetAttribute("DataLoaded") then
		return
	end

	local backpack = player:FindFirstChildOfClass("Backpack")
	local inventory = getContainer(player, "Inventory")
	if not backpack or not inventory then
		return
	end

	clearPrototypeTools(player)
	local fists = toolTemplates:FindFirstChild("Fists")
	if fists then
		fists:Clone().Parent = backpack
	end
	for _, value in ipairs(inventory:GetChildren()) do
		local template = toolTemplates:FindFirstChild(value.Name)
		if value:IsA("IntValue") and template then
			local copies = value.Name == "Medkit" and value.Value or math.min(1, value.Value)
			for _ = 1, copies do
				template:Clone().Parent = backpack
			end
		end
	end
end

local function changeCash(player, amount)
	local current = player:GetAttribute("Cash") or 0
	player:SetAttribute("Cash", math.max(0, math.floor(current + amount)))
end

local function changeBank(player, amount)
	local current = player:GetAttribute("Bank") or 0
	player:SetAttribute("Bank", math.max(0, math.floor(current + amount)))
end

local function changeHeat(player, amount)
	local current = player:GetAttribute("Heat") or 0
	player:SetAttribute("Heat", math.clamp(math.floor(current + amount), 0, MAX_HEAT))
end

local function changeBounty(player, amount)
	local current = player:GetAttribute("Bounty") or 0
	player:SetAttribute("Bounty", math.max(0, math.floor(current + amount)))
end

local function dailyDayKey()
	local date = os.date("!*t")
	return date.year * 1000 + date.yday
end

local function getDailyDefinition(contractId)
	for _, definition in ipairs(DAILY_CONTRACTS) do
		if definition.Id == contractId then
			return definition
		end
	end
	return nil
end

local function syncDailyContract(player, state)
	local definition = state and getDailyDefinition(state.ContractId)
	if not definition then
		return
	end
	player:SetAttribute("DailyContractDay", state.DayKey)
	player:SetAttribute("DailyContractId", definition.Id)
	player:SetAttribute("DailyContractTitle", definition.Title)
	player:SetAttribute("DailyContractDescription", definition.Description)
	player:SetAttribute("DailyContractProgress", state.Progress)
	player:SetAttribute("DailyContractGoal", definition.Goal)
	player:SetAttribute("DailyContractReward", definition.Reward)
	player:SetAttribute("DailyContractClaimed", state.Claimed == true)
end

local function assignDailyContract(player, savedState)
	local dayKey = dailyDayKey()
	local definition = DAILY_CONTRACTS[(player.UserId + dayKey) % #DAILY_CONTRACTS + 1]
	local state = {
		DayKey = dayKey,
		ContractId = definition.Id,
		Progress = 0,
		Claimed = false,
	}
	if type(savedState) == "table" and tonumber(savedState.DayKey) == dayKey and savedState.ContractId == definition.Id then
		state.Progress = math.clamp(math.floor(tonumber(savedState.Progress) or 0), 0, definition.Goal)
		state.Claimed = savedState.Claimed == true and state.Progress >= definition.Goal
	end
	dailyContracts[player] = state
	syncDailyContract(player, state)
	return state
end

local function progressDailyContract(player, contractId, amount)
	local state = dailyContracts[player]
	if not state or state.DayKey ~= dailyDayKey() then
		state = assignDailyContract(player)
	end
	if state.ContractId ~= contractId or state.Claimed then
		return
	end
	local definition = getDailyDefinition(state.ContractId)
	local before = state.Progress
	state.Progress = math.clamp(state.Progress + (amount or 1), 0, definition.Goal)
	syncDailyContract(player, state)
	if before < definition.Goal and state.Progress >= definition.Goal then
		notify(player, "PHONE: Daily contract complete. Open the phone to claim $" .. definition.Reward .. " into your bank.", Color3.fromRGB(110, 232, 154))
	end
end

local function updateVehicleAttributes(player, vehicle)
	if vehicle and vehicle.Parent then
		player:SetAttribute("VehicleFuel", math.clamp(tonumber(vehicle:GetAttribute("Fuel")) or 0, 0, VEHICLE_MAX_FUEL))
		player:SetAttribute("VehicleCondition", math.clamp(tonumber(vehicle:GetAttribute("Condition")) or 0, 0, VEHICLE_MAX_CONDITION))
		player:SetAttribute("VehicleActive", true)
	else
		player:SetAttribute("VehicleActive", false)
	end
end

local function storeActiveVehicle(player, destroyVehicle)
	local vehicle = activeVehicles[player]
	if vehicle and vehicle.Parent then
		updateVehicleAttributes(player, vehicle)
		if destroyVehicle then
			vehicle:Destroy()
		end
	end
	activeVehicles[player] = nil
	player:SetAttribute("VehicleActive", false)
end

local function spawnPersonalVehicle(player)
	if player:GetAttribute("OwnsRustCompact") ~= true then
		return nil, "Purchase the Rust Compact first."
	end
	storeActiveVehicle(player, true)
	local template = vehicleTemplates:FindFirstChild("RustCompact")
	local spawnPart = map:FindFirstChild("PersonalVehicleSpawn")
	if not template or not spawnPart then
		return nil, "The garage is temporarily unavailable."
	end
	local vehicle = template:Clone()
	vehicle.Name = player.Name .. "_RustCompact"
	vehicle:SetAttribute("OwnerUserId", player.UserId)
	vehicle:SetAttribute("Fuel", math.clamp(player:GetAttribute("VehicleFuel") or VEHICLE_MAX_FUEL, 0, VEHICLE_MAX_FUEL))
	vehicle:SetAttribute("MaxFuel", VEHICLE_MAX_FUEL)
	vehicle:SetAttribute("Condition", math.clamp(player:GetAttribute("VehicleCondition") or VEHICLE_MAX_CONDITION, 0, VEHICLE_MAX_CONDITION))
	vehicle:SetAttribute("MaxCondition", VEHICLE_MAX_CONDITION)
	vehicle:SetAttribute("VehicleDisabled", (vehicle:GetAttribute("Fuel") or 0) <= 0 or (vehicle:GetAttribute("Condition") or 0) <= 0)
	vehicle.Parent = vehiclesFolder
	vehicle:PivotTo(spawnPart.CFrame + Vector3.new(0, 2.2, 0))
	for _, descendant in ipairs(vehicle:GetDescendants()) do
		if descendant:IsA("TextLabel") and string.find(descendant.Text, "COUNTY TEST VEHICLE", 1, true) then
			descendant.Text = string.upper(player.DisplayName) .. "'S RUST COMPACT"
		end
	end
	activeVehicles[player] = vehicle
	updateVehicleAttributes(player, vehicle)
	task.spawn(function()
		while player.Parent and vehicle.Parent and activeVehicles[player] == vehicle do
			updateVehicleAttributes(player, vehicle)
			task.wait(1)
		end
		if activeVehicles[player] == vehicle then
			activeVehicles[player] = nil
			player:SetAttribute("VehicleActive", false)
		end
	end)
	return vehicle
end

local function serializeContainer(container)
	local result = {}
	if container then
		for _, value in ipairs(container:GetChildren()) do
			if value:IsA("IntValue") and itemDefinitions[value.Name] and value.Value > 0 then
				result[value.Name] = value.Value
			end
		end
	end
	return result
end

local function capturePlayerData(player)
	local magazines = {}
	for itemId, item in pairs(itemDefinitions) do
		if item.Kind == "Gun" then
			magazines[itemId] = getMagazine(player, itemId)
		end
	end
	local activeVehicle = activeVehicles[player]
	if activeVehicle and activeVehicle.Parent then
		updateVehicleAttributes(player, activeVehicle)
	end
	local dailyState = dailyContracts[player]
	return {
		Cash = player:GetAttribute("Cash") or DEFAULT_CASH,
		Bank = player:GetAttribute("Bank") or 0,
		Bounty = player:GetAttribute("Bounty") or 0,
		Inventory = serializeContainer(getContainer(player, "Inventory")),
		Stash = serializeContainer(getContainer(player, "Stash")),
		Magazines = magazines,
		DailyContract = dailyState and {
			DayKey = dailyState.DayKey,
			ContractId = dailyState.ContractId,
			Progress = dailyState.Progress,
			Claimed = dailyState.Claimed,
		} or nil,
		Vehicle = {
			Owned = player:GetAttribute("OwnsRustCompact") == true,
			Fuel = math.clamp(player:GetAttribute("VehicleFuel") or VEHICLE_MAX_FUEL, 0, VEHICLE_MAX_FUEL),
			Condition = math.clamp(player:GetAttribute("VehicleCondition") or VEHICLE_MAX_CONDITION, 0, VEHICLE_MAX_CONDITION),
		},
	}
end

local function savePlayer(player)
	if not player:GetAttribute("DataLoaded") or not player:GetAttribute("DataCanSave") then
		return false
	end

	local payload = capturePlayerData(player)
	local success, message = pcall(function()
		playerStore:UpdateAsync("Player_" .. player.UserId, function()
			return payload
		end)
	end)

	if not success and not dataWarnings[player] then
		dataWarnings[player] = true
		warn("Ohio2 data could not save for " .. player.Name .. ": " .. tostring(message))
		notify(player, "Saving is unavailable in this Studio test. Publish and enable API Services.", Color3.fromRGB(255, 196, 82))
	end
	return success
end

local function applySavedItems(player, containerName, saved)
	if type(saved) ~= "table" then
		return
	end
	for itemId, amount in pairs(saved) do
		if itemDefinitions[itemId] and type(amount) == "number" then
			local maximum = itemDefinitions[itemId].Kind == "Ammo" and 999 or 25
			setItemCount(player, containerName, itemId, math.clamp(math.floor(amount), 0, maximum))
		end
	end
end

local function applySavedMagazines(player, saved)
	for itemId, item in pairs(itemDefinitions) do
		if item.Kind == "Gun" then
			local amount = type(saved) == "table" and tonumber(saved[itemId]) or nil
			if amount == nil and getItemCount(player, "Inventory", itemId) > 0 then
				amount = item.MagazineSize
			end
			setMagazine(player, itemId, amount or 0)
		end
	end
end

local function makeLootBag(position, cash, items)
	if cash <= 0 and next(items) == nil then
		return
	end

	local bag = Instance.new("Part")
	bag.Name = "DroppedLoot"
	bag.Size = Vector3.new(2.4, 1.4, 2)
	bag.CFrame = CFrame.new(position + Vector3.new(0, 1.2, 0))
	bag.Color = Color3.fromRGB(72, 58, 43)
	bag.Material = Enum.Material.Fabric
	bag.Anchored = true
	bag.CanCollide = true
	bag.Parent = dropsFolder

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Take Loot"
	prompt.ObjectText = cash > 0 and ("Bag + $" .. cash) or "Dropped Bag"
	prompt.HoldDuration = 0.6
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt:SetAttribute("ActionType", "LootBag")
	prompt.Parent = bag

	lootBags[bag] = {Cash = cash, Items = items, Taken = false}
	task.delay(120, function()
		lootBags[bag] = nil
		if bag.Parent then
			bag:Destroy()
		end
	end)
end

local function clearDowned(player, restoredHealth)
	local state = downedStates[player]
	if state then
		state.Cancelled = true
		if state.Prompt and state.Prompt.Parent then
			state.Prompt:Destroy()
		end
	end
	downedStates[player] = nil
	player:SetAttribute("Downed", false)
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > 0 then
		humanoid.WalkSpeed = state and state.WalkSpeed or 16
		humanoid.JumpPower = state and state.JumpPower or 50
		humanoid.JumpHeight = state and state.JumpHeight or 7.2
		humanoid.AutoRotate = true
		if restoredHealth then
			humanoid.Health = math.min(humanoid.MaxHealth, restoredHealth)
		end
	end
end

local function removeSpawnProtection(player)
	player:SetAttribute("SpawnProtected", false)
	local character = player.Character
	local forceField = character and character:FindFirstChild("Ohio2SpawnProtection")
	if forceField then
		forceField:Destroy()
	end
end

local function resetActionStates(player)
	sprintStates[player] = nil
	blockStates[player] = nil
	player:SetAttribute("Sprinting", false)
	player:SetAttribute("Blocking", false)
end

local function downPlayer(player)
	if downedStates[player] or arrestStates[player] then
		return false
	end
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root or humanoid.Health <= 0 then
		return false
	end

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Revive Player"
	prompt.ObjectText = player.DisplayName .. " • Downed"
	prompt.HoldDuration = 3
	prompt.MaxActivationDistance = 9
	prompt.RequiresLineOfSight = false
	prompt:SetAttribute("ActionType", "RevivePlayer")
	prompt:SetAttribute("TargetUserId", player.UserId)
	prompt.Parent = root

	downedStates[player] = {
		Prompt = prompt,
		WalkSpeed = humanoid.WalkSpeed,
		JumpPower = humanoid.JumpPower,
		JumpHeight = humanoid.JumpHeight,
		Cancelled = false,
	}
	player:SetAttribute("Downed", true)
	resetActionStates(player)
	humanoid.Health = math.max(10, humanoid.Health)
	humanoid.WalkSpeed = 4
	humanoid.JumpPower = 0
	humanoid.JumpHeight = 0
	humanoid.AutoRotate = false
	humanoid:UnequipTools()
	activeJobs[player] = nil
	setObjective(player, "DOWNED: Another player has 18 seconds to revive you.")
	notify(player, "You are downed! A player can hold the revive prompt to save you.", Color3.fromRGB(255, 104, 104))

	local state = downedStates[player]
	task.delay(18, function()
		if downedStates[player] == state and not state.Cancelled then
			state.Cancelled = true
			if humanoid.Parent and humanoid.Health > 0 then
				humanoid.Health = 0
			end
		end
	end)
	return true
end

local function applyCombatDamage(attacker, targetHumanoid, amount, damageType)
	if not targetHumanoid or targetHumanoid.Health <= 0 then
		return "Miss"
	end
	local targetModel = targetHumanoid.Parent
	local victim = Players:GetPlayerFromCharacter(targetModel)
	if victim and victim:GetAttribute("SpawnProtected") then
		return "Protected"
	end
	if victim and attacker and attacker ~= victim then
		victim:SetAttribute("LastAttackerUserId", attacker.UserId)
		victim:SetAttribute("LastAttackAt", os.clock())
	end

	local blocked = false
	if victim and damageType == "Melee" and victim:GetAttribute("Blocking") and attacker and attacker.Character then
		local victimRoot = targetModel:FindFirstChild("HumanoidRootPart")
		local attackerRoot = attacker.Character:FindFirstChild("HumanoidRootPart")
		if victimRoot and attackerRoot then
			local offset = attackerRoot.Position - victimRoot.Position
			if offset.Magnitude > 0 and victimRoot.CFrame.LookVector:Dot(offset.Unit) > 0.05 then
				amount = math.max(1, math.floor(amount * 0.35))
				blocked = true
			end
		end
	end
	if victim and not downedStates[victim] and targetHumanoid.Health - amount <= 0 then
		targetHumanoid.Health = 10
		if downPlayer(victim) then
			if attacker and attacker ~= victim then
				changeBounty(attacker, PLAYER_DOWN_BOUNTY)
				notify(attacker, "+$" .. PLAYER_DOWN_BOUNTY .. " bounty for downing " .. victim.DisplayName .. ".", Color3.fromRGB(255, 152, 84))
			end
			return "Downed"
		end
	end
	targetHumanoid:TakeDamage(amount)
	return blocked and "Blocked" or "Hit"
end

local function handleDeath(player, character)
	if character:GetAttribute("Ohio2DeathHandled") then
		return
	end
	character:SetAttribute("Ohio2DeathHandled", true)

	local bounty = player:GetAttribute("Bounty") or 0
	local attackerUserId = player:GetAttribute("LastAttackerUserId")
	local lastAttackAt = player:GetAttribute("LastAttackAt") or 0
	local hunter = type(attackerUserId) == "number" and Players:GetPlayerByUserId(attackerUserId) or nil
	if bounty > 0 and hunter and hunter ~= player and os.clock() - lastAttackAt <= BOUNTY_CREDIT_WINDOW then
		changeCash(hunter, bounty)
		notify(hunter, "+$" .. bounty .. " BOUNTY CLAIMED on " .. player.DisplayName .. "!", Color3.fromRGB(255, 205, 91))
		notify(player, hunter.DisplayName .. " claimed your $" .. bounty .. " bounty.", Color3.fromRGB(255, 104, 104))
	end
	player:SetAttribute("Bounty", 0)
	player:SetAttribute("LastAttackerUserId", 0)
	player:SetAttribute("LastAttackAt", 0)

	unloadMagazines(player)
	local inventory = getContainer(player, "Inventory")
	local droppedItems = serializeContainer(inventory)
	local cash = player:GetAttribute("Cash") or 0
	local droppedCash = math.floor(cash * 0.25)
	local root = character:FindFirstChild("HumanoidRootPart")
	local dropPosition = root and root.Position or map.SpawnLocation.Position

	for itemId in pairs(droppedItems) do
		setItemCount(player, "Inventory", itemId, 0)
	end
	changeCash(player, -droppedCash)
	player:SetAttribute("Heat", 0)
	player:SetAttribute("Downed", false)
	player:SetAttribute("SpawnProtected", false)
	resetActionStates(player)
	downedStates[player] = nil
	arrestStates[player] = nil
	reloadStates[player] = nil
	comboStates[player] = nil
	activeJobs[player] = nil
	setObjective(player, "Find work, buy equipment, or risk a robbery.")
	clearPrototypeTools(player)
	makeLootBag(dropPosition, droppedCash, droppedItems)
	if droppedCash > 0 or next(droppedItems) then
		notify(player, "You died and dropped your carried loot. Your stash and bank are safe.", Color3.fromRGB(255, 104, 104))
	end
end

local function setupCharacter(player, character)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if humanoid then
		player:SetAttribute("Downed", false)
		player:SetAttribute("Stamina", MAX_STAMINA)
		player:SetAttribute("SpawnProtected", true)
		player:SetAttribute("BalloonEquipped", false)
		player:SetAttribute("LastAttackerUserId", 0)
		player:SetAttribute("LastAttackAt", 0)
		resetActionStates(player)
		downedStates[player] = nil
		arrestStates[player] = nil
		humanoid.WalkSpeed = WALK_SPEED
		humanoid.UseJumpPower = true
		humanoid.JumpPower = 50
		local forceField = Instance.new("ForceField")
		forceField.Name = "Ohio2SpawnProtection"
		forceField.Visible = false
		forceField.Parent = character
		task.delay(1, function()
			if player.Character == character and player:GetAttribute("SpawnProtected") then
				notify(player, "You have 10 seconds of spawn protection. Attacking ends it early.", Color3.fromRGB(107, 169, 255))
			end
		end)
		task.delay(10, function()
			if player.Character == character and character.Parent and player:GetAttribute("SpawnProtected") then
				removeSpawnProtection(player)
				notify(player, "Spawn protection ended.", Color3.fromRGB(170, 175, 185))
			end
		end)
		humanoid.Died:Connect(function()
			handleDeath(player, character)
		end)
	end
	task.delay(0.75, function()
		if player.Parent and character.Parent then
			rebuildTools(player)
		end
	end)
end

local function setupPlayer(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local cashValue = Instance.new("IntValue")
	cashValue.Name = "Cash"
	cashValue.Parent = leaderstats

	local inventory = Instance.new("Folder")
	inventory.Name = "Inventory"
	inventory.Parent = player

	local stash = Instance.new("Folder")
	stash.Name = "Stash"
	stash.Parent = player

	player:SetAttribute("Cash", DEFAULT_CASH)
	player:SetAttribute("Bank", 0)
	player:SetAttribute("Heat", 0)
	player:SetAttribute("Bounty", 0)
	player:SetAttribute("LastPoliceContact", 0)
	player:SetAttribute("LastAttackerUserId", 0)
	player:SetAttribute("LastAttackAt", 0)
	player:SetAttribute("Downed", false)
	player:SetAttribute("Stamina", MAX_STAMINA)
	player:SetAttribute("Sprinting", false)
	player:SetAttribute("Blocking", false)
	player:SetAttribute("SpawnProtected", false)
	player:SetAttribute("BalloonEquipped", false)
	player:SetAttribute("OwnsRustCompact", false)
	player:SetAttribute("VehicleFuel", VEHICLE_MAX_FUEL)
	player:SetAttribute("VehicleCondition", VEHICLE_MAX_CONDITION)
	player:SetAttribute("VehicleActive", false)
	player:SetAttribute("DailyContractDay", 0)
	player:SetAttribute("DailyContractId", "")
	player:SetAttribute("DailyContractTitle", "Loading daily contract...")
	player:SetAttribute("DailyContractDescription", "")
	player:SetAttribute("DailyContractProgress", 0)
	player:SetAttribute("DailyContractGoal", 1)
	player:SetAttribute("DailyContractReward", 0)
	player:SetAttribute("DailyContractClaimed", false)
	player:SetAttribute("DataLoaded", false)
	player:SetAttribute("DataCanSave", false)
	for itemId, item in pairs(itemDefinitions) do
		if item.Kind == "Gun" then
			setMagazine(player, itemId, 0)
		end
	end
	setObjective(player, "Find work, buy equipment, or risk a robbery.")

	player:GetAttributeChangedSignal("Cash"):Connect(function()
		cashValue.Value = player:GetAttribute("Cash") or 0
	end)
	cashValue.Value = DEFAULT_CASH

	player.CharacterAdded:Connect(function(character)
		setupCharacter(player, character)
	end)
	if player.Character then
		task.spawn(setupCharacter, player, player.Character)
	end

	local success, saved = pcall(function()
		return playerStore:GetAsync("Player_" .. player.UserId)
	end)
	if success then
		player:SetAttribute("DataCanSave", true)
		if type(saved) == "table" then
			player:SetAttribute("Cash", math.max(0, math.floor(tonumber(saved.Cash) or DEFAULT_CASH)))
			player:SetAttribute("Bank", math.max(0, math.floor(tonumber(saved.Bank) or 0)))
			player:SetAttribute("Bounty", math.max(0, math.floor(tonumber(saved.Bounty) or 0)))
			applySavedItems(player, "Inventory", saved.Inventory)
			applySavedItems(player, "Stash", saved.Stash)
			applySavedMagazines(player, saved.Magazines)
			if type(saved.Vehicle) == "table" then
				player:SetAttribute("OwnsRustCompact", saved.Vehicle.Owned == true)
				player:SetAttribute("VehicleFuel", math.clamp(tonumber(saved.Vehicle.Fuel) or VEHICLE_MAX_FUEL, 0, VEHICLE_MAX_FUEL))
				player:SetAttribute("VehicleCondition", math.clamp(tonumber(saved.Vehicle.Condition) or VEHICLE_MAX_CONDITION, 0, VEHICLE_MAX_CONDITION))
			end
		end
	else
		warn("Ohio2 data could not load for " .. player.Name .. ": " .. tostring(saved))
		task.delay(3, function()
			notify(player, "Using temporary test data because Studio saving is unavailable.", Color3.fromRGB(255, 196, 82))
		end)
	end

	assignDailyContract(player, type(saved) == "table" and saved.DailyContract or nil)
	player:SetAttribute("DataLoaded", true)
	rebuildTools(player)
	notify(player, "PHONE: Your daily contract is " .. (player:GetAttribute("DailyContractTitle") or "ready") .. ". Press P or tap PHONE.", Color3.fromRGB(107, 169, 255))
end

local function getPromptPosition(prompt)
	local parent = prompt.Parent
	if parent:IsA("Attachment") and parent.Parent:IsA("BasePart") then
		return parent.WorldPosition
	end
	if parent:IsA("BasePart") then
		return parent.Position
	end
	return nil
end

local function playerIsNearPrompt(player, prompt)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local promptPosition = getPromptPosition(prompt)
	return root and promptPosition and (root.Position - promptPosition).Magnitude <= prompt.MaxActivationDistance + 4
end

local function transferAll(player, fromName, toName)
	local from = getContainer(player, fromName)
	if not from then
		return 0
	end
	local moved = 0
	for _, value in ipairs(from:GetChildren()) do
		if value:IsA("IntValue") and value.Value > 0 and itemDefinitions[value.Name] then
			moved = moved + value.Value
			addItem(player, toName, value.Name, value.Value)
			value:Destroy()
		end
	end
	rebuildTools(player)
	return moved
end

local function grantSearchLoot(player, tier)
	local cash
	local pistolAmmo = 0
	local shells = 0
	local medkits = 0
	if tier == "Rare" then
		cash = math.random(160, 400)
		pistolAmmo = math.random(24, 48)
		shells = math.random(8, 18)
		medkits = math.random() < 0.55 and 1 or 0
	else
		cash = math.random(30, 120)
		pistolAmmo = math.random() < 0.5 and math.random(6, 18) or 0
		shells = math.random() < 0.12 and math.random(4, 8) or 0
		medkits = math.random() < 0.18 and 1 or 0
	end

	changeCash(player, cash)
	local rewards = {"$" .. cash}
	if pistolAmmo > 0 then
		addItem(player, "Inventory", "PistolAmmo", pistolAmmo)
		table.insert(rewards, pistolAmmo .. " 9mm")
	end
	if shells > 0 then
		addItem(player, "Inventory", "Shells", shells)
		table.insert(rewards, shells .. " shells")
	end
	if medkits > 0 then
		addItem(player, "Inventory", "Medkit", medkits)
		table.insert(rewards, "1 medkit")
	end
	rebuildTools(player)
	notify(player, "Found " .. table.concat(rewards, ", ") .. ".", tier == "Rare" and Color3.fromRGB(255, 205, 91) or Color3.fromRGB(110, 232, 154))
end

local function grantSupplyDrop(player)
	local cash = math.random(550, 900)
	local pistolAmmo = math.random(36, 60)
	local shells = math.random(12, 24)
	local rewards = {"$" .. cash, pistolAmmo .. " 9mm", shells .. " shells", "1 medkit"}
	changeCash(player, cash)
	addItem(player, "Inventory", "PistolAmmo", pistolAmmo)
	addItem(player, "Inventory", "Shells", shells)
	addItem(player, "Inventory", "Medkit", 1)

	if getItemCount(player, "Inventory", "Pistol") <= 0 and getItemCount(player, "Inventory", "Shotgun") <= 0 then
		local weaponId = math.random() < 0.25 and "Shotgun" or "Pistol"
		local weapon = itemDefinitions[weaponId]
		addItem(player, "Inventory", weaponId, 1)
		setMagazine(player, weaponId, weapon.MagazineSize)
		table.insert(rewards, weapon.DisplayName)
	end

	rebuildTools(player)
	notify(player, "SUPPLY DROP: " .. table.concat(rewards, ", ") .. ".", Color3.fromRGB(255, 205, 91))
end

local function triggerStoreAlarm(duration)
	storeAlarmToken = storeAlarmToken + 1
	local token = storeAlarmToken
	local expiresAt = os.clock() + duration
	local beacon = map:FindFirstChild("QuickStopAlarmBeacon", true)
	local light = beacon and beacon:FindFirstChildOfClass("PointLight")
	workspace:SetAttribute("QuickStopAlarm", true)
	task.spawn(function()
		local lit = false
		while storeAlarmToken == token and os.clock() < expiresAt do
			lit = not lit
			if beacon and beacon.Parent then
				beacon.Transparency = lit and 0 or 0.65
			end
			if light and light.Parent then
				light.Enabled = lit and not blackoutState.Active
			end
			task.wait(0.28)
		end
		if beacon and beacon.Parent then
			beacon.Transparency = 0.65
		end
		if light and light.Parent then
			light.Enabled = false
		end
		if storeAlarmToken == token then
			workspace:SetAttribute("QuickStopAlarm", false)
		end
	end)
end

local function handlePrompt(prompt, player)
	if not player:GetAttribute("DataLoaded") or not playerIsNearPrompt(player, prompt) then
		return
	end
	if player:GetAttribute("Downed") then
		return
	end

	local actionType = prompt:GetAttribute("ActionType")
	if actionType == "BuyItem" then
		local itemId = prompt:GetAttribute("ItemId")
		local item = itemDefinitions[itemId]
		if not item then
			return
		end
		if (item.Kind == "Gun" or item.Kind == "Melee" or item.Kind == "Utility") and getItemCount(player, "Inventory", itemId) > 0 then
			notify(player, "You already carry that item.", Color3.fromRGB(255, 196, 82))
			return
		end
		if (player:GetAttribute("Cash") or 0) < item.Price then
			notify(player, "You need $" .. item.Price .. ".", Color3.fromRGB(255, 104, 104))
			return
		end
		changeCash(player, -item.Price)
		local received = 1
		if item.Kind == "Ammo" then
			received = item.Bundle
			addItem(player, "Inventory", itemId, received)
		elseif item.Kind == "Gun" then
			addItem(player, "Inventory", itemId, 1)
			setMagazine(player, itemId, item.MagazineSize)
			addItem(player, "Inventory", item.AmmoItem, item.StarterAmmo)
		else
			addItem(player, "Inventory", itemId, 1)
		end
		rebuildTools(player)
		local amountText = received > 1 and (" x" .. received) or ""
		notify(player, "Bought " .. item.DisplayName .. amountText .. " for $" .. item.Price .. ".", Color3.fromRGB(110, 232, 154))
	elseif actionType == "StartRouteJob" then
		if activeJobs[player] then
			notify(player, "Finish your current job first.", Color3.fromRGB(255, 196, 82))
			return
		end
		local jobId = prompt:GetAttribute("JobId")
		local jobName = prompt:GetAttribute("JobName")
		local objectiveText = prompt:GetAttribute("ObjectiveText")
		local reward = math.clamp(math.floor(tonumber(prompt:GetAttribute("Reward")) or 0), 100, 1000)
		if type(jobId) ~= "string" or jobId == "" or type(jobName) ~= "string" or type(objectiveText) ~= "string" then
			return
		end
		activeJobs[player] = {
			Type = "Route",
			JobId = jobId,
			JobName = jobName,
			Reward = reward,
			Started = os.clock(),
		}
		setObjective(player, objectiveText)
		notify(player, jobName .. " started • pays $" .. reward .. ".", Color3.fromRGB(110, 232, 154))
	elseif actionType == "CompleteRouteJob" then
		local job = activeJobs[player]
		local jobId = prompt:GetAttribute("JobId")
		if not job or job.Type ~= "Route" or job.JobId ~= jobId then
			notify(player, "You do not have the matching delivery for this receiver.", Color3.fromRGB(255, 196, 82))
			return
		end
		if os.clock() - job.Started < 8 then
			notify(player, "That route was completed suspiciously fast.", Color3.fromRGB(255, 104, 104))
			return
		end
		activeJobs[player] = nil
		changeCash(player, job.Reward)
		setObjective(player, "Job complete. Explore the district or start another route.")
		notify(player, "+$" .. job.Reward .. " • " .. job.JobName .. " complete.", Color3.fromRGB(110, 232, 154))
		progressDailyContract(player, "HonestWork", 1)
	elseif actionType == "StartTowJob" then
		if activeJobs[player] then
			notify(player, "Finish your current job first.", Color3.fromRGB(255, 196, 82))
			return
		end
		local target = TOW_TARGETS[math.random(1, #TOW_TARGETS)]
		activeJobs[player] = {
			Type = "Tow",
			TargetId = target.Id,
			Location = target.Location,
			Stage = "Recover",
			Started = os.clock(),
		}
		setObjective(player, "TOW CALL: Secure the disabled vehicle at " .. target.Location .. ".")
		notify(player, "Tow call accepted • $650 base pay, plus $100 for a fast return.", Color3.fromRGB(110, 232, 154))
	elseif actionType == "RecoverTowVehicle" then
		local job = activeJobs[player]
		local targetId = prompt:GetAttribute("TargetId")
		if not job or job.Type ~= "Tow" or job.Stage ~= "Recover" then
			notify(player, "Start a tow call at Rust Belt Auto first.", Color3.fromRGB(255, 196, 82))
			return
		end
		if job.TargetId ~= targetId then
			notify(player, "This is not your assigned disabled vehicle. Check the objective.", Color3.fromRGB(255, 196, 82))
			return
		end
		if os.clock() - job.Started < 4 then
			notify(player, "You reached that vehicle suspiciously fast.", Color3.fromRGB(255, 104, 104))
			return
		end
		job.Stage = "Return"
		job.RecoveredAt = os.clock()
		setObjective(player, "TOW CALL: Cable secured. Return the vehicle to the blue tow bay at Rust Belt Auto.")
		notify(player, "Tow cable secured. Return to Rust Belt Auto.", Color3.fromRGB(107, 169, 255))
	elseif actionType == "CompleteTowJob" then
		local job = activeJobs[player]
		if not job or job.Type ~= "Tow" or job.Stage ~= "Return" then
			notify(player, "Recover your assigned disabled vehicle first.", Color3.fromRGB(255, 196, 82))
			return
		end
		if os.clock() - (job.RecoveredAt or os.clock()) < 8 then
			notify(player, "That return was completed suspiciously fast.", Color3.fromRGB(255, 104, 104))
			return
		end
		local fastBonus = os.clock() - job.Started <= 150 and 100 or 0
		local reward = TOW_BASE_REWARD + fastBonus
		activeJobs[player] = nil
		changeCash(player, reward)
		setObjective(player, "Tow complete. Pick up another call or explore the district.")
		notify(player, "+$" .. reward .. " tow payment" .. (fastBonus > 0 and " • fast-return bonus included" or ""), Color3.fromRGB(110, 232, 154))
		progressDailyContract(player, "TowShift", 1)
	elseif actionType == "BuyPersonalVehicle" then
		if player:GetAttribute("OwnsRustCompact") then
			notify(player, "You already own a Rust Compact. Use the garage terminal to spawn it.", Color3.fromRGB(255, 196, 82))
			return
		end
		if (player:GetAttribute("Cash") or 0) < VEHICLE_PRICE then
			notify(player, "The Rust Compact costs $" .. VEHICLE_PRICE .. " wallet cash.", Color3.fromRGB(255, 104, 104))
			return
		end
		changeCash(player, -VEHICLE_PRICE)
		player:SetAttribute("OwnsRustCompact", true)
		player:SetAttribute("VehicleFuel", VEHICLE_MAX_FUEL)
		player:SetAttribute("VehicleCondition", VEHICLE_MAX_CONDITION)
		notify(player, "Rust Compact purchased for $" .. VEHICLE_PRICE .. ". Spawn it at the blue garage terminal.", Color3.fromRGB(110, 232, 154))
		task.spawn(savePlayer, player)
	elseif actionType == "GaragePersonalVehicle" then
		if player:GetAttribute("OwnsRustCompact") ~= true then
			notify(player, "Purchase the Rust Compact at the sales terminal first.", Color3.fromRGB(255, 196, 82))
			return
		end
		local activeVehicle = activeVehicles[player]
		if activeVehicle and activeVehicle.Parent then
			storeActiveVehicle(player, true)
			notify(player, "Rust Compact stored with its current fuel and condition.", Color3.fromRGB(107, 169, 255))
			task.spawn(savePlayer, player)
		else
			local vehicle, problem = spawnPersonalVehicle(player)
			if vehicle then
				notify(player, "Rust Compact spawned in the marked garage bay.", Color3.fromRGB(110, 232, 154))
			else
				notify(player, problem, Color3.fromRGB(255, 104, 104))
			end
		end
	elseif actionType == "RefuelPersonalVehicle" then
		local vehicle = activeVehicles[player]
		local chassis = vehicle and vehicle.Parent and vehicle:FindFirstChild("Chassis")
		if not vehicle or not chassis or (chassis.Position - getPromptPosition(prompt)).Magnitude > 24 then
			notify(player, "Park your active Rust Compact beside the fuel pump.", Color3.fromRGB(255, 196, 82))
			return
		end
		local fuel = math.clamp(vehicle:GetAttribute("Fuel") or 0, 0, VEHICLE_MAX_FUEL)
		local missing = VEHICLE_MAX_FUEL - fuel
		if missing <= 0.1 then
			notify(player, "Your tank is already full.", Color3.fromRGB(255, 196, 82))
			return
		end
		local cost = math.max(1, math.ceil(missing * REFUEL_PRICE_PER_UNIT))
		if (player:GetAttribute("Cash") or 0) < cost then
			notify(player, "A full refuel costs $" .. cost .. ".", Color3.fromRGB(255, 104, 104))
			return
		end
		changeCash(player, -cost)
		vehicle:SetAttribute("Fuel", VEHICLE_MAX_FUEL)
		vehicle:SetAttribute("VehicleDisabled", (vehicle:GetAttribute("Condition") or 0) <= 0)
		updateVehicleAttributes(player, vehicle)
		notify(player, "Tank filled for $" .. cost .. ".", Color3.fromRGB(110, 232, 154))
		task.spawn(savePlayer, player)
	elseif actionType == "RepairPersonalVehicle" then
		local vehicle = activeVehicles[player]
		local chassis = vehicle and vehicle.Parent and vehicle:FindFirstChild("Chassis")
		if not vehicle or not chassis or (chassis.Position - getPromptPosition(prompt)).Magnitude > 28 then
			notify(player, "Bring your active Rust Compact into the Rust Belt Auto service bay.", Color3.fromRGB(255, 196, 82))
			return
		end
		local condition = math.clamp(vehicle:GetAttribute("Condition") or 0, 0, VEHICLE_MAX_CONDITION)
		local missing = VEHICLE_MAX_CONDITION - condition
		if missing <= 0.1 then
			notify(player, "Your vehicle does not need repairs.", Color3.fromRGB(255, 196, 82))
			return
		end
		local cost = math.max(50, math.ceil(missing * REPAIR_PRICE_PER_POINT))
		if (player:GetAttribute("Cash") or 0) < cost then
			notify(player, "Rust Belt Auto needs $" .. cost .. " for a full repair.", Color3.fromRGB(255, 104, 104))
			return
		end
		changeCash(player, -cost)
		vehicle:SetAttribute("Condition", VEHICLE_MAX_CONDITION)
		vehicle:SetAttribute("VehicleDisabled", (vehicle:GetAttribute("Fuel") or 0) <= 0)
		updateVehicleAttributes(player, vehicle)
		notify(player, "Rust Compact fully repaired for $" .. cost .. ".", Color3.fromRGB(110, 232, 154))
		task.spawn(savePlayer, player)
	elseif actionType == "StartDelivery" then
		if activeJobs[player] then
			notify(player, "Finish your current delivery first.", Color3.fromRGB(255, 196, 82))
			return
		end
		activeJobs[player] = {Type = "Delivery", Started = os.clock()}
		setObjective(player, "DELIVERY: Take the package to the green counter inside Quick Stop.")
		notify(player, "Delivery started. Follow the objective for a $350 reward.", Color3.fromRGB(110, 232, 154))
	elseif actionType == "CompleteDelivery" then
		local job = activeJobs[player]
		if not job or job.Type ~= "Delivery" then
			notify(player, "Start a delivery at the warehouse first.", Color3.fromRGB(255, 196, 82))
			return
		end
		if os.clock() - job.Started < 4 then
			notify(player, "That delivery was suspiciously fast.", Color3.fromRGB(255, 104, 104))
			return
		end
		activeJobs[player] = nil
		changeCash(player, 350)
		setObjective(player, "Delivery complete. Start another job or spend your cash.")
		notify(player, "+$350 delivery payment", Color3.fromRGB(110, 232, 154))
		progressDailyContract(player, "HonestWork", 1)
	elseif actionType == "RobStore" then
		local readyAt = worldCooldowns[prompt] or 0
		if os.clock() < readyAt then
			notify(player, "The register is empty for another " .. formatWait(readyAt - os.clock()) .. ".", Color3.fromRGB(255, 196, 82))
			return
		end
		if player:GetAttribute("SpawnProtected") then
			removeSpawnProtection(player)
		end
		worldCooldowns[prompt] = os.clock() + WORLD_ROBBERY_COOLDOWN
		activeJobs[player] = nil
		storeRobberies[player] = {Started = os.clock()}
		player:SetAttribute("LastPoliceContact", os.clock())
		triggerStoreAlarm(45)
		local reward = math.random(700, 1200)
		changeCash(player, reward)
		changeHeat(player, 3)
		changeBounty(player, ROBBERY_BOUNTY)
		setObjective(player, "QUICK STOP: The manager code opened the back-room safe. Crack it before the alarm window closes.")
		notify(player, "+$" .. reward .. " from the register • safe access unlocked • bounty +$" .. ROBBERY_BOUNTY .. ".", Color3.fromRGB(255, 104, 104))
		notificationRemote:FireAllClients("POLICE DISPATCH: Armed robbery alarm at Quick Stop.", Color3.fromRGB(255, 104, 104))
	elseif actionType == "RobStoreSafe" then
		local robbery = storeRobberies[player]
		if not robbery or os.clock() - robbery.Started > 75 then
			storeRobberies[player] = nil
			notify(player, "Rob the register first to obtain the temporary manager code.", Color3.fromRGB(255, 196, 82))
			return
		end
		local readyAt = worldCooldowns[prompt] or 0
		if os.clock() < readyAt then
			notify(player, "The back-room safe is on a " .. formatWait(readyAt - os.clock()) .. " security lockout.", Color3.fromRGB(255, 196, 82))
			return
		end
		if os.clock() - robbery.Started < 8 then
			notify(player, "The safe's delay lock has not released yet.", Color3.fromRGB(255, 196, 82))
			return
		end
		worldCooldowns[prompt] = os.clock() + STORE_SAFE_COOLDOWN
		prompt.Enabled = false
		task.delay(STORE_SAFE_COOLDOWN, function()
			if prompt.Parent then
				prompt.Enabled = true
			end
		end)
		storeRobberies[player] = nil
		player:SetAttribute("LastPoliceContact", os.clock())
		triggerStoreAlarm(60)
		local reward = math.random(1200, 1800)
		changeCash(player, reward)
		changeHeat(player, MAX_HEAT)
		changeBounty(player, 750)
		setObjective(player, "MAXIMUM RESPONSE: Escape the search perimeter and protect the cash in your wallet.")
		notify(player, "+$" .. reward .. " from the safe • maximum heat • bounty +$750.", Color3.fromRGB(255, 104, 104))
		notificationRemote:FireAllClients(player.DisplayName .. " breached the Quick Stop safe. Maximum police response authorized!", Color3.fromRGB(255, 104, 104))
	elseif actionType == "SearchContainer" then
		local readyAt = worldCooldowns[prompt] or 0
		if os.clock() < readyAt then
			notify(player, "Someone searched this recently. Check back in " .. formatWait(readyAt - os.clock()) .. ".", Color3.fromRGB(255, 196, 82))
			return
		end
		local cooldown = math.clamp(math.floor(prompt:GetAttribute("Cooldown") or 300), 120, 1200)
		worldCooldowns[prompt] = os.clock() + cooldown
		prompt.Enabled = false
		task.delay(cooldown, function()
			if prompt.Parent then
				prompt.Enabled = true
			end
		end)
		grantSearchLoot(player, prompt:GetAttribute("LootTier") == "Rare" and "Rare" or "Common")
		progressDailyContract(player, "StreetScavenger", 1)
	elseif actionType == "SupplyDrop" then
		local crate = prompt.Parent:IsA("BasePart") and prompt.Parent or nil
		local drop = crate and supplyDrops[crate]
		if not drop or drop.Taken then
			return
		end
		drop.Taken = true
		prompt.Enabled = false
		grantSupplyDrop(player)
		notificationRemote:FireAllClients(player.DisplayName .. " claimed the contested supply drop!", Color3.fromRGB(255, 205, 91))
		supplyDrops[crate] = nil
		task.delay(0.8, function()
			if crate.Parent then
				crate:Destroy()
			end
		end)
	elseif actionType == "ArmoredTruckRobbery" then
		local event = armoredTruckEvent
		if not event or event.Claimed or event.Prompt ~= prompt then
			return
		end
		event.Claimed = true
		prompt.Enabled = false
		if player:GetAttribute("SpawnProtected") then
			removeSpawnProtection(player)
		end
		local reward = math.random(1800, 2600)
		changeCash(player, reward)
		changeHeat(player, MAX_HEAT)
		changeBounty(player, 1500)
		activeJobs[player] = nil
		setObjective(player, "ARMORED TRUCK HIT: Escape the police and secure your stolen cash.")
		notify(player, "+$" .. reward .. " armored-truck score • bounty +$1,500!", Color3.fromRGB(255, 104, 104))
		notificationRemote:FireAllClients(player.DisplayName .. " breached the armored truck. Police response is at maximum!", Color3.fromRGB(255, 104, 104))
		local model = event.Model
		armoredTruckEvent = nil
		workspace:SetAttribute("ArmoredTruckActive", false)
		task.delay(1.5, function()
			if model.Parent then
				model:Destroy()
			end
		end)
	elseif actionType == "ClinicHeal" then
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then
			return
		end
		if humanoid.Health >= humanoid.MaxHealth then
			notify(player, "You are already at full health.", Color3.fromRGB(255, 196, 82))
			return
		end
		if (player:GetAttribute("Cash") or 0) < 75 then
			notify(player, "County Clinic treatment costs $75.", Color3.fromRGB(255, 104, 104))
			return
		end
		changeCash(player, -75)
		humanoid.Health = humanoid.MaxHealth
		notify(player, "County Clinic restored you to full health for $75.", Color3.fromRGB(110, 232, 154))
	elseif actionType == "DepositBank" then
		local amount = math.min(500, player:GetAttribute("Cash") or 0)
		if amount <= 0 then
			notify(player, "You have no wallet cash to deposit.", Color3.fromRGB(255, 196, 82))
			return
		end
		changeCash(player, -amount)
		changeBank(player, amount)
		notify(player, "Deposited $" .. amount .. ". Banked cash is safe on death.", Color3.fromRGB(110, 232, 154))
	elseif actionType == "WithdrawBank" then
		local amount = math.min(500, player:GetAttribute("Bank") or 0)
		if amount <= 0 then
			notify(player, "Your bank is empty.", Color3.fromRGB(255, 196, 82))
			return
		end
		changeBank(player, -amount)
		changeCash(player, amount)
		notify(player, "Withdrew $" .. amount .. ".", Color3.fromRGB(110, 232, 154))
	elseif actionType == "DepositStash" then
		unloadMagazines(player)
		local moved = transferAll(player, "Inventory", "Stash")
		notify(player, moved > 0 and ("Stashed " .. moved .. " item(s).") or "You have nothing to stash.", moved > 0 and Color3.fromRGB(110, 232, 154) or Color3.fromRGB(255, 196, 82))
	elseif actionType == "WithdrawStash" then
		local moved = transferAll(player, "Stash", "Inventory")
		notify(player, moved > 0 and ("Withdrew " .. moved .. " item(s).") or "Your stash is empty.", moved > 0 and Color3.fromRGB(110, 232, 154) or Color3.fromRGB(255, 196, 82))
	elseif actionType == "RevivePlayer" then
		local targetUserId = prompt:GetAttribute("TargetUserId")
		local target = type(targetUserId) == "number" and Players:GetPlayerByUserId(targetUserId) or nil
		if not target or target == player or not downedStates[target] or downedStates[target].Prompt ~= prompt then
			return
		end
		clearDowned(target, 35)
		setObjective(target, "You were revived. Reach the safehouse and protect your gear.")
		notify(target, player.DisplayName .. " revived you with 35 health.", Color3.fromRGB(110, 232, 154))
		notify(player, "You revived " .. target.DisplayName .. ".", Color3.fromRGB(110, 232, 154))
	elseif actionType == "LootBag" then
		local bag = prompt.Parent:IsA("BasePart") and prompt.Parent or nil
		local loot = bag and lootBags[bag]
		if not loot or loot.Taken then
			return
		end
		loot.Taken = true
		changeCash(player, loot.Cash)
		for itemId, amount in pairs(loot.Items) do
			addItem(player, "Inventory", itemId, amount)
		end
		rebuildTools(player)
		notify(player, "Looted the bag and $" .. loot.Cash .. ".", Color3.fromRGB(110, 232, 154))
		lootBags[bag] = nil
		bag:Destroy()
	end
end

local SUPPLY_DROP_POSITIONS = {
	Vector3.new(-165, 2.2, 12),
	Vector3.new(112, 2.2, 12),
	Vector3.new(10, 2.2, -155),
	Vector3.new(178, 2.2, 158),
	Vector3.new(-182, 2.2, 152),
	Vector3.new(-365, 2.2, -340),
	Vector3.new(375, 2.2, -330),
	Vector3.new(-365, 2.2, 335),
	Vector3.new(335, 2.2, 310),
	Vector3.new(-120, 2.2, 334),
}

local function spawnSupplyDrop()
	for crate, drop in pairs(supplyDrops) do
		if crate.Parent and not drop.Taken then
			return
		end
	end

	local position = SUPPLY_DROP_POSITIONS[math.random(1, #SUPPLY_DROP_POSITIONS)]
	local crate = Instance.new("Part")
	crate.Name = "ContestedSupplyDrop"
	crate.Size = Vector3.new(6, 4, 6)
	crate.CFrame = CFrame.new(position)
	crate.Color = Color3.fromRGB(65, 120, 78)
	crate.Material = Enum.Material.Metal
	crate.Anchored = true
	crate.CanCollide = true
	crate.TopSurface = Enum.SurfaceType.Smooth
	crate.BottomSurface = Enum.SurfaceType.Smooth
	crate.Parent = dropsFolder

	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 207, 88)
	light.Range = 28
	light.Brightness = 2.4
	light.Parent = crate

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "DropLabel"
	billboard.Size = UDim2.fromOffset(260, 54)
	billboard.StudsOffset = Vector3.new(0, 5, 0)
	billboard.AlwaysOnTop = false
	billboard.MaxDistance = 0
	billboard.Parent = crate
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = Color3.fromRGB(18, 21, 18)
	label.BackgroundTransparency = 0.08
	label.TextColor3 = Color3.fromRGB(255, 214, 103)
	label.Text = "CONTESTED SUPPLY DROP"
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.Parent = billboard
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = label

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Claim Supplies"
	prompt.ObjectText = "Contested Crate • One winner"
	prompt.HoldDuration = 3
	prompt.MaxActivationDistance = 11
	prompt.RequiresLineOfSight = false
	prompt:SetAttribute("ActionType", "SupplyDrop")
	prompt.Parent = crate

	supplyDrops[crate] = {Taken = false}
	notificationRemote:FireAllClients("SUPPLY DROP INBOUND! Find the gold beacon and hold E for 3 seconds.", Color3.fromRGB(255, 205, 91))
	task.delay(120, function()
		local drop = supplyDrops[crate]
		if drop and not drop.Taken then
			supplyDrops[crate] = nil
			if crate.Parent then
				crate:Destroy()
			end
			notificationRemote:FireAllClients("The unclaimed supply drop expired.", Color3.fromRGB(170, 175, 185))
		end
	end)
end

local ARMORED_TRUCK_LOCATIONS = {
	{Position = Vector3.new(-365, 0, -76), Rotation = 90},
	{Position = Vector3.new(-125, 0, -292), Rotation = 90},
	{Position = Vector3.new(165, 0, -289), Rotation = 90},
	{Position = Vector3.new(375, 0, -88), Rotation = 90},
	{Position = Vector3.new(-355, 0, 178), Rotation = 90},
}

local function spawnArmoredTruck()
	if armoredTruckEvent and armoredTruckEvent.Model.Parent then
		return
	end

	local location = ARMORED_TRUCK_LOCATIONS[math.random(1, #ARMORED_TRUCK_LOCATIONS)]
	local truckCFrame = CFrame.new(location.Position) * CFrame.Angles(0, math.rad(location.Rotation), 0)
	local model = Instance.new("Model")
	model.Name = "ArmoredTruckEvent"
	model.Parent = dropsFolder

	local function eventPart(name, size, relativeCFrame, color, material)
		local part = Instance.new("Part")
		part.Name = name
		part.Size = size
		part.CFrame = truckCFrame * relativeCFrame
		part.Color = color
		part.Material = material or Enum.Material.Metal
		part.Anchored = true
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		part.Parent = model
		return part
	end

	eventPart("Chassis", Vector3.new(9.5, 1.2, 15.5), CFrame.new(0, 1.2, 0), Color3.fromRGB(40, 43, 47), Enum.Material.Metal)
	local body = eventPart("ArmoredBody", Vector3.new(8.8, 6.4, 10), CFrame.new(0, 4.3, 2.1), Color3.fromRGB(75, 82, 84), Enum.Material.DiamondPlate)
	eventPart("Cab", Vector3.new(8.5, 5.2, 5.2), CFrame.new(0, 3.7, -5.4), Color3.fromRGB(68, 75, 78), Enum.Material.Metal)
	eventPart("Windshield", Vector3.new(7.2, 2, 0.2), CFrame.new(0, 4.6, -8.05), Color3.fromRGB(72, 103, 113), Enum.Material.Glass).Transparency = 0.25
	eventPart("FrontBumper", Vector3.new(9.6, 0.7, 0.6), CFrame.new(0, 1.25, -8.3), Color3.fromRGB(42, 45, 48), Enum.Material.Metal)
	for _, offset in ipairs({Vector3.new(-4.8, 1.35, -4.7), Vector3.new(4.8, 1.35, -4.7), Vector3.new(-4.8, 1.35, 4.7), Vector3.new(4.8, 1.35, 4.7)}) do
		local wheel = eventPart("Wheel", Vector3.new(1.5, 3.4, 3.4), CFrame.new(offset), Color3.fromRGB(23, 24, 26), Enum.Material.Rubber)
		wheel.Shape = Enum.PartType.Cylinder
	end
	for _, x in ipairs({-2.7, 2.7}) do
		eventPart("Headlight", Vector3.new(1.4, 0.75, 0.22), CFrame.new(x, 2.5, -8.16), Color3.fromRGB(255, 231, 164), Enum.Material.Neon)
	end
	for y = 2, 6.4, 1.1 do
		eventPart("RearArmorRib", Vector3.new(8.5, 0.14, 0.25), CFrame.new(0, y, 7.18), Color3.fromRGB(47, 51, 54), Enum.Material.Metal).CanCollide = false
	end
	local vault = eventPart("VaultDoor", Vector3.new(7.8, 5.3, 0.4), CFrame.new(0, 4.1, 7.25), Color3.fromRGB(54, 59, 62), Enum.Material.DiamondPlate)
	eventPart("VaultLock", Vector3.new(0.55, 2.1, 2.1), CFrame.new(0, 4.1, 7.52) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(31, 34, 36), Enum.Material.Metal).Shape = Enum.PartType.Cylinder

	local redSiren = eventPart("RedSiren", Vector3.new(1.3, 0.5, 0.9), CFrame.new(-1.1, 7.75, -4.8), Color3.fromRGB(235, 55, 55), Enum.Material.Neon)
	local blueSiren = eventPart("BlueSiren", Vector3.new(1.3, 0.5, 0.9), CFrame.new(1.1, 7.75, -4.8), Color3.fromRGB(65, 128, 235), Enum.Material.Neon)
	local redLight = Instance.new("PointLight")
	redLight.Color = redSiren.Color
	redLight.Range = 20
	redLight.Brightness = 2
	redLight.Parent = redSiren
	local blueLight = redLight:Clone()
	blueLight.Color = blueSiren.Color
	blueLight.Parent = blueSiren

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "EventLabel"
	billboard.Size = UDim2.fromOffset(300, 62)
	billboard.StudsOffset = Vector3.new(0, 7, 0)
	billboard.AlwaysOnTop = false
	billboard.MaxDistance = 0
	billboard.Parent = body
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = Color3.fromRGB(25, 26, 29)
	label.BackgroundTransparency = 0.08
	label.TextColor3 = Color3.fromRGB(255, 104, 104)
	label.Text = "ARMORED TRUCK • $1,800–$2,600"
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.Parent = billboard
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = label

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Breach Vault"
	prompt.ObjectText = "Armored Truck • Maximum police response"
	prompt.HoldDuration = 8
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt:SetAttribute("ActionType", "ArmoredTruckRobbery")
	prompt.Parent = vault

	local event = {Model = model, Prompt = prompt, Claimed = false}
	armoredTruckEvent = event
	workspace:SetAttribute("ArmoredTruckActive", true)
	notificationRemote:FireAllClients("ARMORED TRUCK SPOTTED! Follow the red beacon. It leaves in 150 seconds.", Color3.fromRGB(255, 104, 104))

	task.spawn(function()
		local redOn = true
		while armoredTruckEvent == event and model.Parent do
			redOn = not redOn
			if blackoutState.Active then
				redLight.Enabled = false
				blueLight.Enabled = false
				redSiren.Transparency = 0.7
				blueSiren.Transparency = 0.7
			else
				redLight.Enabled = redOn
				blueLight.Enabled = not redOn
				redSiren.Transparency = redOn and 0 or 0.65
				blueSiren.Transparency = redOn and 0.65 or 0
			end
			task.wait(0.35)
		end
	end)

	task.delay(150, function()
		if armoredTruckEvent == event and not event.Claimed then
			armoredTruckEvent = nil
			workspace:SetAttribute("ArmoredTruckActive", false)
			if model.Parent then
				model:Destroy()
			end
			notificationRemote:FireAllClients("The armored truck escaped unclaimed.", Color3.fromRGB(170, 175, 185))
		end
	end)
end

local function setBlackout(active)
	if active then
		if blackoutState.Active then
			return
		end
		local state = {
			Active = true,
			Lights = {},
			NeonParts = {},
			Lighting = {
				Brightness = Lighting.Brightness,
				ExposureCompensation = Lighting.ExposureCompensation,
				Ambient = Lighting.Ambient,
				OutdoorAmbient = Lighting.OutdoorAmbient,
			},
		}
		blackoutState = state
		for _, rootContainer in ipairs({map, dropsFolder}) do
			for _, descendant in ipairs(rootContainer:GetDescendants()) do
				if descendant:IsA("Light") then
					state.Lights[descendant] = descendant.Enabled
					descendant.Enabled = false
				elseif descendant:IsA("BasePart") and descendant.Material == Enum.Material.Neon and descendant.Name ~= "SpawnLocation" then
					state.NeonParts[descendant] = {
						Material = descendant.Material,
						Color = descendant.Color,
						Transparency = descendant.Transparency,
					}
					descendant.Material = Enum.Material.SmoothPlastic
					descendant.Color = Color3.fromRGB(31, 33, 36)
					descendant.Transparency = math.max(descendant.Transparency, 0.45)
				end
			end
		end
		Lighting.Brightness = 0.45
		Lighting.ExposureCompensation = -0.62
		Lighting.Ambient = Color3.fromRGB(24, 27, 34)
		Lighting.OutdoorAmbient = Color3.fromRGB(35, 39, 48)
		workspace:SetAttribute("Blackout", true)
		notificationRemote:FireAllClients("CITYWIDE BLACKOUT! Streetlights and powered signs are offline for 90 seconds.", Color3.fromRGB(151, 173, 255))
		return
	end

	local state = blackoutState
	if not state.Active then
		return
	end
	for light, wasEnabled in pairs(state.Lights) do
		if light.Parent then
			light.Enabled = wasEnabled
		end
	end
	for part, original in pairs(state.NeonParts) do
		if part.Parent then
			part.Material = original.Material
			part.Color = original.Color
			part.Transparency = original.Transparency
		end
	end
	Lighting.Brightness = state.Lighting.Brightness
	Lighting.ExposureCompensation = state.Lighting.ExposureCompensation
	Lighting.Ambient = state.Lighting.Ambient
	Lighting.OutdoorAmbient = state.Lighting.OutdoorAmbient
	blackoutState = {Active = false}
	workspace:SetAttribute("Blackout", false)
	notificationRemote:FireAllClients("Power restored across the district.", Color3.fromRGB(110, 232, 154))
end

adminBridge.Event:Connect(function(action, argument)
	if action == "SpawnSupply" then
		spawnSupplyDrop()
	elseif action == "SpawnArmored" then
		spawnArmoredTruck()
	elseif action == "Blackout" then
		setBlackout(argument == true)
	elseif action == "SetTime" and type(argument) == "number" then
		Lighting.ClockTime = argument % 24
	elseif action == "SetWeather" and setWeather and type(argument) == "string" then
		setWeather(argument)
	elseif action == "RebuildTools" and typeof(argument) == "Instance" and argument:IsA("Player") and argument.Parent == Players then
		rebuildTools(argument)
	elseif action == "RespawnCivilians" and respawnAllCivilians then
		respawnAllCivilians()
	elseif action == "ResetDailyContract" and typeof(argument) == "Instance" and argument:IsA("Player") and argument.Parent == Players then
		assignDailyContract(argument)
		notify(argument, "ADMIN: Your daily contract progress was reset.", Color3.fromRGB(255, 205, 91))
	elseif action == "VehicleAdmin" and type(argument) == "table" then
		local target = argument.Player
		local mode = argument.Mode
		if typeof(target) ~= "Instance" or not target:IsA("Player") or target.Parent ~= Players then
			return
		end
		if mode == "grant" then
			target:SetAttribute("OwnsRustCompact", true)
			target:SetAttribute("VehicleFuel", VEHICLE_MAX_FUEL)
			target:SetAttribute("VehicleCondition", VEHICLE_MAX_CONDITION)
		elseif mode == "revoke" then
			storeActiveVehicle(target, true)
			target:SetAttribute("OwnsRustCompact", false)
		elseif mode == "refuel" then
			target:SetAttribute("VehicleFuel", VEHICLE_MAX_FUEL)
			local vehicle = activeVehicles[target]
			if vehicle and vehicle.Parent then
				vehicle:SetAttribute("Fuel", VEHICLE_MAX_FUEL)
				vehicle:SetAttribute("VehicleDisabled", (vehicle:GetAttribute("Condition") or 0) <= 0)
			end
		elseif mode == "repair" then
			target:SetAttribute("VehicleCondition", VEHICLE_MAX_CONDITION)
			local vehicle = activeVehicles[target]
			if vehicle and vehicle.Parent then
				vehicle:SetAttribute("Condition", VEHICLE_MAX_CONDITION)
				vehicle:SetAttribute("VehicleDisabled", (vehicle:GetAttribute("Fuel") or 0) <= 0)
			end
		elseif mode == "despawn" then
			storeActiveVehicle(target, true)
		else
			return
		end
		notify(target, "ADMIN: Vehicle action " .. mode .. " applied.", Color3.fromRGB(255, 205, 91))
		task.spawn(savePlayer, target)
	end
end)

local function getWorldPhase(hour)
	if hour >= 5 and hour < 8 then
		return "DAWN"
	elseif hour >= 8 and hour < 18 then
		return "DAY"
	elseif hour >= 18 and hour < 20 then
		return "DUSK"
	end
	return "NIGHT"
end

local streetLightObjects = {}
local function updateStreetLights(phase)
	if blackoutState.Active then
		return
	end
	if #streetLightObjects == 0 then
		for _, descendant in ipairs(map:GetDescendants()) do
			if descendant:IsA("PointLight") and descendant.Parent and descendant.Parent.Name == "Lamp" then
				table.insert(streetLightObjects, descendant)
			end
		end
	end
	local powered = phase == "DUSK" or phase == "NIGHT"
	for _, light in ipairs(streetLightObjects) do
		local lamp = light.Parent
		if lamp then
			light.Enabled = powered
			lamp.Material = powered and Enum.Material.Neon or Enum.Material.SmoothPlastic
			lamp.Transparency = powered and 0 or 0.18
		end
	end
end

setWeather = function(state, silent)
	state = string.upper(state or "")
	if not table.find(WEATHER_STATES, state) then
		return false
	end
	currentWeather = state
	local atmosphere = Lighting:FindFirstChild("Ohio2Atmosphere")
	local clouds = workspace.Terrain:FindFirstChild("Ohio2Clouds")
	local colorCorrection = Lighting:FindFirstChild("Ohio2Color")
	if atmosphere then
		atmosphere.Density = state == "RAIN" and 0.48 or (state == "OVERCAST" and 0.39 or 0.32)
		atmosphere.Haze = state == "RAIN" and 2.7 or (state == "OVERCAST" and 2.1 or 1.5)
		atmosphere.Color = state == "CLEAR" and Color3.fromRGB(205, 211, 222) or Color3.fromRGB(178, 188, 198)
		atmosphere.Decay = state == "RAIN" and Color3.fromRGB(72, 84, 98) or Color3.fromRGB(103, 92, 80)
	end
	if clouds then
		clouds.Cover = state == "RAIN" and 0.88 or (state == "OVERCAST" and 0.68 or 0.36)
		clouds.Density = state == "RAIN" and 0.72 or (state == "OVERCAST" and 0.48 or 0.28)
		clouds.Color = state == "RAIN" and Color3.fromRGB(157, 166, 174) or Color3.fromRGB(226, 225, 218)
	end
	if colorCorrection then
		colorCorrection.Saturation = state == "RAIN" and -0.2 or (state == "OVERCAST" and -0.12 or -0.06)
		colorCorrection.Contrast = state == "RAIN" and 0.05 or 0.03
	end
	workspace:SetAttribute("Weather", state)
	if not silent then
		local message = state == "RAIN" and "Rain is moving across the district. Visibility is reduced." or (state == "OVERCAST" and "Heavy clouds are settling over the district." or "The weather has cleared.")
		notificationRemote:FireAllClients(message, state == "RAIN" and Color3.fromRGB(145, 180, 221) or Color3.fromRGB(210, 215, 220))
	end
	return true
end

local function findHumanoidFromPart(part)
	local ancestor = part
	while ancestor and ancestor ~= workspace do
		if ancestor:IsA("Model") then
			local humanoid = ancestor:FindFirstChildOfClass("Humanoid")
			if humanoid then
				return humanoid, ancestor
			end
		end
		ancestor = ancestor.Parent
	end
	return nil, nil
end

local function isFiniteVector3(value)
	return typeof(value) == "Vector3"
		and value.X == value.X and value.Y == value.Y and value.Z == value.Z
		and math.abs(value.X) < 100000 and math.abs(value.Y) < 100000 and math.abs(value.Z) < 100000
end

local function markViolence(player, victimModel)
	local victimPlayer = Players:GetPlayerFromCharacter(victimModel)
	if victimPlayer and victimPlayer ~= player then
		changeHeat(player, 1)
		return
	end
	if not victimModel or victimModel.Parent ~= npcFolder then
		return
	end
	local isCivilian = victimModel:GetAttribute("Ohio2Civilian") == true
	local isOfficer = string.sub(victimModel.Name, 1, 8) == "Officer_"
	if not isCivilian and not isOfficer then
		return
	end
	npcCrimeCooldowns[player] = npcCrimeCooldowns[player] or {}
	local readyAt = npcCrimeCooldowns[player][victimModel] or 0
	if os.clock() < readyAt then
		return
	end
	npcCrimeCooldowns[player][victimModel] = os.clock() + 20
	changeHeat(player, 2)
	changeBounty(player, isCivilian and 350 or 250)
	notify(player, isCivilian and "Civilian assaulted • +2 heat • +$350 bounty" or "Officer assaulted • +2 heat • +$250 bounty", Color3.fromRGB(255, 104, 104))
end

local function getEquippedDefinition(player)
	local character = player.Character
	local tool = character and character:FindFirstChildOfClass("Tool")
	local itemId = tool and tool:GetAttribute("Ohio2Item")
	return itemId, itemId and itemDefinitions[itemId] or nil
end

stateActionRemote.OnServerEvent:Connect(function(player, action)
	if action == "SprintEnd" then
		sprintStates[player] = nil
		player:SetAttribute("Sprinting", false)
		return
	elseif action == "BlockEnd" then
		blockStates[player] = nil
		player:SetAttribute("Blocking", false)
		return
	end
	if not player:GetAttribute("DataLoaded") or player:GetAttribute("Downed") or arrestStates[player] then
		return
	end
	if action == "VehicleHorn" then
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local seat = humanoid and humanoid.SeatPart
		local vehicle = seat and seat:FindFirstAncestorOfClass("Model")
		local chassis = vehicle and vehicle:FindFirstChild("Chassis")
		if not seat or not seat:IsA("VehicleSeat") or seat.Name ~= "DriverSeat" or not chassis or not vehicle:FindFirstChild("VehicleController") then
			return
		end
		local readyAt = vehicleHornCooldowns[player] or 0
		if os.clock() < readyAt then
			return
		end
		vehicleHornCooldowns[player] = os.clock() + 1.1
		playConfiguredWorldSound("VehicleHorn", chassis)
		return
	elseif action == "SprintStart" then
		if (player:GetAttribute("Stamina") or 0) > 0 and not blockStates[player] then
			sprintStates[player] = true
		end
	elseif action == "BlockStart" then
		local _, item = getEquippedDefinition(player)
		if item and item.Kind == "Melee" then
			blockStates[player] = true
			sprintStates[player] = nil
			player:SetAttribute("Sprinting", false)
		end
	end
end)

weaponActionRemote.OnServerEvent:Connect(function(player, action, cameraOrigin, aimDirection)
	if not player:GetAttribute("DataLoaded") or player:GetAttribute("Downed") or arrestStates[player] then
		return
	end
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local head = character and character:FindFirstChild("Head")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local tool = character and character:FindFirstChildOfClass("Tool")
	local itemId = tool and tool:GetAttribute("Ohio2Item")
	local item = itemId and itemDefinitions[itemId]
	if not root or not head or not humanoid or humanoid.Health <= 0 or not item or (not item.Permanent and getItemCount(player, "Inventory", itemId) <= 0) then
		return
	end
	if item.Kind == "Utility" then
		return
	end

	if action == "Reload" then
		if item.Kind ~= "Gun" or reloadStates[player] then
			return
		end
		local magazine = getMagazine(player, itemId)
		local reserve = getItemCount(player, "Inventory", item.AmmoItem)
		if magazine >= item.MagazineSize then
			notify(player, "Your " .. item.DisplayName .. " is already loaded.", Color3.fromRGB(255, 196, 82))
			return
		end
		if reserve <= 0 then
			notify(player, "You are out of " .. itemDefinitions[item.AmmoItem].DisplayName .. ".", Color3.fromRGB(255, 104, 104))
			weaponFeedbackRemote:FireClient(player, "Empty", itemId)
			return
		end

		reloadStates[player] = itemId
		weaponFeedbackRemote:FireClient(player, "Reloading", itemId, item.ReloadTime)
		task.delay(item.ReloadTime, function()
			if not player.Parent or reloadStates[player] ~= itemId or player:GetAttribute("Downed") or getItemCount(player, "Inventory", itemId) <= 0 then
				if reloadStates[player] == itemId then
					reloadStates[player] = nil
				end
				return
			end
			local currentMagazine = getMagazine(player, itemId)
			local currentReserve = getItemCount(player, "Inventory", item.AmmoItem)
			local loaded = math.min(item.MagazineSize - currentMagazine, currentReserve)
			setMagazine(player, itemId, currentMagazine + loaded)
			setItemCount(player, "Inventory", item.AmmoItem, currentReserve - loaded)
			reloadStates[player] = nil
			weaponFeedbackRemote:FireClient(player, "Reloaded", itemId)
		end)
		return
	elseif action ~= "Activate" then
		return
	end
	if player:GetAttribute("SpawnProtected") then
		removeSpawnProtection(player)
	end
	if blockStates[player] then
		blockStates[player] = nil
		player:SetAttribute("Blocking", false)
	end

	weaponCooldowns[player] = weaponCooldowns[player] or {}
	local readyAt = weaponCooldowns[player][itemId] or 0
	if os.clock() < readyAt then
		return
	end
	weaponCooldowns[player][itemId] = os.clock() + item.Cooldown

	if item.Kind == "Gun" then
		if reloadStates[player] then
			return
		end
		if not isFiniteVector3(cameraOrigin) or not isFiniteVector3(aimDirection) then
			return
		end
		if (cameraOrigin - head.Position).Magnitude > 20 or aimDirection.Magnitude < 0.9 or aimDirection.Magnitude > 1.1 then
			return
		end
		aimDirection = aimDirection.Unit
		local magazine = getMagazine(player, itemId)
		if magazine <= 0 then
			weaponFeedbackRemote:FireClient(player, "Empty", itemId)
			notify(player, "Magazine empty — press R or tap RELOAD.", Color3.fromRGB(255, 196, 82))
			return
		end
		setMagazine(player, itemId, magazine - 1)
		weaponFeedbackRemote:FireClient(player, "Shot", itemId, item.Recoil)

		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {character}
		params.IgnoreWater = true
		local aimResult = workspace:Raycast(cameraOrigin, aimDirection * item.Range, params)
		local aimPoint = aimResult and aimResult.Position or (cameraOrigin + aimDirection * item.Range)
		local rayOrigin = head.Position
		local offset = aimPoint - rayOrigin
		local baseDirection = offset.Magnitude >= 1 and offset.Unit or aimDirection
		local maxDistance = item.Range
		local muzzle = tool:FindFirstChild("Muzzle")
		local visualOrigin = muzzle and muzzle:IsA("BasePart") and muzzle.Position or rayOrigin
		playConfiguredWorldSound(itemId == "Shotgun" and "ShotgunShot" or "PistolShot", muzzle and muzzle:IsA("BasePart") and muzzle or head)
		local random = Random.new()
		local hits = {}
		for pelletIndex = 1, item.Pellets do
			local direction = baseDirection
			if item.Spread > 0 then
				local referenceUp = math.abs(baseDirection.Y) > 0.95 and Vector3.new(1, 0, 0) or Vector3.new(0, 1, 0)
				local right = baseDirection:Cross(referenceUp).Unit
				local up = right:Cross(baseDirection).Unit
				direction = (baseDirection + right * random:NextNumber(-item.Spread, item.Spread) + up * random:NextNumber(-item.Spread, item.Spread)).Unit
			end
			local result = workspace:Raycast(rayOrigin, direction * maxDistance, params)
			local hitPosition = result and result.Position or (rayOrigin + direction * maxDistance)
			local materialName = result and result.Material.Name or "Air"
			local playImpact = result ~= nil and (item.Pellets == 1 or pelletIndex <= 2)
			weaponFXRemote:FireAllClients(visualOrigin, hitPosition, itemId, pelletIndex == 1, result and result.Normal or Vector3.zero, materialName, playImpact)
			if result then
				local targetHumanoid, targetModel = findHumanoidFromPart(result.Instance)
				if targetHumanoid and targetHumanoid ~= humanoid and targetHumanoid.Health > 0 then
					local hit = hits[targetHumanoid] or {Damage = 0, Model = targetModel, Headshot = false}
					local isHeadshot = result.Instance.Name == "Head"
					hit.Damage = hit.Damage + math.floor(item.Damage * (isHeadshot and item.HeadshotMultiplier or 1))
					hit.Headshot = hit.Headshot or isHeadshot
					hits[targetHumanoid] = hit
				end
			end
		end
		local bestFeedback
		for targetHumanoid, hit in pairs(hits) do
			local resultType = applyCombatDamage(player, targetHumanoid, hit.Damage, "Gun")
			if resultType ~= "Protected" then
				markViolence(player, hit.Model)
			end
			if resultType == "Downed" then
				bestFeedback = "Downed"
			elseif resultType == "Protected" and not bestFeedback then
				bestFeedback = "Protected"
			elseif hit.Headshot and bestFeedback ~= "Downed" then
				bestFeedback = "Headshot"
			elseif not bestFeedback then
				bestFeedback = "Hit"
			end
		end
		if bestFeedback then
			weaponFeedbackRemote:FireClient(player, bestFeedback, itemId)
		end
	elseif item.Kind == "Melee" then
		local damage = item.Damage
		local comboNumber
		if itemId == "Fists" then
			local combo = comboStates[player] or {Count = 0, LastAt = 0}
			if os.clock() - combo.LastAt > item.ComboReset then
				combo.Count = 0
			end
			combo.Count = combo.Count % #item.ComboDamage + 1
			combo.LastAt = os.clock()
			comboStates[player] = combo
			comboNumber = combo.Count
			damage = item.ComboDamage[comboNumber]
			weaponFeedbackRemote:FireClient(player, "Punch", itemId, comboNumber)
		else
			weaponFeedbackRemote:FireClient(player, "MeleeSwing", itemId)
		end
		local params = OverlapParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {character}
		local center = root.Position + root.CFrame.LookVector * 3
		local alreadyChecked = {}
		for _, part in ipairs(workspace:GetPartBoundsInRadius(center, 4, params)) do
			local targetHumanoid, targetModel = findHumanoidFromPart(part)
			local targetRoot = targetModel and targetModel:FindFirstChild("HumanoidRootPart")
			local closeEnough = targetRoot and (targetRoot.Position - root.Position).Magnitude <= (item.Range or 5) + 0.75
			if targetHumanoid and targetHumanoid ~= humanoid and targetHumanoid.Health > 0 and closeEnough and not alreadyChecked[targetHumanoid] then
				alreadyChecked[targetHumanoid] = true
				local resultType = applyCombatDamage(player, targetHumanoid, damage, "Melee")
				if resultType ~= "Protected" then
					markViolence(player, targetModel)
				end
				if comboNumber == 3 and resultType ~= "Blocked" and resultType ~= "Protected" then
					targetRoot.AssemblyLinearVelocity = targetRoot.AssemblyLinearVelocity + root.CFrame.LookVector * item.HeavyKnockback + Vector3.new(0, 7, 0)
				end
				weaponFeedbackRemote:FireClient(player, resultType, itemId)
				break
			end
		end
	elseif item.Kind == "Consumable" then
		if humanoid.Health >= humanoid.MaxHealth then
			notify(player, "You are already at full health.", Color3.fromRGB(255, 196, 82))
			return
		end
		humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + item.Heal)
		setItemCount(player, "Inventory", itemId, getItemCount(player, "Inventory", itemId) - 1)
		rebuildTools(player)
		notify(player, "+" .. item.Heal .. " health", Color3.fromRGB(110, 232, 154))
	end
end)

local function findWantedTarget(position)
	local bestPlayer
	local bestDistance = 800
	for _, player in ipairs(Players:GetPlayers()) do
		if (player:GetAttribute("Heat") or 0) > 0 then
			local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
			if root and humanoid and humanoid.Health > 0 then
				local distance = (root.Position - position).Magnitude
				if distance < bestDistance then
					bestPlayer = player
					bestDistance = distance
				end
			end
		end
	end
	return bestPlayer, bestDistance
end

local function arrestPlayer(player)
	if arrestStates[player] then
		return
	end
	arrestStates[player] = true
	local fine = math.floor((player:GetAttribute("Cash") or 0) * 0.15)
	local clearedBounty = player:GetAttribute("Bounty") or 0
	changeCash(player, -fine)
	player:SetAttribute("Heat", 0)
	player:SetAttribute("Bounty", 0)
	player:SetAttribute("LastAttackerUserId", 0)
	player:SetAttribute("LastAttackAt", 0)
	activeJobs[player] = nil
	reloadStates[player] = nil
	resetActionStates(player)
	clearDowned(player, 60)

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local jailSpawn = map:FindFirstChild("JailSpawn")
	if root and humanoid and jailSpawn then
		root.CFrame = jailSpawn.CFrame + Vector3.new(0, 3, 0)
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
		humanoid.JumpHeight = 0
	end
	setObjective(player, "ARRESTED: You will be released from County Police in 6 seconds.")
	notify(player, "Police seized $" .. fine .. " and cleared your $" .. clearedBounty .. " bounty. Carried gear remains yours.", Color3.fromRGB(105, 169, 255))
	task.delay(6, function()
		if not player.Parent then
			return
		end
		arrestStates[player] = nil
		local currentHumanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if currentHumanoid and currentHumanoid.Health > 0 then
			currentHumanoid.WalkSpeed = 16
			currentHumanoid.JumpPower = 50
			currentHumanoid.JumpHeight = 7.2
			currentHumanoid.AutoRotate = true
		end
		setObjective(player, "Released: Find work, rebuild, or plan your next robbery.")
		notify(player, "Released from County Police.", Color3.fromRGB(110, 232, 154))
	end)
end

spawnOfficer = function(index)
	local existing = officerSlots[index]
	if existing and existing.Parent and existing:FindFirstChildOfClass("Humanoid") and existing:FindFirstChildOfClass("Humanoid").Health > 0 then
		return existing
	end
	if os.clock() < (officerRespawnAt[index] or 0) then
		return nil
	end
	local officer = policeTemplate:Clone()
	officer.Name = "Officer_" .. index
	officer:SetAttribute("Ohio2Police", true)
	officer:SetAttribute("ResponseUnit", index > POLICE_BASE_OFFICERS)
	officer.Parent = npcFolder
	officerSlots[index] = officer
	local spawnPart = map:FindFirstChild("PoliceResponseSpawn" .. index) or map:FindFirstChild("PoliceSpawn" .. index) or map:FindFirstChild("PoliceSpawn1")
	officer:PivotTo(spawnPart.CFrame + Vector3.new(0, 3, 0))
	local humanoid = officer:FindFirstChildOfClass("Humanoid")
	local root = officer:FindFirstChild("HumanoidRootPart")
	local lastHit = 0
	local lastShot = 0
	local lastPathAt = 0
	local cachedMovePosition
	pcall(function()
		root:SetNetworkOwner(nil)
	end)

	humanoid.Died:Connect(function()
		if officerSlots[index] == officer then
			officerSlots[index] = nil
			officerRespawnAt[index] = os.clock() + 10
		end
		Debris:AddItem(officer, 4)
	end)

	task.spawn(function()
		while officer.Parent and humanoid.Health > 0 do
			if root.Position.Y < -20 then
				officer:PivotTo(spawnPart.CFrame + Vector3.new(0, 3, 0))
			end
			local target, distance = findWantedTarget(root.Position)
			if target then
				local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
				local targetHumanoid = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
				if targetRoot and targetHumanoid then
					if distance < 90 then
						target:SetAttribute("LastPoliceContact", os.clock())
					end
					local movePosition = cachedMovePosition or targetRoot.Position
					if os.clock() - lastPathAt > 1.25 then
						lastPathAt = os.clock()
						movePosition = targetRoot.Position
						local success, path = pcall(function()
							local computed = PathfindingService:CreatePath({AgentRadius = 2, AgentHeight = 5, AgentCanJump = true})
							computed:ComputeAsync(root.Position, targetRoot.Position)
							return computed
						end)
						if success and path.Status == Enum.PathStatus.Success then
							local waypoints = path:GetWaypoints()
							if waypoints[2] then
								movePosition = waypoints[2].Position
								if waypoints[2].Action == Enum.PathWaypointAction.Jump then
									humanoid.Jump = true
								end
							end
						end
						cachedMovePosition = movePosition
					end
					humanoid:MoveTo(movePosition)
					if distance < 6 and target:GetAttribute("Downed") then
						arrestPlayer(target)
					elseif distance < 5 and os.clock() - lastHit > 1.2 then
						lastHit = os.clock()
						applyCombatDamage(nil, targetHumanoid, 10, "Police")
						notify(target, "Police struck you for 10 damage!", Color3.fromRGB(110, 165, 255))
					elseif (target:GetAttribute("Heat") or 0) >= POLICE_RANGED_MIN_HEAT and distance >= 8 and distance <= 65 and os.clock() - lastShot > 1.65 then
						local origin = root.Position + Vector3.new(0, 1.8, 0)
						local direction = targetRoot.Position + Vector3.new(0, 1.2, 0) - origin
						local params = RaycastParams.new()
						params.FilterType = Enum.RaycastFilterType.Exclude
						params.FilterDescendantsInstances = {officer}
						params.IgnoreWater = true
						local result = workspace:Raycast(origin, direction, params)
						if result and result.Instance:IsDescendantOf(target.Character) then
							lastShot = os.clock()
							playConfiguredWorldSound("PistolShot", root, 0.78, 1.04)
							weaponFXRemote:FireAllClients(origin, result.Position, "Pistol", true, result.Normal, result.Material.Name, true)
							applyCombatDamage(nil, targetHumanoid, 8, "Police")
							notify(target, "Police gunfire hit you for 8 damage!", Color3.fromRGB(110, 165, 255))
						end
					end
				end
			else
				local angle = os.clock() * 0.25 + index * math.pi
				humanoid:MoveTo(spawnPart.Position + Vector3.new(math.cos(angle) * 18, 0, math.sin(angle) * 18))
			end
			task.wait(0.45)
		end
	end)
	return officer
end

local function updatePoliceResponse()
	local highestHeat = 0
	for _, player in ipairs(Players:GetPlayers()) do
		highestHeat = math.max(highestHeat, player:GetAttribute("Heat") or 0)
	end
	local desired = math.clamp(POLICE_BASE_OFFICERS + highestHeat, POLICE_BASE_OFFICERS, POLICE_MAX_OFFICERS)
	local response = highestHeat <= 0 and "PATROL" or (highestHeat <= 2 and "SEARCH" or (highestHeat <= 4 and "ARMED RESPONSE" or "MAXIMUM RESPONSE"))
	for index = 1, desired do
		spawnOfficer(index)
	end
	for index = desired + 1, POLICE_MAX_OFFICERS do
		local officer = officerSlots[index]
		if officer and officer.Parent then
			officerSlots[index] = nil
			officer:Destroy()
		end
	end
	local active = 0
	for index = 1, POLICE_MAX_OFFICERS do
		local officer = officerSlots[index]
		local humanoid = officer and officer.Parent and officer:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then
			active = active + 1
		end
	end
	workspace:SetAttribute("PoliceResponse", response)
	workspace:SetAttribute("ActiveOfficerCount", active)
end

local CIVILIAN_ROUTES = {
	{
		Vector3.new(-410, 0.5, 28), Vector3.new(-245, 0.5, 28), Vector3.new(-80, 0.5, 28),
		Vector3.new(80, 0.5, 28), Vector3.new(245, 0.5, 28), Vector3.new(410, 0.5, 28),
	},
	{
		Vector3.new(410, 0.5, -28), Vector3.new(245, 0.5, -28), Vector3.new(80, 0.5, -28),
		Vector3.new(-80, 0.5, -28), Vector3.new(-245, 0.5, -28), Vector3.new(-410, 0.5, -28),
	},
	{
		Vector3.new(-410, 0.5, -212), Vector3.new(-220, 0.5, -212), Vector3.new(0, 0.5, -212),
		Vector3.new(220, 0.5, -212), Vector3.new(410, 0.5, -212),
	},
	{
		Vector3.new(410, 0.5, 268), Vector3.new(220, 0.5, 268), Vector3.new(0, 0.5, 268),
		Vector3.new(-220, 0.5, 268), Vector3.new(-410, 0.5, 268),
	},
	{
		Vector3.new(-278, 0.5, -410), Vector3.new(-278, 0.5, -205), Vector3.new(-278, 0.5, 0),
		Vector3.new(-278, 0.5, 205), Vector3.new(-278, 0.5, 410),
	},
	{
		Vector3.new(328, 0.5, 410), Vector3.new(328, 0.5, 205), Vector3.new(328, 0.5, 0),
		Vector3.new(328, 0.5, -205), Vector3.new(328, 0.5, -410),
	},
}

local civilianTemplateList = civilianTemplates:GetChildren()

local function updateCivilianCount()
	local count = 0
	for _, model in ipairs(npcFolder:GetChildren()) do
		local humanoid = model:GetAttribute("Ohio2Civilian") and model:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then
			count = count + 1
		end
	end
	workspace:SetAttribute("CivilianCount", count)
end

local function spawnCivilian(index)
	if #civilianTemplateList == 0 or not npcFolder.Parent then
		return
	end
	local existing = npcFolder:FindFirstChild("Civilian_" .. index)
	if existing then
		existing:Destroy()
	end
	local route = CIVILIAN_ROUTES[(index - 1) % #CIVILIAN_ROUTES + 1]
	local routeIndex = (index - 1) % #route + 1
	local template = civilianTemplateList[(index - 1) % #civilianTemplateList + 1]
	local civilian = template:Clone()
	civilian.Name = "Civilian_" .. index
	civilian:SetAttribute("Ohio2Civilian", true)
	civilian.Parent = npcFolder
	civilian:PivotTo(CFrame.new(route[routeIndex] + Vector3.new(0, 3, 0)))
	local humanoid = civilian:FindFirstChildOfClass("Humanoid")
	local root = civilian:FindFirstChild("HumanoidRootPart")
	pcall(function() root:SetNetworkOwner(nil) end)
	updateCivilianCount()

	humanoid.Died:Connect(function()
		updateCivilianCount()
		Debris:AddItem(civilian, 5)
		task.delay(15, function()
			if npcFolder.Parent then
				spawnCivilian(index)
			end
		end)
	end)

	task.spawn(function()
		task.wait(math.random() * 2)
		while civilian.Parent and humanoid.Health > 0 do
			if root.Position.Y < -20 then
				civilian:PivotTo(CFrame.new(route[routeIndex] + Vector3.new(0, 3, 0)))
			end
			local wantedPlayer, wantedDistance = findWantedTarget(root.Position)
			local wantedRoot = wantedPlayer and wantedPlayer.Character and wantedPlayer.Character:FindFirstChild("HumanoidRootPart")
			if wantedRoot and wantedDistance < 38 then
				local away = root.Position - wantedRoot.Position
				if away.Magnitude < 1 then away = Vector3.new(1, 0, 0) end
				humanoid.WalkSpeed = 16
				humanoid:MoveTo(root.Position + away.Unit * 32)
				task.wait(2.25)
			else
				humanoid.WalkSpeed = 10
				routeIndex = routeIndex % #route + 1
				humanoid:MoveTo(route[routeIndex])
				task.wait(6 + math.random() * 3)
			end
		end
	end)
end

respawnAllCivilians = function()
	for _, model in ipairs(npcFolder:GetChildren()) do
		if model:GetAttribute("Ohio2Civilian") then
			model:Destroy()
		end
	end
	for index = 1, 10 do
		spawnCivilian(index)
	end
	updateCivilianCount()
end

ProximityPromptService.PromptTriggered:Connect(handlePrompt)

phoneActionRemote.OnServerEvent:Connect(function(player, action)
	if action ~= "ClaimDailyContract" or not player:GetAttribute("DataLoaded") then
		return
	end
	local state = dailyContracts[player]
	if not state or state.DayKey ~= dailyDayKey() then
		state = assignDailyContract(player)
	end
	local definition = getDailyDefinition(state.ContractId)
	if state.Claimed then
		notify(player, "That daily contract reward was already claimed.", Color3.fromRGB(255, 196, 82))
		return
	end
	if state.Progress < definition.Goal then
		notify(player, "Daily contract incomplete: " .. state.Progress .. "/" .. definition.Goal .. ".", Color3.fromRGB(255, 196, 82))
		return
	end
	state.Claimed = true
	changeBank(player, definition.Reward)
	syncDailyContract(player, state)
	notify(player, "+$" .. definition.Reward .. " daily contract reward deposited into your bank.", Color3.fromRGB(110, 232, 154))
	task.spawn(savePlayer, player)
end)

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player)
	storeActiveVehicle(player, true)
	savePlayer(player)
	activeJobs[player] = nil
	weaponCooldowns[player] = nil
	reloadStates[player] = nil
	comboStates[player] = nil
	sprintStates[player] = nil
	blockStates[player] = nil
	downedStates[player] = nil
	arrestStates[player] = nil
	dataWarnings[player] = nil
	npcCrimeCooldowns[player] = nil
	storeRobberies[player] = nil
	dailyContracts[player] = nil
	activeVehicles[player] = nil
	vehicleHornCooldowns[player] = nil
end)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(setupPlayer, player)
end

task.spawn(function()
	while true do
		task.wait(0.1)
		for _, player in ipairs(Players:GetPlayers()) do
			local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				if arrestStates[player] then
					player:SetAttribute("BalloonEquipped", false)
					humanoid.WalkSpeed = 0
					humanoid.JumpPower = 0
					humanoid.JumpHeight = 0
				elseif player:GetAttribute("Downed") then
					player:SetAttribute("BalloonEquipped", false)
					humanoid.WalkSpeed = 4
				else
					local equippedItemId, equippedItem = getEquippedDefinition(player)
					local balloonEquipped = equippedItemId == "Balloon" and getItemCount(player, "Inventory", "Balloon") > 0
					if player:GetAttribute("BalloonEquipped") ~= balloonEquipped then
						player:SetAttribute("BalloonEquipped", balloonEquipped)
					end
					local blocking = blockStates[player] and equippedItem and equippedItem.Kind == "Melee"
					if not blocking and blockStates[player] then
						blockStates[player] = nil
					end
					local stamina = player:GetAttribute("Stamina") or MAX_STAMINA
					local sprinting = sprintStates[player] and not blocking and stamina > 0 and humanoid.MoveDirection.Magnitude > 0.05
					if sprinting then
						stamina = math.max(0, stamina - 2)
						if stamina <= 0 then
							sprintStates[player] = nil
							sprinting = false
						end
					else
						stamina = math.min(MAX_STAMINA, stamina + 1.35)
					end
					local roundedStamina = math.floor(stamina * 10 + 0.5) / 10
					if player:GetAttribute("Stamina") ~= roundedStamina then
						player:SetAttribute("Stamina", roundedStamina)
					end
					if player:GetAttribute("Blocking") ~= (blocking == true) then
						player:SetAttribute("Blocking", blocking == true)
					end
					if player:GetAttribute("Sprinting") ~= (sprinting == true) then
						player:SetAttribute("Sprinting", sprinting == true)
					end
					local adminWalkSpeed = tonumber(player:GetAttribute("AdminWalkSpeed"))
					local baseWalkSpeed = adminWalkSpeed and math.clamp(adminWalkSpeed, 8, 80) or WALK_SPEED
					humanoid.WalkSpeed = blocking and math.min(BLOCK_SPEED, baseWalkSpeed) or (sprinting and math.min(80, baseWalkSpeed + (SPRINT_SPEED - WALK_SPEED)) or baseWalkSpeed)
					local adminJumpPower = tonumber(player:GetAttribute("AdminJumpPower"))
					local balloonDefinition = itemDefinitions.Balloon
					local jumpPower = adminJumpPower and math.clamp(adminJumpPower, 20, 150) or (balloonEquipped and balloonDefinition.JumpPower or 50)
					local jumpHeight = adminJumpPower and math.max(7.2, jumpPower * 0.15) or (balloonEquipped and balloonDefinition.JumpHeight or 7.2)
					humanoid.UseJumpPower = true
					humanoid.JumpPower = jumpPower
					humanoid.JumpHeight = jumpHeight
				end
			end
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(25)
		for _, player in ipairs(Players:GetPlayers()) do
			local heat = player:GetAttribute("Heat") or 0
			if heat > 0 and os.clock() - (player:GetAttribute("LastPoliceContact") or 0) >= 18 then
				changeHeat(player, -1)
				if heat - 1 <= 0 then
					setObjective(player, "You lost the police. Bank or stash anything you want to protect.")
					notify(player, "You are no longer wanted.", Color3.fromRGB(110, 232, 154))
					progressDailyContract(player, "EscapeArtist", 1)
				end
			end
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(90)
		for _, player in ipairs(Players:GetPlayers()) do
			local state = dailyContracts[player]
			if state and state.DayKey ~= dailyDayKey() then
				assignDailyContract(player)
				notify(player, "A new daily contract is available on your phone.", Color3.fromRGB(107, 169, 255))
			end
			task.spawn(savePlayer, player)
		end
	end
end)

task.delay(2, function()
	updatePoliceResponse()
end)

task.spawn(function()
	while true do
		task.wait(2)
		updatePoliceResponse()
	end
end)

task.delay(3, function()
	respawnAllCivilians()
end)

task.spawn(function()
	task.wait(math.random(SUPPLY_FIRST_DELAY[1], SUPPLY_FIRST_DELAY[2]))
	while true do
		spawnSupplyDrop()
		task.wait(math.random(SUPPLY_REPEAT_DELAY[1], SUPPLY_REPEAT_DELAY[2]))
	end
end)

workspace:SetAttribute("Blackout", false)
workspace:SetAttribute("ArmoredTruckActive", false)
workspace:SetAttribute("QuickStopAlarm", false)
workspace:SetAttribute("PoliceResponse", "PATROL")
workspace:SetAttribute("ActiveOfficerCount", 0)
workspace:SetAttribute("WorldPhase", getWorldPhase(Lighting.ClockTime))
workspace:SetAttribute("CivilianCount", 0)
setWeather("CLEAR", true)

task.spawn(function()
	local lastPhase = getWorldPhase(Lighting.ClockTime)
	while true do
		task.wait(1)
		Lighting.ClockTime = (Lighting.ClockTime + 0.025) % 24
		local phase = getWorldPhase(Lighting.ClockTime)
		workspace:SetAttribute("WorldPhase", phase)
		updateStreetLights(phase)
		if phase ~= lastPhase then
			lastPhase = phase
			local messages = {
				DAWN = "Dawn is breaking over the district.",
				DAY = "Daylight has returned to the district.",
				DUSK = "Dusk is settling in. Streetlights are coming on.",
				NIGHT = "Night has fallen. Watch the alleys and outer districts.",
			}
			notificationRemote:FireAllClients(messages[phase], phase == "NIGHT" and Color3.fromRGB(151, 173, 255) or Color3.fromRGB(255, 205, 91))
		end
	end
end)

task.spawn(function()
	task.wait(math.random(ARMORED_FIRST_DELAY[1], ARMORED_FIRST_DELAY[2]))
	while true do
		spawnArmoredTruck()
		task.wait(math.random(ARMORED_REPEAT_DELAY[1], ARMORED_REPEAT_DELAY[2]))
	end
end)

task.spawn(function()
	task.wait(math.random(WEATHER_FIRST_DELAY[1], WEATHER_FIRST_DELAY[2]))
	local weatherIndex = 1
	while true do
		weatherIndex = weatherIndex % #WEATHER_STATES + 1
		setWeather(WEATHER_STATES[weatherIndex])
		task.wait(math.random(WEATHER_REPEAT_DELAY[1], WEATHER_REPEAT_DELAY[2]))
	end
end)

task.spawn(function()
	task.wait(math.random(BLACKOUT_FIRST_DELAY[1], BLACKOUT_FIRST_DELAY[2]))
	while true do
		setBlackout(true)
		task.wait(90)
		setBlackout(false)
		task.wait(math.random(BLACKOUT_REPEAT_DELAY[1], BLACKOUT_REPEAT_DELAY[2]))
	end
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		storeActiveVehicle(player, true)
		task.spawn(savePlayer, player)
	end
	task.wait(3)
end)

print("[Ohio2] Build 1.3 world pacing, replicated gunplay, and combat validation loaded")
]==]
serverMain.Parent = ServerScriptService

local adminServer = Instance.new("Script")
adminServer.Name = "Ohio2AdminServer"
adminServer.Source = [==[
-- Ohio 2 server-authoritative admin console.
-- Edit ServerStorage > Ohio2AdminConfig > AdminUserIds with comma-separated user IDs.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local project = ReplicatedStorage:WaitForChild("Ohio2")
local remotes = project:WaitForChild("Remotes")
local commandRemote = remotes:WaitForChild("AdminCommand")
local feedbackRemote = remotes:WaitForChild("AdminFeedback")
local notificationRemote = remotes:WaitForChild("Notification")
local itemDefinitions = require(project.Shared.ItemDefinitions)
local config = ServerStorage:WaitForChild("Ohio2AdminConfig")
local adminUserIdsValue = config:WaitForChild("AdminUserIds")
local creatorIsAdminValue = config:WaitForChild("CreatorIsAdmin")
local studioPlayersAreAdminValue = config:WaitForChild("StudioPlayersAreAdmin")
local adminBridge = ServerStorage:WaitForChild("Ohio2AdminBridge")

local adminUserIds = {}
local lastCommandAt = {}
local knownCommands = "help, heal, kill, respawn, cash, setcash, heat, bounty, give, goto, bring, speed, jump, freeze, unfreeze, announce, day, night, weather, blackout, event, civilians, contracts, vehicle, kick"

local function rebuildAdminIds()
	table.clear(adminUserIds)
	for token in string.gmatch(adminUserIdsValue.Value or "", "%d+") do
		local userId = tonumber(token)
		if userId and userId > 0 then
			adminUserIds[userId] = true
		end
	end
end

local function isAdmin(player)
	if adminUserIds[player.UserId] then
		return true
	end
	if creatorIsAdminValue.Value and game.CreatorType == Enum.CreatorType.User and game.CreatorId == player.UserId then
		return true
	end
	if studioPlayersAreAdminValue.Value and RunService:IsStudio() then
		return true
	end
	return false
end

local function refreshAdmin(player)
	player:SetAttribute("Ohio2Admin", isAdmin(player))
end

local function refreshAllAdmins()
	rebuildAdminIds()
	for _, player in ipairs(Players:GetPlayers()) do
		refreshAdmin(player)
	end
end

local function sendFeedback(player, success, message)
	if player.Parent then
		feedbackRemote:FireClient(player, success == true, tostring(message))
	end
end

local function splitWords(line)
	local words = {}
	for word in string.gmatch(line, "%S+") do
		table.insert(words, word)
	end
	return words
end

local function startsWith(text, query)
	return string.sub(string.lower(text), 1, #query) == query
end

local function resolveTargets(executor, selector, allowMany)
	local query = string.lower(selector or "")
	if query == "" then
		return nil, "Missing player target. Use me, all, others, a username, display name, or user ID."
	end
	if query == "me" then
		return {executor}
	elseif query == "all" then
		if not allowMany then
			return nil, "That command needs one player, not all."
		end
		return Players:GetPlayers()
	elseif query == "others" then
		if not allowMany then
			return nil, "That command needs one player, not others."
		end
		local others = {}
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= executor then
				table.insert(others, player)
			end
		end
		return others
	end

	local numericId = tonumber(query)
	local exactMatch
	local matches = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if numericId and player.UserId == numericId then
			exactMatch = player
			break
		end
		if string.lower(player.Name) == query or string.lower(player.DisplayName) == query then
			exactMatch = player
			break
		end
		if startsWith(player.Name, query) or startsWith(player.DisplayName, query) then
			table.insert(matches, player)
		end
	end
	if exactMatch then
		return {exactMatch}
	end
	if #matches == 0 then
		return nil, "No player matched '" .. selector .. "'."
	elseif #matches > 1 then
		return nil, "That player name is ambiguous. Type more of it."
	end
	return matches
end

local function targetSummary(targets)
	if #targets == 0 then
		return "nobody"
	elseif #targets == 1 then
		return targets[1].Name
	end
	return tostring(#targets) .. " players"
end

local function resolveMany(executor, selector)
	return resolveTargets(executor, selector, true)
end

local function getHumanoid(player)
	return player.Character and player.Character:FindFirstChildOfClass("Humanoid")
end

local function getRoot(player)
	return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end

local function readNumber(value, label, minimum, maximum)
	local number = tonumber(value)
	if not number then
		return nil, "Invalid " .. label .. "."
	end
	return math.clamp(math.floor(number), minimum, maximum)
end

local function setInventoryAmount(target, itemId, amount)
	local inventory = target:FindFirstChild("Inventory")
	if not inventory then
		return false
	end
	local value = inventory:FindFirstChild(itemId)
	if not value then
		value = Instance.new("IntValue")
		value.Name = itemId
		value.Parent = inventory
	end
	local item = itemDefinitions[itemId]
	local maximum = item.Kind == "Ammo" and 9999 or 25
	value.Value = math.clamp(value.Value + amount, 0, maximum)
	if value.Value <= 0 then
		value:Destroy()
	end
	if item.Kind == "Gun" then
		target:SetAttribute("Magazine_" .. itemId, item.MagazineSize)
	end
	adminBridge:Fire("RebuildTools", target)
	return true
end

local commands = {}

commands.help = function()
	return true, "Commands: " .. knownCommands .. ". Targets: me, all, others, name, display name, or user ID."
end
commands.cmds = commands.help

commands.heal = function(executor, args)
	local targets, problem = resolveMany(executor, args[1])
	if not targets then return false, problem end
	for _, target in ipairs(targets) do
		local humanoid = getHumanoid(target)
		if humanoid then humanoid.Health = humanoid.MaxHealth end
	end
	return true, "Healed " .. targetSummary(targets) .. "."
end

commands.kill = function(executor, args)
	local targets, problem = resolveMany(executor, args[1])
	if not targets then return false, problem end
	for _, target in ipairs(targets) do
		local humanoid = getHumanoid(target)
		if humanoid then humanoid.Health = 0 end
	end
	return true, "Eliminated " .. targetSummary(targets) .. "."
end

commands.respawn = function(executor, args)
	local targets, problem = resolveMany(executor, args[1])
	if not targets then return false, problem end
	for _, target in ipairs(targets) do target:LoadCharacter() end
	return true, "Respawned " .. targetSummary(targets) .. "."
end

commands.cash = function(executor, args)
	local targets, problem = resolveMany(executor, args[1])
	if not targets then return false, problem end
	local amount, amountProblem = readNumber(args[2], "cash amount", -1000000, 1000000)
	if not amount then return false, amountProblem end
	for _, target in ipairs(targets) do
		target:SetAttribute("Cash", math.clamp((target:GetAttribute("Cash") or 0) + amount, 0, 100000000))
	end
	return true, "Changed cash by $" .. amount .. " for " .. targetSummary(targets) .. "."
end

commands.setcash = function(executor, args)
	local targets, problem = resolveMany(executor, args[1])
	if not targets then return false, problem end
	local amount, amountProblem = readNumber(args[2], "cash amount", 0, 100000000)
	if not amount then return false, amountProblem end
	for _, target in ipairs(targets) do target:SetAttribute("Cash", amount) end
	return true, "Set " .. targetSummary(targets) .. " to $" .. amount .. "."
end

commands.heat = function(executor, args)
	local targets, problem = resolveMany(executor, args[1])
	if not targets then return false, problem end
	local amount, amountProblem = readNumber(args[2], "heat level", 0, 5)
	if not amount then return false, amountProblem end
	for _, target in ipairs(targets) do target:SetAttribute("Heat", amount) end
	return true, "Set heat to " .. amount .. " for " .. targetSummary(targets) .. "."
end

commands.bounty = function(executor, args)
	local targets, problem = resolveMany(executor, args[1])
	if not targets then return false, problem end
	local amount, amountProblem = readNumber(args[2], "bounty", 0, 10000000)
	if not amount then return false, amountProblem end
	for _, target in ipairs(targets) do target:SetAttribute("Bounty", amount) end
	return true, "Set bounty to $" .. amount .. " for " .. targetSummary(targets) .. "."
end

commands.give = function(executor, args)
	local targets, problem = resolveMany(executor, args[1])
	if not targets then return false, problem end
	local typedId = string.lower(args[2] or "")
	local itemId
	for candidateId in pairs(itemDefinitions) do
		if string.lower(candidateId) == typedId then itemId = candidateId break end
	end
	if not itemId or itemId == "Fists" then
		return false, "Unknown item. Use Bat, Pistol, PistolAmmo, Shotgun, Shells, Medkit, or Balloon."
	end
	local amount, amountProblem = readNumber(args[3] or "1", "item amount", 1, 999)
	if not amount then return false, amountProblem end
	for _, target in ipairs(targets) do setInventoryAmount(target, itemId, amount) end
	return true, "Gave " .. amount .. " " .. itemId .. " to " .. targetSummary(targets) .. "."
end

commands["goto"] = function(executor, args)
	local targets, problem = resolveTargets(executor, args[1], false)
	if not targets then return false, problem end
	local executorRoot = getRoot(executor)
	local targetRoot = getRoot(targets[1])
	if not executorRoot or not targetRoot then return false, "A character is not ready." end
	executorRoot.CFrame = targetRoot.CFrame * CFrame.new(3, 0, 0)
	return true, "Teleported to " .. targets[1].Name .. "."
end

commands.bring = function(executor, args)
	local targets, problem = resolveMany(executor, args[1])
	if not targets then return false, problem end
	local executorRoot = getRoot(executor)
	if not executorRoot then return false, "Your character is not ready." end
	for index, target in ipairs(targets) do
		local root = getRoot(target)
		if root and target ~= executor then root.CFrame = executorRoot.CFrame * CFrame.new((index - 1) * 3, 0, -4) end
	end
	return true, "Brought " .. targetSummary(targets) .. "."
end

commands.speed = function(executor, args)
	local targets, problem = resolveMany(executor, args[1])
	if not targets then return false, problem end
	if string.lower(args[2] or "") == "reset" then
		for _, target in ipairs(targets) do target:SetAttribute("AdminWalkSpeed", nil) end
		return true, "Reset speed for " .. targetSummary(targets) .. "."
	end
	local amount, amountProblem = readNumber(args[2], "speed", 8, 80)
	if not amount then return false, amountProblem end
	for _, target in ipairs(targets) do target:SetAttribute("AdminWalkSpeed", amount) end
	return true, "Set speed to " .. amount .. " for " .. targetSummary(targets) .. "."
end

commands.jump = function(executor, args)
	local targets, problem = resolveMany(executor, args[1])
	if not targets then return false, problem end
	if string.lower(args[2] or "") == "reset" then
		for _, target in ipairs(targets) do target:SetAttribute("AdminJumpPower", nil) end
		return true, "Reset jump for " .. targetSummary(targets) .. "."
	end
	local amount, amountProblem = readNumber(args[2], "jump power", 20, 150)
	if not amount then return false, amountProblem end
	for _, target in ipairs(targets) do target:SetAttribute("AdminJumpPower", amount) end
	return true, "Set jump power to " .. amount .. " for " .. targetSummary(targets) .. "."
end

commands.freeze = function(executor, args)
	local targets, problem = resolveMany(executor, args[1])
	if not targets then return false, problem end
	for _, target in ipairs(targets) do
		local root = getRoot(target)
		if root then root.Anchored = true end
	end
	return true, "Froze " .. targetSummary(targets) .. "."
end

commands.unfreeze = function(executor, args)
	local targets, problem = resolveMany(executor, args[1])
	if not targets then return false, problem end
	for _, target in ipairs(targets) do
		local root = getRoot(target)
		if root then root.Anchored = false end
	end
	return true, "Unfroze " .. targetSummary(targets) .. "."
end

commands.announce = function(_, args)
	local message = table.concat(args, " ")
	if message == "" then return false, "Type a message to announce." end
	notificationRemote:FireAllClients("ADMIN: " .. string.sub(message, 1, 180), Color3.fromRGB(255, 205, 91))
	return true, "Announcement sent."
end

commands.day = function()
	adminBridge:Fire("SetTime", 12)
	return true, "Set the district to daytime."
end

commands.night = function()
	adminBridge:Fire("SetTime", 0)
	return true, "Set the district to nighttime."
end

commands.weather = function(_, args)
	local state = string.lower(args[1] or "")
	if state ~= "clear" and state ~= "overcast" and state ~= "rain" then
		return false, "Use: weather clear, weather overcast, or weather rain"
	end
	adminBridge:Fire("SetWeather", string.upper(state))
	return true, "Set district weather to " .. state .. "."
end

commands.blackout = function(_, args)
	local mode = string.lower(args[1] or "")
	if mode ~= "on" and mode ~= "off" then return false, "Use: blackout on or blackout off" end
	adminBridge:Fire("Blackout", mode == "on")
	return true, "Blackout turned " .. mode .. "."
end

commands.event = function(_, args)
	local eventName = string.lower(args[1] or "")
	if eventName == "supply" then
		adminBridge:Fire("SpawnSupply")
	elseif eventName == "truck" or eventName == "armored" then
		adminBridge:Fire("SpawnArmored")
	else
		return false, "Use: event supply or event truck"
	end
	return true, "Started the " .. eventName .. " event if one was not already active."
end

commands.civilians = function(_, args)
	if string.lower(args[1] or "") ~= "respawn" then
		return false, "Use: civilians respawn"
	end
	adminBridge:Fire("RespawnCivilians")
	return true, "Respawned the civilian population."
end

commands.contracts = function(executor, args)
	if string.lower(args[1] or "") ~= "reset" then
		return false, "Use: contracts reset <target>"
	end
	local targets, problem = resolveMany(executor, args[2] or "me")
	if not targets then return false, problem end
	for _, target in ipairs(targets) do
		adminBridge:Fire("ResetDailyContract", target)
	end
	return true, "Reset daily contract progress for " .. targetSummary(targets) .. "."
end

commands.vehicle = function(executor, args)
	local targets, problem = resolveMany(executor, args[1])
	if not targets then return false, problem end
	local mode = string.lower(args[2] or "")
	if mode ~= "grant" and mode ~= "revoke" and mode ~= "refuel" and mode ~= "repair" and mode ~= "despawn" then
		return false, "Use: vehicle <target> grant|revoke|refuel|repair|despawn"
	end
	for _, target in ipairs(targets) do
		adminBridge:Fire("VehicleAdmin", {Player = target, Mode = mode})
	end
	return true, "Applied vehicle " .. mode .. " to " .. targetSummary(targets) .. "."
end

commands.kick = function(executor, args)
	local targets, problem = resolveMany(executor, args[1])
	if not targets then return false, problem end
	local reason = table.concat(args, " ", 2)
	if reason == "" then reason = "Removed by an Ohio 2 administrator." end
	for _, target in ipairs(targets) do
		if target ~= executor then target:Kick(string.sub(reason, 1, 180)) end
	end
	return true, "Kick command completed for " .. targetSummary(targets) .. "."
end

local function runCommand(player, rawLine)
	if typeof(rawLine) ~= "string" or #rawLine > 300 then
		return
	end
	if not isAdmin(player) then
		refreshAdmin(player)
		warn("[Ohio2 Admin] Rejected command request from " .. player.Name .. " (" .. player.UserId .. ")")
		return
	end
	local now = os.clock()
	if now - (lastCommandAt[player] or 0) < 0.12 then
		return
	end
	lastCommandAt[player] = now
	local cleaned = string.gsub(rawLine, "^%s*[;:]%s*", "")
	local words = splitWords(cleaned)
	local commandName = string.lower(table.remove(words, 1) or "")
	local command = commands[commandName]
	if not command then
		sendFeedback(player, false, "Unknown command. Type help for the command list.")
		return
	end
	local ok, success, message = pcall(command, player, words)
	if not ok then
		warn("[Ohio2 Admin] Command error: " .. tostring(success))
		sendFeedback(player, false, "Command failed safely. Check the Server output.")
		return
	end
	print("[Ohio2 Admin] " .. player.Name .. " ran: " .. cleaned)
	sendFeedback(player, success, message)
end

rebuildAdminIds()
adminUserIdsValue.Changed:Connect(refreshAllAdmins)
creatorIsAdminValue.Changed:Connect(refreshAllAdmins)
studioPlayersAreAdminValue.Changed:Connect(refreshAllAdmins)
Players.PlayerAdded:Connect(refreshAdmin)
Players.PlayerRemoving:Connect(function(player) lastCommandAt[player] = nil end)
for _, player in ipairs(Players:GetPlayers()) do refreshAdmin(player) end
commandRemote.OnServerEvent:Connect(runCommand)

print("[Ohio2 Admin] Secure admin console loaded")
]==]
adminServer.Parent = ServerScriptService

local clientMain = Instance.new("LocalScript")
clientMain.Name = "Ohio2Client"
clientMain.Source = [==[
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
]==]
clientMain.Parent = StarterPlayer.StarterPlayerScripts

local adminClient = Instance.new("LocalScript")
adminClient.Name = "Ohio2AdminClient"
adminClient.Source = [==[
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
-- Server-authoritative arcade controller for public and player-owned vehicles.

local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local car = script.Parent
local chassis = car:WaitForChild("Chassis")
local seat = car:WaitForChild("DriverSeat")
local notificationRemote = ReplicatedStorage:WaitForChild("Ohio2"):WaitForChild("Remotes"):WaitForChild("Notification")
local soundDefinitions = require(ReplicatedStorage:WaitForChild("Ohio2"):WaitForChild("Shared"):WaitForChild("SoundDefinitions"))

local MAX_SPEED = 58
local TURN_SPEED = 1.8
local FUEL_DRAIN_PER_SECOND = 0.48
local COLLISION_SPEED = 30
local COLLISION_COOLDOWN = 1.4

local lastCollisionAt = 0
local warnedFuel = false
local warnedCondition = false
local warnedUnauthorized = {}
local smoke = Instance.new("Smoke")
smoke.Name = "DamageSmoke"
smoke.Color = Color3.fromRGB(87, 91, 94)
smoke.Opacity = 0.24
smoke.RiseVelocity = 3
smoke.Size = 4
smoke.Enabled = false
smoke.Parent = chassis

local function configureSound(sound, soundName, volumeScale, speedScale)
	local definition = soundDefinitions.Catalog[soundName]
	if not definition or type(definition.SoundId) ~= "string" or definition.SoundId == "" then
		return false
	end
	sound.Name = "Ohio2_" .. soundName
	sound.SoundId = definition.SoundId
	sound.Volume = (definition.Volume or 0.5) * (soundDefinitions.MasterVolume or 1) * (volumeScale or 1)
	sound.PlaybackSpeed = math.max(0.05, (definition.PlaybackSpeed or 1) * (speedScale or 1))
	sound.RollOffMode = Enum.RollOffMode.InverseTapered
	sound.RollOffMinDistance = definition.MinDistance or 5
	sound.RollOffMaxDistance = definition.MaxDistance or 100
	return true
end

local engineSound = Instance.new("Sound")
local engineAvailable = configureSound(engineSound, "VehicleEngine")
engineSound.Looped = true
engineSound.Parent = chassis

local function playCrashSound(speed)
	local sound = Instance.new("Sound")
	if not configureSound(sound, "VehicleCrash", math.clamp(speed / 45, 0.65, 1.2), 0.94 + math.random() * 0.12) then
		return
	end
	sound.Parent = chassis
	sound:Play()
	Debris:AddItem(sound, 7)
end

if car:GetAttribute("Fuel") == nil then
	car:SetAttribute("Fuel", 100)
end
if car:GetAttribute("MaxFuel") == nil then
	car:SetAttribute("MaxFuel", 100)
end
if car:GetAttribute("Condition") == nil then
	car:SetAttribute("Condition", 100)
end
if car:GetAttribute("MaxCondition") == nil then
	car:SetAttribute("MaxCondition", 100)
end
if car:GetAttribute("OwnerUserId") == nil then
	car:SetAttribute("OwnerUserId", 0)
end
car:SetAttribute("VehicleDisabled", false)

pcall(function()
	chassis:SetNetworkOwner(nil)
end)

local function notify(player, message, color)
	if player and player.Parent then
		notificationRemote:FireClient(player, message, color)
	end
end

local function currentDriver()
	local humanoid = seat.Occupant
	local player = humanoid and Players:GetPlayerFromCharacter(humanoid.Parent)
	return player, humanoid
end

local function isOwnedVehicle()
	return (car:GetAttribute("OwnerUserId") or 0) > 0
end

local function ejectUnauthorizedDriver(player, humanoid)
	if not humanoid then
		return
	end
	humanoid.Sit = false
	seat.Disabled = true
	task.delay(0.45, function()
		if seat.Parent then
			seat.Disabled = false
		end
	end)
	if player and not warnedUnauthorized[player] then
		warnedUnauthorized[player] = true
		notify(player, "This vehicle is locked to its owner.", Color3.fromRGB(255, 104, 104))
		task.delay(2, function()
			warnedUnauthorized[player] = nil
		end)
	end
end

chassis.Touched:Connect(function(hit)
	if not isOwnedVehicle() or not hit or hit:IsDescendantOf(car) or not hit.CanCollide then
		return
	end
	local now = os.clock()
	local speed = Vector3.new(chassis.AssemblyLinearVelocity.X, 0, chassis.AssemblyLinearVelocity.Z).Magnitude
	if speed < COLLISION_SPEED or now - lastCollisionAt < COLLISION_COOLDOWN then
		return
	end
	if hit.Material == Enum.Material.Asphalt or hit.Material == Enum.Material.Grass or hit.Material == Enum.Material.Ground then
		return
	end
	lastCollisionAt = now
	playCrashSound(speed)
	local condition = math.clamp(tonumber(car:GetAttribute("Condition")) or 100, 0, 100)
	local damage = math.clamp(math.floor((speed - COLLISION_SPEED) * 0.45 + 2), 2, 14)
	condition = math.max(0, condition - damage)
	car:SetAttribute("Condition", condition)
	if condition <= 0 then
		car:SetAttribute("VehicleDisabled", true)
	end
	local driver = currentDriver()
	notify(driver, "Collision damage: -" .. damage .. " vehicle condition.", Color3.fromRGB(255, 174, 91))
end)

RunService.Heartbeat:Connect(function(deltaTime)
	if not car.Parent or not chassis.Parent then
		return
	end

	local velocity = chassis.AssemblyLinearVelocity
	local driver, humanoid = currentDriver()
	local ownerUserId = car:GetAttribute("OwnerUserId") or 0
	if humanoid and ownerUserId > 0 and (not driver or driver.UserId ~= ownerUserId) then
		ejectUnauthorizedDriver(driver, humanoid)
		driver = nil
		humanoid = nil
	end

	local fuel = math.clamp(tonumber(car:GetAttribute("Fuel")) or 0, 0, tonumber(car:GetAttribute("MaxFuel")) or 100)
	local condition = math.clamp(tonumber(car:GetAttribute("Condition")) or 0, 0, tonumber(car:GetAttribute("MaxCondition")) or 100)
	local disabled = isOwnedVehicle() and (fuel <= 0 or condition <= 0)
	car:SetAttribute("VehicleDisabled", disabled)
	smoke.Enabled = isOwnedVehicle() and condition <= 35

	if humanoid and not disabled then
		local throttle = seat.ThrottleFloat
		local steer = seat.SteerFloat
		local planarSpeed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
		if engineAvailable then
			local definition = soundDefinitions.Catalog.VehicleEngine
			local conditionScale = isOwnedVehicle() and math.clamp(condition / 45, 0.62, 1) or 1
			local sputter = condition <= 35 and (0.84 + math.sin(os.clock() * 13) * 0.12) or 1
			engineSound.Volume = (definition.Volume or 0.38) * (soundDefinitions.MasterVolume or 1) * (0.58 + math.abs(throttle) * 0.42) * conditionScale * sputter
			engineSound.PlaybackSpeed = (definition.PlaybackSpeed or 0.72) * (0.9 + math.clamp(planarSpeed / MAX_SPEED, 0, 1) * 0.72 + math.abs(throttle) * 0.14)
			if not engineSound.IsPlaying then
				engineSound:Play()
			end
		end
		local forward = chassis.CFrame.LookVector
		local desired = forward * throttle * MAX_SPEED
		chassis.AssemblyLinearVelocity = Vector3.new(
			velocity.X + (desired.X - velocity.X) * 0.12,
			velocity.Y,
			velocity.Z + (desired.Z - velocity.Z) * 0.12
		)
		local direction = throttle < -0.05 and -1 or 1
		chassis.AssemblyAngularVelocity = Vector3.new(0, -steer * TURN_SPEED * direction, 0)
		if isOwnedVehicle() and math.abs(throttle) > 0.05 then
			fuel = math.max(0, fuel - math.abs(throttle) * FUEL_DRAIN_PER_SECOND * deltaTime)
			car:SetAttribute("Fuel", math.floor(fuel * 10 + 0.5) / 10)
		end
		warnedFuel = false
		warnedCondition = false
	else
		if engineAvailable and engineSound.IsPlaying then
			engineSound:Stop()
		end
		chassis.AssemblyLinearVelocity = Vector3.new(velocity.X * 0.97, velocity.Y, velocity.Z * 0.97)
		chassis.AssemblyAngularVelocity = chassis.AssemblyAngularVelocity * 0.82
		if humanoid and isOwnedVehicle() then
			if fuel <= 0 and not warnedFuel then
				warnedFuel = true
				notify(driver, "Out of fuel. Refuel the vehicle at the Quick Stop pump.", Color3.fromRGB(255, 104, 104))
			elseif condition <= 0 and not warnedCondition then
				warnedCondition = true
				notify(driver, "Vehicle disabled. Bring it to Rust Belt Auto for repairs.", Color3.fromRGB(255, 104, 104))
			end
		end
	end
end)
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
