--// DEXPS Key System v4

----------------------------------------------------------------
-- CONFIG
----------------------------------------------------------------
local CorrectKey = "DEXPSONTOPPLSLIKEMYSCRIPT"       -- the valid key
local MaxTries   = 3                      -- wrong tries before kick
local SaveKey    = false                   -- remember key in a file (auto-verifies next time)
local KeyFile    = "DEXPS_Key.txt"

-- Get Key dropdown: every entry becomes a button, click = copies the link
local Url = {
    Lootlabs    = "https://lootdest.org/s?pagZLWvi",
    Linkvertise = "https://direct-link.net/3017644/LazaUdxdEqVD",
    Workink     = "https://work.ink/38El/dexps",
}

--[[
    GAMES  (one entry per game, as many as you want)
    Id     = PlaceId or UniverseId (GameId). Use a table for several: Id = { 111, 222 }
    Load   = function that runs when the key is correct AND you are in that game
    Script = (optional shortcut instead of Load) a link, e.g. Script = "https://raw.githubusercontent.com/..."
]]
local Games = {
    ["Steal A Brainrot"] = {
        Id = 109983668079237,
        Load = function()
            -- PUT YOUR STEAL A BRAINROT LOADSTRING HERE:
            -- loadstring(game:HttpGet("https://raw.githubusercontent.com/you/repo/main/brainrot.lua"))()
        end,
    },

    -- ["Another Game"] = {
    --     Id = { 1234567890, 9876543210 },
    --     Script = "https://raw.githubusercontent.com/you/repo/main/another.lua",
    -- },
}

-- Optional: runs in games that are NOT in the list above (leave nil to block them)
-- Can be a function, a link, or nil.
local Fallback = nil

local HubTitle  = "DEXPS"
local HubTag    = "KEY"
local BlurSize  = 56                       -- real blur strength (0 - 56)
local DimAlpha  = 0.45                     -- how dark the screen gets behind the window
local ToggleKey = Enum.KeyCode.RightShift  -- minimize / restore

----------------------------------------------------------------
-- THEMES
----------------------------------------------------------------
local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end
local function makeTheme(t) return t end

local Themes = {
    Black = makeTheme({
        Background = rgb(7, 7, 9), Background2 = rgb(18, 18, 23),
        Topbar = rgb(12, 12, 15), Section = rgb(14, 14, 18),
        Element = rgb(22, 22, 28), ElementHover = rgb(34, 34, 42), Stroke = rgb(48, 48, 58),
        Accent = rgb(238, 238, 245), Accent2 = rgb(132, 150, 196), OnAccent = rgb(10, 10, 12),
        Text = rgb(242, 242, 248), SubText = rgb(142, 142, 158),
        Glow = rgb(120, 130, 175), Glow2 = rgb(70, 82, 120),
        Snow = rgb(240, 245, 255), Dim = rgb(0, 0, 0),
    }),
    Crimson = makeTheme({
        Background = rgb(11, 5, 7), Background2 = rgb(32, 9, 16),
        Topbar = rgb(18, 9, 12), Section = rgb(21, 10, 14),
        Element = rgb(31, 15, 20), ElementHover = rgb(47, 22, 30), Stroke = rgb(82, 34, 46),
        Accent = rgb(232, 28, 66), Accent2 = rgb(255, 112, 86), OnAccent = rgb(255, 255, 255),
        Text = rgb(248, 238, 240), SubText = rgb(172, 132, 142),
        Glow = rgb(222, 30, 72), Glow2 = rgb(255, 110, 60),
        Snow = rgb(255, 234, 238), Dim = rgb(22, 0, 5),
    }),
    Violet = makeTheme({
        Background = rgb(8, 5, 17), Background2 = rgb(26, 12, 50),
        Topbar = rgb(15, 9, 28), Section = rgb(18, 11, 33),
        Element = rgb(27, 17, 47), ElementHover = rgb(41, 26, 72), Stroke = rgb(74, 50, 124),
        Accent = rgb(154, 94, 255), Accent2 = rgb(216, 128, 255), OnAccent = rgb(255, 255, 255),
        Text = rgb(244, 239, 253), SubText = rgb(152, 138, 188),
        Glow = rgb(140, 80, 255), Glow2 = rgb(222, 110, 255),
        Snow = rgb(240, 232, 255), Dim = rgb(8, 0, 22),
    }),
}

local theme = "Black" -- "Black" or "Crimson" or "Violet"
local themeName = Themes[theme] and theme or "Black"
local T = Themes[themeName]

-- the glow around the window / button: black glows black, crimson glows crimson, violet glows violet
local ShadowCol = themeName == "Black" and rgb(0, 0, 0) or T.Glow

local GOOD = rgb(88, 214, 141)
local BAD  = rgb(240, 84, 96)
local WARN = rgb(240, 190, 80)

-- notifications are always plain black
local NBG, NSTROKE, NTEXT, NSUB, NBOX = rgb(10, 10, 13), rgb(44, 44, 52), rgb(245, 245, 250), rgb(150, 150, 162), rgb(22, 22, 27)

----------------------------------------------------------------
-- SERVICES / HELPERS
----------------------------------------------------------------
local Players            = game:GetService("Players")
local TweenService       = game:GetService("TweenService")
local RunService         = game:GetService("RunService")
local Lighting           = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
local StatsService       = game:GetService("Stats")
local TextService        = game:GetService("TextService")
local UIS                = game:GetService("UserInputService")
local LocalPlayer        = Players.LocalPlayer

local setclip = setclipboard or toclipboard or (syn and syn.write_clipboard) or (Clipboard and Clipboard.set)
local getclip = getclipboard or readclipboard or (Clipboard and Clipboard.get)
local rng = Random.new()
local WHITE = Color3.new(1, 1, 1)
local alive = true

local Left, Center, Right = Enum.TextXAlignment.Left, Enum.TextXAlignment.Center, Enum.TextXAlignment.Right
local Bold, Med, Reg, Black, Code = Enum.Font.GothamBold, Enum.Font.GothamMedium, Enum.Font.Gotham, Enum.Font.GothamBlack, Enum.Font.Code

local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function tween(o, t, props, style, dir)
    local tw = TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

local function corner(o, r) return new("UICorner", { CornerRadius = UDim.new(0, r) }, o) end
local function stroke(o, color, th)
    return new("UIStroke", { Color = color, Thickness = th or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, o)
end
local function pad(o, l, r)
    return new("UIPadding", { PaddingLeft = UDim.new(0, l or 0), PaddingRight = UDim.new(0, r or 0) }, o)
end

local function label(parent, text, size, color, font, pos, sz, align)
    return new("TextLabel", {
        Text = text, TextSize = size, TextColor3 = color, Font = font or Reg,
        BackgroundTransparency = 1, Position = pos, Size = sz, TextXAlignment = align or Left,
    }, parent)
end

local function textW(text, size, font)
    local ok, v = pcall(function()
        return TextService:GetTextSize(tostring(text), size, font, Vector2.new(1000, 100)).X
    end)
    return ok and v or (#tostring(text) * size * 0.6)
end

local function ease(dt, speed) return 1 - math.exp(-dt * speed) end

local function isPress(i) return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch end
local function isMove(i) return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch end
local function pointer(i) return Vector2.new(i.Position.X, i.Position.Y) end

local function makeChevron(parent, pos, color)
    local c = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = pos, Size = UDim2.fromOffset(14, 14), BackgroundTransparency = 1,
    }, parent)
    for _, cfg in ipairs({ { 4, 45 }, { 10, -45 } }) do
        local b = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(cfg[1], 7),
            Size = UDim2.fromOffset(8, 2), Rotation = cfg[2], BackgroundColor3 = color or T.Text, BorderSizePixel = 0,
        }, c)
        corner(b, 1)
    end
    return c
end

-- Button: gradient fill (primary) or glass (ghost), hover lift, press squish, click ripple
local function makeButton(parent, text, pos, size, style, noScale)
    local primary = style == "primary"
    local root = new("CanvasGroup", {
        Position = pos, Size = size, BorderSizePixel = 0,
        BackgroundColor3 = T.Element, BackgroundTransparency = primary and 1 or 0,
    }, parent)
    corner(root, 10)
    local st = stroke(root, primary and T.Accent2 or T.Stroke, 1)

    local grad
    if primary then
        local fill = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, BorderSizePixel = 0 }, root)
        grad = new("UIGradient", { Color = ColorSequence.new(T.Accent, T.Accent2), Rotation = 0 }, fill)
        st.Transparency = 0.55
    end

    local lbl = new("TextLabel", {
        Text = text, Font = Bold, TextSize = 13, BackgroundTransparency = 1,
        TextColor3 = primary and T.OnAccent or T.Text, Size = UDim2.fromScale(1, 1),
    }, root)
    local hit = new("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 10 }, root)
    local sc = new("UIScale", {}, root)
    local hovering = false

    hit.MouseEnter:Connect(function()
        hovering = true
        if not noScale then tween(sc, 0.2, { Scale = 1.025 }) end
        if primary then
            tween(grad, 0.35, { Offset = Vector2.new(0.3, 0) })
            tween(st, 0.2, { Transparency = 0 })
        else
            tween(root, 0.2, { BackgroundColor3 = T.ElementHover })
            tween(st, 0.2, { Color = T.Accent2 })
        end
    end)
    hit.MouseLeave:Connect(function()
        hovering = false
        tween(sc, 0.2, { Scale = 1 })
        if primary then
            tween(grad, 0.35, { Offset = Vector2.new(0, 0) })
            tween(st, 0.2, { Transparency = 0.55 })
        else
            tween(root, 0.2, { BackgroundColor3 = T.Element })
            tween(st, 0.2, { Color = T.Stroke })
        end
    end)
    hit.MouseButton1Down:Connect(function(x)
        tween(sc, 0.1, { Scale = 0.96 })
        local rx = math.clamp((x - root.AbsolutePosition.X) / math.max(root.AbsoluteSize.X, 1), 0, 1)
        local r = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(rx, 0.5),
            Size = UDim2.fromOffset(0, 0), BackgroundColor3 = primary and T.OnAccent or WHITE,
            BackgroundTransparency = 0.82, BorderSizePixel = 0, ZIndex = 6,
        }, root)
        corner(r, 400)
        tween(r, 0.55, { Size = UDim2.fromOffset(340, 340), BackgroundTransparency = 1 })
        task.delay(0.6, function() r:Destroy() end)
    end)
    hit.MouseButton1Up:Connect(function()
        tween(sc, 0.18, { Scale = (hovering and not noScale) and 1.025 or 1 }, Enum.EasingStyle.Back)
    end)

    return { Root = root, Hit = hit, Label = lbl, Stroke = st }
