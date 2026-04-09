-- Xeno Executor Enhanced Aimbot with UI
-- Press '=' key to toggle aimbot on/off

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Configuration
local AIMBOT_KEY = Enum.KeyCode.Equals
local UI_TOGGLE_KEY = Enum.KeyCode.RightShift

-- Default Settings
local Settings = {
    Enabled = false,
    AimPart = "Head",
    FOV = 100,
    Smoothing = 0.05, -- Lower = stronger/smoother aim
    VisibleCheck = false,
    TeamCheck = true,
    WallCheck = false,
    Prediction = 0.1, -- Bullet prediction
    FOVCircle = true,
    SilentAim = false, -- Makes aim less obvious
    TriggerBot = false,
    TriggerDelay = 0.1
}

-- Variables
local connection = nil
local targetPlayer = nil
local uiEnabled = true
local fovCircle = nil

-- Create UI
local function createUI()
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AimbotUI"
    screenGui.Parent = CoreGui
    screenGui.ResetOnSpawn = false
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    title.BorderSizePixel = 0
    title.Text = "ENHANCED AIMBOT"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 14
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = mainFrame
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        uiEnabled = false
    end)
    
    -- Content Frame
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -20, 1, -60)
    contentFrame.Position = UDim2.new(0, 10, 0, 50)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 4
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
    contentFrame.Parent = mainFrame
    
    -- Create Settings Controls
    local yOffset = 10
    
    -- Toggle Aimbot
    local function createToggle(name, setting, yPos)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 30)
        frame.Position = UDim2.new(0, 0, 0, yPos)
        frame.BackgroundTransparency = 1
        frame.Parent = contentFrame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.Parent = frame
        
        local toggleButton = Instance.new("TextButton")
        toggleButton.Name = setting
        toggleButton.Size = UDim2.new(0, 50, 0, 25)
        toggleButton.Position = UDim2.new(1, -55, 0, 2)
        toggleButton.BackgroundColor3 = Settings[setting] and Color3.fromRGB(60, 180, 80) or Color3.fromRGB(180, 60, 60)
        toggleButton.BorderSizePixel = 0
        toggleButton.Text = Settings[setting] and "ON" or "OFF"
        toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleButton.TextSize = 12
        toggleButton.Font = Enum.Font.GothamBold
        toggleButton.Parent = frame
        
        toggleButton.MouseButton1Click:Connect(function()
            Settings[setting] = not Settings[setting]
            toggleButton.BackgroundColor3 = Settings[setting] and Color3.fromRGB(60, 180, 80) or Color3.fromRGB(180, 60, 60)
            toggleButton.Text = Settings[setting] and "ON" or "OFF"
            print(name .. ": " .. (Settings[setting] and "Enabled" or "Disabled"))
        end)
        
        return frame
    end
    
    -- Slider Control
    local function createSlider(name, setting, min, max, yPos)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 50)
        frame.Position = UDim2.new(0, 0, 0, yPos)
        frame.BackgroundTransparency = 1
        frame.Parent = contentFrame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name .. ": " .. Settings[setting]
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.Name = "Label"
        label.Parent = frame
        
        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(1, 0, 0, 10)
        slider.Position = UDim2.new(0, 0, 0, 25)
        slider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        slider.BorderSizePixel = 0
        slider.Parent = frame
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((Settings[setting] - min) / (max - min), 0, 1, 0)
        fill.Position = UDim2.new(0, 0, 0, 0)
        fill.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
        fill.BorderSizePixel = 0
        fill.Parent = slider
        
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0, 20, 0, 20)
        button.Position = UDim2.new((Settings[setting] - min) / (max - min), -10, 0.5, -10)
        button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        button.BorderSizePixel = 0
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
        
        button.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UIS.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateValue(input.Position.X)
            end
        end)
        
        return frame
    end
    
    -- Dropdown for Aim Part
    local function createDropdown(name, setting, options, yPos)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 40)
        frame.Position = UDim2.new(0, 0, 0, yPos)
        frame.BackgroundTransparency = 1
        frame.Parent = contentFrame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
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
        dropdownButton.BorderSizePixel = 0
        dropdownButton.Text = Settings[setting]
        dropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        dropdownButton.TextSize = 12
        dropdownButton.Font = Enum.Font.Gotham
        dropdownButton.Parent = frame
        
        local dropdownOpen = false
        local dropdownFrame
        
        local function toggleDropdown()
            if dropdownOpen then
                if dropdownFrame then
                    dropdownFrame:Destroy()
                end
                dropdownOpen = false
            else
                dropdownFrame = Instance.new("Frame")
                dropdownFrame.Size = UDim2.new(0, 100, 0, #options * 30)
                dropdownFrame.Position = UDim2.new(1, -105, 1, 5)
                dropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                dropdownFrame.BorderSizePixel = 0
                dropdownFrame.ZIndex = 10
                dropdownFrame.Parent = frame
                
                for i, option in ipairs(options) do
                    local optionButton = Instance.new("TextButton")
                    optionButton.Size = UDim2.new(1, 0, 0, 30)
                    optionButton.Position = UDim2.new(0, 0, 0, (i-1)*30)
                    optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                    optionButton.BorderSizePixel = 0
                    optionButton.Text = option
                    optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    optionButton.TextSize = 12
                    optionButton.Font = Enum.Font.Gotham
                    optionButton.Parent = dropdownFrame
                    
                    optionButton.MouseButton1Click:Connect(function()
                        Settings[setting] = option
                        dropdownButton.Text = option
                        toggleDropdown()
                        print(name .. " set to: " .. option)
                    end)
                end
                dropdownOpen = true
            end
        end
        
        dropdownButton.MouseButton1Click:Connect(toggleDropdown)
        
        return frame
    end
    
    -- Create all controls
    yOffset = yOffset + createToggle("Aimbot Enabled", "Enabled", yOffset).Size.Y.Offset + 5
    yOffset = yOffset + createSlider("FOV Size", "FOV", 10, 500, yOffset).Size.Y.Offset + 5
    yOffset = yOffset + createSlider("Smoothness", "Smoothing", 0.01, 1, yOffset).Size.Y.Offset + 5
    yOffset = yOffset + createSlider("Prediction", "Prediction", 0, 0.5, yOffset).Size.Y.Offset + 5
    yOffset = yOffset + createDropdown("Aim Part", "AimPart", {"Head", "HumanoidRootPart", "Torso", "LeftHand", "RightHand"}, yOffset).Size.Y.Offset + 5
    yOffset = yOffset + createToggle("Team Check", "TeamCheck", yOffset).Size.Y.Offset + 5
    yOffset = yOffset + createToggle("Visible Check", "VisibleCheck", yOffset).Size.Y.Offset + 5
    yOffset = yOffset + createToggle("FOV Circle", "FOVCircle", yOffset).Size.Y.Offset + 5
    yOffset = yOffset + createToggle("Silent Aim", "SilentAim", yOffset).Size.Y.Offset + 5
    yOffset = yOffset + createToggle("Trigger Bot", "TriggerBot", yOffset).Size.Y.Offset + 5
    
    if Settings.TriggerBot then
        yOffset = yOffset + createSlider("Trigger Delay", "TriggerDelay", 0.01, 0.5, yOffset).Size.Y.Offset + 5
    end
    
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 20)
    
    -- Make frame draggable
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    
    return screenGui
