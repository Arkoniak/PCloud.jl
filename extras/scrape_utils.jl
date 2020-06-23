using UrlDownload
using Cascadia
using Cascadia: matchFirst
using Gumbo
using Underscores

const TYPESCONVERT = Dict("string" => "String",
                          "strimg" => "String",
                          "bool" => "Bool",
                          "boolean" => "Bool",
                          "datetime" => "datetime",
                          "int" => "Int",
                          "event" => "event"
                         )

# const SPECIAL_METHODS = Dict("diff" => "pcloud_diff", "stat" => "pcloud_stat")
const SPECIAL_METHODS = Dict()

const endpoint_url = "https://docs.pcloud.com"

pageparser(x) = parsehtml(String(x)).root

function process_name(c)
    name = strip(nodeText(c))
    name = get(SPECIAL_METHODS, name, name)
    name = replace(name, r"\.$" => "")
    (name, "\t"*name*"(client::PCloudClient; kwargs...)")
end

function roll_description(c::HTMLText)
    return c.text
end

mytag(c::HTMLText) = nothing
mytag(c) = tag(c)

function roll_description(c)
    if mytag(c) == :br
        return "\n"
    else
        docstring = ""
        for cc in c.children
            if mytag(cc) == :span
                docstring *= "`" * nodeText(cc) * "`"
            elseif mytag(cc) == :table
                docstring *= extract_table(cc)
            elseif mytag(cc) == :strong
                docstring *= "\n*" * nodeText(cc) * "*"
            else
                docstring *= roll_description(cc)
            end
        end
        if mytag(c) == :p
            docstring *= "\n"
        end
    end

    return docstring
end

function process_descr(c)
    docdesc = roll_description(c)
    return uppercasefirst(docdesc)
end

function process_required(c)
    docstring = "# Arguments\n"
    docstring *= roll_description(c)

    return docstring
end

function process_example(c)
    docstring = "# Output Example\n```\n"
    docstring *= matchFirst(sel"pre", c)[1].text
    docstring *= "```\n"

    docstring = replace(docstring, "\\" => "")

    return docstring
end

function extract_table(c)
    docstring = ""
    rows = matchFirst(sel"tbody", c).children
    for i in 2:length(rows)
        row = rows[i]
        paramname = row[1] |> nodeText |> strip
        desc = row[2]
        paramtypenode = matchFirst(sel"span.single-rounded", desc)
        if !(paramtypenode === nothing)
            paramtype = nodeText(paramtypenode) |> strip
            paramtypenode[1].text = ""
        end
        docstring *= "- `" * paramname
        if !(paramtypenode === nothing)
            if haskey(TYPESCONVERT, paramtype)
                docstring *= "::" * TYPESCONVERT[paramtype]
            else
                @error "Unknown type: " * paramtype
                docstring *= "::" * paramtype
            end
        end
        docstring *= "`: "
        docstring *= nodeText(desc) * "\n"
    end
    
    return docstring
end

function process_output(c)
    docstring = "# Output\n"
    docstring *= roll_description(c)

    return docstring
end

function process_optional(c)
    docstring = "# Optional Arguments\n"
    docstring *= roll_description(c)
    docstring = replace(docstring, "[\\i]" => "")

    return docstring
end

function normalize(docstring)
    docstring = replace(docstring, r"\n+" => "\n")
    docstring = replace(docstring, r" +" => " ")
    docstring = replace(docstring, r"\n$" => "")
    docstring = @_ split(docstring, "\n") |> strip.(__) |> join(__, "\n\n")
    
    return docstring
end

function dl2doc(node, url)
    prev = ""
    docstrings = Dict{String, String}()
    name = ""
    sections = ("Name", "Auth", "Description", "URL", "Required", "Optional", "Output", "Example", "Errors")
    for c in node.children
        if tag(c) == :dt
            prev = nodeText(c)
            if !(prev in sections)
                @error "Unknown field: " * prev
            end
        else
            if prev == "Name"
                name, docs = process_name(c) 
                docstrings[prev] = docs
            elseif prev == "Description"
                docstrings[prev] = normalize(process_descr(c) * "\nSource: " * url * "\n")
            elseif prev == "Required"
                docstrings[prev] = process_required(c) |> normalize
            elseif prev == "Example"
                docstrings[prev] = process_example(c)
            elseif prev == "Output"
                docstrings[prev] = process_output(c) |> normalize
            elseif prev == "Optional"
                docstrings[prev] = process_optional(c) |> normalize
            end
        end
    end
    
    docstring = ""
    for k in sections
        if haskey(docstrings, k)
            docstring *= docstrings[k] * "\n\n"
        end
    end
    docstring = replace(docstring, r"\n+$" => "")

    return (name = Symbol(name), docstring = docstring)
