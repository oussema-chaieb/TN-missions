local QBCore = exports['qb-core']:GetCoreObject()

local pedloc = 0
local pilot
local navigator
local navigator2

CreateThread(function()
    pedloc = math.random(1, #Config.Ped.Locations)
    SetupPedLocations()
    -- for _, coords in pairs(Config.Ped.Locations) do
    --     local blip = AddBlipForCoord(coords['x'], coords['y'], coords['z'])
    --     SetBlipSprite(blip, 500)
    --     SetBlipScale(blip, 0.8)
    --     SetBlipColour(blip, 4)
    --     SetBlipAsShortRange(blip, false)
    --     BeginTextCommandSetBlipName("STRING")
    --     AddTextComponentString("mission")
    --     EndTextCommandSetBlipName(blip)
    -- end    
end)

function SetupPedLocations()
    pedloc = math.random(1, #Config.Ped.Locations)
    SpawnNewPed()
end

function SpawnNewPed()
    for k, v in pairs(Config.Ped.Peds) do
        RequestModel(GetHashKey(v.model))
        while not HasModelLoaded(GetHashKey(v.model)) do
            Wait(1) 
        end
        missionped = CreatePed(4, v.model, Config.Ped.Locations[pedloc]["x"],Config.Ped.Locations[pedloc]["y"],Config.Ped.Locations[pedloc]["z"]-1, 3374176, false, true)
        SetEntityHeading(missionped, Config.Ped.Locations[pedloc]["h"])
        FreezeEntityPosition(missionped, true)
        SetEntityInvincible(missionped, true)
        SetBlockingOfNonTemporaryEvents(missionped, true)
        TaskStartScenarioInPlace(missionped, v.scenario, 0, true)
        exports["qb-target"]:AddTargetModel(v.model, {
            options = {
                {
                    event = 'tn-missions:cl:getMission', 
                    icon = v.icon, 
                    label = v.label
                },
                {
                    event = 'tn-missions:cl:joinTeam', 
                    icon = v.icon, 
                    label = "join Team mates",
                    canInteract = function() -- This will check if you can interact with it, this won't show up if it returns false, this is OPTIONAL
                        local missionData = checkMissionLevelAndStage()
                        if missionData.level == 1 and missionData.stage == 3 then return true else return false end
                    end,
                }
            }, 
            distance = v.distance
        })
    end
end
-- Delete ped
function DeleteWashPed()
    local player = PlayerPedId()
	if DoesEntityExist(missionped) then
        ClearPedTasks(missionped) 
		ClearPedTasksImmediately(missionped)
        ClearPedSecondaryTask(missionped)
        FreezeEntityPosition(missionped, false)
        SetEntityInvincible(missionped, false)
        SetBlockingOfNonTemporaryEvents(missionped, false)
        TaskReactAndFleePed(missionped, player)
		SetPedAsNoLongerNeeded(missionped)
		Wait(8000)
		DeletePed(missionped)
        SetupMoneyWash()
	end
end

function firstMissionStageOne()
    --TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 20, "mission_one_welcome", 1.0)
    --Wait(3000)
    local dialog = exports['qb-input']:ShowInput({
        header = "t7eb taatih il card ?",
        submitText = "Submit",
        inputs = {
            {
                text = "you want to give him the card ?", -- text you want to be displayed as a input header
                name = "givecard", -- name of the input should be unique otherwise it might override
                type = "radio", -- type of the input - Radio is useful for "or" options e.g; billtype = Cash OR Bill OR bank
                options = { -- The options (in this case for a radio) you want displayed, more than 6 is not recommended
                    { value = "yes", text = "Yes" }, -- Options MUST include a value and a text option
                    { value = "no", text = "No" }
                },
                default = "no", -- Default radio option, must match a value from above, this is optional
            },
        },
    })
    if dialog ~= nil then
        if dialog.givecard == "yes" then
            local hasitem = QBCore.Functions.HasItem("weed_card", 1)
            if hasitem then
                TriggerServerEvent("tn-missions:sv:joinMission")
                TriggerServerEvent("tn-missions:sv:removeItem", "weed_card", 1)
                TriggerServerEvent("tn-missions:sv:updateMissionStage", 1, 2)
            else
                missionFailed()
            end
        end
    end
end

function firstMissionStageTwo()
    --TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 20, "mission_one_intoductionstagetwo", 1.0)
    --Wait(3000)
    local dialog = exports['qb-input']:ShowInput({
        header = "t7eb te5o il mission wala mazelt t5amem ?",
        submitText = "Submit",
        inputs = {
            {
                text = "you want to take the mission ?", -- text you want to be displayed as a input header
                name = "takemission", -- name of the input should be unique otherwise it might override
                type = "radio", -- type of the input - Radio is useful for "or" options e.g; billtype = Cash OR Bill OR bank
                options = { -- The options (in this case for a radio) you want displayed, more than 6 is not recommended
                    { value = "yes", text = "Yes" }, -- Options MUST include a value and a text option
                    { value = "no", text = "No" }
                },
                default = "no", -- Default radio option, must match a value from above, this is optional
            },
        },
    })
    if dialog ~= nil then
        if dialog.takemission == "yes" then
            TriggerServerEvent("tn-missions:sv:updateMissionStage", 1, 3)
            --TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 20, "mission_one_colleguesadvice", 1.0)


        end
    end
