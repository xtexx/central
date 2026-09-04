local p = {
    state = false
}

function p.init()
    log('switch: init\n')
    p.gpioIdx = tonumber(netconf.eusParams['gpio_idx'])
    log('switch: selected GPIO index ' .. p.gpioIdx .. '\n')
    gpio.mode(p.gpioIdx, gpio.OUTPUT, gpio.PULLUP)
    log('switch: configured GPIO OUTPUT PULLUP mode\n')
    gpio.write(p.gpioIdx, gpio.LOW)
    log('switch: reset to LOW\n')
end
                     
function p.set(state)
    log('switch: set to ' .. tostring(state) .. '\n')
    p.state = state;
    if state then
        gpio.write(p.gpioIdx, gpio.HIGH)
    else
        gpio.write(p.gpioIdx, gpio.LOW)
    end
end

return p
