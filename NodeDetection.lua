-- EpochSonar NodeDetection: Simple minimap landmark detection
-- Author: EpochWoW Community

EpochSonar.NodeDetection = {}

-- Current detected nodes
local currentNodes = {}

-- Initialize node detection
function EpochSonar.NodeDetection:Initialize()
    self.lastPlayerPos = { x = 0, y = 0 }
    self.lastUpdate = 0
    self.playerFacing = 0
    
    -- Initialize database
    self:InitializeDatabase()
    
    -- Register events for learning
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("LOOT_OPENED")
    frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    
    frame:SetScript("OnEvent", function(self, event, ...)
        EpochSonar.NodeDetection:OnEvent(event, ...)
    end)
    
    self.eventFrame = frame
end

-- Initialize node database
function EpochSonar.NodeDetection:InitializeDatabase()
    if not EpochSonarDB.learnedNodes then
        EpochSonarDB.learnedNodes = {}
    end
end

-- Main update function - updates player position and gets learned nodes
function EpochSonar.NodeDetection:Update()
    -- Always update player position and facing for smooth rotation
    SetMapToCurrentZone()
    local playerX, playerY = GetPlayerMapPosition("player")
    local playerFacing = GetPlayerFacing()
    
    if playerX and playerY and playerX > 0 and playerY > 0 then
        self.lastPlayerPos.x = playerX
        self.lastPlayerPos.y = playerY
        self.playerFacing = playerFacing or 0
    end
    
    -- Get learned nodes in current zone
    self:UpdateCurrentNodes()
end

-- Update the current nodes list from learned database
function EpochSonar.NodeDetection:UpdateCurrentNodes()
    currentNodes = {}
    
    local zone = GetZoneText()
    local playerX, playerY = self:GetPlayerPosition()
    
    if not zone or not playerX or not EpochSonarDB.learnedNodes[zone] then
        return
    end
    
    -- Get all learned nodes in this zone within range
    for nodeId, nodeData in pairs(EpochSonarDB.learnedNodes[zone]) do
        local distance = self:CalculateDistance(playerX, playerY, nodeData.x, nodeData.y)
        
        if distance < 0.20 then -- Within display range
            table.insert(currentNodes, {
                name = nodeData.name,
                x = nodeData.x,
                y = nodeData.y,
                distance = distance,
                nodeType = nodeData.nodeType,
                lastSeen = nodeData.lastSeen
            })
        end
    end
end

-- Calculate distance between two map coordinates
function EpochSonar.NodeDetection:CalculateDistance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

-- Get current detected nodes
function EpochSonar.NodeDetection:GetCurrentNodes()
    return currentNodes
end

-- Get current player position
function EpochSonar.NodeDetection:GetPlayerPosition()
    return self.lastPlayerPos.x, self.lastPlayerPos.y
end

-- Get current player facing direction
function EpochSonar.NodeDetection:GetPlayerFacing()
    return self.playerFacing
end

-- Handle events for node learning
function EpochSonar.NodeDetection:OnEvent(event, ...)
    if event == "LOOT_OPENED" then
        self:OnLootOpened()
    elseif event == "PLAYER_TARGET_CHANGED" then
        self:OnTargetChanged()
    end
end

-- Handle loot opening (potential gathering)
function EpochSonar.NodeDetection:OnLootOpened()
    local targetName = UnitName("target")
    if targetName and self:IsGatheringNodeName(targetName) then
        self:LearnNode(targetName)
    end
end

-- Handle target changes (to identify gathering nodes)
function EpochSonar.NodeDetection:OnTargetChanged()
    local targetName = UnitName("target")
    if targetName and self:IsGatheringNodeName(targetName) and UnitCanAttack("player", "target") == nil then
        -- Store as potential node for learning when looted
        self.potentialNode = targetName
    else
        self.potentialNode = nil
    end
end

-- Learn a new node at current position
function EpochSonar.NodeDetection:LearnNode(nodeName)
    SetMapToCurrentZone()
    local playerX, playerY = GetPlayerMapPosition("player")
    local zone = GetZoneText()
    
    if not playerX or not playerY or not zone or playerX == 0 or playerY == 0 then
        return
    end
    
    -- Initialize zone if needed
    if not EpochSonarDB.learnedNodes[zone] then
        EpochSonarDB.learnedNodes[zone] = {}
    end
    
    -- Create unique node ID based on position (rounded to avoid duplicates)
    local nodeId = string.format("%.3f_%.3f", playerX, playerY)
    
    -- Determine node type
    local nodeType = "unknown"
    if self:IsMiningNode(nodeName) then
        nodeType = "mining"
    elseif self:IsHerbNode(nodeName) then
        nodeType = "herb"
    end
    
    -- Store the node
    EpochSonarDB.learnedNodes[zone][nodeId] = {
        name = nodeName,
        x = playerX,
        y = playerY,
        nodeType = nodeType,
        lastSeen = time()
    }
    
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00EpochSonar|r: Learned " .. nodeName)
end

-- Check if name matches gathering node patterns
function EpochSonar.NodeDetection:IsGatheringNodeName(name)
    if not name then return false end
    
    local lowerName = string.lower(name)
    
    -- Mining nodes
    if string.find(lowerName, "vein") or string.find(lowerName, "deposit") then
        return true
    end
    
    -- Common herb patterns
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

-- Check if it's a mining node
function EpochSonar.NodeDetection:IsMiningNode(name)
    local lowerName = string.lower(name)
    return string.find(lowerName, "vein") or string.find(lowerName, "deposit")
end

-- Check if it's an herb node
function EpochSonar.NodeDetection:IsHerbNode(name)
    local lowerName = string.lower(name)
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

-- Handle zone changes
function EpochSonar.NodeDetection:OnZoneChanged()
    -- Clear current nodes and reset position
    currentNodes = {}
    self.lastPlayerPos = { x = 0, y = 0 }
    self.playerFacing = 0
end

-- Handle minimap updates
function EpochSonar.NodeDetection:OnMinimapUpdate()
    -- Not needed for learning approach
end