local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Xoa menu cu neu co
if LocalPlayer.PlayerGui:FindFirstChild("AzureUI_Pure") then
    LocalPlayer.PlayerGui.AzureUI_Pure:Destroy()
end

local Azure = Instance.new("ScreenGui")
Azure.Name = "AzureUI_Pure"
Azure.Parent = LocalPlayer:WaitForChild("PlayerGui")
Azure.ResetOnSpawn = false

-- Khung Main giong anh
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = Azure
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.5, -230, 0.5, -160)
Main.Size = UDim2.new(0, 460, 0, 320)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(45, 45, 45)

-- Title Bar
local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.Text = "  Azure | Beta"
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.TextColor3 = Color3.fromRGB(220, 220, 220)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Tab Bar (Top)
local TabBar = Instance.new("Frame")
TabBar.Parent = Main
TabBar.Position = UDim2.new(0, 0, 0, 25)
TabBar.Size = UDim2.new(1, 0, 0, 25)
TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

local TabList = Instance.new("UIListLayout", TabBar)
TabList.FillDirection = Enum.FillDirection.Horizontal
TabList.Padding = UDim.new(0, 10)

local function AddTab(name)
    local T = Instance.new("TextButton")
    T.Parent = TabBar
    T.Size = UDim2.new(0, 60, 1, 0)
    T.BackgroundTransparency = 1
    T.Text = name
    T.TextColor3 = Color3.fromRGB(150, 150, 150)
    T.Font = Enum.Font.Gotham
    T.TextSize = 11
end

AddTab("  Aiming")
AddTab("Blatant")
AddTab("Visuals")
AddTab("Misc")
AddTab("Settings")

-- Keybinds Menu (Cái bảng nhỏ bên trái trong ảnh)
local Keybinds = Instance.new("Frame")
Keybinds.Parent = Azure
Keybinds.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Keybinds.Position = UDim2.new(0, 50, 0.5, -50)
Keybinds.Size = UDim2.new(0, 150, 0, 140)
Instance.new("UIStroke", Keybinds).Color = Color3.fromRGB(255, 105, 180)

local KTitle = Instance.new("TextLabel", Keybinds)
KTitle.Text = "Keybinds"
KTitle.Size = UDim2.new(1, 0, 0, 20)
KTitle.TextColor3 = Color3.fromRGB(255, 105, 180)
KTitle.BackgroundTransparency = 1
KTitle.Font = Enum.Font.GothamBold

local KList = Instance.new("TextLabel", Keybinds)
KList.Text = "[None] Aimbot\n[Q] Target Aim\n[None] Speed\n[None] Fly"
KList.Position = UDim2.new(0, 5, 0, 25)
KList.Size = UDim2.new(1, -10, 1, -30)
KList.TextColor3 = Color3.fromRGB(180, 180, 180)
KList.Font = Enum.Font.Gotham
KList.TextSize = 10
KList.TextYAlignment = Enum.TextYAlignment.Top
KList.TextXAlignment = Enum.TextXAlignment.Left

-- Noi dung chinh (2 cot)
local Container = Instance.new("Frame", Main)
Container.Position = UDim2.new(0, 10, 0, 60)
Container.Size = UDim2.new(1, -20, 1, -70)
Container.BackgroundTransparency = 1

local function CreateSection(name, pos)
    local S = Instance.new("Frame", Container)
    S.Position = pos
    S.Size = UDim2.new(0.48, 0, 1, 0)
    S.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    Instance.new("UIStroke", S).Color = Color3.fromRGB(40, 40, 40)
    
    local L = Instance.new("TextLabel", S)
    L.Text = "  " .. name
    L.Size = UDim2.new(1, 0, 0, 20)
    L.TextColor3 = Color3.fromRGB(255, 105, 180)
    L.BackgroundTransparency = 1
    L.Font = Enum.Font.GothamBold
    L.TextSize = 10
    L.TextXAlignment = Enum.TextXAlignment.Left
    return S
end

local Left = CreateSection("Aimbot", UDim2.new(0, 0, 0, 0))
local Right = CreateSection("Target Aim", UDim2.new(0.52, 0, 0, 0))

-- Pink Slider (Thanh truot mau hong y chan anh)
local function AddPinkSlider(parent, name, y)
    local Label = Instance.new("TextLabel", parent)
    Label.Text = "  " .. name
    Label.Position = UDim2.new(0, 0, 0, y)
    Label.Size = UDim2.new(1, 0, 0, 15)
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 9
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Bg = Instance.new("Frame", parent)
    Bg.Position = UDim2.new(0.05, 0, 0, y + 15)
    Bg.Size = UDim2.new(0.9, 0, 0, 10)
    Bg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    
    local Fill = Instance.new("Frame", Bg)
    Fill.Size = UDim2.new(0.7, 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(255, 105, 180) -- Pink
end

AddPinkSlider(Left, "Aimbot FOV", 30)
AddPinkSlider(Right, "Target FOV", 30)

-- Dragging (Keo tha menu)
local dStart, sPos
Main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dStart = i.Position sPos = Main.Position end end)
UserInputService.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement and dStart then local delta = i.Position - dStart Main.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y) end end)
