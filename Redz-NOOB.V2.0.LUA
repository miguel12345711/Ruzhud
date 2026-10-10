--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║         Redz-Noob Menu Library — MOBILE (Samsung A06)        ║
    ║                        Version 1.0.1                         ║
    ║                    By: Redz-Noob Team                        ║
    ║                                                              ║
    ║  Otimizado para Samsung Galaxy A06 (720x1600, Android 14)   ║
    ║  Toques grandes, fontes legíveis, baixo uso de CPU.         ║
    ╚══════════════════════════════════════════════════════════════╝
--]]

if not game:IsLoaded() then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Redz-Noob",
        Text = "Aguardando o jogo carregar...",
        Duration = 3
    })
    game.Loaded:Wait()
end

--==============================================================
-- SERVIÇOS
--==============================================================
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local HS = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Detecção mobile
local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- Detecção de tela pequena (A06 tem 720px de largura)
local viewport = workspace.CurrentCamera.ViewportSize
local isSmallScreen = viewport.X <= 800

--==============================================================
-- GLOBAIS
--==============================================================
getgenv().RedzNoob = getgenv().RedzNoob or {}
getgenv().RedzNoob.Tabs = {}
getgenv().RedzNoob.FloatingButtons = {}
getgenv().RedzNoob.FloatingDraggers = {}
getgenv().RedzNoob.FloatingConns = {}
getgenv().RedzNoob.IsMobile = isMobile
getgenv().RedzNoob.IsSmallScreen = isSmallScreen

--==============================================================
-- UTILS
--==============================================================
local Utils = {}

function Utils.randomString(len)
    len = len or math.random(10, 20)
    local t = {}
    for i = 1, len do t[i] = string.char(math.random(32, 126)) end
    return table.concat(t)
end

function Utils.round(num, decimals)
    return tonumber(string.format("%." .. decimals .. "f", num))
end

function Utils.toBase64(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x)
        local r, b2 = '', x:byte()
        for i = 8, 1, -1 do r = r .. (b2 % 2^i - b2 % 2^(i-1) > 0 and '1' or '0') end
        return r
    end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if #x < 6 then return '' end
        local c = 0
        for i = 1, 6 do c = c + (x:sub(i,i) == '1' and 2^(6-i) or 0) end
        return b:sub(c+1, c+1)
    end) .. ({'', '==', '='})[#data % 3 + 1])
end

function Utils.fromBase64(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^' .. b .. '=]', '')
    return (data:gsub('.', function(x)
        if x == '=' then return '' end
        local r, f = '', (b:find(x) - 1)
        for i = 6, 1, -1 do r = r .. (f % 2^i - f % 2^(i-1) > 0 and '1' or '0') end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if #x ~= 8 then return '' end
        local c = 0
        for i = 1, 8 do c = c + (x:sub(i,i) == '1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

function Utils.serializeUDim2(v)
    if typeof(v) == "UDim2" then
        return string.format("%g,%g,%g,%g", v.X.Scale, v.X.Offset, v.Y.Scale, v.Y.Offset)
    elseif typeof(v) == "string" then
        local xs, xo, ys, yo = string.match(v, "([^,]+),([^,]+),([^,]+),([^,]+)")
        if not xs then return UDim2.new(0,0,0,0) end
        return UDim2.new(tonumber(xs), tonumber(xo), tonumber(ys), tonumber(yo))
    end
end

--==============================================================
-- POINTSAVE
--==============================================================
getgenv()._FOLDERS = getgenv()._FOLDERS or {}
getgenv()._FILES = getgenv()._FILES or {}

isfolder = isfolder or function(n) return getgenv()._FOLDERS[n] ~= nil end
makefolder = makefolder or function(n) getgenv()._FOLDERS[n] = {} return getgenv()._FOLDERS[n] end
isfile = isfile or function(n) return getgenv()._FILES[n] ~= nil end
writefile = writefile or function(n, c) getgenv()._FILES[n] = c return c end
readfile = readfile or function(n) return getgenv()._FILES[n] end
delfile = delfile or function(n) getgenv()._FILES[n] = nil end
listfiles = listfiles or function(folder)
    local out = {}
    for k in pairs(getgenv()._FILES) do
        if k:sub(1, #folder + 1) == folder .. "/" then
            table.insert(out, k:sub(#folder + 2))
        end
    end
    return out
end

local PointSave = {}
PointSave.__index = PointSave
local BASE_FOLDER = "RedzNoobData"

local function ensureBase()
    if not isfolder(BASE_FOLDER) then makefolder(BASE_FOLDER) end
end

function PointSave.new(namespace)
    ensureBase()
    local self = setmetatable({}, PointSave)
    self.namespace = namespace
    self.folderPath = BASE_FOLDER .. "/" .. namespace
    if not isfolder(self.folderPath) then makefolder(self.folderPath) end
    return self
end

function PointSave:set(key, value) writefile(self.folderPath .. "/" .. key .. ".txt", tostring(value)) end
function PointSave:get(key)
    local p = self.folderPath .. "/" .. key .. ".txt"
    if isfile(p) then return readfile(p) end
end
function PointSave:remove(key)
    local p = self.folderPath .. "/" .. key .. ".txt"
    if isfile(p) then delfile(p) end
end
function PointSave:clear()
    for _, f in ipairs(listfiles(self.folderPath)) do delfile(self.folderPath .. "/" .. f) end
end
function PointSave:listKeys() return listfiles(self.folderPath) end

local Save = PointSave.new("RedzNoob")

--==============================================================
-- DRAGGABLE OBJECT (otimizado para toque)
--==============================================================
local DraggableObject = {}
DraggableObject.__index = DraggableObject

function DraggableObject.new(object, toMove, smooth, callbackOnly)
    local self = setmetatable({}, DraggableObject)
    self.Object = object
    self.ToMove = toMove
    self.Smooth = smooth
    self.CallbackOnly = callbackOnly
    self.CanBeDragged = false
    self.Dragged = nil
    self.DragStarted = nil
    self.DragEnded = nil
    self.Dragging = false
    self.LastPosition = nil
    self.Velocity = Vector2.new(0, 0)
    return self
end

function DraggableObject:Enable()
    self.CanBeDragged = true
    local obj = self.Object
    local target = self.ToMove or self.Object
    local inputChanged, lastPos, currentPos, isDragging

    local function clampToScreen(pos)
        local parent = obj:FindFirstAncestorWhichIsA("ScreenGui")
        if not parent then return pos end
        local size = parent.AbsoluteSize
        local absX = pos.X.Scale * size.X + pos.X.Offset
        local absY = pos.Y.Scale * size.Y + pos.Y.Offset
        absX = math.clamp(absX, 0, size.X)
        absY = math.clamp(absY, 0, size.Y)
        return UDim2.new(pos.X.Scale, absX - pos.X.Scale * size.X, pos.Y.Scale, absY - pos.Y.Scale * size.Y)
    end

    self.InputBegan = obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
        end
    end)

    self.InputChanged = obj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            inputChanged = input
        end
    end)

    self.InputChanged2 = UIS.InputChanged:Connect(function(input)
        if obj.Parent == nil then self:Disable() return end
        if isDragging then
            isDragging = false
            if self.DragStarted then self.DragStarted() end
            self.Dragging = true
            lastPos = input.Position
            currentPos = target.Position
            self.LastPosition = input.Position
        end
        if input == inputChanged and self.Dragging then
            local delta = input.Position - lastPos
            local newPos = UDim2.new(
                currentPos.X.Scale, currentPos.X.Offset + delta.X,
                currentPos.Y.Scale, currentPos.Y.Offset + delta.Y
            )
            if not self.CallbackOnly then
                newPos = clampToScreen(newPos)
                -- Sem tween durante drag (mais leve para A06)
                if self.Smooth == true then
                    TS:Create(target, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), { Position = newPos }):Play()
                else
                    target.Position = newPos
                end
            end
            self.Velocity = input.Position - self.LastPosition
            self.LastPosition = input.Position
            if self.Dragged then self.Dragged(newPos) end
        end
    end)
end

function DraggableObject:Disable()
    self.CanBeDragged = false
    if self.InputBegan then self.InputBegan:Disconnect() end
    if self.InputChanged then self.InputChanged:Disconnect() end
    if self.InputChanged2 then self.InputChanged2:Disconnect() end
    if self.Dragging then
        self.Dragging = false
        if self.DragEnded then self.DragEnded(self.Velocity) end
    end
end

--==============================================================
-- CLICK AND HOLD
--==============================================================
local ClickAndHold = {}
ClickAndHold.__index = ClickAndHold

function ClickAndHold.new(textButton, holdTime)
    local self = setmetatable({}, ClickAndHold)
    self.textButton = textButton
    self.holdTime = holdTime or 0.8
    self.holdTask = nil
    self.initialPosition = nil
    self.Holded = Instance.new("BindableEvent")

    local function dist(a, b) return math.sqrt((b.X - a.X)^2 + (b.Y - a.Y)^2) end

    textButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            self.initialPosition = Vector2.new(input.Position.X, input.Position.Y)
            self.holdTask = task.spawn(function()
                task.wait(self.holdTime)
                if self.holdTask then self.Holded:Fire() end
            end)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            if self.holdTask and self.initialPosition then
                if dist(self.initialPosition, input.Position) > 15 then
                    coroutine.close(self.holdTask)
                    self.holdTask = nil
                end
            end
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            if self.holdTask then coroutine.close(self.holdTask) self.holdTask = nil end
            self.initialPosition = nil
        end
    end)
    return self
end

--==============================================================
-- NOTIFICAÇÕES (otimizadas)
--==============================================================
local notifIcons = {
    info = "rbxassetid://11780939099",
    x = "rbxassetid://10002373478",
    check = "rbxassetid://11604833061",
}
local notifHolder
local notifIncoming = false

local function Notify(msg, color, icon)
    if not notifHolder then return end
    notifIncoming = true
    task.spawn(function()
        local sample = notifHolder:FindFirstChild("NotificationSample")
        if not sample then return end
        local notif = sample:Clone()
        notif.Parent = notifHolder
        notif.Name = tostring(msg)
        notif.Position = UDim2.fromScale(0.5, -0.1)
        notif.UIScale.Scale = 0.7
        notif.Visible = true

        if color and typeof(color) == "Color3" then
            if notif:FindFirstChild("UIStroke") then notif.UIStroke.Color = color end
            if notif:FindFirstChild("ImageLabel") then notif.ImageLabel.ImageColor3 = color end
        end

        if icon then
            if notifIcons[icon] then notif.ImageLabel.Image = notifIcons[icon]
            elseif tonumber(icon) then notif.ImageLabel.Image = "rbxassetid://" .. tonumber(icon)
            else notif.ImageLabel.Image = icon end
        end

        notif.TextLabel.MaxVisibleGraphemes = 0
        notif.TextLabel.Text = tostring(msg)
        notif:SetAttribute("close", false)

        TS:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, 0, 0, 10)
        }):Play()
        TS:Create(notif.UIScale, TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
            Scale = 1
        }):Play()

        notif.Close.MouseButton1Click:Connect(function() notif:SetAttribute("close", true) end)

        task.wait()
        notifIncoming = false
        local lastClock = os.clock()
        repeat task.wait() until os.clock() - lastClock > 4 or notifIncoming or notif:GetAttribute("close")

        local finish = TS:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
            Position = UDim2.fromScale(0.5, -0.1)
        })
        finish:Play()
        finish.Completed:Connect(function() notif:Destroy() end)
    end)
