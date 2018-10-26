# Repeated-measures Designs
#
# author: yizhan miao
# email: yzmiao@protonmail.com
# last update: Oct 26 2018


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


"""Two-way Repeated Measures ANOVA

Syntax:
- `Result = rm_anova2(Y::Array{T, 1}, S::Array{D, 1}, A::Array{D, 1}, B::Array{D, 1};names::Tuple{Symbol, Symbol}=(:A, :B), preview::Bool=true) where {T <: Number, D <: Integer}`

Arguments:
- `Y`: data set in 1d vector
- `S`: corresponding subject marker, as Array{Integer, 1}
- `A`: corresponding factor A marker, as Array{Integer, 1}
- `B`: corresponding factor B marker, as Array{Integer, 1}

Keywords:
- `names`: the name of the factor [default: `(:A, :B)`]
- `preview`: print anova table [default: `true`]

Return:
- ANOVA Result

"""
function rm_anova2(Y::Array{T, 1}, S::Array{D, 1}, A::Array{D, 1}, B::Array{D, 1};names::Tuple{Symbol, Symbol}=(:A, :B), preview::Bool=true) where {T <: Number, D <: Integer}
    # check balance
    _factor_A = unique(A)
    _n_factor_A = zeros(Int64, length(_factor_A))
    for (idx, each) in enumerate(_factor_A)
        _n_factor_A[idx] = A[A .== each] |> length
    end
    
    _factor_B = unique(B)
    _n_factor_B = zeros(Int64, length(_factor_B))
    for (idx, each) in enumerate(_factor_B)
        _n_factor_B[idx] = B[B .== each] |> length
    end
    
    _subject = unique(S)
    _n_subject = zeros(Int64, length(_subject))
    for (idx, each) in enumerate(_subject)
        _n_subject[idx] = S[S .== each] |> length
    end
    
    @assert(length(unique(_n_factor_A)) == 1, "input data is not balanced across factor A.")
    @assert(length(unique(_n_factor_B)) == 1, "input data is not balanced across factor B.")
    @assert(length(unique(_n_subject)) == 1,  "input data is not balanced across subject.")
    #TODO: support unbalanced ANOVA
    
    _mean_total = mean(Y)
    _mean_A = [mean(Y[A .== _A]) for _A in _factor_A]
    _mean_B = [mean(Y[B .== _B]) for _B in _factor_B]
    _mean_BA = [mean(Y[(A .== _A) .& (B .== _B)]) for _A in _factor_A, _B in _factor_B]
    _mean_S = [mean(Y[S .== _S]) for _S in _subject]
    
    _mean_AS = [mean(Y[(A .== _A) .& (S .== _S)]) for _A in _factor_A, _S in _subject]
    _mean_BS = [mean(Y[(B .== _B) .& (S .== _S)]) for _B in _factor_B, _S in _subject]
    
    _SS_total = (Y .- _mean_total).^2 |> sum
    _SS_A = sum((_mean_A .- _mean_total) .^ 2) * length(_subject) * length(_factor_B)
    _SS_B = sum((_mean_B .- _mean_total) .^ 2) * length(_subject) * length(_factor_A)
    _SS_BA = sum((_mean_BA .- _mean_total) .^ 2) * length(_subject) - _SS_A - _SS_B
    _SS_S = sum((_mean_S .- _mean_total).^2) * length(_factor_A) * length(_factor_B)
    _SS_AS = sum((_mean_AS .- _mean_total) .^ 2) * length(_factor_B) - _SS_A - _SS_S
    _SS_BS = sum((_mean_BS .- _mean_total) .^ 2) * length(_factor_A) - _SS_B - _SS_S
    _SS_BAS = _SS_total - _SS_A - _SS_B - _SS_BA - _SS_S - _SS_AS - _SS_BS

    _df_total = length(Y) - 1
    _df_A = length(_factor_A) - 1
    _df_B = length(_factor_B) - 1
    _df_S = length(_subject) - 1
    _df_BA = _df_A * _df_B
    _df_AS = _df_A * _df_S
    _df_BS = _df_B * _df_S
    _df_BAS = _df_BA * _df_S
    
    _MS_A = _SS_A / _df_A
    _MS_B = _SS_B / _df_B
    _MS_BA = _SS_BA / _df_BA
    _MS_S = _SS_S / _df_S
    _MS_AS = _SS_AS / _df_AS
    _MS_BS = _SS_BS / _df_BS
    _MS_BAS = _SS_BAS / _df_BAS

    ##### ANOVA #####
    _F_A = _MS_A / _MS_AS
    _F_B = _MS_B / _MS_BS
    _F_BA = _MS_BA / _MS_BAS
    
    _p_A = ccdf(FDist(_df_A, _df_AS), _F_A)
    _p_B = ccdf(FDist(_df_B, _df_BS), _F_B)
    _p_BA = ccdf(FDist(_df_BA, _df_BAS), _F_BA)
    
    TOTAL = anova_entry(:total, _SS_total, _df_total, NaN, NaN, NaN)
    _S    = anova_entry(:S, _SS_S, _df_S, _MS_S, NaN, NaN)
    _A    = anova_entry(names[1], _SS_A, _df_A, _MS_A, _F_A, _p_A)
    _B    = anova_entry(names[2], _SS_B, _df_B, _MS_B, _F_B, _p_B)
    _BA   = anova_entry(Symbol("$(names[2])*$(names[1])"), _SS_BA, _df_BA, _MS_BA, _F_BA, _p_BA)
    _AS   = anova_entry(Symbol("S*$(names[1])"), _SS_AS, _df_AS, _MS_AS, NaN, NaN)
    _BS   = anova_entry(Symbol("S*$(names[2])"), _SS_BS, _df_BS, _MS_BS, NaN, NaN)
    _BAS   = anova_entry(Symbol("S*$(names[2])*$(names[1])"), _SS_BAS, _df_BAS, _MS_BAS, NaN, NaN)
    
    RESULT = anova_result("Two-way repeated measures ANOVA", [_S, _A, _B, _BA, _AS, _BS, _BAS, TOTAL])
    
    preview&&preview_anova_result(RESULT)
    
    RESULT
end