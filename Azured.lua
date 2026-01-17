local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

getgenv().selectedHitsound = "rbxassetid://6607142036"
getgenv().hitsoundEnabled = true
getgenv().PredictionAmount = 0.165

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Azured_Mobile_Final_V3"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local FovCircle = Instance.new("Frame")
FovCircle.Parent = ScreenGui
FovCircle.Size = UDim2.new(0, 200, 0, 200)
FovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FovCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FovCircle.BackgroundTransparency = 0.95
FovCircle.Visible = true
Instance.new("UICorner", FovCircle).CornerRadius = UDim.new(1, 0)
local FovStroke = Instance.new("UIStroke", FovCircle)
FovStroke.Thickness = 1
FovStroke.Color = Color3.fromRGB(255, 255, 255)

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
    local Stroke = Instance.new("UIStroke", NotifyLabel)
    Stroke.Thickness = 2
    TweenService:Create(NotifyLabel, TweenInfo.new(0.5), {Position = UDim2.new(0, 0, 0.15, 0)}):Play()
    task.delay(2, function()
        TweenService:Create(NotifyLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        task.wait(0.5)
        NotifyLabel:Destroy()
    end)
end

local function playHitsound()
    if getgenv().hitsoundEnabled then
        local sound = Instance.new("Sound")
        sound.SoundId = getgenv().selectedHitsound
        sound.Volume = 3
        sound.Parent = SoundService
        sound:Play()
        sound.Ended:Connect(function() sound:Destroy() end)
    end
end

local lastHealth = {}
local function trackHealth()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") then
            local hum = v.Character.Humanoid
            if not lastHealth[v.Name] then lastHealth[v.Name] = hum.Health end
            if hum.Health < lastHealth[v.Name] then playHitsound() end
            lastHealth[v.Name] = hum.Health
        end
    end
end

local function GetClosestTargetToCenter()
    local Target, ClosestDist = nil, 100
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("LowerTorso") and v.Character.Humanoid.Health > 0 then
            local ScreenPos, OnScreen = Camera:WorldToScreenPoint(v.Character.LowerTorso.Position)
            if OnScreen then
                local Dist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Center).Magnitude
                if Dist < ClosestDist then ClosestDist = Dist; Target = v end
            end
        end
    end
    return Target
end

local mt = getrawmetatable(game)
local oldIndex = mt.__index
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__index = newcclosure(function(t, k)
    if t == Mouse and (k == "Hit" or k == "Target") then
        local Target = GetClosestTargetToCenter()
        if Target and Target.Character:FindFirstChild("LowerTorso") then
            local Prediction = Target.Character.LowerTorso.Position + (Target.Character.LowerTorso.Velocity * getgenv().PredictionAmount)
            return k == "Hit" and CFrame.new(Prediction) or Target.Character.LowerTorso
        end
    end
    return oldIndex(t, k)
end)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if method == "FireServer" and self.Name == "MainEvent" then
        if args[1] == "Shoot" or args[1] == "UpdateMousePos" then
            local Target = GetClosestTargetToCenter()
            if Target and Target.Character:FindFirstChild("LowerTorso") then
                args[2] = Target.Character.LowerTorso.Position + (Target.Character.LowerTorso.Velocity * getgenv().PredictionAmount)
                return oldNamecall(self, unpack(args))
            end
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

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
    Btn.Size = UDim2.new(0, 65, 0, 65)
    Btn.Position = pos
    Btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Btn.Text = text
    Btn.TextColor3 = color
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 25
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)
    local Stroke = Instance.new("UIStroke", Btn)
    Stroke.Thickness = 3
    Stroke.Color = color
    MakeDraggable(Btn)
    return Btn, Stroke
end

local LockBtn, LockStroke = CreateRoundBtn("🔓", UDim2.new(0.8, 0, 0.4, 0), Color3.fromRGB(0, 255, 0))

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 110, 0, 255)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BackgroundTransparency = 0.3
Instance.new("UICorner", MainFrame)
MakeDraggable(MainFrame)

local MiniBtn = Instance.new("TextButton")
MiniBtn.Parent = MainFrame
MiniBtn.Size = UDim2.new(0, 20, 0, 20)
MiniBtn.Position = UDim2.new(1, -25, 0, 5)
MiniBtn.Text = "-"
MiniBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", MiniBtn)