end

-- Tags: little glowing pills with a pulsing dot (accent / good / bad / warn / mute)
local pulseDots = {}
local function kindColor(kind)
    if kind == "good" then return GOOD
    elseif kind == "bad" then return BAD
    elseif kind == "warn" then return WARN
    elseif kind == "mute" then return T.SubText end
    return T.Accent2
end

local function makeTag(parent, text, kind, pos, h, solid, ax)
    h = h or 22
    local tag = {}
    local col = kindColor(kind)
    local f = new("Frame", {
        AnchorPoint = Vector2.new(ax or 1, 0.5), Position = pos or UDim2.new(),
        Size = UDim2.fromOffset(textW(text, 10, Bold) + 30, h),
        BackgroundColor3 = solid and T.Background or col, BackgroundTransparency = solid and 0.2 or 0.86,
        BorderSizePixel = 0,
    }, parent)
    corner(f, h / 2)
    local st = stroke(f, col, 1)
    st.Transparency = 0.45
    local dot = new("Frame", {
        AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 9, 0.5, 0),
        Size = UDim2.fromOffset(5, 5), BackgroundColor3 = col, BorderSizePixel = 0,
    }, f)
    corner(dot, 3)
    local lbl = label(f, text, 10, col, Bold, UDim2.fromOffset(20, 0), UDim2.new(1, -24, 1, 0))
    table.insert(pulseDots, dot)

    function tag:Set(t2, k2)
        kind = k2 or kind
        local c = kindColor(kind)
        lbl.Text = t2
        tween(f, 0.3, { Size = UDim2.fromOffset(textW(t2, 10, Bold) + 30, h) })
        tween(lbl, 0.3, { TextColor3 = c })
        tween(dot, 0.3, { BackgroundColor3 = c })
        tween(st, 0.3, { Color = c })
        if not solid then tween(f, 0.3, { BackgroundColor3 = c }) end
    end
    tag.Root = f
    return tag
end

----------------------------------------------------------------
-- GAME DETECTION
----------------------------------------------------------------
local function idsOf(g)
    local out = {}
    local raw = type(g.Id) == "table" and g.Id or { g.Id }
    for _, v in ipairs(raw) do
        local id = tonumber(v) or tonumber(tostring(v):match("%d+"))
        if id then table.insert(out, id) end
    end
    return out
end
local function isCurrent(id) return id == game.PlaceId or id == game.GameId end
local function hasScript(g) return g and (type(g.Load) == "function" or g.Script ~= nil) end

local entries = {}
for name, g in pairs(Games) do
    table.insert(entries, { name = name, g = g, ids = idsOf(g) })
end
table.sort(entries, function(a, b) return a.name < b.name end)

local currentEntry
for _, e in ipairs(entries) do
    for _, id in ipairs(e.ids) do
        if isCurrent(id) then currentEntry = e end
    end
end
local supportedNow = currentEntry ~= nil

local FallbackG
if type(Fallback) == "table" then FallbackG = Fallback
elseif type(Fallback) == "function" then FallbackG = { Load = Fallback }
elseif Fallback ~= nil then FallbackG = { Script = Fallback } end

local function runScript(g)
    local ok, err = pcall(function()
        if type(g.Load) == "function" then
            g.Load()
        elseif type(g.Script) == "function" then
            g.Script()
        elseif type(g.Script) == "string" then
            if g.Script:match("^https?://") then loadstring(game:HttpGet(g.Script))()
            else loadstring(g.Script)() end
        end
    end)
    if not ok then warn("[DEXPS] script error: " .. tostring(err)) end
end

local urlNames = {}
for name in pairs(Url) do table.insert(urlNames, name) end
table.sort(urlNames)

----------------------------------------------------------------
-- LAYOUT CONSTANTS  (smaller than the library window: 680 x 460)
----------------------------------------------------------------
local W, H = 640, 410
local TOP, SIDE_W = 48, 196
local PAGE_X, PAGE_Y = SIDE_W, TOP + 1
local PAGE_W, PAGE_H = W - SIDE_W, H - TOP - 1
local ROWS = math.min(math.max(#urlNames, 1), 3)
local ROW_H = 34

----------------------------------------------------------------
-- GUI ROOT
----------------------------------------------------------------
local host
do
    local ok, r = pcall(function() return (gethui and gethui()) or game:GetService("CoreGui") end)
    host = (ok and r) or LocalPlayer:WaitForChild("PlayerGui")
end
for _, n in ipairs({ "DEXPS_KeySystem", "DEXPS_Notify" }) do
    local old = host:FindFirstChild(n)
    if old then old:Destroy() end
end
for _, v in ipairs(Lighting:GetChildren()) do
    if v.Name == "DEXPS_Blur" or v.Name == "DEXPS_DoF" then v:Destroy() end
end

local function makeGui(name, order)
    local g = new("ScreenGui", {
        Name = name, IgnoreGuiInset = true, ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = order,
    })
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(g) end end)
    g.Parent = host
    return g
end
local Gui = makeGui("DEXPS_KeySystem", 999)
local NotifGui = makeGui("DEXPS_Notify", 1000)

-- REAL blur: heavy BlurEffect + DepthOfField that puts the whole 3D world out of focus
local Blur = new("BlurEffect", { Name = "DEXPS_Blur", Size = 0, Enabled = false }, Lighting)
local DoF = new("DepthOfFieldEffect", {
    Name = "DEXPS_DoF", FarIntensity = 0, NearIntensity = 0, FocusDistance = 0, InFocusRadius = 0, Enabled = false,
}, Lighting)

local Dim = new("Frame", {
    Size = UDim2.fromScale(1, 1), BackgroundColor3 = T.Dim, BackgroundTransparency = 1,
    BorderSizePixel = 0, ZIndex = 1, Visible = false,
}, Gui)

----------------------------------------------------------------
-- NOTIFICATIONS  (plain black cards, countdown number instead of a bar)
----------------------------------------------------------------
local NW, MAXN = 300, 4
local notifs = {}

local function notifRelayout()
    local y = 0
    for i = #notifs, 1, -1 do
        local n = notifs[i]
        n.y = y
        tween(n.wrap, 0.45, { Position = UDim2.new(1, -18, 1, -(18 + y)) })
        y += n.h + 10
    end
end

local function dismissNotif(n)
    if n.closing then return end
    n.closing = true
    for i, v in ipairs(notifs) do
        if v == n then table.remove(notifs, i) break end
    end
    notifRelayout()
    tween(n.shadow, 0.3, { ImageTransparency = 1 })
    tween(n.card, 0.4, { Position = UDim2.new(1.3, 0, 0, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        .Completed:Connect(function() n.wrap:Destroy() end)
end

local function notify(title, content, duration)
    duration = tonumber(duration) or 5
    content = content or ""
    local tw = NW - 28 - 48
    local bh = 14
    local ok, sz = pcall(function() return TextService:GetTextSize(content, 12, Reg, Vector2.new(tw, 1000)) end)
    if ok then bh = math.max(14, sz.Y) end
    local h = math.max(58, 10 + 18 + 3 + bh + 12)

    while #notifs >= MAXN do dismissNotif(notifs[1]) end

    local n = { h = h, y = 0, t = 0, dur = duration, closing = false, shown = -1 }
    n.wrap = new("Frame", {
        AnchorPoint = Vector2.new(1, 1), Size = UDim2.fromOffset(NW, h),
        Position = UDim2.new(1, -18, 1, -18), BackgroundTransparency = 1,
    }, NotifGui)
    n.shadow = new("ImageLabel", {
        BackgroundTransparency = 1, Image = "rbxassetid://6014261993", ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.4, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(49, 49, 450, 450),
        Size = UDim2.new(1, 44, 1, 44), Position = UDim2.fromOffset(-22, -14),
    }, n.wrap)
    n.card = new("Frame", {
        Size = UDim2.fromScale(1, 1), Position = UDim2.new(1.3, 0, 0, 0),
        BackgroundColor3 = NBG, BorderSizePixel = 0,
    }, n.wrap)
    corner(n.card, 12)
    stroke(n.card, NSTROKE, 1)

    label(n.card, title or "", 13, NTEXT, Bold, UDim2.fromOffset(14, 10), UDim2.fromOffset(tw, 18)).TextTruncate = Enum.TextTruncate.AtEnd
    local body = label(n.card, content, 12, NSUB, Reg, UDim2.fromOffset(14, 31), UDim2.fromOffset(tw, bh))
    body.TextWrapped = true
    body.TextYAlignment = Enum.TextYAlignment.Top

    local box = new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(30, 30), BackgroundColor3 = NBOX, BorderSizePixel = 0,
    }, n.card)
    corner(box, 9)
    stroke(box, NSTROKE, 1)
    n.num = label(box, tostring(math.ceil(duration)), 14, NTEXT, Bold, UDim2.new(), UDim2.fromScale(1, 1), Center)
    n.numScale = new("UIScale", {}, box)

    local hit = new("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 5 }, n.card)
    hit.MouseButton1Click:Connect(function() dismissNotif(n) end)

    table.insert(notifs, n)
    notifRelayout()
    tween(n.card, 0.55, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Back)
end

local notifConn = RunService.Heartbeat:Connect(function(dt)
    for i = #notifs, 1, -1 do
        local n = notifs[i]
        if n and not n.closing then
            n.t += dt
            local rem = math.max(0, math.ceil(n.dur - n.t))
            if rem ~= n.shown then
                n.shown = rem
                n.num.Text = tostring(rem)
                n.numScale.Scale = 1.25
                tween(n.numScale, 0.3, { Scale = 1 }, Enum.EasingStyle.Back)
            end
            if n.t >= n.dur then dismissNotif(n) end
        end
    end
end)

----------------------------------------------------------------
-- PARTICLES: orbs, snow, sparkles
----------------------------------------------------------------
local function makeOrb(parent, color, diameter)
    local o = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(diameter, diameter), BackgroundTransparency = 1,
    }, parent)
    local layers = {}
    for i = 1, 10 do
        local k = 1 - (i - 1) * 0.09
        local c = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromScale(k, k), BackgroundColor3 = color,
            BackgroundTransparency = 0.978, BorderSizePixel = 0,
        }, o)
        corner(c, 2000)
        layers[i] = c
    end
    return o, layers
