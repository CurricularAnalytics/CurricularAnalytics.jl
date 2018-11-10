using Documenter, CurricularAnalytics

# include contributing, citing and license pages 
cp(normpath(@__FILE__, "../../CONTRIBUTING.md"), normpath(@__FILE__, "../src/contributing.md"); force=true)
cp(normpath(@__FILE__, "../../LICENSE.md"), normpath(@__FILE__, "../src/license.md"); force=true)
cp(normpath(@__FILE__, "../../CITING.md"), normpath(@__FILE__, "../src/citing.md"); force=true)

makedocs(
    modules     = [CurricularAnalytics],
    format      = :html,
    sitename    = "CurricularAnalytics.jl",
    doctest     = true,
    pages       = Any[
        "Getting Started"                           => "index.md",
        "Installing the Toolbox"                    => "install.md",
        "Data Types"                                => "types.md",
        "Reading/Writing Curricula & Degree Plans"  => "persistence.md",
        "Visualizing Degree Plans"                  => "plotting.md",
        "Curricular Metrics"                        => "metrics.md",
        "Optimizing Degree Plans"                   => "optimizing.md",
        "Simulating Student Flows"                  => "simulating.md",
        "Contributing"                              => "contributing.md",
        "License Information"                       => "license.md",
        "Citing CurricularAnalytics"                => "citing.md"
    ],
    # Use clean URLs, unless built as a "local" build
    # html_prettyurls = false,       #!("local" in ARGS),
    # html_canonical = "https://juliadocs.github.io/Documenter.jl/stable/", # location of stable documentation site
)

deploydocs(
    repo    = "github.com/heileman/CurricularAnalytics.jl.git",
    target  = "build",
)