--==============================================================
-- REGISTER-SAFE XENON SCRIPT 1
-- AIM + ESP
-- The runtime namespace S keeps the top-level chunk below Luau's
-- 200-local register limit. Each subsystem function has its own scope.
--==============================================================

local S = _G.XenonScript1State or {}
_G.XenonScript1State = S

--==============================================================
-- XENON
-- CONTROLLER CAMERA LOCK + ESP + WHITELIST
-- MOBILE RESPONSIVE EDITION
--==============================================================

--==============================================================
-- SERVICES
--==============================================================

S.Players = game:GetService("S.Players")
S.UserInputService = game:GetService("S.UserInputService")
S.RunService = game:GetService("S.RunService")
S.HttpService = game:GetService("S.HttpService")
S.MarketplaceService = game:GetService("S.MarketplaceService")

S.LocalPlayer = S.Players.LocalPlayer
S.PlayerGui = S.LocalPlayer:WaitForChild("S.PlayerGui")
S.Camera = workspace.CurrentCamera

--==============================================================
-- ADAPTIVE 15-STAGE LOADER
--==============================================================

S.LoaderState = {
    Stage = 0,
    FPS = 0,
    FrameTime = 0,
    Mobile = false,
    Warnings = {},
    Capabilities = {},
}

local LoaderGui
local LoaderStatus
local LoaderProgress
local LoaderPercent
local LoaderPerformance

function S.LoaderWarning(Message)
    table.insert(S.LoaderState.Warnings, tostring(Message))
end

function S.SetLoadingStage(Number, Text)
    S.LoaderState.Stage = Number

    if LoaderStatus then
        LoaderStatus.Text = tostring(Number) .. "/15 — " .. Text
    end

    if LoaderPercent then
        LoaderPercent.Text = tostring(math.floor((Number - 1) / 15 * 100)) .. "%"
    end

    if LoaderProgress then
        LoaderProgress.Size = UDim2.new((Number - 1) / 15, 0, 1, 0)
    end
end

function S.CompleteLoadingStage(Number)
    if LoaderPercent then
        LoaderPercent.Text = tostring(math.floor(Number / 15 * 100)) .. "%"
    end

    if LoaderProgress then
        LoaderProgress.Size = UDim2.new(Number / 15, 0, 1, 0)
    end
end

function S.RunLoadingStage(Number, Text, Work)
    S.SetLoadingStage(Number, Text)

    local Success, Result = pcall(Work)
    if not Success then
        S.LoaderWarning(Text .. " unavailable — using fallback")
        Result = nil
    end

    S.CompleteLoadingStage(Number)
    return Success, Result
end

function S.CreateLoadingScreen()
    local Existing = S.PlayerGui:FindFirstChild("XenonLoader")
    if Existing then
        Existing:Destroy()
    end

    local Gui = Instance.new("ScreenGui")
    Gui.Name = "XenonLoader"
    Gui.IgnoreGuiInset = true
    Gui.ResetOnSpawn = false
    Gui.DisplayOrder = 2000000
    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    Gui.Parent = S.PlayerGui

    local Panel = Instance.new("Frame")
    Panel.AnchorPoint = Vector2.new(0.5, 0.5)
    Panel.Position = UDim2.fromScale(0.5, 0.5)
    Panel.Size = UDim2.fromOffset(300, 150)
    Panel.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    Panel.BorderSizePixel = 0
    Panel.Parent = Gui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 14)
    Corner.Parent = Panel

    local Title = Instance.new("TextLabel")
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.fromOffset(18, 13)
    Title.Size = UDim2.new(1, -36, 0, 28)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "XENON"
    Title.TextColor3 = Color3.fromRGB(245, 245, 245)
    Title.TextSize = 22
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Panel

    local Subtitle = Instance.new("TextLabel")
    Subtitle.BackgroundTransparency = 1
    Subtitle.Position = UDim2.fromOffset(19, 39)
    Subtitle.Size = UDim2.new(1, -38, 0, 16)
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Text = "INITIALIZING"
    Subtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
    Subtitle.TextSize = 9
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.Parent = Panel

    LoaderStatus = Instance.new("TextLabel")
    LoaderStatus.BackgroundTransparency = 1
    LoaderStatus.Position = UDim2.fromOffset(19, 68)
    LoaderStatus.Size = UDim2.new(1, -38, 0, 20)
    LoaderStatus.Font = Enum.Font.GothamMedium
    LoaderStatus.TextColor3 = Color3.fromRGB(245, 245, 245)
    LoaderStatus.TextSize = 11
    LoaderStatus.TextXAlignment = Enum.TextXAlignment.Left
    LoaderStatus.Parent = Panel

    local BarBack = Instance.new("Frame")
    BarBack.Position = UDim2.fromOffset(19, 96)
    BarBack.Size = UDim2.new(1, -38, 0, 6)
    BarBack.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    BarBack.BorderSizePixel = 0
    BarBack.Parent = Panel

    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = BarBack

    LoaderProgress = Instance.new("Frame")
    LoaderProgress.Size = UDim2.new(0, 0, 1, 0)
    LoaderProgress.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
    LoaderProgress.BorderSizePixel = 0
    LoaderProgress.Parent = BarBack

    local ProgressCorner = Instance.new("UICorner")
    ProgressCorner.CornerRadius = UDim.new(1, 0)
    ProgressCorner.Parent = LoaderProgress

    LoaderPercent = Instance.new("TextLabel")
    LoaderPercent.BackgroundTransparency = 1
    LoaderPercent.Position = UDim2.new(1, -55, 0, 111)
    LoaderPercent.Size = UDim2.fromOffset(55, 18)
    LoaderPercent.Font = Enum.Font.Gotham
    LoaderPercent.Text = "0%"
    LoaderPercent.TextColor3 = Color3.fromRGB(150, 150, 150)
    LoaderPercent.TextSize = 9
    LoaderPercent.TextXAlignment = Enum.TextXAlignment.Right
    LoaderPercent.Parent = Panel

    LoaderPerformance = Instance.new("TextLabel")
    LoaderPerformance.BackgroundTransparency = 1
    LoaderPerformance.Position = UDim2.fromOffset(19, 111)
    LoaderPerformance.Size = UDim2.fromOffset(130, 18)
    LoaderPerformance.Font = Enum.Font.Gotham
    LoaderPerformance.Text = "Performance: sampling"
    LoaderPerformance.TextColor3 = Color3.fromRGB(150, 150, 150)
    LoaderPerformance.TextSize = 9
    LoaderPerformance.TextXAlignment = Enum.TextXAlignment.Left
    LoaderPerformance.Parent = Panel

    return Gui
end

LoaderGui = S.CreateLoadingScreen()

S.RunLoadingStage(1, "Detecting environment", function()
    local function Has(Name)
        local Environment

        if type(getgenv) == "function" then
            local Success, Result = pcall(getgenv)
            if Success and type(Result) == "table" then
                Environment = Result
            end
        end

        local Value = (Environment and Environment[Name]) or _G[Name]
        return type(Value) == "function"
    end

    S.LoaderState.Capabilities.Filesystem = Has("isfile")
        and Has("readfile")
        and Has("writefile")
    S.LoaderState.Capabilities.isfile = Has("isfile")
    S.LoaderState.Capabilities.readfile = Has("readfile")
    S.LoaderState.Capabilities.writefile = Has("writefile")
    S.LoaderState.Capabilities.delfile = Has("delfile")
    S.LoaderState.Capabilities.clipboard = Has("setclipboard")
    S.LoaderState.Mobile = workspace.CurrentCamera.ViewportSize.X <= 600
end)

S.RunLoadingStage(2, "Measuring client performance", function()
    local Started = os.clock()
    local Delta = S.RunService.Heartbeat:Wait()
    if not Delta or Delta <= 0 then
        Delta = os.clock() - Started
    end

    S.LoaderState.FrameTime = Delta
    S.LoaderState.FPS = math.clamp(math.floor(1 / math.max(Delta, 0.001) + 0.5), 1, 999)

    if LoaderPerformance then
        LoaderPerformance.Text = "FPS: " .. tostring(S.LoaderState.FPS)
    end
end)

-- DownCheckPath is intentionally only defined for games that actually
-- support the automatic Downed check. Future supported games can leave
-- it nil and use the manual health check instead.

local SupportedGames = {
[13388465281] = {
DownCheckPath = {"Backpack", "Stats", "Downed"},
DownCheckDefault = true,
ManualHealthDefault = false,
ManualHealthDefaultValue = 10,
},
[13083893317] = {
DownCheckPath = {"Backpack", "Stats", "Downed"},
DownCheckDefault = false,
ManualHealthDefault = false,
ManualHealthDefaultValue = 10,
},
}

local CurrentPlaceId = tonumber(game.PlaceId) or 0
local CurrentGameId = tonumber(game.GameId) or 0

-- Normalize the support table so numeric keys AND string keys work.
-- This also accepts either a Roblox PlaceId or Universe/GameId.
local ActiveGameConfig
local ActiveSupportId

for SupportId, GameConfig in pairs(SupportedGames) do
local Id = tonumber(SupportId)

if Id then
    -- Normal entry: [PlaceId] = {...}
    if Id == CurrentPlaceId or Id == CurrentGameId then
        ActiveGameConfig = GameConfig
        ActiveSupportId = Id
        break
    end
end

-- Optional explicit IDs for future entries:
-- { PlaceId = 123, GameId = 456, ... }
if type(GameConfig) == "table" then
    local ConfigPlaceId = tonumber(GameConfig.PlaceId)
    local ConfigGameId = tonumber(GameConfig.GameId)

    if (ConfigPlaceId and ConfigPlaceId == CurrentPlaceId)
        or (ConfigGameId and ConfigGameId == CurrentGameId) then
        ActiveGameConfig = GameConfig
        ActiveSupportId = Id or ConfigPlaceId or ConfigGameId
        break
    end
end

end

if not ActiveGameConfig then
pcall(function()
S.LocalPlayer:Kick("Game Not Supported")
end)
return
end

