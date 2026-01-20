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

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Aura_V1_Final"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local function Notify(txt)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Aura System",
        Text = txt,
        Duration = 2
    })
end

-- PANEL CHINH HITBOX
local HitboxPanel = Instance.new("Frame")
HitboxPanel.Name = "HitboxPanel"
HitboxPanel.Parent = ScreenGui
HitboxPanel.Size = UDim2.new(0, 200, 0, 100)
HitboxPanel.Position = UDim2.new(0.5, -100, 0.4, 0)
HitboxPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
HitboxPanel.BorderSizePixel = 0
HitboxPanel.Visible = false
Instance.new("UICorner", HitboxPanel)

local HitboxTitle = Instance.new("TextLabel")
HitboxTitle.Parent = HitboxPanel
HitboxTitle.Size = UDim2.new(1, 0, 0, 30)
HitboxTitle.Text = "NHAP SIZE HITBOX"
HitboxTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HitboxTitle.BackgroundTransparency = 1
HitboxTitle.Font = Enum.Font.SourceSansBold
HitboxTitle.TextSize = 14

local HitboxInput = Instance.new("TextBox")
HitboxInput.Parent = HitboxPanel
HitboxInput.Size = UDim2.new(0, 160, 0, 30)
HitboxInput.Position = UDim2.new(0.1, 0, 0.45, 0)
HitboxInput.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
HitboxInput.Text = tostring(HitSize)
HitboxInput.TextColor3 = Color3.fromRGB(0, 255, 150)
HitboxInput.PlaceholderText = "Size (2 - 100)"
Instance.new("UICorner", HitboxInput)

HitboxInput.FocusLost:Connect(function()
    local val = tonumber(HitboxInput.Text)
    if val then 
        HitSize = math.clamp(val, 2, 100) 
        Notify("Da thiet lap Hitbox: " .. HitSize) 
    end
    HitboxPanel.Visible = false
end)

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

local function CreateRoundBtn(text, pos, color)
    local Btn = Instance.new("TextButton")
    Btn.Parent = ScreenGui
    Btn.Size = UDim2.new(0, 65, 0, 65)
    Btn.Position = pos
    Btn.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 14
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)
    local Stroke = Instance.new("UIStroke", Btn)
    Stroke.Thickness = 3
    Stroke.Color = color
    MakeDraggable(Btn)
    return Btn
end

local LockBtn = CreateRoundBtn("LOCK", UDim2.new(0.8, 0, 0.2, 0), Color3.fromRGB(80, 80, 80))
local ViewBtn = CreateRoundBtn("AURA", UDim2.new(0.8, 75, 0.2, 0), Color3.fromRGB(0, 150, 255))

local SpeedBtn = CreateBigBtn("SPEED", UDim2.new(0.8, -10, 0.35, 0))
local FlyBtn = CreateBigBtn("FLY", UDim2.new(0.8, -10, 0.43, 0))
local StompBtn = CreateBigBtn("STOMP", UDim2.new(0.8, -10, 0.51, 0))
local HitboxBtn = CreateBigBtn("HITBOX", UDim2.new(0.8, -10, 0.59, 0))
local BulletTPBtn = CreateBigBtn("BULLET TP", UDim2.new(0.8, -10, 0.67, 0))
local EspBtn = CreateBigBtn("ESP", UDim2.new(0.8, -10, 0.75, 0))

local LockedPlayer, StrafeOn, SpeedOn, FlyOn, HitOn, StompOn, BulletTPOn, EspOn, ViewOn = nil, false, false, false, false, false, false, false, false

-- XU LY NHAN GIU HITBOX 3 GIAY
local holdStart = 0
HitboxBtn.MouseButton1Down:Connect(function() holdStart = tick() end)
HitboxBtn.MouseButton1Up:Connect(function()
    if tick() - holdStart >= 3 then 
        HitboxPanel.Visible = true 
    else 
        HitOn = not HitOn 
        HitboxBtn.Text = HitOn and "HITBOX: ON" or "HITBOX: OFF" 
    end
end)

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

