# Installation

Installation is straightforward.  Enter Pkg mode in the Julia REPL by typing `]`, and then type:
```julia-repl
pkg> add CurricularAnalytics
```

The CurricularAnalytics.jl toolbox contains sophisticated visualization capabilities. In order to use them, you must first install the [Blink.jl](http://junolab.org/Blink.jl/latest/) package.  Blink.jl is a Julia wrapper that leverages the [Electron](https://electronjs.org) framework to perform the actual visualizations. Blink.jl should install automatically when you install the CurricularAnalytics.jl toolbox, and Electron will also install automatically upon first use of the visualization functions.

## Additional Requirements

If you plan to use the optimization capabilities built into the degree plan creation functions, you must install the [Gurobi Optimizer](https://www.gurobi.com/downloads/gurobi-optimizer-eula/). Gurobi is a commercial product, and requires a license key. However, [academic licenses](https://www.gurobi.com/downloads/end-user-license-agreement-academic/) are available at no cost.

After installing the Gurobi Solver you must run the following command in the Julia REPL by typing `]`, and then:
```julia-repl
pkg> add Gurobi
```

## Windows Specific Steps
If you are using Windows you must add the location of Julia to your PATH environment variable. To do this go to Control Panel -> System -> Advanced System Settings -> Environment Variables -> Path and click edit. Here you must append the file path of the Julia \bin directory.

If you are using Julia version 1.0.1 with default settings the path would be `C:\Users\[YOUR USERNAME]\AppData\Local\Julia-1.0.1\bin`

## Troubleshooting

Following these steps should allow you to install and use the toolbox; however, in the event you experience an error of some type, please submit an issue by clicking [this link](https://github.com/heileman/CurricularAnalytics.jl/issues/new) and following these steps:

1. Enter a short title that describes the issue you're experiencing.
2. Provide any relevant logs and information in the larger comment section.
3. Click the word `labels` to the right of the comment box and select the most relevant option.
4. Click Submit new issue.