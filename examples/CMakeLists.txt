# The gallery is the demo *and* the screenshot source for the visual
# regression pass; see README "Демо и скриншоты" for its dev flags.
add_subdirectory(gallery)

# examples/consumer and examples/submodule are deliberately not added here:
# each is a separate project that consumes this one the way an outside
# project would -- one through find_package() against an install tree, the
# other through add_subdirectory(). Configuring them from inside this build
# would defeat the point, so CI configures them on their own.
