-- RUON: COMBINED FULL PANEL (BÖLMELİ, TAŞMA YOK, ÖZELLİKLER KORUNDU)
-- Tek dosya — yapıştırıp çalıştır

-- Services & basic refs (kept names similar to original)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local Lighting = game:GetService("Lighting")
local Workspace = workspace

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- =========================
-- Utility: safe mouse clicks (pcall wrappers)
-- =========================
local function safe_mouse1press()
    pcall(function() mouse1press() end)
end
local function safe_mouse1release()
    pcall(function() mouse1release() end)
end
local function safe_mouse1click()
    pcall(function() mouse1click() end)
end

-- =========================
-- STATE & DEVICE VARS
-- =========================
local deviceMode = "PC" -- default
local rainbowEnabled = false
local rainbowHue = 0

local flySpeed = 50
local flying = false
local noclip = false
local BV, BG -- BodyVelocity / BodyGyro

local aimModes = {"Kapalı","Düşmanlar","Herkes"}; local aimIndex = 1
local espModes = {"Kapalı","Düşmanlar","Herkes"}; local espIndex = 1

local triggerEnabled = false
local HoldClick = true
local Hotkey = 't'
local HotkeyToggle = true
local CurrentlyPressed = false

local flying2 = false
local BV2, BG2

local infiniteJump = false
local mobileUp = false
local mobileDown = false

local mobFlyUI = nil

local Mouse = LocalPlayer:GetMouse()

-- =========================
-- UTILITY FUNCTIONS
-- =========================
local function updateMobFlyUI()
    if deviceMode ~= "Mobil" then return end
    if (flying or flying2) then
        if not mobFlyUI then
            mobFlyUI = Instance.new("Frame", screenGui)
            mobFlyUI.Size = UDim2.new(0,80,0,180)
            mobFlyUI.Position = UDim2.new(1,-100,0.5,-90)
            mobFlyUI.BackgroundTransparency = 1
            
            local upBtn = Instance.new("TextButton", mobFlyUI)
            upBtn.Size = UDim2.new(1,0,0,80)
            upBtn.BackgroundColor3 = Color3.fromRGB(40,40,45)
            upBtn.Text = "⬆"
            upBtn.TextColor3 = Color3.fromRGB(240,240,240)
            upBtn.Font = Enum.Font.GothamBold
            upBtn.TextSize = 30
            Instance.new("UICorner", upBtn).CornerRadius = UDim.new(0,12)
            local str1 = Instance.new("UIStroke", upBtn); str1.Color = Color3.fromRGB(100,100,120)
            
            local downBtn = Instance.new("TextButton", mobFlyUI)
            downBtn.Size = UDim2.new(1,0,0,80)
            downBtn.Position = UDim2.new(0,0,0,100)
            downBtn.BackgroundColor3 = Color3.fromRGB(40,40,45)
            downBtn.Text = "⬇"
            downBtn.TextColor3 = Color3.fromRGB(240,240,240)
            downBtn.Font = Enum.Font.GothamBold
            downBtn.TextSize = 30
            Instance.new("UICorner", downBtn).CornerRadius = UDim.new(0,12)
            local str2 = Instance.new("UIStroke", downBtn); str2.Color = Color3.fromRGB(100,100,120)
            
            upBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    mobileUp = true
                    upBtn.BackgroundColor3 = Color3.fromRGB(60,60,70)
                end
            end)
            upBtn.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    mobileUp = false
                    upBtn.BackgroundColor3 = Color3.fromRGB(40,40,45)
                end
            end)
            
            downBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    mobileDown = true
                    downBtn.BackgroundColor3 = Color3.fromRGB(60,60,70)
                end
            end)
            downBtn.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    mobileDown = false
                    downBtn.BackgroundColor3 = Color3.fromRGB(40,40,45)
                end
            end)
        end
        mobFlyUI.Visible = true
    else
        if mobFlyUI then mobFlyUI.Visible = false end
        mobileUp = false
        mobileDown = false
    end
end

-- =========================
-- GUI CREATION
-- =========================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RuonHackGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui
screenGui.Enabled = false -- Start hidden for device selection
screenGui.DisplayOrder = 1000

-- main container (compact)
local main = Instance.new("Frame", screenGui)
main.Name = "MainPanel"
main.Size = UDim2.new(0, 560, 0, 400) -- Increased height to 400
main.Position = UDim2.fromOffset(20,20)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.BackgroundTransparency = 0.12
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0,14)

-- subtle stroke
local mainStroke = Instance.new("UIStroke", main)
mainStroke.Thickness = 1
mainStroke.Transparency = 0.6
mainStroke.Color = Color3.fromRGB(90,90,110)

-- title
local topBar = Instance.new("Frame", main)
topBar.Size = UDim2.new(1,0,0,48)
topBar.Position = UDim2.new(0,0,0,0)
topBar.BackgroundTransparency = 1
local title = Instance.new("TextLabel", topBar)
title.Size = UDim2.new(1,-120,1,0)
title.Position = UDim2.new(0,20,0,0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(240,240,240)
title.Text = "RUON HACK TEAM"
title.TextXAlignment = Enum.TextXAlignment.Left

-- minimize button
local minimizeBtn = Instance.new("TextButton", topBar)
minimizeBtn.Size = UDim2.new(0,36,0,36)
minimizeBtn.Position = UDim2.new(1,-52,0,6)
minimizeBtn.Text = "-"
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 22
minimizeBtn.TextColor3 = Color3.fromRGB(240,240,240)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(35,35,35)
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0,8)

-- rgb animated outline (subtle)
local hue = 0
RunService.RenderStepped:Connect(function(dt)
    hue = (hue + dt*0.06) % 1
    if rainbowEnabled then
        rainbowHue = (rainbowHue + 0.005) % 1
        main.BackgroundColor3 = Color3.fromHSV(rainbowHue,0.7,0.95)
    else
        mainStroke.Color = Color3.fromHSV(hue, 0.12, 0.85)
    end
end)

