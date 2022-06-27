### A Pluto.jl notebook ###
# v0.19.8

using Markdown
using InteractiveUtils

# ╔═╡ 6d7cb113-3740-49e4-88a0-12d06c586ac8
begin
	using StableRNGs
	myRNG = StableRNG(123)
	popsize = 50
end

# ╔═╡ c9784408-f60f-11ec-24ae-a3ea2f42e265
md"""
# Particle Swarm Optimisation

This is a notebook on Particle Swarm Optimisation (PSO) with examples taken from Kochenderfer's Algorithms for Optimization book.
"""

# ╔═╡ 5be582a8-a833-400c-b424-ff71e50bd79c
md"""
We begin by creating the type/struct of the particle. Each particle should have a position, a velocity, and memory of its best location:
"""

# ╔═╡ 887785da-a2a8-43ce-9d5a-99ad34e01827
mutable struct Particle
	x
	v
	x_best
end

# ╔═╡ 129fd065-4e49-461c-92e7-42adb979a4c0
md"""
In PSO, each particle will accelerate towards both the best position it has seen, and towards the best position the whole swarm has encountered.

The acceleration is weighted by a random term, and the update equations are the following:

$$\begin{align}
x^{(i)} & \leftarrow x^{(i)} + v^{(i)} \\
v^{(i)} & \leftarrow wv^{(i)} + c_1r_1(x^{(i)}_{best} - x^{(i)}) + c_2r_2(x_{best} - x^{(i)})
\end{align}$$

$w, c_1$ and $c_2$ are parameters, while $r_1, r_2 \sim U(0, 1)$. A common strategy is to allow the inertia ($w$) to decay over time, and thus reducing the step size of the search.
"""

# ╔═╡ 91ef2869-87bb-450f-aaf1-830ebb55cf80
function pso(f, population, k_max; w=1, c1= 1, c2=1)
	n = length(population[1].x)
	x_best, y_best = copy(population[1].x_best), Inf
	for P in population
		y = f(P.x)
		if y < y_best; x_best[:], y_best = P.x, y; end
	end
	for k in 1 : k_max
		for P in population
			r1, r2 = rand(myRNG, n), rand(myRNG, n)
			P.x += P.v
			P.v = w*P.v + c1*r1.*(P.x_best - P.x) + c2*r2.*(x_best - P.x)

			y = f(P.x)
			if y < y_best; x_best[:], y_best = P.x, y; end
			if y < f(P.x_best); P.x_best[:] = P.x; end
		end
	end
	return population
end

# ╔═╡ 559baf28-786d-4bbc-88b0-9dd2a3f01c90
md"""
So we need a function $f$, and a $population$ container of vectors. $k_{max}$ is the maximum number of iterations. Let's do that:
"""

# ╔═╡ cf4ae8d1-27b8-4c95-b50e-f1ee2f624f3a
md"""
The Michalewicz function is a d-dimensional optimisation functions with a lot of valleys. The functions is the following:

$$f(x) = - \sum_{i=1}^{d} \sin(x_i) \sin^{2m}\left(\frac{ix^2_i}{\pi}\right)$$

For $d=2$, the minimum is at approximately $[2.20, 1.57]$, with $f(\mathbf{x}^*) = -1.8011$
"""

# ╔═╡ 63064890-159b-4304-98df-fcc1f52a3308
function michalewicz(x; m=10)
	return -sum(sin(v) * sin(i*v^2/π)^(2m) for (i, v) in enumerate(x))
end

# ╔═╡ 8f7dfd4f-7696-4566-960e-82d375aebd09
begin
	pop = []
	for i in 1:popsize
		let x_pos = rand(myRNG, 0:0.1:5, 2)
			push!(pop, Particle(x_pos, [0, 0], x_pos))
		end
	end
pop[1:3]
end

# ╔═╡ a11b37c5-f0fd-4e48-89dc-5afc71d537ff
md"""
We now have a procedure with a population named `pop` and a function. Let's test it!
"""

# ╔═╡ a94f7855-9586-4c5e-85b9-52d590954c70
pso(michalewicz, pop, 200)

# ╔═╡ 25a3e5fd-86b6-4849-be2c-cbc240831751
md"""
Now we only need a way to extract the minimum, but as you can see it got real close!
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
StableRNGs = "860ef19b-820b-49d6-a774-d7a799459cd3"

[compat]
StableRNGs = "~1.0.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.3"
manifest_format = "2.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.StableRNGs]]
deps = ["Random", "Test"]
git-tree-sha1 = "3be7d49667040add7ee151fefaf1f8c04c8c8276"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
"""

# ╔═╡ Cell order:
# ╟─c9784408-f60f-11ec-24ae-a3ea2f42e265
# ╠═6d7cb113-3740-49e4-88a0-12d06c586ac8
# ╟─5be582a8-a833-400c-b424-ff71e50bd79c
# ╠═887785da-a2a8-43ce-9d5a-99ad34e01827
# ╟─129fd065-4e49-461c-92e7-42adb979a4c0
# ╠═91ef2869-87bb-450f-aaf1-830ebb55cf80
# ╟─559baf28-786d-4bbc-88b0-9dd2a3f01c90
# ╟─cf4ae8d1-27b8-4c95-b50e-f1ee2f624f3a
# ╠═63064890-159b-4304-98df-fcc1f52a3308
# ╠═8f7dfd4f-7696-4566-960e-82d375aebd09
# ╟─a11b37c5-f0fd-4e48-89dc-5afc71d537ff
# ╠═a94f7855-9586-4c5e-85b9-52d590954c70
# ╟─25a3e5fd-86b6-4849-be2c-cbc240831751
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
