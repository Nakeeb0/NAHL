envobjects = {
    ["spike"] = {
        env_actor_update = function(self)
            for act in all(actors) do
                if actor_collision(self, act) then
                    act.vel = (-act.vel*act.bounce)
                    resolve_damage(self, act, 999, 0) --spike always damages the actor
                end
            end
        end,
    }
}