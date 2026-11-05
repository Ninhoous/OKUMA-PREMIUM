local CONFIG = {
    service = "OKUMA PREMIUM",
    identifier = "112067",
    discord = "https://discord.gg/ErGASZ4zjD",
    keyFile = "Okuma/premium_key.txt",
    price = "R$ 6,99",
    priceEn = "R$ 6.99",
}
local UNIVERSES = {
}
local PLACES = {
    [73283852203739] = { name = "Exército Brasileiro RP", id = "c4bb27fa75b78a504ecc82c95268f52d795eb5ba8451b73a92b50ff0cfb6fe99" },
}
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local LocalPlayer = Players.LocalPlayer
local genv = (type(getgenv) == "function" and getgenv()) or _G
local COUNTRY
pcall(function() COUNTRY = game:GetService("LocalizationService"):GetCountryRegionForPlayerAsync(LocalPlayer) end)
local LUSO = { BR = true, PT = true, AO = true, MZ = true, CV = true, GW = true, ST = true, TL = true }
local IS_PT = (COUNTRY ~= nil and LUSO[COUNTRY] == true) or tostring(LocalPlayer.LocaleId or ""):lower():sub(1, 2) == "pt"
local PT = {
    ["This game is not supported yet."] = "Esse jogo ainda não é suportado.",
    [" has no Premium yet."] = " ainda não tem Premium.",
    ["Could not reach the key service. Try again later."] = "Não deu pra falar com o sistema de key. Tenta de novo mais tarde.",
    ["Could not reach the key service. Try again."] = "Não deu pra falar com o sistema de key. Tenta de novo.",
    ["Invalid key."] = "Key inválida.",
    ["This key expired. Renew it on the Discord."] = "Essa key expirou. Renova no Discord.",
    ["This key was disabled."] = "Essa key foi desativada.",
    ["This key was already used."] = "Essa key já foi usada.",
    ["This key is bound to another device. Ask for an HWID reset on the Discord."] = "Essa key tá presa em outro aparelho. Pede um reset de HWID no Discord.",
    ["This device is banned."] = "Esse aparelho tá banido.",
    ["This key is for another script."] = "Essa key é de outro script.",
    ["The key service is unavailable."] = "O sistema de key tá fora do ar.",
    ["This key is not Premium."] = "Essa key não é Premium.",
    ["Too many tries. Wait a minute."] = "Muitas tentativas. Espera um minuto.",
    ["Key not accepted ("] = "Key recusada (",
    ["Could not load "] = "Não deu pra carregar ",
    ["Premium key"] = "Key Premium",
    ["Paste your Premium key"] = "Cola sua key Premium",
    ["Paste the Premium key you got on the Discord and press Verify."] = "Cola a key Premium que você recebeu no Discord e aperta Verificar.",
    ["Saved key: "] = "Key salva: ",
    ["Verify"] = "Verificar",
    ["Checking"] = "Verificando",
    ["Verified"] = "Verificada",
    ["Paste a key first."] = "Cola uma key primeiro.",
    ["Checking the key..."] = "Verificando a key...",
    ["Premium key accepted. Loading "] = "Key Premium aceita. Carregando ",
    ["The key is saved on this device. Next time you go straight in."] = "A key fica salva nesse aparelho. Da próxima vez você entra direto.",
    ["Don't have one? Get Premium for "] = "Ainda não tem? Pegue o Premium por ",
    [" on our Discord."] = " no nosso Discord.",
    ["Buy"] = "Comprar",
    ["Copied"] = "Copiado",
    ["Discord invite copied."] = "Convite do Discord copiado.",
    ["Your executor can't copy: the invite is in the box above."] = "Seu executor não copia: o convite tá na caixa de cima.",
}
local function T(s) return IS_PT and PT[s] or s end
local function notify(text)
    pcall(function() StarterGui:SetCore("SendNotification", { Title = "Okuma Premium", Text = text, Duration = 7 }) end)
end
local entry = UNIVERSES[game.GameId] or PLACES[game.PlaceId]
if not entry then notify(T("This game is not supported yet.")); return end
if entry.id == "" then notify(entry.name .. T(" has no Premium yet.")); return end
local PREVIEW = CONFIG.service == "" or CONFIG.identifier == ""
local Junkie
if PREVIEW then
    notify("Preview: try the key \"premium\".")
    Junkie = {
        check_key = function(k)
            task.wait(0.9)
            if k == "premium" then return { valid = true, is_keyless = false, is_premium = true, message = "KEY_VALID" } end
            if k == "okuma" then return { valid = true, is_keyless = false, is_premium = false, message = "KEY_VALID" } end
            return { valid = false, error = (k == "expired" and "KEY_EXPIRED") or "KEY_INVALID" }
        end,
        load_script = function() notify("Preview: " .. entry.name .. " Premium would load now.") end,
    }
