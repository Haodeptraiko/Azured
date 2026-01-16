local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Khoi tao ScreenGui
local AzureGui = Instance.new("ScreenGui")
AzureGui.Name = "AzureBeta"
AzureGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
AzureGui.ResetOnSpawn = false

-- Khung chinh (Main Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = AzureGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.Size = UDim2.new(0, 500, 0, 350)

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 5)

-- Thanh ben trai (Sidebar)
local SideBar = Instance.new("Frame")
SideBar.Name = "SideBar"
SideBar.Parent = MainFrame
SideBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
SideBar.BorderSizePixel = 0
SideBar.Size = UDim2.new(0, 120, 1, 0)
Instance.new("UICorner", SideBar)

local Title = Instance.new("TextLabel")
Title.Parent = SideBar
Title.Text = "Azure | Beta"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 105, 180)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

-- Danh sach Tab
local TabContainer = Instance.new("ScrollingFrame")
TabContainer.Parent = SideBar
TabContainer.Position = UDim2.new(0, 0, 0, 50)
TabContainer.Size = UDim2.new(1, 0, 1, -50)
TabContainer.BackgroundTransparency = 1
TabContainer.ScrollBarTransparency = 1

local UIList = Instance.new("UIListLayout", TabContainer)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 5)

-- Vung noi dung (Content)
local ContentFrame = Instance.new("Frame")
ContentFrame.Parent = MainFrame
ContentFrame.Position = UDim2.new(0, 130, 0, 10)
ContentFrame.Size = UDim2.new(1, -140, 1, -20)
ContentFrame.BackgroundTransparency = 1

local _G = {Speed = false, Fly = false, SpeedVal = 1.5}

local function CreateTab(name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Parent = TabContainer
    TabBtn.Size = UDim2.new(1, -10, 0, 30)
    TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.Font = Enum.Font.Gotham
    TabBtn.TextSize = 12
    Instance.new("UICorner", TabBtn)
    return TabBtn
end

local function CreateToggle(name, parent, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, 0, 0, 30)
    Frame.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Text = name
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Btn = Instance.new("TextButton", Frame)
    Btn.Position = UDim2.new(0.8, 0, 0.1, 0)
    Btn.Size = UDim2.new(0, 40, 0, 20)
    Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Btn.Text = ""
    Instance.new("UICorner", Btn)
    
    local state = false
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.BackgroundColor3 = state and Color3.fromRGB(255, 105, 180) or Color3.fromRGB(50, 50, 50)
        callback(state)
    end)
end

-- Tao cac muc y hinh
local AimBtn = CreateTab("Aiming")
local BlatantBtn = CreateTab("Blatant")
local VisualBtn = CreateTab("Visuals")

-- Noi dung Tab Blatant (Movement)
local BlatantContent = Instance.new("Frame", ContentFrame)
BlatantContent.Size = UDim2.new(1, 0, 1, 0)
BlatantContent.BackgroundTransparency = 1
local Layout = Instance.new("UIListLayout", BlatantContent)

CreateToggle("Speed Hack", BlatantContent, function(v) _G.Speed = v end)
CreateToggle("Fly Mode", BlatantContent, function(v) _G.Fly = v end)

-- Keo tha menu (Draggable)
local Dragging, DragInput, DragStart, StartPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true
        DragStart = input.Position
        StartPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local Delta = input.Position - DragStart
        MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
end)

-- Logic thuc thi
RunService.RenderStepped:Connect(function()
    local Char = LocalPlayer.Character
    if Char and Char:FindFirstChild("HumanoidRootPart") then
        local Root = Char.HumanoidRootPart
        if _G.Speed and Char.Humanoid.MoveDirection.Magnitude > 0 then
            Root.CFrame = Root.CFrame + (Char.Humanoid.MoveDirection * _G.SpeedVal)
        end
        if _G.Fly then
            Root.Velocity = Vector3.zero
            Root.CFrame = Root.CFrame + (workspace.CurrentCamera.CFrame.LookVector * 2.5)
        end
    end
end)
