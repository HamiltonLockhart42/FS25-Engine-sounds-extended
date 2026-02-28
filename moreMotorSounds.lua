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

moreMotorSounds = {}
local _modDirectory = g_currentModDirectory
local _modName = g_currentModName
local modDescFile = loadXMLFile("modDescFile", g_currentModDirectory .. "modDesc.xml")
local soundFile = {}
local i = 0
while true do
    local keyPath = "modDesc.moreMotorSounds.motorSound(" .. tostring(i) .. ")"
    if not hasXMLProperty(modDescFile, keyPath) then
        break
    end
    soundFile[i+2] = Utils.getNoNil(getXMLString(modDescFile, keyPath .. "#soundFile"), "")
    i = i + 1
end
delete(modDescFile)

--  --  --  --  --

function moreMotorSounds.prerequisitesPresent(specializations)
    return true
end

function moreMotorSounds.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onPreLoad", moreMotorSounds)
end

function moreMotorSounds.initSpecialization()
    local schemaSavegame = Vehicle.xmlSchemaSavegame
    schemaSavegame:register(XMLValueType.INT, "vehicles.vehicle(?)." .. _modName .. ".moreMotorSounds#configurationId", "More motor sounds configuration id", 1)
end

function moreMotorSounds:onPreLoad(savegame)

    if SpecializationUtil.hasSpecialization(Honk, self.specializations) then
        Honk.onLoad = Utils.overwrittenFunction(Honk.onLoad, moreMotorSounds.onLoadHonk)
    end

    local configurationId = Utils.getNoNil(self.configurations["moreMotorSounds"], 0)
    if savegame ~= nil then
        if configurationId > 0 then
            configurationId = savegame.xmlFile:getValue(savegame.key .. "." .. _modName .. ".moreMotorSounds#configurationId", configurationId)
            if configurationId < 1 then
                configurationId = 1
            end
            self.configurations["moreMotorSounds"] = configurationId
        end
    end
    
    local configId = Utils.getNoNil(self.configurations["moreMotorSounds"], 1)
    local indexMMS = 1
    if configId >= 2 then
        local storeItem = g_storeManager:getItemByXMLFilename(self.configFileName)
        if storeItem ~= nil and storeItem.configurations ~= nil then
            if storeItem.configurations["moreMotorSounds"] ~= nil then
                if storeItem.configurations["moreMotorSounds"][configId] ~= nil then
                    if storeItem.configurations["moreMotorSounds"][configId].indexMMS ~= nil then
                        indexMMS = storeItem.configurations["moreMotorSounds"][configId].indexMMS
                    end
                end
            end
        end

        if indexMMS >= 2 then
            self.externalSoundsFilename = _modDirectory .. soundFile[indexMMS]
            if self.externalSoundsFile ~= nil then
                self.externalSoundsFile:delete()
            end
            self.externalSoundsFile = XMLFile.load("TempExternalSounds", self.externalSoundsFilename, Vehicle.xmlSchemaSounds)
			self.soundVolumeFactor = 1
        else
            self.configurations["moreMotorSounds"] = 1
        end
    end
    
end

function moreMotorSounds:loadSounds(superFunc, xmlFile, baseString)
    local configId = Utils.getNoNil(self.configurations["moreMotorSounds"], 1)
    if configId == 1 then
        superFunc(self, xmlFile, baseString)
    else
        local baseDirectoryBackup = self.baseDirectory
        self.baseDirectory = _modDirectory
        superFunc(self, xmlFile, baseString)
        self.baseDirectory = baseDirectoryBackup        
    end
end
Motorized.loadSounds = Utils.overwrittenFunction(Motorized.loadSounds, moreMotorSounds.loadSounds)

function moreMotorSounds:onLoadHonk(superFunc, savegame)
    local configId = Utils.getNoNil(self.configurations["moreMotorSounds"], 1)
    if configId == 1 then
        superFunc(self, savegame)
    else
        local baseDirectoryBackup = self.baseDirectory
        self.baseDirectory = _modDirectory
        superFunc(self, savegame)
        self.baseDirectory = baseDirectoryBackup        
    end
end
function moreMotorSounds:saveToXMLFile(xmlFile, key, usedModNames)
    if self.configurations ~= nil then
        if self.configurations["moreMotorSounds"] ~= nil then
            xmlFile:setValue(key.."#configurationId", self.configurations["moreMotorSounds"])
        end
    end
end
