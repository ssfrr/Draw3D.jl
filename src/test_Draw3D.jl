using Draw3D

disp = GLDisplay()
c1 = Cube(1) |> rotate(30, 0.5, 0.1, 0.9) |> translate(-2, 0, 0)
c2 = Cube(1) |> rotate(70, 0.1, 0.8, 0.2) |> translate(2, 0, 0)
em = Empty([c1, c2])
rot = 0

while isopen(disp)
    prepare(disp)
    render(em |> rotate(rot, 0, 0, 1) |> translate(0, 0, -6))
    swap(disp)
    rot += 1
end
close(disp)
