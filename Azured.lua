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
local SpeedMultiplier = 4.5
local AntiLockVelocity = Vector3.new(0, 0, -1) * (2^16)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Azured_Full_V55_SuperRapid_SkinFixed"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local function Notify(txt)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Azured PC",
        Text = txt,
        Duration = 2
    })
end

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

-- FOV Circle
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

-- Function Create Menu
local function CreateBaseMenu(name, pos)
    local MenuMain = Instance.new("Frame")
    MenuMain.Parent = ScreenGui
    MenuMain.Size = UDim2.new(0, 140, 0, 40)
    MenuMain.Position = pos
    MenuMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MenuMain.ClipsDescendants = true
    MenuMain.Active = true
    Instance.new("UICorner", MenuMain).CornerRadius = UDim.new(0, 8)
    local MenuStroke = Instance.new("UIStroke", MenuMain)
    MenuStroke.Thickness = 2
    MenuStroke.Color = Color3.fromRGB(60, 60, 60)

    local DragHandle = Instance.new("Frame")
    DragHandle.Parent = MenuMain
    DragHandle.Size = UDim2.new(1, 0, 0, 40)
    DragHandle.BackgroundTransparency = 1
    DragHandle.ZIndex = 5 
    MakeDraggable(MenuMain, DragHandle)

    local MenuToggle = Instance.new("TextButton")
    MenuToggle.Parent = MenuMain
    MenuToggle.Size = UDim2.new(1, 0, 0, 40)
    MenuToggle.BackgroundTransparency = 1
    MenuToggle.Text = name .. " [OPEN]"
    MenuToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    MenuToggle.Font = Enum.Font.SourceSansBold
    MenuToggle.TextSize = 14
    MenuToggle.ZIndex = 4

    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Parent = MenuMain
    Scroll.Position = UDim2.new(0, 0, 0, 40)
    Scroll.Size = UDim2.new(1, 0, 1, -45)
    Scroll.BackgroundTransparency = 1
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 1200)
    Scroll.ScrollBarThickness = 2

    local UIList = Instance.new("UIListLayout", Scroll)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 2)

    return MenuMain, MenuToggle, Scroll
end

local function CreateBtn(parent, text)
    local Btn = Instance.new("TextButton")
    Btn.Parent = parent
    Btn.Size = UDim2.new(1, -10, 0, 28)
    Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 11
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    return Btn
end

-- MAIN MENU
local MainM, MainT, MainS = CreateBaseMenu("MENU", UDim2.new(0.85, 0, 0.32, 0))
local SpeedBtn = CreateBtn(MainS, "SPEED: OFF")
local FlyBtn = CreateBtn(MainS, "FLY: OFF")
local HitboxBtn = CreateBtn(MainS, "HITBOX: OFF")
local StompBtn = CreateBtn(MainS, "STOMP: OFF")
local AntiLockBtn = CreateBtn(MainS, "ANTI LOCK: OFF")
local RapidBtn = CreateBtn(MainS, "RAPID FIRE: OFF")
local ReloadBtn = CreateBtn(MainS, "AUTO RELOAD: OFF")
local DesyncBtn = CreateBtn(MainS, "DESYNC: OFF")

local MainOpened = false
MainT.MouseButton1Click:Connect(function()
    MainOpened = not MainOpened
    MainM:TweenSize(MainOpened and UDim2.new(0, 140, 0, 350) or UDim2.new(0, 140, 0, 40), "Out", "Quart", 0.3, true)
    MainT.Text = MainOpened and "MENU [CLOSE]" or "MENU [OPEN]"
end)

-- SKIN MENU FIXED
local GunSkins = {
    ["[LMG]"] = nil, ["[AK47]"] = nil, ["[Glock]"] = nil, ["[Revolver]"] = nil,
    ["[Shotgun]"] = nil, ["[SMG]"] = nil, ["[P90]"] = nil, ["[SilencerAR]"] = nil,
    ["[DrumGun]"] = nil, ["[Double-Barrel SG]"] = nil
}

local SkinTextures = {
    ["Galaxy"] = "rbxassetid://9402007158",
    ["Inferno"] = "rbxassetid://9401972413",
    ["Matrix"] = "rbxassetid://9402023983",
    ["RedDeath"] = "rbxassetid://8213168054",
    ["GoldGlory"] = "rbxassetid://8213175568"
}

local SkinM, SkinT, SkinS = CreateBaseMenu("Skin Gun", UDim2.new(0.72, 0, 0.32, 0))

for gunName, _ in pairs(GunSkins) do
    local displayName = gunName:gsub("[%[%]]", "")
    for skinType, id in pairs(SkinTextures) do
        local b = CreateBtn(SkinS, displayName .. " " .. skinType)
        b.MouseButton1Click:Connect(function()
            GunSkins[gunName] = id
            Notify("Applied: " .. displayName .. " " .. skinType)
        end)
    end
end

