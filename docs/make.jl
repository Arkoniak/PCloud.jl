using PCloud
using Documenter

makedocs(;
    modules=[PCloud],
    authors="Andrey Oskin",
    repo="https://github.com/Arkoniak/PCloud.jl/blob/{commit}{path}#L{line}",
    sitename="PCloud.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Arkoniak.github.io/PCloud.jl",
        siteurl="https://github.com/Arkoniak/PCloud.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Reference API" => "reference.md",
        "Usage examples" => "examples.md",
        "Developer guide" => "developers.md"
    ],
)

deploydocs(;
    repo="github.com/Arkoniak/PCloud.jl",
)
