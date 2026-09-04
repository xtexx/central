local p = {}
wifiReconnectCounter = 0

-- Register WiFi event callbacks
wifi.eventmon.register(wifi.eventmon.WIFI_MODE_CHANGED, function(T)
    log("netconf: WiFi mode has been changed from " .. T.old_mode .. " to " .. T.new_mode .. "\n")
    if T.new_mode == wifi.SOFTAP or T.new_mode == wifi.STATIONAP then
        local cfg = wifi.ap.getconfig(true);
        log("netconf: AP: SSID: " .. cfg["ssid"] .. ", password: " .. tostring(cfg["pwd"]) .. "\n")
    end
end)

wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T)
    log("netconf: station: Connected to AP '" .. T.SSID .. "' (" .. T.BSSID .. ") on channel " .. T.channel .. "\n")
    log("netconf: station: Waiting for IP address\n")
end)

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
    log("netconf: station: IP address obtained: " .. T.IP .. "\n")
    log("netconf: station: netmask: " .. T.netmask .. ", gateway: " .. T.gateway .. "\n")

    log("netconf: station: Reset WiFi reconnect counter due to successfully obtaining an IP\n")
    wifiReconnectCounter = 0

    if p['eusParams'] ~= nil then
        log("netconf: station: Will start after T-minus 5 seconds\n")
        tmr.delay(5000000)
        initAfterNetSetup()
    end
end)

wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T)
    log("netconf: station: Connection to AP " .. T.SSID .. " lost, retrying to connect\n")

    for key, val in pairs(wifi.eventmon.reason) do
        if val == T.reason then
            log("netconf: station: Disconnect reason: " .. val .. " (" .. key .. ")\n")
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
        log("netconf: station: Reconnecting to AP (attempt " .. wifiReconnectCounter .. "/" .. maxAttempts .. ")\n")
        if T.reason == wifi.eventmon.reason.ASSOC_LEAVE then
            log("netconf: station: Disconnecting from AP\n")
            wifi.sta.disconnect()
            log("netconf: station: Disconnected from AP\n")
            log("netconf: station: Will reboot after T-minus 120 seconds\n")
            if not tmr.create():alarm(120000, tmr.ALARM_SINGLE, function()
                node.restart()
            end) then
                log("netconf: failed to enqueue for restart, reset\n")
                node.restart()
            end
        end
    else
        log("netconf: station: Disconnecting from AP\n")
        wifi.sta.disconnect()
        log("netconf: station: Disconnected from AP\n")
        log("netconf: station: Will reboot after T-minus 120 seconds\n")
        tmr.delay(120000000)
        node.restart()
    end
end)

wifi.eventmon.register(wifi.eventmon.STA_AUTHMODE_CHANGE, function(T)
    log("netconf: station: auth mode has been changed from " .. T.old_auth_mode .. " to " .. T.new_auth_mode .. "\n")
end)

wifi.eventmon.register(wifi.eventmon.AP_STACONNECTED, function(T)
    log("netconf: AP: station connected, MAC: " .. T.MAC .. ", AID: " .. T.AID .. "\n")
end)

wifi.eventmon.register(wifi.eventmon.AP_STADISCONNECTED, function(T)
    log("netconf: AP: station disconnected, MAC: " .. T.MAC .. ", AID: " .. T.AID .. "\n")
end)

wifi.setmode(wifi.NULLMODE, false)
function p.init()
    -- Load EUS params
    if file.open("eus_params.lua") == nil then
        log("netconf: EUS: Parameters does not exist yet, starting EUS\n")
        function eusOnConnected()
            log("netconf: EUS: Connected to WiFi as " .. wifi.sta.getip() .. "\n")
            log("netconf: EUS: Will reboot after T-minus 15 seconds\n")
            tmr.delay(15000000)
            node.restart()
        end
        function eusOnError(err, str)
            log("netconf: EUS: Error #" .. err .. ": " .. str .. "\n")
        end
        enduser_setup.start(eusOnConnected, eusOnError)
        log("netconf: EUS: Started\n")
    else
        p.eusParams = dofile('eus_params.lua')
        log("netconf: EUS: Parameters have been loaded\n")
        local ok, json = pcall(sjson.encode, p.eusParams)
        if ok then
            log("netconf: EUS: Parameters: " .. json .. "\n")
        else
            log("netconf: EUS: Failed to print parameters as JSON\n")
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
