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
local AntiLockY = -10000

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Azured_Mobile_V55"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local VelDot = Drawing.new("Circle")
VelDot.Filled = true
VelDot.Thickness = 1
VelDot.Transparency = 1
VelDot.Radius = 5
VelDot.Color = Color3.fromRGB(170, 120, 210)
VelDot.Visible = false

local function Notify(txt)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Azured Mobile",
        Text = txt,
        Duration = 2
    })
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

local function CreateBigBtn(text, pos)
    local Btn = Instance.new("TextButton")
    Btn.Parent = ScreenGui
    Btn.Size = UDim2.new(0, 110, 0, 40)
    Btn.Position = pos
    Btn.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    Btn.Text = text .. ": OFF"
    Btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 14
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    local S = Instance.new("UIStroke", Btn)
    S.Thickness = 2
    S.Color = Color3.fromRGB(60, 60, 60)
    MakeDraggable(Btn)
    return Btn
end

local LockBtn = Instance.new("TextButton")
LockBtn.Parent = ScreenGui
LockBtn.Size = UDim2.new(0, 60, 0, 60)
LockBtn.Position = UDim2.new(0.85, 0, 0.2, 0)
LockBtn.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
LockBtn.Text = "LOCK"
LockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LockBtn.Font = Enum.Font.SourceSansBold
LockBtn.TextSize = 14
Instance.new("UICorner", LockBtn).CornerRadius = UDim.new(1, 0)
local LockStroke = Instance.new("UIStroke", LockBtn)
LockStroke.Thickness = 2
LockStroke.Color = Color3.fromRGB(70, 70, 70)
MakeDraggable(LockBtn)

local SpeedBtn = CreateBigBtn("SPEED", UDim2.new(0.85, -20, 0.32, 0))
local FlyBtn = CreateBigBtn("FLY", UDim2.new(0.85, -20, 0.4, 0))
local StompBtn = CreateBigBtn("STOMP", UDim2.new(0.85, -20, 0.48, 0))
local HitboxBtn = CreateBigBtn("HITBOX", UDim2.new(0.85, -20, 0.56, 0))
local AntiStompBtn = CreateBigBtn("ANTI STOMP", UDim2.new(0.85, -20, 0.64, 0))
local AntiLockBtn = CreateBigBtn("ANTI LOCK", UDim2.new(0.85, -20, 0.72, 0))
local EspBtn = CreateBigBtn("ESP", UDim2.new(0.85, -20, 0.8, 0))

local LockedPlayer, StrafeOn, SpeedOn, FlyOn, HitOn, StompOn, AntiLockOn, EspOn = nil, false, false, false, false, false, false, false
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

local function CreateEsp(plr)
    local Box = Drawing.new("Square")
    local Name = Drawing.new("Text")
    local Distance = Drawing.new("Text")
    local HealthBar = Drawing.new("Line")
    local ArmorBar = Drawing.new("Line")
    Box.Filled = false
    Box.Thickness = 1.5
    local function UpdateEsp()
        local Connection
        Connection = RunService.RenderStepped:Connect(function()
            if EspOn and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr ~= LocalPlayer then
                local Root = plr.Character.HumanoidRootPart
                local Hum = plr.Character:FindFirstChild("Humanoid")
                local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
                if OnScreen and Hum then
                    local SizeX = 2000 / Pos.Z
                    local SizeY = 3000 / Pos.Z
                    local X = Pos.X - SizeX / 2
                    local Y = Pos.Y - SizeY / 2
                    Box.Visible, Box.Size, Box.Position = true, Vector2.new(SizeX, SizeY), Vector2.new(X, Y)
                    Box.Color = Color3.fromRGB(255, 0, 255)
                    Name.Visible, Name.Text, Name.Position = true, plr.Name, Vector2.new(Pos.X, Y - 16)
                    Name.Size, Name.Center, Name.Outline = 14, true, true
                    local Dist = math.floor((Camera.CFrame.Position - Root.Position).Magnitude)
                    Distance.Visible, Distance.Text, Distance.Position = true, tostring(Dist) .. " studs", Vector2.new(Pos.X, Y + SizeY + 5)
                    Distance.Size, Distance.Center, Distance.Outline = 14, true, true
                    HealthBar.Visible = true
                    HealthBar.From = Vector2.new(X - 5, Y + SizeY)
                    HealthBar.To = Vector2.new(X - 5, Y + SizeY - (SizeY * (Hum.Health / Hum.MaxHealth)))
                    HealthBar.Color = Color3.fromRGB(0, 255, 0)
                    local Armor = plr.Character:FindFirstChild("BodyArmor")
                    local ArmorVal = (Armor and Armor:FindFirstChild("Value")) and Armor.Value.Value or 0
                    ArmorBar.Visible = ArmorVal > 0
                    ArmorBar.From = Vector2.new(X + SizeX + 5, Y + SizeY)
                    ArmorBar.To = Vector2.new(X + SizeX + 5, Y + SizeY - (SizeY * (ArmorVal / 100)))
                    ArmorBar.Color = Color3.fromRGB(0, 150, 255)
                else
                    Box.Visible, Name.Visible, Distance.Visible, HealthBar.Visible, ArmorBar.Visible = false, false, false, false, false
                end
            else
                Box.Visible, Name.Visible, Distance.Visible, HealthBar.Visible, ArmorBar.Visible = false, false, false, false, false
                if not plr.Parent then
                    Box:Remove() Name:Remove() Distance:Remove() HealthBar:Remove() ArmorBar:Remove()
                    Connection:Disconnect()
                end
            end
        end)
    end
    coroutine.wrap(UpdateEsp)()
end

