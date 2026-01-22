local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local AnimationSpeed = 1
local dance_animation = Instance.new("Animation")
dance_animation.AnimationId = "rbxassetid://14352343065"

local animationTrack
local flossEnabled = false
local currentAnimationPreset = "None"
local animationBaseUrl = "http://www.roblox.com/asset/?id="
local anim_presets = {
    Rthro = {idle = "2510196951", walk = "2510202577", run = "2510198475", jump = "2510197830", climb = "2510192778", fall = "2510195892"},
    Ninja = {idle = "656117400", jump = "656117878", fall = "656115606", walk = "656121766", run = "656118852", climb = "656114359"},
    DaHoodian = {idle = "782841498", walk = "616168032", run = "616163682", jump = "1083218792", climb = "1083439238", fall = "707829716"}
}

local FovSize = 293 
local TargetPart = "Head" 
local StompRange = 15 
local HitSize = 15
local SpeedMultiplier = 10 
getgenv().Prediction = 0 
local MainEvent = ReplicatedStorage:WaitForChild("MainEvent")

local velMax = (128 ^ 2)
local timeRelease, timeChoke = 0.015, 0.105
local Property = sethiddenproperty
local DesyncOn = false

getgenv().headshots = {
    HitEffects = {
        HitSounds = true,
        HitSoundID = "rbxassetid://97643101798871",
        HitSoundVolume = 5,
        HitNotifications = true,
        HitNotificationsTime = 3,
    }
}
local lastNotifTime = 0

local KillAuraOn = false
local StompAuraOn = false
local KillAuraDist = 50
local LockedPlayer, StrafeOn, ViewOn, SpeedOn, FlyOn, HitOn, StompOn, AntiLockOn, RapidOn, ReloadOn = nil, false, false, false, false, false, false, false, false, false
local IsMouseDown, Degree, LastPos = false, 0, nil

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

local function createHitSound()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local sound = Instance.new("Sound")
    sound.Parent = LocalPlayer.Character.HumanoidRootPart
    sound.SoundId = headshots.HitEffects.HitSoundID
    sound.Volume = headshots.HitEffects.HitSoundVolume
    sound:Play()
    sound.Ended:Connect(function() sound:Destroy() end)
end

local function sendHitNotification(targetName)
    if headshots.HitEffects.HitNotifications then
        if tick() - lastNotifTime >= 3 then
            lastNotifTime = tick()
            print("headshots.cc - Hit Target: " .. targetName)
        end
    end
end

local function Sleep()
    local Char = LocalPlayer.Character
    if Char and Char:FindFirstChild("HumanoidRootPart") and Property then
        return Property(Char.HumanoidRootPart, "NetworkIsSleeping", true)
    end
end

local function InitDesync()
    if not DesyncOn then return end
    local Char = LocalPlayer.Character
    if not Char or not Char:FindFirstChild("HumanoidRootPart") then return end
    local Root = Char.HumanoidRootPart
    local rootVel = Root.Velocity
    local rootAng = math.random(-180, 180)
    local X = math.random(-velMax, velMax)
    local Y = math.random(0, velMax)
    local Z = math.random(-velMax, velMax)
    local rootOffset = Vector3.new(X, -Y, Z)
    Root.CFrame *= CFrame.Angles(0, math.rad(rootAng), 0)
    Root.Velocity = rootOffset
    RunService.RenderStepped:Wait()
    Root.CFrame *= CFrame.Angles(0, math.rad(-rootAng), 0)
    Root.Velocity = rootVel
end

local MainM, MainT, MainS = CreateBaseMenu("MENU", UDim2.new(0.85, 0, 0.35, 0), 100)
local SpeedBtn = CreateBtn(MainS, "SPEED: OFF")
local FlyBtn = CreateBtn(MainS, "FLY: OFF")
local DesyncBtn = CreateBtn(MainS, "DESYNC: OFF")
local HitboxBtn = CreateBtn(MainS, "HITBOX: OFF")
local StompBtn = CreateBtn(MainS, "AUTO STOMP: OFF")
local KillAuraBtn = CreateBtn(MainS, "KILL AURA: OFF")
local StompAuraBtn = CreateBtn(MainS, "STOMP AURA: OFF")
local AntiLockBtn = CreateBtn(MainS, "ANTI LOCK: OFF")
local RapidBtn = CreateBtn(MainS, "RAPID FIRE: OFF")
local ReloadBtn = CreateBtn(MainS, "AUTO RELOAD: OFF")
local DanceBtn = CreateBtn(MainS, "DANCE: OFF")

DanceBtn.MouseButton1Click:Connect(function()
    flossEnabled = not flossEnabled
    DanceBtn.Text = "DANCE: " .. (flossEnabled and "ON" or "OFF")
    if flossEnabled and animationTrack then
        animationTrack:Play()
        animationTrack:AdjustSpeed(AnimationSpeed)
    elseif animationTrack then
        animationTrack:Stop()
    end
end)

