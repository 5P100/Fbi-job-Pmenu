local CurrentActionData, handcuffTimer, dragStatus, blipsCops, currentTask = {}, {}, {}, {}, {}
local HasAlreadyEnteredMarker, isDead, isHandcuffed, hasAlreadyJoined, playerInService = false, false, false, false, false
local LastStation, LastPart, LastPartNum, LastEntity, CurrentAction, CurrentActionMsg
local spawnedVehicles = {}

dragStatus.isDragged, isInShopMenu = false, false
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)

function OpenAccueilMenu()
local accueilmenu = {
	Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {255, 255, 255}, Title = "Accueil" },
	Data = { currentMenu = "Accueil FBI"},
	Events = {
		onSelected = function(self, _, btn, PMenu, menuData, currentButton, currentBtn, currentSlt, result)
			local interval = 200

			if btn.name == "Renseignements" then
				Advancednotif("Secrétaire", "~b~FBI", "Vous pouvez vous diriger dans le couloir sur votre droite pour l'accès aux ascenseurs.", "CHAR_FBI", 1)
				Citizen.Wait(interval)
				CloseMenu(force)
			end    
		end,
	},

	Menu = {
		["Accueil FBI"] = {
			b = {
				{name = "Renseignements", ask = "→→", askX = true, Description = "~g~Demander ~c~des renseignements."},
			}
		}
	}
}

CreateMenu(accueilmenu)
end

function OpenCloakroomMenu()
local vestiairesmenu = {
	Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {255, 255, 255}, Title = "Vestiaires" },
	Data = { currentMenu = "Vestiaires FBI"},
	Events = {
		onSelected = function(self, _, btn, PMenu, menuData, currentButton, currentBtn, currentSlt, result)
			local interval = 200
			local playerPed = GetPlayerPed(-1)

			local uniformObject
			if btn.name == "Tenue FBI" then
				SetFBIOutfit()
				Advancednotif("Secrétaire", "~b~FBI", "Vous avez enfilé votre tenue de fonction.", "CHAR_FBI", 1)
			elseif btn.name == "Tenue Civil" then
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
					TriggerEvent('skinchanger:loadSkin', skin)
				end)
				Advancednotif("Secrétaire", "~b~FBI", "Vous avez récuperé vos affaires.", "CHAR_FBI", 1)
			elseif btn.name == "Gilet Pare-Balles" then
				SetBulletProof()
			end    
		end,
	},

	Menu = {
		["Vestiaires FBI"] = {
			b = {
				{name = "Tenue FBI", ask = "→→", askX = true, Description = "~g~Enfiler ~c~la tenue de service."},
				{name = "Tenue Civil", ask = "→→", askX = true, Description = "~g~Reprendre ~c~ses affaires."},
				{name = "Gilet Pare-Balles", ask = "→→", askX = true, Description = "~g~Mettre ~c~un gilet pare balles."},
			}
		}
	}
}

CreateMenu(vestiairesmenu)
end

function OpenArmoryMenu()
ArmoryMenu = {
	Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {255, 255, 255}, Title = "Armurerie" },
	Data = { currentMenu = "Armurerie FBI"},
	Events = {
		onSelected = function(self, _, btn, PMenu, menuData, currentButton, currentBtn, currentSlt, result)
			local interval = 200
			local playerPed = GetPlayerPed(-1)

			if btn.name == "Prendre Armes" then
				GetEquipement()
				Citizen.Wait(200)
				Advancednotif("Secrétaire", "~b~FBI", "Vous avez récuperer votre équipement !", "CHAR_FBI", 1)
			elseif btn.name == "Déposer Armes" then
				RemovePlayerWeapons()
				Citizen.Wait(200)
				Advancednotif("Secrétaire", "~b~FBI", "Vous avez bien déposé la totalité de votre équipement !", "CHAR_FBI", 1)
			elseif btn.name == "Déposer Coffre" then
				CloseMenu(force)
				OpenPutStocksMenu()
			elseif btn.name == "Pendre Coffre" then 
				CloseMenu(force)
				OpenGetStocksMenu()
			end    
		end,
	},

	Menu = {
		["Armurerie FBI"] = {
			b = {
				{name = "Prendre Armes", ask = "→→", askX = true, Description = "~g~Récuperer ~c~équipement de service."},
				{name = "Déposer Armes", ask = "→→", askX = true, Description = "~y~Attention~s~ ~c~cela retirera la ~r~PLUPART~c~ de vos armes."},
				{name = "~b~~h~↓~s~", ask = "~b~~h~↓~s~", askX = true},
				{name = "Pendre Coffre", ask = "→→", askX = true, Description = "~g~Prendre~s~ ~c~des choses dans le coffre du FBI."},
				{name = "Déposer Coffre", ask = "→→", askX = true, Description = "~g~Déposer~s~ ~c~des choses dans le coffre du FBI."},
			}
		}
	}
}

CreateMenu(ArmoryMenu)
end

