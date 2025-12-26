local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local request = (syn and syn.request) or (http and http.request) or http_request or request

-- CONFIGURATION
local apiUrl = "https://api.thatguyalpha.net/SL2Genkai"
local folderName = "SL2Genkai"
local fileName = "settings.txt" -- Using JSON content inside txt as requested
local filePath = folderName .. "/" .. fileName

-- State
getgenv().AutoRollEnabled = false
local currentSettings = {
    webhook_url = "",
    halve_res = false
}

-- File System Setup
if not isfolder(folderName) then
    makefolder(folderName)
end

-- Load Settings
if isfile(filePath) then
    local success, decoded = pcall(function()
        return HttpService:JSONDecode(readfile(filePath))
    end)
    if success and decoded then
        currentSettings = decoded
        -- Backwards compatibility if it was just a string before (though we changed filename)
        if type(currentSettings) == "string" then
             currentSettings = { webhook_url = currentSettings, halve_res = false }
        end
    end
elseif isfile(folderName .. "/webhook.txt") then
    -- Migration from old file
    local oldUrl = readfile(folderName .. "/webhook.txt")
    currentSettings.webhook_url = oldUrl
end

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local WebhookInput = Instance.new("TextBox")
local ToggleButton = Instance.new("TextButton")
local HalfResButton = Instance.new("TextButton")
local CloseButton = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "SL2AutoRollGui"
if pcall(function() ScreenGui.Parent = CoreGui end) then
else
    ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -110) 
MainFrame.Size = UDim2.new(0, 300, 0, 260) -- Increased height for extra button
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true 

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = MainFrame

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1.000
Title.Position = UDim2.new(0, 0, 0, 10)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "SL2 Genkai Auto-Roll"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18.000

WebhookInput.Name = "WebhookInput"
WebhookInput.Parent = MainFrame
WebhookInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
WebhookInput.Position = UDim2.new(0.1, 0, 0.2, 0)
WebhookInput.Size = UDim2.new(0.8, 0, 0, 35)
WebhookInput.Font = Enum.Font.Gotham
WebhookInput.PlaceholderText = "Enter Webhook URL"
WebhookInput.Text = currentSettings.webhook_url
WebhookInput.TextColor3 = Color3.fromRGB(200, 200, 200)
WebhookInput.TextSize = 14.000
WebhookInput.ClearTextOnFocus = false
WebhookInput.ClipsDescendants = true 
WebhookInput.TextXAlignment = Enum.TextXAlignment.Left

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 6)
inputCorner.Parent = WebhookInput

local UIPadding = Instance.new("UIPadding")
UIPadding.Parent = WebhookInput
UIPadding.PaddingLeft = UDim.new(0, 10)
UIPadding.PaddingRight = UDim.new(0, 10)

-- Half Res Toggle Button
HalfResButton.Name = "HalfResButton"
HalfResButton.Parent = MainFrame
HalfResButton.BackgroundColor3 = currentSettings.halve_res and Color3.fromRGB(60, 200, 60) or Color3.fromRGB(80, 80, 80)
HalfResButton.Position = UDim2.new(0.1, 0, 0.4, 0)
HalfResButton.Size = UDim2.new(0.8, 0, 0, 30)
HalfResButton.Font = Enum.Font.GothamBold
HalfResButton.Text = "Small Image: " .. (currentSettings.halve_res and "ON" or "OFF")
HalfResButton.TextColor3 = Color3.fromRGB(255, 255, 255)
HalfResButton.TextSize = 14.000

local hrCorner = Instance.new("UICorner")
hrCorner.CornerRadius = UDim.new(0, 6)
hrCorner.Parent = HalfResButton

ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
ToggleButton.Position = UDim2.new(0.1, 0, 0.6, 0)
ToggleButton.Size = UDim2.new(0.35, 0, 0, 40)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "START"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 16.000

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = ToggleButton

CloseButton.Name = "CloseButton"
CloseButton.Parent = MainFrame
CloseButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
CloseButton.Position = UDim2.new(0.55, 0, 0.6, 0)
CloseButton.Size = UDim2.new(0.35, 0, 0, 40)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "CLOSE"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16.000

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = CloseButton

