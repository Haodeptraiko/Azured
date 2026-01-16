local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Azure | Beta",
   LoadingTitle = "Azure Hub Loading...",
   LoadingSubtitle = "by Haodeptraiko",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "AzureConfig",
      FileName = "MainGui"
   }
})

-- Tab Aiming (Aimbot)
local AimTab = Window:CreateTab("Aiming", 4483362458) -- Icon ID
local AimSection = AimTab:CreateSection("Aimbot Settings")

local AimbotEnabled = false
AimTab:CreateToggle({
   Name = "Enable Aimbot",
   CurrentValue = false,
   Flag = "AimbotToggle",
   Callback = function(Value)
      AimbotEnabled = Value
   end,
})

AimTab:CreateSlider({
   Name = "Aimbot FOV",
   Range = {0, 500},
   Increment = 10,
   Suffix = "Radius",
   CurrentValue = 150,
   Flag = "FOVSlider",
   Callback = function(Value)
      -- FOVCircle.Radius = Value (Ket noi voi code FOV cua ban)
   end,
})

-- Tab Blatant (Speed, Fly)
local BlatantTab = Window:CreateTab("Blatant", 4483362458)
local MovementSection = BlatantTab:CreateSection("Movement")

BlatantTab:CreateToggle({
   Name = "Fly Mode",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
      -- FlyOn = Value (Ket noi voi logic Fly)
   end,
})

BlatantTab:CreateSlider({
   Name = "Speed Multiplier",
   Range = {1, 10},
   Increment = 0.5,
   Suffix = "x",
   CurrentValue = 1.5,
   Flag = "SpeedSlider",
   Callback = function(Value)
      -- SpeedMultiplier = Value
   end,
})

-- Tab Visuals (ESP)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
VisualsTab:CreateToggle({
   Name = "ESP Name",
   CurrentValue = false,
   Flag = "EspToggle",
   Callback = function(Value)
      -- EspOn = Value
   end,
})

Rayfield:LoadConfiguration()
