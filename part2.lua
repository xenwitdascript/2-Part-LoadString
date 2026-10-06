--==============================================================
-- REGISTER-SAFE XENON SCRIPT 2
-- WHITELIST + RAGE
-- Top-level subsystem functions are stored on S rather than local
-- registers, and each heavy subsystem has its own function scope.
--==============================================================

local S = _G.XenonScript2State or {}
_G.XenonScript2State = S

--==============================================================
-- XENON SCRIPT 2
-- WHITELIST + RAGE
-- Attaches to Script 1 through _G.XenonShared.
--==============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Shared = _G.XenonShared or {}
_G.XenonShared = Shared
Shared.Version = Shared.Version or 3
Shared.Modules = Shared.Modules or {}
Shared.Cleanup = Shared.Cleanup or {}
Shared.UI = Shared.UI or {}
Shared.Whitelist = Shared.Whitelist or {}
Shared.Config = Shared.Config or {}

if Shared.Modules.WhitelistLoaded or Shared.Modules.RageLoaded then
    return
end

--==============================================================
-- SHARED SETTINGS / CONFIG
--==============================================================

local Config = Shared.Config

local RageDefaults = {
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

for Key, Value in pairs(RageDefaults) do
    if Config[Key] == nil then
        Config[Key] = Value
    end
end

local SaveSettings = Shared.SaveSettings

if type(SaveSettings) ~= "function" then
    local SettingsFileName =
        "XenonSettings_" .. tostring(LocalPlayer.UserId) .. ".json"

    SaveSettings = function()
        if type(writefile) ~= "function" then
            return
        end

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

        pcall(function()
            writefile(
                SettingsFileName,
                HttpService:JSONEncode(Data)
            )
        end)
    end

    Shared.SaveSettings = SaveSettings
end

local LoadSettings = Shared.LoadSettings

if type(LoadSettings) ~= "function" then
    local SettingsFileName =
        "XenonSettings_" .. tostring(LocalPlayer.UserId) .. ".json"

    LoadSettings = function()
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
            return HttpService:JSONDecode(Data)
        end)

        if not DecodeSuccess or type(Saved) ~= "table" then
            return
        end

        for Key, Value in pairs(Saved) do
            if Config[Key] ~= nil
                and type(Value) == type(Config[Key]) then
                Config[Key] = Value
            end
        end
    end

    Shared.LoadSettings = LoadSettings
end

if not Shared.Modules.AimLoaded then
    pcall(LoadSettings)
end

--==============================================================
-- WAIT FOR SCRIPT 1 / FALLBACK SHARED UI
--==============================================================

function S.HasSharedUI()
    return Shared.Gui
        and Shared.Gui.Parent
        and Shared.UI
        and type(Shared.UI.SetActiveTab) == "function"
        and type(Shared.UI.CreateSection) == "function"
        and type(Shared.UI.CreateRow) == "function"
end

local WaitStarted = os.clock()
while not S.HasSharedUI()
    and os.clock() - WaitStarted < 5 do
    task.wait(0.1)
end

