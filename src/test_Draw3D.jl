using Draw3D

function main()
    disp = GLDisplay(800, 600)
    c1 = Cube(1) |> color([1, 0, 0, 1]) |> rotate(30, 0.5, 0.1, 0.9) |> translate(-1, 0, 0)
    c2 = Cube(1) |> color([0, 1, 0, 0.5]) |> rotate(70, 0.1, 0.8, 0.2) |> translate(1, 0, 0)
    s = Sphere(2) |> color([1, 0, 0, 1]) |> translate(0, 0, 1)
    em = Empty([s, c1, c2])
    rot_x = 0
    rot_z = 0

    previous_time = time()
    frame_count::Int = 0.0
    frame_time::Float32 = 0.0

    while isopen(disp) && !pressed(KEY_ESC)
        elapsed_sec = time() - previous_time
        frame_count += 1
        frame_time += elapsed_sec
        if frame_time > 2
            fps = frame_count / frame_time
            print("$(1 / fps * 1000) ms per frame ($fps fps)\n")
            frame_time = 0
            frame_count = 0
        end

        previous_time += elapsed_sec
        prepare(disp)
        render(em |> rotate(rot_z, 0, 0, 1) |> rotate(rot_x, 1, 0, 0) |> translate(0, 0, -5))
        swap(disp)
        rot_x += 5 * elapsed_sec
        rot_z += 20 * elapsed_sec
    end
    close(disp)
end

main()
