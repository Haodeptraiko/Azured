local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local FovSize = 150
local StompRange = 20 
local HitSize = 15
local SpeedMultiplier = 3.5
local Prediction = 0.135

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Azured_Nuke_V55"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local function Notify(txt)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Azured System",
        Text = txt,
        Duration = 2
    })
end

local TargetUI = Instance.new("Frame")
TargetUI.Name = "TargetUI"
TargetUI.Parent = ScreenGui
TargetUI.Size = UDim2.new(0, 140, 0, 50)
TargetUI.Position = UDim2.new(0.02, 0, 0.7, 0)
TargetUI.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TargetUI.BackgroundTransparency = 0.4
TargetUI.Visible = false
Instance.new("UICorner", TargetUI).CornerRadius = UDim.new(0, 5)

local TargetName = Instance.new("TextLabel")
TargetName.Parent = TargetUI
TargetName.Size = UDim2.new(1, 0, 0, 20)
TargetName.BackgroundTransparency = 1
TargetName.Text = "None"
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
ArmorLabel.Text = "Armor: 0"
ArmorLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
ArmorLabel.Font = Enum.Font.SourceSans
ArmorLabel.TextSize = 10

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
LockBtn.Position = UDim2.new(0.85, 0, 0.1, 0)
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

local AuraBtn = CreateBigBtn("KILL ALL", UDim2.new(0.85, -20, 0.24, 0))
local SpeedBtn = CreateBigBtn("SPEED", UDim2.new(0.85, -20, 0.32, 0))
local FlyBtn = CreateBigBtn("FLY", UDim2.new(0.85, -20, 0.4, 0))
local StompBtn = CreateBigBtn("STOMP", UDim2.new(0.85, -20, 0.48, 0))
local HitboxBtn = CreateBigBtn("HITBOX", UDim2.new(0.85, -20, 0.56, 0))

local LockedPlayer, StrafeOn, SpeedOn, FlyOn, HitOn, StompOn, AuraOn = nil, false, false, false, false, false, false
local Degree = 0

local function GetServerTarget()
    local BestTarget = nil
    local Dist = math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character:FindFirstChild("HumanoidRootPart") then
            if v.Character.Humanoid.Health > 0 then
                local d = (LocalPlayer.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                if d < Dist then Dist = d BestTarget = v end
            end
        end
    end
    return BestTarget
end

local function GetFovTarget()
    local Target, MinDist = nil, FovSize / 2
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local Hum = v.Character:FindFirstChild("Humanoid")
            if Hum and Hum.Health > 0 then
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                if OnScreen then
                    local Dist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Center).Magnitude
                    if Dist < MinDist then MinDist = Dist Target = v end
                end
            end
        end
    end
    return Target
end

local function GetChestPos(p)
    if p and p.Character then
        local Part = p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("HumanoidRootPart")
        if Part then return Part.Position + (Part.Velocity * Prediction) end
    end
    return nil
end

AuraBtn.MouseButton1Click:Connect(function() 
    AuraOn = not AuraOn 
    AuraBtn.Text = AuraOn and "KILL ALL: ON" or "KILL ALL: OFF"
    if not AuraOn then Camera.CameraType = Enum.CameraType.Custom end
end)

LockBtn.MouseButton1Click:Connect(function()
    StrafeOn = not StrafeOn
    if StrafeOn then
        local T = GetFovTarget()
        if T then LockedPlayer = T Camera.CameraType = Enum.CameraType.Scriptable Notify("Lock ON: " .. T.Name)
        else StrafeOn = false end
    else LockedPlayer = nil Camera.CameraType = Enum.CameraType.Custom Notify("Lock OFF") end
end)

SpeedBtn.MouseButton1Click:Connect(function() SpeedOn = not SpeedOn SpeedBtn.Text = SpeedOn and "SPEED: ON" or "SPEED: OFF" end)
FlyBtn.MouseButton1Click:Connect(function() FlyOn = not FlyOn FlyBtn.Text = FlyOn and "FLY: ON" or "FLY: OFF" end)
StompBtn.MouseButton1Click:Connect(function() StompOn = not StompOn StompBtn.Text = StompOn and "STOMP: ON" or "STOMP: OFF" end)
HitboxBtn.MouseButton1Click:Connect(function() HitOn = not HitOn HitboxBtn.Text = HitOn and "HITBOX: ON" or "HITBOX: OFF" end)

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
local oldIndex = mt.__index
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if not checkcaller() and method == "FireServer" and self.Name == "MainEvent" then
        if args[1] == "UpdateMousePos" or args[1] == "Shoot" then
            local T = (AuraOn and GetServerTarget()) or LockedPlayer or GetFovTarget()
            local Pos = GetChestPos(T)
            if Pos then args[2] = Pos return oldNamecall(self, unpack(args)) end
        end
    end
    return oldNamecall(self, ...)
