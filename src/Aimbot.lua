-- BIPIN_GOOD Final Cam Lock + Distance Changer
-- Hold Right Click = Aim | Right Alt = Toggle Aimbot | Drag Slider = Distance 1-1000

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- ================== SETTINGS ==================
local AimEnabled = true
local FOV = 40
local MaxDistance = 500
local Smoothing = 0.80
local AimPart = "Head"
local FOVVisible = true

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = FOVVisible and AimEnabled
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 50, 50)
FOVCircle.Transparency = 0.4
FOVCircle.Filled = false
FOVCircle.Radius = math.tan(math.rad(FOV)/2) * (Camera.ViewportSize.Y / 2)

-- ================== AIMBOT / CAM LOCK ==================
local RightClickDown = false

Mouse.Button2Down:Connect(function() RightClickDown = true end)
Mouse.Button2Up:Connect(function() RightClickDown = false end)

-- Toggle Aimbot with Right Alt
UserInputService.InputBegan:Connect(function(Input)
   if Input.KeyCode == Enum.KeyCode.RightAlt then
      AimEnabled = not AimEnabled
      FOVCircle.Visible = FOVVisible and AimEnabled
      print("Aimbot " .. (AimEnabled and "ENABLED" or "DISABLED"))
   end
end)

-- Toggle FOV with F
UserInputService.InputBegan:Connect(function(Input)
   if Input.KeyCode == Enum.KeyCode.F then
      FOVVisible = not FOVVisible
      FOVCircle.Visible = FOVVisible and AimEnabled
   end
end)

-- Aim Logic
local function GetBestTarget()
   if not LocalPlayer.Character then return nil end
   local BestTarget = nil
   local BestAngle = math.rad(FOV)

   for _, Player in pairs(Players:GetPlayers()) do
      if Player ~= LocalPlayer and Player.Character then
         local Character = Player.Character
         local Humanoid = Character:FindFirstChildOfClass("Humanoid")
         if Humanoid and Humanoid.Health > 0 then
            local TargetPart = Character:FindFirstChild(AimPart) or Character:FindFirstChild("HumanoidRootPart")
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
   local TargetPos = Target.Position
   local CurrentCFrame = Camera.CFrame
   local Direction = (TargetPos - CurrentCFrame.Position).Unit
   local Smoothed = CurrentCFrame.LookVector:Lerp(Direction, Smoothing)
   Camera.CFrame = CFrame.new(CurrentCFrame.Position, CurrentCFrame.Position + Smoothed)
end

RunService.RenderStepped:Connect(function()
   local ScreenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
   FOVCircle.Position = ScreenCenter
   FOVCircle.Radius = math.tan(math.rad(FOV)/2) * (Camera.ViewportSize.Y / 2)
   FOVCircle.Visible = FOVVisible and AimEnabled
  
   if AimEnabled and RightClickDown then
      local Target = GetBestTarget()
      if Target then 
         AimAt(Target) 
      end
   end
end)

-- ================== DISTANCE CHANGER GUI ==================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 280, 0, 200)
Frame.Position = UDim2.new(0.5, -140, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Text = "BIPIN_GOOD Cam Lock"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

local DistLabel = Instance.new("TextLabel", Frame)
DistLabel.Size = UDim2.new(1, 0, 0, 25)
DistLabel.Position = UDim2.new(0, 0, 0, 50)
DistLabel.BackgroundTransparency = 1
DistLabel.Text = "Max Aim Distance: " .. MaxDistance .. " studs"
DistLabel.TextColor3 = Color3.new(1,1,1)
DistLabel.TextSize = 15

local DistanceSlider = Instance.new("TextButton", Frame)
DistanceSlider.Size = UDim2.new(0.9, 0, 0, 30)
DistanceSlider.Position = UDim2.new(0.05, 0, 0, 80)
DistanceSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
DistanceSlider.Text = "← Drag Here to Change Distance →"

local dragging = false
DistanceSlider.MouseButton1Down:Connect(function() dragging = true end)

UserInputService.InputEnded:Connect(function(input)
   if input.UserInputType == Enum.UserInputType.MouseButton1 then 
      dragging = false 
   end
end)

RunService.RenderStepped:Connect(function()
   if dragging then
      local mouseX = Mouse.X
      local sliderX = DistanceSlider.AbsolutePosition.X
      local sliderWidth = DistanceSlider.AbsoluteSize.X
      local percent = math.clamp((mouseX - sliderX) / sliderWidth, 0, 1)
      MaxDistance = math.floor(1 + percent * 999) -- 1 to 1000 studs
      DistLabel.Text = "Max Aim Distance: " .. MaxDistance .. " studs"
   end
end)

print("========================================")
print("🎯 BIPIN_GOOD Cam Lock Loaded 🎯")
print("========================================")
print("🖱️ Hold RIGHT CLICK → Aim Lock")
print("🎮 RIGHT ALT → Toggle Aimbot")
print("👁️ F → Toggle FOV Circle")
print("📏 Drag the slider → Change Distance (1-1000 studs)")
print("========================================")
