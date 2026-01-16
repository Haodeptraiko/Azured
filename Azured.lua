local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Xoa UI cu
if LocalPlayer.PlayerGui:FindFirstChild("Azure_Premium") then
    LocalPlayer.PlayerGui.Azure_Premium:Destroy()
end

local Screen = Instance.new("ScreenGui")
Screen.Name = "Azure_Premium"
Screen.Parent = LocalPlayer:WaitForChild("PlayerGui")
Screen.ResetOnSpawn = false

-- Color Palette
local Pink = Color3.fromRGB(255, 105, 180)
local Dark = Color3.fromRGB(15, 15, 15)
local Gray = Color3.fromRGB(30, 30, 30)

-- Nut mo menu (Floating Button)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 20, 0.5, -25)
OpenBtn.BackgroundColor3 = Dark
OpenBtn.Text = "A"
OpenBtn.TextColor3 = Pink
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 20
OpenBtn.Parent = Screen
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
local BtnStroke = Instance.new("UIStroke", OpenBtn)
BtnStroke.Color = Pink
BtnStroke.Thickness = 2

-- Ham keo tha
local function Drag(obj)
    local dragging, input, start, pos
    obj.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true start = i.Position pos = obj.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - start
            obj.Position = UDim2.new(pos.X.Scale, pos.X.Offset + delta.X, pos.Y.Scale, pos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
end
Drag(OpenBtn)

-- Main Menu
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 450, 0, 300)
Main.Position = UDim2.new(0.5, -225, 0.5, -150)
Main.BackgroundColor3 = Dark
Main.Parent = Screen
Main.Visible = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(50, 50, 50)
Drag(Main)

OpenBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- Sidebar (Thanh ben trai)
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 120, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Sidebar)
Title.Text = "AZURE"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.TextColor3 = Pink
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.BackgroundTransparency = 1

-- Page Container
local Container = Instance.new("Frame", Main)
Container.Position = UDim2.new(0, 130, 0, 10)
Container.Size = UDim2.new(1, -140, 1, -20)
Container.BackgroundTransparency = 1

local Pages = {}
local TabHolder = Instance.new("Frame", Sidebar)
TabHolder.Position = UDim2.new(0, 0, 0, 50)
TabHolder.Size = UDim2.new(1, 0, 1, -50)
TabHolder.BackgroundTransparency = 1
local TabList = Instance.new("UIListLayout", TabHolder)
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabList.Padding = UDim.new(0, 5)

local function NewTab(name)
    local Btn = Instance.new("TextButton", TabHolder)
    Btn.Size = UDim2.new(0.8, 0, 0, 30)
    Btn.BackgroundColor3 = Gray
    Btn.Text = name
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 12
    Instance.new("UICorner", Btn)

    local Page = Instance.new("ScrollingFrame", Container)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarTransparency = 1
    Instance.new("UIListLayout", Page).Padding = UDim.new(0, 10)

    Pages[name] = Page
    Btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        Page.Visible = true
        for _, b in pairs(TabHolder:GetChildren()) do if b:IsA("TextButton") then b.BackgroundColor3 = Gray end end
        Btn.BackgroundColor3 = Pink
        Btn.TextColor3 = Color3.fromRGB(255,255,255)
    end)
    return Page
end

-- Tao Tab va Chuc nang
local AimPage = NewTab("Aiming")
local VisPage = NewTab("Visuals")

-- Custom Hitbox Toggle (Checkbox style)
local function NewToggle(parent, text, callback)
    local F = Instance.new("Frame", parent)
    F.Size = UDim2.new(1, 0, 0, 35)
    F.BackgroundTransparency = 1
    
    local B = Instance.new("TextButton", F)
    B.Size = UDim2.new(0, 20, 0, 20)
    B.Position = UDim2.new(0, 5, 0.5, -10)
    B.BackgroundColor3 = Gray
    B.Text = ""
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 4)
    
    local L = Instance.new("TextLabel", F)
    L.Text = text
    L.Position = UDim2.new(0, 35, 0, 0)
    L.Size = UDim2.new(1, -35, 1, 0)
    L.TextColor3 = Color3.fromRGB(220, 220, 220)
    L.Font = Enum.Font.Gotham
    L.TextSize = 13
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.BackgroundTransparency = 1

    local active = false
    B.MouseButton1Click:Connect(function()
        active = not active
        B.BackgroundColor3 = active and Pink or Gray
        callback(active)
    end)
end

-- Custom Slider
local function NewSlider(parent, text, min, max, callback)
    local F = Instance.new("Frame", parent)
    F.Size = UDim2.new(1, 0, 0, 45)
    F.BackgroundTransparency = 1

    local L = Instance.new("TextLabel", F)
    L.Text = text .. ": " .. min
    L.Size = UDim2.new(1, 0, 0, 20)
    L.TextColor3 = Color3.fromRGB(180, 180, 180)
    L.Font = Enum.Font.Gotham
    L.TextSize = 11
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.BackgroundTransparency = 1

    local Sbg = Instance.new("Frame", F)
    Sbg.Position = UDim2.new(0, 0, 0, 25)
    Sbg.Size = UDim2.new(0.9, 0, 0, 6)
    Sbg.BackgroundColor3 = Gray
    Instance.new("UICorner", Sbg)

    local Fill = Instance.new("Frame", Sbg)
    Fill.Size = UDim2.new(0, 0, 1, 0)
    Fill.BackgroundColor3 = Pink
    Instance.new("UICorner", Fill)

    local function Update(i)
        local p = math.clamp((i.Position.X - Sbg.AbsolutePosition.X) / Sbg.AbsoluteSize.X, 0, 1)
        Fill.Size = UDim2.new(p, 0, 1, 0)
        local val = math.floor(min + (max - min) * p)
        L.Text = text .. ": " .. val
        callback(val)
    end
    Sbg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then Update(i) end end)
end

-- Khoi tao Tab (Dam bao ten bien la AimgPage de khong bi loi)
local AimgPage = NewTab("Aimg")

-- Bat tat Hitbox (Dung bien AimgPage o day)
AddToggle(AimgPage, "Enable Hitbox", function(v) 
    _G.HitboxEnabled = v 
end)

-- Chinh kich thuoc Hitbox
AddSlider(AimgPage, "Hitbox Size", 2, 50, 2, function(v) 
    _G.HitboxSize = v 
end)


Pages["Aiming"].Visible = true

local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function()
    if _G.HitboxEnabled then
        for _, p in pairs(game:GetService("Players"):GetPlayers()) do
            if p ~= game:GetService("Players").LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                hrp.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
                hrp.Transparency = 0.7
                hrp.BrickColor = BrickColor.new("Bright violet")
                hrp.CanCollide = false
            end
        end
    end
end)
