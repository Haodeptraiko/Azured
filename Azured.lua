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
ScreenGui.Name = "Azured_V3_Final"
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

local Title = Instance.new("TextLabel")
Title.Parent = Sidebar
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "Azured"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 22

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
    Page.Name = name .. "Page"
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
local MiscPage = CreatePage("Misc")

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
    Btn.Font = Enum.Font.GothamSemibold
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
CreateTabBtn("Misc", MiscPage)
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
    SecTitle.Font = Enum.Font.GothamBold
    SecTitle.TextSize = 12
    
    local function UpdateSize()
        SecFrame.Size = UDim2.new(1, -10, 0, SecLayout.AbsoluteContentSize.Y + 10)
    end
    SecLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSize)
    
    return SecFrame
end

local function CreateToggle(parent, text, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Parent = parent
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Frame.Size = UDim2.new(1, 0, 0, 35)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)
    
    local Label = Instance.new("TextLabel")
    Label.Parent = Frame
    Label.Text = text
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Btn = Instance.new("TextButton")
    Btn.Parent = Frame
    Btn.Size = UDim2.new(0, 35, 0, 18)
    Btn.Position = UDim2.new(1, -45, 0.25, 0)
    Btn.Text = ""
    Btn.BackgroundColor3 = default and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(80, 80, 80)
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)
    
    local state = default
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(80, 80, 80)
        callback(state)
    end)
end

local function CreateSlider(parent, text, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Parent = parent
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Frame.Size = UDim2.new(1, 0, 0, 45)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)

    local Label = Instance.new("TextLabel")
    Label.Parent = Frame
    Label.Text = text .. ": " .. default
    Label.Size = UDim2.new(1, -20, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local SliderBar = Instance.new("TextButton")
    SliderBar.Parent = Frame
    SliderBar.Size = UDim2.new(1, -20, 0, 4)
    SliderBar.Position = UDim2.new(0, 10, 0, 30)
    SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SliderBar.Text = ""

    local Indicator = Instance.new("Frame")
    Indicator.Parent = SliderBar
    Indicator.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    Indicator.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)

    local function UpdateSlider()
        local mousePos = UserInputService:GetMouseLocation().X
        local barPos = SliderBar.AbsolutePosition.X
        local barSize = SliderBar.AbsoluteSize.X
        local percent = math.clamp((mousePos - barPos) / barSize, 0, 1)
        local val = math.floor(min + (max - min) * percent)
        Indicator.Size = UDim2.new(percent, 0, 1, 0)
        Label.Text = text .. ": " .. val
        callback(val)
    end

    SliderBar.MouseButton1Down:Connect(function()
        local MoveConn, UpConn
        MoveConn = RunService.RenderStepped:Connect(UpdateSlider)
        UpConn = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                MoveConn:Disconnect()
                UpConn:Disconnect()
            end
        end)
    end)
end

local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.NumSides = 100
FovCircle.Radius = FovSize
FovCircle.Filled = false
FovCircle.Color = Color3.fromRGB(255, 255, 255)
FovCircle.Visible = false

local LockedPlayer, StrafeOn, SpeedOn, FlyOn, HitOn, StompOn, RapidOn, Shooting, FovShow = nil, false, false, false, false, false, false, false, false
local Degree = 0

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local function GetPlayerFromMouse()
    local Target = Mouse.Target
    if Target and Target.Parent then
        local Char = Target.Parent:FindFirstChild("Humanoid") and Target.Parent or Target.Parent.Parent:FindFirstChild("Humanoid") and Target.Parent.Parent
        if Char then return Players:GetPlayerFromCharacter(Char) end
    end
    return nil
end

local function GiveAuraTool()
    if LocalPlayer.Backpack:FindFirstChild("Aura") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Aura")) then return end
    local Tool = Instance.new("Tool")
    Tool.Name = "Aura"
    Tool.RequiresHandle = true
    local Handle = Instance.new("Part")
    Handle.Name = "Handle"
    Handle.Size = Vector3.new(1, 1, 1)
    Handle.Transparency = 0.5
    Handle.Color = Color3.fromRGB(170, 0, 255)
    Handle.Parent = Tool
    Tool.Parent = LocalPlayer.Backpack
    Tool.Activated:Connect(function()
        local Plr = GetPlayerFromMouse()
        if Plr and Plr ~= LocalPlayer then
            LockedPlayer = Plr; StrafeOn = true; FovCircle.Visible = FovShow
            Camera.CameraType = Enum.CameraType.Scriptable
        else
            LockedPlayer = nil; StrafeOn = false; FovCircle.Visible = false
            Camera.CameraType = Enum.CameraType.Custom
        end
    end)
