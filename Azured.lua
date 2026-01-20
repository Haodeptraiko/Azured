local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Variables
local FovSize = 150
local StompRange = 15 
local SpeedMultiplier = 3.5
local Degree = 0
local LockedPlayer, StrafeOn, SilentOn, SpeedOn, FlyOn, HitOn, EspOn, StompOn, AntiStompOn = nil, false, false, false, false, false, false, false, false

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Azured_V3_LegacyStyle"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Intro
local IntroLabel = Instance.new("TextLabel")
IntroLabel.Parent = ScreenGui
IntroLabel.Size = UDim2.new(1, 0, 0, 50)
IntroLabel.Position = UDim2.new(0, 0, 0.2, 0)
IntroLabel.BackgroundTransparency = 1
IntroLabel.Text = "Azured"
IntroLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
IntroLabel.Font = Enum.Font.GothamBold
IntroLabel.TextSize = 25
IntroLabel.TextTransparency = 1
local IntroStroke = Instance.new("UIStroke", IntroLabel)
IntroStroke.Thickness = 2
IntroStroke.Color = Color3.fromRGB(0, 255, 0)
IntroStroke.Transparency = 1

task.spawn(function()
    local TweenService = game:GetService("TweenService")
    local Info = TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    TweenService:Create(IntroLabel, Info, {TextTransparency = 0, Position = UDim2.new(0, 0, 0.25, 0)}):Play()
    TweenService:Create(IntroStroke, Info, {Transparency = 0}):Play()
    task.wait(2)
    TweenService:Create(IntroLabel, Info, {TextTransparency = 1, Position = UDim2.new(0, 0, 0.2, 0)}):Play()
    TweenService:Create(IntroStroke, Info, {Transparency = 1}):Play()
    task.wait(1)
    IntroLabel:Destroy()
end)

-- Draggable Function
local function MakeDraggable(obj)
    local Dragging, DragInput, DragStart, StartPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true; DragStart = input.Position; StartPos = obj.Position
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

-- Create Round Button for LOCK
local function CreateRoundBtn(text, pos, color)
    local Btn = Instance.new("TextButton")
    Btn.Parent = ScreenGui
    Btn.Size = UDim2.new(0, 65, 0, 65)
    Btn.Position = pos
    Btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Btn.Text = text
    Btn.TextColor3 = color
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 11
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)
    local Stroke = Instance.new("UIStroke", Btn)
    Stroke.Thickness = 3
    Stroke.Color = color
    MakeDraggable(Btn)
    return Btn, Stroke
end

local LockBtn, LockStroke = CreateRoundBtn("LOCK", UDim2.new(0.8, 0, 0.4, 0), Color3.fromRGB(0, 255, 0))

-- Main Menu Frame
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 120, 0, 280)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
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

local Content = Instance.new("ScrollingFrame")
Content.Parent = MainFrame
Content.Size = UDim2.new(1, 0, 1, -35)
Content.Position = UDim2.new(0, 0, 0, 30)
Content.BackgroundTransparency = 1
Content.CanvasSize = UDim2.new(0, 0, 1.5, 0)
Content.ScrollBarThickness = 2
local Layout = Instance.new("UIListLayout", Content)
Layout.Padding = UDim.new(0, 5)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

MiniBtn.MouseButton1Click:Connect(function()
    Content.Visible = not Content.Visible
    MainFrame.Size = Content.Visible and UDim2.new(0, 120, 0, 280) or UDim2.new(0, 120, 0, 30)
    MiniBtn.Text = Content.Visible and "-" or "+"
end)

local function CreateMenuBtn(name)
    local Btn = Instance.new("TextButton")
    Btn.Parent = Content
    Btn.Size = UDim2.new(0, 100, 0, 30)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Btn.Text = name
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 10
    Instance.new("UICorner", Btn)
    return Btn
end

-- Menu Buttons
local SilentBtn = CreateMenuBtn("SILENT AIM")
local SpeedBtn = CreateMenuBtn("SPEED")
local FlyBtn = CreateMenuBtn("FLY")
local HitboxBtn = CreateMenuBtn("HITBOX")
local EspBtn = CreateMenuBtn("ESP NAME")
local StompBtn = CreateMenuBtn("AUTO STOMP")
local AntiBtn = CreateMenuBtn("ANTI STOMP")

-- Drawing FOV for Silent Aim
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1; FovCircle.NumSides = 100; FovCircle.Radius = FovSize
FovCircle.Filled = false; FovCircle.Color = Color3.fromRGB(255, 255, 255); FovCircle.Visible = false

-- Logic Functions
local function GetTarget(fov)
    local Target, MinDist = nil, fov or math.huge
    local Center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if v.Character.Humanoid.Health > 0 then
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

local function GetChestPos(p)
    if not p or not p.Character then return nil end
    return p.Character:FindFirstChild("UpperTorso") and p.Character.UpperTorso.Position or p.Character.HumanoidRootPart.Position
end