end

--==============================================================
-- DIÁLOGO
--==============================================================
local dialogFrame, dialogEvent

local function DialogShow(title, desc, buttons)
    if not dialogFrame then return end
    dialogFrame.DialogTitle.Text = title
    dialogFrame.DialogDesc.Text = desc
    for _, v in ipairs(dialogFrame.Options:GetChildren()) do
        if v:IsA("TextButton") and v.Name ~= "OptionPlaceholder" then v:Destroy() end
    end
    for _, btnName in ipairs(buttons) do
        local newBtn = dialogFrame.Options.OptionPlaceholder:Clone()
        newBtn.Visible = true
        newBtn.Name = btnName
        newBtn.Text = btnName
        newBtn.Parent = dialogFrame.Options
        newBtn.MouseButton1Click:Connect(function() dialogEvent:Fire(newBtn.Name) end)
    end
    TS:Create(dialogFrame, TweenInfo.new(0.9, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(300, 160)
    }):Play()
    if dialogFrame:FindFirstChild("UIScale") then
        TS:Create(dialogFrame.UIScale, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
    end
end

local function DialogClose()
    if not dialogFrame then return end
    TS:Create(dialogFrame, TweenInfo.new(0.9, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(0, 160)
    }):Play()
    if dialogFrame:FindFirstChild("UIScale") then
        TS:Create(dialogFrame.UIScale, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 0 }):Play()
    end
end

local function DialogWait()
    if dialogEvent then return dialogEvent.Event:Wait() end
end

--==============================================================
-- THEME MANAGER
--==============================================================
local ThemeManager = {}
ThemeManager.colors = {
    textColor = Color3.fromRGB(255, 255, 255),
    accentColor = Color3.fromRGB(197, 0, 0),
    primaryColor = Color3.fromRGB(22, 22, 22),
    secondaryColor = Color3.fromRGB(12, 12, 12),
    backgroundColorCSQ = ColorSequence.new(Color3.fromRGB(36,36,36), Color3.fromRGB(68,68,68)),
}

local themeObjects = {
    textColor = {}, primaryColor = {}, secondaryColor = {},
    backgroundColorCSQ = {},
}

function ThemeManager.sortObjects(gui)
    for _, obj in ipairs(gui:GetDescendants()) do
        local themed = obj:FindFirstChild("themedColor")
        if themed then
            local v = themed.Value
            if v == "primaryColor" then table.insert(themeObjects.primaryColor, obj)
            elseif v == "secondaryColor" then table.insert(themeObjects.secondaryColor, obj)
            elseif v == "backgroundColorCSQ" then
                for _, c in ipairs(obj:GetChildren()) do
                    if c:IsA("UIGradient") then table.insert(themeObjects.backgroundColorCSQ, c) break end
                end
            end
        end
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            table.insert(themeObjects.textColor, obj)
        end
    end
end

function ThemeManager.updateColor(t, c)
    if t == "textColor" then
        for _, o in ipairs(themeObjects.textColor) do o.TextColor3 = c end
    elseif t == "primaryColor" then
        for _, o in ipairs(themeObjects.primaryColor) do
            local ok = pcall(function() o.Color = c end)
            if not ok then o.BackgroundColor3 = c end
        end
    elseif t == "secondaryColor" then
        for _, o in ipairs(themeObjects.secondaryColor) do
            local ok = pcall(function() o.Color = c end)
            if not ok then o.BackgroundColor3 = c end
        end
    elseif t == "backgroundColorCSQ" then
        for _, o in ipairs(themeObjects.backgroundColorCSQ) do o.Color = c end
    end
end

function ThemeManager.setColors(t)
    ThemeManager.colors = t
    getgenv().RedzNoob.Theme = t
end

function ThemeManager.init(root)
    for k in pairs(themeObjects) do themeObjects[k] = {} end
    ThemeManager.sortObjects(root)
    for k, c in pairs(ThemeManager.colors) do
        pcall(function() ThemeManager.updateColor(k, c) end)
    end
end

function ThemeManager.serialize(data)
    local function s(v)
        local t = typeof(v)
        if t == "number" or t == "string" or t == "boolean" then return v
        elseif t == "Color3" then
            return {__type="Color3", r=math.floor(v.R*255+0.5), g=math.floor(v.G*255+0.5), b=math.floor(v.B*255+0.5)}
        elseif t == "EnumItem" then
            return {__type="EnumItem", enumType=v.EnumType.Name, name=v.Name}
        elseif t == "ColorSequence" then
            local kp = {}
            for _, k in ipairs(v.Keypoints) do
                table.insert(kp, {t=k.Time, v={r=math.floor(k.Value.R*255+0.5), g=math.floor(k.Value.G*255+0.5), b=math.floor(k.Value.B*255+0.5)}})
            end
            return {__type="ColorSequence", keypoints=kp}
        elseif t == "table" then
            local out = {}
            for k, val in pairs(v) do
                if k ~= "font" then out[k] = s(val) end
            end
            return out
        end
        return nil
    end
    return s(data)
end

function ThemeManager.deserialize(data)
    local function d(v)
        if typeof(v) ~= "table" then return v end
        if v.__type == "Color3" then return Color3.fromRGB(v.r, v.g, v.b)
        elseif v.__type == "EnumItem" then
            local e = Enum[v.enumType]
            return e and e[v.name] or nil
        elseif v.__type == "ColorSequence" then
            local kps = {}
            for _, k in ipairs(v.keypoints) do
                table.insert(kps, ColorSequenceKeypoint.new(k.t, Color3.fromRGB(k.v.r, k.v.g, k.v.b)))
            end
            return ColorSequence.new(kps)
        else
            local out = {}
            for k, val in pairs(v) do out[k] = d(val) end
            return out
        end
    end
    return d(data)
end

--==============================================================
-- HELPERS UI
--==============================================================
local function makeFrame(props)
    local f = Instance.new("Frame")
    f.BorderSizePixel = 0
    for k, v in pairs(props or {}) do f[k] = v end
    return f
end