local PackBtn = CreateBtn(MainS, "PACK: NONE")
local p_list = {"None", "Rthro", "Ninja", "DaHoodian"}
local p_idx = 1
PackBtn.MouseButton1Click:Connect(function()
    p_idx = p_idx % #p_list + 1
    currentAnimationPreset = p_list[p_idx]
    PackBtn.Text = "PACK: " .. currentAnimationPreset
    if LocalPlayer.Character and currentAnimationPreset ~= "None" then
        apply_animations(LocalPlayer.Character, anim_presets[currentAnimationPreset])
    end
end)

local MainOpened = false
MainT.MouseButton1Click:Connect(function()
    MainOpened = not MainOpened
    MainS.Visible = MainOpened
    MainM:TweenSize(MainOpened and UDim2.new(0, 150, 0, 350) or UDim2.new(0, 150, 0, 40), "Out", "Quart", 0.3, true)
    MainT.Text = MainOpened and "MENU [CLOSE]" or "MENU [OPEN]"
end)

RunService.Heartbeat:Connect(InitDesync)
task.spawn(function()
    while true do
        task.wait(timeRelease)
        if DesyncOn then
            local statPing = game:GetService("Stats").PerformanceStats.Ping
            local chokeClient = RunService.Heartbeat:Connect(Sleep)
            local chokeServer = RunService.RenderStepped:Connect(Sleep)
            task.wait(math.ceil(statPing:GetValue()) / 1000)
            chokeClient:Disconnect()
            chokeServer:Disconnect()
        end
    end
end)

local HitM, HitT, HitS = CreateBaseMenu("HIT EFFECTS", UDim2.new(0.59, 0, 0.35, 0), 300)
local SoundToggleBtn = CreateBtn(HitS, "HIT SOUNDS: ON")
local NotifToggleBtn = CreateBtn(HitS, "NOTIF: ON")
local CycleSoundBtn = CreateBtn(HitS, "SOUND: NEVERLOSE")

SoundToggleBtn.MouseButton1Click:Connect(function()
    headshots.HitEffects.HitSounds = not headshots.HitEffects.HitSounds
    SoundToggleBtn.Text = "HIT SOUNDS: " .. (headshots.HitEffects.HitSounds and "ON" or "OFF")
end)

NotifToggleBtn.MouseButton1Click:Connect(function()
    headshots.HitEffects.HitNotifications = not headshots.HitEffects.HitNotifications
    NotifToggleBtn.Text = "NOTIF: " .. (headshots.HitEffects.HitNotifications and "ON" or "OFF")
end)

local currentSoundIdx = 1
local sounds = {
    {name = "NEVERLOSE", id = "rbxassetid://97643101798871"},
    {name = "GAMESENSE", id = "rbxassetid://4817809188"},
    {name = "BUBBLE", id = "rbxassetid://6534947588"}
}

CycleSoundBtn.MouseButton1Click:Connect(function()
    currentSoundIdx = currentSoundIdx % #sounds + 1
    headshots.HitEffects.HitSoundID = sounds[currentSoundIdx].id
    CycleSoundBtn.Text = "SOUND: " .. sounds[currentSoundIdx].name
end)

local HitOpened = false
HitT.MouseButton1Click:Connect(function()
    HitOpened = not HitOpened
    HitS.Visible = HitOpened
    HitM:TweenSize(HitOpened and UDim2.new(0, 150, 0, 180) or UDim2.new(0, 150, 0, 40), "Out", "Quart", 0.3, true)
    HitT.Text = HitOpened and "HIT [CLOSE]" or "HIT [OPEN]"
end)

local function loadAnimationTrack(character)
    local humanoid = character:WaitForChild("Humanoid")
    if animationTrack then animationTrack:Stop() end
    animationTrack = humanoid:LoadAnimation(dance_animation)
    animationTrack.Looped = true
    if flossEnabled then
        task.wait(0.5)
        animationTrack:Play()
        animationTrack:AdjustSpeed(AnimationSpeed)
    end
end

local function apply_animations(char, preset)
    local animate = char:FindFirstChild("Animate")
    if animate and preset then
        if animate:FindFirstChild("idle") then animate.idle.Animation1.AnimationId = animationBaseUrl .. preset.idle end
        if animate:FindFirstChild("walk") then animate.walk.WalkAnim.AnimationId = animationBaseUrl .. preset.walk end
        if animate:FindFirstChild("run") then animate.run.RunAnim.AnimationId = animationBaseUrl .. preset.run end
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    loadAnimationTrack(char)
end)

