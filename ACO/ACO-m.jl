### A Pluto.jl notebook ###
# v0.19.12

using Markdown
using InteractiveUtils

# ╔═╡ 378dc465-09ab-4a69-8b7a-734876c1526e
begin
	import StatsBase: Weights, sample
	using Statistics
	using Graphs
	using SimpleWeightedGraphs
	using Random
	using StableRNGs
	using SparseArrays
end

# ╔═╡ 91e4e7fa-5146-11ed-16b2-a9c11a8c087a
md"""
# Ant Colony Optimisation

I had a very nice implementation for this, taken from the code samples in the Algorithms for Optimization book of Kochenderfer and Wheeler, but I lost it in the moving from computer to computer.

Let's try to set it up again.
"""

# ╔═╡ 7174f81d-667a-408d-99c4-335caf7a1285
md"""
The edge attractiveness function which receives:
- A graph (that I honestly think we don't need)
- A matrix ``\tau``
- A matrix ``\eta``
- Parameters ``\alpha`` and ``\beta``, by default 1 and 5

The edge attractiveness updates by the following interaction:

```math
A[i, j] = \tau[i, j]^\alpha \eta[i, j]^\beta
```

The book uses ``A(i \rightarrow j)`` which I have replaced by ``A[i, j]`` instead, and refers to the attractiveness of the edge from node ``i`` to node ``j``.
"""

# ╔═╡ f35d6a76-7d45-4e55-bab2-03d1fee2ad88
function edge_attractiveness(graph, τ, η; α=1, β=5)
	A = similar(τ)
	for i in 1:nv(graph)
		neighbourhood = outneighbors(graph, i)
		for j in neighbourhood
			v = τ[i, j]^α * η[i, j]^β
			A[i, j] = v
		end
	end
	return A
end

# ╔═╡ be2f98a6-af19-47f2-aa2c-06729e549bc8
md"""
A single run of the ant is what the ant needs to figure out. In this case, it's for TSP. This is what we can modify and make modular!
"""

# ╔═╡ 49432c5f-5158-4379-9dd0-e083e6f2af44
function run_ant(G, lengths, τ, A, x_best, y_best)
	x = [1]
	while length(x) < nv(G)
		i = x[end]
		neighbourhood = setdiff(outneighbors(G, i), x)
		if isempty(neighbourhood) # ant got stuck
			return (x_best, y_best)
		end

		as = [A[i, j] for j in neighbourhood]
		push!(x, neighbourhood[sample(Weights(as))])
	end

	l = sum(lengths[x[i-1], x[i]] for i in 2:length(x))
	for i in 2:length(x)
		τ[x[i-1], x[i]] += 1/l
	end
	if l < y_best
		return (x, l)
	else
		return (x_best, y_best)
	end
end

# ╔═╡ f67dd38f-90df-4190-925b-e4969198b4a7
md"""
This is the ACO function itself. It receives:

- A graph `G` that originall came from `LightGraphs.jl`. Since it has been deprecated, we now create it with `Graphs.jl`.
- A matrix of weights (lengths)
- Number of ants `m`
- Number of iterations `k_max`
- Pheromone exponent ``\alpha``
- Prior exponent ``\beta``
- Evaporation scalar ``\rho``
- A matrix of prior edge weights ``\eta``
"""

# ╔═╡ 9a84d2cc-8d85-4986-874a-36c700f6cc02
function ACO(G, lengths; m=1000, k_max=100, α=1.0, β=5.0, ρ=0.5, η=1 ./ lengths)
	τ = ones(size(lengths))
	x_best, y_best = [], Inf

	for k in 1:k_max
		A = edge_attractiveness(G, τ, η, α=α, β=β)
		for e in keys(τ)
			τ[e] = (1-ρ) * τ[e]
		end
		for ant in 1:m
			# actual ant behaviour goes here
			# in this case, this is Alg. 19.9 in the book
			# which is solving a TSP
			x_best, y_best = run_ant(G, lengths, τ, A, x_best, y_best)
		end
	end
	return x_best, y_best
end

# ╔═╡ 5e68578c-fdde-45d8-b387-27dfc5886fdf
md"""
## Setup
"""

# ╔═╡ 0c7b7dbf-20af-4443-bdc6-84653797793e
begin
	myrng = StableRNG(351)
	n = 90
	g = complete_digraph(n)
	lengths = zeros((n, n))
	for e in edges(g)
		lengths[e.src, e.dst] = rand(myrng, 0.2:0.2:100)
	end
