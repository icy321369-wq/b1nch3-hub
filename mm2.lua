--!nocheck
-- ==============================================================================
-- B1NCH3 MM2 APEX :: FREE COMMUNITY EDITION (v6.5 MASTER COMBAT & PHYSICS BUILD)
-- Target: Murder Mystery 2 (PlaceId: 142823291, Nikilis)
-- Environment: MacSploit / Universal Luau Executor
-- UI Framework: Fluent Interface Suite (Acrylic Glassmorphism by dawid)
-- Security Gateway: REMOVED (100% Free Instant Execution)
-- Dynamic Typography: Real-time UI Font Engine (Ubuntu default, live selector)
-- Mobile Architecture: Auto-device detection, responsive viewport clamping, draggable touch toggle button
-- Architecture: Universal Silent Aim & Kill Aura (All Roles: Sheriff, Innocent, Murderer),
--               High-Torque God Fling & Walk Touch-Fling, Streamlined Selection Tabs,
--               Kick-Proof Physical Coin Auto-Farm, Hitbox Expander, Dropped Gun Snatcher
-- Official Community: https://discord.gg/JSUbVWTYc
-- Developer: B1NCH3
-- ==============================================================================

if _G.MM2SuiteLoaded and _G.MM2SuiteCleanup then
    pcall(_G.MM2SuiteCleanup)
end
_G.MM2SuiteLoaded = true

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local function SafeParent()
    if gethui then return gethui() end
    return CoreGui
end

local function SafeCopy(text)
    if setclipboard then
        setclipboard(text)
    elseif toclipboard then
        toclipboard(text)
    elseif writeclipboard then
        writeclipboard(text)
    end
end

-- ==============================================================================
-- 1. DYNAMIC TYPOGRAPHY & FONT ENGINE
-- ==============================================================================
local AVAILABLE_FONTS = {
    ["Ubuntu"] = Enum.Font.Ubuntu,
    ["Montserrat"] = Enum.Font.Montserrat,
    ["BuilderSans"] = Enum.Font.BuilderSans,
    ["FredokaOne"] = Enum.Font.FredokaOne,
    ["JosefinSans"] = Enum.Font.JosefinSans,
    ["Michroma"] = Enum.Font.Michroma,
    ["SourceSansBold"] = Enum.Font.SourceSansBold,
    ["GothamBold"] = Enum.Font.GothamBold,
}

local CurrentFont = Enum.Font.Ubuntu

local FontEngine = {}
FontEngine.WatchedGuis = {}

function FontEngine:ApplyFont(fontEnum)
    CurrentFont = fontEnum
    for _, gui in ipairs(FontEngine.WatchedGuis) do
        if gui and gui.Parent then
            for _, d in ipairs(gui:GetDescendants()) do
                if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
                    pcall(function()
                        d.Font = CurrentFont
                    end)
                end
            end
        end
    end
end

function FontEngine:RegisterGui(gui)
    table.insert(FontEngine.WatchedGuis, gui)
    for _, d in ipairs(gui:GetDescendants()) do
        if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
            pcall(function()
                d.Font = CurrentFont
            end)
        end
    end
    gui.DescendantAdded:Connect(function(d)
        if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
            pcall(function()
                d.Font = CurrentFont
            end)
        end
    end)
end

task.defer(function()
    for _, g in ipairs(CoreGui:GetChildren()) do
        if g:IsA("ScreenGui") and (g.Name == "ScreenGui" or g.Name:find("Fluent")) then
            FontEngine:RegisterGui(g)
        end
    end
    CoreGui.ChildAdded:Connect(function(g)
        if g:IsA("ScreenGui") then
            task.wait(0.1)
            FontEngine:RegisterGui(g)
        end
    end)
end)

local function DestroyExistingFluentAndHUD()
    for _, parent in ipairs({CoreGui, gethui and gethui(), LocalPlayer:FindFirstChild("PlayerGui")}) do
        if parent then
            for _, child in ipairs(parent:GetChildren()) do
                if child:IsA("ScreenGui") and (child.Name == "ScreenGui" or child.Name:find("Fluent") or child.Name:find("B1nch3") or child.Name:find("B1NCH3") or child.Name:find("IslandHUD")) then
                    pcall(function() child:Destroy() end)
                end
            end
        end
    end
end
DestroyExistingFluentAndHUD()

-- ==============================================================================
-- 2. CONFIGURATION STORE & STATE
-- ==============================================================================
local Config = {
    Combat = {
        HitboxExpander = false,
        HitboxSize = 16,
        MurdererKillAura = false,
        MurdererAuraRange = 22,
        ShooterSilentAim = false,
        PredictMovement = true,
        ShooterAimRange = 350,
        InstantGrabGun = false,
        InstantGrabGunKeybind = "G",
    },
    Fling = {
        TouchFling = false,
        FlingDuration = 1.5,
        FlingPower = 50,
        SelectedPlayer = nil,
    },
    ESP = {
        Enabled = false,
        Names = true,
        Distance = true,
        Roles = true,
        GunDrop = false,
        Coins = false,
        Traps = false,
    },
    AutoFarm = {
        Enabled = false,
        Mode = "Tween", -- "Tween" or "Instant"
        Speed = 26,
        InstantDelay = 0.20,
        AvoidMurderer = false,
        ReturnOnFull = true,
        AutoGrabGun = false,
    },
    Movement = {
        FlyEnabled = false,
        FlySpeed = 50,
        Noclip = false,
        NoclipKeybind = "N",
        InfJump = false,
        SpeedEnabled = false,
        WalkSpeed = 24,
        JumpEnabled = false,
        JumpPower = 70,
        BunnyHop = false,
    },
    Defense = {
        AntiStab = false,
        EvadeDistance = 14,
        AntiFling = false,
        TrapDisarmer = false,
        GhostMode = false,
    },
    Visuals = {
        Fullbright = false,
    },
    Emotes = {
        SelectedEmote = "ninja",
    },
    Security = {
        DiscordInvite = "https://discord.gg/JSUbVWTYc",
    },
    UI = {
        ActiveFontName = "Ubuntu",
    }
}

local DefaultLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
}

local State = {
    Murderer = nil,
    Sheriff = nil,
    Hero = nil,
    OriginalSheriff = nil,
    GunDroppedOnce = false,
    LastInMapState = false,
    GunDrop = nil,
    FlyBodyVelocity = nil,
    FlyBodyGyro = nil,
    OriginalHitboxes = {},
    AntiAfkConnected = false,
    ActiveFarmTween = nil,
    SelectedFlingPlayer = nil,
    SelectedTeleportPlayer = nil,
    ServerRoleData = {},
    CollectedCoins = {},
    CoinCooldowns = {},
    BagFull = false,
    CurrentCoins = 0,
    MaxCoins = 40,
}

local InitFluentSuite

-- ==============================================================================
-- 3. DEVICE TELEMETRY & 5-MINUTE COMMUNITY ENGAGEMENT PROMPT
-- ==============================================================================
local function IsMobileDevice()
    local isTouch = UserInputService.TouchEnabled
    local hasKeyboard = UserInputService.KeyboardEnabled
    local vp = Camera.ViewportSize
    return (isTouch and not hasKeyboard) or (isTouch and (vp.X < 760 or vp.Y < 560))
end

local function ShowDiscordCommunityPrompt(Fluent)
    pcall(function()
        if Fluent and Fluent.Notify then
            Fluent:Notify({
                Title = "Join Our Discord Server!",
                Content = "Join our discord server for more scripts!\nhttps://discord.gg/JSUbVWTYc",
                Duration = 20
            })
        end

        local promptGui = Instance.new("ScreenGui")
        promptGui.Name = "B1nch3_CommunityPrompt"
        promptGui.ResetOnSpawn = false
        promptGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        promptGui.DisplayOrder = 999999
        promptGui.Parent = SafeParent()

        local modal = Instance.new("Frame")
        modal.Name = "FluentDiscordModal"
        modal.Size = UDim2.new(0, 410, 0, 175)
        modal.Position = UDim2.new(0.5, -205, 0, -210)
        modal.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
        modal.BorderSizePixel = 0
        modal.ClipsDescendants = true
        modal.Parent = promptGui

        local mCorner = Instance.new("UICorner")
        mCorner.CornerRadius = UDim.new(0, 8)
        mCorner.Parent = modal

        local mStroke = Instance.new("UIStroke")
        mStroke.Color = Color3.fromRGB(48, 48, 58)
        mStroke.Thickness = 1
        mStroke.Parent = modal

        -- Header Bar (Fluent Style)
        local header = Instance.new("Frame")
        header.Name = "Header"
        header.Size = UDim2.new(1, 0, 0, 36)
        header.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
        header.BorderSizePixel = 0
        header.Parent = modal

        local hSep = Instance.new("Frame")
        hSep.Size = UDim2.new(1, 0, 0, 1)
        hSep.Position = UDim2.new(0, 0, 1, -1)
        hSep.BackgroundColor3 = Color3.fromRGB(42, 42, 50)
        hSep.BorderSizePixel = 0
        hSep.Parent = header

        local hIcon = Instance.new("TextLabel")
        hIcon.Size = UDim2.new(0, 26, 1, 0)
        hIcon.Position = UDim2.new(0, 12, 0, 0)
        hIcon.Text = "⚡"
        hIcon.Font = Enum.Font.Ubuntu
        hIcon.TextSize = 14
        hIcon.TextColor3 = Color3.fromRGB(0, 220, 160)
        hIcon.BackgroundTransparency = 1
        hIcon.Parent = header

        local hTitle = Instance.new("TextLabel")
        hTitle.Size = UDim2.new(1, -75, 1, 0)
        hTitle.Position = UDim2.new(0, 38, 0, 0)
        hTitle.Text = "MM2 SUITE • COMMUNITY"
        hTitle.Font = Enum.Font.Ubuntu
        hTitle.TextSize = 11.5
        hTitle.TextColor3 = Color3.fromRGB(240, 240, 245)
        hTitle.TextXAlignment = Enum.TextXAlignment.Left
        hTitle.BackgroundTransparency = 1
        hTitle.Parent = header

        local closeBtn = Instance.new("TextButton")
        closeBtn.Name = "CloseBtn"
        closeBtn.Size = UDim2.new(0, 24, 0, 24)
        closeBtn.Position = UDim2.new(1, -32, 0.5, -12)
        closeBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
        closeBtn.Text = "✕"
        closeBtn.Font = Enum.Font.Ubuntu
        closeBtn.TextSize = 11
        closeBtn.TextColor3 = Color3.fromRGB(160, 160, 175)
        closeBtn.AutoButtonColor = true
        closeBtn.Parent = header

        local cCorner = Instance.new("UICorner")
        cCorner.CornerRadius = UDim.new(0, 4)
        cCorner.Parent = closeBtn

        -- Body Content
        local body = Instance.new("Frame")
        body.Name = "Body"
        body.Size = UDim2.new(1, 0, 1, -36)
        body.Position = UDim2.new(0, 0, 0, 36)
        body.BackgroundTransparency = 1
        body.Parent = modal

        local mainText = Instance.new("TextLabel")
        mainText.Size = UDim2.new(1, -28, 0, 20)
        mainText.Position = UDim2.new(0, 14, 0, 12)
        mainText.Text = "Enjoying the script?"
        mainText.Font = Enum.Font.Ubuntu
        mainText.TextSize = 15
        mainText.TextColor3 = Color3.fromRGB(255, 255, 255)
        mainText.TextXAlignment = Enum.TextXAlignment.Left
        mainText.BackgroundTransparency = 1
        mainText.Parent = body

        local subText = Instance.new("TextLabel")
        subText.Size = UDim2.new(1, -28, 0, 18)
        subText.Position = UDim2.new(0, 14, 0, 33)
        subText.Text = "Join our discord server for more scripts!"
        subText.Font = Enum.Font.Ubuntu
        subText.TextSize = 13
        subText.TextColor3 = Color3.fromRGB(180, 185, 200)
        subText.TextXAlignment = Enum.TextXAlignment.Left
        subText.BackgroundTransparency = 1
        subText.Parent = body

        local linkPill = Instance.new("Frame")
        linkPill.Size = UDim2.new(1, -28, 0, 24)
        linkPill.Position = UDim2.new(0, 14, 0, 56)
        linkPill.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
        linkPill.BorderSizePixel = 0
        linkPill.Parent = body

        local pCorner = Instance.new("UICorner")
        pCorner.CornerRadius = UDim.new(0, 4)
        pCorner.Parent = linkPill

        local pStroke = Instance.new("UIStroke")
        pStroke.Color = Color3.fromRGB(36, 36, 44)
        pStroke.Thickness = 0.8
        pStroke.Parent = linkPill

        local linkLabel = Instance.new("TextLabel")
        linkLabel.Size = UDim2.new(1, -16, 1, 0)
        linkLabel.Position = UDim2.new(0, 8, 0, 0)
        linkLabel.Text = Config.Security.DiscordInvite
        linkLabel.Font = Enum.Font.Ubuntu
        linkLabel.TextSize = 11.5
        linkLabel.TextColor3 = Color3.fromRGB(88, 101, 242)
        linkLabel.TextXAlignment = Enum.TextXAlignment.Left
        linkLabel.BackgroundTransparency = 1
        linkLabel.Parent = linkPill

        -- Action Buttons
        local copyBtn = Instance.new("TextButton")
        copyBtn.Name = "CopyBtn"
        copyBtn.Size = UDim2.new(0, 145, 0, 30)
        copyBtn.Position = UDim2.new(1, -159, 1, -38)
        copyBtn.BackgroundColor3 = Color3.fromRGB(0, 190, 130)
        copyBtn.Text = "Copy Discord Link"
        copyBtn.Font = Enum.Font.Ubuntu
        copyBtn.TextSize = 12
        copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        copyBtn.AutoButtonColor = true
        copyBtn.Parent = body

        local btnCorn = Instance.new("UICorner")
        btnCorn.CornerRadius = UDim.new(0, 5)
        btnCorn.Parent = copyBtn

        local dismissBtn = Instance.new("TextButton")
        dismissBtn.Name = "DismissBtn"
        dismissBtn.Size = UDim2.new(0, 85, 0, 30)
        dismissBtn.Position = UDim2.new(1, -253, 1, -38)
        dismissBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
        dismissBtn.Text = "Dismiss"
        dismissBtn.Font = Enum.Font.Ubuntu
        dismissBtn.TextSize = 12
        dismissBtn.TextColor3 = Color3.fromRGB(180, 180, 195)
        dismissBtn.AutoButtonColor = true
        dismissBtn.Parent = body

        local disCorn = Instance.new("UICorner")
        disCorn.CornerRadius = UDim.new(0, 5)
        disCorn.Parent = dismissBtn

        local disStroke = Instance.new("UIStroke")
        disStroke.Color = Color3.fromRGB(48, 48, 60)
        disStroke.Thickness = 0.8
        disStroke.Parent = dismissBtn

        -- Smooth slide down entrance animation
        TweenService:Create(modal, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, -205, 0.12, 0)
        }):Play()

        local function CloseModal()
            local closeTween = TweenService:Create(modal, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, -205, 0, -220)
            })
            closeTween:Play()
            closeTween.Completed:Connect(function()
                if promptGui and promptGui.Parent then promptGui:Destroy() end
            end)
        end

        copyBtn.MouseButton1Click:Connect(function()
            SafeCopy(Config.Security.DiscordInvite)
            copyBtn.Text = "Copied!"
            copyBtn.BackgroundColor3 = Color3.fromRGB(0, 220, 160)
            task.delay(1.2, CloseModal)
        end)

        dismissBtn.MouseButton1Click:Connect(CloseModal)
        closeBtn.MouseButton1Click:Connect(CloseModal)

        task.delay(60, function()
            if promptGui and promptGui.Parent then CloseModal() end
        end)
    end)