local function makeLabel(props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.BorderSizePixel = 0
    for k, v in pairs(props or {}) do l[k] = v end
    return l
end

local function makeButton(props)
    local b = Instance.new("TextButton")
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    for k, v in pairs(props or {}) do b[k] = v end
    return b
end

local function themedValue(parent, value)
    local v = Instance.new("StringValue")
    v.Name = "themedColor"
    v.Value = value
    v.Parent = parent
    return v
end

--==============================================================
-- CONSTRUÇÃO DO MENU (OTIMIZADO A06)
--==============================================================
local RedzRoot, mainWindow, tabList, contentArea, selectedTab, activeTabButton

local function buildUI()
    RedzRoot = Instance.new("ScreenGui")
    RedzRoot.Name = Utils.randomString()
    RedzRoot.IgnoreGuiInset = true
    RedzRoot.ResetOnSpawn = false
    RedzRoot.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    RedzRoot.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets

    pcall(function()
        if gethui then
            RedzRoot.Parent = gethui()
        elseif syn and syn.protect_gui then
            syn.protect_gui(RedzRoot)
            RedzRoot.Parent = CoreGui
        else
            RedzRoot.Parent = CoreGui
        end
    end)
    getgenv().RedzNoob.Root = RedzRoot

    -- Tamanho calculado com base na tela do A06 (720px largura)
    -- Menu ocupa ~90% da largura mas não ultrapassa 400px
    local winWidth = math.min(400, viewport.X - 40)
    local winHeight = math.min(340, viewport.Y * 0.55)

    mainWindow = makeFrame({
        Name = "MainWindow",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.fromScale(0.5, -0.6),
        Size = UDim2.fromOffset(winWidth, winHeight),
        BackgroundColor3 = ThemeManager.colors.primaryColor,
    })
    mainWindow.Parent = RedzRoot
    themedValue(mainWindow, "primaryColor")

    Instance.new("UICorner", mainWindow).CornerRadius = UDim.new(0, 14)

    local stroke = Instance.new("UIStroke", mainWindow)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 2

    local gradient = Instance.new("UIGradient", mainWindow)
    gradient.Color = ThemeManager.colors.backgroundColorCSQ
    gradient.Rotation = 68
    themedValue(mainWindow, "backgroundColorCSQ")

    -- HEADER (mais alto para facilitar arrastar com dedo)
    local header = makeFrame({
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1,
    })
    header.Parent = mainWindow

    local title = makeLabel({
        Name = "Title",
        Text = "Redz-Noob",
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = ThemeManager.colors.textColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
    })
    title.Parent = header
    themedValue(title, "textColor")

    local version = makeLabel({
        Name = "Version",
        Text = "A06 Ed.",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Color3.fromRGB(180, 180, 180),
        TextXAlignment = Enum.TextXAlignment.Right,
        Position = UDim2.new(0.4, 0, 0, 0),
        Size = UDim2.new(0.35, 0, 1, 0),
    })
    version.Parent = header

    -- Botões maiores (40x40) - ideais para dedo
    local minimizeBtn = makeButton({
        Name = "Minimize",
        Text = "—",
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = ThemeManager.colors.textColor,
        BackgroundColor3 = ThemeManager.colors.secondaryColor,
        Position = UDim2.new(1, -95, 0, 5),
        Size = UDim2.fromOffset(40, 38),
    })
    minimizeBtn.Parent = header
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 8)
    themedValue(minimizeBtn, "secondaryColor")

    local closeBtn = makeButton({
        Name = "Close",
        Text = "✕",
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = Color3.fromRGB(255, 100, 100),
        BackgroundColor3 = ThemeManager.colors.secondaryColor,
        Position = UDim2.new(1, -50, 0, 5),
        Size = UDim2.fromOffset(40, 38),
    })
    closeBtn.Parent = header
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    themedValue(closeBtn, "secondaryColor")

    closeBtn.MouseButton1Click:Connect(function() getgenv().RedzNoob:Unload() end)
    minimizeBtn.MouseButton1Click:Connect(function() getgenv().RedzNoob:Minimize() end)

    -- LISTA DE ABAS (mais larga no A06: 120px)
    local listWidth = 120

    tabList = makeFrame({
        Name = "TabList",
        Position = UDim2.new(0, 10, 0, 58),
        Size = UDim2.new(0, listWidth, 1, -70),
        BackgroundColor3 = ThemeManager.colors.secondaryColor,
    })
    tabList.Parent = mainWindow
    Instance.new("UICorner", tabList).CornerRadius = UDim.new(0, 12)
    themedValue(tabList, "secondaryColor")

    local tabScroll = Instance.new("ScrollingFrame")
    tabScroll.Name = "TabScroll"
    tabScroll.Size = UDim2.fromScale(1, 1)
    tabScroll.BackgroundTransparency = 1
    tabScroll.BorderSizePixel = 0
    tabScroll.ScrollBarThickness = 5
    tabScroll.ScrollBarImageColor3 = Color3.fromRGB(140, 140, 140)
    tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabScroll.Parent = tabList

    local tabLayout = Instance.new("UIListLayout", tabScroll)
    tabLayout.Padding = UDim.new(0, 6)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local tabPad = Instance.new("UIPadding", tabScroll)
    tabPad.PaddingTop = UDim.new(0, 10)
    tabPad.PaddingBottom = UDim.new(0, 10)
    tabPad.PaddingLeft = UDim.new(0, 4)
    tabPad.PaddingRight = UDim.new(0, 4)

    getgenv().RedzNoob.TabScroll = tabScroll

    -- ÁREA DE CONTEÚDO
    contentArea = makeFrame({
        Name = "Content",
        Position = UDim2.new(0, listWidth + 18, 0, 58),
        Size = UDim2.new(1, -(listWidth + 28), 1, -70),
        BackgroundTransparency = 1,
    })
    contentArea.Parent = mainWindow

    local contentScroll = Instance.new("ScrollingFrame")
    contentScroll.Name = "ContentScroll"
    contentScroll.Size = UDim2.fromScale(1, 1)
    contentScroll.BackgroundTransparency = 1
    contentScroll.BorderSizePixel = 0
    contentScroll.ScrollBarThickness = 5
    contentScroll.ScrollBarImageColor3 = Color3.fromRGB(140, 140, 140)
    contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentScroll.Parent = contentArea

    local contentLayout = Instance.new("UIListLayout", contentScroll)
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local contentPadding = Instance.new("UIPadding", contentScroll)
    contentPadding.PaddingRight = UDim.new(0, 8)
    contentPadding.PaddingBottom = UDim.new(0, 10)

    getgenv().RedzNoob.ContentScroll = contentScroll

    -- DRAG do menu pela header
    local drag = DraggableObject.new(header, mainWindow, false, true)
    drag:Enable()

    -- Animação de entrada
    TS:Create(mainWindow, TweenInfo.new(0.8, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
        Position = UDim2.fromScale(0.5, 0.05)
    }):Play()

    -- NOTIFICAÇÕES (largura total da tela)
    notifHolder = makeFrame({
        Name = "NotificationHolder",
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 0.98, 0),
        Size = UDim2.new(0.95, 0, 0.5, 0),
        BackgroundTransparency = 1,
    })
    notifHolder.Parent = RedzRoot
    local nhLayout = Instance.new("UIListLayout", notifHolder)
    nhLayout.Padding = UDim.new(0, 8)
    nhLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    nhLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    nhLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local sample = makeFrame({
        Name = "NotificationSample",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.fromScale(0.5, 0),
        Size = UDim2.new(1, -30, 0, 60),
        BackgroundColor3 = ThemeManager.colors.primaryColor,
        ClipsDescendants = true,
        Visible = false,
    })
    sample.Parent = notifHolder
    Instance.new("UICorner", sample).CornerRadius = UDim.new(0, 12)
    local sStroke = Instance.new("UIStroke", sample)
    sStroke.Color = Color3.fromRGB(255, 255, 255)
    sStroke.Thickness = 2
    local sGrad = Instance.new("UIGradient", sample)
    sGrad.Color = ColorSequence.new(Color3.fromRGB(46,46,46), Color3.fromRGB(12,12,12))
    themedValue(sample, "backgroundColorCSQ")

    local img = Instance.new("ImageLabel", sample)
    img.Name = "ImageLabel"
    img.Image = notifIcons.info
    img.ImageColor3 = Color3.fromRGB(255, 255, 255)
    img.BackgroundTransparency = 1
    img.AnchorPoint = Vector2.new(0.5, 0.5)
    img.Position = UDim2.new(0.12, 0, 0.5, 0)
    img.Size = UDim2.new(0.1, 0, 0.55, 0)

    local notifText = makeLabel({
        Name = "TextLabel",
        Text = "",
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        TextScaled = true,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0.55, 0, 0.6, 0),
    })
    notifText.Parent = sample
    themedValue(notifText, "textColor")

    local notifClose = Instance.new("ImageButton", sample)
    notifClose.Name = "Close"
    notifClose.Image = notifIcons.x
    notifClose.BackgroundTransparency = 1
    notifClose.AnchorPoint = Vector2.new(0.5, 0.5)
    notifClose.Position = UDim2.new(0.9, 0, 0.5, 0)
    notifClose.Size = UDim2.new(0.1, 0, 0.5, 0)

    -- DIÁLOGO
    dialogFrame = makeFrame({
        Name = "Dialog",
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 0.98, 0),
        Size = UDim2.fromOffset(0, 160),
        BackgroundColor3 = ThemeManager.colors.primaryColor,
        Visible = true,
        ZIndex = 5,
    })
    dialogFrame.Parent = RedzRoot
    Instance.new("UICorner", dialogFrame).CornerRadius = UDim.new(0, 14)
    local dStroke = Instance.new("UIStroke", dialogFrame)
    dStroke.Color = Color3.fromRGB(255, 255, 255)
    dStroke.Thickness = 2
    local dGrad = Instance.new("UIGradient", dialogFrame)
    dGrad.Color = ThemeManager.colors.backgroundColorCSQ
    dGrad.Rotation = -133
    local dPad = Instance.new("UIPadding", dialogFrame)
    dPad.PaddingTop = UDim.new(0, 15)
    dPad.PaddingBottom = UDim.new(0, 15)
    dPad.PaddingLeft = UDim.new(0, 15)
    dPad.PaddingRight = UDim.new(0, 15)
    local dScale = Instance.new("UIScale", dialogFrame)
    dScale.Scale = 0
    local dLayout = Instance.new("UIListLayout", dialogFrame)
    dLayout.Padding = UDim.new(0, 5)
    dLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local dialogTitle = makeLabel({
        Name = "DialogTitle",
        Text = "",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextXAlignment = Enum.TextXAlignment.Right,
        TextScaled = true,
        TextWrapped = true,
        Size = UDim2.new(1, 0, 0.15, 0),
    })
    dialogTitle.Parent = dialogFrame
    themedValue(dialogTitle, "textColor")

    local dialogDesc = makeLabel({
        Name = "DialogDesc",
        Text = "",
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextScaled = true,
        TextWrapped = true,
        Size = UDim2.new(1, 0, 0.6, 0),
    })
    dialogDesc.Parent = dialogFrame
    themedValue(dialogDesc, "textColor")

    local optionsHolder = makeFrame({
        Name = "Options",
        Position = UDim2.new(0, 0, 0.78, 0),
        Size = UDim2.new(1, 0, 0.28, 0),
        BackgroundTransparency = 1,
    })
    optionsHolder.Parent = dialogFrame
    local optLayout = Instance.new("UIListLayout", optionsHolder)
    optLayout.Padding = UDim.new(0, 10)
    optLayout.FillDirection = Enum.FillDirection.Horizontal
    optLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    optLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local optionPlaceholder = makeButton({
        Name = "OptionPlaceholder",
        Text = "",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextScaled = true,
        BackgroundColor3 = Color3.fromRGB(36, 36, 36),
        Size = UDim2.new(0.5, -5, 1, 0),
        Visible = false,
    })
    optionPlaceholder.Parent = optionsHolder
    Instance.new("UICorner", optionPlaceholder).CornerRadius = UDim.new(0, 10)
    local optStroke = Instance.new("UIStroke", optionPlaceholder)
    optStroke.Color = Color3.fromRGB(255, 255, 255)
    optStroke.Thickness = 2
    themedValue(optionPlaceholder, "primaryColor")

    dialogEvent = Instance.new("BindableEvent")
    dialogEvent.Name = "OnSelect"
    dialogEvent.Parent = dialogFrame

    -- BOTÃO MINIMIZADO (grande: 70x70 - ideal para dedo)
    local minimizedButton = makeButton({
        Name = "MinimizedBtn",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.05),
        Size = UDim2.fromOffset(70, 70),
        BackgroundColor3 = ThemeManager.colors.accentColor,
        Text = "R",
        Font = Enum.Font.GothamBold,
        TextSize = 28,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Visible = false,
        ZIndex = 10,
    })
    minimizedButton.Parent = RedzRoot
    Instance.new("UICorner", minimizedButton).CornerRadius = UDim.new(1, 0)
    local minStroke = Instance.new("UIStroke", minimizedButton)
    minStroke.Color = Color3.fromRGB(255, 255, 255)
    minStroke.Thickness = 2.5

    minimizedButton.MouseButton1Click:Connect(function()
        getgenv().RedzNoob:Open()
    end)

    local mbDrag = DraggableObject.new(minimizedButton)
    mbDrag:Enable()
    mbDrag.Dragged = function(pos)
        Save:set("MinBtnPos", Utils.serializeUDim2(pos))
    end

    getgenv().RedzNoob.MinBtn = minimizedButton