end

# ╔═╡ 7fa21ab3-dec6-40db-91eb-c01d261fc6d3
bestant, cost = ACO(g, lengths)

# ╔═╡ 705caf87-faf3-4481-9bc6-b5700fe32e26
sum(lengths[bestant[i-1], bestant[i]] for i in bestant[2:end])

# ╔═╡ 01138e74-1f66-407c-b0b4-7e6215e8202a
md"""
The expected average of a tour would theoretically be
``n`` cities times ``\mathbb{E}[W]``:
"""

# ╔═╡ 8b1c03b5-4825-4480-8014-38a8b0d0028a
mean(lengths)

# ╔═╡ cc6c7099-c732-44bd-8351-b3e1742a63f0
median(lengths)

# ╔═╡ 48a64b7c-c7ac-40ea-820d-44dd3e8c4cc4
n * mean(lengths)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Graphs = "86223c79-3864-5bf0-83f7-82e725a168b6"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
SimpleWeightedGraphs = "47aef6b3-ad0c-573a-a1e2-d07658019622"
SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
StableRNGs = "860ef19b-820b-49d6-a774-d7a799459cd3"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"

[compat]
Graphs = "~1.7.4"
SimpleWeightedGraphs = "~1.2.1"
StableRNGs = "~1.0.0"
StatsBase = "~0.33.21"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.3"
manifest_format = "2.0"

[[deps.ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "62e51b39331de8911e4a7ff6f5aaf38a5f4cc0ae"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.2.0"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "e7ff6cadf743c098e08fca25c91103ee4303c9bb"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.6"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "38f7a08f19d8810338d4f5085211c7dfa5d5bdd8"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.4"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "3ca828fe1b75fa84b021a7860bd039eaea84d2f2"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.3.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.DataAPI]]
git-tree-sha1 = "46d2680e618f8abd007bce0c3026cb0c4a8f2032"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.12.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "c36550cb29cbe373e95b3f40486b9a4148f89ffd"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.2"

[[deps.Graphs]]
deps = ["ArnoldiMethod", "Compat", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "ba2d094a88b6b287bd25cfa86f301e7693ffae2f"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.7.4"

[[deps.Inflate]]
git-tree-sha1 = "5cd07aab533df5170988219191dfad0519391428"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.3"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "94d9c52ca447e23eac0c0f074effbcd38830deb5"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.18"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[deps.SimpleWeightedGraphs]]
deps = ["Graphs", "LinearAlgebra", "Markdown", "SparseArrays", "Test"]
git-tree-sha1 = "a6f404cc44d3d3b28c793ec0eb59af709d827e4e"
uuid = "47aef6b3-ad0c-573a-a1e2-d07658019622"
version = "1.2.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StableRNGs]]
deps = ["Random", "Test"]
git-tree-sha1 = "3be7d49667040add7ee151fefaf1f8c04c8c8276"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.0"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "f86b3a049e5d05227b10e15dbb315c5b90f14988"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.9"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6b7ba252635a5eff6a0b0664a41ee140a1c9e72a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f9af7f195fb13589dd2e2d57fdb401717d2eb1f6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.5.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
"""

# ╔═╡ Cell order:
# ╟─91e4e7fa-5146-11ed-16b2-a9c11a8c087a
# ╠═378dc465-09ab-4a69-8b7a-734876c1526e
# ╟─7174f81d-667a-408d-99c4-335caf7a1285
# ╠═f35d6a76-7d45-4e55-bab2-03d1fee2ad88
# ╟─be2f98a6-af19-47f2-aa2c-06729e549bc8
# ╠═49432c5f-5158-4379-9dd0-e083e6f2af44
# ╟─f67dd38f-90df-4190-925b-e4969198b4a7
# ╠═9a84d2cc-8d85-4986-874a-36c700f6cc02
# ╟─5e68578c-fdde-45d8-b387-27dfc5886fdf
# ╠═0c7b7dbf-20af-4443-bdc6-84653797793e
# ╠═7fa21ab3-dec6-40db-91eb-c01d261fc6d3
# ╠═705caf87-faf3-4481-9bc6-b5700fe32e26
# ╟─01138e74-1f66-407c-b0b4-7e6215e8202a
# ╠═8b1c03b5-4825-4480-8014-38a8b0d0028a
# ╠═cc6c7099-c732-44bd-8351-b3e1742a63f0
# ╠═48a64b7c-c7ac-40ea-820d-44dd3e8c4cc4
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