function S.CreateFallbackUI()
    if S.HasSharedUI() then
        return
    end

    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Xenon"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.Parent = PlayerGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.fromScale(0.5, 0.5)
    MainFrame.Size = UDim2.fromOffset(470, 520)
    MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.fromOffset(14, 10)
    Title.Size = UDim2.new(1, -28, 0, 36)
    Title.Text = "XENON"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextColor3 = Color3.fromRGB(245, 245, 245)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = MainFrame

    local TabBar = Instance.new("Frame")
    TabBar.BackgroundColor3 = Color3.fromRGB(27, 27, 30)
    TabBar.BorderSizePixel = 0
    TabBar.Position = UDim2.fromOffset(10, 52)
    TabBar.Size = UDim2.new(1, -20, 0, 38)
    TabBar.Parent = MainFrame

    local TabBarCorner = Instance.new("UICorner")
    TabBarCorner.CornerRadius = UDim.new(0, 8)
    TabBarCorner.Parent = TabBar

    local TabList = Instance.new("UIListLayout")
    TabList.FillDirection = Enum.FillDirection.Horizontal
    TabList.Padding = UDim.new(0, 2)
    TabList.Parent = TabBar

    local Tabs = {}
    local Layouts = {}
    local Buttons = {}
    local Indicators = {}

    local function MakeTab(Name, Order)
        local Frame = Instance.new("ScrollingFrame")
        Frame.Name = "Tab" .. Name
        Frame.BackgroundTransparency = 1
        Frame.BorderSizePixel = 0
        Frame.Position = UDim2.fromOffset(10, 100)
        Frame.Size = UDim2.new(1, -20, 1, -110)
        Frame.ScrollBarThickness = 3
        Frame.Visible = false
        Frame.Parent = MainFrame

        local Padding = Instance.new("UIPadding")
        Padding.PaddingLeft = UDim.new(0, 5)
        Padding.PaddingRight = UDim.new(0, 5)
        Padding.PaddingTop = UDim.new(0, 3)
        Padding.PaddingBottom = UDim.new(0, 12)
        Padding.Parent = Frame

        local Layout = Instance.new("UIListLayout")
        Layout.Padding = UDim.new(0, 8)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Parent = Frame

        local Button = Instance.new("TextButton")
        Button.LayoutOrder = Order
        Button.Size = UDim2.new(1 / 5, -3, 1, 0)
        Button.BackgroundTransparency = 1
        Button.BorderSizePixel = 0
        Button.Text = Name
        Button.TextColor3 = Color3.fromRGB(150, 150, 155)
        Button.Font = Enum.Font.GothamSemibold
        Button.TextSize = 11
        Button.Parent = TabBar

        Tabs[Name] = Frame
        Layouts[Name] = Layout
        Buttons[Name] = Button
        return Frame, Layout, Button
    end

    local AimTab = MakeTab("AIM", 1)
    local VisualsTab = MakeTab("VISUALS", 2)
    local WhitelistTab = MakeTab("WHITELIST", 3)
    local SupportedTab = MakeTab("SUPPORTED", 4)
    local RageTab = MakeTab("RAGE", 5)

    local Current = nil

    local function SetActive(Name)
        local Target = Tabs[Name]
        if not Target then
            return
        end

        Current = Target

        for TabName, Frame in pairs(Tabs) do
            Frame.Visible = TabName == Name
            Buttons[TabName].TextColor3 =
                TabName == Name
                and Color3.fromRGB(245, 245, 245)
                or Color3.fromRGB(150, 150, 155)
        end
    end

    for Name, Button in pairs(Buttons) do
        Button.Activated:S.Connect(function()
            SetActive(Name)
        end)
    end

    local function CreateRow(Height)
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, 0, 0, Height)
        Row.BackgroundColor3 = Color3.fromRGB(27, 27, 30)
        Row.BorderSizePixel = 0
        Row.Parent = Current

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = Row
        return Row
    end

    local function CreateLabel(Parent, Text)
        local Label = Instance.new("TextLabel")
        Label.BackgroundTransparency = 1
        Label.Position = UDim2.fromOffset(10, 0)
        Label.Size = UDim2.new(0.55, 0, 1, 0)
        Label.Font = Enum.Font.GothamMedium
        Label.Text = Text
        Label.TextColor3 = Color3.fromRGB(235, 235, 238)
        Label.TextSize = 11
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Parent
        return Label
    end

    local function CreateSection(Text)
        local Label = Instance.new("TextLabel")
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(1, 0, 0, 26)
        Label.Font = Enum.Font.GothamBold
        Label.Text = Text
        Label.TextColor3 = Color3.fromRGB(230, 55, 55)
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Current
        return Label
    end

    local function CreateToggleRow(Text, GetValue, SetValue)
        local Row = CreateRow(44)
        CreateLabel(Row, Text)

        local Button = Instance.new("TextButton")
        Button.AnchorPoint = Vector2.new(1, 0.5)
        Button.Position = UDim2.new(1, -8, 0.5, 0)
        Button.Size = UDim2.fromOffset(70, 30)
        Button.Text = GetValue() and "ON" or "OFF"
        Button.Font = Enum.Font.GothamBold
        Button.TextSize = 10
        Button.TextColor3 = Color3.fromRGB(245, 245, 245)
        Button.BackgroundColor3 = Color3.fromRGB(45, 45, 48)
        Button.Parent = Row

        Button.Activated:S.Connect(function()
            local Value = not GetValue()
            SetValue(Value)
            Button.Text = Value and "ON" or "OFF"
        end)

        return Row, Button
    end

    local function CreateInputRow(Text, Value)
        local Row = CreateRow(44)
        CreateLabel(Row, Text)

        local Box = Instance.new("TextBox")
        Box.AnchorPoint = Vector2.new(1, 0.5)
        Box.Position = UDim2.new(1, -8, 0.5, 0)
        Box.Size = UDim2.fromOffset(100, 30)
        Box.Text = tostring(Value)
        Box.ClearTextOnFocus = false
        Box.Font = Enum.Font.GothamMedium
        Box.TextSize = 11
        Box.TextColor3 = Color3.fromRGB(245, 245, 245)
        Box.BackgroundColor3 = Color3.fromRGB(34, 34, 38)
        Box.Parent = Row
        return Row, Box
    end

    local function UpdateCanvas(Name)
        local Layout = Layouts[Name]
        local Frame = Tabs[Name]
        if Layout and Frame then
            Frame.CanvasSize =
                UDim2.fromOffset(0, Layout.AbsoluteContentSize.Y + 25)
        end
    end

    Shared.Gui = ScreenGui
    Shared.MainFrame = MainFrame
    Shared.TabBar = TabBar
    Shared.TabButtons = Buttons
    Shared.TabContainers = Tabs
    Shared.TabLayouts = Layouts

    Shared.UI.ScreenGui = ScreenGui
    Shared.UI.MainFrame = MainFrame
    Shared.UI.SetActiveTab = SetActive
    Shared.UI.UpdateTabCanvas = UpdateCanvas
    Shared.UI.CreateSection = CreateSection
    Shared.UI.CreateRow = CreateRow
    Shared.UI.CreateLabel = CreateLabel
    Shared.UI.CreateToggleRow = CreateToggleRow
    Shared.UI.CreateInputRow = CreateInputRow
    Shared.UI.IsMobile = function()
        return UserInputService.TouchEnabled
            and not UserInputService.KeyboardEnabled
    end
    Shared.UI.WhitelistTab = WhitelistTab
    Shared.UI.WhitelistLayout = Layouts.WHITELIST
    Shared.UI.RageTab = RageTab
    Shared.UI.RageLayout = Layouts.RAGE

    SetActive("AIM")
end

S.CreateFallbackUI()

