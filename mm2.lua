--[[
    MM2 GOD V20.0 [PREMIUM]
    - Robust GUI (Right Control to Toggle)
    - Stable Touch Fling
    - Advanced ESP & AimBot
    - All features default to OFF
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CLEANUP SYSTEM
pcall(function()
    _G.MM2_ACTIVE = false
    if _G.MM2_HB then _G.MM2_HB:Disconnect() end
    
    local function clean(p)
        if not p then return end
        for _, v in pairs(p:GetChildren()) do
            if v.Name:match("MM2_") or v.Name:match("V20_") then v:Destroy() end
        end
    end
    pcall(function() clean(game:GetService("CoreGui")) end)
    pcall(function() clean(LocalPlayer:FindFirstChild("PlayerGui")) end)
    
    if _G.MM2_DRAWINGS then
        for _, v in pairs(_G.MM2_DRAWINGS) do pcall(function() v:Remove() end) end
    end
end)

_G.MM2_ACTIVE = true
_G.MM2_DRAWINGS = {}
local function track(obj) 
    if obj then 
        table.insert(_G.MM2_DRAWINGS, obj) 
    end
    return obj 
end

local function safeDrawing(type)
    local obj
    pcall(function()
        obj = Drawing.new(type)
    end)
    return track(obj)
end

-- CONFIG (Defaults: OFF)
local Config = {
    ESP = false,
    ESP_Box = false,
    ESP_Tracers = false,
    ESP_Names = false,
    SilentAim = false,
    Aim_FOV = 150,
    ShowFOV = false,
    KillAura = false,
    Fly = false,
    FlySpeed = 50,
    SpeedEnabled = false,
    WalkSpeed = 50,
    JumpEnabled = false,
    JumpPower = 65,
    AutoFarm = false,
    AutoGrab = false,
    Noclip = false,
    TouchFling = false,
    FlingPower = 10000,
    AuraFling = false,
    TargetName = "",
    FlingTarget = false
}

-- ROLE DETECTION
local function getMurderer()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then return p end
    end
    return nil
end

local function getRole(p)
    if not p or not p.Character then return "Innocent" end
    if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then return "Murderer" end
    if p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Hero") or p.Character:FindFirstChild("Hero") then return "Sheriff" end
    return "Innocent"
end

-- UI BUILDER
-- UI BUILDER (ULTIMATELY ROBUST)
local function BuildUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "MM2_V20_UI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    gui.DisplayOrder = 999
    gui.IgnoreGuiInset = true
    
    -- Recursive Parenting (The most robust way)
    local function parentGui()
        local core = game:GetService("CoreGui")
        local gethui = gethui or function() return nil end
        
        local success = pcall(function() gui.Parent = gethui() end)
        if not success or not gui.Parent then
            success = pcall(function() gui.Parent = core end)
        end
        if not success or not gui.Parent then
            gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
    end
    parentGui()

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 480, 0, 400)
    Main.Position = UDim2.new(0.5, -240, 0.5, -200)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = false -- Using custom drag
    Main.ZIndex = 100
    Main.Parent = gui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = Color3.fromRGB(255, 30, 30)
    Stroke.Thickness = 2
    Stroke.ZIndex = 101

    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 50)
    Header.BackgroundTransparency = 1
    Header.ZIndex = 110

    local Title = Instance.new("TextLabel", Header)
    Title.Text = "MM2 GOD V20 [PREMIUM]"
    Title.Size = UDim2.new(1, -60, 1, 0)
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 111

    local Close = Instance.new("TextButton", Header)
    Close.Size = UDim2.new(0, 30, 0, 30)
    Close.Position = UDim2.new(1, -40, 0.5, -15)
    Close.Text = "X"
    Close.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Close.TextColor3 = Color3.new(1, 1, 1)
    Close.Font = Enum.Font.GothamBold
    Close.ZIndex = 112
    Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 6)
    Close.MouseButton1Click:Connect(function() Main.Visible = false end)

    -- Custom Drag
    local dragInput, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragStart then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragStart = nil end end)

    local DragArea = Header

    local MainScroll = Instance.new("ScrollingFrame", Main)
    MainScroll.Name = "MainScroll"
    MainScroll.Size = UDim2.new(1, -20, 1, -70)
    MainScroll.Position = UDim2.new(0, 10, 0, 60)
    MainScroll.BackgroundTransparency = 1
    MainScroll.BorderSizePixel = 0
    MainScroll.ScrollBarThickness = 3
    MainScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 30, 30)
    MainScroll.ZIndex = 120
    MainScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

    local List = Instance.new("UIListLayout", MainScroll)
    List.Padding = UDim.new(0, 8)
    List.HorizontalAlignment = Enum.HorizontalAlignment.Center
    List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        MainScroll.CanvasSize = UDim2.new(0, 0, 0, List.AbsoluteContentSize.Y + 10)
    end)

    local function createSection(name)
        local h = Instance.new("TextLabel", MainScroll)
        h.Size = UDim2.new(0.95, 0, 0, 30)
        h.BackgroundTransparency = 1
        h.Text = "--- " .. name .. " ---"
        h.TextColor3 = Color3.fromRGB(255, 30, 30)
        h.Font = Enum.Font.GothamBold
        h.TextSize = 14
        h.ZIndex = 125
    end

    local function createToggle(name, key)
        local b = Instance.new("TextButton", MainScroll)
        b.Size = UDim2.new(0.95, 0, 0, 42)
        b.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
        b.Text = "  " .. name
        b.TextColor3 = Color3.fromRGB(180, 180, 180)
        b.Font = Enum.Font.GothamSemibold
        b.TextSize = 14
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.ZIndex = 130
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        
        local s = Instance.new("Frame", b)
        s.Size = UDim2.new(0, 32, 0, 16)
        s.Position = UDim2.new(1, -42, 0.5, -8)
        s.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        s.ZIndex = 131
        Instance.new("UICorner", s).CornerRadius = UDim.new(1, 0)

        local d = Instance.new("Frame", s)
        d.Size = UDim2.new(0, 12, 0, 12)
        d.Position = UDim2.new(0, 2, 0.5, -6)
        d.BackgroundColor3 = Color3.new(1, 1, 1)
        d.ZIndex = 132
        Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)

        local function up()
            local a = Config[key]
            TweenService:Create(s, TweenInfo.new(0.3), {BackgroundColor3 = a and Color3.fromRGB(255, 30, 30) or Color3.fromRGB(45, 45, 50)}):Play()
            TweenService:Create(d, TweenInfo.new(0.3), {Position = a and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}):Play()
            b.TextColor3 = a and Color3.new(1, 1, 1) or Color3.fromRGB(180, 180, 180)
        end
        b.MouseButton1Click:Connect(function() Config[key] = not Config[key]; up() end)
        up()
    end

    local function createSlider(name, key, min, max)
        local f = Instance.new("Frame", MainScroll)
        f.Size = UDim2.new(0.95, 0, 0, 60)
        f.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
        f.ZIndex = 130
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)

        local l = Instance.new("TextLabel", f)
        l.Size = UDim2.new(1, -20, 0, 25)
        l.Position = UDim2.new(0, 12, 0, 8)
        l.BackgroundTransparency = 1
        l.Text = name .. ": " .. Config[key]
        l.TextColor3 = Color3.new(1, 1, 1)
        l.Font = Enum.Font.GothamSemibold
        l.TextSize = 13
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.ZIndex = 131

        local bg = Instance.new("Frame", f)
        bg.Size = UDim2.new(1, -24, 0, 4)
        bg.Position = UDim2.new(0, 12, 0, 40)
        bg.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        bg.ZIndex = 131
        Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
        
        local fill = Instance.new("Frame", bg)
        fill.Size = UDim2.new((Config[key] - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
        fill.ZIndex = 132
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

        local btn = Instance.new("TextButton", bg)
        btn.Size = UDim2.new(0, 14, 0, 14)
        btn.Position = UDim2.new((Config[key] - min) / (max - min), -7, 0.5, -7)
        btn.BackgroundColor3 = Color3.new(1, 1, 1)
        btn.Text = ""
        btn.ZIndex = 133
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

        local draggingSlider = false
        local function update(input)
            local p = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
            local v = math.floor(min + (max - min) * p)
            Config[key] = v
            l.Text = name .. ": " .. v
            fill.Size = UDim2.new(p, 0, 1, 0)
            btn.Position = UDim2.new(p, -7, 0.5, -7)
        end
        btn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = true end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end end)
        UserInputService.InputChanged:Connect(function(i) if draggingSlider and i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end end)
    end

    local function createInput(name, key, placeholder)
        local f = Instance.new("Frame", MainScroll)
        f.Size = UDim2.new(0.95, 0, 0, 42)
        f.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
        f.ZIndex = 130
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)

        local l = Instance.new("TextLabel", f)
        l.Size = UDim2.new(0.4, 0, 1, 0)
        l.Position = UDim2.new(0, 12, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = name
        l.TextColor3 = Color3.new(1, 1, 1)
        l.Font = Enum.Font.GothamSemibold
        l.TextSize = 13
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.ZIndex = 131

        local box = Instance.new("TextBox", f)
        box.Size = UDim2.new(0.5, -12, 0.7, 0)
        box.Position = UDim2.new(0.5, 0, 0.15, 0)
        box.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        box.Text = Config[key]
        box.PlaceholderText = placeholder
        box.TextColor3 = Color3.new(1, 1, 1)
        box.Font = Enum.Font.Gotham
        box.TextSize = 13
        box.ClearTextOnFocus = false
        box.ZIndex = 131
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

        box.FocusLost:Connect(function()
            Config[key] = box.Text
        end)
    end

    createSection("Combat")
    createToggle("SILENT AIMBOT", "SilentAim")
    createToggle("SHOW AIM FOV", "ShowFOV")
    createSlider("Aim FOV Radius", "Aim_FOV", 50, 800)
    createToggle("MURDERER KILL AURA", "KillAura")
    createToggle("TOUCH FLING (STABLE)", "TouchFling")
    createSlider("Fling Power", "FlingPower", 1000, 100000)
    createToggle("AURA FLING (MURDERER)", "AuraFling")
    createToggle("TARGET FLING TROLL", "FlingTarget")
    createInput("Target Name", "TargetName", "Partial Player Name")

    createSection("Visuals")
    createToggle("PLAYER HIGHLIGHT ESP", "ESP")
    createToggle("BOX ESP (2D)", "ESP_Box")
    createToggle("SNAPLINE TRACERS", "ESP_Tracers")
    createToggle("SHOW PLAYER NAMES", "ESP_Names")

    createSection("Movement")
    createToggle("ULTRA FLIGHT", "Fly")
    createSlider("Flight Speed", "FlySpeed", 10, 250)
    createToggle("SPEED HACK", "SpeedEnabled")
    createSlider("Walk Speed", "WalkSpeed", 16, 300)
    createToggle("JUMP HACK", "JumpEnabled")
    createSlider("Jump Power", "JumpPower", 50, 350)
    createToggle("NOCLIP (Wallhack)", "Noclip")

    createSection("Misc")
    createToggle("AUTO COIN FARM", "AutoFarm")
    createToggle("AUTO ITEM PICKUP", "AutoGrab")

    UserInputService.InputBegan:Connect(function(i, g)
        if not g and i.KeyCode == Enum.KeyCode.RightControl then Main.Visible = not Main.Visible end
    end)
end

-- COMBAT & ESP SETUP
local FOVCircle = safeDrawing("Circle")
if FOVCircle then
    FOVCircle.Thickness = 2
    FOVCircle.NumSides = 64
    FOVCircle.Color = Color3.fromRGB(255, 30, 30)
    FOVCircle.Filled = false
    FOVCircle.Transparency = 1
end

local function GetClosestToMouse()
    local target, dist = nil, Config.Aim_FOV
    local murd = getMurderer()
    if murd and murd.Character and murd.Character:FindFirstChild("HumanoidRootPart") then
        local hum = murd.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            local pos, visible = Camera:WorldToViewportPoint(murd.Character.HumanoidRootPart.Position)
            if visible then
                local mag = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if mag < dist then target = murd end
            end
        end
    end
    return target
end

local lastShot = 0

-- HEARTBEAT LOOP
_G.MM2_HB = RunService.Heartbeat:Connect(function()
    if not _G.MM2_ACTIVE then _G.MM2_HB:Disconnect() return end
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        if FOVCircle then
            FOVCircle.Visible = Config.ShowFOV and Config.SilentAim
            FOVCircle.Radius = Config.Aim_FOV
            FOVCircle.Position = UserInputService:GetMouseLocation()
        end

        hum.WalkSpeed = Config.SpeedEnabled and Config.WalkSpeed or 16
        hum.JumpPower = Config.JumpEnabled and Config.JumpPower or 50

        if Config.Fly then
            hrp.Velocity = Vector3.new(0, 0.1, 0)
            local mX = (UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0)
            local mZ = (UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0)
            local move = (Camera.CFrame.RightVector * mX) + (Camera.CFrame.LookVector * -mZ)
            local spd = Config.FlySpeed / 10
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then hrp.CFrame = hrp.CFrame * CFrame.new(0, spd, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then hrp.CFrame = hrp.CFrame * CFrame.new(0, -spd, 0) end
            if move.Magnitude > 0 then hrp.CFrame = hrp.CFrame + (move.Unit * spd) end
        end

        if Config.Noclip then
            for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
        end

        -- Touch Fling is now handled in a dedicated thread below

        -- AimBot & KillAura (FIXED LOGIC)
        if Config.SilentAim and (getRole(LocalPlayer) == "Sheriff" or getRole(LocalPlayer) == "Hero") then
            if tick() - lastShot > 0.2 then
                local t = GetClosestToMouse()
                if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                    local shoot = ReplicatedStorage:FindFirstChild("ShootGun", true) or ReplicatedStorage:FindFirstChild("MainEvent", true)
                    if shoot then 
                        lastShot = tick()
                        local args = {
                            Target = t.Character.HumanoidRootPart, 
                            Pos = t.Character.HumanoidRootPart.Position + Vector3.new(0, 0.5, 0) -- Slight upward aim
                        }
                        if shoot:IsA("RemoteEvent") then shoot:FireServer(args)
                        else shoot:InvokeServer(args) end
                    end
                end
            end
        end
        if Config.KillAura and getRole(LocalPlayer) == "Murderer" then
            local knife = char:FindFirstChild("Knife")
            if knife then
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        if (hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude < 18 then
                            local r = knife:FindFirstChild("Attack") or knife:FindFirstChild("KnifeServer", true) or ReplicatedStorage:FindFirstChild("KnifeServer", true) or ReplicatedStorage:FindFirstChild("Slash", true)
                            if r then 
                                if r:IsA("RemoteEvent") then r:FireServer(p.Character.HumanoidRootPart.Position) 
                                else r:InvokeServer(p.Character.HumanoidRootPart.Position) end 
                            end
                        end
                    end
                end
            end
        end
    end)
end)

-- ESP SYSTEM
local function CreateESP(p)
    local tracer = safeDrawing("Line")
    local name = safeDrawing("Text")
    local box = safeDrawing("Square")
    RunService.RenderStepped:Connect(function()
        if not _G.MM2_ACTIVE or not p.Character or not p.Parent then
            if tracer then tracer.Visible = false end
            if name then name.Visible = false end
            if box then box.Visible = false end
            return
        end
        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then 
            if tracer then tracer.Visible = false end
            if name then name.Visible = false end
            if box then box.Visible = false end
            return 
        end
        
        local pos, vis = Camera:WorldToViewportPoint(hrp.Position)
        local role = getRole(p)
        local color = role == "Murderer" and Color3.new(1,0,0) or (role == "Sheriff" and Color3.new(0,0.5,1) or Color3.new(0,1,0))
        
        if tracer then
            tracer.Visible = Config.ESP_Tracers and vis
            tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            tracer.To = Vector2.new(pos.X, pos.Y)
            tracer.Color = color
        end

        if name then
            name.Visible = Config.ESP_Names and vis
            name.Text = p.Name .. " [" .. role .. "]"
            name.Position = Vector2.new(pos.X, pos.Y - 40)
            name.Color = color
            name.Center = true
            name.Outline = true
        end

        if box then
            box.Visible = Config.ESP_Box and vis
            box.Size = Vector2.new(2000 / pos.Z, 2500 / pos.Z)
            box.Position = Vector2.new(pos.X - box.Size.X/2, pos.Y - box.Size.Y/2)
            box.Color = color
        end

        local h = p.Character:FindFirstChild("V20_ESP")
        if Config.ESP then
            if not h then h = Instance.new("Highlight", p.Character); h.Name = "V20_ESP" end
            h.FillColor = color
        elseif h then h:Destroy() end
    end)
end

Players.PlayerAdded:Connect(CreateESP)
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end

-- TOUCH FLING (VIP FRAME-PERFECT)
task.spawn(function()
    local hrp, c, vel, movel = nil, nil, nil, 0.1
    while true do
        if not _G.MM2_ACTIVE then break end
        RunService.Heartbeat:Wait()
        if Config.TouchFling then
            pcall(function()
                while Config.TouchFling and not (c and c.Parent and hrp and hrp.Parent) do
                    RunService.Heartbeat:Wait()
                    c = LocalPlayer.Character
                    hrp = c and c:FindFirstChild("HumanoidRootPart")
                    if not _G.MM2_ACTIVE then break end
                end

                if Config.TouchFling then
                    local fp = Config.FlingPower
                    vel = hrp.Velocity
                    hrp.Velocity = vel * fp + Vector3.new(0, fp, 0)
                    RunService.RenderStepped:Wait()
                    if c and c.Parent and hrp and hrp.Parent then
                        hrp.Velocity = vel
                    end
                    RunService.Stepped:Wait()
                    if c and c.Parent and hrp and hrp.Parent then
                        hrp.Velocity = vel + Vector3.new(0, movel, 0)
                        movel = movel * -1
                    end
                end
            end)
        elseif Config.AuraFling then
            pcall(function()
                while Config.AuraFling and not (c and c.Parent and hrp and hrp.Parent) do
                    RunService.Heartbeat:Wait()
                    c = LocalPlayer.Character
                    hrp = c and c:FindFirstChild("HumanoidRootPart")
                    if not _G.MM2_ACTIVE then break end
                end

                if Config.AuraFling then
                    local murd = getMurderer()
                    if murd and murd.Character and murd.Character:FindFirstChild("HumanoidRootPart") then
                        local targetHrp = murd.Character.HumanoidRootPart
                        local targetHum = murd.Character:FindFirstChildOfClass("Humanoid")
                        if targetHum and targetHum.Health > 0 and (targetHrp.Position - hrp.Position).Magnitude > 5 then
                            local fp = Config.FlingPower
                            local oldCFrame = hrp.CFrame
                            vel = hrp.Velocity
                            
                            -- Heartbeat: Apply velocity and jump into target (offsetting slightly above to avoid blade but ensure collision)
                            hrp.Velocity = vel * fp + Vector3.new(0, fp, 0)
                            hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 1.5, 0)
                            
                            -- RenderStepped: Reset visually
                            RunService.RenderStepped:Wait()
                            if c and c.Parent and hrp and hrp.Parent then
                                hrp.Velocity = vel
                                hrp.CFrame = oldCFrame
                            end
                            
                            -- Stepped
                            RunService.Stepped:Wait()
                            if c and c.Parent and hrp and hrp.Parent then
                                hrp.Velocity = vel + Vector3.new(0, movel, 0)
                                movel = movel * -1
                            end
                        end
                    end
                end
            end)
        elseif Config.FlingTarget and Config.TargetName ~= "" then
            pcall(function()
                while Config.FlingTarget and Config.TargetName ~= "" and not (c and c.Parent and hrp and hrp.Parent) do
                    RunService.Heartbeat:Wait()
                    c = LocalPlayer.Character
                    hrp = c and c:FindFirstChild("HumanoidRootPart")
                    if not _G.MM2_ACTIVE then break end
                end

                if Config.FlingTarget and Config.TargetName ~= "" then
                    local targetPlayer = nil
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and string.find(string.lower(p.Name), string.lower(Config.TargetName)) or string.find(string.lower(p.DisplayName), string.lower(Config.TargetName)) then
                            targetPlayer = p
                            break
                        end
                    end
                    
                    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local targetHrp = targetPlayer.Character.HumanoidRootPart
                        local targetHum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
                        if targetHum and targetHum.Health > 0 and (targetHrp.Position - hrp.Position).Magnitude > 5 then
                            local fp = Config.FlingPower
                            local oldCFrame = hrp.CFrame
                            vel = hrp.Velocity
                            
                            -- Heartbeat
                            hrp.Velocity = vel * fp + Vector3.new(0, fp, 0)
                            hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 1.5, 0)
                            
                            -- RenderStepped
                            RunService.RenderStepped:Wait()
                            if c and c.Parent and hrp and hrp.Parent then
                                hrp.Velocity = vel
                                hrp.CFrame = oldCFrame
                            end
                            
                            -- Stepped
                            RunService.Stepped:Wait()
                            if c and c.Parent and hrp and hrp.Parent then
                                hrp.Velocity = vel + Vector3.new(0, movel, 0)
                                movel = movel * -1
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- FARMING
task.spawn(function()
    while task.wait(0.5) do
        if not _G.MM2_ACTIVE then break end
        pcall(function()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            if Config.AutoFarm then
                local c = workspace:FindFirstChild("CoinContainer", true) or workspace:FindFirstChild("Coins", true)
                local t = c and c:FindFirstChildOfClass("Part")
                if t then hrp.CFrame = t.CFrame * CFrame.new(0, 1, 0) end
            end
            if Config.AutoGrab then
                local g = workspace:FindFirstChild("GunDrop") or workspace:FindFirstChild("DroppedGun")
                if g then hrp.CFrame = g.CFrame end
            end
        end)
    end
end)

BuildUI()
game:GetService("StarterGui"):SetCore("SendNotification", {Title = "[MM2 PREMIUM]", Text = "Right Control to toggle.", Duration = 5})
