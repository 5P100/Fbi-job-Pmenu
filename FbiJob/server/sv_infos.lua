ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent('esx_fbi_job:infosend')
AddEventHandler('esx_fbi_job:infosend', function(message)
	local _src = source
	sendToDiscordWithSpecialURL("Los Santos FBI","**Infos envoyé par l'agent du FBI  __'"..GetPlayerName(_src).."'__** :\n\n__Informations transmises :__\n"..message, 1260221, Config.Webhook)
end)

function sendToDiscordWithSpecialURL (name,message,color,url)
    local DiscordWebHook = url
	local embeds = {
		{
			["title"]=message,
			["type"]="rich",
			["color"] =color,
			["footer"]=  {
			["text"]= "Revenge & 5% FBI Job",
			},
		}
	}
    if message == nil or message == '' then return FALSE end
    PerformHttpRequest(DiscordWebHook, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
end