end

-- Mobile Floating Menu Button Constructor
local function CreateMobileMenuToggle(Window)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "B1nch3_MM2_MobileToggle"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = SafeParent()

    local btn = Instance.new("TextButton")
    btn.Name = "MobileToggleBtn"
    btn.Size = UDim2.new(0, 46, 0, 46)
    btn.Position = UDim2.new(0, 14, 0.5, -23)
    btn.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
    btn.BackgroundTransparency = 0.15
    btn.Text = "⚡"
    btn.Font = Enum.Font.Ubuntu
    btn.TextSize = 22
    btn.TextColor3 = Color3.fromRGB(0, 255, 170)
    btn.AutoButtonColor = true
    btn.Active = true
    btn.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 220, 160)
    stroke.Thickness = 1.8
    stroke.Parent = btn

    local dragging, dragStart, startPos
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = btn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    btn.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) and dragging then
            local delta = input.Position - dragStart
            btn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    local lastTap = 0
    btn.MouseButton1Click:Connect(function()
        local now = tick()
        if now - lastTap < 0.25 then return end
        lastTap = now

        pcall(function()
            if Window.Minimized then
                Window:Minimize()
            else
                Window:Minimize()
            end
        end)
    end)

    return screenGui
end

local mobileToggleGuiInstance = nil

-- ==============================================================================
-- 8. MM2 MAP, LOBBY & CORE GAMEPLAY LOGIC
-- ==============================================================================
local LOBBY_CENTER = Vector3.new(500, 520, 0)
local LOBBY_RADIUS = 260

local _cachedMap = nil
local _lastMapSearch = 0

local function GetActiveMap()
    local now = os.clock()
    if _cachedMap and _cachedMap.Parent == workspace and (now - _lastMapSearch < 0.75) then
        return _cachedMap
    end
    _lastMapSearch = now
    for _, c in ipairs(workspace:GetChildren()) do
        if c:IsA("Model") and c.Name ~= "Lobby" and (c:FindFirstChild("Spawns") or c:FindFirstChild("CoinContainer")) then
            _cachedMap = c
            return c
        end
    end
    for _, c in ipairs(workspace:GetChildren()) do
        if c:IsA("Model") and c.Name ~= "Lobby" and not Players:GetPlayerFromCharacter(c)
           and c.Name ~= "RCCars" and c.Name ~= "ServerStatus" and c.Name ~= "EffectLoader"
           and c.Name ~= "PetContainer" and c.Name ~= "Terrain" and c.Name ~= "Spawns" and c.Name ~= "WeaponDisplays" then
            _cachedMap = c
            return c
        end
    end
    _cachedMap = nil
    return nil
end

local function IsInLobby(target)
    local pos = nil
    if typeof(target) == "Vector3" then
        pos = target
    elseif typeof(target) == "Instance" then
        if target:IsA("Player") then
            local char = target.Character
            local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
            if hrp then pos = hrp.Position end
        elseif target:IsA("Model") then
            local hrp = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
            if hrp then pos = hrp.Position end
        elseif target:IsA("BasePart") then
            pos = target.Position
        end
    end
    if not pos then return true end
    if pos.Y < -50 then return true end -- Spectator box / void
    return (pos - LOBBY_CENTER).Magnitude <= LOBBY_RADIUS
end

local function IsLocalInMap()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    if IsInLobby(hrp.Position) then return false end
    if not GetActiveMap() then return false end
    return true
end

local function HasWeapon(player, weaponName)
    if not player then return false end
    local checkName = weaponName:lower()

    local function MatchesWeapon(t)
        if not (t and t:IsA("Tool")) then return false end
        local tName = t.Name:lower()
        if checkName == "knife" then
            return tName:find("knife") or tName:find("blade") or tName:find("dagger") or t:HasTag("Weapon_Knife")
        elseif checkName == "gun" then
            return tName:find("gun") or tName:find("revolver") or tName:find("pistol") or t:HasTag("Weapon_Gun")
        else
            return tName:find(checkName) ~= nil
        end
    end

    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        if backpack:FindFirstChild(weaponName) then return true end
        for _, t in ipairs(backpack:GetChildren()) do
            if MatchesWeapon(t) then return true end
        end
    end

    local char = player.Character
    if char then
        if char:FindFirstChild(weaponName) then return true end
        for _, t in ipairs(char:GetChildren()) do
            if MatchesWeapon(t) then return true end
        end
    end

    return false
end

local ScanRoles, UpdateESP, FetchServerRoles

local function FetchServerRoles()
    pcall(function()
        local rep = game:GetService("ReplicatedStorage")
        local crcMod = rep:FindFirstChild("Modules") and rep.Modules:FindFirstChild("CurrentRoundClient")
        if crcMod then
            local crc = require(crcMod)
            if crc and crc.PlayerData and next(crc.PlayerData) ~= nil then
                for name, data in pairs(crc.PlayerData) do
                    State.ServerRoleData[name] = data
                end
                if ScanRoles then ScanRoles() end
                return
            end
        end
        local gp = rep:FindFirstChild("Remotes") and rep.Remotes:FindFirstChild("Gameplay")
        local gcd = gp and gp:FindFirstChild("GetCurrentPlayerData")
        if gcd and gcd:IsA("RemoteFunction") then
            local data = gcd:InvokeServer()
            if type(data) == "table" and next(data) ~= nil then
                for name, d in pairs(data) do
                    State.ServerRoleData[name] = d
                end
                if ScanRoles then ScanRoles() end
            end
        end
    end)
end

local function GetPlayerRole(player)
    if not player then return "Innocent" end
    local name = player.Name

    -- 1. Direct Server Data from CurrentRoundClient or cached ServerRoleData
    if State.ServerRoleData and State.ServerRoleData[name] and State.ServerRoleData[name].Role then
        local r = State.ServerRoleData[name].Role
        if r == "Murderer" or r == "Sheriff" or r == "Hero" or r == "Innocent" then
            return r
        end
    end

    -- Direct live query into CurrentRoundClient
    local crcSuccess, crcRole = pcall(function()
        local rep = game:GetService("ReplicatedStorage")
        local crcMod = rep:FindFirstChild("Modules") and rep.Modules:FindFirstChild("CurrentRoundClient")
        if crcMod then
            local crc = require(crcMod)
            if crc and crc.PlayerData and crc.PlayerData[name] and crc.PlayerData[name].Role then
                local r = crc.PlayerData[name].Role
                State.ServerRoleData[name] = crc.PlayerData[name]
                return r
            end
        end
        return nil
    end)
    if crcSuccess and crcRole and (crcRole == "Murderer" or crcRole == "Sheriff" or crcRole == "Hero" or crcRole == "Innocent") then
        return crcRole
    end

    -- 2. Equipped Tools / Backpack (Real Weapon Check)
    if HasWeapon(player, "Knife") then
        return "Murderer"
    elseif HasWeapon(player, "Gun") then
        if State.GunDroppedOnce and State.OriginalSheriff and player ~= State.OriginalSheriff then
            return "Hero"
        end
        return "Sheriff"
    end

    -- 3. Character Attributes
    local char = player.Character
    if char then
        local attrRole = char:GetAttribute("Role") or player:GetAttribute("Role")
        if attrRole == "Murderer" or attrRole == "Sheriff" or attrRole == "Hero" or attrRole == "Innocent" then
            return attrRole
        end
    end

    return "Innocent"
end

local function ScanRoles()
    State.Murderer = nil
    State.Sheriff = nil
    State.Hero = nil

    if not State.ServerRoleData or next(State.ServerRoleData) == nil then
        FetchServerRoles()
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and not IsInLobby(p) and p:GetAttribute("Alive") ~= false then
            local role = GetPlayerRole(p)
            if role == "Murderer" then
                State.Murderer = p
            elseif role == "Sheriff" then
                State.Sheriff = p
                State.Hero = p
                State.OriginalSheriff = p
            elseif role == "Hero" then
                State.Hero = p
            end
        end
    end
end

local function ScanGunDrop()
    State.GunDrop = nil
    local drop = workspace:FindFirstChild("GunDrop", true)
    if drop and drop:IsA("BasePart") then
        if not IsInLobby(drop.Position) then
            State.GunDrop = drop
            State.GunDroppedOnce = true
        end
    end
end

local function IsValidCoin(coin)
    if not coin or not coin.Parent or not coin:IsA("BasePart") then return false end
    if coin:GetAttribute("Collected") == true or coin:GetAttribute("Delete") == true then return false end

    local vis = coin:FindFirstChild("CoinVisual")
    if vis then
        if vis:GetAttribute("Collected") == true or vis:GetAttribute("Delete") == true then return false end
        if vis.Transparency > 0.6 then return false end
    end

    local touch = coin:FindFirstChildWhichIsA("TouchTransmitter") or coin:FindFirstChild("TouchInterest")
    if not touch then return false end

    -- Check specific coin part instance
    if State.CollectedCoins[coin] then return false end

    local cooldown = State.CoinCooldowns[coin]
    if cooldown and os.clock() < cooldown then return false end

    if IsInLobby(coin.Position) then return false end
    return true
end

local function GetMapCoins()
    local coins = {}
    local activeMap = GetActiveMap()
    local container = activeMap and (activeMap:FindFirstChild("CoinContainer") or activeMap:FindFirstChild("Coins"))
    local searchScope = container and container:GetChildren() or (activeMap and activeMap:GetDescendants() or workspace:GetDescendants())
    for _, obj in ipairs(searchScope) do
        if (obj.Name == "Coin_Server" or obj.Name == "Coin") and obj:IsA("BasePart") then
            if IsValidCoin(obj) then
                table.insert(coins, obj)
            end
        end
    end
    return coins
end

local function GetClosestValidCoin(fromPos)
    local bestCoin = nil
    local bestDist = math.huge

    local mHrp = nil
    if Config.AutoFarm.AvoidMurderer and State.Murderer and State.Murderer.Character then
        mHrp = State.Murderer.Character:FindFirstChild("HumanoidRootPart")
    end

    local activeMap = GetActiveMap()
    local cc = activeMap and activeMap:FindFirstChild("CoinContainer")
    local candidates = cc and cc:GetChildren() or {}

    if #candidates > 0 then
        for _, obj in ipairs(candidates) do
            if obj:IsA("BasePart") and IsValidCoin(obj) then
                if mHrp and (mHrp.Position - obj.Position).Magnitude < 24 then
                    continue
                end
                local d = (obj.Position - fromPos).Magnitude
                if d < bestDist then
                    bestDist = d
                    bestCoin = obj
                end
            end
        end
    else
        for _, obj in ipairs(workspace:GetDescendants()) do
            if (obj.Name == "Coin_Server" or obj.Name == "Coin") and obj:IsA("BasePart") then
                if IsValidCoin(obj) then
                    if mHrp and (mHrp.Position - obj.Position).Magnitude < 24 then
                        continue
                    end
                    local d = (obj.Position - fromPos).Magnitude
                    if d < bestDist then
                        bestDist = d
                        bestCoin = obj
                    end
                end
            end
        end
    end
    return bestCoin, bestDist
end

local function IsBagFull()
    if State.BagFull then return true end
    if State.CurrentCoins and State.MaxCoins and State.MaxCoins > 0 and State.CurrentCoins >= State.MaxCoins then
        return true
    end

    local full = false
    pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local mainGui = pg and pg:FindFirstChild("MainGUI")
        local bag = mainGui and mainGui:FindFirstChild("Game") and mainGui.Game:FindFirstChild("CoinBags")
        local container = bag and bag:FindFirstChild("Container")
        if container then
            for _, bagType in ipairs(container:GetChildren()) do
                if bagType:IsA("Frame") and bagType.Visible then
                    local f = bagType:FindFirstChild("Full")
                    if f and f:IsA("GuiObject") and f.Visible then
                        full = true
                        return
                    end
                end
            end
        end
    end)
    return full
