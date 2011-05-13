# Copyright © 2011 Gilbert "payload" Röhrbein
# License: GNU AGPL 3, see also COPYING file

class Game
    constructor: (@dom, @bindings) ->
        @canvas = @dom.canvas
        @width = @canvas.width
        @height = @canvas.height
        @world = @create_world()
        @player = @create_player()
        @spawner = @create_spawner()
        @pause = false
        @game_over = false
        @time_factor = 1
        @time_factor_display = false
        @keys = @create_keys()
        @texts = @create_texts()
        @actions = @create_actions()
        @set_bindings()
        @myscore = 0
        @mynick = "Anony Mous"

    create_keys: ->
        up: [87, 75, 38]
        left: [65, 72, 37]
        down: [83, 74, 40]
        right: [68, 76, 39]
        shoot: [16, 32]
        pause: [80]
        mute: [77]
        time_slower: [189]
        time_faster: [187]
        time_normal: [48]

    create_texts: ->
        reload: "Reload with F5 or Ctrl+R to play it again!"
        game_over: "GAME OVER"
        score: (score) ->
            if score == 1 then "#{score} point" else "#{score} points"
        time_factor_display: (tf) ->
            tf = Math.round(tf * 100) / 100
            "#{tf} time"

    create_actions: ->
        up: [
            (dt) => @player.move_up_on(dt),
            (dt) => @player.move_up_off(dt),
            null]
        left: [
            (dt) => @player.move_left_on(dt),
            (dt) => @player.move_left_off(dt),
            null]
        down: [
            (dt) => @player.move_down_on(dt),
            (dt) => @player.move_down_off(dt),
            null]
        right: [
            (dt) => @player.move_right_on(dt),
            (dt) => @player.move_right_off(dt),
            null]
        shoot: [
            => @player.shoot_on(),
            => @player.shoot_off(),
            (dt) => @player.shoot(dt)]
        pause: [null, (=> @switch_pause()), null]
        mute: [null, (=> @world.switch_mute()), null]
        time_slower: [
            => @time_display(true),
            => @time_display(false),
            (dt) => @time_slower(dt)]
        time_faster: [
            => @time_display(true),
            => @time_display(false),
            (dt) => @time_faster(dt)]
        time_normal: [null, ((dt) => @time_normal(dt)), null]

    time_slower: (dt) -> @time_factor *= 1 - 0.5 * dt
    time_faster: (dt) ->
        @time_factor = Math.min(@time_factor * (1 + 0.5 * dt), 16)
    time_normal: (dt) -> @time_factor = 1
    time_display: (b) -> @time_factor_display = b

    set_bindings: ->
        @enable_binding(@keys[x], @actions[x]) for own x of @actions

    disable_player_bindings: () =>
        @disable_bindings( (x) => x not in ['pause', 'mute'] )

    disable_bindings: (filter) =>
        for own y of @actions
            if not filter or filter(y)
                @bindings.disable(x) for x in @keys[y]

    enable_binding: (keys, action) ->
        @bindings.enable.apply(@bindings, [k].concat(action)) for k in keys

    switch_pause: ->
        @pause = !@pause
        if @pause
        then @disable_player_bindings()
        else @set_bindings()

    spawn_position: (s) =>
        x = @width * Math.random()
        y = @height + s
        x = Math.max(Math.min(x, @width - s / 2), s / 2)
        return new b2Vec2(x, y)

    create_some_froth: (count) =>
        for i in [0...count]
            obj = new Bubble(@world)
            m = obj.movement
            m.pos.SetV(@spawn_position(m.size.Length()))
            m.vel.SetV(@world.shootdir)
            m.vel.Multiply(-160 + 40 * Math.random())
            m.vel_want.SetV(m.vel)

    create_spawner: ->
        new Timer(@world, 0.4, =>
            #if (Math.random() < 0.2)
            #    @create_some_enemies(1 + 2 * Math.random())
            if (Math.random() < 0.4)
                @create_some_froth(3 + 3 * Math.random())
        )

    create_player: ->
        player = new DumbUnit(@world)
        s = player.movement.size.Length()
        x = @width / 2 * Math.random()
        x = Math.max(Math.min(x, @width - s / 2), s / 2)
        y = @height * Math.random()
        y = Math.max(Math.min(y, @height - s / 2), s / 2)
        player.damage.regenerate = 0.4
        player.keep_in_field = true
        player.shooting.auto_shoot = false
        player.shooting.recharge_time = 0.05
        player.shooting.shell_vel = 1200
        player.damage.groups.push("player")
        player.shooting.shell_group = "player"
        player.movement.pos.Set(x, y)
        player.show_energy = true
        die = player.damage.die
        player.damage.die = (other) =>
            die(other)
            @game_over = true
            screen = @dom.gameover
            $(screen).css("visibility", "visible")
            @disable_bindings()

        style = [0.8, 0.4, 0.0, 1.0]
        player.sprite.style.stroke = style
        player.sprite.style.fill = style

        player

    fetch_highscore: (score) =>
        # TODO fetch highscore from server
        ###[{
            rank: 0
            nick: undefined
            score: score
            },{
            rank: 1
            nick: "foo"
            score: "some"
        }]
        ###

    push_highscore_entry: (nick, score) =>
        # TODO push highscore entry to server
        #alert(nick, score)

    close: () =>
        if @game_over
            @push_highscore_entry(@mynick, @myscore)

    show_highscore: () =>
        ###
        @myscore = Math.round(@world.score)
        highscore = @fetch_highscore(@myscore)
        { hstable, hsline } = @dom
        $(hstable).empty()
        for { rank, nick, score } in highscore
            line = hsline.clone(true)
            tds = line.children()
            hsrank = tds.filter(".highscore_rank")
            hsnick = tds.filter(".highscore_nick")
            hsscore = tds.filter(".highscore_score")
            hsrank.append("#{rank}.")
            hsnick_input = hsnick.children().filter("input")
            if nick is undefined
                hsnick_input.prop { value: "Anony Mous"}
                mynick = hsnick_input
            else
                hsnick_input.prop { value: nick } # TODO readonly
            hsscore.append("#{score}")
            $(hstable).append(line)
            mynick.focus()
            mynick.change () =>
                @mynick = mynick.html()
        ###

    create_world: ->
        field = [0, 0, @width, @height]
        world = new World(field)
        world

    collision_handler: (dt, coll) ->
        coll.a.obj?.collide?(dt, coll.b, coll)
        coll.b.obj?.collide?(dt, coll.a, coll)

    step: (dt) ->
        return undefined if @pause
        chandler = @collision_handler
        collisions = @world.get_collisions()
        chandler(dt, collision) for collision in collisions
        @world.step(dt)

    draw: (ctx) ->
        create_style: ->
        normal_font = (ctx) ->
            ctx.font = "1em UnifrakturMaguntia"
        big_font = (ctx) ->
            ctx.font = "5em UnifrakturMaguntia"

        ctx.save()

        ctx.save()
        filling = @world.filling
        w = @width
        h = @height
        ctx.beginPath()
        ctx.rect(0, h - h * filling, w, h * filling)
        ctx.closePath()
        ctx.fillStyle = "#FFBE00"
        ctx.fill()
        ctx.restore()

        ctx.lineWidth = 2
        @world.draw_objs()
        @world.draw_shapes(ctx)
        # score
        score = Math.round(@world.score)
        score = @texts.score(score)
        ctx.save()
        normal_font(ctx)
        ctx.fillText(score, 6, 15)
        ctx.restore()
        # time factor display
        if @time_factor_display
            tf = @texts.time_factor_display(@time_factor)
            ctx.save()
            normal_font(ctx)
            ctx.fillText(tf, 6, 40)
            ctx.restore()
        ctx.restore()

