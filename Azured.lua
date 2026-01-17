local repo = "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

Library.ScreenGui.IgnoreGuiInset = true

local Window = Library:CreateWindow({ 
    Title = "                     $ Azured.gg |  discord.gg                    ", 
    Center = true,
    AutoShow = true, 
    TabPadding = 2, 
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

getgenv().ESP = { Enabled = false, Color = Color3.fromRGB(255, 255, 255), Rainbow = false, Boxes = false, Names = false, Tracers = false, Objects = setmetatable({}, {__mode = "kv"}) }
getgenv().hbar = { enabled = false, barThickness = 3, greenThickness = 1.5, barColor = Color3.fromRGB(0, 0, 0), greenColor = Color3.fromRGB(0, 255, 0) }
getgenv().pname = { Color = Color3.fromRGB(255, 255, 255), Enabled = false, Position = "Above", Size = 10 }
getgenv().ptool = { Color = Color3.fromRGB(255, 255, 255), Enabled = false, Position = "Above", Size = 10 }
getgenv().viewtracer = { Enabled = false, Color = Color3.fromRGB(255, 203, 138), Thickness = 1, Transparency = 1, AutoThickness = true, Length = 15, Smoothness = 0.2 }

local LocalPlayer = game:GetService("Players").LocalPlayer
local Camera = workspace.CurrentCamera
local VT = getgenv().viewtracer

local function CreateViewTracer(plr)
    local line = Drawing.new("Line")
    line.Visible = false
    line.Transparency = 1
    
    game:GetService("RunService").RenderStepped:Connect(function()
        if VT.Enabled and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character.Humanoid.Health > 0 then
            local head = plr.Character.Head
            local headpos, onScreen = Camera:WorldToViewportPoint(head.Position)
            
            if onScreen then
                local offsetCFrame = CFrame.new(0, 0, -VT.Length)
                local targetWorldPos = head.CFrame:ToWorldSpace(offsetCFrame).Position
                local targetScreenPos, targetVis = Camera:WorldToViewportPoint(targetWorldPos)
                
                if targetVis then
                    line.From = Vector2.new(headpos.X, headpos.Y)
                    line.To = Vector2.new(targetScreenPos.X, targetScreenPos.Y)
                    line.Color = VT.Color
                    
                    if VT.AutoThickness then
                        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - head.Position).magnitude
                        line.Thickness = math.clamp(1/dist*100, 0.1, 3)
                    else
                        line.Thickness = VT.Thickness
                    end
                    
                    line.Visible = true
                else line.Visible = false end
            else line.Visible = false end
        else
            line.Visible = false
            if not plr.Parent then line:Delete() end
        end
    end)
end

for _, p in next, game:GetService("Players"):GetPlayers() do if p ~= LocalPlayer then CreateViewTracer(p) end end
game:GetService("Players").PlayerAdded:Connect(function(p) CreateViewTracer(p) end)

local VisualBox = Tabs.Visuals:AddLeftGroupbox("ESP & Health")
VisualBox:AddToggle("EspMaster", {Text = "Enable ESP Boxes", Default = false, Callback = function(v) getgenv().ESP.Enabled = v getgenv().ESP.Boxes = v end})
VisualBox:AddToggle("HBarToggle", {Text = "Show Health Bar", Default = false, Callback = function(v) getgenv().hbar.enabled = v end})

local TracerBox = Tabs.Visuals:AddLeftGroupbox("View Tracer")
TracerBox:AddToggle("VTToggle", {Text = "Enable View Tracer", Default = false, Callback = function(v) VT.Enabled = v end})
TracerBox:AddSlider("VTLength", {Text = "Tracer Length", Default = 15, Min = 5, Max = 50, Rounding = 0, Callback = function(v) VT.Length = v end})
TracerBox:AddLabel("Tracer Color"):AddColorPicker("VTColor", {Default = VT.Color, Callback = function(v) VT.Color = v end})

local NameBox = Tabs.Visuals:AddRightGroupbox("Billboards")
NameBox:AddToggle("PNameToggle", {Text = "Show Names", Default = false, Callback = function(v) getgenv().pname.Enabled = v end})
NameBox:AddToggle("PToolToggle", {Text = "Show Tools", Default = false, Callback = function(v) getgenv().ptool.Enabled = v end})

local MobileGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local OpenBtn = Instance.new("TextButton", MobileGui)
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
OpenBtn.Size = UDim2.new(0, 45, 0, 45)
OpenBtn.Position = UDim2.new(0.1, 0, 0.15, 0)
OpenBtn.Text = "K"
OpenBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
OpenBtn.ZIndex = 1000
OpenBtn.MouseButton1Click:Connect(function() Library:Toggle() end)

Library:Notify("Azured.gg")
