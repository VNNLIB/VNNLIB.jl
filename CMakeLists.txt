cmake_minimum_required(VERSION 3.10)
project(VNNLibJuliaWrapper)

# --------------------------
# Dependencies
# --------------------------

# Find JlCxx (from CxxWrap.jl)
find_package(JlCxx REQUIRED)

# Add the C++ library 
# We can just add it as a subdirectory since it also contains a CMakeLists.txt 
add_subdirectory(deps/VNNLIB-CPP)

# --------------------------
# Julia wrapper library 
# --------------------------

set(WRAPPER_SOURCES src/VNNLib_julia.cpp)

add_library(VNNLib_julia SHARED ${WRAPPER_SOURCES})


# Ensure that the wrapper can see VNNLib headers and JlCxx headers
target_include_directories(VNNLib_julia
    PRIVATE 
        src
        ${JlCxx_INCLUDE_DIRS}
        ${CMAKE_CURRENT_SOURCE_DIR}/deps/VNNLIB-CPP/include 
	    ${CMAKE_CURRENT_SOURCE_DIR}/deps/VNNLIB-CPP/include/util
        ${CMAKE_CURRENT_SOURCE_DIR}/deps/VNNLIB-CPP/src/generated
)

# Link against JlCxx and the C++ library 
target_link_libraries(VNNLib_julia 
    PRIVATE
        JlCxx::cxxwrap_julia
        VNNLib
)

# On *nix: avoid the lib prefix, so Julia can load the shared library directly
set_target_properties(VNNLib_julia PROPERTIES
    PREFIX ""  # yields "VNNLib_julia.so" instead of "libVNNLib_julia.so" 
)