StatusLabel.Name = "StatusLabel"
StatusLabel.Parent = MainFrame
StatusLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.BackgroundTransparency = 1.000
StatusLabel.Position = UDim2.new(0, 0, 0.85, 0)
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.TextSize = 12.000

-- ## FUNCTIONS ## --
local function saveSettings()
    currentSettings.webhook_url = WebhookInput.Text
    -- halve_res is updated by button click
    
    local json = HttpService:JSONEncode(currentSettings)
    writefile(filePath, json)
    print("Settings saved to " .. filePath)
end

local function updateHalfResButton()
    if currentSettings.halve_res then
        HalfResButton.Text = "Small Image: ON"
        HalfResButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60) -- Green
    else
        HalfResButton.Text = "Small Image: OFF"
        HalfResButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80) -- Grey
    end
end

local function updateButtonState()
    if getgenv().AutoRollEnabled then
        ToggleButton.Text = "STOP"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60) 
        StatusLabel.Text = "Status: Rolling..."
    else
        ToggleButton.Text = "START"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60) 
        StatusLabel.Text = "Status: Idle"
    end
end

local function cleanup()
    getgenv().AutoRollEnabled = false
    ScreenGui:Destroy()
    print("SL2 Auto Roll GUI Closed")
end

local function sendGenkaiUpdate()
    if currentSettings.webhook_url == "" then return end
    
    local success, err = pcall(function()
        local stats = game.Players.LocalPlayer.statz.main
        
        local rawNames = {}
        local rawSpins = game.Players.LocalPlayer.PlayerGui.Main.Customization.numberofspins.Text
        local spins = rawSpins:gsub("[%[%]]", "") .. " left"

        for i = 1, 4 do
            local name = stats["kg" .. i].Value
            if name ~= "" and name ~= "Empty" and name ~= nil then
                table.insert(rawNames, name)
            end
        end

        if #rawNames > 0 then
            request({
                Url = apiUrl .. "/webhook",
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode({
                    ["webhook_url"] = currentSettings.webhook_url,
                    ["genkai_names"] = rawNames,
                    ["spins_text"] = spins,
                    ["halve_res"] = currentSettings.halve_res
                })
            })
            print("Genkai update sent to backend.")
        else
            warn("No Genkais detected.")
        end
    end)
    
    if not success then
        warn("Error sending update: " .. tostring(err))
    end
end

local function rollGenkai()
    pcall(function()
        game:GetService("Players").LocalPlayer:WaitForChild("startevent"):FireServer("spin", "kg1")
        task.wait(0.2)
        game:GetService("Players").LocalPlayer:WaitForChild("startevent"):FireServer("spin", "kg2")
        
        -- Uncomment if you have 3rd and 4th slots
        -- game:GetService("Players").LocalPlayer:WaitForChild("startevent"):FireServer("spin", "kg3")
        -- game:GetService("Players").LocalPlayer:WaitForChild("startevent"):FireServer("spin", "kg4")
    end)
end

WebhookInput.FocusLost:Connect(function(enterPressed)
    saveSettings()
end)

HalfResButton.MouseButton1Click:Connect(function()
    currentSettings.halve_res = not currentSettings.halve_res
    updateHalfResButton()
    saveSettings()
end)

ToggleButton.MouseButton1Click:Connect(function()
    getgenv().AutoRollEnabled = not getgenv().AutoRollEnabled
    updateButtonState()
    saveSettings()
    
    if getgenv().AutoRollEnabled then
        task.spawn(function()
            while getgenv().AutoRollEnabled do
                if currentSettings.webhook_url == "" then
                    warn("Please enter a webhook URL first!")
                    getgenv().AutoRollEnabled = false
                    updateButtonState()
                    break
                end
                
                rollGenkai()
                task.wait(0.3)
                sendGenkaiUpdate()
                task.wait(10)
            end
        end)
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    cleanup()
end)

updateButtonState()
updateHalfResButton()
