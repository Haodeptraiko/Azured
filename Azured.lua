local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

getgenv().Prediction = 0.155
getgenv().FovSize = 250
getgenv().FlySpeed = 5
getgenv().WalkSpeedValue = 1.5
getgenv().HitboxSize = 5

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DaHood_Bypass_V4"
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
            local TPart = Target.Character.LowerTorso
            args[2] = TPart.Position + (TPart.Velocity * getgenv().Prediction)
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

local function CreateBtn(text, pos, sizeX, sizeY)
    local Btn = Instance.new("TextButton")
    Btn.Parent = ScreenGui
    Btn.Size = UDim2.new(0, sizeX or 80, 0, sizeY or 80)
    Btn.Position = pos
    Btn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Btn.BackgroundTransparency = 0.4
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 20
    Instance.new("UICorner", Btn)
    return Btn
end

local LockBtn = CreateBtn("🔓", UDim2.new(0.85, 0, 0.1, 0), 90, 90)
LockBtn.TextSize = 50
local FlyBtn = CreateBtn("FLY", UDim2.new(0.85, 10, 0.25, 0), 70, 40)
local SpeedBtn = CreateBtn("SPEED", UDim2.new(0.85, 10, 0.32, 0), 70, 40)
local HitboxBtn = CreateBtn("HITBOX", UDim2.new(0.85, 10, 0.39, 0), 70, 40)

local LockedPlayer, StrafeOn, FlyOn, SpeedOn, HitboxOn = nil, false, false, false, false

LockBtn.MouseButton1Click:Connect(function()
    StrafeOn = not StrafeOn
    if StrafeOn then
        local Target = GetClosestTarget()
        if Target then LockedPlayer = Target LockBtn.Text = "🔒" LockBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        else StrafeOn = false end
    else LockedPlayer = nil LockBtn.Text = "🔓" LockBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10) end
end)

FlyBtn.MouseButton1Click:Connect(function() FlyOn = not FlyOn FlyBtn.TextColor3 = FlyOn and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255) end)
SpeedBtn.MouseButton1Click:Connect(function() SpeedOn = not SpeedOn SpeedBtn.TextColor3 = SpeedOn and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255) end)
HitboxBtn.MouseButton1Click:Connect(function() HitboxOn = not HitboxOn HitboxBtn.TextColor3 = HitboxOn and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255) end)

RunService.Stepped:Connect(function()
    local Char = LocalPlayer.Character
    if not Char or not Char:FindFirstChild("HumanoidRootPart") then return end
    local Root = Char.HumanoidRootPart
    local Hum = Char.Humanoid

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
            local CamTarget = CFrame.new(Camera.CFrame.Position, TPart.Position + (TPart.Velocity * getgenv().Prediction))
            Camera.CFrame = Camera.CFrame:Lerp(CamTarget, 0.15)
        else
            StrafeOn = false LockedPlayer = nil LockBtn.Text = "🔓" LockBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
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
end)
