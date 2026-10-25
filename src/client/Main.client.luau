local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("LastDelivery"):WaitForChild("GameEvent")

local gui = Instance.new("ScreenGui")
gui.Name = "LastDeliveryHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Position = UDim2.new(0, 12, 0, 12)
panel.Size = UDim2.new(0.92, 0, 0, 204)
panel.BackgroundColor3 = Color3.fromRGB(12, 15, 22)
panel.BackgroundTransparency = 0.12
panel.BorderSizePixel = 0
panel.Parent = gui
local constraint = Instance.new("UISizeConstraint")
constraint.MaxSize = Vector2.new(510, 204)
constraint.Parent = panel
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = panel

local function text(parent, y, height, size, color)
	local object = Instance.new("TextLabel")
	object.Position = UDim2.new(0, 14, 0, y)
	object.Size = UDim2.new(1, -28, 0, height)
	object.BackgroundTransparency = 1
	object.Font = Enum.Font.Gotham
	object.TextSize = size
	object.TextColor3 = color or Color3.fromRGB(225, 225, 230)
	object.TextWrapped = true
	object.TextXAlignment = Enum.TextXAlignment.Left
	object.TextYAlignment = Enum.TextYAlignment.Center
	object.Parent = parent
	return object
end

local title = text(panel, 8, 26, 20, Color3.fromRGB(238, 190, 111))
title.Text = "THE LAST DELIVERY"
title.Font = Enum.Font.GothamBold
local status = text(panel, 37, 24, 15)
local objective = text(panel, 65, 42, 16)
local rule = text(panel, 108, 48, 15, Color3.fromRGB(244, 201, 143))
local controls = text(panel, 160, 38, 12, Color3.fromRGB(170, 180, 195))
controls.Text = "WASD: move • Space: jump • Hold right mouse: look\nE / tap: interact • F: light • Shift: sprint • Van = safe"

-- This marker is local: every player sees their current shared objective.
local marker = Instance.new("BillboardGui")
marker.Name = "ObjectiveMarker"
marker.Size = UDim2.fromOffset(240, 72)
marker.StudsOffsetWorldSpace = Vector3.new(0, 7, 0)
marker.AlwaysOnTop = true
marker.MaxDistance = 500
marker.Enabled = false
marker.Parent = gui
local markerText = Instance.new("TextLabel")
markerText.Size = UDim2.fromScale(1, 1)
markerText.BackgroundColor3 = Color3.fromRGB(15, 23, 30)
markerText.BackgroundTransparency = 0.15
markerText.TextColor3 = Color3.fromRGB(255, 220, 120)
markerText.TextStrokeTransparency = 0.3
markerText.Font = Enum.Font.GothamBold
markerText.TextSize = 18
markerText.Parent = marker
local markerTarget = ""
local markerCaption = ""
local markerElapsed = 0
RunService.Heartbeat:Connect(function(dt)
	markerElapsed += dt
	if markerElapsed < 0.15 then return end
	markerElapsed = 0
	local world = workspace:FindFirstChild("LastDeliveryWorld")
	local target = world and world:FindFirstChild(markerTarget)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	marker.Enabled = target ~= nil and root ~= nil and markerTarget ~= ""
	marker.Adornee = target
	if target and root then
		markerText.Text = string.format("▼ %s\n%d studs away", markerCaption, math.floor((root.Position - target.Position).Magnitude))
	end
end)

local notice = Instance.new("TextLabel")
notice.AnchorPoint = Vector2.new(0.5, 1)
notice.Position = UDim2.new(0.5, 0, 1, -110)
notice.Size = UDim2.new(0.9, 0, 0, 65)
notice.BackgroundColor3 = Color3.fromRGB(16, 19, 27)
notice.BackgroundTransparency = 0.2
notice.Font = Enum.Font.GothamBold
notice.TextColor3 = Color3.fromRGB(255, 228, 190)
notice.TextSize = 18
notice.TextWrapped = true
notice.Visible = false
notice.Parent = gui