end

--==============================================================
-- CONTROLE DE JANELA
--==============================================================
local function openMenu()
    if not mainWindow then return end
    mainWindow.Visible = true
    getgenv().RedzNoob.MinBtn.Visible = false
    TS:Create(mainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.fromScale(0.5, 0.05),
    }):Play()
end

local function minimizeMenu()
    if not mainWindow then return end
    local lastPos = Save:get("MinBtnPos")
    local minBtn = getgenv().RedzNoob.MinBtn
    if lastPos then pcall(function() minBtn.Position = Utils.serializeUDim2(lastPos) end) end
    mainWindow.Visible = false
    minBtn.Visible = true
    minBtn.Size = UDim2.fromOffset(0, 0)
    TS:Create(minBtn, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(70, 70)
    }):Play()
end

local function unloadMenu()
    if RedzRoot then
        TS:Create(mainWindow, TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
            Position = UDim2.fromScale(0.5, -0.6)
        }):Play()
        task.wait(0.4)
        RedzRoot:Destroy()
    end
    getgenv().RedzNoob.Tabs = {}
    getgenv().RedzNoob.Root = nil
end

--==============================================================
-- CLASSE TAB (botões de aba grandes: 45px)
--==============================================================
local Tab = {}
Tab.__index = Tab

function Tab.new(name)
    local self = setmetatable({}, Tab)
    self.Name = name
    self.Elements = {}
    self.Button = nil

    local btn = makeButton({
        Name = name .. "Btn",
        Text = name,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = ThemeManager.colors.textColor,
        BackgroundColor3 = ThemeManager.colors.primaryColor,
        Size = UDim2.new(1, 0, 0, 45),
        TextWrapped = true,
    })
    btn.Parent = getgenv().RedzNoob.TabScroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    themedValue(btn, "primaryColor")

    self.Button = btn

    btn.MouseButton1Click:Connect(function() self:Select() end)

    table.insert(getgenv().RedzNoob.Tabs, self)

    if #getgenv().RedzNoob.Tabs == 1 then
        task.defer(function() self:Select() end)
    end

    return self
end

function Tab:Select()
    if activeTabButton and activeTabButton.Button then
        TS:Create(activeTabButton.Button, TweenInfo.new(0.25), {
            BackgroundColor3 = ThemeManager.colors.primaryColor
        }):Play()
    end
    activeTabButton = self
    selectedTab = self
    TS:Create(self.Button, TweenInfo.new(0.25), {
        BackgroundColor3 = ThemeManager.colors.accentColor
    }):Play()
    self:Refresh()
end

function Tab:Refresh()
    local scroll = getgenv().RedzNoob.ContentScroll
    if not scroll then return end
    for _, v in ipairs(scroll:GetChildren()) do
        if not v:IsA("UIListLayout") and not v:IsA("UIPadding") then
            v:Destroy()
        end
    end
    for _, el in ipairs(self.Elements) do
        if el.Builder then
            pcall(el.Builder, scroll)
        end
    end
end

function Tab:Clear()
    self.Elements = {}
    self:Refresh()
end

--==============================================================
-- ELEMENTOS DA TAB (todos maiores para A06)
--==============================================================

function Tab:AddText(text, align)
    local builder = function(parent)
        local lbl = makeLabel({
            Text = text,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = ThemeManager.colors.textColor,
            TextWrapped = true,
            TextXAlignment = align == "center" and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
        })
        lbl.Parent = parent
        themedValue(lbl, "textColor")
    end
    table.insert(self.Elements, {Builder = builder, Type = "Text"})
    if selectedTab == self then builder(getgenv().RedzNoob.ContentScroll) end
end

function Tab:AddSection(text)
    return self:AddText("─── " .. text .. " ───", "center")
end

function Tab:AddLabel(text)
    return self:AddText(text)
end

