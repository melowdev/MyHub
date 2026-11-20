--[[
    MM2 HUB — MOBILE COMPATIBLE (FIXED)
    Responsive UI | Touch Optimized | Fling System | Position Memory
]]

local Players   = game:GetService("Players")
local RS        = game:GetService("RunService")
local UIS       = game:GetService("UserInputService")
local TS        = game:GetService("TweenService")
local Lighting  = game:GetService("Lighting")
local Debris    = game:GetService("Debris")
local CS        = game:GetService("CollectionService")

local lp   = Players.LocalPlayer
local pgui = lp:WaitForChild("PlayerGui")
local cam  = workspace.CurrentCamera

-- ═══ MOBİL TESPİT ═══
local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local isTablet = UIS.TouchEnabled and UIS.KeyboardEnabled

-- ═══ ÖLÇEK ═══
local function getScale()
    local vp = cam.ViewportSize
    local scaleX = math.min(vp.X / 540 * 0.9, 1)
    local scaleY = math.min(vp.Y / 420 * 0.9, 1)
    return math.min(scaleX, scaleY)
end

local function isSmallScreen()
    return cam.ViewportSize.X < 600 or cam.ViewportSize.Y < 500
end

local scale = getScale()
local TW = math.floor(540 * scale)
local TH = math.floor(420 * scale)
local SIDEBAR_W = isSmallScreen() and 90 or 130
local HEADER_H = isMobile and 44 or 52
local BTN_HEIGHT = isMobile and 42 or 36

local OLD = pgui:FindFirstChild("MM2Tablet")
if OLD then OLD:Destroy() end

-- ═══ YARDIMCILAR ═══
local function C() return lp.Character end
local function R() local c=C(); return c and c:FindFirstChild("HumanoidRootPart") end
local function H() local c=C(); return c and c:FindFirstChildOfClass("Humanoid") end

local hasDrawing = pcall(function() return Drawing.new end)

-- ═══ ROL TESPİTİ ═══
local KNIFE_KW = {"knife","bıçak","sickle","virtual knife","mm2knife"}
local GUN_KW   = {"revolver","gun","sheriff","luger","mm2gun","pistol"}
local roleCache = {}

local function scanRole(plr)
    if plr == lp then return "self" end
    for _, src in pairs({plr.Character, plr:FindFirstChild("Backpack")}) do
        if not src then continue end
        for _, t in pairs(src:GetChildren()) do
            if t:IsA("Tool") then
                local n = t.Name:lower()
                for _, k in pairs(KNIFE_KW) do if n:find(k) then return "murderer" end end
                for _, g in pairs(GUN_KW)   do if n:find(g) then return "sheriff"  end end
            end
        end
    end
    return "innocent"
end

local function getRole(plr)
    local c = roleCache[plr]
    if c and tick() - c.t < 1 then return c.r end
    local r = scanRole(plr)
    roleCache[plr] = {r=r, t=tick()}
    return r
end

local RCOL = {
    murderer = Color3.fromRGB(255,70,70),
    sheriff  = Color3.fromRGB(70,150,255),
    innocent = Color3.fromRGB(90,220,90),
    self     = Color3.fromRGB(200,200,200),
    unknown  = Color3.fromRGB(160,160,160),
}
local RTXT = {
    murderer = "🔪 KATİL",
    sheriff  = "🔫 ŞERİF",
    innocent = "🟢 MASUM",
    self     = "👤 SEN",
    unknown  = "❔",
}

-- ══════════════════════════════════════════════
--  GUI
-- ══════════════════════════════════════════════
local sg = Instance.new("ScreenGui")
sg.Name = "MM2Tablet"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.DisplayOrder = 999
sg.Parent = pgui

local overlay = Instance.new("Frame", sg)
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = Color3.new(0, 0, 0)
overlay.BackgroundTransparency = 1
overlay.BorderSizePixel = 0
overlay.Visible = false

local tablet = Instance.new("Frame", sg)
tablet.Size = UDim2.fromOffset(TW, TH)
tablet.Position = UDim2.new(0.5, -TW/2, 0.5, -TH/2)
tablet.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
tablet.BorderSizePixel = 0
tablet.ClipsDescendants = true
tablet.Active = true
Instance.new("UICorner", tablet).CornerRadius = UDim.new(0, isMobile and 12 or 16)

-- ★ KONUM HAFIZASI — tablet oluşturulduktan hemen sonra
local savedPosition = tablet.Position

local stroke = Instance.new("UIStroke", tablet)
stroke.Color = Color3.fromRGB(45, 130, 255)
stroke.Thickness = 1.5
stroke.Transparency = 0.3

-- ─── Başlık ───
local header = Instance.new("Frame", tablet)
header.Size = UDim2.new(1, 0, 0, HEADER_H)
header.BackgroundColor3 = Color3.fromRGB(22, 22, 34)
header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0, isMobile and 12 or 16)
local headerFix = Instance.new("Frame", header)
headerFix.Size = UDim2.new(1, 0, 0.5, 0)
headerFix.Position = UDim2.new(0, 0, 0.5, 0)
headerFix.BackgroundColor3 = Color3.fromRGB(22, 22, 34)
headerFix.BorderSizePixel = 0