end

local AuraSec = CreateSection(CombatPage, "Aura")
local SilentSec = CreateSection(CombatPage, "Silent")
local FovSec = CreateSection(CombatPage, "Fov")

local function CreateButton(parent, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = parent
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Btn.Size = UDim2.new(1, 0, 0, 35)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    Btn.MouseButton1Click:Connect(callback)
end

CreateButton(AuraSec, "Get Aura Tool", GiveAuraTool)
CreateToggle(SilentSec, "Rapid Fire 100x", false, function(v) RapidOn = v end)
CreateToggle(SilentSec, "Hitbox Large", false, function(v) HitOn = v end)
CreateToggle(SilentSec, "Auto Stomp", false, function(v) StompOn = v end)

CreateToggle(FovSec, "Fov Visible", false, function(v) FovShow = v if StrafeOn then FovCircle.Visible = v end end)
CreateSlider(FovSec, "Fov Size", 50, 800, 150, function(v) FovSize = v FovCircle.Radius = v end)

CreateToggle(MovementPage, "Speed Hack", false, function(v) SpeedOn = v end)
CreateToggle(MovementPage, "Fly Mode", false, function(v) FlyOn = v end)

RunService.Heartbeat:Connect(function()
    FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end)

RunService.RenderStepped:Connect(function()
    local Char = LocalPlayer.Character
    if not Char or not Char:FindFirstChild("HumanoidRootPart") then return end
    local Root, Hum = Char.HumanoidRootPart, Char.Humanoid
    if StrafeOn and LockedPlayer and LockedPlayer.Character and LockedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local TRoot = LockedPlayer.Character.HumanoidRootPart
        local TChest = LockedPlayer.Character:FindFirstChild("UpperTorso") and LockedPlayer.Character.UpperTorso.Position or TRoot.Position
        Degree = Degree + 0.025
        local TargetPos = TChest + Vector3.new(math.sin(Degree * 60) * 11, 5, math.cos(Degree * 60) * 11)
        Root.CFrame = CFrame.new(TargetPos, TChest)
        Camera.CFrame = CFrame.new(TChest + Vector3.new(0, 5, 12), TChest)
    end
    if SpeedOn and Hum.MoveDirection.Magnitude > 0 then Root.CFrame = Root.CFrame + (Hum.MoveDirection * SpeedMultiplier) end
    if FlyOn and not StrafeOn then Root.Velocity = Vector3.new(0, 0, 0) Root.CFrame = Root.CFrame + (Camera.CFrame.LookVector * 3.8) end
    if StompOn then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local eRoot, eHum = v.Character.HumanoidRootPart, v.Character:FindFirstChild("Humanoid")
                if eHum and eHum.Health <= 15 and (Root.Position - eRoot.Position).Magnitude <= StompRange then ReplicatedStorage.MainEvent:FireServer("Stomp") end
            end
        end
    end
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local pRoot = v.Character.HumanoidRootPart
            if HitOn then pRoot.Size, pRoot.Transparency, pRoot.CanCollide = Vector3.new(HitSize, HitSize, HitSize), 0.8, false
            else pRoot.Size, pRoot.Transparency = Vector3.new(2, 2, 1), 1 end
        end
    end
    if RapidOn and Shooting and LocalPlayer.Character:FindFirstChildOfClass("Tool") then
        local Pos = (StrafeOn and LockedPlayer) and (LockedPlayer.Character:FindFirstChild("UpperTorso") and LockedPlayer.Character.UpperTorso.Position or LockedPlayer.Character.HumanoidRootPart.Position) or Mouse.Hit.p
        for i = 1, 100 do ReplicatedStorage.MainEvent:FireServer("Shoot", Pos) end
    end
end)

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    if not checkcaller() and getnamecallmethod() == "FireServer" and self.Name == "MainEvent" then
        if (args[1] == "UpdateMousePos" or args[1] == "Shoot") and StrafeOn and LockedPlayer then
            local T = LockedPlayer.Character
            args[2] = T:FindFirstChild("UpperTorso") and T.UpperTorso.Position or T.HumanoidRootPart.Position
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)
