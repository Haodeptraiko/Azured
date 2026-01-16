local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Xóa menu cũ để không bị chồng chéo
if LocalPlayer.PlayerGui:FindFirstChild("Azure_Hitbox_Fix") then
    LocalPlayer.PlayerGui.Azure_Hitbox_Fix:Destroy()
end

local Azure = Instance.new("ScreenGui")
Azure.Name = "Azure_Hitbox_Fix"
Azure.Parent = LocalPlayer:WaitForChild("PlayerGui")
Azure.ResetOnSpawn = false

local _G = {
    HitboxEnabled = false,
    HitboxSize = 2
}

-- Hàm kéo thả cho Menu và Nút
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

-- 1. Nút bật/tắt Menu (Azure: ON)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Parent = Azure
OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
OpenBtn.Position = UDim2.new(0, 10, 0.5, 0)
OpenBtn.Size = UDim2.new(0, 85, 0, 30)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Text = "Azure: ON"
OpenBtn.TextColor3 = Color3.fromRGB(255, 105, 180)
OpenBtn.TextSize = 12
Instance.new("UICorner", OpenBtn)
Instance.new("UIStroke", OpenBtn).Color = Color3.fromRGB(255, 105, 180)
EnableDrag(OpenBtn, OpenBtn)

-- 2. Menu chính
local Main = Instance.new("Frame")
Main.Parent = Azure
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Position = UDim2.new(0.5, -200, 0.5, -130)
Main.Size = UDim2.new(0, 400, 0, 260)
Main.Visible = true
Instance.new("UICorner", Main)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(45, 45, 45)
EnableDrag(Main, Main)

OpenBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
    OpenBtn.Text = Main.Visible and "Azure: ON" or "Azure: OFF"
end)

local Title = Instance.new("TextLabel", Main)
Title.Text = "  Azure | Beta"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.TextColor3 = Color3.fromRGB(255, 105, 180)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", Title)

-- 3. Hệ thống Tab (Căn trái)
local TabBar = Instance.new("Frame", Main)
TabBar.Position = UDim2.new(0, 10, 0, 35)
TabBar.Size = UDim2.new(1, -20, 0, 25)
TabBar.BackgroundTransparency = 1
local TabList = Instance.new("UIListLayout", TabBar)
TabList.FillDirection = Enum.FillDirection.Horizontal
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Left
TabList.Padding = UDim.new(0, 15)

local Container = Instance.new("Frame", Main)
Container.Position = UDim2.new(0, 15, 0, 70)
Container.Size = UDim2.new(1, -30, 1, -80)
Container.BackgroundTransparency = 1

local Pages = {}
local function CreateTab(name)
    local T = Instance.new("TextButton", TabBar)
    T.Size = UDim2.new(0, 45, 1, 0)
    T.BackgroundTransparency = 1
    T.Text = name
    T.TextColor3 = Color3.fromRGB(150, 150, 150)
    T.Font = Enum.Font.Gotham
    T.TextSize = 11
    T.TextXAlignment = Enum.TextXAlignment.Left
    
    local P = Instance.new("ScrollingFrame", Container)
    P.Size = UDim2.new(1, 0, 1, 0)
    P.BackgroundTransparency = 1
    P.Visible = false
    P.ScrollBarTransparency = 1
    Instance.new("UIListLayout", P).Padding = UDim.new(0, 10)
    
    Pages[name] = P
    T.MouseButton1Click:Connect(function()
        for _, page in pairs(Pages) do page.Visible = false end
        for _, btn in pairs(TabBar:GetChildren()) do if btn:IsA("TextButton") then btn.TextColor3 = Color3.fromRGB(150, 150, 150) end end
        P.Visible = true
        T.TextColor3 = Color3.fromRGB(255, 105, 180)
    end)
    return P
end

-- Tạo tab Aimg và nội dung
local AimgPage = CreateTab("Aimg")
CreateTab("Visuals")

