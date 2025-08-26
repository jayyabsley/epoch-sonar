-- EpochSonar: Simple audio alert for gathering nodes
-- Author: EpochWoW Community

EpochSonar = {}
EpochSonar.version = "2.0.0"

-- Track learned nodes for audio alerts
local learnedNodes = {}
local lastAlertTime = 0
local alertCooldown = 2.0 -- Seconds between alerts

-- Initialize the addon
local function Initialize()
    -- Initialize saved variables
    if not EpochSonarDB then
        EpochSonarDB = {
            enabled = true,
            soundEnabled = true,
            learnedNodes = {}
        }
    end
    
    -- Load learned nodes
    learnedNodes = EpochSonarDB.learnedNodes or {}
    
    -- Register events for learning
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("LOOT_OPENED")
    frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    
    frame:SetScript("OnEvent", function(self, event, ...)
        EpochSonar:OnEvent(event, ...)
    end)
    
    -- Start proximity checking
    EpochSonar:StartProximityCheck()
    
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00EpochSonar|r v" .. EpochSonar.version .. " loaded! Audio alerts enabled.")
end

-- Event handling
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "EpochSonar" then
        Initialize()
    end
end)

-- Handle events
function EpochSonar:OnEvent(event, ...)
    if event == "LOOT_OPENED" then
        self:OnLootOpened()
    elseif event == "PLAYER_TARGET_CHANGED" then
        self:OnTargetChanged()
    end
end

-- Handle loot opening (learning nodes)
function EpochSonar:OnLootOpened()
    local targetName = UnitName("target")
    if targetName and self:IsGatheringNode(targetName) then
        self:LearnNode(targetName)
    end
end

-- Handle target changes
function EpochSonar:OnTargetChanged()
    -- Not needed for simplified version
end

-- Learn a new node
function EpochSonar:LearnNode(nodeName)
    SetMapToCurrentZone()
    local playerX, playerY = GetPlayerMapPosition("player")
    local zone = GetZoneText()
    
    if not playerX or not playerY or not zone or playerX == 0 or playerY == 0 then
        return
    end
    
    -- Initialize zone if needed
    if not learnedNodes[zone] then
        learnedNodes[zone] = {}
    end
    
    -- Create unique node ID
    local nodeId = string.format("%.3f_%.3f", playerX, playerY)
    
    -- Store the node
    learnedNodes[zone][nodeId] = {
        name = nodeName,
        x = playerX,
        y = playerY,
        lastSeen = time()
    }
    
    -- Update saved variables
    EpochSonarDB.learnedNodes = learnedNodes
    
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00EpochSonar|r: Learned " .. nodeName)
end

-- Check if name is a gathering node
function EpochSonar:IsGatheringNode(name)
    if not name then return false end
    
    local lowerName = string.lower(name)
    
    -- Mining nodes
    if string.find(lowerName, "vein") or string.find(lowerName, "deposit") then
        return true
    end
    
    -- Herb nodes
    local herbs = {
        "peacebloom", "silverleaf", "earthroot", "mageroyal", "briarthorn",
        "swiftthistle", "stranglekelp", "bruiseweed", "steelbloom", "kingsblood",
        "liferoot", "fadeleaf", "goldthorn", "khadgar", "wintersbite", "firebloom",
        "lotus", "sungrass", "blindweed", "mushroom", "gromsblood", "sansam",
        "dreamfoil", "silversage", "plaguebloom", "icecap", "goldclover",
        "tiger lily", "talandra", "lichbloom", "icethorn", "adder"
    }
    
    for _, herb in pairs(herbs) do
        if string.find(lowerName, herb) then
            return true
        end
    end
    
    return false
end

-- Start proximity checking for audio alerts
function EpochSonar:StartProximityCheck()
    local frame = CreateFrame("Frame")
    frame:SetScript("OnUpdate", function()
        if EpochSonarDB.enabled and EpochSonarDB.soundEnabled then
            EpochSonar:CheckNodeProximity()
        end
    end)
end

-- Check for nearby learned nodes and play sound
function EpochSonar:CheckNodeProximity()
    local currentTime = GetTime()
    
    -- Cooldown check
    if currentTime - lastAlertTime < alertCooldown then
        return
    end
    
    SetMapToCurrentZone()
    local playerX, playerY = GetPlayerMapPosition("player")
    local zone = GetZoneText()
    
    if not playerX or not playerY or not zone or not learnedNodes[zone] then
        return
    end
    
    -- Check distance to all learned nodes in current zone
    for nodeId, nodeData in pairs(learnedNodes[zone]) do
        local distance = self:CalculateDistance(playerX, playerY, nodeData.x, nodeData.y)
        
        -- Play sound if within range (adjust as needed)
        if distance < 0.08 then -- Closer proximity for audio alert
            self:PlayNodeAlert()
            lastAlertTime = currentTime
            return -- Only one alert per check
        end
    end
end

-- Calculate distance between two points
function EpochSonar:CalculateDistance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

-- Play node proximity alert sound
function EpochSonar:PlayNodeAlert()
    -- Use a built-in WoW sound
    PlaySoundFile("Sound\\Interface\\MapPing.wav")
end