-- layout: left menu / right content
local left = Instance.new("ScrollingFrame", main)
left.Size = UDim2.new(0,140,1,-60)
left.Position = UDim2.new(0,12,0,56)
left.BackgroundColor3 = Color3.fromRGB(18,18,20)
left.BackgroundTransparency = 0.05
left.CanvasSize = UDim2.new(0,0,0,450) -- Adjust based on content
left.ScrollBarThickness = 2
left.BorderSizePixel = 0
Instance.new("UICorner", left).CornerRadius = UDim.new(0,12)
local leftLayout = Instance.new("UIListLayout", left)
leftLayout.Padding = UDim.new(0,8)
leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
leftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local leftPad = Instance.new("UIPadding", left)
leftPad.PaddingTop = UDim.new(0, 8)
leftPad.PaddingBottom = UDim.new(0, 8)

local right = Instance.new("Frame", main)
right.Size = UDim2.new(1,-172,1,-60)
right.Position = UDim2.new(0,164,0,56)
right.BackgroundTransparency = 1

-- small subtitle on top-left of right
local subtitle = Instance.new("TextLabel", main)
subtitle.Size = UDim2.new(0,300,0,18)
subtitle.Position = UDim2.new(0,164,0,34)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 11
subtitle.TextColor3 = Color3.fromRGB(190,190,200)
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Text = "Ultra Premium • Glass • RGB Highlights"

-- menu button factory (compact)
local function mkMenuBtn(parent, txt)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.92,0,0,36)
    b.BackgroundColor3 = Color3.fromRGB(22,22,25)
    b.TextColor3 = Color3.fromRGB(240,240,240)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 14
    b.Text = txt
    b.AutoButtonColor = false
    local c = Instance.new("UICorner", b); c.CornerRadius = UDim.new(0,8)
    b.MouseEnter:Connect(function() b.BackgroundTransparency = 0.3 end)
    b.MouseLeave:Connect(function() b.BackgroundTransparency = 0.6 end)
    b.TextSize = 16
    return b
end

local btnFly = mkMenuBtn(left, "Fly")
local btnMovement = mkMenuBtn(left, "Movement")
local btnESP = mkMenuBtn(left, "ESP")
local btnAim = mkMenuBtn(left, "Aimlock")
local btnTrigger = mkMenuBtn(left, "TriggerBot")
local btnWorld = mkMenuBtn(left, "World")
local btnSkins = mkMenuBtn(left, "Skins")
local btnTeleport = mkMenuBtn(left, "Teleport")
local btnThemes = mkMenuBtn(left, "Themes")
local btnMisc = mkMenuBtn(left, "Misc")

-- pages
local pages = {}
local function newPage(name)
    local p = Instance.new("Frame", right)
    p.Size = UDim2.new(1,0,1,0)
    p.BackgroundTransparency = 1
    p.Visible = false
    pages[name] = p
    return p
end

local pageFly = newPage("Fly")
local pageMovement = newPage("Movement")
local pageESP = newPage("ESP")
local pageAim = newPage("Aim")
local pageTrigger = newPage("Trigger")
local pageWorld = newPage("World")
local pageSkins = newPage("Skins")
local pageTeleport = newPage("Teleport")
local pageThemes = newPage("Themes")
local pageMisc = newPage("Misc")

local function showPage(name)
    for k,v in pairs(pages) do v.Visible = false end
    if pages[name] then pages[name].Visible = true end
end

-- default
showPage("Fly")

btnFly.MouseButton1Click:Connect(function() showPage("Fly") end)
btnMovement.MouseButton1Click:Connect(function() showPage("Movement") end)
btnESP.MouseButton1Click:Connect(function() showPage("ESP") end)
btnAim.MouseButton1Click:Connect(function() showPage("Aim") end)
btnTrigger.MouseButton1Click:Connect(function() showPage("Trigger") end)
btnWorld.MouseButton1Click:Connect(function() showPage("World") end)
btnSkins.MouseButton1Click:Connect(function() showPage("Skins") end)
btnTeleport.MouseButton1Click:Connect(function() showPage("Teleport") end)
btnThemes.MouseButton1Click:Connect(function() showPage("Themes") end)
btnMisc.MouseButton1Click:Connect(function() showPage("Misc") end)

