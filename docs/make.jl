using CompatEntryUtilities
using Documenter

DocMeta.setdocmeta!(CompatEntryUtilities, :DocTestSetup, :(using CompatEntryUtilities); recursive=true)

makedocs(;
    modules=[CompatEntryUtilities],
    authors="Dilum Aluthge and contributors",
    repo="https://github.com/bcbi/CompatEntryUtilities.jl/blob/{commit}{path}#{line}",
    sitename="CompatEntryUtilities.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://bcbi.github.io/CompatEntryUtilities.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/bcbi/CompatEntryUtilities.jl",
)