else
    local okSdk, lib = pcall(function() return loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))() end)
    if not okSdk or type(lib) ~= "table" then notify(T("Could not reach the key service. Try again later.")); return end
    Junkie = lib
end
Junkie.service, Junkie.identifier, Junkie.script_id = CONFIG.service, CONFIG.identifier, entry.id
local function readKey()
    if not (isfile and readfile) then return nil end
    local ok, has = pcall(isfile, CONFIG.keyFile)
    if not (ok and has) then return nil end
    local ok2, k = pcall(readfile, CONFIG.keyFile)
    k = ok2 and type(k) == "string" and k:match("^%s*(.-)%s*$") or nil
    return (k and k ~= "") and k or nil
end
local function saveKey(k)
    if PREVIEW or not writefile then return end
    pcall(function()
        if makefolder and isfolder and not isfolder("Okuma") then makefolder("Okuma") end
        writefile(CONFIG.keyFile, k or "")
    end)
end
local MESSAGES = {
    KEY_INVALID = "Invalid key.",
    KEY_EXPIRED = "This key expired. Renew it on the Discord.",
    KEY_INVALIDATED = "This key was disabled.",
    ALREADY_USED = "This key was already used.",
    HWID_MISMATCH = "This key is bound to another device. Ask for an HWID reset on the Discord.",
    HWID_BANNED = "This device is banned.",
    SERVICE_MISMATCH = "This key is for another script.",
    SERVICE_NOT_FOUND = "The key service is unavailable.",
    PREMIUM_REQUIRED = "This key is not Premium.",
    ["http 429"] = "Too many tries. Wait a minute.",
}
local function check(key)
    local ok, res = pcall(Junkie.check_key, key)
    if not ok or type(res) ~= "table" then
        warn("[Okuma Premium] check failed: " .. tostring(res))
        return false, T("Could not reach the key service. Try again."), "net"
    end
    warn(("[Okuma Premium] valid=%s keyless=%s premium=%s error=%s"):format(tostring(res.valid), tostring(res.is_keyless),
        tostring(res.is_premium), tostring(res.error)))
    if not res.valid then
        local msg = MESSAGES[tostring(res.error)]
        return false, msg and T(msg) or (T("Key not accepted (") .. tostring(res.error) .. ")."), (res.error == "PREMIUM_REQUIRED") and "free" or "bad"
    end
    if res.is_keyless or res.message == "KEYLESS" or res.is_premium ~= true then
        return false, T("This key is not Premium."), "free"
    end
    return true
end
local function launch(key)
    genv.SCRIPT_KEY = key
    local ok, err = pcall(Junkie.load_script)
    if not ok then notify(T("Could not load ") .. entry.name .. " Premium."); warn("[Okuma Premium] " .. tostring(err)) end
end
local saved = not PREVIEW and readKey() or nil
local savedErr
if saved then
    local ok, why, kind = check(saved)
    if ok then notify(T("Premium key accepted. Loading ") .. entry.name .. "."); launch(saved); return end
    savedErr = why
    if kind ~= "net" then saveKey("") end
end
local C = {
    deep = Color3.fromRGB(16, 16, 17), card = Color3.fromRGB(25, 25, 26), alt = Color3.fromRGB(41, 41, 42),
    hover = Color3.fromRGB(52, 52, 53), border = Color3.fromRGB(63, 63, 65), low = Color3.fromRGB(47, 47, 49),
    text = Color3.fromRGB(236, 236, 240), dim = Color3.fromRGB(140, 140, 150), mute = Color3.fromRGB(84, 84, 90),
    ok = Color3.fromRGB(110, 220, 130), warn = Color3.fromRGB(240, 190, 110), err = Color3.fromRGB(240, 110, 130),
    accent = Color3.fromRGB(236, 236, 240), accentDeep = Color3.fromRGB(196, 196, 204),
}
local F = {
    bold = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
    medium = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
    regular = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular),
}
local ICON = {
    logo = 89786629350927, shield = 13780781482, play = 8517323802, copy = 85360060654230, globe = 121176334529781,
    target = 107058246184363, check = 13289068631,
}
local function New(class, props)
    local o = Instance.new(class)
    for k, v in pairs(props) do if k ~= "Parent" then o[k] = v end end
    if props.Parent then o.Parent = props.Parent end
    return o
