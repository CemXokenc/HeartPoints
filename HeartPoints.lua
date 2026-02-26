-- HeartPoints
-- Replaces combo points (Druid) and soul shards (Warlock) with heart icons.
-- Compatibility: WoW Retail / Midnight

-- ╔════════════════════════════════════════════════════════════════╗
-- ║                      CONFIGURATION                             ║
-- ╚════════════════════════════════════════════════════════════════╝

local CFG = {
    -- Heart icon size in pixels
    heartSize    = 22,
    -- Distance between heart centers
    heartSpacing = 26,
    -- Anchor offset of the heart frame relative to PlayerFrame
    heartOffsetX = -31,
    heartOffsetY = -15,

    -- Glow layer behind each heart
    glowEnabled    = true,
    glowMultiplier = 1.1,   -- glow size relative to heartSize
    glowAlpha      = 0.6,

    -- Active heart color: Druid (pink)
    druidActiveColor = { r = 0.86, g = 0.39, b = 0.77 },
    druidGlowColor   = { r = 0.65, g = 0.23, b = 0.57 },

    -- Active heart color: Warlock (purple)
    lockActiveColor  = { r = 0.61, g = 0.35, b = 0.71 },
    lockGlowColor    = { r = 0.40, g = 0.15, b = 0.55 },

    -- Inactive heart color (both classes)
    inactiveColor    = { r = 0.7,  g = 0.7,  b = 0.7  },

    -- Pixels to shift TotemFrame downward (applied once per world entry)
    druidTotemShiftY   = -30,   -- applied only while in Cat Form
	druidTotemShiftX = -5,
    warlockTotemShiftY = -30,   -- permanent while playing Warlock
    warlockTotemShiftX = -5,

    -- Texture paths
    texActive   = "Interface\\AddOns\\HeartPoints\\heart.tga",
    texInactive = "Interface\\AddOns\\HeartPoints\\heart_grey.tga",
}

-- ╔════════════════════════════════════════════════════════════════╗
-- ║                        CORE LOGIC                              ║
-- ╚════════════════════════════════════════════════════════════════╝

local _, playerClass = UnitClass("player")

-- ── TotemFrame repositioning ──────────────────────────────────────

local warlockTotemShifted = false
local druidTotemShifted   = false

local function ResetShiftState()
    warlockTotemShifted = false
    druidTotemShifted   = false
end

-- Warlock: shift TotemFrame once; ForceApply ignores the "already shifted" guard.
local function ApplyWarlockTotemShift()
    if not TotemFrame or warlockTotemShifted then return end
    warlockTotemShifted = true
    TotemFrame:AdjustPointsOffset(CFG.warlockTotemShiftX, CFG.warlockTotemShiftY)
end

local function ForceWarlockTotemShift()
    warlockTotemShifted = false
    ApplyWarlockTotemShift()
end

-- Druid: toggle shift when entering / leaving Cat Form.
local function ApplyDruidTotemShift()
    if not TotemFrame then return end
    local inCat = (GetShapeshiftFormID() == DRUID_CAT_FORM)
    if inCat and not druidTotemShifted then
        druidTotemShifted = true
        TotemFrame:AdjustPointsOffset(CFG.druidTotemShiftX, CFG.druidTotemShiftY)
    elseif not inCat and druidTotemShifted then
        druidTotemShifted = false
        TotemFrame:AdjustPointsOffset(CFG.druidTotemShiftX, -CFG.druidTotemShiftY)   -- exact reverse
    end
end

-- ── Native power bar suppression ──────────────────────────────────

local function HideBlizzardPowerDisplay()
    if playerClass == "DRUID" then
        if DruidComboPointBarFrame then DruidComboPointBarFrame:Hide() end
    elseif playerClass == "WARLOCK" then
        if WarlockPowerFrame then
            WarlockPowerFrame:Hide()
            WarlockPowerFrame:UnregisterAllEvents()
        end
        if SoulShardBar then SoulShardBar:Hide() end
    end
end

-- ── Heart frame ───────────────────────────────────────────────────

