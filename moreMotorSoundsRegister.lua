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

    local category = "no category found"
    if storeItem == nil then
    elseif configurations == nil then
    elseif configurations["moreMotorSounds"] ~= nil then
    else
        category = "/" .. string.upper(storeItem.categoryName) .. "/"
    end

    if string.find(_allUsedCategories, category) then

        configurations["moreMotorSounds"] = {
            {name = g_i18n:getText("CONFIG_STANDARD_SOUND"), index = 1, isDefault = true,  price = 0, dailyUpkeep = 0, isSelectable = true}
        }

        local j = 2
        local i = 2
        local name = string.lower(storeItem.name)




		while _configName[j] ~= nil do
			local excludeBlowoff = _excludeBlowoff[j] -- Use the parsed excludeBlowoff value

			-- Determine if we should apply the blowoff filter based on multiplayer status
			local isMultiplayer = g_currentMission ~= nil and g_currentMission.missionDynamicInfo ~= nil and g_currentMission.missionDynamicInfo.isMultiplayer
			if not isMultiplayer and g_mpLoadingScreen ~= nil and g_mpLoadingScreen.missionDynamicInfo ~= nil then
				isMultiplayer = g_mpLoadingScreen.missionDynamicInfo.isMultiplayer
			end

			local shouldExcludeBlowoff = isMultiplayer and 
										 (string.find(_configName[j]:lower(), "blowoff") or excludeBlowoff == "true")

			-- If not excluding due to blowoff, proceed with the rest of the logic
			if not shouldExcludeBlowoff then
				if _brand[j] == "" or _brand[j] == storeItem.brandNameRaw then
					if string.find(_category[j], category) then
						if _search[j] == "" or string.find(storeItem.xmlFilenameLower, _search[j]) or string.find(name, _search[j]) or string.find(storeItem.xmlFilenameLower, _search2[j]) or string.find(name, _search2[j]) then
							if not string.find(name, _exclude[j]) or _exclude[j] == "" then
								if not string.find(name, _exclude2[j]) or _exclude2[j] == "" then
									configurations["moreMotorSounds"][i] = {}
									configurations["moreMotorSounds"][i].name = _configName[j]
									configurations["moreMotorSounds"][i].index = i
									configurations["moreMotorSounds"][i].indexMMS = j
									configurations["moreMotorSounds"][i].isDefault = false
									configurations["moreMotorSounds"][i].price = 0
									configurations["moreMotorSounds"][i].dailyUpkeep = 0
									configurations["moreMotorSounds"][i].isSelectable = true
									i = i + 1
								end
							end
						end
					end
				end
			else
				print("Excluding configName due to blowoff condition: ", _configName[j])
			end

			j = j + 1
		end





    end

    return configurations
end

if g_configurationManager.configurations["moreMotorSounds"] == nil then
    initNewStoreConfig()
end
