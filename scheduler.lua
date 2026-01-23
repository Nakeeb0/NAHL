running_update_coroutines = {}
running_draw_coroutines = {}

function add_update_coroutine(func)
    running_update_coroutines[#running_update_coroutines+1] = cocreate(func)
end
function add_draw_coroutine(func)
    running_draw_coroutines[#running_draw_coroutines+1] = cocreate(func)
end

function base_run_coroutines(target_coroutines)
    local i = 1
    while target_coroutines[i] do
        coresume(target_coroutines[i])
        if costatus(target_coroutines[i]) == "dead" then
            target_coroutines[i] = target_coroutines[#target_coroutines]
            target_coroutines[#target_coroutines] = nil
        else
            i += 1
        end
    end
end

function run_update_coroutines()
    base_run_coroutines(running_update_coroutines)
end
function run_draw_coroutines()
    base_run_coroutines(running_draw_coroutines)
end