local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local FovSize = 150
local StompRange = 15 
local LockedPlayer, StrafeOn, SpeedOn, FlyOn, HitOn, EspOn, StompOn = nil, false, false, false, false, false, false
local Degree = 0

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Azured_V3_Final_White"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local function MakeDraggable(obj)
    local Dragging, DragInput, DragStart, StartPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true; DragStart = input.Position; StartPos = obj.Position
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

local LockBtn = Instance.new("TextButton")
LockBtn.Parent = ScreenGui
LockBtn.Size = UDim2.new(0, 80, 0, 30)
LockBtn.Position = UDim2.new(0.8, 0, 0.4, 0)
LockBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LockBtn.BackgroundTransparency = 0.2
LockBtn.Text = "LOCK: OFF"
LockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LockBtn.Font = Enum.Font.SourceSans
LockBtn.TextSize = 14
local LockStroke = Instance.new("UIStroke", LockBtn)
LockStroke.Thickness = 1.5
LockStroke.Color = Color3.fromRGB(0, 255, 0)
Instance.new("UICorner", LockBtn).CornerRadius = UDim.new(0, 4)
MakeDraggable(LockBtn)

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 110, 0, 220)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BackgroundTransparency = 0.2
Instance.new("UICorner", MainFrame)
MakeDraggable(MainFrame)

local MiniBtn = Instance.new("TextButton")
MiniBtn.Parent = MainFrame
MiniBtn.Size = UDim2.new(0, 20, 0, 20)
MiniBtn.Position = UDim2.new(1, -25, 0, 5)
MiniBtn.Text = "-"
MiniBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", MiniBtn)

local Content = Instance.new("Frame")
Content.Parent = MainFrame
Content.Size = UDim2.new(1, 0, 1, -30)
Content.Position = UDim2.new(0, 0, 0, 30)
Content.BackgroundTransparency = 1

MiniBtn.MouseButton1Click:Connect(function()
    Content.Visible = not Content.Visible
    MainFrame.Size = Content.Visible and UDim2.new(0, 110, 0, 220) or UDim2.new(0, 110, 0, 30)
    MiniBtn.Text = Content.Visible and "-" or "+"
end)

local function CreateMenuBtn(name, pos)
    local Btn = Instance.new("TextButton")
    Btn.Parent = Content
    Btn.Size = UDim2.new(1, -10, 0, 30)
    Btn.Position = pos
    Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Btn.Text = name
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.SourceSans
    Btn.TextSize = 13
    Instance.new("UICorner", Btn)
    return Btn
end

local SpeedBtn = CreateMenuBtn("SPEED", UDim2.new(0, 5, 0, 0))
local FlyBtn = CreateMenuBtn("FLY", UDim2.new(0, 5, 0, 35))
local HitboxBtn = CreateMenuBtn("HITBOX", UDim2.new(0, 5, 0, 70))
local EspBtn = CreateMenuBtn("ESP NAME", UDim2.new(0, 5, 0, 105))
local StompBtn = CreateMenuBtn("STOMP", UDim2.new(0, 5, 0, 140))

local function GetClosestPlayer()
    local Target, MinDist = nil, math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                local Dist = (v.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude
                if Dist < MinDist then MinDist = Dist; Target = v end
            end
        end
    end
    return Target
end

local function GetSilentTarget()
    local Target, MinDist = nil, FovSize
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
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

local function GetChestPos(p)
    if not p or not p.Character then return nil end
    return p.Character:FindFirstChild("UpperTorso") and p.Character.UpperTorso.Position or p.Character.HumanoidRootPart.Position
end

LockBtn.MouseButton1Click:Connect(function()
    StrafeOn = not StrafeOn
    if StrafeOn then
        local T = GetClosestPlayer()
        if T then 
            LockedPlayer = T; LockBtn.Text = "LOCK: ON"; LockStroke.Color = Color3.fromRGB(255, 255, 255); Camera.CameraType = Enum.CameraType.Scriptable
        else StrafeOn = false end
    else
        LockedPlayer = nil; LockBtn.Text = "LOCK: OFF"; LockStroke.Color = Color3.fromRGB(0, 255, 0); Camera.CameraType = Enum.CameraType.Custom
    end
end)

SpeedBtn.MouseButton1Click:Connect(function() SpeedOn = not SpeedOn; SpeedBtn.TextColor3 = SpeedOn and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255) end)
FlyBtn.MouseButton1Click:Connect(function() FlyOn = not FlyOn; FlyBtn.TextColor3 = FlyOn and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255) end)
HitboxBtn.MouseButton1Click:Connect(function() HitOn = not HitOn; HitboxBtn.TextColor3 = HitOn and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255) end)
EspBtn.MouseButton1Click:Connect(function() EspOn = not EspOn; EspBtn.TextColor3 = EspOn and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255) end)
StompBtn.MouseButton1Click:Connect(function() StompOn = not StompOn; StompBtn.TextColor3 = StompOn and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255) end)

