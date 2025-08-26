-- EpochSonar SonarDisplay: Simple rotating minimap-style overlay
-- Author: EpochWoW Community

EpochSonar.SonarDisplay = {}

-- Initialize the display
function EpochSonar.SonarDisplay:Initialize()
    self:CreateMainFrame()
    self.isVisible = false
    self.nodeFrames = {}
    self.maxNodes = 50
end

-- Create the main overlay frame
function EpochSonar.SonarDisplay:CreateMainFrame()
    local frame = CreateFrame("Frame", "EpochSonarMainFrame", UIParent)
    
    -- Position at screen center, smaller size
    frame:SetSize(200, 200)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    
    -- Make it click-through
    frame:EnableMouse(false)
    frame:SetFrameStrata("MEDIUM")
    frame:SetFrameLevel(100)
    
    -- Create center dot (player position)
    local centerDot = frame:CreateTexture(nil, "OVERLAY")
    centerDot:SetTexture(1, 1, 1, 0.8) -- White dot
    centerDot:SetSize(4, 4)
    centerDot:SetPoint("CENTER")
    self.centerDot = centerDot
    
    self.mainFrame = frame
    
    -- Start hidden
    frame:Hide()
end

-- Show the display
function EpochSonar.SonarDisplay:Show()
    if EpochSonarDB and EpochSonarDB.enabled then
        self.mainFrame:Show()
        self.isVisible = true
    end
end

-- Hide the display
function EpochSonar.SonarDisplay:Hide()
    self.mainFrame:Hide()
    self.isVisible = false
end

-- Main update function
function EpochSonar.SonarDisplay:Update()
    if not self.isVisible or not EpochSonarDB or not EpochSonarDB.enabled then
        return
    end
    
    -- Get current nodes from detection system
    local currentNodes = EpochSonar.NodeDetection:GetCurrentNodes()
    local playerX, playerY = EpochSonar.NodeDetection:GetPlayerPosition()
    local playerFacing = EpochSonar.NodeDetection:GetPlayerFacing()
    
    if not playerX or playerX == 0 or playerY == 0 then
        return
    end
    
    -- Update node display
    self:UpdateNodeDisplay(playerX, playerY, playerFacing, currentNodes)
end

-- Update the display of nodes with rotation
function EpochSonar.SonarDisplay:UpdateNodeDisplay(playerX, playerY, playerFacing, nodes)
    -- Hide all existing node frames
    for _, nodeFrame in pairs(self.nodeFrames) do
        nodeFrame:Hide()
    end
    
    local usedFrames = 0
    local maxDisplayRadius = 90 -- Max pixels from center to display nodes
    local maxDistance = 0.20 -- Max map coordinate distance (matches NodeDetection range)
    
    -- Display each node
    for _, nodeData in pairs(nodes) do
        usedFrames = usedFrames + 1
        
        -- Don't exceed max nodes
        if usedFrames > self.maxNodes then
            break
        end
        
        -- Get or create node frame
        local nodeFrame = self:GetNodeFrame(usedFrames)
        
        -- Calculate relative position from player
        local relativeX = nodeData.x - playerX
        local relativeY = nodeData.y - playerY
        
        -- Recalculate current distance for smooth movement
        local currentDistance = math.sqrt(relativeX * relativeX + relativeY * relativeY)
        
        -- Convert to screen coordinates with rotation and distance scaling
        local screenX, screenY = self:WorldToScreen(relativeX, relativeY, playerFacing, maxDisplayRadius, currentDistance, maxDistance)
        
        -- Position the node frame
        nodeFrame:ClearAllPoints()
        nodeFrame:SetPoint("CENTER", self.mainFrame, "CENTER", screenX, screenY)
        
        -- Set node appearance (simple yellow dots)
        self:SetNodeAppearance(nodeFrame, nodeData)
        
        -- Show the frame
        nodeFrame:Show()
    end
end

-- Get or create a node frame
function EpochSonar.SonarDisplay:GetNodeFrame(index)
    if not self.nodeFrames[index] then
        local frame = CreateFrame("Frame", nil, self.mainFrame)
        frame:SetSize(6, 6)
        
        local texture = frame:CreateTexture(nil, "OVERLAY")
        texture:SetAllPoints()
        texture:SetTexture(1, 1, 0, 0.8) -- Yellow dot
        
        frame.texture = texture
        self.nodeFrames[index] = frame
    end
    
    return self.nodeFrames[index]
end

-- Set the appearance of a node frame (simple dots)
function EpochSonar.SonarDisplay:SetNodeAppearance(nodeFrame, nodeData)
    -- Simple yellow dots for all nodes
    nodeFrame.texture:SetVertexColor(1, 1, 0, 0.8) -- Yellow
    
    -- Scale size based on distance (closer = larger)
    local sizeFactor = math.max(0.3, 1 - (nodeData.distance * 8)) -- Scale based on distance
    local size = 4 + (sizeFactor * 4)
    nodeFrame:SetSize(size, size)
end

-- Convert world coordinates to rotated screen coordinates with distance scaling
function EpochSonar.SonarDisplay:WorldToScreen(relativeX, relativeY, playerFacing, maxRadius, actualDistance, maxDistance)
    -- Calculate direction angle from player to node
    local angle = math.atan2(relativeY, relativeX)
    
    -- Apply player facing rotation to the angle
    angle = angle - playerFacing
    
    -- Scale distance: map actual distance to screen radius
    local screenDistance = (actualDistance / maxDistance) * maxRadius
    
    -- Convert polar coordinates to screen coordinates
    local screenX = screenDistance * math.cos(angle)
    local screenY = screenDistance * math.sin(angle)
    
    -- Clamp to max radius (shouldn't be needed with proper scaling, but safety check)
    local distance = math.sqrt(screenX * screenX + screenY * screenY)
    if distance > maxRadius then
        screenX = (screenX / distance) * maxRadius
        screenY = (screenY / distance) * maxRadius
    end
    
    -- Return coordinates with Y NOT flipped so north is up on screen
    return screenX, screenY
end

-- Handle zone changes
function EpochSonar.SonarDisplay:OnZoneChanged()
    -- Clear current node display
    for _, nodeFrame in pairs(self.nodeFrames) do
        nodeFrame:Hide()
    end
end

-- Toggle display
function EpochSonar.SonarDisplay:Toggle()
    if self.isVisible then
        self:Hide()
    else
        self:Show()
    end
end