local SkinOpened = false
SkinT.MouseButton1Click:Connect(function()
    SkinOpened = not SkinOpened
    SkinM:TweenSize(SkinOpened and UDim2.new(0, 140, 0, 350) or UDim2.new(0, 140, 0, 40), "Out", "Quart", 0.3, true)
    SkinT.Text = SkinOpened and "Skin Gun [CLOSE]" or "Skin Gun [OPEN]"
end)

-- TARGET UI
local TargetUI = Instance.new("Frame", ScreenGui)
TargetUI.Size = UDim2.new(0, 140, 0, 50)
TargetUI.Position = UDim2.new(0.02, 0, 0.7, 0)
TargetUI.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TargetUI.BackgroundTransparency = 0.5
TargetUI.Visible = false
Instance.new("UICorner", TargetUI)
local TargetName = Instance.new("TextLabel", TargetUI)
TargetName.Size = UDim2.new(1, 0, 0, 20)
TargetName.BackgroundTransparency = 1
TargetName.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetName.TextSize = 12
local HealthBarBack = Instance.new("Frame", TargetUI)
HealthBarBack.Position = UDim2.new(0.1, 0, 0.6, 0)
HealthBarBack.Size = UDim2.new(0.8, 0, 0, 6)
HealthBarBack.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
local HealthBarMain = Instance.new("Frame", HealthBarBack)
HealthBarMain.Size = UDim2.new(1, 0, 1, 0)
HealthBarMain.BackgroundColor3 = Color3.fromRGB(0, 255, 0)

-- LOCK & AURA BUTTONS
local LockBtn = Instance.new("TextButton", ScreenGui)
LockBtn.Size = UDim2.new(0, 55, 0, 55)
LockBtn.Position = UDim2.new(0.85, 0, 0.2, 0)
LockBtn.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
LockBtn.Text = "LOCK"
LockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", LockBtn).CornerRadius = UDim.new(1, 0)
MakeDraggable(LockBtn)

local AuraBtn = Instance.new("TextButton", ScreenGui)
AuraBtn.Size = UDim2.new(0, 55, 0, 55)
AuraBtn.Position = UDim2.new(0.85, 60, 0.2, 0)
AuraBtn.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
AuraBtn.Text = "AURA"
AuraBtn.TextColor3 = Color3.fromRGB(0, 150, 255)
Instance.new("UICorner", AuraBtn).CornerRadius = UDim.new(1, 0)
MakeDraggable(AuraBtn)

-- LOGIC VARIABLES
local LockedPlayer, StrafeOn, ViewOn, SpeedOn, FlyOn, HitOn, StompOn, AntiLockOn, RapidOn, ReloadOn, DesyncOn = nil, false, false, false, false, false, false, false, false, false, false
local IsMouseDown, Degree, LastPos = false, 0, nil

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

local function GetChestPos(p)
    if not p.Character then return nil end
    return p.Character:FindFirstChild("UpperTorso") and p.Character.UpperTorso.Position or p.Character.HumanoidRootPart.Position
end

-- EVENTS
SpeedBtn.MouseButton1Click:Connect(function() SpeedOn = not SpeedOn SpeedBtn.Text = "SPEED: "..(SpeedOn and "ON" or "OFF") end)
FlyBtn.MouseButton1Click:Connect(function() FlyOn = not FlyOn FlyBtn.Text = "FLY: "..(FlyOn and "ON" or "OFF") end)
HitboxBtn.MouseButton1Click:Connect(function() HitOn = not HitOn HitboxBtn.Text = "HITBOX: "..(HitOn and "ON" or "OFF") end)
StompBtn.MouseButton1Click:Connect(function() StompOn = not StompOn StompBtn.Text = "STOMP: "..(StompOn and "ON" or "OFF") end)
AntiLockBtn.MouseButton1Click:Connect(function() AntiLockOn = not AntiLockOn AntiLockBtn.Text = "ANTI LOCK: "..(AntiLockOn and "ON" or "OFF") end)
RapidBtn.MouseButton1Click:Connect(function() RapidOn = not RapidOn RapidBtn.Text = "RAPID FIRE: "..(RapidOn and "ON" or "OFF") end)
ReloadBtn.MouseButton1Click:Connect(function() ReloadOn = not ReloadOn ReloadBtn.Text = "AUTO RELOAD: "..(ReloadOn and "ON" or "OFF") end)
DesyncBtn.MouseButton1Click:Connect(function() DesyncOn = not DesyncOn DesyncBtn.Text = "DESYNC: "..(DesyncOn and "ON" or "OFF") end)

LockBtn.MouseButton1Click:Connect(function()
    StrafeOn = not StrafeOn
    if StrafeOn then
        LockedPlayer = GetTarget()
        if LockedPlayer then Camera.CameraType = Enum.CameraType.Scriptable Notify("Locked: "..LockedPlayer.Name) else StrafeOn = false end
    else LockedPlayer = nil Camera.CameraType = Enum.CameraType.Custom end
end)

