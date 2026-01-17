local repo = "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

Library.ScreenGui.IgnoreGuiInset = true

local Window = Library:CreateWindow({
    Title = "                     $ Seizure.gg | Mobile Fix                   ",
    Center = true,
    AutoShow = true,
    TabPadding = 4,
    MenuFadeTime = 0.2
})

Window.Holder.Size = UDim2.new(0, 450, 0, 300)

local Tabs = {
    Main = Window:AddTab("Main"),
    Character = Window:AddTab("Character"),
    Visuals = Window:AddTab("Visuals"),
    Misc = Window:AddTab("Misc"),
    Players = Window:AddTab("Players"),
    ["UI Settings"] = Window:AddTab("UI Settings")
}

local LocalPlayer = game:GetService("Players").LocalPlayer
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local lockedTarget = nil
local StickyAimEnabled = false
local ViewTargetEnabled = false
local targetHitPart = "Head"
local strafeEnabled = false
local maddieplsnomad = false

local MobileGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local OpenBtn = Instance.new("TextButton", MobileGui)
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
local Stroke = Instance.new("UIStroke", OpenBtn)

OpenBtn.Name = "SeizureToggle"
OpenBtn.Size = UDim2.new(0, 45, 0, 45)
OpenBtn.Position = UDim2.new(0.1, 0, 0.15, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
OpenBtn.Text = "K"
OpenBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 20
OpenBtn.ZIndex = 1000
Stroke.Thickness = 2
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

local TargetingGroup = Tabs.Main:AddLeftGroupbox("Targeting")

TargetingGroup:AddToggle("StickyAim", {
    Text = "Sticky Aim",
    Default = false,
    Callback = function(Value)
        StickyAimEnabled = Value
        if not Value then 
            lockedTarget = nil 
            workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
        end
    end
})

TargetingGroup:AddDropdown("HitPart", {
    Text = "Hit Part",
    Values = {"Head", "HumanoidRootPart", "UpperTorso", "Left Arm", "Right Arm"},
    Default = "Head",
    Callback = function(Value)
        targetHitPart = Value
    end
})

local TargetControl = Tabs.Main:AddLeftGroupbox("Target Control")

TargetControl:AddToggle("SpectateToggle", {
    Text = "Enable Spectate",
    Default = false,
    Callback = function(Value)
        maddieplsnomad = Value
        if not Value then 
            workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
        end
    end
})

TargetControl:AddToggle("StrafeToggle", {
    Text = "Target Strafe",
    Default = false,
    Callback = function(Value)
        strafeEnabled = Value
    end
})

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")
MenuGroup:AddButton("Unload", function() Library:Unload() MobileGui:Destroy() end)
MenuGroup:AddLabel("Menu Bind"):AddKeyPicker("MenuKeybind", { Default = "LeftAlt", NoUI = true, Text = "Menu keybind" })

Library:Notify("Script da fix loi hien thi to tren Mobile!")