local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if not checkcaller() and method == "FireServer" and self.Name == "MainEvent" then
        if args[1] == "UpdateMousePos" or args[1] == "Shoot" then
            local ST = GetSilentTarget()
            if ST then args[2] = GetChestPos(ST) return old(self, unpack(args)) end
        end
    end
    return old(self, ...)
end)
setreadonly(mt, true)

RunService.RenderStepped:Connect(function()
    local Char = LocalPlayer.Character
    if not Char or not Char:FindFirstChild("HumanoidRootPart") then return end
    local Root, Hum = Char.HumanoidRootPart, Char.Humanoid
    if StrafeOn and LockedPlayer and LockedPlayer.Character and LockedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        if LockedPlayer.Character.Humanoid.Health <= 0 then
            StrafeOn = false; LockedPlayer = nil; LockBtn.Text = "LOCK: OFF"; LockStroke.Color = Color3.fromRGB(0, 255, 0); Camera.CameraType = Enum.CameraType.Custom
        else
            local TRoot = LockedPlayer.Character.HumanoidRootPart
            Degree = Degree + 0.03
            local TargetPos = TRoot.Position + Vector3.new(math.sin(Degree*60) * 11, 5, math.cos(Degree*60) * 11)
            Root.CFrame = CFrame.new(TargetPos, TRoot.Position)
            Camera.CFrame = CFrame.new(TRoot.Position + Vector3.new(0, 5, 12), TRoot.Position)
        end
    end
    if SpeedOn and Hum.MoveDirection.Magnitude > 0 then Root.CFrame = Root.CFrame + (Hum.MoveDirection * 2.5) end
    if FlyOn and not StrafeOn then Root.Velocity = Vector3.new(0, 0, 0); Root.CFrame = Root.CFrame + (Camera.CFrame.LookVector * 3.8) end
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local pChar = v.Character
            local pRoot = pChar.HumanoidRootPart
            local pHum = pChar:FindFirstChild("Humanoid")
            if StompOn and pHum and pHum.Health <= 15 then
                if (Root.Position - pRoot.Position).Magnitude <= StompRange then ReplicatedStorage.MainEvent:FireServer("Stomp") end
            end
            if HitOn then pRoot.Size, pRoot.Transparency, pRoot.CanCollide = Vector3.new(30, 30, 30), 0.7, false
            else pRoot.Size, pRoot.Transparency = Vector3.new(2, 2, 1), 1 end
            local Tag = pRoot:FindFirstChild("EspTag")
            if EspOn then
                if not Tag then
                    Tag = Instance.new("BillboardGui", pRoot); Tag.Name = "EspTag"; Tag.Size = UDim2.new(0, 100, 0, 40); Tag.AlwaysOnTop = true
                    local L = Instance.new("TextLabel", Tag); L.Size = UDim2.new(1, 0, 1, 0); L.BackgroundTransparency = 1; L.TextColor3 = Color3.fromRGB(255, 255, 255); L.TextSize = 12; L.Font = Enum.Font.SourceSans; L.Text = v.Name
                end
            elseif Tag then Tag:Destroy() end
        end
    end
end)
