-- Xeno Executor Enhanced Aimbot with UI
-- Hold Right Click to Aim at Head
-- Press G to Toggle All Hacks ON/OFF

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Configuration
local MASTER_TOGGLE_KEY = Enum.KeyCode.G
local UI_TOGGLE_KEY = Enum.KeyCode.RightShift

-- Default Settings
local Settings = {
    Enabled = true,           -- Master switch (controlled by G key)
    AimPart = "Head",
    FOV = 100,
    Smoothing = 0.05,
    VisibleCheck = false,
    TeamCheck = true,
    Prediction = 0.1,
    FOVCircle = true,
    SilentAim = false,
    TriggerBot = false,
    TriggerDelay = 0.1
}

-- Variables
local connection = nil
local fovCircle = nil
local isAiming = false          -- Right click state
local allHacksEnabled = true    -- Master toggle (G key)
local uiInstance = nil

-- Create UI
local function createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AimbotUI"
    screenGui.Parent = CoreGui
    screenGui.ResetOnSpawn = false

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    title.Text = "ENHANCED AIMBOT (Hold RMB)"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = mainFrame

    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Size = UDim2.new(1, -20, 1, -60)
    contentFrame.Position = UDim2.new(0, 10, 0, 50)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ScrollBarThickness = 4
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
    contentFrame.Parent = mainFrame

    local yOffset = 10

    local function createToggle(name, setting, yPos)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 30)
        frame.Position = UDim2.new(0, 0, 0, yPos)
        frame.BackgroundTransparency = 1
        frame.Parent = contentFrame

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.Text = name
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.Parent = frame

        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(0, 50, 0, 25)
        toggleBtn.Position = UDim2.new(1, -55, 0, 2)
        toggleBtn.BackgroundColor3 = Settings[setting] and Color3.fromRGB(60, 180, 80) or Color3.fromRGB(180, 60, 60)
        toggleBtn.Text = Settings[setting] and "ON" or "OFF"
        toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleBtn.Font = Enum.Font.GothamBold
        toggleBtn.Parent = frame

        toggleBtn.MouseButton1Click:Connect(function()
            Settings[setting] = not Settings[setting]
            toggleBtn.BackgroundColor3 = Settings[setting] and Color3.fromRGB(60, 180, 80) or Color3.fromRGB(180, 60, 60)
            toggleBtn.Text = Settings[setting] and "ON" or "OFF"
        end)
        return frame
    end

    local function createSlider(name, setting, min, max, yPos)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 50)
        frame.Position = UDim2.new(0, 0, 0, yPos)
        frame.BackgroundTransparency = 1
        frame.Parent = contentFrame

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.Text = name .. ": " .. Settings[setting]
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.Parent = frame

        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(1, 0, 0, 10)
        slider.Position = UDim2.new(0, 0, 0, 25)
        slider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        slider.Parent = frame

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((Settings[setting] - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
        fill.Parent = slider

        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0, 20, 0, 20)
        button.Position = UDim2.new((Settings[setting] - min) / (max - min), -10, 0.5, -10)
        button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        button.Text = ""
        button.Parent = slider

        local dragging = false

        local function updateValue(x)
            local relativeX = math.clamp((x - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            local value = min + (relativeX * (max - min))
            value = math.floor(value * 100) / 100

            Settings[setting] = value
            fill.Size = UDim2.new(relativeX, 0, 1, 0)
            button.Position = UDim2.new(relativeX, -10, 0.5, -10)
            label.Text = name .. ": " .. value

            if setting == "FOV" and fovCircle then
                fovCircle.Radius = Settings.FOV * 2
            end
        end

        button.MouseButton1Down:Connect(function() dragging = true end)

        UIS.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateValue(input.Position.X)
            end
        end)

        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)

        return frame
    end

    local function createDropdown(name, setting, options, yPos)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 40)
        frame.Position = UDim2.new(0, 0, 0, yPos)
        frame.BackgroundTransparency = 1
        frame.Parent = contentFrame

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.Text = name
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.Parent = frame

        local dropdownButton = Instance.new("TextButton")
        dropdownButton.Size = UDim2.new(0, 100, 0, 30)
        dropdownButton.Position = UDim2.new(1, -105, 0.5, -15)
        dropdownButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        dropdownButton.Text = Settings[setting]
        dropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        dropdownButton.Parent = frame

        local open = false
        local dropFrame

        local function toggleDrop()
            if open then
                if dropFrame then dropFrame:Destroy() end
                open = false
            else
                dropFrame = Instance.new("Frame")
                dropFrame.Size = UDim2.new(0, 100, 0, #options * 30)
                dropFrame.Position = UDim2.new(1, -105, 1, 5)
                dropFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                dropFrame.ZIndex = 10
                dropFrame.Parent = frame

                for i, opt in ipairs(options) do
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, 0, 0, 30)
                    btn.Position = UDim2.new(0, 0, 0, (i-1)*30)
                    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                    btn.Text = opt
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    btn.Parent = dropFrame

                    btn.MouseButton1Click:Connect(function()
                        Settings[setting] = opt
                        dropdownButton.Text = opt
                        toggleDrop()
                    end)
                end
                open = true
            end
        end

        dropdownButton.MouseButton1Click:Connect(toggleDrop)
        return frame
    end

    -- Controls
    yOffset = yOffset + createToggle("Aimbot Enabled", "Enabled", yOffset).Size.Y.Offset + 5
    yOffset = yOffset + createSlider("FOV Size", "FOV", 10, 500, yOffset).Size.Y.Offset + 5
    yOffset = yOffset + createSlider("Smoothness", "Smoothing", 0.01, 1, yOffset).Size.Y.Offset + 5
    yOffset = yOffset + createSlider("Prediction", "Prediction", 0, 0.5, yOffset).Size.Y.Offset + 5
    yOffset = yOffset + createDropdown("Aim Part", "AimPart", {"Head", "HumanoidRootPart", "Torso"}, yOffset).Size.Y.Offset + 5
    yOffset = yOffset + createToggle("Team Check", "TeamCheck", yOffset).Size.Y.Offset + 5
    yOffset = yOffset + createToggle("Visible Check", "VisibleCheck", yOffset).Size.Y.Offset + 5
    yOffset = yOffset + createToggle("FOV Circle", "FOVCircle", yOffset).Size.Y.Offset + 5
    yOffset = yOffset + createToggle("Silent Aim", "SilentAim", yOffset).Size.Y.Offset + 5
    yOffset = yOffset + createToggle("Trigger Bot", "TriggerBot", yOffset).Size.Y.Offset + 5

    contentFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 20)

    -- Draggable UI
    local dragging = false
    local dragStart, startPos

    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return screenGui