end
local function round(p, r) return New("UICorner", { CornerRadius = UDim.new(0, r), Parent = p }) end
local function stroke(p, c) return New("UIStroke", { Color = c, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = p }) end
local function tween(o, props, t, style)
    local tw = TweenService:Create(o, TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end
local function icon(parent, name, size, color)
    local img = New("ImageLabel", { BackgroundTransparency = 1, Size = UDim2.new(0, size, 0, size), ScaleType = Enum.ScaleType.Fit,
        Image = "rbxthumb://type=Asset&id=" .. ICON[name] .. "&w=150&h=150", Parent = parent })
    if color then img.ImageColor3 = color end
    return img
end
local function glintGrad(parent, base)
    return New("UIGradient", { Parent = parent, Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, base), ColorSequenceKeypoint.new(0.4, base), ColorSequenceKeypoint.new(0.5, C.accent),
        ColorSequenceKeypoint.new(0.6, base), ColorSequenceKeypoint.new(1, base) }) })
end
local function ripple(btn, color)
    local abs, size = btn.AbsolutePosition, btn.AbsoluteSize
    if size.X <= 0 or size.Y <= 0 then return end
    local m = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
    local host = New("CanvasGroup", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 5, Parent = btn })
    round(host, 10)
    local dot = New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = color, BackgroundTransparency = 0.75,
        Position = UDim2.fromScale(math.clamp((m.X - abs.X) / size.X, 0, 1), math.clamp((m.Y - abs.Y) / size.Y, 0, 1)),
        Size = UDim2.fromScale(0, 0), BorderSizePixel = 0, Parent = host })
    New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = dot })
    New("UIAspectRatioConstraint", { AspectRatio = 1, DominantAxis = Enum.DominantAxis.Width, Parent = dot })
    tween(dot, { Size = UDim2.fromScale(2.4, 2.4), BackgroundTransparency = 1 }, 0.55, Enum.EasingStyle.Quad)
    task.delay(0.6, function() host:Destroy() end)
end
local function copyDiscord()
    if setclipboard then pcall(setclipboard, CONFIG.discord); return true end
    return false
end
local gui = New("ScreenGui", { Name = "OkumaPremiumKey", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 1000,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
if not pcall(function() gui.Parent = (type(gethui) == "function" and gethui()) or game:GetService("CoreGui") end) then
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end
local conns = {}
local function track(c) conns[#conns + 1] = c; return c end
local touchOnly = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local dim = New("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1,
    BorderSizePixel = 0, Parent = gui })
local W, H = 380, 334
local shadows = {}
for i, a in ipairs({ 0.72, 0.84, 0.92 }) do
    local sh = New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1,
        BorderSizePixel = 0, Parent = gui })
    round(sh, 18 + i * 6)
    shadows[i] = { frame = sh, alpha = a, grow = i * 14 }
end
local win = New(touchOnly and "Frame" or "CanvasGroup", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, W, 0, H), BackgroundColor3 = C.deep, BorderSizePixel = 0, Parent = gui })
if not touchOnly then win.GroupTransparency = 1 end
round(win, 16)
local scale = New("UIScale", { Scale = 0.9, Parent = win })
track(RunService.RenderStepped:Connect(function()
    local abs = win.AbsoluteSize
    local seen = win.Visible and (touchOnly and 0 or win.GroupTransparency) or 1
    for _, sh in ipairs(shadows) do
        sh.frame.Position = win.Position + UDim2.fromOffset(0, 10)
        sh.frame.Size = UDim2.fromOffset(abs.X + sh.grow, abs.Y + sh.grow)
        sh.frame.BackgroundTransparency = sh.alpha + (1 - sh.alpha) * seen
    end
end))
local sheenTop = New("Frame", { Size = UDim2.new(1, 0, 0, 130), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.955,
    BorderSizePixel = 0, ZIndex = 0, Parent = win })
New("UIGradient", { Rotation = 90, Parent = sheenTop, Transparency = NumberSequence.new(0, 1) })
for i = 1, 10 do
    local d = New("Frame", { Size = UDim2.fromOffset(2, 2), BackgroundColor3 = C.text, BackgroundTransparency = 0.82, BorderSizePixel = 0,
        ZIndex = 0, Parent = win })
    round(d, 1)
    task.spawn(function()
        task.wait(i * 0.4)
        while d.Parent do
            local x, t = math.random(8, 92) / 100, math.random(55, 95) / 10
            d.Position = UDim2.new(x, 0, 1, 4)
            d.BackgroundTransparency = 0.75 + math.random() * 0.15
            tween(d, { Position = UDim2.new(x + (math.random() - 0.5) * 0.12, 0, 0, -6), BackgroundTransparency = 1 }, t, Enum.EasingStyle.Sine)
            task.wait(t)
        end
    end)