function S.GetGameInfo(PlaceId)
local Success, Info = pcall(function()
return S.MarketplaceService:GetProductInfo(PlaceId)
end)

if Success and type(Info) == "table" then
    return Info.Name or ("Place " .. tostring(PlaceId))
end

return "Place " .. tostring(PlaceId)

end

local CurrentGameName = S.GetGameInfo(CurrentPlaceId)

S.RunLoadingStage(3, "Validating game", function()
    assert(ActiveGameConfig, "No active game configuration")
end)

--==============================================================
-- SHARED XENON RUNTIME / DUPLICATE EXECUTION
--==============================================================

local Shared = _G.XenonShared or {}
_G.XenonShared = Shared

Shared.Version = 3
Shared.Modules = Shared.Modules or {}
Shared.Cleanup = Shared.Cleanup or {}
Shared.UI = Shared.UI or {}

if Shared.Modules.AimLoaded then
    return
end

if Shared.Modules.RageLoaded or Shared.Modules.WhitelistLoaded then
    return
end

pcall(function()
    S.RunService:UnbindFromRenderStep("XenonCameraLock")
end)

local OldGui = S.PlayerGui:FindFirstChild("Xenon")
if OldGui and not Shared.Gui then
    OldGui:Destroy()
end

S.RunLoadingStage(4, "Cleaning previous instance", function()
    assert(S.PlayerGui, "S.PlayerGui unavailable")
end)

--==============================================================
-- SHARED CONFIG
--==============================================================

local Config = Shared.Config or {
    LockButton = Enum.KeyCode.ButtonY,
    CameraMode = "Third Person",
    AimOffset = 9.5,
    ReferenceDistance = 40,
    ThirdPersonAnchor = 0.65,
    ThirdPersonCalibrationDistance = 40,
    ThirdPersonMinOffset = 0,
    ThirdPersonMaxOffset = 100,
    Smoothing = 3,
    Prediction = 0.02,
    MaxTargetDistance = 500,
    StickyAim = true,
    WallCheck = true,
    DownCheck = ActiveGameConfig.DownCheckDefault == true,
    ManualHealthCheck = ActiveGameConfig.ManualHealthDefault == true,
    HealthThreshold = tonumber(ActiveGameConfig.ManualHealthDefaultValue) or 10,
    ESPEnabled = false,
    ESPShowName = true,
    ESPShowOutline = true,
    ESPWhitelistCheck = false,
    AimbotWhitelistSkip = true,

    HitboxEnabled = false,
    HitboxTransparent = true,
    HitboxWhitelistSkip = true,
    HitboxSize = 10,
    HitboxPart = "Head",
    HitboxFFCheck = true,
    FlyEnabled = false,
    FlySpeed = 60,
    RapidFireEnabled = false,
    RapidFireMethod = "Auto / Best Method",
}

Shared.Config = Config

--==============================================================
-- PER-USER SETTINGS STORAGE
--==============================================================
-- Each Roblox account gets its own settings file. Values are loaded
-- before the UI is created, so the controls open on the saved values.

local SettingsFileName =
"XenonSettings_" .. tostring(S.LocalPlayer.UserId) .. ".json"

function S.SerializeConfig()
local Data = {}

for Key, Value in pairs(Config) do
    if typeof(Value) == "EnumItem" then
        Data[Key] = {
            __type = "EnumItem",
            enum = tostring(Value.EnumType),
            name = Value.Name,
        }
    elseif type(Value) == "number"
        or type(Value) == "boolean"
        or type(Value) == "string" then
        Data[Key] = Value
    end
end

return Data

end

S.RunLoadingStage(5, "Checking settings support", function()
    S.LoaderState.Capabilities.Settings = S.LoaderState.Capabilities.Filesystem == true
end)

function S.SaveSettings()
if not S.LoaderState.Capabilities.writefile then
return
end

pcall(function()
    writefile(
        SettingsFileName,
        S.HttpService:JSONEncode(S.SerializeConfig())
    )
end)

end

function S.LoadSettings()
if type(isfile) ~= "function"
or type(readfile) ~= "function" then
return
end

local Success, Data = pcall(function()
    if not isfile(SettingsFileName) then
        return nil
    end

    return readfile(SettingsFileName)
end)

if not Success or not Data or Data == "" then
    return
end

local DecodeSuccess, Saved = pcall(function()
    return S.HttpService:JSONDecode(Data)
end)

if not DecodeSuccess or type(Saved) ~= "table" then
    return
end

for Key, Value in pairs(Saved) do
    if Config[Key] ~= nil then
        if type(Value) == "table"
            and Value.__type == "EnumItem"
            and Key == "LockButton" then

            local Button = Enum.KeyCode[Value.name]

            if Button then
                Config[Key] = Button
            end

        elseif type(Value) == type(Config[Key]) then
            Config[Key] = Value
        end
    end
end

end

S.RunLoadingStage(6, "Loading saved settings", function()
    S.LoadSettings()
end)

Shared.SaveSettings = S.SaveSettings
Shared.LoadSettings = S.LoadSettings

-- Never carry the automatic Downed mode from another game.
-- Only a supported game that explicitly defines DownCheckPath may use it.
if not ActiveGameConfig.DownCheckPath then
Config.DownCheck = false
end

--==============================================================
-- STATE
--==============================================================

S.RunLoadingStage(8, "Preparing game configuration", function()
    Config.DownCheck = Config.DownCheck and ActiveGameConfig.DownCheckPath ~= nil
    Config.HealthThreshold = math.max(0, tonumber(Config.HealthThreshold) or 10)
end)

local Locked = false
local LockedTarget = nil

local WaitingForButton = false
local MainVisible = true

local Connections = {}

local ESPObjects = {}

Shared.Whitelist = Shared.Whitelist or {}
local Whitelist = Shared.Whitelist

S.RunLoadingStage(9, "Preparing runtime", function()
    assert(type(Connections) == "table", "Runtime state unavailable")
    assert(type(ESPObjects) == "table", "ESP state unavailable")
    assert(type(Whitelist) == "table", "Shared whitelist unavailable")
end)

Shared.Modules.Aim = Shared.Modules.Aim or {}

function S.IsWhitelisted(Player)
    if not Player then
        return false
    end
    local List = Shared.Whitelist
    return type(List) == "table" and List[Player.UserId] == true
end

Shared.IsWhitelisted = S.IsWhitelisted

function S.SetWhitelist(Player, State)
    if not Player then
        return
    end
    local List = Shared.Whitelist
    if State then
        List[Player.UserId] = true
    else
        List[Player.UserId] = nil
    end
    if Shared.OnWhitelistChanged then
        pcall(Shared.OnWhitelistChanged, Player, State)
    end
end

Shared.Modules.Aim.IsWhitelisted = S.IsWhitelisted
Shared.Modules.Aim.SetWhitelist = S.SetWhitelist
Shared.SetWhitelist = S.SetWhitelist

--==============================================================
-- GUI
--==============================================================

-- Remove stale XENON instances from previous executions.
-- This prevents an old empty panel from sitting above the current UI.
for _, Existing in ipairs(S.PlayerGui:GetChildren()) do
if Existing.Name == "Xenon" then
pcall(function() Existing:Destroy() end)
end
end

-- Some executors keep an earlier UI copy in CoreGui. Remove that too.
pcall(function()
local CoreGui = game:GetService("CoreGui")
local ExistingCore = CoreGui:FindFirstChild("Xenon")
if ExistingCore then
ExistingCore:Destroy()
end
end)

S.RunLoadingStage(10, "Building interface", function()
    assert(S.PlayerGui, "S.PlayerGui unavailable")
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Xenon"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = false
ScreenGui.Enabled = false
-- Sibling ordering is safer here: descendants are not accidentally
-- hidden behind their own parent when another UI is present.
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.DisplayOrder = 1000000
ScreenGui.Parent = S.PlayerGui

--==============================================================
-- COLORS
--==============================================================

local BLACK = Color3.fromRGB(8, 8, 8)
local DARK = Color3.fromRGB(14, 14, 14)
local DARKER = Color3.fromRGB(20, 20, 20)
local LIGHT_DARK = Color3.fromRGB(30, 30, 30)

local WHITE = Color3.fromRGB(245, 245, 245)
local GRAY = Color3.fromRGB(150, 150, 150)

local RED = Color3.fromRGB(220, 40, 40)
local DARK_RED = Color3.fromRGB(110, 25, 25)

--==============================================================
-- MAIN FRAME
--==============================================================

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.fromScale(0.5, 0.5)
MainFrame.BackgroundColor3 = BLACK
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.ZIndex = 1
MainFrame.Active = true
MainFrame.ClipsDescendants = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 45, 45)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

--==============================================================
-- TOP BAR
--==============================================================

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.BackgroundColor3 = DARK
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 58)
TopBar.ZIndex = 11
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 14)
TopCorner.Parent = TopBar

local TopBottom = Instance.new("Frame")
TopBottom.BackgroundColor3 = DARK
TopBottom.BorderSizePixel = 0
TopBottom.Position = UDim2.new(0, 0, 1, -14)
TopBottom.Size = UDim2.new(1, 0, 0, 14)
TopBottom.ZIndex = 11
TopBottom.Parent = TopBar

--==============================================================
-- TITLE
--==============================================================

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 18, 0, 7)
Title.Size = UDim2.new(1, -80, 0, 25)
Title.Font = Enum.Font.GothamBold
Title.Text = "XENON"
Title.TextColor3 = WHITE
Title.TextSize = 21
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 12
Title.Parent = TopBar

local Subtitle = Instance.new("TextLabel")
Subtitle.BackgroundTransparency = 1
Subtitle.Position = UDim2.new(0, 19, 0, 32)
Subtitle.Size = UDim2.new(1, -80, 0, 17)
Subtitle.Font = Enum.Font.Gotham
Subtitle.Text = "CONTROLLER CAMERA LOCK"
Subtitle.TextColor3 = GRAY
Subtitle.TextSize = 9
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.ZIndex = 12
Subtitle.Parent = TopBar

