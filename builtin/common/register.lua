-- local builtin_shared = ...
--
-- do
-- 	local default = {mod = "??", name = "??"}
-- 	core.callback_origins = setmetatable({}, {
-- 		__index = function()
-- 			return default
-- 		end
-- 	})
-- end
--
-- function core.run_callbacks(callbacks, mode, ...)
-- 	assert(type(callbacks) == "table")
-- 	local cb_len = #callbacks
-- 	if cb_len == 0 then
-- 		if mode == 2 or mode == 3 then
-- 			return true
-- 		elseif mode == 4 or mode == 5 then
-- 			return false
-- 		end
-- 	end
-- 	local ret = nil
-- 	for i = 1, cb_len do
-- 		local origin = core.callback_origins[callbacks[i]]
-- 		core.set_last_run_mod(origin.mod)
-- 		local cb_ret = callbacks[i](...)
--
-- 		if mode == 0 and i == 1 then
-- 			ret = cb_ret
-- 		elseif mode == 1 and i == cb_len then
-- 			ret = cb_ret
-- 		elseif mode == 2 then
-- 			if not cb_ret or i == 1 then
-- 				ret = cb_ret
-- 			end
-- 		elseif mode == 3 then
-- 			if cb_ret then
-- 				return cb_ret
-- 			end
-- 			ret = cb_ret
-- 		elseif mode == 4 then
-- 			if (cb_ret and not ret) or i == 1 then
-- 				ret = cb_ret
-- 			end
-- 		elseif mode == 5 and cb_ret then
-- 			return cb_ret
-- 		end
-- 	end
-- 	return ret
-- end
--
-- function builtin_shared.make_registration()
-- 	local t = {}
-- 	local registerfunc = function(func)
-- 		t[#t + 1] = func
-- 		core.callback_origins[func] = {
-- 			mod = core.get_current_modname() or "??",
-- 			name = debug.getinfo(1, "n").name or "??"
-- 		}
-- 	end
-- 	return t, registerfunc
-- end
--
-- function builtin_shared.make_registration_reverse()
-- 	local t = {}
-- 	local registerfunc = function(func)
-- 		table.insert(t, 1, func)
-- 		core.callback_origins[func] = {
-- 			mod = core.get_current_modname() or "??",
-- 			name = debug.getinfo(1, "n").name or "??"
-- 		}
-- 	end
-- 	return t, registerfunc
-- end





-- local builtin_shared = ...
--
-- do
--     local default = {mod = "??", name = "??"}
--     core.callback_origins = setmetatable({}, {
--         __index = function()
--             return default
--         end
--     })
-- end
--
-- -- Cache for origins to avoid frequent lookups
-- local origin_cache = {}
--
-- function core.set_last_run_mod_from_cache(callback)
--     local origin = origin_cache[callback] or core.callback_origins[callback]
--     if not origin_cache[callback] then
--         origin_cache[callback] = origin
--     end
--     core.set_last_run_mod(origin.mod)
-- end
--
-- -- Specialized function handlers for each mode
-- local function handle_mode_0(callbacks, ...)
--     local ret = nil
--     for i = 1, #callbacks do
--         local cb_ret = callbacks[i](...)
--         if i == 1 then
--             ret = cb_ret
--             break
--         end
--     end
--     return ret
-- end
--
-- local function handle_mode_1(callbacks, ...)
--     return callbacks[#callbacks](...)
-- end
--
-- local function handle_mode_2(callbacks, ...)
--     for i = 1, #callbacks do
--         local cb_ret = callbacks[i](...)
--         if not cb_ret or i == 1 then
--             return cb_ret
--         end
--     end
-- end
--
-- local function handle_mode_3(callbacks, ...)
--     for i = 1, #callbacks do
--         local cb_ret = callbacks[i](...)
--         if cb_ret then
--             return cb_ret
--         end
--     end
-- end
--
-- local function handle_mode_4(callbacks, ...)
--     local ret = nil
--     for i = 1, #callbacks do
--         local cb_ret = callbacks[i](...)
--         if (cb_ret and not ret) or i == 1 then
--             ret = cb_ret
--         end
--     end
--     return ret
-- end
--
-- local function handle_mode_5(callbacks, ...)
--     for i = 1, #callbacks do
--         local cb_ret = callbacks[i](...)
--         if cb_ret then
--             return cb_ret
--         end
--     end
-- end
--
-- function core.run_callbacks(callbacks, mode, ...)
--     assert(type(callbacks) == "table")
--     if #callbacks == 0 then
--         if mode == 2 or mode == 3 then
--             return true
--         elseif mode == 4 or mode == 5 then
--             return false
--         end
--     end
--     -- Dispatch to the appropriate handler based on the mode
--     if mode == 0 then
--         return handle_mode_0(callbacks, ...)
--     elseif mode == 1 then
--         return handle_mode_1(callbacks, ...)
--     elseif mode == 2 then
--         return handle_mode_2(callbacks, ...)
--     elseif mode == 3 then
--         return handle_mode_3(callbacks, ...)
--     elseif mode == 4 then
--         return handle_mode_4(callbacks, ...)
--     elseif mode == 5 then
--         return handle_mode_5(callbacks, ...)
--     end
-- end
--
-- function builtin_shared.make_registration()
--     local t = {}
--     local registerfunc = function(func)
--         t[#t + 1] = func
--         core.callback_origins[func] = {
--             mod = core.get_current_modname() or "??",
--             name = debug.getinfo(1, "n").name or "??"
--         }
--     end
--     return t, registerfunc
-- end
--
-- function builtin_shared.make_registration_reverse()
--     local t = {}
--     local registerfunc = function(func)
--         table.insert(t, 1, func)
--         core.callback_origins[func] = {
--             mod = core.get_current_modname() or "??",
--             name = debug.getinfo(1, "n").name or "??"
--         }
--     end
--     return t, registerfunc
-- end
--
--
--







-- Improved caching mechanism with debug info control based on execution environment
local origin_cache = {}
local function get_origin(callback)
    local callback_id = tostring(callback)
    local origin = origin_cache[callback_id]
    if not origin then
        local debug_info = debug.getinfo(callback, "n")
        origin = {
            mod = core.get_current_modname() or "??",
            name = debug_info and debug_info.name or "??"
        }
        origin_cache[callback_id] = origin
    end
    return origin
end

function core.set_last_run_mod_from_cache(callback)
    local origin = get_origin(callback)
    core.set_last_run_mod(origin.mod)
end

-- Optimized single handler for all modes with reduced complexity
local function handle_callbacks(callbacks, mode, ...)
    local response, condition_met
    for i, callback in ipairs(callbacks) do
        local result = callback(...)
        if mode == 0 and i == 1 then return result end
        if mode == 1 and i == #callbacks then return result end
        if mode == 2 and not result then return result end
        if mode == 3 and result then return result end
        if mode >= 4 and result then return result end
    end
    return mode == 2 or mode == 3 and false or nil
end

function core.run_callbacks(callbacks, mode, ...)
    assert(type(callbacks) == "table", "Invalid input type for callbacks: " .. type(callbacks))
    return handle_callbacks(callbacks, mode, ...)
end

-- Unified registration function handling both direct and reverse insertion
local function make_registration(is_reverse)
    local t = {}
    local function register(func)
        if is_reverse then
            table.insert(t, 1, func) -- insert at beginning for reverse order
        else
            table.insert(t, func) -- append to end for normal order
        end
    end
    return t, register
end

builtin_shared.make_registration = function() return make_registration(false) end
builtin_shared.make_registration_reverse = function() return make_registration(true) end










