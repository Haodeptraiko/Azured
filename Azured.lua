local library = loadstring(game:HttpGet('https://garfieldscripts.xyz/ui-libs/janlib.lua'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local MobileGui = Instance.new("ScreenGui")
local ToggleBtn = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")
MobileGui.Name = "JanLibMobile"
MobileGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
MobileGui.ResetOnSpawn = false
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Parent = MobileGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
ToggleBtn.Size = UDim2.new(0, 55, 0, 55)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.Text = "MENU"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 14
ToggleBtn.Active = true
ToggleBtn.Draggable = true
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = ToggleBtn
ToggleBtn.MouseButton1Click:Connect(function()
    library:Close()
end)

local function GetTarget(fov)
    local Target, MinDist = nil, fov
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local Hum = v.Character:FindFirstChild("Humanoid")
            if Hum and Hum.Health > 0 then
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                local Dist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Center).Magnitude
                if Dist < MinDist then MinDist = Dist; Target = v end
            end
        end
    end
    return Target
end

local function GetHitboxPos(p, flag)
    local partName = "UpperTorso"
    if library.flags[flag] == "Head" then partName = "Head" end
    if p.Character:FindFirstChild(partName) then return p.Character[partName].Position end
    return p.Character.HumanoidRootPart.Position
end

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
local oldIndex = mt.__index
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if library.flags["SilentAimEnabled"] and not checkcaller() and method == "FireServer" and self.Name == "MainEvent" then
        if args[1] == "UpdateMousePos" or args[1] == "Shoot" then
            local T = GetTarget(library.flags["SilentAimFOV"])
            if T then
                args[2] = GetHitboxPos(T, "SilentAimHitbox")
                return oldNamecall(self, unpack(args))
            end
        end
    end
    return oldNamecall(self, ...)
end)

mt.__index = newcclosure(function(self, idx)
    if library.flags["SilentAimEnabled"] and self == Mouse and (idx == "Hit" or idx == "Target") and not checkcaller() then
        local T = GetTarget(library.flags["SilentAimFOV"])
        if T then
            local Pos = GetHitboxPos(T, "SilentAimHitbox")
            return (idx == "Hit" and CFrame.new(Pos) or T.Character.HumanoidRootPart)
        end
    end
    return oldIndex(self, idx)
end)
setreadonly(mt, true)

local LegitTab = library:AddTab("Legit"); 
local LegitColunm1 = LegitTab:AddColumn();
local LegitMain = LegitColunm1:AddSection("Aim Assist")
LegitMain:AddToggle{text = "Enabled", flag = "AimbotEnabled"}
LegitMain:AddSlider{text = "Aimbot FOV", flag = "AimbotFov", min = 0, max = 750, value = 105}
LegitMain:AddList({text = "Hit Box", flag = "AimbotHitbox", value = "Head", values = {"Head", "Torso"}});

local LegitSecond = LegitColunm1:AddSection("Extend Hitbox")
LegitSecond:AddToggle{text = "Enabled", flag = "HitboxEnabled"}
LegitSecond:AddSlider{text = "Extend Rate", flag = "ExtendRate", min = 0, max = 15, value = 10}

local LegitColunm2 = LegitTab:AddColumn();
local LegitForth = LegitColunm2:AddSection("Bullet Redirection")
LegitForth:AddToggle{text = "Enabled", flag = "SilentAimEnabled"}
LegitForth:AddSlider{text = "Silent Aim FOV", flag = "SilentAimFOV", min = 0, max = 750, value = 150}
LegitForth:AddList({text = "Hit Box", flag = "SilentAimHitbox", value = "Torso", values = {"Head", "Torso"}});

local VisualsTab = library:AddTab("Visuals"); 
local VisualsColunm2 = VisualsTab:AddColumn();
local VisualsSecond = VisualsColunm2:AddSection("Camera Visuals")
VisualsSecond:AddToggle{text = "Change Camera FOV", flag = "ChangeCameraFOV"}
VisualsSecond:AddSlider{text = "Camera FOV", flag = "CameraFOV", min = 10, max = 120, value = 100}

local SettingsTab = library:AddTab("Settings"); 
local SettingsColumn = SettingsTab:AddColumn(); 
local SettingSection = SettingsColumn:AddSection("Menu"); 
SettingSection:AddBind({text = "Open / Close", flag = "UI Toggle", nomouse = true, key = "End", callback = function() library:Close(); end});

RunService.RenderStepped:Connect(function()
    if library.flags["ChangeCameraFOV"] then
        Camera.FieldOfView = library.flags["CameraFOV"]
    end
    if library.flags["HitboxEnabled"] then
        local size = library.flags["ExtendRate"]
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                v.Character.HumanoidRootPart.Size = Vector3.new(size, size, size)
                v.Character.HumanoidRootPart.Transparency = 0.8
                v.Character.HumanoidRootPart.CanCollide = false
            end
        end
    end
end)

library:Init();
library:selectTab(library.tabs[1]);
