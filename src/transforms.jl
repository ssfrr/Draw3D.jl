export Empty, Translation, Rotation
export translate, rotate

###################
# Empty
###################

# often used as a container or root of a render tree.
type Empty <: Renderable
    children::Array{Renderable}

    Empty() = new(Renderable[])
    Empty(child::Renderable) = new(Renderable[child])
    Empty{T <: Renderable}(children::Array{T}) = new(children)
end


function render(r::Empty, args...)
    for child in r.children
        render(child, args...)
    end
end

####################
# Translation
####################

type Translation <: Renderable
    child::Renderable
    x::GLfloat
    y::GLfloat
    z::GLfloat

    Translation(child::Renderable, x::Real, y::Real, z::Real) = new(child, x, y, z)
end

translate(x::Real, y::Real, z::Real) = m::Renderable -> Translation(m, x, y, z)

function render(t::Translation, args...)
    glPushMatrix()
        glTranslate(t.x, t.y, t.z)
        render(t.child, args...)
    glPopMatrix()
end

####################
# Rotation
####################

type Rotation <: Renderable
    child::Renderable
    w::GLfloat
    x::GLfloat
    y::GLfloat
    z::GLfloat

    Rotation(child::Renderable,
        w::Real, x::Real, y::Real, z::Real) = new(child, w, x, y, z)
end

rotate(w::Real, x::Real, y::Real, z::Real) = m::Renderable -> Rotation(m, w, x, y, z)

function render(r::Rotation, args...)
    glPushMatrix()
        glRotate(r.w, r.x, r.y, r.z)
        render(r.child, args...)
    glPopMatrix()
end
