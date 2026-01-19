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
ScreenGui.Name = "Azured_V3_RapidFix"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ScreenGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Text = "M"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 24
ToggleBtn.Draggable = true
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.2, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)

local Sidebar = Instance.new("Frame")
Sidebar.Parent = MainFrame
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Sidebar.Size = UDim2.new(0, 140, 1, 0)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 6)

local TabContainer = Instance.new("Frame")
TabContainer.Parent = Sidebar
TabContainer.BackgroundTransparency = 1
TabContainer.Position = UDim2.new(0, 0, 0, 60)
TabContainer.Size = UDim2.new(1, 0, 1, -60)

local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainFrame
ContentArea.Position = UDim2.new(0, 150, 0, 10)
ContentArea.Size = UDim2.new(0, 390, 0, 330)
ContentArea.BackgroundTransparency = 1

local Tabs, Pages = {}, {}

local function CreatePage(name)
    local Page = Instance.new("ScrollingFrame")
    Page.Parent = ContentArea
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 2
    Page.Visible = false
    Instance.new("UIListLayout", Page).Padding = UDim.new(0, 10)
    table.insert(Pages, Page)
    return Page
end

local CombatPage = CreatePage("Combat")
local MovementPage = CreatePage("Movement")

local function SwitchTab(activePage)
    for _, p in pairs(Pages) do p.Visible = false end
    activePage.Visible = true
end

local function CreateTabBtn(text, page)
    local Btn = Instance.new("TextButton")
    Btn.Parent = TabContainer
    Btn.Size = UDim2.new(1, -20, 0, 35)
    Btn.Position = UDim2.new(0, 10, 0, #Tabs * 40)
    Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    Btn.MouseButton1Click:Connect(function()
        SwitchTab(page)
        for _, b in pairs(Tabs) do b.BackgroundColor3 = Color3.fromRGB(30, 30, 30) end
        Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end)
    table.insert(Tabs, Btn)
end

CreateTabBtn("Combat", CombatPage)
CreateTabBtn("Movement", MovementPage)
SwitchTab(CombatPage)

local function CreateSection(parent, name)
    local SecFrame = Instance.new("Frame")
    SecFrame.Parent = parent
    SecFrame.Size = UDim2.new(1, -10, 0, 30)
    SecFrame.BackgroundTransparency = 1
    local SecLayout = Instance.new("UIListLayout", SecFrame)
    SecLayout.Padding = UDim.new(0, 5)
    local SecTitle = Instance.new("TextLabel")
    SecTitle.Parent = SecFrame
    SecTitle.Size = UDim2.new(1, 0, 0, 20)
    SecTitle.Text = "--- " .. name .. " ---"
    SecTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
    SecTitle.BackgroundTransparency = 1
    SecLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SecFrame.Size = UDim2.new(1, -10, 0, SecLayout.AbsoluteContentSize.Y + 10)
    end)
    return SecFrame
end

local function CreateToggle(parent, text, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Parent = parent
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Frame.Size = UDim2.new(1, 0, 0, 35)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)
    local Btn = Instance.new("TextButton")
    Btn.Parent = Frame
    Btn.Size = UDim2.new(0, 35, 0, 18)
    Btn.Position = UDim2.new(1, -45, 0.25, 0)
    Btn.Text = ""
    Btn.BackgroundColor3 = default and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(80, 80, 80)
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)
    local Label = Instance.new("TextLabel")
    Label.Parent = Frame
    Label.Text = text
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    local state = default
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(80, 80, 80)
        callback(state)
    end)
end

local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.NumSides = 100
FovCircle.Radius = FovSize
FovCircle.Visible = false

local LockedPlayer, StrafeOn, SilentOn, RapidOn, Shooting, SpeedOn, FlyOn, HitOn, StompOn = nil, false, false, false, false, false, false, false, false
local Degree = 0

local function GetSilentTarget()
    local Target, MinDist = nil, FovSize
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local Hum = v.Character:FindFirstChild("Humanoid")
            if Hum and Hum.Health > 0 then
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                local Dist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Center).Magnitude
                if OnScreen and Dist < MinDist then MinDist = Dist; Target = v end
            end
        end
    end
    return Target
end