--==============================================================
-- CLOSE
--==============================================================

local CloseButton = Instance.new("TextButton")
CloseButton.AnchorPoint = Vector2.new(1, 0.5)
CloseButton.Position = UDim2.new(1, -12, 0.5, 0)
CloseButton.Size = UDim2.fromOffset(32, 32)
CloseButton.BackgroundColor3 = DARKER
CloseButton.BorderSizePixel = 0
CloseButton.Text = "×"
CloseButton.TextColor3 = WHITE
CloseButton.TextSize = 24
CloseButton.Font = Enum.Font.GothamBold
CloseButton.AutoButtonColor = false
CloseButton.ZIndex = 20
CloseButton.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

--==============================================================
-- SCROLL
--==============================================================

local Scroll = Instance.new("ScrollingFrame")
Scroll.Name = "TabAim"
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.Position = UDim2.new(0, 10, 0, 108)
Scroll.Size = UDim2.new(1, -20, 1, -118)
Scroll.CanvasSize = UDim2.fromOffset(0, 1200)
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = RED
Scroll.ScrollingDirection = Enum.ScrollingDirection.Y
Scroll.ZIndex = 11
Scroll.Parent = MainFrame

function S.ConfigureTabContainer(Container, Name)
Container.Name = Name
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.Position = Scroll.Position
Container.Size = Scroll.Size
Container.CanvasSize = UDim2.fromOffset(0, 1200)
Container.ScrollBarThickness = 3
Container.ScrollBarImageColor3 = RED
Container.ScrollingDirection = Enum.ScrollingDirection.Y
Container.ZIndex = 11
Container.Visible = false
Container.Parent = MainFrame

local Padding = Instance.new("UIPadding")
Padding.PaddingLeft = UDim.new(0, 5)
Padding.PaddingRight = UDim.new(0, 5)
Padding.PaddingTop = UDim.new(0, 3)
Padding.PaddingBottom = UDim.new(0, 12)
Padding.Parent = Container

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Container

return Layout

end

local VisualsTab = Instance.new("ScrollingFrame")
local WhitelistTab = Instance.new("ScrollingFrame")
local SupportedTab = Instance.new("ScrollingFrame")
local RageTab = Instance.new("ScrollingFrame")

local AimLayout = Instance.new("UIListLayout")
AimLayout.Padding = UDim.new(0, 8)
AimLayout.SortOrder = Enum.SortOrder.LayoutOrder
AimLayout.Parent = Scroll

local AimPadding = Instance.new("UIPadding")
AimPadding.PaddingLeft = UDim.new(0, 5)
AimPadding.PaddingRight = UDim.new(0, 5)
AimPadding.PaddingTop = UDim.new(0, 3)
AimPadding.PaddingBottom = UDim.new(0, 12)
AimPadding.Parent = Scroll

local VisualsLayout = S.ConfigureTabContainer(VisualsTab, "TabVisuals")
local WhitelistLayout = S.ConfigureTabContainer(WhitelistTab, "TabWhitelist")
local SupportedLayout = S.ConfigureTabContainer(SupportedTab, "TabSupported")
local RageLayout = S.ConfigureTabContainer(RageTab, "TabRage")

local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.BackgroundColor3 = DARK
TabBar.BorderSizePixel = 0
TabBar.Position = UDim2.new(0, 10, 0, 66)
TabBar.Size = UDim2.new(1, -20, 0, 38)
TabBar.ZIndex = 20
TabBar.Parent = MainFrame

local TabBarCorner = Instance.new("UICorner")
TabBarCorner.CornerRadius = UDim.new(0, 8)
TabBarCorner.Parent = TabBar

local TabPadding = Instance.new("UIPadding")
TabPadding.PaddingLeft = UDim.new(0, 4)
TabPadding.PaddingRight = UDim.new(0, 4)
TabPadding.Parent = TabBar

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 2)
TabLayout.Parent = TabBar

local CurrentTabContainer = Scroll
local CurrentTabName = "AIM"
local TabButtons = {}
local TabIndicators = {}

function S.CreateTab(Name, Order)
local Button = Instance.new("TextButton")
Button.Name = Name .. "Tab"
Button.LayoutOrder = Order
Button.BackgroundTransparency = 1
Button.BorderSizePixel = 0
Button.Size = UDim2.new(1/5, -3, 1, 0)
Button.Text = Name
Button.TextColor3 = GRAY
Button.TextSize = 11
Button.Font = Enum.Font.GothamSemibold
Button.AutoButtonColor = false
Button.ZIndex = 22
Button.Parent = TabBar

local Indicator = Instance.new("Frame")
Indicator.Name = "Indicator"
Indicator.AnchorPoint = Vector2.new(0.5, 1)
Indicator.Position = UDim2.new(0.5, 0, 1, 0)
Indicator.Size = UDim2.new(0.55, 0, 0, 2)
Indicator.BackgroundColor3 = RED
Indicator.BorderSizePixel = 0
Indicator.Visible = false
Indicator.ZIndex = 23
Indicator.Parent = Button

TabButtons[Name] = Button
TabIndicators[Name] = Indicator

return Button

end

local AimTabButton = S.CreateTab("AIM", 1)
local VisualsTabButton = S.CreateTab("VISUALS", 2)
local WhitelistTabButton = S.CreateTab("WHITELIST", 3)
local SupportedTabButton = S.CreateTab("SUPPORTED", 4)
local RageTabButton = S.CreateTab("RAGE", 5)

function S.UpdateTabCanvas(Container, Layout)
Container.CanvasSize = UDim2.fromOffset(0, Layout.AbsoluteContentSize.Y + 25)
end

function S.SetActiveTab(Name)
local Containers = {
AIM = Scroll,
VISUALS = VisualsTab,
WHITELIST = WhitelistTab,
SUPPORTED = SupportedTab,
RAGE = RageTab,
}

local Layouts = {
    AIM = AimLayout,
    VISUALS = VisualsLayout,
    WHITELIST = WhitelistLayout,
    SUPPORTED = SupportedLayout,
    RAGE = RageLayout,
}

local Container = Containers[Name]
if not Container then return end

CurrentTabName = Name
CurrentTabContainer = Container

for TabName, TabButton in pairs(TabButtons) do
    local Active = TabName == Name
    TabButton.TextColor3 = Active and WHITE or GRAY
    TabIndicators[TabName].Visible = Active
end

for TabName, TabContainer in pairs(Containers) do
    TabContainer.Visible = TabName == Name
end

S.UpdateTabCanvas(Container, Layouts[Name])

end

AimTabButton.Activated:Connect(function() S.SetActiveTab("AIM") end)
VisualsTabButton.Activated:Connect(function() S.SetActiveTab("VISUALS") end)
WhitelistTabButton.Activated:Connect(function() S.SetActiveTab("WHITELIST") end)
SupportedTabButton.Activated:Connect(function() S.SetActiveTab("SUPPORTED") end)
RageTabButton.Activated:Connect(function() S.SetActiveTab("RAGE") end)

S.SetActiveTab("AIM")

--==============================================================
-- MOBILE RESPONSIVE
--==============================================================

local IsMobile = false

function S.UpdateResponsiveState()
local Viewport = S.Camera.ViewportSize

IsMobile = Viewport.X <= 600

if Viewport.X <= 600 then
    MainFrame.Size = UDim2.fromOffset(
        math.max(
            260,
            math.min(
                275,
                Viewport.X - 20
            )
        ),
        math.max(
            390,
            math.min(
                440,
                Viewport.Y - 30
            )
        )
    )

    TopBar.Size = UDim2.new(1, 0, 0, 50)

    TabBar.Position =
        UDim2.new(0, 8, 0, 57)
    TabBar.Size =
        UDim2.new(1, -16, 0, 34)

    Scroll.Position =
        UDim2.new(0, 8, 0, 99)
    Scroll.Size =
        UDim2.new(1, -16, 1, -107)
    VisualsTab.Position = Scroll.Position
    VisualsTab.Size = Scroll.Size
    WhitelistTab.Position = Scroll.Position
    WhitelistTab.Size = Scroll.Size
    SupportedTab.Position = Scroll.Position
    SupportedTab.Size = Scroll.Size
    RageTab.Position = Scroll.Position
    RageTab.Size = Scroll.Size

    for _, Button in pairs(TabButtons) do
        Button.TextSize = 9
    end

    Title.TextSize = 17
    Title.Position =
        UDim2.new(0, 14, 0, 5)

    Subtitle.TextSize = 7
    Subtitle.Position =
        UDim2.new(0, 15, 0, 28)

    CloseButton.Size =
        UDim2.fromOffset(28, 28)

    CloseButton.Position =
        UDim2.new(1, -9, 0.5, 0)

    AimPadding.PaddingLeft =
        UDim.new(0, 3)
    AimPadding.PaddingRight =
        UDim.new(0, 3)

elseif Viewport.X <= 1000 then
    MainFrame.Size =
        UDim2.fromOffset(320, 490)

    TopBar.Size =
        UDim2.new(1, 0, 0, 54)

    TabBar.Position =
        UDim2.new(0, 9, 0, 62)
    TabBar.Size =
        UDim2.new(1, -18, 0, 36)

    Scroll.Position =
        UDim2.new(0, 9, 0, 104)
    Scroll.Size =
        UDim2.new(1, -18, 1, -112)
    VisualsTab.Position = Scroll.Position
    VisualsTab.Size = Scroll.Size
    WhitelistTab.Position = Scroll.Position
    WhitelistTab.Size = Scroll.Size
    SupportedTab.Position = Scroll.Position
    SupportedTab.Size = Scroll.Size
    RageTab.Position = Scroll.Position
    RageTab.Size = Scroll.Size

    for _, Button in pairs(TabButtons) do
        Button.TextSize = 10
    end

    Title.TextSize = 19

    Subtitle.TextSize = 8

    CloseButton.Size =
        UDim2.fromOffset(30, 30)

    AimPadding.PaddingLeft =
        UDim.new(0, 4)
    AimPadding.PaddingRight =
        UDim.new(0, 4)

