# Installation

Installation is straightforward.  Enter Pkg mode in the Julia REPL by typing `]`, and then type:
```julia-repl
(v1.0) pkg> add CurricularAnalytics
```

The CurricularAnalytics.jl toolbox contains sophisticated visualization capabilities. In order to use them, you must first install the [Blink.jl](http://junolab.org/Blink.jl/latest/) package.  Blink.jl is a Julia wrapper that leverages the [Electron](https://electronjs.org) framework to perform the actual visualizations. Blink.jl should install automatically when you install the CurricularAnalytics.jl toolbox, and Electron will also install automatically upon first use of the visualization functions.

## Troubleshooting

Following these steps should allow you to install and use the toolbox; however, in the event you experience an error of some type, please submit an issue by clicking [this link](https://github.com/heileman/CurricularAnalytics.jl/issues/new) and following these steps:

1. Enter a short title that describes the issue you're experiencing.
2. Provide any relevant logs and information in the larger comment section.
3. Click the word `labels` to the right of the comment box and select the most relevant option.
4. Click Submit new issue.