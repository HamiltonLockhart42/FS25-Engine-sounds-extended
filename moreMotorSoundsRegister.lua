--[[
    Script-Author: PeterAH (Modding-Welt)
    Sounds: Vassili_K98 (Farming Dud's)
	peppie84 + Aekzl: soundVolumeFactor fix; disable blowoff in multiplayer;
    Mod name: More Motor Sounds
    Version: 1.0.0.0
    Date: August 2024
    Script-Support: https://www.modding-welt.com
    Sound-Support: https://discord.gg/MFpAxHX5xK
    Discord: @peter_ah
]]

    if g_specializationManager:getSpecializationByName("moreMotorSounds") == nil then
        g_specializationManager:addSpecialization('moreMotorSounds', 'moreMotorSounds', Utils.getFilename('moreMotorSounds.lua', g_currentModDirectory), nil)
    end

    for vehicleTypeName, vehicleType in pairs(g_vehicleTypeManager.types) do
        if vehicleType == nil then
        elseif SpecializationUtil.hasSpecialization(moreMotorSounds, vehicleType.specializations) then
        elseif not SpecializationUtil.hasSpecialization(Motorized, vehicleType.specializations) then
        elseif not SpecializationUtil.hasSpecialization(Drivable, vehicleType.specializations) then
        elseif not SpecializationUtil.hasSpecialization(Wheels, vehicleType.specializations) then
        elseif not SpecializationUtil.hasSpecialization(Enterable, vehicleType.specializations) then
        elseif SpecializationUtil.hasSpecialization(Locomotive, vehicleType.specializations) then
        elseif SpecializationUtil.hasSpecialization(SplineVehicle, vehicleType.specializations) then
        elseif vehicleTypeName == 'locomotive' then
        elseif vehicleTypeName == 'conveyorBelt' then
        else
            g_vehicleTypeManager:addSpecialization(vehicleTypeName, 'moreMotorSounds')
        end
    end

    local modDescFile = loadXMLFile("modDescFile", g_currentModDirectory .. "modDesc.xml")
    local _standardCategories = Utils.getNoNil(getXMLString(modDescFile, "modDesc.motorSounds#standardCategories"), "")
    _standardCategories = "/" .. string.upper(_standardCategories) .. "/"
    _allUsedCategories = _standardCategories
    local _configName = {}
    local _configNameDE = {}
    local _brand = {}
    local _category ={}
    local _search = {}
    local _search2 = {}
    local _exclude = {}
    local _exclude2 = {}
    local _excludeBlowoff = {} -- Add this to store the parsed excludeBlowoff values
    local i = 0


    while true do
        local keyPath = "modDesc.moreMotorSounds.motorSound(" .. tostring(i) .. ")"
        if not hasXMLProperty(modDescFile, keyPath) then
            break
        end
        _configName[i+2] = Utils.getNoNil(getXMLString(modDescFile, keyPath .. "#configName"), "")
        _configNameDE[i+2] = Utils.getNoNil(getXMLString(modDescFile, keyPath .. "#configNameDE"), "")
        if _configNameDE[i+2] ~= "" then
            if g_gui.languageSuffix == "_de" then
                _configName[i+2] = _configNameDE[i+2]
            end
        end

        _brand[i+2] = Utils.getNoNil(getXMLString(modDescFile, keyPath .. "#brand"), "")
        _category[i+2] = Utils.getNoNil(getXMLString(modDescFile, keyPath .. "#category"), "")
        if _category[i+2] == "" then
            _category[i+2] = _standardCategories
        else
            _category[i+2] = "/" .. string.upper(_category[i+2]) .. "/"
            if _category[i+2] ~= _standardCategories then
                _allUsedCategories = _allUsedCategories .. _category[i+2]
            end
        end

        _search[i+2] = string.lower(Utils.getNoNil(getXMLString(modDescFile, keyPath .. "#search"), ""))
        _search2[i+2] = string.lower(Utils.getNoNil(getXMLString(modDescFile, keyPath .. "#search2"), "no__search"))
        if _search[i+2] == "" then
            if _search2[i+2] ~= "no__search" then
                _search[i+2] = _search2[i+2]
            end
        end

        _exclude[i+2] = string.lower(Utils.getNoNil(getXMLString(modDescFile, keyPath .. "#exclude"), ""))
        _exclude2[i+2] = string.lower(Utils.getNoNil(getXMLString(modDescFile, keyPath .. "#exclude2"), ""))

        -- Parse the excludeBlowoff attribute
        _excludeBlowoff[i+2] = Utils.getNoNil(getXMLString(modDescFile, keyPath .. "#excludeBlowoff"), "false")
        -- if not isMultiplayer then
            -- _excludeBlowoff[i+2] = false
        -- end
		
        i = i + 1
    end
    delete(modDescFile)

function initNewStoreConfig()
    --print("initNewStoreConfig =================================")
    g_configurationManager:addConfigurationType("moreMotorSounds", g_i18n:getText("CONFIG_TITLE"), nil, nil, nil, nil, ConfigurationUtil.SELECTOR_MULTIOPTION)
	StoreItemUtil.getConfigurationsFromXML = Utils.overwrittenFunction(StoreItemUtil.getConfigurationsFromXML, addNewStoreConfig)
end

function addNewStoreConfig(xmlFile, superFunc, baseXMLName, baseDir, customEnvironment, isMod, storeItem)
	local configurations = superFunc(xmlFile, baseXMLName, baseDir, customEnvironment, isMod, storeItem)

    if storeItem == nil or configurations == nil or configurations["moreMotorSounds"] ~= nil then
        return configurations
    end

    configurations["moreMotorSounds"] = {
        {name = g_i18n:getText("CONFIG_STANDARD_SOUND"), index = 1, isDefault = true,  price = 0, dailyUpkeep = 0, isSelectable = true}
    }

    local isMultiplayer = g_currentMission ~= nil and g_currentMission.missionDynamicInfo ~= nil and g_currentMission.missionDynamicInfo.isMultiplayer
    if not isMultiplayer and g_mpLoadingScreen ~= nil and g_mpLoadingScreen.missionDynamicInfo ~= nil then
        isMultiplayer = g_mpLoadingScreen.missionDynamicInfo.isMultiplayer
    end

    local i = 2
    local j = 2
    while _configName[j] ~= nil do
        local excludeBlowoff = _excludeBlowoff[j]
        local shouldExcludeBlowoff = isMultiplayer and (string.find(_configName[j]:lower(), "blowoff") or excludeBlowoff == "true")

        if not shouldExcludeBlowoff then
            configurations["moreMotorSounds"][i] = {
                name = _configName[j],
                index = i,
                indexMMS = j,
                isDefault = false,
                price = 0,
                dailyUpkeep = 0,
                isSelectable = true
            }
            i = i + 1
        end

        j = j + 1
    end

    return configurations
end

if g_configurationManager.configurations["moreMotorSounds"] == nil then
    initNewStoreConfig()
end
