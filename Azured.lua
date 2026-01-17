local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local FovSize = 300
local StompRange = 40
local AttackDistance = 75
local SelectedGun = "rifle"

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Azured_Mobile_V21"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local FovCircle = Instance.new("Frame")
FovCircle.Parent = ScreenGui
FovCircle.Size = UDim2.new(0, FovSize, 0, FovSize)
FovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FovCircle.BackgroundTransparency = 1
local StrokeFOV = Instance.new("UIStroke", FovCircle)
StrokeFOV.Thickness = 2
StrokeFOV.Color = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", FovCircle).CornerRadius = UDim.new(1, 0)

local function Notify(text, color)
    local NotifyLabel = Instance.new("TextLabel")
    NotifyLabel.Parent = ScreenGui
    NotifyLabel.Size = UDim2.new(1, 0, 0, 30)
    NotifyLabel.Position = UDim2.new(0, 0, 0.1, 0)
    NotifyLabel.BackgroundTransparency = 1
    NotifyLabel.Text = text
    NotifyLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    NotifyLabel.Font = Enum.Font.GothamBold
    NotifyLabel.TextSize = 18
    local S = Instance.new("UIStroke", NotifyLabel)
    S.Thickness = 2
    TweenService:Create(NotifyLabel, TweenInfo.new(0.5), {Position = UDim2.new(0, 0, 0.15, 0)}):Play()
    task.delay(2, function()
        TweenService:Create(NotifyLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        task.wait(0.5)
        NotifyLabel:Destroy()
    end)
end

local function MakeDraggable(obj)
    local Dragging, DragInput, DragStart, StartPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true DragStart = input.Position StartPos = obj.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then Dragging = false end end)
        end
    end)
    obj.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then DragInput = input end end)
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - DragStart
            obj.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        end
    end)
end

local function CreateRoundBtn(text, pos, color)
    local Btn = Instance.new("TextButton")
    Btn.Parent = ScreenGui
    Btn.Size = UDim2.new(0, 60, 0, 60)
    Btn.Position = pos
    Btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Btn.Text = text
    Btn.TextColor3 = color
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 10
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)
    local S = Instance.new("UIStroke", Btn)
    S.Thickness = 3
    S.Color = color
    MakeDraggable(Btn)
    return Btn, S
end

local function CreateLongBtn(text, pos)
    local Btn = Instance.new("TextButton")
    Btn.Parent = ScreenGui
    Btn.Size = UDim2.new(0, 120, 0, 40)
    Btn.Position = pos
    Btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Btn.Text = text .. ": OFF"
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 12
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    local S = Instance.new("UIStroke", Btn)
    S.Thickness = 2
    S.Color = Color3.fromRGB(50, 50, 50)
    MakeDraggable(Btn)
    return Btn, S
end

local LockBtn, LockStroke = CreateRoundBtn("LOCK", UDim2.new(0.85, 0, 0.3, 0), Color3.fromRGB(0, 255, 0))
local StompBtn, StompStroke = CreateLongBtn("AUTO STOMP", UDim2.new(0.85, -30, 0.42, 0))
local GKillBtn, GKillStroke = CreateLongBtn("GKILL", UDim2.new(0.85, -30, 0.5, 0))

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 110, 0, 160)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BackgroundTransparency = 0.3
Instance.new("UICorner", MainFrame)
MakeDraggable(MainFrame)

local Content = Instance.new("Frame")
Content.Parent = MainFrame
Content.Size = UDim2.new(1, 0, 1, -10)
Content.Position = UDim2.new(0, 0, 0, 5)
Content.BackgroundTransparency = 1

local function CreateMenuBtn(name, pos)
    local Btn = Instance.new("TextButton")
    Btn.Parent = Content
    Btn.Size = UDim2.new(1, -10, 0, 30)
    Btn.Position = pos
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Btn.Text = name
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 10
    Instance.new("UICorner", Btn)
    return Btn
end

local SpeedBtn = CreateMenuBtn("SPEED", UDim2.new(0, 5, 0, 5))
local FlyBtn = CreateMenuBtn("FLY", UDim2.new(0, 5, 0, 40))
local HitboxBtn = CreateMenuBtn("HITBOX", UDim2.new(0, 5, 0, 75))
local EspBtn = CreateMenuBtn("ESP", UDim2.new(0, 5, 0, 110))

local HitSize = 15
local LockedPlayer, StrafeOn, SpeedOn, FlyOn, HitOn, EspOn, StompOn, GKillOn = nil, false, false, false, false, false, false, false
local LastStrafe = 0

local ShootEvent = ReplicatedStorage:FindFirstChild("Shoot") or ReplicatedStorage:FindFirstChild("ShootEvent")
local PunchEvent = ReplicatedStorage:FindFirstChild("Punch") or ReplicatedStorage:FindFirstChild("PunchEvent")
local MainEvent = ReplicatedStorage:FindFirstChild("MainEvent")

local function GetTarget()
    local Target, MinDist = nil, FovSize / 2
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local Hum = v.Character:FindFirstChild("Humanoid")
            if Hum and Hum.Health > 0 then
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                if OnScreen then
                    local Dist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Center).Magnitude
                    if Dist < MinDist then MinDist = Dist; Target = v end
                end
            end
        end
    end
    return Target
end

LockBtn.MouseButton1Click:Connect(function()
    StrafeOn = not StrafeOn
    if StrafeOn then
        local Target = GetTarget()
        if Target then LockedPlayer = Target LockStroke.Color = Color3.fromRGB(255, 255, 255) Camera.CameraType = Enum.CameraType.Scriptable
        else StrafeOn = false end
    else LockedPlayer = nil LockStroke.Color = Color3.fromRGB(0, 255, 0) Camera.CameraType = Enum.CameraType.Custom end
end)

