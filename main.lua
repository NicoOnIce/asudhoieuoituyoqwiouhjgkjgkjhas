local players = game:GetService("Players")
local RunService = game:GetService("RunService")
local inputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local mouse = player:GetMouse()

local tp = false
local clicking = false
local playerss = {}
local angle = 0 -- Initialize an angle variable for circular movement
local targetDrawing = Drawing.new('Text')
targetDrawing.Text = 'No target found'
targetDrawing.Font = Drawing.Fonts.UI
targetDrawing.Size = 20
targetDrawing.Position = Vector2.new(150, 100 + Drawing.Fonts.UI * 50)
targetDrawing.Outline = true

while true do
    if tp then
        targetDrawing.Visible = true
        targetDrawing.Text = playerss[1].Name..'\nHealth: '..tostring(playerss[1].Character:FindFirstChild('Humanoid').Health)
    else
        targetDrawing.Visible = false
    end
    wait(0.1)
end

local function isplayerdead(playerObject)
    if playerObject.Character:FindFirstChild('Humanoid').Health > 0 then
        return false
    end
    return true
end

local function hasTeammateLabel(playerObject)
    local part = playerObject.Character:FindFirstChild("HumanoidRootPart")
    if not part then
        return false
    end
    
    for _, descendant in pairs(part:GetDescendants()) do
        if descendant:IsA("BillboardGui") and descendant.Name == "TeammateLabel" then
            return true
        end
    end
    return false
end

local function updatePlayers()
    playerss = {}
    for _, playerObject in pairs(players:GetPlayers()) do
        if playerObject ~= player then
            if not isplayerdead(playerObject) then
                if not hasTeammateLabel(playerObject) then
                    table.insert(playerss, playerObject)
                end
            end
        end
    end
end

local function newGame()
    wait(4)
    mousemoveabs(1380, 762)
    mouse1click()
    wait(1)
    mousemoveabs(1162, 748)
    mouse1click()
    print('New game started')
end

local function click(playerObject)
    if not clicking then
        clicking = true
        local done = {'one', 'two'}
        for _, value in pairs(done) do
            if not isplayerdead(playerObject) then
                wait(0.15)
                VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, true, game, 1)
                VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, false, game, 1)
                wait(0.15)
            end
        end
        clicking = false
    end
end

updatePlayers()

local function onRenderStepped(deltaTime)
    if tp and #playerss > 0 then
        local targetPlayer = playerss[1]
        local targetCharacter = targetPlayer.Character
        local targetHumanoidRootPart = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
        local localHumanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

        if targetHumanoidRootPart and localHumanoidRootPart then
            -- Calculate circular movement around the target player
            angle = angle + deltaTime * 50 -- Adjust the speed by modifying the multiplier
            local radius = 3 -- Set the radius for circular movement
            local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
            local newPosition = targetHumanoidRootPart.Position + offset

            -- Teleport the local player to the new position
            localHumanoidRootPart.CFrame = CFrame.new(newPosition)

            -- Set the camera to third-person view
            local cameraOffset = Vector3.new(0, 5, 0) -- Offset behind and above the player
            camera.CFrame = CFrame.new(localHumanoidRootPart.Position + cameraOffset, targetHumanoidRootPart.Position)

            -- Make the camera look at the target's head
            local head = targetCharacter:FindFirstChild("Head")
            if head then
                camera.CFrame = CFrame.lookAt(camera.CFrame.Position, head.Position)
            end

            -- Click action
            click(targetPlayer)
        end
    end
end

-- Set the camera to Scriptable to allow manual control
camera.CameraType = Enum.CameraType.Scriptable

RunService.RenderStepped:Connect(onRenderStepped)

inputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.X then
        tp = not tp
        VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, false, game, 1)
    elseif input.KeyCode == Enum.KeyCode.T then
        newGame()
    end
end)

while true do
    task.wait(1)
    updatePlayers()
end
