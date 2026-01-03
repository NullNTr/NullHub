// Variables used by Scriptable.
// These must be at the very top of the file. Do not edit.
// icon-color: purple; icon-glyph: magic;
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🌠 Null Hub",
    LoadingTitle = "V̷̅̿͆̈́͘ö̸́͋̽̍͘i̷̐̀͋̕d̸̈́̅̄͠ ̷̈́͆͝H̷̍̀̕u̸̔͋b̷",
    LoadingSubtitle = "100%",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ArsenalSmoothFull"
    },
    KeySystem = false
})

local AntiTab     = Window:CreateTab("Players", "shield")
local CombatTab   = Window:CreateTab("Combats", "sword")
local AutoTab = Window:CreateTab("Auto Farm", "user")
local ESPTab      = Window:CreateTab("ESP", "eye")
local TrollTab    = Window:CreateTab("Trolls", "skull")
local TeleportTab = Window:CreateTab("Teleports", "map-pin")
local DiscordTab  = Window:CreateTab("Info", "info")

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Settings
local MovementSettings = {
    Enabled = false,            
    WalkspeedEnabled = false,   
    WalkspeedValue = 50,      
    JumpPowerEnabled = true,
    JumpPowerValue = 300,
    NoclipEnabled = false,
    Connections = {}
}

-- Utils
local function GetCharacterParts(character)
    local char = character or LocalPlayer.Character
    if not char then return nil, nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return hum, hrp
end

-- WalkSpeed
local ACCEL = 50
local currentSpeed = 0

local function EnableSpeed()
    local hum, hrp = GetCharacterParts()
    if not hum or not hrp then return end

    hum.WalkSpeed = 16  -- WalkSpeedは低めにセット（キック回避のため）

    if MovementSettings.Connections.Speed then
        MovementSettings.Connections.Speed:Disconnect()
    end

    MovementSettings.Connections.Speed = RunService.Heartbeat:Connect(function()
        if not MovementSettings.Enabled then return end

        if hum.MoveDirection.Magnitude == 0 then
            currentSpeed = math.max(0, currentSpeed - ACCEL * 2)
        else
            currentSpeed = math.clamp(currentSpeed + ACCEL, 0, MovementSettings.WalkspeedValue)
        end

        hrp.Velocity = hum.MoveDirection * currentSpeed + Vector3.new(0, hrp.Velocity.Y, 0)
    end)
end

local function DisableSpeed()
    if MovementSettings.Connections.Speed then
        MovementSettings.Connections.Speed:Disconnect()
        MovementSettings.Connections.Speed = nil
    end

    local hum, _ = GetCharacterParts()
    if hum then
        hum.WalkSpeed = 16 
    end
    currentSpeed = 0
end

-- Jump Power
local function OnStateChanged(oldState, newState)
    if not MovementSettings.JumpPowerEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if newState == Enum.HumanoidStateType.Jumping then
        hum.JumpPower = math.clamp(MovementSettings.JumpPowerValue, 0, 1000)
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = Vector3.new(hrp.Velocity.X, hrp.Velocity.Y + MovementSettings.JumpPowerValue * 0.5, hrp.Velocity.Z)
        end
    elseif newState == Enum.HumanoidStateType.Landed or newState == Enum.HumanoidStateType.Freefall then
        hum.JumpPower = 50
    end
end

local function SetupCharacter(character)
    local hum = character:WaitForChild("Humanoid")
    hum.StateChanged:Connect(OnStateChanged)
end

-- Noclip
local function ToggleNoclip(state)
    MovementSettings.NoclipEnabled = state

    if MovementSettings.Connections.Noclip then
        MovementSettings.Connections.Noclip:Disconnect()
        MovementSettings.Connections.Noclip = nil
    end

    if state then
        MovementSettings.Connections.Noclip =
            RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
    else
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- CharacterAdded
LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.3)

    SetupCharacter(character)

    local hum, _ = GetCharacterParts(character)
    if hum then
        if MovementSettings.JumpPowerEnabled then
            hum.JumpPower = math.clamp(MovementSettings.JumpPowerValue, 0, 300)
        else
            hum.JumpPower = 50
        end
    end

    if MovementSettings.Enabled then
        EnableSpeed()
    else
        DisableSpeed()
    end

    if MovementSettings.NoclipEnabled then
        ToggleNoclip(true)
    else
        ToggleNoclip(false)
    end
