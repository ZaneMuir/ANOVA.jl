
<a id='Functions-1'></a>

# Functions



- [Functions](API.md#Functions-1)
    - [One-factor Designs](API.md#One-factor-Designs-1)
    - [Fully replicated factorial designs](API.md#Fully-replicated-factorial-designs-1)
    - [Repeated-measures designs](API.md#Repeated-measures-designs-1)


---


<a id='One-factor-Designs-1'></a>

## One-factor Designs

<a id='ANOVA.anova' href='#ANOVA.anova'>#</a>
**`ANOVA.anova`** &mdash; *Function*.



One-way ANOVA

Syntax:

  * `RESULT, _F, _p = anova(Y::Array{T, 2}; preview::Bool) where {T <: Number}`
  * `RESULT, _F, _p = anova(Y::Array{T, 1}, F::Array{D, 1}; preview::Bool) where {T <: Number, D<:Integer}`

Arguments:

  * `Y`: data set in 1d vector, or 2d matrix, columns as treatments and rows as observations
  * `F`: corresponding factor markers, as `Array{Integer, 1}`

Keywords:

  * `preview`: print anova table [default: `true`]

Returns:

  * ANOVA Result
  * F statistic
  * p value


<a target='_blank' href='https://github.com/ZaneMuir/ANOVA.jl/blob/1a6a2221e5a44a7cfba8a24870a56c88220cefe6/src/one_factor_designs.jl#L9-L27' class='documenter-source'>source</a><br>


<a id='Fully-replicated-factorial-designs-1'></a>

## Fully replicated factorial designs

<a id='ANOVA.anova2' href='#ANOVA.anova2'>#</a>
**`ANOVA.anova2`** &mdash; *Function*.



Two-way ANOVA

Syntax:

  * `Result = anova2(Y::Array{T, 1}, A::Array{D, 1}, B::Array{D, 1};names=(:A, :B), preview::Bool=true) where {T <: Number, D <: Integer}`

Arguments:

  * `Y`: data set in 1d vector
  * `A`: corresponding factor A marker, as Array{Integer, 1}
  * `B`: corresponding factor B marker, as Array{Integer, 1}

Keywords:

  * `names`: the name of the factor [default: `(:A, :B)`]
  * `preview`: print anova table [default: `true`]

Return:

  * ANOVA Result


<a target='_blank' href='https://github.com/ZaneMuir/ANOVA.jl/blob/1a6a2221e5a44a7cfba8a24870a56c88220cefe6/src/two_factor_designs.jl#L7-L25' class='documenter-source'>source</a><br>


<a id='Repeated-measures-designs-1'></a>

## Repeated-measures designs

<a id='ANOVA.rm_anova' href='#ANOVA.rm_anova'>#</a>
**`ANOVA.rm_anova`** &mdash; *Function*.



One-way Repeated Measures ANOVA

Syntax:

  * `RESULT, _F, _p = rm_anova(Y::Array{T, 1}, S::Array{D, 1}, F::Array{D, 1};name::Symbol=:F, preview::Bool=true) where {T <: Number, D <: Integer}`

Arguments:

  * `Y`: data set in 1d vector
  * `S`: corresponding subject marker, as Array{Integer, 1}
  * `F`: corresponding factor marker, as Array{Integer, 1}

Keywords:

  * `name`: the name of the factor [default: `:F`]
  * `preview`: print anova table [default: `true`]

Returns:

  * ANOVA Result
  * F statistic
  * p value

Example:

```julia
julia> rm_anova_Y = [
    -4.4297,  4.7513,  3.2971, -1.4606, 
     4.8458,  5.1163,  6.0739, -1.9225, 
     6.1542, 10.4794, 12.4438,  9.2150];
julia> rm_anova_S = [1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4];
julia> rm_anova_F = [1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3];
julia> ANOVA.rm_anova(rm_anova_Y, rm_anova_S, rm_anova_F, name=:factor);
```

```
One-way repeated measures ANOVA
-----------------------------------------------
source  SS      df    MS      F       Prob
-----------------------------------------------
factor  169.437 2     84.718  12.364  0.00744
error   41.112  6     6.852   NaN     NaN
S       74.253  3     24.751  NaN     NaN
total   284.802 11    NaN     NaN     NaN
-----------------------------------------------
```


<a target='_blank' href='https://github.com/ZaneMuir/ANOVA.jl/blob/1a6a2221e5a44a7cfba8a24870a56c88220cefe6/src/repeated_measures_designs.jl#L8-L49' class='documenter-source'>source</a><br>

<a id='ANOVA.rm_anova2' href='#ANOVA.rm_anova2'>#</a>
**`ANOVA.rm_anova2`** &mdash; *Function*.



Two-way Repeated Measures ANOVA

Syntax:

  * `Result = rm_anova2(Y::Array{T, 1}, S::Array{D, 1}, A::Array{D, 1}, B::Array{D, 1};names::Tuple{Symbol, Symbol}=(:A, :B), preview::Bool=true) where {T <: Number, D <: Integer}`

Arguments:

  * `Y`: data set in 1d vector
  * `S`: corresponding subject marker, as Array{Integer, 1}
  * `A`: corresponding factor A marker, as Array{Integer, 1}
  * `B`: corresponding factor B marker, as Array{Integer, 1}

Keywords:

  * `names`: the name of the factor [default: `(:A, :B)`]
  * `preview`: print anova table [default: `true`]

Return:

  * ANOVA Result


<a target='_blank' href='https://github.com/ZaneMuir/ANOVA.jl/blob/1a6a2221e5a44a7cfba8a24870a56c88220cefe6/src/repeated_measures_designs.jl#L105-L124' class='documenter-source'>source</a><br>