local function GetChestPos(p)
    if not p or not p.Character then return nil end
    return p.Character:FindFirstChild("UpperTorso") and p.Character.UpperTorso.Position or p.Character.HumanoidRootPart.Position
end

local AuraSec = CreateSection(CombatPage, "Aura Lock")
local SilentSec = CreateSection(CombatPage, "Silent Aim")

local function GiveAuraTool()
    if LocalPlayer.Backpack:FindFirstChild("Aura") then return end
    local Tool = Instance.new("Tool")
    Tool.Name = "Aura"
    Tool.RequiresHandle = true
    local Handle = Instance.new("Part")
    Handle.Name = "Handle"
    Handle.Parent = Tool
    Tool.Parent = LocalPlayer.Backpack
    Tool.Activated:Connect(function()
        local T = Mouse.Target
        local Plr = T and T.Parent and Players:GetPlayerFromCharacter(T.Parent) or T and T.Parent.Parent and Players:GetPlayerFromCharacter(T.Parent.Parent)
        if Plr and Plr ~= LocalPlayer then LockedPlayer = Plr StrafeOn = true Camera.CameraType = Enum.CameraType.Scriptable
        else LockedPlayer = nil StrafeOn = false Camera.CameraType = Enum.CameraType.Custom end
    end)
end

local function CreateButton(parent, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = parent
    Btn.Size = UDim2.new(1, 0, 0, 35)
    Btn.Text = text
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    Btn.MouseButton1Click:Connect(callback)
end

CreateButton(AuraSec, "Get Aura Tool", GiveAuraTool)
CreateToggle(SilentSec, "Silent Aim", false, function(v) SilentOn = v end)
CreateToggle(SilentSec, "Rapid Fire 100x", false, function(v) RapidOn = v end)
CreateToggle(SilentSec, "Auto Stomp", false, function(v) StompOn = v end)

CreateToggle(MovementPage, "Speed Hack", false, function(v) SpeedOn = v end)

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

UserInputService.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then Shooting = true end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then Shooting = false end end)

RunService.RenderStepped:Connect(function()
    local Char = LocalPlayer.Character
    if not Char or not Char:FindFirstChild("HumanoidRootPart") then return end
    local Root, Hum = Char.HumanoidRootPart, Char.Humanoid

    if StrafeOn and LockedPlayer and LockedPlayer.Character then
        local TChest = GetChestPos(LockedPlayer)
        if TChest then
            Degree = Degree + 0.025
            Root.CFrame = CFrame.new(TChest + Vector3.new(math.sin(Degree*60)*11, 5, math.cos(Degree*60)*11), TChest)
            Camera.CFrame = CFrame.new(TChest + Vector3.new(0, 5, 12), TChest)
        end
    end

    if SpeedOn and Hum.MoveDirection.Magnitude > 0 then Root.CFrame = Root.CFrame + (Hum.MoveDirection * SpeedMultiplier) end

    if StompOn then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and (Root.Position - v.Character.HumanoidRootPart.Position).Magnitude <= StompRange then
                if v.Character.Humanoid.Health <= 15 then ReplicatedStorage.MainEvent:FireServer("Stomp") end
            end
        end
    end

    -- Fix Rapid Fire
    if RapidOn and Shooting then
        local Tool = Char:FindFirstChildOfClass("Tool")
        if Tool then
            local ST = GetSilentTarget()
            local TargetPos = (SilentOn and ST) and GetChestPos(ST) or (StrafeOn and LockedPlayer) and GetChestPos(LockedPlayer) or Mouse.Hit.p
            
            -- Gửi nhiều gói tin cùng lúc để tăng tốc độ bắn
            for i = 1, 10 do
                ReplicatedStorage.MainEvent:FireServer("Shoot", TargetPos)
            end
        end
    end
end)

-- Metatable Hook để Silent Aim hoạt động chuẩn
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if not checkcaller() and method == "FireServer" and self.Name == "MainEvent" then
        if args[1] == "UpdateMousePos" or args[1] == "Shoot" then
            local ST = GetSilentTarget()
            local TargetPos = (SilentOn and ST) and GetChestPos(ST) or (StrafeOn and LockedPlayer) and GetChestPos(LockedPlayer)
            if TargetPos then args[2] = TargetPos return old(self, unpack(args)) end
        end
    end
    return old(self, ...)
end)
setreadonly(mt, true)
