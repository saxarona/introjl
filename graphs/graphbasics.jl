### A Pluto.jl notebook ###
# v0.19.12

using Markdown
using InteractiveUtils

# ╔═╡ 5bc6b8e7-65a3-463e-bb1f-fac91e5fdc19
begin
	using Graphs
	using SimpleWeightedGraphs
end

# ╔═╡ b2bc2262-54b4-11ed-3ebd-eb8f4d033fbf
md"""
# Graph basics in Julia

Let's do a quick exercise to know what we can do with Graph.jl
"""

# ╔═╡ de1c2b2b-973a-4341-9547-6f78837e39ec
md"""
`Graphs.jl` contains constructors for _standard_ graphs, like a complete graph:
"""

# ╔═╡ f4a66e7c-d402-451a-b502-275f6599c462
g = complete_graph(10)

# ╔═╡ ad17d848-7165-4bf1-8d13-04d252b5f19e
md"""
The graph ``g`` has ``n`` vertices, with ``n^2 - n\over{2}`` edges. You can use `ne` to check how many edges a graph has:
"""

# ╔═╡ 3b2b32c7-783d-40c9-ad37-7cc7dc8d3a48
g.ne

# ╔═╡ 3aad02e0-3384-4a9c-b406-8ed5dfdf504d
md"""
And the adjacency list representation can be checked using `fadjlist`:
"""

# ╔═╡ 2d646b36-9d8a-4f8c-a391-33e46a563d40
g.fadjlist

# ╔═╡ 32f98774-5194-4f26-9b72-c8312d97da0f
md"""
which is a Vector of Vectors of Ints, since using `Graphs.jl` you get int names for the vertices.
"""

# ╔═╡ 434e63f5-11f6-48b4-9c54-a2524b2c4322
typeof(g.fadjlist)

# ╔═╡ f7c7ed27-c0ec-4b05-a7f8-5575cd991fd7
md"""
If you want weights in it, then the suggestion is to use `SimpleWeightedGraphs` instead:
"""

# ╔═╡ 8df3edcd-4f5c-42c7-a2c8-29a0a1bb194d
g1 = SimpleWeightedGraph(4)

# ╔═╡ ba7b5859-11ee-4626-aa07-6f3b69b0fede
md"""
The weights are stored in the `weights` field, which is a `SparseMatrix`:
"""

# ╔═╡ 2a4f6dfe-7c9f-4b8e-8bba-e75dd0a09217
g1.weights

# ╔═╡ 6506ab96-5e99-437d-b756-5eed9ce31349
md"""
To add a weight, you "add an edge" to the graph:
"""

# ╔═╡ cdcee57d-8b58-438d-9797-c2483d1a2fbf
add_edge!(g1, 1, 2, 0.5)

# ╔═╡ 19f59b43-f3ac-4e80-97e4-6eea7a7a0531
md"""
Notice how the fuction works in place. If you check the weights of `g1`, it now reflects the added edge:
"""

# ╔═╡ c43e496c-bc67-4c23-a4b3-c07621b26f23
g1.weights

# ╔═╡ e521bce8-2e5d-4a0b-95ea-390c26505d3b
md"""
`Graphs.jl` functions also work on `SimpleWeightedGraph`s:
"""

# ╔═╡ 7aa982ff-621d-44be-99c6-9bbfa3cfd613
nv(g1)

# ╔═╡ ef27e0b9-7b61-496d-bcb8-55ced7c91428
ne(g1)

# ╔═╡ e36218d4-592d-4ea7-aac5-db2008da527f
md"""
As you probably gathered, `ne` can be used to get the number of edges in a graph.
"""

# ╔═╡ 1168cc77-d88e-44f2-9752-438737f40876
md"""
There are some other useful functions in `Graphs.jl` that you should check out:
"""

# ╔═╡ 35cf8528-497d-4513-99f2-3007b524f555
is_cyclic(g1)

# ╔═╡ 474c3eba-3230-4939-a2d6-965e71fceddb
is_cyclic(g)

# ╔═╡ fa0b8510-42f7-4752-ad21-c0ba65f35f87
md"""
There are also `Directed` versions of the simple graphs, as well as their weighted versions.
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Graphs = "86223c79-3864-5bf0-83f7-82e725a168b6"
SimpleWeightedGraphs = "47aef6b3-ad0c-573a-a1e2-d07658019622"

[compat]
Graphs = "~1.7.4"
SimpleWeightedGraphs = "~1.2.1"
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

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "3ca828fe1b75fa84b021a7860bd039eaea84d2f2"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.3.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

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

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

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

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

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

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

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
# ╠═b2bc2262-54b4-11ed-3ebd-eb8f4d033fbf
# ╠═5bc6b8e7-65a3-463e-bb1f-fac91e5fdc19
# ╟─de1c2b2b-973a-4341-9547-6f78837e39ec
# ╠═f4a66e7c-d402-451a-b502-275f6599c462
# ╟─ad17d848-7165-4bf1-8d13-04d252b5f19e
# ╠═3b2b32c7-783d-40c9-ad37-7cc7dc8d3a48
# ╟─3aad02e0-3384-4a9c-b406-8ed5dfdf504d
# ╠═2d646b36-9d8a-4f8c-a391-33e46a563d40
# ╟─32f98774-5194-4f26-9b72-c8312d97da0f
# ╠═434e63f5-11f6-48b4-9c54-a2524b2c4322
# ╟─f7c7ed27-c0ec-4b05-a7f8-5575cd991fd7
# ╠═8df3edcd-4f5c-42c7-a2c8-29a0a1bb194d
# ╟─ba7b5859-11ee-4626-aa07-6f3b69b0fede
# ╠═2a4f6dfe-7c9f-4b8e-8bba-e75dd0a09217
# ╟─6506ab96-5e99-437d-b756-5eed9ce31349
# ╠═cdcee57d-8b58-438d-9797-c2483d1a2fbf
# ╟─19f59b43-f3ac-4e80-97e4-6eea7a7a0531
# ╠═c43e496c-bc67-4c23-a4b3-c07621b26f23
# ╟─e521bce8-2e5d-4a0b-95ea-390c26505d3b
# ╠═7aa982ff-621d-44be-99c6-9bbfa3cfd613
# ╠═ef27e0b9-7b61-496d-bcb8-55ced7c91428
# ╟─e36218d4-592d-4ea7-aac5-db2008da527f
# ╟─1168cc77-d88e-44f2-9752-438737f40876
# ╠═35cf8528-497d-4513-99f2-3007b524f555
# ╠═474c3eba-3230-4939-a2d6-965e71fceddb
# ╟─fa0b8510-42f7-4752-ad21-c0ba65f35f87
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
