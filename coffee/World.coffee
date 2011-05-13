# Copyright © 2011 Gilbert "payload" Röhrbein
# License: GNU AGPL 3, see also COPYING file

class World
    constructor: (@field) ->
        @objs = []
        @shapes = []
        @timers = []
        @collide =
            rect_rect: @collision_rect_rect
            circle_circle: @collision_circle_circle
        @score = 0
        @laser_sounds = []
        @laser_sound = 0
        @shootdir = new b2Vec2(0, 1)
        @filling = 0.8

    switch_mute: ->
        @laser_sounds = if @laser_sounds.length == 0
        then (new Audio('stuff/laser.ogg') for x in [0...10])
        else []

    inc_score: ->
        @score += 1

    shell_miss: ->
        @score -= 1/5

    in_field: (vec) ->
        f = @field
        vec.x > f[0] && vec.x < field[2] &&
        vec.y > f[1] && vec.y < field[3]

    collision_rect_rect: (a, b) ->
        posa = a.pos
        posb = b.pos
        diff = posb.Copy()
        diff.Subtract(posa)
        distance = diff.Length()
        min_distance = a.size.Length()*0.5 + b.size.Length()*0.5
        if distance < min_distance
            a: a,
            b: b,
            diff: diff,
            distance: distance,
            min_distance: min_distance
        else
            null

    collision_circle_circle: (a, b) ->
        posa = a.pos
        posb = b.pos
        diff = posb.Copy()
        diff.Subtract(posa)
        distance = diff.Length()
        ar = a.radius.x / 2
        br = b.radius.x / 2
        min_distance = ar + br
        if distance < min_distance
            a: a,
            b: b,
            diff: diff,
            distance: distance,
            min_distance: min_distance
        else
            null

    get_collisions: ->
        collide = @collide
        shapes = @shapes
        collisions = []
        for i in [0...shapes.length]
            for j in [i+1...shapes.length]
                a = shapes[i]
                b = shapes[j]
                [a,b] = [b,a] if b.type < a.type
                collision_type = a.type + "_" + b.type
                collide_f = collide[collision_type]
                collision = collide_f?(a, b)
                collisions.push(collision) if collision?
        collisions

    add_obj: (obj) -> @objs.push(obj)
    remove_obj: (obj) -> @objs.splice(@objs.indexOf(obj),1)
    add_shape: (obj) -> @shapes.push(obj)
    remove_shape: (obj) -> @shapes.splice(@shapes.indexOf(obj),1)
    add_timer: (obj) -> @timers.push(obj)
    remove_timer: (obj) -> @timers.splice(@timers.indexOf(obj),1)

    step: (dt) ->
        timer.step?(dt) for timer in @timers
        obj.step?(dt) for obj in @objs[0...@objs.length]

    draw_objs: -> obj.draw?() for obj in @objs
    draw_shapes: (ctx) -> shape.draw?(ctx) for shape in @shapes

