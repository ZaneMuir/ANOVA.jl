# ANOVA.jl
[![Build Status](https://travis-ci.org/ZaneMuir/ANOVA.jl.svg?branch=master)](https://travis-ci.org/ZaneMuir/ANOVA.jl)

### Getting Started
#### Install
for julia 0.7 or 1.0, in julia REPL: `] add https://www.github.com/ZaneMuir/ANOVA.jl.git` or

```julia
using Pkg
Pkg.add("https://www.github.com/ZaneMuir/ANOVA.jl.git")
```

julia 0.6 is not tested.

see [Example.ipynb](https://github.com/ZaneMuir/ANOVA.jl/blob/master/src/Examples.ipynb)

### including
- one-way ANOVA: `ANOVA.anova`
- two-way ANOVA: `ANOVA.anova2`
- one-way repeated measures ANOVA: `ANOVA.rm_anova`
- two-way repeated measures ANOVA: `ANOVA.rm_anova2`

### TODO
- unbalanced ANOVA
- type II and type III two way ANOVA
