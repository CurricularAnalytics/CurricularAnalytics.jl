[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Documentation Status](https://readthedocs.org/projects/ansicolortags/badge/?version=latest)](https://curricularanalytics.github.io/CurricularAnalytics.jl/latest/)
[![Coverage Status](https://coveralls.io/repos/github/CurricularAnalytics/CurricularAnalytics.jl/badge.svg?branch=master)](https://coveralls.io/github/CurricularAnalytics/CurricularAnalytics.jl?branch=master)
[![DOI](https://zenodo.org/badge/147096983.svg)](https://zenodo.org/badge/latestdoi/147096983)
<!--[![Build Status](https://travis-ci.org/CurricularAnalytics/CurricularAnalytics.jl.svg?branch=master)](https://travis-ci.org/CurricularAnalytics/CurricularAnalytics.jl)-->

# CurricularAnalytics.jl
**CurricularAnalytics.jl** is a toolbox for studying and analyzing academic program curricula.  The toolbox represents curricula as graphs, allowing various graph-theoretic measures to be applied in order to quantify the complexity of curricula. In addition to analyzing curricular complexity, the toolbox supports the ability to visualize curricula, to compare and contrast curricula, to create optimal degree plans for completing curricula that satisfy particular constraints, and to simulate the impact of various events on student progression through a curriculum.

## Documentation
Full documentation is available at [GitHub Pages](https://curricularanalytics.github.io/CurricularAnalytics.jl/latest/).
Documentation for functions in this toolbox is also available via the Julia REPL help system.
Additional tutorials can be found at the [Curricular Analytics Notebooks](https://github.com/CurricularAnalytics/CA-Notebooks) site.

# Installation

Installation is straightforward.  First, install the Julia programming language on your computer.  To do this, download Julia here: https://julialang.org, and follow the instructions for your operating system.

Next, open the Julia application that you just installed. It should look similar to the image below. This interface is referred to as the `Julia REPL`.

<img width="800" alt="Screenshot 2022-11-20 at 12 22 55 PM" src="https://user-images.githubusercontent.com/1368490/202916371-ee5cda31-3f76-42ec-be01-bc5044c33587.png">

The toolbox must be loaded via the `using CurricularAnalytics` command every time you restart the Julia REPL.

For more information about installing the toolbox, including the steps neccessary to utilize degree plan optimization, please see the [INSTALLING.md](https://curricularanalytics.github.io/CurricularAnalytics.jl/latest/install.html)

## Supported Versions
* CurricularAnalytics master will be maintained/enhanced to work with the latest stable version of Julia.
* Later versions: Some functionality might not work with older / prerelease / unstable / nightly versions of Julia. If you run into a problem, please file an issue.

# Contributing and Reporting Bugs
We welcome contributions and bug reports! Please see [CONTRIBUTING.md](https://github.com/CurricularAnalytics/CurricularAnalytics.jl/blob/master/CONTRIBUTING.md)
for guidance on development and bug reporting.