end

-- ==============================================================================
-- 9. ESP ENGINE (INSTANT MAP-ONLY CHAMS, BILLBOARDS, COINS, TRAPS)
-- ==============================================================================
local function CreateHighlight(target, color)
    local hl = target:FindFirstChild("MM2_Highlight")
    if not hl then
        hl = Instance.new("Highlight")
        hl.Name = "MM2_Highlight"
        hl.Adornee = target
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = target
    end
    hl.FillColor = color
    hl.FillTransparency = 0.45
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.OutlineTransparency = 0.15
    return hl
end

local function CreateBillboard(target, text, color, offset)
    local bg = target:FindFirstChild("MM2_Billboard")
    if not bg then
        bg = Instance.new("BillboardGui")
        bg.Name = "MM2_Billboard"
        bg.Adornee = target
        bg.Size = UDim2.new(0, 160, 0, 40)
        bg.StudsOffset = offset or Vector3.new(0, 3, 0)
        bg.AlwaysOnTop = true
        bg.Parent = target

        local txtRole = Instance.new("TextLabel")
        txtRole.Name = "RoleLabel"
        txtRole.Size = UDim2.new(1, 0, 0.55, 0)
        txtRole.BackgroundTransparency = 1
        txtRole.TextColor3 = color
        txtRole.Font = CurrentFont
        txtRole.TextSize = 13
        txtRole.TextStrokeTransparency = 0.2
        txtRole.Parent = bg

        local txtInfo = Instance.new("TextLabel")
        txtInfo.Name = "InfoLabel"
        txtInfo.Size = UDim2.new(1, 0, 0.45, 0)
        txtInfo.Position = UDim2.new(0, 0, 0.55, 0)
        txtInfo.BackgroundTransparency = 1
        txtInfo.TextColor3 = Color3.fromRGB(240, 240, 240)
        txtInfo.Font = CurrentFont
        txtInfo.TextSize = 11
        txtInfo.TextStrokeTransparency = 0.3
        txtInfo.Parent = bg
    end
    bg.RoleLabel.TextColor3 = color
    bg.RoleLabel.Text = text
    bg.RoleLabel.Font = CurrentFont
    bg.InfoLabel.Font = CurrentFont
    return bg
end

local function CreateCoinBillboard(coin)
    local bg = coin:FindFirstChild("MM2_CoinBillboard")
    if not bg then
        bg = Instance.new("BillboardGui")
        bg.Name = "MM2_CoinBillboard"
        bg.Adornee = coin
        bg.Size = UDim2.new(0, 60, 0, 20)
        bg.AlwaysOnTop = true
        bg.Parent = coin

        local lbl = Instance.new("TextLabel")
        lbl.Name = "CoinText"
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = "★ COIN"
        lbl.TextColor3 = Color3.fromRGB(255, 220, 0)
        lbl.Font = CurrentFont
        lbl.TextSize = 11
        lbl.TextStrokeTransparency = 0.2
        lbl.Parent = bg
    end
    return bg
end

local function CleanPlayerESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local hl = p.Character:FindFirstChild("MM2_Highlight")
            if hl then hl:Destroy() end
            local head = p.Character:FindFirstChild("Head")
            if head then
                local bb = head:FindFirstChild("MM2_Billboard")
                if bb then bb:Destroy() end
            end
        end
    end
end

local function CleanSinglePlayerESP(p)
    if not p then return end
    if p.Character then
        local hl = p.Character:FindFirstChild("MM2_Highlight")
        if hl then hl:Destroy() end
        local head = p.Character:FindFirstChild("Head")
        if head then
            local bb = head:FindFirstChild("MM2_Billboard")
            if bb then bb:Destroy() end
        end
    end
end

local function CleanGunDropESP()
    if State.GunDrop and State.GunDrop.Parent then
        local hl = State.GunDrop:FindFirstChild("MM2_Highlight")
        if hl then hl:Destroy() end
        local bb = State.GunDrop:FindFirstChild("MM2_Billboard")
        if bb then bb:Destroy() end
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "GunDrop" and obj:IsA("BasePart") then
            local hl = obj:FindFirstChild("MM2_Highlight")
            if hl then hl:Destroy() end
            local bb = obj:FindFirstChild("MM2_Billboard")
            if bb then bb:Destroy() end
        end
    end
end

local function CleanTrapsESP()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("trap") and (obj:IsA("BasePart") or obj:IsA("Model")) then
            local hl = obj:FindFirstChild("MM2_Highlight")
            if hl then hl:Destroy() end
        end
    end
end

local function CleanCoinsESP()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj.Name == "Coin_Server" or obj.Name == "Coin") and obj:IsA("BasePart") then
            local hl = obj:FindFirstChild("MM2_Highlight")
            if hl then hl:Destroy() end
            local bb = obj:FindFirstChild("MM2_Billboard")
            if bb then bb:Destroy() end
            local cbb = obj:FindFirstChild("MM2_CoinBillboard")
            if cbb then cbb:Destroy() end
        end
    end
end

local function CleanAllESP()
    CleanPlayerESP()
    CleanGunDropESP()
    CleanCoinsESP()
    CleanTrapsESP()
end

local function UpdateESP()
    if not Config.ESP.Enabled then
        CleanAllESP()
        return
    end

    local activeMap = GetActiveMap()
    if not activeMap then
        CleanAllESP()
        return
    end

    ScanRoles()
    ScanGunDrop()

    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myPos = myHrp and myHrp.Position

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local char = p.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local head = char and char:FindFirstChild("Head")
            local hum = char and char:FindFirstChild("Humanoid")
            local aliveAttr = p:GetAttribute("Alive")

            -- Must be alive, valid humanoid, and physically in the map (NOT lobby or void)
            if aliveAttr ~= false and char and hrp and head and hum and hum.Health > 0 and not IsInLobby(hrp.Position) then
                local role = GetPlayerRole(p)
                local color = Color3.fromRGB(46, 213, 115) -- Innocent (Green)
                if role == "Murderer" then
                    color = Color3.fromRGB(255, 45, 85) -- Murderer (Red)
                elseif role == "Sheriff" or role == "Hero" then
                    color = Color3.fromRGB(0, 150, 255) -- Sheriff / Hero (Blue)
                end

                CreateHighlight(char, color)

                local dist = myPos and math.floor((myPos - hrp.Position).Magnitude) or 0
                local titleParts = {}
                if Config.ESP.Roles then
                    table.insert(titleParts, "[" .. role:upper() .. "]")
                end
                if Config.ESP.Names then
                    table.insert(titleParts, p.DisplayName)
                end
                local headerText = table.concat(titleParts, " ")
                if headerText == "" then headerText = p.DisplayName end

                local bb = CreateBillboard(head, headerText, color, Vector3.new(0, 2.5, 0))
                if bb:FindFirstChild("InfoLabel") then
                    local infoParts = {}
                    if Config.ESP.Names then
                        table.insert(infoParts, "@" .. p.Name)
                    end
                    if Config.ESP.Distance then
                        table.insert(infoParts, tostring(dist) .. "m")
                    end
                    bb.InfoLabel.Text = table.concat(infoParts, " • ")
                end
            else
                CleanSinglePlayerESP(p)
            end
        end
    end

    if Config.ESP.GunDrop then
        if State.GunDrop and State.GunDrop.Parent and not IsInLobby(State.GunDrop.Position) then
            CreateHighlight(State.GunDrop, Color3.fromRGB(255, 215, 0))
            local dist = myPos and math.floor((myPos - State.GunDrop.Position).Magnitude) or 0
            CreateBillboard(State.GunDrop, "DROPPED REVOLVER (" .. dist .. "m)", Color3.fromRGB(255, 215, 0), Vector3.new(0, 1.5, 0))
        else
            CleanGunDropESP()
        end
    else
        CleanGunDropESP()
    end

    if Config.ESP.Coins then
        local cc = activeMap:FindFirstChild("CoinContainer")
        local coinList = cc and cc:GetChildren() or {}
        if #coinList > 0 then
            for _, obj in ipairs(coinList) do
                if obj:IsA("BasePart") then
                    local cbb = obj:FindFirstChild("MM2_CoinBillboard")
                    if IsValidCoin(obj) then
                        if not cbb then CreateCoinBillboard(obj) end
                    else
                        if cbb then cbb:Destroy() end
                    end
                end
            end
        else
            for _, obj in ipairs(workspace:GetDescendants()) do
                if (obj.Name == "Coin_Server" or obj.Name == "Coin") and obj:IsA("BasePart") then
                    local cbb = obj:FindFirstChild("MM2_CoinBillboard")
                    if IsValidCoin(obj) then
                        if not cbb then CreateCoinBillboard(obj) end
                    else
                        if cbb then cbb:Destroy() end
                    end
                end
            end
        end
    else
        CleanCoinsESP()
    end

    if Config.ESP.Traps then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("trap") and (obj:IsA("BasePart") or obj:IsA("Model")) then
                local pos = obj:IsA("BasePart") and obj.Position or (obj.PrimaryPart and obj.PrimaryPart.Position)
                if pos and not IsInLobby(pos) then
                    CreateHighlight(obj, Color3.fromRGB(255, 60, 60))
                end
            end
        end
    else
        CleanTrapsESP()
    end
end

-- Event Listeners for Instant 0ms Role Detection & Map Transitions
local playerConnMap = {}
local gameEventsConns = {}

local function DisconnectPlayerListeners(player)
    local conns = playerConnMap[player]
    if conns then
        for _, c in ipairs(conns) do
            pcall(function() c:Disconnect() end)
        end
        playerConnMap[player] = nil
    end
end

local function SetupPlayerListeners(player)
    DisconnectPlayerListeners(player)
    local conns = {}

    local function HookBackpack(bp)
        if not bp then return end
        table.insert(conns, bp.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                task.defer(UpdateESP)
            end
        end))
        table.insert(conns, bp.ChildRemoved:Connect(function(child)
            if child:IsA("Tool") then
                task.defer(UpdateESP)
            end
        end))
    end

    local function HookCharacter(char)
        if not char then return end
        table.insert(conns, char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") or child.Name:find("DisplayRef") or child.Name:find("Knife") or child.Name:find("Gun") then
                task.defer(UpdateESP)
            end
        end))
        table.insert(conns, char.ChildRemoved:Connect(function(child)
            if child:IsA("Tool") or child.Name:find("DisplayRef") or child.Name:find("Knife") or child.Name:find("Gun") then
                task.defer(UpdateESP)
            end
        end))
        table.insert(conns, char:GetAttributeChangedSignal("Role"):Connect(function()
            task.defer(UpdateESP)
        end))
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            table.insert(conns, hum.Died:Connect(function()
                CleanSinglePlayerESP(player)
                task.defer(UpdateESP)
            end))
        end
    end

    table.insert(conns, player.CharacterAdded:Connect(function(char)
        HookCharacter(char)
        task.defer(UpdateESP)
    end))

    table.insert(conns, player.CharacterRemoving:Connect(function()
        CleanSinglePlayerESP(player)
        task.defer(UpdateESP)
    end))

    local bp = player:FindFirstChild("Backpack")
    if bp then HookBackpack(bp) end
    table.insert(conns, player.ChildAdded:Connect(function(child)
        if child.Name == "Backpack" then
            HookBackpack(child)
            task.defer(UpdateESP)
        end
    end))

    if player.Character then
        HookCharacter(player.Character)
    end

    table.insert(conns, player:GetAttributeChangedSignal("Alive"):Connect(function()
        if player:GetAttribute("Alive") == false then
            CleanSinglePlayerESP(player)
        end
        task.defer(UpdateESP)
    end))

    table.insert(conns, player:GetAttributeChangedSignal("Role"):Connect(function()
        task.defer(UpdateESP)
    end))

    playerConnMap[player] = conns
end

