local repo = "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

Library.ScreenGui.IgnoreGuiInset = true

local Window = Library:CreateWindow({
    Title = "Azured",
    Center = true,
    AutoShow = true,
    TabPadding = 4,
    MenuFadeTime = 0.2
})

Library.Minimized = false

local MobileGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local OpenBtn = Instance.new("TextButton", MobileGui)
local Corner = Instance.new("UICorner", OpenBtn)
local Stroke = Instance.new("UIStroke", OpenBtn)

OpenBtn.Name = "MobileToggle"
OpenBtn.Size = UDim2.new(0, 45, 0, 45)
OpenBtn.Position = UDim2.new(0.1, 0, 0.15, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
OpenBtn.Text = "K"
OpenBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 18
OpenBtn.ZIndex = 100

Corner.CornerRadius = UDim.new(1, 0)
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
    Visuals = Window:AddTab("Visuals"),
    Settings = Window:AddTab("Settings")
}

local MainBox = Tabs.Combat:AddLeftGroupbox("Main Features")
MainBox:AddToggle("SAim", { Text = "Silent Aim", Default = false, Callback = function(v) getgenv().SA = v end })

local EspBox = Tabs.Visuals:AddLeftGroupbox("ESP")
EspBox:AddToggle("EName", { Text = "Show Names", Default = false, Callback = function(v) getgenv().EN = v end })

local MenuBox = Tabs.Settings:AddLeftGroupbox("Menu")
MenuBox:AddButton("Close Script", function() 
    Library:Unload() 
    MobileGui:Destroy()
end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
ThemeManager:SetFolder("KenyaiHub")
SaveManager:SetFolder("KenyaiHub/Mobile")
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

Library:Notify("Giao dien da duoc toi uu cho Mobile!")
