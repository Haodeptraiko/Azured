local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

getgenv().FovSize = 250
getgenv().FlySpeed = 5
getgenv().WalkSpeedValue = 1.5
getgenv().HitboxSize = 5
getgenv().LockSmoothness = 0.18

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Azured_V3_Premium"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local FovCircle = Instance.new("Frame")
FovCircle.Parent = ScreenGui
FovCircle.Size = UDim2.new(0, getgenv().FovSize, 0, getgenv().FovSize)
FovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FovCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FovCircle.BackgroundTransparency = 0.98
FovCircle.Visible = true
Instance.new("UICorner", FovCircle).CornerRadius = UDim.new(1, 0)
local FovStroke = Instance.new("UIStroke", FovCircle)
FovStroke.Thickness = 1.5
FovStroke.Color = Color3.fromRGB(0, 255, 255)

local function GetClosestTarget()
    local Target, ClosestDist = nil, getgenv().FovSize / 2
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("LowerTorso") then
            local Hum = v.Character:FindFirstChild("Humanoid")
            if Hum and Hum.Health > 0 then
                local ScreenPos, OnScreen = Camera:WorldToScreenPoint(v.Character.LowerTorso.Position)
                if OnScreen then
                    local Dist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Center).Magnitude
                    if Dist < ClosestDist then ClosestDist = Dist; Target = v end
                end
            end
        end
    end
    return Target
end

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if method == "FireServer" and self.Name == "MainEvent" and (args[1] == "Shoot" or args[1] == "UpdateMousePos") then
        local Target = GetClosestTarget()
        if Target and Target.Character:FindFirstChild("LowerTorso") then
            args[2] = Target.Character.LowerTorso.Position
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

local function CreatePremiumBtn(text, pos, sizeX, sizeY, isMain)
    local Btn = Instance.new("TextButton")
    Btn.Parent = ScreenGui
    Btn.Size = UDim2.new(0, sizeX, 0, sizeY)
    Btn.Position = pos
    Btn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Btn.BackgroundTransparency = 0.1
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = isMain and 45 or 14
    local Corner = Instance.new("UICorner", Btn)
    Corner.CornerRadius = UDim.new(0, 12)
    local Stroke = Instance.new("UIStroke", Btn)
    Stroke.Thickness = 2.5
    Stroke.Color = Color3.fromRGB(0, 255, 255)
    return Btn, Stroke
end

local LockBtn, LockStroke = CreatePremiumBtn("🔓", UDim2.new(0.85, 0, 0.1, 0), 90, 90, true)
local MenuFrame = Instance.new("Frame")
MenuFrame.Parent = ScreenGui
MenuFrame.Size = UDim2.new(0, 100, 0, 200)
MenuFrame.Position = UDim2.new(0.85, 0, 0.25, 0)
MenuFrame.BackgroundTransparency = 1

local FlyBtn = CreatePremiumBtn("FLY", UDim2.new(0, 5, 0, 0), 80, 35, false)
FlyBtn.Parent = MenuFrame
local SpeedBtn = CreatePremiumBtn("SPEED", UDim2.new(0, 5, 0, 45), 80, 35, false)
SpeedBtn.Parent = MenuFrame
local HitboxBtn = CreatePremiumBtn("HITBOX", UDim2.new(0, 5, 0, 90), 80, 35, false)
HitboxBtn.Parent = MenuFrame
local StompBtn = CreatePremiumBtn("STOMP", UDim2.new(0, 5, 0, 135), 80, 35, false)
StompBtn.Parent = MenuFrame

local LockedPlayer, StrafeOn, FlyOn, SpeedOn, HitboxOn, StompOn = nil, false, false, false, false, false
local Degree = 0

LockBtn.MouseButton1Click:Connect(function()
    StrafeOn = not StrafeOn
    if StrafeOn then
        local Target = GetClosestTarget()
        if Target then 
            LockedPlayer = Target 
            LockBtn.Text = "🔒" 
            LockBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
            LockStroke.Color = Color3.fromRGB(255, 0, 0)
            FovStroke.Color = Color3.fromRGB(255, 0, 0)
        else 
            StrafeOn = false 
        end
    else 
        LockedPlayer = nil 
        LockBtn.Text = "🔓" 
        LockBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        LockStroke.Color = Color3.fromRGB(0, 255, 255)
        FovStroke.Color = Color3.fromRGB(0, 255, 255)
    end
end)

FlyBtn.MouseButton1Click:Connect(function() FlyOn = not FlyOn FlyBtn.TextColor3 = FlyOn and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(255, 255, 255) end)
SpeedBtn.MouseButton1Click:Connect(function() SpeedOn = not SpeedOn SpeedBtn.TextColor3 = SpeedOn and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(255, 255, 255) end)
HitboxBtn.MouseButton1Click:Connect(function() HitboxOn = not HitboxOn HitboxBtn.TextColor3 = HitboxOn and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(255, 255, 255) end)
StompBtn.MouseButton1Click:Connect(function() StompOn = not StompOn StompBtn.TextColor3 = StompOn and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(255, 255, 255) end)

RunService.Stepped:Connect(function()
    local Char = LocalPlayer.Character
    if not Char or not Char:FindFirstChild("HumanoidRootPart") then return end
    local Root, Hum = Char.HumanoidRootPart, Char.Humanoid

    if FlyOn then
        Root.Velocity = Vector3.new(0, 0.1, 0)
        if Hum.MoveDirection.Magnitude > 0 then
            Root.CFrame = Root.CFrame + (Camera.CFrame.LookVector * getgenv().FlySpeed) + (Hum.MoveDirection * getgenv().FlySpeed)
        end
    end

    if SpeedOn and Hum.MoveDirection.Magnitude > 0 then
        Root.CFrame = Root.CFrame + (Hum.MoveDirection * getgenv().WalkSpeedValue)
    end

    if StrafeOn and LockedPlayer and LockedPlayer.Character and LockedPlayer.Character:FindFirstChild("LowerTorso") then
        local TPart = LockedPlayer.Character.LowerTorso
        if LockedPlayer.Character.Humanoid.Health > 0 then
            Degree = Degree + 0.05
            local TargetPos = TPart.Position + Vector3.new(math.sin(Degree) * 12, 4, math.cos(Degree) * 12)
            Root.CFrame = Root.CFrame:Lerp(CFrame.new(TargetPos, TPart.Position), getgenv().LockSmoothness)
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, TPart.Position), getgenv().LockSmoothness)
        else
            StrafeOn = false LockedPlayer = nil LockBtn.Text = "🔓" LockBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10) LockStroke.Color = Color3.fromRGB(0, 255, 255)
        end
    end

    if HitboxOn then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("LowerTorso") then
                local T = v.Character.LowerTorso
                T.Size = Vector3.new(getgenv().HitboxSize, getgenv().HitboxSize, getgenv().HitboxSize)
                T.Transparency = 0.8
                T.CanCollide = false
            end
        end
    end

    if StompOn then
        game:GetService("ReplicatedStorage").MainEvent:FireServer("Stomp")
    end
end)
