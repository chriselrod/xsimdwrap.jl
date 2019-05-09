using Documenter, xsimdwrap

makedocs(;
    modules=[xsimdwrap],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/chriselrod/xsimdwrap.jl/blob/{commit}{path}#L{line}",
    sitename="xsimdwrap.jl",
    authors="Chris Elrod",
    assets=[],
)

deploydocs(;
    repo="github.com/chriselrod/xsimdwrap.jl",
)