end)

if LocalPlayer.Character then
    SetupCharacter(LocalPlayer.Character)

    if MovementSettings.Enabled then
        EnableSpeed()
    end

    if MovementSettings.NoclipEnabled then
        ToggleNoclip(true)
    end
end


-- Players Button
AntiTab:CreateSection("Players")

AntiTab:CreateToggle({
    Name = "Speed Boost",
    CurrentValue = false,
    Callback = function(v)
        MovementSettings.Enabled = v
        if v then
            EnableSpeed()
        else
            DisableSpeed()
        end
    end
})

AntiTab:CreateSlider({
    Name = "Speed Boost",
    Range = {1, 500},
    Increment = 1,
    CurrentValue = MovementSettings.WalkspeedValue,
    Callback = function(v)
        MovementSettings.WalkspeedValue = v
        if MovementSettings.Enabled then
            EnableSpeed()
        end
    end
})

AntiTab:CreateToggle({
    Name = "Jump Power",
    CurrentValue = MovementSettings.JumpPowerEnabled,
    Callback = function(state)
        MovementSettings.JumpPowerEnabled = state
    end
})

AntiTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 1000},
    Increment = 10,
    CurrentValue = MovementSettings.JumpPowerValue,
    Callback = function(value)
        MovementSettings.JumpPowerValue = value
    end
})

AntiTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = MovementSettings.NoclipEnabled,
    Callback = function(state)
        ToggleNoclip(state)
    end
})

local RagdollEnabled = false
local RagdollConstraints = {}

local function EnableRagdoll()
    local char = game.Players.LocalPlayer.Character
    if not char then return end

    for _, m in pairs(char:GetDescendants()) do
        if m:IsA("Motor6D") then
            local a0 = Instance.new("Attachment", m.Part0)
            local a1 = Instance.new("Attachment", m.Part1)

            a0.CFrame = m.C0
            a1.CFrame = m.C1

            local ball = Instance.new("BallSocketConstraint")
            ball.Attachment0 = a0
            ball.Attachment1 = a1
            ball.Parent = m.Part0

            table.insert(RagdollConstraints, {m, a0, a1, ball})
            m.Enabled = false
        end
    end
end

local function DisableRagdoll()
    for _, data in pairs(RagdollConstraints) do
        local motor, a0, a1, ball = unpack(data)
        if motor then motor.Enabled = true end
        if a0 then a0:Destroy() end
        if a1 then a1:Destroy() end
        if ball then ball:Destroy() end
    end
    table.clear(RagdollConstraints)
end

AntiTab:CreateToggle({
    Name = "Ragdoll",
    CurrentValue = false,
    Callback = function(state)
        RagdollEnabled = state
        if state then
            EnableRagdoll()
        else
            DisableRagdoll()
        end
    end
})