end

function startMissionOne()
    local DrawCoord = math.random(1,5)
	VehicleCoords = Config.Ped.VehicleSpawn[DrawCoord]
    local ped = PlayerPedId()
    RequestModel(`stockade`)
    while not HasModelLoaded(`stockade`) do
        Wait(0)
    end
    ClearAreaOfVehicles(VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, 15.0, false, false, false, false, false)
    transport = CreateVehicle(`stockade`, VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, 52.0, true, true)
    SetEntityAsMissionEntity(transport)
    TruckBlip = AddBlipForEntity(transport)
    SetBlipSprite(TruckBlip, 57)
    SetBlipColour(TruckBlip, 1)
    SetBlipFlashes(TruckBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName('Van with Cash')
    EndTextCommandSetBlipName(TruckBlip)
    --
    RequestModel("s_m_m_security_01")
    while not HasModelLoaded("s_m_m_security_01") do
        Wait(10)
    end
    pilot = CreatePed(26, "s_m_m_security_01", VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, 268.9422, true, false)
    navigator = CreatePed(26, "s_m_m_security_01", VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, 268.9422, true, false)
    navigator2 = CreatePed(26, "s_m_m_security_01", VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, 268.9422, true, false)

    SetPedIntoVehicle(pilot, transport, -1)
    SetPedIntoVehicle(navigator, transport, 0)
    SetPedIntoVehicle(navigator2, transport, 1)
    SetPedFleeAttributes(pilot, 0, 0)
    SetPedCombatAttributes(pilot, 46, 1)
    SetPedCombatAbility(pilot, 100)
    SetPedCombatMovement(pilot, 2)
    SetPedCombatRange(pilot, 2)
    SetPedKeepTask(pilot, true)
    GiveWeaponToPed(pilot, Config.DriverWep,250,false,true)
    SetPedAsCop(pilot, true)
    --
    SetPedFleeAttributes(navigator, 0, 0)
    SetPedCombatAttributes(navigator, 46, 1)
    SetPedCombatAbility(navigator, 100)
    SetPedCombatMovement(navigator, 2)
    SetPedCombatRange(navigator, 2)
    SetPedKeepTask(navigator, true)
    GiveWeaponToPed(navigator, Config.NavWep,250,false,true)
    SetPedAsCop(navigator, true)
    --
    SetPedFleeAttributes(navigator2, 0, 0)
    SetPedCombatAttributes(navigator2, 46, 1)
    SetPedCombatAbility(navigator2, 100)
    SetPedCombatMovement(navigator2, 2)
    SetPedCombatRange(navigator2, 2)
    SetPedKeepTask(navigator2, true)
    GiveWeaponToPed(navigator2, Config.NavWep,250,false,true)
    SetPedAsCop(navigator2, true)
    --
    TaskVehicleDriveWander(pilot, transport, 80.0, 443)
end

function firstMissionStageThree()
    local dialog = exports['qb-input']:ShowInput({
        header = "tabda il mission ?",
        submitText = "Submit",
        inputs = {
            {
                text = "start the mission ?", -- text you want to be displayed as a input header
                name = "startmission", -- name of the input should be unique otherwise it might override
                type = "radio", -- type of the input - Radio is useful for "or" options e.g; billtype = Cash OR Bill OR bank
                options = { -- The options (in this case for a radio) you want displayed, more than 6 is not recommended
                    { value = "yes", text = "Yes" }, -- Options MUST include a value and a text option
                    { value = "no", text = "No" }
                },
                default = "no", -- Default radio option, must match a value from above, this is optional
            },
        },
    })
    if dialog ~= nil then
        if dialog.startmission == "yes" then
            TriggerServerEvent("tn-missions:sv:updateMissionStage", 1, 4)
            --TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 20, "mission_one_givemission", 1.0)
            --Wait(3000)
            startMissionOne()
        end
    end
