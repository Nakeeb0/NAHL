-- Define the available powerups (powerup name in small letters)
all_powerups = {
    {
        name = "repair",
        desc = "Heal 1 HP",
        apply = function(p) 
            p.hp = min(p.hp + 1, p.hp_max)
        end,
        is_eligible = function(p)
            return p.hp < p.hp_max 
        end
    },
    {
        name = "sharpen",
        desc = "Damage +0.4",
        apply = function(p) 
            p.damage += 0.4
        end,
        is_eligible = function(p)
            return true
        end

    },
    { 
        --todo: revise the limit
        name = "turbo",
        desc = "acceleration +10%",
        apply = function(p) 
            p.accel = min(p.accel*1.1,0.45) 
        end,
        is_eligible = function(p)
            return false
            -- return p.accel < 0.45
        end
    },
    {
        name = "sturdy",
        desc = "Max HP +1",
        apply = function(p) 
            p.hp_max += 1 
        end,
        is_eligible = function(p)
            return false
        end
    }
    ,
    {
        name = "harder",
        desc = "surprise!!",
        apply = function(p) 
            difficulty += 1
        end,
        is_eligible = function(p)
            return true
        end
    }
    ,
    {
        name = "fat",
        desc = "More mass",
        apply = function(p) 
            p.weight = p.weight+1
        end,
        is_eligible = function(p)
            return false
        end
    }
    ,
    {
        name = "bounce",
        desc = "energy conserving",
        apply = function(p) 
            p.bounce += 0.3 
        end,
        is_eligible = function(p)
            if p.bounce > 0.9 then return false 
            else return true end
        end
    }
}