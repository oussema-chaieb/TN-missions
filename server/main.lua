local QBCore = exports['qb-core']:GetCoreObject()

local missionPlayers = {}

QBCore.Functions.CreateCallback('tn-missions:sv:GetMissionData', function(source, cb)
    local player = QBCore.Functions.GetPlayer(source)

    MySQL.Async.fetchAll('SELECT level, stage FROM mission WHERE citizenid = ?', { player.PlayerData.citizenid }, function(result)
        if result and #result > 0 then
            local missionData = {
                level = result[1].level,
                stage = result[1].stage
            }
            cb(missionData)
        else
            MySQL.Async.execute('INSERT INTO mission (citizenid, level, stage) VALUES (?, ?, ?)', { player.PlayerData.citizenid, 1, 1 }, function(rowsInserted)
                if rowsInserted > 0 then
                    local newMissionData = {
                        level = 1, 
                        stage = 1 
                    }
                    cb(newMissionData)
                else
                    print("insertion to database error")
                    cb(nil) -- Failed to insert new mission data
                end
            end)
        end
    end)
end)

RegisterNetEvent("tn-missions:sv:joinMission", function(id)
    local src = source
    local Player = QBCore.Functions.GetPlayer(id)
    local bool = false 
    for k,v in pairs(missionPlayers) do
        if v == id then
            bool = true
            break
        end
    end
    if bool == true then
        TriggerClientEvent('QBCore:Notify', src, "you allready here.", 'error')
    else
        table.insert(missionPlayers,id)
        TriggerClientEvent('QBCore:Notify', src, "You Join the team", 'success')
        for k,v in pairs(missionPlayers) do
            local xPlayer = QBCore.Functions.GetPlayer(v)
            MySQL.Async.execute('INSERT INTO mission (citizenid, level, stage) VALUES (?, ?, ?)', { xPlayer.PlayerData.citizenid, 1, 1 })
            TriggerClientEvent('QBCore:Notify', v, Player.PlayerData.charinfo.firstname.." Join the team", 'success')
        end
    end
    -- Todo
end)