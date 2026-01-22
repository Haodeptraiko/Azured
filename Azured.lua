local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Configs
local FovSize = 293 
local TargetPart = "Head" 
local StompRange = 15 
local HitSize = 15
local SpeedMultiplier = 10 
getgenv().Prediction = 0 
local MainEvent = ReplicatedStorage:WaitForChild("MainEvent")

-- Variables for Kill Aura & Features
local KillAuraOn = false
local StompAuraOn = false
local KillAuraDist = 50
local LockedPlayer, StrafeOn, ViewOn, SpeedOn, FlyOn, HitOn, StompOn, AntiLockOn, RapidOn, ReloadOn = nil, false, false, false, false, false, false, false, false, false
local IsMouseDown, Degree, LastPos = false, 0, nil

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Azured_V61_Fixed"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

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

local FovCircle = Instance.new("Frame", ScreenGui)
FovCircle.Size = UDim2.new(0, FovSize, 0, FovSize)
FovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FovCircle.BackgroundTransparency = 1
local StrokeFOV = Instance.new("UIStroke", FovCircle)
StrokeFOV.Thickness = 1
StrokeFOV.Color = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", FovCircle).CornerRadius = UDim.new(1, 0)

local function CreateBaseMenu(name, pos, zindex)
    local MenuMain = Instance.new("Frame", ScreenGui)
    MenuMain.Size = UDim2.new(0, 150, 0, 40)
    MenuMain.Position = pos
    MenuMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MenuMain.ClipsDescendants = true
    MenuMain.Active = true
    MenuMain.ZIndex = zindex
    Instance.new("UICorner", MenuMain).CornerRadius = UDim.new(0, 8)

    local MenuToggle = Instance.new("TextButton", MenuMain)
    MenuToggle.Size = UDim2.new(1, 0, 0, 40)
    MenuToggle.BackgroundTransparency = 1
    MenuToggle.Text = name .. " [OPEN]"
    MenuToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    MenuToggle.Font = Enum.Font.SourceSansBold
    MenuToggle.TextSize = 14
    MenuToggle.ZIndex = zindex + 10

    local Scroll = Instance.new("ScrollingFrame", MenuMain)
    Scroll.Position = UDim2.new(0, 5, 0, 45)
    Scroll.Size = UDim2.new(1, -10, 1, -50)
    Scroll.BackgroundTransparency = 1
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 500)
    Scroll.ScrollBarThickness = 3
    Scroll.ZIndex = zindex + 5
    Scroll.Visible = false

    local UIList = Instance.new("UIListLayout", Scroll)
    UIList.Padding = UDim.new(0, 5)
    UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Scroll.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 20)
    end)

    MakeDraggable(MenuMain, MenuToggle)
    return MenuMain, MenuToggle, Scroll
end

local function CreateBtn(parent, text)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1, 0, 0, 30)
    Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.SourceSans
    Btn.TextSize = 12
    Btn.ZIndex = parent.ZIndex + 1
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    return Btn
end

-- Menus
local MainM, MainT, MainS = CreateBaseMenu("MENU", UDim2.new(0.85, 0, 0.35, 0), 100)
local SpeedBtn = CreateBtn(MainS, "SPEED: OFF")
local FlyBtn = CreateBtn(MainS, "FLY: OFF")
local HitboxBtn = CreateBtn(MainS, "HITBOX: OFF")
local StompBtn = CreateBtn(MainS, "AUTO STOMP: OFF")
local KillAuraBtn = CreateBtn(MainS, "KILL AURA: OFF")
local StompAuraBtn = CreateBtn(MainS, "STOMP AURA: OFF")
local AntiLockBtn = CreateBtn(MainS, "ANTI LOCK: OFF")
local RapidBtn = CreateBtn(MainS, "RAPID FIRE: OFF")
local ReloadBtn = CreateBtn(MainS, "AUTO RELOAD: OFF")

local MainOpened = false
MainT.MouseButton1Click:Connect(function()
    MainOpened = not MainOpened
    MainS.Visible = MainOpened
    MainM:TweenSize(MainOpened and UDim2.new(0, 150, 0, 320) or UDim2.new(0, 150, 0, 40), "Out", "Quart", 0.3, true)
    MainT.Text = MainOpened and "MENU [CLOSE]" or "MENU [OPEN]"
end)

