
using Libdl
using CxxWrap

const REPO_URL = "https://github.com/VNNLIB/VNNLIB-CPP.git"
const REPO_DIR = joinpath(@__DIR__, "VNNLIB-CPP")
const BUILD_DIR = joinpath(@__DIR__, "..", "build")


function check_command_available(cmd::String)
    try
        run(`$cmd --version`)
        return true
    catch
        return false
    end
end


@assert check_command_available("cmake") "Please install CMake!"
@assert check_command_available("git") "Please install Git!"
@assert check_command_available("bnfc") "Please install BNFC!"
@assert check_command_available("flex") "Please install Flex!"
@assert check_command_available("bison") "Please install Bison!"


function clone_repo(repo_url::String, dest_dir::String)
    if !isdir(dest_dir)
        println("Cloning repository from $repo_url to $dest_dir")
        run(`git clone --recursive $repo_url $dest_dir`)
    else
        println("Directory $dest_dir already exists, pulling latest changes ...")
        cd(dest_dir) do
            run(`git pull`)
        end
    end
end

clone_repo(REPO_URL, REPO_DIR)

if !isdir(BUILD_DIR)
    mkpath(BUILD_DIR)
end

cd(BUILD_DIR) do
    println("Building VNNLIB-CPP in $BUILD_DIR ...")
    cxx_wrap_prefix = CxxWrap.prefix_path()
    run(`cmake .. -DCMAKE_PREFIX_PATH=$cxx_wrap_prefix`)
    run(`make`)
end


