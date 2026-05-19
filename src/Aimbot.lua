-- // DRP Aimbot - Sticky Cam Lock
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ================== SETTINGS ==================
local AimEnabled = true
local FOV = 80
local MaxDistance = 300
local Smoothing = 0.90
local AimPart = "Head"
local FOVVisible = true
local AUTO_SHOOT = true
local PREDICTION = 0.12

-- ================== VARIABLES ==================
local currentTarget = nil

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(0, 170, 255)
FOVCircle.Transparency = 0.5
FOVCircle.Filled = false
FOVCircle.NumSides = 100

-- ================== GUI ==================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DRPAimbot"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 290, 0, 380)
MainFrame.Position = UDim2.new(1, -310, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(255, 0, 100)
Title.Text = "DRP Aimbot"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local ResetBtn = Instance.new("TextButton")
ResetBtn.Size = UDim2.new(0, 80, 0, 25)
ResetBtn.Position = UDim2.new(1, -90, 0, 10)
ResetBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
ResetBtn.Text = "Reset Pos"
ResetBtn.TextColor3 = Color3.new(1,1,1)
ResetBtn.TextSize = 14
ResetBtn.Parent = MainFrame
ResetBtn.MouseButton1Click:Connect(function()
    MainFrame.Position = UDim2.new(1, -310, 0.5, -190)
end)

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -20, 0, 45)
ToggleBtn.Position = UDim2.new(0, 10, 0, 55)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
ToggleBtn.Text = "Aimbot: ON"
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.TextSize = 16
ToggleBtn.Font = Enum.Font.GothamSemibold
ToggleBtn.Parent = MainFrame

-- FOV & Distance
local FovLabel = Instance.new("TextLabel")
FovLabel.Position = UDim2.new(0, 10, 0, 110)
FovLabel.Size = UDim2.new(1, -20, 0, 20)
FovLabel.BackgroundTransparency = 1
FovLabel.Text = "FOV: "..FOV
FovLabel.TextColor3 = Color3.new(1,1,1)
FovLabel.TextXAlignment = Enum.TextXAlignment.Left
FovLabel.Parent = MainFrame

local FovBox = Instance.new("TextBox")
FovBox.Position = UDim2.new(0, 10, 0, 135)
FovBox.Size = UDim2.new(1, -20, 0, 35)
FovBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
FovBox.Text = tostring(FOV)
FovBox.TextColor3 = Color3.new(1,1,1)
FovBox.Parent = MainFrame

local DistLabel = Instance.new("TextLabel")
DistLabel.Position = UDim2.new(0, 10, 0, 180)
DistLabel.Size = UDim2.new(1, -20, 0, 20)
DistLabel.BackgroundTransparency = 1
DistLabel.Text = "Max Distance: "..MaxDistance
DistLabel.TextColor3 = Color3.new(1,1,1)
DistLabel.TextXAlignment = Enum.TextXAlignment.Left
DistLabel.Parent = MainFrame

local DistBox = Instance.new("TextBox")
DistBox.Position = UDim2.new(0, 10, 0, 205)
DistBox.Size = UDim2.new(1, -20, 0, 35)
DistBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
DistBox.Text = tostring(MaxDistance)
DistBox.TextColor3 = Color3.new(1,1,1)
DistBox.Parent = MainFrame

local function CreateToggle(text, yOffset, default, callback)
    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(1, -20, 0, 40)
    Toggle.Position = UDim2.new(0, 10, 0, yOffset)
    Toggle.BackgroundColor3 = default and Color3.fromRGB(0, 170, 80) or Color3.fromRGB(170, 50, 50)
    Toggle.Text = text
    Toggle.TextColor3 = Color3.new(1,1,1)
    Toggle.TextSize = 15
    Toggle.Parent = MainFrame
   
    Toggle.MouseButton1Click:Connect(function()
        default = not default
        Toggle.BackgroundColor3 = default and Color3.fromRGB(0, 170, 80) or Color3.fromRGB(170, 50, 50)
        callback(default)
    end)
