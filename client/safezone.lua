local QBCore = exports["qb-core"]:GetCoreObject()
local PlayerData = {}
local AllCreatedZones = {}

CreateThread(function()
	for k,v in pairs(AllZones) do
		local TempZone = nil
		local TempTable = {}
		for k2,v2 in ipairs(v.Zones) do
			TempZone = PolyZone:Create(v2.Coords, {
				name = k .. "_" .. k2,
				minZ = v2.minZ,
				maxZ = v2.maxZ,
				debugPoly = v.Debug,
				debugGrid = v.Debug,
			})
			table.insert(TempTable,TempZone)
		end
		if #TempTable > 1 then
			TempZone = ComboZone:Create(TempTable, {name= k .. "_combo"})

			TempZone:onPlayerInOut(function(isPointInside, point, zone)
			  EnteredZone(isPointInside,k)
			end, CheckLoopTime)
		else
			TempZone:onPointInOut(PolyZone.getPlayerPosition, function(isPointInside, point, zone)
			  EnteredZone(isPointInside,k)
			end, CheckLoopTime)
		end
	end
end)



local IsLoopStarted = false
local IsPlayerCanAttackInSafeZone = nil
local UnarmedHash = `WEAPON_UNARMED`
local WhatIsLastLoop = ""

RegisterNetEvent("QBCore:Client:OnPlayerLoaded")
AddEventHandler("QBCore:Client:OnPlayerLoaded",function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)



RegisterNetEvent("QBCore:Client:OnJobUpdate")
AddEventHandler("QBCore:Client:OnJobUpdate",function(job)
    PlayerData.job = job
end)

function EnteredZone(isPointInside,Name)
	local InZone,Name = InZone,Name
	if isPointInside and WhatIsLastLoop ~= Name then
		QBCore.Functions.Notify("Güvenli Alana Girdiniz. Silah Çekemezsiniz.")
		CreateThread(function()
			WhatIsLastLoop = Name
			IsLoopStarted = true
			while WhatIsLastLoop == Name do
				Wait(1)
				if PlayerData.job == nil then
					PlayerData = QBCore.Functions.GetPlayerData()
				end
				if WhiteListedJobs[PlayerData.job.name] then
					IsPlayerCanAttackInSafeZone = true
				else
					local player = PlayerPedId()
					SetCurrentPedWeapon(player, UnarmedHash, true)
					TriggerEvent('weapons:ResetHolster')
					DisablePlayerFiring(player,true) 
					DisableControlAction(0, 140, true)
					DisableControlAction(0, 25, true)
					IsPlayerCanAttackInSafeZone = false
				end
			end
			IsPlayerCanAttackInSafeZone = nil
			IsLoopStarted = false
		end)
	else
		QBCore.Functions.Notify("Güvenli Alandan Çıktınız. Silah Çekebilirsiniz.")
		WhatIsLastLoop = ""
	end
end

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
		return
	end
	for i = 1, #AllCreatedZones do
		AllCreatedZones[i]:destroy()
	end
	PlayerData = QBCore.Functions.GetPlayerData()
end)

InSafeZone = function()
    return IsLoopStarted
end

exports("InSafeZone", InSafeZone)

SafeZoneName = function()
    return WhatIsLastLoop
end

exports("SafeZoneName", SafeZoneName)

CanAttackInSafeZone = function()
    return IsPlayerCanAttackInSafeZone
end

exports("CanAttackInSafeZone", CanAttackInSafeZone)

SetJobAndGrade = function(NewJob,NewGrade)
	job = NewJob
	grade = NewGrade
end

exports("SetJobAndGrade", SetJobAndGrade)

function tprint (tbl, indent)
    if not indent then indent = 0 end
    for k, v in pairs(tbl) do
        formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            print(formatting)
            tprint(v, indent+1)
        elseif type(v) == 'boolean' then
            print(formatting .. tostring(v))
        else
            print(formatting .. v)
        end
    end
end

Alanlar = {
    ["alan"] = {
        [1] = { loc = vector3(304.19, -586.54, 43.28), heading = 70.0, }
    },
}

CreateThread(function()
    for k, v in pairs(Alanlar["alan"]) do

        local boxZone = BoxZone:Create(vector3(v.loc.x, v.loc.y, v.loc.z), 9.8, 5, {
            name = "alan" .. k,
            debugPoly = false,
            heading = v.heading,
            minZ = v.loc.z - 2,
            maxZ = v.loc.z + 2,
        })

        boxZone:onPlayerInOut(function(isPointInside)
            if isPointInside then
                local ped = PlayerPedId()
                local car = GetVehiclePedIsIn(PlayerPedId(),true)
                if IsPedInAnyVehicle(PlayerPedId(), false) then
                    QBCore.Functions.Notify('Araç Çekildi')
                    TaskLeaveVehicle(ped, car, 1)
                    DeleteVehicle(car)
                    DeleteEntity(car)
                end
            else
            end
        end)
    end
end)