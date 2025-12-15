local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local ENABLED = false
local LABEL_NAME = "TouchLabel"

local keybinds = {
    toggle = Enum.KeyCode.RightShift,
    clear = Enum.KeyCode.RightControl
}

local GUI_KEY = Enum.KeyCode.L
local connections = {}

local CFG = getgenv().ItemESP or {}

local COLOR_MAP = {
    Yellow = Color3.fromRGB(255, 255, 0),
    Purple = Color3.fromRGB(128, 0, 128),
    Orange = Color3.fromRGB(255, 165, 0),
    Green  = Color3.fromRGB(0, 255, 0),
    Default = Color3.new(1, 0, 0)
}

local function isValidItem(handle)
    local parentModel = handle.Parent
    while parentModel do
        if parentModel:FindFirstChildOfClass("Humanoid") then
            return false
        end
        parentModel = parentModel.Parent
    end
    return true
end

local function getItemColor(itemName)
    for group, items in pairs(CFG) do
        local color = COLOR_MAP[group]
        if color then
            for i = 1, #items do
                if items[i] == itemName then
                    return color
                end
            end
        end
    end
    return COLOR_MAP.Default
end

local function createBillboard(handle)
    if handle:FindFirstChild(LABEL_NAME) then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = LABEL_NAME
    billboard.Parent = handle
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 50, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.Enabled = ENABLED

    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = billboard
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Text = handle.Parent.Name
    textLabel.TextColor3 = getItemColor(handle.Parent.Name)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
end

local function scanWorkspace()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.ClassName == "TouchTransmitter" and v.Parent and v.Parent.Name == "Handle" then
            if isValidItem(v.Parent) then
                createBillboard(v.Parent)
            end
        end
    end
end

local function toggleLabels()
    ENABLED = not ENABLED
    if ENABLED then scanWorkspace() end
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BillboardGui") and v.Name == LABEL_NAME then
            v.Enabled = ENABLED
        end
    end
end

local function clearLabels()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BillboardGui") and v.Name == LABEL_NAME then
            v:Destroy()
        end
    end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TouchLabelGUI"
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 130)
frame.Position = UDim2.new(0.5, -125, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Parent = screenGui
frame.Visible = true
frame.Active = true
frame.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundTransparency = 1
title.Text = "Item ESP (made by eezhan)"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

table.insert(connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == keybinds.toggle then
        toggleLabels()
    elseif input.KeyCode == keybinds.clear then
        clearLabels()
    elseif input.KeyCode == GUI_KEY then
        frame.Visible = not frame.Visible
    end
end))

table.insert(connections, Workspace.DescendantAdded:Connect(function(inst)
    if not ENABLED then return end
    if inst.ClassName == "TouchTransmitter" and inst.Parent and inst.Parent.Name == "Handle" then
        if isValidItem(inst.Parent) then
            createBillboard(inst.Parent)
        end
    end
end))