end

CreateToggle("Show FOV Circle", 255, true, function(v) FOVVisible = v end)
CreateToggle("Auto Shoot", 305, true, function(v) AUTO_SHOOT = v end)

-- ================== FUNCTIONS ==================
local function GetBestTarget()
    if not LocalPlayer.Character then return nil end
    local BestTarget = nil
    local BestAngle = math.rad(FOV)

    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
            local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
            if Humanoid and Humanoid.Health > 0 then
                local TargetPart = Player.Character:FindFirstChild(AimPart) or Player.Character:FindFirstChild("UpperTorso")
                if TargetPart then
                    local Dist = (TargetPart.Position - Camera.CFrame.Position).Magnitude
                    if Dist > MaxDistance then continue end

                    local Direction = (TargetPart.Position - Camera.CFrame.Position).Unit
                    local Angle = math.acos(Camera.CFrame.LookVector:Dot(Direction))

                    if Angle < BestAngle then
                        BestAngle = Angle
                        BestTarget = TargetPart
                    end
                end
            end
        end
    end
    return BestTarget
end

local function AimAt(Target)
    if not Target then return end
    local TargetPos = Target.Position + (Target.Velocity * PREDICTION)
    local CurrentCFrame = Camera.CFrame
    local Direction = (TargetPos - CurrentCFrame.Position).Unit
    local Smoothed = CurrentCFrame.LookVector:Lerp(Direction, Smoothing)
    Camera.CFrame = CFrame.new(CurrentCFrame.Position, CurrentCFrame.Position + Smoothed)
end

-- ================== MAIN LOOP ==================
RunService.RenderStepped:Connect(function()
    local ScreenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Position = ScreenCenter
    FOVCircle.Radius = math.tan(math.rad(FOV)/2) * (Camera.ViewportSize.Y / 2)
    FOVCircle.Visible = FOVVisible and AimEnabled

    local isHolding = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)

    if AimEnabled and isHolding then
        if not currentTarget or not currentTarget.Parent then
            currentTarget = GetBestTarget()
        end
        if currentTarget then
            AimAt(currentTarget)
        end
    else
        currentTarget = nil
    end
end)

-- ================== CONTROLS ==================
ToggleBtn.MouseButton1Click:Connect(function()
    AimEnabled = not AimEnabled
    ToggleBtn.Text = AimEnabled and "Aimbot: ON" or "Aimbot: OFF"
    ToggleBtn.BackgroundColor3 = AimEnabled and Color3.fromRGB(0, 170, 80) or Color3.fromRGB(170, 50, 50)
end)

UserInputService.InputBegan:Connect(function(Input)
    if Input.KeyCode == Enum.KeyCode.RightAlt then
        AimEnabled = not AimEnabled
        ToggleBtn.Text = AimEnabled and "Aimbot: ON" or "Aimbot: OFF"
        ToggleBtn.BackgroundColor3 = AimEnabled and Color3.fromRGB(0, 170, 80) or Color3.fromRGB(170, 50, 50)
    end
end)

FovBox.FocusLost:Connect(function(enter)
    if enter then
        local num = tonumber(FovBox.Text)
        if num then
            FOV = math.clamp(num, 10, 300)
            FovLabel.Text = "FOV: " .. FOV
        end
    end
end)

DistBox.FocusLost:Connect(function(enter)
    if enter then
        local num = tonumber(DistBox.Text)
        if num then
            MaxDistance = math.clamp(num, 50, 2000)
            DistLabel.Text = "Max Distance: " .. MaxDistance
        end
    end
end)

spawn(function()
    while task.wait(0.07) do
        if AUTO_SHOOT and AimEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            mouse1click()
        end
    end
end)

print("========================================")
print("🎯 DRP Aimbot Loaded Successfully 🎯")
print("========================================")
print("🖱️ Hold RIGHT CLICK → Sticky Aim Lock")
print("🎮 Right Alt → Toggle Aimbot")
print("👁️ FOV & Distance adjustable in GUI")
print("========================================")
