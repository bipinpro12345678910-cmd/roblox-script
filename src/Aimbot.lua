-- BIPIN_GOOD Combined Cam Lock + ESP Script
-- Hold Right Mouse Button = Cam Lock
-- Press F9 = Toggle ESP On/Off

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

getgenv().CamLockEnabled = false
getgenv().LockedPlayer = nil
getgenv().ESPEnabled = false

-- ================== ESP ==================
local ESP = {}

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local function AddHighlight(char)
        if not char then return end
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "BIPIN_ESP"
        highlight.Adornee = char
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = char
        
        -- Billboard for name + distance + health
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "BIPIN_NameESP"
        billboard.Adornee = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 200, 0, 60)
        billboard.ExtentsOffset = Vector3.new(0, 3, 0)
        billboard.Parent = char
        
        local text = Instance.new("TextLabel", billboard)
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.TextColor3 = Color3.fromRGB(255, 255, 255)
        text.TextStrokeTransparency = 0.4
        text.Font = Enum.Font.SourceSansBold
        text.TextSize = 14
        text.Text = player.Name
        
        ESP[player] = {Highlight = highlight, Text = text}
    end
    
    if player.Character then
        AddHighlight(player.Character)
    end
    
    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        AddHighlight(char)
    end)
end

local function UpdateESP()
    for player, data in pairs(ESP) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local dist = (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            local health = player.Character:FindFirstChild("Humanoid") and math.floor(player.Character.Humanoid.Health) or "?"
            
            data.Text.Text = player.Name .. "\n[" .. math.floor(dist) .. " studs]\n♥ " .. health
        end
    end
end

-- Create ESP for current players
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

-- ================== Cam Lock ==================
local function LockCamera()
    if getgenv().LockedPlayer and getgenv().LockedPlayer.Character then
        local target = getgenv().LockedPlayer.Character:FindFirstChild("HumanoidRootPart") 
                    or getgenv().LockedPlayer.Character:FindFirstChild("Head")
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(
                CFrame.lookAt(Camera.CFrame.Position, target.Position),
                0.25
            )
        end
    end
end

-- Right Click Hold for Cam Lock
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if getgenv().LockedPlayer then
            getgenv().CamLockEnabled = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        getgenv().CamLockEnabled = false
    end
end)

-- F9 to toggle ESP
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F9 then
        getgenv().ESPEnabled = not getgenv().ESPEnabled
        
        for player, data in pairs(ESP) do
            if data.Highlight then
                data.Highlight.Enabled = getgenv().ESPEnabled
            end
        end
        
        print("ESP " .. (getgenv().ESPEnabled and "ENABLED" or "DISABLED"))
    end
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    if getgenv().CamLockEnabled then
        LockCamera()
    end
    
    if getgenv().ESPEnabled then
        UpdateESP()
    end
end)

-- Simple GUI for player selection
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "BIPIN_GOOD Cam Lock + ESP",
   LoadingTitle = "Loading...",
   LoadingSubtitle = "F9 = Toggle ESP | Hold RMB = Cam Lock",
   KeySystem = false
})

local Tab = Window:CreateTab("Main", 4483362458)

local playerList = {}
for _, plr in pairs(Players:GetPlayers()) do
   if plr ~= LocalPlayer then table.insert(playerList, plr.Name) end
end

local Dropdown = Tab:CreateDropdown({
   Name = "Select Player for Cam Lock",
   Options = playerList,
   CurrentOption = playerList[1] or "No players",
   Callback = function(Option)
      getgenv().LockedPlayer = Players:FindFirstChild(Option)
   end,
})

Tab:CreateButton({
   Name = "Refresh Player List",
   Callback = function()
      playerList = {}
      for _, plr in pairs(Players:GetPlayers()) do
         if plr ~= LocalPlayer then table.insert(playerList, plr.Name) end
      end
      Dropdown:Refresh(playerList, true)
   end,
})

Tab:CreateLabel("Controls:")
Tab:CreateLabel("• Hold Right Mouse Button = Cam Lock")
Tab:CreateLabel("• Press F9 = Toggle ESP On/Off")

print("BIPIN_GOOD Combined Script Loaded!")
print("F9 = ESP Toggle | Hold RMB = Cam Lock")
