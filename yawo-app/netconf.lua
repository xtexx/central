local p = {}
wifiReconnectCounter = 0

-- Register WiFi event callbacks
wifi.eventmon.register(wifi.eventmon.WIFI_MODE_CHANGED, function(T)
    print("netconf: WiFi mode has been changed from " .. T.old_mode .. " to " .. T.new_mode .. "\n")
    if T.new_mode == wifi.SOFTAP or T.new_mode == wifi.STATIONAP then
        local cfg = wifi.ap.getconfig(true);
        print("netconf: AP: SSID: " .. cfg["ssid"] .. ", password: " .. tostring(cfg["pwd"]) .. "\n")
    end
end)

wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T)
    print("netconf: station: Connected to AP '" .. T.SSID .. "' (" .. T.BSSID .. ") on channel " .. T.channel .. "\n")
    print("netconf: station: Waiting for IP address\n")
end)

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
    print("netconf: station: IP address obtained: " .. T.IP .. "\n")
    print("netconf: station: netmask: " .. T.netmask .. ", gateway: " .. T.gateway .. "\n")

    print("netconf: station: Reset WiFi reconnect counter due to successfully obtaining an IP\n")
    wifiReconnectCounter = 0

    if p['eusParams'] ~= nil then
        print("netconf: station: Will start after T-minus 5 seconds\n")
        tmr.delay(5000000)
        initAfterNetSetup()
    end
end)

wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T)
    if T.reason == wifi.eventmon.reason.ASSOC_LEAVE then
        -- the station has disassociated from a previously connected AP
        return
    end
    print("netconf: station: Connection to AP " .. T.SSID .. " lost, retrying to connect\n")

    for key, val in pairs(wifi.eventmon.reason) do
        if val == T.reason then
            print("netconf: station: Disconnect reason: " .. val .. " (" .. key .. ")\n")
            break
        end
    end

    local maxAttempts = 100
    local maxResetAttempts = 2

    wifiReconnectCounter = wifiReconnectCounter + 1
    if wifiReconnectCounter >= maxResetAttempts then
        switch.set(false)
    end
    if wifiReconnectCounter < maxAttempts then
        print("netconf: station: Reconnecting to AP (attempt " .. wifiReconnectCounter .. "/" .. maxAttempts .. ")\n")
    else
        print("netconf: station: Disconnecting from AP\n")
        wifi.sta.disconnect()
        print("netconf: station: Disconnected from AP\n")
        print("netconf: station: Will reboot after T-minus 900 seconds\n")
        tmr.delay(900000000)
        node.restart()
    end
end)

wifi.eventmon.register(wifi.eventmon.STA_AUTHMODE_CHANGE, function(T)
    print("netconf: station: auth mode has been changed from " .. T.old_auth_mode .. " to " .. T.new_auth_mode .. "\n")
end)

wifi.eventmon.register(wifi.eventmon.AP_STACONNECTED, function(T)
    print("netconf: AP: station connected, MAC: " .. T.MAC .. ", AID: " .. T.AID .. "\n")
end)

wifi.eventmon.register(wifi.eventmon.AP_STADISCONNECTED, function(T)
    print("netconf: AP: station disconnected, MAC: " .. T.MAC .. ", AID: " .. T.AID .. "\n")
end)

wifi.setmode(wifi.NULLMODE, false)
function p.init()
    -- Load EUS params
    if file.open("eus_params.lua") == nil then
        print("netconf: EUS: Parameters does not exist yet, starting EUS\n")
        function eusOnConnected()
            print("netconf: EUS: Connected to WiFi as " .. wifi.sta.getip() .. "\n")
            print("netconf: EUS: Will reboot after T-minus 15 seconds\n")
            tmr.delay(15000000)
            node.restart()
        end
        function eusOnError(err, str)
            print("netconf: EUS: Error #" .. err .. ": " .. str .. "\n")
        end
        enduser_setup.start(eusOnConnected, eusOnError)
        print("netconf: EUS: Started\n")
    else
        p.eusParams = dofile('eus_params.lua')
        print("netconf: EUS: Parameters have been loaded\n")
        local ok, json = pcall(sjson.encode, p.eusParams)
        if ok then
            print("netconf: EUS: Parameters: " .. json .. "\n")
        else
            print("netconf: EUS: Failed to print parameters as JSON\n")
        end
        wifi.setmode(wifi.STATION, false)
        wifi.sta.config({
            ssid = p.eusParams["wifi_ssid"],
            pwd = p.eusParams["wifi_password"],
            auto = true,
            save = false
        })
    end
end
return p
