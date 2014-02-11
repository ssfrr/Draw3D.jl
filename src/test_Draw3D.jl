using Draw3D

disp = GLDisplay(800, 600)
c1 = Cube(1) |> color([1, 0, 0, 1]) |> rotate(30, 0.5, 0.1, 0.9) |> translate(-1, 0, 0)
c2 = Cube(1) |> color([0, 1, 0, 0.5]) |> rotate(70, 0.1, 0.8, 0.2) |> translate(1, 0, 0)
s = Sphere(4) |> color([1, 0, 0, 1]) |> translate(0, 0, 1)
em = Empty([s, c1, c2])
rot_x = 0
rot_z = 0

previous_time = time()
while isopen(disp) && !pressed(KEY_ESC)
    elapsed_sec = time() - previous_time
    previous_time += elapsed_sec
    prepare(disp)
    render(em |> rotate(rot_z, 0, 0, 1) |> rotate(rot_x, 1, 0, 0) |> translate(0, 0, -5))
    swap(disp)
    rot_x += 20 * elapsed_sec
    rot_z += 100 * elapsed_sec
end
close(disp)
