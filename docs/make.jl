using Documenter
#include("../src/CurricularAnalytics.jl")
using CurricularAnalytics

# same for contributing and license
#cp(normpath(@__FILE__, "../../CONTRIBUTING.md"), normpath(@__FILE__, "../src/contributing.md"); force=true)
#cp(normpath(@__FILE__, "../../LICENSE.md"), normpath(@__FILE__, "../src/license.md"); force=true)
#cp(normpath(@__FILE__, "../../CITING.md"), normpath(@__FILE__, "../src/citing.md"); force=true)

makedocs(
    modules     = [CurricularAnalytics],
    format      = :html,
    sitename    = "CurricularAnalytics.jl",
    doctest     = true,
    pages       = Any[
        "Getting Started"                           => "index.md",
        "CurricularAnalytics Data Types"            => "types.md",
        "Creating Curricula"                       => "curriculum.md",
        "Creating Degree Plans"                     => "degreeplan.md",
        "Reading/Writing Curricula & Degree Plans"  => "persistence.md",
        "Visualizing Degree Plans"                  => "plotting.md",
        "Curricular Metrics"                        => "metrics.md",
        "Optimizing Degree Plans"                   => "optimizing.md",
        "Simulating Student Flows"                  => "simulating.md",
#        "Contributing"                              => "contributing.md",
        "Developer Notes"                           => "developing.md",
#        "License Information"                       => "license.md",
#        "Citing CurricularAnalytics"                => "citing.md"
    ]
)

deploydocs(
    deps        = nothing,
    make        = nothing,
    repo        = "github.com/heileman/CurricularAnalytics.jl.git",
    target      = "build",
    julia       = "nightly",
    osname      = "linux"
)

#rm(normpath(@__FILE__, "../src/contributing.md"))
#rm(normpath(@__FILE__, "../src/license.md"))