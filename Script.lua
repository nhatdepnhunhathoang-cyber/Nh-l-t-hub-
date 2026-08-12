
--========================================================--
-- NHỌ LẬT HUB NOT CALI 🤪 (v4.5: REAL WALL HOP FLICK & LADDER FLICK)
--========================================================--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--========================================================--
-- CONFIGURATION
--========================================================--

local Config = {
    Fly = false,
    FlySpeed = 50,

    SpeedToggle = false,
    WalkSpeed = 16,

    JumpToggle = false,
    JumpPower = 50,

    Godmode = false,
    GodmodeOffset = 12,
    DamageSync = true,

    ShiftLock = false,
    InfJump = false,
    Noclip = false,

    Aimbot = false,
    DrawFOV = false,
    FOVSize = 150,

    KillAura = false,
    KillAuraDist = 30,

    ESPPlayer = false,
    ESPMobs = false,

    AutoWallHop = false,
    WallHopCameraFlick = true, -- Tự động lắc/flick camera màn hình giống real
    WallHopColorFilter = false,
    TargetWallColor = Color3.fromRGB(255, 255, 255),
    WallColorTolerance = 0.18,

    AutoLadderFlick = false,   -- Ladder Flick Pro
    LadderFlickPower = 55,     -- Lực bật nảy khi flick thang

    SelectedTargetPlayer = nil,
    AutoFollowPlayer = false
}

_G.NhoLatHub = Config

--========================================================--
-- SAFE GUI CONTAINER & CLEANUP
--========================================================--

local function GetSafeGuiParent()
    if gethui then
        local ok, res = pcall(gethui)
        if ok and res and typeof(res) == "Instance" then return res end
    end
    local ok, core = pcall(function() return game:GetService("CoreGui") end)
    if ok and core and typeof(core) == "Instance" then return core end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local GuiParent = GetSafeGuiParent()

pcall(function()
    local oldNames = {"NhoLatHubCaliVer", "NhoLatHub"}
    for _, name in ipairs(oldNames) do
        local old = GuiParent:FindFirstChild(name)
        if old then old:Destroy() end
        local oldCore = game:GetService("CoreGui"):FindFirstChild(name)
        if oldCore then oldCore:Destroy() end
        if LocalPlayer:FindFirstChild("PlayerGui") then
            local oldPlr = LocalPlayer.PlayerGui:FindFirstChild(name)
            if oldPlr then oldPlr:Destroy() end
        end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NhoLatHubCaliVer"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = GuiParent

--========================================================--
-- SHIFT LOCK CROSSHAIR
--========================================================--

local CrosshairFrame = Instance.new("Frame")
CrosshairFrame.Name = "ShiftLockCrosshair"
CrosshairFrame.Size = UDim2.new(0, 12, 0, 12)
CrosshairFrame.Position = UDim2.new(0.5, -6, 0.5, -6)
CrosshairFrame.BackgroundTransparency = 1
CrosshairFrame.Visible = false
CrosshairFrame.ZIndex = 10000
CrosshairFrame.Parent = ScreenGui

local Dot = Instance.new("Frame")
Dot.Size = UDim2.new(0, 4, 0, 4)
Dot.Position = UDim2.new(0.5, -2, 0.5, -2)
Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Dot.BorderSizePixel = 0
Dot.Parent = CrosshairFrame

local LineV = Instance.new("Frame")
LineV.Size = UDim2.new(0, 2, 0, 12)
LineV.Position = UDim2.new(0, 0.5 - 1, 0, 0)
LineV.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LineV.BorderSizePixel = 0
LineV.Parent = CrosshairFrame

local LineH = Instance.new("Frame")
LineH.Size = UDim2.new(0, 12, 0, 2)
LineH.Position = UDim2.new(0, 0, 0.5, -1)
LineH.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LineH.BorderSizePixel = 0
LineH.Parent = CrosshairFrame

--========================================================--
-- HELPERS & STYLING
--========================================================--

local Colors = {
    Background = Color3.fromRGB(18, 15, 28),
    Dark = Color3.fromRGB(12, 10, 20),
    Item = Color3.fromRGB(25, 22, 38),
    Item2 = Color3.fromRGB(40, 35, 60),
    Purple = Color3.fromRGB(130, 50, 210),
    PurpleLight = Color3.fromRGB(200, 130, 255),
    Green = Color3.fromRGB(0, 180, 100),
    Red = Color3.fromRGB(180, 50, 50),
    White = Color3.fromRGB(255, 255, 255),
}

local function Corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = obj
    return c
end

local function Stroke(obj, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 1
    s.Parent = obj
    return s
end

local function Notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 3 })
    end)
