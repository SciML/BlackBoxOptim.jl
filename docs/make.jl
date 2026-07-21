using Documenter
using BlackBoxOptim

makedocs(;
    sitename = "BlackBoxOptim.jl",
    modules = [BlackBoxOptim],
    checkdocs = :exports,
    pages = [
        "Public API" => "index.md",
    ],
)
