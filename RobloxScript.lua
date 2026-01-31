-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- AUTO EXECUTION
local function AutoExecute()
    if getgenv().KillFarmLoaded then return end
    getgenv().KillFarmLoaded = true

    -- SETTINGS
    local HOP_INTERVAL = 60
    getgenv().LastHopTime = getgenv().LastHopTime or tick()

    getgenv().AutoKill = true
    getgenv().AutoHop = true
    getgenv().NanKill = false
    getgenv().KillCount = 0
    getgenv().WhitelistFriends = true -- NEW: whitelist friends toggle

    -- CHARACTER VARS
    local Character, Humanoid, Hand, Punch
    local LastAttack = 0
    local HitDebounce = {} -- FIXED kill counter debounce

    -- UPDATE CHARACTER
    local function UpdateChar()
        Character = LocalPlayer.Character
        if Character then
            Humanoid = Character:FindFirstChildOfClass("Humanoid")
            Hand = Character:FindFirstChild("LeftHand") or Character:FindFirstChild("Left Arm")
            Punch = Character:FindFirstChild("Punch")
        end
    end

    UpdateChar()
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        UpdateChar()
    end)

    -- WHITELIST FUNCTION
    local function IsWhitelisted(player)
        if not getgenv().WhitelistFriends then return false end
        if player == LocalPlayer then return true
        elseif LocalPlayer:IsFriendsWith(player.UserId) then return true
        else return false
        end
    end

    -- SERVER HOP FUNCTION
    local function HopServer()
        local PlaceId = game.PlaceId
        local JobId = game.JobId
        local Cursor = ""

        while true do
            local Url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?limit=100"
            if Cursor ~= "" then
                Url = Url .. "&cursor=" .. Cursor
            end

            local ok, data = pcall(function()
                return HttpService:JSONDecode(game:HttpGet(Url))
            end)

            if ok and data and data.data then
                for _, server in ipairs(data.data) do
                    if server.id ~= JobId and server.playing < server.maxPlayers then
                        TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer)
                        return
                    end
                end
                Cursor = data.nextPageCursor
                if not Cursor then break end
            else
                break
            end
            task.wait(0.4)
        end
    end

    -- GUI
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.ResetOnSpawn = false

    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, 180, 0, 210)
    main.Position = UDim2.new(0.5, -90, 0.2, 0)
    main.BackgroundColor3 = Color3.fromRGB(25,25,25)

    local titleBar = Instance.new("Frame", main)
    titleBar.Size = UDim2.new(1, 0, 0, 25)
    titleBar.BackgroundColor3 = Color3.fromRGB(50,50,50)

    local titleLabel = Instance.new("TextLabel", titleBar)
    titleLabel.Size = UDim2.new(1, -10, 1, 0)
    titleLabel.Position = UDim2.new(0, 5, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Kill Farm 2.0"
    titleLabel.TextColor3 = Color3.new(1,1,1)
    titleLabel.Font = Enum.Font.Code
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local close = Instance.new("TextButton", titleBar)
    close.Size = UDim2.new(0, 20, 0, 20)
    close.Position = UDim2.new(1, -22, 0, 2)
    close.Text = "X"
    close.Font = Enum.Font.Code
    close.TextColor3 = Color3.new(1,1,1)
    close.BackgroundTransparency = 1

    local killToggle = Instance.new("TextButton", main)
    killToggle.Size = UDim2.new(1, -12, 0, 20)
    killToggle.Position = UDim2.new(0, 6, 0, 30)
    killToggle.Font = Enum.Font.Code
    killToggle.TextSize = 13

    local hopToggle = Instance.new("TextButton", main)
    hopToggle.Size = UDim2.new(1, -12, 0, 20)
    hopToggle.Position = UDim2.new(0, 6, 0, 54)
    hopToggle.Font = Enum.Font.Code
    hopToggle.TextSize = 13

    local nanKillToggle = Instance.new("TextButton", main)
    nanKillToggle.Size = UDim2.new(1, -12, 0, 20)
    nanKillToggle.Position = UDim2.new(0, 6, 0, 78)
    nanKillToggle.Font = Enum.Font.Code
    nanKillToggle.TextSize = 13
    nanKillToggle.TextColor3 = Color3.fromRGB(255, 255, 0)
    nanKillToggle.Text = "Nan Kill: OFF"

    local whitelistToggle = Instance.new("TextButton", main)
    whitelistToggle.Size = UDim2.new(1, -12, 0, 20)
    whitelistToggle.Position = UDim2.new(0, 6, 0, 102)
    whitelistToggle.Font = Enum.Font.Code
    whitelistToggle.TextSize = 13
    whitelistToggle.TextColor3 = Color3.fromRGB(0, 200, 255)

    local killLabel = Instance.new("TextLabel", main)
    killLabel.Size = UDim2.new(1, -12, 0, 20)
    killLabel.Position = UDim2.new(0, 6, 0, 126)
    killLabel.Font = Enum.Font.Code
    killLabel.TextSize = 13
    killLabel.BackgroundTransparency = 1
    killLabel.TextColor3 = Color3.new(1,1,1)

    -- REFRESH GUI
    local function RefreshUI()
        killToggle.Text = "Auto Kill: " .. (getgenv().AutoKill and "ON" or "OFF")
        killToggle.TextColor3 = getgenv().AutoKill and Color3.fromRGB(0,255,0) or Color3.new(1,1,1)

        hopToggle.Text = "Auto Hop: " .. (getgenv().AutoHop and "ON" or "OFF")
        hopToggle.TextColor3 = getgenv().AutoHop and Color3.fromRGB(0,255,0) or Color3.new(1,1,1)

        nanKillToggle.Text = "Nan Kill: " .. (getgenv().NanKill and "ON" or "OFF")
        whitelistToggle.Text = "Whitelist Friends: " .. (getgenv().WhitelistFriends and "ON" or "OFF")
        killLabel.Text = "Kills: " .. getgenv().KillCount
    end

    RefreshUI()

    killToggle.MouseButton1Click:Connect(function()
        getgenv().AutoKill = not getgenv().AutoKill
        RefreshUI()
    end)

    hopToggle.MouseButton1Click:Connect(function()
        getgenv().AutoHop = not getgenv().AutoHop
        RefreshUI()
    end)

    nanKillToggle.MouseButton1Click:Connect(function()
        getgenv().NanKill = not getgenv().NanKill
        RefreshUI()
    end)

    whitelistToggle.MouseButton1Click:Connect(function()
        getgenv().WhitelistFriends = not getgenv().WhitelistFriends
        RefreshUI()
    end)

    close.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    -- DRAG
    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = i.Position
            startPos = main.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- NAN KILL FUNCTION
    local function ApplyNanMode()
        if not Character or not Humanoid then return end

        for _, part in pairs(Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.Size = part.Size * 0.2
            end
        end

        Humanoid.HipHeight = Humanoid.HipHeight * 0.2
        Humanoid.WalkSpeed = 16
        Humanoid.JumpPower = 50

        local egg = LocalPlayer.Backpack:FindFirstChild("Protein Egg")
        if egg then Humanoid:EquipTool(egg) end

        local punchTool = LocalPlayer.Backpack:FindFirstChild("Punch") or Character:FindFirstChild("Punch")
        if punchTool then Humanoid:EquipTool(punchTool) end
    end

    -- MAIN LOOP
    RunService.Heartbeat:Connect(function()
        local now = tick()

        if getgenv().AutoHop and now - getgenv().LastHopTime >= HOP_INTERVAL then
            getgenv().LastHopTime = now
            HopServer()
            return
        end

        if getgenv().NanKill then ApplyNanMode() end

        if not getgenv().AutoKill then return end
        if not Character or not Humanoid then UpdateChar() return end

        if not Punch then
            local tool = LocalPlayer.Backpack:FindFirstChild("Punch")
            if tool then
                Humanoid:EquipTool(tool)
                Punch = Character:FindFirstChild("Punch")
            end
            return
        end

        if now - LastAttack < 0.05 then return end
        LastAttack = now

        Punch.attackTime.Value = 0
        Punch:Activate()

        for _, p in ipairs(Players:GetPlayers()) do
            if not IsWhitelisted(p) and p.Character then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local head = p.Character:FindFirstChild("Head")
                local root = p.Character:FindFirstChild("HumanoidRootPart")

                if hum and head and root and hum.Health > 0 then
                    firetouchinterest(head, Hand, 0)
                    firetouchinterest(head, Hand, 1)
                end

                if hum and hum.Health <= 0 and not HitDebounce[p] then
                    HitDebounce[p] = true
                    getgenv().KillCount += 1
                    RefreshUI()

                    p.CharacterAdded:Connect(function()
                        HitDebounce[p] = nil
                    end)
                end
            end
        end
    end)

    -- ANTI AFK
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)

    print("✅ Kill Farm 2.0 auto-executed with whitelist")
end

-- RUN AUTO EXECUTE
AutoExecute()
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    AutoExecute()
end)