local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Prediction = 0.16599
local TargetPart = "HumanoidRootPart"

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = HttpService:GenerateGUID(false)
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local function MakeDraggable(obj)
    local Dragging, DragInput, DragStart, StartPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPos = obj.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then Dragging = false end
            end)
        end
    end)
    obj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then DragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - DragStart
            obj.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        end
    end)
end

local function ApplyWhiteAura(char)
    if not char then return end
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("MeshPart") then
            v.Material = Enum.Material.ForceField
            v.Color = Color3.fromRGB(255, 255, 255)
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    ApplyWhiteAura(char)
end)
if LocalPlayer.Character then ApplyWhiteAura(LocalPlayer.Character) end

local function CreateRoundBtn(text, pos, color)
    local Btn = Instance.new("TextButton")
    Btn.Parent = ScreenGui
    Btn.Size = UDim2.new(0, 65, 0, 65)
    Btn.Position = pos
    Btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Btn.Text = text
    Btn.TextColor3 = color
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 11
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)
    local Stroke = Instance.new("UIStroke", Btn)
    Stroke.Thickness = 3
    Stroke.Color = color
    MakeDraggable(Btn)
    return Btn, Stroke
end

local LockBtn, LockStroke = CreateRoundBtn("LOCK", UDim2.new(0.8, 0, 0.4, 0), Color3.fromRGB(0, 255, 0))

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 110, 0, 185)
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
    if Content.Visible then
        MainFrame.Size = UDim2.new(0, 110, 0, 185)
        MiniBtn.Text = "-"
    else
        MainFrame.Size = UDim2.new(0, 110, 0, 30)
        MiniBtn.Text = "+"
    end
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
local EspBtn = CreateMenuBtn("ESP NAME", UDim2.new(0, 5, 0, 105))

local LockedPlayer, StrafeOn, SpeedOn, FlyOn, HitOn, EspOn = nil, false, false, false, false, false
local Degree = 0

local function GetClosestPlayer()
    local Target, MinDist = nil, math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local Dist = (v.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude
            if Dist < MinDist then
                MinDist = Dist
                Target = v
            end
        end
    end
    return Target
end

LockBtn.MouseButton1Click:Connect(function()
    StrafeOn = not StrafeOn
    if StrafeOn then
        local T = GetClosestPlayer()
        if T then 
            LockedPlayer = T
            LockStroke.Color = Color3.fromRGB(255, 255, 255)
            Camera.CameraType = Enum.CameraType.Scriptable
        else 
            StrafeOn = false 
        end
    else
        LockedPlayer = nil
        LockStroke.Color = Color3.fromRGB(0, 255, 0)
        Camera.CameraType = Enum.CameraType.Custom
    end
end)

SpeedBtn.MouseButton1Click:Connect(function() SpeedOn = not SpeedOn; SpeedBtn.TextColor3 = SpeedOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200) end)
FlyBtn.MouseButton1Click:Connect(function() FlyOn = not FlyOn; FlyBtn.TextColor3 = FlyOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200) end)
HitboxBtn.MouseButton1Click:Connect(function() HitOn = not HitOn; HitboxBtn.TextColor3 = HitOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200) end)
EspBtn.MouseButton1Click:Connect(function() EspOn = not EspOn; EspBtn.TextColor3 = EspOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200) end)

RunService.RenderStepped:Connect(function()
    local Char = LocalPlayer.Character
    if not Char or not Char:FindFirstChild("HumanoidRootPart") or not Char:FindFirstChild("Humanoid") then return end
    local Root, Hum = Char.HumanoidRootPart, Char.Humanoid

    if StrafeOn and LockedPlayer and LockedPlayer.Character and LockedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        if LockedPlayer.Character.Humanoid.Health <= 0 then
            StrafeOn = false
            LockedPlayer = nil
            LockStroke.Color = Color3.fromRGB(0, 255, 0)
            Camera.CameraType = Enum.CameraType.Custom
            Line.Visible = false
        else
            local TRoot = LockedPlayer.Character.HumanoidRootPart
            Degree = Degree + 1.5
            local TargetPos = TRoot.Position + Vector3.new(math.sin(Degree) * 11, 5, math.cos(Degree) * 11)
            Root.CFrame = CFrame.new(TargetPos, TRoot.Position)
            Camera.CFrame = CFrame.new(TRoot.Position + Vector3.new(0, 10, 20), TRoot.Position)

            local Pos, OnScreen = Camera:WorldToViewportPoint(TRoot.Position + (TRoot.Velocity * Prediction))
            if OnScreen then
                Line.Visible = true
                Line.Color = Color3.fromRGB(255, 255, 255)
                Line.Thickness = 1
                Line.Transparency = 1
                Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                Line.To = Vector2.new(Pos.X, Pos.Y)
            else
                Line.Visible = false
            end
        end
    else
        Line.Visible = false
    end

    if SpeedOn and Hum.MoveDirection.Magnitude > 0 then
        Root.CFrame = Root.CFrame + (Hum.MoveDirection * 2.5)
    end
    
    if FlyOn and not StrafeOn then
        Root.Velocity = Vector3.new(0, 0, 0)
        Root.CFrame = Root.CFrame + (Camera.CFrame.LookVector * 3.8)
    end

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local pRoot = v.Character.HumanoidRootPart
            if HitOn then
                pRoot.Size = Vector3.new(30, 30, 30)
                pRoot.Transparency = 0.7
                pRoot.CanCollide = false
            else
                pRoot.Size = Vector3.new(2, 2, 1)
                pRoot.Transparency = 1
            end
            
            local Tag = pRoot:FindFirstChild("EspTag")
            if EspOn then
                if not Tag then
                    Tag = Instance.new("BillboardGui", pRoot)
                    Tag.Name = "EspTag"
                    Tag.Size = UDim2.new(0, 100, 0, 40)
                    Tag.AlwaysOnTop = true
                    local L = Instance.new("TextLabel", Tag)
                    L.Size = UDim2.new(1, 0, 1, 0)
                    L.BackgroundTransparency = 1
                    L.TextColor3 = Color3.fromRGB(255, 255, 255)
                    L.TextSize = 10
                    L.Font = Enum.Font.GothamBold
                    L.Name = "TextLabel"
                end
                Tag.TextLabel.Text = v.Name
            elseif Tag then 
                Tag:Destroy() 
            end
        end
    end
end)

local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if StrafeOn and LockedPlayer and method == "FireServer" and args[1] == "UpdateMousePos" then
        args[2] = LockedPlayer.Character[TargetPart].Position + (LockedPlayer.Character[TargetPart].Velocity * Prediction)
        return old(self, unpack(args))
    end
    
    return old(self, ...)
end)

setreadonly(mt, true)

