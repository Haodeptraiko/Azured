local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local FovSize = 150
local StompRange = 20 
local HitSize = 200 -- Mac dinh 200
local SpeedMultiplier = 3.5

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Aura_Mobile_V3_Final"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local function Notify(txt)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Aura Mobile",
        Text = txt,
        Duration = 2
    })
end

-- SILENT FOV CIRCLE
local FovCircle = Instance.new("Frame")
FovCircle.Parent = ScreenGui
FovCircle.Size = UDim2.new(0, FovSize, 0, FovSize)
FovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FovCircle.BackgroundTransparency = 1
local StrokeFOV = Instance.new("UIStroke", FovCircle)
StrokeFOV.Thickness = 1
StrokeFOV.Color = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", FovCircle).CornerRadius = UDim.new(1, 0)

-- HITBOX SLIDER PANEL
local HitboxPanel = Instance.new("Frame")
HitboxPanel.Parent = ScreenGui
HitboxPanel.Size = UDim2.new(0, 260, 0, 110)
HitboxPanel.Position = UDim2.new(0.5, -130, 0.4, 0)
HitboxPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
HitboxPanel.BorderSizePixel = 0
HitboxPanel.Visible = false
HitboxPanel.ZIndex = 15
Instance.new("UICorner", HitboxPanel)

local HitLabel = Instance.new("TextLabel")
HitLabel.Parent = HitboxPanel
HitLabel.Size = UDim2.new(1, 0, 0, 40)
HitLabel.Text = "HITBOX SIZE: 200"
HitLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
HitLabel.BackgroundTransparency = 1
HitLabel.Font = Enum.Font.SourceSansBold
HitLabel.TextSize = 16

local SliderBack = Instance.new("Frame")
SliderBack.Parent = HitboxPanel
SliderBack.Size = UDim2.new(0, 200, 0, 12)
SliderBack.Position = UDim2.new(0.5, -100, 0.65, 0)
SliderBack.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Instance.new("UICorner", SliderBack)

local SliderMain = Instance.new("TextButton")
SliderMain.Parent = SliderBack
SliderMain.Size = UDim2.new(0, 25, 0, 25)
SliderMain.Position = UDim2.new(0.05, 0, -0.5, 0)
SliderMain.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
SliderMain.Text = ""
Instance.new("UICorner", SliderMain)

local function UpdateSlider(input)
    local pos = math.clamp((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
    SliderMain.Position = UDim2.new(pos, -12, -0.5, 0)
    HitSize = math.floor(150 + (pos * 850)) -- 150 -> 1000
    HitLabel.Text = "HITBOX SIZE: " .. HitSize
end

local draggingSlider = false
SliderMain.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSlider = true end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        UpdateSlider(input)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
        draggingSlider = false 
        task.wait(0.5)
        if not draggingSlider then HitboxPanel.Visible = false end
    end
end)

local function MakeDraggable(obj)
    local Dragging, DragInput, DragStart, StartPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true DragStart = input.Position StartPos = obj.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local Delta = input.Position - DragStart
            obj.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        end
    end)
    obj.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then Dragging = false end
    end)
end

local function CreateBigBtn(text, pos)
    local Btn = Instance.new("TextButton")
    Btn.Parent = ScreenGui
    Btn.Size = UDim2.new(0, 115, 0, 42)
    Btn.Position = pos
    Btn.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    Btn.Text = text .. ": OFF"
    Btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 14
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    local S = Instance.new("UIStroke", Btn)
    S.Thickness = 2
    S.Color = Color3.fromRGB(70, 70, 70)
    MakeDraggable(Btn)
    return Btn
end

local function CreateRoundBtn(text, pos, color)
    local Btn = Instance.new("TextButton")
    Btn.Parent = ScreenGui
    Btn.Size = UDim2.new(0, 68, 0, 68)
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

local LockBtn = CreateRoundBtn("LOCK", UDim2.new(0.8, 0, 0.15, 0), Color3.fromRGB(80, 80, 80))
local ViewBtn = CreateRoundBtn("AURA", UDim2.new(0.8, 75, 0.15, 0), Color3.fromRGB(0, 150, 255))

