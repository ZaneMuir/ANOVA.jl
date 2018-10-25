# One-factor Designs
# Y = A + e
#
# author: yizhan miao
# email: yzmiao@protonmail.com
# last update: Oct 25 2018


""" One-way ANOVA

Syntax:
- `RESULT, _F, _p = anova(Y::Array{T, 2}; preview::Bool) where {T <: Number}`
- `RESULT, _F, _p = anova(Y::Array{T, 1}, F::Array{D, 1}; preview::Bool) where {T <: Number, D<:Integer}`

Arguments:
- `Y`: data set in 1d vector, or 2d matrix, columns as treatments and rows as observations
- `F`: corresponding factor markers, as `Array{Integer, 1}`

Keywords:
- `preview`: print anova table [default: `true`]

Returns:
- ANOVA Result
- F statistic
- p value
"""
function anova(Y::Array{T, 2}; preview::Bool=true) where {T <: Number}
    _row, _col = size(Y)
    _mean_total = mean(Y)
    _mean_treat = mean(Y, dims = 1)

    _SS_total = (Y .- _mean_total) .^ 2 |> sum
    _SS_treat = _row * sum((_mean_treat .- _mean_total).^2)
    _SS_error = sum(broadcast(-, Y, _mean_treat).^2)

    _df_total = _row * _col - 1
    _df_treat = _col - 1
    _df_error = _col * (_row - 1)

    _MS_treat = _SS_treat / _df_treat
    _MS_error = _SS_error / _df_error

    _F = _MS_treat / _MS_error
    _F_dist = FDist(_df_treat, _df_error)

    _p = ccdf(_F_dist, _F)
    
    TOTAL = anova_entry(:total, _SS_total, _df_total, NaN, NaN, NaN)
    ERROR = anova_entry(:error, _SS_error, _df_error, _MS_error, NaN, NaN)
    TREAT = anova_entry(:columns, _SS_treat, _df_treat, _MS_treat, _F, _p)
    RESULT = anova_result("One-way Anova", [TREAT, ERROR, TOTAL])
    
    preview&&preview_anova_result(RESULT)
    
    RESULT, _F, _p
end


function anova(Y::Array{T, 1}, F::Array{D, 1}; preview::Bool=true) where {T <: Number, D<:Integer}
    # check balance
    _factor = unique(F)
    _n_factor = zeros(Int64, length(_factor))
    for (idx, each) in enumerate(_factor)
        _n_factor[idx] = F[F .== each] |> length
    end
    
    @assert(length(unique(_n_factor)) == 1, "input data is not balanced across factors.")
    # TODO: support unbalanced ANOVA
    
    _mean_total = mean(Y)
    _mean_treat = [mean(Y[F .== _F]) for _F in _factor]
    
    _SS_total = (Y .- _mean_total) |> x->x.^2 |> sum
    _SS_treat = (_mean_treat .- _mean_total).^2 .* _n_factor[1] |> sum
    _SS_error = _SS_total - _SS_treat
    
    _df_total = length(Y) - 1
    _df_treat = length(_factor) - 1
    _df_error = _df_total - _df_treat
    
    ##### one way ANOVA #####
    _MS_treat = _SS_treat / _df_treat
    _MS_error = _SS_error / _df_error

    _F = _MS_treat / _MS_error
    _F_dist = FDist(_df_treat, _df_error)

    _p = ccdf(_F_dist, _F)
    
    TOTAL = anova_entry(:total, _SS_total, _df_total, NaN, NaN, NaN)
    ERROR = anova_entry(:error, _SS_error, _df_error, _MS_error, NaN, NaN)
    TREAT = anova_entry(:columns, _SS_treat, _df_treat, _MS_treat, _F, _p)
    RESULT = anova_result("One-way Anova", [TREAT, ERROR, TOTAL])
    
    preview&&preview_anova_result(RESULT)
    
    RESULT, _F, _p
end