-- =========================
-- Populate Fly page (controls kept)
-- =========================
do
    local lbl = Instance.new("TextLabel", pageFly)
    lbl.Size = UDim2.new(1,0,0,28)
    lbl.Position = UDim2.new(0,0,0,4)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 16
    lbl.Text = "Fly • H ile aç/kapa"
    lbl.TextColor3 = Color3.fromRGB(240,240,240)
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local flyBtn = Instance.new("TextButton", pageFly)
    flyBtn.Size = UDim2.new(0,160,0,36)
    flyBtn.Position = UDim2.new(0,0,0,40)
    flyBtn.Text = "Fly: Kapalı"
    flyBtn.Font = Enum.Font.GothamBold
    flyBtn.TextSize = 16
    flyBtn.BackgroundColor3 = Color3.fromRGB(30,30,35)
    Instance.new("UICorner", flyBtn).CornerRadius = UDim.new(0,8)

    local fly2Btn = Instance.new("TextButton", pageFly)
    fly2Btn.Size = UDim2.new(0,240,0,36) -- Wider button
    fly2Btn.Position = UDim2.new(0,0,0,80)
    fly2Btn.Text = "Fly 2 (Anti-Cheat): Kapalı"
    fly2Btn.Font = Enum.Font.GothamBold
    fly2Btn.TextSize = 16
    fly2Btn.BackgroundColor3 = Color3.fromRGB(30,30,35)
    Instance.new("UICorner", fly2Btn).CornerRadius = UDim.new(0,8)

    local noclipBtn = Instance.new("TextButton", pageFly)
    noclipBtn.Size = UDim2.new(0,140,0,36)
    noclipBtn.Position = UDim2.new(0,250,0,40)
    noclipBtn.Text = "Noclip: Kapalı"
    noclipBtn.Font = Enum.Font.GothamBold
    noclipBtn.TextSize = 16
    noclipBtn.BackgroundColor3 = Color3.fromRGB(30,30,35)
    Instance.new("UICorner", noclipBtn).CornerRadius = UDim.new(0,8)

    local speedLabel = Instance.new("TextLabel", pageFly)
    speedLabel.Position = UDim2.new(0,0,0,130) -- Pushed down
    speedLabel.Size = UDim2.new(0,220,0,24)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextSize = 13
    speedLabel.TextColor3 = Color3.fromRGB(200,200,200)
    speedLabel.Text = "Uçuş Hızı: "..flySpeed

    local speedBox = Instance.new("TextBox", pageFly)
    speedBox.Position = UDim2.new(0,0,0,160) -- Pushed down
    speedBox.Size = UDim2.new(0,120,0,28)
    speedBox.Text = tostring(flySpeed)
    speedBox.Font = Enum.Font.Gotham
    speedBox.TextSize = 16
    speedBox.BackgroundColor3 = Color3.fromRGB(40,40,45)
    speedBox.TextColor3 = Color3.fromRGB(240,240,240)
    Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0,6)

    speedBox.FocusLost:Connect(function()
        local v = tonumber(speedBox.Text)
        if v and v > 0 then flySpeed = v; speedLabel.Text = "Uçuş Hızı: "..flySpeed
        else speedBox.Text = tostring(flySpeed) end
    end)

    flyBtn.MouseButton1Click:Connect(function()
        flying = not flying
        if flying then
            -- start fly (original startFly logic)
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    BV = Instance.new("BodyVelocity")
                    BV.MaxForce = Vector3.new(1e5,1e5,1e5)
                    BV.Velocity = Vector3.zero
                    BV.Parent = hrp
                    BG = Instance.new("BodyGyro")
                    BG.MaxTorque = Vector3.new(1e5,1e5,1e5)
                    BG.CFrame = hrp.CFrame
                    BG.Parent = hrp
                end
            end
        else
            if BV then BV:Destroy(); BV=nil end
            if BG then BG:Destroy(); BG=nil end
        end
        flyBtn.Text = "Fly: "..(flying and "Açık" or "Kapalı")
        updateMobFlyUI()
    end)

    noclipBtn.MouseButton1Click:Connect(function()
        noclip = not noclip
        noclipBtn.Text = "Noclip: "..(noclip and "Açık" or "Kapalı")
        noclipBtn.Text = "Noclip: "..(noclip and "Açık" or "Kapalı")
    end)

    fly2Btn.MouseButton1Click:Connect(function()
        flying2 = not flying2
        if flying2 then
             -- start advanced fly
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChild("Humanoid")
                if hrp and hum then
                   hum.PlatformStand = true
                   BV2 = Instance.new("BodyVelocity")
                   BV2.MaxForce = Vector3.new(9e9,9e9,9e9)
                   BV2.Velocity = Vector3.zero
                   BV2.Parent = hrp
                   BG2 = Instance.new("BodyGyro")
                   BG2.P = 9e4
                   BG2.MaxTorque = Vector3.new(9e9,9e9,9e9)
                   BG2.CFrame = hrp.CFrame
                   BG2.Parent = hrp
                end
            end
        else
            if BV2 then BV2:Destroy(); BV2=nil end
            if BG2 then BG2:Destroy(); BG2=nil end
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum then hum.PlatformStand = false end
        end
        fly2Btn.Text = "Fly 2 (Anti-Cheat): "..(flying2 and "Açık" or "Kapalı")
        updateMobFlyUI()
    end)

    -- H hotkey toggle (keep H behavior)
    UserInputService.InputBegan:Connect(function(input,gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.H then
            flying = not flying
            if flying then
                -- startFly
                local char = LocalPlayer.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        BV = Instance.new("BodyVelocity")
                        BV.MaxForce = Vector3.new(1e5,1e5,1e5)
                        BV.Velocity = Vector3.zero
                        BV.Parent = hrp
                        BG = Instance.new("BodyGyro")
                        BG.MaxTorque = Vector3.new(1e5,1e5,1e5)
                        BG.CFrame = hrp.CFrame
                        BG.Parent = hrp
                    end
                end
            else
                if BV then BV:Destroy(); BV=nil end
                if BG then BG:Destroy(); BG=nil end
            end
            flyBtn.Text = "Fly: "..(flying and "Açık" or "Kapalı")
            updateMobFlyUI()
        end
    end)
end
-- =========================
-- ESP Toggle + Enemy/Team Filter + Charm + Duvar Arkası Renkleri
-- =========================
do
    local scroll = Instance.new("ScrollingFrame", pageESP)
    scroll.Size = UDim2.new(1,0,1,-40)
    scroll.Position = UDim2.new(0,0,0,40)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0,0,0,200)
    scroll.ScrollBarThickness = 2
    scroll.BorderSizePixel = 0

    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0,8)

    local espToggleBtn = Instance.new("TextButton", scroll)
    espToggleBtn.Size = UDim2.new(0,200,0,38)
    espToggleBtn.Text = "ESP: Kapalı"
    espToggleBtn.Font = Enum.Font.GothamBold
    espToggleBtn.TextSize = 16
    espToggleBtn.BackgroundColor3 = Color3.fromRGB(30,30,35)
    Instance.new("UICorner", espToggleBtn).CornerRadius = UDim.new(0,8)

    local charmBtn = Instance.new("TextButton", scroll)
    charmBtn.Size = UDim2.new(0,200,0,38)
    charmBtn.Text = "Charm: Kapalı"
    charmBtn.Font = Enum.Font.GothamBold
    charmBtn.TextSize = 16
    charmBtn.BackgroundColor3 = Color3.fromRGB(30,30,35)
    Instance.new("UICorner", charmBtn).CornerRadius = UDim.new(0,8)

    local enemyFilterBtn = Instance.new("TextButton", scroll)
    enemyFilterBtn.Size = UDim2.new(0,200,0,38)
    enemyFilterBtn.Text = "only enemy: Açık"
    enemyFilterBtn.Font = Enum.Font.GothamBold
    enemyFilterBtn.TextSize = 16
    enemyFilterBtn.BackgroundColor3 = Color3.fromRGB(30,30,35)
    Instance.new("UICorner", enemyFilterBtn).CornerRadius = UDim.new(0,8)

    local teamFilterBtn = Instance.new("TextButton", scroll)
    teamFilterBtn.Size = UDim2.new(0,200,0,38)
    teamFilterBtn.Text = "only team: Kapalı"
    teamFilterBtn.Font = Enum.Font.GothamBold
    teamFilterBtn.TextSize = 16
    teamFilterBtn.BackgroundColor3 = Color3.fromRGB(30,30,35)
    Instance.new("UICorner", teamFilterBtn).CornerRadius = UDim.new(0,8)

    local espActive = false
    local charmActive = false
    local enemyFilter = true
    local teamFilter = false
    local espBoxes = {}

    local function clearESP()
        for _,box in pairs(espBoxes) do box:Destroy() end
        espBoxes = {}
    end

    local function isVisible(part)
        local origin = workspace.CurrentCamera.CFrame.Position
        local direction = (part.Position - origin).Unit * (part.Position - origin).Magnitude
        local ray = Ray.new(origin, direction)
        local hitPart = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
        return hitPart == part or hitPart == nil
    end

    local function updateESP()
        clearESP()
        if not espActive then return end
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local isEnemy = plr.Team ~= LocalPlayer.Team
                local isTeam = plr.Team == LocalPlayer.Team
                if (enemyFilter and isEnemy) or (teamFilter and isTeam) then
                    local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local box = Instance.new("BoxHandleAdornment")
                        box.Adornee = hrp
                        box.Size = Vector3.new(4,7,2)
                        box.Transparency = 0.4
                        box.AlwaysOnTop = true
                        box.ZIndex = 10
                        -- Renk: Duvar arkası kırmızı, görünür yeşil
                        box.Color3 = isVisible(hrp) and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
                        if charmActive then
                            box.Color3 = Color3.fromRGB(255,0,255)
                        end
                        box.Parent = workspace
                        table.insert(espBoxes, box)
                    end
                end
            end
        end
    end

    espToggleBtn.MouseButton1Click:Connect(function()
        espActive = not espActive
        espToggleBtn.Text = "ESP: "..(espActive and "Açık" or "Kapalı")
        updateESP()
    end)

    charmBtn.MouseButton1Click:Connect(function()
        charmActive = not charmActive
        charmBtn.Text = "Charm: "..(charmActive and "Açık" or "Kapalı")
        updateESP()
    end)

    enemyFilterBtn.MouseButton1Click:Connect(function()
        enemyFilter = not enemyFilter
        enemyFilterBtn.Text = "Enemy Filter: "..(enemyFilter and "Açık" or "Kapalı")
        updateESP()
    end)

    teamFilterBtn.MouseButton1Click:Connect(function()
        teamFilter = not teamFilter
        teamFilterBtn.Text = "Team Filter: "..(teamFilter and "Açık" or "Kapalı")
        updateESP()
    end)

    Players.PlayerAdded:Connect(function(plr)
        plr.CharacterAdded:Connect(function() task.wait(0.3); updateESP() end)
    end)
    Players.PlayerRemoving:Connect(function(plr) updateESP() end)
