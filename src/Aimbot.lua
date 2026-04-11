-- BIPIN_GOOD Enhanced Cam Lock / Aimbot with Distance Slider UI (Fixed 2026)
-- Hold Right Click to Aim | Right Alt to Toggle | F to toggle FOV Circle

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local AimEnabled = true
local FOV = 40
local MaxDistance = 500
local Smoothing = 0.25          -- Increased a bit for less jitter (adjust 0.1-0.4)
local AimPart = "Head"
local FOVVisible = true

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 50, 50)
FOVCircle.Transparency = 0.4
FOVCircle.Filled = false
FOVCircle.Visible = false

-- GUI
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
Title.Text = "BIPIN_GOOD Aimbot + Distance"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

local Status = Instance.new("TextLabel", Frame)
Status.Size = UDim2.new(1, 0, 0, 25)
Status.Position = UDim2.new(0, 0, 0, 40)
Status.BackgroundTransparency = 1
Status.Text = "Aimbot: ON | Hold Right Click to Aim"
Status.TextColor3 = Color3.fromRGB(0, 255, 100)
Status.TextSize = 14

local DistLabel = Instance.new("TextLabel", Frame)
DistLabel.Size = UDim2.new(1, 0, 0, 20)
DistLabel.Position = UDim2.new(0, 0, 0, 70)
DistLabel.BackgroundTransparency = 1
DistLabel.Text = "Max Aim Distance: " .. MaxDistance .. " studs"
DistLabel.TextColor3 = Color3.new(1,1,1)
DistLabel.TextSize = 14

local DistanceSlider = Instance.new("TextButton", Frame)
DistanceSlider.Size = UDim2.new(0.9, 0, 0, 25)
DistanceSlider.Position = UDim2.new(0.05, 0, 0, 95)
DistanceSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
DistanceSlider.Text = ""

-- Slider variables
local dragging = false
local sliderBar = Instance.new("Frame", DistanceSlider) -- Visual bar
sliderBar.Size = UDim2.new(0, 0, 1, 0)
sliderBar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
sliderBar.BorderSizePixel = 0

-- Slider logic
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
		local mouseX = UserInputService:GetMouseLocation().X
		local sliderX = DistanceSlider.AbsolutePosition.X
		local sliderWidth = DistanceSlider.AbsoluteSize.X
		
		local percent = math.clamp((mouseX - sliderX) / sliderWidth, 0, 1)
		MaxDistance = math.floor(100 + percent * 900) -- 100 to 1000
		
		DistLabel.Text = "Max Aim Distance: " .. MaxDistance .. " studs"
		sliderBar.Size = UDim2.new(percent, 0, 1, 0)
	end
end)

-- Get Best Target
local function GetBestTarget()
	if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
		return nil 
	end
	
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

-- Improved Aim Function (less jitter)
local function AimAt(Target)
	if not Target then return end
	
	local TargetPos = Target.Position
	local CurrentCFrame = Camera.CFrame
	local Direction = (TargetPos - CurrentCFrame.Position).Unit
	
	-- Better smoothing with delta time
	local Smoothed = CurrentCFrame.LookVector:Lerp(Direction, Smoothing)
	
	Camera.CFrame = CFrame.new(CurrentCFrame.Position, CurrentCFrame.Position + Smoothed)
end

-- Right Click Hold (using UserInputService - more reliable)
local RightClickDown = false

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		RightClickDown = true
	end
	
	if input.KeyCode == Enum.KeyCode.RightAlt then
		AimEnabled = not AimEnabled
		FOVCircle.Visible = FOVVisible and AimEnabled
		Status.Text = "Aimbot: " .. (AimEnabled and "ON" or "OFF") .. " | Hold Right Click to Aim"
		print("Aimbot " .. (AimEnabled and "ENABLED" or "DISABLED"))
	end
	
	if input.KeyCode == Enum.KeyCode.F then
		FOVVisible = not FOVVisible
		FOVCircle.Visible = FOVVisible and AimEnabled
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		RightClickDown = false
	end
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
	-- Update FOV Circle
	local ScreenCenter = Camera.ViewportSize / 2
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

print("========================================")
print("🎯 BIPIN_GOOD Cam Lock Loaded (Fixed) 🎯")
print("========================================")
print("🖱️ Hold RIGHT CLICK to aim lock")
print("🎮 RIGHT ALT = Toggle Aimbot")
print("👁️ F = Toggle FOV Circle")
print("📏 Distance Slider in GUI (100-1000 studs)")
print("========================================")