function Tab:AddButton(text, callback)
    local builder = function(parent)
        local btn = makeButton({
            Text = text,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = ThemeManager.colors.textColor,
            BackgroundColor3 = ThemeManager.colors.primaryColor,
            Size = UDim2.new(1, 0, 0, 45),
            TextWrapped = true,
        })
        btn.Parent = parent
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
        local pad = Instance.new("UIPadding", btn)
        pad.PaddingLeft = UDim.new(0, 12)
        pad.PaddingRight = UDim.new(0, 12)
        themedValue(btn, "primaryColor")

        btn.MouseButton1Click:Connect(function()
            if callback then
                local ok, err = pcall(callback)
                if not ok then warn("[Redz-Noob] Erro:", err) end
            end
        end)

        -- Hold 1s para criar botão flutuante (mobile)
        local hold = ClickAndHold.new(btn, 1.0)
        hold.Holded.Event:Connect(function()
            Notify("Botão flutuante criado: " .. text, Color3.fromRGB(0, 200, 100), "check")
            getgenv().RedzNoob:CreateFloatingButton(text, {
                Text = text,
                Color = ThemeManager.colors.primaryColor,
            }, callback)
        end)
    end
    table.insert(self.Elements, {Builder = builder, Type = "Button"})
    if selectedTab == self then builder(getgenv().RedzNoob.ContentScroll) end
end

function Tab:AddToggle(text, default, callback)
    local state = default or false
    local setState
    local builder = function(parent)
        local container = makeFrame({
            Size = UDim2.new(1, 0, 0, 45),
            BackgroundTransparency = 1,
        })
        container.Parent = parent

        local lbl = makeLabel({
            Text = text,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = ThemeManager.colors.textColor,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Size = UDim2.new(0.6, 0, 1, 0),
        })
        lbl.Parent = container
        themedValue(lbl, "textColor")

        local switchBg = makeFrame({
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.fromOffset(60, 32),
            BackgroundColor3 = state and ThemeManager.colors.accentColor or Color3.fromRGB(60, 60, 60),
        })
        switchBg.Parent = container
        Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)

        local knob = makeFrame({
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = state and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 16, 0.5, 0),
            Size = UDim2.fromOffset(26, 26),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            ZIndex = 2,
        })
        knob.Parent = switchBg
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local clickBtn = makeButton({
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = 3,
        })
        clickBtn.Parent = container

        setState = function(newState, fire)
            state = newState
            TS:Create(switchBg, TweenInfo.new(0.2), {
                BackgroundColor3 = state and ThemeManager.colors.accentColor or Color3.fromRGB(60, 60, 60)
            }):Play()
            TS:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = state and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 16, 0.5, 0)
            }):Play()
            if fire and callback then pcall(callback, state) end
        end

        clickBtn.MouseButton1Click:Connect(function() setState(not state, true) end)
    end
    table.insert(self.Elements, {Builder = builder, Type = "Toggle"})
    if selectedTab == self then builder(getgenv().RedzNoob.ContentScroll) end
    return {
        SetValue = function(v) if setState then setState(v, false) end end,
        GetValue = function() return state end,
    }
end

function Tab:AddSlider(text, min, max, default, callback)
    min = min or 0
    max = max or 100
    default = default or min
    local value = default
    local builder = function(parent)
        local container = makeFrame({
            Size = UDim2.new(1, 0, 0, 75),
            BackgroundTransparency = 1,
        })
        container.Parent = parent

        local lbl = makeLabel({
            Text = text,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = ThemeManager.colors.textColor,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(0.7, 0, 0, 22),
        })
        lbl.Parent = container
        themedValue(lbl, "textColor")

        local valueLbl = makeLabel({
            Text = tostring(value),
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = ThemeManager.colors.accentColor,
            TextXAlignment = Enum.TextXAlignment.Right,
            Size = UDim2.new(0.3, 0, 0, 22),
            Position = UDim2.new(0.7, 0, 0, 0),
        })
        valueLbl.Parent = container

        -- Track mais grosso
        local track = makeFrame({
            Position = UDim2.new(0, 0, 0, 48),
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        })
        track.Parent = container
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

        local fill = makeFrame({
            Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
            BackgroundColor3 = ThemeManager.colors.accentColor,
        })
        fill.Parent = track
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

        -- Knob visível de 26px
        local knob = makeFrame({
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
            Size = UDim2.fromOffset(26, 26),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            ZIndex = 2,
        })
        knob.Parent = track
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local clickArea = makeButton({
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = 5,
        })
        clickArea.Parent = track

        local dragging = false
        local function updateFromX(x)
            local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            value = math.floor(min + (max - min) * rel + 0.5)
            valueLbl.Text = tostring(value)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, 0, 0.5, 0)
            if callback then pcall(callback, value) end
        end

        clickArea.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                updateFromX(input.Position.X)
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseMovement) then
                updateFromX(input.Position.X)
            end
        end)
        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end
    table.insert(self.Elements, {Builder = builder, Type = "Slider"})
    if selectedTab == self then builder(getgenv().RedzNoob.ContentScroll) end
    return {
        SetValue = function(v) value = math.clamp(v, min, max) end,
        GetValue = function() return value end,
    }
end

function Tab:AddInput(label, placeholder, callback)
    local builder = function(parent)
        local container = makeFrame({
            Size = UDim2.new(1, 0, 0, 90),
            BackgroundTransparency = 1,
        })
        container.Parent = parent

        local box = Instance.new("TextBox")
        box.PlaceholderText = placeholder or "Digite aqui..."
        box.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
        box.Text = ""
        box.Font = Enum.Font.Gotham
        box.TextSize = 14
        box.TextColor3 = ThemeManager.colors.textColor
        box.BackgroundColor3 = ThemeManager.colors.primaryColor
        box.BorderSizePixel = 0
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.Size = UDim2.new(1, 0, 0, 45)
        box.ClearTextOnFocus = false
        box.Parent = container
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 10)
        local bp = Instance.new("UIPadding", box)
        bp.PaddingLeft = UDim.new(0, 12)
        bp.PaddingRight = UDim.new(0, 12)
        themedValue(box, "primaryColor")

        local btn = makeButton({
            Text = label,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = ThemeManager.colors.textColor,
            BackgroundColor3 = ThemeManager.colors.accentColor,
            Position = UDim2.new(0, 0, 0, 52),
            Size = UDim2.new(1, 0, 0, 38),
        })
        btn.Parent = container
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

        btn.MouseButton1Click:Connect(function()
            if callback then pcall(callback, box.Text) end
        end)
    end
    table.insert(self.Elements, {Builder = builder, Type = "Input"})
    if selectedTab == self then builder(getgenv().RedzNoob.ContentScroll) end
end

function Tab:AddDropdown(label, options, callback)
    local currentValue
    local builder = function(parent)
        local container = makeFrame({
            Size = UDim2.new(1, 0, 0, 90),
            BackgroundTransparency = 1,
        })
        container.Parent = parent

        local lbl = makeLabel({
            Text = label,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = ThemeManager.colors.textColor,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, 0, 0, 22),
        })
        lbl.Parent = container
        themedValue(lbl, "textColor")

        local ddBtn = makeButton({
            Text = "Selecionar...",
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = ThemeManager.colors.textColor,
            BackgroundColor3 = ThemeManager.colors.primaryColor,
            Position = UDim2.new(0, 0, 0, 28),
            Size = UDim2.new(1, 0, 0, 45),
        })
        ddBtn.Parent = container
        Instance.new("UICorner", ddBtn).CornerRadius = UDim.new(0, 10)
        themedValue(ddBtn, "primaryColor")

        ddBtn.MouseButton1Click:Connect(function()
            local opts = typeof(options) == "function" and options() or options
            if not opts or #opts == 0 then
                Notify("Sem opções disponíveis.", Color3.fromRGB(255, 100, 100), "x")
                return
            end
            local popup = makeFrame({
                Position = UDim2.new(0, 0, 1, 4),
                Size = UDim2.new(1, 0, 0, 50 * #opts + 12),
                BackgroundColor3 = ThemeManager.colors.secondaryColor,
                ZIndex = 100,
            })
            popup.Parent = container
            Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 12)
            local pl = Instance.new("UIListLayout", popup)
            pl.Padding = UDim.new(0, 4)
            pl.SortOrder = Enum.SortOrder.LayoutOrder
            local pp = Instance.new("UIPadding", popup)
            pp.PaddingTop = UDim.new(0, 6)
            pp.PaddingBottom = UDim.new(0, 6)
            pp.PaddingLeft = UDim.new(0, 6)
            pp.PaddingRight = UDim.new(0, 6)

            for _, opt in ipairs(opts) do
                local oBtn = makeButton({
                    Text = tostring(opt),
                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    TextColor3 = ThemeManager.colors.textColor,
                    BackgroundColor3 = ThemeManager.colors.primaryColor,
                    Size = UDim2.new(1, 0, 0, 45),
                })
                oBtn.Parent = popup
                Instance.new("UICorner", oBtn).CornerRadius = UDim.new(0, 10)
                oBtn.MouseButton1Click:Connect(function()
                    currentValue = opt
                    ddBtn.Text = tostring(opt)
                    popup:Destroy()
                    if callback then pcall(callback, opt) end
                end)
            end

            -- Fecha ao tocar fora
            task.delay(0.1, function()
                local conn
                conn = UIS.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch
                    or input.UserInputType == Enum.UserInputType.MouseButton1 then
                        task.wait(0.05)
                        if popup and popup.Parent then popup:Destroy() end
                        conn:Disconnect()
                    end
                end)
            end)
        end)
    end
    table.insert(self.Elements, {Builder = builder, Type = "Dropdown"})
    if selectedTab == self then builder(getgenv().RedzNoob.ContentScroll) end
    return { GetValue = function() return currentValue end }
