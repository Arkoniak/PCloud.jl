using Pkg

Pkg.activate(".")
include("scrape_utils.jl")

docs = extract_docs()

build_reference(docs)
build_methods(docs)
