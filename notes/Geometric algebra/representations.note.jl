### A Pluto.jl notebook ###
# v0.19.42

using Markdown
using InteractiveUtils

# ╔═╡ 741b2f4a-4d8b-11ef-0987-9d615e40a0f7
begin
	using Pkg
	Pkg.develop(path="/Users/josephwilson/Documents/GeometricAlgebra.jl")
	Pkg.add.(["Quaternions", "StaticArrays"])
	using GeometricAlgebra, Quaternions, Test
	using LinearAlgebra
	using StaticArrays
end

# ╔═╡ f0dce386-ea19-4e73-aee8-fd3748dd47d2
function M2()
	e1 = SA[0 1; 1 0]
	e2 = SA[1 0; 0 -1]
	[e1, e2]
end

# ╔═╡ 349943a2-e143-4748-9d2f-a84bf5b0d8ca
function H2()
	e1 = quat(0, 1, 0, 0)
	e2 = quat(0, 0, 1, 0)
	[e1, e2]
end

# ╔═╡ c3d45906-2cf3-4727-a303-56f2662b35cb
struct DirectSum{X,Y} <: Number
	x::X
	y::Y
end

# ╔═╡ 04831c01-1e64-454b-a3aa-37c39661cbbe
begin
	# for op in [:+, :-, :*, :/, :\]
	# 	@eval Base.$op(a::DirectSum, b::DirectSum) = DirectSum($op(a.x, b.x), $op(a.y, b.y))
	# end
	Base.promote_rule(::Type{T}, ::Type{DirectSum{X,Y}}) where {T<:Number,X,Y} = DirectSum{promote_type(T, X),promote_type(T, Y)}
	Base.:+(a::DirectSum, b::DirectSum) = DirectSum(a.x + b.x, a.y + b.y)
	Base.:-(a::DirectSum, b::DirectSum) = DirectSum(a.x - b.x, a.y - b.y)
	Base.:*(a::DirectSum, b::DirectSum) = DirectSum(a.x*b.x + a.y*b.y, a.x*b.y + a.y*b.x)
	Base.convert(::Type{DirectSum{X,Y}}, a::DirectSum) where {X,Y} = DirectSum{X,Y}(a.x, a.y)
	Base.convert(::Type{D}, x::Number) where D <: DirectSum = D(x, 0)
	# Base.:*(a::DirectSum, b::Number) = DirectSum(a.x*b, a.y*b)
	# Base.:*(a::Number, b::DirectSum) = DirectSum(a*b.x, a*b.y)
	Base.:^(a::DirectSum, b::Number) = DirectSum(a.x^b, a.y^b)
	Base.show(io::IO, a::DirectSum) = print(io, a.x, " ⊕ ", a.y)
	a ⊕ b = DirectSum(a, b)
end

# ╔═╡ b22886a7-c14e-460d-8869-8bb53ef78cf6
function reprbasis(sig)
	if sig == Cl(0,0)
		Int[]
	elseif sig == Cl(1,0)
		[1 ⊕ 0]
	elseif sig == Cl(0,1)
		[im]
	elseif sig == Cl(2,0)
		M2()
	elseif sig == Cl(1,1)
		# [1 0; 0 1], M2()
	elseif sig == Cl(0,2)
		H2()
	end
end

# ╔═╡ bb0131d0-6e7e-4302-827b-a17aef26f970
function completebasis(basisvectors)
	dim = length(basisvectors)
	bits = UInt.(0:(2^dim - 1))
	indices = GeometricAlgebra.bits_to_indices.(bits)
	[prod(basisvectors[i]) for i in indices]
end

# ╔═╡ 86b1355c-129c-4312-bf66-fd51419f2a81
function checkbasisiso(basisblades1, basisblades2)
	translation = Dict(basisblades1 .=> basisblades2)
	f(k) = k in keys(translation) ? translation[k] : -translation[-k]
	for a in basisblades1, b in basisblades1
		@test f(a*b) == f(a)*f(b)
	end
	true
end

# ╔═╡ 23b47d54-8cae-4768-9e75-f917a771584d
checkbasisiso(sig::Cl, b) = checkbasisiso(basis(sig, :all), b)

# ╔═╡ 34ee067a-2627-4d55-945c-8765594fee41
test(sig) = checkbasisiso(sig, completebasis(reprbasis(sig)))

# ╔═╡ a585617d-b3ee-4bb4-8d17-86ffc2b1944c
test(Cl(2,))

# ╔═╡ 5eb09705-fd8c-40fa-a5c1-947dd548e8e1
basis(Cl(1,0), :all)

# ╔═╡ 30d9b026-bfe2-47e0-9e81-4f34abf2255f
checkbasisiso(basis(Cl(2,2), :all), completebasis([kron(a, b) for a in M2() for b in M2()]))

# ╔═╡ 76381792-2894-4044-82d6-c6cc07df867b
let a = M2()
	I = one(a[1])
	v = kron.(zip(
		a[1] => I,
		a[2] => I,
		a[1] => a[2],
		a[1]a[2] => a[1]a[2],
	)...)
	# V = completebasis(v)
	@testset for i=1:4, j=1:4
		if i == j
			@test isone(v[i]^2)
		else
			@test v[i]v[j] == -v[j]v[i]
		end
	end
	# checkbasisiso(Cl(2,2), V)
end

# ╔═╡ e4b0cc3d-13fb-440a-8a0f-f126372e96e2
test(Cl(2,0))

# ╔═╡ f8b086e2-4159-4a96-9b8b-b52f10f269a7
M2()

# ╔═╡ Cell order:
# ╠═741b2f4a-4d8b-11ef-0987-9d615e40a0f7
# ╠═f0dce386-ea19-4e73-aee8-fd3748dd47d2
# ╠═349943a2-e143-4748-9d2f-a84bf5b0d8ca
# ╠═b22886a7-c14e-460d-8869-8bb53ef78cf6
# ╠═c3d45906-2cf3-4727-a303-56f2662b35cb
# ╠═04831c01-1e64-454b-a3aa-37c39661cbbe
# ╠═bb0131d0-6e7e-4302-827b-a17aef26f970
# ╠═86b1355c-129c-4312-bf66-fd51419f2a81
# ╠═23b47d54-8cae-4768-9e75-f917a771584d
# ╠═34ee067a-2627-4d55-945c-8765594fee41
# ╠═a585617d-b3ee-4bb4-8d17-86ffc2b1944c
# ╠═5eb09705-fd8c-40fa-a5c1-947dd548e8e1
# ╠═30d9b026-bfe2-47e0-9e81-4f34abf2255f
# ╠═76381792-2894-4044-82d6-c6cc07df867b
# ╠═e4b0cc3d-13fb-440a-8a0f-f126372e96e2
# ╠═f8b086e2-4159-4a96-9b8b-b52f10f269a7