end

function Tab:AddButtonGrid(columns, buttons, options)
    options = options or {}
    local toggleable = options.Toggleable or false
    local states = {}
    local builder = function(parent)
        local grid = Instance.new("Frame")
        grid.Size = UDim2.new(1, 0, 0, 0)
        grid.AutomaticSize = Enum.AutomaticSize.Y
        grid.BackgroundTransparency = 1
        grid.Parent = parent

        local gl = Instance.new("UIGridLayout", grid)
        gl.CellSize = UDim2.new((1 / columns) - 0.02, 0, 0, 45)
        gl.CellPadding = UDim2.new(0.01, 0, 0, 8)
        gl.SortOrder = Enum.SortOrder.LayoutOrder

        for btnName, btnCallback in pairs(buttons) do
            if states[btnName] == nil then states[btnName] = false end
            local b = makeButton({
                Text = string.gsub(btnName, "_", " "),
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextColor3 = ThemeManager.colors.textColor,
                BackgroundColor3 = states[btnName] and ThemeManager.colors.accentColor or ThemeManager.colors.primaryColor,
                TextWrapped = true,
            })
            b.Parent = grid
            Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
            themedValue(b, "primaryColor")

            b.MouseButton1Click:Connect(function()
                if btnCallback then pcall(btnCallback, b) end
                if toggleable then
                    states[btnName] = not states[btnName]
                    TS:Create(b, TweenInfo.new(0.2), {
                        BackgroundColor3 = states[btnName] and ThemeManager.colors.accentColor or ThemeManager.colors.primaryColor
                    }):Play()
                end
            end)

            local hold = ClickAndHold.new(b, 1.0)
            hold.Holded.Event:Connect(function()
                getgenv().RedzNoob:CreateFloatingButton(btnName, {
                    Text = string.gsub(btnName, "_", " "),
                    Color = ThemeManager.colors.primaryColor,
                }, btnCallback)
            end)
        end
    end
    table.insert(self.Elements, {Builder = builder, Type = "ButtonGrid"})
    if selectedTab == self then builder(getgenv().RedzNoob.ContentScroll) end
end

function Tab:AddColorPicker(label, default, callback)
    local current = default or Color3.fromRGB(255, 255, 255)
    local builder = function(parent)
        local container = makeFrame({
            Size = UDim2.new(1, 0, 0, 45),
            BackgroundTransparency = 1,
        })
        container.Parent = parent

        local lbl = makeLabel({
            Text = label,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = ThemeManager.colors.textColor,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(0.7, 0, 1, 0),
        })
        lbl.Parent = container
        themedValue(lbl, "textColor")

        local preview = makeButton({
            Text = "",
            BackgroundColor3 = current,
            Position = UDim2.new(0.75, 0, 0.15, 0),
            Size = UDim2.new(0.25, -4, 0.7, 0),
        })
        preview.Parent = container
        Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 8)

        preview.MouseButton1Click:Connect(function()
            local popup = makeFrame({
                Position = UDim2.new(0, 0, 1, 4),
                Size = UDim2.new(1, 0, 0, 200),
                BackgroundColor3 = ThemeManager.colors.secondaryColor,
                ZIndex = 100,
            })
            popup.Parent = container
            Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 12)
            local pPad = Instance.new("UIPadding", popup)
            pPad.PaddingTop = UDim.new(0, 8)
            pPad.PaddingBottom = UDim.new(0, 8)
            pPad.PaddingLeft = UDim.new(0, 8)
            pPad.PaddingRight = UDim.new(0, 8)

            local cols = {"R", "G", "B"}
            local vals = {current.R, current.G, current.B}

            local function apply()
                current = Color3.new(vals[1], vals[2], vals[3])
                preview.BackgroundColor3 = current
                if callback then pcall(callback, current) end
            end

            for i, cn in ipairs(cols) do
                local lblR = makeLabel({
                    Text = cn,
                    Font = Enum.Font.GothamBold,
                    TextSize = 14,
                    TextColor3 = ThemeManager.colors.textColor,
                    Position = UDim2.new(0, 0, 0, (i-1) * 60 + 5),
                    Size = UDim2.new(0.1, 0, 0, 40),
                })
                lblR.Parent = popup

                local bar = makeFrame({
                    Position = UDim2.new(0.12, 0, 0, (i-1) * 60 + 12),
                    Size = UDim2.new(0.85, 0, 0, 26),
                    BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                })
                bar.Parent = popup
                Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

                local fill = makeFrame({
                    Size = UDim2.new(vals[i], 0, 1, 0),
                    BackgroundColor3 = Color3.fromRGB(vals[i]*255, vals[i]*255, vals[i]*255),
                })
                fill.Parent = bar
                Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

                local click = makeButton({
                    Size = UDim2.fromScale(1, 1),
                    BackgroundTransparency = 1,
                    Text = "",
                })
                click.Parent = bar

                local dragging = false
                click.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch
                    or input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)
                UIS.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.Touch
                    or input.UserInputType == Enum.UserInputType.MouseMovement) then
                        local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                        vals[i] = rel
                        fill.Size = UDim2.new(rel, 0, 1, 0)
                        fill.BackgroundColor3 = Color3.fromRGB(rel*255, rel*255, rel*255)
                        apply()
                    end
                end)
                UIS.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch
                    or input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
            end

            task.delay(0.1, function()
                local conn
                conn = UIS.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch
                    or input.UserInputType == Enum.UserInputType.MouseButton1 then
                        task.wait(0.05)
                        if popup and popup.Parent then popup:Destroy() end
                        conn:Disconnect()
                    end
                end)
            end)
        end)
    end
    table.insert(self.Elements, {Builder = builder, Type = "ColorPicker"})
    if selectedTab == self then builder(getgenv().RedzNoob.ContentScroll) end
    return {
        SetValue = function(c) current = c end,
        GetValue = function() return current end,
    }
end

function Tab:AddKeybind(label, defaultKey, callback)
    local current = defaultKey or Enum.KeyCode.F
    local capturing = false
    local keyBtn
    local builder = function(parent)
        local container = makeFrame({
            Size = UDim2.new(1, 0, 0, 45),
            BackgroundTransparency = 1,
        })
        container.Parent = parent

        local lbl = makeLabel({
            Text = label,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextColor3 = ThemeManager.colors.textColor,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Size = UDim2.new(0.6, 0, 1, 0),
        })
        lbl.Parent = container
        themedValue(lbl, "textColor")

        keyBtn = makeButton({
            Text = current.Name,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = ThemeManager.colors.textColor,
            BackgroundColor3 = ThemeManager.colors.primaryColor,
            Position = UDim2.new(0.6, 4, 0, 0),
            Size = UDim2.new(0.4, -4, 1, 0),
        })
        keyBtn.Parent = container
        Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 10)
        themedValue(keyBtn, "primaryColor")

        keyBtn.MouseButton1Click:Connect(function()
            capturing = true
            keyBtn.Text = "..."
        end)
    end

    UIS.InputBegan:Connect(function(input)
        if not capturing then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            current = input.KeyCode
            if keyBtn then keyBtn.Text = current.Name end
            capturing = false
            if callback then pcall(callback, current) end
        end
    end)

    table.insert(self.Elements, {Builder = builder, Type = "Keybind"})
    if selectedTab == self then builder(getgenv().RedzNoob.ContentScroll) end
    return {
        SetValue = function(k) current = k if keyBtn then keyBtn.Text = k.Name end end,
        GetValue = function() return current end,
    }
end