end

-- =========================
-- Populate Aim page (aimlock)
-- =========================
do
    local lbl = Instance.new("TextLabel", pageAim)
    lbl.Size = UDim2.new(1,0,0,28)
    lbl.Position = UDim2.new(0,0,0,4)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 16
    lbl.Text = "Aimlock"
    lbl.TextColor3 = Color3.fromRGB(240,240,240)
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local aimBtn = Instance.new("TextButton", pageAim)
    aimBtn.Size = UDim2.new(0,220,0,36)
    aimBtn.Position = UDim2.new(0,0,0,40)
    aimBtn.Text = "Aimlock: "..aimModes[aimIndex]
    aimBtn.Font = Enum.Font.GothamBold
    aimBtn.TextSize = 16
    aimBtn.BackgroundColor3 = Color3.fromRGB(30,30,35)
    Instance.new("UICorner", aimBtn).CornerRadius = UDim.new(0,8)

    -- visibility check reused
    local function isVisible(part)
        if not part or not part.Position then return false end
        local origin = Camera.CFrame.Position
        local dir = (part.Position - origin)
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {LocalPlayer.Character}
        params.FilterType = Enum.RaycastFilterType.Blacklist
        local hit = workspace:Raycast(origin, dir, params)
        return hit and hit.Instance and hit.Instance:IsDescendantOf(part.Parent)
    end

    local function getClosestTarget()
        local bestHead, bestDist = nil, math.huge
        local mousePos = UserInputService:GetMouseLocation()
        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                if aimIndex==3 or (aimIndex==2 and p.Team~=LocalPlayer.Team) then
                    local head = p.Character and p.Character:FindFirstChild("Head")
                    if head then
                        local sp,onScreen = Camera:WorldToScreenPoint(head.Position)
                        if onScreen and isVisible(head) then
                            local d = (Vector2.new(sp.X, sp.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                            if d < bestDist then bestDist = d; bestHead = head end
                        end
                    end
                end
            end
        end
        return bestHead
    end

    RunService.RenderStepped:Connect(function()
        if aimIndex ~= 1 then
            local targetHead = getClosestTarget()
            if targetHead then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
            end
        end
    end)

    aimBtn.MouseButton1Click:Connect(function()
        aimIndex = aimIndex % #aimModes + 1
        aimBtn.Text = "Aimlock: "..aimModes[aimIndex]
    end)
end

-- =========================
-- TriggerBot page
-- =========================
do
    local lbl = Instance.new("TextLabel", pageTrigger)
    lbl.Size = UDim2.new(1,0,0,28)
    lbl.Position = UDim2.new(0,0,0,4)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 16
    lbl.Text = "TriggerBot"
    lbl.TextColor3 = Color3.fromRGB(240,240,240)
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local trigBtn = Instance.new("TextButton", pageTrigger)
    trigBtn.Size = UDim2.new(0,220,0,36)
    trigBtn.Position = UDim2.new(0,0,0,40)
    trigBtn.Text = "TriggerBot: Kapalı"
    trigBtn.Font = Enum.Font.GothamBold
    trigBtn.TextSize = 16
    trigBtn.BackgroundColor3 = Color3.fromRGB(30,30,35)
    Instance.new("UICorner", trigBtn).CornerRadius = UDim.new(0,8)

    trigBtn.MouseButton1Click:Connect(function()
        triggerEnabled = not triggerEnabled
        trigBtn.Text = "TriggerBot: "..(triggerEnabled and "Açık" or "Kapalı")
    end)

    -- old style mouse key handling (kept)
    Mouse.KeyDown:Connect(function(key)
        if HotkeyToggle == true and key == Hotkey then
            triggerEnabled = not triggerEnabled
            trigBtn.Text = "TriggerBot: "..(triggerEnabled and "Açık" or "Kapalı")
        elseif key == Hotkey then
            triggerEnabled = true
        end
    end)
    Mouse.KeyUp:Connect(function(key)
        if not HotkeyToggle and key == Hotkey then
            triggerEnabled = false
        end
    end)

    RunService.RenderStepped:Connect(function()
        if triggerEnabled then
            if Mouse.Target and Mouse.Target.Parent:FindFirstChild('Humanoid') then
                if HoldClick then
                    if not CurrentlyPressed then
                        CurrentlyPressed = true
                        safe_mouse1press()
                    end
                    task.wait(0)
                    safe_mouse1release()
                    CurrentlyPressed = false
                else
                    safe_mouse1click()
                end
            end
        end
    end)
end

-- =========================
-- World page (lighting quick choices)
-- =========================
do
    local lbl = Instance.new("TextLabel", pageWorld)
    lbl.Size = UDim2.new(1,0,0,28)
    lbl.Position = UDim2.new(0,0,0,4)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 16
    lbl.Text = "World / Lighting"
    lbl.TextColor3 = Color3.fromRGB(240,240,240)
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local colors = {
        {Name="Mavi", Col=Color3.fromRGB(0,120,255)},
        {Name="Kırmızı", Col=Color3.fromRGB(255,60,60)},
        {Name="Yeşil", Col=Color3.fromRGB(60,255,100)},
        {Name="Turuncu", Col=Color3.fromRGB(255,120,0)},
        {Name="Mor", Col=Color3.fromRGB(180,0,255)},
        {Name="Pembe", Col=Color3.fromRGB(255,100,200)},
        {Name="Sarı", Col=Color3.fromRGB(255,255,0)},
        {Name="Turkuaz", Col=Color3.fromRGB(0,255,255)},
        {Name="Beyaz", Col=Color3.fromRGB(255,255,255)},
        {Name="Siyah", Col=Color3.fromRGB(0,0,0)},
    }

    for i,data in ipairs(colors) do
        local btn = Instance.new("TextButton", pageWorld)
        btn.Size = UDim2.new(0,110,0,36)
        btn.Position = UDim2.new(0, (i-1)*116, 0, 40)
        btn.Text = data.Name
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 16
        btn.BackgroundColor3 = Color3.fromRGB(30,30,35)
        btn.TextColor3 = Color3.fromRGB(240,240,240)
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

        btn.MouseButton1Click:Connect(function()
            Lighting.Ambient = data.Col
            Lighting.OutdoorAmbient = data.Col
            Lighting.ColorShift_Top = data.Col
            Lighting.ColorShift_Bottom = data.Col
        end)
    end

    -- Scroll adjustment for many buttons
    local grid = Instance.new("UIGridLayout", pageWorld)
    grid.CellSize = UDim2.new(0,110,0,38) -- Increased size
    grid.CellPadding = UDim2.new(0,8,0,8)
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    
    local pad = Instance.new("UIPadding", pageWorld)
    pad.PaddingTop = UDim.new(0,40)
end

-- =========================
-- Misc page (rainbow toggle, player list teleport)
-- =========================
do
    local lbl = Instance.new("TextLabel", pageMisc)
    lbl.Size = UDim2.new(1,0,0,28)
    lbl.Position = UDim2.new(0,0,0,4)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 16
    lbl.Text = "Misc"
    lbl.TextColor3 = Color3.fromRGB(240,240,240)
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local rainbowBtn = Instance.new("TextButton", pageMisc)
    rainbowBtn.Size = UDim2.new(0,200,0,36)
    rainbowBtn.Position = UDim2.new(0,0,0,40)
    rainbowBtn.Text = "Rainbow GUI: Kapalı"
    rainbowBtn.Font = Enum.Font.Gotham
    rainbowBtn.TextSize = 16
    rainbowBtn.BackgroundColor3 = Color3.fromRGB(30,30,35)
    Instance.new("UICorner", rainbowBtn).CornerRadius = UDim.new(0,8)

    rainbowBtn.MouseButton1Click:Connect(function()
        rainbowEnabled = not rainbowEnabled
        rainbowBtn.Text = "Rainbow GUI: "..(rainbowEnabled and "Açık" or "Kapalı")
        if not rainbowEnabled then
            main.BackgroundColor3 = Color3.fromRGB(25,25,25)
        end
    end)
end

-- =========================
-- Movement Page
-- =========================
do
    local lbl = Instance.new("TextLabel", pageMovement)
    lbl.Size = UDim2.new(1,0,0,32)
    lbl.Position = UDim2.new(0,0,0,4)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 18
    lbl.Text = "Movement Controls"
    lbl.TextColor3 = Color3.fromRGB(240,240,240)
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local scroll = Instance.new("ScrollingFrame", pageMovement)
    scroll.Size = UDim2.new(1,0,1,-40)
    scroll.Position = UDim2.new(0,0,0,40)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0,0,0,300)
    scroll.ScrollBarThickness = 4

    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0,8)

    local function addMoveControl(name, default, callback)
        local frame = Instance.new("Frame", scroll)
        frame.Size = UDim2.new(1, -10, 0, 45)
        frame.BackgroundTransparency = 1
        
        local textLabel = Instance.new("TextLabel", frame)
        textLabel.Size = UDim2.new(0.4, 0, 1, 0)
        textLabel.Text = name
        textLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        textLabel.Font = Enum.Font.Gotham
        textLabel.TextSize = 16
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.BackgroundTransparency = 1

        local box = Instance.new("TextBox", frame)
        box.Size = UDim2.new(0.5, 0, 0.8, 0)
        box.Position = UDim2.new(0.45, 0, 0.1, 0)
        box.Text = tostring(default)
        box.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        box.TextColor3 = Color3.fromRGB(240, 240, 240)
        box.Font = Enum.Font.Gotham
        box.TextSize = 16
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

        box.FocusLost:Connect(function()
            local val = tonumber(box.Text)
            if val then callback(val) end
        end)
    end

    addMoveControl("Yürüme Hızı", 16, function(v)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = v
        end
    end)

    addMoveControl("Zıplama Gücü", 50, function(v)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = v
            LocalPlayer.Character.Humanoid.UseJumpPower = true
        end
    end)

    addMoveControl("Yerçekimi", workspace.Gravity, function(v)
        workspace.Gravity = v
    end)

    local infJumpBtn = Instance.new("TextButton", scroll)
    infJumpBtn.Size = UDim2.new(1, -10, 0, 36)
    infJumpBtn.Text = "Sonsuz Zıplama: Kapalı"
    infJumpBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    infJumpBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
    infJumpBtn.Font = Enum.Font.GothamBold
    infJumpBtn.TextSize = 15
    Instance.new("UICorner", infJumpBtn).CornerRadius = UDim.new(0, 6)

    infJumpBtn.MouseButton1Click:Connect(function()
        infiniteJump = not infiniteJump
        infJumpBtn.Text = "Sonsuz Zıplama: " .. (infiniteJump and "Açık" or "Kapalı")
    end)