end

local function addOrb(list, parent, color, diameter, ax, ay, sp, ph)
    local o, layers = makeOrb(parent, color, diameter)
    table.insert(list, { o = o, layers = layers, ax = ax, ay = ay, sp = sp, ph = ph })
end
local function stepOrbs(list, t)
    for _, b in ipairs(list) do
        b.o.Position = UDim2.fromScale(
            0.5 + math.cos(t * b.sp + b.ph) * b.ax,
            0.5 + math.sin(t * b.sp * 1.3 + b.ph) * b.ay
        )
    end
end
local function setOrbAlpha(list, a)
    for _, b in ipairs(list) do
        for _, c in ipairs(b.layers) do c.BackgroundTransparency = 1 - (1 - 0.978) * a end
    end
end

local function makeSnow(parent, count, minS, maxS, minSp, maxSp)
    local list = {}
    for i = 1, count do
        local d = rng:NextNumber()
        local size = minS + (maxS - minS) * d
        local base = 0.8 - 0.55 * d
        local f = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(size, size),
            BackgroundColor3 = T.Snow, BackgroundTransparency = base, BorderSizePixel = 0,
        }, parent)
        corner(f, 100)
        list[i] = {
            f = f, d = d, base = base, x = rng:NextNumber(), y = rng:NextNumber(),
            sp = minSp + (maxSp - minSp) * d, ph = rng:NextNumber(0, 6.28),
            fr = rng:NextNumber(0.6, 1.6), sw = rng:NextNumber(0.004, 0.016), tw = rng:NextNumber(1, 3),
        }
    end
    return list
end

local function stepSnow(list, dt, t, a)
    local wind = math.sin(t * 0.35) * 0.012 + 0.004
    for _, s in ipairs(list) do
        s.y += s.sp * dt
        s.x += wind * (0.5 + s.d) * dt
        if s.y > 1.04 then s.y = -0.04; s.x = rng:NextNumber() end
        if s.x > 1.05 then s.x = -0.05 elseif s.x < -0.05 then s.x = 1.05 end
        s.f.Position = UDim2.fromScale(s.x + math.sin(t * s.fr + s.ph) * s.sw, s.y)
        local tr = math.clamp(s.base + math.sin(t * s.tw + s.ph) * 0.12, 0, 1)
        s.f.BackgroundTransparency = 1 - (1 - tr) * a
    end
end

local bgOrbs, inOrbs = {}, {}

local OrbsBG = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 2, ClipsDescendants = true }, Gui)
addOrb(bgOrbs, OrbsBG, T.Glow, 720, 0.30, 0.25, 0.11, 0)
addOrb(bgOrbs, OrbsBG, T.Glow2, 620, 0.38, 0.28, 0.08, 2.1)
addOrb(bgOrbs, OrbsBG, T.Accent2, 520, 0.28, 0.32, 0.06, 4.2)
setOrbAlpha(bgOrbs, 0)

local SnowBG = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 3, ClipsDescendants = true }, Gui)
local snowBG = makeSnow(SnowBG, 90, 2, 7, 0.04, 0.15)

----------------------------------------------------------------
-- WINDOW (Root -> Canvas(scaled) -> glow shadows + Main)
----------------------------------------------------------------
local function screenSize()
    local s = Gui.AbsoluteSize
    if s.X < 100 or s.Y < 100 then
        local cam = workspace.CurrentCamera
        return cam and cam.ViewportSize or Vector2.new(1280, 720)
    end
    return s
end

local S = 1
local function calcScale()
    local vs = screenSize()
    S = math.clamp(math.min(vs.X / (W + 30), vs.Y / (H + 30)), 0.45, 1)
end
calcScale()

local curX, curY = (screenSize().X - W * S) / 2, (screenSize().Y - H * S) / 2
local tgtX, tgtY = curX, curY

local Root = new("Frame", {
    Name = "Root", Size = UDim2.fromOffset(W * S, H * S), Position = UDim2.fromOffset(curX, curY),
    BackgroundTransparency = 1, ZIndex = 4, Visible = false,
}, Gui)
local Canvas = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(W, H), BackgroundTransparency = 1,
}, Root)
local WinScale = new("UIScale", { Scale = S * 0.92 }, Canvas)

local function shadowLayer(parent, spread, zi)
    return new("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, spread, 1, spread), BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993", ImageColor3 = ShadowCol, ImageTransparency = 1,
        ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(49, 49, 450, 450), ZIndex = zi or 0,
    }, parent)
end
local WShadowWide = shadowLayer(Canvas, 150)
local WShadowTight = shadowLayer(Canvas, 60)

local Main = new("CanvasGroup", {
    Name = "Main", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
    BorderSizePixel = 0, GroupTransparency = 1, ZIndex = 1,
}, Canvas)
corner(Main, 14)
local MainStroke = stroke(Main, WHITE, 1.5)
local StrokeGrad = new("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, T.Glow), ColorSequenceKeypoint.new(0.5, T.Glow2), ColorSequenceKeypoint.new(1, T.Glow),
    }),
}, MainStroke)

local Bg = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 0 }, Main)
local BgGrad = new("UIGradient", { Color = ColorSequence.new(T.Background, T.Background2), Rotation = 62 }, Bg)

local OrbsIn = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 1, ClipsDescendants = true }, Main)
addOrb(inOrbs, OrbsIn, T.Glow, 340, 0.35, 0.30, 0.20, 1)
addOrb(inOrbs, OrbsIn, T.Glow2, 300, 0.30, 0.30, 0.16, 3.4)

local SnowIn = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 2, ClipsDescendants = true }, Main)
local snowIn = makeSnow(SnowIn, 44, 2, 5, 0.07, 0.22)

local sparkles = {}
for i = 1, 8 do
    local s = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1 }, SnowIn)
    new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = T.Accent2, BackgroundTransparency = 0.15, BorderSizePixel = 0 }, s)
    new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(0, 2, 1, 0), BackgroundColor3 = T.Accent2, BackgroundTransparency = 0.15, BorderSizePixel = 0 }, s)
    sparkles[i] = {
        f = s, t = rng:NextNumber(0, 2), life = rng:NextNumber(1.4, 2.6),
        x = rng:NextNumber(0.05, 0.95), y = rng:NextNumber(0.1, 0.95), size = rng:NextNumber(8, 15),
    }
end
local function stepSparkles(dt)
    for _, s in ipairs(sparkles) do
        s.t += dt
        if s.t >= s.life then
            s.t = 0
            s.life = rng:NextNumber(1.4, 2.6)
            s.x = rng:NextNumber(0.05, 0.95)
            s.y = rng:NextNumber(0.1, 0.95)
            s.size = rng:NextNumber(8, 15)
        end
        local k = math.sin(math.pi * s.t / s.life)
        local sz = s.size * k
        s.f.Size = UDim2.fromOffset(sz, sz)
        s.f.Position = UDim2.fromScale(s.x, s.y)
        s.f.Rotation = s.t * 80
    end
end

local Shine = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, -120, 0.5, 0), Size = UDim2.new(0, 70, 1.8, 0),
    Rotation = 18, BackgroundColor3 = WHITE, BackgroundTransparency = 0.93, BorderSizePixel = 0, ZIndex = 30,
}, Main)
new("UIGradient", {
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1),
    }),
}, Shine)
task.spawn(function()
    while alive do
        task.wait(rng:NextNumber(5, 9))
        if not alive then break end
        Shine.Position = UDim2.new(0, -120, 0.5, 0)
        tween(Shine, 1.4, { Position = UDim2.new(0, W + 120, 0.5, 0) }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut).Completed:Wait()
    end
end)

----------------------------------------------------------------
-- TOPBAR: logo, title, tag, tabs, minimize
----------------------------------------------------------------
local Top = new("Frame", {
    Size = UDim2.new(1, 0, 0, TOP), BackgroundColor3 = T.Topbar, BackgroundTransparency = 0.1,
    BorderSizePixel = 0, ZIndex = 5, Active = true,
}, Main)

-- logo: ring with a rotating gradient, monogram, orbiting dot
local Logo = new("Frame", {
    Position = UDim2.fromOffset(12, 7), Size = UDim2.fromOffset(34, 34), BackgroundColor3 = T.Background, BorderSizePixel = 0,
}, Top)
corner(Logo, 17)
local LogoStroke = stroke(Logo, WHITE, 2)
local LogoRing = new("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, T.Accent), ColorSequenceKeypoint.new(0.5, T.Accent2), ColorSequenceKeypoint.new(1, T.Accent),
    }),
}, LogoStroke)
local LogoInner = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(26, 26), BackgroundColor3 = WHITE, BackgroundTransparency = 0.78, BorderSizePixel = 0,
}, Logo)
corner(LogoInner, 13)
new("UIGradient", { Color = ColorSequence.new(T.Accent, T.Accent2), Rotation = 45 }, LogoInner)
local LogoTxt = label(Logo, "DX", 12, WHITE, Black, UDim2.new(), UDim2.fromScale(1, 1), Center)
new("UIGradient", { Color = ColorSequence.new(T.Accent, T.Accent2), Rotation = 90 }, LogoTxt)
local OrbitHolder = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
}, Logo)
local OrbitDot = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0), Size = UDim2.fromOffset(5, 5),
    BackgroundColor3 = WHITE, BorderSizePixel = 0,
}, OrbitHolder)
corner(OrbitDot, 3)

