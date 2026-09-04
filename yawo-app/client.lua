local p = {
    reconnAttempts = 0,
    buf = ''
}

function p.init()
    log('client: init\n')
    p.serverHost = netconf.eusParams['server']
    p.serverPort = tonumber(netconf.eusParams['server_port'])
    log('client: server endpoint: ' .. p.serverHost .. ' port: ' .. p.serverPort .. '\n')
    p.connect()
end

function p.disconnect()
    p.conn.close()
end

function p.connect()
    pcall(p.disconnect)

    log('client: reconnect attempt ' .. p.reconnAttempts .. '\n')
    if p.reconnAttempts >= 2 then
        log('client: Too many reconnection attempts, reset switch\n')
        switch.set(false)
    end
    if p.reconnAttempts >= 100 then
        log("client: Will reboot after T-minus 120 seconds\n")
        tmr.delay(120000000)
        node.restart()
    end

    log('client: prepareing to connect\n')
    p.conn = net.createConnection()
    p.conn:on("receive", function(sck, c)
        log('client: recv: ' .. c .. '\n')
        p.buf = p.buf .. c
        while true do
            local pos = string.find(p.buf, '\n', 1, true)
            if pos then
                local line = string.sub(p.buf, 1, pos - 1)
                p.processMessage(line)
                p.buf = string.sub(p.buf, pos + 1)
            else
                break
            end
        end
    end)
    p.conn:on("disconnection", function(sck, c)
        log('client: disconnect, reason: ' .. c .. '\n')
        if not tmr.create():alarm(500, tmr.ALARM_SINGLE, function()
            log("client: reonnecting\n")
            p.reconnAttempts = p.reconnAttempts + 1
            p.connect()
        end) then
            log("client: failed to enqueue for reconnection, reset\n")
            node.restart()
        end
    end)
    p.conn:on("connection", function(sck, c)
        p.buf = ''
        local req = {
            sig = 'YetAnotherWiFiOutlet',
            version = 1,
            controller = 'NodeMCU',
            sw_version = node.info('sw_version'),
            build_config = node.info('build_config')
        }
        sck:send(sjson.encode(req))
        log('client: handshake sent\n')
    end)
    p.conn:connect(p.serverPort, p.serverHost)
    log('client: connecting\n')
end

function p.processMessage(line)
    local ok, msg = pcall(sjson.decode, line)
    if not ok then
        log("client: cannot parse json\n")
        sck.close()
    end
    if msg['version'] ~= nil then
        local version = msg['version']
        log("client: remote version: " .. tostring(version) .. "\n")
        if version ~= 1 then
            log("client: unsupported remote version\n")
            sck.close()
            return
        end
        p.reconnAttempts = 0
    elseif msg['update'] ~= nil then
        local newState = msg['update']
        log("client: remote state update: " .. tostring(newState) .. "\n")
        switch.set(newState == true)
    else
        log("client: invalid protocol message\n")
        sck.close()
    end
end

return p