AuraBtn.MouseButton1Click:Connect(function()
    ViewOn = not ViewOn
    if ViewOn then
        local T = GetTarget()
        if T and T.Character then LockedPlayer = T LastPos = LocalPlayer.Character.HumanoidRootPart.CFrame Camera.CameraSubject = T.Character.Humanoid Notify("Aura View: "..T.Name) else ViewOn = false end
    else Camera.CameraSubject = LocalPlayer.Character.Humanoid if LastPos then LocalPlayer.Character.HumanoidRootPart.CFrame = LastPos end Notify("Aura View OFF") end
end)

-- SILENT AIM METATABLE
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
local oldIndex = mt.__index
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    if not checkcaller() and getnamecallmethod() == "FireServer" and self.Name == "MainEvent" then
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
        if T then if idx == "Hit" then return CFrame.new(GetChestPos(T)) end if idx == "Target" then return T.Character.HumanoidRootPart end end
    end
    return oldIndex(self, idx)
end)
setreadonly(mt, true)

-- SUPER RAPID FIRE LOGIC
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.UserInputType == Enum.UserInputType.MouseButton1 then
        IsMouseDown = true
        if RapidOn then
            while IsMouseDown and RapidOn do
                local Tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if Tool and Tool:FindFirstChild("Ammo") then 
                    Tool:Activate() 
                    if ReloadOn and Tool.Ammo.Value <= 0 then ReplicatedStorage.MainEvent:FireServer("Reload", Tool) end
                end
                task.wait() -- Mức nhanh nhất có thể (Heartbeat)
            end
        end
    end
end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then IsMouseDown = false end end)

-- MAIN RENDER LOOP
RunService.RenderStepped:Connect(function()
    local Char = LocalPlayer.Character
    if not Char or not Char:FindFirstChild("HumanoidRootPart") then return end
    local Root, Hum = Char.HumanoidRootPart, Char.Humanoid

    -- Apply Skin & Super Rapid Bypass
    for _, tool in pairs(Char:GetChildren()) do
        if tool:IsA("Tool") then
            -- Fix Skin: Kiểm tra tool name có chứa trong GunSkins không
            for gunPattern, skinId in pairs(GunSkins) do
                if tool.Name:find(gunPattern) and skinId then
                    if tool:FindFirstChild("Default") then tool.Default.TextureID = skinId end
                end
            end
            
            -- Xóa delay súng triệt để
            if RapidOn and getconnections then
                for _, Connection in pairs(getconnections(tool.Activated)) do
                    local Function = Connection.Function
                    if Function then
                        local Info = debug.getinfo(Function)
                        for i = 1, Info.nups do
                            local val = debug.getupvalue(Function, i)
                            if type(val) == "number" then debug.setupvalue(Function, i, 0) end
                        end
                    end
                end
            end
        end
    end

    -- Target UI Update
    local T = GetTarget()
    if T and T.Character and T.Character:FindFirstChild("Humanoid") then
        TargetUI.Visible = true
        TargetName.Text = T.Name
        HealthBarMain.Size = UDim2.new(T.Character.Humanoid.Health/T.Character.Humanoid.MaxHealth, 0, 1, 0)
    else TargetUI.Visible = false end

    -- Desync
    if DesyncOn then Root.Velocity = Root.Velocity + Vector3.new(0, 0.08, 0) end
    if AntiLockOn then
        local OldV = Root.Velocity
        Root.Velocity = AntiLockVelocity
        RunService.Heartbeat:Wait()
        Root.Velocity = OldV
    end

    -- Strafe & Spec Lock
    if StrafeOn and LockedPlayer and LockedPlayer.Character and LockedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Degree = Degree + 0.03
        local TPos = GetChestPos(LockedPlayer)
        local Orbit = TPos + Vector3.new(math.sin(Degree*50)*12, 5, math.cos(Degree*50)*12)
        Root.CFrame = CFrame.new(Orbit, TPos)
        Camera.CFrame = CFrame.new(TPos + Vector3.new(0, 5, 15), TPos)
    end

    -- Movement
    if SpeedOn and Hum.MoveDirection.Magnitude > 0 then Root.CFrame = Root.CFrame + (Hum.MoveDirection * SpeedMultiplier) end
    if FlyOn then Root.Velocity = Vector3.new(0,0,0) Root.CFrame = Root.CFrame + (Camera.CFrame.LookVector * 4.5) end
    
    -- Hitbox & Stomp
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if HitOn then v.Character.HumanoidRootPart.Size = Vector3.new(HitSize, HitSize, HitSize) v.Character.HumanoidRootPart.Transparency = 0.8 else v.Character.HumanoidRootPart.Size = Vector3.new(2,2,1) v.Character.HumanoidRootPart.Transparency = 1 end
            if StompOn and v.Character.Humanoid.Health <= 15 and (Root.Position - v.Character.HumanoidRootPart.Position).Magnitude < StompRange then ReplicatedStorage.MainEvent:FireServer("Stomp") end
        end
    end
end)
                    
