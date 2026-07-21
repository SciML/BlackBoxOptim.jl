"""
`FitnessScheme` defines how fitness vectors/values are
compared, presented and aggregated.
`Fitness` represents the score of one and the same individual
on one or a set of evaluations. A scheme is a specific
way to consider the scores in a coherent way.
Type parameter `F` specifies the type of fitness values.

`FitnessScheme` could also be used as a function that defines the fitness
ordering, i.e. `fs(x, y) == true` iff fitness `x` is better than `y`.
"""
abstract type FitnessScheme{F} end

"""
    fitness_type(fs::FitnessScheme)
    fitness_type(fs_type::Type{FitnessScheme})

Get the type of fitness values for fitness scheme `fs`.
"""
fitness_type(::Type{<:FitnessScheme{F}}) where {F} = F
fitness_type(fs::FitnessScheme) = fitness_type(typeof(fs))

"""
    fitness_eltype(fs::FitnessScheme)
    fitness_eltype(fs_type::Type{<:FitnessScheme})

Return the scalar element type used by numeric fitness values in `fs`.
"""
fitness_eltype(::Type{<:FitnessScheme{F}}) where {F <: Number} = F
fitness_eltype(fs::FitnessScheme) = fitness_eltype(typeof(fs))

# trivial convert() between calculated and archived fitness
Base.convert(::Type{F}, fit::F, fit_scheme::FitnessScheme{F}) where {F} = fit

# ordering induced by the fitness scheme
# FIXME enable once v0.5 issue #14919 is fixed
# (fs::FitnessScheme{F}){F}(x::F, y::F) = is_better(x, y, fs)

"""
In `RatioFitnessScheme` the fitness values can be ranked on a ratio scale so
pairwise comparisons are not required.
The default scale used is the aggregate of the fitness components.

"""
abstract type RatioFitnessScheme{F} <: FitnessScheme{F} end
# FIXME is it necessary?

"""
`Float64`-valued scalar fitness scheme.
The boolean type parameter `MIN` specifies if smaller fitness values
are better (`true`) or worse (`false`).
"""
struct ScalarFitnessScheme{MIN} <: RatioFitnessScheme{Float64}
end

"""
    MinimizingFitnessScheme

Scalar fitness scheme where smaller values are better.
"""
const MinimizingFitnessScheme = ScalarFitnessScheme{true}()

"""
    MaximizingFitnessScheme

Scalar fitness scheme where larger values are better.
"""
const MaximizingFitnessScheme = ScalarFitnessScheme{false}()

"""
    is_minimizing(scheme::FitnessScheme)

Return `true` when lower fitness values are better for `scheme`.
"""
is_minimizing(::ScalarFitnessScheme{MIN}) where {MIN} = MIN

"""
    nafitness(T::Type)
    nafitness(scheme::FitnessScheme)

Return the sentinel value used for a missing or unevaluated fitness.
"""
nafitness(::Type{F}) where {F <: Number} = convert(F, NaN)
@inline nafitness(fs::FitnessScheme) = nafitness(fitness_type(fs))

"""
    isnafitness(fitness, scheme::FitnessScheme)

Return `true` when `fitness` is the unevaluated sentinel for `scheme`.
"""
isnafitness(f::F, ::RatioFitnessScheme{F}) where {F <: Number} = isnan(f)

"""
    numobjectives(scheme::FitnessScheme)

Return the number of objectives represented by `scheme`.
"""
numobjectives(::RatioFitnessScheme) = 1

"""
Aggregation is just the identity function for scalar fitness.
"""
aggregate(fitness::F, ::RatioFitnessScheme{F}) where {F <: Number} = fitness

is_better(f1::Float64, f2::Float64, scheme::ScalarFitnessScheme{true}) = f1 < f2
is_better(f1::Float64, f2::Float64, scheme::ScalarFitnessScheme{false}) = f1 > f2

"""
Complex-valued fitness.
"""
struct ComplexFitnessScheme <: FitnessScheme{ComplexF64}
    # FIXME what is isbetter() for ComplexFitnessScheme?
end

# FIXME do we need it? it might be confused with problem's fitness bounds
worst_fitness(fs::FitnessScheme) = is_minimizing(fs) ? Inf : (-Inf)

"""
    best_fitness(x)

Return the best fitness represented by a fitness scheme, archive, or
optimization result.
"""
best_fitness(fs::FitnessScheme) = -worst_fitness(fs)

hat_compare(a1::Number, a2::Number) =
    (a1 < a2) ? -1 : ((a1 > a2) ? 1 : (isnan(a1) ? (isnan(a2) ? 0 : 1) : (isnan(a2) ? -1 : 0)))

"""
Check whether `f1` or `f2` fitness is better.

Returns
  * `-1` if `f1` is better than `f2`
  * `1` if `f2` is better than `f1`
  * `0` if `f1` and `f2` are equal.
"""
function hat_compare(f1, f2, s::RatioFitnessScheme)
    return if is_minimizing(s)
        hat_compare(aggregate(f1, s), aggregate(f2, s))
    else
        hat_compare(aggregate(f2, s), aggregate(f1, s))
    end
end

"""
    is_better(f1, f2, scheme::FitnessScheme)

Return `true` when `f1` is better than `f2` according to `scheme`.
"""
is_better(f1, f2, scheme::FitnessScheme) = hat_compare(f1, f2, scheme) == -1

"""
    is_worse(f1, f2, scheme::FitnessScheme)

Return `true` when `f1` is worse than `f2` according to `scheme`.
"""
is_worse(f1, f2, scheme::FitnessScheme) = hat_compare(f1, f2, scheme) == 1

"""
    same_fitness(f1, f2, scheme::FitnessScheme)

Return `true` when `f1` and `f2` compare as equal under `scheme`.
"""
same_fitness(f1, f2, scheme::FitnessScheme) = hat_compare(f1, f2, scheme) == 0

struct HatCompare{FS <: FitnessScheme}
    fs::FS

    HatCompare(fs::FS) where {FS <: FitnessScheme} = new{FS}(fs)
end

(hc::HatCompare)(x::F, y::F) where {F} = hat_compare(x, y, hc.fs)