end

function docify_method(url)
    docpage = urldownload(url, parser = pageparser)
    docs = matchFirst(sel"div.dev-content", docpage)
    dl = matchFirst(sel"dl", docpage)

    name, docstring = dl2doc(dl, url)
    @eval @doc "$($docstring)" $name
end

function getseeds()
    seed_url = endpoint_url * "/methods/"
    mask = ["Intro"]
    
    page = urldownload(seed_url, parser = pageparser)
    seeds = @_ matchFirst(sel"div.api-column", page) |> eachmatch(sel"a", __) |>
        map((nodeText(_) => endpoint_url * _.attributes["href"]), __)
    seeds = filter(p -> !(p.first in ["Intro"]), seeds)

    return seeds
end

function get_urls(topic_url)
    page = urldownload(topic_url, parser = pageparser)

    res = @_ matchFirst(sel"div.api-column", page) |> eachmatch(sel"li", __) |> matchFirst.(Ref(sel"a"), __) |> map(nodeText(_) => endpoint_url*_.attributes["href"], __)
    
    return res
end

function extract_docs()
    seeds = getseeds()
    res = []
    for (seed_name, seed_url) in seeds
        topic = (seed_name => [])
        @info "================================"
        @info "Processing topic: " * seed_name
        @info "================================"
        urls = get_urls(seed_url)
        for (method, url) in urls
            @info "Processing " * method
            docpage = urldownload(url, parser = pageparser)
            docs = matchFirst(sel"div.dev-content", docpage)
            dl = matchFirst(sel"dl", docpage)

            name, docstring = dl2doc(dl, url)
            push!(topic.second, (method = method, url = url, name = name, docstring = docstring))
        end
        push!(res, topic)
    end

    return res
end

# function create_methods()
#     seeds = getseeds()
#     open("pcloud_api.jl", "w") do f
#         write(f, "const PCLOUD_API = [\n")
#         for (seed_name, seed_url) in seeds
#             @info "================================"
#             @info "Processing topic: " * seed_name
#             @info "================================"
#             urls = get_urls(seed_url)
#             for (method, url) in urls
#                 @info "Processing " * method
#                 docpage = urldownload(url, parser = pageparser)
#                 docs = matchFirst(sel"div.dev-content", docpage)
#                 dl = matchFirst(sel"dl", docpage)

#                 name, docstring = dl2doc(dl, url)
#                 write(f, "(:" * String(name) * ", \"\"\"\n" * docstring * "\n\"\"\"),\n")
#             end
#         end
#         write(f, "]")
#     end
# end

function build_methods(docs, dev = false)
    filepath = dev ? "pcloud_api.jl" : joinpath(@__DIR__, "..", "src", "pcloud_api.jl")

    open(filepath, "w") do f
        write(f, "const PCLOUD_API = [\n")
        for (topic_name, methods) in docs
            for method in methods
                write(f, "(:" * String(method.name) * ", \"\"\"\n" * method.docstring * "\n\"\"\"),\n")
            end
        end
        write(f, "]")
    end
end

const REFERENCE_PREAMBULE = """
```@meta
CurrentModule = PCloud
```

# API Reference
"""

function build_reference(docs, dev = false)
    filepath = dev ? "reference.md" : joinpath(@__DIR__, "..", "docs", "src", "reference.md")

    open(filepath, "w") do f
        write(f, REFERENCE_PREAMBULE)
        for (topic_name, methods) in docs
            write(f, "## " * topic_name * "\n\n")
            index = String[]
            methodsdocs = String[]
            for method in methods
                push!(index, "* [`PCloud." * String(method.name) * "`](@ref)")
                mdoc = "**API documentation source**: [" * method.url * "](" * method.url * ")\n"
                mdoc *= "```@docs\n" * String(method.name) * "\n```\n"
                push!(methodsdocs, mdoc)
            end
            indexdoc = join(index, "\n")
            methodsdoc = join(methodsdocs, "\n")
            write(f, indexdoc) 
            write(f, "\n\n")
            write(f, methodsdoc)
        end
    end
end