AntiTab:CreateButton({
    Name = "Respown",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = 0
        end
    end
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- 共通関数
local function GetHRP(char)
	return char and char:FindFirstChild("HumanoidRootPart")
end

-- Aim Lock
CombatTab:CreateSection("Kill")

local KillLabel = CombatTab:CreateLabel("Kill: 0")
local BaseKillCount = 0 
local LastKillCount = 0
local KillValueConnection 

local function UpdateKills()
	if LocalPlayer:FindFirstChild("leaderstats")
	and LocalPlayer.leaderstats:FindFirstChild("Kills") then
		local currentKills = LocalPlayer.leaderstats.Kills.Value
		local displayKills = currentKills - BaseKillCount
		if displayKills < 0 then
			displayKills = 0
		end
		KillLabel:Set("キル数: " .. displayKills)
		
		if currentKills > LastKillCount then
			LastKillCount = currentKills
			
			if CombatTab.Notify then
				CombatTab.Notify({
					Title = "キル通知",
					Content = "キル数が " .. displayKills .. " に増えました！",
					Duration = 3
				})
			else
				print("キル通知: キル数が " .. displayKills .. " に増えました！")
			end
		end
	else
		KillLabel:Set("キル数: N/A")
	end
end

local function ConnectKills()
	if KillValueConnection then
		KillValueConnection:Disconnect()
		KillValueConnection = nil
	end
	
	if LocalPlayer:FindFirstChild("leaderstats")
	and LocalPlayer.leaderstats:FindFirstChild("Kills") then
		local kills = LocalPlayer.leaderstats.Kills
		BaseKillCount = kills.Value -- 基準キル数をここで取得
		LastKillCount = BaseKillCount
		UpdateKills()
		KillValueConnection = kills:GetPropertyChangedSignal("Value"):Connect(UpdateKills)
	end
end

LocalPlayer.ChildAdded:Connect(function(child)
	if child.Name == "leaderstats" then
		local kills = child:WaitForChild("Kills", 5)
		if kills then
			ConnectKills()
		end
	end
end)

ConnectKills()

CombatTab:CreateSection("Aimbot")

local CombatMessage = "Aimbot"

CombatTab:CreateLabel(CombatMessage)

local AimEnabled = false
local AimTargetName = nil
local AimSmoothness = 0.25

CombatTab:CreateDropdown({
	Name = "Aimbot Target",
	Options = (function()
		local t = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer then
				table.insert(t, p.Name)
			end
		end
		return t
	end)(),
	CurrentOption = {},
	Callback = function(v)
		AimTargetName = (type(v) == "table") and v[1] or v
	end
})

-- プレイヤー一覧
local function GetOtherPlayerNames()
	local t = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			table.insert(t, p.Name)
		end
	end
	return t
end

CombatTab:CreateToggle({
	Name = "Aimbot",
	CurrentValue = false,
	Callback = function(v)
		AimEnabled = v
	end
})

getgenv().SilentAimRunning = getgenv().SilentAimRunning or false

CombatTab:CreateToggle({
	Name = "Silent Aim",
	CurrentValue = false,
	Callback = function(state)
		local Players = game:GetService("Players")
		local LocalPlayer = Players.LocalPlayer

		if state then

			if getgenv().SilentAimRunning then
				return
			end

			getgenv().SilentAimRunning = true

			local success, err = pcall(function()
				local src = game:HttpGet("https://pastefy.app/05x2AvVC/raw")
				loadstring(src)()
			end)

			if not success then
				warn("SilentAim 起動エラー:", err)
				getgenv().SilentAimRunning = false
			end

		else

			getgenv().SilentAimRunning = false

			local gui = LocalPlayer:FindFirstChild("PlayerGui")
			if gui then
				local g = gui:FindFirstChild("SilentAimGui")
				if g then
					g:Destroy()
				end
			end
		end
	end
})

-- Auto Farm
AutoTab:CreateSection("Auto Farm")

local BackLockEnabled = false
local BackLockAllEnabled = false
local BackLockTargetName = nil

local BackLockDistance = 2.5
local BackLockRange = 150
local BackLockSmoothness = 0.25

AutoTab:CreateToggle({
	Name = "Auto Farm",
	CurrentValue = false,
	Callback = function(v)
		BackLockEnabled = v
	end
})

AutoTab:CreateToggle({
	Name = "Auto Farm All",
	CurrentValue = false,
	Callback = function(v)
		BackLockAllEnabled = v
	end
})

AutoTab:CreateDropdown({
	Name = "Auto Farm Target",
	Options = (function()
		local t = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer then
				table.insert(t, p.Name)
			end
		end
		return t
	end)(),
	CurrentOption = {},
	Callback = function(v)
		BackLockTargetName = (type(v) == "table") and v[1] or v
	end
})

AutoTab:CreateSlider({
	Name = "Auto Farm Distance",
	Range = {1, 8},
	Increment = 0.5,
	Suffix = "stud",
	CurrentValue = 2.5,
	Callback = function(v)
		BackLockDistance = v
	end
})

local function GetNearestEnemy(myHRP)
	local nearestHRP = nil
	local nearestDist = math.huge

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			local hrp = GetHRP(p.Character)
			local hum = p.Character:FindFirstChild("Humanoid")
			if hrp and hum and hum.Health > 0 then
				local d = (myHRP.Position - hrp.Position).Magnitude
				if d < nearestDist and d <= BackLockRange then
					nearestDist = d
					nearestHRP = hrp
				end
			end
		end
	end

	return nearestHRP
end

RunService.RenderStepped:Connect(function()
	local char = LocalPlayer.Character
	if not char then return end

	local myHRP = GetHRP(char)
	if not myHRP then return end

	if AimEnabled and AimTargetName then
		local target = Players:FindFirstChild(AimTargetName)
		if target and target.Character then
			local tHRP = GetHRP(target.Character)
			if tHRP then
				Camera.CFrame = Camera.CFrame:Lerp(
					CFrame.lookAt(Camera.CFrame.Position, tHRP.Position),
					AimSmoothness
				)
			end
		end
	end

	local targetHRP = nil

	if BackLockEnabled and BackLockTargetName then
		local p = Players:FindFirstChild(BackLockTargetName)
		if p and p.Character then
			targetHRP = GetHRP(p.Character)
		end
	end

	if BackLockAllEnabled then
		targetHRP = GetNearestEnemy(myHRP)
	end

	if targetHRP then
		local behindPos =
			targetHRP.Position -
			(targetHRP.CFrame.LookVector * BackLockDistance)

		local cf = CFrame.new(behindPos, targetHRP.Position)
		myHRP.CFrame = myHRP.CFrame:Lerp(cf, BackLockSmoothness)
	end
end)

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

-- Anti
local Anti = {
    Knockback = false,
    Hitstun = false,
    Fling = false,
    Ragdoll = false,
    AntiLag = false,
    AntiSlowWalk = false,
    AntiGravity = false  
}

local AntiGravityConnection = nil

local AntiConnection
local AntiKickdownConnection
local AntiCameraShakeConnection
local AntiAFKConnection
local AntiGravityConnection 

-- 処理機能
local function StartAnti()
    if AntiConnection then return end

    AntiConnection = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not (hrp and hum and hum.Health > 0) then return end

        -- Anti Fling
        if Anti.Fling then
            if hrp.AssemblyLinearVelocity.Magnitude > 60 then
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
            if hrp.AssemblyAngularVelocity.Magnitude > 40 then
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
        end

        -- Anti Hitstun
        if Anti.Hitstun then
            local s = hum:GetState()
            if s == Enum.HumanoidStateType.Physics or s == Enum.HumanoidStateType.Ragdoll then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end

            if hum.WalkSpeed < 16 then
                hum.WalkSpeed = 16
            end
            if hum.UseJumpPower and hum.JumpPower < 50 then
                hum.JumpPower = 50
            end
        end

        -- Anti SlowWalk
        if Anti.AntiSlowWalk then
            if hum.WalkSpeed < 16 then
                hum.WalkSpeed = 16
            end
        end
    end)
end

-- Anti Gravity
local function StartAntiGravity()
    if AntiGravityConnection then return end
    AntiGravityConnection = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            if hrp.AssemblyLinearVelocity.Y < -50 then
                hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
            end
        end
    end)