else
    MainFrame.Size =
        UDim2.fromOffset(390, 570)

    TopBar.Size =
        UDim2.new(1, 0, 0, 58)

    TabBar.Position =
        UDim2.new(0, 10, 0, 66)
    TabBar.Size =
        UDim2.new(1, -20, 0, 38)

    Scroll.Position =
        UDim2.new(0, 10, 0, 108)
    Scroll.Size =
        UDim2.new(1, -20, 1, -118)
    VisualsTab.Position = Scroll.Position
    VisualsTab.Size = Scroll.Size
    WhitelistTab.Position = Scroll.Position
    WhitelistTab.Size = Scroll.Size
    SupportedTab.Position = Scroll.Position
    SupportedTab.Size = Scroll.Size
    RageTab.Position = Scroll.Position
    RageTab.Size = Scroll.Size

    for _, Button in pairs(TabButtons) do
        Button.TextSize = 11
    end

    Title.TextSize = 21

    Subtitle.TextSize = 9

    CloseButton.Size =
        UDim2.fromOffset(32, 32)

    AimPadding.PaddingLeft =
        UDim.new(0, 5)
    AimPadding.PaddingRight =
        UDim.new(0, 5)
end

end

--==============================================================
-- FLOATING BUTTON
--==============================================================

local FloatingToggle = Instance.new("TextButton")
FloatingToggle.Name = "FloatingToggle"
FloatingToggle.AnchorPoint = Vector2.new(1, 0)
FloatingToggle.Position =
UDim2.new(1, -10, 0, 10)

FloatingToggle.Size =
UDim2.fromOffset(42, 42)

FloatingToggle.BackgroundColor3 = BLACK
FloatingToggle.BorderSizePixel = 0
FloatingToggle.Text = "X"
FloatingToggle.TextColor3 = WHITE
FloatingToggle.TextSize = 18
FloatingToggle.Font = Enum.Font.GothamBold
FloatingToggle.AutoButtonColor = false
FloatingToggle.ZIndex = 100000
FloatingToggle.Parent = ScreenGui

local FloatingCorner = Instance.new("UICorner")
FloatingCorner.CornerRadius = UDim.new(0, 10)
FloatingCorner.Parent = FloatingToggle

local FloatingStroke = Instance.new("UIStroke")
FloatingStroke.Color = RED
FloatingStroke.Thickness = 1.5
FloatingStroke.Parent = FloatingToggle

--==============================================================
-- SECTION
--==============================================================

function S.CreateSection(Text)
local Section = Instance.new("TextLabel")

Section.BackgroundTransparency = 1
Section.Size =
    UDim2.new(1, 0, 0, 20)

Section.Font =
    Enum.Font.GothamBold

Section.Text = Text
Section.TextColor3 = RED
Section.TextSize = IsMobile and 10 or 11

Section.TextXAlignment =
    Enum.TextXAlignment.Left

Section.ZIndex = 12
Section.Parent = CurrentTabContainer

return Section

end

--==============================================================
-- ROW
--==============================================================

function S.CreateRow(Height)
local Row = Instance.new("Frame")

Row.BackgroundColor3 = DARK
Row.BorderSizePixel = 0

Row.Size =
    UDim2.new(1, 0, 0, Height)

Row.ZIndex = 12
Row.Parent = CurrentTabContainer

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Row

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(35, 35, 35)
Stroke.Thickness = 1
Stroke.Parent = Row

return Row

end

--==============================================================
-- LABEL
--==============================================================

function S.CreateLabel(Parent, Text)
local Label = Instance.new("TextLabel")

Label.BackgroundTransparency = 1
Label.Position =
    UDim2.new(0, 12, 0, 0)

Label.Size =
    UDim2.new(0.55, -12, 1, 0)

Label.Font =
    Enum.Font.GothamMedium

Label.Text = Text
Label.TextColor3 = WHITE
Label.TextSize = IsMobile and 11 or 13

Label.TextXAlignment =
    Enum.TextXAlignment.Left

Label.ZIndex = 13
Label.Parent = Parent

return Label

end

--==============================================================
--==============================================================
-- SHARED UI BRIDGE
--==============================================================

Shared.Gui = ScreenGui
Shared.MainFrame = MainFrame
Shared.TabBar = TabBar
Shared.TabButtons = TabButtons
Shared.TabIndicators = TabIndicators
Shared.TabContainers = {
    AIM = Scroll,
    VISUALS = VisualsTab,
    WHITELIST = WhitelistTab,
    SUPPORTED = SupportedTab,
    RAGE = RageTab,
}
Shared.TabLayouts = {
    AIM = AimLayout,
    VISUALS = VisualsLayout,
    WHITELIST = WhitelistLayout,
    SUPPORTED = SupportedLayout,
    RAGE = RageLayout,
}
Shared.UI.ScreenGui = ScreenGui
Shared.UI.MainFrame = MainFrame
Shared.UI.SetActiveTab = S.SetActiveTab
Shared.UI.UpdateTabCanvas = S.UpdateTabCanvas
Shared.UI.CreateSection = S.CreateSection
Shared.UI.CreateRow = S.CreateRow
Shared.UI.CreateLabel = S.CreateLabel
Shared.UI.CreateToggleRow = S.CreateToggleRow
Shared.UI.CreateInputRow = S.CreateInputRow
Shared.UI.IsMobile = function()
    return IsMobile
end
Shared.UI.WhitelistTab = WhitelistTab
Shared.UI.WhitelistLayout = WhitelistLayout
Shared.UI.RageTab = RageTab
Shared.UI.RageLayout = RageLayout

local CameraCorner = Instance.new("UICorner")
CameraCorner.CornerRadius = UDim.new(0, 6)
CameraCorner.Parent = CameraButton

local CameraOptions = Instance.new("Frame")

CameraOptions.Visible = false
CameraOptions.AnchorPoint =
Vector2.new(1, 0)

CameraOptions.Position =
UDim2.new(1, -8, 1, 3)

CameraOptions.Size =
UDim2.new(0.42, 0, 0, 62)

CameraOptions.BackgroundColor3 = DARKER
CameraOptions.BorderSizePixel = 0
CameraOptions.ZIndex = 50
CameraOptions.Parent = CameraRow

local CameraOptionsCorner = Instance.new("UICorner")
CameraOptionsCorner.CornerRadius = UDim.new(0, 6)
CameraOptionsCorner.Parent = CameraOptions

local CameraOptionLayout = Instance.new("UIListLayout")
CameraOptionLayout.Parent = CameraOptions

function S.CreateCameraOption(Text)
local Option = Instance.new("TextButton")

Option.Size =
    UDim2.new(1, 0, 0, 31)

Option.BackgroundTransparency = 1
Option.BorderSizePixel = 0
Option.Text = Text
Option.TextColor3 = WHITE
Option.TextSize = IsMobile and 9 or 11
Option.Font = Enum.Font.Gotham
Option.AutoButtonColor = false
Option.ZIndex = 51
Option.Parent = CameraOptions

Option.Activated:Connect(function()
    Config.CameraMode = Text
    S.SaveSettings()
    CameraButton.Text = Text
    CameraOptions.Visible = false
end)

return Option

end

S.CreateCameraOption("First Person")
S.CreateCameraOption("Third Person")

CameraButton.Activated:Connect(function()
CameraOptions.Visible =
not CameraOptions.Visible
end)

--==============================================================
-- AIM SETTINGS
--==============================================================

S.CreateSection("AIM SETTINGS")

function S.CreateInputRow(LabelText, DefaultValue)
local Row = S.CreateRow(44)

S.CreateLabel(Row, LabelText)

local Box = Instance.new("TextBox")

Box.AnchorPoint =
    Vector2.new(1, 0.5)

Box.Position =
    UDim2.new(1, -8, 0.5, 0)

Box.Size =
    UDim2.new(0.37, 0, 0, 30)

Box.BackgroundColor3 = DARKER
Box.BorderSizePixel = 0
Box.ClearTextOnFocus = false
Box.Text = tostring(DefaultValue)
Box.TextColor3 = WHITE
Box.PlaceholderColor3 = GRAY
Box.TextSize = IsMobile and 10 or 12
Box.Font = Enum.Font.GothamMedium
Box.TextXAlignment = Enum.TextXAlignment.Center
Box.ZIndex = 13
Box.Parent = Row

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 6)
Corner.Parent = Box

return Row, Box

end

--==============================================================
-- 3P OFFSET
--==============================================================

local OffsetRow, OffsetBox =
S.CreateInputRow(
"3P Offset",
Config.AimOffset
)

OffsetBox.FocusLost:Connect(function()
local Number = tonumber(OffsetBox.Text)

if Number then
    Number =
        math.clamp(Number, -100, 100)

    Config.AimOffset = Number
    S.SaveSettings()

    OffsetBox.Text =
        tostring(Number)
else
    OffsetBox.Text =
        tostring(Config.AimOffset)
end

end)

--==============================================================
-- SMOOTHING
--==============================================================

local SmoothRow, SmoothBox =
S.CreateInputRow(
"Smoothing",
Config.Smoothing
)

SmoothBox.FocusLost:Connect(function()
local Number = tonumber(SmoothBox.Text)

if Number then
    Number = math.max(0, Number)

    Config.Smoothing = Number
    S.SaveSettings()

    SmoothBox.Text =
        tostring(Number)
else
    SmoothBox.Text =
        tostring(Config.Smoothing)
end

end)

--==============================================================
-- PREDICTION
--==============================================================

local PredictionRow, PredictionBox =
S.CreateInputRow(
"Prediction",
Config.Prediction
)

PredictionBox.FocusLost:Connect(function()
local Number = tonumber(PredictionBox.Text)

if Number then
    Number = math.max(0, Number)

    Config.Prediction = Number
    S.SaveSettings()

    PredictionBox.Text =
        tostring(Number)
else
    PredictionBox.Text =
        tostring(Config.Prediction)
end

end)

--==============================================================
-- TOGGLE CREATOR
--==============================================================

