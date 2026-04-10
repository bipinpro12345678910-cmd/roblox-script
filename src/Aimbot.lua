-- BIPIN_GOOD Enhanced Cam Lock / Aimbot with Distance Slider + ESP
-- Hold Right Click to Aim | Right Alt to Toggle Aimbot + GUI | F to toggle FOV Circle

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local AimEnabled = true
local GUIEnabled = true
local FOV = 40
local MaxDistance = 500
local Smoothing = 0.15
local AimPart = "Head"
local FOVVisible = true

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 50, 50)
FOVCircle.Transparency = 0.4
FOVCircle.Filled = false
FOVCircle.Radius = math.tan(math.rad(FOV)/2) * (Camera.ViewportSize.Y / 2)

-- Simple Draggable GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 260, 0, 180)
Frame.Position = UDim2.new(0.5, -130, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Text = "BIPIN_GOOD Aimbot + Distance"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

-- Distance Label
local DistLabel = Instance.new("TextLabel", Frame)
DistLabel.Size = UDim2.new(1, 0, 0, 20)
DistLabel.Position = UDim2.new(0, 0, 0, 45)
DistLabel.BackgroundTransparency = 1
DistLabel.Text = "Max Aim Distance: " .. MaxDistance .. " studs"
DistLabel.TextColor3 = Color3.new(1,1,1)
DistLabel.TextSize = 14

-- Distance Slider
local DistanceSlider = Instance.new("TextButton", Frame)
DistanceSlider.Size = UDim2.new(0.9, 0, 0, 25)
DistanceSlider.Position = UDim2.new(0.05, 0, 0, 70)
DistanceSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
DistanceSlider.Text = ""
DistanceSlider.TextColor3 = Color3.new(1,1,1)

local dragging = false

DistanceSlider.MouseButton1Down:Connect(function()
   dragging = true
end)

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
      MaxDistance = math.floor(100 + percent * 900) -- 100 to 1000 studs
      
      DistLabel.Text = "Max Aim Distance: " .. MaxDistance .. " studs"
   end
end)

-- ESP Table
local ESP = {}

local function CreateESP(Player)
   if Player == LocalPlayer then return end
   
   local Billboard = Instance.new("BillboardGui")
   Billboard.Adornee = nil
   Billboard.Size = UDim2.new(0, 200, 0, 60)
   Billboard.StudsOffset = Vector3.new(0, 3, 0)
   Billboard.AlwaysOnTop = true
   Billboard.LightInfluence = 0
   Billboard.Enabled = true
   
   -- Name Label
   local NameLabel = Instance.new("TextLabel", Billboard)
   NameLabel.Size = UDim2.new(1, 0, 0.5, 0)
   NameLabel.BackgroundTransparency = 1
   NameLabel.Text = Player.Name
   NameLabel.TextColor3 = Color3.new(1, 1, 1)
   NameLabel.TextStrokeTransparency = 0.5
   NameLabel.Font = Enum.Font.SourceSansBold
   NameLabel.TextSize = 16
   
   -- Avatar (Headshot)
   local Avatar = Instance.new("ImageLabel", Billboard)
   Avatar.Size = UDim2.new(0, 40, 0, 40)
   Avatar.Position = UDim2.new(0.5, -20, 0.5, 0)
   Avatar.BackgroundTransparency = 1
   Avatar.Image = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
   
   ESP[Player] = Billboard
end

-- Update ESP
local function UpdateESP()
   for _, Player in pairs(Players:GetPlayers()) do
      if Player ~= LocalPlayer and Player.Character then
         local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
         local RootPart = Player.Character:FindFirstChild("HumanoidRootPart")
         
         if Humanoid and Humanoid.Health > 0 and RootPart then
            local Dist = (RootPart.Position - Camera.CFrame.Position).Magnitude
            if not ESP[Player] then
               CreateESP(Player)
            end
            
            local Billboard = ESP[Player]
            Billboard.Adornee = RootPart
            Billboard.Enabled = GUIEnabled and AimEnabled  -- Show ESP only when aimbot + gui is on
         elseif ESP[Player] then
            ESP[Player].Enabled = false
         end
      end
   end
end

-- Get Best Target
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

-- Aim Function
local function AimAt(Target)
   if not Target then return end
   local TargetPos = Target.Position
   local CurrentCFrame = Camera.CFrame
   local Direction = (TargetPos - CurrentCFrame.Position).Unit
   local Smoothed = CurrentCFrame.LookVector:Lerp(Direction, Smoothing)
   
   Camera.CFrame = CFrame.new(CurrentCFrame.Position, CurrentCFrame.Position + Smoothed)
end

-- Right Click Hold
local RightClickDown = false
Mouse.Button2Down:Connect(function() RightClickDown = true end)
Mouse.Button2Up:Connect(function() RightClickDown = false end)

-- Toggle Aimbot + GUI with Right Alt
UserInputService.InputBegan:Connect(function(Input)
   if Input.KeyCode == Enum.KeyCode.RightAlt then
      AimEnabled = not AimEnabled
      GUIEnabled = AimEnabled  -- GUI turns on/off with aimbot
      
      Frame.Visible = GUIEnabled
      FOVCircle.Visible = FOVVisible and AimEnabled
      
      print("Aimbot " .. (AimEnabled and "ENABLED" or "DISABLED") .. " | GUI " .. (GUIEnabled and "ON" or "OFF"))
   end
end)

-- Toggle FOV Circle with F
UserInputService.InputBegan:Connect(function(Input)
   if Input.KeyCode == Enum.KeyCode.F then
      FOVVisible = not FOVVisible
      FOVCircle.Visible = FOVVisible and AimEnabled
   end
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
   -- Update FOV Circle
   local ScreenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
   FOVCircle.Position = ScreenCenter
   FOVCircle.Radius = math.tan(math.rad(FOV)/2) * (Camera.ViewportSize.Y / 2)
   FOVCircle.Visible = FOVVisible and AimEnabled
   
   -- Update ESP
   UpdateESP()
   
   -- Aiming Logic
   if AimEnabled and RightClickDown then
      local Target = GetBestTarget()
      if Target then
         AimAt(Target)
      end
   end
end)

-- Initial ESP Creation
for _, Player in pairs(Players:GetPlayers()) do
   CreateESP(Player)
end

Players.PlayerAdded:Connect(CreateESP)

print("========================================")
print("🎯 BIPIN_GOOD Cam Lock + ESP Loaded 🎯")
print("========================================")
print("🖱️ Hold RIGHT CLICK to aim")
print("🎮 RIGHT ALT = Toggle Aimbot + GUI")
print("👁️ F = Toggle FOV Circle")
print("📏 Distance Slider in GUI")
print("👤 ESP: Name + Avatar")
print("========================================")
