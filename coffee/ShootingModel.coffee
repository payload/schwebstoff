# Copyright © 2011 Gilbert "payload" Röhrbein
# License: GNU AGPL 3, see also COPYING file

class ShootingModel
    constructor: (@world) ->
        @recharge_time = 2.5
        @not_recharged = @recharge_time * Math.random()
        @auto_shoot = true
        @shell_vel = 400
        @shell_group = null

    create_shell: (pos, vel) ->
        shell = new Shell(@world)
        shell.movement.pos.SetV(pos)
        shell.movement.vel.SetV(vel)
        shell.movement.vel_want.SetV(vel)
        shell.movement.vel_max[0] = vel.Length()
        shell.damage.groups.push(@shell_group) if @shell_group != null
        shell

    shoot: (dt, movement) ->
        return null if @not_recharged
        @not_recharged = @recharge_time
        m = movement
        shell_vel = @world.shootdir.Copy()
        shell_vel.Multiply(@shell_vel)
        pos = shell_vel.Copy()
        vel = shell_vel.Copy()
        pos.Normalize()
        pos.Multiply(m.size.Length())
        pos.Add(m.pos)
        vel.Add(m.vel)
        @create_shell(pos, vel)

    step: (dt, movement) ->
        @not_recharged = Math.max(0, @not_recharged - dt)
        @shoot(dt, movement) if @auto_shoot