end
local cam = workspace.CurrentCamera
local fit = (cam and cam.ViewportSize.X < W + 32) and (cam.ViewportSize.X - 32) / W or 1
local border = stroke(win, Color3.new(1, 1, 1))
local glint = glintGrad(border, C.border)
local GLINT = glint.Color
track(RunService.RenderStepped:Connect(function() glint.Rotation = (os.clock() * 40) % 360 end))
local tile = New("Frame", { Position = UDim2.new(0, 20, 0, 20), Size = UDim2.new(0, 36, 0, 36), BackgroundTransparency = 1, Parent = win })
local logo = icon(tile, "logo", 36)
logo.AnchorPoint, logo.Position = Vector2.new(0.5, 0.5), UDim2.new(0.5, 0, 0.5, 0)
round(logo, 10)
local logoRing = New("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 1.5, Parent = logo })
local logoGrad = glintGrad(logoRing, C.accentDeep)
track(RunService.RenderStepped:Connect(function() logoGrad.Rotation = (os.clock() * 90) % 360 end))
local logoScale = New("UIScale", { Scale = 1, Parent = logo })
track(RunService.RenderStepped:Connect(function() logoScale.Scale = 1 + math.sin(os.clock() * 2.2) * 0.035 end))
track(tile.MouseEnter:Connect(function()
    tween(logo, { Rotation = -12, Size = UDim2.new(0, 39, 0, 39) }, 0.12, Enum.EasingStyle.Quad)
    task.delay(0.12, function() tween(logo, { Rotation = 0, Size = UDim2.new(0, 36, 0, 36) }, 0.6, Enum.EasingStyle.Elastic) end)
end))
local titleRow = New("Frame", { Position = UDim2.new(0, 66, 0, 18), Size = UDim2.new(1, -120, 0, 22), BackgroundTransparency = 1, Parent = win })
New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center,
    Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = titleRow })
New("TextLabel", { Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Text = "Okuma",
    TextColor3 = C.text, FontFace = F.bold, TextSize = 16, LayoutOrder = 1, Parent = titleRow })
local badge = New("Frame", { Size = UDim2.new(0, 0, 0, 18), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = C.alt,
    BorderSizePixel = 0, ClipsDescendants = true, LayoutOrder = 2, Parent = titleRow })
round(badge, 6)
New("UIPadding", { PaddingLeft = UDim.new(0, 7), PaddingRight = UDim.new(0, 7), Parent = badge })
stroke(badge, C.border)
New("TextLabel", { Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Text = "PREMIUM",
    TextColor3 = C.text, FontFace = F.bold, TextSize = 10, Parent = badge })
local subLbl = New("TextLabel", { Position = UDim2.new(0, 66, 0, 40), Size = UDim2.new(1, -120, 0, 14), BackgroundTransparency = 1,
    Text = T("Premium key") .. (PREVIEW and "  ·  preview" or "  ·  v3") .. (COUNTRY and ("  ·  " .. COUNTRY) or ""),
    TextColor3 = C.dim, FontFace = F.regular, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = win })
local closeBtn = New("TextButton", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 14), Size = UDim2.new(0, 28, 0, 28),
    BackgroundColor3 = C.card, BackgroundTransparency = 1, AutoButtonColor = false, Text = "", Parent = win })
round(closeBtn, 8)
local closeX = New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 14, 0, 14),
    BackgroundTransparency = 1, Parent = closeBtn })
local closeBars = {}
for i, r in ipairs({ 45, -45 }) do
    closeBars[i] = New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, 0, 0, 2),
        Rotation = r, BackgroundColor3 = C.dim, BorderSizePixel = 0, Parent = closeX })
    round(closeBars[i], 1)
end
local chip = New("Frame", { Position = UDim2.new(0, 20, 0, 70), Size = UDim2.new(0, 0, 0, 24), AutomaticSize = Enum.AutomaticSize.X,
    BackgroundColor3 = C.card, BorderSizePixel = 0, Parent = win })
round(chip, 12)
stroke(chip, C.low)
New("UIPadding", { PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 11), Parent = chip })
New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center,
    Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = chip })
local live = New("Frame", { Size = UDim2.fromOffset(6, 6), BackgroundColor3 = C.ok, BorderSizePixel = 0, LayoutOrder = 0, Parent = chip })
round(live, 3)
track(RunService.RenderStepped:Connect(function() live.BackgroundTransparency = 0.15 + (math.sin(os.clock() * 3) + 1) * 0.25 end))
icon(chip, "target", 12, C.dim).LayoutOrder = 1
New("TextLabel", { Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Text = entry.name,
    TextColor3 = C.text, FontFace = F.medium, TextSize = 11, LayoutOrder = 2, Parent = chip })