LockBtn.MouseButton1Click:Connect(function()
    StrafeOn = not StrafeOn
    if StrafeOn then
        local T = GetTarget()
        if T then LockedPlayer = T Camera.CameraType = Enum.CameraType.Scriptable Notify("Locked: "..T.Name)
        else StrafeOn = false end
    else LockedPlayer = nil Camera.CameraType = Enum.CameraType.Custom Notify("Lock OFF") end
end)

ViewBtn.MouseButton1Click:Connect(function()
    ViewOn = not ViewOn
    ViewBtn.BackgroundColor3 = ViewOn and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(5, 5, 5)
    if ViewOn then
        local T = GetTarget()
        if T and T.Character and T.Character:FindFirstChild("Humanoid") then
            LockedPlayer = T
            Camera.CameraSubject = T.Character.Humanoid
            Notify("Aura View: " .. T.Name)
        else ViewOn = false ViewBtn.BackgroundColor3 = Color3.fromRGB(5, 5, 5) end
    else
        Camera.CameraSubject = LocalPlayer.Character.Humanoid
        Notify("Aura OFF")
    end
end)

SpeedBtn.MouseButton1Click:Connect(function() SpeedOn = not SpeedOn SpeedBtn.Text = SpeedOn and "SPEED: ON" or "SPEED: OFF" end)
FlyBtn.MouseButton1Click:Connect(function() FlyOn = not FlyOn FlyBtn.Text = FlyOn and "FLY: ON" or "FLY: OFF" end)
StompBtn.MouseButton1Click:Connect(function() StompOn = not StompOn StompBtn.Text = StompOn and "STOMP: ON" or "STOMP: OFF" end)
BulletTPBtn.MouseButton1Click:Connect(function() BulletTPOn = not BulletTPOn BulletTPBtn.Text = BulletTPOn and "BULLET TP: ON" or "BULLET TP: OFF" end)
EspBtn.MouseButton1Click:Connect(function() EspOn = not EspOn EspBtn.Text = EspOn and "ESP: ON" or "ESP: OFF" end)

-- METATABLE HOOKS
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if not checkcaller() and method == "FireServer" and self.Name == "MainEvent" then
        if args[1] == "UpdateMousePos" or args[1] == "Shoot" then
            local T = GetTarget()
            if T then args[2] = GetChestPos(T) return oldNamecall(self, unpack(args)) end
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- MAIN LOOP
RunService.RenderStepped:Connect(function()
    local Char = LocalPlayer.Character
    if not Char or not Char:FindFirstChild("HumanoidRootPart") then return end
    local Root, Hum = Char.HumanoidRootPart, Char.Humanoid

    -- LOGIC AURA VIEW (Bay 500 studs)
    if ViewOn and LockedPlayer and LockedPlayer.Character and LockedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local TRoot = LockedPlayer.Character.HumanoidRootPart
        Root.Velocity = Vector3.new(0, 0, 0)
        Root.CFrame = CFrame.new(TRoot.Position + Vector3.new(0, 500, 0))
    end

    if SpeedOn and Hum.MoveDirection.Magnitude > 0 then Root.CFrame = Root.CFrame + (Hum.MoveDirection * SpeedMultiplier) end
    if FlyOn and not ViewOn then Root.Velocity = Vector3.new(0, 0, 0) Root.CFrame = Root.CFrame + (Camera.CFrame.LookVector * 4) end

    -- CAP NHAT HITBOX
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local pRoot = v.Character.HumanoidRootPart
            if HitOn then
                pRoot.Size = Vector3.new(HitSize, HitSize, HitSize)
                pRoot.Transparency = 0.7
                pRoot.CanCollide = false
            else
                pRoot.Size = Vector3.new(2, 2, 1)
                pRoot.Transparency = 1
                pRoot.CanCollide = true
            end
        end
    end
    
    -- AUTO STOMP
    if StompOn then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") then
                local eRoot = v.Character:FindFirstChild("HumanoidRootPart")
                local eHum = v.Character.Humanoid
                if eRoot and eHum.Health <= 15 and (Root.Position - eRoot.Position).Magnitude <= StompRange then
                    ReplicatedStorage.MainEvent:FireServer("Stomp")
                end
            end
        end
    end
end)