end

-- =========================
-- Teleport Page
-- =========================
do
    local lbl = Instance.new("TextLabel", pageTeleport)
    lbl.Size = UDim2.new(1,0,0,32)
    lbl.Position = UDim2.new(0,0,0,4)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 18
    lbl.Text = "Teleport Players"
    lbl.TextColor3 = Color3.fromRGB(240,240,240)
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local scroll = Instance.new("ScrollingFrame", pageTeleport)
    scroll.Size = UDim2.new(1,0,1,-40)
    scroll.Position = UDim2.new(0,0,0,40)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.ScrollBarThickness = 4

    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0,6)

    local function makeTpEntry(plr)
        local btn = Instance.new("TextButton", scroll)
        btn.Size = UDim2.new(1,-10,0,32)
        btn.BackgroundColor3 = Color3.fromRGB(35,35,40)
        btn.Text = "TP to: "..plr.Name
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 15
        btn.TextColor3 = Color3.fromRGB(230,230,230)
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

        btn.MouseButton1Click:Connect(function()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local targetHRP = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp and targetHRP then
                hrp.CFrame = targetHRP.CFrame + Vector3.new(0,3,0)
            end
        end)
    end

    local function refreshTP()
        for _,c in ipairs(scroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        local count = 0
        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                makeTpEntry(p); count = count + 1
            end
        end
        scroll.CanvasSize = UDim2.new(0,0,0, count * 38)
    end

    Players.PlayerAdded:Connect(refreshTP)
    Players.PlayerRemoving:Connect(refreshTP)
    task.spawn(function() while true do task.wait(5); refreshTP() end end)
    refreshTP()
end

-- =========================
-- Themes Page
-- =========================
do
    local lbl = Instance.new("TextLabel", pageThemes)
    lbl.Size = UDim2.new(1,0,0,32)
    lbl.Position = UDim2.new(0,0,0,4)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 18
    lbl.Text = "Theme Changer"
    lbl.TextColor3 = Color3.fromRGB(240,240,240)
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local themes = {
        {Name="Karanlık", Main=Color3.fromRGB(25,25,25), Left=Color3.fromRGB(18,18,20), Stroke=Color3.fromRGB(90,90,110)},
        {Name="Aydınlık", Main=Color3.fromRGB(240,240,240), Left=Color3.fromRGB(220,220,225), Stroke=Color3.fromRGB(150,150,160), Text=Color3.fromRGB(20,20,30)},
        {Name="Okyanus", Main=Color3.fromRGB(10,30,50), Left=Color3.fromRGB(5,20,40), Stroke=Color3.fromRGB(0,100,200)},
        {Name="Yakut", Main=Color3.fromRGB(40,10,10), Left=Color3.fromRGB(30,5,5), Stroke=Color3.fromRGB(200,0,0)},
        {Name="Orman", Main=Color3.fromRGB(10,30,15), Left=Color3.fromRGB(5,25,10), Stroke=Color3.fromRGB(0,150,50)},
        {Name="Gece Yarısı", Main=Color3.fromRGB(5,5,10), Left=Color3.fromRGB(2,2,5), Stroke=Color3.fromRGB(60,60,80)}
    }

    local grid = Instance.new("UIGridLayout", pageThemes)
    grid.CellSize = UDim2.new(0,130,0,40)
    grid.CellPadding = UDim2.new(0,10,0,10)

    local pad = Instance.new("UIPadding", pageThemes)
    pad.PaddingTop = UDim.new(0,50)

    for _,t in ipairs(themes) do
        local b = Instance.new("TextButton", pageThemes)
        b.Text = t.Name
        b.BackgroundColor3 = t.Main
        b.TextColor3 = t.Text or Color3.fromRGB(240,240,240)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 16
        local corn = Instance.new("UICorner", b); corn.CornerRadius = UDim.new(0,8)
        local str = Instance.new("UIStroke", b); str.Color = t.Stroke; str.Thickness = 1

        b.MouseButton1Click:Connect(function()
            main.BackgroundColor3 = t.Main
            left.BackgroundColor3 = t.Left
            mainStroke.Color = t.Stroke
            subtitle.TextColor3 = t.Text or Color3.fromRGB(190,190,200)
            title.TextColor3 = t.Text or Color3.fromRGB(240,240,240)
        end)
    end
end
-- =========================
-- Global listeners
-- =========================
UserInputService.JumpRequest:Connect(function()
    if infiniteJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)


-- =========================
-- Skin Changer page + Warning Notification
-- =========================
do
    local function showNotify(txt)
        local notify = Instance.new("TextLabel", screenGui)
        notify.Size = UDim2.new(0,300,0,30)
        notify.Position = UDim2.new(0.5,-150,0,50)
        notify.BackgroundColor3 = Color3.fromRGB(20,20,25)
        notify.TextColor3 = Color3.fromRGB(255,200,50)
        notify.Text = "⚠ "..txt
        notify.Font = Enum.Font.GothamBold
        notify.TextSize = 14
        notify.BorderSizePixel = 0
        local corner = Instance.new("UICorner", notify); corner.CornerRadius = UDim.new(0,8)
        local stroke = Instance.new("UIStroke", notify); stroke.Color = Color3.fromRGB(255,200,50); stroke.Thickness = 1

        task.spawn(function()
            task.wait(3)
            for i=0,1,0.1 do
                notify.BackgroundTransparency = i
                notify.TextTransparency = i
                stroke.Transparency = i
                task.wait(0.05)
            end
            notify:Destroy()
        end)
    end

    local lbl = Instance.new("TextLabel", pageSkins)
    lbl.Size = UDim2.new(1,0,0,28)
    lbl.Position = UDim2.new(0,0,0,4)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 16
    lbl.Text = "Skin Changer"
    lbl.TextColor3 = Color3.fromRGB(240,240,240)
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local sub = Instance.new("TextLabel", pageSkins)
    sub.Size = UDim2.new(1,0,0,20)
    sub.Position = UDim2.new(0,0,0,28)
    sub.BackgroundTransparency = 1
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 12
    sub.Text = "Sadece sizde görünür!"
    sub.TextColor3 = Color3.fromRGB(255,100,100)
    sub.TextXAlignment = Enum.TextXAlignment.Left

    local skins = {
        {Name="Neon Full", Action=function()
            local char = LocalPlayer.Character
            if not char then return end
            for _,p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Material = Enum.Material.Neon
                    p.Color = Color3.fromRGB(0, 255, 255)
                end
            end
        end},
        {Name="Zombi", Action=function()
            local char = LocalPlayer.Character
            if not char then return end
            for _,p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.Name:lower():find("skin") or p.Name:lower():find("arm") or p.Name:lower():find("leg") or p.Name:lower():find("head") or p.Name:lower():find("torso") then
                    p.Color = Color3.fromRGB(50, 100, 50)
                end
            end
        end},
        {Name="Altın", Action=function()
            local char = LocalPlayer.Character
            if not char then return end
            for _,p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Material = Enum.Material.Metal
                    p.Color = Color3.fromRGB(255, 215, 0)
                end
            end
        end},
        {Name="Hayalet", Action=function()
            local char = LocalPlayer.Character
            if not char then return end
            for _,p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Transparency = 0.5
                end
            end
        end},
        {Name="Ateşli", Action=function()
            local char = LocalPlayer.Character
            if not char then return end
            for _,p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    local f = Instance.new("Fire", p)
                    f.Size = 5
                end
            end
        end},
        {Name="Işıltılı", Action=function()
            local char = LocalPlayer.Character
            if not char then return end
            for _,p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    Instance.new("Sparkles", p)
                end
            end
        end},
        {Name="Dumanlı", Action=function()
            local char = LocalPlayer.Character
            if not char then return end
            for _,p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    Instance.new("Smoke", p)
                end
            end
        end},
        {Name="Kalkan", Action=function()
            local char = LocalPlayer.Character
            if not char then return end
            Instance.new("ForceField", char)
        end},
        {Name="Normal", Action=function()
            -- Bu sadece yerel bir deneme olduğu için karakteri yenilemek en iyisidir
            LocalPlayer:LoadCharacter()
        end}
    }

    local skinGrid = Instance.new("UIGridLayout", pageSkins)
    skinGrid.CellSize = UDim2.new(0,130,0,38)
    skinGrid.CellPadding = UDim2.new(0,10,0,10)
    skinGrid.SortOrder = Enum.SortOrder.LayoutOrder

    -- Padding for grid
    local pad = Instance.new("UIPadding", pageSkins)
    pad.PaddingTop = UDim.new(0,60)

    for _,data in ipairs(skins) do
        local btn = Instance.new("TextButton", pageSkins)
        btn.Text = data.Name
        btn.BackgroundColor3 = Color3.fromRGB(35,35,40)
        btn.TextColor3 = Color3.fromRGB(230,230,230)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 16
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

        btn.MouseButton1Click:Connect(function()
            showNotify("Sadece sende görünür!")
            task.wait(0.5)
            data.Action()
        end)
    end
end

-- =========================
-- Shared runtime: Fly movement, noclip, rainbow background, aim/esp updates
-- =========================
-- Reuse parts of original RenderStepped logic
RunService.RenderStepped:Connect(function()
    -- rainbow gui background (if enabled)
    -- Removed as requested

    -- flying
    if flying and BV and BG then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if char and hum then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local move = Vector3.zero
                local cam = Camera.CFrame
                local look = cam.LookVector
                local right = cam.RightVector
                local isTyping = UserInputService:GetFocusedTextBox() ~= nil
                
                -- Detect intent from MoveDirection (supports both WASD and Joystick)
                if not isTyping and hum.MoveDirection.Magnitude > 0 then
                    local moveDir = hum.MoveDirection
                    local horizontalLook = Vector3.new(look.X, 0, look.Z).Unit
                    local horizontalRight = Vector3.new(right.X, 0, right.Z).Unit
                    
                    local forwardAmount = moveDir:Dot(horizontalLook)
                    local rightAmount = moveDir:Dot(horizontalRight)
                    
                    -- Apply intent to 3D vectors (Look up -> Fly up)
                    move = (look * forwardAmount) + (right * rightAmount)
                end
                
                -- Vertical Movement Overrides
                if not isTyping then
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) or mobileUp then 
                        move += Vector3.new(0,1,0) 
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or mobileDown then 
                        move -= Vector3.new(0,1,0) 
                    end
                end
                
                if move.Magnitude > 0 then move = move.Unit * flySpeed end
                BV.Velocity = move
                BG.CFrame = CFrame.new(hrp.Position, hrp.Position + look)
            end
        end
    end

    -- advanced flying (fly2)
    if flying2 and BV2 and BG2 then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if char and hum then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                 local move = Vector3.zero
                 local cam = Camera.CFrame
                 local look = cam.LookVector
                 local right = cam.RightVector
                 local isTyping = UserInputService:GetFocusedTextBox() ~= nil
                 
                 -- Detect intent from MoveDirection
                 if not isTyping and hum.MoveDirection.Magnitude > 0 then
                    local moveDir = hum.MoveDirection
                    local horizontalLook = Vector3.new(look.X, 0, look.Z).Unit
                    local horizontalRight = Vector3.new(right.X, 0, right.Z).Unit
                    
                    local forwardAmount = moveDir:Dot(horizontalLook)
                    local rightAmount = moveDir:Dot(horizontalRight)
                    
                    move = (look * forwardAmount) + (right * rightAmount)
                 end
                 
                 -- Vertical Movement Overrides
                 if not isTyping then
                     if UserInputService:IsKeyDown(Enum.KeyCode.Space) or mobileUp then 
                        move += Vector3.new(0,1,0) 
                     end
                     if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or mobileDown then 
                        move -= Vector3.new(0,1,0) 
                     end
                 end
                 
                 local s = flySpeed
                 if not isTyping and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then s = s * 2 end
                 if move.Magnitude > 0 then move = move.Unit * s end

                 BV2.Velocity = move
                 BG2.CFrame = cam
            end
        end
    end

    -- noclip
    if noclip then
        local char = LocalPlayer.Character
        if char then
            for _,part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- =========================
-- GUI toggle & dragging (kept but fixed)
-- =========================
-- =========================
-- DEVICE SELECTION SCRIPT
-- =========================
local GUI_ACTION = "Ruon_Toggle_GUI"
local toggleCooldown = false

local function toggleGUI(actionName,inputState,inputObj)
    if inputState == Enum.UserInputState.Begin and not toggleCooldown then
        toggleCooldown = true
        screenGui.Enabled = not screenGui.Enabled
        task.delay(0.15,function() toggleCooldown = false end)
    end
end

-- dragging (fixed)
do
    local dragging = false
    local dragStart, startPos
    main.Active = true
    main.Draggable = false

    main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- minimize behavior (kept but compact)
local minimized = false
local originalSize = main.Size
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        for _,child in pairs(main:GetChildren()) do
            if child ~= topBar and child ~= subtitle and child ~= mainStroke and child ~= minimizeBtn then
                child.Visible = false
            end
        end
        main.Size = UDim2.new(0,240,0,56)
        minimizeBtn.Text = "+"
    else
        for _,child in pairs(main:GetChildren()) do
            child.Visible = true
        end
        main.Size = originalSize
        minimizeBtn.Text = "-"
    end
end)