local box = New("Frame", { Position = UDim2.new(0, 20, 0, 106), Size = UDim2.new(1, -40, 0, 42), BackgroundColor3 = C.card,
    BorderSizePixel = 0, Parent = win })
round(box, 10)
local boxStroke = stroke(box, C.low)
local boxIcon = icon(box, "shield", 16, C.dim)
boxIcon.AnchorPoint, boxIcon.Position = Vector2.new(0, 0.5), UDim2.new(0, 13, 0.5, 0)
local input = New("TextBox", { Position = UDim2.new(0, 38, 0, 0), Size = UDim2.new(1, -76, 1, 0), BackgroundTransparency = 1,
    Text = "", PlaceholderText = T("Paste your Premium key"), PlaceholderColor3 = C.mute, TextColor3 = C.text, FontFace = F.medium,
    TextSize = 13, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = box })
local spinner = New("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -13, 0.5, 0), Size = UDim2.new(0, 16, 0, 16),
    BackgroundTransparency = 1, Visible = false, Parent = box })
New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = spinner })
local spinStroke = New("UIStroke", { Color = C.accent, Thickness = 2, Parent = spinner })
local spinGrad = New("UIGradient", { Parent = spinStroke, Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.55, 0.15), NumberSequenceKeypoint.new(0.56, 1), NumberSequenceKeypoint.new(1, 1) }) })
track(RunService.RenderStepped:Connect(function() if spinner.Visible then spinGrad.Rotation = (os.clock() * 420) % 360 end end))
local boxScale = New("UIScale", { Scale = 1, Parent = box })
local boxGlint = glintGrad(boxStroke, Color3.fromRGB(120, 110, 90))
boxGlint.Enabled = false
track(RunService.RenderStepped:Connect(function() if boxGlint.Enabled then boxGlint.Rotation = (os.clock() * 120) % 360 end end))
track(input.Focused:Connect(function()
    tween(boxStroke, { Color = Color3.new(1, 1, 1) }); tween(boxIcon, { ImageColor3 = C.accent })
    boxGlint.Enabled = true
    tween(boxScale, { Scale = 1.015 }, 0.3, Enum.EasingStyle.Back)
end))
track(input.FocusLost:Connect(function()
    tween(boxStroke, { Color = C.low }); tween(boxIcon, { ImageColor3 = C.dim })
    boxGlint.Enabled = false
    tween(boxScale, { Scale = 1 }, 0.25)
end))
track(input:GetPropertyChangedSignal("Text"):Connect(function()
    boxIcon.Size = UDim2.new(0, 19, 0, 19)
    tween(boxIcon, { Size = UDim2.new(0, 16, 0, 16) }, 0.3, Enum.EasingStyle.Back)
end))
local statusRow = New("Frame", { Position = UDim2.new(0, 22, 0, 158), Size = UDim2.new(1, -44, 0, 30), BackgroundTransparency = 1, Parent = win })
local statusDot = New("Frame", { Position = UDim2.new(0, 0, 0, 4), Size = UDim2.new(0, 6, 0, 6), BackgroundColor3 = C.mute,
    BorderSizePixel = 0, Parent = statusRow })
New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = statusDot })
local status = New("TextLabel", { Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(1, -14, 1, 0), BackgroundTransparency = 1,
    Text = T("Paste the Premium key you got on the Discord and press Verify."), TextColor3 = C.dim, FontFace = F.regular, TextSize = 11,
    TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Parent = statusRow })
local function setStatus(text, color)
    status.Text = text
    status.TextTransparency, status.Position = 1, UDim2.new(0, 14, 0, 5)
    tween(status, { TextTransparency = 0, Position = UDim2.new(0, 14, 0, 0) }, 0.3, Enum.EasingStyle.Quint)
    tween(status, { TextColor3 = color or C.dim })
    tween(statusDot, { BackgroundColor3 = color or C.mute })
    statusDot.Size = UDim2.new(0, 2, 0, 2)
    statusDot.Position = UDim2.new(0, 2, 0, 6)
    tween(statusDot, { Size = UDim2.new(0, 6, 0, 6), Position = UDim2.new(0, 0, 0, 4) }, 0.4, Enum.EasingStyle.Back)
    if color then
        local ring = New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 3, 0, 7), Size = UDim2.fromOffset(6, 6),
            BackgroundTransparency = 1, Parent = statusRow })
        round(ring, 10)
        local rs = New("UIStroke", { Color = color, Thickness = 1.5, Parent = ring })
        tween(ring, { Size = UDim2.fromOffset(20, 20) }, 0.6, Enum.EasingStyle.Quint)
        tween(rs, { Transparency = 1 }, 0.6)
        task.delay(0.65, function() ring:Destroy() end)
    end
