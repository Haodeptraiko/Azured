local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/Streekaiz/Visual-UI-Library/main/Source.lua'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local FovSize = 150
local StompRange = 15 
local HitSize = 15
local SpeedMultiplier = 3.5
local LockedPlayer, StrafeOn, SpeedOn, FlyOn, HitOn, StompOn = nil, false, false, false, false, false
local Degree = 0

local function GetTarget()
    local Target, MinDist = nil, FovSize / 2
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local Hum = v.Character:FindFirstChild("Humanoid")
            if Hum and Hum.Health > 0 then
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                local Dist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Center).Magnitude
                if Dist < MinDist then MinDist = Dist; Target = v end
            end
        end
    end
    return Target
end

local function GetChestPos(p)
    if p.Character:FindFirstChild("UpperTorso") then return p.Character.UpperTorso.Position
    elseif p.Character:FindFirstChild("HumanoidRootPart") then return p.Character.HumanoidRootPart.Position
    end
    return nil
end

local Window = Library:CreateWindow('Azured V55', 'Mobile Edition')

local MobileGui = Instance.new("ScreenGui")
local ToggleBtn = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

MobileGui.Name = "MobileToggle"
MobileGui.Parent = (game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui"))
MobileGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Parent = MobileGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.Text = "MENU"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 14
ToggleBtn.Draggable = true
ToggleBtn.Active = true

UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = ToggleBtn

ToggleBtn.MouseButton1Click:Connect(function()
    Library:ToggleUI()
end)

local MainTab = Window:CreateTab('Combat', true, 'rbxassetid://3926305904', Vector2.new(484, 44), Vector2.new(36, 36))
local CombatSection = MainTab:CreateSection('Main Features')

CombatSection:CreateToggle('Target Strafe (Lock)', false, Color3.fromRGB(255, 0, 0), 0.25, function(Value)
    StrafeOn = Value
    if StrafeOn then
        local T = GetTarget()
        if T then 
            LockedPlayer = T 
            Camera.CameraType = Enum.CameraType.Scriptable
        else 
            StrafeOn = false 
        end
    else 
        LockedPlayer = nil 
        Camera.CameraType = Enum.CameraType.Custom
    end
end)

CombatSection:CreateToggle('Hitbox Expand', false, Color3.fromRGB(0, 255, 0), 0.25, function(Value)
    HitOn = Value
end)

CombatSection:CreateToggle('Auto Stomp', false, Color3.fromRGB(0, 125, 255), 0.25, function(Value)
    StompOn = Value
end)

local MovementTab = Window:CreateTab('Movement', false, 'rbxassetid://3926305904', Vector2.new(484, 44), Vector2.new(36, 36))
local MoveSection = MovementTab:CreateSection('Speed & Fly')

MoveSection:CreateToggle('Speed Boost', false, Color3.fromRGB(255, 255, 0), 0.25, function(Value)
    SpeedOn = Value
end)

MoveSection:CreateSlider('Speed Multiplier', 1, 10, Color3.fromRGB(255, 255, 255), function(Value)
    SpeedMultiplier = Value
end)

MoveSection:CreateToggle('Fly Mode', false, Color3.fromRGB(255, 0, 255), 0.25, function(Value)
    FlyOn = Value
end)

RunService.RenderStepped:Connect(function()
    local Char = LocalPlayer.Character
    if not Char or not Char:FindFirstChild("HumanoidRootPart") then return end
    local Root, Hum = Char.HumanoidRootPart, Char.Humanoid

    if StrafeOn and LockedPlayer and LockedPlayer.Character and LockedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local TRoot = LockedPlayer.Character.HumanoidRootPart
        local TChest = GetChestPos(LockedPlayer) or TRoot.Position
        Degree = Degree + 0.025
        local TargetPos = TChest + Vector3.new(math.sin(Degree * 60) * 11, 5, math.cos(Degree * 60) * 11)
        Root.CFrame = CFrame.new(TargetPos, TChest)
        Camera.CFrame = CFrame.new(TChest + Vector3.new(0, 5, 12), TChest)
    end

    if SpeedOn and Hum.MoveDirection.Magnitude > 0 then 
        Root.CFrame = Root.CFrame + (Hum.MoveDirection * SpeedMultiplier) 
    end
    
    if FlyOn and not StrafeOn then 
        Root.Velocity = Vector3.new(0, 0, 0) 
        Root.CFrame = Root.CFrame + (Camera.CFrame.LookVector * 3.8) 
    end

    if StompOn then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local eRoot = v.Character.HumanoidRootPart
                local eHum = v.Character:FindFirstChild("Humanoid")
                if eHum and eHum.Health <= 15 and (Root.Position - eRoot.Position).Magnitude <= StompRange then
                    ReplicatedStorage.MainEvent:FireServer("Stomp")
                end
            end
        end
    end

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            local pRoot = v.Character:FindFirstChild("HumanoidRootPart")
            if pRoot then
                if HitOn then 
                    pRoot.Size = Vector3.new(HitSize, HitSize, HitSize) 
                    pRoot.Transparency = 0.8 
                    pRoot.CanCollide = false
                else 
                    pRoot.Size = Vector3.new(2, 2, 1) 
                    pRoot.Transparency = 1 
                end
            end
        end
    end
end)