function OpenFBIActionsMenu()
F6Menu = {
	Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {255, 255, 255}, Title = "Menu F6" },
	Data = { currentMenu = "Menu Interactions FBI"},
	Events = {
		onSelected = function(self, _, btn, PMenu, menuData, currentButton, currentBtn, currentSlt, result)
			local interval = 200
			local playerPed = GetPlayerPed(-1)
			local coords = GetEntityCoords(playerPed)
			local vehicle = ESX.Game.GetVehicleInDirection()
			local vehicleData = ESX.Game.GetVehicleProperties(vehicle)
			local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

			if btn.name == "Interactions Citoyen" then
				OpenMenu("Interactions Citoyens")
			elseif btn.name == "Interactions Véhicule" then
				OpenMenu("Interactions Véhicules")
			elseif btn.name == "Menu Props" then
				CloseMenu(force)
				OpenPropsMenu()
			elseif btn.name == "Carte d'identité" then
				if closestPlayer ~= -1 and closestDistance <= 3.0 then
					OpenIdentityCardMenu(closestPlayer)
				else
					ESX.ShowNotification(_U('no_players_nearby'))
				end
			elseif btn.name == "Fouiller" then
				if closestPlayer ~= -1 and closestDistance <= 3.0 then
					OpenBodySearchMenu(closestPlayer)
				else
					ESX.ShowNotification(_U('no_players_nearby'))
				end
			elseif btn.name == "Menotter" then
				if closestPlayer ~= -1 and closestDistance <= 3.0 then
					TriggerServerEvent('esx_fbi_job:handcuff', GetPlayerServerId(closestPlayer))
				else
					ESX.ShowNotification(_U('no_players_nearby'))
				end
			elseif btn.name == "Escorter" then
				if closestPlayer ~= -1 and closestDistance <= 3.0 then
					TriggerServerEvent('esx_fbi_job:drag', GetPlayerServerId(closestPlayer))
				else
					ESX.ShowNotification(_U('no_players_nearby'))
				end
			elseif btn.name == "Mettre dans le véhicule" then
				if closestPlayer ~= -1 and closestDistance <= 3.0 then
					TriggerServerEvent('esx_fbi_job:putInVehicle', GetPlayerServerId(closestPlayer))
				else
					ESX.ShowNotification(_U('no_players_nearby'))
				end
			elseif btn.name == "Sortir du véhicule" then
				if closestPlayer ~= -1 and closestDistance <= 3.0 then
					TriggerServerEvent('esx_fbi_job:OutVehicle', GetPlayerServerId(closestPlayer))
				else
					ESX.ShowNotification(_U('no_players_nearby'))
				end
			elseif btn.name == "Factures Impayées" then
				if closestPlayer ~= -1 and closestDistance <= 3.0 then
					OpenUnpaidBillsMenu(closestPlayer)
				else
					ESX.ShowNotification(_U('no_players_nearby'))
				end
			elseif btn.name == "Licenses" then
				if closestPlayer ~= -1 and closestDistance <= 3.0 then
					ShowPlayerLicense(closestPlayer)
				else
					ESX.ShowNotification(_U('no_players_nearby'))
				end
			elseif btn.name == "Amende" then 
				if closestPlayer ~= -1 and closestDistance <= 3.0 then
					OpenFineMenu(closestPlayer)
				else
					ESX.ShowNotification(_U('no_players_nearby'))
				end
			-----------------------------------------------------------
			elseif btn.name == "Informations proprietaire" then
				CloseMenu(force)
				if DoesEntityExist(vehicle) then
					OpenVehicleInfosMenu(vehicleData)
				else
					ESX.ShowNotification(_U('no_vehicles_nearby'))
				end
			elseif btn.name == "Déverouiller" then
				if DoesEntityExist(vehicle) then
					if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 3.0) then
						TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_WELDING', 0, true)
						Citizen.Wait(20000)
						ClearPedTasksImmediately(playerPed)

						SetVehicleDoorsLocked(vehicle, 1)
						SetVehicleDoorsLockedForAllPlayers(vehicle, false)
						ESX.ShowNotification(_U('vehicle_unlocked'))
					end
				else
					ESX.ShowNotification(_U('no_vehicles_nearby'))
				end
			elseif btn.name == "Fourrière" then
				if DoesEntityExist(vehicle) then
					if currentTask.busy then
						return
					end

					ESX.ShowHelpNotification(_U('impound_prompt'))
					
					TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)

					currentTask.busy = true
					currentTask.task = ESX.SetTimeout(10000, function()
						ClearPedTasks(playerPed)
						ImpoundVehicle(vehicle)
						Citizen.Wait(100) 
					end)

					Citizen.CreateThread(function()
						while currentTask.busy do
							Citizen.Wait(1000)

							vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 3.0, 0, 71)
							if not DoesEntityExist(vehicle) and currentTask.busy then
								ESX.ClearTimeout(currentTask.task)
								ClearPedTasks(playerPed)
								currentTask.busy = false
								break
							end
						end
					end)
				else
					ESX.ShowNotification(_U('no_vehicles_nearby'))
				end
				--
			elseif btn.name == "Infos Véhicule" then
				if DoesEntityExist(vehicle) then
					LookupVehicle()	
				else
					ESX.ShowNotification(_U('no_vehicles_nearby'))
				end
				
			end    
		end,
	},

	Menu = {
		["Menu Interactions FBI"] = {
			b = {
				{name = "Interactions Citoyen", ask = "→→", askX = true, Description = "~g~Acceder ~c~au menu interactions citoyens."},
				{name = "Interactions Véhicule", ask = "→→", askX = true, Description = "~g~Acceder ~c~au menu interactions véhicules."},
				{name = "Menu Props", ask = "→→", askX = true, Description = "~g~Acceder ~c~au menu props."},
			}
		},
		["Interactions Citoyens"] = {
			b = {
				{name = "Carte d'identité", ask = "", askX = true, Description = "~g~Regarder ~c~la carte d'identité de la personne."},
				{name = "Fouiller", ask = "", askX = true, Description = "~g~Fouiller ~c~la personne."},
				{name = "Menotter", ask = "", askX = true, Description = "~g~Menotter ~c~la personne."},
				{name = "Escorter", ask = "", askX = true, Description = "~g~Escorter ~c~la personne."},
				{name = "~b~~h~↓~s~", ask = "~b~~h~↓~s~", askX = true},
				{name = "Mettre dans le véhicule", ask = "", askX = true, Description = "~g~Mettre ~c~la personne dans le véhicule."},
				{name = "Sortir du véhicule", ask = "", askX = true, Description = "~g~Sortir ~c~la personne du véhicule."},
				{name = "~b~~h~↓~s~", ask = "~b~~h~↓~s~", askX = true},
				{name = "Factures Impayées", ask = "", askX = true, Description = "~g~Gerer ~c~les factures impayées de la personne."},
				{name = "Licenses", ask = "", askX = true, Description = "~g~Voir ~c~les licenses de la personne."},
				{name = "Amende", ask = "", askX = true, Description = "~g~Mettre ~c~une amende à la personne."},
			}
		},
		["Interactions Véhicules"] = {
			b = {
				{name = "Infos Véhicule", ask = "", askX = true, Description = "~g~Voir ~c~les informations du véhicule depuis la base de données du FBI."},
				{name = "Informations proprietaire", ask = "", askX = true, Description = "~g~Voir ~c~les informations du véhicule."},
				{name = "Déverouiller", ask = "", askX = true, Description = "~g~Déverouiller ~c~le véhicule."},
				{name = "Fourrière", ask = "", askX = true, Description = "~g~Mettre ~c~le véhicule en fourrière."},
			}
		}
	}
}

CreateMenu(F6Menu)
end