local TitleLbl = label(Top, HubTitle, 18, WHITE, Black, UDim2.fromOffset(56, 0), UDim2.fromOffset(textW(HubTitle, 18, Black) + 4, TOP), Left)
local TitleGrad = new("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, T.Text), ColorSequenceKeypoint.new(0.5, T.Accent), ColorSequenceKeypoint.new(1, T.Accent2),
    }),
}, TitleLbl)
makeTag(Top, HubTag, "accent", UDim2.fromOffset(56 + textW(HubTitle, 18, Black) + 14, TOP / 2), 20, false, 0)

-- tabs (segmented control with a sliding indicator)
local tabNames = { "Key", "Games", "Info" }
local tabIndex = { Key = 1, Games = 2, Info = 3 }
local TAB_W = 74
local TabBar = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.fromOffset(TAB_W * 3 + 8, 32), BackgroundColor3 = T.Element, BorderSizePixel = 0,
}, Top)
corner(TabBar, 10)
stroke(TabBar, T.Stroke, 1)
local Indicator = new("Frame", {
    Position = UDim2.fromOffset(4, 4), Size = UDim2.fromOffset(TAB_W, 24), BackgroundColor3 = WHITE, BorderSizePixel = 0,
}, TabBar)
corner(Indicator, 7)
new("UIGradient", { Color = ColorSequence.new(T.Accent, T.Accent2), Rotation = 0 }, Indicator)

local tabLabels = {}
local currentTab = "Key"
local function currentTabName() return currentTab end
local goTab -- forward
for i, name in ipairs(tabNames) do
    local b = new("TextButton", {
        Position = UDim2.fromOffset(4 + (i - 1) * TAB_W, 4), Size = UDim2.fromOffset(TAB_W, 24),
        BackgroundTransparency = 1, Text = name, Font = Bold, TextSize = 12,
        TextColor3 = i == 1 and T.OnAccent or T.SubText, AutoButtonColor = false, ZIndex = 3,
    }, TabBar)
    tabLabels[name] = b
    b.MouseEnter:Connect(function()
        if name ~= currentTabName() then tween(b, 0.15, { TextColor3 = T.Text }) end
    end)
    b.MouseLeave:Connect(function()
        if name ~= currentTabName() then tween(b, 0.2, { TextColor3 = T.SubText }) end
    end)
    b.MouseButton1Click:Connect(function() goTab(name) end)
end

-- minimize button
local MinBtn = new("TextButton", {
    Position = UDim2.new(1, -40, 0.5, -14), Size = UDim2.fromOffset(28, 28),
    BackgroundColor3 = T.Element, Text = "", AutoButtonColor = false,
}, Top)
corner(MinBtn, 8)
local MinStroke = stroke(MinBtn, T.Stroke, 1)
local MinLine = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(11, 2),
    BackgroundColor3 = T.Text, BorderSizePixel = 0,
}, MinBtn)
corner(MinLine, 1)
MinBtn.MouseEnter:Connect(function()
    tween(MinBtn, 0.15, { BackgroundColor3 = T.ElementHover })
    tween(MinStroke, 0.15, { Color = T.Accent2 })
end)
MinBtn.MouseLeave:Connect(function()
    tween(MinBtn, 0.2, { BackgroundColor3 = T.Element })
    tween(MinStroke, 0.2, { Color = T.Stroke })
end)

local TopLine = new("Frame", {
    Position = UDim2.fromOffset(0, TOP), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 6,
}, Main)
local TopLineGrad = new("UIGradient", { Color = ColorSequence.new(T.Accent, T.Accent2) }, TopLine)

----------------------------------------------------------------
-- SECTIONS (cards with header, tag, optional collapse)
----------------------------------------------------------------
local function makeSection(parent, title, tagText, tagKind, order, collapsible)
    local sec = { Open = true, BodyH = 0 }
    local card = new("CanvasGroup", {
        Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = T.Section, BackgroundTransparency = 0.12,
        BorderSizePixel = 0, LayoutOrder = order,
    }, parent)
    corner(card, 12)
    stroke(card, T.Stroke, 1)
    local header = new("Frame", { Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1 }, card)

    local tx
    if collapsible then
        sec.Chevron = makeChevron(header, UDim2.fromOffset(22, 20), T.SubText)
        tx = 38
    else
        local bar = new("Frame", {
            Position = UDim2.fromOffset(14, 13), Size = UDim2.fromOffset(3, 14), BackgroundColor3 = WHITE, BorderSizePixel = 0,
        }, header)
        corner(bar, 2)
        new("UIGradient", { Color = ColorSequence.new(T.Accent, T.Accent2), Rotation = 90 }, bar)
        tx = 26
    end
    sec.Title = label(header, title, 13, T.Text, Bold, UDim2.fromOffset(tx, 0), UDim2.new(1, -170, 1, 0))
    sec.Tag = makeTag(header, tagText, tagKind, UDim2.new(1, -12, 0.5, 0), 22)
    sec.Divider = new("Frame", {
        Position = UDim2.fromOffset(0, 40), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = T.Stroke,
        BackgroundTransparency = 0.5, BorderSizePixel = 0, Visible = false,
    }, card)
    sec.Body = new("Frame", { Position = UDim2.fromOffset(0, 41), Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1 }, card)
    sec.Card, sec.Header = card, header

    function sec:Resize(bodyH, animate)
        sec.BodyH = bodyH
        sec.Body.Size = UDim2.new(1, 0, 0, bodyH)
        sec.Divider.Visible = bodyH > 0
        local h = (sec.Open and bodyH > 0) and (41 + bodyH) or 40
        if animate then tween(card, 0.45, { Size = UDim2.new(1, 0, 0, h) })
        else card.Size = UDim2.new(1, 0, 0, h) end
    end

    function sec:SetOpen(open, instant)
        sec.Open = open
        sec:Resize(sec.BodyH, not instant)
        if sec.Chevron then
            if instant then sec.Chevron.Rotation = open and 180 or 0
            else tween(sec.Chevron, 0.4, { Rotation = open and 180 or 0 }) end
        end
        if sec.OnToggle then sec.OnToggle(open, instant) end
    end

    if collapsible then
        local hh = new("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 3 }, header)
        hh.MouseButton1Click:Connect(function() sec:SetOpen(not sec.Open) end)
        sec.HeaderHit = hh
    end
    return sec
end

----------------------------------------------------------------
-- PAGES
----------------------------------------------------------------
local function makePage()
    local p = new("CanvasGroup", {
        Position = UDim2.fromOffset(PAGE_X, PAGE_Y), Size = UDim2.fromOffset(PAGE_W, PAGE_H),
        BackgroundTransparency = 1, ZIndex = 3,
    }, Main)
    local sc = new("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
        ScrollBarImageColor3 = T.Stroke, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, p)
    new("UIPadding", {
        PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14),
    }, sc)
    new("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, sc)
    return p, sc
end

----------------------------------------------------------------
-- DASHBOARD (left sidebar: player + game + live stats)
----------------------------------------------------------------
local Dash = new("Frame", {
    Position = UDim2.fromOffset(0, TOP + 1), Size = UDim2.fromOffset(SIDE_W, H - TOP - 1),
    BackgroundColor3 = T.Topbar, BackgroundTransparency = 0.4, BorderSizePixel = 0, ZIndex = 3,
}, Main)
local DashEdge = new("Frame", {
    Position = UDim2.fromOffset(SIDE_W - 1, 0), Size = UDim2.new(0, 1, 1, 0), BackgroundColor3 = WHITE, BorderSizePixel = 0,
}, Dash)
new("UIGradient", {
    Color = ColorSequence.new(T.Accent, T.Accent2), Rotation = 90,
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.9), NumberSequenceKeypoint.new(0.5, 0.45), NumberSequenceKeypoint.new(1, 0.9),
    }),
}, DashEdge)

label(Dash, "DASHBOARD", 10, T.SubText, Bold, UDim2.fromOffset(14, 10), UDim2.fromOffset(100, 18))
makeTag(Dash, "LIVE", "good", UDim2.new(1, -12, 0, 19), 18)

-- player card
local PCard = new("Frame", {
    Position = UDim2.fromOffset(10, 34), Size = UDim2.fromOffset(176, 90), BackgroundColor3 = T.Element,
    BackgroundTransparency = 0.15, BorderSizePixel = 0,
}, Dash)
corner(PCard, 12)
stroke(PCard, T.Stroke, 1)

local Face = new("ImageLabel", {
    Position = UDim2.fromOffset(10, 10), Size = UDim2.fromOffset(44, 44), BackgroundColor3 = T.Stroke,
    BorderSizePixel = 0, Image = "",
}, PCard)
corner(Face, 22)
local FaceStroke = stroke(Face, WHITE, 2)
local FaceGrad = new("UIGradient", { Color = ColorSequence.new(T.Accent, T.Accent2), Rotation = 45 }, FaceStroke)
local OnlineDot = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(49, 49), Size = UDim2.fromOffset(10, 10),
    BackgroundColor3 = GOOD, BorderSizePixel = 0, ZIndex = 3,
}, PCard)
corner(OnlineDot, 5)
stroke(OnlineDot, T.Element, 2)
task.spawn(function()
    local ok, img = pcall(function()
        return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    end)
    if ok and img and Face.Parent then
        Face.Image = img
        Face.ImageTransparency = 1
        tween(Face, 0.5, { ImageTransparency = 0 })
    end
end)

label(PCard, LocalPlayer.DisplayName, 13, T.Text, Bold, UDim2.fromOffset(64, 12), UDim2.fromOffset(104, 18)).TextTruncate = Enum.TextTruncate.AtEnd
label(PCard, "@" .. LocalPlayer.Name, 10, T.SubText, Code, UDim2.fromOffset(64, 31), UDim2.fromOffset(104, 14)).TextTruncate = Enum.TextTruncate.AtEnd

