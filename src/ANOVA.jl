module ANOVA

using Printf
using Distributions
using Statistics
# using DataFrames  #TODO
using DocumentFunction

struct anova_entry
    name::Symbol
    SS::Float64
    df::Int64
    MS::Float64
    F::Float64
    p::Float64
end

struct anova_result
    anova_type::String
    components::Array{anova_entry, 1}
end

function preview_anova_result(R::anova_result)
    output = """
$(R.anova_type)
-----------------------------------------------------------------
source\t\tSS\tdf\t\tMS\tF\tProb
-----------------------------------------------------------------\n"""
    
    for part in R.components
        output *= @sprintf("%s\t%10.3f\t%d\t%10.3f\t%.3f\t%.5f\n", part.name, part.SS, part.df, part.MS, part.F, part.p)
    end
    output *= "-----------------------------------------------------------------"
    println(output)
end

include("one_factor_designs.jl")
include("two_factor_designs.jl")
include("repeated_measures_designs.jl")

export anova, anova2, rm_anova, rm_anova2

end
