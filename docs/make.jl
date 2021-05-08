using CompatEntryUtilities
using Documenter

DocMeta.setdocmeta!(CompatEntryUtilities, :DocTestSetup, :(using CompatEntryUtilities); recursive=true)

makedocs(;
    modules=[CompatEntryUtilities],
    authors="Dilum Aluthge and contributors",
    repo="https://github.com/JuliaRegistries/CompatEntryUtilities.jl/blob/{commit}{path}#{line}",
    sitename="CompatEntryUtilities.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://JuliaRegistries.github.io/CompatEntryUtilities.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/JuliaRegistries/CompatEntryUtilities.jl",
    devbranch="main",
)
