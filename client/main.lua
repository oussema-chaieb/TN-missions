local QBCore = exports['qb-core']:GetCoreObject()

local pedloc = 0

CreateThread(function()
    pedloc = math.random(1, #Config.Ped.Locations)
    SetupPedLocations()
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
            options = {{
                event = 'tn-missions:cl:getMission', 
                icon = v.icon, 
                label = v.label
            }}, 
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
    TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 20, "mission_one_welcome", 1.0)
    Wait(3000)
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

        else
            TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 20, "mission_one_dismisscard", 1.0)
            -- TODO dismiss logic
        end
    end
end

function firstMissionStageTwo()
    TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 20, "mission_one_intoductionstagetwo", 1.0)
    Wait(3000)
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
            TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 20, "mission_one_colleguesadvice", 1.0)


        end
    end
end

function firstMissionStageThree()
    local dialog = exports['qb-input']:ShowInput({
        header = "tabda il mission ?",
        submitText = "Submit",
        inputs = {
            {
                text = "satrt the mission ?", -- text you want to be displayed as a input header
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
            TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 20, "mission_one_givemission", 1.0)
            Wait(3000)



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

RegisterNetEvent('tn-missions:cl:getMission', function()
    local missionData = checkMissionLevelAndStage()
    print(missionData.level)
    print(missionData.stage)
end)

RegisterNetEvent('tn-missions:cl:takeReward', function()

end)