local function SetupGameEventListeners()
    for _, c in ipairs(gameEventsConns) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(gameEventsConns)

    -- Map models added or removed from workspace
    table.insert(gameEventsConns, workspace.ChildAdded:Connect(function(child)
        if child:IsA("Model") and child.Name ~= "Lobby" and not Players:GetPlayerFromCharacter(child)
           and child.Name ~= "RCCars" and child.Name ~= "ServerStatus" and child.Name ~= "EffectLoader"
           and child.Name ~= "PetContainer" and child.Name ~= "Terrain" and child.Name ~= "Spawns" then
            task.spawn(FetchServerRoles)
            task.defer(UpdateESP)
        end
    end))

    table.insert(gameEventsConns, workspace.ChildRemoved:Connect(function(child)
        if child:IsA("Model") and child.Name ~= "Lobby" and not Players:GetPlayerFromCharacter(child)
           and child.Name ~= "RCCars" and child.Name ~= "ServerStatus" and child.Name ~= "EffectLoader"
           and child.Name ~= "PetContainer" and child.Name ~= "Terrain" and child.Name ~= "Spawns" then
            State.BagFull = false
            State.CurrentCoins = 0
            table.clear(State.ServerRoleData)
            table.clear(State.CollectedCoins)
            table.clear(State.CoinCooldowns)
            CleanAllESP()
        end
    end))

    -- Gameplay remotes
    local rep = game:GetService("ReplicatedStorage")
    local gp = rep:FindFirstChild("Remotes") and rep.Remotes:FindFirstChild("Gameplay")
    if gp then
        local pdc = gp:FindFirstChild("PlayerDataChanged")
        if pdc and pdc:IsA("RemoteEvent") then
            table.insert(gameEventsConns, pdc.OnClientEvent:Connect(function(data)
                if type(data) == "table" then
                    for name, d in pairs(data) do
                        State.ServerRoleData[name] = d
                    end
                end
                task.spawn(FetchServerRoles)
                if ScanRoles then ScanRoles() end
                task.defer(UpdateESP)
            end))
        end

        local rstart = gp:FindFirstChild("RoundStart")
        if rstart and rstart:IsA("RemoteEvent") then
            table.insert(gameEventsConns, rstart.OnClientEvent:Connect(function()
                State.GunDroppedOnce = false
                task.spawn(FetchServerRoles)
                task.defer(UpdateESP)
            end))
        end

        local rrole = gp:FindFirstChild("RoleSelect")
        if rrole and rrole:IsA("RemoteEvent") then
            table.insert(gameEventsConns, rrole.OnClientEvent:Connect(function()
                task.spawn(FetchServerRoles)
                task.defer(UpdateESP)
            end))
        end

        local cstart = gp:FindFirstChild("CoinsStarted")
        if cstart and cstart:IsA("RemoteEvent") then
            table.insert(gameEventsConns, cstart.OnClientEvent:Connect(function()
                State.BagFull = false
                State.CurrentCoins = 0
                table.clear(State.CollectedCoins)
                table.clear(State.CoinCooldowns)
            end))
        end

        local ccoll = gp:FindFirstChild("CoinCollected")
        if ccoll and ccoll:IsA("RemoteEvent") then
            table.insert(gameEventsConns, ccoll.OnClientEvent:Connect(function(coinType, currentCoins, maxCoins)
                if currentCoins and maxCoins and type(currentCoins) == "number" and type(maxCoins) == "number" then
                    State.CurrentCoins = currentCoins
                    State.MaxCoins = maxCoins
                    if currentCoins >= maxCoins then
                        State.BagFull = true
                    end
                end
            end))
        end

        local rfade = gp:FindFirstChild("RoundEndFade")
        if rfade and rfade:IsA("RemoteEvent") then
            table.insert(gameEventsConns, rfade.OnClientEvent:Connect(function()
                State.BagFull = false
                State.CurrentCoins = 0
                table.clear(State.ServerRoleData)
                table.clear(State.CollectedCoins)
                table.clear(State.CoinCooldowns)
                CleanAllESP()
            end))
        end

        local gover = gp:FindFirstChild("GameOver")
        if gover and gover:IsA("RemoteEvent") then
            table.insert(gameEventsConns, gover.OnClientEvent:Connect(function()
                State.BagFull = false
                State.CurrentCoins = 0
                table.clear(State.ServerRoleData)
                table.clear(State.CollectedCoins)
                table.clear(State.CoinCooldowns)
                CleanAllESP()
            end))
        end
    end

    -- Hook CurrentRoundClient internal BindableEvent if available
    pcall(function()
        local crcMod = rep:FindFirstChild("Modules") and rep.Modules:FindFirstChild("CurrentRoundClient")
        if crcMod then
            local crc = require(crcMod)
            if crc and crc.PlayerDataChanged and crc.PlayerDataChanged.Event then
                table.insert(gameEventsConns, crc.PlayerDataChanged.Event:Connect(function()
                    if crc.PlayerData then
                        for name, d in pairs(crc.PlayerData) do
                            State.ServerRoleData[name] = d
                        end
                    end
                    if ScanRoles then ScanRoles() end
                    task.defer(UpdateESP)
                end))
            end
        end
    end)

    -- Hook all existing players
    for _, p in ipairs(Players:GetPlayers()) do
        SetupPlayerListeners(p)
    end

    table.insert(gameEventsConns, Players.PlayerAdded:Connect(function(p)
        SetupPlayerListeners(p)
    end))

    table.insert(gameEventsConns, Players.PlayerRemoving:Connect(function(p)
        CleanSinglePlayerESP(p)
        DisconnectPlayerListeners(p)
        task.defer(UpdateESP)
    end))

    -- Throttled heartbeat listener (4 Hz) for zero-lag map teleport & role detection
    local _lastHbMapCheck = 0
    table.insert(gameEventsConns, RunService.Heartbeat:Connect(function()
        local now = os.clock()
        if now - _lastHbMapCheck < 0.25 then return end
        _lastHbMapCheck = now
        local inMap = IsLocalInMap()
        if inMap ~= State.LastInMapState then
            State.LastInMapState = inMap
            if inMap then
                task.spawn(FetchServerRoles)
                UpdateESP()
            else
                State.BagFull = false
                State.CurrentCoins = 0
                table.clear(State.ServerRoleData)
                table.clear(State.CollectedCoins)
                table.clear(State.CoinCooldowns)
                CleanAllESP()
            end
        end
    end))
end

-- ==============================================================================
-- 10. HITBOX EXPANSION ENGINE
-- ==============================================================================
local function ResetAllHitboxes()
    for part, orig in pairs(State.OriginalHitboxes) do
        if part and part.Parent then
            part.Size = orig.Size
            part.Transparency = orig.Transparency
            part.CanCollide = orig.CanCollide
        end
    end
    table.clear(State.OriginalHitboxes)
end

local function UpdateHitboxExpander()
    if not Config.Combat.HitboxExpander or not IsLocalInMap() then
        ResetAllHitboxes()
        return
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and not IsInLobby(p) and p:GetAttribute("Alive") ~= false then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if not State.OriginalHitboxes[hrp] then
                    State.OriginalHitboxes[hrp] = {
                        Size = hrp.Size,
                        Transparency = hrp.Transparency,
                        CanCollide = hrp.CanCollide
                    }
                end
                hrp.Size = Vector3.new(Config.Combat.HitboxSize, Config.Combat.HitboxSize, Config.Combat.HitboxSize)
                hrp.Transparency = 0.65
                hrp.CanCollide = false
            end
        end
    end
end

-- ==============================================================================
-- 11. UNIVERSAL COMBAT & SILENT AIM ENGINE (WEAPONSERVICE HOOKS)
-- ==============================================================================
-- Resolves targets regardless of role (Sheriff, Innocent, Murderer)
local function GetAimbotTarget(targetFilter, maxRange, checkFov)
    if not IsLocalInMap() then return nil end
    local bestTarget = nil
    local bestScore = math.huge
    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return nil end

    local myRole = GetPlayerRole(LocalPlayer)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and not IsInLobby(p) and p:GetAttribute("Alive") ~= false then
            local tChar = p.Character
            local tHrp = tChar:FindFirstChild("HumanoidRootPart")
            local tHum = tChar:FindFirstChild("Humanoid")
            if tHrp and tHum and tHum.Health > 0 then
                local tRole = GetPlayerRole(p)
                local allowed = false

                if targetFilter == "All Players (Everyone)" or not targetFilter then
                    allowed = true
                elseif targetFilter == "Enemies Only" then
                    if myRole == "Murderer" then
                        allowed = true
                    elseif myRole == "Sheriff" or myRole == "Hero" then
                        allowed = (tRole == "Murderer")
                    else
                        allowed = (tRole == "Murderer")
                    end
                elseif targetFilter == "Murderer Only" then
                    allowed = (tRole == "Murderer")
                elseif targetFilter == "Sheriff Only" then
                    allowed = (tRole == "Sheriff" or tRole == "Hero")
                elseif targetFilter == "Innocents Only" then
                    allowed = (tRole == "Innocent")
                else
                    allowed = true
                end

                if allowed then
                    local dist = (tHrp.Position - myHrp.Position).Magnitude
                    if not maxRange or dist <= maxRange then
                        if checkFov then
                            local screenPos, onScreen = Camera:WorldToViewportPoint(tHrp.Position)
                            if onScreen then
                                local mousePos = UserInputService:GetMouseLocation()
                                local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                                if screenDist < bestScore then
                                    bestScore = screenDist
                                    bestTarget = p
                                end
                            end
                        else
                            if dist < bestScore then
                                bestScore = dist
                                bestTarget = p
                            end
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

local function GetPredictedTargetPosition(targetPlayer, projSpeed)
    if not targetPlayer or not targetPlayer.Character then return nil end
    local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    if not Config.Combat.PredictMovement then
        return hrp.Position + Vector3.new(0, 0.35, 0)
    end

    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local distance = myHrp and (hrp.Position - myHrp.Position).Magnitude or 50
    local speed = projSpeed or 1000
    local velocity = hrp.AssemblyLinearVelocity or hrp.Velocity or Vector3.zero
    local timeToHit = distance / speed
    return hrp.Position + (velocity * timeToHit) + Vector3.new(0, 0.35, 0)
end

-- Hook WeaponService for Gun & Knife Silent Aim
local wsSuccess, WeaponService = pcall(function()
    return require(ReplicatedStorage:WaitForChild("ClientServices"):WaitForChild("WeaponService"))
end)

local originalGetMouseTargetCFrame = nil
local originalGetTargetPosition = nil

if wsSuccess and type(WeaponService) == "table" then
    originalGetMouseTargetCFrame = WeaponService.GetMouseTargetCFrame
    originalGetTargetPosition = WeaponService.GetTargetPosition

    WeaponService.GetMouseTargetCFrame = function(...)
        if Config.Combat.ShooterSilentAim then
            ScanRoles()
            local target = State.Murderer
            if target and target.Character then
                local tHrp = target.Character:FindFirstChild("HumanoidRootPart")
                local tHum = target.Character:FindFirstChild("Humanoid")
                if tHrp and tHum and tHum.Health > 0 then
                    local predPos = GetPredictedTargetPosition(target, 1000)
                    if predPos then
                        return CFrame.new(predPos)
                    end
                end
            end
        end
        if originalGetMouseTargetCFrame then
            return originalGetMouseTargetCFrame(...)
        end
        return CFrame.new()
    end

    WeaponService.GetTargetPosition = function(...)
        if Config.Combat.ShooterSilentAim then
            ScanRoles()
            local target = State.Murderer
            if target and target.Character then
                local tHrp = target.Character:FindFirstChild("HumanoidRootPart")
                local tHum = target.Character:FindFirstChild("Humanoid")
                if tHrp and tHum and tHum.Health > 0 then
                    local predPos = GetPredictedTargetPosition(target, 1000)
                    if predPos then
                        return CFrame.new(predPos)
                    end
                end
            end
        end
        if originalGetTargetPosition then
            return originalGetTargetPosition(...)
        end
        return CFrame.new()
    end
end