local UI = Shared.UI
local CreateRow = UI.CreateRow
local CreateLabel = UI.CreateLabel
local CreateSection = UI.CreateSection
local CreateToggleRow = UI.CreateToggleRow
local CreateInputRow = UI.CreateInputRow
local SetActiveTab = UI.SetActiveTab

local IsMobile = UI.IsMobile and UI.IsMobile() or false

function S.Connect(Signal, Callback)
    return Signal:S.Connect(Callback)
end

local ModuleConnections = {}

function S.Track(Connection)
    if Connection then
        table.insert(ModuleConnections, Connection)
    end
    return Connection
end

--==============================================================
-- WHITELIST STORAGE
--==============================================================

local Whitelist = Shared.Whitelist
local WhitelistFileName = "XenonWhitelist.json"

function S.LoadWhitelist()
    table.clear(Whitelist)

    if type(isfile) ~= "function"
        or type(readfile) ~= "function" then
        return
    end

    local Success, Data = pcall(function()
        if not isfile(WhitelistFileName) then
            return nil
        end
        return readfile(WhitelistFileName)
    end)

    if not Success or not Data or Data == "" then
        return
    end

    local DecodeSuccess, Decoded = pcall(function()
        return HttpService:JSONDecode(Data)
    end)

    if not DecodeSuccess or type(Decoded) ~= "table" then
        return
    end

    for _, UserId in ipairs(Decoded) do
        local NumberId = tonumber(UserId)
        if NumberId then
            Whitelist[NumberId] = true
        end
    end
end

function S.SaveWhitelist()
    if type(writefile) ~= "function" then
        return
    end

    local Data = {}
    local Seen = {}

    for UserId, IsEnabled in pairs(Whitelist) do
        local NumberId = tonumber(UserId)
        if IsEnabled and NumberId and not Seen[NumberId] then
            Seen[NumberId] = true
            table.insert(Data, NumberId)
        end
    end

    table.sort(Data)

    pcall(function()
        writefile(
            WhitelistFileName,
            HttpService:JSONEncode(Data)
        )
    end)
end

function S.IsWhitelisted(Player)
    return Player
        and Whitelist[Player.UserId] == true
end

function S.SetWhitelist(Player, State)
    if not Player then
        return
    end

    if State then
        Whitelist[Player.UserId] = true
    else
        Whitelist[Player.UserId] = nil
    end

    S.SaveWhitelist()

    if Shared.OnWhitelistChanged then
        pcall(Shared.OnWhitelistChanged, Player, State)
    end
end

Shared.Whitelist = Whitelist
Shared.IsWhitelisted = S.IsWhitelisted
Shared.SetWhitelist = S.SetWhitelist

S.LoadWhitelist()

--==============================================================
-- WHITELIST UI
--==============================================================

SetActiveTab("WHITELIST")
CreateSection("WHITELIST")

local WhitelistInfoRow = CreateRow(45)
local WhitelistInfo = Instance.new("TextLabel")
WhitelistInfo.BackgroundTransparency = 1
WhitelistInfo.Position = UDim2.fromOffset(10, 4)
WhitelistInfo.Size = UDim2.new(1, -20, 1, -8)
WhitelistInfo.Font = Enum.Font.Gotham
WhitelistInfo.Text = "Tap a player to whitelist / unwhitelist them.\nRED = WHITELISTED"
WhitelistInfo.TextColor3 = Color3.fromRGB(150, 150, 155)
WhitelistInfo.TextSize = IsMobile and 9 or 10
WhitelistInfo.TextWrapped = true
WhitelistInfo.TextXAlignment = Enum.TextXAlignment.Left
WhitelistInfo.TextYAlignment = Enum.TextYAlignment.Center
WhitelistInfo.Parent = WhitelistInfoRow

local WhitelistContainer = Instance.new("Frame")
WhitelistContainer.Name = "WhitelistContainer"
WhitelistContainer.BackgroundTransparency = 1
WhitelistContainer.Size = UDim2.new(1, 0, 0, 10)
WhitelistContainer.Parent = UI.WhitelistTab

local PlayerListLayout = Instance.new("UIListLayout")
PlayerListLayout.Padding = UDim.new(0, 6)
PlayerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
PlayerListLayout.Parent = WhitelistContainer

function S.ClearWhitelistUI()
    for _, Child in ipairs(WhitelistContainer:GetChildren()) do
        if Child:IsA("GuiObject") then
            Child:Destroy()
        end
    end
end

