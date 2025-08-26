-- EpochSonar Database: Node storage and retrieval system
-- Author: EpochWoW Community

EpochSonar.Database = {}

-- Node types
local NODE_TYPES = {
    MINING = 1,
    HERBALISM = 2,
    TREASURE = 3
}

EpochSonar.Database.NODE_TYPES = NODE_TYPES

-- Initialize database
function EpochSonar.Database:Initialize()
    if not EpochSonarDB.nodes then
        EpochSonarDB.nodes = {}
    end
end

-- Get current zone identifier
function EpochSonar.Database:GetZoneKey()
    local zone = GetZoneText()
    local subzone = GetSubZoneText()
    
    if subzone and subzone ~= "" then
        return zone .. ":" .. subzone
    else
        return zone
    end
end

-- Store a gathering node
function EpochSonar.Database:StoreNode(x, y, nodeType, nodeName, objectId)
    local zoneKey = self:GetZoneKey()
    
    if not EpochSonarDB.nodes[zoneKey] then
        EpochSonarDB.nodes[zoneKey] = {}
    end
    
    -- Create unique node ID based on position
    local nodeId = string.format("%.3f_%.3f", x, y)
    
    -- Store node data
    EpochSonarDB.nodes[zoneKey][nodeId] = {
        x = x,
        y = y,
        type = nodeType,
        name = nodeName,
        objectId = objectId,
        lastSeen = time(),
        timesGathered = (EpochSonarDB.nodes[zoneKey][nodeId] and EpochSonarDB.nodes[zoneKey][nodeId].timesGathered or 0) + 1
    }
end

-- Get nodes in the current zone
function EpochSonar.Database:GetNodesInZone(zoneKey)
    zoneKey = zoneKey or self:GetZoneKey()
    return EpochSonarDB.nodes[zoneKey] or {}
end

-- Get nodes within range of player
function EpochSonar.Database:GetNodesInRange(playerX, playerY, maxDistance)
    local nodes = self:GetNodesInZone()
    local nearbyNodes = {}
    
    for nodeId, nodeData in pairs(nodes) do
        local distance = self:CalculateDistance(playerX, playerY, nodeData.x, nodeData.y)
        
        if distance <= maxDistance then
            nodeData.distance = distance
            table.insert(nearbyNodes, nodeData)
        end
    end
    
    return nearbyNodes
end

-- Calculate distance between two points
function EpochSonar.Database:CalculateDistance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

-- Convert world coordinates to yards (approximate)
function EpochSonar.Database:CoordinatesToYards(distance)
    -- WoW map coordinates are 0-1, this converts to approximate yard distance
    -- This is a rough estimation and may need adjustment based on zone size
    return distance * 1000
end

-- Clean old nodes (nodes not seen in X days)
function EpochSonar.Database:CleanOldNodes(daysOld)
    daysOld = daysOld or 30
    local cutoffTime = time() - (daysOld * 24 * 60 * 60)
    local cleanedCount = 0
    
    for zoneKey, zoneNodes in pairs(EpochSonarDB.nodes) do
        for nodeId, nodeData in pairs(zoneNodes) do
            if nodeData.lastSeen < cutoffTime then
                zoneNodes[nodeId] = nil
                cleanedCount = cleanedCount + 1
            end
        end
    end
    
    return cleanedCount
end

-- Get node statistics
function EpochSonar.Database:GetNodeStats()
    local stats = {
        totalNodes = 0,
        nodesByType = {},
        nodesByZone = {}
    }
    
    for nodeTypeName, nodeTypeId in pairs(NODE_TYPES) do
        stats.nodesByType[nodeTypeName] = 0
    end
    
    for zoneKey, zoneNodes in pairs(EpochSonarDB.nodes) do
        local zoneCount = 0
        
        for nodeId, nodeData in pairs(zoneNodes) do
            stats.totalNodes = stats.totalNodes + 1
            zoneCount = zoneCount + 1
            
            for nodeTypeName, nodeTypeId in pairs(NODE_TYPES) do
                if nodeData.type == nodeTypeId then
                    stats.nodesByType[nodeTypeName] = stats.nodesByType[nodeTypeName] + 1
                    break
                end
            end
        end
        
        stats.nodesByZone[zoneKey] = zoneCount
    end
    
    return stats
end

-- Export nodes data (for backup or sharing)
function EpochSonar.Database:ExportData()
    return EpochSonarDB.nodes
end

-- Import nodes data
function EpochSonar.Database:ImportData(nodeData)
    if type(nodeData) == "table" then
        EpochSonarDB.nodes = nodeData
        return true
    end
    return false
end

-- Check if a node type should be shown based on config
function EpochSonar.Database:ShouldShowNodeType(nodeType)
    if nodeType == NODE_TYPES.MINING then
        return EpochSonarDB.config.showMiningNodes
    elseif nodeType == NODE_TYPES.HERBALISM then
        return EpochSonarDB.config.showHerbNodes
    elseif nodeType == NODE_TYPES.TREASURE then
        return EpochSonarDB.config.showTreasures
    end
    
    return false
end

-- Get filtered nodes based on configuration
function EpochSonar.Database:GetFilteredNodes(playerX, playerY)
    local allNodes = self:GetNodesInRange(playerX, playerY, EpochSonarDB.config.maxNodeDistance / 1000)
    local filteredNodes = {}
    
    for _, nodeData in pairs(allNodes) do
        if self:ShouldShowNodeType(nodeData.type) then
            table.insert(filteredNodes, nodeData)
        end
    end
    
    return filteredNodes
end