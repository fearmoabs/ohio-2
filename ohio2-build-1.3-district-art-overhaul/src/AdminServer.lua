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
