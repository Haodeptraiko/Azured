local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

if LocalPlayer.PlayerGui:FindFirstChild("Azure_Checkbox_UI") then
    LocalPlayer.PlayerGui.Azure_Checkbox_UI:Destroy()
end

local Azure = Instance.new("ScreenGui")
Azure.Name = "Azure_Checkbox_UI"
Azure.Parent = LocalPlayer:WaitForChild("PlayerGui")
Azure.ResetOnSpawn = false

local _G = {
    HitboxEnabled = false,
    HitboxSize = 2
}

-- HAM KEO THA
local function EnableDrag(guiObject, parent)
    local dragging, dragInput, dragStart, startPos
    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = parent.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    guiObject.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            parent.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- NUT MO MENU
local OpenBtn = Instance.new("TextButton")
OpenBtn.Parent = Azure
OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
OpenBtn.Position = UDim2.new(0, 10, 0.5, 0)
OpenBtn.Size = UDim2.new(0, 80, 0, 30)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Text = "Azure: ON"
OpenBtn.TextColor3 = Color3.fromRGB(255, 105, 180)
OpenBtn.TextSize = 12
Instance.new("UICorner", OpenBtn)
Instance.new("UIStroke", OpenBtn).Color = Color3.fromRGB(255, 105, 180)
EnableDrag(OpenBtn, OpenBtn)

-- MENU CHINH
local Main = Instance.new("Frame")
Main.Parent = Azure
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Position = UDim2.new(0.5, -200, 0.5, -130)
Main.Size = UDim2.new(0, 400, 0, 260)
Instance.new("UICorner", Main)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(45, 45, 45)
EnableDrag(Main, Main)

OpenBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
    OpenBtn.Text = Main.Visible and "Azure: ON" or "Azure: OFF"
end)

-- Title
local Title = Instance.new("TextLabel", Main)
Title.Text = "  Azure | Beta"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.TextColor3 = Color3.fromRGB(255, 105, 180)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", Title)

-- TAB BAR
local TabBar = Instance.new("Frame", Main)
TabBar.Position = UDim2.new(0, 10, 0, 35)
TabBar.Size = UDim2.new(1, -20, 0, 25)
TabBar.BackgroundTransparency = 1
local TabList = Instance.new("UIListLayout", TabBar)
TabList.FillDirection = Enum.FillDirection.Horizontal
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Left
TabList.Padding = UDim.new(0, 15)

local Container = Instance.new("Frame", Main)
Container.Position = UDim2.new(0, 10, 0, 65)
Container.Size = UDim2.new(1, -20, 1, -75)
Container.BackgroundTransparency = 1

local Pages = {}
local function CreateTab(name)
    local T = Instance.new("TextButton", TabBar)
    T.Size = UDim2.new(0, 50, 1, 0)
    T.BackgroundTransparency = 1
    T.Text = name
    T.TextColor3 = Color3.fromRGB(150, 150, 150)
    T.Font = Enum.Font.Gotham
    T.TextSize = 11
    
    local P = Instance.new("ScrollingFrame", Container)
    P.Size = UDim2.new(1, 0, 1, 0)
    P.BackgroundTransparency = 1
    P.Visible = false
    P.ScrollBarTransparency = 1
    Instance.new("UIListLayout", P).Padding = UDim.new(0, 12)
    
    Pages[name] = P
    T.MouseButton1Click:Connect(function()
        for _, page in pairs(Pages) do page.Visible = false end
        for _, btn in pairs(TabBar:GetChildren()) do if btn:IsA("TextButton") then btn.TextColor3 = Color3.fromRGB(150, 150, 150) end end
        P.Visible = true
        T.TextColor3 = Color3.fromRGB(255, 105, 180)
    end)
    return P
end

local AimgPage = CreateTab("Aimg")
CreateTab("Blatant")
CreateTab("Visuals")

-- SECTION HITBOX
local HitboxLabel = Instance.new("TextLabel", AimgPage)
HitboxLabel.Text = "Hitbox Settings"
HitboxLabel.Size = UDim2.new(1, 0, 0, 20)
HitboxLabel.BackgroundTransparency = 1
HitboxLabel.TextColor3 = Color3.fromRGB(255, 105, 180)
HitboxLabel.Font = Enum.Font.GothamBold
HitboxLabel.TextSize = 12
HitboxLabel.TextXAlignment = Enum.TextXAlignment.Left

-- O CHECKBOX KHI CLICK HIEN MAU HONG
local CheckboxFrame = Instance.new("Frame", AimgPage)
CheckboxFrame.Size = UDim2.new(1, 0, 0, 25)
CheckboxFrame.BackgroundTransparency = 1

local Box = Instance.new("TextButton", CheckboxFrame)
Box.Size = UDim2.new(0, 18, 0, 18)
Box.Position = UDim2.new(0, 5, 0, 3)
Box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Box.Text = ""
Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 3)
local BoxStroke = Instance.new("UIStroke", Box)
BoxStroke.Color = Color3.fromRGB(60, 60, 60)

local BoxLabel = Instance.new("TextLabel", CheckboxFrame)
BoxLabel.Text = "Enable Hitbox"
BoxLabel.Position = UDim2.new(0, 30, 0, 0)
BoxLabel.Size = UDim2.new(1, -30, 1, 0)
BoxLabel.BackgroundTransparency = 1
BoxLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
BoxLabel.Font = Enum.Font.Gotham
BoxLabel.TextSize = 11
BoxLabel.TextXAlignment = Enum.TextXAlignment.Left

Box.MouseButton1Click:Connect(function()
    _G.HitboxEnabled = not _G.HitboxEnabled
    if _G.HitboxEnabled then
        Box.BackgroundColor3 = Color3.fromRGB(255, 105, 180) -- Bien thanh mau hong
        BoxStroke.Color = Color3.fromRGB(255, 255, 255)
    else
        Box.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Ve mau toi
        BoxStroke.Color = Color3.fromRGB(60, 60, 60)
    end
end)

Pages["Aimg"].Visible = true
