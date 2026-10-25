local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Config = require(ReplicatedStorage.LastDelivery.Config)
local Rules = require(ReplicatedStorage.LastDelivery.Rules)

Players.RespawnTime = 5
Lighting.ClockTime = 0
Lighting.Brightness = 1
Lighting.Ambient = Color3.fromRGB(30, 34, 50)
Lighting.OutdoorAmbient = Color3.fromRGB(18, 22, 35)
Lighting.FogColor = Color3.fromRGB(20, 24, 35)
Lighting.FogStart = 35
Lighting.FogEnd = 230

local remote = Instance.new("RemoteEvent")
remote.Name = "GameEvent"
remote.Parent = ReplicatedStorage.LastDelivery
local world = Instance.new("Folder")
world.Name = "LastDeliveryWorld"
world.Parent = workspace

local function part(name, size, position, color, parent)
	local object = Instance.new("Part")
	object.Name = name
	object.Size = size
	object.Position = position
	object.Anchored = true
	object.Color = color
	object.Material = Enum.Material.SmoothPlastic
	object.TopSurface = Enum.SurfaceType.Smooth
	object.BottomSurface = Enum.SurfaceType.Smooth
	object.Parent = parent or world
	return object
end

local function label(target, text)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(220, 60)
	gui.StudsOffset = Vector3.new(0, 4, 0)
	gui.MaxDistance = 65
	gui.Parent = target
	local title = Instance.new("TextLabel")
	title.Size = UDim2.fromScale(1, 1)
	title.BackgroundTransparency = 1
	title.Text = text
	title.TextColor3 = Color3.fromRGB(255, 220, 160)
	title.TextStrokeTransparency = 0.3
	title.Font = Enum.Font.GothamBold
	title.TextSize = 18
	title.Parent = gui
end

local function prompt(target, action, description, callback)
	local interaction = Instance.new("ProximityPrompt")
	interaction.ActionText = action
	interaction.ObjectText = description
	interaction.HoldDuration = 0.6
	interaction.MaxActivationDistance = 11
	interaction.RequiresLineOfSight = false
	interaction.Parent = target
	interaction.Triggered:Connect(function(player)
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if root and humanoid and humanoid.Health > 0 and (root.Position - target.Position).Magnitude <= 14 then
			callback(player)
		end
	end)
	return interaction
end

part("Ground", Vector3.new(360, 2, 430), Vector3.new(0, -1, -130), Color3.fromRGB(25, 38, 30))
part("Road", Vector3.new(44, 0.2, 370), Vector3.new(0, 0.1, -130), Color3.fromRGB(31, 32, 37))
for z = 20, -300, -20 do
	part("RoadStripe", Vector3.new(0.6, 0.1, 9), Vector3.new(0, 0.25, z), Color3.fromRGB(170, 150, 85))
end
for _, x in ipairs({ -25, 25 }) do
	part("Sidewalk", Vector3.new(6, 0.4, 370), Vector3.new(x, 0.2, -130), Color3.fromRGB(75, 76, 81))
end
for z = 0, -280, -56 do
	local post = part("Streetlight", Vector3.new(0.8, 19, 0.8), Vector3.new(27, 9.5, z), Color3.fromRGB(45, 47, 50))
	local lamp = part("Lamp", Vector3.new(4, 0.4, 3), post.Position + Vector3.new(-1.6, 9.5, 0), Color3.fromRGB(245, 207, 140))
	lamp.Material = Enum.Material.Neon
	local light = Instance.new("PointLight")
	light.Color = lamp.Color
	light.Range = 33
	light.Brightness = 1.5
	light.Parent = lamp
end

local spawn = Instance.new("SpawnLocation")
spawn.Name = "VanSpawn"
spawn.Size = Vector3.new(8, 1, 8)
spawn.Position = Vector3.new(0, 1, 35)
spawn.Transparency = 1
spawn.Anchored = true
spawn.Neutral = true
spawn.Parent = world