function OpenPropsMenu()
PropsMenu = {
	Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {255, 255, 255}, Title = "Menu Props" },
	Data = { currentMenu = "Props FBI"},
	Events = {
		onSelected = function(self, _, btn, PMenu, menuData, currentButton, currentBtn, currentSlt, result)
			local interval = 200
			local playerPed = GetPlayerPed(-1)
			local coords, forward = GetEntityCoords(playerPed), GetEntityForwardVector(playerPed)
			local objectCoords = (coords + forward * 1.0)
			--props
			local cone = "prop_roadcone02a"
			local bar = "prop_barrier_work05"
			local hrs = "p_ld_stinger_s"
			local box = "prop_boxpile_07d"

			if btn.name == "Cône" then
				SpawnProp(cone)
			elseif btn.name == "Barrière" then
				SpawnProp(bar)
			elseif btn.name == "Herses" then
				SpawnProp(hrs)
			elseif btn.name == "Boite" then
				SpawnProp(box)
			end    
		end,
	},

	Menu = {
		["Props FBI"] = {
			b = {
				{name = "Cône", ask = "→→", askX = true, Description = "~g~Faire ~c~apparaitre un cône."},
				{name = "Barrière", ask = "→→", askX = true, Description = "~g~Faire ~c~apparaitre une barrière."},
				{name = "Herses", ask = "→→", askX = true, Description = "~g~Faire ~c~apparaitre des herses."},
				{name = "Boite", ask = "→→", askX = true, Description = "~g~Faire ~c~apparaitre une boite."},
			}
		}
	}
}

CreateMenu(PropsMenu)
end

function SpawnProp(nomprop)
	local playerPed = GetPlayerPed(-1)
	local coords, forward = GetEntityCoords(playerPed), GetEntityForwardVector(playerPed)
	local objectCoords = (coords + forward * 1.0)
	ESX.Game.SpawnObject(nomprop, objectCoords, function(obj)
		SetEntityHeading(obj, GetEntityHeading(playerPed))
		PlaceObjectOnGroundProperly(obj)
	end)
end

function OpenIdentityCardMenu(player)
	ESX.TriggerServerCallback('esx_fbi_job:getOtherPlayerData', function(data)
		local elements = {
			{label = _U('name', data.name)},
			{label = _U('job', ('%s - %s'):format(data.job, data.grade))}
		}

		if Config.EnableESXIdentity then
			table.insert(elements, {label = _U('sex', _U(data.sex))})
			table.insert(elements, {label = _U('dob', data.dob)})
			table.insert(elements, {label = _U('height', data.height)})
		end

		if data.drunk then
			table.insert(elements, {label = _U('bac', data.drunk)})
		end

		if data.licenses then
			table.insert(elements, {label = _U('license_label')})

			for i=1, #data.licenses, 1 do
				table.insert(elements, {label = data.licenses[i].label})
			end
		end

	end, GetPlayerServerId(player))
end

function OpenBodySearchMenu(player)
	ESX.TriggerServerCallback('esx_fbi_job:getOtherPlayerData', function(data)
		local elements = {}

		for i=1, #data.accounts, 1 do
			if data.accounts[i].name == 'black_money' and data.accounts[i].money > 0 then
				table.insert(elements, {
					label = _U('confiscate_dirty', ESX.Math.Round(data.accounts[i].money)),
					value = 'black_money',
					itemType = 'item_account',
					amount = data.accounts[i].money
				})

				break
			end
		end

		table.insert(elements, {label = _U('guns_label')})

		for i=1, #data.weapons, 1 do
			table.insert(elements, {
				label = _U('confiscate_weapon', ESX.GetWeaponLabel(data.weapons[i].name), data.weapons[i].ammo),
				value = data.weapons[i].name,
				itemType = 'item_weapon',
				amount = data.weapons[i].ammo
			})
		end

		table.insert(elements, {label = _U('inventory_label')})

		for i=1, #data.inventory, 1 do
			if data.inventory[i].count > 0 then
				table.insert(elements, {
				label = _U('confiscate_inv', data.inventory[i].count, data.inventory[i].label),
				value = data.inventory[i].name,
				itemType = 'item_standard',
				amount = data.inventory[i].count
				})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'body_search', {
			title = _U('search'),
			align = 'top-left',
			elements = elements
		}, function(data, menu)
			if data.current.value then
				TriggerServerEvent('esx_fbi_job:confiscatePlayerItem', GetPlayerServerId(player), data.current.itemType, data.current.value, data.current.amount)
				OpenBodySearchMenu(player)
			end
		end, function(data, menu)
			menu.close()
		end)
	end, GetPlayerServerId(player))
end

function OpenFineMenu(player)
	if Config.EnablePoliceFine then
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'fine', {
			title = _U('fine'),
			align = 'top-left',
			elements = {
				{label = _U('traffic_offense'), value = 0},
				{label = _U('minor_offense'),   value = 1},
				{label = _U('average_offense'), value = 2},
				{label = _U('major_offense'),   value = 3}
			}
		}, function(data, menu)
			OpenFineCategoryMenu(player, data.current.value)
		end, function(data, menu)
			menu.close()
		end)
	end
end

function OpenFineCategoryMenu(player, category)
	if Config.EnablePoliceFine then 
		ESX.TriggerServerCallback('esx_fbi_job:getFineList', function(fines)
			local elements = {}

			for k,fine in ipairs(fines) do
				table.insert(elements, {
					label = ('%s <span style="color:green;">%s</span>'):format(fine.label, _U('armory_item', ESX.Math.GroupDigits(fine.amount))),
					value = fine.id,
					amount = fine.amount,
					fineLabel = fine.label
				})
			end

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'fine_category', {
				title = _U('fine'),
				align = 'top-left',
				elements = elements
			}, function(data, menu)
				menu.close()

				if Config.EnablePlayerManagement then
					TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), 'society_fbi', _U('fine_total', data.current.fineLabel), data.current.amount)
				else
					TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), '', _U('fine_total', data.current.fineLabel), data.current.amount)
				end

				ESX.SetTimeout(300, function()
					OpenFineCategoryMenu(player, category)
				end)

			end, function(data, menu)
				menu.close()
			end)

		end, category)
	end
end

function LookupVehicle()
	KeyboardInput("Plaque d'immatriculation :", "", 9)
	while (UpdateOnscreenKeyboard() == 0) do
		DisableAllControlActions(0);
	Citizen.Wait(interval)
	end

	if (GetOnscreenKeyboardResult()) then
		local vehinfos = GetOnscreenKeyboardResult()
	end
	if not vehinfos or length < 2 or length > 9 then
		ESX.ShowNotification(_U('search_database_error_invalid'))
	else
		ESX.TriggerServerCallback('esx_fbi_job:getVehicleInfos', function(retrivedInfo)
			local elements = {{label = _U('plate', retrivedInfo.plate)}}
			menu.close()

			if not retrivedInfo.owner then
				table.insert(elements, {label = _U('owner_unknown')})
			else
				table.insert(elements, {label = _U('owner', retrivedInfo.owner)})
			end

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_infos', {
				title = _U('vehicle_info'),
				align = 'top-left',
				elements = elements
			}, nil, function(data2, menu2)
				menu2.close()
			end)
		end, data.value)
	end
