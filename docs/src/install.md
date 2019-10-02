# Installation

Installation is straightforward.  First, install the Julia programming language on your computer.  To do this, download Julia here: https://julialang.org, and follow the instructions for your operating system.

Next, open the Julia application that you just installed. It should look similar to the image below. This interface is referred to as the `Julia REPL`.

![Julia termain](https://s3.amazonaws.com/curricularanalytics.jl/julia-command-line.png)

Next, enter Pkg mode from within Julia by hitting the `]` key, and then type:
```julia-repl
  pkg> add CurricularAnalytics
```
This will install the toolbox, along with the other Julia packages needed to run it. To load and use the toolbox, hit the `backspace` key to return to the Julia REPL. Now type:
```julia-repl
  julia> using CurricularAnalytics
```
The toolbox must be loaded again via `using CurricularAnalytics` every time you restart Julia.

## Additional Requirements

### Jupyter Notebooks

Along with the CurricularAnalytics Toolbox, we've also created a repository for Jupyter Notebooks demonstrating various use cases.

If you'd like to utilize the Jupyter notebooks you should follow the installation instructions here: [Click Here](https://github.com/CurricularAnalytics/CA-Notebooks#how-do-i-run-notebooks-on-my-machine)

### Optimization Functionality

If you plan to use the optimization capabilities built into the degree plan creation functions, you must install the [Gurobi Optimizer](https://www.gurobi.com/downloads/gurobi-optimizer-eula/). Gurobi is a commercial product and requires a license key. However, [academic licenses](https://www.gurobi.com/downloads/end-user-license-agreement-academic/) are available at no cost.

After installing the Gurobi Solver you must run the following command in Pkg mode in the Julia REPL by hitting `]`, and then:
```julia-repl
  pkg> add Gurobi
```
Back in the normal Julia REPL, which can be returned to from Pkg mode by hitting `backspace`, you must know run the following:
```julia-repl
  julia> using Gurobi
```
This final command, `using Gurobi`, should be run every time you restart Julia. No further steps are necessary, and you may now utilize the optimization functionality of the toolbox.

 To load the toolbox and Gurobi at the same time you can run: 
```julia-repl
  julia> using CurricularAnalytics, Gurobi
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