function S.RefreshWhitelistUI()
    S.ClearWhitelistUI()

    local PlayerList = Players:GetPlayers()
    table.sort(
        PlayerList,
        function(A, B)
            return A.Name:lower() < B.Name:lower()
        end
    )

    for _, Player in ipairs(PlayerList) do
        if Player ~= LocalPlayer then
            local Entry = Instance.new("TextButton")
            Entry.Name = "Whitelist_" .. tostring(Player.UserId)
            Entry.Size = UDim2.new(1, 0, 0, 40)
            Entry.BackgroundColor3 =
                S.IsWhitelisted(Player)
                and Color3.fromRGB(225, 50, 50)
                or Color3.fromRGB(35, 35, 38)
            Entry.BorderSizePixel = 0
            Entry.Text =
                Player.DisplayName .. "  @" .. Player.Name
            Entry.TextColor3 = Color3.fromRGB(245, 245, 245)
            Entry.TextSize = IsMobile and 9 or 11
            Entry.Font = Enum.Font.GothamMedium
            Entry.TextXAlignment = Enum.TextXAlignment.Left
            Entry.AutoButtonColor = false
            Entry.Parent = WhitelistContainer

            local Padding = Instance.new("UIPadding")
            Padding.PaddingLeft = UDim.new(0, 12)
            Padding.Parent = Entry

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 8)
            Corner.Parent = Entry

            Entry.Activated:S.Connect(function()
                S.SetWhitelist(
                    Player,
                    not S.IsWhitelisted(Player)
                )
                Entry.BackgroundColor3 =
                    S.IsWhitelisted(Player)
                    and Color3.fromRGB(225, 50, 50)
                    or Color3.fromRGB(35, 35, 38)
            end)
        end
    end

    WhitelistContainer.Size =
        UDim2.new(1, 0, 0, PlayerListLayout.AbsoluteContentSize.Y)

    UI.UpdateTabCanvas(
        UI.WhitelistTab,
        UI.WhitelistLayout
    )
end

S.Track(
    Players.PlayerAdded:S.Connect(function()
        task.defer(S.RefreshWhitelistUI)
    end)
)

S.Track(
    Players.PlayerRemoving:S.Connect(function()
        task.defer(S.RefreshWhitelistUI)
    end)
)

S.Track(
    PlayerListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):S.Connect(function()
        WhitelistContainer.Size =
            UDim2.new(1, 0, 0, PlayerListLayout.AbsoluteContentSize.Y)
    end)
)

S.RefreshWhitelistUI()

--==============================================================
-- RAGE
--==============================================================

SetActiveTab("RAGE")

CreateSection("HITBOX EXTENDER")

--==============================================================
-- RAGE HELPERS
--==============================================================

local HitboxOriginals = {}
local HitboxRuntimeConnection = nil
local HitboxPlayerConnections = {}

local FlyConnection = nil
local FlyInputBeganConnection = nil
local FlyInputEndedConnection = nil
local FlyCharacterConnection = nil
local FlyOriginal = nil
local FlyKeys = {
    Up = false,
    Down = false,
}

local RapidFireConnection = nil
local RapidFireLastTool = nil

local RageDropdownOpen = nil

function S.GetHitboxPart(Character)
    if not Character then
        return nil
    end

    local Requested = Config.HitboxPart
    local Fallbacks = {
        Head = {"Head"},
        HumanoidRootPart = {"HumanoidRootPart"},
        UpperTorso = {"UpperTorso", "Torso"},
        LowerTorso = {"LowerTorso", "Torso", "UpperTorso"},
        Torso = {"Torso", "UpperTorso", "LowerTorso"},
        LeftUpperArm = {"LeftUpperArm", "Left Arm"},
        RightUpperArm = {"RightUpperArm", "Right Arm"},
        LeftUpperLeg = {"LeftUpperLeg", "Left Leg"},
        RightUpperLeg = {"RightUpperLeg", "Right Leg"},
    }

    local Names = Fallbacks[Requested] or {Requested}
    for _, Name in ipairs(Names) do
        local Part = Character:FindFirstChild(Name)
        if Part and Part:IsA("BasePart") then
            return Part
        end
    end

    return nil
end

function S.RestoreHitboxPart(Part)
    local Original = HitboxOriginals[Part]
    if not Original or not Part or not Part.Parent then
        HitboxOriginals[Part] = nil
        return
    end

    pcall(function()
        Part.Size = Original.Size
        Part.Transparency = Original.Transparency
        Part.CanCollide = Original.CanCollide
        Part.CanTouch = Original.CanTouch
        Part.CanQuery = Original.CanQuery
        Part.Massless = Original.Massless
    end)

    HitboxOriginals[Part] = nil
end

function S.RestoreAllHitboxes()
    for Part in pairs(HitboxOriginals) do
        S.RestoreHitboxPart(Part)
    end
    table.clear(HitboxOriginals)
end

function S.ShouldSkipHitbox(Player)
    if not Player or Player == LocalPlayer then
        return true
    end

    if Config.HitboxWhitelistSkip and S.IsWhitelisted(Player) then
        return true
    end

    if Config.HitboxFFCheck then
        local Character = Player.Character
        if Character and Character:FindFirstChildOfClass("ForceField") then
            return true
        end
    end

    return false
end

function S.ApplyHitbox(Player)
    if not Config.HitboxEnabled or S.ShouldSkipHitbox(Player) then
        return
    end

    local Character = Player.Character
    local Part = S.GetHitboxPart(Character)
    if not Part then
        return
    end

    if not HitboxOriginals[Part] then
        HitboxOriginals[Part] = {
            Size = Part.Size,
            Transparency = Part.Transparency,
            CanCollide = Part.CanCollide,
            CanTouch = Part.CanTouch,
            CanQuery = Part.CanQuery,
            Massless = Part.Massless,
        }
    end

    local Size = math.clamp(tonumber(Config.HitboxSize) or 10, 1, 50)

    pcall(function()
        Part.Size = Vector3.new(Size, Size, Size)
        Part.Transparency = Config.HitboxTransparent and 1
            or HitboxOriginals[Part].Transparency
        Part.CanCollide = false
        Part.CanTouch = true
        Part.CanQuery = true
        Part.Massless = true
    end)
end

