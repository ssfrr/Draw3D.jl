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

    function Sphere(subdivs::Integer)
        # isohedron from the redbook
        const X = .525731112119133606 / 2
        const Z = .850650808352039932 / 2

        # note we transpose to get column vectors
        unique_verts = GLfloat[
            -X 0.0 Z; X 0.0 Z; -X 0.0 -Z; X 0.0 -Z;
            0.0 Z X; 0.0 Z -X; 0.0 -Z X; 0.0 -Z -X;
            Z X 0.0; -Z X 0.0; Z -X 0.0; -Z -X 0.0]'

        # indices into the unique_verts array
        faces = Int[
            12,3,8, 6,3,10, 3,12,10, 12,1,10, 11,2,7,
             7,2,1, 7,1,12, 7,12,8,  11,7,8,  4,11,8,
             4,8,3, 4,3,6,  9,4,6,   11,4,9,  2,11,9,
             2,9,5, 9,6,5,  5,6,10,  5,10,1,  2,5,1]

             # the original redbook indices (reverse order):
            #1,5,2, 1,10,5, 10,6,5, 5,6,9, 5,9,2,
            #9,11,2, 9,4,11, 6,4,9, 6,3,4, 3,8,4,
            #8,11,4, 8,7,11, 8,12,7, 12,1,7, 1,2,7,
            #7,2,11, 10,1,12, 10,12,3, 10,3,6, 8,3,12




        verts = unique_verts[:, faces]
        new(subdivide(verts, subdivs))
    end
    Sphere() = Sphere(1)
end

function render(m::Sphere, args...)
    glBegin(GL_TRIANGLES);
    for i in 1:size(m.vertices, 2)
        # we're making a sphere, so the vertices are also the normals
        glNormal3fv(m.vertices[:, i])
        glVertex(m.vertices[:, i])
    end
    glEnd()
end


# each set of 3 vertices are assumed to define a triangle.
function subdivide{T <: Real}(vertices::Array{T}, n::Integer = 1)
    if n <= 0
        return vertices
    end
    new_verts = zeros(T, 3, size(vertices, 2) * 4)
    mid = zeros(T, 3, 3)
    dest = 1
    for i in 1:3:size(vertices, 2)
        # get the normalized midpoint for each pair of vertices
        mid[:, 1] = mean(vertices[:, [  i, i+1]], 2)
        mid[:, 2] = mean(vertices[:, [i+1, i+2]], 2)
        mid[:, 3] = mean(vertices[:, [i+2, i  ]], 2)
        mid[:, 1] = mid[:, 1] / norm(mid[:, 1]) / 2
        mid[:, 2] = mid[:, 2] / norm(mid[:, 2]) / 2
        mid[:, 3] = mid[:, 3] / norm(mid[:, 3]) / 2
        # make 3 new faces from each input face
        new_verts[:,   dest:dest+ 2] = hcat(vertices[:,   i], mid[:, [1, 3]])
        new_verts[:, dest+3:dest+ 5] = hcat(vertices[:, i+1], mid[:, [2, 1]])
        new_verts[:, dest+6:dest+ 8] = hcat(vertices[:, i+2], mid[:, [3, 2]])
        new_verts[:, dest+9:dest+11] = mid
        dest += 12
    end
    return subdivide(new_verts, n - 1)
end