local function CreateHeartPoints()
    local f = CreateFrame("Frame", "HeartPointsFrame", UIParent)
    f:SetSize(CFG.heartSize * 5 + CFG.heartSpacing * 4, CFG.heartSize * 2)
    f:SetPoint("BOTTOMLEFT", PlayerFrame, "BOTTOM", CFG.heartOffsetX, CFG.heartOffsetY)

    for i = 1, 5 do
        local x = (i - 1) * CFG.heartSpacing

        if CFG.glowEnabled then
            local gs   = CFG.heartSize * CFG.glowMultiplier
            local glow = f:CreateTexture("HeartGlow"..i, "BACKGROUND")
            glow:SetSize(gs, gs)
            glow:SetPoint("LEFT", x + (CFG.heartSize - gs) / 2, 0)
            glow:SetTexture(CFG.texInactive)
            glow:SetBlendMode("ADD")
            local c = CFG.inactiveColor
            glow:SetVertexColor(c.r * 0.5, c.g * 0.5, c.b * 0.5, CFG.glowAlpha)
            f["HeartGlow"..i] = glow
        end

        local heart = f:CreateTexture("HeartPoint"..i, "ARTWORK")
        heart:SetSize(CFG.heartSize, CFG.heartSize)
        heart:SetPoint("LEFT", x, 0)
        heart:SetTexture(CFG.texInactive)
        heart:SetBlendMode("BLEND")
        local c = CFG.inactiveColor
        heart:SetVertexColor(c.r, c.g, c.b, 1)
        f["Heart"..i] = heart
    end

    return f
end

local function UpdateHeartPoints(hf)
    if not hf then return end

    local show, power, activeC, glowC

    if playerClass == "DRUID" then
        show    = (GetShapeshiftFormID() == DRUID_CAT_FORM)
        power   = UnitPower("player", Enum.PowerType.ComboPoints) or 0
        activeC = CFG.druidActiveColor
        glowC   = CFG.druidGlowColor
    elseif playerClass == "WARLOCK" then
        show    = true
        power   = UnitPower("player", Enum.PowerType.SoulShards) or 0
        activeC = CFG.lockActiveColor
        glowC   = CFG.lockGlowColor
    end

    hf:SetShown(show)
    if not show then return end

    for i = 1, 5 do
        local heart = hf["Heart"..i]
        local glow  = CFG.glowEnabled and hf["HeartGlow"..i]
        if heart then
            if i <= power then
                heart:SetTexture(CFG.texActive)
                heart:SetVertexColor(activeC.r, activeC.g, activeC.b, 1)
                if glow then
                    glow:SetTexture(CFG.texActive)
                    glow:SetVertexColor(glowC.r, glowC.g, glowC.b, CFG.glowAlpha)
                end
            else
                local c = CFG.inactiveColor
                heart:SetTexture(CFG.texInactive)
                heart:SetVertexColor(c.r, c.g, c.b, 1)
                if glow then
                    glow:SetTexture(CFG.texInactive)
                    glow:SetVertexColor(c.r * 0.5, c.g * 0.5, c.b * 0.5, CFG.glowAlpha)
                end
            end
        end
    end
end

-- ── Event handling ────────────────────────────────────────────────

local heartFrame = nil
local events     = CreateFrame("Frame")

events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("UNIT_POWER_UPDATE")

if playerClass == "DRUID" then
    events:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
elseif playerClass == "WARLOCK" then
    events:RegisterEvent("PLAYER_TOTEM_UPDATE")
end

events:SetScript("OnEvent", function(_, event, unit, powerType)

    if event == "UNIT_POWER_UPDATE" then
        if unit ~= "player" then return end
        if playerClass == "DRUID"   and powerType ~= "COMBO_POINTS" then return end
        if playerClass == "WARLOCK" and powerType ~= "SOUL_SHARDS"  then return end
    end

    if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        ResetShiftState()
        heartFrame = heartFrame or CreateHeartPoints()
        HideBlizzardPowerDisplay()

        -- Wait for Blizzard to finish laying out frames before we reposition
        C_Timer.After(0.3, function()
            if playerClass == "WARLOCK" then
                ApplyWarlockTotemShift()
                -- Re-apply every time TotemFrame is shown (guardian spawn / relog)
                if TotemFrame and not TotemFrame._hpHooked then
                    TotemFrame._hpHooked = true
                    TotemFrame:HookScript("OnShow", ForceWarlockTotemShift)
                end
            elseif playerClass == "DRUID" then
                ApplyDruidTotemShift()
            end
        end)
    end

    if event == "UPDATE_SHAPESHIFT_FORM" then
        HideBlizzardPowerDisplay()
        ApplyDruidTotemShift()
    end

    UpdateHeartPoints(heartFrame)
end)