local SkinM, SkinT, SkinS = CreateBaseMenu("SKIN GUN", UDim2.new(0.72, 0, 0.35, 0), 200)
local GunSkins = {["LMG"] = nil, ["AK47"] = nil, ["Glock"] = nil, ["Revolver"] = nil, ["Shotgun"] = nil, ["SMG"] = nil, ["P90"] = nil, ["SilencerAR"] = nil, ["DrumGun"] = nil, ["Double-Barrel"] = nil}
local SkinTextures = {["Galaxy"] = "rbxassetid://9402007158", ["Inferno"] = "rbxassetid://9401972413", ["Matrix"] = "rbxassetid://9402023983", ["RedDeath"] = "rbxassetid://8213168054", ["GoldGlory"] = "rbxassetid://8213175568"}

for gunKey, _ in pairs(GunSkins) do
    for skinName, skinId in pairs(SkinTextures) do
        local b = CreateBtn(SkinS, gunKey .. " - " .. skinName)
        b.MouseButton1Click:Connect(function() GunSkins[gunKey] = skinId end)
    end
end

local SkinOpened = false
SkinT.MouseButton1Click:Connect(function()
    SkinOpened = not SkinOpened
    SkinS.Visible = SkinOpened
    SkinM:TweenSize(SkinOpened and UDim2.new(0, 150, 0, 280) or UDim2.new(0, 150, 0, 40), "Out", "Quart", 0.3, true)
    SkinT.Text = SkinOpened and "SKIN [CLOSE]" or "SKIN [OPEN]"
end)

local LockBtn = Instance.new("TextButton", ScreenGui)
LockBtn.Size = UDim2.new(0, 55, 0, 55); LockBtn.Position = UDim2.new(0.85, 0, 0.2, 0)
LockBtn.BackgroundColor3 = Color3.fromRGB(5, 5, 5); LockBtn.Text = "LOCK"; LockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LockBtn.ZIndex = 500; Instance.new("UICorner", LockBtn).CornerRadius = UDim.new(1, 0)
MakeDraggable(LockBtn)

local AuraBtn = Instance.new("TextButton", ScreenGui)
AuraBtn.Size = UDim2.new(0, 55, 0, 55); AuraBtn.Position = UDim2.new(0.85, 60, 0.2, 0)
AuraBtn.BackgroundColor3 = Color3.fromRGB(5, 5, 5); AuraBtn.Text = "AURA"; AuraBtn.TextColor3 = Color3.fromRGB(0, 150, 255)
AuraBtn.ZIndex = 500; Instance.new("UICorner", AuraBtn).CornerRadius = UDim.new(1, 0)
MakeDraggable(AuraBtn)

-- Button Events
SpeedBtn.MouseButton1Click:Connect(function() SpeedOn = not SpeedOn SpeedBtn.Text = "SPEED: "..(SpeedOn and "ON" or "OFF") end)
FlyBtn.MouseButton1Click:Connect(function() FlyOn = not FlyOn FlyBtn.Text = "FLY: "..(FlyOn and "ON" or "OFF") end)
HitboxBtn.MouseButton1Click:Connect(function() HitOn = not HitOn HitboxBtn.Text = "HITBOX: "..(HitOn and "ON" or "OFF") end)
StompBtn.MouseButton1Click:Connect(function() StompOn = not StompOn StompBtn.Text = "AUTO STOMP: "..(StompOn and "ON" or "OFF") end)
KillAuraBtn.MouseButton1Click:Connect(function() KillAuraOn = not KillAuraOn KillAuraBtn.Text = "KILL AURA: "..(KillAuraOn and "ON" or "OFF") end)
StompAuraBtn.MouseButton1Click:Connect(function() StompAuraOn = not StompAuraOn StompAuraBtn.Text = "STOMP AURA: "..(StompAuraOn and "ON" or "OFF") end)
AntiLockBtn.MouseButton1Click:Connect(function() AntiLockOn = not AntiLockOn AntiLockBtn.Text = "ANTI LOCK: "..(AntiLockOn and "ON" or "OFF") end)
RapidBtn.MouseButton1Click:Connect(function() RapidOn = not RapidOn RapidBtn.Text = "RAPID FIRE: "..(RapidOn and "ON" or "OFF") end)
ReloadBtn.MouseButton1Click:Connect(function() ReloadOn = not ReloadOn ReloadBtn.Text = "AUTO RELOAD: "..(ReloadOn and "ON" or "OFF") end)