local IdTag = makeTag(PCard, "ID  " .. LocalPlayer.UserId, "accent", UDim2.fromOffset(10, 70), 22, false, 0)
local IdHit = new("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 5 }, IdTag.Root)
IdHit.MouseButton1Click:Connect(function()
    local ok = pcall(function() setclip(tostring(LocalPlayer.UserId)) end)
    if ok then notify("Copied", "User ID " .. LocalPlayer.UserId .. " copied to clipboard", 3)
    else notify("Clipboard not supported", "Your executor has no clipboard function", 4) end
end)

-- game card
local GCard = new("Frame", {
    Position = UDim2.fromOffset(10, 132), Size = UDim2.fromOffset(176, 152), BackgroundColor3 = T.Element,
    BackgroundTransparency = 0.15, BorderSizePixel = 0,
}, Dash)
corner(GCard, 12)
stroke(GCard, T.Stroke, 1)

local GameImg = new("ImageLabel", {
    Position = UDim2.fromOffset(8, 8), Size = UDim2.fromOffset(160, 80), BackgroundColor3 = T.Section,
    BorderSizePixel = 0, ScaleType = Enum.ScaleType.Crop,
    Image = "rbxthumb://type=GameIcon&id=" .. game.GameId .. "&w=256&h=256",
}, GCard)
corner(GameImg, 8)
local ImgFade = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0 }, GameImg)
corner(ImgFade, 8)
new("UIGradient", {
    Rotation = 90,
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.75), NumberSequenceKeypoint.new(1, 0.25),
    }),
}, ImgFade)

local gKind = supportedNow and "good" or (FallbackG and "warn" or "bad")
local gText = supportedNow and "SUPPORTED" or (FallbackG and "UNIVERSAL" or "UNSUPPORTED")
local GTag = makeTag(GameImg, gText, gKind, UDim2.fromOffset(8, 14), 20, true, 0)

local GName = label(GCard, currentEntry and currentEntry.name or "Loading...", 12, T.Text, Bold,
    UDim2.fromOffset(10, 94), UDim2.fromOffset(156, 18))
GName.TextTruncate = Enum.TextTruncate.AtEnd
label(GCard, "PLACE", 9, T.SubText, Bold, UDim2.fromOffset(10, 116), UDim2.fromOffset(40, 14))
label(GCard, tostring(game.PlaceId), 10, T.Text, Code, UDim2.fromOffset(52, 116), UDim2.fromOffset(116, 14)).TextTruncate = Enum.TextTruncate.AtEnd
label(GCard, "GAME", 9, T.SubText, Bold, UDim2.fromOffset(10, 132), UDim2.fromOffset(40, 14))
label(GCard, tostring(game.GameId), 10, T.Text, Code, UDim2.fromOffset(52, 132), UDim2.fromOffset(116, 14)).TextTruncate = Enum.TextTruncate.AtEnd

local gameNameReal = currentEntry and currentEntry.name or ("Place " .. game.PlaceId)
task.spawn(function()
    local ok, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
    if ok and info then
        if info.Name then gameNameReal = info.Name end
        if not currentEntry then GName.Text = gameNameReal end
        if info.IconImageAssetId and info.IconImageAssetId ~= 0 then
            GameImg.Image = "rbxassetid://" .. info.IconImageAssetId
        end
    elseif not currentEntry then
        GName.Text = gameNameReal
    end
end)

-- live stat chips
local function chip(parent, x, y, title, w)
    local f = new("Frame", {
        Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, 38),
        BackgroundColor3 = T.Element, BackgroundTransparency = 0.15, BorderSizePixel = 0,
    }, parent)
    corner(f, 10)
    stroke(f, T.Stroke, 1)
    label(f, title, 9, T.SubText, Bold, UDim2.fromOffset(0, 5), UDim2.new(1, 0, 0, 12), Center)
    return label(f, "--", 13, T.Text, Bold, UDim2.fromOffset(0, 18), UDim2.new(1, 0, 0, 16), Center)
end
local FpsV  = chip(Dash, 10, 292, "FPS", 83)
local PingV = chip(Dash, 103, 292, "PING (MS)", 83)
label(Dash, ToggleKey.Name .. " = minimize", 9, T.SubText, Code, UDim2.fromOffset(0, 338), UDim2.new(1, 0, 0, 14), Center)

----------------------------------------------------------------
-- KEY PAGE
----------------------------------------------------------------
local KeyPage, KeyScroll = makePage()

local Verify = makeSection(KeyScroll, "Verification", MaxTries .. " TRIES", "accent", 1, false)
Verify:Resize(126, false)
local VB = Verify.Body

local SubLbl = label(VB, "", 12, T.SubText, Med, UDim2.fromOffset(14, 10), UDim2.fromOffset(300, 16))

local PipBox = new("Frame", {
    AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 12),
    Size = UDim2.fromOffset(MaxTries * 16, 12), BackgroundTransparency = 1,
}, VB)
new("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right,
    VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 6),
}, PipBox)
local pips = {}
for i = 1, MaxTries do
    local p = new("Frame", { Size = UDim2.fromOffset(10, 10), BackgroundColor3 = T.Accent2, BorderSizePixel = 0, LayoutOrder = i }, PipBox)
    corner(p, 5)
    pips[i] = p
end

-- textbox
local BoxWrap = new("Frame", {
    Position = UDim2.fromOffset(14, 30), Size = UDim2.fromOffset(392, 40), BackgroundColor3 = T.Element, BorderSizePixel = 0,
}, VB)
corner(BoxWrap, 10)
local BoxStroke = stroke(BoxWrap, T.Stroke, 1)

local Pill = new("Frame", { Size = UDim2.fromOffset(52, 40), BackgroundColor3 = T.Section, BorderSizePixel = 0 }, BoxWrap)
corner(Pill, 10)
new("Frame", { Position = UDim2.fromOffset(26, 0), Size = UDim2.fromOffset(26, 40), BackgroundColor3 = T.Section, BorderSizePixel = 0 }, Pill)
local PillTxt = label(Pill, "KEY", 11, T.Accent2, Bold, UDim2.new(), UDim2.fromScale(1, 1), Center)
PillTxt.ZIndex = 2
new("Frame", { Position = UDim2.fromOffset(52, 0), Size = UDim2.new(0, 1, 1, 0), BackgroundColor3 = T.Stroke, BorderSizePixel = 0 }, BoxWrap)

local boxRight = getclip and 84 or 12
local Box = new("TextBox", {
    Text = "", PlaceholderText = "Paste your key here...", PlaceholderColor3 = T.SubText,
    Font = Med, TextSize = 14, TextColor3 = T.Text, BackgroundTransparency = 1,
    ClearTextOnFocus = false, ClipsDescendants = true, TextXAlignment = Left,
    Position = UDim2.fromOffset(64, 0), Size = UDim2.new(1, -(64 + boxRight), 1, 0),
}, BoxWrap)

local Underline = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, 0),
    Size = UDim2.new(0, 0, 0, 2), BackgroundColor3 = WHITE, BorderSizePixel = 0,
}, BoxWrap)
local UnderGrad = new("UIGradient", { Color = ColorSequence.new(T.Accent, T.Accent2) }, Underline)
local boxLocked = false

local function boxFocusVisual(on)
    if boxLocked then return end
    tween(BoxStroke, 0.25, { Color = on and T.Accent2 or T.Stroke })
    tween(BoxWrap, 0.25, { BackgroundColor3 = on and T.ElementHover or T.Element })
    tween(PillTxt, 0.25, { TextColor3 = on and T.Accent or T.Accent2 })
    tween(Underline, 0.4, { Size = on and UDim2.new(1, -24, 0, 2) or UDim2.new(0, 0, 0, 2) })
end
Box.Focused:Connect(function() boxFocusVisual(true) end)
Box.FocusLost:Connect(function() boxFocusVisual(false) end)

local function flashBox(good)
    local c = good and GOOD or BAD
    boxLocked = true
    BoxStroke.Color = c
    UnderGrad.Color = ColorSequence.new(c)
    tween(Underline, 0.3, { Size = UDim2.new(1, -24, 0, 2) })
    if good then return end
    task.delay(0.8, function()
        boxLocked = false
        UnderGrad.Color = ColorSequence.new(T.Accent, T.Accent2)
        boxFocusVisual(Box:IsFocused())
    end)
end

if getclip then
    local PasteBtn = makeButton(BoxWrap, "PASTE", UDim2.new(1, -72, 0.5, -13), UDim2.fromOffset(62, 26), "ghost")
    PasteBtn.Label.TextSize = 10
    PasteBtn.Hit.MouseButton1Click:Connect(function()
        local ok, txt = pcall(function() return getclip() end)
        if ok and type(txt) == "string" and txt ~= "" then
            Box.Text = txt:match("^%s*(.-)%s*$")
        else
            notify("Paste failed", "Could not read your clipboard", 3)
        end
    end)
end

local VerifyBtn = makeButton(VB, "Verify Key", UDim2.fromOffset(14, 78), UDim2.fromOffset(191, 36), "primary")
local GetKeyBtn = makeButton(VB, "Get Key", UDim2.fromOffset(211, 78), UDim2.fromOffset(195, 36), "ghost")
local KeyChev = makeChevron(GetKeyBtn.Root, UDim2.new(1, -20, 0.5, 0), T.Text)