function S.CreateToggleRow(
LabelText,
GetValue,
SetValue
)
local Row = S.CreateRow(44)

S.CreateLabel(Row, LabelText)

local Button = Instance.new("TextButton")

Button.AnchorPoint =
    Vector2.new(1, 0.5)

Button.Position =
    UDim2.new(1, -8, 0.5, 0)

Button.Size =
    UDim2.fromOffset(58, 28)

Button.BorderSizePixel = 0
Button.TextColor3 = WHITE
Button.TextSize = IsMobile and 10 or 11
Button.Font = Enum.Font.GothamBold
Button.AutoButtonColor = false
Button.ZIndex = 13
Button.Parent = Row

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 7)
Corner.Parent = Button

local function Update()
    if GetValue() then
        Button.Text = "ON"
        Button.BackgroundColor3 = RED
    else
        Button.Text = "OFF"
        Button.BackgroundColor3 = DARKER
    end
end

Button.Activated:Connect(function()
    SetValue(not GetValue())
    S.Update()
end)

S.Update()

return Row, Button

end

--==============================================================
-- STICKY AIM
--==============================================================

local StickyRow, StickyButton =
S.CreateToggleRow(
"Sticky Aim",

    function()
        return Config.StickyAim
    end,

    function(Value)
        Config.StickyAim = Value
        S.SaveSettings()
    end
)

--==============================================================
-- AIMBOT WHITELIST SKIP
--==============================================================

local AimWhitelistRow, AimWhitelistButton =
S.CreateToggleRow(
"Whitelist Skip",

    function()
        return Config.AimbotWhitelistSkip
    end,

    function(Value)
        Config.AimbotWhitelistSkip = Value
        S.SaveSettings()

        -- If currently locked onto someone who is
        -- now protected, immediately unlock.
        if Value and LockedTarget then
            if S.IsWhitelisted(LockedTarget) then
                Locked = false
                LockedTarget = nil
            end
        end
    end
)

--==============================================================
-- LOCK SAFETY CHECKS
--==============================================================

local WallCheckRow, WallCheckButton =
S.CreateToggleRow(
"Wall Check",

    function()
        return Config.WallCheck
    end,

    function(Value)
        Config.WallCheck = Value
        S.SaveSettings()

        -- Re-check the current target immediately when enabled.
        if Value and LockedTarget then
            -- Validation also checks the knocked/health condition.
            -- The render loop will perform the full check next frame.
        end
    end
)

local DownRow, DownButton =
S.CreateToggleRow(
"Down Check",

    function()
        return Config.DownCheck and ActiveGameConfig.DownCheckPath ~= nil
    end,

    function(Value)
        if ActiveGameConfig.DownCheckPath then
            Config.DownCheck = Value
            if Value then
                Config.ManualHealthCheck = false
            end
        else
            Config.DownCheck = false
        end
        S.SaveSettings()
    end
)

local ManualHealthRow, ManualHealthButton =
S.CreateToggleRow(
"Manual Health",

    function()
        return Config.ManualHealthCheck
    end,

    function(Value)
        Config.ManualHealthCheck = Value
        if Value then
            Config.DownCheck = false
        end
        S.SaveSettings()
    end
)

local HealthRow, HealthBox =
S.CreateInputRow(
"Health Threshold",
Config.HealthThreshold
)

HealthBox.FocusLost:Connect(function()
local Number = tonumber(HealthBox.Text)

if Number then
    Number = math.max(0, Number)
    Config.HealthThreshold = Number
    S.SaveSettings()
    HealthBox.Text = tostring(Number)
else
    HealthBox.Text = tostring(Config.HealthThreshold)
end

end)

-- CONTROLLER
--==============================================================

S.CreateSection("CONTROLLER")

local LockRow = S.CreateRow(44)

S.CreateLabel(
LockRow,
"S.Lock Button"
)

local LockButtonDisplay = Instance.new("TextLabel")

LockButtonDisplay.AnchorPoint =
Vector2.new(1, 0.5)

LockButtonDisplay.Position =
UDim2.new(1, -8, 0.5, 0)

LockButtonDisplay.Size =
UDim2.new(0.37, 0, 0, 30)

LockButtonDisplay.BackgroundColor3 =
DARKER

LockButtonDisplay.BorderSizePixel = 0
LockButtonDisplay.Text =
Config.LockButton.Name

LockButtonDisplay.TextColor3 = WHITE
LockButtonDisplay.TextSize = IsMobile and 8 or 10
LockButtonDisplay.Font =
Enum.Font.GothamBold

LockButtonDisplay.ZIndex = 13
LockButtonDisplay.Parent = LockRow

local LockCorner = Instance.new("UICorner")
LockCorner.CornerRadius = UDim.new(0, 6)
LockCorner.Parent = LockButtonDisplay

local RebindRow = S.CreateRow(44)

local RebindButton = Instance.new("TextButton")

RebindButton.Position =
UDim2.new(0, 8, 0, 7)

RebindButton.Size =
UDim2.new(1, -16, 1, -14)

RebindButton.BackgroundColor3 = RED
RebindButton.BorderSizePixel = 0
RebindButton.Text = "SET LOCK BUTTON"
RebindButton.TextColor3 = WHITE
RebindButton.TextSize = IsMobile and 10 or 12
RebindButton.Font = Enum.Font.GothamBold
RebindButton.AutoButtonColor = false
RebindButton.ZIndex = 13
RebindButton.Parent = RebindRow

local RebindCorner = Instance.new("UICorner")
RebindCorner.CornerRadius = UDim.new(0, 7)
RebindCorner.Parent = RebindButton

S.RunLoadingStage(11, "Preparing controls", function()
    assert(CameraButton and RebindButton, "Core controls unavailable")
end)

--==============================================================
-- VISUALS
--==============================================================

S.SetActiveTab("VISUALS")
S.CreateSection("VISUALS")

local ESPEnabledRow, ESPEnabledButton =
S.CreateToggleRow(
"Enabled",

    function()
        return Config.ESPEnabled
    end,

    function(Value)
        Config.ESPEnabled = Value
        S.SaveSettings()
    end
)

local ESPNameRow, ESPNameButton =
S.CreateToggleRow(
"Show Name",

    function()
        return Config.ESPShowName
    end,

    function(Value)
        Config.ESPShowName = Value
        S.SaveSettings()
    end
)

local ESPOutlineRow, ESPOutlineButton =
S.CreateToggleRow(
"Show Outline",

    function()
        return Config.ESPShowOutline
    end,

    function(Value)
        Config.ESPShowOutline = Value
        S.SaveSettings()
    end
)

local ESPWhitelistRow, ESPWhitelistButton =
S.CreateToggleRow(
"Whitelist Check",

    function()
        return Config.ESPWhitelistCheck
    end,

    function(Value)
        Config.ESPWhitelistCheck = Value
        S.SaveSettings()
    end
)

--==============================================================
--==============================================================
-- SUPPORTED
--==============================================================

S.SetActiveTab("SUPPORTED")
S.CreateSection("SUPPORTED GAMES")

function S.CreateSupportedGameCard(PlaceId, GameConfig)
local Name = S.GetGameInfo(PlaceId)

local Row = S.CreateRow(72)

local Icon = Instance.new("ImageLabel")
Icon.BackgroundColor3 = DARKER
Icon.BorderSizePixel = 0
Icon.Position = UDim2.new(0, 10, 0.5, -25)
Icon.Size = UDim2.fromOffset(50, 50)
Icon.Image = "rbxthumb://type=Game&id=" .. tostring(PlaceId) .. "&w=150&h=150"
Icon.ScaleType = Enum.ScaleType.Crop
Icon.ZIndex = 13
Icon.Parent = Row

local IconCorner = Instance.new("UICorner")
IconCorner.CornerRadius = UDim.new(0, 8)
IconCorner.Parent = Icon

local NameLabel = Instance.new("TextLabel")
NameLabel.BackgroundTransparency = 1
NameLabel.Position = UDim2.new(0, 72, 0, 9)
NameLabel.Size = UDim2.new(1, -82, 0, 24)
NameLabel.Font = Enum.Font.GothamBold
NameLabel.Text = Name
NameLabel.TextColor3 = WHITE
NameLabel.TextSize = IsMobile and 11 or 13
NameLabel.TextXAlignment = Enum.TextXAlignment.Left
NameLabel.TextTruncate = Enum.TextTruncate.AtEnd
NameLabel.ZIndex = 13
NameLabel.Parent = Row

local SupportLabel = Instance.new("TextLabel")
SupportLabel.BackgroundTransparency = 1
SupportLabel.Position = UDim2.new(0, 72, 0, 35)
SupportLabel.Size = UDim2.new(1, -82, 0, 22)
SupportLabel.Font = Enum.Font.Gotham
SupportLabel.Text = GameConfig.DownCheckPath and "DOWN CHECK SUPPORTED" or "MANUAL HEALTH CHECK"
SupportLabel.TextColor3 = GameConfig.DownCheckPath and RED or GRAY
SupportLabel.TextSize = 9
SupportLabel.TextXAlignment = Enum.TextXAlignment.Left
SupportLabel.ZIndex = 13
SupportLabel.Parent = Row

return Row

end

local CurrentGameRow = S.CreateRow(54)
local CurrentGameLabel = Instance.new("TextLabel")
CurrentGameLabel.BackgroundTransparency = 1
CurrentGameLabel.Position = UDim2.new(0, 12, 0, 6)
CurrentGameLabel.Size = UDim2.new(1, -24, 0, 20)
CurrentGameLabel.Font = Enum.Font.GothamBold
CurrentGameLabel.Text = "CURRENT: " .. CurrentGameName
CurrentGameLabel.TextColor3 = WHITE
CurrentGameLabel.TextSize = IsMobile and 10 or 12
CurrentGameLabel.TextXAlignment = Enum.TextXAlignment.Left
CurrentGameLabel.TextTruncate = Enum.TextTruncate.AtEnd
CurrentGameLabel.ZIndex = 13
CurrentGameLabel.Parent = CurrentGameRow