end

function ShowPlayerLicense(player)
	local elements = {}

	ESX.TriggerServerCallback('esx_fbi_job:getOtherPlayerData', function(playerData)
		if playerData.licenses then
			for i=1, #playerData.licenses, 1 do
				if playerData.licenses[i].label and playerData.licenses[i].type then
					table.insert(elements, {
						label = playerData.licenses[i].label,
						type = playerData.licenses[i].type
					})
				end
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_license', {
			title = _U('license_revoke'),
			align = 'top-left',
			elements = elements,
		}, function(data, menu)
			ESX.ShowNotification(_U('licence_you_revoked', data.current.label, playerData.name))
			TriggerServerEvent('esx_fbi_job:message', GetPlayerServerId(player), _U('license_revoked', data.current.label))

			TriggerServerEvent('esx_license:removeLicense', GetPlayerServerId(player), data.current.type)

			ESX.SetTimeout(300, function()
				ShowPlayerLicense(player)
			end)
		end, function(data, menu)
			menu.close()
		end)
	end, GetPlayerServerId(player))
end

function OpenUnpaidBillsMenu(player)
	local elements = {}

	ESX.TriggerServerCallback('esx_billing:getTargetBills', function(bills)
		for k,bill in ipairs(bills) do
			table.insert(elements, {
				label = ('%s - <span style="color:red;">%s</span>'):format(bill.label, _U('armory_item', ESX.Math.GroupDigits(bill.amount))),
				billId = bill.id
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'billing', {
			title = _U('unpaid_bills'),
			align = 'top-left',
			elements = elements
		}, nil, function(data, menu)
			menu.close()
		end)
	end, GetPlayerServerId(player))
end


function OpenGetStocksMenu()
	ESX.TriggerServerCallback('esx_fbi_job:getStockItems', function(items)
		local elements = {}

		for i=1, #items, 1 do
			table.insert(elements, {
				label = 'x' .. items[i].count .. ' ' .. items[i].label,
				value = items[i].name
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			title = _U('fbi_stock'),
			align = 'top-left',
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
				title = _U('quantity')
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if not count then
					ESX.ShowNotification(_U('quantity_invalid'))
				else
					menu2.close()
					menu.close()
					TriggerServerEvent('esx_fbi_job:getStockItem', itemName, count)

					Citizen.Wait(300)
					OpenGetStocksMenu()
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

function OpenPutStocksMenu()
	ESX.TriggerServerCallback('esx_fbi_job:getPlayerInventory', function(inventory)
		local elements = {}

		for i=1, #inventory.items, 1 do
			local item = inventory.items[i]

			if item.count > 0 then
				table.insert(elements, {
					label = item.label .. ' x' .. item.count,
					type = 'item_standard',
					value = item.name
				})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			title = _U('inventory'),
			align = 'top-left',
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count', {
				title = _U('quantity')
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if not count then
					ESX.ShowNotification(_U('quantity_invalid'))
				else
					menu2.close()
					menu.close()
					TriggerServerEvent('esx_fbi_job:putStockItems', itemName, count)

					Citizen.Wait(300)
					OpenPutStocksMenu()
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

function OpenVehiclesMenu()
local vehiculemenu = {
	Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {255, 255, 255}, Title = "Garage" },
	Data = { currentMenu = "Garage FBI"},
	Events = {
		onSelected = function(self, _, btn, PMenu, menuData, currentButton, currentBtn, currentSlt, result)
			local interval = 200

			if btn.name == "Buffalo Banalisé FBI" then
				spawnCar('fbi')
				Citizen.Wait(interval)
				CloseMenu(force)
			elseif btn.name == "Declasse Banalisé FBI" then
				spawnCar('fbi2')
				Citizen.Wait(interval)
				CloseMenu(force)	
			end    
		end,
	},

	Menu = {
		["Garage FBI"] = {
			b = {
				{name = "Buffalo Banalisé FBI", ask = "→→", askX = true, Description = "~g~Sortir ~c~un véhicule de fonction."},
				{name = "Declasse Banalisé FBI", ask = "→→", askX = true, Description = "~g~Sortir ~c~un véhicule de fonction."},
			}
		}
	}
}

CreateMenu(vehiculemenu)
end

function OpenBossMenu()
	local bossenu = {
		Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {255, 255, 255}, Title = "Bureau Directeur" },
		Data = { currentMenu = "Bureau FBI"},
		Events = {
			onSelected = function(self, _, btn, PMenu, menuData, currentButton, currentBtn, currentSlt, result)
				local interval = 200
	
				if btn.name == "Gestion FBI" then
					CloseMenu(force)
					TriggerEvent('esx_society:openBossMenu', 'fbi', function(data, menu)menu.close()end)
				end    
			end,
		},
	
		Menu = {
			["Bureau FBI"] = {
				b = {
					{name = "Gestion FBI", ask = "→→", askX = true, Description = "~g~Gérer ~c~la societé."},
				}
			}
		}
	}
	
	CreateMenu(bossenu)
	end


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if isInShopMenu then
			DisableControlAction(0, 75, true)  -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle
		else
			Citizen.Wait(500)
		end
	end
end)

function OpenElevator(station)
local elevatormenu = {
	Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {255, 255, 255}, Title = "Ascenseur" },
	Data = { currentMenu = "Étages FBI"},
	Events = {
		onSelected = function(self, _, btn, PMenu, menuData, currentButton, currentBtn, currentSlt, result)
			local interval = 50
			local elements = {}
			local playerPed = PlayerPedId()
			local coordsBureaux = vector3(136.09, -761.8, 241.1)
			local coordsPark = vector3(65.4, -749.6, 30.6)
			local coordsRdc = vector3(136.09, -761.5, 44.7)

			if btn.name == "Bureaux" then
				TpAscenceurs(coordsBureaux)
				Citizen.Wait(interval)
				CloseMenu(force)
			elseif btn.name == "Dehors" then 
				TpAscenceurs(coordsPark)
				Citizen.Wait(interval)
				CloseMenu(force)
			elseif btn.name == "Rez de Chaussée" then 
				TpAscenceurs(coordsRdc)
				Citizen.Wait(interval)
				CloseMenu(force)
			end    
		end,
	},

	Menu = {
		["Étages FBI"] = {
			b = {
				{name = "Bureaux", ask = "→→", askX = true, Description = "~g~Aller ~c~dans les bureaux."},
				{name = "Dehors", ask = "→→", askX = true, Description = "~g~Aller ~c~dehors. (Parking)"},
				{name = "Rez de Chaussée", ask = "→→", askX = true, Description = "~g~Aller ~c~à l'accueil."},
			}
		}
	}
}

CreateMenu(elevatormenu)
end

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job

	Citizen.Wait(5000)
	TriggerServerEvent('esx_fbi_job:forceBlip')
end)