function S.RefreshHitboxes()
    if not Config.HitboxEnabled then
        S.RestoreAllHitboxes()
        return
    end

    local ActiveParts = {}

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            local Character = Player.Character
            local Part = S.GetHitboxPart(Character)

            if Part and not S.ShouldSkipHitbox(Player) then
                ActiveParts[Part] = true
                S.ApplyHitbox(Player)
            end
        end
    end

    for Part in pairs(HitboxOriginals) do
        if not ActiveParts[Part] then
            S.RestoreHitboxPart(Part)
        end
    end
end

function S.StopHitboxExtender()
    if HitboxRuntimeConnection then
        pcall(function()
            HitboxRuntimeConnection:Disconnect()
        end)
        HitboxRuntimeConnection = nil
    end

    for _, Connection in pairs(HitboxPlayerConnections) do
        pcall(function()
            Connection:Disconnect()
        end)
    end
    table.clear(HitboxPlayerConnections)

    S.RestoreAllHitboxes()
end

function S.StartHitboxExtender()
    S.StopHitboxExtender()

    if not Config.HitboxEnabled then
        return
    end

    HitboxRuntimeConnection = S.Connect(
        RunService.Heartbeat,
        function()
            S.RefreshHitboxes()
        end
    )

    local function WatchPlayer(Player)
        if Player == LocalPlayer then
            return
        end

        if HitboxPlayerConnections[Player] then
            pcall(function()
                HitboxPlayerConnections[Player]:Disconnect()
            end)
        end

        HitboxPlayerConnections[Player] =
            Player.CharacterAdded:S.Connect(function()
                task.defer(function()
                    if Config.HitboxEnabled then
                        S.RefreshHitboxes()
                    end
                end)
            end)
    end

    for _, Player in ipairs(Players:GetPlayers()) do
        WatchPlayer(Player)
    end

    table.insert(
        HitboxPlayerConnections,
        Players.PlayerAdded:S.Connect(WatchPlayer)
    )

    S.RefreshHitboxes()
end

function S.SetHitboxEnabled(Value)
    Config.HitboxEnabled = Value
    SaveSettings()

    if Value then
        S.StartHitboxExtender()
    else
        S.StopHitboxExtender()
    end
end

function S.SetHitboxPart(Value)
    Config.HitboxPart = Value
    SaveSettings()

    if Config.HitboxEnabled then
        S.RefreshHitboxes()
    end
end

function S.SetHitboxSize(Value)
    local Number = tonumber(Value)
    if not Number then
        return false
    end

    Config.HitboxSize = math.clamp(Number, 1, 50)
    SaveSettings()

    if Config.HitboxEnabled then
        S.RefreshHitboxes()
    end

    return true
end

function S.RestoreFlyCharacter()
    if not FlyOriginal then
        return
    end

    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

    if Humanoid then
        pcall(function()
            Humanoid.AutoRotate = FlyOriginal.AutoRotate
            Humanoid.PlatformStand = FlyOriginal.PlatformStand
        end)
    end

    FlyOriginal = nil
end

function S.StopFly()
    if FlyConnection then
        pcall(function()
            FlyConnection:Disconnect()
        end)
        FlyConnection = nil
    end

    if FlyInputBeganConnection then
        pcall(function()
            FlyInputBeganConnection:Disconnect()
        end)
        FlyInputBeganConnection = nil
    end

    if FlyInputEndedConnection then
        pcall(function()
            FlyInputEndedConnection:Disconnect()
        end)
        FlyInputEndedConnection = nil
    end

    if FlyCharacterConnection then
        pcall(function()
            FlyCharacterConnection:Disconnect()
        end)
        FlyCharacterConnection = nil
    end

    FlyKeys.Up = false
    FlyKeys.Down = false
    S.RestoreFlyCharacter()
end