end

local function GetCharacter() return LocalPlayer.Character end
local function GetHumanoid()
    local char = GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end
local function GetRoot()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

--========================================================--
-- MAIN UI SETUP
--========================================================--

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 330)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -165)
MainFrame.BackgroundColor3 = Colors.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

Corner(MainFrame, 10)
Stroke(MainFrame, Color3.fromRGB(70, 35, 100), 1)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 36)
TopBar.BackgroundColor3 = Colors.Dark
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "nhọ lật hub not Cali 🤪 (v4.5 - Real Flick & Ladder Flick)"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 13
Title.TextColor3 = Colors.PurpleLight
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 28, 0, 28)
CloseButton.Position = UDim2.new(1, -32, 0, 4)
CloseButton.Text = "×"
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 22
CloseButton.TextColor3 = Colors.White
CloseButton.BackgroundColor3 = Colors.Red
CloseButton.Parent = TopBar
Corner(CloseButton, 6)

local ToggleBtn = Instance.new("ImageButton")
ToggleBtn.Name = "OpenButton"
ToggleBtn.Size = UDim2.new(0, 52, 0, 52)
ToggleBtn.Position = UDim2.new(0, 15, 0.35, 0)
ToggleBtn.BackgroundColor3 = Colors.Dark
ToggleBtn.ZIndex = 9999
ToggleBtn.Visible = false
ToggleBtn.Parent = ScreenGui
Corner(ToggleBtn, 26)
Stroke(ToggleBtn, Colors.PurpleLight, 2)

task.spawn(function()
    pcall(function()
        local content = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        ToggleBtn.Image = content
    end)
end)

CloseButton.Activated:Connect(function() MainFrame.Visible = false; ToggleBtn.Visible = true end)
ToggleBtn.Activated:Connect(function() MainFrame.Visible = not MainFrame.Visible; ToggleBtn.Visible = not MainFrame.Visible end)

local function MakeDraggable(gui, handle)
    handle = handle or gui
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
MakeDraggable(MainFrame, TopBar)
MakeDraggable(ToggleBtn)

--========================================================--
-- TABS & BUILDERS
--========================================================--

local LeftPanel = Instance.new("Frame")
LeftPanel.Size = UDim2.new(0, 125, 1, -36)
LeftPanel.Position = UDim2.new(0, 0, 0, 36)
LeftPanel.BackgroundColor3 = Colors.Dark
LeftPanel.BorderSizePixel = 0
LeftPanel.Parent = MainFrame

local ResetButton = Instance.new("TextButton")
ResetButton.Size = UDim2.new(1, -16, 0, 32)
ResetButton.Position = UDim2.new(0, 8, 1, -40)
ResetButton.BackgroundColor3 = Colors.Red
ResetButton.Text = "Reset All 🔄"
ResetButton.TextColor3 = Colors.White
ResetButton.Font = Enum.Font.SourceSansBold
ResetButton.TextSize = 12
ResetButton.Parent = LeftPanel
Corner(ResetButton, 6)

local TabHeader = Instance.new("Frame")
TabHeader.Size = UDim2.new(1, -130, 0, 32)
TabHeader.Position = UDim2.new(0, 128, 0, 38)
TabHeader.BackgroundTransparency = 1
TabHeader.Parent = MainFrame

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 4)
TabLayout.Parent = TabHeader

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -133, 1, -76)
Content.Position = UDim2.new(0, 128, 0, 72)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local Tabs, Buttons, ToggleSetters = {}, {}, {}