local logo = Instance.new("TextLabel", header)
local logoSize = isMobile and 32 or 38
logo.Size = UDim2.fromOffset(logoSize, logoSize)
logo.Position = UDim2.new(0, 8, 0.5, -logoSize/2)
logo.BackgroundColor3 = Color3.fromRGB(45, 130, 255)
logo.Text = "🔪"
logo.TextSize = isMobile and 16 or 20
logo.Font = Enum.Font.GothamBold
logo.TextColor3 = Color3.new(1,1,1)
logo.BorderSizePixel = 0
Instance.new("UICorner", logo).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(0, 180, 0, 18)
title.Position = UDim2.new(0, logoSize + 12, 0, isMobile and 6 or 9)
title.BackgroundTransparency = 1
title.Text = "MM2 HUB"
title.TextSize = isMobile and 13 or 15
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1,1,1)
title.TextXAlignment = Enum.TextXAlignment.Left

local subtitle = Instance.new("TextLabel", header)
subtitle.Size = UDim2.new(0, 180, 0, 12)
subtitle.Position = UDim2.new(0, logoSize + 12, 0, isMobile and 24 or 28)
subtitle.BackgroundTransparency = 1
subtitle.Text = "MOBILE EDITION"
subtitle.TextSize = 7
subtitle.Font = Enum.Font.GothamSemibold
subtitle.TextColor3 = Color3.fromRGB(120, 180, 255)
subtitle.TextXAlignment = Enum.TextXAlignment.Left

local hBtnSize = isMobile and 36 or 28
local function headerBtn(txt, ox, col)
    local b = Instance.new("TextButton", header)
    b.Size = UDim2.fromOffset(hBtnSize, hBtnSize)
    b.Position = UDim2.new(1, ox, 0.5, -hBtnSize/2)
    b.BackgroundColor3 = col
    b.Text = txt
    b.TextSize = isMobile and 16 or 13
    b.Font = Enum.Font.GothamBold
    b.TextColor3 = Color3.new(1,1,1)
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local closeBtn = headerBtn("✕", -(hBtnSize + 10), Color3.fromRGB(220, 50, 60))
local minBtn   = headerBtn("—", -(hBtnSize * 2 + 14), Color3.fromRGB(50, 50, 70))

-- ─── TABLET SÜRÜKLEME (konum kaydeder) ───
local dragging = false
local dragStart, startPos

header.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = i.Position
        startPos = tablet.Position
    end
end)

UIS.InputChanged:Connect(function(i)
    if not dragging then return end
    if i.UserInputType == Enum.UserInputType.MouseMovement
    or i.UserInputType == Enum.UserInputType.Touch then
        local d = i.Position - dragStart
        tablet.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y
        )
    end
end)

UIS.InputEnded:Connect(function(i)
    if not dragging then return end
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        dragging = false
        -- ★ Sürükleme bitti → konumu kaydet
        savedPosition = tablet.Position
    end
end)

-- ─── SIDEBAR ───
local sidebar = Instance.new("Frame", tablet)
sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, -HEADER_H)
sidebar.Position = UDim2.new(0, 0, 0, HEADER_H)
sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
sidebar.BorderSizePixel = 0

local sidebarPad = Instance.new("UIPadding", sidebar)
sidebarPad.PaddingTop = UDim.new(0, 6)
sidebarPad.PaddingLeft = UDim.new(0, 5)
sidebarPad.PaddingRight = UDim.new(0, 5)

local sidebarList = Instance.new("UIListLayout", sidebar)
sidebarList.Padding = UDim.new(0, 3)

-- ─── CONTENT ───
local contentFrame = Instance.new("Frame", tablet)
contentFrame.Size = UDim2.new(1, -SIDEBAR_W, 1, -HEADER_H)
contentFrame.Position = UDim2.new(0, SIDEBAR_W, 0, HEADER_H)
contentFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
contentFrame.BorderSizePixel = 0
contentFrame.ClipsDescendants = true

-- ─── TABS ───
local TABS = {
    {icon="👁", name="ESP"},
    {icon="🎯", name="Oyun"},
    {icon="👥", name="Oyuncu"},
    {icon="⚡", name="Karakter"},
    {icon="🎨", name="Görsel"},
    {icon="⚙", name="Ayar"},
}

local tabButtons, pages = {}, {}
local activeTab = 0

local function switchTab(idx)
    if activeTab == idx then return end
    for i, btn in ipairs(tabButtons) do
        local isA = i == idx
        TS:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = isA and Color3.fromRGB(45,130,255) or Color3.fromRGB(20,20,30)
        }):Play()
        if btn:FindFirstChild("Label") then
            TS:Create(btn.Label, TweenInfo.new(0.15), {
                TextColor3 = isA and Color3.new(1,1,1) or Color3.fromRGB(140,140,170)
            }):Play()
        end
        pages[i].Visible = isA
    end
    activeTab = idx
end