end

local function StopAntiIfNeeded()
    if not (Anti.Knockback or Anti.Hitstun or Anti.Fling or Anti.AntiLag or Anti.AntiSlowWalk or Anti.AntiGravity) then
        if AntiConnection then
            AntiConnection:Disconnect()
            AntiConnection = nil
        end
    end

    if not Anti.AntiGravity and AntiGravityConnection then
        AntiGravityConnection:Disconnect()
        AntiGravityConnection = nil
    end
end

-- Anti Kickdown
local AntiRagdollEnabled = false
local AntiRagdollConnection = nil

local function ToggleAntiRagdoll(state)
    AntiRagdollEnabled = state

    if AntiRagdollConnection then
        AntiRagdollConnection:Disconnect()
        AntiRagdollConnection = nil
    end

    if state then
        AntiRagdollConnection = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end

            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not (hum and hrp and hum.Health > 0) then return end

            -- ▼ ラグドール状態を即検知
            local stateType = hum:GetState()
            if stateType == Enum.HumanoidStateType.Ragdoll
            or stateType == Enum.HumanoidStateType.Physics
            or stateType == Enum.HumanoidStateType.FallingDown
            or stateType == Enum.HumanoidStateType.GettingUp
            or stateType == Enum.HumanoidStateType.PlatformStanding then

                -- ▼ 即通常状態へ戻す
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end

            -- ▼ Motor6D が無効化されていたら復活させる（重要）
            for _, m in ipairs(char:GetDescendants()) do
                if m:IsA("Motor6D") and not m.Enabled then
                    m.Enabled = true
                end
            end

            -- ▼ 物理固定解除
            hum.PlatformStand = false

            -- ▼ 変な吹っ飛び防止
            local vel = hrp.AssemblyLinearVelocity
            hrp.AssemblyLinearVelocity = Vector3.new(vel.X, math.clamp(vel.Y, -5, 5), vel.Z)
        end)
    end