local overlay = Instance.new("Frame")
overlay.Size = UDim2.fromScale(1, 1)
overlay.BackgroundColor3 = Color3.fromRGB(150, 10, 15)
overlay.BackgroundTransparency = 1
overlay.BorderSizePixel = 0
overlay.ZIndex = 5
overlay.Parent = gui

local flashlight = false
local sprinting = false
local function refreshControls()
	ContextActionService:SetTitle("DeliveryFlashlight", if flashlight then "Light ON" else "Light OFF")
end

ContextActionService:BindAction("DeliveryFlashlight", function(_, inputState)
	if inputState == Enum.UserInputState.Begin then
		flashlight = not flashlight
		remote:FireServer("Flashlight", flashlight)
		refreshControls()
	end
	return Enum.ContextActionResult.Sink
end, true, Enum.KeyCode.F, Enum.KeyCode.ButtonY)
ContextActionService:SetPosition("DeliveryFlashlight", UDim2.new(1, -180, 1, -150))
refreshControls()

ContextActionService:BindAction("DeliverySprint", function(_, inputState)
	if inputState == Enum.UserInputState.Begin then
		sprinting = true
	elseif inputState == Enum.UserInputState.End or inputState == Enum.UserInputState.Cancel then
		sprinting = false
	else
		return Enum.ContextActionResult.Sink
	end
	remote:FireServer("Sprint", sprinting)
	return Enum.ContextActionResult.Sink
end, true, Enum.KeyCode.LeftShift, Enum.KeyCode.ButtonL3)
ContextActionService:SetTitle("DeliverySprint", "Sprint")
ContextActionService:SetPosition("DeliverySprint", UDim2.new(1, -100, 1, -200))

local noticeVersion = 0
local function showNotice(message)
	noticeVersion += 1
	local version = noticeVersion
	notice.Text = message
	notice.Visible = true
	task.delay(5, function()
		if noticeVersion == version then notice.Visible = false end
	end)
end

remote.OnClientEvent:Connect(function(kind, payload)
	if kind == "State" then
		markerTarget = payload.Target or ""
		markerCaption = if markerTarget == "ParcelPickup" then "COLLECT PARCEL " .. payload.House elseif markerTarget == "DriverDoor" then "ESCAPE • DRIVER DOOR" else "DELIVER • HOUSE " .. payload.House
		local minutes = math.floor(payload.Remaining / 60)
		local seconds = payload.Remaining % 60
		status.Text = string.format("%d / %d delivered   •   %02d:%02d until dawn", payload.Delivered, payload.Total, minutes, seconds)
		if payload.Phase == "Delivery" then
			if payload.IsCarrier then
				objective.Text = "Parcel collected! Follow the marker to HOUSE " .. payload.House
			elseif payload.Carrier ~= "" then
				objective.Text = "Escort " .. payload.Carrier .. " to house " .. payload.House
			else
				objective.Text = "Follow COLLECT PARCEL " .. payload.House .. " to the box beside the van. Press E or tap."
			end
			rule.Text = "DELIVERY NOTE: " .. payload.Rule
		elseif payload.Phase == "Escape" then
			objective.Text = "Return to the van. Gather your crew and use the driver door!"
			rule.Text = "Something is running behind you."
		elseif payload.Phase == "Intermission" then
			status.Text = "Next shift in " .. payload.Remaining .. " seconds"
			objective.Text = payload.Result
			rule.Text = "Take a breath. Dispatch has another route."
		end
	elseif kind == "Notice" then
		showNotice(payload)
	elseif kind == "Scare" then
		showNotice(payload)
		overlay.BackgroundTransparency = 0.55
		TweenService:Create(overlay, TweenInfo.new(0.8), { BackgroundTransparency = 1 }):Play()
	end
end)

player.CharacterAdded:Connect(function()
	flashlight = false
	sprinting = false
	refreshControls()
end)
remote:FireServer("Ready")