local tabHeight = isMobile and 46 or 42
for i, tab in ipairs(TABS) do
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(1, 0, 0, tabHeight)
    btn.BackgroundColor3 = Color3.fromRGB(20,20,30)
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local icon = Instance.new("TextLabel", btn)
    icon.Size = UDim2.fromOffset(isMobile and 28 or 24, tabHeight)
    icon.Position = UDim2.new(0, 4, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = tab.icon
    icon.TextSize = isMobile and 18 or 16
    icon.Font = Enum.Font.GothamBold
    icon.TextColor3 = Color3.new(1,1,1)

    local label = Instance.new("TextLabel", btn)
    label.Name = "Label"
    label.Size = UDim2.new(1, -(isMobile and 36 or 34), 1, 0)
    label.Position = UDim2.new(0, isMobile and 34 or 32, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = tab.name
    label.TextSize = isMobile and 10 or 11
    label.Font = Enum.Font.GothamSemibold
    label.TextColor3 = Color3.fromRGB(140,140,170)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd

    btn.MouseButton1Click:Connect(function() switchTab(i) end)
    tabButtons[i] = btn

    local page = Instance.new("ScrollingFrame", contentFrame)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = isMobile and 5 or 3
    page.ScrollBarImageColor3 = Color3.fromRGB(45,130,255)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.ClipsDescendants = true
    page.ScrollingEnabled = true
    page.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable

    local pad = Instance.new("UIPadding", page)
    pad.PaddingTop = UDim.new(0, 6)
    pad.PaddingLeft = UDim.new(0, isMobile and 6 or 10)
    pad.PaddingRight = UDim.new(0, isMobile and 6 or 10)
    pad.PaddingBottom = UDim.new(0, 10)

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, isMobile and 6 or 5)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    pages[i] = page
end

-- ══════════════════════════════════════════════
--  UI BİLEŞENLERİ
-- ══════════════════════════════════════════════
local function Section(parent, txt)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, isMobile and 24 or 22)
    f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = txt:upper()
    l.TextSize = isMobile and 10 or 9
    l.Font = Enum.Font.GothamBold
    l.TextColor3 = Color3.fromRGB(100,160,255)
    l.TextXAlignment = Enum.TextXAlignment.Left
    return f
end

local function Button(parent, txt, color, cb)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, 0, 0, BTN_HEIGHT)
    b.BackgroundColor3 = color or Color3.fromRGB(45,130,255)
    b.Text = txt
    b.TextSize = isMobile and 12 or 11
    b.Font = Enum.Font.GothamSemibold
    b.TextColor3 = Color3.new(1,1,1)
    b.BorderSizePixel = 0
    b.AutoButtonColor = true
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(function()
        if cb then pcall(cb) end
    end)
    return b
end

local function Toggle(parent, txt, cb)
    local row = Instance.new("TextButton", parent)
    row.Size = UDim2.new(1, 0, 0, isMobile and 46 or 40)
    row.BackgroundColor3 = Color3.fromRGB(24,24,36)
    row.Text = ""
    row.BorderSizePixel = 0
    row.AutoButtonColor = false
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -70, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = txt
    lbl.TextSize = isMobile and 12 or 11
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextColor3 = Color3.fromRGB(210,210,230)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true
    lbl.TextTruncate = Enum.TextTruncate.AtEnd

    local track = Instance.new("Frame", row)
    track.Size = UDim2.fromOffset(isMobile and 48 or 42, isMobile and 26 or 22)
    track.Position = UDim2.new(1, isMobile and -62 or -54, 0.5, isMobile and -13 or -11)
    track.BackgroundColor3 = Color3.fromRGB(50,50,68)
    track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("Frame", track)
    local knobSize = isMobile and 20 or 16
    knob.Size = UDim2.fromOffset(knobSize, knobSize)
    knob.Position = UDim2.new(0, 3, 0.5, -knobSize/2)
    knob.BackgroundColor3 = Color3.fromRGB(160,160,180)
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local on = false
    local function set(v)
        on = v
        TS:Create(track, TweenInfo.new(0.15), {
            BackgroundColor3 = v and Color3.fromRGB(45,130,255) or Color3.fromRGB(50,50,68)
        }):Play()
        TS:Create(knob, TweenInfo.new(0.15), {
            Position = v and UDim2.new(1, -(knobSize+3), 0.5, -knobSize/2) or UDim2.new(0, 3, 0.5, -knobSize/2),
            BackgroundColor3 = v and Color3.new(1,1,1) or Color3.fromRGB(160,160,180)
        }):Play()
        if cb then pcall(cb, v) end
    end

    row.MouseButton1Click:Connect(function() set(not on) end)
    return {set=set, get=function() return on end, row=row}
end