-- ensure original features (boost etc.) still available via quick binds:
-- boost: camera forward velocity (kept)
local function doBoost()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Velocity = Camera.CFrame.LookVector * (flySpeed * 6) end
end

-- Add a small quick-boost button in topBar
local boostQuick = Instance.new("TextButton", topBar)
boostQuick.Size = UDim2.new(0,36,0,36)
boostQuick.Position = UDim2.new(1,-102,0,6)
boostQuick.Text = "B"
boostQuick.Font = Enum.Font.GothamBold
boostQuick.TextSize = 18
boostQuick.TextColor3 = Color3.fromRGB(240,240,240)
boostQuick.BackgroundColor3 = Color3.fromRGB(35,35,35)
Instance.new("UICorner", boostQuick).CornerRadius = UDim.new(0,8)
boostQuick.MouseButton1Click:Connect(doBoost)

do
    local startup = Instance.new("ScreenGui", PlayerGui)
    startup.Name = "RuonStartup"
    startup.DisplayOrder = 2000

    local bg = Instance.new("Frame", startup)
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundColor3 = Color3.fromRGB(15,15,20)
    bg.BorderSizePixel = 0

    local center = Instance.new("Frame", bg)
    center.Size = UDim2.new(0,400,0,250)
    center.Position = UDim2.new(0.5,-200,0.5,-125)
    center.BackgroundColor3 = Color3.fromRGB(25,25,30)
    Instance.new("UICorner", center).CornerRadius = UDim.new(0,16)
    Instance.new("UIStroke", center).Color = Color3.fromRGB(60,60,80)

    local topText = Instance.new("TextLabel", center)
    topText.Size = UDim2.new(1,0,0,60)
    topText.Text = "CİHAZINIZI SEÇİN"
    topText.Font = Enum.Font.GothamBold
    topText.TextSize = 24
    topText.TextColor3 = Color3.fromRGB(255,255,255)
    topText.BackgroundTransparency = 1

    local btnPC = Instance.new("TextButton", center)
    btnPC.Size = UDim2.new(0,160,0,80)
    btnPC.Position = UDim2.new(0.1,0,0.4,0)
    btnPC.Text = "💻 PC"
    btnPC.Font = Enum.Font.GothamBold
    btnPC.TextSize = 20
    btnPC.BackgroundColor3 = Color3.fromRGB(40,40,45)
    btnPC.TextColor3 = Color3.fromRGB(240,240,240)
    Instance.new("UICorner", btnPC).CornerRadius = UDim.new(0,12)

    local btnMob = Instance.new("TextButton", center)
    btnMob.Size = UDim2.new(0,160,0,80)
    btnMob.Position = UDim2.new(0.55,0,0.4,0)
    btnMob.Text = "📱 MOBİL"
    btnMob.Font = Enum.Font.GothamBold
    btnMob.TextSize = 20
    btnMob.BackgroundColor3 = Color3.fromRGB(40,40,45)
    btnMob.TextColor3 = Color3.fromRGB(240,240,240)
    Instance.new("UICorner", btnMob).CornerRadius = UDim.new(0,12)

    local function finalize(mode)
        deviceMode = mode
        startup:Destroy()
        screenGui.Enabled = true
        
        if mode == "PC" then
            ContextActionService:BindAction(GUI_ACTION, toggleGUI, false, Enum.KeyCode.Insert)
            ContextActionService:BindAction(GUI_ACTION.."_Home", toggleGUI, false, Enum.KeyCode.Home)
            
            -- Keep old keybinds: t toggles trigger by HotkeyToggle mode
            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    local key = input.KeyCode
                    if key == Enum.KeyCode.T then
                        if HotkeyToggle then
                            triggerEnabled = not triggerEnabled
                        else
                            triggerEnabled = true
                        end
                    end
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    if input.KeyCode == Enum.KeyCode.T and not HotkeyToggle then
                        triggerEnabled = false
                    end
                end
            end)
        else
            -- Create Mobile Toggle Button
            local toggleMob = Instance.new("TextButton", screenGui)
            toggleMob.Size = UDim2.new(0,60,0,60)
            toggleMob.Position = UDim2.new(0,10,0.5,-30)
            toggleMob.BackgroundColor3 = Color3.fromRGB(30,30,35)
            toggleMob.Text = "RUON"
            toggleMob.Font = Enum.Font.GothamBold
            toggleMob.TextSize = 14
            toggleMob.TextColor3 = Color3.fromRGB(240,240,240)
            Instance.new("UICorner", toggleMob).CornerRadius = UDim.new(1,0)
            local str = Instance.new("UIStroke", toggleMob); str.Color = Color3.fromRGB(100,100,120); str.Thickness = 2
            
            -- Draggable for Mobile
            local dragStart, startPos
            local dragging = false
            toggleMob.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    dragStart = input.Position
                    startPos = toggleMob.Position
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
                    local delta = input.Position - dragStart
                    toggleMob.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            toggleMob.MouseButton1Click:Connect(function()
                main.Visible = not main.Visible
            end)
        end
        print("[Ruon] Mod Seçildi: "..mode)
    end

    btnPC.MouseButton1Click:Connect(function() finalize("PC") end)
    btnMob.MouseButton1Click:Connect(function() finalize("Mobil") end)
end

-- Final: print to console to confirm injection
print("[Ruon] Premium GUI injected — bölmeli, kompakt ve hazır.")
