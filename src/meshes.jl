export Square, Cube


###################
# Square
###################

# a simple 2d square
type Square <: Renderable
    subdiv::GLint

    Square() = new(5)
    Square(subdiv::Integer) = new(subdiv)
end

function render(m::Square, args...)
    flip = :flip_normals in args

    subplane_width = 1 / m.subdiv
    glBegin(GL_QUADS);
    glNormal(0.0, 0.0, flip ? -1.0 : 1.0)
    for x in linspace(-0.5, 0.5-subplane_width, m.subdiv)
        for y in linspace(-0.5, 0.5-subplane_width, m.subdiv)
            glVertex(x, y,  0.0)
            glVertex(x+subplane_width, y,  0.0)
            glVertex(x+subplane_width, y+subplane_width,  0.0)
            glVertex(x, y+subplane_width,  0.0)
        end
    end
    glEnd()
end

###################
# Cube
###################

# a cube takes its renderable and renders it on each of the 6 faces
type Cube <: Renderable
    front::Renderable

    Cube(front::Renderable) = new(front)
    # most of the time people will probably want the boring cube that uses a
    # square for each side
    function Cube(subdiv::Integer)
        front = Square(subdiv) |> translate(0, 0, 0.5)
        new(front)
    end

    Cube() = Cube(5)
end


function render(m::Cube, args...)
    for rot in [0, 90, 180, 270]
        render(m.front |> rotate(rot, 0, 1, 0), args...)
    end

    for rot in [90, 270]
        render(m.front |> rotate(rot, 1, 0, 0), args...)
    end
end