local function Slider(parent, txt, mn, mx, def, cb)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, isMobile and 62 or 52)
    f.BackgroundColor3 = Color3.fromRGB(24,24,36)
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)

    local name = Instance.new("TextLabel", f)
    name.Size = UDim2.new(0.65, 0, 0, 22)
    name.Position = UDim2.new(0, 12, 0, 6)
    name.BackgroundTransparency = 1
    name.Text = txt
    name.TextSize = isMobile and 12 or 11
    name.Font = Enum.Font.GothamSemibold
    name.TextColor3 = Color3.fromRGB(210,210,230)
    name.TextXAlignment = Enum.TextXAlignment.Left

    local val = Instance.new("TextLabel", f)
    val.Size = UDim2.new(0.3, 0, 0, 22)
    val.Position = UDim2.new(0.65, -10, 0, 6)
    val.BackgroundTransparency = 1
    val.Text = tostring(def)
    val.TextSize = isMobile and 12 or 11
    val.Font = Enum.Font.GothamBold
    val.TextColor3 = Color3.fromRGB(45,130,255)
    val.TextXAlignment = Enum.TextXAlignment.Right

    local trackH = isMobile and 28 or 22
    local track = Instance.new("Frame", f)
    track.Size = UDim2.new(1, -24, 0, trackH)
    track.Position = UDim2.new(0, 12, 1, isMobile and -34 or -20)
    track.BackgroundTransparency = 1

    local barBg = Instance.new("Frame", track)
    barBg.Size = UDim2.new(1, 0, 0, 5)
    barBg.Position = UDim2.new(0, 0, 0.5, -2.5)
    barBg.BackgroundColor3 = Color3.fromRGB(40,40,58)
    barBg.BorderSizePixel = 0
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1,0)

    local p0 = (def - mn) / (mx - mn)
    local fill = Instance.new("Frame", barBg)
    fill.Size = UDim2.new(p0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(45,130,255)
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

    local knobSize2 = isMobile and 18 or 13
    local knob = Instance.new("Frame", barBg)
    knob.Size = UDim2.fromOffset(knobSize2, knobSize2)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(p0, 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local dragging2 = false
    local function update(x)
        local p = math.clamp((x - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
        local v = math.floor(mn + p * (mx - mn))
        val.Text = tostring(v)
        fill.Size = UDim2.new(p, 0, 1, 0)
        knob.Position = UDim2.new(p, 0, 0.5, 0)
        if cb then pcall(cb, v) end
    end

    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging2 = true
            update(i.Position.X)
        end
    end)

    UIS.InputChanged:Connect(function(i)
        if dragging2 and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then
            update(i.Position.X)
        end
    end)

    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging2 = false
        end
    end)

    return f
end

-- ══════════════════════════════════════════════
--  ESP SİSTEMİ
-- ══════════════════════════════════════════════
local espData = {}
local espOn = false
local espUpdateConn

local function createESPFor(plr)
    if plr == lp or espData[plr] then return end
    local char = plr.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end
    local role = getRole(plr)
    local col = RCOL[role] or RCOL.unknown

    local bill = Instance.new("BillboardGui")
    bill.Name = "MM2ESP"
    bill.AlwaysOnTop = true
    bill.Size = UDim2.fromOffset(isMobile and 120 or 150, isMobile and 44 or 52)
    bill.StudsOffset = Vector3.new(0, 3.5, 0)
    bill.LightInfluence = 0

    local bg = Instance.new("Frame", bill)
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundColor3 = Color3.fromRGB(12,12,20)
    bg.BackgroundTransparency = 0.25
    bg.BorderSizePixel = 0
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 6)
    local st = Instance.new("UIStroke", bg)
    st.Color = col; st.Thickness = 1.2

    local rl = Instance.new("TextLabel", bg)
    rl.Size = UDim2.new(1,0,0.4,0)
    rl.BackgroundTransparency = 1
    rl.Text = RTXT[role] or "❔"
    rl.TextSize = isMobile and 10 or 11
    rl.Font = Enum.Font.GothamBold
    rl.TextColor3 = col

    local nl = Instance.new("TextLabel", bg)
    nl.Size = UDim2.new(1,0,0.3,0)
    nl.Position = UDim2.new(0,0,0.4,0)
    nl.BackgroundTransparency = 1
    nl.Text = plr.Name
    nl.TextSize = isMobile and 9 or 10
    nl.Font = Enum.Font.Gotham
    nl.TextColor3 = Color3.new(1,1,1)

    local hl = Instance.new("TextLabel", bg)
    hl.Size = UDim2.new(1,0,0.3,0)
    hl.Position = UDim2.new(0,0,0.7,0)
    hl.BackgroundTransparency = 1
    hl.TextSize = isMobile and 8 or 9
    hl.Font = Enum.Font.Gotham
    hl.TextColor3 = Color3.fromRGB(100,255,100)

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hl.Text = "❤ " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
    end

    bill.Parent = head
    espData[plr] = {bill=bill, head=head, role=role, healthLabel=hl}
end

local function removeESPFor(plr)
    local d = espData[plr]
    if d then pcall(function() d.bill:Destroy() end); espData[plr] = nil end
end

local function clearAllESP()
    for plr, _ in pairs(espData) do removeESPFor(plr) end
    espData = {}
end

local function refreshAllESP()
    clearAllESP()
    if not espOn then return end
    for _, plr in ipairs(Players:GetPlayers()) do createESPFor(plr) end
end

local function startESP()
    espOn = true
    refreshAllESP()
    local acc = 0
    espUpdateConn = RS.Heartbeat:Connect(function(dt)
        acc = acc + dt
        if acc < 0.3 then return end
        acc = 0
        for plr, data in pairs(espData) do
            if not data.bill.Parent or not plr.Character then
                removeESPFor(plr)
            else
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hum and data.healthLabel and data.healthLabel.Parent then
                    data.healthLabel.Text = "❤ " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
                end
            end
        end
    end)
end

local function stopESP()
    espOn = false
    if espUpdateConn then espUpdateConn:Disconnect(); espUpdateConn = nil end
    clearAllESP()
end

-- ══════════════════════════════════════════════
--  COIN / WEAPON ESP
-- ══════════════════════════════════════════════
local coinESPObjs, coinESPOn = {}, false
local function clearCoinESP()
    for _, o in ipairs(coinESPObjs) do pcall(function() o:Destroy() end) end
    coinESPObjs = {}
end
local function rebuildCoinESP()
    clearCoinESP()
    if not coinESPOn then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if n:find("coin") or n == "credit" then
                local bill = Instance.new("BillboardGui")
                bill.AlwaysOnTop = true
                bill.Size = UDim2.fromOffset(40, 18)
                bill.StudsOffset = Vector3.new(0, 2, 0)
                bill.LightInfluence = 0
                local l = Instance.new("TextLabel", bill)
                l.Size = UDim2.new(1,0,1,0)
                l.BackgroundTransparency = 1
                l.Text = "💰"; l.TextSize = 13
                bill.Parent = obj
                table.insert(coinESPObjs, bill)
            end
        end
    end
end

local weaponESPObjs, weaponESPOn = {}, false
local function clearWeaponESP()
    for _, o in ipairs(weaponESPObjs) do pcall(function() o:Destroy() end) end
    weaponESPObjs = {}
end
local function rebuildWeaponESP()
    clearWeaponESP()
    if not weaponESPOn then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") then
            local n = obj.Name:lower()
            local isK, isG = false, false
            for _, k in pairs(KNIFE_KW) do if n:find(k) then isK=true; break end end
            for _, g in pairs(GUN_KW)   do if n:find(g) then isG=true; break end end
            if isK or isG then
                local handle = obj:FindFirstChild("Handle")
                if handle then
                    local bill = Instance.new("BillboardGui")
                    bill.AlwaysOnTop = true
                    bill.Size = UDim2.fromOffset(60, 18)
                    bill.StudsOffset = Vector3.new(0, 2, 0)
                    bill.LightInfluence = 0
                    local l = Instance.new("TextLabel", bill)
                    l.Size = UDim2.new(1,0,1,0)
                    l.BackgroundTransparency = 1
                    l.Text = isK and "🔪" or "🔫"
                    l.TextSize = 12
                    l.TextColor3 = isK and Color3.fromRGB(255,80,80) or Color3.fromRGB(80,150,255)
                    bill.Parent = handle
                    table.insert(weaponESPObjs, bill)
                end
            end
        end
    end
end

-- ══════════════════════════════════════════════
--  TRACER
-- ══════════════════════════════════════════════
local tracerLines, tracerConn = {}, nil
local function clearTracers()
    for _, l in pairs(tracerLines) do pcall(function() l.Visible=false; l:Remove() end) end
    tracerLines = {}
end
local function startTracers()
    if not hasDrawing then return end
    clearTracers()
    tracerConn = RS.RenderStepped:Connect(function()
        for _, l in pairs(tracerLines) do pcall(function() l.Visible=false end) end
        local idx = 1
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == lp then continue end
            local role = getRole(plr)
            if role ~= "murderer" and role ~= "sheriff" then continue end
            local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if not root then continue end
            local sp, vis = cam:WorldToViewportPoint(root.Position)
            if not vis then continue end
            local line = tracerLines[idx]
            if not line then
                line = Drawing.new("Line")
                line.Thickness = 1.8
                tracerLines[idx] = line
            end
            line.From = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y - 20)
            line.To = Vector2.new(sp.X, sp.Y)
            line.Color = role == "murderer" and Color3.fromRGB(255,70,70) or Color3.fromRGB(70,150,255)
            line.Visible = true
            idx = idx + 1
        end
    end)