-- Button Events
LockBtn.MouseButton1Click:Connect(function()
    StrafeOn = not StrafeOn
    if StrafeOn then
        local T = GetTarget()
        if T then LockedPlayer = T; LockStroke.Color = Color3.fromRGB(255, 255, 255); Camera.CameraType = Enum.CameraType.Scriptable
        else StrafeOn = false end
    else
        LockedPlayer = nil; LockStroke.Color = Color3.fromRGB(0, 255, 0); Camera.CameraType = Enum.CameraType.Custom
    end
end)

SilentBtn.MouseButton1Click:Connect(function() SilentOn = not SilentOn; FovCircle.Visible = SilentOn; SilentBtn.TextColor3 = SilentOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200) end)
SpeedBtn.MouseButton1Click:Connect(function() SpeedOn = not SpeedOn; SpeedBtn.TextColor3 = SpeedOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200) end)
FlyBtn.MouseButton1Click:Connect(function() FlyOn = not FlyOn; FlyBtn.TextColor3 = FlyOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200) end)
HitboxBtn.MouseButton1Click:Connect(function() HitOn = not HitOn; HitboxBtn.TextColor3 = HitOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200) end)
EspBtn.MouseButton1Click:Connect(function() EspOn = not EspOn; EspBtn.TextColor3 = EspOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200) end)
StompBtn.MouseButton1Click:Connect(function() StompOn = not StompOn; StompBtn.TextColor3 = StompOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200) end)
AntiBtn.MouseButton1Click:Connect(function() AntiStompOn = not AntiStompOn; AntiBtn.TextColor3 = AntiStompOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200) end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    FovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local Char = LocalPlayer.Character
    if not Char or not Char:FindFirstChild("HumanoidRootPart") then return end
    local Root, Hum = Char.HumanoidRootPart, Char.Humanoid

    -- Strafe Lock Logic
    if StrafeOn and LockedPlayer and LockedPlayer.Character and LockedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        if LockedPlayer.Character.Humanoid.Health <= 0 then
            StrafeOn = false; LockedPlayer = nil; LockStroke.Color = Color3.fromRGB(0, 255, 0); Camera.CameraType = Enum.CameraType.Custom
        else
            local TRoot = LockedPlayer.Character.HumanoidRootPart
            Degree = Degree + 0.03
            local TargetPos = TRoot.Position + Vector3.new(math.sin(Degree*60) * 11, 5, math.cos(Degree*60) * 11)
            Root.CFrame = CFrame.new(TargetPos, TRoot.Position)
            Camera.CFrame = CFrame.new(TRoot.Position + Vector3.new(0, 5, 12), TRoot.Position)
        end
    end

    if SpeedOn and Hum.MoveDirection.Magnitude > 0 then Root.CFrame = Root.CFrame + (Hum.MoveDirection * SpeedMultiplier) end
    if FlyOn and not StrafeOn then Root.Velocity = Vector3.new(0, 0, 0); Root.CFrame = Root.CFrame + (Camera.CFrame.LookVector * 3.8) end

    -- Stomp Logic
    if StompOn then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and (Root.Position - v.Character.HumanoidRootPart.Position).Magnitude <= StompRange then
                if v.Character.Humanoid.Health <= 15 then ReplicatedStorage.MainEvent:FireServer("Stomp") end
            end
        end
    end
end)

-- Metatable Hook for Silent Aim & Anti Stomp
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if not checkcaller() and method == "FireServer" and self.Name == "MainEvent" then
        if (args[1] == "UpdateMousePos" or args[1] == "Shoot") and SilentOn then
            local ST = GetTarget(FovSize)
            if ST then args[2] = GetChestPos(ST) return old(self, unpack(args)) end
        end
        if args[1] == "Stomp" and AntiStompOn and LocalPlayer.Character.Humanoid.Health <= 15 then return nil end
    end
    return old(self, unpack(args))
end)
setreadonly(mt, true)

-- ESP & Hitbox Loop
task.spawn(function()
    while task.wait(0.5) do
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local pRoot = v.Character.HumanoidRootPart
                -- Hitbox
                if HitOn then pRoot.Size, pRoot.Transparency, pRoot.CanCollide = Vector3.new(30,30,30), 0.7, false
                else pRoot.Size, pRoot.Transparency = Vector3.new(2,2,1), 1 end
                -- ESP
                local Tag = pRoot:FindFirstChild("EspTag")
                if EspOn then
                    if not Tag then
                        Tag = Instance.new("BillboardGui", pRoot); Tag.Name = "EspTag"; Tag.Size = UDim2.new(0, 100, 0, 40); Tag.AlwaysOnTop = true
                        local L = Instance.new("TextLabel", Tag); L.Size = UDim2.new(1,0,1,0); L.BackgroundTransparency = 1; L.TextColor3 = Color3.fromRGB(255,255,255); L.TextSize = 10; L.Font = Enum.Font.GothamBold; L.Text = v.Name
                    end
                elseif Tag then Tag:Destroy() end
            end
        end
    end
end)