local function CreateTab(name)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 70, 1, 0)
    button.BackgroundColor3 = Colors.Item
    button.Text = name
    button.TextColor3 = Colors.White
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 11
    button.Parent = TabHeader
    Corner(button, 6)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Colors.Purple
    scroll.Visible = false
    scroll.Parent = Content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)

    button.Activated:Connect(function()
        for _, tab in pairs(Tabs) do tab.Visible = false end
        for _, b in pairs(Buttons) do b.BackgroundColor3 = Colors.Item end
        scroll.Visible = true; button.BackgroundColor3 = Colors.Purple
    end)

    table.insert(Tabs, scroll); table.insert(Buttons, button)
    return scroll
end

local LocalTab = CreateTab("local 👽")
local TeleportTab = CreateTab("teleport 🚀")
local CombatTab = CreateTab("combat 🗿")
local VisualTab = CreateTab("visual 😈")
local WallTab = CreateTab("wall & ladder 🧗")

Tabs[1].Visible = true
Buttons[1].BackgroundColor3 = Colors.Purple

local function AddToggle(parent, key, text, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -8, 0, 36)
    frame.BackgroundColor3 = Colors.Item
    frame.Parent = parent
    Corner(frame, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -65, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Colors.White
    label.Font = Enum.Font.SourceSans
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 48, 0, 24)
    button.Position = UDim2.new(1, -54, 0.5, -12)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 11
    button.Parent = frame
    Corner(button, 5)

    local function Set(value)
        Config[key] = value
        button.Text = value and "ON" or "OFF"
        button.BackgroundColor3 = value and Colors.Green or Colors.Red
        button.TextColor3 = Colors.White
        if callback then task.spawn(function() pcall(callback, value) end) end
    end
    Set(Config[key])
    button.Activated:Connect(function() Set(not Config[key]) end)
    ToggleSetters[key] = Set
end

local function AddInput(parent, key, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -8, 0, 36)
    frame.BackgroundColor3 = Colors.Item
    frame.Parent = parent
    Corner(frame, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -95, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Colors.White
    label.Font = Enum.Font.SourceSans
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 80, 0, 24)
    box.Position = UDim2.new(1, -87, 0.5, -12)
    box.BackgroundColor3 = Colors.Item2
    box.TextColor3 = Colors.White
    box.Font = Enum.Font.SourceSansBold
    box.TextSize = 12
    box.Text = tostring(default)
    box.ClearTextOnFocus = false
    box.Parent = frame
    Corner(box, 5)

    box.FocusLost:Connect(function()
        local value = typeof(default) == "number" and tonumber(box.Text) or box.Text
        if typeof(default) == "number" and not value then box.Text = tostring(Config[key]); return end
        Config[key] = value
        if callback then task.spawn(function() pcall(callback, value) end) end
    end)
end

local function AddButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -8, 0, 32)
    button.BackgroundColor3 = Colors.Purple
    button.Text = text
    button.TextColor3 = Colors.White
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 12
    button.Parent = parent
    Corner(button, 6)

    button.Activated:Connect(function()
        if callback then task.spawn(function() pcall(callback) end) end
    end)
    return button
end

--========================================================--
-- ADVANCED GODMODE V4.0 (DAMAGE & INTERACTION SYNC)
--========================================================--

local VirtualCharacter = nil

local function EnableGodmode(state)
    local char = GetCharacter()
    local root = GetRoot()
    local hum = GetHumanoid()

    if state then
        if not char or not root or not hum then return end

        pcall(function()
            if VirtualCharacter then VirtualCharacter:Destroy() end

            char.Archivable = true
            VirtualCharacter = char:Clone()
            char.Archivable = false

            VirtualCharacter.Name = "VirtualGodmodeModel"
            VirtualCharacter.Parent = Workspace

            local vRoot = VirtualCharacter:FindFirstChild("HumanoidRootPart")
            local vHum = VirtualCharacter:FindFirstChildOfClass("Humanoid")

            if vRoot and vHum then
                vRoot.CFrame = root.CFrame * CFrame.new(0, Config.GodmodeOffset or 12, 0)
                
                for _, part in ipairs(VirtualCharacter:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Transparency = 0
                        part.CanCollide = true
                    elseif part:IsA("LocalScript") or part:IsA("Script") then
                        part:Destroy()
                    end
                end

                Camera.CameraSubject = vHum
            end

            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.LocalTransparencyModifier = 1
                end
            end
        end)

        Notify("nhọ lật hub", "🛡️ Đã BẬT Godmode v4.0 (Bất tử + Đánh Sát Thương)")
    else
        pcall(function()
            if VirtualCharacter then
                VirtualCharacter:Destroy()
                VirtualCharacter = nil
            end

            if hum then Camera.CameraSubject = hum end
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.LocalTransparencyModifier = 0
                    end
                end
            end
        end)

        Notify("nhọ lật hub", "🛡️ Đã TẮT Godmode")
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if Config.Godmode then EnableGodmode(true) end
end)