function S.StartFly()
    S.StopFly()

    if not Config.FlyEnabled then
        return
    end

    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")

    if not Character or not Humanoid or not Root then
        return
    end

    FlyOriginal = {
        AutoRotate = Humanoid.AutoRotate,
        PlatformStand = Humanoid.PlatformStand,
    }

    Humanoid.AutoRotate = false

    FlyInputBeganConnection = S.Connect(
        UserInputService.InputBegan,
        function(Input, GameProcessed)
            if GameProcessed then
                return
            end

            if Input.KeyCode == Enum.KeyCode.Space then
                FlyKeys.Up = true
            elseif Input.KeyCode == Enum.KeyCode.LeftControl
                or Input.KeyCode == Enum.KeyCode.RightControl then
                FlyKeys.Down = true
            end
        end
    )

    FlyInputEndedConnection = S.Connect(
        UserInputService.InputEnded,
        function(Input)
            if Input.KeyCode == Enum.KeyCode.Space then
                FlyKeys.Up = false
            elseif Input.KeyCode == Enum.KeyCode.LeftControl
                or Input.KeyCode == Enum.KeyCode.RightControl then
                FlyKeys.Down = false
            end
        end
    )

    FlyCharacterConnection = S.Connect(
        LocalPlayer.CharacterAdded,
        function()
            task.defer(function()
                if Config.FlyEnabled then
                    S.StartFly()
                end
            end)
        end
    )

    FlyConnection = S.Connect(
        RunService.RenderStepped,
        function(Delta)
            if not Config.FlyEnabled then
                return
            end

            local CurrentCharacter = LocalPlayer.Character
            local CurrentHumanoid =
                CurrentCharacter and CurrentCharacter:FindFirstChildOfClass("Humanoid")
            local CurrentRoot =
                CurrentCharacter and CurrentCharacter:FindFirstChild("HumanoidRootPart")

            if not CurrentHumanoid or not CurrentRoot then
                return
            end

            local CameraObject = workspace.CurrentCamera
            if not CameraObject then
                return
            end

            local MoveDirection = CurrentHumanoid.MoveDirection
            local CameraLook = CameraObject.CFrame.LookVector
            local CameraRight = CameraObject.CFrame.RightVector

            local Direction = Vector3.new(
                MoveDirection.X,
                0,
                MoveDirection.Z
            )

            local UpDown = 0
            if FlyKeys.Up then
                UpDown += 1
            end
            if FlyKeys.Down then
                UpDown -= 1
            end

            if UpDown ~= 0 then
                Direction += Vector3.new(0, UpDown, 0)
            end

            -- On keyboard/controller, allow camera-relative vertical
            -- flight while preserving ordinary Humanoid input.
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then
                Direction += Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
                Direction += Vector3.new(0, -1, 0)
            end

            local Horizontal = Vector3.new(
                CameraLook.X,
                0,
                CameraLook.Z
            )

            local HorizontalRight = Vector3.new(
                CameraRight.X,
                0,
                CameraRight.Z
            )

            if MoveDirection.Magnitude > 0.01 then
                local LocalX = MoveDirection:Dot(HorizontalRight)
                local LocalZ = MoveDirection:Dot(Horizontal)
                Direction = (
                    HorizontalRight * LocalX
                    + Horizontal * LocalZ
                )
            end

            if Direction.Magnitude > 1 then
                Direction = Direction.Unit
            end

            local Speed = math.clamp(
                tonumber(Config.FlySpeed) or 60,
                1,
                500
            )

            local Step = Direction * Speed * math.min(Delta, 0.05)

            -- CFrame is the primary movement mechanism. No
            -- BodyVelocity, LinearVelocity, or VectorForce is used.
            CurrentRoot.CFrame =
                CurrentRoot.CFrame + Step
        end
    )
end

function S.SetFlyEnabled(Value)
    Config.FlyEnabled = Value
    SaveSettings()

    if Value then
        S.StartFly()
    else
        S.StopFly()
    end
end

function S.SetFlySpeed(Value)
    local Number = tonumber(Value)
    if not Number then
        return false
    end

    Config.FlySpeed = math.clamp(Number, 1, 500)
    SaveSettings()
    return true
end

--==============================================================
-- RAPID FIRE
--==============================================================

function S.GetEquippedTool()
    local Character = LocalPlayer.Character
    if not Character then
        return nil
    end

    for _, Object in ipairs(Character:GetChildren()) do
        if Object:IsA("Tool") then
            return Object
        end
    end

    return nil
end

function S.GetRemoteCandidates(Tool)
    local Candidates = {}

    if not Tool then
        return Candidates
    end

    local PreferredNames = {
        "Fire",
        "Shoot",
        "ShootEvent",
        "FireEvent",
        "RemoteEvent",
        "Activate",
        "Attack",
        "Use",
    }

    for _, Name in ipairs(PreferredNames) do
        local Object = Tool:FindFirstChild(Name, true)
        if Object and (
            Object:IsA("RemoteEvent")
            or Object:IsA("RemoteFunction")
        ) then
            table.insert(Candidates, Object)
        end
    end

    for _, Object in ipairs(Tool:GetDescendants()) do
        if Object:IsA("RemoteEvent")
            or Object:IsA("RemoteFunction") then

            local Exists = false
            for _, Existing in ipairs(Candidates) do
                if Existing == Object then
                    Exists = true
                    break
                end
            end

            if not Exists then
                table.insert(Candidates, Object)
            end
        end
    end

    return Candidates
end

function S.RapidMethodToolActivate(Tool)
    if not Tool or not Tool:IsA("Tool") then
        return false
    end

    local Success = pcall(function()
        Tool:Activate()
    end)

    return Success
end

function S.RapidMethodRemoteNoArgs(Tool)
    local Candidates = S.GetRemoteCandidates(Tool)

    for _, Remote in ipairs(Candidates) do
        local Success = pcall(function()
            if Remote:IsA("RemoteEvent") then
                Remote:FireServer()
            else
                Remote:InvokeServer()
            end
        end)

        if Success then
            return true
        end
    end

    return false
end

function S.RapidMethodRemoteTool(Tool)
    local Candidates = S.GetRemoteCandidates(Tool)

    for _, Remote in ipairs(Candidates) do
        local Success = pcall(function()
            if Remote:IsA("RemoteEvent") then
                Remote:FireServer(Tool)
            else
                Remote:InvokeServer(Tool)
            end
        end)

        if Success then
            return true
        end
    end

    return false
end

local RapidMethods = {
    ["Method 1"] = S.RapidMethodToolActivate,
    ["Method 2"] = S.RapidMethodRemoteNoArgs,
    ["Method 3"] = S.RapidMethodRemoteTool,
}

function S.RunRapidFireMethod(Tool, MethodName)
    if not Tool then
        return false
    end

    if MethodName == "Auto / Best Method" then
        -- Prefer normal Tool activation first, then fall back to
        -- generic remote-based methods if the weapon exposes them.
        if S.RapidMethodToolActivate(Tool) then
            return true
        end

        if S.RapidMethodRemoteNoArgs(Tool) then
            return true
        end

        return S.RapidMethodRemoteTool(Tool)
    end

    local Method = RapidMethods[MethodName]
    if not Method then
        return false
    end

    local Success, Result = pcall(Method, Tool)
    return Success and Result == true
