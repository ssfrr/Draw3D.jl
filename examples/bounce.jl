using Draw3D

# using Float32s for the state caused lots of bad float math issues,
# which is why there are the checks below
immutable State
    pos::Float64
    vel::Float64

    State(pos::Real, vel::Real) = new(pos, vel)
end

const grav = -9.8
const bounce = 0.9

function quad(a::Real, b::Real, c::Real)
    desc = b^2 - 4a*c
    if desc < 0
        info("got descriminant of $desc, clamping to 0")
        desc = 0
    end
    sqdesc = sqrt(desc)
    xp = (-b + sqdesc) / 2a
    xn = (-b - sqdesc) / 2a
    if xp >= 0 && xn <= 0
        return xp
    elseif xp <= 0 && xn >= 0
        return xn
    else
        info("quad got got $xp and $xn, clamping to 0")
        return 0
    end
end

function physicsify(state::State, elapsed)
    test_pos = state.pos + state.vel * elapsed + 0.5grav * elapsed^2
    if test_pos > 0
        return State(test_pos, state.vel + grav * elapsed)
    end
    # looks like an impact
    fall_time = quad(0.5grav, state.vel, state.pos)
    if fall_time <= 0
        # given our previous position and velocity we would have fallen
        # through, but the fall time is 0 which means we must be on the
        # ground
        return State(0, 0)
    end
    rise_time = elapsed - fall_time
    if rise_time < 0
        # in case numerical errors creep in
        rise_time = 0
    end

    impact_vel = state.vel + fall_time * grav
    vel = -impact_vel * bounce + rise_time * grav
    pos = vel / 2 * rise_time
    if pos < 0
        pos = 0
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
        balls[i] = Sphere(2) |> color([rand(), rand(), rand(), 0.7]) |> translate(x*spread, 0.5, z*spread)
        i += 1
    end

    states = [State(rand() * 5 + 1, 0.0) for _ in 1:length(balls)]

    previous_time = time()

    cam_rot = 20
    while isopen(disp) && !pressed(KEY_ESC)
        elapsed_sec = time() - previous_time
        previous_time += elapsed_sec

        balls_ = Renderable[b |> translate(0, states[i].pos, 0) for (i, b) in enumerate(balls)]
        world = Empty(hcat(cubes, balls_))

        prepare(disp)
        render(world |> rotate(cam_rot, 0, 1, 0) |> translate(0, -5, -10) |> rotate(30, 1, 0, 0))
        swap(disp)

        states = map(s -> physicsify(s, elapsed_sec), states)
        cam_rot += 10 * elapsed_sec
    end
    close(disp)
end

run_sim()

