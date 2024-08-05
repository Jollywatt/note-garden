using Test
using LinearAlgebra: I, tr, det

"""
Fadeev–LeVerrier algorithm

Given an ``n × n`` matrix `A`, return a named tuple with

- `inv`, the inverse matrix
- `det`, the determinant
- `c`, the coefficients of the characteristic polynomial ``χ(t) = Σ c[k] t^k``
"""
function fadeevleverrier(A::Matrix{T}) where T
	n = size(A, 1)
	c = ones(T, n + 1)
	N = zero(A)
	k = n - 1
	while k >= 0
		N = A*N + c[begin + k+1]*I
		c[begin + k] = tr(A*N)/(k - n)
		k -= 1
	end
	(; inv = -N/c[1], det = (-1)^n*c[1], c)
end

function test()
	@testset "Fadeev-LeVerrier for n = $n" for n = 1:10
		for _ = 1:50
			A = 5randn(n,n)
			flv = fadeevleverrier(A)
			@test A*flv.inv ≈ I atol=2e-4
			@test det(A) ≈ flv.det atol=2e-4
		end
	end
	nothing
end

