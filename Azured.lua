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
ScreenGui.Name = "Azured_Chest_V55_Fixed_Drag"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local function Notify(txt)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Azured PC",
        Text = txt,
        Duration = 2
    })
end

-- He thong keo tha chuyen dung cho Mobile va PC
local function MakeDraggable(gui, dragHandle)
    local dragging, dragInput, dragStart, startPos
    local handle = dragHandle or gui

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- 1. FOV CIRCLE
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

-- 2. MENU CHINH
local MenuMain = Instance.new("Frame")
MenuMain.Name = "MenuMain"
MenuMain.Parent = ScreenGui
MenuMain.Size = UDim2.new(0, 130, 0, 40)
MenuMain.Position = UDim2.new(0.85, 0, 0.32, 0)
MenuMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MenuMain.ClipsDescendants = true
MenuMain.Active = true
Instance.new("UICorner", MenuMain).CornerRadius = UDim.new(0, 8)
local MenuStroke = Instance.new("UIStroke", MenuMain)
MenuStroke.Thickness = 2
MenuStroke.Color = Color3.fromRGB(60, 60, 60)

-- Vung dem de keo (Quan trong)
local DragHandle = Instance.new("Frame")
DragHandle.Name = "DragHandle"
DragHandle.Parent = MenuMain
DragHandle.Size = UDim2.new(1, 0, 0, 40)
DragHandle.BackgroundTransparency = 1
DragHandle.ZIndex = 5 -- Nam tren cung de nhan tin hieu keo
MakeDraggable(MenuMain, DragHandle)

local MenuToggle = Instance.new("TextButton")
MenuToggle.Parent = MenuMain
MenuToggle.Size = UDim2.new(1, 0, 0, 40)
MenuToggle.BackgroundTransparency = 1
MenuToggle.Text = "MENU [OPEN]"
MenuToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuToggle.Font = Enum.Font.SourceSansBold
MenuToggle.TextSize = 14
MenuToggle.ZIndex = 4

local ButtonContainer = Instance.new("Frame")
ButtonContainer.Parent = MenuMain
ButtonContainer.Position = UDim2.new(0, 0, 0, 40)
ButtonContainer.Size = UDim2.new(1, 0, 0, 240)
ButtonContainer.BackgroundTransparency = 1

local UIList = Instance.new("UIListLayout", ButtonContainer)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 2)

