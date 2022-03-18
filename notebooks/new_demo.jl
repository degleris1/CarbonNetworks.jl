### A Pluto.jl notebook ###
# v0.18.1

using Markdown
using InteractiveUtils

# ╔═╡ ab12ce06-a668-11ec-2f53-abde75339997
using Pkg; Pkg.activate(joinpath(@__DIR__, "../dev"))

# ╔═╡ 760d886b-2891-4e38-b765-524ba998de95
using Revise; using CarbonNetworks

# ╔═╡ 69df35dd-be27-484c-9101-635ee37590fb
T = 5

# ╔═╡ f9abd878-26bd-404c-9dc7-8c624487d615
md"""
### Create network
"""

# ╔═╡ e889f18d-7280-4903-ab2c-b802ea9fa0c4
A = [
	-1 0 1
	1 -1 0
	0 1 -1
]

# ╔═╡ 492abd5d-4a99-4849-8767-9affcec16a0c
β = [1, 1, 1]

# ╔═╡ 30ceea15-e8c5-4e8e-9186-5a5d0ef8def3
fmax = let
	fmax = [10, 4, 10] * ones(1, T)
	[fmax; fmax]
end;

# ╔═╡ 866f9d9e-d572-4eb8-9b5a-21088da5cebe
md"""
### Construct devices
"""

# ╔═╡ c0abc95f-6d3f-47fb-b420-f968ea6510d3
α = 100

# ╔═╡ 4c5ad529-7252-4948-b474-9634d38d2f43
devices = [
	Demand(10 .+ 3rand(T), α),
	Demand(2 .+ rand(T), α),
	Generator(zeros(T), 10 * rand(T), 0.1*ones(T)),
	StaticGenerator(0, 12, 20, T)
]

# ╔═╡ b40a72ae-371d-4aa1-bced-508fe592420c
nodes = [1, 2, 2, 3]

# ╔═╡ f7efa9a7-a171-47f7-b4f9-477fff221562
F = make_device_pfdf_matrix(A, β, nodes);

# ╔═╡ 432a5854-0885-4e74-bb59-27f482ab033e
md"""
### Instantiate and solve problem
"""

# ╔═╡ 174edb6e-85a8-48c9-9d69-61ee0348f162
pmp = DynamicPowerManagementProblem(devices, F, fmax, T);

# ╔═╡ df2d83fc-54fc-4c72-acc3-0c2aa8ac6a07
pmp_result = solve!(pmp);

# ╔═╡ 8bbada9c-19b4-4627-829f-fdd21f5e49a9
maximum(abs, kkt(pmp, pmp_result))

# ╔═╡ 1a2d2f09-b84a-4ab3-b953-69c75e818302
md"""
### Compute marginal emissions rates
"""

# ╔═╡ c98e2c65-7361-43e9-9f19-af4f45e9429c
demand_devices = [1, 2]

# ╔═╡ d35e7d68-aa3a-46e1-9061-ab4433e8df37
generator_devices = [3, 4]

# ╔═╡ c998b46e-5c9c-43c5-a360-b74fbc132cbc
emissions_rates = [zeros(T), 1.1*ones(T)]

# ╔═╡ ba3dfa35-8bcb-4fbf-8cdf-d0255b3b6e26
λ = get_lme(demand_devices, generator_devices, emissions_rates)

# ╔═╡ Cell order:
# ╠═ab12ce06-a668-11ec-2f53-abde75339997
# ╠═760d886b-2891-4e38-b765-524ba998de95
# ╠═69df35dd-be27-484c-9101-635ee37590fb
# ╟─f9abd878-26bd-404c-9dc7-8c624487d615
# ╠═e889f18d-7280-4903-ab2c-b802ea9fa0c4
# ╠═492abd5d-4a99-4849-8767-9affcec16a0c
# ╠═30ceea15-e8c5-4e8e-9186-5a5d0ef8def3
# ╟─866f9d9e-d572-4eb8-9b5a-21088da5cebe
# ╠═c0abc95f-6d3f-47fb-b420-f968ea6510d3
# ╠═4c5ad529-7252-4948-b474-9634d38d2f43
# ╠═b40a72ae-371d-4aa1-bced-508fe592420c
# ╠═f7efa9a7-a171-47f7-b4f9-477fff221562
# ╟─432a5854-0885-4e74-bb59-27f482ab033e
# ╠═174edb6e-85a8-48c9-9d69-61ee0348f162
# ╠═df2d83fc-54fc-4c72-acc3-0c2aa8ac6a07
# ╠═8bbada9c-19b4-4627-829f-fdd21f5e49a9
# ╟─1a2d2f09-b84a-4ab3-b953-69c75e818302
# ╠═c98e2c65-7361-43e9-9f19-af4f45e9429c
# ╠═d35e7d68-aa3a-46e1-9061-ab4433e8df37
# ╠═c998b46e-5c9c-43c5-a360-b74fbc132cbc
# ╠═ba3dfa35-8bcb-4fbf-8cdf-d0255b3b6e26