end

-- Create FOV Circle
local function createFOVCircle()
    if fovCircle then fovCircle:Remove() end
    
    fovCircle = Drawing.new("Circle")
    fovCircle.Visible = Settings.FOVCircle
    fovCircle.Color = Color3.fromRGB(255, 255, 255)
    fovCircle.Thickness = 2
    fovCircle.NumSides = 64
    fovCircle.Radius = Settings.FOV * 2
    fovCircle.Filled = false
    fovCircle.Transparency = 1
    
    RunService.RenderStepped:Connect(function()
        if fovCircle then
            fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            fovCircle.Visible = Settings.FOVCircle and Settings.Enabled
            fovCircle.Radius = Settings.FOV * 2
        end
    end)
end

-- Enhanced raycast function for wall check
local function isVisible(targetPart)
    if not Settings.VisibleCheck then return true end
    
    local origin = Camera.CFrame.Position
    local targetPos = targetPart.Position
    
    -- Add prediction if target is moving
    if targetPart.Velocity then
        targetPos = targetPos + (targetPart.Velocity * Settings.Prediction)
    end
    
    local direction = (targetPos - origin).Unit * (origin - targetPos).Magnitude
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    
    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    
    if raycastResult then
        return raycastResult.Instance:IsDescendantOf(targetPart.Parent)
    end
    
    return true
end