-- Get Key: collapsible section with the links
local LinkSec = makeSection(KeyScroll, "Get Key", #urlNames .. (#urlNames == 1 and " LINK" or " LINKS"), "accent", 2, true)
LinkSec:Resize(ROWS * ROW_H + 12, false)
LinkSec:SetOpen(false, true)
LinkSec.Tag.Root.Position = UDim2.new(1, -44, 0.5, 0)

local CloseX = makeButton(LinkSec.Header, "X", UDim2.new(1, -36, 0.5, -12), UDim2.fromOffset(24, 24), "ghost", true)
CloseX.Label.TextSize = 11
CloseX.Root.GroupTransparency = 1
CloseX.Hit.Visible = false
CloseX.Hit.ZIndex = 20

local List = new("ScrollingFrame", {
    Position = UDim2.fromOffset(10, 6), Size = UDim2.fromOffset(392, ROWS * ROW_H),
    BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
    ScrollBarImageColor3 = T.Stroke, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, LinkSec.Body)
new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, List)

local linkRows = {}
for _, name in ipairs(urlNames) do
    local link = Url[name]
    local domain = tostring(link):match("^https?://([^/]+)") or ""
    local row = makeButton(List, name, UDim2.new(), UDim2.new(1, -8, 0, 30), "ghost", true)
    row.Label.TextXAlignment = Left
    pad(row.Label, 14, 0)
    local dl = label(row.Root, domain, 10, T.SubText, Code, UDim2.new(1, -190, 0, 0), UDim2.fromOffset(120, 30), Right)
    dl.TextTruncate = Enum.TextTruncate.AtEnd
    makeTag(row.Root, "COPY", "accent", UDim2.new(1, -8, 0.5, 0), 18)
    row.Root.GroupTransparency = 1
    row.Hit.MouseButton1Click:Connect(function()
        local ok = pcall(function() setclip(link) end)
        if ok then notify("Link Copied", name .. " link copied to your clipboard", 3)
        else notify("Clipboard not supported", "Your executor has no clipboard function", 4) end
        LinkSec:SetOpen(false)
    end)
    table.insert(linkRows, row)
end

LinkSec.OnToggle = function(open, instant)
    tween(KeyChev, 0.4, { Rotation = open and 180 or 0 })
    CloseX.Hit.Visible = open
    tween(CloseX.Root, 0.3, { GroupTransparency = open and 0 or 1 })
    for i, r in ipairs(linkRows) do
        if open and not instant then
            r.Root.GroupTransparency = 1
            task.delay(0.12 + i * 0.06, function()
                if LinkSec.Open then tween(r.Root, 0.3, { GroupTransparency = 0 }) end
            end)
        else
            tween(r.Root, 0.15, { GroupTransparency = 1 })
        end
    end
    if open and not instant then
        task.delay(0.15, function()
            pcall(function()
                local y = math.max(0, KeyScroll.AbsoluteCanvasSize.Y - KeyScroll.AbsoluteWindowSize.Y)
                tween(KeyScroll, 0.45, { CanvasPosition = Vector2.new(0, y) })
            end)
        end)
    end
end

GetKeyBtn.Hit.MouseButton1Click:Connect(function()
    if #urlNames == 0 then notify("No links set", "Add links to the Url table", 3) return end
    LinkSec:SetOpen(not LinkSec.Open)
end)
CloseX.Hit.MouseButton1Click:Connect(function() LinkSec:SetOpen(false) end)

----------------------------------------------------------------
-- GAMES PAGE
----------------------------------------------------------------
local GamesPage, GamesScroll = makePage()
GamesPage.Visible = false
GamesPage.GroupTransparency = 1

local Det = makeSection(GamesScroll, "Detected Game", supportedNow and "SUPPORTED" or (FallbackG and "UNIVERSAL" or "UNSUPPORTED"), gKind, 1, false)
Det:Resize(62, false)
do
    local col = supportedNow and GOOD or (FallbackG and WARN or BAD)
    local sdot = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(26, 31), Size = UDim2.fromOffset(10, 10),
        BackgroundColor3 = col, BorderSizePixel = 0,
    }, Det.Body)
    corner(sdot, 5)
    local ring = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(26, 31), Size = UDim2.fromOffset(10, 10),
        BackgroundTransparency = 1, BorderSizePixel = 0,
    }, Det.Body)
    corner(ring, 20)
    local rs = stroke(ring, col, 2)
    TweenService:Create(ring, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1), { Size = UDim2.fromOffset(30, 30) }):Play()
    TweenService:Create(rs, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1), { Transparency = 1 }):Play()

    label(Det.Body, supportedNow and "Game Supported" or "Game Not Supported", 15, col, Bold, UDim2.fromOffset(50, 10), UDim2.new(1, -64, 0, 20))
    local sub = label(Det.Body, "Playing: ...", 11, T.SubText, Reg, UDim2.fromOffset(50, 31), UDim2.new(1, -64, 0, 16))
    sub.TextTruncate = Enum.TextTruncate.AtEnd
    task.spawn(function()
        local ok, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
        sub.Text = "Playing: " .. ((ok and info and info.Name) or ("Place " .. game.PlaceId))
    end)
end

local ListHead = makeSection(GamesScroll, "Supported Games", #entries .. (#entries == 1 and " GAME" or " GAMES"), "accent", 2, false)
ListHead:Resize(0, false)

local ROW_C, ROW_OPEN = 56, 118
local gameRows = {}
if #entries == 0 then
    local l = label(GamesScroll, "No games added yet.", 12, T.SubText, Med, UDim2.new(), UDim2.new(1, 0, 0, 30), Center)
    l.LayoutOrder = 3
end

for idx, e in ipairs(entries) do
    local cur = currentEntry == e
    local ready = hasScript(e.g)
    local row = new("CanvasGroup", {
        Size = UDim2.new(1, 0, 0, ROW_C), BackgroundColor3 = T.Section, BackgroundTransparency = 0.12,
        BorderSizePixel = 0, LayoutOrder = 2 + idx,
    }, GamesScroll)
    corner(row, 12)
    stroke(row, cur and GOOD or T.Stroke, 1)

    local icon = new("ImageLabel", {
        Position = UDim2.fromOffset(8, 6), Size = UDim2.fromOffset(44, 44), BackgroundColor3 = T.Element,
        BorderSizePixel = 0, Image = "", ScaleType = Enum.ScaleType.Crop,
    }, row)
    corner(icon, 8)

    label(row, e.name, 14, T.Text, Bold, UDim2.fromOffset(62, 9), UDim2.new(1, -200, 0, 18)).TextTruncate = Enum.TextTruncate.AtEnd
    label(row, "ID: " .. tostring(e.ids[1] or "?"), 11, T.SubText, Code, UDim2.fromOffset(62, 30), UDim2.new(1, -200, 0, 16))

    makeTag(row, cur and "PLAYING" or (ready and "SUPPORTED" or "NO SCRIPT"),
        cur and "good" or (ready and "accent" or "warn"), UDim2.new(1, -38, 0, 28), 22)
    local rowChev = makeChevron(row, UDim2.new(1, -18, 0, 28), T.SubText)

    local function line(y, k, v, vc)
        label(row, k, 11, T.SubText, Med, UDim2.fromOffset(14, y), UDim2.fromOffset(80, 16))
        local vl = label(row, v, 11, vc or T.Text, Bold, UDim2.fromOffset(96, y), UDim2.new(1, -110, 0, 16))
        vl.TextTruncate = Enum.TextTruncate.AtEnd
    end
    local idList = {}
    for _, id in ipairs(e.ids) do table.insert(idList, tostring(id)) end
    new("Frame", { Position = UDim2.fromOffset(14, 58), Size = UDim2.new(1, -28, 0, 1), BackgroundColor3 = T.Stroke, BorderSizePixel = 0 }, row)
    line(66, "Place IDs", #idList > 0 and table.concat(idList, ", ") or "none")
    line(84, "Script", ready and "Ready" or "Not set", ready and GOOD or WARN)
    line(102, "Here", cur and "You are playing this game" or "Join this game to use it", cur and GOOD or T.SubText)

    local open = false
    local head = new("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, ROW_C), ZIndex = 5 }, row)
    head.MouseButton1Click:Connect(function()
        open = not open
        tween(row, 0.4, { Size = UDim2.new(1, 0, 0, open and ROW_OPEN or ROW_C) })
        tween(rowChev, 0.4, { Rotation = open and 180 or 0 })
    end)

    task.spawn(function()
        local first = e.ids[1]
        local ok, info = pcall(function() return MarketplaceService:GetProductInfo(first) end)
        if ok and info and info.IconImageAssetId and info.IconImageAssetId ~= 0 then
            icon.Image = "rbxassetid://" .. info.IconImageAssetId
        elseif cur then
            icon.Image = "rbxthumb://type=GameIcon&id=" .. game.GameId .. "&w=150&h=150"
        end
    end)
    table.insert(gameRows, row)
end

local function playRows()
    for i, r in ipairs(gameRows) do
        r.GroupTransparency = 1
        task.delay(0.08 + i * 0.07, function() tween(r, 0.35, { GroupTransparency = 0 }) end)
    end
end

----------------------------------------------------------------
-- INFO PAGE
----------------------------------------------------------------
local InfoPage, InfoScroll = makePage()
InfoPage.Visible = false
InfoPage.GroupTransparency = 1

local How = makeSection(InfoScroll, "How it works", "3 STEPS", "accent", 1, false)
How:Resize(3 * 32 + 12, false)
local steps = {
    "Press Get Key, pick a link and finish the steps to receive your key.",
    "Paste the key into the Verification box and press Verify Key.",
    "DEXPS detects your game and loads its script automatically.",
}
for i, txt in ipairs(steps) do
    local y = 6 + (i - 1) * 32
    local c = new("Frame", { Position = UDim2.fromOffset(14, y + 5), Size = UDim2.fromOffset(22, 22), BackgroundColor3 = WHITE, BorderSizePixel = 0 }, How.Body)
    corner(c, 11)
    new("UIGradient", { Color = ColorSequence.new(T.Accent, T.Accent2), Rotation = 45 }, c)
    label(c, tostring(i), 11, T.OnAccent, Bold, UDim2.new(), UDim2.fromScale(1, 1), Center)
    local l = label(How.Body, txt, 11, T.SubText, Med, UDim2.fromOffset(46, y), UDim2.new(1, -60, 0, 32))
    l.TextWrapped = true
end

local Sess = makeSection(InfoScroll, "Session", "LIVE", "good", 2, false)
Sess:Resize(5 * 22 + 12, false)
local function infoRow(i, k)
    local y = 8 + (i - 1) * 22
    label(Sess.Body, k, 12, T.SubText, Med, UDim2.fromOffset(14, y), UDim2.fromOffset(140, 20))
    return label(Sess.Body, "--", 12, T.Text, Code, UDim2.new(1, -164, 0, y), UDim2.fromOffset(150, 20), Right)
end
local SessTries  = infoRow(1, "Tries left")
local SessUptime = infoRow(2, "Uptime")
local SessPing   = infoRow(3, "Ping")
local SessFps    = infoRow(4, "FPS")
local SessTheme  = infoRow(5, "Theme")
SessTheme.Text = themeName

----------------------------------------------------------------
-- TAB SWITCHING (smooth slide + fade, sliding indicator)
----------------------------------------------------------------
local Pages = { Key = KeyPage, Games = GamesPage, Info = InfoPage }
local switching = false

goTab = function(name)
    if switching or name == currentTab then return end
    switching = true
    local from, to = Pages[currentTab], Pages[name]
    local dir = tabIndex[name] > tabIndex[currentTab] and 1 or -1

    tween(Indicator, 0.4, { Position = UDim2.fromOffset(4 + (tabIndex[name] - 1) * TAB_W, 4) })
    for n, b in pairs(tabLabels) do
        tween(b, 0.25, { TextColor3 = n == name and T.OnAccent or T.SubText })
    end
    tween(from, 0.22, { GroupTransparency = 1, Position = UDim2.fromOffset(PAGE_X - dir * 28, PAGE_Y) }, Enum.EasingStyle.Quad)
    task.wait(0.22)

    from.Visible = false
    to.Position = UDim2.fromOffset(PAGE_X + dir * 28, PAGE_Y)
    to.GroupTransparency = 1
    to.Visible = true
    tween(to, 0.4, { GroupTransparency = 0, Position = UDim2.fromOffset(PAGE_X, PAGE_Y) })
    if name == "Games" then playRows() end
    currentTab = name
    task.wait(0.4)
    switching = false
end

----------------------------------------------------------------
-- FX: confetti burst
----------------------------------------------------------------
local FX = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 50 }, Gui)
local function burst()
    local c = Main.AbsolutePosition + Main.AbsoluteSize / 2
    local cols = { T.Accent, T.Accent2, T.Glow, T.Snow, GOOD }
    for i = 1, 52 do
        local sz = rng:NextInteger(4, 8)
        local p = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(c.X, c.Y),
            Size = UDim2.fromOffset(sz, sz), BackgroundColor3 = cols[rng:NextInteger(1, #cols)],
            BorderSizePixel = 0, Rotation = rng:NextInteger(0, 90),
        }, FX)
        if i % 2 == 0 then corner(p, sz) end
        local a = rng:NextNumber(0, math.pi * 2)
        local dist = rng:NextNumber(120, 330) * (0.6 + 0.4 * S)
        local dur = rng:NextNumber(0.7, 1.1)
        tween(p, dur, {
            Position = UDim2.fromOffset(c.X + math.cos(a) * dist, c.Y + math.sin(a) * dist + 60),
            BackgroundTransparency = 1, Rotation = p.Rotation + rng:NextInteger(-200, 200),
        }, Enum.EasingStyle.Quad)
        task.delay(dur + 0.05, function() p:Destroy() end)
    end
    local ring = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(c.X, c.Y),
        Size = UDim2.fromOffset(60, 60), BackgroundTransparency = 1, BorderSizePixel = 0,
    }, FX)
    corner(ring, 2000)
    local rs = stroke(ring, T.Accent, 3)
    tween(ring, 0.9, { Size = UDim2.fromOffset(900, 900) }, Enum.EasingStyle.Quad)
    tween(rs, 0.9, { Transparency = 1 }, Enum.EasingStyle.Quad)
    task.delay(1, function() ring:Destroy() end)
