local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local FovSize = 150
local StompRange = 15 
local HitSize = 15

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Azured_Final_V29"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local FovCircle = Instance.new("Frame")
FovCircle.Parent = ScreenGui
FovCircle.Size = UDim2.new(0, FovSize, 0, FovSize)
FovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FovCircle.BackgroundTransparency = 1
local StrokeFOV = Instance.new("UIStroke", FovCircle)
StrokeFOV.Thickness = 1
StrokeFOV.Color = Color3.fromRGB(150, 150, 150)
Instance.new("UICorner", FovCircle).CornerRadius = UDim.new(1, 0)

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

local function CreateLongBtn(text, pos)
    local Btn = Instance.new("TextButton")
    Btn.Parent = ScreenGui
    Btn.Size = UDim2.new(0, 110, 0, 35)
    Btn.Position = pos
    Btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Btn.Text = text .. ": OFF"
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.Font = Enum.Font.SourceSans
    Btn.TextSize = 14
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    local S = Instance.new("UIStroke", Btn)
    S.Thickness = 1
    S.Color = Color3.fromRGB(40, 40, 40)
    MakeDraggable(Btn)
    return Btn, S
end

local LockBtn = Instance.new("TextButton")
LockBtn.Parent = ScreenGui
LockBtn.Size = UDim2.new(0, 60, 0, 60)
LockBtn.Position = UDim2.new(0.85, 0, 0.25, 0)
LockBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
LockBtn.Text = "LOCK"
LockBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
LockBtn.Font = Enum.Font.SourceSansBold
LockBtn.TextSize = 12
Instance.new("UICorner", LockBtn).CornerRadius = UDim.new(1, 0)
local LockStroke = Instance.new("UIStroke", LockBtn)
LockStroke.Thickness = 1
LockStroke.Color = Color3.fromRGB(40, 40, 40)
MakeDraggable(LockBtn)

local SpeedBtn = CreateLongBtn("SPEED", UDim2.new(0.85, -25, 0.38, 0))
local FlyBtn = CreateLongBtn("FLY", UDim2.new(0.85, -25, 0.45, 0))
local StompBtn = CreateLongBtn("STOMP", UDim2.new(0.85, -25, 0.52, 0))
local HitboxBtn = CreateLongBtn("HITBOX", UDim2.new(0.85, -25, 0.59, 0))

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
                if OnScreen then
                    local Dist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Center).Magnitude
                    if Dist < MinDist then MinDist = Dist; Target = v end
                end
            end
        end
    end
    return Target
end

local function CreateTracer(TargetPos)
    local Char = LocalPlayer.Character
    if not Char then return end
    local StartPart = Char:FindFirstChild("RightHand") or Char:FindFirstChild("Right Arm") or Char:FindFirstChild("HumanoidRootPart")
    local StartPos = StartPart.Position
    
    local Part = Instance.new("Part")
    Part.Name = "AzuredTracer"
    Part.Parent = workspace
    Part.Anchored = true
    Part.CanCollide = false
    Part.Material = Enum.Material.Neon
    Part.Color = Color3.fromRGB(0, 180, 255)
    Part.Transparency = 0
    
    local Dist = (StartPos - TargetPos).Magnitude
    Part.Size = Vector3.new(0.15, 0.15, Dist)
    Part.CFrame = CFrame.new(StartPos, TargetPos) * CFrame.new(0, 0, -Dist/2)
    
    TweenService:Create(Part, TweenInfo.new(0.4), {Transparency = 1, Size = Vector3.new(0, 0, Dist)}):Play()
    task.delay(0.4, function() Part:Destroy() end)
end

LockBtn.MouseButton1Click:Connect(function()
    StrafeOn = not StrafeOn
    if StrafeOn then
        local T = GetTarget()
        if T then LockedPlayer = T Camera.CameraType = Enum.CameraType.Scriptable
        else StrafeOn = false end
    else LockedPlayer = nil Camera.CameraType = Enum.CameraType.Custom end
end)

SpeedBtn.MouseButton1Click:Connect(function() SpeedOn = not SpeedOn SpeedBtn.Text = SpeedOn and "SPEED: ON" or "SPEED: OFF" end)
FlyBtn.MouseButton1Click:Connect(function() FlyOn = not FlyOn FlyBtn.Text = FlyOn and "FLY: ON" or "FLY: OFF" end)
StompBtn.MouseButton1Click:Connect(function() StompOn = not StompOn StompBtn.Text = StompOn and "STOMP: ON" or "STOMP: OFF" end)
HitboxBtn.MouseButton1Click:Connect(function() HitOn = not HitOn HitboxBtn.Text = HitOn and "HITBOX: ON" or "HITBOX: OFF" end)

local mt = getrawmetatable(game)
local oldIndex, oldNamecall = mt.__index, mt.__namecall
setreadonly(mt, false)

mt.__index = newcclosure(function(t, k)
    if t == Mouse and (k == "Hit" or k == "Target") then
        local T = GetTarget()
        if T and T.Character and T.Character:FindFirstChild("Head") then
            if k == "Hit" then return T.Character.Head.CFrame end
            if k == "Target" then return T.Character.Head end
        end
    end
    return oldIndex(t, k)
end)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if method == "FireServer" and self.Name == "MainEvent" then
        if args[1] == "Shoot" or args[1] == "UpdateMousePos" then
            local T = GetTarget()
            local TargetPosition
            
            if T and T.Character and T.Character:FindFirstChild("Head") then
                TargetPosition = T.Character.Head.Position
                args[2] = TargetPosition
            else
                TargetPosition = Mouse.Hit.Position
            end
            
            if args[1] == "Shoot" then
                CreateTracer(TargetPosition)
            end
            
            return oldNamecall(self, unpack(args))
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
        Degree = Degree + 0.025
        local TargetPos = TRoot.Position + Vector3.new(math.sin(Degree * 60) * 11, 5, math.cos(Degree * 60) * 11)
        Root.CFrame = CFrame.new(TargetPos, TRoot.Position)
        Camera.CFrame = CFrame.new(TRoot.Position + Vector3.new(0, 5, 12), TRoot.Position)
    end

    if SpeedOn and Hum.MoveDirection.Magnitude > 0 then Root.CFrame = Root.CFrame + (Hum.MoveDirection * 2.5) end
    if FlyOn and not StrafeOn then Root.Velocity = Vector3.new(0, 0, 0) Root.CFrame = Root.CFrame + (Camera.CFrame.LookVector * 3.8) end

    if StompOn then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local eRoot = v.Character.HumanoidRootPart
                local eHum = v.Character:FindFirstChild("Humanoid")
                if eHum and eHum.Health <= 15 and (Root.Position - eRoot.Position).Magnitude <= StompRange then
                    local ME = ReplicatedStorage:FindFirstChild("MainEvent")
                    if ME then ME:FireServer("Stomp") end
                end
            end
        end
    end

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            local pRoot = v.Character:FindFirstChild("HumanoidRootPart")
            if pRoot then
                if HitOn then pRoot.Size = Vector3.new(HitSize, HitSize, HitSize) pRoot.Transparency = 0.8 pRoot.CanCollide = false
                else pRoot.Size = Vector3.new(2, 2, 1) pRoot.Transparency = 1 end
            end
        end
    end
end)