end
if savedErr then setStatus(T("Saved key: ") .. savedErr, C.warn) end
local buyCard = New("Frame", { Position = UDim2.new(0, 20, 0, 194), Size = UDim2.new(1, -40, 0, 54), BackgroundColor3 = C.card,
    BorderSizePixel = 0, ClipsDescendants = true, Parent = win })
round(buyCard, 12)
local buyStroke = stroke(buyCard, Color3.new(1, 1, 1))
local buyGlint = New("UIGradient", { Parent = buyStroke, Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.accent:Lerp(C.deep, 0.6)), ColorSequenceKeypoint.new(0.42, C.accent:Lerp(C.deep, 0.6)),
    ColorSequenceKeypoint.new(0.5, C.accent), ColorSequenceKeypoint.new(0.58, C.accent:Lerp(C.deep, 0.6)),
    ColorSequenceKeypoint.new(1, C.accent:Lerp(C.deep, 0.6)) }) })
track(RunService.RenderStepped:Connect(function() buyGlint.Rotation = (os.clock() * 70) % 360 end))
local buyTile = New("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 12, 0.5, 0), Size = UDim2.new(0, 30, 0, 30),
    BackgroundColor3 = C.accent:Lerp(C.deep, 0.78), BorderSizePixel = 0, Parent = buyCard })
round(buyTile, 9)
local buyLogo = icon(buyTile, "logo", 18, C.accent)
buyLogo.AnchorPoint, buyLogo.Position = Vector2.new(0.5, 0.5), UDim2.new(0.5, 0, 0.5, 0)
New("TextLabel", { Position = UDim2.new(0, 52, 0, 9), Size = UDim2.new(1, -150, 0, 14), BackgroundTransparency = 1, Text = "PREMIUM",
    TextColor3 = C.accent, FontFace = F.bold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = buyCard })
New("TextLabel", { Position = UDim2.new(0, 52, 0, 24), Size = UDim2.new(1, -150, 0, 24), BackgroundTransparency = 1,
    Text = T("Don't have one? Get Premium for ") .. (IS_PT and CONFIG.price or CONFIG.priceEn) .. T(" on our Discord."),
    TextColor3 = C.text, FontFace = F.regular, TextSize = 10, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top, Parent = buyCard })
local buyBtn = New("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.new(0, 84, 0, 30),
    BackgroundColor3 = Color3.new(1, 1, 1), AutoButtonColor = false, Text = T("Buy"), TextColor3 = C.deep, FontFace = F.bold, TextSize = 12,
    ClipsDescendants = true, Parent = buyCard })
round(buyBtn, 8)
New("UIGradient", { Rotation = 90, Color = ColorSequence.new(C.accent, C.accentDeep), Parent = buyBtn })
local buyScale = New("UIScale", { Scale = 1, Parent = buyBtn })
track(buyBtn.MouseEnter:Connect(function() tween(buyScale, { Scale = 1.05 }, 0.25, Enum.EasingStyle.Back) end))
track(buyBtn.MouseLeave:Connect(function() tween(buyScale, { Scale = 1 }, 0.2) end))
local sheen = New("Frame", { Size = UDim2.new(0.35, 0, 1, 0), Position = UDim2.new(-0.4, 0, 0, 0), BackgroundColor3 = Color3.new(1, 1, 1),
    BackgroundTransparency = 0.88, BorderSizePixel = 0, ZIndex = 3, Parent = buyCard })
New("UIGradient", { Rotation = 20, Parent = sheen, Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) }) })
task.spawn(function()
    while buyCard.Parent do
        sheen.Position = UDim2.new(-0.4, 0, 0, 0)
        tween(sheen, { Position = UDim2.new(1.1, 0, 0, 0) }, 0.9, Enum.EasingStyle.Sine)
        task.wait(3)
    end
end)
local function pulseBuy()
    buyStroke.Thickness = 3
    tween(buyStroke, { Thickness = 1 }, 0.6, Enum.EasingStyle.Quad)
    buyTile.Rotation = -25
    tween(buyTile, { Rotation = 0 }, 0.8, Enum.EasingStyle.Elastic)
end
local row = New("Frame", { Position = UDim2.new(0, 20, 0, 260), Size = UDim2.new(1, -40, 0, 40), BackgroundTransparency = 1, Parent = win })
local verifyBtn = New("TextButton", { Size = UDim2.new(1, 0, 1, 0), AutoButtonColor = false, BackgroundColor3 = Color3.new(1, 1, 1),
    Text = "", ClipsDescendants = true, Parent = row })
