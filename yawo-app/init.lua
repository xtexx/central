print("YAWO Init\n")

function remoteLog(msg)
    logUdpSocket = net.createUDPSocket()
    logUdpSocket:listen(5000)
    logUdpSocket:send(client.serverPort + 1, client.serverHost, "LOG " .. msg)
    logUdpSocket:close()
end
function log(msg)
    print(msg)
    pcall(remoteLog, msg)
end

netconf = dofile('netconf.lua')
switch = dofile('switch.lua')
client = dofile('client.lua')

function initAfterNetSetup()
    switch.init()
    client.init()
end

log('init: files: ' .. sjson.encode(file.list()) .. '\n')

log('init: loaded modules\n')
netconf.init()
log('init: init completed\n')
