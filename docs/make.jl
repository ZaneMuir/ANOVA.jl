push!(LOAD_PATH,"../src/")
using Documenter, ANOVA

makedocs(
    format = :html,
    sitename = "ANOVA.jl",
    clean = false,
    pages = Any[
        "Getting Start" => "index.md",
        "Functions" => "API.md"
    ]
)

deploydocs(
    #deps   = Deps.pip("mkdocs", "python-markdown-math"),
    repo = "github.com/ZaneMuir/ANOVA.jl.git",
    target = "build",
    deps = nothing,
    make = nothing,
    julia  = "0.7"
)
