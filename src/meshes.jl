export Square, Cube, Sphere


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

###################
# Sphere
###################

# a sphere created by starting with a Tetrahedron
type Sphere <: Renderable
    vertices::Array{GLfloat}
    faces::Array{Int} # array of index triples into the vertices array

    function Sphere(subdivs::Integer)
        # note we transpose to get column vectors
        vertices = GLfloat[1 1 1; -1 -1 1; -1 1 -1; 1 -1 -1]' ./ norm([1 1 1])
        faces = Int[1 2 4; 1 3 2; 1 4 3; 2 3 4]'
        new(vertices, faces)
    end
    Sphere() = Sphere(1)
end

function render(m::Sphere, args...)
    glBegin(GL_TRIANGLES);
    # iterate through each element of faces, each of which is an index into the
    # vertex array. We don't care about the face order, but we rely on the fact that
    # the vertices for each face are stored in order
    for f in m.faces
        # we're making a sphere, so the vertices are also the normals
        glNormal3fv(m.vertices[:, f])
        glVertex(m.vertices[:, f])
    end
    glEnd()
end