end

local function redFlash()
    tween(Dim, 0.08, { BackgroundColor3 = BAD })
    task.delay(0.12, function()
        if alive then tween(Dim, 0.5, { BackgroundColor3 = T.Dim }) end
    end)
end

local shaking = false
local function shake()
    if shaking then return end
    shaking = true
    for i = 1, 8 do
        local d = (i % 2 == 0 and 1 or -1) * (16 - i * 1.5)
        tween(Canvas, 0.045, { Position = UDim2.new(0.5, d, 0.5, 0) }, Enum.EasingStyle.Sine).Completed:Wait()
    end
    Canvas.Position = UDim2.fromScale(0.5, 0.5)
    shaking = false
end

----------------------------------------------------------------
-- RECTANGLE TOGGLE BUTTON (shown while minimized, draggable)
----------------------------------------------------------------
local TBW, TBH = 124, 38
local Toggle = new("Frame", {
    Name = "Toggle", AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(TBW, TBH),
    Position = UDim2.fromOffset(0, 0), BackgroundTransparency = 1, Visible = false, ZIndex = 6,
}, Gui)
local TScale = new("UIScale", { Scale = 0.7 }, Toggle)
local TShadowWide = shadowLayer(Toggle, 70)
local TShadowTight = shadowLayer(Toggle, 28)

local TBody = new("CanvasGroup", {
    Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, GroupTransparency = 1, ZIndex = 1,
}, Toggle)
corner(TBody, 10)
local TStroke = stroke(TBody, WHITE, 2)
local TStrokeGrad = new("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, T.Accent), ColorSequenceKeypoint.new(0.5, T.Accent2), ColorSequenceKeypoint.new(1, T.Accent),
    }),
}, TStroke)

local TFill = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, BorderSizePixel = 0 }, TBody)
new("UIGradient", { Color = ColorSequence.new(T.Background, T.Background2), Rotation = 62 }, TFill)
local TWash = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, BorderSizePixel = 0 }, TBody)
new("UIGradient", {
    Rotation = 38, Color = ColorSequence.new(T.Accent, T.Accent2),
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.55), NumberSequenceKeypoint.new(0.65, 1), NumberSequenceKeypoint.new(1, 1),
    }),
}, TWash)
local TSnowHolder = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ClipsDescendants = true }, TBody)
local tbSnow = makeSnow(TSnowHolder, 14, 1.4, 3, 0.1, 0.35)

local TLogo = new("Frame", {
    AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 9, 0.5, 0), Size = UDim2.fromOffset(24, 24),
    BackgroundColor3 = T.Background, BorderSizePixel = 0,
}, TBody)
corner(TLogo, 12)
local TLogoStroke = stroke(TLogo, WHITE, 1.5)
new("UIGradient", { Color = ColorSequence.new(T.Accent, T.Accent2), Rotation = 45 }, TLogoStroke)
local TLogoTxt = label(TLogo, "DX", 9, WHITE, Black, UDim2.new(), UDim2.fromScale(1, 1), Center)
new("UIGradient", { Color = ColorSequence.new(T.Accent, T.Accent2), Rotation = 90 }, TLogoTxt)

local TTitle = label(TBody, HubTitle, 15, WHITE, Black, UDim2.fromOffset(40, 0), UDim2.new(1, -62, 1, 0), Left)
local TTitleGrad = new("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, T.Text), ColorSequenceKeypoint.new(0.5, T.Accent), ColorSequenceKeypoint.new(1, T.Accent2),
    }),
}, TTitle)
local TDot = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -13, 0.5, 0), Size = UDim2.fromOffset(6, 6),
    BackgroundColor3 = T.Accent2, BorderSizePixel = 0,
}, TBody)
corner(TDot, 3)
table.insert(pulseDots, TDot)

local TBHit = new("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 10 }, Toggle)

----------------------------------------------------------------
-- STATE: window / toggle / backdrop (everything eases every frame)
----------------------------------------------------------------
local appear, appearT = 0, 1
local bAppear, bAppearT = 0, 0
local backdrop, backdropT = 0, 1
local lastOrbA = -1
local tbHover, tbHoverT = 1, 1
local minimized, closing, togglePlaced = false, false, false
local btnX, btnY, btnTX, btnTY = 16, 76, 16, 76

local function clampWin(x, y)
    local s = screenSize()
    return math.clamp(x, 90 - W * S, s.X - 90), math.clamp(y, 0, s.Y - 60)
end
local function clampBtn(x, y)
    local s = screenSize()
    return math.clamp(x, 0, s.X - TBW), math.clamp(y, 0, s.Y - TBH)
end

local function setMinimized(state)
    if closing or state == minimized then return end
    minimized = state
    if state then
        if not togglePlaced then
            togglePlaced = true
            btnTX, btnTY = clampBtn(curX + 12, curY + 8)
            btnX, btnY = btnTX, btnTY
        end
        Toggle.Visible = true
        appearT, bAppearT, backdropT = 0, 1, 0
    else
        Root.Visible = true
        appearT, bAppearT, backdropT = 1, 0, 1
    end
end
MinBtn.MouseButton1Click:Connect(function() setMinimized(true) end)

-- drag the window (smooth: target position eased every frame)
local conns = {}
local dragging, grabX, grabY = false, 0, 0
Top.InputBegan:Connect(function(input)
    if isPress(input) then
        dragging = true
        local p = pointer(input)
        grabX, grabY = p.X - tgtX, p.Y - tgtY
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
table.insert(conns, UIS.InputChanged:Connect(function(input)
    if dragging and isMove(input) then
        local p = pointer(input)
        tgtX, tgtY = clampWin(p.X - grabX, p.Y - grabY)
    end
end))

-- drag the toggle button (click = restore, drag = move)
do
    local bDragging, moved, hovering = false, false, false
    local startP, bGrabX, bGrabY = Vector2.new(), 0, 0
    TBHit.MouseEnter:Connect(function() hovering = true; tbHoverT = 1.07 end)
    TBHit.MouseLeave:Connect(function() hovering = false; tbHoverT = 1 end)
    TBHit.InputBegan:Connect(function(input)
        if isPress(input) then
            bDragging, moved = true, false
            startP = pointer(input)
            bGrabX, bGrabY = startP.X - btnTX, startP.Y - btnTY
            tbHoverT = 0.94
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    bDragging = false
                    tbHoverT = hovering and 1.07 or 1
                    if not moved then setMinimized(false) end
                end
            end)
        end
    end)
    table.insert(conns, UIS.InputChanged:Connect(function(input)
        if bDragging and isMove(input) then
            local p = pointer(input)
            if (p - startP).Magnitude > 6 then moved = true end
            if moved then btnTX, btnTY = clampBtn(p.X - bGrabX, p.Y - bGrabY) end
        end
    end))
end

table.insert(conns, UIS.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == ToggleKey then setMinimized(not minimized) end
end))