end

function S.StopRapidFire()
    if RapidFireConnection then
        pcall(function()
            RapidFireConnection:Disconnect()
        end)
        RapidFireConnection = nil
    end

    RapidFireLastTool = nil
end

function S.StartRapidFire()
    S.StopRapidFire()

    if not Config.RapidFireEnabled then
        return
    end

    RapidFireConnection = S.Connect(
        RunService.Heartbeat,
        function()
            local Tool = S.GetEquippedTool()

            if not Tool then
                RapidFireLastTool = nil
                return
            end

            RapidFireLastTool = Tool

            -- A very small interval is intentionally not hard-coded;
            -- Heartbeat naturally follows the client's frame/update rate.
            -- The selected method determines the actual firing path.
            S.RunRapidFireMethod(
                Tool,
                Config.RapidFireMethod
            )
        end
    )
end

function S.SetRapidFireEnabled(Value)
    Config.RapidFireEnabled = Value
    SaveSettings()

    if Value then
        S.StartRapidFire()
    else
        S.StopRapidFire()
    end
end

function S.SetRapidFireMethod(Value)
    Config.RapidFireMethod = Value
    SaveSettings()

    if Config.RapidFireEnabled then
        S.StartRapidFire()
    end
end

--==============================================================
-- HITBOX EXTENDER UI
--==============================================================

local HitboxEnabledRow, HitboxEnabledButton =
CreateToggleRow(
    "Enabled",
    function()
        return Config.HitboxEnabled
    end,
    function(Value)
        S.SetHitboxEnabled(Value)
    end
)

local HitboxTransparentRow, HitboxTransparentButton =
CreateToggleRow(
    "Transparent",
    function()
        return Config.HitboxTransparent
    end,
    function(Value)
        Config.HitboxTransparent = Value
        SaveSettings()
        if Config.HitboxEnabled then
            S.RefreshHitboxes()
        end
    end
)

local HitboxWhitelistRow, HitboxWhitelistButton =
CreateToggleRow(
    "Whitelist Skip",
    function()
        return Config.HitboxWhitelistSkip
    end,
    function(Value)
        Config.HitboxWhitelistSkip = Value
        SaveSettings()
        if Config.HitboxEnabled then
            S.RefreshHitboxes()
        end
    end
)

local HitboxSizeRow, HitboxSizeBox =
CreateInputRow(
    "Size",
    Config.HitboxSize
)

HitboxSizeBox.FocusLost:S.Connect(function()
    local Number = tonumber(HitboxSizeBox.Text)

    if Number then
        Number = math.clamp(Number, 1, 50)
        Config.HitboxSize = Number
        SaveSettings()

        if Config.HitboxEnabled then
            S.RefreshHitboxes()
        end

        HitboxSizeBox.Text = tostring(Number)
    else
        HitboxSizeBox.Text = tostring(Config.HitboxSize)
    end
end)

