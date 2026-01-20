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
ScreenGui.Name = "Azured_Chest_V55"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

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

local FovCircle = Instance.new("Frame")
FovCircle.Name = "FovCircle"
FovCircle.Parent = ScreenGui
FovCircle.Size = UDim2.new(0, FovSize, 0, FovSize)
FovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FovCircle.BackgroundTransparency = 1
FovCircle.Visible = true
local StrokeFOV = Instance.new("UIStroke", FovCircle)
StrokeFOV.Thickness = 1
StrokeFOV.Color = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", FovCircle).CornerRadius = UDim.new(1, 0)

local function CreateBar(name, pos, size)
    local Frame = Instance.new("Frame")
    Frame.Name = name
    Frame.Parent = ScreenGui
    Frame.Size = size
    Frame.Position = pos
    Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Frame.BorderSizePixel = 0
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    local Stroke = Instance.new("UIStroke", Frame)
    Stroke.Color = Color3.fromRGB(60, 60, 60)
    Stroke.Thickness = 2
    MakeDraggable(Frame)
    
    local Tl = Instance.new("TextLabel")
    Tl.Parent = Frame
    Tl.Size = UDim2.new(1, -20, 1, 0)
    Tl.Position = UDim2.new(0, 10, 0, 0)
    Tl.Text = name .. " - ALWAYS ACTIVE"
    Tl.TextColor3 = Color3.fromRGB(255, 255, 255)
    Tl.Font = Enum.Font.SourceSansBold
    Tl.TextSize = 14
    Tl.BackgroundTransparency = 1
    Tl.TextXAlignment = Enum.TextXAlignment.Left
    
    return Frame
end

local MainM = CreateBar("MAIN", UDim2.new(0.3, 0, 0.05, 0), UDim2.new(0, 250, 0, 35))
local FarmM = CreateBar("AUTO FARM", UDim2.new(0.3, 0, 0.12, 0), UDim2.new(0, 200, 0, 35))

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

local function GetATM()
    for _, v in pairs(workspace.Cashiers:GetChildren()) do
        if v:IsA("Model") and v:FindFirstChild("Head") and v.Head.Transparency == 0 then return v end
    end
    return nil
end

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

RunService.RenderStepped:Connect(function()
    local Char = LocalPlayer.Character
    if not Char or not Char:FindFirstChild("HumanoidRootPart") then return end
    local Root, Hum = Char.HumanoidRootPart, Char.Humanoid

    if Hum.MoveDirection.Magnitude > 0 then Root.CFrame = Root.CFrame + (Hum.MoveDirection * SpeedMultiplier) end
    Root.Velocity = Vector3.new(0, 0, 0) Root.CFrame = Root.CFrame + (Camera.CFrame.LookVector * 3.8)

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local eRoot, eHum = v.Character.HumanoidRootPart, v.Character:FindFirstChild("Humanoid")
            if eHum and eHum.Health <= 15 and (Root.Position - eRoot.Position).Magnitude <= StompRange then 
                ReplicatedStorage.MainEvent:FireServer("Stomp") 
            end
            eRoot.Size, eRoot.Transparency, eRoot.CanCollide = Vector3.new(HitSize, HitSize, HitSize), 0.8, false
        end
    end

    local TargetATM = GetATM()
    if TargetATM and TargetATM:FindFirstChild("Head") then
        Root.CFrame = TargetATM.Head.CFrame * CFrame.new(0, -2, 2)
        local Tool = Char:FindFirstChildOfClass("Tool")
        if Tool then Tool:Activate() end
    end
    for _, v in pairs(workspace:GetChildren()) do
        if v.Name == "DroppedCash" and (Root.Position - v.Position).Magnitude <= 18 then
            fireclickdetector(v:FindFirstChild("ClickDetector"))
        end
    end
end)
