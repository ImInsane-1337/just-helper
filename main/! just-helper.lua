local pui = require("gamesense/pui")

-- locals
local client_exec             = client.exec
local client_color_log        = client.color_log
local client_screen_size      = client.screen_size
local client_system_time      = client.system_time
local client_key_state        = client.key_state
local client_set_cvar         = client.set_cvar
local client_userid_to_ent    = client.userid_to_entindex
local client_random_int       = client.random_int
local client_set_event        = client.set_event_callback

local renderer_world_to_screen= renderer.world_to_screen
local renderer_line           = renderer.line
local renderer_rectangle      = renderer.rectangle
local renderer_gradient       = renderer.gradient
local renderer_text           = renderer.text
local renderer_measure_text   = renderer.measure_text
local renderer_circle         = renderer.circle

local entity_get_all          = entity.get_all
local entity_get_prop         = entity.get_prop
local entity_set_prop         = entity.set_prop
local entity_get_player_name  = entity.get_player_name
local entity_get_local        = entity.get_local_player
local entity_is_alive         = entity.is_alive
local entity_get_player_weapon= entity.get_player_weapon
local entity_get_classname    = entity.get_classname

local globals_realtime        = globals.realtime
local globals_tickcount       = globals.tickcount

local ui_reference            = ui.reference
local ui_get                  = ui.get
local ui_set                  = ui.set
local ui_is_menu_open         = ui.is_menu_open
local ui_mouse_position       = ui.mouse_position
local ui_name                 = ui.name

local math_cos                = math.cos
local math_sin                = math.sin
local math_pi                 = math.pi
local math_abs                = math.abs
local math_max                = math.max
local math_min                = math.min
local math_floor              = math.floor
local math_sqrt               = math.sqrt

local database_read           = database.read
local database_write          = database.write

local cvar_r_aspectratio      = cvar.r_aspectratio
local cvar_viewmodel_fov      = cvar.viewmodel_fov
local cvar_viewmodel_offset_x = cvar.viewmodel_offset_x
local cvar_viewmodel_offset_y = cvar.viewmodel_offset_y
local cvar_viewmodel_offset_z = cvar.viewmodel_offset_z
local cvar_con_filter_enable  = cvar.con_filter_enable
local cvar_con_filter_text_out= cvar.con_filter_text_out
local cvar_cl_righthand       = cvar.cl_righthand

local table_insert            = table.insert
local table_remove            = table.remove
local bit_band                = bit.band
local orig_ar                 = cvar_r_aspectratio:get_float()
local orig_view_fov           = cvar_viewmodel_fov:get_float()
local orig_view_x             = cvar_viewmodel_offset_x:get_float()
local orig_view_y             = cvar_viewmodel_offset_y:get_float()
local orig_view_z             = cvar_viewmodel_offset_z:get_float()
local orig_righthand          = cvar_cl_righthand:get_int()

client_exec("clear")
client_color_log(180, 210, 255, "[Just Helper] Successfully loaded!")
client_color_log(180, 210, 255, "[Just Helper] Have a good game!")

-- PUI Setuping
local tmp_title_label = pui.label("LUA", "B", "JUST HELPER")
local ui_tab = pui.combobox("LUA", "B", "Tabs", {"Info", "Visual", "Misc"})
local tmp_accent_color = pui.color_picker("LUA", "B", "Accent color", 180, 210, 255, 255)

local ar, ag, ab, aa = tmp_accent_color:get()
pui.accent = string.format("%02X%02X%02X%02X", ar, ag, ab, aa)
pui.macros.pfx = "\v~\r "

local menu
menu = {
    info = {
        version_label = pui.label("LUA", "B", "Version:"),
        emptylabel = pui.label("LUA", "B", " "),
        stats_group = pui.label("LUA", "B", "\v[-] Overall stats"),
        time_label = pui.label("LUA", "B", " • Time played:"),
        kills_label = pui.label("LUA", "B", " • Total kills:"),
        deaths_label = pui.label("LUA", "B", " • Total deaths:"),
        kd_label = pui.label("LUA", "B", " • K/D Ratio:"),
        emptylabel2 = pui.label("LUA", "B", "  "),
        github_btn = pui.button("LUA", "B", "\vOpen Github Project", function()
            panorama.open().SteamOverlayAPI.OpenExternalBrowserURL("https://github.com/")
        end)
    },
    vis = {
        title_label = tmp_title_label,
        accent_color = tmp_accent_color,
        
        molotov_radius = pui.checkbox("LUA", "B", "\f<pfx>Molotov spread"),
        molotov_style = pui.combobox("LUA", "B", "\f<pfx>Molotov spread style", {"Circles", "Lines"}),
        molotov_color = pui.color_picker("LUA", "B", "\f<pfx>Molotov spread color", 255, 100, 100, 150),
        
        aspect_enable = pui.checkbox("LUA", "B", "\f<pfx>Override aspect ratio"),
        aspect_ratio = pui.slider("LUA", "B", "\f<pfx>Aspect ratio value", 0, 200, 100, true, "x", 0.01),
        
        viewmodel_enable = pui.checkbox("LUA", "B", "\f<pfx>Override viewmodel"),
        viewmodel_fov = pui.slider("LUA", "B", "\f<pfx>Viewmodel FOV", 40, 150, 60),
        viewmodel_x = pui.slider("LUA", "B", "\f<pfx>Viewmodel offset X", -100, 100, 10, true, "", 0.1),
        viewmodel_y = pui.slider("LUA", "B", "\f<pfx>Viewmodel offset Y", -100, 100, 10, true, "", 0.1),
        viewmodel_z = pui.slider("LUA", "B", "\f<pfx>Viewmodel offset Z", -100, 100, -10, true, "", 0.1),
        vm_in_scope = pui.checkbox("LUA", "B", "\f<pfx>Show viewmodel in scope"),
        
        watermark = pui.checkbox("LUA", "B", "\f<pfx>Watermark"),
        
        hitlogs = pui.multiselect("LUA", "B", "\f<pfx>Hitlogs", {"Console", "Screen"}),
        hitlogs_label = pui.label("LUA", "B", "\f<pfx>Hit color"),
        hitlogs_color = pui.color_picker("LUA", "B", "\f<pfx>Hit color", 180, 210, 255, 255),
        
        misslogs_label = pui.label("LUA", "B", "\f<pfx>Miss color"),
        misslogs_color = pui.color_picker("LUA", "B", "\f<pfx>Miss color", 255, 100, 100, 255),
        
        hitmarker_3d = pui.checkbox("LUA", "B", "\f<pfx>3D Hitmarker & Damage"),
        hitmarker_color = pui.color_picker("LUA", "B", "\n3DHitcolor", 255, 70, 70, 255),
        
        inds = pui.checkbox("LUA", "B", "\f<pfx>Crosshair Indicators"),
        keybinds = pui.checkbox("LUA", "B", "\f<pfx>Keybinds"),
        speclist = pui.checkbox("LUA", "B", "\f<pfx>Spectator List"),
        velo_ind = pui.checkbox("LUA", "B", "\f<pfx>Slowdown Indicator")
    },
    misc = {
        spoofer_enable = pui.checkbox("LUA", "B", "\f<pfx>Name Spoofer (In Menu)"),
        spoofer_name = pui.textbox("LUA", "B", "\f<pfx>Spoofed Name"),
        
        spoofer_save = pui.button("LUA", "B", "Save Nickname", function()
            if menu.misc.spoofer_enable:get() then
                local name = menu.misc.spoofer_name:get()
                if name and name ~= "" then
                    client_set_cvar("name", name)
                    client_color_log(150, 200, 255, "[Just Helper] Name spoofed to: " .. name)
                end
            end
        end),
        
        killsay_enable = pui.checkbox("LUA", "B", "\f<pfx>Killsay"),
        
        smart_hs = pui.checkbox("LUA", "B", "\f<pfx>Smart Hide Shots"),
        smart_hs_conds = pui.multiselect("LUA", "B", "\f<pfx>Hide shots conditions", {"Stand", "Crouch", "Sneaking", "Slow walk"}),
        smart_hs_weaps = pui.multiselect("LUA", "B", "\f<pfx>Hide shots weapons", {"Scout", "AWP", "Auto", "R8", "Deagle", "Pistols", "Other"}),
        
        autobuy = pui.checkbox("LUA", "B", "\f<pfx>Autobuy"),
        autobuy_money = pui.slider("LUA", "B", "\f<pfx>Buy when money is more than", 0, 16000, 3000, true, "$", 1),
        autobuy_pri = pui.combobox("LUA", "B", "\f<pfx>Primary", {"-", "Scout", "AWP", "Auto"}),
        autobuy_sec = pui.combobox("LUA", "B", "\f<pfx>Secondary", {"-", "Deagle/R8", "Tec-9/Fiveseven/CZ", "Dual Berretas", "P250"}),
        autobuy_nades = pui.multiselect("LUA", "B", "\f<pfx>Grenades", {"HE", "Smoke", "Molotov", "Decoy", "Flashbang"}),
        autobuy_utils = pui.multiselect("LUA", "B", "\f<pfx>Utilities", {"Helmet", "Armor", "Zeus", "Defuser"}),
        
        console_filter = pui.checkbox("LUA", "B", "\f<pfx>Console Spam Filter"),
        
        first_person_nade = pui.checkbox("LUA", "B", "\f<pfx>Firstperson grenades"),
        left_knife = pui.checkbox("LUA", "B", "\f<pfx>Knife opposite hand")
    }
}

 
-- dependencies
menu.info.version_label:depend({ui_tab, "Info"})
menu.info.emptylabel:depend({ui_tab, "Info"})
menu.info.stats_group:depend({ui_tab, "Info"})
menu.info.time_label:depend({ui_tab, "Info"})
menu.info.kills_label:depend({ui_tab, "Info"})
menu.info.deaths_label:depend({ui_tab, "Info"})
menu.info.kd_label:depend({ui_tab, "Info"})
menu.info.emptylabel2:depend({ui_tab, "Info"})
menu.info.github_btn:depend({ui_tab, "Info"})