end

-- Anti Camera Shake
local AntiCameraShakeEnabled = false

local function ToggleAntiCameraShake(state)
    AntiCameraShakeEnabled = state

    if AntiCameraShakeConnection then
        AntiCameraShakeConnection:Disconnect()
        AntiCameraShakeConnection = nil
    end

    if state then
        AntiCameraShakeConnection = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.CameraOffset = Vector3.new(0, 0, 0)
                end
            end
        end)
    end
end

-- Anti AFK
local AntiAFKEnabled = false

local function ToggleAntiAFK(state)
    AntiAFKEnabled = state

    if AntiAFKConnection then
        AntiAFKConnection:Disconnect()
        AntiAFKConnection = nil
    end

    if state then
        AntiAFKConnection = LocalPlayer.Idled:Connect(function()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end

-- Anti Gravity
local function StartAntiGravity()
    if AntiGravityConnection then return end

    AntiGravityConnection = RunService.Heartbeat:Connect(function()
        local character = LocalPlayer.Character
        if not character then return end

        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local velocity = hrp.AssemblyLinearVelocity

        if velocity.Y < -50 then
            hrp.AssemblyLinearVelocity = Vector3.new(velocity.X, 0, velocity.Z)
        end
    end)
end

-- Anti Gravity
local function StopAntiGravity()
    if AntiGravityConnection then
        AntiGravityConnection:Disconnect()
        AntiGravityConnection = nil
    end
end

-- Anti Gravity
local function ToggleAntiGravity(state)
    Anti.AntiGravity = state
    if state then
        StartAntiGravity()
    else
        StopAntiGravity()
    end
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ENABLED = false
local CONNECTION

local DEFAULT_WALKSPEED = 16
local DEFAULT_JUMPPOWER = 50

local BLOCK = {
	BodyVelocity = true,
	BodyPosition = true,
	BodyGyro = true,
	BodyAngularVelocity = true,
	AlignPosition = true,
	AlignOrientation = true,
	LinearVelocity = true,
	AngularVelocity = true
}

local function setupHumanoid(char)
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		DEFAULT_WALKSPEED = hum.WalkSpeed
		DEFAULT_JUMPPOWER = hum.JumpPower
	end
end

local function forceRestore(char)
	local hum = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp then return end

	-- 減速検知 → 即復元
	if hum.WalkSpeed ~= DEFAULT_WALKSPEED then
		hum.WalkSpeed = DEFAULT_WALKSPEED
	end

	if hum.JumpPower ~= DEFAULT_JUMPPOWER then
		hum.JumpPower = DEFAULT_JUMPPOWER
	end

	-- 固定解除
	hum.PlatformStand = false
	hum.AutoRotate = true

	for _, p in ipairs(char:GetDescendants()) do
		if p:IsA("BasePart") then
			p.Anchored = false
		end
		if BLOCK[p.ClassName] then
			p:Destroy()
		end
	end
end

local function start()
	if CONNECTION then return end

	CONNECTION = RunService.Heartbeat:Connect(function()
		if not ENABLED then return end
		local char = LocalPlayer.Character
		if char then
			forceRestore(char)
		end
	end)
end

local function stop()
	if CONNECTION then
		CONNECTION:Disconnect()
		CONNECTION = nil
	end
end

_G.ToggleAntiSlow = function(state)
	ENABLED = state
	if state then
		start()
	else
		stop()
	end
end

LocalPlayer.CharacterAdded:Connect(function(char)
	task.wait(0.3)
	setupHumanoid(char)
end)

if LocalPlayer.Character then
	setupHumanoid(LocalPlayer.Character)
end

-- Button
AntiTab:CreateSection("Anti Players")

AntiTab:CreateToggle({
    Name = "Anti Ragdoll",
    CurrentValue = false,
    Callback = function(v)
        ToggleAntiRagdoll(v)
    end
})

AntiTab:CreateToggle({
    Name = "Anti Fling",
    CurrentValue = false,
    Callback = function(v)
        Anti.Fling = v
        if v then
            StartAnti()
        else
            StopAntiIfNeeded()
        end
    end
})

AntiTab:CreateToggle({
    Name = "Anti Gravity",
    CurrentValue = false,
    Callback = function(state)
        ToggleAntiGravity(state)
    end
})

AntiTab:CreateToggle({
    Name = "Anti Shake",
    CurrentValue = false,
    Callback = ToggleAntiCameraShake
})

-- Troll Tab
TrollTab:CreateSection("Trolls")

TrollTab:CreateButton({
    Name = "invisible",
    Callback = function()
        loadstring(game:HttpGet("https://pastefy.app/OBYJ1UWC/raw"))()
    end
})

TrollTab:CreateButton({
    Name = "Kill all",
    Callback = function()
        loadstring(game:HttpGet("https://pastefy.app/aW96SQyL/raw"))()
    end
})

TrollTab:CreateButton({
    Name = "Touch Fling",
    Callback = function()
        loadstring(game:HttpGet("https://pastefy.app/zxzPV1gw/raw"))()
    end
})

-- ESP Tab
ESPTab:CreateSection("ESP")

local NameESP = false
local BoxESP = false
local LineESP = false
local SkeletonEnabled = false
local HealthBarEnabled = false
local ESPObjects = {}


ESPTab:CreateToggle({ Name="Name ESP", CurrentValue=false, Callback=function(v) NameESP=v end })
ESPTab:CreateToggle({ Name="Box ESP",  CurrentValue=false, Callback=function(v) BoxESP=v end })
ESPTab:CreateToggle({ Name="Line ESP", CurrentValue=false, Callback=function(v) LineESP=v end })

-- ESP Utils
local function ClearESP(plr)
	if ESPObjects[plr] then
		for _, obj in pairs(ESPObjects[plr]) do
			pcall(function() obj:Remove() end)
		end
		ESPObjects[plr] = nil
	end
end

-- Main Loop
RunService.RenderStepped:Connect(function()
	local myChar = LocalPlayer.Character
	local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")

	-- AimLock
	if AimEnabled and AimTarget then
		local p = Players:FindFirstChild(AimTarget)
		if p and p.Character then
			local hrp = p.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				Camera.CFrame = Camera.CFrame:Lerp(
					CFrame.lookAt(Camera.CFrame.Position, hrp.Position),
					0.25
				)
			end
		end
	end

	-- BackLock
	if myHRP and (BackLock or BackLockAll) then
		local nearest, dist = nil, math.huge
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character then
				local hrp = p.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					local d = (myHRP.Position - hrp.Position).Magnitude
					if d < dist then
						dist = d
						nearest = hrp
					end
				end
			end
		end
		if nearest then
			local pos = nearest.Position - nearest.CFrame.LookVector * BackDistance
			myHRP.CFrame = myHRP.CFrame:Lerp(
				CFrame.new(pos, nearest.Position),
				0.25
			)
		end
	end

	-- ESP
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr == LocalPlayer then continue end
		local char = plr.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local head = char and char:FindFirstChild("Head")

		if not char or not hrp then
			ClearESP(plr)
			continue
		end

		local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
		if not onScreen then
			ClearESP(plr)
			continue
		end

		ESPObjects[plr] = ESPObjects[plr] or {}

		-- Name ESP
		if NameESP and head and not head:FindFirstChild("NameESP") then
			local b = Instance.new("BillboardGui", head)
			b.Name="NameESP"
			b.Size=UDim2.new(0,100,0,30)
			b.AlwaysOnTop=true
			local t=Instance.new("TextLabel",b)
			t.Size=UDim2.new(1,0,1,0)
			t.BackgroundTransparency=1
			t.Text=plr.Name
			t.TextColor3=Color3.fromRGB(255,255,255)
		elseif not NameESP and head and head:FindFirstChild("NameESP") then
			head.NameESP:Destroy()
     end
    
		if BoxESP then
			if not ESPObjects[plr].Box then
				pcall(function()
					local box = Drawing.new("Square")
					box.Thickness=1
					box.Color=Color3.fromRGB(255,0,0)
					box.Filled=false
					ESPObjects[plr].Box=box
				end)
			end
			local box = ESPObjects[plr].Box
			if box then
				box.Size=Vector2.new(18,36)
				box.Position=Vector2.new(pos.X-9,pos.Y-18)
				box.Visible=true
			end
		elseif ESPObjects[plr].Box then
			ESPObjects[plr].Box.Visible=false
		end

		if LineESP then
			if not ESPObjects[plr].Line then
				pcall(function()
					local l=Drawing.new("Line")
					l.Thickness=1
					l.Color=Color3.fromRGB(255,0,0)
					ESPObjects[plr].Line=l
				end)
			end
			local line=ESPObjects[plr].Line
			if line then
				line.From=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y)
				line.To=Vector2.new(pos.X,pos.Y)
				line.Visible=true
			end
		elseif ESPObjects[plr].Line then
			ESPObjects[plr].Line.Visible=false
		end
	end
end)

