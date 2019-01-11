# Visualizing Curricula and Degree Plans

In order to visualize curricula and degree plans, you must first install [Blink.jl](http://junolab.org/Blink.jl/latest/). For instructions on how to do this, see the [Installation](@ref) section.

## Visualization Functions

```@docs
visualize
```

## Examples
An example curriculum for an electrical engineering program is provided in the `examples` directory of this toolbox.  To visualize this curriculum, execute the following commands:

```julia-repl
julia> curric = read_csv("./examples/UKY_EE_curric.csv")
julia> visualize(curric)
```

This should produce the following window:
![UK EE curriculum](./UK-EE-curric.png)

An example eight-term degree plan for the electrical engineering curriculum shown above is also provided in the `examples` directory of this toolbox. To visualize this degree plan, execute the following commands:

```julia-repl
julia> curric = read_csv("./examples/UKY_EE_plan.csv")
julia> visualize(dp)
```

This should produce the following window:
![UK EE degree plan](./UK-EE-degree-plan.png)

In order to visualize the various metrics associated with this degree plan, simply hover your mouse over a course, as shown below:
![UK EE degree plan metrics](./UK-EE-metrics.png)

To learn more about the metrics displayed in this visualization, see the [Metrics](@ref) section.