local van = part("DeliveryVan", Vector3.new(12, 9, 20), Vector3.new(0, 5, 15), Color3.fromRGB(166, 136, 85))
part("Windshield", Vector3.new(10, 3, 0.3), Vector3.new(0, 7, 4.8), Color3.fromRGB(35, 58, 70))
for _, x in ipairs({ -6, 6 }) do
	for _, z in ipairs({ 9, 21 }) do
		part("Wheel", Vector3.new(1, 4, 4), Vector3.new(x, 2, z), Color3.fromRGB(16, 16, 18))
	end
end
label(van, "LAST DELIVERY • DISPATCH")
local hatch = part("ParcelHatch", Vector3.new(6, 3, 0.5), Vector3.new(0, 4, 25.4), Color3.fromRGB(108, 84, 48))
local exit = part("DriverDoor", Vector3.new(0.5, 5, 6), Vector3.new(-6.4, 5, 9), Color3.fromRGB(120, 96, 60))

local porches = {}
for index, house in ipairs(Config.Houses) do
	local p = house.Position
	local side = if p.X < 0 then 1 else -1
	part("House" .. house.Number, Vector3.new(32, 22, 34), p + Vector3.new(0, 11, 0), Color3.fromRGB(57 + index * 9, 57, 65))
	part("Roof", Vector3.new(36, 3, 38), p + Vector3.new(0, 23, 0), Color3.fromRGB(29, 28, 33))
	local door = part("Door" .. house.Number, Vector3.new(0.5, 9, 5), p + Vector3.new(side * 16.4, 4.5, 0), Color3.fromRGB(55, 35, 31))
	local porch = part("Porch" .. house.Number, Vector3.new(12, 0.5, 12), p + Vector3.new(side * 22, 0.3, 0), Color3.fromRGB(91, 83, 75))
	part("Walkway", Vector3.new(22, 0.2, 6), Vector3.new(side * -37, 0.2, p.Z), Color3.fromRGB(72, 72, 76))
	label(door, "HOUSE " .. house.Number)
	porches[index] = { Door = door, Porch = porch }
end

-- A readable silhouette that needs no uploaded models or paid assets.
local creature = Instance.new("Model")
creature.Name = "TheFollower"
creature.Parent = world
local torso = part("Body", Vector3.new(3, 7, 2), Vector3.new(0, 5, -300), Color3.fromRGB(8, 8, 12), creature)
part("Head", Vector3.new(2.4, 2.5, 2), torso.Position + Vector3.new(0, 4.3, 0), Color3.fromRGB(19, 17, 20), creature)
for _, x in ipairs({ -2, 2 }) do
	part("Arm", Vector3.new(0.8, 8, 0.8), torso.Position + Vector3.new(x, -0.5, 0), Color3.fromRGB(9, 9, 12), creature)
end
for _, x in ipairs({ -0.6, 0.6 }) do
	local eye = part("Eye", Vector3.new(0.3, 0.25, 0.2), torso.Position + Vector3.new(x, 4.5, -1.1), Color3.fromRGB(255, 75, 60), creature)
	eye.Material = Enum.Material.Neon
end
for _, object in ipairs(creature:GetChildren()) do
	if object:IsA("BasePart") then object.CanCollide = false end
end
creature.PrimaryPart = torso

local phase = "Waiting"
local route = 1
local delivered = 0
local deadline = 0
local result = ""
local carrier = nil
local angerUntil = 0
local state = {}
local lastAttack = {}
local monsterPosition = Vector3.new(0, 5, -300)

local function send(player, message)
	remote:FireClient(player, "Notice", message)
end

local function broadcast()
	local house = Config.Houses[route]
	for _, player in ipairs(Players:GetPlayers()) do
		remote:FireClient(player, "State", {
			Phase = phase, Delivered = delivered, Total = #Config.Houses,
			Remaining = math.max(0, math.ceil(deadline - workspace:GetServerTimeNow())),
			House = house and house.Number or "", Rule = house and house.Rule or "",
			Carrier = carrier and carrier.DisplayName or "", IsCarrier = carrier == player,
			Result = result,
		})
	end
end

local function removeParcel(player)
	if player and player.Character then
		local parcel = player.Character:FindFirstChild("DeliveryParcel")
		if parcel then parcel:Destroy() end
	end