-- Functions
local function KnockCheck(v)
    if v.Character and v.Character:FindFirstChild("BodyEffects") then
        local ko = v.Character.BodyEffects:FindFirstChild("K.O") or v.Character.BodyEffects:FindFirstChild("KO")
        if ko and ko.Value then return true end
    end
    if v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health <= 15 then return true end
    return false
end

local function GetTarget()
    local Target, MinDist = nil, FovSize / 2
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local Root = v.Character:FindFirstChild("HumanoidRootPart")
            if Root then
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
                local Dist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Center).Magnitude
                if OnScreen and Dist < MinDist then MinDist = Dist; Target = v end
            end
        end
    end
    return Target
end

local function GetTargetPartPos(p)
    if not p.Character then return nil end
    local part = p.Character:FindFirstChild(TargetPart) or p.Character:FindFirstChild("HumanoidRootPart")
    return part.Position 
end

-- Metatables
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
local oldIndex = mt.__index
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    if not checkcaller() and getnamecallmethod() == "FireServer" and self.Name == "MainEvent" then
        if args[1] == "UpdateMousePos" or args[1] == "Shoot" then
            local T = GetTarget()
            if T then args[2] = GetTargetPartPos(T) return oldNamecall(self, unpack(args)) end
        end
    end
    return oldNamecall(self, unpack(args))
end)
mt.__index = newcclosure(function(self, idx)
    if not checkcaller() and self == Mouse and (idx == "Hit" or idx == "Target") then
        local T = GetTarget()
        if T then 
            if idx == "Hit" then return CFrame.new(GetTargetPartPos(T)) end
            if idx == "Target" then return T.Character.HumanoidRootPart end
        end
    end
    return oldIndex(self, idx)
end)
setreadonly(mt, true)

LockBtn.MouseButton1Click:Connect(function()
    StrafeOn = not StrafeOn
    if StrafeOn then
        LockedPlayer = GetTarget()
        if LockedPlayer then Camera.CameraType = Enum.CameraType.Scriptable else StrafeOn = false end
    else LockedPlayer = nil Camera.CameraType = Enum.CameraType.Custom end
end)

AuraBtn.MouseButton1Click:Connect(function()
    ViewOn = not ViewOn
    if ViewOn then
        local T = GetTarget()
        if T and T.Character and T.Character:FindFirstChild("HumanoidRootPart") then 
            LockedPlayer = T; LastPos = LocalPlayer.Character.HumanoidRootPart.CFrame; Camera.CameraSubject = T.Character.Humanoid 
        else ViewOn = false end
    else Camera.CameraSubject = LocalPlayer.Character.Humanoid; if LastPos then LocalPlayer.Character.HumanoidRootPart.CFrame = LastPos end end
end)

