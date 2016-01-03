#################### Metropolis-Adjusted Langevin Algorithm ####################

#################### Types ####################

type MALATune <: SamplerTune
  scale::Float64
  SigmaF::Cholesky{Float64}

  function MALATune(value::Vector{Float64}=Float64[])
    new(
      NaN,
      Cholesky(Array(Float64, 0, 0), :U)
    )
  end
end


typealias MALAVariate SamplerVariate{MALATune}


#################### Sampler Constructor ####################

function MALA(params::ElementOrVector{Symbol}, scale::Real;
              dtype::Symbol=:forward)
  samplerfx = function(model::Model, block::Integer)
    v = SamplerVariate(model, block, true)
    f = x -> logpdfgrad!(model, x, block, dtype)
    mala!(v, scale, f)
    relist(model, v, block, true)
  end
  Sampler(params, samplerfx, MALATune())
end


function MALA{T<:Real}(params::ElementOrVector{Symbol}, scale::Real,
                       Sigma::Matrix{T}; dtype::Symbol=:forward)
  SigmaF = cholfact(Sigma)
  samplerfx = function(model::Model, block::Integer)
    v = SamplerVariate(model, block, true)
    f = x -> logpdfgrad!(model, x, block, dtype)
    mala!(v, scale, SigmaF, f)
    relist(model, v, block, true)
  end
  Sampler(params, samplerfx, MALATune())
end


#################### Sampling Functions ####################

function mala!(v::MALAVariate, scale::Real, logfgrad::Function)
  scale2 = scale / 2.0

  logf0, grad0 = logfgrad(v.value)
  y = v + scale2 * grad0 + sqrt(scale) * randn(length(v))
  logf1, grad1 = logfgrad(y)

  q0 = -0.5 * sumabs2((v - y - scale2 * grad1)) / scale
  q1 = -0.5 * sumabs2((y - v - scale2 * grad0)) / scale

  if rand() < exp((logf1 - q1) - (logf0 - q0))
    v[:] = y
  end
  v.tune.scale = scale

  v
end


function mala!(v::MALAVariate, scale::Real, SigmaF::Cholesky{Float64},
               logfgrad::Function)
  L = sqrt(scale) * SigmaF[:L]
  Linv = inv(L)
  M2 = 0.5 * L * L'

  logf0, grad0 = logfgrad(v.value)
  y = v + M2 * grad0 + L * randn(length(v))
  logf1, grad1 = logfgrad(y)

  q0 = -0.5 * sumabs2(Linv * (v - y - M2 * grad1))
  q1 = -0.5 * sumabs2(Linv * (y - v - M2 * grad0))

  if rand() < exp((logf1 - q1) - (logf0 - q0))
    v[:] = y
  end
  v.tune.scale = scale
  v.tune.SigmaF = SigmaF

  v
end