-- Utils
local function GetHRP()
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	return char:WaitForChild("HumanoidRootPart")
end

local function GetPlayerNames()
	local t = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			table.insert(t, p.Name)
		end
	end
	return t
end

-- Teleport Tab
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function GetHRP()
    local char = LocalPlayer.Character
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local function GetPlayerNames()
    local names = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(names, player.Name)
        end
    end
    return names
end

local PlayerNames = GetPlayerNames()
local SelectedTeleportPlayer = nil

TeleportTab:CreateSection("Players Teleports")

local function Notify(text)
    Rayfield:Notify({
        Title = "Teleport",
        Content = text,
        Duration = 3
    })
end

TeleportTab:CreateDropdown({
    Name = "Teleports Target",
    Options = PlayerNames,
    CurrentOption = PlayerNames[1],
    Callback = function(value)
        if typeof(value) == "table" then
            SelectedTeleportPlayer = value[1]
        else
            SelectedTeleportPlayer = value
        end
    end
})

TeleportTab:CreateButton({
    Name = "Teleports",
    Callback = function()
        if not SelectedTeleportPlayer then
            warn("No player selected")
            return
        end

        local targetPlayer = Players:FindFirstChild(SelectedTeleportPlayer)
        if not targetPlayer then
            warn("Target player not found")
            return
        end

        local targetChar = targetPlayer.Character
        local targetHRP = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
        local myHRP = GetHRP()

        if targetHRP and myHRP then
            myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, -3)
            Notify("Teleportation Complete")
        else
            warn("HumanoidRootPart missing")
        end
    end
})

