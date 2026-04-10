-- Xeno Executor Enhanced Aimbot Script
-- Right-click to aim at head, Right Alt to toggle, shows FOV visualization

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local AimEnabled = true
local FOV = 40
local Smoothing = 1
local AimPart = "Head"
local FOVVisible = true
local FOVRad = math.rad(FOV)
local Camera = workspace.CurrentCamera

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = FOVVisible and AimEnabled
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 50, 50)
FOVCircle.Transparency = 0.3
FOVCircle.Filled = false
FOVCircle.Radius = math.tan(FOVRad/2) * 180

-- Get Best Target
local function GetBestTarget()
    if not LocalPlayer.Character then return nil end
    local MyRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not MyRoot then return nil end
  
    local MyDirection = Camera.CFrame.LookVector
    local BestTarget = nil
    local BestDistance = FOVRad
    local BestPosition = nil
  
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
            local Character = Player.Character
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
          
            if Humanoid and Humanoid.Health > 0 then
                local Head = Character:FindFirstChild("Head")
                local HRP = Character:FindFirstChild("HumanoidRootPart")
              
                local TargetPart = Head or HRP
                if not TargetPart then continue end
              
                local TargetPosition = TargetPart.Position
                local DirectionToTarget = (TargetPosition - Camera.CFrame.Position).Unit
              
                local DotProduct = MyDirection:Dot(DirectionToTarget)
                local Angle = math.acos(math.clamp(DotProduct, -1, 1))
              
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

-- Aim Function
local function AimAtHead(Target, HeadPosition)
    if not Target or not HeadPosition then return end
  
    local CurrentCFrame = Camera.CFrame
    local TargetPosition = HeadPosition + Vector3.new(0, -0.2, 0) -- slight head offset
  
    local Direction = (TargetPosition - CurrentCFrame.Position).Unit
    local CurrentLook = CurrentCFrame.LookVector
    local SmoothedDirection = CurrentLook:Lerp(Direction, Smoothing)
  
    Camera.CFrame = CFrame.new(CurrentCFrame.Position, CurrentCFrame.Position + SmoothedDirection)
end

-- Right Click Handling
local RightClickDown = false
Mouse.Button2Down:Connect(function() RightClickDown = true end)
Mouse.Button2Up:Connect(function() RightClickDown = false end)

-- Toggle with RIGHT ALT (changed from LeftAlt)
UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if GameProcessed then return end -- Prevents triggering while typing in chat
   
    if Input.KeyCode == Enum.KeyCode.RightAlt then
        AimEnabled = not AimEnabled
        FOVCircle.Visible = FOVVisible and AimEnabled
       
        print("Aimbot " .. (AimEnabled and "ENABLED 🔴" or "DISABLED ⚫"))
        print("FOV: " .. FOV .. "° | Smoothing: " .. Smoothing .. " | Target: " .. AimPart)
    end
end)

-- Toggle FOV Circle with F key
UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if GameProcessed then return end
    if Input.KeyCode == Enum.KeyCode.F then
        FOVVisible = not FOVVisible
        FOVCircle.Visible = FOVVisible and AimEnabled
        print("FOV Circle " .. (FOVVisible and "VISIBLE" or "HIDDEN"))
    end
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    -- Update FOV Circle
    local ScreenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Position = ScreenCenter
    FOVCircle.Visible = FOVVisible and AimEnabled
    FOVCircle.Radius = math.tan(FOVRad/2) * 180
   
    if AimEnabled then
        FOVCircle.Color = RightClickDown and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
    end
    -- Aimbot Logic
    if AimEnabled and RightClickDown then
        local Target, HeadPosition = GetBestTarget()
        if Target and HeadPosition then
            AimAtHead(Target, HeadPosition)
        end
    end
end)

-- Cleanup
local function Cleanup()
    if FOVCircle then FOVCircle:Remove() end
end
game:GetService("StarterGui"):SetCore("ResetButtonCallback", Cleanup)

-- Load Message (Updated)
print("========================================")
print("🎯 ENHANCED AIMBOT LOADED 🎯")
print("========================================")
print("🖱️ Hold RIGHT CLICK to aim at HEAD")
print("🎮 Press RIGHT ALT to toggle aimbot")   -- Updated here
print("👁️ Press F to toggle FOV circle")
print("🎯 FOV: " .. FOV .. "° | Smoothing: " .. Smoothing)
print("💀 Targeting: HEAD")
print("🔴 FOV Circle: " .. (FOVVisible and "VISIBLE" or "HIDDEN"))
print("========================================")
