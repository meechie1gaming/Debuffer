--#   ,-.       _,---._ __  / \
--#  /  )    .-'       `./ /   \
--# (  (   ,'            `/    /|
--#  \  `-"             \'\   / |
--#   `.              ,  \ \ /  |
--#    /`.          ,'-`----Y   |
--#   (            ;        |   '
--#   |  ,-.    ,-'         |  /
--#   |  | (   |   Meechie  | /
--#   )  |  \  `.___________|/
--================================================================================
-- Debuffer LUA - v1.8 Date: 2026-10-24
--================================================================================

_addon.name = 'Debuffer'
_addon.author = 'Meechie'
_addon.version = '1.8'

res = require('resources')
res_buffs = res.buffs

-- ==[ Cure Map ]==============================================
local debuff_item_map = {
    ['poison']    = {'Antidote', 'Remedy'},
    ['blindness'] = {'Eye Drops', 'Remedy'},
    ['paralysis'] = {'Remedy'},
    ['silence']   = {'Echo Drops', 'Remedy'},
    ['disease']   = {'Remedy'},
    ['curse']     = {'Holy Water'},
    ['doom']      = {'Holy Water'},
}

local item_valid_for_buff = {
    ['Antidote']   = {'poison'},
    ['Remedy']     = {'poison','blindness','paralysis','silence','disease'},
    ['Eye Drops']  = {'blindness'},
    ['Echo Drops'] = {'silence'},
    ['Holy Water'] = {'curse','doom'},
}

-- ==[ State ]=================================================
local buff_timers = {}

-- ==[ Helpers ]===============================================
local function player_has_buff_name(buff_name)
    buff_name = buff_name:lower()
    local buffs = windower.ffxi.get_player().buffs or {}
    for _, id in ipairs(buffs) do
        local b = res_buffs[id]
        if b and b.english and b.english:lower() == buff_name then
            return true
        end
    end
    return false
end

local function has_item(item)
    local items = windower.ffxi.get_items()
    local function check_container(container)
        for _, entry in pairs(container) do
            if type(entry) == 'table' and entry.id and entry.count > 0 then
                local res_item = res.items[entry.id]
                if res_item and res_item.en:lower() == item:lower() then
                    return true
                end
            end
        end
        return false
    end
    if check_container(items.inventory) then return true end
    if check_container(items.wardrobe) then return true end
    if check_container(items.wardrobe2) then return true end
    if check_container(items.wardrobe3) then return true end
    if check_container(items.wardrobe4) then return true end
    return false
end

local function is_valid_item_for_buff(item, buff_name)
    local valid_buffs = item_valid_for_buff[item]
    if not valid_buffs then return false end
    for _, name in ipairs(valid_buffs) do
        if name == buff_name then return true end
    end
    return false
end

-- ==[ Timers ]================================================
local function stop_buff_timer(buff_id, running)
    local co = buff_timers[buff_id]
    if not co then return end
    buff_timers[buff_id] = nil
    if not running then
        coroutine.close(co)
    end
    local buff = res_buffs[buff_id]
    if buff and buff.english then
        windower.add_to_chat(200, '[Debuffer] Stopped curing '..buff.english)
    end
end

local function try_cure(buff_id)
    local buff = res_buffs[buff_id]
    if not buff or not buff.english then return false end
    local name = buff.english:lower()
    if not player_has_buff_name(name) then
        return false
    end
    if not debuff_item_map[name] then return false end
    for _, item in ipairs(debuff_item_map[name]) do
        if has_item(item) and is_valid_item_for_buff(item, name) then
            windower.chat.input('/item "'..item..'" <me>')
            windower.add_to_chat(123, ('[Debuffer] >>> Using "%s" to cure [%s]!'):format(item, buff.english))
            return true
        end
    end
    windower.add_to_chat(200, '[Debuffer] No cure found for '..buff.english)
    return false
end

local function start_buff_timer(buff_id)
    if buff_timers[buff_id] then return end
    local function repeater()
        local buff = res_buffs[buff_id]
        local name = buff and buff.english and buff.english:lower() or nil
        if name and player_has_buff_name(name) then
            if try_cure(buff_id) then
                buff_timers[buff_id] = coroutine.schedule(repeater, 2.5)
            else
                buff_timers[buff_id] = coroutine.schedule(repeater, 10)
            end
        else
            stop_buff_timer(buff_id, true)
        end
    end
    repeater()
end

local function stop_all_timers()
    for buff_id, _ in pairs(buff_timers) do
        stop_buff_timer(buff_id)
    end
end

-- ==[ Events ]================================================
windower.register_event('gain buff', function(buff_id)
    local buff = res_buffs[buff_id]
    local name = buff and buff.english and buff.english:lower() or nil
    if name and debuff_item_map[name] then
        start_buff_timer(buff_id)
    end
end)

windower.register_event('lose buff', function(buff_id)
    if buff_timers[buff_id] then
        stop_buff_timer(buff_id)
    end
end)

windower.register_event('load', function()
    windower.add_to_chat(8, '[Debuffer] Loaded and active. Will auto-cure tracked debuffs.')
    local buffs = windower.ffxi.get_player().buffs or {}
    for _, buff_id in ipairs(buffs) do
        local buff = res_buffs[buff_id]
        local name = buff and buff.english and buff.english:lower() or nil
        if name and debuff_item_map[name] and not buff_timers[buff_id] then
            start_buff_timer(buff_id)
        end
    end
end)

windower.register_event('unload', function()
    stop_all_timers()
    windower.add_to_chat(8, '[Debuffer] Unloaded and stopped.')
end)
