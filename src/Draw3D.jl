# we're using old-school OpenGL here. Mostly because it's what I've used before
global const OpenGLver="1.0"

module Draw3D

###################
# Imports
###################

import GLFW
using OpenGL
# not sure why this doesn't get exported when I pull in OpenGL like it does
# from the REPL
using OpenGLStd
using GLU

###################
# Exports
###################

export GLDisplay, Renderable
export prepare, swap, isopen, render, close

# re-export from GLFW
pressed = GLFW.GetKey
export pressed
include("keyexports.jl")

###################
# Abstract Types
###################

# Renderable subtypes should implement a render function that uses the OpenGL
# calls to render the mesh at the origin and at unit scale
abstract Renderable

###################
# Modules
###################

include("transforms.jl")
include("meshes.jl")
include("materials.jl")

##############################
# Exported Types and Methods
##############################

type GLDisplay
    render_root::Renderable

    function GLDisplay(width::Number=640, height::Number=480;
                       alphabuf=true, depthbuf=true, stencilbuf=true,
                       fullscreen=false, title="Draw3D")
        global _glfw_init
        if ! _glfw_init
            info("Initializing GLFW...")
            GLFW.Init()
            _glfw_init = true
        end
        # set up anti-aliasing to smooth the edges
        GLFW.OpenWindowHint(GLFW.FSAA_SAMPLES, 4)
        GLFW.OpenWindow(width, height, 0, 0, 0,
                        alphabuf ? 8 : 0,
                        depthbuf ? 24 : 0,
                        stencilbuf ? 8 : 0,
                        fullscreen ? GLFW.FULLSCREEN : GLFW.WINDOW)
        GLFW.SetWindowTitle(title)
        GLFW.Enable(GLFW.STICKY_KEYS);
        init_gl(width, height)

        new(Empty())
   end
end

function isopen(disp)
    GLFW.GetWindowParam(GLFW.OPENED)
end

function prepare(disp::GLDisplay)
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    # DEBUG
    glColor(1.0, 1.0, 1.0, 1.0)
    # reset the current Modelview matrix
    glLoadIdentity()
end

function swap(disp::GLDisplay)
    GLFW.SwapBuffers()
end

function close(disp::GLDisplay)
    global _glfw_init
    GLFW.CloseWindow()
    info("Terminating GLFW")
    GLFW.Terminate()
    _glfw_init = false
end

#######################
# Global Data
#######################

_glfw_init = false

#######################
# Internal Functions
#######################

function init_gl(width::Number, height::Number)
    aspect_ratio = width / height

    # first configure the camera perspective
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity()
    gluPerspective(45.0, aspect_ratio, 0.1, 100.0)

    glMatrixMode(GL_MODELVIEW)

    glShadeModel(GL_SMOOTH)
    glEnable(GL_BLEND)
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
    glEnable(GL_CULL_FACE)
    #  Really Nice Perspective Calculations
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)

    # white background
    glClearColor(1.0, 1.0, 1.0, 1.0)
    glEnable(GL_DEPTH_TEST)
    glDepthFunc(GL_LEQUAL)
    glClearDepth(1.0)
    glEnable(GL_LIGHTING)
    #glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

    # scene init stuff, should be moved
    glEnable(GL_LIGHT0)
    glLightfv(GL_LIGHT0, GL_POSITION, GLfloat[1, 1, 1, 1])
end

end # module
