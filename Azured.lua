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

local FovSize = 300 
local TracerColor = Color3.fromRGB(255, 50, 50) 

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Azured_Mobile_Final_V5"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local function CreateAura(Char)
    if not Char then return end
    local Root = Char:WaitForChild("HumanoidRootPart", 10)
    local Head = Char:WaitForChild("Head", 10)
    local Torso = Char:FindFirstChild("UpperTorso") or Char:FindFirstChild("Torso")
    
    if not Root or not Head or not Torso then return end

    if Char:FindFirstChild("AzuredAura") then Char.AzuredAura:Destroy() end
    local AuraFolder = Instance.new("Folder", Char)
    AuraFolder.Name = "AzuredAura"

    local Halo = Instance.new("Part", AuraFolder)
    Halo.Size = Vector3.new(2, 0.1, 2)
    Halo.Color = Color3.fromRGB(255, 0, 0)
    Halo.Material = Enum.Material.Neon
    Halo.CanCollide = false
    Halo.CanTouch = false
    local HaloMesh = Instance.new("SpecialMesh", Halo)
    HaloMesh.MeshId = "rbxassetid://11419736442"
    HaloMesh.Scale = Vector3.new(0.008, 0.008, 0.008)
    local HaloWeld = Instance.new("Weld", Halo)
    HaloWeld.Part0 = Halo
    HaloWeld.Part1 = Head
    HaloWeld.C0 = CFrame.new(0, -1.5, 0)

    local Wings = Instance.new("Part", AuraFolder)
    Wings.Size = Vector3.new(2, 2, 2)
    Wings.Color = Color3.fromRGB(255, 0, 0)
    Wings.Material = Enum.Material.Neon
    Wings.CanCollide = false
    Wings.CanTouch = false
    Wings.Transparency = 0.2
    local WingsMesh = Instance.new("SpecialMesh", Wings)
    WingsMesh.MeshId = "rbxassetid://12140411823"
    WingsMesh.Scale = Vector3.new(0.06, 0.06, 0.06)
    local WingsWeld = Instance.new("Weld", Wings)
    WingsWeld.Part0 = Wings
    WingsWeld.Part1 = Torso
    WingsWeld.C0 = CFrame.new(0, -0.5, 1) * CFrame.Angles(0, math.rad(180), 0)

    local Circle = Instance.new("Part", AuraFolder)
    Circle.Size = Vector3.new(6, 0.1, 6)
    Circle.Color = Color3.fromRGB(255, 0, 0)
    Circle.Material = Enum.Material.Neon
    Circle.Transparency = 0.6
    Circle.CanCollide = false
    Circle.CanTouch = false
    local CircleMesh = Instance.new("SpecialMesh", Circle)
    CircleMesh.MeshType = Enum.MeshType.Cylinder
    local CircleWeld = Instance.new("Weld", Circle)
    CircleWeld.Part0 = Circle
    CircleWeld.Part1 = Root
    CircleWeld.C0 = CFrame.new(0, 3, 0)
end

LocalPlayer.CharacterAdded:Connect(CreateAura)
if LocalPlayer.Character then CreateAura(LocalPlayer.Character) end

local FovCircle = Instance.new("Frame")
FovCircle.Parent = ScreenGui
FovCircle.Size = UDim2.new(0, FovSize, 0, FovSize)
FovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FovCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FovCircle.BackgroundTransparency = 0.95
FovCircle.Visible = true
Instance.new("UICorner", FovCircle).CornerRadius = UDim.new(1, 0)
local FovStroke = Instance.new("UIStroke", FovCircle)
FovStroke.Thickness = 1
FovStroke.Color = Color3.fromRGB(255, 255, 255)

local TracerLines = {}

local function GetTracer(playerName)
    if not TracerLines[playerName] then
        if Drawing then
            local line = Drawing.new("Line")
            line.Visible = false
            line.Thickness = 1.5
            line.Color = TracerColor
            line.Transparency = 0.8
            TracerLines[playerName] = line
        else
            return nil 
        end
    end
    return TracerLines[playerName]
end

Players.PlayerRemoving:Connect(function(player)
    if TracerLines[player.Name] then
        TracerLines[player.Name]:Remove()
        TracerLines[player.Name] = nil
    end
end)

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
            if lastHealth[v.Name] and hum.Health < lastHealth[v.Name] then
                playHitsound()
            end
            lastHealth[v.Name] = hum.Health
        end
    end
end

