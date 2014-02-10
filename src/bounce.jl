using Draw3D

disp = GLDisplay(800, 600)
c1 = Cube(1) |> color([1, 0, 0, 1]) |> rotate(30, 0.5, 0.1, 0.9) |> translate(-1, 0, 0)
c2 = Cube(1) |> color([0, 1, 0, 0.5]) |> rotate(70, 0.1, 0.8, 0.2) |> translate(1, 0, 0)
em = Empty([c1, c2])

floor = Cube(1) |> color([0.1, 0.1, 0.1, 1])
floor = floor |> rotate(90, 1, 0, 0) |> translate(0, -1, -5)
rot_x = 0
rot_z = 0

while isopen(disp)
    prepare(disp)
    render(em |> rotate(rot_z, 0, 0, 1) |> rotate(rot_x, 1, 0, 0) |> translate(0, 0, -5))
    render(floor)
    swap(disp)
    rot_x += 0.2
    rot_z += 1
end
close(disp)