RegisterNetEvent('esx_phone:loaded')
AddEventHandler('esx_phone:loaded', function(phoneNumber, contacts)
	local specialContact = {
		name = _U('phone_fbi'),
		number = 'fbi',
		base64Icon = 'base64' -- replace base64 link if you use esx_phone. If you use gcphone ignore this.
	}

	TriggerEvent('esx_phone:addSpecialContact', specialContact.name, specialContact.number, specialContact.base64Icon)
end)

-- don't show dispatches if the player isn't in service
AddEventHandler('esx_phone:cancelMessage', function(dispatchNumber)
	if ESX.PlayerData.job and ESX.PlayerData.job.name == 'fbi' and ESX.PlayerData.job.name == dispatchNumber then
		if Config.EnableESXService and not playerInService then
			CancelEvent()
		end
	end
end)

AddEventHandler('esx_fbi_job:hasEnteredMarker', function(station, part, partNum)
	local playerPed = PlayerPedId()
	if part == 'Cloakroom' then
		CurrentAction = 'menu_cloakroom'
		CurrentActionMsg = _U('open_cloackroom')
		CurrentActionData = {}
	elseif part == 'Ordinateur' then
		CurrentAction = 'menu_ordinateur'
		CurrentActionMsg = _U('open_ordinateur')
		CurrentActionData = {}
	elseif part == 'Armory' then
		CurrentAction = 'menu_armory'
		CurrentActionMsg = _U('open_armory')
		CurrentActionData = {station = station}
	elseif part == 'Vehicles' then
		CurrentAction     = 'menu_vehicle_spawner'
		CurrentActionMsg  = _U('garage_prompt')
		CurrentActionData = {station = station, part = part, partNum = partNum}
	elseif part == 'Deleter' then
		if IsPedInAnyVehicle(playerPed, true) then
			CurrentAction     = 'menu_vehicle_deleter'
			CurrentActionMsg  = _U('range_vehicule')
			CurrentActionData = {}
		end
	elseif part == 'Helicopters' then
		CurrentAction     = 'menu_helicopter_spawner'
		CurrentActionMsg  = _U('helicopter_prompt')
		CurrentActionData = {station = station, part = part, partNum = partNum}
	elseif part == 'BossActions' then
		CurrentAction = 'menu_boss_actions'
		CurrentActionMsg = _U('open_bossmenu')
		CurrentActionData = {}
	elseif part == 'Elevator' then
		CurrentAction = 'menu_elevator'
		CurrentActionMsg = _U('open_elevator')
		CurrentActionData = {station = station}
	elseif part == 'Accueil' then
		CurrentAction = 'menu_accueil'
		CurrentActionMsg = _U('menu_accueil')
		CurrentActionData = {}
	end
end)

AddEventHandler('esx_fbi_job:hasExitedMarker', function(station, part, partNum)
	if not isInShopMenu then
		ESX.UI.Menu.CloseAll()
		CloseMenu(force)
	end

	CurrentAction = nil
end)

AddEventHandler('esx_fbi_job:hasEnteredEntityZone', function(entity)
	local playerPed = PlayerPedId()

	if ESX.PlayerData.job and ESX.PlayerData.job.name == 'fbi' and IsPedOnFoot(playerPed) then
		CurrentAction = 'remove_entity'
		CurrentActionMsg = _U('remove_prop')
		CurrentActionData = {entity = entity}
	end

	if GetEntityModel(entity) == GetHashKey('p_ld_stinger_s') then
		local playerPed = PlayerPedId()

		if IsPedInAnyVehicle(playerPed, false) then
			local vehicle = GetVehiclePedIsIn(playerPed)

			for i=0, 7, 1 do
				SetVehicleTyreBurst(vehicle, i, true, 1000)
			end
		end
	end
end)

AddEventHandler('esx_fbi_job:hasExitedEntityZone', function(entity)
	if CurrentAction == 'remove_entity' then
		CurrentAction = nil
	end
end)

RegisterNetEvent('esx_fbi_job:handcuff')
AddEventHandler('esx_fbi_job:handcuff', function()
	isHandcuffed = not isHandcuffed
	local playerPed = PlayerPedId()

	if isHandcuffed then
		RequestAnimDict('mp_arresting')
		while not HasAnimDictLoaded('mp_arresting') do
			Citizen.Wait(100)
		end

		TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)

		SetEnableHandcuffs(playerPed, true)
		DisablePlayerFiring(playerPed, true)
		SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true) -- unarm player
		SetPedCanPlayGestureAnims(playerPed, false)
		FreezeEntityPosition(playerPed, true)
		DisplayRadar(false)

		if Config.EnableHandcuffTimer then
			if handcuffTimer.active then
				ESX.ClearTimeout(handcuffTimer.task)
			end

			StartHandcuffTimer()
		end
	else
		if Config.EnableHandcuffTimer and handcuffTimer.active then
			ESX.ClearTimeout(handcuffTimer.task)
		end

		ClearPedSecondaryTask(playerPed)
		SetEnableHandcuffs(playerPed, false)
		DisablePlayerFiring(playerPed, false)
		SetPedCanPlayGestureAnims(playerPed, true)
		FreezeEntityPosition(playerPed, false)
		DisplayRadar(true)
	end
end)

RegisterNetEvent('esx_fbi_job:unrestrain')
AddEventHandler('esx_fbi_job:unrestrain', function()
	if isHandcuffed then
		local playerPed = PlayerPedId()
		isHandcuffed = false

		ClearPedSecondaryTask(playerPed)
		SetEnableHandcuffs(playerPed, false)
		DisablePlayerFiring(playerPed, false)
		SetPedCanPlayGestureAnims(playerPed, true)
		FreezeEntityPosition(playerPed, false)
		DisplayRadar(true)

		-- end timer
		if Config.EnableHandcuffTimer and handcuffTimer.active then
			ESX.ClearTimeout(handcuffTimer.task)
		end
	end
end)

RegisterNetEvent('esx_fbi_job:drag')
AddEventHandler('esx_fbi_job:drag', function(AgentId)
	if isHandcuffed then
		dragStatus.isDragged = not dragStatus.isDragged
		dragStatus.AgentId = AgentId
	end
end)

