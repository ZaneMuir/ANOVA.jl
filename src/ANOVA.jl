module ANOVA

import DataFrames
import Distributions

export oneway, twoway

function oneway(data::Array{Float64, 2}; preview=true)
    _row, _col = size(data)
    _mean_total = mean(data)
    _mean_treat = mean(data, 1)

    _SS_treat = _row * sum((_mean_treat - _mean_total).^2)
    _SS_error = sum(broadcast(-, data, _mean_treat).^2)

    _df_treat = _col - 1
    _df_error = _col * (_row - 1)

    _MS_treat = _SS_treat / _df_treat
    _MS_error = _SS_error / _df_error

    _F = _MS_treat / _MS_error
    _F_dist = Distributions.FDist(_df_treat, _df_error)

    _p = 1.0 - Distributions.cdf(_F_dist, _F)

    if preview
        @printf "One-way ANOVA\n-------------------------------------------\nsource\tSS\t\tdf\tMS\t\tF\tp\n\ntreat\t%.5f\t%d\t%.5f\t%.5f\t%.5f\n\nerror\t%.5f\t%d\t%.5f\n\ntotal\t%.5f\t%d\n-------------------------------------------\n" _SS_treat _df_treat _MS_treat _F _p _SS_error _df_error _MS_error sum((data-_mean_total).^2) _df_treat+_df_error
    end

    (_F, _p)
end

function oneway(data::DataFrames.DataFrame)
     nothing  #TODO
end

function twoway(data)
    "twoway anova"
end

end
