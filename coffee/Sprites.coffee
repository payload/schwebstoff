# Copyright © 2011 Gilbert "payload" Röhrbein
# License: GNU AGPL 3, see also COPYING file

class Circle
    constructor: (@world, @obj) ->
        m = @obj.movement
        @pos = m.pos
        @radius = m.size
        @rot = m.rot or [0]
        @type = "circle"
        @obj or= null
        @style =
            stroke: [1.0, 0.9, 0.5, 1.0]
            fill: [1.0, 0.9, 0.5, 1.0]
        @world.add_shape(this)

    remove: ->
        @world.remove_shape(this)

    draw: (ctx) ->
        ctx.save()
        pos = @pos
        r = @radius.x / 2
        ctx.translate(pos.x, pos.y)
        ctx.rotate(@rot[0])
        ctx.beginPath()
        ctx.arc(0, 0, r, 0, 2*Math.PI)
        ctx.closePath()
        if @style.fill != null
            ctx.fillStyle = color_to_css(@style.fill)
            ctx.fill()
        if @style.stroke != null
            ctx.strokeStyle = color_to_css(@style.stroke)
            ctx.stroke()
        ctx.restore()

class Rectangle
    constructor: (@world, @obj) ->
        m = @obj.movement
        @pos = m.pos
        @size = m.size
        @rot = m.rot or [0]
        @type = "rect"
        @obj or= null
        @style =
            stroke: [0.5, 0.5, 0.5, 1.0]
            fill: [0.88, 0.88, 0.88, 1.0]
        @world.add_shape(this)

    remove: ->
        @world.remove_shape(this)

    draw: (ctx) ->
        ctx.save()
        pos = @pos
        size = @size
        w = size.x
        h = size.y
        ctx.translate(pos.x, pos.y)
        ctx.rotate(@rot[0])
        ctx.beginPath()
        ctx.rect(-w / 2, -h / 2, w, h)
        ctx.closePath()
        if @style.fill != null
            ctx.fillStyle = color_to_css(@style.fill)
            ctx.fill()
        if @style.stroke != null
            ctx.strokeStyle = color_to_css(@style.stroke)
            ctx.stroke()
        ctx.restore()