end

-- Create FOV Circle
local function createFOVCircle()
    if fovCircle then fovCircle:Remove() end
    fovCircle = Drawing.new("Circle")
    fovCircle.Color = Color3.fromRGB(255, 255, 255)
    fovCircle.Thickness = 2
    fovCircle.NumSides = 64
    fovCircle.Filled = false
    fovCircle.Transparency = 1
    fovCircle.Radius = Settings.FOV * 2

    RunService.RenderStepped:Connect(function()
        if fovCircle then
            fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            fovCircle.Visible = Settings.FOVCircle and allHacksEnabled and Settings.Enabled
        end
    end)
end

-- Visibility Check
local function isVisible(targetPart)
    if not Settings.VisibleCheck then return true end
    local origin = Camera.CFrame.Position
    local targetPos = targetPart.Position + (targetPart.Velocity or Vector3.new()) * Settings.Prediction

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}

    local result = workspace:Raycast(origin, (targetPos - origin), rayParams)
    return not result or result.Instance:IsDescendantOf(targetPart.Parent)
end

-- Get closest player
local function getClosestPlayer()
    local closest = nil
    local minDist = Settings.FOV * 2

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local part = plr.Character:FindFirstChild(Settings.AimPart)

            if hum and hum.Health > 0 and part then
                if Settings.TeamCheck and plr.Team == LocalPlayer.Team then continue end
                if not isVisible(part) then continue end

                local predicted = part.Position + (part.Velocity or Vector3.new()) * Settings.Prediction
                local screen, onScreen = Camera:WorldToViewportPoint(predicted)

                if onScreen then
                    local dist = (Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2) - Vector2.new(screen.X, screen.Y)).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closest = plr
                    end
                end
            end
        end
    end
    return closest
end

-- Aim function
local function aimAtTarget(target)
    if not target or not target.Character then return end
    local aimPart = target.Character:FindFirstChild(Settings.AimPart)
    if not aimPart then return end

    local targetPos = aimPart.Position + (aimPart.Velocity or Vector3.new()) * Settings.Prediction
    local camPos = Camera.CFrame.Position
    local direction = (targetPos - camPos).Unit

    local smoothed = Camera.CFrame.LookVector:Lerp(direction, Settings.Smoothing)
    Camera.CFrame = CFrame.new(camPos, camPos + smoothed)
end

-- Main aimbot loop
local function aimbotLoop()
    if not allHacksEnabled or not Settings.Enabled or not isAiming then return end

    local target = getClosestPlayer()
    if target then
        aimAtTarget(target)
    end
end

-- Master Toggle (G Key)
local function toggleAllHacks()
    allHacksEnabled = not allHacksEnabled

    if allHacksEnabled then
        print("🔥 ALL HACKS ENABLED - Hold Right Click to Aim")
        if not connection then
            connection = RunService.RenderStepped:Connect(aimbotLoop)
        end
        if not fovCircle then createFOVCircle() end
    else
        print("⛔ ALL HACKS DISABLED")
        isAiming = false
        if connection then
            connection:Disconnect()
            connection = nil
        end
        if fovCircle then
            fovCircle.Visible = false
        end
    end
end

-- Right Click Handling
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end

    if input.UserInputType == Enum.UserInputType.MouseButton2 then  -- Right Click
        if allHacksEnabled then
            isAiming = true
            if not connection then
                connection = RunService.RenderStepped:Connect(aimbotLoop)
            end
        end
    elseif input.KeyCode == MASTER_TOGGLE_KEY then  -- G Key
        toggleAllHacks()
    elseif input.KeyCode == UI_TOGGLE_KEY then     -- Right Shift
        if uiInstance and uiInstance.Parent then
            uiInstance.Enabled = not uiInstance.Enabled
        else
            uiInstance = createUI()
        end
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isAiming = false
    end
end)

-- Initialize
uiInstance = createUI()
createFOVCircle()

print("==========================================")
print("🔥 ENHANCED AIMBOT LOADED 🔥")
print("==========================================")
print("Hold Right Mouse Button (RMB) → Aim at Head")
print("Press G → Turn ALL hacks ON / OFF")
print("Press RightShift → Show/Hide UI")
print("==========================================")
