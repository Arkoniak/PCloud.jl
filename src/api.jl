module API

using PCloud
# import ..PCloud: PCloudClient, OPTS, PCloudError
using ..PCloud: HTTP, JSON3

include("pcloud_api.jl")

pushfiles!(body, file) = push!(body, :files => file)
function pushfiles!(body, file::Pair)
    push!(body, :files => HTTP.Multipart(file.first, ioify(file.second)))
end
function pushfiles!(body, file::AbstractString)
    push!(body, :files => open(file, "r"))
end
function pushfiles!(body, files::AbstractVector)
    for file in files
        pushfiles!(body, file)
    end
end

ioify(elem::IO) = elem
ioify(elem) = IOBuffer(elem)
function ioify(elem::IOBuffer)
    seekstart(elem)
    return elem
end

function query(client::PCloud.PCloudClient, method, params)
    response = if haskey(params, :files)
        body = Pair[]
        for (k, v) in params
            k == :files && continue
            # We need strings in multipart. Fortunately all parameters other then
            # `files` should transform to String straightforwardly. But it is of
            # course one of the possible source of errors.
            push!(body, k => string(v))
        end
        pushfiles!(body, params[:files])
    uri = client.apiep * method
        HTTP.post(uri, ["Connection" => "Keep-Alive"], HTTP.Form(body); cookies = client.cookies)
    else
    uri = client.apiep * method * "?" * HTTP.URIs.escapeuri(params)
        HTTP.get(uri, ["Connection" => "Keep-Alive"]; cookies = client.cookies)
    end
    res = JSON3.read(String(response.body))
    if res.result == 0
        return res
    else
        throw(PCloud.PCloudError(res))
    end
end

for (f, fdoc) in PCLOUD_API
    @eval begin
        $f(client::PCloud.PCloudClient = PCloud.OPTS.client; kwargs...) = query(client, String(Symbol($f)), Dict(kwargs))
        @doc $fdoc $f
        export $f
    end
end

end # module