end)

mt.__index = newcclosure(function(self, idx)
    if self == Mouse and (idx == "Hit" or idx == "Target") and not checkcaller() then
        local T = (AuraOn and GetServerTarget()) or LockedPlayer or GetFovTarget()
        local Pos = GetChestPos(T)
        if Pos then return (idx == "Hit" and CFrame.new(Pos) or T.Character:FindFirstChild("UpperTorso") or T.Character.HumanoidRootPart) end
    end
    return oldIndex(self, idx)
end)
setreadonly(mt, true)

RunService.RenderStepped:Connect(function()
    local Char = LocalPlayer.Character
    if not Char or not Char:FindFirstChild("HumanoidRootPart") then return end
    local Root, Hum = Char.HumanoidRootPart, Char.Humanoid
    local Tool = Char:FindFirstChildOfClass("Tool")

    if Tool and Tool:FindFirstChild("Ammo") and Tool.Ammo.Value == 0 then
        ReplicatedStorage.MainEvent:FireServer("Reload", Tool)
    end

    if AuraOn then
        local ATarget = GetServerTarget()
        if ATarget and ATarget.Character then
            local TRoot = ATarget.Character:FindFirstChild("HumanoidRootPart")
            local THum = ATarget.Character:FindFirstChild("Humanoid")
            if TRoot and THum then
                TargetUI.Visible = true
                TargetName.Text = "KILLING: " .. ATarget.Name
                HealthBarMain.Size = UDim2.new(math.clamp(THum.Health / THum.MaxHealth, 0, 1), 0, 1, 0)
                
                if THum.Health > 15 then
                    Degree = Degree + 0.07
                    local Pos = TRoot.Position + Vector3.new(math.sin(Degree) * 12, 7, math.cos(Degree) * 12)
                    Root.CFrame = CFrame.new(Pos, TRoot.Position)
                    Root.Velocity = Vector3.new(0, 0, 0)
                    if Tool then 
                        Tool:Activate() 
                        ReplicatedStorage.MainEvent:FireServer("Shoot", GetChestPos(ATarget)) 
                    end
                else
                    Root.CFrame = TRoot.CFrame * CFrame.new(0, 2, 0)
                    Root.Velocity = Vector3.new(0, 0, 0)
                    ReplicatedStorage.MainEvent:FireServer("Stomp")
                end
            end
        else TargetUI.Visible = false end
    else
        local CTarget = LockedPlayer or GetFovTarget()
        if CTarget and CTarget.Character and CTarget.Character:FindFirstChild("Humanoid") then
            local tHum = CTarget.Character.Humanoid
            TargetUI.Visible = true
            TargetName.Text = CTarget.Name
            HealthBarMain.Size = UDim2.new(math.clamp(tHum.Health / tHum.MaxHealth, 0, 1), 0, 1, 0)
            local armorValue = CTarget.Character:FindFirstChild("BodyArmor") and 100 or 0
            ArmorLabel.Text = "Armor: " .. armorValue
        else TargetUI.Visible = false end

        if StrafeOn and LockedPlayer and LockedPlayer.Character and LockedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local TRoot = LockedPlayer.Character.HumanoidRootPart
            Degree = Degree + 0.025
            local TargetPos = TRoot.Position + Vector3.new(math.sin(Degree * 60) * 11, 5, math.cos(Degree * 60) * 11)
            Root.CFrame = CFrame.new(TargetPos, TRoot.Position)
            Camera.CFrame = CFrame.new(TRoot.Position + Vector3.new(0, 5, 12), TRoot.Position)
        end
    end

    if SpeedOn and Hum.MoveDirection.Magnitude > 0 and not AuraOn then 
        Root.CFrame = Root.CFrame + (Hum.MoveDirection * SpeedMultiplier) 
    end
    if FlyOn and not StrafeOn and not AuraOn then 
        Root.Velocity = Vector3.new(0, 0, 0) 
        Root.CFrame = Root.CFrame + (Camera.CFrame.LookVector * 3.8) 
    end

    if StompOn and not AuraOn then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local eRoot = v.Character.HumanoidRootPart
                local eHum = v.Character:FindFirstChild("Humanoid")
                if eHum and eHum.Health <= 15 and (Root.Position - eRoot.Position).Magnitude <= StompRange then
                    ReplicatedStorage.MainEvent:FireServer("Stomp")
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
