# CurricularAnalytics.jl Data Types

This section describes the basic data types associated with the CurricularAnalytics.jl toolbox. These are used to construct courses (with associated learning outcomes), curricula and degree plans.

## Courses

```@docs
Course
```

Once a course has been created, requisites may be added to it, or deleted from it, using the following functions.

```@docs
add_requisite!
delete_requisite!
```

Just like courses, learning outcomes can have requisite relationships between them.

## Learning Outcomes

```@docs
LearningOutcome
```

## Curricula

To create a curriculum from a collection of courses, and their associated requisites, use:

```@docs
Curriculum
```

The following function can be used to ensure that a constructed curriculum is valid.

```@docs
is_valid
```

## Terms

```@docs
Term
```

## Degree Plans

To create a degree plan that satisfies the courses associated with a particular curriculum use:

```@docs
DegreePlan
```

The following function can be used to ensure that a constructed degree plan is valid.

```@docs
is_valid
```

To find the term where a given course is located within a degree plan use:

```@docs
find_term
```

To see the terms and courses associated with a degree plan use:

```@docs
print_plan
```

The ability to create degree plans that satsify very "goodness" criteria is described in more detail in [Creating Degree Plans](@ref).

A sophisticated visualization capability for viewing degree plans is described in [Visualizing Curricula and Degree Plans](@ref).

![Basket Weaving degree plan](./BW-plan.png)