Citizen.CreateThread(function()
	local wasDragged

	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()

		if isHandcuffed and dragStatus.isDragged then
			local targetPed = GetPlayerPed(GetPlayerFromServerId(dragStatus.AgentId))

			if DoesEntityExist(targetPed) and IsPedOnFoot(targetPed) and not IsPedDeadOrDying(targetPed, true) then
				if not wasDragged then
					AttachEntityToEntity(playerPed, targetPed, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
					wasDragged = true
				else
					Citizen.Wait(1000)
				end
			else
				wasDragged = false
				dragStatus.isDragged = false
				DetachEntity(playerPed, true, false)
			end
		elseif wasDragged then
			wasDragged = false
			DetachEntity(playerPed, true, false)
		else
			Citizen.Wait(500)
		end
	end
end)

RegisterNetEvent('esx_fbi_job:putInVehicle')
AddEventHandler('esx_fbi_job:putInVehicle', function()
	if isHandcuffed then
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)

		if IsAnyVehicleNearPoint(coords, 5.0) then
			local vehicle = GetClosestVehicle(coords, 5.0, 0, 71)

			if DoesEntityExist(vehicle) then
				local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)

				for i=maxSeats - 1, 0, -1 do
					if IsVehicleSeatFree(vehicle, i) then
						freeSeat = i
						break
					end
				end

				if freeSeat then
					TaskWarpPedIntoVehicle(playerPed, vehicle, freeSeat)
					dragStatus.isDragged = false
				end
			end
		end
	end
end)

RegisterNetEvent('esx_fbi_job:OutVehicle')
AddEventHandler('esx_fbi_job:OutVehicle', function()
	local playerPed = PlayerPedId()

	if IsPedSittingInAnyVehicle(playerPed) then
		local vehicle = GetVehiclePedIsIn(playerPed, false)
		TaskLeaveVehicle(playerPed, vehicle, 64)
	end
end)

-- Handcuff
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()

		if isHandcuffed then
			DisableControlAction(0, 1, true) -- Disable pan
			DisableControlAction(0, 2, true) -- Disable tilt
			DisableControlAction(0, 24, true) -- Attack
			DisableControlAction(0, 257, true) -- Attack 2
			DisableControlAction(0, 25, true) -- Aim
			DisableControlAction(0, 263, true) -- Melee Attack 1
			DisableControlAction(0, 32, true) -- W
			DisableControlAction(0, 34, true) -- A
			DisableControlAction(0, 31, true) -- S
			DisableControlAction(0, 30, true) -- D

			DisableControlAction(0, 45, true) -- Reload
			DisableControlAction(0, 22, true) -- Jump
			DisableControlAction(0, 44, true) -- Cover
			DisableControlAction(0, 37, true) -- Select Weapon
			DisableControlAction(0, 23, true) -- Also 'enter'?

			DisableControlAction(0, 288,  true) -- Disable phone
			DisableControlAction(0, 289, true) -- Inventory
			DisableControlAction(0, 170, true) -- Animations
			DisableControlAction(0, 167, true) -- Job

			DisableControlAction(0, 0, true) -- Disable changing view
			DisableControlAction(0, 26, true) -- Disable looking behind
			DisableControlAction(0, 73, true) -- Disable clearing animation
			DisableControlAction(2, 199, true) -- Disable pause screen

			DisableControlAction(0, 59, true) -- Disable steering in vehicle
			DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
			DisableControlAction(0, 72, true) -- Disable reversing in vehicle

			DisableControlAction(2, 36, true) -- Disable going stealth

			DisableControlAction(0, 47, true)  -- Disable weapon
			DisableControlAction(0, 264, true) -- Disable melee
			DisableControlAction(0, 257, true) -- Disable melee
			DisableControlAction(0, 140, true) -- Disable melee
			DisableControlAction(0, 141, true) -- Disable melee
			DisableControlAction(0, 142, true) -- Disable melee
			DisableControlAction(0, 143, true) -- Disable melee
			DisableControlAction(0, 75, true)  -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle

			if IsEntityPlayingAnim(playerPed, 'mp_arresting', 'idle', 3) ~= 1 then
				ESX.Streaming.RequestAnimDict('mp_arresting', function()
					TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
				end)
			end
		else
			Citizen.Wait(500)
		end
	end
end)

-- Create blips
Citizen.CreateThread(function()
	for k,v in pairs(Config.FBIStations) do
		local blip = AddBlipForCoord(v.Blip.Coords)

		SetBlipSprite(blip, v.Blip.Sprite)
		SetBlipDisplay(blip, v.Blip.Display)
		SetBlipScale(blip, v.Blip.Scale)
		SetBlipColour(blip, v.Blip.Colour)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName(_U('map_blip'))
		EndTextCommandSetBlipName(blip)
	end
end)