local Content = Instance.new("Frame")
Content.Parent = MainFrame
Content.Size = UDim2.new(1, 0, 1, -30)
Content.Position = UDim2.new(0, 0, 0, 30)
Content.BackgroundTransparency = 1

MiniBtn.MouseButton1Click:Connect(function()
    Content.Visible = not Content.Visible
    MainFrame.Size = Content.Visible and UDim2.new(0, 110, 0, 255) or UDim2.new(0, 110, 0, 30)
    MiniBtn.Text = Content.Visible and "-" or "+"
end)

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

local SpeedBtn = CreateMenuBtn("SPEED", UDim2.new(0, 5, 0, 0))
local FlyBtn = CreateMenuBtn("FLY", UDim2.new(0, 5, 0, 35))
local HitboxBtn = CreateMenuBtn("HITBOX", UDim2.new(0, 5, 0, 70))
local EspBtn = CreateMenuBtn("ESP", UDim2.new(0, 5, 0, 105))
local AntiBtn = CreateMenuBtn("ANTI", UDim2.new(0, 5, 0, 140))
local SoundBtn = CreateMenuBtn("SOUND: ON", UDim2.new(0, 5, 0, 175))

local LockedPlayer, StrafeOn, SpeedOn, FlyOn, HitOn, EspOn, AntiOn = nil, false, false, false, false, false, false
local Degree = 0
local AntiVelocity = -1.85

LockBtn.MouseButton1Click:Connect(function()
    StrafeOn = not StrafeOn
    if StrafeOn then
        local Target = GetClosestTargetToCenter()
        if Target then 
            LockedPlayer = Target 
            LockBtn.Text = "🔒"
            LockStroke.Color = Color3.fromRGB(255, 255, 255) 
            Camera.CameraType = Enum.CameraType.Scriptable
        else 
            StrafeOn = false 
        end
    else 
        LockedPlayer = nil 
        LockBtn.Text = "🔓"
        LockStroke.Color = Color3.fromRGB(0, 255, 0) 
        Camera.CameraType = Enum.CameraType.Custom 
    end
end)

SpeedBtn.MouseButton1Click:Connect(function() SpeedOn = not SpeedOn SpeedBtn.TextColor3 = SpeedOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200) end)
FlyBtn.MouseButton1Click:Connect(function() FlyOn = not FlyOn FlyBtn.TextColor3 = FlyOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200) end)
EspBtn.MouseButton1Click:Connect(function() EspOn = not EspOn EspBtn.TextColor3 = EspOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200) end)
AntiBtn.MouseButton1Click:Connect(function() AntiOn = not AntiOn AntiBtn.TextColor3 = AntiOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200) end)
SoundBtn.MouseButton1Click:Connect(function() getgenv().hitsoundEnabled = not getgenv().hitsoundEnabled SoundBtn.Text = getgenv().hitsoundEnabled and "SOUND: ON" or "SOUND: OFF" SoundBtn.TextColor3 = getgenv().hitsoundEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200) end)

RunService.RenderStepped:Connect(function()
    local Char = LocalPlayer.Character
    if not Char or not Char:FindFirstChild("HumanoidRootPart") then return end
    local Root, Hum = Char.HumanoidRootPart, Char.Humanoid
    trackHealth()
    if StrafeOn and LockedPlayer and LockedPlayer.Character and LockedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local TRoot = LockedPlayer.Character.HumanoidRootPart
        Degree = Degree + 1.5
        local TargetPos = TRoot.Position + Vector3.new(math.sin(Degree) * 11, 5, math.cos(Degree) * 11)
        Root.CFrame = CFrame.new(TargetPos, TRoot.Position)
        Camera.CFrame = CFrame.new(TRoot.Position + Vector3.new(0, 5, 12), TRoot.Position)
    end
    if SpeedOn and Hum.MoveDirection.Magnitude > 0 then Root.CFrame = Root.CFrame + (Hum.MoveDirection * 2.5) end
    if FlyOn and not StrafeOn then Root.Velocity = Vector3.new(0, 0, 0) Root.CFrame = Root.CFrame + (Camera.CFrame.LookVector * 3.8) end
    if AntiOn and Hum.MoveDirection.Magnitude > 0 then 
        Root.CFrame = Root.CFrame + (Hum.MoveDirection * AntiVelocity)
        Root.Velocity = Hum.MoveDirection * (AntiVelocity * 100)
    end
end)

Notify("Azured V3 Fatality Loaded!", Color3.fromRGB(0, 255, 0))
