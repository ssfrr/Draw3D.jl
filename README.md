# Draw3D

## Note - NOT STABLE, NOT USABLE
This is pre-alpha and nothing about it is stable, or sometimes even
functioning.

Draw3D is a package for 3D graphics with a nice Julian API.

It is built on top of the OpenGL.jl and GLFW.jl packages and takes advantage of
the fantastic work they have done wrapping the OpenGL API. Those packages
provide an API that is a direct mapping of the OpenGL C API however, which
isn't particularly user-friendly if you are not already an OpenGL developer.

The main datatypes are Mesh, Light, Material, Transform

## Examples

The simplest possible thing is to render a unit (1x1x1) cube in the default
position, which is with its local origin at the global origin.

    c = Cube()
    display(c)

To make a cube that is twice as large and centered at the origin:

    c = Cube()
    c = scale(c, 2)
    c = translate(c, -1, -1, -1)
    display(c)

As you can see this can get a little verbose. All the transform functions are
also defined for partial application, so you can also use Julia's built-in
composition operator like so:

    Cube() |> scale(2) |> translate(-1, -1, -1) |> display



## Limitations

### Transparent Materials

Transparent objects are assumed to be convex, and are rendered by first
rendering the faces pointing away from the camera and then those pointing
towards. Handling this properly for non-convex meshes requires z-sorting
the faces, which we don't do right now.