local CurrentStatusLabel = Instance.new("TextLabel")
CurrentStatusLabel.BackgroundTransparency = 1
CurrentStatusLabel.Position = UDim2.new(0, 12, 0, 27)
CurrentStatusLabel.Size = UDim2.new(1, -24, 0, 18)
CurrentStatusLabel.Font = Enum.Font.Gotham
CurrentStatusLabel.Text = "SUPPORTED"
CurrentStatusLabel.TextColor3 = RED
CurrentStatusLabel.TextSize = 9
CurrentStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
CurrentStatusLabel.ZIndex = 13
CurrentStatusLabel.Parent = CurrentGameRow

for PlaceId, GameConfig in pairs(SupportedGames) do
S.CreateSupportedGameCard(PlaceId, GameConfig)
end

--==============================================================
-- STATUS
--==============================================================

S.SetActiveTab("AIM")
S.CreateSection("STATUS")

local StatusRow = S.CreateRow(55)

local StatusLabel = Instance.new("TextLabel")

StatusLabel.BackgroundTransparency = 1
StatusLabel.Position =
UDim2.new(0, 12, 0, 5)

StatusLabel.Size =
UDim2.new(1, -24, 0, 20)

StatusLabel.Font =
Enum.Font.GothamBold

StatusLabel.Text = "UNLOCKED"
StatusLabel.TextColor3 = GRAY
StatusLabel.TextSize = IsMobile and 12 or 14
StatusLabel.TextXAlignment =
Enum.TextXAlignment.Left

StatusLabel.ZIndex = 13
StatusLabel.Parent = StatusRow

local TargetLabel = Instance.new("TextLabel")

TargetLabel.BackgroundTransparency = 1
TargetLabel.Position =
UDim2.new(0, 12, 0, 27)

TargetLabel.Size =
UDim2.new(1, -24, 0, 18)

TargetLabel.Font =
Enum.Font.Gotham

TargetLabel.Text =
"Target: None"

TargetLabel.TextColor3 = GRAY
TargetLabel.TextSize = IsMobile and 9 or 10
TargetLabel.TextXAlignment =
Enum.TextXAlignment.Left

TargetLabel.ZIndex = 13
TargetLabel.Parent = StatusRow

--==============================================================
S.RunLoadingStage(12, "Preparing ESP", function()
    assert(type(ESPObjects) == "table", "ESP state unavailable")
end)

--==============================================================
-- ESP
--==============================================================

function S.DestroyESP(Player)
local Data = ESPObjects[Player]

if not Data then
    return
end

if Data.Highlight then
    pcall(function()
        Data.Highlight:Destroy()
    end)
end

if Data.NameGui then
    pcall(function()
        Data.NameGui:Destroy()
    end)
end

ESPObjects[Player] = nil

end

function S.CreateESP(Player)
if Player == S.LocalPlayer then
return
end

local Existing = ESPObjects[Player]
if Existing and Existing.Character == Player.Character then
    return
end

S.DestroyESP(Player)

local Character = Player.Character

if not Character then
    return
end

local Data = {
    Character = Character,
}

--==========================================================
-- OUTLINE
--==========================================================

if Config.ESPShowOutline then
    local Highlight =
        Instance.new("Highlight")

    Highlight.Name =
        "XenonESP"

    Highlight.Adornee =
        Character

    Highlight.FillTransparency = 1

    Highlight.OutlineTransparency = 0

    Highlight.OutlineColor = WHITE

    Highlight.DepthMode =
        Enum.HighlightDepthMode.AlwaysOnTop

    Highlight.Parent = Character

    Data.Highlight = Highlight
end

--==========================================================
-- NAME
--==========================================================

if Config.ESPShowName then
    local Head =
        Character:FindFirstChild("Head")

    local Root =
        Character:FindFirstChild(
            "HumanoidRootPart"
        )

    local Adornee =
        Head or Root

    if Adornee then
        local Billboard =
            Instance.new("BillboardGui")

        Billboard.Name =
            "XenonName"

        Billboard.Adornee =
            Adornee

        Billboard.Size =
            UDim2.fromOffset(150, 30)

        Billboard.StudsOffset =
            Vector3.new(0, 2.7, 0)

        Billboard.AlwaysOnTop = true

        Billboard.MaxDistance = 1000

        Billboard.Parent = Adornee

        local NameLabel =
            Instance.new("TextLabel")

        NameLabel.BackgroundTransparency = 1
        NameLabel.Size =
            UDim2.fromScale(1, 1)

        NameLabel.Font =
            Enum.Font.GothamBold

        NameLabel.Text =
            Player.DisplayName ..
            "  @" ..
            Player.Name

        NameLabel.TextColor3 =
            WHITE

        NameLabel.TextStrokeTransparency =
            0.3

        NameLabel.TextSize = 12

        NameLabel.Parent =
            Billboard

        Data.NameGui = Billboard
    end
end

ESPObjects[Player] = Data

end

function S.ShouldESP(Player)
if Player == S.LocalPlayer then
return false
end

if not Config.ESPEnabled then
    return false
end

if Config.ESPWhitelistCheck
    and S.IsWhitelisted(Player) then

    return false
end

return true

end

function S.UpdateESPPlayer(Player)
if Player == S.LocalPlayer then
return
end

if S.ShouldESP(Player) then
    S.CreateESP(Player)
else
    S.DestroyESP(Player)
end

end

function S.UpdateAllESP()
for _, Player in ipairs(S.Players:GetPlayers()) do
S.UpdateESPPlayer(Player)
end
end

-- Rebuild ESP when settings change.

ESPEnabledButton.Activated:Connect(function()
task.defer(S.UpdateAllESP)
end)

ESPNameButton.Activated:Connect(function()
task.defer(S.UpdateAllESP)
end)

ESPOutlineButton.Activated:Connect(function()
task.defer(S.UpdateAllESP)
end)

ESPWhitelistButton.Activated:Connect(function()
task.defer(S.UpdateAllESP)
end)

--==============================================================
-- PLAYER EVENTS
--==============================================================

Connect(
S.Players.PlayerAdded,
function(Player)
task.defer(function()

        if Player.Character then
            S.UpdateESPPlayer(Player)
        end
    end)

    Player.CharacterAdded:Connect(function()
        task.wait(0.5)

        S.UpdateESPPlayer(Player)
    end)
end

)

Connect(
S.Players.PlayerRemoving,
function(Player)
if Player == LockedTarget then
Locked = false
LockedTarget = nil
end

    S.DestroyESP(Player)

    task.defer(function()
            end)
end

)

for _, Player in ipairs(S.Players:GetPlayers()) do
if Player ~= S.LocalPlayer then
Connect(
Player.CharacterAdded,
function()
task.wait(0.5)

            S.UpdateESPPlayer(Player)
        end
    )
end

end

S.RunLoadingStage(13, "Connecting runtime systems", function()
    assert(type(Connections) == "table", "Connection tracking unavailable")
end)

--==============================================================
-- TARGET DATA
--==============================================================

function S.GetCharacterData(Player)
if not Player then
return nil
end

if Player == S.LocalPlayer then
    return nil
end

local Character =
    Player.Character

if not Character then
    return nil
end

local Humanoid =
    Character:FindFirstChildOfClass(
        "Humanoid"
    )

local Root =
    Character:FindFirstChild(
        "HumanoidRootPart"
    )

if not Humanoid or not Root then
    return nil
end

if Humanoid.Health <= 0 then
    return nil
end

return Character,
    Humanoid,
    Root

end

--==============================================================
-- LOCAL ROOT
--==============================================================

function S.GetLocalRoot()
local Character =
S.LocalPlayer.Character

if not Character then
    return nil
end

return Character:FindFirstChild(
    "HumanoidRootPart"
)

end

--==============================================================
-- LOCK SAFETY CHECKS
--==============================================================

-- Game path: Player.Backpack.Stats.Downed
-- Matching is case-insensitive for Backpack/BackPack, Stats/stats,
-- and Downed/DOWNED.

function S.FindChildCaseInsensitive(Parent, WantedName)
if not Parent then
return nil
end

local Wanted = string.lower(WantedName)

for _, Child in ipairs(Parent:GetChildren()) do
    if string.lower(Child.Name) == Wanted then
        return Child
    end
end

return nil

end

function S.GetPathValueCaseInsensitive(Root, Path)
local Current = Root

for _, Name in ipairs(Path or {}) do
    Current = S.FindChildCaseInsensitive(Current, Name)
    if not Current then
        return nil
    end
end

return Current

end

function S.IsTargetDown(Player)
if not Player or not ActiveGameConfig.DownCheckPath then
return false
end

local ValueObject =
    S.GetPathValueCaseInsensitive(
        Player,
        ActiveGameConfig.DownCheckPath
    )

if not ValueObject then
    return false
end

local Success, Value = pcall(function()
    return ValueObject.Value
end)

return Success and Value == true

end

function S.IsTargetBelowHealth(Player)
if not Player then
return false
end

local Character = Player.Character
if not Character then
    return false
end

local Humanoid = Character:FindFirstChildOfClass("Humanoid")
if not Humanoid then
    return false
end

return Humanoid.Health <= Config.HealthThreshold

end

function S.IsHeadVisible(Player)
if not Player then
return false
end

local Character = Player.Character
if not Character then
    return false
end

local Head = Character:FindFirstChild("Head")
local CurrentCamera = workspace.CurrentCamera

if not Head or not CurrentCamera then
    return false
end

local Origin = CurrentCamera.CFrame.Position
local Direction = Head.Position - Origin

if Direction.Magnitude <= 0.01 then
    return true
end

local Params = RaycastParams.new()
Params.FilterType = Enum.RaycastFilterType.Exclude
Params.FilterDescendantsInstances = {
    S.LocalPlayer.Character
}
Params.IgnoreWater = true

local Result = workspace:Raycast(
    Origin,
    Direction,
    Params
)

if not Result then
    return true
end

return Result.Instance:IsDescendantOf(Character)

end

