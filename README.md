
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Build Status](https://travis-ci.com/heileman/CurricularAnalytics.jl.svg?branch=master)](https://travis-ci.com/heileman/CurricularAnalytics.jl)
[![DOI](https://zenodo.org/badge/147096983.svg)](https://zenodo.org/badge/latestdoi/147096983)

# CurricularAnalytics.jl
**CurricularAnalytics.jl** is a toolbox for studying and analyzing academic program curricula.  The toolbox represents curricula as graphs, allowing various graph-theoretic measures to be applied in order to quantify the complexity of curricula. In addition to analyzing curricular complexity, the toolbox supports the ability to visualize curricula, to compare and contrast curricula, to create optimal degree plans for completing curricula that satisfy particular constraints, and to simulate the impact of various events on student progression through a curriculum. 

## Documentation
Full documentation is available at [GitHub Pages](https://curricularanalytics.github.io/CurricularAnalytics.jl/).
Documentation for functions in this toolbox is also available via the Julia REPL help system.
Additional tutorials can be found at [CurricularAnaltyics](http://curricula.academicdashboards.org).

## Installation
Installation is straightforward.  Enter Pkg mode in the Julia REPL by typing `]`, and then type:
```julia-repl
(v1.0) pkg> add CurricularAnalytics
```

## Supported Versions
* CurricularAnalytics master will be maintained/enhanced to work with the latest stable version of Julia.
* Julia 1.0: CurricularAnalytics v0.2.5 is the last version guaranteed to work with Julia 1.0.
* Later versions: Some functionality might not work with prerelease / unstable / nightly versions of Julia. If you run into a problem, please file an issue.

# Contributing and Reporting Bugs
We welcome contributions and bug reports! Please see [CONTRIBUTING.md](https://github.com/CurricularAnalytics/git/master/CONTRIBUTING.md)
for guidance on development and bug reporting.