local SpeedBtn = CreateBigBtn("SPEED", UDim2.new(0.8, -10, 0.32, 0))
local FlyBtn = CreateBigBtn("FLY", UDim2.new(0.8, -10, 0.40, 0))
local StompBtn = CreateBigBtn("STOMP", UDim2.new(0.8, -10, 0.48, 0))
local HitboxBtn = CreateBigBtn("HITBOX", UDim2.new(0.8, -10, 0.56, 0))
local BulletTPBtn = CreateBigBtn("BULLET TP", UDim2.new(0.8, -10, 0.64, 0))
local EspBtn = CreateBigBtn("ESP", UDim2.new(0.8, -10, 0.72, 0))

local LockedPlayer, SpeedOn, FlyOn, HitOn, StompOn, BulletTPOn, EspOn, ViewOn = nil, false, false, false, false, false, false, false

-- HANDLE HITBOX HOLD 3s
local holdStart = 0
local isHolding = false
HitboxBtn.MouseButton1Down:Connect(function() 
    holdStart = tick() 
    isHolding = true
    task.spawn(function()
        while isHolding do
            if tick() - holdStart >= 3 then HitboxPanel.Visible = true isHolding = false break end
            task.wait(0.1)
        end
    end)
end)
HitboxBtn.MouseButton1Up:Connect(function() 
    if isHolding then HitOn = not HitOn HitboxBtn.Text = HitOn and "HITBOX: ON" or "HITBOX: OFF" end
    isHolding = false
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

LockBtn.MouseButton1Click:Connect(function()
    local T = GetTarget()
    if T then LockedPlayer = T Notify("Locked: "..T.Name) else LockedPlayer = nil end
end)

ViewBtn.MouseButton1Click:Connect(function()
    ViewOn = not ViewOn
    ViewBtn.BackgroundColor3 = ViewOn and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(5, 5, 5)
    if ViewOn then
        local T = GetTarget()
        if T and T.Character and T.Character:FindFirstChild("Humanoid") then
            LockedPlayer = T
            Camera.CameraSubject = T.Character.Humanoid
            Notify("Aura View ON")
        else ViewOn = false ViewBtn.BackgroundColor3 = Color3.fromRGB(5, 5, 5) end
    else
        Camera.CameraSubject = LocalPlayer.Character.Humanoid
        Notify("Aura View OFF")
    end
end)

SpeedBtn.MouseButton1Click:Connect(function() SpeedOn = not SpeedOn SpeedBtn.Text = SpeedOn and "SPEED: ON" or "SPEED: OFF" end)
FlyBtn.MouseButton1Click:Connect(function() FlyOn = not FlyOn FlyBtn.Text = FlyOn and "FLY: ON" or "FLY: OFF" end)
StompBtn.MouseButton1Click:Connect(function() StompOn = not StompOn StompBtn.Text = StompOn and "STOMP: ON" or "STOMP: OFF" end)
BulletTPBtn.MouseButton1Click:Connect(function() BulletTPOn = not BulletTPOn BulletTPBtn.Text = BulletTPOn and "BULLET TP: ON" or "BULLET TP: OFF" end)
EspBtn.MouseButton1Click:Connect(function() EspOn = not EspOn EspBtn.Text = EspOn and "ESP: ON" or "ESP: OFF" end)

-- SILENT AIM
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    if not checkcaller() and getnamecallmethod() == "FireServer" and self.Name == "MainEvent" then
        if args[1] == "UpdateMousePos" or args[1] == "Shoot" then
            local T = GetTarget()
            if T and T.Character:FindFirstChild("HumanoidRootPart") then
                args[2] = T.Character.HumanoidRootPart.Position
                return oldNamecall(self, unpack(args))
            end
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

    -- AURA LOGIC
    if ViewOn and LockedPlayer and LockedPlayer.Character and LockedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Root.Velocity = Vector3.new(0, 0, 0)
        Root.CFrame = CFrame.new(LockedPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 500, 0))
    end

    if SpeedOn and Hum.MoveDirection.Magnitude > 0 then Root.CFrame = Root.CFrame + (Hum.MoveDirection * SpeedMultiplier) end
    if FlyOn and not ViewOn then Root.Velocity = Vector3.new(0, 0, 0) Root.CFrame = Root.CFrame + (Camera.CFrame.LookVector * 4) end

    -- HITBOX UPDATE
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

    -- STOMP
    if StompOn then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") then
                local eRoot = v.Character:FindFirstChild("HumanoidRootPart")
                if eRoot and v.Character.Humanoid.Health <= 15 and (Root.Position - eRoot.Position).Magnitude <= StompRange then
                    ReplicatedStorage.MainEvent:FireServer("Stomp")
                end
            end
        end
    end
end)