for _, v in pairs(Players:GetPlayers()) do if v ~= LocalPlayer then CreateEsp(v) end end
Players.PlayerAdded:Connect(function(v) CreateEsp(v) end)

AntiStompBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character then
        for _, obj in pairs(LocalPlayer.Character:GetDescendants()) do
            if obj:IsA("BasePart") then obj:Destroy() end
        end
        Notify("Anti Stomp: Character Destroyed")
    end
end)

AntiLockBtn.MouseButton1Click:Connect(function()
    AntiLockOn = not AntiLockOn
    AntiLockBtn.Text = AntiLockOn and "ANTI LOCK: ON" or "ANTI LOCK: OFF"
    VelDot.Visible = AntiLockOn
end)

LockBtn.MouseButton1Click:Connect(function()
    StrafeOn = not StrafeOn
    if StrafeOn then
        local T = GetTarget()
        if T then LockedPlayer = T Camera.CameraType = Enum.CameraType.Scriptable Notify("Lock ON")
        else StrafeOn = false end
    else LockedPlayer = nil Camera.CameraType = Enum.CameraType.Custom Notify("Lock OFF") end
end)

SpeedBtn.MouseButton1Click:Connect(function() SpeedOn = not SpeedOn SpeedBtn.Text = SpeedOn and "SPEED: ON" or "SPEED: OFF" end)
FlyBtn.MouseButton1Click:Connect(function() FlyOn = not FlyOn FlyBtn.Text = FlyOn and "FLY: ON" or "FLY: OFF" end)
StompBtn.MouseButton1Click:Connect(function() StompOn = not StompOn StompBtn.Text = StompOn and "STOMP: ON" or "STOMP: OFF" end)
HitboxBtn.MouseButton1Click:Connect(function() HitOn = not HitOn HitboxBtn.Text = HitOn and "HITBOX: ON" or "HITBOX: OFF" end)
EspBtn.MouseButton1Click:Connect(function() EspOn = not EspOn EspBtn.Text = EspOn and "ESP: ON" or "ESP: OFF" end)

RunService.Heartbeat:Connect(function()
    if AntiLockOn and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local Root = LocalPlayer.Character.HumanoidRootPart
        local Velocity = Root.AssemblyLinearVelocity
        local Cframe = Root.CFrame
        Root.AssemblyLinearVelocity = Vector3.new(0, AntiLockY, 0)
        Root.CFrame = Cframe * CFrame.Angles(0, math.rad(0.1), 0)
        RunService.RenderStepped:Wait()
        Root.AssemblyLinearVelocity = Velocity
    end
end)

RunService.RenderStepped:Connect(function()
    local Char = LocalPlayer.Character
    if not Char or not Char:FindFirstChild("HumanoidRootPart") then 
        VelDot.Visible = false
        return 
    end
    local Root, Hum = Char.HumanoidRootPart, Char.Humanoid

    if AntiLockOn then
        local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position + (Root.AssemblyLinearVelocity * 0.15))
        if OnScreen then
            VelDot.Visible = true
            VelDot.Position = Vector2.new(Pos.X, Pos.Y)
        else
            VelDot.Visible = false
        end
    end

    if StrafeOn and LockedPlayer and LockedPlayer.Character and LockedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local TRoot = LockedPlayer.Character.HumanoidRootPart
        local TChest = GetChestPos(LockedPlayer) or TRoot.Position
        Degree = Degree + 0.025
        local TargetPos = TChest + Vector3.new(math.sin(Degree * 60) * 11, 5, math.cos(Degree * 60) * 11)
        Root.CFrame = CFrame.new(TargetPos, TChest)
        Camera.CFrame = CFrame.new(TChest + Vector3.new(0, 5, 12), TChest)
    end

    if SpeedOn and Hum.MoveDirection.Magnitude > 0 then Root.CFrame = Root.CFrame + (Hum.MoveDirection * SpeedMultiplier) end
    if FlyOn and not StrafeOn then Root.Velocity = Vector3.new(0, 0, 0) Root.CFrame = Root.CFrame + (Camera.CFrame.LookVector * 3.8) end
    
    if StompOn then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local eRoot, eHum = v.Character.HumanoidRootPart, v.Character:FindFirstChild("Humanoid")
                if eHum and eHum.Health <= 15 and (Root.Position - eRoot.Position).Magnitude <= StompRange then ReplicatedStorage.MainEvent:FireServer("Stomp") end
            end
        end
    end

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local pRoot = v.Character.HumanoidRootPart
            if HitOn then pRoot.Size, pRoot.Transparency, pRoot.CanCollide = Vector3.new(HitSize, HitSize, HitSize), 0.8, false
            else pRoot.Size, pRoot.Transparency = Vector3.new(2, 2, 1), 1 end
        end
    end
end)

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
local oldIndex = mt.__index
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if not checkcaller() and method == "FireServer" and self.Name == "MainEvent" then
        if args[1] == "UpdateMousePos" or args[1] == "Shoot" then
            local T = GetTarget()
            local Pos = T and GetChestPos(T)
            if Pos then args[2] = Pos return oldNamecall(self, unpack(args)) end
        end
    end
    return oldNamecall(self, ...)
end)
mt.__index = newcclosure(function(self, idx)
    if self == Mouse and (idx == "Hit" or idx == "Target") and not checkcaller() then
        local T = GetTarget()
        local Pos = T and GetChestPos(T)
        if Pos then return (idx == "Hit" and CFrame.new(Pos) or T.Character:FindFirstChild("UpperTorso") or T.Character.HumanoidRootPart) end
    end
    return oldIndex(self, idx)
end)
setreadonly(mt, true)