end

local function dropParcel(player)
	if carrier == player then
		removeParcel(player)
		carrier = nil
		broadcast()
	end
end

local function finish(won)
	phase = "Intermission"
	result = if won then "ROUTE COMPLETE — You made it out. But who signed the last receipt?" else "SHIFT LOST — The neighborhood keeps its packages."
	removeParcel(carrier)
	carrier = nil
	deadline = workspace:GetServerTimeNow() + Config.IntermissionSeconds
	broadcast()
end

local function anger(player, reason)
	angerUntil = workspace:GetServerTimeNow() + 12
	remote:FireClient(player, "Scare", reason)
	-- The monster approaches by road; it never teleports onto a player.
end

prompt(hatch, "Collect parcel", "Dispatch • one parcel at a time", function(player)
	if phase ~= "Delivery" then send(player, "Complete your route, then use the driver door to escape."); return end
	if carrier then send(player, carrier.DisplayName .. " already has the parcel."); return end
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	carrier = player
	local parcel = Instance.new("Part")
	parcel.Name = "DeliveryParcel"
	parcel.Size = Vector3.new(2.2, 1.6, 1.6)
	parcel.Color = Color3.fromRGB(160, 118, 68)
	parcel.CanCollide = false
	parcel.Massless = true
	parcel.CFrame = root.CFrame * CFrame.new(0, -0.2, -2)
	parcel.Parent = character
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = parcel
	weld.Parent = parcel
	send(player, "Parcel collected. Read the instruction before approaching the house.")
	broadcast()
end)

for index, house in ipairs(Config.Houses) do
	prompt(porches[index].Door, "Deliver / ring bell", "House " .. house.Number, function(player)
		if phase ~= "Delivery" then return end
		local data = state[player]
		if not data then return end
		local decision = Rules.delivery(index, route, carrier == player, house.Kind, data.Flashlight, data.Sprinting, data.NoisyUntil, workspace:GetServerTimeNow())
		if decision == "RepeatedBell" then anger(player, "You rang twice. Something heard you."); return end
		if decision == "WrongAddress" then send(player, "Wrong address. Follow the dispatch route."); return end
		if decision == "NoParcel" then send(player, "Collect this house's parcel from the van first."); return end
		if decision == "Light" then
			anger(player, "The light woke the tenant. Turn it OFF and try again.")
			return
		end
		if decision == "Noise" then
			anger(player, "Too loud. Walk slowly and let the porch settle.")
			return
		end
		removeParcel(player)
		carrier = nil
		delivered += 1
		route += 1
		if delivered == #Config.Houses then
			phase = "Escape"
			angerUntil = workspace:GetServerTimeNow() + 999
			send(player, "All packages delivered. EVERYONE back to the van!")
		else
			send(player, "Delivered. Return to dispatch for the next parcel.")
		end
		broadcast()
	end)
end

prompt(exit, "Finish shift", "Driver door • gather your crew nearby", function(player)
	if phase ~= "Escape" then send(player, "There are still packages to deliver."); return end
	for _, teammate in ipairs(Players:GetPlayers()) do
		local character = teammate.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if humanoid and humanoid.Health > 0 and root and (root.Position - van.Position).Magnitude > 28 then
			send(player, "A living teammate is still outside. Bring everyone back.")
			return
		end
	end
	finish(true)
end)

remote.OnServerEvent:Connect(function(player, action, enabled)
	local data = state[player]
	if not data then return end
	local now = workspace:GetServerTimeNow()
	if action == "Ready" then
		if now - data.LastReady < 1 then return end
		data.LastReady = now
		broadcast()
		return
	end
	if typeof(enabled) ~= "boolean" then return end
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end
	if action == "Sprint" then
		data.Sprinting = enabled
		humanoid.WalkSpeed = if enabled then 22 else 12
	elseif action == "Flashlight" then
		data.Flashlight = enabled
		local head = character:FindFirstChild("Head")
		local light = head and head:FindFirstChild("DeliveryLight")
		if light then light.Enabled = enabled end
	end
end)

