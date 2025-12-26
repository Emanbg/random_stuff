local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local request = (syn and syn.request) or (http and http.request) or http_request or request

local apiUrl = "https://api.thatguyalpha.net/SL2Genkai"
local folderName = "SL2Genkai"
local fileName = "webhook.txt"
local filePath = folderName .. "/" .. fileName

getgenv().AutoRollEnabled = false
local currentWebhook = ""
local webhookName = "SL2 Genkai Roll"
local webhookAvatar = "https://files.thatguyalpha.net/screenshots/SL2GenkaiIcon.png"

if not isfolder(folderName) then
    makefolder(folderName)
end

if isfile(filePath) then
    currentWebhook = readfile(filePath)
end

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local WebhookInput = Instance.new("TextBox")
local ToggleButton = Instance.new("TextButton")
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
MainFrame.Size = UDim2.new(0, 300, 0, 220) 
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true -- Prevent overflow

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
WebhookInput.Position = UDim2.new(0.1, 0, 0.25, 0)
WebhookInput.Size = UDim2.new(0.8, 0, 0, 35)
WebhookInput.Font = Enum.Font.Gotham
WebhookInput.PlaceholderText = "Enter Webhook URL"
WebhookInput.Text = currentWebhook
WebhookInput.TextColor3 = Color3.fromRGB(200, 200, 200)
WebhookInput.TextSize = 14.000
WebhookInput.ClearTextOnFocus = false
WebhookInput.ClipsDescendants = true 
WebhookInput.TextXAlignment = Enum.TextXAlignment.Left

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 6)
inputCorner.Parent = WebhookInput

-- Padding for text box
local UIPadding = Instance.new("UIPadding")
UIPadding.Parent = WebhookInput
UIPadding.PaddingLeft = UDim.new(0, 10)
UIPadding.PaddingRight = UDim.new(0, 10)

ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
ToggleButton.Position = UDim2.new(0.1, 0, 0.5, 0)
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
CloseButton.Position = UDim2.new(0.55, 0, 0.5, 0)
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
StatusLabel.Position = UDim2.new(0, 0, 0.8, 0)
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.TextSize = 12.000

-- ## FUNCTIONS ## --
local function saveWebhook()
    local url = WebhookInput.Text
    if url and url ~= "" then
        writefile(filePath, url)
        currentWebhook = url
        print("Webhook saved to " .. filePath)
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
    if currentWebhook == "" then return end
    
    local success, err = pcall(function()
        local stats = game.Players.LocalPlayer.statz.main
        
        local nameList = {}
        local rawNames = {}
        local spins = game.Players.LocalPlayer.PlayerGui.Main.Customization.numberofspins.Text

        for i = 1, 4 do
            local name = stats["kg" .. i].Value
            
            if name ~= "" and name ~= "Empty" and name ~= nil then
                table.insert(nameList, i .. " - " .. name)
                table.insert(rawNames, name)
            end
        end

        if #rawNames > 0 then
            -- Create URL with comma separated names
            -- Format: api.thatguyalpha.net/SL2Genkai?Name1,Name2,Name3,Name4
            local urlString = table.concat(rawNames, ",")
            local finalRequestUrl = apiUrl .. "?" .. urlString

            request({
                Url = currentWebhook,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode({
                    ["username"] = webhookName,
                    ["avatar_url"] = webhookAvatar,
                    ["content"] = "**Current Genkais:**\n" .. table.concat(nameList, "\n") .. "\n" .. spins,
                    ["embeds"] = {{
                        ["image"] = { ["url"] = finalRequestUrl },
                        ["color"] = 0x2b2d31
                    }}
                })
            })
            print("Genkai layout sent to backend successfully.")
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
    saveWebhook()
end)

ToggleButton.MouseButton1Click:Connect(function()
    getgenv().AutoRollEnabled = not getgenv().AutoRollEnabled
    updateButtonState()
    saveWebhook()
    
    if getgenv().AutoRollEnabled then
        task.spawn(function()
            while getgenv().AutoRollEnabled do
                if currentWebhook == "" then
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