--==============================================================
-- BOTÕES FLUTUANTES (tamanho grande para A06)
--==============================================================
function getgenv().RedzNoob:CreateFloatingButton(name, options, callback)
    if not RedzRoot then return end
    local cleanName = string.gsub(name, "[^%w]", "_")
    if self.FloatingButtons[cleanName] then
        Notify("Botão já existe: " .. name, Color3.fromRGB(255, 200, 0), "info")
        return
    end

    options = options or {}

    local btn = makeButton({
        Name = cleanName,
        Text = options.Text or name,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundColor3 = options.Color or ThemeManager.colors.primaryColor,
        Position = options.Position or UDim2.fromOffset(20, 100),
        Size = options.Size or UDim2.fromOffset(140, 60),
        TextWrapped = true,
        AutoButtonColor = false,
    })
    btn.Parent = RedzRoot
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 14)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 2.5
    local scale = Instance.new("UIScale", btn)
    scale.Scale = 0
    themedValue(btn, "primaryColor")

    local lock = makeLabel({
        Name = "Lock",
        Text = "🔒",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -8, 1, -8),
        Size = UDim2.fromOffset(22, 22),
        TextTransparency = 1,
        ZIndex = 999,
    })
    lock.Parent = btn

    TS:Create(scale, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Scale = 1
    }):Play()

    local saved = Save:get("FB_" .. cleanName)
    if saved then
        pcall(function()
            local parts = string.split(saved, "|")
            btn.Position = Utils.serializeUDim2(parts[1])
            btn.Size = Utils.serializeUDim2(parts[2])
            btn.Visible = parts[3] == "true"
        end)
    end

    local dragger = DraggableObject.new(btn, nil, false, true)
    dragger:Enable()
    dragger.Dragged = function(pos)
        Save:set("FB_" .. cleanName, Utils.serializeUDim2(pos) .. "|" .. Utils.serializeUDim2(btn.Size) .. "|" .. tostring(btn.Visible))
    end
    self.FloatingDraggers[cleanName] = dragger

    btn.MouseButton1Click:Connect(function()
        if callback then pcall(callback) end
    end)

    -- Hold 1.2s = popup de opções
    local hold = ClickAndHold.new(btn, 1.2)
    hold.Holded.Event:Connect(function()
        local popup = makeFrame({
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(260, 200),
            BackgroundColor3 = ThemeManager.colors.secondaryColor,
            ZIndex = 200,
        })
        popup.Parent = RedzRoot
        Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 14)
        local pStroke = Instance.new("UIStroke", popup)
        pStroke.Color = Color3.fromRGB(255, 255, 255)
        pStroke.Thickness = 2
        local pl = Instance.new("UIListLayout", popup)
        pl.Padding = UDim.new(0, 6)
        pl.SortOrder = Enum.SortOrder.LayoutOrder
        pl.HorizontalAlignment = Enum.HorizontalAlignment.Center
        local pp = Instance.new("UIPadding", popup)
        pp.PaddingTop = UDim.new(0, 10)
        pp.PaddingBottom = UDim.new(0, 10)
        pp.PaddingLeft = UDim.new(0, 10)
        pp.PaddingRight = UDim.new(0, 10)

        local title = makeLabel({
            Text = "Opções: " .. name,
            Font = Enum.Font.GothamBold,
            TextSize = 15,
            TextColor3 = ThemeManager.colors.textColor,
            Size = UDim2.new(1, 0, 0, 30),
        })
        title.Parent = popup
        themedValue(title, "textColor")

        local function optBtn(text, cb)
            local ob = makeButton({
                Text = text,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextColor3 = ThemeManager.colors.textColor,
                BackgroundColor3 = ThemeManager.colors.primaryColor,
                Size = UDim2.new(1, 0, 0, 40),
            })
            ob.Parent = popup
            Instance.new("UICorner", ob).CornerRadius = UDim.new(1, 0)
            themedValue(ob, "primaryColor")
            ob.MouseButton1Click:Connect(function()
                popup:Destroy()
                cb()
            end)
        end

        optBtn("Ocultar/Mostrar", function()
            btn.Visible = not btn.Visible
            Save:set("FB_" .. cleanName, Utils.serializeUDim2(btn.Position) .. "|" .. Utils.serializeUDim2(btn.Size) .. "|" .. tostring(btn.Visible))
        end)
        optBtn("Remover", function()
            getgenv().RedzNoob:RemoveFloatingButton(name)
        end)
        optBtn("Fechar", function() end)
    end)

    self.FloatingButtons[cleanName] = btn
    return btn
end

function getgenv().RedzNoob:RemoveFloatingButton(name)
    local cleanName = string.gsub(name, "[^%w]", "_")
    local btn = self.FloatingButtons[cleanName]
    if not btn then return end
    if self.FloatingDraggers[cleanName] then
        self.FloatingDraggers[cleanName]:Disable()
        self.FloatingDraggers[cleanName] = nil
    end
    if self.FloatingConns[cleanName] then
        self.FloatingConns[cleanName]:Disconnect()
        self.FloatingConns[cleanName] = nil
    end
    TS:Create(btn, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
        Size = UDim2.fromOffset(0, 0)
    }):Play()
    task.wait(0.3)
    btn:Destroy()
    self.FloatingButtons[cleanName] = nil
    Save:remove("FB_" .. cleanName)
end

function getgenv().RedzNoob:ClearFloatingButtons()
    for name in pairs(self.FloatingButtons) do
        self:RemoveFloatingButton(name)
    end
end

function getgenv().RedzNoob:ListFloatingButtons()
    local out = {}
    for name in pairs(self.FloatingButtons) do
        table.insert(out, name)
    end
    return out
end

--==============================================================
-- API PÚBLICA
--==============================================================
function getgenv().RedzNoob:Init(settings)
    settings = settings or {}
    RedzRoot, mainWindow, tabList, contentArea = nil, nil, nil, nil
    selectedTab, activeTabButton = nil, nil
    self.Tabs = {}

    buildUI()
    ThemeManager.init(RedzRoot)

    if isMobile then
        -- Botão "R" no canto superior esquerdo (arrastável)
        local openBtn = makeButton({
            Name = "OpenBtn",
            AnchorPoint = Vector2.new(0, 0),
            Position = UDim2.fromOffset(15, 80),
            Size = UDim2.fromOffset(65, 65),
            BackgroundColor3 = ThemeManager.colors.accentColor,
            Text = "R",
            Font = Enum.Font.GothamBold,
            TextSize = 26,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            ZIndex = 20,
        })
        openBtn.Parent = RedzRoot
        Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)
        local obStroke = Instance.new("UIStroke", openBtn)
        obStroke.Color = Color3.fromRGB(255, 255, 255)
        obStroke.Thickness = 2.5

        openBtn.MouseButton1Click:Connect(function()
            if mainWindow.Visible then minimizeMenu() else openMenu() end
        end)

        local obDrag = DraggableObject.new(openBtn)
        obDrag:Enable()
        obDrag.Dragged = function(pos)
            Save:set("OpenBtnPos", Utils.serializeUDim2(pos))
        end

        local savedOB = Save:get("OpenBtnPos")
        if savedOB then
            pcall(function() openBtn.Position = Utils.serializeUDim2(savedOB) end)
        end

        getgenv().RedzNoob.OpenBtn = openBtn
    else
        local openKey = settings.ToggleKeybind or Enum.KeyCode.RightShift
        UIS.InputBegan:Connect(function(inp, proc)
            if proc then return end
            if inp.KeyCode == openKey then
                if mainWindow.Visible then minimizeMenu() else openMenu() end
            end
        end)
    end

    local savedMenu = Save:get("MenuPosition")
    if savedMenu then
        pcall(function() mainWindow.Position = Utils.serializeUDim2(savedMenu) end)
    end

    local menuDragger = DraggableObject.new(mainWindow.Header, mainWindow, false, true)
    menuDragger:Enable()
    menuDragger.Dragged = function(pos)
        Save:set("MenuPosition", Utils.serializeUDim2(pos))
    end

    task.wait(1)
    Notify("Redz-Noob carregado! Toque no botão 'R'.", Color3.fromRGB(0, 200, 100), "check")
end

function getgenv().RedzNoob:Open() openMenu() end
function getgenv().RedzNoob:Close() minimizeMenu() end
function getgenv().RedzNoob:Minimize() minimizeMenu() end
function getgenv().RedzNoob:Unload() unloadMenu() end
function getgenv().RedzNoob:IsOpen() return mainWindow and mainWindow.Visible end
function getgenv().RedzNoob:Toggle() if mainWindow and mainWindow.Visible then minimizeMenu() else openMenu() end end

function getgenv().RedzNoob:SetTitle(t)
    if mainWindow and mainWindow.Header and mainWindow.Header:FindFirstChild("Title") then
        mainWindow.Header.Title.Text = t
    end
end

function getgenv().RedzNoob:SetSubtitle(t)
    if mainWindow and mainWindow.Header and mainWindow.Header:FindFirstChild("Version") then
        mainWindow.Header.Version.Text = t
    end
end

function getgenv().RedzNoob:SetSize(udim2)
    if mainWindow then TS:Create(mainWindow, TweenInfo.new(0.4), {Size = udim2}):Play() end
end

function getgenv().RedzNoob:SetPosition(udim2)
    if mainWindow then TS:Create(mainWindow, TweenInfo.new(0.4), {Position = udim2}):Play() end