local function characterAdded(player, character)
	dropParcel(player)
	local data = state[player]
	if not data then return end
	data.Sprinting = false
	data.Flashlight = false
	data.NoisyUntil = 0
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = 12
	local head = character:WaitForChild("Head")
	local light = Instance.new("SpotLight")
	light.Name = "DeliveryLight"
	light.Angle = 75
	light.Range = 55
	light.Brightness = 3
	light.Enabled = false
	light.Parent = head
	humanoid.Died:Connect(function()
		dropParcel(player)
		send(player, "The follower caught you. Dispatch will recover you in five seconds.")
	end)
	broadcast()
end

local function playerAdded(player)
	if #Players:GetPlayers() > Config.MaxPlayers then player:Kick("This delivery crew is full (4 players)."); return end
	state[player] = { Sprinting = false, Flashlight = false, NoisyUntil = 0, LastReady = 0 }
	player.CharacterAdded:Connect(function(character) characterAdded(player, character) end)
	if player.Character then task.spawn(characterAdded, player, player.Character) end
end
Players.PlayerAdded:Connect(playerAdded)
for _, player in ipairs(Players:GetPlayers()) do playerAdded(player) end
Players.PlayerRemoving:Connect(function(player)
	dropParcel(player)
	state[player] = nil
	lastAttack[player] = nil
end)

local function beginRound()
	route = 1
	delivered = 0
	result = ""
	angerUntil = 0
	monsterPosition = Vector3.new(0, 5, -300)
	lastAttack = {}
	phase = "Delivery"
	deadline = workspace:GetServerTimeNow() + Config.RoundSeconds
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if character then character:PivotTo(CFrame.new(0, 5, 35)) end
	end
	broadcast()
end

local accumulated = 0
RunService.Heartbeat:Connect(function(dt)
	local now = workspace:GetServerTimeNow()
	if phase == "Delivery" or phase == "Escape" then
		local target = nil
		local closest = math.huge
		for player, data in pairs(state) do
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if root and humanoid and humanoid.Health > 0 then
				local moving = humanoid.MoveDirection.Magnitude > 0.1
				if data.Sprinting and moving then data.NoisyUntil = now + 3 end
				-- The well-lit van is a safe zone; house interiors are sealed.
				local distance = (root.Position - monsterPosition).Magnitude
				if Rules.detectable(root.Position.Z, distance, Config.DetectionRadius, data.Sprinting, data.Flashlight, now < angerUntil) and distance < closest then
					closest = distance
					target = player
				end
			end
		end
		local goal = Vector3.new(0, 5, -150 + math.sin(now / 12) * 110)
		if target then
			local root = target.Character.HumanoidRootPart
			goal = Vector3.new(root.Position.X, 5, root.Position.Z)
			if closest < Config.AttackRadius and now - (lastAttack[target] or 0) > 1.5 then
				lastAttack[target] = now
				target.Character.Humanoid:TakeDamage(Config.AttackDamage)
				remote:FireClient(target, "Scare", "DON'T LOOK BACK.")
			end
		end
		local delta = goal - monsterPosition
		local speed = if now < angerUntil then Config.MonsterSprintSpeed else Config.MonsterSpeed
		-- Clamp frame time so a server hitch cannot teleport the follower.
		if delta.Magnitude > 0.1 then
			local nextPosition = monsterPosition + delta.Unit * math.min(delta.Magnitude, speed * math.min(dt, 0.1))
			-- Walk around the sealed buildings using the road-side corridor.
			if math.abs(nextPosition.X) > 47 then nextPosition = Vector3.new(math.clamp(nextPosition.X, -47, 47), 5, nextPosition.Z) end
			monsterPosition = nextPosition
			creature:PivotTo(CFrame.lookAt(monsterPosition, monsterPosition + delta.Unit))
		end
		if now >= deadline then finish(false) end
	elseif #Players:GetPlayers() > 0 and (phase == "Waiting" or now >= deadline) then
		beginRound()
	end
	accumulated += dt
	if accumulated >= 1 then accumulated = 0; broadcast() end
end)
