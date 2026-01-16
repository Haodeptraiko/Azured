local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/zxciaz/VenyxUI/main/Reallibrary.lua"))()
local Venyx = Library.new("Azure | Beta", 5013109572)

-- Mau sac giong trong anh
local Themes = {
    Background = Color3.fromRGB(24, 24, 24),
    Glow = Color3.fromRGB(255, 105, 180),
    Accent = Color3.fromRGB(30, 30, 30),
    LightContrast = Color3.fromRGB(20, 20, 20),
    DarkContrast = Color3.fromRGB(14, 14, 14),
    TextColor = Color3.fromRGB(255, 255, 255)
}

-- Tao cac Tab giong anh
local AimingPage = Venyx:addPage("Aiming", 5012544693)
local BlatantPage = Venyx:addPage("Blatant", 5012544693)
local VisualsPage = Venyx:addPage("Visuals", 5012544693)
local MiscPage = Venyx:addPage("Misc", 5012544693)
local SettingsPage = Venyx:addPage("Settings", 5012544693)

-- Tab Aiming
local AimSection = AimingPage:addSection("Aimbot")
AimSection:addToggle("Enable", false, function(value) print("Aimbot: ", value) end)
AimSection:addTextbox("Prediction", "0.165", function(value, focusLost) end)
AimSection:addToggle("Draw FOV", false, function(value) end)

-- Tab Blatant
local MovementSection = BlatantPage:addSection("Movement")
MovementSection:addToggle("Speed", false, function(value) _G.Speed = value end)
MovementSection:addToggle("Fly", false, function(value) _G.Fly = value end)

-- Tab Visuals
local VisualSection = VisualsPage:addSection("Visuals")
VisualSection:addToggle("ESP Name", false, function(value) end)
VisualSection:addToggle("Tracers", false, function(value) end)

-- Keybind de an/hien menu (Mac dinh la nut Phai Chuot hoac phim bam tu chon)
Venyx:SelectPage(Venyx.pages[1], true)