-- Toggle addon
function EpochSonar:Toggle()
    if not EpochSonarDB then return end
    
    EpochSonarDB.enabled = not EpochSonarDB.enabled
    
    if EpochSonarDB.enabled then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00EpochSonar|r audio alerts enabled")
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000EpochSonar|r audio alerts disabled")
    end
end

-- Toggle sound
function EpochSonar:ToggleSound()
    if not EpochSonarDB then return end
    
    EpochSonarDB.soundEnabled = not EpochSonarDB.soundEnabled
    
    if EpochSonarDB.soundEnabled then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00EpochSonar|r sound enabled")
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000EpochSonar|r sound disabled")
    end
end

-- Slash commands
SLASH_EPOCHSONAR1 = "/epochsonar"
SLASH_EPOCHSONAR2 = "/es"

SlashCmdList["EPOCHSONAR"] = function(msg)
    local command = string.lower(msg or "")
    
    if command == "toggle" or command == "" then
        EpochSonar:Toggle()
    elseif command == "sound" then
        EpochSonar:ToggleSound()
    elseif command == "test" then
        EpochSonar:PlayNodeAlert()
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00EpochSonar|r: Test sound played")
    elseif command == "debug" then
        EpochSonar:Debug()
    elseif command == "reset" then
        EpochSonar:Reset()
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00EpochSonar|r Commands:")
        DEFAULT_CHAT_FRAME:AddMessage("  /es toggle - Enable/disable audio alerts")
        DEFAULT_CHAT_FRAME:AddMessage("  /es sound - Enable/disable sound")
        DEFAULT_CHAT_FRAME:AddMessage("  /es test - Play test sound")
        DEFAULT_CHAT_FRAME:AddMessage("  /es debug - Show debug information")
        DEFAULT_CHAT_FRAME:AddMessage("  /es reset - Reset all data")
    end
end

-- Debug function
function EpochSonar:Debug()
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00EpochSonar Debug Info:|r")
    DEFAULT_CHAT_FRAME:AddMessage("Enabled: " .. (EpochSonarDB.enabled and "true" or "false"))
    DEFAULT_CHAT_FRAME:AddMessage("Sound Enabled: " .. (EpochSonarDB.soundEnabled and "true" or "false"))
    
    -- Current location
    SetMapToCurrentZone()
    local playerX, playerY = GetPlayerMapPosition("player")
    local zone = GetZoneText()
    DEFAULT_CHAT_FRAME:AddMessage("Zone: " .. (zone or "nil"))
    DEFAULT_CHAT_FRAME:AddMessage("Player Pos: " .. string.format("%.4f, %.4f", playerX or 0, playerY or 0))
    
    -- Check what's being targeted
    local targetName = UnitName("target")
    if targetName then
        local isGathering = self:IsGatheringNode(targetName)
        DEFAULT_CHAT_FRAME:AddMessage("Target: " .. targetName .. " (Gathering: " .. (isGathering and "YES" or "NO") .. ")")
    else
        DEFAULT_CHAT_FRAME:AddMessage("Target: none")
    end
    
    -- Show learned nodes in current zone
    local nodeCount = 0
    if learnedNodes[zone] then
        for nodeId, nodeData in pairs(learnedNodes[zone]) do
            nodeCount = nodeCount + 1
        end
    end
    DEFAULT_CHAT_FRAME:AddMessage("Learned nodes in " .. (zone or "unknown") .. ": " .. nodeCount)
    
    -- Show nearby nodes with distances
    if learnedNodes[zone] and nodeCount > 0 then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFAA00Nearby Learned Nodes:|r")
        local nearbyCount = 0
        for nodeId, nodeData in pairs(learnedNodes[zone]) do
            local distance = self:CalculateDistance(playerX, playerY, nodeData.x, nodeData.y)
            if distance < 0.2 then -- Show nodes within reasonable range
                nearbyCount = nearbyCount + 1
                local willAlert = distance < 0.08 and "WILL ALERT" or "too far"
                DEFAULT_CHAT_FRAME:AddMessage(string.format("  %s: %.4f distance (%s)", nodeData.name, distance, willAlert))
                if nearbyCount >= 5 then -- Limit output
                    break
                end
            end
        end
        if nearbyCount == 0 then
            DEFAULT_CHAT_FRAME:AddMessage("  No learned nodes nearby")
        end
    end
    
    -- Show all landmarks for comparison (like before)
    local numLandmarks = GetNumMapLandmarks()
    DEFAULT_CHAT_FRAME:AddMessage("Map Landmarks: " .. (numLandmarks or "0"))
    if numLandmarks and numLandmarks > 0 then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFAA00All Landmarks (for comparison):|r")
        for i = 1, math.min(numLandmarks, 5) do -- Limit to 5
            local name, description, textureIndex, x, y = GetMapLandmarkInfo(i)
            if name and x and y then
                local distance = self:CalculateDistance(playerX, playerY, x, y)
                DEFAULT_CHAT_FRAME:AddMessage(string.format("  %s: %.4f distance (tex:%d)", name, distance, textureIndex or 0))
            end
        end
    end
end

-- Reset function
function EpochSonar:Reset()
    EpochSonarDB = nil
    ReloadUI()
end