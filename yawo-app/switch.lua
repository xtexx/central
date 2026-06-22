local p = {
    state = false
}

function p.init()
    print('switch: init\n')
    p.gpioIdx = tonumber(netconf.eusParams['gpio_idx'])
    print('switch: selected GPIO index ' .. p.gpioIdx .. '\n')
    gpio.mode(p.gpioIdx, gpio.OUTPUT, gpio.PULLUP)
    print('switch: configured GPIO OUTPUT PULLUP mode\n')
    gpio.write(p.gpioIdx, gpio.LOW)
    print('switch: reset to LOW\n')
end
                     
function p.set(state)
    print('switch: set to ' .. tostring(state) .. '\n')
    p.state = state;
    if state then
        gpio.write(p.gpioIdx, gpio.HIGH)
    else
        gpio.write(p.gpioIdx, gpio.LOW)
    end
end

return p