local function FireSheriffGun(targetPos)
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    local gun = char:FindFirstChild("Gun") or (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Gun"))
    if not gun or not hrp or not hum or hum.Health <= 0 then return false end

    if gun.Parent ~= char then
        hum:EquipTool(gun)
        local startEquip = tick()
        while gun.Parent ~= char and tick() - startEquip < 0.25 do
            task.wait(0.02)
        end
    end

    local rayAttachment = hrp:FindFirstChild("GunRaycastAttachment") or (gun:FindFirstChild("Handle") and gun.Handle:FindFirstChild("GunRaycastAttachment1"))
    local originCF = rayAttachment and rayAttachment.WorldCFrame or hrp.CFrame
    local targetCF = typeof(targetPos) == "CFrame" and targetPos or CFrame.new(targetPos)

    local shootRemote = gun:FindFirstChild("Shoot")
    if shootRemote and shootRemote:IsA("RemoteEvent") then
        pcall(function()
            shootRemote:FireServer(originCF, targetCF)
        end)
    end

    pcall(function()
        gun:Activate()
    end)
    return true
end

local function ExecuteKillAll(FluentInstance)
    local char = LocalPlayer.Character
    if not char then return end
    local knife = char:FindFirstChild("Knife") or (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Knife"))
    if not knife then
        if FluentInstance then
            FluentInstance:Notify({Title = "Kill All", Content = "You must have Knife in Backpack or Character!", Duration = 3})
        end
        return
    end

    if knife.Parent ~= char then
        char.Humanoid:EquipTool(knife)
        task.wait(0.08)
    end

    if not IsLocalInMap() then return end
    local myHrp = char:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end
    local initialPos = myHrp.CFrame

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and not IsInLobby(p) and p:GetAttribute("Alive") ~= false and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local targetHrp = p.Character.HumanoidRootPart
            myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 1.5)
            task.wait(0.04)
            pcall(function()
                knife:Activate()
                local events = knife:FindFirstChild("Events")
                if events then
                    local stab = events:FindFirstChild("KnifeStabbed")
                    if stab and stab:IsA("RemoteEvent") then stab:FireServer() end
                    local handleTouched = events:FindFirstChild("HandleTouched")
                    if handleTouched and handleTouched:IsA("RemoteEvent") then handleTouched:FireServer(targetHrp) end
                end
            end)
            task.wait(0.04)
        end
    end

    myHrp.CFrame = initialPos
    if FluentInstance then
        FluentInstance:Notify({Title = "Kill All Complete", Content = "Map wiped cleanly.", Duration = 3})
    end
end

-- Dedicated Murderer Kill Aura (Knife Slash Engine)
local lastKnifeStabTick = 0

task.spawn(function()
    while true do
        task.wait(0.04)
        if Config.Combat.MurdererKillAura and IsLocalInMap() then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")

            if char and hrp and hum and hum.Health > 0 then
                local knife = char:FindFirstChild("Knife") or (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Knife"))
                if knife then
                    local maxRange = Config.Combat.MurdererAuraRange or 22
                    local bestTarget = nil
                    local bestDist = maxRange

                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character and not IsInLobby(p) and p:GetAttribute("Alive") ~= false then
                            local tHrp = p.Character:FindFirstChild("HumanoidRootPart")
                            local tHum = p.Character:FindFirstChild("Humanoid")
                            if tHrp and tHum and tHum.Health > 0 then
                                local dist = (tHrp.Position - hrp.Position).Magnitude
                                if dist <= bestDist then
                                    bestDist = dist
                                    bestTarget = p
                                end
                            end
                        end
                    end

                    if bestTarget and bestTarget.Character then
                        local tHrp = bestTarget.Character:FindFirstChild("HumanoidRootPart")
                        local now = tick()
                        if now - lastKnifeStabTick >= 0.06 and tHrp then
                            lastKnifeStabTick = now
                            if knife.Parent ~= char then
                                hum:EquipTool(knife)
                                task.wait(0.02)
                            end
                            pcall(function()
                                knife:Activate()
                                local events = knife:FindFirstChild("Events")
                                if events then
                                    local stab = events:FindFirstChild("KnifeStabbed")
                                    if stab and stab:IsA("RemoteEvent") then stab:FireServer() end
                                    local handleTouched = events:FindFirstChild("HandleTouched")
                                    if handleTouched and handleTouched:IsA("RemoteEvent") then handleTouched:FireServer(tHrp) end
                                end
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- ==============================================================================
-- 12. RE-ENGINEERED GOD FLING & TOUCH-FLING ENGINE (PHYSICS MOMENTUM TRANSFER)
-- ==============================================================================
local function LaunchFling(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local targetHrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetHum = targetPlayer.Character:FindFirstChild("Humanoid")
    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local humanoid = myChar and myChar:FindFirstChild("Humanoid")
    if not targetHrp or not targetHum or targetHum.Health <= 0 or not myHrp or not humanoid or humanoid.Health <= 0 then return end

    local originalCF = myHrp.CFrame
    local savedCameraSubject = Camera.CameraSubject
    Camera.CameraSubject = targetHum

    humanoid.Sit = false

    -- Keep rootpart collision ENABLED for physics impulse transfer
    myHrp.CanCollide = true

    local bRot = Instance.new("BodyAngularVelocity")
    bRot.Name = "B1nch3FlingAngular"
    bRot.AngularVelocity = Vector3.new(9999999, 9999999, 9999999)
    bRot.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bRot.P = math.huge
    bRot.Parent = myHrp

    local startTime = tick()
    local duration = Config.Fling.FlingDuration or 1.5

    while (tick() - startTime) < duration and targetPlayer.Character and targetHrp.Parent and targetHum.Health > 0 and myChar.Parent and humanoid.Health > 0 do
        RunService.Heartbeat:Wait()
        myHrp.AssemblyLinearVelocity = Vector3.new(999999, 999999, 999999)
        myHrp.AssemblyAngularVelocity = Vector3.new(999999, 999999, 999999)

        local tPos = targetHrp.Position
        local tVel = targetHrp.AssemblyLinearVelocity or Vector3.zero
        local ramPos = tPos + (tVel * 0.08) + Vector3.new(math.random(-1, 1) * 0.25, math.random(-1, 1) * 0.25, math.random(-1, 1) * 0.25)

        myHrp.CFrame = CFrame.new(ramPos) * CFrame.Angles(
            math.rad(math.random(-360, 360)),
            math.rad(math.random(-360, 360)),
            math.rad(math.random(-360, 360))
        )
    end

    bRot:Destroy()
    myHrp.AssemblyLinearVelocity = Vector3.zero
    myHrp.AssemblyAngularVelocity = Vector3.zero
    myHrp.CFrame = originalCF
    Camera.CameraSubject = humanoid
end

-- Touch Fling (Walk & Touch to Fling Anyone)
local touchFlingConn = nil
local function SetTouchFling(enabled)
    Config.Fling.TouchFling = enabled
    if touchFlingConn then
        touchFlingConn:Disconnect()
        touchFlingConn = nil
    end
    if enabled then
        touchFlingConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local oldVel = hrp.AssemblyLinearVelocity
                hrp.AssemblyLinearVelocity = Vector3.new(999999, 999999, 999999)
                hrp.AssemblyAngularVelocity = Vector3.new(999999, 999999, 999999)
                RunService.RenderStepped:Wait()
                if hrp and hrp.Parent then
                    hrp.AssemblyLinearVelocity = oldVel
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end
            end
        end)
    end
end

-- ==============================================================================
-- 13. INSTANT REVOLVER SNATCHER (TOUCH & TWEEN HYBRID)
-- ==============================================================================
local function GrabDroppedGun()
    ScanGunDrop()
    local gunDrop = State.GunDrop
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not gunDrop or not hrp then return false end

    -- Direct remote touch trigger if supported
    if firetouchinterest then
        pcall(function()
            firetouchinterest(hrp, gunDrop, 0)
            task.wait(0.02)
            firetouchinterest(hrp, gunDrop, 1)
        end)
    end

    -- Instant micro-warp fallback
    local oldCF = hrp.CFrame
    hrp.CFrame = gunDrop.CFrame + Vector3.new(0, 0.5, 0)
    task.wait(0.06)
    hrp.CFrame = oldCF
    return true
end

task.spawn(function()
    while true do
        task.wait(0.2)
        if Config.Combat.InstantGrabGun then
            local char = LocalPlayer.Character
            local hasGun = (char and char:FindFirstChild("Gun")) or (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Gun"))
            if not hasGun then
                ScanGunDrop()
                if State.GunDrop and State.GunDrop.Parent then
                    GrabDroppedGun()
                    task.wait(1.5)
                end
            end
        end
    end
end)

-- ==============================================================================
-- 14. DEFENSE & SURVIVAL
-- ==============================================================================
local antiFlingConn = nil
local function SyncAntiFling(enabled)
    Config.Defense.AntiFling = enabled
    if antiFlingConn then
        antiFlingConn:Disconnect()
        antiFlingConn = nil
    end
    if enabled then
        antiFlingConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local vel = hrp.AssemblyLinearVelocity or hrp.Velocity or Vector3.zero
                local rotVel = hrp.AssemblyAngularVelocity or hrp.RotVelocity or Vector3.zero
                if vel.Magnitude > 250 or rotVel.Magnitude > 250 then
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end
            end
        end)
    end
end

task.spawn(function()
    while true do
        if Config.Defense.AntiStab and State.Murderer and State.Murderer.Character then
            task.wait(0.08)
            local mHrp = State.Murderer.Character:FindFirstChild("HumanoidRootPart")
            local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")

            if mHrp and myHrp and humanoid then
                local dist = (mHrp.Position - myHrp.Position).Magnitude
                if dist <= Config.Defense.EvadeDistance then
                    local evadeDir = (myHrp.Position - mHrp.Position).Unit
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    myHrp.CFrame = myHrp.CFrame + (evadeDir * 12) + Vector3.new(0, 8, 0)
                end
            end
        else
            task.wait(0.5)
        end
    end
end)

local function SetGhostMode(enabled)
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = enabled and 0.65 or 0
        elseif part:IsA("Decal") then
            part.Transparency = enabled and 0.65 or 0
        end
    end
end

-- ==============================================================================
-- 15. SAFE COIN AUTO-FARM (DUAL-MODE: INSTANT ANTI-CHEAT SAFE / KICK-PROOF TWEEN)
-- ==============================================================================
local function CollectCoinSafe(coinPart)
    if not coinPart or not coinPart.Parent or not LocalPlayer.Character then return false end
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return false end

    -- Verify not collected yet
    if not IsValidCoin(coinPart) then return false end

    if Config.AutoFarm.AvoidMurderer and State.Murderer and State.Murderer.Character then
        local mHrp = State.Murderer.Character:FindFirstChild("HumanoidRootPart")
        if mHrp and (mHrp.Position - coinPart.Position).Magnitude < 24 then
            State.CoinCooldowns[coinPart] = os.clock() + 4.0
            return false
        end
    end

    local startPos = hrp.Position
    -- Standing elevation offset: +2.3 studs positions character upright above floor geometry
    -- Prevents character feet/legs from penetrating floor mesh, eliminating physics depenetration kicks/flings
    local targetPos = coinPart.Position + Vector3.new(0, 2.3, 0)
    local distance = (targetPos - startPos).Magnitude

    -- Soft limb noclip during glide/warp to prevent snagging on geometry
    local char = LocalPlayer.Character
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.CanCollide = false
        end
    end

    if Config.AutoFarm.Mode == "Instant" then
        -- Anti-cheat safe instant warp sequence
        hrp.CFrame = CFrame.new(targetPos)
        pcall(function()
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)

        pcall(function()
            firetouchinterest(hrp, coinPart, 0)
            task.wait(0.02)
            firetouchinterest(hrp, coinPart, 1)

            local vis = coinPart:FindFirstChild("CoinVisual")
            if vis and vis:IsA("BasePart") then
                firetouchinterest(hrp, vis, 0)
                task.wait(0.02)
                firetouchinterest(hrp, vis, 1)
            end
        end)

        pcall(function()
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)

        State.CollectedCoins[coinPart] = true
        State.CoinCooldowns[coinPart] = os.clock() + 5.0

        -- Anti-cheat rate limit cooldown: wait user-configured delay (0.15s - 0.25s)
        local delayTime = math.clamp(Config.AutoFarm.InstantDelay or 0.20, 0.05, 0.6)
        task.wait(delayTime)
        return true
    else
        -- Standard Kick-Proof Tweening
        local speed = math.clamp(Config.AutoFarm.Speed, 18, 35)
        local duration = math.clamp(distance / speed, 0.15, 3.5)

        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})

        -- Character physics controller fights unanchored Tweens.
        -- Temporarily anchoring hrp allows TweenService to translate position cleanly without rubberbanding or physics fighting.
        hrp.Anchored = true
        State.ActiveFarmTween = tween
        tween:Play()

        local completed = false
        local conn
        conn = tween.Completed:Connect(function()
            completed = true
            if conn then conn:Disconnect() end
        end)

        local waitStart = tick()
        while not completed and (tick() - waitStart < duration + 0.35) do
            task.wait(0.03)
            if not Config.AutoFarm.Enabled or hum.Health <= 0 or not coinPart.Parent or coinPart:GetAttribute("Collected") == true then
                tween:Cancel()
                break
            end
        end

        -- Restore unanchored state immediately upon arrival or cancel
        pcall(function()
            if hrp and hrp.Parent then
                hrp.Anchored = false
            end
        end)

        -- Dual touch interest activation (coin server + coin visual)
        pcall(function()
            firetouchinterest(hrp, coinPart, 0)
            task.wait(0.02)
            firetouchinterest(hrp, coinPart, 1)

            local vis = coinPart:FindFirstChild("CoinVisual")
            if vis and vis:IsA("BasePart") then
                firetouchinterest(hrp, vis, 0)
                task.wait(0.02)
                firetouchinterest(hrp, vis, 1)
            end
        end)

        -- Velocity dampening: zero out linear & angular velocity to prevent momentum flings
        pcall(function()
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)

        State.CollectedCoins[coinPart] = true
        State.CoinCooldowns[coinPart] = os.clock() + 5.0

        State.ActiveFarmTween = nil
        return true
    end
end

task.spawn(function()
    local farmStartCFrame = nil
    while true do
        task.wait(0.05)
        if Config.AutoFarm.Enabled and IsLocalInMap() and not IsBagFull() then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")
            if hrp and hum and hum.Health > 0 then
                if not farmStartCFrame then
                    farmStartCFrame = hrp.CFrame
                end
                -- Greedily pick the absolute closest valid coin to our CURRENT position
                local closestCoin, dist = GetClosestValidCoin(hrp.Position)
                if closestCoin then
                    CollectCoinSafe(closestCoin)
                    if Config.AutoFarm.Mode ~= "Instant" then
                        task.wait(0.04)
                    end
                else
                    task.wait(0.25)
                end
            end
        else
            if farmStartCFrame then
                if Config.AutoFarm.ReturnOnFull and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    pcall(function()
                        LocalPlayer.Character.HumanoidRootPart.CFrame = farmStartCFrame
                    end)
                end
                farmStartCFrame = nil
            end
            if IsBagFull() and Config.AutoFarm.Enabled then
                task.wait(1.5)
            end
        end
    end
end)

-- Gun Snatcher Routine
task.spawn(function()
    while true do
        task.wait(0.15)
        if Config.Combat.InstantGrabGun then
            ScanGunDrop()
            if State.GunDrop and State.GunDrop.Parent and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local char = LocalPlayer.Character
                local hrp = char.HumanoidRootPart
                local originalPos = hrp.CFrame

                hrp.CFrame = State.GunDrop.CFrame + Vector3.new(0, 1.5, 0)
                task.wait(0.05)
                pcall(function()
                    firetouchinterest(hrp, State.GunDrop, 0)
                    task.wait(0.02)
                    firetouchinterest(hrp, State.GunDrop, 1)
                end)

                if Config.Combat.InstantGrabReturn then
                    task.wait(0.05)
                    hrp.CFrame = originalPos
                end
                task.wait(1.5)
            end
        end
    end
end)

-- ==============================================================================
-- 16. MOVEMENT ENGINE (FLY, NOCLIP, SPEED)
-- ==============================================================================
local function StartFlying()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if State.FlyBodyVelocity then State.FlyBodyVelocity:Destroy() end
    if State.FlyBodyGyro then State.FlyBodyGyro:Destroy() end

    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.zero
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Parent = hrp
    State.FlyBodyVelocity = bv

    local bg = Instance.new("BodyGyro")
    bg.CFrame = hrp.CFrame
    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bg.Parent = hrp
    State.FlyBodyGyro = bg
end

local function StopFlying()
    if State.FlyBodyVelocity then
        State.FlyBodyVelocity:Destroy()
        State.FlyBodyVelocity = nil
    end
    if State.FlyBodyGyro then
        State.FlyBodyGyro:Destroy()
        State.FlyBodyGyro = nil
    end
end

RunService.RenderStepped:Connect(function()
    if Config.Movement.FlyEnabled and State.FlyBodyVelocity and State.FlyBodyGyro then
        local cam = Camera
        local moveDir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

        State.FlyBodyVelocity.Velocity = moveDir * Config.Movement.FlySpeed
        State.FlyBodyGyro.CFrame = cam.CFrame
    end
end)

RunService.Stepped:Connect(function()
    if Config.Movement.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Config.Movement.InfJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.N then
        Config.Movement.Noclip = not Config.Movement.Noclip
        pcall(function()
            if Fluent and Fluent.Options and Fluent.Options.NoclipToggle then
                Fluent.Options.NoclipToggle:SetValue(Config.Movement.Noclip)
            end
            if Fluent and Fluent.Notify then
                Fluent:Notify({
                    Title = "Noclip",
                    Content = "Noclip: " .. (Config.Movement.Noclip and "ENABLED [N]" or "DISABLED [N]"),
                    Duration = 1.8
                })
            end
        end)
    elseif input.KeyCode == Enum.KeyCode.G then
        local grabbed = GrabDroppedGun()
        Config.Combat.InstantGrabGun = not Config.Combat.InstantGrabGun
        pcall(function()
            if Fluent and Fluent.Options and Fluent.Options.InstantGrabGunToggle then
                Fluent.Options.InstantGrabGunToggle:SetValue(Config.Combat.InstantGrabGun)
            end
            if Fluent and Fluent.Notify then
                Fluent:Notify({
                    Title = "Instant Grab Gun",
                    Content = "Grab Gun: " .. (Config.Combat.InstantGrabGun and "ACTIVE [G]" or "OFF [G]") .. (grabbed and " (Gun Snapped!)" or ""),
                    Duration = 2
                })
            end
        end)
    end
end)

local movementHeartbeatConn = nil
local function CheckMovementHeartbeat()
    if Config.Movement.SpeedEnabled or Config.Movement.JumpEnabled or Config.Movement.BunnyHop then
        if not movementHeartbeatConn then
            movementHeartbeatConn = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChild("Humanoid")
                if hum then
                    if Config.Movement.SpeedEnabled then
                        hum.WalkSpeed = Config.Movement.WalkSpeed
                    end
                    if Config.Movement.JumpEnabled then
                        hum.UseJumpPower = true
                        hum.JumpPower = Config.Movement.JumpPower
                    end
                    if Config.Movement.BunnyHop and hum.FloorMaterial ~= Enum.Material.Air and hum.MoveDirection.Magnitude > 0 then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
        end
    else
        if movementHeartbeatConn then
            movementHeartbeatConn:Disconnect()
            movementHeartbeatConn = nil
        end
    end
end

-- ==============================================================================
-- 17. VISUALS & UTILITIES
-- ==============================================================================
local function ApplyFullbright(enabled)
    if enabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 1e5
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
    else
        Lighting.Brightness = DefaultLighting.Brightness
        Lighting.ClockTime = DefaultLighting.ClockTime
        Lighting.FogEnd = DefaultLighting.FogEnd
        Lighting.GlobalShadows = DefaultLighting.GlobalShadows
        Lighting.Ambient = DefaultLighting.Ambient
        Lighting.OutdoorAmbient = DefaultLighting.OutdoorAmbient
    end
end

local function PlayEmote(emoteName)
    local emoteRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Misc") and ReplicatedStorage.Remotes.Misc:FindFirstChild("PlayEmote")
    if emoteRemote then
        emoteRemote:Fire(emoteName)
    end
end

local function GetPlayerNamesList()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(names, p.DisplayName .. " (@" .. p.Name .. ")")
        end
    end
    if #names == 0 then table.insert(names, "No Other Players") end
    table.sort(names)
    return names
end

local function ResolvePlayerFromSelection(selectedText)
    if not selectedText or selectedText == "" or selectedText == "No Other Players" then return nil end
    local username = selectedText:match("@([%w_]+)")
    if username then
        return Players:FindFirstChild(username)
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.DisplayName == selectedText or p.Name == selectedText then
            return p
        end
    end
    return nil
end

-- ==============================================================================
-- 18. MASTER FLUENT SUITE INITIALIZER (8 CLEAN ORGANIZED TABS)
-- ==============================================================================
InitFluentSuite = function()
    local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

    local isMobile = IsMobileDevice()
    local vp = Camera.ViewportSize
    local windowSize = isMobile
        and UDim2.fromOffset(math.clamp(vp.X - 30, 340, 520), math.clamp(vp.Y - 30, 270, 390))
        or UDim2.fromOffset(640, 520)
    local tabWidth = isMobile and 120 or 160

    local Window = Fluent:CreateWindow({
        Title = "MM2 APEX SUITE",
        SubTitle = isMobile and "Free Edition • B1NCH3" or "Free Community Edition • B1NCH3",
        TabWidth = tabWidth,
        Size = windowSize,
        Acrylic = false, -- Zero-lag optimization: disabled blur shader
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.RightShift
    })

    if isMobile or UserInputService.TouchEnabled then
        task.defer(function()
            if not mobileToggleGuiInstance or not mobileToggleGuiInstance.Parent then
                mobileToggleGuiInstance = CreateMobileMenuToggle(Window)
            end
        end)
    end

    -- DOCKED SIDEBAR PROFILE WIDGET
    pcall(function()
        local parentFrame = Window.Root or (Window.TitleBar and Window.TitleBar.Frame and Window.TitleBar.Frame.Parent)
        if parentFrame then
            local sideProfile = Instance.new("TextButton")
            sideProfile.Name = "SidebarProfileWidget"
            sideProfile.Size = UDim2.new(0, tabWidth - 16, 0, 48)
            sideProfile.Position = UDim2.new(0, 8, 1, -56)
            sideProfile.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
            sideProfile.BorderSizePixel = 0
            sideProfile.Text = ""
            sideProfile.AutoButtonColor = false
            sideProfile.ZIndex = 5
            sideProfile.Parent = parentFrame

            local spCorner = Instance.new("UICorner")
            spCorner.CornerRadius = UDim.new(0, 6)
            spCorner.Parent = sideProfile

            local spStroke = Instance.new("UIStroke")
            spStroke.Color = Color3.fromRGB(44, 44, 54)
            spStroke.Thickness = 0.8
            spStroke.Parent = sideProfile

            local avFrame = Instance.new("Frame")
            avFrame.Size = UDim2.new(0, 32, 0, 32)
            avFrame.Position = UDim2.new(0, 8, 0.5, -16)
            avFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
            avFrame.BorderSizePixel = 0
            avFrame.Parent = sideProfile

            local avCorner = Instance.new("UICorner")
            avCorner.CornerRadius = UDim.new(1, 0)
            avCorner.Parent = avFrame

            local avImg = Instance.new("ImageLabel")
            avImg.Size = UDim2.new(1, 0, 1, 0)
            avImg.BackgroundTransparency = 1
            avImg.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
            avImg.Parent = avFrame

            local imgCorner = Instance.new("UICorner")
            imgCorner.CornerRadius = UDim.new(1, 0)
            imgCorner.Parent = avImg

            task.spawn(function()
                pcall(function()
                    local thumb, ready = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
                    if ready and thumb then avImg.Image = thumb end
                end)
            end)

            local dName = Instance.new("TextLabel")
            dName.Size = UDim2.new(1, -48, 0, 14)
            dName.Position = UDim2.new(0, 46, 0, 6)
            dName.Text = LocalPlayer.DisplayName
            dName.Font = Enum.Font.Ubuntu
            dName.TextSize = 11
            dName.TextColor3 = Color3.fromRGB(245, 245, 250)
            dName.TextXAlignment = Enum.TextXAlignment.Left
            dName.TextTruncate = Enum.TextTruncate.AtEnd
            dName.BackgroundTransparency = 1
            dName.Parent = sideProfile

            local expText = Instance.new("TextLabel")
            expText.Size = UDim2.new(1, -48, 0, 12)
            expText.Position = UDim2.new(0, 46, 0, 22)
            expText.Text = "FREE EDITION • ACTIVE"
            expText.Font = Enum.Font.Ubuntu
            expText.TextSize = 9
            expText.TextColor3 = Color3.fromRGB(0, 255, 170)
            expText.TextXAlignment = Enum.TextXAlignment.Left
            expText.TextTruncate = Enum.TextTruncate.AtEnd
            expText.BackgroundTransparency = 1
            expText.Parent = sideProfile

            local tierBadge = Instance.new("TextLabel")
            tierBadge.Size = UDim2.new(1, -48, 0, 10)
            tierBadge.Position = UDim2.new(0, 46, 0, 34)
            tierBadge.Text = "@" .. LocalPlayer.Name
            tierBadge.Font = Enum.Font.Ubuntu
            tierBadge.TextSize = 8
            tierBadge.TextColor3 = Color3.fromRGB(140, 140, 160)
            tierBadge.TextXAlignment = Enum.TextXAlignment.Left
            tierBadge.TextTruncate = Enum.TextTruncate.AtEnd
            tierBadge.BackgroundTransparency = 1
            tierBadge.Parent = sideProfile

            sideProfile.MouseEnter:Connect(function()
                TweenService:Create(spStroke, TweenInfo.new(0.18), {Color = Color3.fromRGB(0, 120, 215)}):Play()
                TweenService:Create(sideProfile, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(32, 32, 40)}):Play()
            end)
            sideProfile.MouseLeave:Connect(function()
                TweenService:Create(spStroke, TweenInfo.new(0.18), {Color = Color3.fromRGB(44, 44, 54)}):Play()
                TweenService:Create(sideProfile, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(26, 26, 32)}):Play()
            end)

            sideProfile.MouseButton1Click:Connect(function()
                pcall(function()
                    Window:SelectTab(7)
                end)
            end)
        end
    end)

    -- ORGANIZED 8 SELECTIONS
    local Tabs = {
        Combat = Window:AddTab({ Title = "Combat", Icon = "crosshair" }),
        Fling = Window:AddTab({ Title = "Fling Engine", Icon = "zap" }),
        Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
        Farm = Window:AddTab({ Title = "Auto-Farm", Icon = "coins" }),
        Move = Window:AddTab({ Title = "Movement & Defense", Icon = "shield" }),
        Teleports = Window:AddTab({ Title = "Teleports & World", Icon = "map-pin" }),
        Community = Window:AddTab({ Title = "Community", Icon = "users" }),
        Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
    }

    -- ==========================================================================
    -- TAB 1: COMBAT (EXPANDER, MURDERER KILL AURA, SHOOTER SILENT AIM, GRAB GUN)
    -- ==========================================================================
    Tabs.Combat:AddParagraph({ Title = "Hitbox Expander", Content = "Expand opponent collision boundaries for effortless hits." })

    Tabs.Combat:AddToggle("HitboxToggle", {Title = "Expand Player Hitboxes", Default = Config.Combat.HitboxExpander}):OnChanged(function(v)
        Config.Combat.HitboxExpander = v
        UpdateHitboxExpander()
    end)

    Tabs.Combat:AddSlider("HitboxSlider", {
        Title = "Hitbox Dimension (Studs)",
        Min = 4,
        Max = 35,
        Default = Config.Combat.HitboxSize,
        Rounding = 0,
        Callback = function(v)
            Config.Combat.HitboxSize = v
            if Config.Combat.HitboxExpander then
                UpdateHitboxExpander()
            end
        end
    })

    Tabs.Combat:AddParagraph({ Title = "Murderer Kill Aura", Content = "Autonomous knife slash radius when playing as Murderer." })

    Tabs.Combat:AddToggle("MurdererKillAuraToggle", {Title = "Murderer Kill Aura (Knife Slash)", Default = Config.Combat.MurdererKillAura}):OnChanged(function(v)
        Config.Combat.MurdererKillAura = v
    end)

    Tabs.Combat:AddSlider("MurdererAuraDistSlider", {
        Title = "Knife Kill Aura Range (Studs)",
        Min = 10,
        Max = 35,
        Default = Config.Combat.MurdererAuraRange,
        Rounding = 0,
        Callback = function(v)
            Config.Combat.MurdererAuraRange = v
        end
    })

    Tabs.Combat:AddParagraph({ Title = "Shooter & Hero Silent Aim", Content = "Directs revolver bullets straight into Murderer with velocity prediction." })

    Tabs.Combat:AddToggle("ShooterSilentAimToggle", {Title = "Shooter & Hero Silent Aim (Gun)", Default = Config.Combat.ShooterSilentAim}):OnChanged(function(v)
        Config.Combat.ShooterSilentAim = v
    end)

    Tabs.Combat:AddToggle("PredictionToggle", {Title = "Velocity Movement Prediction", Default = Config.Combat.PredictMovement}):OnChanged(function(v)
        Config.Combat.PredictMovement = v
    end)

    Tabs.Combat:AddParagraph({ Title = "Revolver Snatcher", Content = "Autonomous detection and instant retrieval of dropped revolver." })

    Tabs.Combat:AddToggle("InstantGrabGunToggle", {Title = "Instant Grab Dropped Gun", Default = Config.Combat.InstantGrabGun}):OnChanged(function(v)
        Config.Combat.InstantGrabGun = v
    end)

    Tabs.Combat:AddKeybind("InstantGrabGunKeybind", {
        Title = "Instant Grab Gun Keybind",
        Mode = "Toggle",
        Default = Config.Combat.InstantGrabGunKeybind,
        Callback = function(Value)
            Config.Combat.InstantGrabGun = Value
            if Fluent and Fluent.Options and Fluent.Options.InstantGrabGunToggle then
                Fluent.Options.InstantGrabGunToggle:SetValue(Value)
            end
            if Value then
                local grabbed = GrabDroppedGun()
                Fluent:Notify({
                    Title = "Instant Grab Gun",
                    Content = "Auto-Grab Enabled [G]" .. (grabbed and " (Gun Snapped!)" or ""),
                    Duration = 2
                })
            else
                Fluent:Notify({
                    Title = "Instant Grab Gun",
                    Content = "Auto-Grab Disabled [G]",
                    Duration = 2
                })
            end
        end
    })

    Tabs.Combat:AddButton({
        Title = "⚡ Snag Dropped Gun Now",
        Description = "Instantly touches and retrieves dropped revolver (Keybind: G)",
        Callback = function()
            local success = GrabDroppedGun()
            if success then
                Fluent:Notify({Title = "Gun Snagged", Content = "Retrieved revolver successfully!", Duration = 2.5})
            else
                Fluent:Notify({Title = "Gun Snag", Content = "No dropped revolver found in map.", Duration = 2})
            end
        end
    })

    -- ==========================================================================
    -- TAB 2: FLING ENGINE (FIXED & HIGH-POWERED)
    -- ==========================================================================
    Tabs.Fling:AddParagraph({ Title = "Target Player Fling", Content = "Select a specific player to launch high-torque physical kinetic distortion." })

    local FlingPlayerDropdown = Tabs.Fling:AddDropdown("FlingPlayerSelect", {
        Title = "Select Target Player",
        Values = GetPlayerNamesList(),
        Multi = false,
        Default = GetPlayerNamesList()[1]
    })
    FlingPlayerDropdown:OnChanged(function(v)
        State.SelectedFlingPlayer = ResolvePlayerFromSelection(v)
    end)

    Tabs.Fling:AddButton({
        Title = "🔄 Refresh Players List",
        Description = "Updates the player selector dropdown with active lobby players",
        Callback = function()
            FlingPlayerDropdown:SetValues(GetPlayerNamesList())
            Fluent:Notify({Title = "Players Refreshed", Content = "Fling list updated!", Duration = 1.5})
        end
    })

    Tabs.Fling:AddButton({
        Title = "💥 Launch Fling on Selected Player",
        Description = "Penetrates target and applies hyper-speed angular torque",
        Callback = function()
            local target = State.SelectedFlingPlayer
            if target then
                Fluent:Notify({Title = "Fling Engine", Content = "Launching fling on: " .. target.DisplayName, Duration = 2.5})
                LaunchFling(target)
            else
                Fluent:Notify({Title = "Fling Engine", Content = "Please select a valid player first.", Duration = 2})
            end
        end
    })

    Tabs.Fling:AddParagraph({ Title = "Quick Role Flings", Content = "Instantly fling Murderer or Sheriff without selecting." })

    Tabs.Fling:AddButton({
        Title = "🎯 God Fling Murderer",
        Description = "Launches hyper-speed rotational momentum at Murderer",
        Callback = function()
            ScanRoles()
            if State.Murderer then
                LaunchFling(State.Murderer)
                Fluent:Notify({Title = "Fling Engine", Content = "Fling cycle dispatched on Murderer!", Duration = 2.5})
            else
                Fluent:Notify({Title = "Fling Engine", Content = "Murderer has not spawned.", Duration = 2})
            end
        end
    })

    Tabs.Fling:AddButton({
        Title = "🛡️ God Fling Sheriff / Hero",
        Description = "Launches hyper-speed rotational momentum at Sheriff",
        Callback = function()
            ScanRoles()
            local target = State.Sheriff or State.Hero
            if target then
                LaunchFling(target)
                Fluent:Notify({Title = "Fling Engine", Content = "Fling cycle dispatched on Sheriff!", Duration = 2.5})
            else
                Fluent:Notify({Title = "Fling Engine", Content = "Sheriff has not spawned.", Duration = 2})
            end
        end
    })

    Tabs.Fling:AddButton({
        Title = "🌪️ Fling All Players (Lobby Wipe)",
        Description = "Sequentially flings all players across the lobby",
        Callback = function()
            Fluent:Notify({Title = "Lobby Wipe", Content = "Starting sequential fling cycle...", Duration = 3})
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    LaunchFling(p)
                    task.wait(0.1)
                end
            end
        end
    })

    Tabs.Fling:AddParagraph({ Title = "Passive Kinetic Auras", Content = "Touch-activated fling mechanisms." })

    Tabs.Fling:AddToggle("TouchFlingToggle", {Title = "⚡ Touch Fling (Walk-Fling Aura)", Default = Config.Fling.TouchFling}):OnChanged(function(v)
        SetTouchFling(v)
        Fluent:Notify({
            Title = "Touch Fling",
            Content = v and "Active: Anyone who touches you gets launched!" or "Touch Fling Disabled",
            Duration = 2.5
        })
    end)

    Tabs.Fling:AddSlider("FlingTime", {
        Title = "Fling Cycle Duration (Sec)",
        Min = 0.5,
        Max = 4.0,
        Default = Config.Fling.FlingDuration,
        Rounding = 1,
        Callback = function(v)
            Config.Fling.FlingDuration = v
        end
    })

    Tabs.Fling:AddSlider("FlingPowerSlider", {
        Title = "Kinetic Power Multiplier",
        Min = 10,
        Max = 100,
        Default = Config.Fling.FlingPower,
        Rounding = 0,
        Callback = function(v)
            Config.Fling.FlingPower = v
        end
    })

    -- ==========================================================================
    -- TAB 3: VISUALS (ESP)
    -- ==========================================================================
    Tabs.Visuals:AddParagraph({ Title = "Entity & Role ESP", Content = "Real-time wall penetration, distance calculations, and beacons." })

    Tabs.Visuals:AddToggle("MasterESP", {Title = "Master Role ESP (Chams)", Default = Config.ESP.Enabled}):OnChanged(function(v)
        Config.ESP.Enabled = v
        if not v then
            CleanPlayerESP()
        end
    end)

    Tabs.Visuals:AddToggle("GunDropESP", {Title = "Dropped Gun Tracker", Default = Config.ESP.GunDrop}):OnChanged(function(v)
        Config.ESP.GunDrop = v
        if not v then
            CleanGunDropESP()
        end
    end)

    Tabs.Visuals:AddToggle("CoinESP", {Title = "Map Coins Radar", Default = Config.ESP.Coins}):OnChanged(function(v)
        Config.ESP.Coins = v
        if not v then
            CleanCoinsESP()
        end
    end)

    Tabs.Visuals:AddToggle("TrapESP", {Title = "Bear Trap Radar", Default = Config.ESP.Traps}):OnChanged(function(v)
        Config.ESP.Traps = v
        if not v then
            CleanTrapsESP()
        end
    end)

    Tabs.Visuals:AddToggle("FullbrightToggle", {Title = "Fullbright (Night Vision)", Default = Config.Visuals.Fullbright}):OnChanged(function(v)
        Config.Visuals.Fullbright = v
        ApplyFullbright(v)
    end)

    -- ==========================================================================
    -- TAB 4: AUTO-FARM (KICK-PROOF)
    -- ==========================================================================
    Tabs.Farm:AddParagraph({ Title = "Automated Economy Engine", Content = "Collects coins with collision-safe physical tweening and auto bag-limit detect." })

    Tabs.Farm:AddToggle("AutoFarmCoins", {Title = "Auto-Farm Coins", Default = Config.AutoFarm.Enabled}):OnChanged(function(v)
        Config.AutoFarm.Enabled = v
        if not v and State.ActiveFarmTween then
            State.ActiveFarmTween:Cancel()
            State.ActiveFarmTween = nil
        end
    end)

    Tabs.Farm:AddDropdown("FarmModeSelect", {
        Title = "Farming Method",
        Values = {"Tween (Safe)", "Instant (Warp)"},
        Multi = false,
        Default = Config.AutoFarm.Mode == "Instant" and "Instant (Warp)" or "Tween (Safe)"
    }):OnChanged(function(v)
        Config.AutoFarm.Mode = (v:find("Instant") and "Instant" or "Tween")
        Fluent:Notify({
            Title = "Auto-Farm Mode",
            Content = "Farming mode set to: " .. v,
            Duration = 2
        })
    end)

    Tabs.Farm:AddSlider("InstantDelaySlider", {
        Title = "Instant Warp Anti-Cheat Delay (Sec)",
        Description = "Minimum safe delay between warps (0.15s - 0.25s recommended)",
        Min = 0.05,
        Max = 0.50,
        Default = Config.AutoFarm.InstantDelay,
        Rounding = 2,
        Callback = function(v)
            Config.AutoFarm.InstantDelay = v
        end
    })

    Tabs.Farm:AddSlider("FarmSpeed", {
        Title = "Tweening Travel Speed",
        Description = "Used when Farm Mode is set to Tween (Safe)",
        Min = 15,
        Max = 35,
        Default = Config.AutoFarm.Speed,
        Rounding = 0,
        Callback = function(v)
            Config.AutoFarm.Speed = v
        end
    })

    Tabs.Farm:AddToggle("AvoidMurderer", {Title = "Avoid Murderer During Farm", Default = Config.AutoFarm.AvoidMurderer}):OnChanged(function(v)
        Config.AutoFarm.AvoidMurderer = v
    end)

    Tabs.Farm:AddToggle("ReturnOnFull", {Title = "Return to Start Position on Full Bag", Default = Config.AutoFarm.ReturnOnFull}):OnChanged(function(v)
        Config.AutoFarm.ReturnOnFull = v
    end)

    Tabs.Farm:AddButton({
        Title = "Clear Coin History & Reset Farm",
        Description = "Manually flushes coin cache and unlocks auto-collector",
        Callback = function()
            State.BagFull = false
            State.CurrentCoins = 0
            table.clear(State.CollectedCoins)
            table.clear(State.CoinCooldowns)
            Fluent:Notify({Title = "Auto-Farm", Content = "Coin cache cleared and farm reset.", Duration = 2})
        end
    })

    -- ==========================================================================
    -- TAB 5: MOVEMENT & DEFENSE
    -- ==========================================================================
    Tabs.Move:AddParagraph({ Title = "Physics & Locomotion", Content = "Flight, noclip, speed adjustments, and infinite jump." })

    Tabs.Move:AddToggle("FlyToggle", {Title = "Enable Flight Mode", Default = Config.Movement.FlyEnabled}):OnChanged(function(v)
        Config.Movement.FlyEnabled = v
        if v then
            StartFlying()
        else
            StopFlying()
        end
    end)

    Tabs.Move:AddSlider("FlySpeedSlider", {
        Title = "Flight Velocity",
        Min = 10,
        Max = 120,
        Default = Config.Movement.FlySpeed,
        Rounding = 0,
        Callback = function(v)
            Config.Movement.FlySpeed = v
        end
    })

    Tabs.Move:AddToggle("NoclipToggle", {Title = "Noclip (Pass Through Walls)", Default = Config.Movement.Noclip}):OnChanged(function(v)
        Config.Movement.Noclip = v
    end)

    Tabs.Move:AddKeybind("NoclipKeybind", {
        Title = "Noclip Keybind",
        Mode = "Toggle",
        Default = Config.Movement.NoclipKeybind,
        Callback = function(Value)
            Config.Movement.Noclip = Value
            if Fluent and Fluent.Options and Fluent.Options.NoclipToggle then
                Fluent.Options.NoclipToggle:SetValue(Value)
            end
            Fluent:Notify({
                Title = "Noclip",
                Content = "Noclip: " .. (Value and "ENABLED [N]" or "DISABLED [N]"),
                Duration = 2
            })
        end
    })

    Tabs.Move:AddToggle("InfJumpToggle", {Title = "Infinite Jump", Default = Config.Movement.InfJump}):OnChanged(function(v)
        Config.Movement.InfJump = v
    end)

    Tabs.Move:AddToggle("SpeedToggle", {Title = "Custom WalkSpeed", Default = Config.Movement.SpeedEnabled}):OnChanged(function(v)
        Config.Movement.SpeedEnabled = v
        CheckMovementHeartbeat()
    end)

    Tabs.Move:AddSlider("SpeedSlider", {
        Title = "WalkSpeed Value",
        Min = 16,
        Max = 80,
        Default = Config.Movement.WalkSpeed,
        Rounding = 0,
        Callback = function(v)
            Config.Movement.WalkSpeed = v
        end
    })

    Tabs.Move:AddToggle("BunnyHopToggle", {Title = "Bunny Hop (Auto-Jump)", Default = Config.Movement.BunnyHop}):OnChanged(function(v)
        Config.Movement.BunnyHop = v
        CheckMovementHeartbeat()
    end)

    Tabs.Move:AddParagraph({ Title = "Defense & Anti-Exploit", Content = "Anti-stab, anti-fling, and trap neutralizer." })

    Tabs.Move:AddToggle("AntiFlingToggle", {Title = "Anti-Fling Shield (Momentum Anchor)", Default = Config.Defense.AntiFling}):OnChanged(function(v)
        SyncAntiFling(v)
    end)

    Tabs.Move:AddToggle("AntiStab", {Title = "Anti-Stab Auto-Evade", Default = Config.Defense.AntiStab}):OnChanged(function(v)
        Config.Defense.AntiStab = v
    end)

    Tabs.Move:AddToggle("GhostMode", {Title = "Ghost Mode (Semi-Invisibility)", Default = Config.Defense.GhostMode}):OnChanged(function(v)
        Config.Defense.GhostMode = v
        SetGhostMode(v)
    end)

    Tabs.Move:AddButton({
        Title = "Activate Fake Gun Perk",
        Description = "Sends FakeGun network event so Murderer perceives you as Sheriff",
        Callback = function()
            local fakeGun = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Gameplay") and ReplicatedStorage.Remotes.Gameplay:FindFirstChild("FakeGun")
            if fakeGun then
                pcall(function() fakeGun:FireServer() end)
                Fluent:Notify({Title = "Fake Gun", Content = "FakeGun signal broadcasted!", Duration = 2.5})
            else
                Fluent:Notify({Title = "Fake Gun", Content = "FakeGun remote unavailable in this round.", Duration = 2})
            end
        end
    })

    -- ==========================================================================
    -- TAB 6: TELEPORTS & WORLD
    -- ==========================================================================
    Tabs.Teleports:AddParagraph({ Title = "Player Teleportation", Content = "Warp instantly to any player in the server." })

    local TeleportPlayerDropdown = Tabs.Teleports:AddDropdown("TeleportPlayerSelect", {
        Title = "Select Player to Teleport to",
        Values = GetPlayerNamesList(),
        Multi = false,
        Default = GetPlayerNamesList()[1]
    })
    TeleportPlayerDropdown:OnChanged(function(v)
        State.SelectedTeleportPlayer = ResolvePlayerFromSelection(v)
    end)

    Tabs.Teleports:AddButton({
        Title = "🔄 Refresh Players List",
        Description = "Updates the player selector dropdown",
        Callback = function()
            TeleportPlayerDropdown:SetValues(GetPlayerNamesList())
            Fluent:Notify({Title = "Players Refreshed", Content = "Teleport list updated!", Duration = 1.5})
        end
    })

    Tabs.Teleports:AddButton({
        Title = "Warp to Selected Player",
        Description = "Teleports 3 studs behind selected player",
        Callback = function()
            local target = State.SelectedTeleportPlayer
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                Fluent:Notify({Title = "Teleport", Content = "Arrived at " .. target.DisplayName .. "!", Duration = 2})
            else
                Fluent:Notify({Title = "Teleport", Content = "Player not found or dead.", Duration = 2})
            end
        end
    })

    Tabs.Teleports:AddParagraph({ Title = "Tactical Role Warps", Content = "Instant warps to critical game objects." })

    Tabs.Teleports:AddButton({
        Title = "Teleport to Dropped Gun",
        Description = "Warps directly to dropped revolver",
        Callback = function()
            ScanGunDrop()
            if State.GunDrop and State.GunDrop.Parent and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = State.GunDrop.CFrame + Vector3.new(0, 2, 0)
                Fluent:Notify({Title = "Teleport", Content = "Arrived at Dropped Gun!", Duration = 2})
            else
                Fluent:Notify({Title = "Teleport", Content = "No gun currently dropped.", Duration = 2})
            end
        end
    })

    Tabs.Teleports:AddButton({
        Title = "Teleport Behind Murderer",
        Description = "Warps 3 studs behind active Murderer",
        Callback = function()
            ScanRoles()
            if State.Murderer and State.Murderer.Character and State.Murderer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = State.Murderer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                Fluent:Notify({Title = "Teleport", Content = "Arrived behind Murderer!", Duration = 2})
            else
                Fluent:Notify({Title = "Teleport", Content = "Murderer not found.", Duration = 2})
            end
        end
    })

    Tabs.Teleports:AddButton({
        Title = "Teleport to Sheriff / Hero",
        Description = "Warps to active firearm carrier",
        Callback = function()
            ScanRoles()
            local target = State.Sheriff or State.Hero
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                Fluent:Notify({Title = "Teleport", Content = "Arrived at Sheriff!", Duration = 2})
            else
                Fluent:Notify({Title = "Teleport", Content = "Sheriff not found.", Duration = 2})
            end
        end
    })

    Tabs.Teleports:AddButton({
        Title = "Teleport to Safe Sky Vantage",
        Description = "Warps 80 studs above map to safely avoid Murderer",
        Callback = function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = hrp.CFrame + Vector3.new(0, 80, 0)
                Fluent:Notify({Title = "Vantage Point", Content = "Teleported high above map!", Duration = 2})
            end
        end
    })

    Tabs.Teleports:AddButton({
        Title = "Teleport to Lobby Spawn",
        Description = "Warps back to main spawn area",
        Callback = function()
            local lobby = workspace:FindFirstChild("Lobby") or workspace:FindFirstChild("Spawns")
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                if lobby and lobby:FindFirstChild("SpawnLocation") then
                    hrp.CFrame = lobby.SpawnLocation.CFrame + Vector3.new(0, 3, 0)
                else
                    hrp.CFrame = CFrame.new(-108, 140, -11)
                end
                Fluent:Notify({Title = "Teleport", Content = "Arrived at Lobby!", Duration = 2})
            end
        end
    })

    Tabs.Teleports:AddParagraph({ Title = "Server & Session Operations", Content = "Anti-AFK idle prevention, server hop, and fast reconnect." })

    Tabs.Teleports:AddButton({
        Title = "🛡️ Enable Anti-AFK (20m Disconnect Block)",
        Description = "Prevents Roblox from disconnecting your session due to inactivity",
        Callback = function()
            if not State.AntiAfkConnected then
                State.AntiAfkConnected = true
                LocalPlayer.Idled:Connect(function()
                    pcall(function()
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.new(0, 0))
                    end)
                end)
                Fluent:Notify({Title = "Anti-AFK", Content = "Idle disconnect blocker active!", Duration = 3})
            else
                Fluent:Notify({Title = "Anti-AFK", Content = "Anti-AFK is already active.", Duration = 2})
            end
        end
    })

    Tabs.Teleports:AddButton({
        Title = "🔄 Rejoin Current Server",
        Description = "Instantly reconnects to same server instance",
        Callback = function()
            Fluent:Notify({Title = "Reconnecting", Content = "Rejoining server instance...", Duration = 3})
            task.wait(0.5)
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end)
        end
    })

    Tabs.Teleports:AddButton({
        Title = "🌐 Server Hop (Lowest Ping)",
        Description = "Teleports to fresh populated server",
        Callback = function()
            Fluent:Notify({Title = "Server Hop", Content = "Searching for optimized server...", Duration = 3})
            task.spawn(function()
                local endpoint = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100", tostring(game.PlaceId))
                local success, raw = pcall(function() return game:HttpGet(endpoint) end)
                local result = success and HttpService:JSONDecode(raw)
                if success and result and result.data then
                    for _, s in ipairs(result.data) do
                        if s.playing < s.maxPlayers and s.id ~= game.JobId then
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                            return
                        end
                    end
                end
                Fluent:Notify({Title = "Server Hop", Content = "No alternative server found.", Duration = 3})
            end)
        end
    })

    -- ==========================================================================
    -- TAB 7: EMOTES & COMMUNITY
    -- ==========================================================================
    Tabs.Community:AddParagraph({ Title = "Free Emote Studio", Content = "Trigger official MM2 animations in real time." })

    local EmoteDropdown = Tabs.Community:AddDropdown("EmoteSelect", {
        Title = "Select Animation / Emote",
        Values = {"ninja", "dab", "floss", "zen", "zombie", "sit", "headless", "wave", "point", "laugh", "cheer", "dance1", "dance2", "dance3"},
        Multi = false,
        Default = "ninja",
    })
    EmoteDropdown:OnChanged(function(v)
        Config.Emotes.SelectedEmote = v
    end)

    Tabs.Community:AddButton({
        Title = "▶ Play Selected Emote",
        Callback = function()
            PlayEmote(Config.Emotes.SelectedEmote)
            Fluent:Notify({Title = "Emote Triggered", Content = "Playing: " .. Config.Emotes.SelectedEmote, Duration = 2})
        end
    })

    Tabs.Community:AddButton({
        Title = "⏹ Stop Current Emote",
        Callback = function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    })

    Tabs.Community:AddParagraph({
        Title = "Official Community & Updates",
        Content = "Welcome to our script community! Join our official Discord to get access to more free scripts, live updates, game support, and direct script requests."
    })

    Tabs.Community:AddButton({
        Title = "Copy Official Discord Link",
        Description = "Copies https://discord.gg/JSUbVWTYc to your clipboard",
        Callback = function()
            SafeCopy(Config.Security.DiscordInvite)
            Fluent:Notify({
                Title = "Discord Invite Copied",
                Content = "Link copied to clipboard! Paste it into Discord or browser.",
                Duration = 3
            })
        end
    })

    Tabs.Community:AddParagraph({
        Title = "Developer & Credits",
        Content = "Engineered by B1NCH3\n• 100% Free Public Release\n• Universal Luau & MacSploit Optimized\n• Regular updates for Murder Mystery 2"
    })


    -- ==========================================================================
    -- TAB 8: SETTINGS & DYNAMIC TYPOGRAPHY
    -- ==========================================================================
    Tabs.Settings:AddParagraph({ Title = "Interface Settings & Mobile Telemetry", Content = "Configure UI typography and on-screen touch navigation." })

    Tabs.Settings:AddToggle("MobileMenuToggleBtn", {
        Title = "Mobile Floating Menu Button",
        Default = isMobile or UserInputService.TouchEnabled
    }):OnChanged(function(v)
        if v then
            if not mobileToggleGuiInstance or not mobileToggleGuiInstance.Parent then
                mobileToggleGuiInstance = CreateMobileMenuToggle(Window)
            else
                mobileToggleGuiInstance.Enabled = true
            end
        else
            if mobileToggleGuiInstance then
                mobileToggleGuiInstance.Enabled = false
            end
        end
    end)

    local FontDropdown = Tabs.Settings:AddDropdown("UIFontFamilyDropdown", {
        Title = "UI Font Family",
        Values = {"Ubuntu", "Montserrat", "BuilderSans", "FredokaOne", "JosefinSans", "Michroma", "SourceSansBold", "GothamBold"},
        Multi = false,
        Default = Config.UI.ActiveFontName,
    })

    FontDropdown:OnChanged(function(fontName)
        Config.UI.ActiveFontName = fontName
        local targetEnum = AVAILABLE_FONTS[fontName]
        if targetEnum then
            FontEngine:ApplyFont(targetEnum)
            Fluent:Notify({
                Title = "Typography Updated",
                Content = "Applied " .. fontName .. " font to UI!",
                Duration = 2.5
            })
        end
    end)

    InterfaceManager:SetLibrary(Fluent)
    InterfaceManager:BuildInterfaceSection(Tabs.Settings)

    task.defer(function()
        FontEngine:ApplyFont(CurrentFont)
    end)

    Window:SelectTab(1)

    Fluent:Notify({
        Title = "MM2 APEX SUITE",
        Content = "Free Community Edition loaded! All features active.",
        Duration = 4
    })

    -- 5-Minute Execution Prompt (Strictly triggers 5 minutes after script execution)
    local executionStartTime = os.clock()
    local hasTriggeredPrompt = false
    task.spawn(function()
        while _G.MM2SuiteLoaded and not hasTriggeredPrompt do
            task.wait(1.0)
            if os.clock() - executionStartTime >= 300 then
                hasTriggeredPrompt = true
                ShowDiscordCommunityPrompt(Fluent)
                break
            end
        end
    end)

    print("[B1NCH3] MM2 Apex Suite initialized successfully. Developed by B1NCH3.")