local function CreateMenuBtn(text)
    local Btn = Instance.new("TextButton")
    Btn.Parent = ButtonContainer
    Btn.Size = UDim2.new(1, -10, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Btn.Text = text .. ": OFF"
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 13
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    local s = Instance.new("UIStroke", Btn)
    s.Thickness = 1
    s.Color = Color3.fromRGB(45, 45, 45)
    return Btn
end

local SpeedBtn = CreateMenuBtn("SPEED")
local FlyBtn = CreateMenuBtn("FLY")
local HitboxBtn = CreateMenuBtn("HITBOX")
local StompBtn = CreateMenuBtn("STOMP")
local ReloadBtn = CreateMenuBtn("AUTO RELOAD")
local AnimBtn = CreateMenuBtn("ANIMATION")

local MenuOpened = false
MenuToggle.MouseButton1Click:Connect(function()
    MenuOpened = not MenuOpened
    if MenuOpened then
        MenuMain:TweenSize(UDim2.new(0, 130, 0, 280), "Out", "Quart", 0.3, true)
        MenuToggle.Text = "MENU [CLOSE]"
    else
        MenuMain:TweenSize(UDim2.new(0, 130, 0, 40), "Out", "Quart", 0.3, true)
        MenuToggle.Text = "MENU [OPEN]"
    end
end)

-- 3. LOCK & AURA BUTTONS
local LockBtn = Instance.new("TextButton")
LockBtn.Parent = ScreenGui
LockBtn.Size = UDim2.new(0, 55, 0, 55)
LockBtn.Position = UDim2.new(0.85, 0, 0.2, 0)
LockBtn.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
LockBtn.Text = "LOCK"
LockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LockBtn.Font = Enum.Font.SourceSansBold
LockBtn.TextSize = 13
Instance.new("UICorner", LockBtn).CornerRadius = UDim.new(1, 0)
local LockStroke = Instance.new("UIStroke", LockBtn)
LockStroke.Thickness = 2
LockStroke.Color = Color3.fromRGB(70, 70, 70)
MakeDraggable(LockBtn)

local AuraBtn = Instance.new("TextButton")
AuraBtn.Parent = ScreenGui
AuraBtn.Size = UDim2.new(0, 55, 0, 55)
AuraBtn.Position = UDim2.new(0.85, 60, 0.2, 0)
AuraBtn.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
AuraBtn.Text = "AURA"
AuraBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AuraBtn.Font = Enum.Font.SourceSansBold
AuraBtn.TextSize = 13
Instance.new("UICorner", AuraBtn).CornerRadius = UDim.new(1, 0)
local AuraStroke = Instance.new("UIStroke", AuraBtn)
AuraStroke.Thickness = 2
AuraStroke.Color = Color3.fromRGB(0, 150, 255)
MakeDraggable(AuraBtn)

-- 4. TARGET UI
local TargetUI = Instance.new("Frame")
TargetUI.Parent = ScreenGui
TargetUI.Size = UDim2.new(0, 140, 0, 50)
TargetUI.Position = UDim2.new(0.02, 0, 0.7, 0)
TargetUI.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TargetUI.BackgroundTransparency = 0.4
TargetUI.Visible = false
Instance.new("UICorner", TargetUI)

local TargetName = Instance.new("TextLabel")
TargetName.Parent = TargetUI
TargetName.Size = UDim2.new(1, 0, 0, 20)
TargetName.BackgroundTransparency = 1
TargetName.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetName.Font = Enum.Font.SourceSansBold
TargetName.TextSize = 12

local HealthBarBack = Instance.new("Frame")
HealthBarBack.Parent = TargetUI
HealthBarBack.Position = UDim2.new(0.1, 0, 0.5, 0)
HealthBarBack.Size = UDim2.new(0.8, 0, 0, 6)
HealthBarBack.BackgroundColor3 = Color3.fromRGB(30, 0, 0)

local HealthBarMain = Instance.new("Frame")
HealthBarMain.Parent = HealthBarBack
HealthBarMain.Size = UDim2.new(1, 0, 1, 0)
HealthBarMain.BackgroundColor3 = Color3.fromRGB(0, 255, 120)

local ArmorLabel = Instance.new("TextLabel")
ArmorLabel.Parent = TargetUI
ArmorLabel.Position = UDim2.new(0, 0, 0.75, 0)
ArmorLabel.Size = UDim2.new(1, 0, 0, 12)
ArmorLabel.BackgroundTransparency = 1
ArmorLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
ArmorLabel.Font = Enum.Font.SourceSans
ArmorLabel.TextSize = 10

-- LOGIC
local LockedPlayer, StrafeOn, SpeedOn, FlyOn, HitOn, StompOn, ViewOn, ReloadOn, AnimOn = nil, false, false, false, false, false, false, false, false
local Degree = 0
local LastPos = nil

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

SpeedBtn.MouseButton1Click:Connect(function() SpeedOn = not SpeedOn SpeedBtn.Text = SpeedOn and "SPEED: ON" or "SPEED: OFF" end)
FlyBtn.MouseButton1Click:Connect(function() FlyOn = not FlyOn FlyBtn.Text = FlyOn and "FLY: ON" or "FLY: OFF" end)
HitboxBtn.MouseButton1Click:Connect(function() HitOn = not HitOn HitboxBtn.Text = HitOn and "HITBOX: ON" or "HITBOX: OFF" end)
StompBtn.MouseButton1Click:Connect(function() StompOn = not StompOn StompBtn.Text = StompOn and "STOMP: ON" or "STOMP: OFF" end)
ReloadBtn.MouseButton1Click:Connect(function() ReloadOn = not ReloadOn ReloadBtn.Text = ReloadOn and "AUTO RELOAD: ON" or "AUTO RELOAD: OFF" end)
AnimBtn.MouseButton1Click:Connect(function() AnimOn = not AnimOn AnimBtn.Text = AnimOn and "ANIMATION: ON" or "ANIMATION: OFF" end)

LockBtn.MouseButton1Click:Connect(function()
    StrafeOn = not StrafeOn
    if StrafeOn then
        local T = GetTarget()
        if T then LockedPlayer = T Camera.CameraType = Enum.CameraType.Scriptable Notify("Lock ON: " .. T.Name)
        else StrafeOn = false end
    else LockedPlayer = nil Camera.CameraType = Enum.CameraType.Custom Notify("Lock OFF") end
end)

AuraBtn.MouseButton1Click:Connect(function()
    ViewOn = not ViewOn
    local Char = LocalPlayer.Character
    local Root = Char and Char:FindFirstChild("HumanoidRootPart")
    AuraBtn.BackgroundColor3 = ViewOn and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(5, 5, 5)
    if ViewOn then
        if Root then LastPos = Root.CFrame end
        local T = GetTarget()
        if T and T.Character and T.Character:FindFirstChild("Humanoid") then
            LockedPlayer = T Camera.CameraSubject = T.Character.Humanoid Notify("Aura View: " .. T.Name)
        else ViewOn = false AuraBtn.BackgroundColor3 = Color3.fromRGB(5, 5, 5) end
    else
        if Root and LastPos then Root.CFrame = LastPos end
        Camera.CameraSubject = LocalPlayer.Character.Humanoid Notify("Aura View OFF")
    end
end)

-- SILENT AIM HOOK
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
            if T then args[2] = GetChestPos(T) return oldNamecall(self, unpack(args)) end
        end
    end
    return oldNamecall(self, ...)
end)
mt.__index = newcclosure(function(self, idx)
    if not checkcaller() and self == Mouse and (idx == "Hit" or idx == "Target") then
        local T = GetTarget()
        if T then
            local Pos = GetChestPos(T)
            if idx == "Hit" then return CFrame.new(Pos) end
            if idx == "Target" then return T.Character.HumanoidRootPart end
        end
    end
    return oldIndex(self, idx)
end)
setreadonly(mt, true)

