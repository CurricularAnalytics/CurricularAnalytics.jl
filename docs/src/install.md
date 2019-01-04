# Installation

To install the toolbox open the Julia REPL and run the following:

```julia-repl
julia> using Pkg
julia> Pkg.add("CurricularAnalytics")
```

Next we will use the `Blink` package to download and build `Electron`. This is neccessary for visualizations to function.

```julia-repl
julia> using Blink
julia> Blink.AtomShell.install()
```

## Troubleshooting

Following these steps should allow you to install and use the toolbox. However, in the event you're experiencing an error of some kind you can submit an issue by clicking [this link](https://github.com/heileman/CurricularAnalytics.jl/issues/new) and following these steps:

1. Enter a short title that describes the issue you're experiencing
2. Provide any relevant logs and information in the larger comment section
3. Click the word `labels` to the right of the comment box and select the most relevant option
4. Click Submit new issue