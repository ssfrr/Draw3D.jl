using Draw3D

immutable State
    pos::Float32
    vel::Float32
end

const grav = -9.8

function physicsify(state::State, elapsed)
    vel = state.vel + grav * elapsed
    pos = state.pos + vel * elapsed
    if pos - 0.5 <= 0 && vel < 0
        vel = -vel * 0.9
        pos = 0.5
    end

    return State(pos, vel)
end


function run_sim()
    disp = GLDisplay(800, 600)

    cubes = Array(Renderable, 49)
    balls = Array(Renderable, 49)
    i = 1
    spread = 1.3
    # back to front, so transparency works!
    for z in -3:3, x in -3:3
        cubes[i] = Cube() |> color([0, 1, 0, 1])|> translate(x*spread, -0.5, z*spread)
        balls[i] = Sphere(2) |> color([rand(), rand(), rand(), 0.7]) |> translate(x*spread, 0, z*spread)
        i += 1
    end

    states = [State(rand() * 5 + 1, 0) for _ in 1:length(balls)]

    previous_time = time()

    while isopen(disp) && !pressed(KEY_ESC)
        elapsed_sec = time() - previous_time
        previous_time += elapsed_sec

        balls_ = Renderable[b |> translate(0, states[i].pos, 0) for (i, b) in enumerate(balls)]
        world = Empty(hcat(cubes, balls_))

        prepare(disp)
        render(world |> rotate(20, 0, 1, 0) |> translate(0, -5, -10) |> rotate(30, 1, 0, 0))
        swap(disp)

        states = map(s -> physicsify(s, elapsed_sec), states)
    end
    close(disp)
end

run_sim()

