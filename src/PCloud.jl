module PCloud
using HTTP
using JSON3
using SHA
using AbstractTrees
import AbstractTrees: children, printnode

export authorize!, PCloudClient, authtoken, update_endpoints!, reset_endpoints!, useglobally!

# Filesystem tree specific functions
export gettree, fileid, folderid, name, metadata

mutable struct PCloudClient
    apiep::String
    binep::String
    rootep::String
    cookies::Dict{String, String}
end

include("api.jl")
using .API

mutable struct PCloudOpts
    client::PCloudClient
end

include("client.jl")

const OPTS = PCloudOpts(PCloudClient(set_endpoints = false))

include("fs.jl")


end # module