function S.IsTargetLockable(Player)
if not Player then
return false
end

if Config.DownCheck
    and ActiveGameConfig.DownCheckPath
    and S.IsTargetDown(Player) then
    return false
end

if Config.ManualHealthCheck
    and S.IsTargetBelowHealth(Player) then
    return false
end

if Config.WallCheck and not S.IsHeadVisible(Player) then
    return false
end

return true

end

-- CONTROLLER DOT TARGET
--==============================================================

local ControllerDotNames = {
ControllerDot = true,
ControllerCursor = true,
ControllerReticle = true,
AimDot = true,
AimCursor = true,
CrosshairDot = true,
TargetDot = true,
LockDot = true,
Reticle = true,
Crosshair = true,
Cursor = true,
}

function S.GetControllerDotPosition()
local CurrentCamera = workspace.CurrentCamera

if not CurrentCamera then
    return nil
end

local Viewport = CurrentCamera.ViewportSize
local ScreenCenter =
    Vector2.new(Viewport.X * 0.5, Viewport.Y * 0.5)

local BestPosition = nil
local BestScore = math.huge

-- Prefer an actual game UI reticle/dot when the game exposes one.
for _, Object in ipairs(S.PlayerGui:GetDescendants()) do
    if Object:IsA("GuiObject")
        and Object.Visible
        and ControllerDotNames[Object.Name] then

        local Size = Object.AbsoluteSize

        -- Ignore large menus/panels that happen to use a reticle-like name.
        if Size.X <= 80 and Size.Y <= 80 then
            local Position =
                Object.AbsolutePosition + Size * 0.5

            local DistanceFromCenter =
                (Position - ScreenCenter).Magnitude

            local Area = math.max(Size.X * Size.Y, 1)

            local Score =
                DistanceFromCenter +
                math.sqrt(Area) * 0.15

            if Score < BestScore then
                BestScore = Score
                BestPosition = Position
            end
        end
    end
end

if BestPosition then
    return BestPosition
end

-- Fallback for games that do not expose the controller dot as a GUI
-- object: use the camera center rather than the mouse position.
return ScreenCenter

end

function S.GetTargetScreenPosition(Player)
local CurrentCamera = workspace.CurrentCamera

if not CurrentCamera then
    return nil, false
end

local Character = Player and Player.Character
if not Character then
    return nil, false
end

local Head = Character:FindFirstChild("Head")
local Root = Character:FindFirstChild("HumanoidRootPart")

local Position =
    Head and Head.Position
    or Root and Root.Position

if not Position then
    return nil, false
end

return CurrentCamera:WorldToViewportPoint(Position)

end

function S.GetClosestToControllerDot()
local CurrentCamera = workspace.CurrentCamera

if not CurrentCamera then
    return nil
end

local DotPosition = S.GetControllerDotPosition()
if not DotPosition then
    return nil
end

local BestPlayer = nil
local BestDistance = math.huge

for _, Player in ipairs(S.Players:GetPlayers()) do
    if not (
        Config.AimbotWhitelistSkip
        and S.IsWhitelisted(Player)
    ) then
        local Character, Humanoid, Root =
            S.GetCharacterData(Player)

        if Character
            and Humanoid
            and Root
            and S.IsTargetLockable(Player) then

            local WorldDistance =
                (Root.Position - CurrentCamera.CFrame.Position).Magnitude

            if WorldDistance <= Config.MaxTargetDistance then
                local ScreenPosition, OnScreen =
                    S.GetTargetScreenPosition(Player)

                if OnScreen and ScreenPosition.Z > 0 then
                    local ScreenDistance =
                        (
                            Vector2.new(
                                ScreenPosition.X,
                                ScreenPosition.Y
                            ) - DotPosition
                        ).Magnitude

                    if ScreenDistance < BestDistance then
                        BestDistance = ScreenDistance
                        BestPlayer = Player
                    end
                end
            end
        end
    end
end

return BestPlayer

end

--==============================================================
-- PHYSICAL DISTANCE TARGET
--==============================================================

function S.GetClosestByDistance()
local LocalRoot =
S.GetLocalRoot()

if not LocalRoot then
    return nil
end

local BestPlayer = nil

local BestDistance =
    Config.MaxTargetDistance

for _, Player in ipairs(S.Players:GetPlayers()) do

    if
        not (
            Config.AimbotWhitelistSkip
            and S.IsWhitelisted(Player)
        )
    then

        local Character,
            Humanoid,
            Root =
            S.GetCharacterData(Player)

        if Character
            and Humanoid
            and Root
            and S.IsTargetLockable(Player) then

            local Distance =
                (
                    Root.Position -
                    LocalRoot.Position
                ).Magnitude

            if Distance <=
                BestDistance then

                BestDistance =
                    Distance

                BestPlayer =
                    Player
            end
        end
    end
end

return BestPlayer

end

--==============================================================
-- FIND TARGET
--==============================================================

function S.FindTarget()
if Config.StickyAim then
return S.GetClosestToControllerDot()
end

return S.GetClosestByDistance()

end

--==============================================================
-- PREDICTION
--==============================================================

function S.GetPredictedPosition(
Position,
Velocity
)
-- Some characters/executor environments can briefly expose missing
-- velocity data. Never allow that to reach the render-step callback.
if typeof(Position) ~= "Vector3" then
    return nil
end

if typeof(Velocity) ~= "Vector3" then
    Velocity = Vector3.zero
end

local Prediction = tonumber(Config.Prediction) or 0
return Position + Velocity * Prediction
end

--==============================================================
-- THIRD PERSON ADAPTIVE OFFSET
--==============================================================

function S.GetAdaptiveOffset(TargetRoot)
if not TargetRoot then
return Config.AimOffset
end

local CurrentCamera = workspace.CurrentCamera
if not CurrentCamera then
    return Config.AimOffset
end

local Character = TargetRoot.Parent
if not Character then
    return Config.AimOffset
end

-- The calibration point is the distance where AimOffset is exact.
-- 23.5 at 40 studs therefore becomes the baseline.
-- This is intentionally calculated from distance only: no expensive
-- per-frame screen feedback and no correction fighting the user value.
local Head = Character:FindFirstChild("Head")
local Alpha = math.clamp(Config.ThirdPersonAnchor, 0, 1)

local AnchorPosition = TargetRoot.Position
if Head then
    AnchorPosition = TargetRoot.Position:Lerp(Head.Position, Alpha)
end

local Distance =
    (AnchorPosition - CurrentCamera.CFrame.Position).Magnitude

local CalibrationDistance =
    math.max(Config.ReferenceDistance, 1)

local DistanceScale =
    Distance / CalibrationDistance

-- Scale the offset so the same camera-angle relationship is retained
-- when the target gets closer or farther away.
local FinalOffset =
    Config.AimOffset * DistanceScale

return math.clamp(
    FinalOffset,
    Config.ThirdPersonMinOffset,
    Config.ThirdPersonMaxOffset
)

end

--==============================================================
-- AIM POSITION
--==============================================================

function S.GetAimPosition(Player)
local Character,
Humanoid,
Root =
S.GetCharacterData(Player)

if not Character
    or not Humanoid
    or not Root then

    return nil
end

if Config.CameraMode ==
    "First Person" then

    local Head =
        Character:FindFirstChild(
            "Head"
        )

    if Head then
        return S.GetPredictedPosition(
            Head.Position,
            Head.AssemblyLinearVelocity
        )
    end

    return S.GetPredictedPosition(
        Root.Position,
        Root.AssemblyLinearVelocity
    )
end

-- In third person, predict from the same upper-body anchor
-- used by the adaptive correction. Keeping both calculations
-- on the same point prevents the dot from separating from the
-- target when distance or movement changes.
local Head =
    Character:FindFirstChild("Head")

local AnchorPosition
local AnchorVelocity

if Head then
    local AnchorAlpha =
        math.clamp(
            Config.ThirdPersonAnchor,
            0,
            1
        )

    AnchorPosition =
        Root.Position:Lerp(
            Head.Position,
            AnchorAlpha
        )

    AnchorVelocity =
        Root.AssemblyLinearVelocity:Lerp(
            Head.AssemblyLinearVelocity,
            AnchorAlpha
        )
else
    AnchorPosition = Root.Position
    AnchorVelocity = Root.AssemblyLinearVelocity
end

local Predicted =
    S.GetPredictedPosition(
        AnchorPosition,
        AnchorVelocity
    )

if not Predicted then
    return nil
end

local Offset =
    tonumber(S.GetAdaptiveOffset(Root)) or 0

return Predicted -
    Vector3.new(
        0,
        Offset,
        0
    )

end

--==============================================================
-- STATUS
--==============================================================

function S.UpdateStatus()
if Locked
and LockedTarget then

    StatusLabel.Text =
        "LOCKED"

    StatusLabel.TextColor3 =
        RED

    TargetLabel.Text =
        "Target: " ..
        LockedTarget.Name
else
    StatusLabel.Text =
        "UNLOCKED"

    StatusLabel.TextColor3 =
        GRAY

    TargetLabel.Text =
        "Target: None"
end

end

--==============================================================
-- UNLOCK
--==============================================================

function S.Unlock()
Locked = false
LockedTarget = nil

S.UpdateStatus()

end

--==============================================================
-- LOCK
--==============================================================

function S.Lock()
if Locked then
S.Unlock()
return
end

local Target =
    S.FindTarget()

if not Target then
    S.UpdateStatus()
    return
end

if Config.AimbotWhitelistSkip
    and S.IsWhitelisted(Target) then

    return
end

if not S.IsTargetLockable(Target) then
    S.UpdateStatus()
    return
end

LockedTarget =
    Target

Locked = true

S.UpdateStatus()

end

--==============================================================
-- TARGET VALIDATION
--==============================================================

function S.IsTargetValid(Player)
if not Player then
return false
end

if Player.Parent ~= S.Players then
    return false
end

if Config.AimbotWhitelistSkip
    and S.IsWhitelisted(Player) then

    return false
end

local Character,
    Humanoid,
    Root =
    S.GetCharacterData(Player)

