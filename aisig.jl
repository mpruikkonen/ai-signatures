#!/home/mipr/julia/julia-d55cadc350/bin/julia
#
# You can update the above path to point to your Julia 0.6 binary
# to run this as an executable script.
#
# It's also possible to include("main.jl") in the Julia REPL,
# after which you can e.g.:
#
# ret = aisig('datafile')
#
# and manipulate the returned data structures in the REPL.

include("main.jl")

function print_help()
    print("""
Usage:
  aisig.jl [OPTION]... input.bed

Options:
  -r, --nmf-runs n        number of parallel nmf runs (default: 1)
  -h, --host host[:port]  run workers on remote host via passwordless ssh
                          instead of on the local machine (identical Julia
                          installation must be present on the remote)
""")
    quit()
end

options = Dict("-h" => "", "-r" => 1)

function parse_cmdline()
    while !isempty(ARGS)
        a = shift!(ARGS)
        if(a[1] != '-')
            options["datafile"] = a
            if !isempty(ARGS)
                print_help()
            end
            return
        end
        if(a == "--nmf-runs" || a == "-r")
            options["-r"] = parse(Int64, shift!(ARGS))
        elseif(a == "--host" || a == "-h")
            options["-h"] = shift!(ARGS)
        elseif a == "--help"
            print_help()
        else
            println("Invalid option '$a'")
            print_help()
        end
    end
    print_help()
end

try
    parse_cmdline()
catch
    print_help()
end

aisig(options["datafile"], host=options["-h"], nmf_runs=options["-r"])
