local repo = "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

Library.ScreenGui.IgnoreGuiInset = true

local Window = Library:CreateWindow({ 
    Title = "$ Seizure.gg | Mobile Fix Tab", 
    Center = true, 
    AutoShow = true, 
    TabPadding = 1, 
    MenuFadeTime = 0.2 
})

local Tabs = { 
    Main = Window:AddTab("Main"), 
    Visuals = Window:AddTab("Visuals"), 
    Misc = Window:AddTab("Misc"), 
    ["UI Settings"] = Window:AddTab("UI Settings") 
}

getgenv().ESP = { Enabled = false, Color = Color3.fromRGB(255, 255, 255), Rainbow = false, Boxes = false, Names = false, Tracers = false, Objects = setmetatable({}, {__mode = "kv"}) }
getgenv().hbar = { enabled = false, barThickness = 3, greenThickness = 1.5, barColor = Color3.fromRGB(0, 0, 0), greenColor = Color3.fromRGB(0, 255, 0) }
getgenv().pname = { Color = Color3.fromRGB(255, 255, 255), Enabled = false, Position = "Above", Size = 10 }
getgenv().ptool = { Color = Color3.fromRGB(255, 255, 255), Enabled = false, Position = "Above", Size = 10 }
getgenv().viewtracer = { Enabled = false, Color = Color3.fromRGB(255, 203, 138), Thickness = 1, Transparency = 1, AutoThickness = true, Length = 15, Smoothness = 0.2 }

local LocalPlayer = game:GetService("Players").LocalPlayer
local Camera = workspace.CurrentCamera
local VT = getgenv().viewtracer

local function CreateGlobalVisuals(plr)
    local lineVT = Drawing.new("Line")
    lineVT.Visible = false
    
    local lineHBBg = Drawing.new("Line")
    lineHBBg.Visible = false
    
    local lineHBMain = Drawing.new("Line")
    lineHBMain.Visible = false

    game:GetService("RunService").RenderStepped:Connect(function()
        if not plr or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character.Humanoid.Health <= 0 then
            lineVT.Visible = false
            lineHBBg.Visible = false
            lineHBMain.Visible = false
            return
        end

        local char = plr.Character
        local root = char.HumanoidRootPart
        local head = char:FindFirstChild("Head")
        if not head then return end

        local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        local headPos = Camera:WorldToViewportPoint(head.Position)

        if onScreen then
            if VT.Enabled then
                local offsetCFrame = CFrame.new(0, 0, -VT.Length)
                local targetWorldPos = head.CFrame:ToWorldSpace(offsetCFrame).Position
                local targetScreenPos, targetVis = Camera:WorldToViewportPoint(targetWorldPos)
                if targetVis then
                    lineVT.From = Vector2.new(headPos.X, headPos.Y)
                    lineVT.To = Vector2.new(targetScreenPos.X, targetScreenPos.Y)
                    lineVT.Color = VT.Color
                    lineVT.Thickness = VT.AutoThickness and math.clamp(1/(LocalPlayer.Character.HumanoidRootPart.Position - head.Position).magnitude*100, 0.1, 3) or VT.Thickness
                    lineVT.Visible = true
                else lineVT.Visible = false end
            else lineVT.Visible = false end

            if getgenv().hbar.enabled then
                local distY = math.clamp((Vector2.new(headPos.X, headPos.Y) - Vector2.new(rootPos.X, rootPos.Y)).magnitude, 2, math.huge)
                local hRatio = char.Humanoid.Health / char.Humanoid.MaxHealth
                lineHBBg.Visible = true
                lineHBBg.From = Vector2.new(rootPos.X - distY - 4, rootPos.Y + distY*2)
                lineHBBg.To = Vector2.new(rootPos.X - distY - 4, rootPos.Y - distY*2)
                lineHBBg.Color = getgenv().hbar.barColor
                lineHBBg.Thickness = getgenv().hbar.barThickness

                lineHBMain.Visible = true
                lineHBMain.From = Vector2.new(rootPos.X - distY - 4, rootPos.Y + distY*2)
                lineHBMain.To = Vector2.new(rootPos.X - distY - 4, rootPos.Y + distY*2 - (hRatio * (distY*4)))
                lineHBMain.Color = Color3.fromRGB(255, 0, 0):lerp(getgenv().hbar.greenColor, hRatio)
                lineHBMain.Thickness = getgenv().hbar.greenThickness
            else lineHBBg.Visible = false lineHBMain.Visible = false end
        else
            lineVT.Visible = false
            lineHBBg.Visible = false
            lineHBMain.Visible = false
        end
    end)
end

for _, p in next, game:GetService("Players"):GetPlayers() do if p ~= LocalPlayer then CreateGlobalVisuals(p) end end
game:GetService("Players").PlayerAdded:Connect(function(p) CreateGlobalVisuals(p) end)

local MainBox = Tabs.Main:AddLeftGroupbox("Targeting")
MainBox:AddToggle("StickyAim", { Text = "Sticky Aim", Default = false })

local VisualBox = Tabs.Visuals:AddLeftGroupbox("ESP Settings")
VisualBox:AddToggle("HBarToggle", {Text = "Health Bar", Default = false, Callback = function(v) getgenv().hbar.enabled = v end})
VisualBox:AddToggle("VTToggle", {Text = "View Tracer", Default = false, Callback = function(v) VT.Enabled = v end})

local BillboardBox = Tabs.Visuals:AddRightGroupbox("Billboards")
BillboardBox:AddToggle("PNameToggle", {Text = "Show Names", Default = false, Callback = function(v) getgenv().pname.Enabled = v end})
BillboardBox:AddToggle("PToolToggle", {Text = "Show Tools", Default = false, Callback = function(v) getgenv().ptool.Enabled = v end})

local MobileGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local OpenBtn = Instance.new("TextButton", MobileGui)
OpenBtn.Size = UDim2.new(0, 45, 0, 45)
OpenBtn.Position = UDim2.new(0.1, 0, 0.15, 0)
OpenBtn.Text = "K"
OpenBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
OpenBtn.ZIndex = 10000
OpenBtn.MouseButton1Click:Connect(function() Library:Toggle() end)

Library:Notify("Fix loi bam tab va ghep code thanh cong!")