end
local function stopTracers()
    if tracerConn then tracerConn:Disconnect(); tracerConn = nil end
    clearTracers()
end

-- ══════════════════════════════════════════════
--  FLING SİSTEMİ
-- ══════════════════════════════════════════════
local function flingPlayer(plr, power, direction)
    local char = plr.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    power = power or 150
    direction = direction or Vector3.new(math.random(-1,1), math.random(0,1), math.random(-1,1))

    for _, child in ipairs(root:GetChildren()) do
        if child:IsA("LinearVelocity") or child:IsA("BodyVelocity") or child:IsA("AngularVelocity") then
            child:Destroy()
        end
    end

    local attach = Instance.new("Attachment", root)
    local lv = Instance.new("LinearVelocity")
    lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    lv.VectorVelocity = direction.Unit * power
    lv.MaxForce = math.huge
    lv.ForceLimitMode = Enum.ForceLimitMode.PerAxis
    lv.MaxAxesForce = Vector3.new(math.huge, math.huge, math.huge)
    lv.Attachment0 = attach
    lv.Parent = root
    Debris:AddItem(lv, 0.5)
    Debris:AddItem(attach, 0.5)

    pcall(function()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Physics) end
    end)
end

-- ══════════════════════════════════════════════
--  SAYFA 1 — ESP
-- ══════════════════════════════════════════════
local P1 = pages[1]
Section(P1, "Rol ESP")
Toggle(P1, "👁️ Rol ESP", function(on)
    if on then startESP() else stopESP() end
end)
Button(P1, "🔄 ESP Yenile", Color3.fromRGB(30,30,46), function()
    if espOn then refreshAllESP() end
end)

Section(P1, "Eşya ESP")
Toggle(P1, "💰 Coin ESP", function(on)
    coinESPOn = on
    if on then rebuildCoinESP() else clearCoinESP() end
end)
Toggle(P1, "🔪 Silah ESP", function(on)
    weaponESPOn = on
    if on then rebuildWeaponESP() else clearWeaponESP() end
end)
Button(P1, "🔄 Silah ESP Yenile", Color3.fromRGB(30,30,46), rebuildWeaponESP)

