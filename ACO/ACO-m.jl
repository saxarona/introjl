### A Pluto.jl notebook ###
# v0.20.4

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
	using BenchmarkTools
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

# ╔═╡ f244bda5-67b0-4737-959e-974c5f23752c
@benchmark ACO(g, lengths)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
Graphs = "86223c79-3864-5bf0-83f7-82e725a168b6"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
SimpleWeightedGraphs = "47aef6b3-ad0c-573a-a1e2-d07658019622"
SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
StableRNGs = "860ef19b-820b-49d6-a774-d7a799459cd3"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"

[compat]
BenchmarkTools = "~1.6.0"
Graphs = "~1.7.4"
SimpleWeightedGraphs = "~1.2.1"
StableRNGs = "~1.0.0"
Statistics = "~1.11.1"
StatsBase = "~0.33.21"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.3"
manifest_format = "2.0"
project_hash = "592b2dc38579303a501e415e896b284721ef0081"

[[deps.ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "62e51b39331de8911e4a7ff6f5aaf38a5f4cc0ae"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.2.0"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.BenchmarkTools]]
deps = ["Compat", "JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "e38fbc49a620f5d0b660d7f543db1009fe0f8336"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.6.0"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "8ae8d32e09f0dcf42a36b90d4e17f5dd2e4c4215"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.16.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "1d0a14036acb104d9e89698bd408f63ab58cdc82"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.20"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"
version = "1.11.0"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Graphs]]
deps = ["ArnoldiMethod", "Compat", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "ba2d094a88b6b287bd25cfa86f301e7693ffae2f"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.7.4"

[[deps.Inflate]]
git-tree-sha1 = "d1b1b796e47d94588b3757fe84fbf65a5ec4a80d"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.5"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "e2222959fbc6c19554dc15174c81bf7bf3aa691c"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.4"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.7.2+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.11.0"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "13ca9e2586b89836fd20cccf56e57e2b9ae7f38f"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.29"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.MacroTools]]
git-tree-sha1 = "72aebe0b5051e5143a079a4685a46da330a40472"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.15"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

[[deps.OrderedCollections]]
git-tree-sha1 = "cc4054e898b852042d7b503313f7ad03de99c3dd"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.8.0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.Profile]]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"
version = "1.11.0"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[deps.SimpleWeightedGraphs]]
deps = ["Graphs", "LinearAlgebra", "Markdown", "SparseArrays", "Test"]
git-tree-sha1 = "a8d28ad975506694d59ac2f351e29243065c5c52"
uuid = "47aef6b3-ad0c-573a-a1e2-d07658019622"
version = "1.2.2"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.11.0"

[[deps.StableRNGs]]
deps = ["Random"]
git-tree-sha1 = "83e6cce8324d49dfaf9ef059227f91ed4441a8e5"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.2"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "02c8bd479d26dbeff8a7eb1d77edfc10dacabc01"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.11"

    [deps.StaticArrays.extensions]
    StaticArraysChainRulesCoreExt = "ChainRulesCore"
    StaticArraysStatisticsExt = "Statistics"

    [deps.StaticArrays.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StaticArraysCore]]
git-tree-sha1 = "192954ef1208c7019899fbf8049e717f92959682"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.3"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"
weakdeps = ["SparseArrays"]

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.7.0+0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"
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
# ╠═f244bda5-67b0-4737-959e-974c5f23752c
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
