push!(LOAD_PATH,"../src/")
using Documenter, ANOVA

makedocs(
    # format = :html,
    sitename = "ANOVA.jl",
    pages = Any[
        "Getting Start" => "index.md",
    ]
)

deploydocs(
    deps   = Deps.pip("mkdocs", "python-markdown-math"),
    repo = "github.com/ZaneMuir/ANOVA.jl.git",
    julia  = "0.6"
)
