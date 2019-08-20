# Creating Degree Plans

As mentioned previously, many different degree plans can be created for a given curriculum.  A *curriculum* is a collection of courses containing requisite relationships between them (see [Terminology](@ref)), while a *degree plan* adds a temporal element to a curriculum.  Specifically, a degree plan orders the courses in a curriculum into a collection of successive *terms*: Term 1, Term 2, etc., where a term is considered an academic period (e.g., semester or quarter).  Thus, students following a particular degree plan are expected to complete all of the courses in the first term during the first semester, all of the courses in the second term during the second semester, etc.  The important concept is that if a student completes their degree plan they will earn the degree associated with the curriculum.

Given that we can create many different degree plans for a curriculum, we are interested in finding those plans that best suit the needs and backgrounds of particular students.  For instance, a transfer student with existing college credits will require a different degree plan than a new student who has no prior college credit.  Similarly, a student may not have the background necessary to take the first math course in a curriculum, necessitating the addition of a prerequisite math class as a part of that student's degree plan, etc.

Below we describe a number of different techniques for creating degree plans.  In [Basic Degree Plans](@ref) we describe some simple techniques that can be used to create degree plans that are minimally feasible (feasible degree plans are defined below).

The methods decribed in [Optimized Degree Plans](@ref) are more sophisticated, and make use of optimization techniques that allow you to build in more constraints and objectives as a part of the degree plan construction process.  

## Basic Degree Plans

In order to be considered *minimally feasible*, a degree plan $P$ for a curriculum $C$ must satisfy two conditions:

1. Every course in the curriculum $C$ must appear in one and only one term in the degree plan $P$.  (Note: $P$ may contain courses that are not in $C$.)
2. The requisite relationships between the courses in $P$ must be respected across the terms in $P$.  That is, if course ``a`` is a prerequisite for course ``b`` in the curriculum, then course ``a`` must appear in the degree plan $P$ in an earlier term than course ``b``.

## Optimized Degree Plans

