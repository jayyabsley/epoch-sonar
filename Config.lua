-- EpochSonar Config: Configuration panel and settings management
-- Author: EpochWoW Community

EpochSonar.Config = {}

-- Initialize configuration system
function EpochSonar.Config:Initialize()
    self:CreateConfigPanel()
end

-- Create the configuration panel
function EpochSonar.Config:CreateConfigPanel()
    local frame = CreateFrame("Frame", "EpochSonarConfigFrame", UIParent)
    frame:SetSize(400, 500)
    frame:SetPoint("CENTER")
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    frame:SetBackdropColor(0, 0, 0, 0.8)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()
    
    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOP", 0, -16)
    title:SetText("EpochSonar Configuration")
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -8, -8)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)
    
    self.configFrame = frame
    self:CreateConfigOptions()
end

-- Create configuration options
function EpochSonar.Config:CreateConfigOptions()
    local frame = self.configFrame
    local yOffset = -60
    
    -- Enable/Disable checkbox
    local enabledCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    enabledCheck:SetPoint("TOPLEFT", 20, yOffset)
    enabledCheck.Text:SetText("Enable EpochSonar")
    enabledCheck:SetChecked(EpochSonarDB.config.enabled)
    enabledCheck:SetScript("OnClick", function(self)
        EpochSonarDB.config.enabled = self:GetChecked()
        if EpochSonarDB.config.enabled then
            EpochSonar.SonarDisplay:Show()
        else
            EpochSonar.SonarDisplay:Hide()
        end
    end)
    yOffset = yOffset - 30
    
    -- Sonar Radius slider
    local radiusSlider = CreateFrame("Slider", nil, frame, "OptionsSliderTemplate")
    radiusSlider:SetPoint("TOPLEFT", 20, yOffset)
    radiusSlider:SetMinMaxValues(50, 300)
    radiusSlider:SetValue(EpochSonarDB.config.sonarRadius)
    radiusSlider:SetValueStep(10)
    radiusSlider:SetObeyStepOnDrag(true)
    getglobal(radiusSlider:GetName() .. 'Low'):SetText('50')
    getglobal(radiusSlider:GetName() .. 'High'):SetText('300')
    getglobal(radiusSlider:GetName() .. 'Text'):SetText('Sonar Radius: ' .. EpochSonarDB.config.sonarRadius)
    radiusSlider:SetScript("OnValueChanged", function(self, value)
        EpochSonarDB.config.sonarRadius = value
        getglobal(self:GetName() .. 'Text'):SetText('Sonar Radius: ' .. value)
        EpochSonar.SonarDisplay:SetRadius(value)
    end)
    yOffset = yOffset - 50
    
    -- Max Distance slider
    local distanceSlider = CreateFrame("Slider", nil, frame, "OptionsSliderTemplate")
    distanceSlider:SetPoint("TOPLEFT", 20, yOffset)
    distanceSlider:SetMinMaxValues(50, 500)
    distanceSlider:SetValue(EpochSonarDB.config.maxNodeDistance)
    distanceSlider:SetValueStep(25)
    distanceSlider:SetObeyStepOnDrag(true)
    getglobal(distanceSlider:GetName() .. 'Low'):SetText('50')
    getglobal(distanceSlider:GetName() .. 'High'):SetText('500')
    getglobal(distanceSlider:GetName() .. 'Text'):SetText('Max Distance: ' .. EpochSonarDB.config.maxNodeDistance .. ' yards')
    distanceSlider:SetScript("OnValueChanged", function(self, value)
        EpochSonarDB.config.maxNodeDistance = value
        getglobal(self:GetName() .. 'Text'):SetText('Max Distance: ' .. value .. ' yards')
    end)
    yOffset = yOffset - 50
    
    -- Opacity slider
    local opacitySlider = CreateFrame("Slider", nil, frame, "OptionsSliderTemplate")
    opacitySlider:SetPoint("TOPLEFT", 20, yOffset)
    opacitySlider:SetMinMaxValues(0.1, 1.0)
    opacitySlider:SetValue(EpochSonarDB.config.opacity)
    opacitySlider:SetValueStep(0.1)
    opacitySlider:SetObeyStepOnDrag(true)
    getglobal(opacitySlider:GetName() .. 'Low'):SetText('10%')
    getglobal(opacitySlider:GetName() .. 'High'):SetText('100%')
    getglobal(opacitySlider:GetName() .. 'Text'):SetText('Opacity: ' .. math.floor(EpochSonarDB.config.opacity * 100) .. '%')
    opacitySlider:SetScript("OnValueChanged", function(self, value)
        EpochSonarDB.config.opacity = value
        getglobal(self:GetName() .. 'Text'):SetText('Opacity: ' .. math.floor(value * 100) .. '%')
        EpochSonar.SonarDisplay:SetOpacity(value)
    end)
    yOffset = yOffset - 50
    
    -- Node type checkboxes
    local miningCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    miningCheck:SetPoint("TOPLEFT", 20, yOffset)
    miningCheck.Text:SetText("Show Mining Nodes")
    miningCheck:SetChecked(EpochSonarDB.config.showMiningNodes)
    miningCheck:SetScript("OnClick", function(self)
        EpochSonarDB.config.showMiningNodes = self:GetChecked()
    end)
    yOffset = yOffset - 30
    
    local herbCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    herbCheck:SetPoint("TOPLEFT", 20, yOffset)
    herbCheck.Text:SetText("Show Herb Nodes")
    herbCheck:SetChecked(EpochSonarDB.config.showHerbNodes)
    herbCheck:SetScript("OnClick", function(self)
        EpochSonarDB.config.showHerbNodes = self:GetChecked()
    end)
    yOffset = yOffset - 30
    
    local treasureCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    treasureCheck:SetPoint("TOPLEFT", 20, yOffset)
    treasureCheck.Text:SetText("Show Treasures")
    treasureCheck:SetChecked(EpochSonarDB.config.showTreasures)
    treasureCheck:SetScript("OnClick", function(self)
        EpochSonarDB.config.showTreasures = self:GetChecked()
    end)
    yOffset = yOffset - 30
    
    -- Display options
    local distanceRingCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    distanceRingCheck:SetPoint("TOPLEFT", 20, yOffset)
    distanceRingCheck.Text:SetText("Show Distance Rings")
    distanceRingCheck:SetChecked(EpochSonarDB.config.showDistanceRings)
    distanceRingCheck:SetScript("OnClick", function(self)
        EpochSonarDB.config.showDistanceRings = self:GetChecked()
        EpochSonar.SonarDisplay:UpdateVisibility()
    end)
    yOffset = yOffset - 30
    
    local compassCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    compassCheck:SetPoint("TOPLEFT", 20, yOffset)
    compassCheck.Text:SetText("Show Compass")
    compassCheck:SetChecked(EpochSonarDB.config.showCompass)
    compassCheck:SetScript("OnClick", function(self)
        EpochSonarDB.config.showCompass = self:GetChecked()
        EpochSonar.SonarDisplay:UpdateVisibility()
    end)
    yOffset = yOffset - 40
    
    -- Statistics button
    local statsBtn = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    statsBtn:SetSize(120, 25)
    statsBtn:SetPoint("TOPLEFT", 20, yOffset)
    statsBtn:SetText("View Statistics")
    statsBtn:SetScript("OnClick", function()
        EpochSonar.Config:ShowStatistics()
    end)
    
    -- Reset button
    local resetBtn = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    resetBtn:SetSize(120, 25)
    resetBtn:SetPoint("TOPLEFT", 160, yOffset)
    resetBtn:SetText("Reset All Data")
    resetBtn:SetScript("OnClick", function()
        EpochSonar.Config:ShowResetConfirmation()
    end)