-- Stronger aimbot function with prediction and team check
local function getClosestPlayer()
    local closestPlayer = nil
    local closestDistance = Settings.FOV * 2
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local aimPart = character:FindFirstChild(Settings.AimPart)
            
            if humanoid and humanoid.Health > 0 and aimPart then
                -- Team check
                if Settings.TeamCheck and player.Team == LocalPlayer.Team then
                    continue
                end
                
                -- Visibility check
                if not isVisible(aimPart) then
                    continue
                end
                
                -- Calculate screen position with prediction
                local predictedPosition = aimPart.Position
                if aimPart.Velocity then
                    predictedPosition = predictedPosition + (aimPart.Velocity * Settings.Prediction)
                end
                
                local screenPoint, onScreen = Camera:WorldToViewportPoint(predictedPosition)
                
                if onScreen then
                    local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local targetPos = Vector2.new(screenPoint.X, screenPoint.Y)
                    local distance = (centerScreen - targetPos).Magnitude
                    
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- Stronger aiming algorithm with multiple modes
local function aimAtTarget(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    
    local aimPart = targetPlayer.Character:FindFirstChild(Settings.AimPart)
    if not aimPart then return end
    
    local targetPosition = aimPart.Position
    
    -- Add velocity prediction for moving targets
    if aimPart.Velocity then
        targetPosition = targetPosition + (aimPart.Velocity * Settings.Prediction)
    end
    
    local cameraPosition = Camera.CFrame.Position
    
    if Settings.SilentAim then
        -- Silent aim: Less obvious aiming by slightly offsetting from center
        local direction = (targetPosition - cameraPosition).Unit
        
        -- Add small random offset to make it less detectable
        local offsetAmount = math.random(-10, 10) / 1000
        local offsetVector = Vector3.new(
            math.random(-offsetAmount, offsetAmount),
            math.random(-offsetAmount, offsetAmount),
            math.random(-offsetAmount, offsetAmount)
        )
        
        direction = (direction + offsetVector).Unit
        
        -- Very strong smoothing for silent aim
        local currentLook = Camera.CFrame.LookVector
        local smoothedDirection = currentLook:Lerp(direction, Settings.Smoothing * 0.5)
        
        Camera.CFrame = CFrame.new(cameraPosition, cameraPosition + smoothedDirection)
    else
        -- Normal strong aimbot
        local direction = (targetPosition - cameraPosition).Unit
        
        -- Very strong aiming with minimal smoothing for instant lock
        local currentLook = Camera.CFrame.LookVector
        
        -- Use different smoothing based on distance for better tracking
        local distanceToTarget = (targetPosition - cameraPosition).Magnitude
        local adaptiveSmoothing = math.clamp(Settings.Smoothing * (distanceToTarget / 100), Settings.Smoothing * 0.5, Settings.Smoothing * 2)
        
        local smoothedDirection = currentLook:Lerp(direction, adaptiveSmoothing)
        
        Camera.CFrame = CFrame.new(cameraPosition, cameraPosition + smoothedDirection)
        
        -- Trigger bot functionality
        if Settings.TriggerBot and distanceToTarget < Settings.FOV * 10 then
            task.wait(Settings.TriggerDelay)
            mouse1click()
        end
    end
end

-- Main aimbot loop with enhanced targeting
local function aimbotLoop()
    if not Settings.Enabled or not LocalPlayer.Character then return end
    
    targetPlayer = getClosestPlayer()
    
    if targetPlayer then
        aimAtTarget(targetPlayer)
        
        -- Draw target indicator (optional visual feedback)
        if Settings.FOVCircle then
            -- You could add target highlighting here if desired
        end
    end
end

-- Toggle function with UI feedback
local function toggleAimbot()
    Settings.Enabled = not Settings.Enabled
    
    if Settings.Enabled then
        print("🔥 ENHANCED AIMBOT ENABLED 🔥")
        print(string.format("Settings: FOV=%d | Smoothing=%.2f | Prediction=%.2f", 
            Settings.FOV, Settings.Smoothing, Settings.Prediction))
        
        if not connection then
            connection = RunService.RenderStepped:Connect(aimbotLoop)
        end
        
        createFOVCircle()
    else
        print("Aimbot Disabled")
        
        if connection then
            connection:Disconnect()
            connection = nil
        end
        
        if fovCircle then
            fovCircle.Visible = false
        end
        
        targetPlayer = nil
    end
end

-- Initialize UI and controls
local uiInstance = createUI()
createFOVCircle()

-- Key bindings
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == AIMBOT_KEY then
        toggleAimbot()
    elseif input.KeyCode == UI_TOGGLE_KEY then
        if uiInstance and uiInstance.Parent then
            uiInstance.Enabled = not uiInstance.Enabled
            print("UI " .. (uiInstance.Enabled and "shown" or "hidden"))
        else
            uiInstance = createUI()
            print("UI recreated")
        end
    end
end)

-- Cleanup functions
local function cleanup()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    
    if fovCircle then
        fovCircle:Remove()
        fovCircle = nil
    end
    
    if uiInstance then
        uiInstance:Destroy()
    end
    
    print("Aimbot script cleaned up")
end

-- Auto cleanup on game leave or script stop
game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
    if Settings.Enabled and not connection then
        connection = RunService.RenderStepped:Connect(aimbotLoop)
        createFOVCircle()
    end
end)

game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(function()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    
    if fovCircle then
        fovCircle.Visible = false
    end
end)

-- Script termination hook (for Xeno Executor)
local metaTable = getrawmetatable(game)
local oldNamecall = metaTable.__namecall

metaTable.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    
    if tostring(self) == "AimbotScript" and method == "Destroy" then
        cleanup()
    end
    
    return oldNamecall(self, ...)
end)

print("==========================================")
print("🔥 ENHANCED AIMBOT SCRIPT LOADED 🔥")
print("==========================================")
print("Press '=' to toggle aimbot")
print("Press 'RightShift' to show/hide UI")
print("")
print("Strong Features Enabled:")
print("- Advanced prediction system")
print("- Multiple aim modes (Normal/Silent)")
print("- Team and visibility checks")
print("- Configurable FOV with visual circle")
print("- Trigger bot with adjustable delay")
print("- Smooth UI with draggable window")
print("==========================================")

-- Auto-start aimbot if desired (uncomment to enable)
-- task.wait(2)
-- toggleAimbot()
