local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

getgenv().FovSize = 600
getgenv().FlySpeed = 2.5
getgenv().WalkSpeedValue = 1.2
getgenv().HitboxSize = 5
getgenv().LockSmoothness = 0.15

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Dylan_Mobile_Persistent_V14"
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
FovStroke.Thickness = 1
FovStroke.Color = Color3.fromRGB(0, 255, 255)

local function CreateAura(parent)
    local Att = Instance.new("Attachment", parent)
    Att.Name = "AuraAtt"
    local Glow = Instance.new("ParticleEmitter", Att)
    Glow.Name = "Glow"
    Glow.Texture = "rbxassetid://6071575923"
    Glow.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
    Glow.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 5), NumberSequenceKeypoint.new(1, 0)})
    Glow.Lifetime = NumberRange.new(0.5, 0.8)
    Glow.Rate = 100
    Glow.Speed = NumberRange.new(0)
    Glow.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 1)})
    Glow.LockedToPart = true
    
    local HaloAtt = Instance.new("Attachment", parent)
    HaloAtt.Name = "HaloAtt"
    HaloAtt.Position = Vector3.new(0, 3.5, 0)
    local Halo = Instance.new("ParticleEmitter", HaloAtt)
    Halo.Name = "Halo"
    Halo.Texture = "rbxassetid://6071575923"
    Halo.Color = ColorSequence.new(Color3.fromRGB(255, 100, 100))
    Halo.Size = NumberSequence.new(3)
    Halo.Lifetime = NumberRange.new(0.1)
    Halo.Rate = 20
    Halo.Speed = NumberRange.new(0)
    Halo.LockedToPart = true
end

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
    if getnamecallmethod() == "FireServer" and self.Name == "MainEvent" and (args[1] == "Shoot" or args[1] == "UpdateMousePos") then
        local Target = GetClosestTarget()
        if Target and Target.Character and Target.Character:FindFirstChild("LowerTorso") then
            local TPart = Target.Character.LowerTorso
            args[2] = TPart.Position + (TPart.Velocity * 0.145)
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

local function CreateBtn(text, pos, sizeX, sizeY, isMain)
    local Btn = Instance.new("TextButton")
    Btn.Parent = ScreenGui
    Btn.Size = UDim2.new(0, sizeX, 0, sizeY)
    Btn.Position = pos
    Btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = isMain and 45 or 12
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 10)
    local Stroke = Instance.new("UIStroke", Btn)
    Stroke.Thickness = 2
    Stroke.Color = Color3.fromRGB(0, 255, 255)
    return Btn
end

local LockBtn = CreateBtn("🔓", UDim2.new(0.05, 0, 0.3, 0), 80, 80, true)
local FlyBtn = CreateBtn("FLY", UDim2.new(0.05, 0, 0.48, 0), 80, 35, false)
local AuraBtn = CreateBtn("AURA", UDim2.new(0.05, 0, 0.55, 0), 80, 35, false)
local HitboxBtn = CreateBtn("HITBOX", UDim2.new(0.05, 0, 0.62, 0), 80, 35, false)
local StompBtn = CreateBtn("STOMP", UDim2.new(0.05, 0, 0.69, 0), 80, 35, false)

local LockedPlayer, StrafeOn, FlyOn, AuraOn, SpeedOn, HitboxOn, StompOn = nil, false, false, false, false, false, false
local Degree = 0

AuraBtn.MouseButton1Click:Connect(function() 
    AuraOn = not AuraOn 
    AuraBtn.TextColor3 = AuraOn and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 255, 255)
end)

LockBtn.MouseButton1Click:Connect(function()
    StrafeOn = not StrafeOn
    if StrafeOn then
        local Target = GetClosestTarget()
        if Target then LockedPlayer = Target LockBtn.Text = "🔒" else StrafeOn = false end
    else LockedPlayer = nil LockBtn.Text = "🔓" end
end)

FlyBtn.MouseButton1Click:Connect(function() FlyOn = not FlyOn FlyBtn.TextColor3 = FlyOn and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(255, 255, 255) end)
HitboxBtn.MouseButton1Click:Connect(function() HitboxOn = not HitboxOn HitboxBtn.TextColor3 = HitboxOn and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(255, 255, 255) end)
StompBtn.MouseButton1Click:Connect(function() StompOn = not StompOn StompBtn.TextColor3 = StompOn and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(255, 255, 255) end)

RunService.Stepped:Connect(function()
    local Char = LocalPlayer.Character
    if not Char or not Char:FindFirstChild("HumanoidRootPart") or not Char:FindFirstChild("Humanoid") then return end
    local Root, Hum = Char.HumanoidRootPart, Char.Humanoid

    if AuraOn then
        if not Root:FindFirstChild("AuraAtt") then CreateAura(Root) end
        Root.AuraAtt.Glow.Enabled = true
        Root.HaloAtt.Halo.Enabled = true
    elseif Root:FindFirstChild("AuraAtt") then
        Root.AuraAtt.Glow.Enabled = false
        Root.HaloAtt.Halo.Enabled = false
    end

    if FlyOn then
        Hum.PlatformStand = true
        Root.Velocity = Vector3.new(0, 0, 0)
        if Hum.MoveDirection.Magnitude > 0 then
            Root.CFrame = Root.CFrame + (Vector3.new(Hum.MoveDirection.X, 0, Hum.MoveDirection.Z) * getgenv().FlySpeed)
        end
    else
        if Hum.PlatformStand then Hum.PlatformStand = false end
    end

    if StrafeOn and LockedPlayer and LockedPlayer.Character and LockedPlayer.Character:FindFirstChild("LowerTorso") then
        local TPart = LockedPlayer.Character.LowerTorso
        if LockedPlayer.Character.Humanoid.Health > 0 then
            Degree = Degree + 0.06
            local TargetPos = TPart.Position + Vector3.new(math.sin(Degree) * 12, 5, math.cos(Degree) * 12)
            Root.CFrame = Root.CFrame:Lerp(CFrame.new(TargetPos, TPart.Position), getgenv().LockSmoothness)
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, TPart.Position), getgenv().LockSmoothness)
        else StrafeOn = false LockedPlayer = nil end
    end

    if HitboxOn then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("LowerTorso") then
                v.Character.LowerTorso.Size = Vector3.new(getgenv().HitboxSize, getgenv().HitboxSize, getgenv().HitboxSize)
                v.Character.LowerTorso.Transparency = 0.8
                v.Character.LowerTorso.CanCollide = false
            end
        end
    end

    if StompOn then game:GetService("ReplicatedStorage").MainEvent:FireServer("Stomp") end
end)