menu.vis.molotov_radius:depend({ui_tab, "Visual"})
menu.vis.molotov_style:depend({ui_tab, "Visual"}, {menu.vis.molotov_radius, true})
menu.vis.molotov_color:depend({ui_tab, "Visual"}, {menu.vis.molotov_radius, true})

menu.vis.aspect_enable:depend({ui_tab, "Visual"})
menu.vis.aspect_ratio:depend({ui_tab, "Visual"}, {menu.vis.aspect_enable, true})

menu.vis.viewmodel_enable:depend({ui_tab, "Visual"})
menu.vis.viewmodel_fov:depend({ui_tab, "Visual"}, {menu.vis.viewmodel_enable, true})
menu.vis.viewmodel_x:depend({ui_tab, "Visual"}, {menu.vis.viewmodel_enable, true})
menu.vis.viewmodel_y:depend({ui_tab, "Visual"}, {menu.vis.viewmodel_enable, true})
menu.vis.viewmodel_z:depend({ui_tab, "Visual"}, {menu.vis.viewmodel_enable, true})
menu.vis.vm_in_scope:depend({ui_tab, "Visual"}, {menu.vis.viewmodel_enable, true})

menu.vis.watermark:depend({ui_tab, "Visual"})

menu.vis.hitlogs:depend({ui_tab, "Visual"})
menu.vis.hitlogs_label:depend({ui_tab, "Visual"}, {menu.vis.hitlogs, function() return #menu.vis.hitlogs:get() > 0 end})
menu.vis.hitlogs_color:depend({ui_tab, "Visual"}, {menu.vis.hitlogs, function() return #menu.vis.hitlogs:get() > 0 end})
menu.vis.misslogs_label:depend({ui_tab, "Visual"}, {menu.vis.hitlogs, function() return #menu.vis.hitlogs:get() > 0 end})
menu.vis.misslogs_color:depend({ui_tab, "Visual"}, {menu.vis.hitlogs, function() return #menu.vis.hitlogs:get() > 0 end})

menu.vis.hitmarker_3d:depend({ui_tab, "Visual"})
menu.vis.hitmarker_color:depend({ui_tab, "Visual"}, {menu.vis.hitmarker_3d, true})

menu.vis.inds:depend({ui_tab, "Visual"})
menu.vis.keybinds:depend({ui_tab, "Visual"})
menu.vis.speclist:depend({ui_tab, "Visual"})
menu.vis.velo_ind:depend({ui_tab, "Visual"})

menu.misc.spoofer_enable:depend({ui_tab, "Misc"})
menu.misc.spoofer_name:depend({ui_tab, "Misc"}, {menu.misc.spoofer_enable, true})
menu.misc.spoofer_save:depend({ui_tab, "Misc"}, {menu.misc.spoofer_enable, true})

menu.misc.killsay_enable:depend({ui_tab, "Misc"})

menu.misc.smart_hs:depend({ui_tab, "Misc"})
menu.misc.smart_hs_conds:depend({ui_tab, "Misc"}, {menu.misc.smart_hs, true})
menu.misc.smart_hs_weaps:depend({ui_tab, "Misc"}, {menu.misc.smart_hs, true})

menu.misc.autobuy:depend({ui_tab, "Misc"})
menu.misc.autobuy_money:depend({ui_tab, "Misc"}, {menu.misc.autobuy, true})
menu.misc.autobuy_pri:depend({ui_tab, "Misc"}, {menu.misc.autobuy, true})
menu.misc.autobuy_sec:depend({ui_tab, "Misc"}, {menu.misc.autobuy, true})
menu.misc.autobuy_nades:depend({ui_tab, "Misc"}, {menu.misc.autobuy, true})
menu.misc.autobuy_utils:depend({ui_tab, "Misc"}, {menu.misc.autobuy, true})

menu.misc.console_filter:depend({ui_tab, "Misc"})
menu.misc.first_person_nade:depend({ui_tab, "Misc"})
menu.misc.left_knife:depend({ui_tab, "Misc"})


-- references
local ref_hs, ref_hs_key = ui_reference("AA", "Other", "On shot anti-aim")
local ref_slow, ref_slow_key = ui_reference("AA", "Other", "Slow motion")
local ref_dt, ref_dt_key = ui_reference("RAGE", "Aimbot", "Double tap")
local ref_fd = ui_reference("RAGE", "Other", "Duck peek assist")
local ref_baim = ui_reference("RAGE", "Aimbot", "Force body aim")
local ref_sp = ui_reference("RAGE", "Aimbot", "Force safe point")
local ref_mdmg, ref_mdmg_key = ui_reference("RAGE", "Aimbot", "Minimum damage override")

local pui_ref_dt = pui.reference("RAGE", "Aimbot", "Double tap")
local pui_ref_hs = pui.reference("AA", "Other", "On shot anti-aim")
local pui_ref_tp = pui.reference("VISUALS", "Effects", "Force third person (alive)")

local orig_filter_en = cvar_con_filter_enable:get_int()
local orig_filter_out = cvar_con_filter_text_out:get_string()

-- helpers
local function lerp(a, b, t)
    return a + (b - a) * t
end

local function has_value(tab, val)
    if tab == nil then return false end
    for i = 1, #tab do
        if tab[i] == val then return true end
    end
    return false
end

local function get_dist_sq(p1, p2)
    return (p1.x - p2.x)*(p1.x - p2.x) + (p1.y - p2.y)*(p1.y - p2.y)
end

local function get_orientation(p, q, r)
    local val = (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y)
    if math_abs(val) < 1.0 then return 0 end
    return (val > 0) and 1 or 2
end

local function get_convex_hull(points)
    local n = #points
    if n < 3 then return points end

    local hull = {}
    local leftmost = 1
    for i = 2, n do
        if points[i].x < points[leftmost].x then
            leftmost = i
        end
    end

    local p = leftmost
    local q
    repeat
        hull[#hull + 1] = points[p]
        q = (p % n) + 1
        for i = 1, n do
            local o = get_orientation(points[p], points[i], points[q])
            if o == 2 then
                q = i
            elseif o == 0 then
                if get_dist_sq(points[p], points[i]) > get_dist_sq(points[p], points[q]) then
                    q = i
                end
            end
        end
        p = q
        if #hull > n then break end
    until (p == leftmost)

    return hull
end

local function draw_circle_3d(x, y, z, radius, r, g, b, a)
    local step = (math_pi * 2.0) / 32
    local prev_screen_x, prev_screen_y

    for i = 0, 32 do
        local theta = i * step
        local point_x = x + radius * math_cos(theta)
        local point_y = y + radius * math_sin(theta)
        local screen_x, screen_y = renderer_world_to_screen(point_x, point_y, z)
        
        if screen_x ~= nil and screen_y ~= nil and prev_screen_x ~= nil and prev_screen_y ~= nil then
            renderer_line(prev_screen_x, prev_screen_y, screen_x, screen_y, r, g, b, a)
        end
        prev_screen_x, prev_screen_y = screen_x, screen_y
    end
end

local function format_time(seconds)
    local h = math_floor(seconds / 3600)
    local m = math_floor((seconds % 3600) / 60)
    local s = math_floor(seconds % 60)
    return string.format("%02d:%02d:%02d", h, m, s)
end

local build = "stable"
local p_version = "1.1"
local start_time = globals_realtime()
local jh_stats = database_read("jh_stats") or { kills = 0, deaths = 0, time = 0 }
if jh_stats.deaths == nil then jh_stats.deaths = 0 end
if jh_stats.kills == nil then jh_stats.kills = 0 end

local screen_logs = {}
local _hitmarkers_3d = {}
local fired_shots = {}

-- callbacks + hooking
menu.vis.accent_color:set_callback(function(c)
    local r, g, b, a = c:get()
    pui.accent = string.format("%02X%02X%02X%02X", r, g, b, a)
end, true)

menu.vis.aspect_enable:set_callback(function(c)
    if not c:get() then cvar_r_aspectratio:set_raw_float(orig_ar) end
end)

menu.misc.smart_hs:set_callback(function(c)
    if not c:get() then
        if is_forcing_hs then
            pui_ref_dt:override()
            pui_ref_hs:override()
            ui_set(ref_hs_key, "On hotkey")
            is_forcing_hs = false
        end
    end
end)

menu.misc.console_filter:set_callback(function(c)
    if c:get() then
        cvar_con_filter_enable:set_raw_int(1)
        cvar_con_filter_text_out:set_string("Failed to set custom material for;Achievements disabled;Certificate expires")
    else
        cvar_con_filter_enable:set_raw_int(orig_filter_en)
        cvar_con_filter_text_out:set_string(orig_filter_out)
    end
end)

menu.misc.first_person_nade:set_callback(function(c)
    if not c:get() then
        pui_ref_tp:override()
    end
end)

menu.misc.left_knife:set_callback(function(c)
    if not c:get() then
        cvar_cl_righthand:set_raw_int(orig_righthand)
    end
end)

local function on_shutdown()
    jh_stats.time = jh_stats.time + (globals_realtime() - start_time)
    database_write("jh_stats", jh_stats)

    cvar_r_aspectratio:set_raw_float(orig_ar)
    cvar_viewmodel_fov:set_raw_float(orig_view_fov)
    cvar_viewmodel_offset_x:set_raw_float(orig_view_x)
    cvar_viewmodel_offset_y:set_raw_float(orig_view_y)
    cvar_viewmodel_offset_z:set_raw_float(orig_view_z)
    cvar_cl_righthand:set_raw_int(orig_righthand)
    
    client_color_log(180, 210, 255, "[Just Helper] Script unloaded!")
end

-- Cache variables
local CInferno_cache_circles = {}
local CInferno_cache_lines = {}

local hitgroups = {
    [0] = "generic", [1] = "head", [2] = "chest", [3] = "stomach",
    [4] = "left arm", [5] = "right arm", [6] = "left leg", [7] = "right leg", [10] = "gear"
}

local hitlogs_x, hitlogs_y = nil, nil
local is_dragging_logs = false
local drag_dx, drag_dy = 0, 0

local inds_x, inds_y = nil, nil
local is_dragging_inds = false
local drag_inds_dx, drag_inds_dy = 0, 0

local keybinds_x, keybinds_y = nil, nil
local is_dragging_kbs = false
local drag_kbs_dx, drag_kbs_dy = 0, 0

local speclist_x, speclist_y = nil, nil
local is_dragging_spec = false
local drag_spec_dx, drag_spec_dy = 0, 0

local velo_x, velo_y = nil, nil
local is_dragging_velo = false
local drag_velo_dx, drag_velo_dy = 0, 0

local is_forcing_hs = false
local hs_condition_met_time = 0

local _watermark_width = 0
local keybinds_list_h = 0
local speclist_h = 0

local killsay_phrases = {
    "1", "sit down", "easy", "bot down", "nice try", "zzz", 
    "why are u even trying?", "just helper hooks again"
}

-- Autobuy Variables
local round_start_time = 0
local bought_this_round = false

local function on_round_start()
    round_start_time = globals_realtime()
    bought_this_round = false
end

local function handle_autobuy()
    if not menu.misc.autobuy:get() or bought_this_round then return end

    if globals_realtime() - round_start_time > 0.14 then
        local me = entity_get_local()
        if me and entity_is_alive(me) then
            local money = entity_get_prop(me, "m_iAccount")
            if money and money >= menu.misc.autobuy_money:get() then
                local cmds = {}
                
                local pri = menu.misc.autobuy_pri:get()
                if pri == "Scout" then table_insert(cmds, "buy ssg08")
                elseif pri == "AWP" then table_insert(cmds, "buy awp")
                elseif pri == "Auto" then table_insert(cmds, "buy scar20; buy g3sg1") end
                
                local sec = menu.misc.autobuy_sec:get()
                if sec == "Deagle/R8" then table_insert(cmds, "buy deagle; buy revolver")
                elseif sec == "Tec-9/Fiveseven/CZ" then table_insert(cmds, "buy tec9; buy fiveseven; buy cz75a")
                elseif sec == "Dual Berretas" then table_insert(cmds, "buy elite")
                elseif sec == "P250" then table_insert(cmds, "buy p250") end
                
                for _, nade in ipairs(menu.misc.autobuy_nades:get()) do
                    if nade == "HE" then table_insert(cmds, "buy hegrenade")
                    elseif nade == "Smoke" then table_insert(cmds, "buy smokegrenade")
                    elseif nade == "Molotov" then table_insert(cmds, "buy molotov; buy incgrenade")
                    elseif nade == "Flashbang" then table_insert(cmds, "buy flashbang")
                    elseif nade == "Decoy" then table_insert(cmds, "buy decoy") end
                end
                
                for _, util in ipairs(menu.misc.autobuy_utils:get()) do
                    if util == "Helmet" then table_insert(cmds, "buy vesthelm")
                    elseif util == "Armor" then table_insert(cmds, "buy vest")
                    elseif util == "Zeus" then table_insert(cmds, "buy taser")
                    elseif util == "Defuser" then table_insert(cmds, "buy defuser") end
                end
                
                if #cmds > 0 then
                    client_exec(table.concat(cmds, "; "))
                end
            end
        end
        bought_this_round = true
    end
end

local function on_net_update_end()
    if not menu.vis.molotov_radius:get() then return end
    
    local infernos = entity_get_all("CInferno")
    CInferno_cache_circles = {}
    CInferno_cache_lines = {}
    
    local style = menu.vis.molotov_style:get()
    
    for i = 1, #infernos do
        local inferno = infernos[i]
        local x, y, z = entity_get_prop(inferno, "m_vecOrigin")
        if x and y and z then
            local fire_count = entity_get_prop(inferno, "m_fireCount")
            if fire_count and fire_count > 0 then
                local active_cells = {}
                for j = 0, fire_count - 1 do
                    if entity_get_prop(inferno, "m_bFireIsBurning", j) then
                        local x_delta = entity_get_prop(inferno, "m_fireXDelta", j) or 0
                        local y_delta = entity_get_prop(inferno, "m_fireYDelta", j) or 0
                        local z_delta = entity_get_prop(inferno, "m_fireZDelta", j) or 0
                        table_insert(active_cells, {
                            x = x + x_delta,
                            y = y + y_delta,
                            z = z + z_delta
                        })
                    end
                end
                
                if #active_cells > 0 then
                    if style == "Circles" then
                        table_insert(CInferno_cache_circles, active_cells)
                    elseif style == "Lines" then
                        local hull_points = {}
                        for k = 1, #active_cells do
                            local cx = active_cells[k].x
                            local cy = active_cells[k].y
                            local cz = active_cells[k].z
                            for a_step = 0, 7 do
                                local angle = a_step * (math_pi / 4)
                                table_insert(hull_points, {
                                    x = cx + 40 * math_cos(angle),
                                    y = cy + 40 * math_sin(angle),
                                    z = cz
                                })
                            end
                        end
                        table_insert(CInferno_cache_lines, get_convex_hull(hull_points))
                    end
                end
            end
        end
    end
end

local function on_pre_render()
    if menu.vis.aspect_enable:get() then
        local ar = menu.vis.aspect_ratio:get()
        cvar_r_aspectratio:set_raw_float(ar > 0 and (ar / 100) or 0)
    end

    handle_autobuy()

    -- vm override
    if menu.vis.viewmodel_enable:get() then
        cvar_viewmodel_fov:set_raw_float(menu.vis.viewmodel_fov:get())
        cvar_viewmodel_offset_x:set_raw_float(menu.vis.viewmodel_x:get() / 10)
        cvar_viewmodel_offset_y:set_raw_float(menu.vis.viewmodel_y:get() / 10)
        cvar_viewmodel_offset_z:set_raw_float(menu.vis.viewmodel_z:get() / 10)
        
        if menu.vis.vm_in_scope:get() then
            local me = entity_get_local()
            if me and entity_is_alive(me) then
                if entity_get_prop(me, "m_bIsScoped") == 1 then
                    entity_set_prop(me, "m_bIsScoped", 0)
                end
            end
        end
    end
    
    local is_grenade = false
    local is_knife = false
    local me = entity_get_local()
    if me and entity_is_alive(me) then
        local weap = entity_get_player_weapon(me)
        local classname = weap and entity_get_classname(weap) or ""
        
        is_knife = (classname == "CKnife")
        is_grenade = (classname == "CFlashbang" or classname == "CSmokeGrenade" or classname == "CHEGrenade" or classname == "CMolotovGrenade" or classname == "CIncendiaryGrenade" or classname == "CDecoyGrenade")
    end
    
    if menu.misc.first_person_nade:get() then
        if is_grenade then
            pui_ref_tp:override(false)
        else
            pui_ref_tp:override()
        end
    end
    
    if menu.misc.left_knife:get() then
        if is_knife then
            cvar_cl_righthand:set_raw_int(0)
        else
            cvar_cl_righthand:set_raw_int(orig_righthand)
        end
    end
end

local function draw_molotovs()
    if menu.vis.molotov_radius:get() then
        local style = menu.vis.molotov_style:get()
        local r, g, b, a = menu.vis.molotov_color:get()
        
        if style == "Circles" then
            for i = 1, #CInferno_cache_circles do
                local cells = CInferno_cache_circles[i]
                for k = 1, #cells do
                    draw_circle_3d(cells[k].x, cells[k].y, cells[k].z, 40, r, g, b, a)
                end
            end
        elseif style == "Lines" then
            for i = 1, #CInferno_cache_lines do
                local hull = CInferno_cache_lines[i]
                for k = 1, #hull do
                    local p1 = hull[k]
                    local p2 = hull[(k % #hull) + 1]
                    local sx1, sy1 = renderer_world_to_screen(p1.x, p1.y, p1.z)
                    local sx2, sy2 = renderer_world_to_screen(p2.x, p2.y, p2.z)
                    if sx1 and sy1 and sx2 and sy2 then
                        renderer_line(sx1, sy1, sx2, sy2, r, g, b, a)
                    end
                end
            end
        end
    end
end

local function draw_watermark()
    if menu.vis.watermark:get() then
        local r, g, b, a = menu.vis.accent_color:get()
        local sw, sh = client_screen_size()
        local globals_ft = globals.frametime and globals.frametime() or math_max(0.001, globals_realtime() - (start_time or 0))
        
        local me = entity_get_local()
        local local_name = me and entity_get_player_name(me) or "unknown"
        if #local_name > 14 then local_name = string.sub(local_name, 1, 14) end
        
        local h, m, s = client_system_time()
        local time_str = string.format("%02d:%02d:%02d", h, m, s)
        local text = string.format("Just Helper | %s (%s) | %s | %s", p_version, build, time_str, local_name)
        
        local tw, th = renderer_measure_text("d", text)
        local target_w = tw + 20
        
        if _watermark_width == 0 then _watermark_width = target_w end
        _watermark_width = lerp(_watermark_width, target_w, globals_ft * 12)
        
        local w = math_floor(_watermark_width)
        local x = sw - w - 15
        local y = 15
        
        renderer_rectangle(x, y, w, 22, 20, 20, 20, 230)
        renderer_rectangle(x + 1, y + 1, w - 2, 20, 30, 30, 30, 150)
        
        local t = globals_realtime() * 1.5
        local offset = (math_sin(t) + 1) / 2
        local center = math_floor(x + w * offset)

        renderer_rectangle(x, y, w, 2, r, g, b, 150)
        
        local glow_size = 40
        local glow_start = math_max(x, center - glow_size)
        local glow_end = math_min(x + w, center + glow_size)

        if center > x then
            local size_left = center - glow_start
            renderer_gradient(glow_start, y, size_left, 2, r, g, b, 0, r, g, b, 255, true)
        end
        if center < (x + w) then
            local size_right = glow_end - center
            renderer_gradient(center, y, size_right, 2, r, g, b, 255, r, g, b, 0, true)
        end
        
        renderer_text(x + math_floor((w - tw) / 2), y + 4, 255, 255, 255, 255, "d", 0, text)
    end
end

local function draw_hitlogs()
    local active_hitlogs = menu.vis.hitlogs:get()
    if has_value(active_hitlogs, "Screen") then
        local sw, sh = client_screen_size()
        local globals_ft = globals.frametime and globals.frametime() or 0.015
        if hitlogs_x == nil or hitlogs_y == nil then
            hitlogs_x = math_floor(sw / 2)
            hitlogs_y = math_floor(sh / 2 + 120)
        end
        
        local menu_open = ui_is_menu_open()
        if menu_open then
            local mx, my = ui_mouse_position()
            local is_lmb = client_key_state(0x01)
            
            local dw = 320
            local dh = 135
            local dx = hitlogs_x - dw / 2
            local dy = hitlogs_y + 15
            
            local bg_alpha = is_dragging_logs and 30 or 10
            renderer_rectangle(dx, dy, dw, dh, 255, 255, 255, bg_alpha)
            
            if is_lmb then
                if not is_dragging_logs then
                    if mx >= dx and mx <= (dx + dw) and my >= dy and my <= (dy + dh) then
                        is_dragging_logs = true
                        drag_dx = hitlogs_x - mx
                        drag_dy = hitlogs_y - my
                    end
                end
            else
                is_dragging_logs = false
            end
            
            if is_dragging_logs then
                local target_x = mx + drag_dx
                local target_y = my + drag_dy
                
                if math_abs(target_x - (sw / 2)) < 40 then hitlogs_x = math_floor(sw / 2) else hitlogs_x = target_x end
                if math_abs(target_y - (sh / 2)) < 40 then hitlogs_y = math_floor(sh / 2) else hitlogs_y = target_y end
            end
        else
            is_dragging_logs = false
        end
        
        local draw_y = hitlogs_y + 15
        local draw_log_line = function(text, r, g, b, a, y_pos)
            local tw, th = renderer_measure_text("d", text)
            local pad = 16
            local total_w = tw + pad * 2
            local lx = hitlogs_x - math_floor(total_w / 2)
            
            renderer_rectangle(lx, y_pos, total_w, 22, 20, 20, 20, math_floor(a * 0.7))
            renderer_rectangle(lx, y_pos, 2, 22, r, g, b, a)
            renderer_gradient(lx + 2, y_pos, 40, 22, r, g, b, math_floor(a * 0.15), r, g, b, 0, true)
            renderer_text(hitlogs_x, y_pos + 11, 255, 255, 255, a, "cd", 0, text)
        end
        
        for i = #screen_logs, 1, -1 do
            local log = screen_logs[i]
            if menu_open then log.time = log.time + (globals_realtime() - (log.last_realtime or globals_realtime())) end
            log.last_realtime = globals_realtime()
            if (globals_realtime() - log.time) > 4 and not menu_open then
                log.alpha = log.alpha - 6
            end
            if log.alpha <= 0 then
                table_remove(screen_logs, i)
            end
        end

        local logs_to_draw = {}
        for i=1, #screen_logs do table_insert(logs_to_draw, screen_logs[i]) end
        
        if menu_open and #logs_to_draw == 0 then
            local hr, hg, hb = menu.vis.hitlogs_color:get()
            local mr, mg, mb = menu.vis.misslogs_color:get()
            table_insert(logs_to_draw, {text = "Hit player1 in head for 100 hp | hc: 95%", clr = {hr, hg, hb}, alpha = 255})
            table_insert(logs_to_draw, {text = "Hit player2 in stomach for 45 hp | hc: 81%", clr = {hr, hg, hb}, alpha = 255})
            table_insert(logs_to_draw, {text = "Missmatched player3 in chest for 15 hp | hc: 72% | exp: 50", clr = {mr, mg, mb}, alpha = 255})
        end
        
        if #logs_to_draw > 0 then
            for i = #logs_to_draw, 1, -1 do
                local log = logs_to_draw[i]
                draw_log_line(log.text, log.clr[1], log.clr[2], log.clr[3], log.alpha, draw_y)
                draw_y = draw_y + 24
            end
        end
    end
end

local function draw_crosshair_inds()
    if menu.vis.inds:get() then
        local sw, sh = client_screen_size()
        if inds_x == nil or inds_y == nil then
            inds_x = math_floor(sw / 2)
            inds_y = math_floor(sh / 2 + 50)
        end
        
        local menu_open = ui_is_menu_open()
        if menu_open then
            local mx, my = ui_mouse_position()
            local is_lmb = client_key_state(0x01)
            
            local dh = 16
            local dw = 40
            local dr = 4
            local dx = inds_x - dw / 2
            local dy = inds_y - dh / 2
            
            local bg_alpha = is_dragging_inds and 40 or 20
            renderer_rectangle(dx + dr, dy, dw - dr*2, dh, 255, 255, 255, bg_alpha)
            renderer_rectangle(dx, dy + dr, dw, dh - dr*2, 255, 255, 255, bg_alpha)
            renderer_circle(dx + dr, dy + dr, 255, 255, 255, bg_alpha, dr, 0, 1)
            renderer_circle(dx + dw - dr, dy + dr, 255, 255, 255, bg_alpha, dr, 0, 1)
            renderer_circle(dx + dr, dy + dh - dr, 255, 255, 255, bg_alpha, dr, 0, 1)
            renderer_circle(dx + dw - dr, dy + dh - dr, 255, 255, 255, bg_alpha, dr, 0, 1)
            
            if is_lmb then
                if not is_dragging_inds then
                    if mx >= dx and mx <= (dx + dw) and my >= dy and my <= (dy + dh) then
                        is_dragging_inds = true
                        drag_inds_dx = inds_x - mx
                        drag_inds_dy = inds_y - my
                    end
                end
            else
                is_dragging_inds = false
            end
            
            if is_dragging_inds then
                local target_x = mx + drag_inds_dx
                local target_y = my + drag_inds_dy
                
                if math_abs(target_x - (sw / 2)) < 40 then inds_x = math_floor(sw / 2) else inds_x = target_x end
                inds_y = target_y
            end
        else
            is_dragging_inds = false
        end
        
        local iy = inds_y + 16
        local acc_r, acc_g, acc_b, acc_a = menu.vis.accent_color:get()
        
        local text_title = "JUST HELPER"
        local tw = renderer_measure_text("-d", text_title)
        local current_x = inds_x - tw / 2
        
        for i = 1, #text_title do
            local char = text_title:sub(i, i)
            local char_w = renderer_measure_text("-d", char)
            local pct = (math_sin(globals_realtime() * 3 + i * 0.3) + 1) * 0.5
            local r = math_floor(acc_r + (0 - acc_r) * pct)
            local g = math_floor(acc_g + (0 - acc_g) * pct)
            local b = math_floor(acc_b + (0 - acc_b) * pct)
            
            renderer_text(current_x, iy, r, g, b, 255, "-d", 0, char)
            current_x = current_x + char_w
        end
        
        iy = iy + 14
        
        local function draw_ind(text, extra)
            renderer_text(inds_x, iy, acc_r, acc_g, acc_b, 255, "cd-", 0, text)
            if extra then
                local extra_tw = (renderer_measure_text("-d", text) / 2) + 6
                renderer_text(inds_x + extra_tw, iy, 200, 200, 200, 255, "d-", 0, extra)
            end
            iy = iy + 10
        end

        local function is_active(ref, key)
            if key ~= nil and type(ui_get(key)) == "boolean" then
                return ui_get(key)
            end
            if ref ~= nil and type(ui_get(ref)) == "boolean" then
                return ui_get(ref)
            end
            return false
        end
        
        if ui_get(ref_dt) and is_active(ref_dt, ref_dt_key) then draw_ind("DT") end
        if ui_get(ref_hs) and is_active(ref_hs, ref_hs_key) then draw_ind("HS") end
        if is_active(ref_fd, nil) then draw_ind("FD") end
        if ui_get(ref_baim) then draw_ind("BAIM") end
        if ui_get(ref_sp) then draw_ind("SAFE") end
        if is_active(ref_slow, ref_slow_key) then draw_ind("SLOW") end
        if is_active(ref_mdmg, ref_mdmg_key) then 
            local dmg_val = type(ui_get(ref_mdmg)) == "number" and tostring(ui_get(ref_mdmg)) or nil
            draw_ind("MDMG", dmg_val)
        end
    end
end

local function draw_keybinds()
    if menu.vis.keybinds:get() then
        local sw, sh = client_screen_size()
        local globals_ft = globals.frametime and globals.frametime() or 0.015
        if keybinds_x == nil or keybinds_y == nil then
            keybinds_x = sw - 160
            keybinds_y = 500
        end
        
        local menu_open = ui_is_menu_open()
        if menu_open then
            local mx, my = ui_mouse_position()
            local is_lmb = client_key_state(0x01)
            
            local w = 150
            local base_y = keybinds_y + 16
            local dh = 22
            local dw = w
            local dx = keybinds_x - dw / 2
            local dy = base_y
            
            local bg_alpha = is_dragging_kbs and 40 or 15
            renderer_rectangle(dx, dy, dw, dh, 255, 255, 255, bg_alpha)
            
            if is_lmb then
                if not is_dragging_kbs then
                    if mx >= dx and mx <= (dx + dw) and my >= dy and my <= (dy + dh) then
                        is_dragging_kbs = true
                        drag_kbs_dx = keybinds_x - mx
                        drag_kbs_dy = keybinds_y - my
                    end
                end
            else
                is_dragging_kbs = false
            end
            
            if is_dragging_kbs then
                keybinds_x = mx + drag_kbs_dx
                keybinds_y = my + drag_kbs_dy
            end
        else
            is_dragging_kbs = false
        end
        
        local acc_r, acc_g, acc_b, acc_a = menu.vis.accent_color:get()
        local function is_active(ref, key)
            if key ~= nil and type(ui_get(key)) == "boolean" then return ui_get(key) end
            if ref ~= nil and type(ui_get(ref)) == "boolean" then return ui_get(ref) end
            return false
        end

        local active_binds = {}
        if ui_get(ref_dt) and is_active(ref_dt, ref_dt_key) then table_insert(active_binds, {n = "Double tap", v = "Active"}) end
        if ui_get(ref_hs) and is_active(ref_hs, ref_hs_key) then table_insert(active_binds, {n = "Hide shots", v = "Active"}) end
        if is_active(ref_fd, nil) then table_insert(active_binds, {n = "Duck peek assist", v = "Active"}) end
        if ui_get(ref_baim) then table_insert(active_binds, {n = "Force body aim", v = "Active"}) end
        if ui_get(ref_sp) then table_insert(active_binds, {n = "Force safe point", v = "Active"}) end
        if is_active(ref_slow, ref_slow_key) then table_insert(active_binds, {n = "Slow motion", v = "Active"}) end
        if is_active(ref_mdmg, ref_mdmg_key) then 
            local dmg_val = type(ui_get(ref_mdmg)) == "number" and tostring(ui_get(ref_mdmg)) or ""
            table_insert(active_binds, {n = "Min damage", v = dmg_val}) 
        end
        
        local target_h = #active_binds > 0 and (36 + #active_binds * 18) or 0
        if menu_open and target_h == 0 then target_h = 32 end
        
        keybinds_list_h = lerp(keybinds_list_h, target_h, globals_ft * 12)
        local h = math_floor(keybinds_list_h)
        local w = 150
        
        if h > 2 then
            local base_y = keybinds_y + 16
            renderer_rectangle(keybinds_x - w/2, base_y, w, h, 25, 25, 25, 190)
            renderer_rectangle(keybinds_x - w/2, base_y, w, 2, acc_r, acc_g, acc_b, math_floor(acc_a * 0.9))
            
            local header_a = math_min(255, math_max(0, h * 10 - 20))
            renderer_text(keybinds_x, base_y + 11, 230, 230, 230, header_a, "cd", 0, "Keybinds")
            
            for i, bind in ipairs(active_binds) do
                local item_y = base_y + 22 + (i - 1) * 18
                if item_y + 14 <= base_y + h then
                    local name = bind.n
                    local val = bind.v
                    local lx = keybinds_x - w/2 + 8
                    local rx = keybinds_x + w/2 - 8
                    
                    local text_a = math_min(255, math_max(0, (base_y + h - item_y) * 15))
                    renderer_text(lx, item_y + 9, 230, 230, 230, text_a, "d", 0, name)
                    if val ~= "" then
                        local vw = renderer_measure_text("d", val)
                        renderer_text(rx - vw, item_y + 9, 200, 200, 200, text_a, "d", 0, val)
                    end
                end
            end
        end
    end
end


local slowdown_global_alpha = 0

local function draw_velocity()
    if not menu.vis.velo_ind:get() then return end
    local sw, sh = client_screen_size()
    local globals_ft = globals.frametime and globals.frametime() or 0.015
    if velo_x == nil or velo_y == nil then
        velo_x = math_floor(sw / 2)
        velo_y = math_floor(sh / 2 + 180)
    end
    
    local menu_open = ui_is_menu_open()
    if menu_open then
        local mx, my = ui_mouse_position()
        local is_lmb = client_key_state(0x01)
        local w = 120
        local h = 32
        local by = velo_y + 16
        local dh = h
        local dw = w
        local dx = velo_x - dw / 2
        local dy = by
        
        local bg_alpha = is_dragging_velo and 40 or 15
        renderer_rectangle(dx, dy, dw, dh, 255, 255, 255, bg_alpha)
        
        if is_lmb then
            if not is_dragging_velo then
                if mx >= dx and mx <= (dx + dw) and my >= dy and my <= (dy + dh) then
                    is_dragging_velo = true
                    drag_velo_dx = velo_x - mx
                    drag_velo_dy = velo_y - my
                end
            end
        else
            is_dragging_velo = false
        end
        if is_dragging_velo then
            velo_x = mx + drag_velo_dx
            velo_y = my + drag_velo_dy
        end
    else
        is_dragging_velo = false
    end
    
    local me = entity_get_local()
    local is_alive = me and entity_is_alive(me)
    if not menu_open and not is_alive then return end
    
    local acc_r, acc_g, acc_b, acc_a = menu.vis.accent_color:get()
    
    local modifier = 1.0
    if menu_open then
        modifier = 0.5 + (math_sin(globals_realtime() * 3) + 1) * 0.25
    elseif is_alive then
        local prop_val = entity_get_prop(me, "m_flVelocityModifier")
        if prop_val then modifier = prop_val end
    end
    
    local target_alpha = 0
    if menu_open or modifier < 1.0 then target_alpha = 1.0 end
    
    slowdown_global_alpha = lerp(slowdown_global_alpha, target_alpha, globals_ft * 8)
    
    if slowdown_global_alpha > 0.01 then
        local base_alpha = math_floor(255 * slowdown_global_alpha)
        local w = 120
        local h = 32
        local by = velo_y + 16
        
        local bg_a = math_floor(190 * slowdown_global_alpha)
        local line_a = math_floor(math_floor(acc_a * 0.9) * slowdown_global_alpha)
        
        renderer_rectangle(velo_x - w/2, by, w, h, 25, 25, 25, bg_a)
        renderer_rectangle(velo_x - w/2, by, w, 2, acc_r, acc_g, acc_b, line_a)
        
        local pct_int = math_floor(modifier * 100)
        renderer_text(velo_x, by + 12, 230, 230, 230, base_alpha, "cd", 0, "Slowdown: " .. tostring(pct_int) .. "%")
        
        local bar_w = 100
        if modifier > 1 then modifier = 1 end
        local fill_w = math_max(0, math_floor(modifier * bar_w))
        
        renderer_rectangle(velo_x - bar_w/2, by + 22, bar_w, 4, 15, 15, 15, base_alpha)
        if fill_w > 0 then
            renderer_rectangle(velo_x - bar_w/2, by + 22, fill_w, 4, acc_r, acc_g, acc_b, base_alpha)
        end
    end
end

local function draw_3d_hitmarkers()
    if menu.vis.hitmarker_3d:get() then
        local c_r, c_g, c_b, c_a = menu.vis.hitmarker_color:get()
        for i = #_hitmarkers_3d, 1, -1 do
            local mark = _hitmarkers_3d[i]
            local age = globals_realtime() - mark.time
            local current_z = mark.z + (age * 40)
            local sx, sy = renderer_world_to_screen(mark.x, mark.y, current_z)
            
            if age > 1.2 then
                mark.alpha = mark.alpha - 10
            end
            
            if mark.alpha <= 0 then
                table_remove(_hitmarkers_3d, i)
            elseif sx and sy then
                local a = math_max(0, math_floor(mark.alpha))
                renderer_text(sx, sy, c_r, c_g, c_b, math_floor(a * (c_a / 255)), "c-d", 0, "-" .. mark.dmg)
            end
        end
    end
end

local function draw_speclist()
    draw_velocity()
    if menu.vis.speclist:get() then
        local sw, sh = client_screen_size()
        local globals_ft = globals.frametime and globals.frametime() or 0.015
        if speclist_x == nil or speclist_y == nil then
            speclist_x = sw - 160
            speclist_y = 650
        end
        
        local menu_open = ui_is_menu_open()
        if menu_open then
            local mx, my = ui_mouse_position()
            local is_lmb = client_key_state(0x01)
            
            local w = 150
            local base_y = speclist_y + 16
            local dh = 22
            local dw = w
            local dx = speclist_x - dw / 2
            local dy = base_y
            
            local bg_alpha = is_dragging_spec and 40 or 15
            renderer_rectangle(dx, dy, dw, dh, 255, 255, 255, bg_alpha)
            
            if is_lmb then
                if not is_dragging_spec then
                    if mx >= dx and mx <= (dx + dw) and my >= dy and my <= (dy + dh) then
                        is_dragging_spec = true
                        drag_spec_dx = speclist_x - mx
                        drag_spec_dy = speclist_y - my
                    end
                end
            else
                is_dragging_spec = false
            end
            
            if is_dragging_spec then
                speclist_x = mx + drag_spec_dx
                speclist_y = my + drag_spec_dy
            end
        else
            is_dragging_spec = false
        end
        
        local acc_r, acc_g, acc_b, acc_a = menu.vis.accent_color:get()
        local specs = {}
        
        if menu_open then
            table_insert(specs, "player1")
            table_insert(specs, "nigger2")
            table_insert(specs, "loser3")
        else
            local me = entity_get_local()
            local my_target = entity_get_prop(me, "m_hObserverTarget")
            if my_target ~= nil and my_target ~= me then
                me = my_target
            end
            
            local players = entity.get_players(true)
            for i=1, #players do
                local p = players[i]
                if p ~= me and not entity_is_alive(p) then
                    local target = entity_get_prop(p, "m_hObserverTarget")
                    if target == me then
                        local name = entity_get_player_name(p) or "unknown"
                        table_insert(specs, name)
                    end
                end
            end
        end
        
        local target_h = #specs > 0 and (36 + #specs * 18) or 0
        if menu_open and target_h == 0 then target_h = 32 end
        
        speclist_h = lerp(speclist_h, target_h, globals_ft * 12)
        local h = math_floor(speclist_h)
        local w = 150
        
        if h > 2 then
            local base_y = speclist_y + 16
            renderer_rectangle(speclist_x - w/2, base_y, w, h, 25, 25, 25, 190)
            renderer_rectangle(speclist_x - w/2, base_y, w, 2, acc_r, acc_g, acc_b, math_floor(acc_a * 0.9))
            
            local header_a = math_min(255, math_max(0, h * 10 - 20))
            renderer_text(speclist_x, base_y + 11, 230, 230, 230, header_a, "cd", 0, "Spectators")
            
            for i, name in ipairs(specs) do
                local item_y = base_y + 22 + (i - 1) * 18
                if item_y + 14 <= base_y + h then
                    local lx = speclist_x - w/2 + 8
                    
                    local text_a = math_min(255, math_max(0, (base_y + h - item_y) * 15))
                    renderer_text(lx, item_y + 9, 230, 230, 230, text_a, "d", 0, name)
                end
            end
        end
    end
end

local function on_paint()
    draw_molotovs()
    draw_watermark()
    draw_hitlogs()
    draw_crosshair_inds()
    draw_keybinds()
    draw_speclist()
    draw_velocity()
    draw_3d_hitmarkers()
end
local function on_aim_fire(e)
    e.difference = globals_tickcount() - e.tick
    fired_shots[e.id] = e
end

local function on_aim_hit(e)
    if menu.vis.hitmarker_3d:get() then
        local pre = fired_shots[e.id] or {}
        if pre.x and pre.y and pre.z then
            table_insert(_hitmarkers_3d, {
                x = pre.x, y = pre.y, z = pre.z,
                dmg = e.damage,
                time = globals_realtime(),
                alpha = 255
            })
        end
    end
    
    local options = menu.vis.hitlogs:get()
    if #options > 0 then
        local pre = fired_shots[e.id] or {}
        local target_name = entity_get_player_name(e.target) or "unknown"
        local hitgroup = hitgroups[e.hitgroup] or "generic"
        local expected_damage = pre.damage or 0
        local hc = e.hit_chance or pre.hit_chance or 0
        local r, g, b, a = menu.vis.hitlogs_color:get()
        
        local is_mismatch = (expected_damage > 0 and expected_damage - e.damage > 10)
        local log_text = ""
        
        if is_mismatch then
            log_text = string.format("Missmatched %s in %s for %d hp | hc: %d%%", target_name, hitgroup, e.damage, math_floor(hc))
        else
            log_text = string.format("Hit %s in %s for %d hp | hc: %d%%", target_name, hitgroup, e.damage, math_floor(hc))
        end
        
        if pre.difference and pre.difference ~= 0 then log_text = log_text .. string.format(" | bt: %dt", pre.difference) end
        if is_mismatch then log_text = log_text .. string.format(" | exp: %d", expected_damage) end
        
        if has_value(options, "Console") then client_color_log(r, g, b, "[Just Helper] " .. log_text) end
        if has_value(options, "Screen") then
            local screen_text = is_mismatch and string.format("Missmatched %s in %s for %d hp", target_name, hitgroup, e.damage) or string.format("Hit %s in %s for %d hp", target_name, hitgroup, e.damage)
            table_insert(screen_logs, {text = screen_text, time = globals_realtime(), last_realtime = globals_realtime(), alpha = 255, clr = {r, g, b}})
            if #screen_logs > 5 then table_remove(screen_logs, 1) end
        end
    end
    fired_shots[e.id] = nil
end

local function on_aim_miss(e)
    local options = menu.vis.hitlogs:get()
    if #options > 0 then
        local pre = fired_shots[e.id] or {}
        local target_name = entity_get_player_name(e.target) or "unknown"
        local hitgroup = hitgroups[e.hitgroup] or "generic"
        local reason = e.reason or "unknown"
        
        if reason == "prediction error" and pre.difference and pre.difference > 2 then reason = "unpredicted occasion" end
        local hc = e.hit_chance or pre.hit_chance or 0
        local r, g, b, a = menu.vis.misslogs_color:get()
        
        local log_text = string.format("Missed %s's %s due to %s | hc: %d%%", target_name, hitgroup, reason, math_floor(hc))
        if pre.damage then log_text = log_text .. string.format(" | dmg: %d", pre.damage) end
        if pre.difference and pre.difference ~= 0 then log_text = log_text .. string.format(" | bt: %dt", pre.difference) end
        if pre.teleport then log_text = log_text .. " | LC" end
        if pre.extrapolated then log_text = log_text .. " | EP" end
        
        if has_value(options, "Console") then client_color_log(r, g, b, "[Just Helper] " .. log_text) end
        if has_value(options, "Screen") then
            local screen_text = string.format("Missed %s's %s due to %s", target_name, hitgroup, reason)
            table_insert(screen_logs, {text = screen_text, time = globals_realtime(), last_realtime = globals_realtime(), alpha = 255, clr = {r, g, b}})
            if #screen_logs > 5 then table_remove(screen_logs, 1) end
        end
    end
    fired_shots[e.id] = nil
end

local function on_player_death(e)
    local me = entity_get_local()
    local attacker_ent = client_userid_to_ent(e.attacker)
    local victim_ent = client_userid_to_ent(e.userid)
    
    if attacker_ent == me and victim_ent ~= me then 
        jh_stats.kills = jh_stats.kills + 1
        database_write("jh_stats", jh_stats)
        
        if menu.misc.killsay_enable:get() then
            local phrase = killsay_phrases[client_random_int(1, #killsay_phrases)]
            client_exec("say " .. phrase)
        end
    elseif victim_ent == me and attacker_ent ~= me then
        jh_stats.deaths = jh_stats.deaths + 1
        database_write("jh_stats", jh_stats)
    end
end

local function get_weapon_string(me)
    local weapon = entity_get_player_weapon(me)
    if not weapon then return "Other" end
    
    local item_index = bit_band(entity_get_prop(weapon, "m_iItemDefinitionIndex"), 0xFFFF)
    
    if item_index == 40 then return "Scout" end
    if item_index == 9 then return "AWP" end
    if item_index == 11 or item_index == 38 then return "Auto" end
    if item_index == 64 then return "R8" end
    if item_index == 1 then return "Deagle" end
    
    local is_pistol = item_index == 2 or item_index == 3 or item_index == 4 or item_index == 30 or item_index == 32 or item_index == 36 or item_index == 61 or item_index == 63
    if is_pistol then return "Pistols" end
    
    return "Other"
end

local function get_condition_string(me)
    local flags = entity_get_prop(me, "m_fFlags")
    if not flags then return "Stand" end
    
    local in_air = bit_band(flags, 1) == 0
    if in_air then return "Air" end
    
    if ui_get(ref_slow_key) then return "Slow walk" end
    
    local crouch = entity_get_prop(me, "m_flDuckAmount") > 0.5
    local vel_x, vel_y = entity_get_prop(me, "m_vecVelocity")
    if not vel_x then return "Stand" end
    
    local vel = math_sqrt(vel_x*vel_x + vel_y*vel_y)
    local is_moving = vel > 5
    
    if crouch then return is_moving and "Sneaking" or "Crouch" end
    return is_moving and "Moving" or "Stand"
end

local function on_setup_command()
    if not menu.misc.smart_hs:get() then 
        if is_forcing_hs then
            pui_ref_dt:override()
            pui_ref_hs:override()
            ui_set(ref_hs_key, "On hotkey")
            is_forcing_hs = false
        end
        return 
    end
    
    local me = entity_get_local()
    if not me or not entity_is_alive(me) then return end
    
    local cond = get_condition_string(me)
    local weap = get_weapon_string(me)
    
    local force_hs = has_value(menu.misc.smart_hs_conds:get(), cond) and has_value(menu.misc.smart_hs_weaps:get(), weap)
    
    if not force_hs then
        hs_condition_met_time = 0
    elseif hs_condition_met_time == 0 then
        hs_condition_met_time = globals_realtime()
    end
    
    local should_activate = (hs_condition_met_time ~= 0) and (globals_realtime() - hs_condition_met_time >= 0.09)
    
    if should_activate then
        if not is_forcing_hs then
            is_forcing_hs = true
        end
        pui_ref_dt:override(false)
        pui_ref_hs:override(true)
        ui_set(ref_hs_key, "Always on")
    else
        if is_forcing_hs then
            pui_ref_dt:override()
            pui_ref_hs:override()
            ui_set(ref_hs_key, "On hotkey")
            is_forcing_hs = false
        end
    end
end

local function on_paint_ui()
    local text_title = "                  JUST HELPER"
    local time_anim = globals_realtime() * 3
    local acc_r, acc_g, acc_b, acc_a = menu.vis.accent_color:get()
    local colored = ""
    
    for i = 1, #text_title do
        local char = text_title:sub(i, i)
        
        if char == " " then
            colored = colored .. char
        else
            local pct = (math_sin(time_anim + i * 0.3) + 1) * 0.5
            local r = math_floor(acc_r + (100 - acc_r) * pct)
            local g = math_floor(acc_g + (100 - acc_g) * pct)
            local b = math_floor(acc_b + (100 - acc_b) * pct)
            colored = colored .. string.format("\a%02X%02X%02XFF%s", r, g, b, char)
        end
    end
    
    menu.vis.title_label:set(colored)
    
    if ui_tab:get() == "Info" then
        local build_str = ""
        for i = 1, #build do
            local char = build:sub(i, i)
            local pct = (math_sin(time_anim + i * 0.3) + 1) * 0.5
            local cr = math_floor(acc_r + (255 - acc_r) * pct)
            local cg = math_floor(acc_g + (255 - acc_g) * pct)
            local cb = math_floor(acc_b + (255 - acc_b) * pct)
            build_str = build_str .. string.format("\a%02X%02X%02XFF%s", cr, cg, cb, char)
        end
        
        menu.info.version_label:set(string.format("Version: %s (%s\r)", p_version, build_str))
        
        local current_time = jh_stats.time + (globals_realtime() - start_time)
        menu.info.time_label:set(" • Time played: " .. format_time(current_time))
        menu.info.kills_label:set(" • Total kills: " .. jh_stats.kills)
        menu.info.deaths_label:set(" • Total deaths: " .. jh_stats.deaths)
        
        local k = jh_stats.kills
        local d = jh_stats.deaths
        local kd_ratio = (d > 0) and string.format("%.2f", k / d) or (k > 0 and string.format("%.2f", k) or "0.00")
        menu.info.kd_label:set(" • K/D Ratio: " .. kd_ratio)
    end
end

-- set events
client_set_event("net_update_end", on_net_update_end)
client_set_event("pre_render", on_pre_render)
client_set_event("paint", on_paint)
client_set_event("aim_fire", on_aim_fire)
client_set_event("aim_hit", on_aim_hit)
client_set_event("aim_miss", on_aim_miss)
client_set_event("player_death", on_player_death)
client_set_event("setup_command", on_setup_command)
client_set_event("round_start", on_round_start)
client_set_event("paint_ui", on_paint_ui)
client_set_event("shutdown", on_shutdown)

-- PUI SETUP ALWAYS LAST!
local config = pui.setup({ tab = ui_tab, info = menu.info, vis = menu.vis, misc = menu.misc })