if Character == nil
    or Humanoid == nil
    or Root == nil then

    return false
end

-- Revalidate the active target against the same down/wall checks.
return S.IsTargetLockable(Player)

end

--==============================================================
-- CONTROLLER BUTTONS
--==============================================================

local SupportedButtons = {
[Enum.KeyCode.ButtonA] = true,
[Enum.KeyCode.ButtonB] = true,
[Enum.KeyCode.ButtonX] = true,
[Enum.KeyCode.ButtonY] = true,

[Enum.KeyCode.DPadUp] = true,
[Enum.KeyCode.DPadDown] = true,
[Enum.KeyCode.DPadLeft] = true,
[Enum.KeyCode.DPadRight] = true,

[Enum.KeyCode.ButtonL1] = true,
[Enum.KeyCode.ButtonR1] = true,

[Enum.KeyCode.ButtonSelect] = true,
[Enum.KeyCode.ButtonStart] = true,

[Enum.KeyCode.ButtonL3] = true,
[Enum.KeyCode.ButtonR3] = true,

[Enum.KeyCode.Thumbstick1] = true,
[Enum.KeyCode.Thumbstick2] = true,

[Enum.KeyCode.ButtonL2] = true,
[Enum.KeyCode.ButtonR2] = true,

}

--==============================================================
-- CONTROLLER INPUT
--==============================================================

Connect(
S.UserInputService.InputBegan,
function(Input, GameProcessed)

    if GameProcessed then
        return
    end

    if Input.UserInputType ~=
        Enum.UserInputType.Gamepad1 then

        return
    end

    -- REBIND
    if WaitingForButton then

        if SupportedButtons[
            Input.KeyCode
        ] then

            Config.LockButton =
                Input.KeyCode

            S.SaveSettings()

            LockButtonDisplay.Text =
                Input.KeyCode.Name

            WaitingForButton = false

            RebindButton.Text =
                "SET LOCK BUTTON"

            RebindButton.BackgroundColor3 =
                RED
        end

        return
    end

    -- LOCK
    if Input.KeyCode ==
        Config.LockButton then

        S.Lock()
    end
end

)

--==============================================================
-- REBIND
--==============================================================

RebindButton.Activated:Connect(function()
WaitingForButton =
not WaitingForButton

if WaitingForButton then
    RebindButton.Text =
        "PRESS CONTROLLER BUTTON..."

    RebindButton.BackgroundColor3 =
        DARK_RED
else
    RebindButton.Text =
        "SET LOCK BUTTON"

    RebindButton.BackgroundColor3 =
        RED
end

end)

--==============================================================
-- CLOSE
--==============================================================

CloseButton.Activated:Connect(function()
MainVisible = false

MainFrame.Visible =
    false

FloatingToggle.Text =
    "+"

end)

--==============================================================
-- FLOATING TOGGLE
--==============================================================

FloatingToggle.Activated:Connect(function()
MainVisible =
not MainVisible

MainFrame.Visible =
    MainVisible

if MainVisible then
    FloatingToggle.Text =
        "X"
else
    FloatingToggle.Text =
        "+"
end

end)

FloatingToggle.MouseEnter:Connect(function()
FloatingToggle.BackgroundColor3 =
LIGHT_DARK
end)

FloatingToggle.MouseLeave:Connect(function()
FloatingToggle.BackgroundColor3 =
BLACK
end)

--==============================================================
-- LOCAL CHARACTER
--==============================================================

Connect(
S.LocalPlayer.CharacterAdded,
function()
S.Unlock()
end
)

--==============================================================
-- CAMERA LOCK
--==============================================================

S.RunService:BindToRenderStep(
"XenonCameraLock",
Enum.RenderPriority.Last.Value,
function()

    if not Locked then
        return
    end

    if not S.IsTargetValid(
        LockedTarget
    ) then

        S.Unlock()
        return
    end

    local CurrentCamera =
        workspace.CurrentCamera

    if not CurrentCamera then
        return
    end

    local AimPosition =
        S.GetAimPosition(
            LockedTarget
        )

    if not AimPosition then
        S.Unlock()
        return
    end

    local CameraPosition =
        CurrentCamera.CFrame.Position

    local DesiredCFrame =
        CFrame.lookAt(
            CameraPosition,
            AimPosition
        )

    -- HARD LOCK
    if Config.Smoothing <= 0 then
        CurrentCamera.CFrame =
            DesiredCFrame

        return
    end

    -- SMOOTH LOCK
    local Smoothing = tonumber(Config.Smoothing) or 0

    local Alpha =
        math.clamp(
            1 /
            (
                Smoothing +
                1
            ),
            0,
            1
        )

    CurrentCamera.CFrame =
        CurrentCamera.CFrame:Lerp(
            DesiredCFrame,
            Alpha
        )
end

)

--==============================================================
-- DRAGGING
--==============================================================

local Dragging = false
local DragStart
local StartPosition

TopBar.InputBegan:Connect(function(Input)

if Input.UserInputType ==
    Enum.UserInputType.MouseButton1
    or
    Input.UserInputType ==
    Enum.UserInputType.Touch then

    Dragging = true

    DragStart =
        Input.Position

    StartPosition =
        MainFrame.Position

    local ChangedConnection

    ChangedConnection =
        Input.Changed:Connect(
            function()

                if Input.UserInputState ==
                    Enum.UserInputState.End then

                    Dragging = false

                    if ChangedConnection then
                        ChangedConnection:Disconnect()
                    end
                end
            end
        )
end

end)

Connect(
S.UserInputService.InputChanged,
function(Input)

    if not Dragging then
        return
    end

    if Input.UserInputType ~=
        Enum.UserInputType.MouseMovement
        and
        Input.UserInputType ~=
        Enum.UserInputType.Touch then

        return
    end

    local Delta =
        Input.Position -
        DragStart

    MainFrame.Position =
        UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset +
                Delta.X,

            StartPosition.Y.Scale,
            StartPosition.Y.Offset +
                Delta.Y
        )
end

)

--==============================================================
-- RESPONSIVE CAMERA
--==============================================================

S.UpdateResponsiveState()

S.Camera:GetPropertyChangedSignal("ViewportSize"):Connect(S.UpdateResponsiveState)

--==============================================================
-- CANVAS SIZE
--==============================================================

AimLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
S.UpdateTabCanvas(Scroll, AimLayout)
end)

VisualsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
S.UpdateTabCanvas(VisualsTab, VisualsLayout)
end)

WhitelistLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
S.UpdateTabCanvas(WhitelistTab, WhitelistLayout)
end)

SupportedLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
S.UpdateTabCanvas(SupportedTab, SupportedLayout)
end)

--==============================================================
RageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    S.UpdateTabCanvas(RageTab, RageLayout)
end)

--==============================================================
-- INITIAL ESP
--==============================================================

task.defer(function()
S.UpdateAllESP()
end)

S.RunLoadingStage(14, "Final performance check", function()
    assert(ScreenGui.Parent == S.PlayerGui, "Xenon GUI is not ready")
    assert(ActiveGameConfig, "Game configuration is not ready")
    assert(type(Whitelist) == "table", "Whitelist is not ready")
    assert(type(Connections) == "table", "Connections are not ready")
end)

--==============================================================
-- UI Z-ORDER SAFETY
--==============================================================
-- Use Global ZIndex and give every descendant a layer above its parent.
-- This prevents the black MainFrame from covering its own controls.
function S.RepairXenonZIndex()
MainFrame.ZIndex = 1

for _, Object in ipairs(MainFrame:GetDescendants()) do
    if Object:IsA("GuiObject") then
        local Depth = 1
        local Parent = Object.Parent

        while Parent and Parent ~= MainFrame do
            Depth += 1
            Parent = Parent.Parent
        end

        Object.ZIndex = 100 + (Depth * 10)
    end
end

-- Keep the floating reopen button above the window.
FloatingToggle.ZIndex = 1000000

end

S.RepairXenonZIndex()

--==============================================================
--==============================================================
-- SHARED AIM CALLBACKS / CLEANUP
--==============================================================

Shared.OnWhitelistChanged = function(Player, State)
    if State
        and Locked
        and LockedTarget == Player
        and Config.AimbotWhitelistSkip then
        Locked = false
        LockedTarget = nil
    end
end

Shared.Cleanup.Aim = function()
    pcall(function()
        S.RunService:UnbindFromRenderStep("XenonCameraLock")
    end)

    for Player in pairs(ESPObjects) do
        pcall(S.DestroyESP, Player)
    end

    Shared.Modules.AimLoaded = false
end

Shared.Cleanup.Full = function()
    if Shared.Cleanup.Rage then
        pcall(Shared.Cleanup.Rage)
    end
    if Shared.Cleanup.Whitelist then
        pcall(Shared.Cleanup.Whitelist)
    end
    if Shared.Cleanup.Aim then
        pcall(Shared.Cleanup.Aim)
    end
    pcall(DisconnectAll)

    local Gui = S.PlayerGui:FindFirstChild("Xenon")
    if Gui then
        Gui:Destroy()
    end

    Shared.Gui = nil
    Shared.MainFrame = nil
    Shared.Modules = {}
    _G.XenonShared = nil
    _G.XenonCleanup = nil
end

_G.XenonCleanup = Shared.Cleanup.Full

Shared.Modules.AimLoaded = true

if LoaderGui then
    LoaderGui:Destroy()
    LoaderGui = nil
end

S.RunLoadingStage(15, "Xenon AIM + ESP ready", function()
    ScreenGui.Enabled = true
    assert(type(Shared.Cleanup.Aim) == "function", "AIM cleanup is not registered")
end)

S.SaveSettings()
S.UpdateStatus()

print("======================================")
print("XENON AIM + ESP LOADED")
print("3P Offset:", Config.AimOffset)
print("S.Lock Button:", Config.LockButton.Name)
print("Sticky Aim:", Config.StickyAim)
print("Aimbot Whitelist Skip:", Config.AimbotWhitelistSkip)
print("ESP:", Config.ESPEnabled)
