local world = require('openmw.world')
local core = require('openmw.core')

local function remove(data)
    data.object:remove()
end

return {
    eventHandlers = {
        remove = remove
    }
}

