local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

getgenv().selectedHitsound = "rbxassetid://6607142036"
getgenv().hitsoundEnabled = true

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Azured_Ultimate_V12"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local function Notify(text, color)
    local NotifyLabel = Instance.new("TextLabel")
    NotifyLabel.Parent = ScreenGui
    NotifyLabel.Size = UDim2.new(1, 0, 0, 30)
    NotifyLabel.Position = UDim2.new(0, 0, 0.1, 0)
    NotifyLabel.BackgroundTransparency = 1
    NotifyLabel.Text = text
    NotifyLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    NotifyLabel.Font = Enum.Font.GothamBold
    NotifyLabel.TextSize = 16
    local Stroke = Instance.new("UIStroke", NotifyLabel)
    Stroke.Thickness = 2
    game:GetService("TweenService"):Create(NotifyLabel, TweenInfo.new(0.5), {Position = UDim2.new(0, 0, 0.15, 0)}):Play()
    task.delay(2, function()
        game:GetService("TweenService"):Create(NotifyLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        task.wait(0.5)
        NotifyLabel:Destroy()
    end)
end

-- Aura hieu ung luon bat khi vao script
local function ApplyAura(char)
    if not char then return end
    task.wait(0.5)
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("MeshPart") then
            v.Material = Enum.Material.ForceField
        end
    end
end
LocalPlayer.CharacterAdded:Connect(ApplyAura)
if LocalPlayer.Character then ApplyAura(LocalPlayer.Character) end

local function CreateActionTool(name, actionType)
    local Tool = Instance.new("Tool")
    Tool.Name = name
    Tool.RequiresHandle = false
    Tool.Parent = LocalPlayer.Backpack
    
    Tool.Activated:Connect(function()
        local Target = nil
        local MinDist = 25
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local d = (v.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if d < MinDist then MinDist = d Target = v end
            end
        end
        
        if Target then
            if actionType == "Control" then
                Target.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
            elseif actionType == "Hard" then
                Target.Character.HumanoidRootPart.Velocity = Vector3.new(0, 500, 0) -- Day len troi
            elseif actionType == "Grab" then
                Target.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -1)
            end
            Notify("Action " .. actionType .. " on " .. Target.Name, Color3.fromRGB(255, 0, 0))
        end
    end)
end

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

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 150, 0, 320)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BackgroundTransparency = 0.2
Instance.new("UICorner", MainFrame)
MakeDraggable(MainFrame)

local function CreateMenuBtn(name, pos, callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = MainFrame
    Btn.Size = UDim2.new(1, -10, 0, 35)
    Btn.Position = pos
    Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Btn.Text = name
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 9
    Instance.new("UICorner", Btn)
    Btn.MouseButton1Click:Connect(function() callback(Btn) end)
    return Btn
end

local FlyOn, SpeedOn, EspOn, HitOn = false, false, false, false

CreateMenuBtn("FLY: OFF", UDim2.new(0, 5, 0, 10), function(b) FlyOn = not FlyOn b.Text = FlyOn and "FLY: ON" or "FLY: OFF" getgenv().FlyActive = FlyOn end)
CreateMenuBtn("SPEED: OFF", UDim2.new(0, 5, 0, 50), function(b) SpeedOn = not SpeedOn b.Text = SpeedOn and "SPEED: ON" or "SPEED: OFF" getgenv().SpeedActive = SpeedOn end)
CreateMenuBtn("ESP: OFF", UDim2.new(0, 5, 0, 90), function(b) EspOn = not EspOn b.Text = EspOn and "ESP: ON" or "ESP: OFF" end)

-- NUT TOOLS THEO Y BAN
CreateMenuBtn("TOOLS", UDim2.new(0, 5, 0, 130), function()
    CreateActionTool("Control Tool", "Control")
    CreateActionTool("Hard Tool", "Hard")
    CreateActionTool("Grab Tool", "Grab")
    Notify("Tools Created in Backpack!", Color3.fromRGB(0, 255, 255))
end)

CreateMenuBtn("HITBOX: OFF", UDim2.new(0, 5, 0, 170), function(b) HitOn = not HitOn b.Text = HitOn and "HITBOX: ON" or "HITBOX: OFF" end)
CreateMenuBtn("SOUND: ON", UDim2.new(0, 5, 0, 210), function(b) getgenv().hitsoundEnabled = not getgenv().hitsoundEnabled b.Text = getgenv().hitsoundEnabled and "SOUND: ON" or "SOUND: OFF" end)

RunService.RenderStepped:Connect(function()
    local Char = LocalPlayer.Character
    if not Char or not Char:FindFirstChild("HumanoidRootPart") then return end
    
    if getgenv().FlyActive then
        Char.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
        Char.HumanoidRootPart.CFrame = Char.HumanoidRootPart.CFrame + (Camera.CFrame.LookVector * 3.5)
    end
    if getgenv().SpeedActive and Char.Humanoid.MoveDirection.Magnitude > 0 then
        Char.HumanoidRootPart.CFrame = Char.HumanoidRootPart.CFrame + (Char.Humanoid.MoveDirection * 2.5)
    end
    if HitOn then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                v.Character.HumanoidRootPart.Size = Vector3.new(15, 15, 15)
                v.Character.HumanoidRootPart.Transparency = 0.8
            end
        end
    end
end)

Notify("Azured!", Color3.fromRGB(0, 255, 0))
