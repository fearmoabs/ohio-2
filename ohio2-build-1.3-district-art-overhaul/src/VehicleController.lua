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
