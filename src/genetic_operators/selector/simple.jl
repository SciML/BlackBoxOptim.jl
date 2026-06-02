"""
Simple random `IndividualsSelector`.

The probabilities of all candidates are equal.
"""
struct SimpleSelector <: IndividualsSelector
end

select(::SimpleSelector, population, n::Integer) =
    sample(1:popsize(population), n, ordered = false, replace = false)
