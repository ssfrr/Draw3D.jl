export Material
export color

################
# Material
################

type Material <: Renderable
    child::Renderable
    rgba::Array{GLfloat}

    Material{T <: Real}(child::Renderable, rgba::Array{T}) = new(child, rgba)
end

function render(mat::Material, args...)
    # assuming we're using lighting, so ignore glColor
    # TODO: only set material if need be (track GL state)
    glMaterialfv(GL_FRONT, GL_AMBIENT, mat.rgba * 0.1)
    glMaterialfv(GL_FRONT, GL_DIFFUSE, mat.rgba)
    glMaterialfv(GL_FRONT, GL_SPECULAR, GLfloat[0.4, 0.4, 0.4, 1.0])
    glMaterialfv(GL_FRONT, GL_SHININESS, GLfloat[50.0])
    # if this is transparent, render the back faces then the front faces
    if mat.rgba[4] < 1.0
        glCullFace(GL_FRONT)
        render(mat.child, :flip_normals, args...)
        glCullFace(GL_BACK)
    end
    render(mat.child, args...)
end

color{T <: Real}(rgba::Array{T}) = m::Renderable -> Material(m, rgba)
