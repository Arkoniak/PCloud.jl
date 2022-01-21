abstract type FSNode end
abstract type File <: FSNode end

struct CommonNode
    name::String
    created::String
    modified::String
    thumb::Bool
    ismine::Bool
    isshared::Bool
    id::String
    parentfolderid::Int
    comments::String
    metadata::NamedTuple
end

struct CommonFile
    fileid::Int
    hash::String
    category::Int
    size::Int
    contenttype::String
    icon::String
end

struct Folder <: FSNode
    folderid::Int
    g::CommonNode
    icon::String
    contents::Vector{FSNode}
end

struct Plain <: File
    f::CommonFile
    g::CommonNode
end

struct Document <: File
    f::CommonFile
    g::CommonNode
end

struct Image <: File
    f::CommonFile
    g::CommonNode
    width::Int
    height::Int
end

# TODO: Add necessary fields
struct Video <: File
    f::CommonFile
    g::CommonNode
end

# TODO: Add necessary fields
struct Audio <: File
    f::CommonFile
    g::CommonNode
end

# TODO: Add necessary fields
struct Archive <: File
    f::CommonFile
    g::CommonNode
end

name(x::FSNode) = x.g.name
created(x::FSNode) = x.g.created
modified(x::FSNode) = x.g.modified
thumb(x::FSNode) = x.g.thumb
ismine(x::FSNode) = x.g.ismine
isshared(x::FSNode) = x.g.isshared
id(x::FSNode) = x.g.id
parentfolderid(x::FSNode) = x.g.parentfolderid
comments(x::FSNode) = x.g.comments
metadata(x::FSNode) = x.g.metadata

folderid(x::Folder) = x.folderid

fileid(x::File) = x.f.fileid
size(x::File) = x.f.size
hash(x::File) = x.f.hash
category(x::File) = x.f.category
contenttype(x::File) = x.f.contenttype
icon(x::File) = x.f.icon

isfolder(x::Folder) = true
isfolder(x::File) = false

catname(x::Plain) = "Uncategorized"
catname(x::Image) = "Image"
catname(x::Video) = "Video"
catname(x::Audio) = "Audio"
catname(x::Document) = "Document"
catname(x::Archive) = "Archive"

Base.:length(x::Folder) = length(x.contents)
Base.:iterate(x::Folder) = iterate(x.contents)
Base.:iterate(x::Folder, i::Int) = iterate(x.contents, i)

function CommonNode(x)
    properties = propertynames(x)
    parentfolderid = :parentfolfolderid in properties ? x.parentfolderid : -1
    comments = :comments in properties ? string(x.comments) : ""
    y = []
    for property in propertynames(x)
        property == :contents && continue
        push!(y, property => getproperty(x, property))
    end
    metadata = (; y...)
    CommonNode(x.name, x.created, x.modified, x.thumb, x.ismine, x.isshared, x.id, parentfolderid, comments, metadata)
end

function CommonFile(x)
    CommonFile(x.fileid, string(x.hash), x.category, x.size, x.contenttype, x.icon)
end

function Folder(x, g::CommonNode)
    properties = propertynames(x)
    contents = :contents in properties ? FSNode.(x.contents) : FSNode[]
    Folder(x.folderid, g, x.icon, contents)
end

function Plain(x, g::CommonNode)
    Plain(CommonFile(x), g)
end

function Document(x, g::CommonNode)
    Document(CommonFile(x), g)
end

function Image(x, g::CommonNode)
    Image(CommonFile(x), g, x.width, x.height)
end

function Video(x, g::CommonNode)
    Video(CommonFile(x), g)
end

function Audio(x, g::CommonNode)
    Audio(CommonFile(x), g)
end

function Archive(x, g::CommonNode)
    Archive(CommonFile(x), g)
end

function FSNode(x)
    g = CommonNode(x)
    x.isfolder && return Folder(x, g)
    x.category == 0 && return Plain(x, g)
    x.category == 1 && return Image(x, g)
    x.category == 2 && return Video(x, g)
    x.category == 3 && return Audio(x, g)
    x.category == 4 && return Document(x, g)
    x.category == 5 && return Archive(x, g)
    
    @warn "Unknown category " * string(x.category)
    return Plain(x, g)
end

children(x::Folder) = x.contents
children(x::File) = ()

printnode(io::IO, x::Folder) = print(io, folderid(x), ": " * name(x) * "/")
printnode(io::IO, x::File) = print(io, fileid(x), " (", catname(x), ")", ": ", name(x))

function gettree(client::PCloudClient = OPTS.client; params...)
    if !haskey(params, :folderid)
        params = (; params..., :folderid => 0)
    end
    
    dir = API.listfolder(client; params...)
    return FSNode(dir.metadata)
end

function gettree!(client::PCloudClient, node::Folder; params...)
    dir = API.listfolder(client; :folderid => folderid(node), params...)
    empty!(node.contents)
    if haskey(dir.metadata, :contents)
        for x in dir.metadata.contents
            push!(node.contents, FSNode(x))
        end
    end

    return
end

gettree!(client::PCloudClient, node::File; params...) = nothing

gettree!(nodes::AbstractVector; params...) = gettree!(OPTS.client, nodes; params...)
function gettree!(client::PCloudClient, nodes::AbstractVector; params...)
    for node in nodes
        gettree!(client, node; params...)
    end

    return
end

function search(f, x::FSNode)
    res = FSNode[]
    for node in PreOrderDFS(x)
        f(node) && push!(res, node)
    end

    return res
end
