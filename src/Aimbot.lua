-- Xeno Executor Enhanced Aimbot Script
-- Right-click to aim at head, G key toggle, shows FOV visualization

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local AimEnabled = true
local FOV = 40 -- Field of View in degrees
local Smoothing = 1-- Stronger aim (lower = faster/snappier)
local AimPart = "Head" -- Always aim for head
local FOVVisible = true -- Show FOV circle

-- Convert FOV to radians for calculations
local FOVRad = math.rad(FOV)

-- Get the camera
local Camera = workspace.CurrentCamera

-- Create FOV circle visualization
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = FOVVisible and AimEnabled
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 50, 50)
FOVCircle.Transparency = 0.3
FOVCircle.Filled = false
FOVCircle.Radius = math.tan(FOVRad/2) * 180 -- Adjusted for better visibility

-- Function to find the best target within FOV (prioritizes head)
local function GetBestTarget()
    if not LocalPlayer.Character then return nil end
    local MyRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not MyRoot then return nil end
    
    local MyPosition = MyRoot.Position
    local MyDirection = Camera.CFrame.LookVector
    
    local BestTarget = nil
    local BestDistance = FOVRad
    local BestPosition = nil
    
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
            local Character = Player.Character
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            
            if Humanoid and Humanoid.Health > 0 then
                -- Try to get head first, fall back to HumanoidRootPart
                local Head = Character:FindFirstChild("Head")
                local HRP = Character:FindFirstChild("HumanoidRootPart")
                
                local TargetPart = Head or HRP
                if not TargetPart then continue end
                
                local TargetPosition = TargetPart.Position
                
                -- Calculate direction to target
                local DirectionToTarget = (TargetPosition - Camera.CFrame.Position).Unit
                
                -- Calculate angle between camera direction and target
                local DotProduct = MyDirection:Dot(DirectionToTarget)
                local Angle = math.acos(math.clamp(DotProduct, -1, 1))
                
                -- Check if target is within FOV and closer to crosshair
                if Angle < BestDistance then
                    BestDistance = Angle
                    BestTarget = TargetPart
                    BestPosition = Head and Head.Position or TargetPosition
                end
            end
        end
    end
    
    return BestTarget, BestPosition
end

-- Strong aim function with head targeting
local function AimAtHead(Target, HeadPosition)
    if not Target or not HeadPosition then return end
    
    local CurrentCFrame = Camera.CFrame
    local TargetPosition = HeadPosition
    
    -- Add slight offset for better headshots
    local HeadOffset = Vector3.new(0, -0.2, 0) -- Adjusts aim slightly lower on head
    TargetPosition = TargetPosition + HeadOffset
    
    -- Calculate direction to target
    local Direction = (TargetPosition - CurrentCFrame.Position).Unit
    
    -- Strong, snappy aiming with minimal smoothing
    local CurrentLook = CurrentCFrame.LookVector
    local SmoothedDirection = CurrentLook:Lerp(Direction, Smoothing)
    
    -- Apply stronger aim (snappier movement)
    Camera.CFrame = CFrame.new(CurrentCFrame.Position, CurrentCFrame.Position + SmoothedDirection)
end

-- Right-click hold aimbot
local RightClickDown = false

Mouse.Button2Down:Connect(function()
    RightClickDown = true
end)

Mouse.Button2Up:Connect(function()
    RightClickDown = false
end)

-- Toggle with G key
UserInputService.InputBegan:Connect(function(Input)
    if Input.KeyCode == Enum.KeyCode.G then
        AimEnabled = not AimEnabled
        FOVCircle.Visible = FOVVisible and AimEnabled
        print("Aimbot " .. (AimEnabled and "ENABLED" and "🔴" or "DISABLED" and "⚫"))
        print("FOV: " .. FOV .. "° | Aim Part: " .. AimPart)
    end
end)

-- Toggle FOV visibility with F key (optional)
UserInputService.InputBegan:Connect(function(Input)
    if Input.KeyCode == Enum.KeyCode.F then
        FOVVisible = not FOVVisible
        FOVCircle.Visible = FOVVisible and AimEnabled
        print("FOV Circle " .. (FOVVisible and "VISIBLE" or "HIDDEN"))
    end
end)

-- Update FOV circle position and size
RunService.RenderStepped:Connect(function()
    -- Update FOV circle
    local ScreenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Position = ScreenCenter
    FOVCircle.Visible = FOVVisible and AimEnabled
    
    -- Adjust FOV circle radius based on distance for better visibility
    FOVCircle.Radius = math.tan(FOVRad/2) * 180
    
    -- Change color based on state
    if AimEnabled then
        FOVCircle.Color = RightClickDown and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
    end
    
    -- Main aim logic
    if AimEnabled and RightClickDown then
        local Target, HeadPosition = GetBestTarget()
        if Target and HeadPosition then
            AimAtHead(Target, HeadPosition)
        end
    end
end)

-- Cleanup function
local function Cleanup()
    if FOVCircle then
        FOVCircle:Remove()
    end
end

-- Auto-cleanup on script stop
game:GetService("StarterGui"):SetCore("ResetButtonCallback", Cleanup)

print("========================================")
print("🎯 ENHANCED AIMBOT LOADED 🎯")
print("========================================")
print("🖱️  Hold RIGHT CLICK to aim at HEAD")
print("🎮 Press G to toggle aimbot")
print("👁️  Press F to toggle FOV circle")
print("🎯 FOV: " .. FOV .. "° | Smoothing: " .. Smoothing)
print("💀 Targeting: HEAD")
print("🔴 FOV Circle: " .. (FOVVisible and "VISIBLE" or "HIDDEN"))
print("========================================")
