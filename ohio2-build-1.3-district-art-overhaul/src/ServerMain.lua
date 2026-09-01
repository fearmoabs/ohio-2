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