end

function getgenv().RedzNoob:SetVisible(bool) if mainWindow then mainWindow.Visible = bool end end
function getgenv().RedzNoob:Hide() if mainWindow then mainWindow.Visible = false end end
function getgenv().RedzNoob:Destroy() unloadMenu() end

--==== ABAS ====
function getgenv().RedzNoob:CreateTab(name, options) return Tab.new(name) end

function getgenv().RedzNoob:RemoveTab(name)
    for i, t in ipairs(self.Tabs) do
        if t.Name == name then
            if t.Button then t.Button:Destroy() end
            table.remove(self.Tabs, i)
            return true
        end
    end
    return false
end

function getgenv().RedzNoob:GetTab(name)
    for _, t in ipairs(self.Tabs) do
        if t.Name == name then return t end
    end
end

function getgenv().RedzNoob:SelectTab(name)
    local t = self:GetTab(name)
    if t then t:Select() end
end

function getgenv().RedzNoob:GetSelectedTab()
    return selectedTab and selectedTab.Name or nil
end

function getgenv().RedzNoob:GetTabs() return self.Tabs end

function getgenv().RedzNoob:ClearTabs()
    for _, t in ipairs(self.Tabs) do
        if t.Button then t.Button:Destroy() end
    end
    self.Tabs = {}
end

--==== NOTIFICAÇÕES / DIÁLOGOS ====
function getgenv().RedzNoob:Notify(msg, color, icon) Notify(msg, color, icon) end
function getgenv().RedzNoob:ClearNotifications()
    if notifHolder then
        for _, c in ipairs(notifHolder:GetChildren()) do
            if c:IsA("Frame") and c.Name ~= "NotificationSample" then c:Destroy() end
        end
    end
end
function getgenv().RedzNoob:Dialog(title, desc, buttons) DialogShow(title, desc, buttons) end
function getgenv().RedzNoob:WaitForDialog() return DialogWait() end
function getgenv().RedzNoob:CloseDialog() DialogClose() end

--==== TEMAS ====
function getgenv().RedzNoob:GetTheme() return ThemeManager.colors end
function getgenv().RedzNoob:SetTheme(t)
    ThemeManager.setColors(t)
    if RedzRoot then ThemeManager.init(RedzRoot) end
    for _, tab in ipairs(self.Tabs) do
        if tab == selectedTab then tab:Refresh() end
    end
end
function getgenv().RedzNoob:SetColor(key, color)
    ThemeManager.colors[key] = color
    if RedzRoot then ThemeManager.init(RedzRoot) end
end
function getgenv().RedzNoob:ExportTheme()
    return Utils.toBase64(HS:JSONEncode(ThemeManager.serialize(ThemeManager.colors)))
end
function getgenv().RedzNoob:ImportTheme(code)
    local data = HS:JSONDecode(Utils.fromBase64(code))
    self:SetTheme(ThemeManager.deserialize(data))
    Save:set("ThemeCode", code)
    Notify("Tema aplicado!", Color3.fromRGB(0, 200, 100), "check")
end
function getgenv().RedzNoob:ResetTheme()
    ThemeManager.colors = {
        textColor = Color3.fromRGB(255, 255, 255),
        accentColor = Color3.fromRGB(197, 0, 0),
        primaryColor = Color3.fromRGB(22, 22, 22),
        secondaryColor = Color3.fromRGB(12, 12, 12),
        backgroundColorCSQ = ColorSequence.new(Color3.fromRGB(36,36,36), Color3.fromRGB(68,68,68)),
    }
    self:SetTheme(ThemeManager.colors)
    Save:remove("ThemeCode")
end

--==== SAVE ====
function getgenv().RedzNoob:Save(key, value) Save:set(key, value) end
function getgenv().RedzNoob:Load(key) return Save:get(key) end
function getgenv().RedzNoob:Delete(key) Save:remove(key) end
function getgenv().RedzNoob:ClearSave() Save:clear() end

--==== ANIMAÇÃO / INPUT ====
function getgenv().RedzNoob:Tween(obj, time, props, style)
    local t = TS:Create(obj, TweenInfo.new(time or 0.3, style or Enum.EasingStyle.Cubic), props)
    t:Play()
    return t
end

function getgenv().RedzNoob:BindKey(key, callback, options)
    options = options or {}
    return UIS.InputBegan:Connect(function(input, processed)
        if processed and not options.IgnoreGameProcessed then return end
        if input.KeyCode == key then pcall(callback) end
    end)
end

function getgenv().RedzNoob:UnbindKey(conn)
    if typeof(conn) == "RBXScriptConnection" and conn.Connected then
        conn:Disconnect()
    end
end

function getgenv().RedzNoob:IsKeyDown(key) return UIS:IsKeyDown(key) end

function getgenv().RedzNoob:ClickAndHold(btn, duration, callback)
    local ch = ClickAndHold.new(btn, duration or 0.8)
    ch.Holded.Event:Connect(callback)
    return ch
end

function getgenv().RedzNoob:MakeDraggable(obj, toMove, smooth, callbackOnly)
    local d = DraggableObject.new(obj, toMove, smooth, callbackOnly)
    d:Enable()
    return d
end

--==== UTILS ====
function getgenv().RedzNoob:Base64Encode(s) return Utils.toBase64(s) end
function getgenv().RedzNoob:Base64Decode(s) return Utils.fromBase64(s) end
function getgenv().RedzNoob:Udim2ToString(u) return Utils.serializeUDim2(u) end
function getgenv().RedzNoob:StringToUdim2(s) return Utils.serializeUDim2(s) end
function getgenv().RedzNoob:Round(n, d) return Utils.round(n, d) end
function getgenv().RedzNoob:Lerp(a, b, t) return a + (b - a) * t end
function getgenv().RedzNoob:GetExecutor()
    if identifyexecutor then return identifyexecutor() end
    if getexecutorname then return getexecutorname() end
    return "Desconhecido"
end
function getgenv().RedzNoob:GetVersion() return "1.0.1 (A06)" end
function getgenv().RedzNoob:IsMobile() return isMobile end
function getgenv().RedzNoob:IsSmallScreen() return isSmallScreen end

function getgenv().RedzNoob:GetPlayerByName(name)
    local lower = string.lower(name)
    for _, p in ipairs(Players:GetPlayers()) do
        if string.sub(string.lower(p.Name), 1, #name) == lower
        or string.sub(string.lower(p.DisplayName), 1, #name) == lower then
            return p
        end
    end
end

function getgenv().RedzNoob:GetPlayersByName(name)
    local lower = string.lower(name)
    local found = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if string.sub(string.lower(p.Name), 1, #name) == lower
        or string.sub(string.lower(p.DisplayName), 1, #name) == lower then
            table.insert(found, p)
        end
    end
    return found
end

--==== CONFIGURAÇÕES ====
function getgenv().RedzNoob:SetAutoSave(bool) self.AutoSave = bool end
function getgenv().RedzNoob:SetNotifications(bool) self.NotificationsEnabled = bool end

--==============================================================
-- AUTO-INICIALIZAÇÃO
--==============================================================
task.spawn(function()
    task.wait(0.3)
    local savedTheme = Save:get("ThemeCode")
    if savedTheme then
        pcall(function() getgenv().RedzNoob:ImportTheme(savedTheme) end)
    end
end)

getgenv().RedzNoob:Init({
    ToggleKeybind = Enum.KeyCode.RightShift,
    AutoSave = true,
})

--==============================================================
-- ABA DE EXEMPLO (já vem pronta!)
--==============================================================
task.spawn(function()
    task.wait(1.5)
    local Home = getgenv().RedzNoob:CreateTab("Home")
    Home:AddText("Bem-vindo ao Redz-Noob!")
    Home:AddText("Versão otimizada para <font color='#00AAFF'>Samsung A06</font>")
    Home:AddSection("Testes")
    Home:AddButton("Testar Notificação", function()
        getgenv().RedzNoob:Notify("Funcionou!", Color3.fromRGB(0, 200, 100), "check")
    end)
    Home:AddToggle("Exemplo de Toggle", false, function(state)
        print("Toggle:", state)
    end)
    Home:AddSlider("Exemplo de Slider", 0, 100, 50, function(v)
        print("Slider:", v)
    end)
    Home:AddSection("Sobre")
    Home:AddText("Executor: " .. getgenv().RedzNoob:GetExecutor())
    Home:AddText("Versão: " .. getgenv().RedzNoob:GetVersion())
    Home:AddText("Tela pequena detectada: " .. tostring(isSmallScreen))
end)

print("[Redz-Noob] Carregado! Versão A06 v1.0.1")
print("[Redz-Noob] Executor: " .. getgenv().RedzNoob:GetExecutor())
print("[Redz-Noob] Toque no botão 'R' para abrir o menu.")