round(verifyBtn, 10)
New("UIGradient", { Rotation = 90, Color = ColorSequence.new(C.accent, C.accentDeep), Parent = verifyBtn })
local vInner = New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 0, 0, 16),
    AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Parent = verifyBtn })
New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center,
    Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder, Parent = vInner })
local verifyIcon = icon(vInner, "play", 14, C.deep)
local verifyLbl = New("TextLabel", { Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1,
    Text = T("Verify"), TextColor3 = C.deep, FontFace = F.bold, TextSize = 13, LayoutOrder = 2, Parent = vInner })
local vScale = New("UIScale", { Scale = 1, Parent = verifyBtn })
local vHalo = New("UIStroke", { Color = C.accent, Thickness = 2, Transparency = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = verifyBtn })
track(verifyBtn.MouseEnter:Connect(function()
    tween(vScale, { Scale = 1.03 }, 0.25, Enum.EasingStyle.Back)
    tween(vInner, { Position = UDim2.new(0.5, 2, 0.5, 0) }, 0.25, Enum.EasingStyle.Back)
end))
track(verifyBtn.MouseLeave:Connect(function()
    tween(vScale, { Scale = 1 }, 0.2)
    tween(vInner, { Position = UDim2.new(0.5, 0, 0.5, 0) }, 0.25)
end))
track(verifyBtn.MouseButton1Down:Connect(function() tween(vScale, { Scale = 0.96 }, 0.08) end))
track(verifyBtn.MouseButton1Up:Connect(function() tween(vScale, { Scale = 1.03 }, 0.3, Enum.EasingStyle.Back) end))
local footer = New("TextLabel", { Position = UDim2.new(0, 20, 1, -24), Size = UDim2.new(1, -40, 0, 14), BackgroundTransparency = 1,
    Text = T("The key is saved on this device. Next time you go straight in."), TextColor3 = C.mute, FontFace = F.regular, TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left, Parent = win })
do
    local dragging, start, origin
    track(win.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, start, origin = true, i.Position, win.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end))
    track(UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - start
            win.Position = UDim2.new(origin.X.Scale, origin.X.Offset + d.X, origin.Y.Scale, origin.Y.Offset + d.Y)
        end
    end))
end
local blur = nil
pcall(function()
    blur = Instance.new("BlurEffect")
    blur.Name, blur.Size, blur.Parent = "OkumaPremiumBlur", 0, game:GetService("Lighting")
    tween(blur, { Size = 12 }, 0.4)
end)
tween(dim, { BackgroundTransparency = 0.45 }, 0.3)
tween(scale, { Scale = fit }, 0.45, Enum.EasingStyle.Back)
if not touchOnly then tween(win, { GroupTransparency = 0 }, 0.25) end
for i, o in ipairs({ tile, titleRow, subLbl, closeBtn, chip, box, statusRow, buyCard, row, footer }) do
    local p = o.Position
    o.Position = p + UDim2.fromOffset(0, 14)
    task.delay(0.04 * i, function() tween(o, { Position = p }, 0.55, Enum.EasingStyle.Quint) end)
end
task.delay(0.5, pulseBuy)
local finished = false
local function close(success)
    if finished then return end
    finished = true
    tween(dim, { BackgroundTransparency = 1 }, 0.25)
    if blur then tween(blur, { Size = 0 }, 0.25); task.delay(0.3, function() pcall(function() blur:Destroy() end) end) end
    tween(scale, { Scale = fit * (success and 1.06 or 0.92) }, 0.22, Enum.EasingStyle.Quad)
    if touchOnly then win.Visible = false else tween(win, { GroupTransparency = 1 }, 0.22) end
    task.delay(0.3, function()
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        gui:Destroy()
    end)
end
local function glintIn(color)
    glint.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, C.border), ColorSequenceKeypoint.new(0.38, C.border),
        ColorSequenceKeypoint.new(0.5, color), ColorSequenceKeypoint.new(0.62, C.border), ColorSequenceKeypoint.new(1, C.border) })
end
local function shake()
    local p = win.Position
    tween(boxStroke, { Color = C.err }, 0.1)
    glintIn(C.err)
    input.TextColor3 = C.err
    tween(input, { TextColor3 = C.text }, 0.8)
    task.delay(0.9, function() if not finished then glint.Color = GLINT end end)
    for _, dx in ipairs({ -10, 9, -7, 5, -3, 0 }) do
        tween(win, { Position = UDim2.new(p.X.Scale, p.X.Offset + dx, p.Y.Scale, p.Y.Offset) }, 0.05, Enum.EasingStyle.Sine)
        task.wait(0.05)
    end
    task.delay(0.6, function() tween(boxStroke, { Color = input:IsFocused() and Color3.new(1, 1, 1) or C.low }, 0.4) end)