TeleportTab:CreateSection("Map")

TeleportTab:CreateButton({ 
    Name = "Movie Theater", 
    Callback = function()
        local hrp = GetHRP()
        if hrp then
            hrp.CFrame = CFrame.new(-425.6559143066406, -0.47859877347946167,428.0661315917969)
            Notify("Teleportation Complete")
        else
            warn("HumanoidRootPart not found!")
        end
    end 
})

TeleportTab:CreateButton({ 
    Name = "Practice Area",
    Callback = function()
        local hrp = GetHRP()
        if hrp then
            hrp.CFrame = CFrame.new(316.0783996582031,-5.144254684448242,-279.22332763671875)
            Notify("Teleportation Complete")
        else
            warn("HumanoidRootPart not found!")
        end
    end 
})

TeleportTab:CreateButton({ 
    Name = "1v1",
    Callback = function()
        local hrp = GetHRP()
        if hrp then
            hrp.CFrame = CFrame.new(292.80853271484375,11.69509506225586,-13.354337692260742)
            Notify("Teleportation Complete")
        else
            warn("HumanoidRootPart not found!")
        end
    end 
})

local DiscordMessage = "Creator:デスドル"

DiscordTab:CreateLabel(DiscordMessage)

local DiscordMessage = "Discord Server↓"

DiscordTab:CreateLabel(DiscordMessage)

DiscordTab:CreateButton({
    Name = "Link Copy",
    Callback = function()
        setclipboard("https://discord.gg/di-zheng-huang-rashigong-he-guo-1403496250715803790")

        Rayfield:Notify({
            Title = "Discord",
            Content = "Copied to Clipboard",
            Duration = 3,
            Image = 4483362458
        })
    end
})