function S.CreateRageDropdownRow(LabelText, Options, GetValue, SetValue)
    local Row = CreateRow(44)

    CreateLabel(Row, LabelText)

    local Button = Instance.new("TextButton")
    Button.AnchorPoint = Vector2.new(1, 0.5)
    Button.Position = UDim2.new(1, -8, 0.5, 0)
    Button.Size = UDim2.new(0.50, 0, 0, 30)
    Button.BackgroundColor3 = DARKER
    Button.BorderSizePixel = 0
    Button.Text = tostring(GetValue())
    Button.TextColor3 = WHITE
    Button.TextSize = IsMobile and 9 or 11
    Button.Font = Enum.Font.GothamMedium
    Button.AutoButtonColor = false
    Button.ZIndex = 13
    Button.Parent = Row

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Button

    local OptionsFrame = Instance.new("Frame")
    OptionsFrame.Visible = false
    OptionsFrame.AnchorPoint = Vector2.new(1, 0)
    OptionsFrame.Position = UDim2.new(1, -8, 1, 3)
    OptionsFrame.Size = UDim2.new(0.50, 0, 0, math.min(#Options * 30, 180))
    OptionsFrame.BackgroundColor3 = DARKER
    OptionsFrame.BorderSizePixel = 0
    OptionsFrame.ZIndex = 60
    OptionsFrame.Parent = Row

    local OptionsCorner = Instance.new("UICorner")
    OptionsCorner.CornerRadius = UDim.new(0, 6)
    OptionsCorner.Parent = OptionsFrame

    local OptionsLayout = Instance.new("UIListLayout")
    OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    OptionsLayout.Parent = OptionsFrame

    local function Close()
        OptionsFrame.Visible = false
        if RageDropdownOpen == OptionsFrame then
            RageDropdownOpen = nil
        end
    end

    for Index, OptionText in ipairs(Options) do
        local Option = Instance.new("TextButton")
        Option.LayoutOrder = Index
        Option.Size = UDim2.new(1, 0, 0, 30)
        Option.BackgroundTransparency = 1
        Option.BorderSizePixel = 0
        Option.Text = OptionText
        Option.TextColor3 = WHITE
        Option.TextSize = IsMobile and 8 or 10
        Option.Font = Enum.Font.Gotham
        Option.AutoButtonColor = false
        Option.ZIndex = 61
        Option.Parent = OptionsFrame

        Option.Activated:S.Connect(function()
            SetValue(OptionText)
            Button.Text = tostring(GetValue())
            Close()
        end)
    end

    Button.Activated:S.Connect(function()
        if RageDropdownOpen and RageDropdownOpen ~= OptionsFrame then
            RageDropdownOpen.Visible = false
        end

        OptionsFrame.Visible = not OptionsFrame.Visible
        RageDropdownOpen =
            OptionsFrame.Visible and OptionsFrame or nil
    end)

    return Row, Button
end

local HitboxPartOptions = {
    "Head",
    "HumanoidRootPart",
    "UpperTorso",
    "LowerTorso",
    "Torso",
    "LeftUpperArm",
    "RightUpperArm",
    "LeftUpperLeg",
    "RightUpperLeg",
}

local HitboxPartRow, HitboxPartButton =
S.CreateRageDropdownRow(
    "Part",
    HitboxPartOptions,
    function()
        return Config.HitboxPart
    end,
    function(Value)
        S.SetHitboxPart(Value)
    end
)

local HitboxFFRow, HitboxFFButton =
CreateToggleRow(
    "FF Check",
    function()
        return Config.HitboxFFCheck
    end,
    function(Value)
        Config.HitboxFFCheck = Value
        SaveSettings()
        if Config.HitboxEnabled then
            S.RefreshHitboxes()
        end
    end
)

--==============================================================
-- FLY UI
--==============================================================

CreateSection("FLY")

local FlyEnabledRow, FlyEnabledButton =
CreateToggleRow(
    "Enabled",
    function()
        return Config.FlyEnabled
    end,
    function(Value)
        S.SetFlyEnabled(Value)
    end
)

local FlySpeedRow, FlySpeedBox =
CreateInputRow(
    "Speed",
    Config.FlySpeed
)

FlySpeedBox.FocusLost:S.Connect(function()
    local Number = tonumber(FlySpeedBox.Text)

    if Number then
        Number = math.clamp(Number, 1, 500)
        Config.FlySpeed = Number
        SaveSettings()
        FlySpeedBox.Text = tostring(Number)
    else
        FlySpeedBox.Text = tostring(Config.FlySpeed)
    end
end)

--==============================================================
-- RAPID FIRE UI
--==============================================================

CreateSection("RAPID FIRE")

local RapidFireEnabledRow, RapidFireEnabledButton =
CreateToggleRow(
    "Enabled",
    function()
        return Config.RapidFireEnabled
    end,
    function(Value)
        S.SetRapidFireEnabled(Value)
    end
)

local RapidFireMethodOptions = {
    "Auto / Best Method",
    "Method 1",
    "Method 2",
    "Method 3",
}

local RapidFireMethodRow, RapidFireMethodButton =
S.CreateRageDropdownRow(
    "Method",
    RapidFireMethodOptions,
    function()
        return Config.RapidFireMethod
    end,
    function(Value)
        S.SetRapidFireMethod(Value)
    end
)

-- Normalize saved values that predate the RAGE tab or were edited
-- manually, without changing the existing settings architecture.
if not table.find(HitboxPartOptions, Config.HitboxPart) then
    Config.HitboxPart = "Head"
end

if not table.find(RapidFireMethodOptions, Config.RapidFireMethod) then
    Config.RapidFireMethod = "Auto / Best Method"
end

Config.HitboxSize =
    math.clamp(tonumber(Config.HitboxSize) or 10, 1, 50)

Config.FlySpeed =
    math.clamp(tonumber(Config.FlySpeed) or 60, 1, 500)

HitboxSizeBox.Text = tostring(Config.HitboxSize)
FlySpeedBox.Text = tostring(Config.FlySpeed)
HitboxPartButton.Text = Config.HitboxPart
RapidFireMethodButton.Text = Config.RapidFireMethod

SaveSettings()

--==============================================================
-- RAGE STARTUP
--==============================================================

if Config.HitboxEnabled then
    task.defer(S.StartHitboxExtender)
end

if Config.FlyEnabled then
    task.defer(S.StartFly)
end

if Config.RapidFireEnabled then
    task.defer(S.StartRapidFire)
end

--==============================================================
-- END RAGE
--==============================================================

--==============================================================

--==============================================================
-- RAGE / WHITELIST CLEANUP
--==============================================================

Shared.Cleanup.Whitelist = function()
    for Index, Connection in ipairs(ModuleConnections) do
        pcall(function()
            Connection:Disconnect()
        end)
        ModuleConnections[Index] = nil
    end

    if WhitelistContainer and WhitelistContainer.Parent then
        WhitelistContainer:Destroy()
    end

    Shared.Modules.WhitelistLoaded = false
end

Shared.Cleanup.Rage = function()
    pcall(S.StopHitboxExtender)
    pcall(S.StopFly)
    pcall(S.StopRapidFire)
    Shared.Modules.RageLoaded = false
end

Shared.Modules.WhitelistLoaded = true
Shared.Modules.RageLoaded = true

-- Keep one active Xenon interface. Script 1 owns the main GUI.
SetActiveTab("AIM")

SaveSettings()
print("XENON WHITELIST + RAGE LOADED")
print("Hitbox Extender:", Config.HitboxEnabled)
print("Fly:", Config.FlyEnabled)
print("Rapid Fire:", Config.RapidFireEnabled)