-- MAIN LOOP
RunService.RenderStepped:Connect(function()
    local Char = LocalPlayer.Character
    if not Char or not Char:FindFirstChild("HumanoidRootPart") then return end
    local Root, Hum = Char.HumanoidRootPart, Char.Humanoid
    local CurrentTarget = GetTarget()
    
    if CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("Humanoid") then
        local targetHum = CurrentTarget.Character.Humanoid
        TargetUI.Visible, TargetName.Text = true, CurrentTarget.Name
        HealthBarMain.Size = UDim2.new(math.clamp(targetHum.Health / targetHum.MaxHealth, 0, 1), 0, 1, 0)
        ArmorLabel.Text = "Armor: " .. (CurrentTarget.Character:FindFirstChild("BodyArmor") and "100" or "0")
    else TargetUI.Visible = false end

    if ReloadOn then
        local Tool = Char:FindFirstChildOfClass("Tool")
        if Tool and Tool:FindFirstChild("Ammo") and Tool.Ammo.Value <= 0 then
            ReplicatedStorage.MainEvent:FireServer("Reload", Tool)
        end
    end

    if AnimOn and Char:FindFirstChild("Animate") then
        local Anim = Char.Animate
        Anim.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=782841498"
        Anim.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=782845736"
        Anim.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616168032"
        Anim.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1083218792"
        Anim.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616163682"
        Anim.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=1083189019"
    end

    if ViewOn and LockedPlayer and LockedPlayer.Character and LockedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Root.Velocity = Vector3.new(0,0,0)
        Root.CFrame = CFrame.new(LockedPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 200, 0))
    end
    if StrafeOn and LockedPlayer and LockedPlayer.Character and LockedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local TChest = GetChestPos(LockedPlayer) or LockedPlayer.Character.HumanoidRootPart.Position
        Degree = Degree + 0.025
        local TargetPos = TChest + Vector3.new(math.sin(Degree * 60) * 11, 5, math.cos(Degree * 60) * 11)
        Root.CFrame = CFrame.new(TargetPos, TChest)
        Camera.CFrame = CFrame.new(TChest + Vector3.new(0, 5, 12), TChest)
    end
    if SpeedOn and Hum.MoveDirection.Magnitude > 0 then Root.CFrame = Root.CFrame + (Hum.MoveDirection * SpeedMultiplier) end
    if FlyOn and not StrafeOn and not ViewOn then Root.Velocity = Vector3.new(0, 0, 0) Root.CFrame = Root.CFrame + (Camera.CFrame.LookVector * 3.8) end
    
    if StompOn then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local eHum = v.Character:FindFirstChild("Humanoid")
                if eHum and eHum.Health <= 15 and (Root.Position - v.Character.HumanoidRootPart.Position).Magnitude <= StompRange then ReplicatedStorage.MainEvent:FireServer("Stomp") end
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