end

-- ==============================================================================
-- 19. MAIN BACKGROUND LOOP & INITIALIZATION
-- ==============================================================================
task.spawn(function()
    while true do
        task.wait(0.2)
        if IsLocalInMap() then
            UpdateESP()
            UpdateHitboxExpander()
        else
            CleanAllESP()
            ResetAllHitboxes()
        end
    end
end)

-- Cleanup Handler
_G.MM2SuiteCleanup = function()
    pcall(function()
        if wsSuccess and type(WeaponService) == "table" then
            if originalGetMouseTargetCFrame then WeaponService.GetMouseTargetCFrame = originalGetMouseTargetCFrame end
            if originalGetTargetPosition then WeaponService.GetTargetPosition = originalGetTargetPosition end
        end
        for _, c in ipairs(gameEventsConns) do
            pcall(function() c:Disconnect() end)
        end
        table.clear(gameEventsConns)
        for p, _ in pairs(playerConnMap) do
            DisconnectPlayerListeners(p)
        end
        table.clear(playerConnMap)
        DestroyExistingFluentAndHUD()
        CleanAllESP()
        ResetAllHitboxes()
        ApplyFullbright(false)
        SetTouchFling(false)
        if State.ActiveFarmTween then State.ActiveFarmTween:Cancel(); State.ActiveFarmTween = nil end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.Anchored = false
        end
        if State.FlyBodyVelocity then State.FlyBodyVelocity:Destroy(); State.FlyBodyVelocity = nil end
        if State.FlyBodyGyro then State.FlyBodyGyro:Destroy(); State.FlyBodyGyro = nil end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.PlatformStand = false
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
            LocalPlayer.Character.Humanoid.UseJumpPower = false
            LocalPlayer.Character.Humanoid.JumpPower = 50
        end
        SetGhostMode(false)
        if mobileToggleGuiInstance and mobileToggleGuiInstance.Parent then
            mobileToggleGuiInstance:Destroy()
            mobileToggleGuiInstance = nil
        end

    end)
end

CleanAllESP()
ResetAllHitboxes()
ApplyFullbright(false)
DestroyExistingFluentAndHUD()
SetupGameEventListeners()

-- Launch Fluent immediately
task.defer(InitFluentSuite)

print("[B1NCH3] MM2 Apex Free Community Edition active.")
