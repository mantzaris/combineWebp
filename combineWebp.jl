using Pkg

function check_and_install_package(package_name)
    if !(package_name in keys(Pkg.project().dependencies))
        try
            Pkg.add(package_name)
        catch err
            println(err)
            println("Error occurred while trying to install the package $package_name.")
        end
    else
        println("Package $package_name is already installed.")
    end
end

check_and_install_package("Images")
check_and_install_package("Glob")

using Images, Glob

default_delay = 50
# Check if a delay argument is provided
delay = length(ARGS) >= 1 ? parse(Int, ARGS[1]) : default_delay

frames_dir = "tmp"
mkpath(frames_dir)

global frame_counter = 0


function extract_frames_from_webp(webp_file, frames_dir)
    global frame_counter
    frame_info = read(`webpmux -info $webp_file`, String)
    num_frames = parse(Int, match(r"Number of frames: (\d+)", frame_info).captures[1])

    for i in 1:num_frames
        frame_counter += 1
        run(`webpmux -get frame $i $webp_file -o $frames_dir/frame_$frame_counter.webp`)
    end
end

function merge_webp_frames(frames_dir, output_file)
    # Get all .webp files in the frames_dir directory
    frame_files = glob("*.webp", frames_dir)

    # Sort frame files numerically
    sorted_frame_files = sort(frame_files, by=f -> parse(Int, match(r"frame_(\d+).webp", f).captures[1]))

    cmd = `img2webp -loop 0 -d $delay -o $output_file`
    append!(cmd.exec, sorted_frame_files)

    run(cmd)
end

function extract_number(filename::String)
    m = match(r"(\d+)", filename)
    return m !== nothing ? parse(Int, m.captures[1]) : 0
end

# Get all WebP files in the directory and sort them numerically
function get_sorted_webp_files(directory::String)
    files = filter(f -> occursin(r"\.webp$", f), readdir(directory))
    return sort(files, by=extract_number)
end

#webp_files = ["petlot01.webp", "petlot14.webp"]
webp_files = get_sorted_webp_files(".")

for file in webp_files
    extract_frames_from_webp(file, frames_dir)
end

merge_webp_frames(frames_dir, "output.webp")

#finale
rm(frames_dir, recursive=true)

# Join the sorted file names into a single string
#frame_files_str = join(sorted_frame_files, " ")

# print(`img2webp -loop 0 -d 100 $frame_files_str -o $output_file`)
# return

#run(`img2webp -loop 0 -d 100 $frame_files_str -o $output_file`)