-- ══════════════════════════════════════════════
--  SAYFA 2 — OYUN
-- ══════════════════════════════════════════════
local P2 = pages[2]
Section(P2, "Otomatik")
Toggle(P2, "💰 Auto Coin", function(on)
    if on then
        _G._autoCoin = RS.Heartbeat:Connect(function()
            local r = R(); if not r then return end
            local best, bd = nil, math.huge
            for _, o in ipairs(workspace:GetDescendants()) do
                if o:IsA("BasePart") then
                    local n = o.Name:lower()
                    if n:find("coin") or n == "credit" then
                        local d = (o.Position - r.Position).Magnitude
                        if d < bd and d < 80 then bd = d; best = o end
                    end
                end
            end
            if best then r.CFrame = CFrame.new(best.Position + Vector3.new(0,3,0)) end
        end)
    else
        if _G._autoCoin then _G._autoCoin:Disconnect(); _G._autoCoin = nil end
    end
end)

Section(P2, "Kaçış")
Toggle(P2, "🏃 Katilden Kaç", function(on)
    if on then
        _G._flee = RS.Heartbeat:Connect(function()
            local r = R(); if not r then return end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp and getRole(p) == "murderer" then
                    local t = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                    if t then
                        local diff = r.Position - t.Position
                        if diff.Magnitude < 22 then
                            r.CFrame = CFrame.new(r.Position + diff.Unit * 25 + Vector3.new(0,5,0))
                        end
                    end
                    break
                end
            end
        end)
    else
        if _G._flee then _G._flee:Disconnect(); _G._flee = nil end
    end
end)

-- ══════════════════════════════════════════════
--  SAYFA 3 — OYUNCU (FLING)
-- ══════════════════════════════════════════════
local P3 = pages[3]
local selectedPlayer = nil

local selLabel = Instance.new("TextLabel", P3)
selLabel.Size = UDim2.new(1, 0, 0, 26)
selLabel.BackgroundColor3 = Color3.fromRGB(24,24,36)
selLabel.Text = "🎯 Seçili: Yok"
selLabel.TextSize = isMobile and 12 or 11
selLabel.Font = Enum.Font.GothamSemibold
selLabel.TextColor3 = Color3.fromRGB(45,130,255)
Instance.new("UICorner", selLabel).CornerRadius = UDim.new(0, 6)

Section(P3, "Oyuncu Listesi")
local playerList = Instance.new("ScrollingFrame", P3)
playerList.Size = UDim2.new(1, 0, 0, isMobile and 140 or 160)
playerList.BackgroundColor3 = Color3.fromRGB(18,18,28)
playerList.BorderSizePixel = 0
playerList.ScrollBarThickness = isMobile and 5 or 3
playerList.ScrollBarImageColor3 = Color3.fromRGB(45,130,255)
playerList.CanvasSize = UDim2.new(0,0,0,0)
playerList.ScrollingEnabled = true
Instance.new("UICorner", playerList).CornerRadius = UDim.new(0, 8)
local plL = Instance.new("UIListLayout", playerList)
plL.Padding = UDim.new(0, 3)
local plP = Instance.new("UIPadding", playerList)
plP.PaddingTop = UDim.new(0, 4)
plP.PaddingLeft = UDim.new(0, 4)
plP.PaddingRight = UDim.new(0, 4)