local function onResize()
    calcScale()
    Root.Size = UDim2.fromOffset(W * S, H * S)
    tgtX, tgtY = clampWin(tgtX, tgtY)
end
table.insert(conns, Gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(onResize))

----------------------------------------------------------------
-- VERIFY LOGIC
----------------------------------------------------------------
local tries, busy, accepted = MaxTries, false, false

local function setSub(text, color)
    SubLbl.Text = text
    SubLbl.TextColor3 = color or T.SubText
end
local function refreshSub() setSub("Enter your key to unlock " .. HubTitle) end
refreshSub()

local function updateTries()
    for i, p in ipairs(pips) do
        if i <= tries then tween(p, 0.3, { BackgroundColor3 = T.Accent2, BackgroundTransparency = 0 })
        else tween(p, 0.3, { BackgroundColor3 = BAD, BackgroundTransparency = 0.55 }) end
    end
    local txt = tries .. (tries == 1 and " TRY LEFT" or " TRIES LEFT")
    Verify.Tag:Set(txt, tries >= MaxTries and "accent" or (tries > 1 and "warn" or "bad"))
    SessTries.Text = tostring(tries) .. " / " .. MaxTries
end
updateTries()

local loop
local function cleanup()
    closing = true
    appearT, bAppearT, backdropT = 0, 0, 0
    task.wait(0.6)
    alive = false
    if loop then loop:Disconnect() end
    for _, c in ipairs(conns) do c:Disconnect() end
    pcall(function() Blur:Destroy() end)
    pcall(function() DoF:Destroy() end)
    Gui:Destroy()
    -- keep the black notifications alive until they finish
    task.spawn(function()
        local t0 = os.clock()
        while (#notifs > 0 or os.clock() - t0 < 1) and os.clock() - t0 < 15 do task.wait(0.25) end
        notifConn:Disconnect()
        NotifGui:Destroy()
    end)
end

local function verify(key)
    if busy or switching or closing then return end

    if accepted then -- key accepted earlier but this game had no script
        busy = true
        cleanup()
        return
    end

    key = tostring(key or ""):match("^%s*(.-)%s*$")
    if key == "" then
        notify("Enter a key", "Paste your key into the box first.", 3)
        return
    end

    busy = true
    VerifyBtn.Label.Text = "Checking..."
    task.wait(0.35)

    if key == CorrectKey then
        flashBox(true)
        setSub("Key accepted", GOOD)
        VerifyBtn.Label.Text = "Unlocked"
        notify("Correct Key", "Welcome, " .. LocalPlayer.DisplayName .. ".", 3)
        burst()
        if SaveKey then pcall(function() writefile(KeyFile, key) end) end
        task.wait(0.7)

        local g = currentEntry and currentEntry.g or FallbackG
        local gname = currentEntry and currentEntry.name or "Universal"
        if g then
            notify("Loading", gname .. " script is loading...", 4)
            VerifyBtn.Label.Text = "Loading..."
            task.wait(0.9)
            cleanup()
            task.spawn(runScript, g)
        else
            accepted = true
            busy = false
            setSub("This game is not supported yet", BAD)
            VerifyBtn.Label.Text = "Close"
            notify("Game Not Supported", "There is no script for this game yet.", 5)
            task.wait(0.4)
            goTab("Games")
        end
        return
    end

    -- wrong key
    tries -= 1
    Box.Text = ""
    flashBox(false)
    redFlash()
    updateTries()
    task.spawn(shake)
    VerifyBtn.Label.Text = "Verify Key"
    if tries <= 0 then
        setSub("Wrong Key Pls Put An Valid One", BAD)
        notify("Wrong Key", "Pls Put An Valid One", 4)
        task.wait(0.9)
        LocalPlayer:Kick("Wrong Key Pls Put An Valid One")
    else
        busy = false
        setSub("Wrong key  -  " .. tries .. (tries == 1 and " try left" or " tries left"), BAD)
        notify("Wrong Key", tries .. (tries == 1 and " try left" or " tries left"), 4)
        task.delay(1.8, function() if alive and not busy and not accepted then refreshSub() end end)
    end
end

VerifyBtn.Hit.MouseButton1Click:Connect(function() verify(Box.Text) end)
Box.FocusLost:Connect(function(enter) if enter then verify(Box.Text) end end)

----------------------------------------------------------------
-- LIVE LOOP
----------------------------------------------------------------
local function getPing()
    local ok, v = pcall(function() return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue() end)
    return ok and v and math.floor(v + 0.5) or nil
end

local startT = os.clock()
local acc, frames = 0, 0

loop = RunService.Heartbeat:Connect(function(dt)
    local t = os.clock()
    local k = ease(dt, 10)

    -- eased state
    appear += (appearT - appear) * k
    bAppear += (bAppearT - bAppear) * k
    backdrop += (backdropT - backdrop) * ease(dt, 6)
    tbHover += (tbHoverT - tbHover) * ease(dt, 18)

    -- smooth positions
    local kp = ease(dt, 16)
    curX += (tgtX - curX) * kp
    curY += (tgtY - curY) * kp
    Root.Position = UDim2.fromOffset(curX, curY)
    btnX += (btnTX - btnX) * kp
    btnY += (btnTY - btnY) * kp
    Toggle.Position = UDim2.fromOffset(btnX + TBW / 2, btnY + TBH / 2)

    -- backdrop: dim + real blur + screen snow
    local bd = math.clamp(backdrop, 0, 1)
    local show = bd > 0.01
    Dim.Visible = show
    OrbsBG.Visible = show
    SnowBG.Visible = show
    Dim.BackgroundTransparency = 1 - (1 - DimAlpha) * bd
    Blur.Enabled = show
    Blur.Size = BlurSize * bd
    DoF.Enabled = show
    DoF.FarIntensity = 0.95 * bd
    if show then
        stepSnow(snowBG, dt, t, bd)
        stepOrbs(bgOrbs, t)
        if math.abs(bd - lastOrbA) > 0.004 then lastOrbA = bd; setOrbAlpha(bgOrbs, bd) end
    end

    -- window
    local a = math.clamp(appear, 0, 1)
    Root.Visible = a > 0.01
    if a > 0.01 then
        Main.GroupTransparency = 1 - a
        WinScale.Scale = S * (0.92 + 0.08 * a)
        local br = math.sin(t * 1.6) * 0.06
        WShadowWide.ImageTransparency = 1 - (1 - (0.50 + br)) * a
        WShadowTight.ImageTransparency = 1 - (1 - (0.28 + br)) * a

        stepSnow(snowIn, dt, t, 1)
        stepOrbs(inOrbs, t)
        stepSparkles(dt)

        StrokeGrad.Rotation = (t * 45) % 360
        LogoRing.Rotation = (t * 90) % 360
        BgGrad.Rotation = 62 + math.sin(t * 0.3) * 25
        TitleGrad.Offset = Vector2.new(math.sin(t * 1.2) * 0.6, 0)
        TopLineGrad.Offset = Vector2.new(math.sin(t * 0.8) * 0.4, 0)
        OrbitHolder.Rotation = (t * 120) % 360
        FaceGrad.Rotation = (t * 60) % 360
    end

    -- toggle button
    local ba = math.clamp(bAppear, 0, 1)
    Toggle.Visible = ba > 0.01
    if ba > 0.01 then
        TBody.GroupTransparency = 1 - ba
        TScale.Scale = tbHover * (0.7 + 0.3 * ba)
        local br = math.sin(t * 1.6) * 0.06
        TShadowWide.ImageTransparency = 1 - (1 - (0.50 + br)) * ba
        TShadowTight.ImageTransparency = 1 - (1 - (0.28 + br)) * ba
        TStrokeGrad.Rotation = (t * 60) % 360
        TTitleGrad.Offset = Vector2.new(math.sin(t * 1.2) * 0.6, 0)
        stepSnow(tbSnow, dt, t, ba)
    end

    -- tags: pulsing dots
    local pv = 0.1 + 0.4 * (0.5 + 0.5 * math.sin(t * 3))
    for _, d in ipairs(pulseDots) do
        if d.Parent then d.BackgroundTransparency = pv end
    end

    -- live stats
    frames += 1
    acc += dt
    if acc >= 0.5 then
        local fps = math.floor(frames / acc + 0.5)
        local ping = getPing()
        FpsV.Text = tostring(fps)
        tween(FpsV, 0.2, { TextColor3 = fps >= 50 and GOOD or (fps >= 30 and WARN or BAD) })
        PingV.Text = ping and (ping .. " ms") or "-- ms"
        if ping then tween(PingV, 0.2, { TextColor3 = ping <= 100 and GOOD or (ping <= 200 and WARN or BAD) }) end
        SessFps.Text = tostring(fps)
        SessPing.Text = ping and (ping .. " ms") or "-- ms"
        local up = math.floor(t - startT)
        SessUptime.Text = string.format("%02d:%02d", math.floor(up / 60), up % 60)
        acc, frames = 0, 0
    end
end)

----------------------------------------------------------------
-- INTRO
----------------------------------------------------------------
Root.Visible = true
Dim.Visible = true

-- auto-verify a saved key
if SaveKey then
    local ok, saved = pcall(function() return isfile and isfile(KeyFile) and readfile(KeyFile) end)
    if ok and saved and saved == CorrectKey then
        Box.Text = saved
        task.delay(0.8, verify, saved)
    end
end
