-- BIPIN_GOOD Combined Cam Lock + ESP Script
-- Hold Right Click to Aim | Right Alt to Toggle Aimbot | F to toggle FOV Circle | F9 to toggle ESP

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- ================== AIMBOT / CAM LOCK SETTINGS ==================
local AimEnabled = true
local FOV = 40
local MaxDistance = 500
local Smoothing = 0.15
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

-- ================== ESP (Your Script) ==================
local ESP_Color = Color3.fromRGB(255, 0, 0)
local Text_Color = Color3.fromRGB(255, 255, 255)
local ESP = {}

local function CreateESP(player)
    if player == LocalPlayer then return end
   
    local function AddHighlight(char)
        if not char then return end
       
        local highlight = Instance.new("Highlight")
        highlight.Name = "BIPIN_ESP"
        highlight.Adornee = char
        highlight.FillColor = ESP_Color
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = char
       
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "BIPIN_Name"
        billboard.Adornee = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.ExtentsOffset = Vector3.new(0, 3, 0)
        billboard.Parent = char
       
        local text = Instance.new("TextLabel", billboard)
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.TextColor3 = Text_Color
        text.TextStrokeTransparency = 0.5
        text.Font = Enum.Font.SourceSansBold
        text.TextSize = 14
        text.Text = player.Name
       
        ESP[player] = {Highlight = highlight, Text = text}
    end
   
    if player.Character then
        AddHighlight(player.Character)
    end
   
    player.CharacterAdded:Connect(function(char)
        wait(0.5)
        AddHighlight(char)
    end)
end

-- Update ESP distance & health
RunService.RenderStepped:Connect(function()
    for player, data in pairs(ESP) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local distance = (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
           
            local health = "?"
            if player.Character:FindFirstChild("Humanoid") then
                health = math.floor(player.Character.Humanoid.Health)
            end
           
            local displayText = player.Name
            displayText = displayText .. "\n[" .. math.floor(distance) .. " studs]"
            displayText = displayText .. "\n♥ " .. health
           
            data.Text.Text = displayText
        end
    end
end)

-- Create ESP for existing and new players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end)

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

-- Toggle FOV Circle with F
UserInputService.InputBegan:Connect(function(Input)
   if Input.KeyCode == Enum.KeyCode.F then
      FOVVisible = not FOVVisible
      FOVCircle.Visible = FOVVisible and AimEnabled
   end
end)

-- Toggle ESP with F9
UserInputService.InputBegan:Connect(function(Input)
   if Input.KeyCode == Enum.KeyCode.F9 then
      local newState = not getgenv().ESPEnabled or false
      getgenv().ESPEnabled = newState
      
      for _, data in pairs(ESP) do
         if data.Highlight then
            data.Highlight.Enabled = newState
         end
      end
      
      print("ESP " .. (newState and "ENABLED" or "DISABLED"))
   end
end)

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

local function AimAt(Target)
   if not Target then return end
   local TargetPos = Target.Position
   local CurrentCFrame = Camera.CFrame
   local Direction = (TargetPos - CurrentCFrame.Position).Unit
   local Smoothed = CurrentCFrame.LookVector:Lerp(Direction, Smoothing)
  
   Camera.CFrame = CFrame.new(CurrentCFrame.Position, CurrentCFrame.Position + Smoothed)
end

-- Main Loop
RunService.RenderStepped:Connect(function()
   -- Update FOV Circle
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

-- Distance Slider GUI (kept from your original)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 260, 0, 220)
Frame.Position = UDim2.new(0.5, -130, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Text = "BIPIN_GOOD Aimbot + ESP"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

local Status = Instance.new("TextLabel", Frame)
Status.Size = UDim2.new(1, 0, 0, 25)
Status.Position = UDim2.new(0, 0, 0, 40)
Status.BackgroundTransparency = 1
Status.Text = "Hold Right Click to Aim | F9 = ESP Toggle"
Status.TextColor3 = Color3.fromRGB(0, 255, 100)
Status.TextSize = 14

print("========================================")
print("🎯 BIPIN_GOOD Combined Script Loaded 🎯")
print("========================================")
print("🖱️ Hold RIGHT CLICK to aim lock")
print("🎮 RIGHT ALT = Toggle Aimbot")
print("👁️ F = Toggle FOV Circle")
print("🔹 F9 = Toggle ESP (Red Boxes)")
print("========================================")