local playerButtons = {}
local function refreshPlayerList()
    for _, b in ipairs(playerButtons) do pcall(function() b:Destroy() end) end
    playerButtons = {}
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then table.insert(list, p) end
    end
    if #list == 0 then
        local l = Instance.new("TextLabel", playerList)
        l.Size = UDim2.new(1,0,0,30)
        l.BackgroundTransparency = 1
        l.Text = "Başka oyuncu yok"
        l.TextSize = isMobile and 11 or 10
        l.TextColor3 = Color3.fromRGB(120,120,150)
        table.insert(playerButtons, l)
        return
    end
    local bh = isMobile and 40 or 34
    for _, plr in ipairs(list) do
        local role = getRole(plr)
        local col = RCOL[role] or RCOL.unknown
        local b = Instance.new("TextButton", playerList)
        b.Size = UDim2.new(1,-4,0,bh)
        b.BackgroundColor3 = Color3.fromRGB(24,24,36)
        b.Text = "  " .. (RTXT[role] or "❔") .. "  " .. plr.Name
        b.TextSize = isMobile and 11 or 10
        b.Font = Enum.Font.GothamSemibold
        b.TextColor3 = col
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.BorderSizePixel = 0
        b.AutoButtonColor = true
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        local p = plr
        b.MouseButton1Click:Connect(function()
            selectedPlayer = p
            selLabel.Text = "🎯 Seçili: " .. p.Name
            selLabel.TextColor3 = col
            for _, x in ipairs(playerButtons) do
                if x:IsA("TextButton") then x.BackgroundColor3 = Color3.fromRGB(24,24,36) end
            end
            b.BackgroundColor3 = Color3.fromRGB(45,130,255)
        end)
        table.insert(playerButtons, b)
    end
    playerList.CanvasSize = UDim2.new(0,0,0,#list*(bh+3)+8)
end

Button(P3, "🔄 Listeyi Yenile", Color3.fromRGB(30,30,46), refreshPlayerList)

Section(P3, "Fling Sistemi")
Button(P3, "💥 Seçili Oyuncuya Fling", Color3.fromRGB(200,50,60), function()
    if selectedPlayer then
        flingPlayer(selectedPlayer, 180, Vector3.new(math.random(-1,1), 1, math.random(-1,1)))
    end
end)
Button(P3, "🚀 Yukarı Fırlat", Color3.fromRGB(60,60,200), function()
    if selectedPlayer then flingPlayer(selectedPlayer, 200, Vector3.new(0,1,0)) end
end)
Button(P3, "🌀 Rastgele Fling", Color3.fromRGB(140,60,200), function()
    if selectedPlayer then
        flingPlayer(selectedPlayer, 160, Vector3.new(math.random(-2,2), math.random(0,1), math.random(-2,2)))
    end
end)
Button(P3, "💣 Herkese Fling", Color3.fromRGB(180,40,40), function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            flingPlayer(p, 150, Vector3.new(math.random(-1,1), 1, math.random(-1,1)))
        end
    end
end)

Section(P3, "Işınlanma")
Button(P3, "📦 Oyuncuya Işınlan", Color3.fromRGB(30,30,46), function()
    if not selectedPlayer then return end
    local r = R()
    local t = selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
    if r and t then r.CFrame = t.CFrame + Vector3.new(3,2,0) end
end)

-- ══════════════════════════════════════════════
--  SAYFA 4 — KARAKTER
-- ══════════════════════════════════════════════
local P4 = pages[4]
Section(P4, "Hareket")
Slider(P4, "🏃 Hız", 16, 300, 16, function(v) local h=H(); if h then h.WalkSpeed=v end end)
Slider(P4, "⬆️ Zıplama", 50, 500, 50, function(v) local h=H(); if h then pcall(function() h.JumpPower=v end) end end)
Slider(P4, "🎥 FOV", 50, 130, 70, function(v) cam.FieldOfView=v end)

Section(P4, "Modlar")
Toggle(P4, "🌫️ Noclip", function(on)
    if on then
        _G._noclip = RS.Stepped:Connect(function()
            local c = C(); if not c then return end
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    else
        if _G._noclip then _G._noclip:Disconnect(); _G._noclip = nil end
    end
end)

Toggle(P4, "🚀 Sonsuz Zıplama", function(on)
    if on then
        _G._infJump = UIS.JumpRequest:Connect(function()
            local h = H()
            if h and h.FloorMaterial == Enum.Material.Air then
                h:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if _G._infJump then _G._infJump:Disconnect(); _G._infJump = nil end
    end
end)

Section(P4, "Koruma")
Toggle(P4, "🛡️ God Mode", function(on)
    local h = H(); if not h then return end
    if on then
        h.MaxHealth = math.huge; h.Health = math.huge
        _G._god = h.HealthChanged:Connect(function()
            if h and h.Parent then h.Health = math.huge end
        end)
    else
        if _G._god then _G._god:Disconnect(); _G._god = nil end
        pcall(function() h.MaxHealth = 100; h.Health = 100 end)
    end
end)

Toggle(P4, "👻 Görünmez", function(on)
    local c = C(); if not c then return end
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") or p:IsA("Decal") then
            p.LocalTransparencyModifier = on and 1 or 0
        end
    end
end)

-- ══════════════════════════════════════════════
--  SAYFA 5 — GÖRSEL
-- ══════════════════════════════════════════════
local P5 = pages[5]
local origL = {Ambient=Lighting.Ambient, Brightness=Lighting.Brightness, ClockTime=Lighting.ClockTime, FogEnd=Lighting.FogEnd, GlobalShadows=Lighting.GlobalShadows, OutdoorAmbient=Lighting.OutdoorAmbient}

Section(P5, "Ortam")
Toggle(P5, "💡 Fullbright", function(on)
    if on then
        Lighting.Brightness = 10
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255,255,255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
    else
        for k,v in pairs(origL) do Lighting[k] = v end
    end
end)

Toggle(P5, "🌈 Chams", function(on)
    if on then
        local t = 0
        _G._chams = RS.Heartbeat:Connect(function(dt)
            t = t + dt
            local c = C(); if not c then return end
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.Color = Color3.fromHSV((t*0.4)%1, 1, 1) end
            end
        end)
    else
        if _G._chams then _G._chams:Disconnect(); _G._chams = nil end
    end
end)

-- ══════════════════════════════════════════════
--  SAYFA 6 — AYAR
-- ══════════════════════════════════════════════
local P6 = pages[6]

Section(P6, "Bilgi")
local info = Instance.new("TextLabel", P6)
info.Size = UDim2.new(1,0,0,isMobile and 70 or 60)
info.BackgroundColor3 = Color3.fromRGB(24,24,36)
info.Text = isMobile
    and "📱 Mobil Mod Aktif\nFAB butonuna dokun → aç/kapat\nSürükle → taşı"
    or  "🖥️ PC Mod Aktif\nRightShift → Aç/Kapat"
info.TextSize = isMobile and 11 or 10
info.Font = Enum.Font.Gotham
info.TextColor3 = Color3.fromRGB(180,180,210)
info.TextWrapped = true
Instance.new("UICorner", info).CornerRadius = UDim.new(0, 8)

Section(P6, "Temizle")
Button(P6, "🗑️ Tüm ESP Kapat", Color3.fromRGB(30,30,46), function()
    stopESP(); clearCoinESP(); coinESPOn = false
    clearWeaponESP(); weaponESPOn = false
    stopTracers()
end)
Button(P6, "🎥 Kamerayı Sıfırla", Color3.fromRGB(30,30,46), function()
    cam.CameraType = Enum.CameraType.Custom
    cam.FieldOfView = 70
end)

-- ══════════════════════════════════════════════
--  TABLET AÇ/KAPAT (FIXED — POZİSYON KORUNUR)
-- ══════════════════════════════════════════════
local tabletVisible = true
local TABLET_MIN_SIZE = 10 -- minimum görünür boyut (animasyon için)

function toggleTablet()
    tabletVisible = not tabletVisible
    
    if tabletVisible then
        -- ★ AÇ: pozisyonu geri yükle, sonra büyüt
        tablet.Position = savedPosition
        tablet.Visible = true
        tablet.Size = UDim2.fromOffset(TABLET_MIN_SIZE, TABLET_MIN_SIZE)
        TS:Create(tablet, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(TW, TH),
        }):Play()
    else
        -- ★ KAPAT: sadece size küçült, position'a DOKUNMA
        TS:Create(tablet, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.fromOffset(TABLET_MIN_SIZE, TABLET_MIN_SIZE),
        }):Play()
        task.delay(0.2, function()
            tablet.Visible = false
        end)
    end
end

closeBtn.MouseButton1Click:Connect(toggleTablet)

-- Minimize
local minimized = false
local preMinimizeSize = nil
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        preMinimizeSize = tablet.Size
        TS:Create(tablet, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Size = UDim2.fromOffset(TW, HEADER_H),
        }):Play()
        minBtn.Text = "+"
    else
        TS:Create(tablet, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Size = UDim2.fromOffset(TW, TH),
        }):Play()
        minBtn.Text = "—"
    end
    savedPosition = tablet.Position