StompBtn.MouseButton1Click:Connect(function()
    StompOn = not StompOn
    StompBtn.Text = StompOn and "AUTO STOMP: ON" or "AUTO STOMP: OFF"
    StompStroke.Color = StompOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 50)
end)

GKillBtn.MouseButton1Click:Connect(function()
    GKillOn = not GKillOn
    GKillBtn.Text = GKillOn and "GKILL: ON" or "GKILL: OFF"
    GKillStroke.Color = GKillOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 50)
end)

SpeedBtn.MouseButton1Click:Connect(function() SpeedOn = not SpeedOn SpeedBtn.TextColor3 = SpeedOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200) end)
FlyBtn.MouseButton1Click:Connect(function() FlyOn = not FlyOn FlyBtn.TextColor3 = FlyOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200) end)
HitboxBtn.MouseButton1Click:Connect(function() HitOn = not HitOn HitboxBtn.TextColor3 = HitOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200) end)
EspBtn.MouseButton1Click:Connect(function() EspOn = not EspOn EspBtn.TextColor3 = EspOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200) end)

local mt = getrawmetatable(game)
local oldIndex, oldNamecall = mt.__index, mt.__namecall
setreadonly(mt, false)
mt.__index = newcclosure(function(t, k)
    if t == Mouse and (k == "Hit" or k == "Target") then
        local Target = GetTarget()
        if Target and Target.Character and Target.Character:FindFirstChild("Head") then
            if k == "Hit" then return Target.Character.Head.CFrame end
            if k == "Target" then return Target.Character.Head end
        end
    end
    return oldIndex(t, k)
end)
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if method == "FireServer" and self.Name == "MainEvent" then
        if args[1] == "Shoot" or args[1] == "UpdateMousePos" then
            local Target = GetTarget()
            if Target and Target.Character and Target.Character:FindFirstChild("Head") then
                args[2] = Target.Character.Head.Position
                return oldNamecall(self, unpack(args))
            end
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

RunService.RenderStepped:Connect(function()
    local Char = LocalPlayer.Character
    if not Char or not Char:FindFirstChild("HumanoidRootPart") then return end
    local Root, Hum = Char.HumanoidRootPart, Char.Humanoid
    
    if StrafeOn and LockedPlayer and LockedPlayer.Character and LockedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local TRoot = LockedPlayer.Character.HumanoidRootPart
        if tick() - LastStrafe > 0.1 then
            Root.CFrame = CFrame.new(TRoot.Position + Vector3.new(math.random(-12, 12), math.random(2, 10), math.random(-12, 12)), TRoot.Position)
            LastStrafe = tick()
        end
        Camera.CFrame = CFrame.new(Root.Position + Vector3.new(0, 2, 0), TRoot.Position)
    end
    
    if StompOn or GKillOn then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local eRoot = v.Character.HumanoidRootPart
                local eHum = v.Character:FindFirstChild("Humanoid")
                local Distance = (Root.Position - eRoot.Position).Magnitude
                
                if eHum and eHum.Health <= 15 and Distance <= StompRange then
                    Root.CFrame = eRoot.CFrame * CFrame.new(0, 2, 0)
                    if PunchEvent then PunchEvent:FireServer(v.Character) elseif MainEvent then MainEvent:FireServer("Stomp") end
                    break
                elseif GKillOn and eHum and eHum.Health > 15 and Distance <= AttackDistance then
                    if ShootEvent then ShootEvent:FireServer(v.Character, SelectedGun) elseif MainEvent then MainEvent:FireServer("Shoot", eRoot.Position) end
                end
            end
        end
    end

    if SpeedOn and Hum.MoveDirection.Magnitude > 0 then Root.CFrame = Root.CFrame + (Hum.MoveDirection * 2.5) end
    if FlyOn and not StrafeOn then Root.Velocity = Vector3.new(0, 0, 0) Root.CFrame = Root.CFrame + (Camera.CFrame.LookVector * 3.8) end

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            local pRoot = v.Character:FindFirstChild("HumanoidRootPart")
            if EspOn and pRoot then
                local Tag = pRoot:FindFirstChild("EspTag") or Instance.new("BillboardGui", pRoot)
                Tag.Name = "EspTag" Tag.Size = UDim2.new(4, 0, 2, 0) Tag.AlwaysOnTop = true
                local L = Tag:FindFirstChild("TextLabel") or Instance.new("TextLabel", Tag)
                L.Name = "TextLabel" L.Size = UDim2.new(1, 0, 1, 0) L.BackgroundTransparency = 1 L.TextSize = 12 L.Font = Enum.Font.GothamBold
                local HP = v.Character.Humanoid and math.floor(v.Character.Humanoid.Health) or 0
                L.Text = v.Name .. "\nHP: " .. HP L.TextColor3 = Color3.fromRGB(255, 0, 0):lerp(Color3.fromRGB(0, 255, 0), HP/100)
            elseif pRoot and pRoot:FindFirstChild("EspTag") then pRoot.EspTag:Destroy() end
            if HitOn and pRoot then pRoot.Size = Vector3.new(HitSize, HitSize, HitSize) pRoot.Transparency = 0.7 pRoot.CanCollide = false
            elseif pRoot then pRoot.Size = Vector3.new(2, 2, 1) pRoot.Transparency = 1 end
        end
    end
end)

Notify("Azured", Color3.fromRGB(0, 255, 0))