-- Draw markers and more
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if ESX.PlayerData.job and ESX.PlayerData.job.name == 'fbi' then
			local playerPed = PlayerPedId()
			local playerCoords = GetEntityCoords(playerPed)
			local isInMarker, hasExited, letSleep = false, false, true
			local currentStation, currentPart, currentPartNum

			for k,v in pairs(Config.FBIStations) do
				for i=1, #v.Cloakrooms, 1 do
					local distance = #(playerCoords - v.Cloakrooms[i])

					if distance < Config.DrawDistance then
						DrawMarker(Config.MarkerType.Cloakrooms, v.Cloakrooms[i], 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.9, 0.9, 1.4, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						letSleep = false

						if distance < Config.MarkerSize.x then
							isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Cloakroom', i
						end
					end
				end

				for i=1, #v.Ordinateur, 1 do
					local distance = #(playerCoords - v.Ordinateur[i])

					if distance < Config.DrawDistance then
						DrawMarker(Config.MarkerType.Ordinateur, v.Ordinateur[i], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 1.3, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						letSleep = false

						if distance < Config.MarkerSize.x then
							isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Ordinateur', i
						end
					end
				end
				
				for i=1, #v.Deleter, 1 do
					local distance = #(playerCoords - v.Deleter[i])

					if distance < Config.DrawDistance then
						DrawMarker(Config.MarkerType.Deleter, v.Deleter[i], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.1, 3.1, 0.8, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						letSleep = false

						if distance < Config.MarkerSize.x then
							isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Deleter', i
						end
					end
				end
			
				for i=1, #v.Accueil, 1 do
					local distance = #(playerCoords - v.Accueil[i])

					if distance < Config.DrawDistance then
						DrawMarker(Config.MarkerType.Accueil, v.Accueil[i], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						letSleep = false

						if distance < Config.MarkerSize.x then
							isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Accueil', i
						end
					end
				end

				for i=1, #v.ElevatorBas, 1 do
					local distance = #(playerCoords - v.ElevatorBas[i].coords)

					if distance < Config.DrawDistance then
						DrawMarker(Config.MarkerType.ElevatorBas, v.ElevatorBas[i].coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						letSleep = false

						if distance < Config.MarkerSize.x then
							isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Elevator', i
						end
					end
				end

				for i=1, #v.ElevatorDown, 1 do
					local distance = #(playerCoords - v.ElevatorDown[i].coords)

					if distance < Config.DrawDistance then
						DrawMarker(Config.MarkerType.ElevatorDown, v.ElevatorDown[i].coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						letSleep = false

						if distance < Config.MarkerSize.x then
							isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Elevator', i
						end
					end
				end

				for i=1, #v.Armories, 1 do
					local distance = #(playerCoords - v.Armories[i])

					if distance < Config.DrawDistance then
						DrawMarker(Config.MarkerType.Armories, v.Armories[i], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.9, 0.9, 1.5, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						letSleep = false

						if distance < Config.MarkerSize.x then
							isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Armory', i
						end
					end
				end

				for i=1, #v.Vehicles, 1 do
					local distance = #(playerCoords - v.Vehicles[i].Spawner)

					if distance < Config.DrawDistance then
						DrawMarker(Config.MarkerType.Vehicles, v.Vehicles[i].Spawner, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						letSleep = false

						if distance < Config.MarkerSize.x then
							isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Vehicles', i
						end
					end
				end

				for i=1, #v.Helicopters, 1 do
					local distance = #(playerCoords - v.Helicopters[i].Spawner)

					if distance < Config.DrawDistance then
						DrawMarker(Config.MarkerType.Helicopters, v.Helicopters[i].Spawner, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						letSleep = false

						if distance < Config.MarkerSize.x then
							isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Helicopters', i
						end
					end
				end

				if Config.EnablePlayerManagement and ESX.PlayerData.job.grade_name == 'boss' then
					for i=1, #v.BossActions, 1 do
						local distance = #(playerCoords - v.BossActions[i])

						if distance < Config.DrawDistance then
							DrawMarker(Config.MarkerType.BossActions, v.BossActions[i], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.9, 0.9, 1.5, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
							letSleep = false

							if distance < Config.MarkerSize.x then
								isInMarker, currentStation, currentPart, currentPartNum = true, k, 'BossActions', i
							end
						end
					end
				end

				for i=1, #v.ElevatorTop, 1 do
					local distance = #(playerCoords - v.ElevatorTop[i].coords)

					if distance < Config.DrawDistance then
						DrawMarker(Config.MarkerType.ElevatorTop, v.ElevatorTop[i].coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						letSleep = false

						if distance < Config.MarkerSize.x then
							isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Elevator', i
						end
					end
				end
			end

			if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum)) then
				if
					(LastStation and LastPart and LastPartNum) and
					(LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum)
				then
					TriggerEvent('esx_fbi_job:hasExitedMarker', LastStation, LastPart, LastPartNum)
					hasExited = true
				end

				HasAlreadyEnteredMarker = true
				LastStation, LastPart, LastPartNum = currentStation, currentPart, currentPartNum

				TriggerEvent('esx_fbi_job:hasEnteredMarker', currentStation, currentPart, currentPartNum)
			end

			if not hasExited and not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('esx_fbi_job:hasExitedMarker', LastStation, LastPart, LastPartNum)
			end

			if letSleep then
				Citizen.Wait(500)
			end
		else
			Citizen.Wait(500)
		end
	end
end)

-- Enter / Exit entity zone events
Citizen.CreateThread(function()
	local trackedEntities = {
		'prop_roadcone02a',
		'prop_barrier_work05',
		'p_ld_stinger_s',
		'prop_boxpile_07d'
	}

	while true do
		Citizen.Wait(500)

		local playerPed = PlayerPedId()
		local playerCoords = GetEntityCoords(playerPed)

		local closestDistance = -1
		local closestEntity = nil

		for i=1, #trackedEntities, 1 do
			local object = GetClosestObjectOfType(playerCoords, 3.0, GetHashKey(trackedEntities[i]), false, false, false)

			if DoesEntityExist(object) then
				local objCoords = GetEntityCoords(object)
				local distance = #(playerCoords - objCoords)

				if closestDistance == -1 or closestDistance > distance then
					closestDistance = distance
					closestEntity = object
				end
			end
		end

		if closestDistance ~= -1 and closestDistance <= 3.0 then
			if LastEntity ~= closestEntity then
				TriggerEvent('esx_fbi_job:hasEnteredEntityZone', closestEntity)
				LastEntity = closestEntity
			end
		else
			if LastEntity then
				TriggerEvent('esx_fbi_job:hasExitedEntityZone', LastEntity)
				LastEntity = nil
			end
		end
	end
end)

function OpenOrdinateurMenu()
local ordinateurmenu = {
	Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {255, 255, 255}, Title = "Ordinateur" },
	Data = { currentMenu = "Ordinateur FBI"},
	Events = {
		onSelected = function(self, _, btn, PMenu, menuData, currentButton, currentBtn, currentSlt, result)
			local interval = 200
			local playerPed = GetPlayerPed(-1)
			
			if btn.name == "Notez des informations" then
				OpenMenu("Informations à transmettre")
			elseif btn.name == "~r~Fermer" then
				DoScreenFadeOut(800)
				Wait(800)
				ClearPedTasksImmediately(playerPed)
				destroyCameraCreator(1)
				DoScreenFadeIn(800)
				CloseMenu(force)
				------------------
			elseif btn.name == "Envoyer information(s) :" then
				KeyboardInput("Ecrire et envoyer informations :", "", 70)
				while (UpdateOnscreenKeyboard() == 0) do
					DisableAllControlActions(0);
				Citizen.Wait(interval)
				end

				if (GetOnscreenKeyboardResult()) then
					local infos = GetOnscreenKeyboardResult()
					TriggerServerEvent("esx_fbi_job:infosend", infos)
				end
				Citizen.Wait(200)
				CloseMenu(force)
				DoScreenFadeOut(600)
				Wait(600)
				ClearPedTasksImmediately(playerPed)
				destroyCameraCreator(1)
				DoScreenFadeIn(600)
				Citizen.Wait(800)
				Advancednotif("Secrétaire", "~b~FBI", "Vos informations ont bien été traiter et envoyer sur la base de données nommée 'discord'.", "CHAR_FBI", 1)
			end    
		end,
		onExited = function(self, _, btn, PMenu, menuData, currentButton, currentBtn, currentSlt, result, slide, onSlide) 
			local playerPed = GetPlayerPed(-1)
			DoScreenFadeOut(800)
			Wait(800)
			ClearPedTasksImmediately(playerPed)
			destroyCameraCreator(1)
			DoScreenFadeIn(800)
		end,
	},	

	Menu = {
		["Ordinateur FBI"] = {
			b = {
				{name = "Notez des informations", ask = "→→", askX = true, Description = "~g~Noter ~c~des informations sur la base de données du FBI."},
				{name = "~r~Fermer", ask = "", askX = true},
			}
		},
		["Informations à transmettre"] = {
			b = {
				{name = "Envoyer information(s) :", ask = "💻", askX = true, Description = "~g~Noter ~c~les informations que vous souhaitez transmettre dans la bdd du FBI."},

			}
		}
	}
}

CreateMenu(ordinateurmenu)
end

-- Key Controls
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(0)

		if CurrentAction then
			local playerPed = GetPlayerPed(-1)
			ESX.ShowHelpNotification(CurrentActionMsg)

			if IsControlJustReleased(0, 38) and ESX.PlayerData.job and ESX.PlayerData.job.name == 'fbi' then
				DisableControlAction(0,202,true)
				local playerPed = PlayerPedId()
				if CurrentAction == 'menu_cloakroom' then
					OpenCloakroomMenu()
				elseif CurrentAction == 'menu_ordinateur' then
					SetEntityCoords(playerPed, vector3(118.39, -764.19, 241.2))
					Citizen.Wait(0)
					SetEntityHeading(playerPed, 137.41)
					Wait(200)
					DoScreenFadeOut(800)
					Wait(2000)
					DoScreenFadeIn(800)
					setCameraCreator(1)
					Wait(500)
					PlayAnim("anim@heists@prison_heiststation@cop_reactions", "cop_b_idle", -1)
					Wait(200)
					OpenOrdinateurMenu()
				elseif CurrentAction == 'menu_armory' then
					if not Config.EnableESXService or playerInService then
						OpenArmoryMenu(CurrentActionData.station)
					else
						ESX.ShowNotification(_U('service_not'))
					end
				elseif CurrentAction == 'menu_vehicle_spawner' then
					OpenVehiclesMenu()
				elseif CurrentAction == 'menu_vehicle_deleter' then
					TriggerEvent('esx:deleteVehicle')
				elseif CurrentAction == 'menu_helicopter_spawner' then
					if not Config.EnableESXService then
						OpenVehicleSpawnerMenu('helicopter', CurrentActionData.station, CurrentActionData.part, CurrentActionData.partNum)
					elseif playerInService then
						OpenVehicleSpawnerMenu('helicopter', CurrentActionData.station, CurrentActionData.part, CurrentActionData.partNum)
					else
						ESX.ShowNotification(_U('service_not'))
					end
				elseif CurrentAction == 'menu_boss_actions' then
					OpenBossMenu()
					--[[TriggerEvent('esx_society:openBossMenu', 'fbi', function(data, menu)
						menu.close()

						CurrentAction = 'menu_boss_actions'
						CurrentActionMsg = _U('open_bossmenu')
						CurrentActionData = {}
					end, {wash = false}) -- disable washing money]]
				elseif CurrentAction == 'menu_accueil' then
					OpenAccueilMenu()
				elseif CurrentAction == 'remove_entity' then
					DeleteEntity(CurrentActionData.entity)
				elseif CurrentAction == 'menu_elevator' then
					OpenElevator(CurrentActionData.station)
				end

				CurrentAction = nil
			end
		end

		if IsControlJustReleased(0, 167) and not isDead and ESX.PlayerData.job and ESX.PlayerData.job.name == 'fbi' and not ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'fbi_actions') then
			if not Config.EnableESXService or playerInService then
				OpenFBIActionsMenu()
			else
				ESX.ShowNotification(_U('service_not'))
			end
		end

		if IsControlJustReleased(0, 38) and currentTask.busy then
			ESX.ShowNotification(_U('impound_canceled'))
			ESX.ClearTimeout(currentTask.task)
			ClearPedTasks(PlayerPedId())
			
			currentTask.busy = false
		end
	end
end)

-- Create blip for colleagues
function createBlip(id)
	local ped = GetPlayerPed(id)
	local blip = GetBlipFromEntity(ped)

	if not DoesBlipExist(blip) then -- Add blip and create head display on player
		blip = AddBlipForEntity(ped)
		SetBlipSprite(blip, 1)
		ShowHeadingIndicatorOnBlip(blip, true) -- Player Blip indicator
		SetBlipRotation(blip, math.ceil(GetEntityHeading(ped))) -- update rotation
		SetBlipNameToPlayerName(blip, id) -- update blip name
		SetBlipScale(blip, 0.85) -- set scale
		SetBlipAsShortRange(blip, true)

		table.insert(blipsCops, blip) -- add blip to array so we can remove it later
	end
end

RegisterNetEvent('esx_fbi_job:updateBlip')
AddEventHandler('esx_fbi_job:updateBlip', function()
	-- Refresh all blips
	for k, existingBlip in pairs(blipsCops) do
		RemoveBlip(existingBlip)
	end

	-- Clean the blip table
	blipsCops = {}

	-- Enable blip?
	if Config.EnableESXService and not playerInService then
		return
	end

	if not Config.EnableJobBlip then
		return
	end

	-- Is the player a cop? In that case show all the blips for other cops
	if ESX.PlayerData.job and ESX.PlayerData.job.name == 'fbi' then
		ESX.TriggerServerCallback('esx_society:getOnlinePlayers', function(players)
			for i=1, #players, 1 do
				if players[i].job.name == 'fbi' then
					local id = GetPlayerFromServerId(players[i].source)
					if NetworkIsPlayerActive(id) and GetPlayerPed(id) ~= PlayerPedId() then
						createBlip(id)
					end
				end
			end
		end)
	end
end)


-- Fin
AddEventHandler('playerSpawned', function(spawn)
	isDead = false
	TriggerEvent('esx_fbi_job:unrestrain')

	if not hasAlreadyJoined then
		TriggerServerEvent('esx_fbi_job:spawned')
	end
	hasAlreadyJoined = true
end)

AddEventHandler('esx:onPlayerDeath', function(data)
	isDead = true
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		TriggerEvent('esx_fbi_job:unrestrain')
		TriggerEvent('esx_phone:removeSpecialContact', 'fbi')

		if Config.EnableESXService then
			TriggerServerEvent('esx_service:disableService', 'fbi')
		end

		if Config.EnableHandcuffTimer and handcuffTimer.active then
			ESX.ClearTimeout(handcuffTimer.task)
		end
	end
end)