end
local busy = false
track(RunService.RenderStepped:Connect(function()
    local want = not busy and not finished and #input.Text:gsub("%s", "") >= 6
    vHalo.Transparency = want and (0.45 + (math.sin(os.clock() * 4) + 1) * 0.25) or 1
end))
local function setBusy(on)
    busy = on
    spinner.Visible = on
    verifyLbl.Text = on and T("Checking") or T("Verify")
    if on then
        task.spawn(function()
            local n = 0
            while busy and not finished do
                n = n % 3 + 1
                verifyLbl.Text = T("Checking") .. string.rep(".", n)
                task.wait(0.3)
            end
        end)
    end
    tween(verifyBtn, { BackgroundTransparency = on and 0.35 or 0 })
end
local function verify()
    if busy or finished then return end
    local key = input.Text:match("^%s*(.-)%s*$")
    if key == "" then setStatus(T("Paste a key first."), C.warn); task.spawn(shake); return end
    setBusy(true)
    setStatus(T("Checking the key..."))
    local ok, why, kind = check(key)
    setBusy(false)
    if not ok then
        setStatus(why, kind == "free" and C.warn or C.err)
        if kind == "free" then pulseBuy() end
        shake()
        return
    end
    setStatus(T("Premium key accepted. Loading ") .. entry.name .. "...", C.ok)
    tween(boxStroke, { Color = C.ok }, 0.2)
    boxIcon.Image = "rbxthumb://type=Asset&id=" .. ICON.check .. "&w=150&h=150"
    tween(boxIcon, { ImageColor3 = C.ok }, 0.2)
    verifyLbl.Text = T("Verified")
    verifyIcon.Image = boxIcon.Image
    local ring = New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0, 127), Size = UDim2.new(0, W - 40, 0, 42),
        BackgroundTransparency = 1, Parent = win })
    round(ring, 12)
    local ringStroke = New("UIStroke", { Color = C.ok, Thickness = 2, Parent = ring })
    tween(ring, { Size = UDim2.new(0, W + 10, 0, 92) }, 0.6, Enum.EasingStyle.Quint)
    tween(ringStroke, { Transparency = 1 }, 0.6)
    glintIn(C.ok)
    boxIcon.Size = UDim2.fromOffset(6, 6)
    tween(boxIcon, { Size = UDim2.fromOffset(16, 16) }, 0.5, Enum.EasingStyle.Back)
    for i = 1, 18 do
        local sp = New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0, 127), Size = UDim2.fromOffset(4, 4),
            BackgroundColor3 = (i % 3 == 0) and C.text or C.ok, BorderSizePixel = 0, Rotation = math.random(0, 90), ZIndex = 4, Parent = win })
        round(sp, 1)
        local a = (i / 18) * math.pi * 2 + math.random() * 0.3
        local dist = math.random(60, 130)
        tween(sp, { Position = UDim2.new(0.5, math.cos(a) * dist, 0, 127 + math.sin(a) * dist * 0.55),
            BackgroundTransparency = 1, Rotation = sp.Rotation + 180, Size = UDim2.fromOffset(2, 2) }, 0.7, Enum.EasingStyle.Quint)
        task.delay(0.75, function() sp:Destroy() end)
    end
    saveKey(key)
    task.wait(0.8)
    close(true)
    launch(key)
end
track(verifyBtn.Activated:Connect(function() ripple(verifyBtn, C.deep); task.spawn(verify) end))
track(input.FocusLost:Connect(function(enter) if enter then task.spawn(verify) end end))
track(buyBtn.Activated:Connect(function()
    ripple(buyBtn, C.deep)
    if copyDiscord() then
        setStatus(T("Discord invite copied."), C.ok)
        buyBtn.Text = T("Copied")
        task.delay(1.4, function() if buyBtn.Parent then buyBtn.Text = T("Buy") end end)
    else
        input.Text = CONFIG.discord
        setStatus(T("Your executor can't copy: the invite is in the box above."), C.warn)
    end
end))
track(closeBtn.MouseEnter:Connect(function()
    tween(closeBtn, { BackgroundTransparency = 0 }); tween(closeX, { Rotation = 90 }, 0.3)
    for _, b in ipairs(closeBars) do tween(b, { BackgroundColor3 = C.text }) end
end))
track(closeBtn.MouseLeave:Connect(function()
    tween(closeBtn, { BackgroundTransparency = 1 }); tween(closeX, { Rotation = 0 }, 0.3)
    for _, b in ipairs(closeBars) do tween(b, { BackgroundColor3 = C.dim }) end
end))
track(closeBtn.Activated:Connect(function() close(false) end))
