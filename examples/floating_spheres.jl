using Draw3D

function main()
    disp = GLDisplay(800, 600)
    ss = Renderable[Sphere(2) for _ in 1:100]
    ss = map(ss) do s
        s = s |> color([rand(), rand(), rand(), 1])
        s |> translate(((rand(3) - 0.5) * 15)...)
    end
    xrot = zeros(length(ss))
    xrot_vel = rand(length(ss)) * 20 - 10
    zrot = zeros(length(ss))
    zrot_vel = rand(length(ss)) * 20 - 10

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
        ssrot = [(s |> rotate(zr, 0, 0, 1) |> rotate(xr, 1, 0, 0) |> translate(0, 0, -15))
                    for (s, xr, zr) in zip(ss, xrot, zrot)]
        for s in ssrot
            render(s)
        end

        swap(disp)
        xrot[:] += xrot_vel * elapsed_sec
        zrot[:] += zrot_vel * elapsed_sec
    end
    close(disp)
end

main()
