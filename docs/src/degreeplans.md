# Creating Degree Plans

As mentioned previously, many different degree plans can be created for a given curriculum.  A *curriculum* is a collection of courses containing requisite relationships between them (see [Terminology](@ref)), while a *degree plan* adds a temporal element to a curriculum.  Specifically, a degree plan orders the courses in a curriculum into a collection of successive *terms*: Term 1, Term 2, etc., where a term is considered an academic period (e.g., semester or quarter).  Thus, students following a particular degree plan are expected to complete all of the courses in the first term during the first semester, all of the courses in the second term during the second semester, etc.  The important concept is that if a student completes their degree plan they will earn the degree associated with the curriculum.

Given that we can create many different degree plans for a curriculum, we are interested in finding those plans that best suit the needs and backgrounds of particular students.  For instance, a transfer student with existing college credits will require a different degree plan than a new student who has no prior college credit.  Similarly, a student may not have the background necessary to take the first math course in a curriculum, necessitating the addition of a prerequisite math class as a part of that student's degree plan, etc.

Below we describe a number of different techniques for creating degree plans.  In [Basic Degree Plans](@ref) we describe a number of straightforward techniques that can be used to create degree plans that are minimally feasible (feasible degree plans are defined below).

The methods decribed in [Optimized Degree Plans](@ref) are more sophisticated, and make use of optimization techniques that allow you to build in more constraints and objectives as a part of the degree plan construction process.  In order to use these you must install additional Julia optimiztion packages as well as solver.  For installation instructions see ... 

## Basic Degree Plans

In order to be considered *minimally feasible*, a degree plan $P$ for a curriculum $C$ must satisfy two conditions:

1. Every course in the curriculum $C$ must appear in one and only one term in the degree plan $P$.  (Note: $P$ may contain courses that are not in $C$.)
2. The requisite relationships between the courses in $P$ must be respected across the terms in $P$.  That is, if course ``a`` is a prerequisite for course ``a`` in the curriculum, then course ``a`` must appear in the degree plan $P$ in an earlier term than course ``b``.

## Optimized Degree Plans

Assume a curriculum consisting of $n$ courses is organized over $m$ terms. The degree plan creation process involves the partitioning of the $n$ courses in a curriculum into $m$ disjoint sets. Thus, we can represent a degree plan an $n \times m$ binary-valued assignment matrix $x$, where

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

If we let $T_i$ denote the term that course $i$ is assigned to, i.e., $T_i = j \iff x_{ij} = 1$, then the second condition, which requires the assignment to satisfy all requisites, yeilds three constraints depending upon the requisite type.  If course $a$ is a *requisite* for course $b$, then:

```math
  \mbox{Constraint 2 (prerequisite):} \ \ T_a \ < \ T_b, \\
  \mbox{Constraint 3 (co-requisite):} \ \ T_a \ \leq \ T_b, \\
  \mbox{Constraint 4 (strict co-requisite):} \ \ T_a \ = \ T_b. \\
```

Note that $T_i$ can be obtained from the assignment matrix using:

```math
 T_i = sum_{j=1}^m j \cdot x_{ij}.
```

### Objective Functions

Balanced curriculum objective

```math
\min \left( \sum_{i=1}^m \sum_{j=1}^m |T_i - T_j| \right)
```