The Curricular Analytics Toolbox also allows you to create customized degree plans according to various user-specifed criteria.  These features make use of the [JuMP](https://github.com/JuliaOpt/JuMP.jl) domain-specific language for specifying optimization problems in Julia, and calls the [Gurobi](https://www.gurobi.com) solver in order to solve the optimzaton problems.  In order to use these features you must first install JuMP and Gurobi.  For installation instructions see [Additional Requirements](@ref) in the Installation section.

A brief overview of how we have structured the degree plan creation process as an optimzation problem is provided next.  Assume a curriculum consisting of $n$ courses is organized over $m$ terms. The degree plan creation process involves a partitioning of the $n$ courses in a curriculum into $m$ disjoint sets. Thus, we can represent a degree plan an $n \times m$ binary-valued assignment matrix $x$, where

```math
  x_{ij} = \left\{
  \begin{array}{ll}
  1; & \text{if course $i$ is assigned to term $j$ in the plan,} \\
  0; & \text{otherwise.}
  \end{array}\right.
```

### Constraints

The two conditions required for a degree plan to be minimally feasible can be expressed in terms of these assignment variables in the form of *constraints*.  The first, which requires that each course be assigned to one and only one term, is:

```math
  \mbox{Constraint 1:} \ \ \sum_{j=1}^m  x_{ij} = 1, \ \ \ \ i = 1 \ldots n.
```

If we let $T_i$ denote the term that course $i$ is assigned to, i.e., $T_i = j \iff x_{ij} = 1$, then the second condition, which requires the assignment to satisfy all requisites, yeilds three constraints depending upon the requisite type.  That is, if course $a$ is a *requisite* for course $b$, then:

```math
  \mbox{Constraint 2 (prerequisite):} \ \ T_a \ < \ T_b, \\
  \mbox{Constraint 3 (co-requisite):} \ \ T_a \ \leq \ T_b, \\
  \mbox{Constraint 4 (strict co-requisite):} \ \ T_a \ = \ T_b. 
```

Note that $T_i$ can be obtained from the assignment matrix using:

```math
 T_i = \sum_{j=1}^m j \cdot x_{ij}. 
```

In order to guide the optimzation algorithms towards reasonable soluations, additional constraints are required.  In partciular, it is necessarey to specify the maximum number of terms you would like the degree plan to contain, denoted $\alpha$, as well as the minimum and maximum  number of credit hours allowed in each term, denoted $\beta$ and $\gamma$ respectively. If we let $c_i$ denote the number of credit hours associated with course $i$, and $\theta_j$ the number of credit hours in term $j$, then

```math
 \theta_j = \sum_{i=1}^n c_i \cdot x_{ij}, \ \ \ \ j = 1, \ldots, m,
```

 and the aforementioned conditions may be expressed as the following constraints:

```math
  \mbox{Constraint 5:} \ \ m \ < \ \alpha , \\
  \mbox{Constraint 6:} \ \theta_j \ \ge \ \beta, \ \ \ \ j = 1, \ldots, m. \\
  \mbox{Constraint 7:} \ \theta_j \ \leq \ \gamma, \ \ \ \ j = 1, \ldots, m.
```

### Objective Functions

A number of different objective functions have been defined for use in creating degree plans optimized around particular criteria.  Furthemore, this toolbox supports a multi-objetive framework, allowing more than one of these objective functions to be simultaneously applied while creating degree plans.  

For a single objective function $f(x)$, the optimzation problem can be stated as:
```math
\min f(x), \\
\mbox{subject to: Constraints} \ \ 1-7.
```

For multiple objective functions $f_1(x), f(_2(x), \ldots$  the mulit-objective optimzation problem can be stated as:
```math
\min \left\{ f_1(x), \ f_2(x), \ldots \right\}, \\
\mbox{subject to: Constraints} \ \ 1-7.
```

The currently supported objective functions are described next.

**Balanced curriculum objective.**  The goal of this objective function is to create degree plans that have roughly the same number of credit hours in every term.  This can be expressed as:

```math
f(x) = \min \left( \sum_{i=1}^m \sum_{j=1}^m \left\vert \theta_i(x) - \theta_j(x)\right\vert \right).
```

which may be rewritten as a linear objective function so that integer linear programming may be applied.

**Requisite distance objective.**  The goal of this objective function is to create degree plans where the pre- and co-requisites for every course $c$ in a curriculum appears as close as possible to the term in which $c$ appears in the degree plan.  Consider a curriculum graph $G = (V,E)$.  The objective function can then be expressed as:

```math
  f(x) = min\left( \left\vert T_j(x) - T_i(x) \right\vert \right) \ \  \forall e = (i,j) \in E.
```

which may be rewritten as a linear objective function so that integer linear programming may be applied.

**Toxic course combination avoidance objective.**  For some students, it is the case that certain courses have a toxic impact on other courses in the curriculum if they are taken together in the same term.  That is, course $a$ has a toxic impact on course $b$ if a student is less likely to pass course $b$ if it is taken in the same term as course $a$.  The goal of this objective function is to schedule courses so that toxic course combinations do not appear in the same term in the degree plan.

Let $-1 \leq \aleph_{ij} \leq 1$ denote the toxic impact that course $i$ has on course $j$ if they are taken together in the same term.  (Note: negative values of $\aleph_{ij}$ actually indicate that course $i$ has a synergistic impact on course $j$.) A quadratic objective function for toxic course avoidance can then be expressed as:

```math
f(x) = \min \left( \sum_{t=1}^m \sum_{i=1}^n \sum_{j=1}^n  \aleph_{ij} \cdot x_{it} \cdot x_{jt} \right).
```

The `optimize_plan` function in the toolbox implements the optimziation problems described above.

```julia
optimize_plan(c::Curriculum, term_count::Int, min_cpt::Int, max_cpt::Int, obj_order::Array{String, 1}; diff_max_cpt::Array{UInt, 1}, fix_courses::Dict, consec_courses::Dict, term_range::Dict, prior_courses::Array{Term, 1})
```

Using the curriculum `c` supplied as input, returns a degree plan optimzed according to the various 
optimization criteria that have been specified as well as the objective functions that have been selected.

If an optimzied plan cannot be constructed (i.e., the constraints are such that an optimal solution is infeasible),
`nothing` is returned, and the solver returns a message indicating that the problems is infeasible.  In these cases,
you may wish to experiment with the constraint values.

#### Arguments

Required: 

- `curric::Curriculum` : the curriculum the degree plan will be created from.
- `term_count::Int` : the maximum number of terms in the degree plan.
- `min_cpt::Int` : the minimum number of credits allowed in each term.
- `max_cpt::Int`: the minimum number of credits allowed in each term.
- `obj_order::Array{String, 1}` : the order in which the objective functions shoud be evaluated.  Allowable strings are:
  + `Balance` : the balanced curriculum objective described above.
  + `Prereq` : the requisite distnace objective described above.
  + `Toxicity` : the toxic course avoidance objective described above.

Keyword:

- `diff_max_cpt::Array{UInt, 1}` :  specify particular terms that may deviate from the `max_cpt` specified previously.
- `fix_courses::Dict(Int, Int)` : specify courses that should be assigned to particular terms in `(course_id, term)` 
    format.
- `consec_courses::Dict(Int, Int)`: specify pairs of courses that should appear in consecutive terms in `(course_id, course_id)` format.
- `term_range::Dict(Int, (Int, Int))` : specify courses that should in a particular range of terms in `(course_id, (low_range, high_range))` format.
- `prior_courses::Array{Term, 1}` : specify courses that were already completed in prior terms.

#### Examples:

```julia-repl
julia> curric = read_csv("path/to/curric.csv")
julia> dp = optimize_plan(curric, 8, 6, 18, ["Balance", "Prereq"])
```

```@raw html
<a href="https://github.com/CurricularAnalytics/CurricularAnalytics.jl/blob/master/src/Optimization.jl" target="_blank">source</a>
```
