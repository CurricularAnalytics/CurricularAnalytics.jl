using Documenter, CurricularAnalytics

# include contributing, citing and license pages 
cp(normpath(@__FILE__, "../../CONTRIBUTING.md"), normpath(@__FILE__, "../src/contributing.md"); force=true)
cp(normpath(@__FILE__, "../../LICENSE.md"), normpath(@__FILE__, "../src/license.md"); force=true)
cp(normpath(@__FILE__, "../../CITING.md"), normpath(@__FILE__, "../src/citing.md"); force=true)

makedocs(
    modules     = [CurricularAnalytics],
    format      = Documenter.HTML(prettyurls = false, canonical ="https://curricularanalytics.github.io/CurricularAnalytics.jl/latest/"),
    sitename    = "CurricularAnalytics.jl",
    doctest     = true,
    pages       = Any[
        "Getting Started"                           => "index.md",
        "Installing the Toolbox"                    => "install.md",
        "Data Types"                                => "types.md",
        "Reading/Writing Curricula & Degree Plans"  => "persistence.md",
        "Visualizing Curricula & Degree Plans"      => "visualize.md",
        "Metrics"                                   => "metrics.md",
        "Creating Degree Plans"                     => "degreeplans.md",
        #"Simulating Student Flows"                  => "simulating.md",
        "Graph Algorithms"                          => "graph_algs.md",
        "Contributing"                              => "contributing.md",
        "License Information"                       => "license.md",
        "Citing CurricularAnalytics.jl"             => "citing.md"
    ],
    # Use clean URLs, unless built as a "local" build
)

deploydocs(
    repo    = "github.com/CurricularAnalytics/CurricularAnalytics.jl.git",
    target  = "build",
)

#rm(normpath(@__FILE__, "../src/contributing.md"))
#rm(normpath(@__FILE__, "../src/license.md"))