RunService.RenderStepped:Connect(function()
    local Char = LocalPlayer.Character
    if not Char or not Char:FindFirstChild("HumanoidRootPart") or not Char:FindFirstChild("Humanoid") then return end
    local Root, Hum = Char.HumanoidRootPart, Char.Humanoid

    -- Rapid Fire Cooldown Reducer (Advanced)
    if RapidOn then
        local tool = Char:FindFirstChildOfClass("Tool")
        if tool and getconnections then
            for _, c in pairs(getconnections(tool.Activated)) do
                local f = c.Function
                if f and debug.getinfo(f).nups then
                    for i = 1, debug.getinfo(f).nups do
                        local val = debug.getupvalue(f, i)
                        if type(val) == "number" then debug.setupvalue(f, i, 0) end
                    end
                end
            end
        end
    end

    -- Kill Aura
    if KillAuraOn then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and not KnockCheck(player) and not player.Character:FindFirstChild("ForceField") then
                local distance = (player.Character.HumanoidRootPart.Position - Root.Position).Magnitude
                local Tool = Char:FindFirstChildOfClass("Tool")
                if distance <= KillAuraDist and Tool then
                    MainEvent:FireServer("ShootGun", Tool.Handle, Tool.Handle.Position, player.Character.Head.Position, player.Character.Head, Vector3.new(0,0,0))
                end
            end
        end
    end

    -- Stomp Aura
    if StompAuraOn then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and KnockCheck(player) then
                local distance = (player.Character.HumanoidRootPart.Position - Root.Position).Magnitude
                if distance <= KillAuraDist then
                    local be = player.Character:FindFirstChild("BodyEffects")
                    if be and be:FindFirstChild("SDeath") and be.SDeath.Value == false then
                        local OldCF = Root.CFrame
                        Root.CFrame = CFrame.new(player.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
                        MainEvent:FireServer("Stomp")
                        task.wait(0.1)
                        Root.CFrame = OldCF
                    end
                end
            end
        end
    end

    -- Aura 230m
    if ViewOn and LockedPlayer and LockedPlayer.Character and LockedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Root.CFrame = CFrame.new(LockedPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 230, 0))
        Root.Velocity = Vector3.new(0,0,0)
    end

    -- Skins & Other Logics
    for _, tool in pairs(Char:GetChildren()) do
        if tool:IsA("Tool") then
            for gunKey, skinId in pairs(GunSkins) do
                if tool.Name:lower():find(gunKey:lower()) and skinId then
                    local h = tool:FindFirstChild("Default") or tool:FindFirstChild("Handle")
                    if h and h:IsA("MeshPart") then h.TextureID = skinId end
                end
            end
        end
    end

    if StrafeOn and LockedPlayer and LockedPlayer.Character and LockedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Degree = Degree + 0.03
        local TPos = GetTargetPartPos(LockedPlayer)
        local Orbit = TPos + Vector3.new(math.sin(Degree*50)*12, 5, math.cos(Degree*50)*12)
        Root.CFrame = CFrame.new(Orbit, TPos)
        Camera.CFrame = CFrame.new(TPos + Vector3.new(0, 5, 15), TPos)
    end
    if SpeedOn and Hum.MoveDirection.Magnitude > 0 then Root.CFrame = Root.CFrame + (Hum.MoveDirection * SpeedMultiplier) end
    if FlyOn then Root.Velocity = Vector3.new(0,0,0) Root.CFrame = Root.CFrame + (Camera.CFrame.LookVector * 10) end
    if AntiLockOn then Root.Velocity = Vector3.new(math.random(-500,500), math.random(-500,500), math.random(-500,500)) end
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if HitOn then v.Character.HumanoidRootPart.Size = Vector3.new(HitSize, HitSize, HitSize) v.Character.HumanoidRootPart.Transparency = 0.8 else v.Character.HumanoidRootPart.Size = Vector3.new(2,2,1) v.Character.HumanoidRootPart.Transparency = 1 end
            if StompOn and v.Character.Humanoid.Health <= 15 and (Root.Position - v.Character.HumanoidRootPart.Position).Magnitude < StompRange then MainEvent:FireServer("Stomp") end
        end
    end
end)

-- Improved Rapid Fire Input
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.UserInputType == Enum.UserInputType.MouseButton1 then
        IsMouseDown = true
        if RapidOn then
            task.spawn(function()
                while IsMouseDown and RapidOn do
                    local t = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if t then 
                        t:Activate() 
                        -- Nếu là game Da Hood, việc bắn thêm Remote sẽ giúp tăng tốc độ bắn
                        local target = GetTarget()
                        if target then
                            MainEvent:FireServer("ShootGun", t.Handle, t.Handle.Position, GetTargetPartPos(target), target.Character.Head, Vector3.new(0,0,0))
                        end
                        if ReloadOn and t:FindFirstChild("Ammo") and t.Ammo.Value <= 0 then MainEvent:FireServer("Reload", t) end 
                    end
                    task.wait(0.01) -- Đợi cực ngắn để bắn liên tục
                end
            end)
        end
    end
end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then IsMouseDown = false end end)