end

function checkMissionLevelAndStage()
    local p = promise.new()
    QBCore.Functions.TriggerCallback('tn-missions:sv:GetMissionData', function(result)
        p:resolve(result)
    end)
    return Citizen.Await(p)
end

guards = {
	['npcguards'] = {}
}

function loadModel(model)
    if type(model) == 'number' then
        model = model
    else
        model = GetHashKey(model)
    end
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(0)
    end
end

function missionFailed()
    local ped = PlayerPedId()
    SetPedRelationshipGroupHash(ped, `PLAYER`)
    AddRelationshipGroup('npcguards')

    for k, v in pairs(Config.Ped.Guards[pedloc]) do
        loadModel(v['model'])
        guards['npcguards'][k] = CreatePed(26, GetHashKey(v['model']), v['coords'], v['heading'], true, true)
        NetworkRegisterEntityAsNetworked(guards['npcguards'][k])
        networkID = NetworkGetNetworkIdFromEntity(guards['npcguards'][k])
        SetNetworkIdCanMigrate(networkID, true)
        SetNetworkIdExistsOnAllMachines(networkID, true)
        SetPedRandomComponentVariation(guards['npcguards'][k], 0)
        SetPedRandomProps(guards['npcguards'][k])
        SetEntityAsMissionEntity(guards['npcguards'][k])
        SetEntityVisible(guards['npcguards'][k], true)
        SetPedRelationshipGroupHash(guards['npcguards'][k], `npcguards`)
        SetPedAccuracy(guards['npcguards'][k], 75)
        SetPedArmour(guards['npcguards'][k], 100)
        SetPedCanSwitchWeapon(guards['npcguards'][k], true)
        SetPedDropsWeaponsWhenDead(guards['npcguards'][k], false)
        SetPedFleeAttributes(guards['npcguards'][k], 0, false)
        GiveWeaponToPed(guards['npcguards'][k], v['weapon'], 255, false, false)
        TaskGoToEntity(guards['npcguards'][k], PlayerPedId(), -1, 1.0, 10.0, 1073741824.0, 0)
        local random = math.random(1, 2)
        if random == 2 then
            TaskGuardCurrentPosition(guards['npcguards'][k], 10.0, 10.0, 1)
        end
    end

    SetRelationshipBetweenGroups(0, `npcguards`, `npcguards`)
    SetRelationshipBetweenGroups(5, `npcguards`, `PLAYER`)
    SetRelationshipBetweenGroups(5, `PLAYER`, `npcguards`)
end

function takeReward()

end

RegisterNetEvent('tn-missions:cl:getMission', function()
    local missionData = checkMissionLevelAndStage()
    print(missionData.level)
    print(missionData.stage)
    if missionData.level == 1 then
        if missionData.stage == 1 then
            firstMissionStageOne()
        elseif missionData.stage == 2 then
            firstMissionStageTwo()
        elseif missionData.stage == 3 then
            firstMissionStageThree()
        elseif missionData.stage == 4 then
            takeReward(missionData.level)
        end
    end
end)

RegisterNetEvent('tn-missions:cl:joinTeam', function()
    local missionData = checkMissionLevelAndStage()
    if missionData.level == 1 then
        if missionData.stage == 3 then
            local dialog = exports['qb-input']:ShowInput({
                header = "team mate Id",
                submitText = "Submit",
                inputs = {
                    {
                        text = "Add team mates", -- text you want to be displayed as a input header
                        name = "id", -- name of the input should be unique otherwise it might override
                        type = "text", -- type of the input
                        isRequired = true,
                    },
                },
            })
            if dialog ~= nil then
                TriggerServerEvent("tn-missions:sv:joinMission", tonumber(dialog.id))
            end
        else
            QBCore.Functions.Notify("Not allowed ","error")
        end
    end
end)