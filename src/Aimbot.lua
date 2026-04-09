-- Xeno Enhanced Aimbot v2 - Fixed for BIPIN
local Aimbot = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local AIMBOT_KEY = Enum.KeyCode.Equals

Aimbot.Settings = {
    Enabled = false,
    AimPart = "Head",
    FOV = 120,
    Smoothing = 0.08,
    TeamCheck = true,
    Prediction = 0.12,
    FOVCircle = true
}

local connection = nil
local fovCircle = nil
local target = nil

-- Create FOV Circle
local function createFOVCircle()
    if fovCircle then fovCircle:Remove() end
    fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 2
    fovCircle.Color = Color3.fromRGB(0, 255, 255)
    fovCircle.Filled = false
    fovCircle.Transparency = 0.7
    fovCircle.NumSides = 64
end

-- Get closest player
local function getClosestPlayer()
    local closest = nil
    local shortest = Aimbot.Settings.FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local humanoid = char:FindFirstChild("Humanoid")
            local part = char:FindFirstChild(Aimbot.Settings.AimPart) or char:FindFirstChild("Head")

            if humanoid and humanoid.Health > 0 and part then
                if Aimbot.Settings.TeamCheck and player.Team == LocalPlayer.Team then
                    continue
                end

                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if dist < shortest then
                        shortest = dist
                        closest = player
                    end
                end
            end
        end
    end
    return closest
end

-- Aim at target
local function aimAtTarget(plr)
    if not plr or not plr.Character then return end
    local part = plr.Character:FindFirstChild(Aimbot.Settings.AimPart) or plr.Character:FindFirstChild("Head")
    if not part then return end

    local targetPos = part.Position
    if part.Velocity then
        targetPos = targetPos + (part.Velocity * Aimbot.Settings.Prediction)
    end

    local direction = (targetPos - Camera.CFrame.Position).Unit
    local current = Camera.CFrame.LookVector
    local smoothed = current:Lerp(direction, Aimbot.Settings.Smoothing)

    Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + smoothed)
end

local function aimbotLoop()
    if not Aimbot.Settings.Enabled then return end

    target = getClosestPlayer()

    if target then
        aimAtTarget(target)
    end
end

function Aimbot.Load()
    print("==========================================")
    print("🔥 XENO ENHANCED AIMBOT v2 LOADED 🔥")
    print("==========================================")
    print("Press '=' to toggle aimbot ON/OFF")

    createFOVCircle()

    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == AIMBOT_KEY then
            Aimbot.Settings.Enabled = not Aimbot.Settings.Enabled
            print("Aimbot " .. (Aimbot.Settings.Enabled and "ENABLED ✅" or "DISABLED ❌"))

            if Aimbot.Settings.Enabled then
                if not connection then
                    connection = RunService.RenderStepped:Connect(aimbotLoop)
                end
            else
                if connection then
                    connection:Disconnect()
                    connection = nil
                end
            end
        end
    end)

    -- FOV Circle updater
    RunService.RenderStepped:Connect(function()
        if fovCircle then
            fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            fovCircle.Radius = Aimbot.Settings.FOV
            fovCircle.Visible = Aimbot.Settings.Enabled and Aimbot.Settings.FOVCircle
        end
    end)

    print("Ready! Press '=' to start aiming.")
end

return Aimbot