local function GetClosestTargetToCenter()
    local Target = nil
    local ClosestDist = FovCircle.AbsoluteSize.X / 2 
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("LowerTorso") and v.Character.Humanoid.Health > 0 then
            local ScreenPos, OnScreen = Camera:WorldToScreenPoint(v.Character.LowerTorso.Position)
            if OnScreen then
                local Dist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Center).Magnitude
                if Dist < ClosestDist then
                    ClosestDist = Dist
                    Target = v
                end
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
            return k == "Hit" and Target.Character.LowerTorso.CFrame or Target.Character.LowerTorso
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
                args[2] = Target.Character.LowerTorso.Position
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
    Btn.Size = UDim2.new(0, 70, 0, 70)
    Btn.Position = pos
    Btn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Btn.BackgroundTransparency = 0.2
    Btn.Text = text
    Btn.TextColor3 = color
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 16
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)
    local Stroke = Instance.new("UIStroke", Btn)
    Stroke.Thickness = 3
    Stroke.Color = color
    MakeDraggable(Btn)
    return Btn, Stroke
end

local LockBtn, LockStroke = CreateRoundBtn("AIM: OFF", UDim2.new(0.8, 0, 0.4, 0), Color3.fromRGB(150, 150, 150))

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
            LockBtn.Text = "AIM: ON"
            LockBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
            LockStroke.Color = Color3.fromRGB(0, 255, 255) 
            Camera.CameraType = Enum.CameraType.Scriptable
        else 
            StrafeOn = false 
            Notify("No Target in FOV!", Color3.fromRGB(255, 0, 0))
        end
    else 
        LockedPlayer = nil 
        LockBtn.Text = "AIM: OFF"
        LockBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        LockStroke.Color = Color3.fromRGB(150, 150, 150) 
        Camera.CameraType = Enum.CameraType.Custom 
    end
end)

SpeedBtn.MouseButton1Click:Connect(function() SpeedOn = not SpeedOn SpeedBtn.TextColor3 = SpeedOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200) end)
FlyBtn.MouseButton1Click:Connect(function() FlyOn = not FlyOn FlyBtn.TextColor3 = FlyOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200) end)
HitboxBtn.MouseButton1Click:Connect(function() HitOn = not HitOn HitboxBtn.TextColor3 = HitOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200) end)
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
        Degree = Degree + 0.05
        local TargetPos = TRoot.Position + Vector3.new(math.sin(Degree) * 11, 5, math.cos(Degree) * 11)
        Root.CFrame = CFrame.new(TargetPos, TRoot.Position)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, TRoot.Position)
    end
    
    if SpeedOn and Hum.MoveDirection.Magnitude > 0 then Root.CFrame = Root.CFrame + (Hum.MoveDirection * 1.5) end
    if FlyOn and not StrafeOn then Root.Velocity = Vector3.new(0, 0, 0) Root.CFrame = Root.CFrame + (Camera.CFrame.LookVector * 2.5) end
    if AntiOn and Hum.MoveDirection.Magnitude > 0 then 
        Root.CFrame = Root.CFrame + (Hum.MoveDirection * AntiVelocity)
        Root.Velocity = Hum.MoveDirection * (AntiVelocity * 50)
    end

    local CenterScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local FovRadius = FovCircle.AbsoluteSize.X / 2 

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer then
            local tracer = GetTracer(v.Name)
            local showTracer = false

            if v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
                local ScreenPos, OnScreen = Camera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
                if OnScreen then
                    local Dist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - CenterScreen).Magnitude
                    if Dist <= FovRadius then
                        if tracer then
                            tracer.From = CenterScreen
                            tracer.To = Vector2.new(ScreenPos.X, ScreenPos.Y)
                            showTracer = true
                        end
                    end
                end
            end
            if tracer then tracer.Visible = showTracer end

            if v.Character and HitOn and v.Character:FindFirstChild("HumanoidRootPart") then
                v.Character.HumanoidRootPart.Size = Vector3.new(15, 15, 15)
                v.Character.HumanoidRootPart.Transparency = 0.8
                v.Character.HumanoidRootPart.CanCollide = false
            elseif v.Character and not HitOn and v.Character:FindFirstChild("HumanoidRootPart") then
                v.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                v.Character.HumanoidRootPart.Transparency = 1
            end
            
            if v.Character and EspOn then
                if not v.Character:FindFirstChild("Highlight") then
                    local Highlight = Instance.new("Highlight", v.Character)
                    Highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
            elseif v.Character and not EspOn then
                if v.Character:FindFirstChild("Highlight") then
                    v.Character.Highlight:Destroy()
                end
            end
        end
    end
end)

Notify("Azured.gg!", Color3.fromRGB(0, 255, 0))