DesyncBtn.MouseButton1Click:Connect(function() DesyncOn = not DesyncOn DesyncBtn.Text = "DESYNC: "..(DesyncOn and "ON" or "OFF") end)
SpeedBtn.MouseButton1Click:Connect(function() SpeedOn = not SpeedOn SpeedBtn.Text = "SPEED: "..(SpeedOn and "ON" or "OFF") end)
FlyBtn.MouseButton1Click:Connect(function() FlyOn = not FlyOn FlyBtn.Text = "FLY: "..(FlyOn and "ON" or "OFF") end)
HitboxBtn.MouseButton1Click:Connect(function() HitOn = not HitOn HitboxBtn.Text = "HITBOX: "..(HitOn and "ON" or "OFF") end)
StompBtn.MouseButton1Click:Connect(function() StompOn = not StompOn StompBtn.Text = "AUTO STOMP: "..(StompOn and "ON" or "OFF") end)
KillAuraBtn.MouseButton1Click:Connect(function() KillAuraOn = not KillAuraOn KillAuraBtn.Text = "KILL AURA: "..(KillAuraOn and "ON" or "OFF") end)
StompAuraBtn.MouseButton1Click:Connect(function() StompAuraOn = not StompAuraOn StompAuraBtn.Text = "STOMP AURA: "..(StompAuraOn and "ON" or "OFF") end)
AntiLockBtn.MouseButton1Click:Connect(function() AntiLockOn = not AntiLockOn AntiLockBtn.Text = "ANTI LOCK: "..(AntiLockOn and "ON" or "OFF") end)
RapidBtn.MouseButton1Click:Connect(function() RapidOn = not RapidOn RapidBtn.Text = "RAPID FIRE: "..(RapidOn and "ON" or "OFF") end)
ReloadBtn.MouseButton1Click:Connect(function() ReloadOn = not ReloadOn ReloadBtn.Text = "AUTO RELOAD: "..(ReloadOn and "ON" or "OFF") end)

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

RunService.RenderStepped:Connect(function()
    local Char = LocalPlayer.Character
    if not Char or not Char:FindFirstChild("HumanoidRootPart") or not Char:FindFirstChild("Humanoid") then return end
    local Root, Hum = Char.HumanoidRootPart, Char.Humanoid
 
     if ReloadOn then
        local Tool = Char:FindFirstChildOfClass("Tool")
        if Tool and Tool:FindFirstChild("Ammo") and Tool.Ammo.Value <= 0 then
            MainEvent:FireServer("Reload", Tool)
        end
    end
    
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

    if KillAuraOn then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and not KnockCheck(player) and not player.Character:FindFirstChild("ForceField") then
                local distance = (player.Character.HumanoidRootPart.Position - Root.Position).Magnitude
                local Tool = Char:FindFirstChildOfClass("Tool")
                if distance <= KillAuraDist and Tool then
                    MainEvent:FireServer("ShootGun", Tool.Handle, Tool.Handle.Position, player.Character.Head.Position, player.Character.Head, Vector3.new(0,0,0))
                    if headshots.HitEffects.HitSounds then createHitSound() end
                end
            end
        end
    end

    if SpeedOn and Hum.MoveDirection.Magnitude > 0 then Root.CFrame = Root.CFrame + (Hum.MoveDirection * SpeedMultiplier) end
    if FlyOn then Root.Velocity = Vector3.new(0,0,0) Root.CFrame = Root.CFrame + (Camera.CFrame.LookVector * 10) end
    if AntiLockOn then Root.Velocity = Vector3.new(math.random(-500,500), math.random(-500,500), math.random(-500,500)) end
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if HitOn then v.Character.HumanoidRootPart.Size = Vector3.new(HitSize, HitSize, HitSize) v.Character.HumanoidRootPart.Transparency = 0.8 else v.Character.HumanoidRootPart.Size = Vector3.new(2,2,1) v.Character.HumanoidRootPart.Transparency = 1 end
            if StompOn and v.Character.Humanoid.Health <= 15 and (Root.Position - v.Character.HumanoidRootPart.Position).Magnitude < StompRange then 
                MainEvent:FireServer("Stomp")
                sendHitNotification(v.Name)
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.UserInputType == Enum.UserInputType.MouseButton1 then
        IsMouseDown = true
        if RapidOn then
            task.spawn(function()
                while IsMouseDown and RapidOn do
                    local t = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if t then 
                        t:Activate() 
                        local target = GetTarget()
                        if target then
                            MainEvent:FireServer("ShootGun", t.Handle, t.Handle.Position, GetTargetPartPos(target), target.Character.Head, Vector3.new(0,0,0))
                            if headshots.HitEffects.HitSounds then createHitSound() end
                        end
                    end
                    task.wait(0.01)
                end
            end)
        end
    end
end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then IsMouseDown = false end end)

if LocalPlayer.Character then loadAnimationTrack(LocalPlayer.Character) end
