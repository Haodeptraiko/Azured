local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Qwisaskid/ui-librarys/main/uwuware%20ui%20source.lua"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local MobileGui = Instance.new("ScreenGui")
local ToggleBtn = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

MobileGui.Name = "MobileGui"
MobileGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
MobileGui.ResetOnSpawn = false

ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Parent = MobileGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
ToggleBtn.Size = UDim2.new(0, 60, 0, 60)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.Text = "AZURED"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
ToggleBtn.TextSize = 14
ToggleBtn.Active = true
ToggleBtn.Draggable = true

UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = ToggleBtn

ToggleBtn.MouseButton1Click:Connect(function()
    if library then
        library:Close()
    end
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

local LegitTab = library:AddTab("Mobile Legit"); 
local LegitColunm1 = LegitTab:AddColumn();
local LegitMain = LegitColunm1:AddSection("Aim Assist")
LegitMain:AddToggle{text = "Silent Aim", flag = "SilentAimEnabled"}
LegitMain:AddSlider{text = "Silent FOV", flag = "SilentAimFOV", min = 0, max = 500, value = 150}
LegitMain:AddList({text = "Target Part", flag = "SilentAimHitbox", value = "Torso", values = {"Head", "Torso"}});

local LegitSecond = LegitColunm1:AddSection("Hitbox")
LegitSecond:AddToggle{text = "Extend Hitbox", flag = "HitboxEnabled"}
LegitSecond:AddSlider{text = "Size", flag = "ExtendRate", min = 0, max = 20, value = 10}

local VisualsTab = library:AddTab("Visuals"); 
local VisualsColunm = VisualsTab:AddColumn();
local VisualsMain = VisualsColunm:AddSection("Camera")
VisualsMain:AddToggle{text = "Custom FOV", flag = "ChangeCameraFOV"}
VisualsMain:AddSlider{text = "FOV Value", flag = "CameraFOV", min = 70, max = 120, value = 100}

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
