# Two Factor Designs
#
# author: yizhan miao
# email: yzmiao@protonmail.com
# last update: Oct 26 2018

"""Two-way ANOVA

Syntax:
- `Result = anova2(Y::Array{T, 1}, A::Array{D, 1}, B::Array{D, 1};names=(:A, :B), preview::Bool=true) where {T <: Number, D <: Integer}`

Arguments:
- `Y`: data set in 1d vector
- `A`: corresponding factor A marker, as Array{Integer, 1}
- `B`: corresponding factor B marker, as Array{Integer, 1}

Keywords:
- `names`: the name of the factor [default: `(:A, :B)`]
- `preview`: print anova table [default: `true`]

Return:
- ANOVA Result

"""
function anova2(Y::Array{T, 1}, A::Array{D, 1}, B::Array{D, 1};names=(:A, :B), preview::Bool=true) where {T <: Number, D <: Integer}
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
    
    _rep = length(Y) / length(_factor_A) / length(_factor_B)
    
    @assert(length(unique(_n_factor_A)) == 1, "input data is not balanced across factor A.")
    @assert(length(unique(_n_factor_B)) == 1, "input data is not balanced across factor B.")
    #TODO: support unbalanced ANOVA
    
    _mean_total = mean(Y)
    _mean_A = [mean(Y[A .== _A]) for _A in _factor_A]
    _mean_B = [mean(Y[B .== _B]) for _B in _factor_B]
    _mean_BA = [mean(Y[(A .== _A) .& (B .== _B)]) for _A in _factor_A, _B in _factor_B]
    
    _SS_total = (Y .- _mean_total).^2 |> sum
    _SS_A = sum((_mean_A .- _mean_total).^2) * _rep * length(_factor_B)
    _SS_B = sum((_mean_B .- _mean_total).^2) * _rep * length(_factor_A)
    _SS_S_BA = [sum((Y[(A .== _A) .& (B .== _B)] .- _mean_BA[idx_A, idx_B]).^2) for (idx_A, _A) in enumerate(_factor_A), (idx_B, _B) in enumerate(_factor_B)] |> sum
    _SS_BA = _SS_total - _SS_A - _SS_B - _SS_S_BA
    
    _df_total = length(Y) - 1
    _df_A = length(_factor_A) - 1
    _df_B = length(_factor_B) - 1
    _df_BA = _df_A * _df_B
    _df_S_BA = _df_total - _df_A - _df_B - _df_BA
    
    ##### rm anova #####
    _MS_A = _SS_A / _df_A
    _MS_B = _SS_B / _df_B
    _MS_BA = _SS_BA / _df_BA
    _MS_S_BA = _SS_S_BA / _df_S_BA
    
    _F_A = _MS_A / _MS_S_BA
    _F_B = _MS_B / _MS_S_BA
    _F_BA = _MS_BA / _MS_S_BA

    _p_A = ccdf(FDist(_df_A, _df_S_BA), _F_A)
    _p_B = ccdf(FDist(_df_B, _df_S_BA), _F_B)
    _p_BA = ccdf(FDist(_df_BA, _df_S_BA), _F_BA)
    
    TOTAL = anova_entry(:total, _SS_total, _df_total, NaN, NaN, NaN)
    _A = anova_entry(names[1], _SS_A, _df_A, _MS_A, _F_A, _p_A)
    _B = anova_entry(names[2], _SS_B, _df_B, _MS_B, _F_B, _p_B)
    _BA = anova_entry(Symbol("$(names[2])*$(names[1])"), _SS_BA, _df_BA, _MS_BA, _F_BA, _p_BA)
    _S_BA = anova_entry(:error, _SS_A, _df_A, _MS_A, NaN, NaN)
    
    RESULT = anova_result("Two-way ANOVA", [_A, _B, _BA, _S_BA, TOTAL])
    
    preview&&preview_anova_result(RESULT)
    
    RESULT
end