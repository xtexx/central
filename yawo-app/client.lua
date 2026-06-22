local p = {
    reconnAttempts = 0,
    buf = ''
}

function p.init()
    print('client: init\n')
    p.serverHost = netconf.eusParams['server']
    p.serverPort = tonumber(netconf.eusParams['server_port'])
    print('client: server endpoint: ' .. p.serverHost .. ' port: ' .. p.serverPort .. '\n')
    p.connect()
end

function p.disconnect()
    p.conn.close()
end

function p.connect()
    pcall(p.disconnect)

    print('client: reconnect attempt ' .. p.reconnAttempts .. '\n')
    if p.reconnAttempts >= 2 then
        print('client: Too many reconnection attempts, reset switch\n')
        switch.set(false)
    end
    if p.reconnAttempts >= 100 then
        print("client: Will reboot after T-minus 900 seconds\n")
        tmr.delay(900000000)
        node.restart()
    end

    print('client: prepareing to connect\n')
    p.conn = net.createConnection()
    p.conn:on("receive", function(sck, c)
        print('client: recv: ' .. c .. '\n')
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
        print('client: disconnect, reason: ' .. c .. '\n')
        if not tmr.create():alarm(500, tmr.ALARM_SINGLE, function()
            print("client: reonnecting\n")
            p.reconnAttempts = p.reconnAttempts + 1
            p.connect()
        end) then
            print("client: failed to enqueue for reconnection, reset\n")
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
        print('client: handshake sent\n')
    end)
    p.conn:connect(p.serverPort, p.serverHost)
    print('client: connecting\n')
end

function p.processMessage(line)
    local ok, msg = pcall(sjson.decode, line)
    if not ok then
        print("client: cannot parse json\n")
        sck.close()
    end
    if msg['version'] ~= nil then
        local version = msg['version']
        print("client: remote version: " .. tostring(version) .. "\n")
        if version ~= 1 then
            print("client: unsupported remote version\n")
            sck.close()
            return
        end
        p.reconnAttempts = 0
    elseif msg['update'] ~= nil then
        local newState = msg['update']
        print("client: remote state update: " .. tostring(newState) .. "\n")
        switch.set(newState == true)
    else
        print("client: invalid protocol message\n")
        sck.close()
    end
end

return p