end

-- Show the configuration panel
function EpochSonar.Config:Show()
    self.configFrame:Show()
end

-- Hide the configuration panel
function EpochSonar.Config:Hide()
    self.configFrame:Hide()
end

-- Show statistics window
function EpochSonar.Config:ShowStatistics()
    local stats = EpochSonar.Database:GetNodeStats()
    
    local message = "EpochSonar Statistics:\n\n"
    message = message .. "Total Nodes: " .. stats.totalNodes .. "\n"
    message = message .. "Mining Nodes: " .. stats.nodesByType.MINING .. "\n"
    message = message .. "Herb Nodes: " .. stats.nodesByType.HERBALISM .. "\n"
    message = message .. "Treasure Nodes: " .. stats.nodesByType.TREASURE .. "\n\n"
    message = message .. "Zones with Data:\n"
    
    local zoneCount = 0
    for zone, count in pairs(stats.nodesByZone) do
        message = message .. zone .. ": " .. count .. " nodes\n"
        zoneCount = zoneCount + 1
        if zoneCount > 10 then
            message = message .. "... and " .. (table.getn(stats.nodesByZone) - 10) .. " more zones"
            break
        end
    end
    
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00EpochSonar Statistics:|r")
    for line in string.gmatch(message, "[^\n]+") do
        DEFAULT_CHAT_FRAME:AddMessage(line)
    end
end

-- Show reset confirmation
function EpochSonar.Config:ShowResetConfirmation()
    StaticPopupDialogs["EPOCHSONAR_RESET_CONFIRM"] = {
        text = "Are you sure you want to reset all EpochSonar data? This cannot be undone!",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            EpochSonar:Reset()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("EPOCHSONAR_RESET_CONFIRM")
end