local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local AzureGui = Instance.new("ScreenGui")
AzureGui.Name = "AzureBetaFixed"
AzureGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
AzureGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Parent = AzureGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
MainFrame.Size = UDim2.new(0, 400, 0, 250)
Instance.new("UICorner", MainFrame)

local SideBar = Instance.new("Frame")
SideBar.Parent = MainFrame
SideBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
SideBar.Size = UDim2.new(0, 100, 1, 0)
Instance.new("UICorner", SideBar)

local Title = Instance.new("TextLabel")
Title.Parent = SideBar
Title.Text = "Azure | Beta"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 105, 180)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12

local TabContainer = Instance.new("Frame")
TabContainer.Parent = SideBar
TabContainer.Position = UDim2.new(0, 0, 0, 40)
TabContainer.Size = UDim2.new(1, 0, 1, -40)
TabContainer.BackgroundTransparency = 1
local TabList = Instance.new("UIListLayout", TabContainer)
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabList.Padding = UDim.new(0, 5)

local PageContainer = Instance.new("Frame")
PageContainer.Parent = MainFrame
PageContainer.Position = UDim2.new(0, 110, 0, 10)
PageContainer.Size = UDim2.new(1, -120, 1, -20)
PageContainer.BackgroundTransparency = 1

local Pages = {}
local _G = {Speed = false, Fly = false, SpeedValue = 1.5}

local function CreatePage(name)
    local Page = Instance.new("ScrollingFrame")
    Page.Parent = PageContainer
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarTransparency = 1
    local PageList = Instance.new("UIListLayout", Page)
    PageList.Padding = UDim.new(0, 5)
    
    local TabBtn = Instance.new("TextButton")
    TabBtn.Parent = TabContainer
    TabBtn.Size = UDim2.new(0, 80, 0, 25)
    TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.Font = Enum.Font.Gotham
    TabBtn.TextSize = 10
    Instance.new("UICorner", TabBtn)
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        Page.Visible = true
    end)
    
    Pages[name] = Page
    return Page
end

local function CreateToggle(name, parent, callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = parent
    Btn.Size = UDim2.new(1, 0, 0, 30)
    Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Btn.Text = "  " .. name
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 11
    Instance.new("UICorner", Btn)
    
    local Status = Instance.new("Frame")
    Status.Parent = Btn
    Status.Position = UDim2.new(1, -25, 0.5, -7)
    Status.Size = UDim2.new(0, 15, 0, 15)
    Status.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Instance.new("UICorner", Status)
    
    local toggled = false
    Btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        Status.BackgroundColor3 = toggled and Color3.fromRGB(255, 105, 180) or Color3.fromRGB(50, 50, 50)
        callback(toggled)
    end)
end

-- Tao trang va nut
local AimPage = CreatePage("Aiming")
local BlatantPage = CreatePage("Blatant")
local VisualsPage = CreatePage("Visuals")

CreateToggle("Aimbot Enable", AimPage, function(v) end)
CreateToggle("Speed Hack", BlatantPage, function(v) _G.Speed = v end)
CreateToggle("Fly Mode", BlatantPage, function(v) _G.Fly = v end)
CreateToggle("ESP Name", VisualsPage, function(v) end)

Pages["Aiming"].Visible = true

-- Logic di chuyen
RunService.RenderStepped:Connect(function()
    local Char = LocalPlayer.Character
    if Char and Char:FindFirstChild("HumanoidRootPart") then
        local Root = Char.HumanoidRootPart
        if _G.Speed and Char.Humanoid.MoveDirection.Magnitude > 0 then
            Root.CFrame = Root.CFrame + (Char.Humanoid.MoveDirection * _G.SpeedValue)
        end
        if _G.Fly then
            Root.Velocity = Vector3.zero
            Root.CFrame = Root.CFrame + (workspace.CurrentCamera.CFrame.LookVector * 2.5)
        end
    end
end)