-- CONTROLS LOCAL
AddToggle(LocalTab, "Godmode", "🛡️ Godmode v4.0 (Bất Tử + Đánh Trúng 100%)", function(v) EnableGodmode(v) end)
AddToggle(LocalTab, "DamageSync", "⚔️ Đồng Bộ Hitbox Gây Sát Thương Đòn Đánh", function() end)
AddInput(LocalTab, "GodmodeOffset", "📐 Độ Cao Trốn Đạn Của Nhân Vật Thật", 12, function() end)

--========================================================--
-- TELEPORT TAB
--========================================================--

local PlayerSelectFrame = Instance.new("Frame")
PlayerSelectFrame.Size = UDim2.new(1, -8, 0, 90)
PlayerSelectFrame.BackgroundColor3 = Colors.Item
PlayerSelectFrame.Parent = TeleportTab
Corner(PlayerSelectFrame, 6)

local PlrTitle = Instance.new("TextLabel")
PlrTitle.Size = UDim2.new(1, 0, 0, 22)
PlrTitle.BackgroundTransparency = 1
PlrTitle.Text = "  Danh Sách Người Chơi (Bấm Chọn):"
PlrTitle.TextColor3 = Colors.PurpleLight
PlrTitle.Font = Enum.Font.SourceSansBold
PlrTitle.TextSize = 12
PlrTitle.TextXAlignment = Enum.TextXAlignment.Left
PlrTitle.Parent = PlayerSelectFrame

local PlrScroll = Instance.new("ScrollingFrame")
PlrScroll.Size = UDim2.new(1, -12, 1, -26)
PlrScroll.Position = UDim2.new(0, 6, 0, 22)
PlrScroll.BackgroundTransparency = 1
PlrScroll.ScrollBarThickness = 3
PlrScroll.Parent = PlayerSelectFrame

local PlrListLayout = Instance.new("UIListLayout")
PlrListLayout.Padding = UDim.new(0, 4)
PlrListLayout.Parent = PlrScroll

local SelectedPlrLabel = Instance.new("TextLabel")
SelectedPlrLabel.Size = UDim2.new(1, -8, 0, 26)
SelectedPlrLabel.BackgroundColor3 = Colors.Item2
SelectedPlrLabel.Text = "Đang chọn: Chưa chọn ai"
SelectedPlrLabel.TextColor3 = Colors.White
SelectedPlrLabel.Font = Enum.Font.SourceSans
SelectedPlrLabel.TextSize = 12
SelectedPlrLabel.Parent = TeleportTab
Corner(SelectedPlrLabel, 6)

local function RefreshPlayerList()
    pcall(function()
        for _, child in ipairs(PlrScroll:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -6, 0, 24)
                btn.BackgroundColor3 = Colors.Dark
                btn.Text = " 👤 " .. (plr.DisplayName or plr.Name) .. " (@" .. plr.Name .. ")"
                btn.TextColor3 = Colors.White
                btn.Font = Enum.Font.SourceSans
                btn.TextSize = 11
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.Parent = PlrScroll
                Corner(btn, 4)

                btn.Activated:Connect(function()
                    Config.SelectedTargetPlayer = plr
                    SelectedPlrLabel.Text = "Đang chọn: " .. (plr.DisplayName or plr.Name)
                    Notify("nhọ lật hub", "Đã chọn: " .. (plr.DisplayName or plr.Name))
                end)
            end
        end
        PlrScro
