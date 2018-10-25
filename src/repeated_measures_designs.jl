# Repeated-measures Designs
#
# author: yizhan miao
# email: yzmiao@protonmail.com
# last update: Oct 25 2018


"""One-way Repeated Measures ANOVA

Syntax:
- `RESULT, _F, _p = rm_anova(Y::Array{T, 1}, S::Array{D, 1}, F::Array{D, 1};name::Symbol=:F, preview::Bool=true) where {T <: Number, D <: Integer}`

Arguments:
- `Y`: data set in 1d vector
- `S`: corresponding subject marker, as Array{Integer, 1}
- `F`: corresponding factor marker, as Array{Integer, 1}

Keywords:
- `name`: the name of the factor [default: `:F`]
- `preview`: print anova table [default: `true`]

Returns:
- ANOVA Result
- F statistic
- p value

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
"""
function rm_anova(Y::Array{T, 1}, S::Array{D, 1}, F::Array{D, 1};name::Symbol=:F, preview::Bool=true) where {T <: Number, D <: Integer}
    # check balance
    _factor = unique(F)
    _n_factor = zeros(Int64, length(_factor))
    for (idx, each) in enumerate(_factor)
        _n_factor[idx] = F[F .== each] |> length
    end
    
    _subject = unique(S)
    _n_subject = zeros(Int64, length(_subject))
    for (idx, each) in enumerate(_subject)
        _n_subject[idx] = S[S .== each] |> length
    end
    
    @assert(length(unique(_n_factor)) == 1, "input data is not balanced across factors.")
    @assert(length(unique(_n_subject)) == 1, "input data is not balanced across subject: $(unique(_n_subject)).")
    # TODO: support unbalanced ANOVA
    
    _mean_total = mean(Y)
    _mean_treat = [mean(Y[F .== _F]) for _F in _factor]
    _mean_subject = [mean(Y[S .== _S]) for _S in _subject]
    
    _SS_total = (Y .- _mean_total).^2 |> sum
    _SS_treat = sum((_mean_treat .- _mean_total).^2) * length(_subject)
    _SS_subject = sum((_mean_subject .- _mean_total) .^ 2) * length(_factor)
    _SS_SF = _SS_total - _SS_treat - _SS_subject
    
    _df_total = length(Y) - 1
    _df_treat = length(_factor) - 1
    _df_subject = length(_subject) - 1
    _df_SF = _df_total - _df_treat - _df_subject
    
    ##### rm anova #####
    _MS_treat = _SS_treat / _df_treat
    _MS_subject = _SS_subject / _df_subject
    _MS_SF = _SS_SF / _df_SF
    
    _F = _MS_treat / _MS_SF
    _F_dist = FDist(_df_treat, _df_SF)

    _p = ccdf(_F_dist, _F)
    
    TOTAL = anova_entry(:total, _SS_total, _df_total, NaN, NaN, NaN)
    TREAT = anova_entry(name, _SS_treat, _df_treat, _MS_treat, _F, _p)
    SF    = anova_entry(:error, _SS_SF, _df_SF, _MS_SF, NaN, NaN)
    SUBJECT = anova_entry(:S, _SS_subject, _df_subject, _MS_subject, NaN, NaN)
    
    RESULT = anova_result("One-way repeated measures ANOVA", [TREAT, SF, SUBJECT, TOTAL])
    
    preview&&preview_anova_result(RESULT)
    
    RESULT, _F, _p
    
end