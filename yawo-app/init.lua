print("YAWO Init\n")
netconf = dofile('netconf.lua')
switch = dofile('switch.lua')
client = dofile('client.lua')

function initAfterNetSetup()
    switch.init()
    client.init()
end

print('init: files: ' .. sjson.encode(file.list()) .. '\n')

print('init: loaded modules\n')
netconf.init()
print('init: init completed\n')