-- Cấu trúc Hitbox bên trong tab Aimg
local HitboxSection = Instance.new("TextLabel", AimgPage)
HitboxSection.Text = "Hitbox Settings"
HitboxSection.Size = UDim2.new(1, 0, 0, 20)
HitboxSection.BackgroundTransparency = 1
HitboxSection.TextColor3 = Color3.fromRGB(255, 105, 180)
HitboxSection.Font = Enum.Font.GothamBold
HitboxSection.TextSize = 12
HitboxSection.TextXAlignment = Enum.TextXAlignment.Left

-- Ô Checkbox cho Hitbox
local CheckboxRow = Instance.new("Frame", AimgPage)
CheckboxRow.Size = UDim2.new(1, 0, 0, 25)
CheckboxRow.BackgroundTransparency = 1

local Box = Instance.new("TextButton", CheckboxRow)
Box.Size = UDim2.new(0, 18, 0, 18)
Box.Position = UDim2.new(0, 0, 0, 3)
Box.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Box.Text = ""
Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)
local BoxStroke = Instance.new("UIStroke", Box)
BoxStroke.Color = Color3.fromRGB(70, 70, 70)

local BoxLabel = Instance.new("TextLabel", CheckboxRow)
BoxLabel.Text = "Enable Hitbox"
BoxLabel.Position = UDim2.new(0, 25, 0, 0)
BoxLabel.Size = UDim2.new(1, -25, 1, 0)
BoxLabel.BackgroundTransparency = 1
BoxLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
BoxLabel.Font = Enum.Font.Gotham
BoxLabel.TextSize = 11
BoxLabel.TextXAlignment = Enum.TextXAlignment.Left

Box.MouseButton1Click:Connect(function()
    _G.HitboxEnabled = not _G.HitboxEnabled
    if _G.HitboxEnabled then
        Box.BackgroundColor3 = Color3.fromRGB(255, 105, 180) -- Màu hồng khi bật
        BoxStroke.Color = Color3.fromRGB(255, 255, 255)
    else
        Box.BackgroundColor3 = Color3.fromRGB(35, 35, 35) -- Màu tối khi tắt
        BoxStroke.Color = Color3.fromRGB(70, 70, 70)
    end
end)

-- Thanh Slider chỉnh Size Hitbox
local SliderTitle = Instance.new("TextLabel", AimgPage)
SliderTitle.Text = "Hitbox Size: 2"
SliderTitle.Size = UDim2.new(1, 0, 0, 15)
SliderTitle.BackgroundTransparency = 1
SliderTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
SliderTitle.Font = Enum.Font.Gotham
SliderTitle.TextSize = 10
SliderTitle.TextXAlignment = Enum.TextXAlignment.Left

local SliderBg = Instance.new("Frame", AimgPage)
SliderBg.Size = UDim2.new(0.9, 0, 0, 8)
SliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Instance.new("UICorner", SliderBg)

local SliderFill = Instance.new("Frame", SliderBg)
SliderFill.Size = UDim2.new(0.1, 0, 1, 0) -- Mặc định size nhỏ
SliderFill.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
Instance.new("UICorner", SliderFill)

-- Chức năng kéo Slider
local function UpdateSlider(input)
    local pos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
    local value = math.floor(pos * 50) -- Giới hạn size từ 0 - 50
    _G.HitboxSize = value
    SliderTitle.Text = "Hitbox Size: " .. tostring(value)
end

SliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        UpdateSlider(input)
        local move = UserInputService.InputChanged:Connect(function(m)
            if m.UserInputType == Enum.UserInputType.MouseMovement or m.UserInputType == Enum.UserInputType.Touch then UpdateSlider(m) end
        end)
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then move:Disconnect() end end)
    end
end)

Pages["Aimg"].Visible = true

-- Logic thực thi Hitbox trong Game
RunService.RenderStepped:Connect(function()
    if _G.HitboxEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                hrp.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
                hrp.Transparency = 0.8
                hrp.CanCollide = false
            end
        end
    end
end)