end)

-- ══════════════════════════════════════════════
--  FAB BUTONU (FIXED — tek tetik)
-- ══════════════════════════════════════════════
local fabSize = isMobile and 64 or 56
local toggleFab = Instance.new("TextButton", sg)
toggleFab.Size = UDim2.fromOffset(fabSize, fabSize)
toggleFab.Position = UDim2.new(0, 16, 0.5, -fabSize/2)
toggleFab.BackgroundColor3 = Color3.fromRGB(45,130,255)
toggleFab.Text = "🔪"
toggleFab.TextSize = isMobile and 28 or 24
toggleFab.Font = Enum.Font.GothamBold
toggleFab.BorderSizePixel = 0
toggleFab.AutoButtonColor = false
toggleFab.Active = true
Instance.new("UICorner", toggleFab).CornerRadius = UDim.new(1,0)

local fabStroke = Instance.new("UIStroke", toggleFab)
fabStroke.Color = Color3.new(1,1,1)
fabStroke.Thickness = 1.5

local pulse = TS:Create(toggleFab, TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
    Size = UDim2.fromOffset(fabSize + 6, fabSize + 6),
})
pulse:Play()

-- ★ FAB sürükleme + tıklama state machine
local fabDrag = false
local fabMoved = false
local fabStart = nil
local fabStartP = nil
local FAB_DRAG_THRESHOLD = 10

toggleFab.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        fabDrag = true
        fabMoved = false
        fabStart = i.Position
        fabStartP = toggleFab.Position
        pulse:Pause()
    end
end)

UIS.InputChanged:Connect(function(i)
    if not fabDrag then return end
    if i.UserInputType == Enum.UserInputType.MouseMovement
    or i.UserInputType == Enum.UserInputType.Touch then
        local d = i.Position - fabStart
        if not fabMoved and d.Magnitude > FAB_DRAG_THRESHOLD then
            fabMoved = true
        end
        if fabMoved then
            toggleFab.Position = UDim2.new(
                fabStartP.X.Scale, fabStartP.X.Offset + d.X,
                fabStartP.Y.Scale, fabStartP.Y.Offset + d.Y
            )
        end
    end
end)

UIS.InputEnded:Connect(function(i)
    if not fabDrag then return end
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        fabDrag = false
        pulse:Play()
        -- ★ SADECE sürüklenmediyse toggle et
        if not fabMoved then
            toggleTablet()
        end
    end
end)

-- ══════════════════════════════════════════════
--  KLAVYE (PC için)
-- ══════════════════════════════════════════════
UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightShift then toggleTablet()
    elseif i.KeyCode == Enum.KeyCode.Delete then
        if tabletVisible then toggleTablet() end
    elseif i.KeyCode == Enum.KeyCode.Insert then
        if not tabletVisible then toggleTablet() end
    end
end)

-- ══════════════════════════════════════════════
--  OLAYLAR
-- ══════════════════════════════════════════════
lp.CharacterAdded:Connect(function()
    task.wait(0.8)
    if espOn then refreshAllESP() end
end)
Players.PlayerAdded:Connect(function(plr)
    task.wait(0.5)
    refreshPlayerList()
    if espOn then createESPFor(plr) end
end)
Players.PlayerRemoving:Connect(function(plr)
    removeESPFor(plr)
    roleCache[plr] = nil
    task.wait(0.1)
    refreshPlayerList()
end)

task.wait(0.5)
refreshPlayerList()
switchTab(1)

print("[MM2 HUB — FIXED] Hazır! " .. (isMobile and "FAB'a dokun" or "RightShift"))
