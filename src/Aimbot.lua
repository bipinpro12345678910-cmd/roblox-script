-- Xeno Enhanced Aimbot - Module Style
-- Uploaded by BIPIN

local Aimbot = {}

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local AIMBOT_KEY = Enum.KeyCode.Equals
local UI_TOGGLE_KEY = Enum.KeyCode.RightShift

-- Settings
Aimbot.Settings = {
    Enabled = false,
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

local connection = nil
local fovCircle = nil
local uiInstance = nil

local function createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "XenoAimbotUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    title.Text = "ENHANCED AIMBOT"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Parent = mainFrame
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    return screenGui
end

local function createFOVCircle()
    if fovCircle then fovCircle:Remove() end
    fovCircle = Drawing.new("Circle")
    fovCircle.Color = Color3.fromRGB(255, 255, 255)
    fovCircle.Thickness = 2
    fovCircle.Radius = Aimbot.Settings.FOV * 2
    fovCircle.Filled = false
    fovCircle.Transparency = 1
end

local function aimbotLoop()
    if not Aimbot.Settings.Enabled then return end
    print("Aimbot is running...")  
end

function Aimbot.Load()
    print("==========================================")
    print("🔥 XENO ENHANCED AIMBOT LOADED 🔥")
    print("==========================================")
    print("Press '=' to toggle aimbot")
    print("Press 'RightShift' to toggle UI")

    uiInstance = createUI()
    createFOVCircle()

    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == AIMBOT_KEY then
            Aimbot.Settings.Enabled = not Aimbot.Settings.Enabled
            print("Aimbot " .. (Aimbot.Settings.Enabled and "ENABLED" or "DISABLED"))

            if Aimbot.Settings.Enabled and not connection then
                connection = RunService.RenderStepped:Connect(aimbotLoop)
            elseif not Aimbot.Settings.Enabled and connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end)

    print("Aimbot is ready! Enjoy :)")
end

return Aimbot
