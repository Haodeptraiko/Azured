local repo = "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

Library.ScreenGui.IgnoreGuiInset = true

local Window = Library:CreateWindow({
    Title = "AURA | MOBILE COMPACT",
    Center = true,
    AutoShow = true,
    TabPadding = 2,
    MenuFadeTime = 0.1
})

local MainHolder = Window.Holder
MainHolder.Size = UDim2.new(0.5, 0, 0.5, 0)
MainHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
MainHolder.AnchorPoint = Vector2.new(0.5, 0.5)

local MobileGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local OpenBtn = Instance.new("TextButton", MobileGui)
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
local Stroke = Instance.new("UIStroke", OpenBtn)

OpenBtn.Name = "MobileToggle"
OpenBtn.Size = UDim2.new(0, 40, 0, 40)
OpenBtn.Position = UDim2.new(0.12, 0, 0.12, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
OpenBtn.Text = "K"
OpenBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 16
OpenBtn.ZIndex = 1000
Stroke.Thickness = 1.5
Stroke.Color = Color3.fromRGB(255, 0, 0)

local function MakeMobileDraggable(obj)
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
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local Delta = input.Position - DragStart
            obj.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        end
    end)
end
MakeMobileDraggable(OpenBtn)

OpenBtn.MouseButton1Click:Connect(function()
    Library:Toggle()
end)

local Tabs = {
    Combat = Window:AddTab("Combat"),
    Settings = Window:AddTab("Settings")
}

local MainBox = Tabs.Combat:AddLeftGroupbox("Main")
MainBox:AddToggle("SAim", { Text = "Silent Aim", Default = false, Callback = function(v) getgenv().SA = v end })

local MenuBox = Tabs.Settings:AddLeftGroupbox("Menu")
MenuBox:AddButton("Unload", function() Library:Unload() MobileGui:Destroy() end)

Library:Notify("Menu da duoc thu nho 50% de phu hop Mobile!")
