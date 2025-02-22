### A Pluto.jl notebook ###
# v0.19.9

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ dd32f064-95ad-4321-a740-d87ff3653b50
using Dates

# ╔═╡ 5303b439-2bbb-4a04-b17e-7df6f2983493
using TOML

# ╔═╡ b3352ae6-d614-423d-bfa0-2ee28ab5b134
using BSON

# ╔═╡ d145ef02-6511-4685-bb16-b421703e7dbf
using XLSX, DataFrames

# ╔═╡ 64f8e88a-dfbf-4d25-b40e-af688e9e9f00
using SparseArrays, InlineStrings

# ╔═╡ 32e5f26a-9b2f-4fc0-a0cd-1a5f101f0db9
using StatsBase: mean

# ╔═╡ e19f3dbe-b54a-45c3-b496-cf762f821ed5
using Statistics

# ╔═╡ 4f6b2696-e9b8-439b-ba28-8074be1ae068
using LightGraphs

# ╔═╡ 7a42f00e-193c-45ea-951f-dcd4e1c1975f
using CairoMakie

# ╔═╡ 5cb1709a-eda0-41b3-8bff-f58c19608be5
using PlutoUI

# ╔═╡ ee25f56b-b3a0-4e6d-9410-72f95a15b432
using Makie.GeometryBasics

# ╔═╡ 2d3cf797-4cc2-4aad-bc3e-94f5474e99f9
begin
	using GeoMakie
	using GeoMakie.GeoInterface
	using GeoMakie.GeoJSON
	using Downloads
	using Proj4
end

# ╔═╡ abae6ee4-431a-41e2-adce-53c780e5c975
using Random

# ╔═╡ c6c3d56a-3782-4272-b6c2-b1088160d675
import StatsBase

# ╔═╡ b2b2e596-0f92-4e3c-ab1c-46a0bff9fb4b
# equivalent to include that will replace it

function ingredients(path::String)
	# this is from the Julia source code (evalfile in base/loading.jl)
	# but with the modification that it returns the module instead of the last object
	name = Symbol(basename(path))
	m = Module(name)
	Core.eval(m,
        Expr(:toplevel,
             :(eval(x) = $(Expr(:core, :eval))($name, x)),
             :(include(x) = $(Expr(:top, :include))($name, x)),
             :(include(mapexpr::Function, x) = $(Expr(:top, :include))(mapexpr, $name, x)),
             :(include($path))))
	m
end;

# ╔═╡ 3f03a7e6-2889-428d-984c-0995574f1fc3
analysis = ingredients("analysis_utils.jl")

# ╔═╡ 6db70f24-e8ba-461e-8d86-00e9a37b44d3
md"""
## Load data
"""

# ╔═╡ f9fab4fe-baec-4bfd-9d84-ef9caac85f5f
config = TOML.parsefile(joinpath(@__DIR__, "../../config.toml"))

# ╔═╡ d7598abb-2be7-4e3b-af9e-14827ef5a3b0
DATA_DIR = config["data"]["GOOGLE_DRIVE"]

# ╔═╡ 1605bc95-dd10-4ac1-b258-a58e7242d34f
DATA_DIR

# ╔═╡ 45c73bb3-eecf-4b92-8e91-6a4c83addfdc
RESULTS_DIR = config["data"]["SAVE_DIR"]

# ╔═╡ 67130163-7a9e-4dc9-8458-b00239a1fb07
run_names = ["year18_static", "year18_static", "year18_dynamic", "year_future0gw", "year18_future15gw"]

# ╔═╡ 6de86962-a420-4885-ae7a-18748549c4c2
paths = [joinpath(DATA_DIR, "results240", name) for name in run_names]

# ╔═╡ 2757231c-ef30-417a-87dd-7d155049ba47
cases = [BSON.load(joinpath(p, "case.bson"), @__MODULE__) for p in paths];

# ╔═╡ 9dcbc82a-2ced-4b5a-a879-cc5458d039e4
results = map(analysis.load_results, paths);

# ╔═╡ 25d6013f-ac12-4bb6-baa0-28925dc16e66
avg_demand = mean([sum(r[:d]) for (_, r) in results[2]])

# ╔═╡ b4f91614-ada2-4961-8913-96855f7ca81b
md"""
## Load GIS data
"""

# ╔═╡ 5392f525-ecb3-47c7-a32f-73a6b02967df
df_gis = DataFrame(XLSX.readtable(joinpath(DATA_DIR, "nrel/Bus GIS.xlsx"), "Test1")...);

# ╔═╡ 514b6f5f-c5d7-4937-8dec-a039b50b553c
cleanup(xi) = typeof(xi) <: Real ? xi : Base.parse(Float64, strip(xi))

# ╔═╡ ba2a3175-b445-4227-a401-18ff40fc4c53
x, y = cleanup.(df_gis.Long), cleanup.(df_gis.Lat)

# ╔═╡ b6e667a5-d2ed-4ab6-9c94-9e6e45be84e8
coords(k) = y[k], x[k]

# ╔═╡ 64627393-f9b2-4c64-95c8-458cc005e237
num_nodes = length(x)

# ╔═╡ d2bacf4a-af37-4ff9-bebb-3dc3d06edd8a
md"""
## MEFs
"""

# ╔═╡ cbc71e2e-0bd1-441c-bf17-c60053a60795
md"""
## Plot!
"""

# ╔═╡ fd640755-2f9d-4845-9524-fce685e9053c
let
	t = 10

	rs = results[2][DateTime(0018, 07, 15, 00) .+ Hour(t-1)]
	r = results[3][DateTime(0018, 07, 15, 00)]
	
	d = r[:d][t]
	g = r[:g][t]
	p = r[:p][t]

	pmax = 1.5 * min.(cases[2][:fmax] / 1e3, 100e3) 

	A = cases[3][:A]
	B = cases[3][:B]
	S = cases[3][:S]
	ρ = cases[3][:ramp][1] / 1e3

	ds = d - B*g + A*p

	s_inds = findall(abs.(ds) .> 1e-6)

	# @show sum((abs.(p) ./ abs.(pmax)) .> 0.99)
	# @show sum((abs.(rs[:p]) ./ abs.(pmax)) .> 0.999), "foo"
	
	#ds[s_inds] / sum(d)
	sum(abs, rs[:g] - g) / sum(abs, g)
	#sum(abs.(g - r[:g][t-1]) ./ ρ .> 0.99)
end

# ╔═╡ 73fa2393-d2a2-429b-a84a-493acd8fb841
make_rect(xi, yi, w, h) = [xi-w/2, xi-w/2, xi+w/2, xi+w/2, xi-w/2], [yi-h/2, yi+h/2, yi+h/2, yi-h/2, yi-h/2]

# ╔═╡ 9900463f-5bc6-4649-b970-9456c5712d50
make_rect(xi, yi, r=1) = make_rect(xi, yi, 2r, 2r)

# ╔═╡ effd6c24-94ad-4803-9c30-7186a677480b
in_rect(node, xi, yi, r=1) = (xi-r/2 < x[node] < xi+r/2) && (yi-r/2 < y[node] < yi+2/2)

# ╔═╡ 85f3a3f3-ca15-4e70-8745-a780e069aa9b
minimum(sum.(first(results[3])[2][:gmax]))

# ╔═╡ 7771eb73-3ddb-4f80-b487-4685c1838501
maximum(sum.(first(results[3])[2][:d]))

# ╔═╡ be39a732-89d0-4a8b-9c88-3acd34f96dcc
md"""
## Map
"""

# ╔═╡ 3878f6d7-fdb5-4fe1-9b92-179f3e576ec0
B = cases[5][:B];

# ╔═╡ 2a6bfa51-8f05-46c9-8fd3-5b3f6dd307c7
fuel = cases[5][:params][1].gen.fuel;

# ╔═╡ b0805b35-6545-41ba-8dc3-45cf0072b094
DateTime(18, 07, 09, 00) in keys(results[5])

# ╔═╡ f5bc0567-9fa5-45f7-8d70-c86099559984
sum(fuel .== "Nuclear")

# ╔═╡ 35e55d76-d175-4e77-9b69-930225cb8573
node2 = 140; df_gis[node2, "Bus  Name"], coords(node2)

# ╔═╡ 7126918a-eb31-40a9-8f2d-7e181a1fcb3b
node1 = 100; df_gis[node1, "Bus  Name"], coords(node1)

# ╔═╡ 39ff81d3-9890-4291-8391-9cf0dbd9cf7e
mnth = 8

# ╔═╡ 59316c15-a94c-4c56-a30a-0e6c23629de7
hr = 12

# ╔═╡ 04d0d66a-8427-48a5-9c0e-e93eb619cd05
p_sacramento = (x=-121.3, y=39.0)

# ╔═╡ 35ec1921-8f4c-46cd-aa80-778a475b1542
p_bay = (x=-122.0, y=37.5)

# ╔═╡ a6178160-2471-4e6f-bcd9-debb529d39d4
md"""
## Time Series
"""

# ╔═╡ ef79c984-db2a-4a1d-92e5-2d40abadcca3
R = 0.25

# ╔═╡ 7ffbe1bc-8cc6-4033-a70b-880209164199
function fig_map(
	i, 
	whichdates=d -> (hour(d) == hr) && (month(d) == mnth);
	get_vals = (i, wd) -> analysis.get_average_nodal_mefs(results[i], wd)/1e3,
	fig=Figure(resolution=(600, 300), fontsize=10),
	clims=(0.0, 1.0),
	ms=8,
	r=R,
)
	case = cases[i]
	r = results[i]
	λ = get_vals(i, whichdates)
	
	# Everthing in === is from https://lazarusa.github.io/BeautifulMakie/GeoPlots/geoCoastlinesStatesUS/
	# ===========
    ax = Axis(fig[1,1])
	
	states_url = "https://raw.githubusercontent.com/PublicaMundi/MappingAPI/master/data/geojson/us-states.json"
    states = Downloads.download(states_url)
    states_geo = GeoJSON.read(read(states, String))
    n = length(GeoInterface.features(states_geo))

    trans = Proj4.Transformation("+proj=aeqd +datum=WGS84", "+proj=aeqd", 
        always_xy=true) 
	
    # see https://proj.org/operations/projections/index.html for more options 
    # all input data coordinates are projected using this function
    ax.scene.transformation.transform_func[] = Makie.PointTrans{2}(trans)
	
    xlims!(ax, -125, -104)
	ylims!(ax, 31, 51)
    
	# now the plot 
    lines!(ax, GeoMakie.coastlines(), color = :black)
    poly!(ax, states_geo, color=(:lightgray, 0.2), 
		colormap = :plasma, 
		strokecolor = :black, 
        strokewidth = 1, overdraw = true)
	# ============

	
	# and my part
	
	# Edges
	_case = BSON.load(joinpath(DATA_DIR, "results240", "july18_static", "case.bson"), @__MODULE__)
	A = _case[:A]
	for j in 1:size(A, 2)
		fr = findfirst(==(-1), A[:, j])
		to = findfirst(==(1), A[:, j])

		lines!(ax, [x[fr]; x[to]], [y[fr]; y[to]], 
			color=(:black, 0.08))
	end

	# Nodes
	sct = scatter!(ax, x, y, 
		markersize=ms, 
		strokewidth=0.2, 
		marker=:circle, 
		color=λ, 
		colormap=:jet1,
		colorrange=clims,
	)

	# Plot region
	# lines!(ax, make_rect(p1[1], p1[2], R)..., color=:black)
	#lines!(ax, make_rect(p2[1], p2[2], R)..., color=:black)
	

	# Colorbar
	#cb = Colorbar(fig[1, 2], sct, label="LME [ton CO2 / MWh]")
	#cb.tellheight = true
	
	ax.xticks = [-150]
	ax.yticks = [20]
	ax.title = "WECC: Average Nodal MEFs at Hour $hr "
	
    return fig, ax, sct
end

# ╔═╡ 07268e37-5b62-4ab3-8d0d-5bab2286cdbe
let
	get_cap = (i, wd) -> B * results[i][DateTime(18, 07, 05, 00)][:gmax][hr]
	get_fuel = (i, wd) -> B*(map(f -> f in ["Steam"], fuel)) .> 0
	
	fig, ax = fig_map(
		4, 
		#d -> hour(d) == hr && day(d) in day_range,
		# get_vals = get_fuel,
		#clims=(0.5, 1.0),
	)

	ax.title = ""
	
	#save(joinpath(RESULTS_DIR, "wecc240_map1.pdf"), fig)
	fig
end

# ╔═╡ 76277c5f-c415-4861-b934-c76cc07a3820
day_range = 1:31 # 4, 14, 19

# ╔═╡ fb62741d-d65e-4c6f-a256-5389623362ad
is_renewable = map(f -> f in ["PV-2", "PV-1", "Wind-1", "Wind-2",], fuel)

# ╔═╡ 93b1dd21-6f9d-4770-acd3-fe8f625f6d46
avg_renewable = mean([sum(r[:gmax][2][is_renewable]) for (_, r) in results[5]])

# ╔═╡ a91cbac6-27ba-4238-9b9f-ed561d2267ca
sortperm(cases[4][:params][:gt] .* is_renewable, rev=true)

# ╔═╡ 6cf44a9c-c4f8-42c8-8b19-753ad53ac62b
cases[4][:params][:gt][205]

# ╔═╡ 34461bf7-19e6-4ca9-9238-da512d947ef4
p_renew = let
	i = 240
	@show fuel[i]
	(x=x[i], y=y[i])
end

# ╔═╡ 4c9f5116-6629-4494-a344-ea9061728956
summer = [5, 6, 7, 8]

# ╔═╡ 3a92e994-c094-4ee5-8a02-9c5c6df4551f
winter = [11, 12, 1, 2]

# ╔═╡ 9d35d4df-5fca-430e-bfae-b801107ffb61


# ╔═╡ f06f51e4-98cb-4691-ab2f-acd9f5290aaa
p1 = (x=x[211], y=y[211])

# ╔═╡ 20e85734-92ff-4c34-9572-dd65ddd1d327
md"""
## Distributions
"""

# ╔═╡ 76ddbef6-2ace-44e7-af9f-c71390c4955a
D = 14

# ╔═╡ 5237b37a-1feb-4493-896e-60b4c0427f49
ri, r_hr = 3, 5

# ╔═╡ b75419d4-a203-4103-8dc1-ea7c088f0ada
gas_co2_rate, steam_co2_rate = let
	c = cases[r_hr][:co2_rates]
	fuel = cases[r_hr][:fuel]

	gen_co2_rate(f) = mean(c[fuel .== f])

	map(gen_co2_rate, ["Gas", "Steam"])
end

# ╔═╡ b53cc8dd-c36e-4cf8-9f1d-473a0e985234
function fig_distr(
	i1; 
	whichdates=d -> (hour(d) == hr) && (month(d) == mnth), 
	i2=nothing, 
	fig = Figure(resolution=(300, 300)),
	d=D,
)
	r = results[i1]
	nodal_mefs = analysis.get_nodal_mefs(r, whichdates)
	all_mefs = mean(nodal_mefs, dims=2)[:]

	ax = Axis(fig[1, 1])
	hidedecorations!(ax, ticks=false, ticklabels=false, label=false)

	# Plot first set of data
	kwargs = (strokewidth=1, strokecolor=:black, direction=:y)
	#density!(ax, all_mefs_a/1e3; offset=4.0, kwargs...)
	#density!(ax, all_mefs_b/1e3; offset=2.0, kwargs...)
	density!(ax, all_mefs/1e3; color=(:slategray, 0.7), kwargs...)
	hlines!(ax, [mean(all_mefs)/1e3], color=:black)

	hlines!(ax, [gas_co2_rate/1e3], color=:blue)
	hlines!(ax, [steam_co2_rate/1e3], color=:blue)

	kwargs = (linewidth=4, color=:black)
	#hlines!(ax, [mean(all_mefs_a)/1e3]; xmin=4/6, kwargs...)
	#hlines!(ax, [mean(all_mefs_b)/1e3]; xmin=2/6, xmax=4/6, kwargs...)
	#hlines!(ax, [mean(all_mefs)/1e3]; xmax=2/6, kwargs...)

	# Plot second set of data
	if i2 != nothing
		r = results[i2]
		nodal_mefs = get_nodal_mefs(r, whichdates)
		all_mefs_a = nodal_mefs[node1, :]
		all_mefs_b = nodal_mefs[node2, :]
		all_mefs = reshape(nodal_mefs, :)
		
		kwargs = (direction=:y,)
		density!(ax, all_mefs_a/1e3; color=(:red, 0.2), offset=4, kwargs...)
		density!(ax, all_mefs_b/1e3; color=(:red, 0.2), offset=2, kwargs...)
		density!(ax, all_mefs/1e3; color=(:red, 0.2), kwargs...)
	end

	
	

	ylims!(ax, -0.25, 1.5)
	ax.ylabel = "MEF [ton CO2 / MWh]"
	
	
	#xlims!(ax, 0, 10)
	ax.xlabel = "Frequency"
	ax.xticks = [-100]
	# ax.xtickformat = xs -> ["All", "South", "North"]

	return fig, ax
end

# ╔═╡ 3e977d3a-01b6-428e-962f-a5128b739a78
function get_col(i)
	c = fig_distr(2)[2].palette.patchcolor.val[i]
	return RGBA(c.r, c.g, c.b, 0.5)
end

# ╔═╡ d6abbce4-27ba-4a1d-8fb0-ce97a40c716d
function fig_time(
	; run_id=1,
	regions=[((0, 0), 1)],
	hybrid_mode=[false],
	labels=["run A"],
	fig=Figure(resolution=(650, 200), fontsize=10),
	whichdates=d -> true,
	ls_cycle=[:solid, :dash],
	color_cycle=[
		get_col(1), 
		get_col(2), :orange
	],
	bands=false
)
	run_id = typeof(run_id) <: Array ? run_id : [run_id]

	ax = Axis(fig[1, 1], xgridvisible=false, ygridvisible=false)
	xlims!(ax, 1, 23)

	ax.xticks = 0:6:24
	ax.xlabel = "Hour"
	ax.ylabel = "LME [ton CO2 / MWh]"

	for (indr, rid) in enumerate(run_id)
		r = results[rid]
		hm = hybrid_mode[indr]
		
		for (ind, (p, radius)) in enumerate(regions)
			nodes = in_rect.(1:num_nodes, p.x, p.y, radius)

			λ_nodes = [
				StatsBase.median(reshape(analysis.get_nodal_mefs(r, 
					d -> whichdates(d) && hour(d) == h,
					hybrid_mode=hm)[nodes, :], :))
				for h in 0:23
			]

			c = color_cycle[indr]
			lines!(ax, λ_nodes, label="$(labels[indr])",
				linewidth=3, linestyle=ls_cycle[ind], color=RGBA(c.r, c.g, c.b, 1))

			if bands
				mefs_up = [
					λ_nodes[h+1] + StatsBase.mad(reshape(analysis.get_nodal_mefs(r, 
						d -> whichdates(d) && hour(d) == h,
						hybrid_mode=hm)[nodes, :], :))
					for h in 0:23
				]
				mefs_low = [
					λ_nodes[h+1] - StatsBase.mad(reshape(analysis.get_nodal_mefs(r, 
						d -> whichdates(d) && hour(d) == h,
						hybrid_mode=hm)[nodes, :], :))
					for h in 0:23
				]

				band!(ax, 1:24, mefs_up, mefs_low, color=color_cycle[indr])
			end
		end
	end
	
	fig, ax
end

# ╔═╡ 971d68b9-c140-4594-a0af-4bb45f665508
let
	fig, ax = fig_time(
		fig=Figure(resolution=(650, 200), fontsize=10),
		run_id=[5, 4], 
		hybrid_mode=[false, false],
		labels=["Storage", "No Storage"],
		regions=[(p_sacramento, 0.1)], 
		whichdates=d -> month(d) in summer,
		bands=true
	)

	ax.title = "Hourly LMEs for High Renewable Scenario"
	ax.ytickformat = ys -> string.(ys/1e3)
	axislegend(ax, position=:lb, margin=(2, 2, 2, 2))

	save(joinpath(RESULTS_DIR, "fig_240_storage_timeseries.pdf"), fig)
	fig
end

# ╔═╡ e1a1acda-1d52-45bd-8257-8b7249318c9b
fig_distr(4)[1]

# ╔═╡ fb306c55-5558-46db-a9c6-87a6e079304a
total_emissions = let
	co2 = []
	for i in [ri, r_hr]
		c = cases[i][:co2_rates]
	
		flatten = g -> (typeof(g[1]) <: Array) ? reduce(hcat, g) : g
	
		push!(co2, [sum(c'flatten(r[:g])) for (k, r) in results[i]])
	end

	co2
end

# ╔═╡ 0d764950-bb7d-49fb-a8d3-9e12e68c1afe
dim_total_emissions = length(total_emissions[1])

# ╔═╡ 9efcc207-4a79-4cf0-b47a-c2cc2e7e6347
function make_total_emissions_plot(ti; 
	fig=Figure(resolution=(200, 200)),
	scale=1e6
)
	ax = Axis(fig[1, 1], xgridvisible=false, ygridvisible=false)

	density!(ax, ti / scale, direction=:y, 
		strokewidth=1, strokecolor=:black, color=(:slategray, 0.7))
	ylims!(ax, 0, 2)
	ax.xticks = [-1]
	ax.ylabel = "Daily Total Emissions [gton CO2]"

	hlines!(ax, [mean(ti)/scale], color=:black)
	

	return fig, ax
end

# ╔═╡ c6f2eb39-a0e6-44bf-8649-f25ef72961a4
figure_18 = let
	ri = 3
	r_hr = 5
	fig = Figure(resolution=(650, 500), fontsize=10)

	gl1 = fig[1, 1] = GridLayout()
	gl2 = fig[1, 2] = GridLayout()

	f0, ax0 = make_total_emissions_plot(total_emissions[1], fig=gl1[1, 1])	
	f1, ax1 = make_total_emissions_plot(total_emissions[2], fig=gl1[1, 2])

	f25, ax25 = fig_distr(ri, fig=gl2[1, 1])
	ax25.xlabel = ""
	f3, ax3 = fig_distr(r_hr, fig=gl2[1, 2])
	ax3.xlabel = ""

	colgap!(gl1, 1, 6)
	colgap!(gl2, 1, 6)

	f2, ax2, sct1 = fig_map(ri, fig=fig[2, 1], ms=6, clims=(0.25, 1.25))
	f4, ax4, sct2 = fig_map(r_hr, fig=fig[2, 2], ms=6, clims=(0.25, 1.25))
	
	cb = Colorbar(fig[2, 3], sct1, label="LME [ton CO2 / MWh]")
	cb.tellheight = true

	ylims!(ax25, 0.25, 1.25)
	ylims!(ax3, 0.25, 1.25)

	#colsize!(fig.layout, 1, Auto(0.3))
	#colsize!(fig.layout, 0, Auto(0.3))
	
	ax2.title = "2018"
	ax4.title= "High Renewable"
	
	#ax1.ylabel = "LME [ton CO2 / MWh]"
	ax25.ylabel = "Nodal LMEs [ton CO2 / MWh]"

	ax1.yticks = [-10]
	ax3.yticks = [-10]
	ax1.ylabel = ""
	ax3.ylabel = ""
	
	ax0.title = "2018"
	ax1.title = "High Renewable"
	ax25.title = "2018"
	ax3.title = "High Renewable"

	for (label, layout) in zip(["A", "B", "C", "D"], [fig[1, 1], fig[1, 2], fig[2, 1], fig[2, 2]])
    	Label(layout[1, 1, TopLeft()], label,
	        textsize = 18,
			font="Noto Sans Bold",
	        padding = (0, -8, 0, 0),
	        halign = :right
		)
	end

	# Label(fig[1, 1:2], "Nodal LMEs at 6 PM in August", 
	# 	textsize=10,
	# 	padding=(0, 0, 0, 0),
	# 	valign=:bottom
	# )
	
	colgap!(fig.layout, 1, 20)
	rowgap!(fig.layout, 1, 20)

	fig
end

# ╔═╡ 5154fdd8-a58d-4faa-aced-7212ed0dc705
save(joinpath(RESULTS_DIR, "fig_240_map_month$(mnth)_hr$(hr).pdf"), figure_18)

# ╔═╡ 7b14b74e-bc68-4fe7-9a6e-5e58f322f02d
md"""
## Compute deviations between results
"""

# ╔═╡ 19bcbdad-4c42-4bbd-a0f9-5db9709e84be
begin
	_d(r) = abs(r)^2
	metric_all = (x, y) -> begin
		if (size(x) != size(y)) || (length(x) == 0)
			missing
		else
			( sum(_d, x-y) / (sqrt(sum(_d, x)) * sqrt(sum(_d, y))) )^(1/2)
		end
	end
end

# ╔═╡ d199eb5e-ce69-440f-998d-9c6c09511848
function get_deviations(metric, r1, r2)
    # Get all date-times in R1 and R2
    dts = intersect(keys(r1.data), keys(r2.data))

    # Compute deviations for all date-times in both
    mef = (ri, dt) -> analysis.get_nodal_mefs(ri.data, d -> dayofyear(d) == dayofyear(dt), hybrid_mode=ri.hm)

	r = []
	for dt in dts
		m1 = mef(r1, dt)
		m2 = mef(r2, dt)
		for i in 1:num_nodes
			err = metric(m1[i, :], m2[i, :])
			!ismissing(err) && push!(r, err)
		end
	end

    return r
end

# ╔═╡ f0216b2c-f165-4265-8fba-8b124cc0e9a1
devs1, devs2 = let
	i = 5  # 5, 10, 15
		
	metric = metric_all
	agg = d -> StatsBase.mean(d)

	r_no_storage = (data=results[4], hm=false)
	r_storage_static = (data=results[i], hm=true)
	r_storage_dynamic = (data=results[i], hm=false)

	# Compute deviations
	devs1 = get_deviations(metric, r_no_storage, r_storage_dynamic)
	devs2 = get_deviations(metric, r_storage_static, r_storage_dynamic)

	devs1, devs2
end;

# ╔═╡ de2bb00f-3d3a-4487-bd67-d867a6641e3a
length(devs2)

# ╔═╡ dbbe9c67-6a5a-4c31-ba0c-1ae57878e52f
StatsBase.quantile(devs2, 0.95)

# ╔═╡ 0e241122-3b83-4ab9-8f8a-a83f2e154fb9
sample_devs = let
	Random.seed!(0)
	Real.(StatsBase.sample(devs2[devs2 .< 1.5], 10_000, replace=false))
end

# ╔═╡ c4275ffc-d383-4da7-8ec6-9877f4343b3d
length(sample_devs)

# ╔═╡ 3aeeec7f-764c-4a08-9d6d-3d2653ccf944
StatsBase.median(devs2)

# ╔═╡ 56065ebb-9d06-427c-bddc-fb02b803203e
function make_error_figure(fig = Figure(resolution=(600, 200), fontsize=10))
	#  Make plot
	ax = Axis(fig[1, 1], xgridvisible=false, ygridvisible=false)

	xs = repeat(1:3, inner=length(devs1[1]))
	dl = (0, 0.3)
	
	density!(ax, sample_devs, label="Fixed Storage vs Dynamic", 
		npoints=500, strokewidth=2, bandwidth=0.05, color=(:gray, 0.5))

	xlims!(0.0, 1.5)
	#xlims!(0.0, 1.0)
	ax.xlabel = "Relative RMS Deviation"
	ax.ylabel = "Frequency"

	fig
end

# ╔═╡ b633d77f-f32f-4837-bfa6-2bf0d1e24852
findall(i -> in_rect(i, p_sacramento.x, p_sacramento.y, 0.25), 1:num_nodes)

# ╔═╡ 09b46920-5066-46b0-8df2-787b87a877dc
# let
# 	i = 205  # 240, 211, 94, 138
# 		fig_time(
# 		run_id=[5, 5], 
# 		hybrid_mode=[true, false],
# 		labels=["Static", "Dynamic"],
# 		regions=[((x=x[i], y=y[i]), 0.1)], 
# 		whichdates=d -> true,
# 	)[1]
# end

# ╔═╡ 92b92ca5-b89d-4221-8c61-3da679f7fe24
let
	fig = Figure(resolution=(650, 250), fontsize=10)
	
	make_error_figure(fig[1, 1])

	grid = fig[1, 2] = GridLayout()

	axes = []
	for (loc, i, t) in zip(
		[(1, 1), (1, 2), (2, 1)], 
		[240, 211, 94],
		["Sacramento", "Wyoming", "San Francisco"]
	)
		_, ax = fig_time(
			fig=grid[loc...],
			run_id=[5, 5], 
			hybrid_mode=[true, false],
			labels=["Static", "Dynamic"],
			regions=[((x=x[i], y=y[i]), 0.1)], 
			whichdates=d -> true, #month(d) == mnth),
		)
		ax.ytickformat = ys -> string.(ys/1e3)
		ax.title = t
		push!(axes, ax)
	end

	Legend(grid[2, 2], axes[3])
	colsize!(grid, 2, Relative(0.5))

	axes[1].xlabel = ""
	axes[2].xlabel = ""
	
	axes[2].ylabel = ""

	for (label, layout) in zip(["A", "B"], [fig[1, 1], fig[1, 2]])
    	Label(layout[1, 1, TopLeft()], label,
	        textsize = 18,
			font="Noto Sans Bold",
	        padding = (0, -8, 0, 0),
	        halign = :right
		)
	end
	
	save(joinpath(RESULTS_DIR, "fig_240_error.pdf"), fig)
	fig
end

# ╔═╡ d65a97f9-426c-4a21-85f5-76daf68b2b96
fuel

# ╔═╡ 00eef9dd-ebe5-410b-8aaa-a09743705548
let
	r = results[5][DateTime(18, 07, 10, 00)]
	is_renew = map(f -> f in ["PV-1", "PV-2", "Wind-1", "Wind-2"], fuel)
	
	gr = [
		sum(r[:g][h]) - sum(r[:d][h])
		for h in 1:24
	]

	lines(gr)

	c = cases[5][:co2_rates][fuel .== "Steam"]
	c
end

# ╔═╡ 6acf8b05-53c1-444c-93e3-d3ff1ce2fb3c
md"""# Exploring the changes in distributions of LMEs"""

# ╔═╡ cfe44d37-6e91-463c-b18c-0096f5c6b40f
unique_fuels = sort(unique(cases[r_hr][:fuel]))

# ╔═╡ f1985da7-f96c-4a01-8e29-2b354349a130
function total_mef(r)
	return dropdims(sum(r, dims=2), dims=2)
end

# ╔═╡ 12405d50-bcba-4edd-813c-76a5b8775e6b
# total mefs per node
begin
	λ_tot_18 = reduce(
		hcat, total_mef(results[ri][dt][:λ])[:,hr] for dt in  filter(x -> month(x) == mnth, keys(results[ri]))
	);
	
	λ_tot_hr = reduce(
		hcat, total_mef(results[r_hr][dt][:λ])[:,hr] for dt in  filter(x -> month(x) == mnth, keys(results[r_hr]))
	);
end;

# ╔═╡ 66c5ec69-3155-4a73-af06-4597f2b09dfa
begin

	dim = 2

	μ_18 = dropdims(mean(λ_tot_18, dims=dim), dims=dim)
	σ_18 = dropdims(std(λ_tot_18, dims=dim), dims=dim)
	CV_18 = σ_18 ./ μ_18
	
	μ_hr = dropdims(mean(λ_tot_hr, dims=dim), dims=dim)
	σ_hr = dropdims(std(λ_tot_hr, dims=dim), dims=dim)
	CV_hr = σ_hr ./ μ_hr

end

# ╔═╡ eb21dad6-54dd-40aa-9e4d-e877bf901367
# coefficient of variation

let
	fig = Figure()#resolution=(650, 500), fontsize=10)
	ax = Axis(fig[1,1], xlabel="Day of month",ylabel="CV = σ/μ")
	lines!(CV_18, label="2018", title="test")
	lines!(CV_hr, label="HR")
	fig
end

# ╔═╡ b7f4a04e-ca6d-4340-8641-e305840e368d
size(λ_tot_18)

# ╔═╡ 66707e17-02ec-416e-b9f0-9b6168acd0ae
idx_plot = 14

# ╔═╡ fd18b8a9-c7d0-483a-9603-82ffe45f2414
#lme trajectories
let
	fig = Figure()

	ax = Axis(fig[1,1], xlabel="day of the month", ylabel="λ", title="node = $(idx_plot)")
	
	lines!(λ_tot_18[idx_plot, :])
	lines!(λ_tot_hr[idx_plot, :])
	fig
end

# ╔═╡ aca9781b-0ee1-431a-83d0-f15975a03f43
begin
	# correlation patterns of lmes
	cor_18 = cor(λ_tot_18, dims=2)
	cor_hr = cor(λ_tot_hr, dims=2)

	cor_X = cor(λ_tot_18, λ_tot_hr, dims=2)
end;

# ╔═╡ d7c4adcb-c0b2-4cc8-9673-eeaca80ec033
heatmap(cor_18)

# ╔═╡ 547d5a4a-b3db-4fb3-acfc-3ab8123e0b6e
heatmap(cor_hr)

# ╔═╡ a1570dd5-53bb-441e-a3b7-0b439ede76f0
heatmap(cor_X)

# ╔═╡ f816914a-cce7-4f5e-998b-c84666666d73
# difference in lmes between the same nodes under the different scenarios
Δλ = reduce(vcat, [
		reduce(hcat, 
			(total_mef(results[ri][dt][:λ]) .- total_mef(results[r_hr][dt][:λ]))[:, hr])
		for (dt) in filter(x -> month(x) == mnth, keys(results[ri]))
]);

# ╔═╡ 1896e6f3-606f-4b84-88e4-a62a7a739cfe
begin
	q10 = [quantile(Δλ[x, :], .1) for x in 1:31]
	q50 = dropdims(median(Δλ, dims=2), dims=2)
	q90 = [quantile(Δλ[x, :], .9) for x in 1:31]
	
end

# ╔═╡ 97bf2231-c34a-4086-8d44-cb1c4c6bbeae
begin
	p = plot(q50, color=:blue)
	plot!(q10)
	plot!(q90, color=:orange)
	p
end

# ╔═╡ a64bba16-67e4-4782-858c-4a88308010ad
size(Δλ, 2)

# ╔═╡ 74cc43ef-58c3-4cc0-a0f6-be9066285fc5
# difference for every node
begin
	q10_n = [quantile(Δλ[:, x], .1) for x in 1:size(Δλ, 2)]
	q50_n = dropdims(median(Δλ, dims=1), dims=1)
	q90_n = [quantile(Δλ[:, x], .9) for x in 1:size(Δλ, 2)]
	
end

# ╔═╡ 17780900-89c3-4e92-b35c-a2360aa9c9a0
sp = sortperm(q50_n)

# ╔═╡ e2bc41ca-37d6-449c-a773-1757947fa09c
let
	p = lines(q50_n[sp])
	lines!(q90_n[sp], color=:orange)
	lines!(q10_n[sp], color=:green)
	p
end

# ╔═╡ e317f9b7-b25b-4489-b9af-0ff050cdd0b1
function fraction_demand_per_resource_type(r, resource_type)
	fuel = cases[r][:fuel]
	gens = map(f -> f in [resource_type], fuel)

	total_generation = reduce(hcat, [
		reduce(hcat, results[r][dt][:g])[gens, hr] for (dt) in filter(x -> month(x) == mnth, keys(results[r]))
			])

	total_demand = [
		sum(reduce(hcat, results[r][dt][:d])[:, hr]) for (dt) in filter(x -> month(x) == mnth, keys(results[r]))
	]

	total_generation = dropdims(sum(total_generation, dims=1), dims=1)

	resource_frac =  total_generation ./ total_demand

	return resource_frac, total_generation, total_demand
	
end

# ╔═╡ 86f1d6f6-9dc1-40d2-bac1-3ec14ff214b7
unique_fuels

# ╔═╡ 28d5a15b-0b6a-45f2-8929-405cd78c85aa
fracs_demand = Dict(f => (fraction_demand_per_resource_type(ri, f)[1], fraction_demand_per_resource_type(r_hr, f)[1]) for f in unique_fuels)

# ╔═╡ f2b80c29-2ddd-43f4-9f84-89c1dfd54502
# tot_gen = Dict(f => (fraction_demand_per_resource_type(ri, f)[2], fraction_demand_per_resource_type(r_hr, f)[2]) for f in unique_fuels)

# ╔═╡ 17275cb2-751d-4e12-9810-a394487db6af
let
	bar_x = [1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9]
	bar_y = [median(fracs_demand[f][k]) for f in unique_fuels for k in 1:2]
	gp = [1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2]
	
	colors = Makie.wong_colors()
	
	fig = Figure()
	
	ax = Axis(fig[1,1], xticks = (1:length(unique_fuels), unique_fuels),
	                title = "Mean fraction of demand met by resource type")
	
	barplot!(bar_x, bar_y,
	        dodge = gp,
	        color = colors[gp],
	        )
	
	# Legend
	labels = ["2018", "HR"]
	elements = [PolyElement(polycolor = colors[i]) for i in 1:length(labels)]
	title = "Groups"
	
	Legend(fig[1,2], elements, labels, title)
	fig
end

# ╔═╡ a5dec126-a70e-44f2-b39f-5cf1e35707f9
function available_capacity(r, resource_type, q)
	c = cases[r][:co2_rates]
	fuel = cases[r][:fuel]
	gmax = cases[r][:gmax]

	gens = map(f -> f in [resource_type], fuel)

	# TODO filter by date and month
	all_available_capacities = [
		reduce(hcat, r_[:gmax] .- r_[:g])[:, hr]
		for (dt, r_) in filter(pr -> month(pr[1]) == mnth, results[r])
	]


	
	max_capacities_for_resource = [
		reduce(hcat, r_[:gmax])[:, hr]
		for (dt, r_) in filter(pr -> month(pr[1]) == mnth, results[r])
	]

	# here you average before taking the capacities
	# total_available_capacity_for_resource = 
		# sum(mean(all_available_capacities)[gens])
	# total_max_capacity_for_resource = sum(mean(max_capacities_for_resource)[gens])
	# return total_available_capacity_for_resource / total_max_capacity_for_resource

	# @show size(all_available_capacities)
	frac = reduce(hcat, [all_available_capacities[k][gens] ./ (max_capacities_for_resource[k][gens] .+ 1e-4) for k in 1:length(all_available_capacities)])

	# here I think I am taking the quantile across all days and generators... at least I am not sure what I am doing really? 
	# NO because I am taking the mean!
	frac_qs = quantile([mean(all_available_capacities[k][gens] ./ (max_capacities_for_resource[k][gens] .+ 1e-4)) for k in 1:length(all_available_capacities)], q)
	
	return frac, frac_qs
end

# ╔═╡ a53cef1b-e064-407b-82af-9db8ff319dbe
begin
	q_ = .5
	
	av_cap = Dict(f => (available_capacity(ri, f, q_)[2], available_capacity(r_hr, f, q_)[2]) for f in unique_fuels)
end

# ╔═╡ f3733150-48df-4511-9578-f46dab8b6b75
let
	bar_x = [1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9]
	bar_y = [median(av_cap[f][k]) for f in unique_fuels for k in 1:2]
	gp = [1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2]
	
	colors = Makie.wong_colors()
	
	fig = Figure()
	
	ax = Axis(fig[1,1], xticks = (1:length(unique_fuels), unique_fuels),
	                title = "Available capacity per fuel type")
	
	barplot!(bar_x, bar_y,
	        dodge = gp,
	        color = colors[gp],
	        )
	
	# Legend
	labels = ["2018", "HR"]
	elements = [PolyElement(polycolor = colors[i]) for i in 1:length(labels)]
	title = "Groups"
	
	Legend(fig[1,2], elements, labels, title)
	fig
end

# ╔═╡ 358f606a-b200-4833-81f1-fd7663c12bba
md"""
one way to plot this effectively is to show the proportion of the time it is effectively zero (i.e. number of days where the available capacity is zero among all generators)

another way is to ask how many generators are open
"""

# ╔═╡ 9f994d3d-b343-455e-9da8-2b0c871da5fa
av_cap_vec = Dict(
	f => (available_capacity(ri, f, .6)[1], available_capacity(r_hr, f, .6)[1]) for f in unique_fuels
);

# ╔═╡ 51e898b8-6d45-4eb2-ae15-ee88fd153a40
proportion_available_generators = Dict(
	f => (prop_av_gens(av_cap_vec[f][1]), prop_av_gens(av_cap_vec[f][2]))
	for f in unique_fuels
)

# ╔═╡ 5df243e2-3813-4623-86ba-6d6e77d4a8b0
"""proportion of available generators"""
prop_av_gens(frac) = dropdims(
	sum(
		frac .> 1e-6, dims=1)/size(frac,1)
	, dims=1
)

# ╔═╡ c9e431db-49a3-40fe-8437-0b4e95625118
av_cap_vec["Steam"][1]

# ╔═╡ 76aa2360-d03e-4c92-be36-70f2a0bc0352
let
	q = .5
	bar_x = [1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9]
	bar_y = [
		quantile(proportion_available_generators[f][k], q) 
		for f in unique_fuels for k in 1:2
	]
	gp = [1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2]
	
	colors = Makie.wong_colors()
	
	fig = Figure()
	
	ax = Axis(fig[1,1], xticks = (1:length(unique_fuels), unique_fuels),
	                title = "Proportion of available generators")
	
	barplot!(bar_x, bar_y,
	        dodge = gp,
	        color = colors[gp],
	        )
	
	# Legend
	labels = ["2018", "HR"]
	elements = [PolyElement(polycolor = colors[i]) for i in 1:length(labels)]
	title = "Groups"
	
	Legend(fig[1,2], elements, labels, title)
	fig
end

# ╔═╡ 0b079fc2-8643-4681-aca7-a4b1aeaf6034
@bind ff Select(unique_fuels)

# ╔═╡ 41b5a11c-df97-485c-a919-e0639d426d33
begin
	qs = LinRange(0, 1, 100)

	xx = Dict(
		f=> reduce(vcat, [available_capacity(ri, f, q)[2] for q in qs]) for f in unique_fuels
	)
	xx_hr = Dict(
		f=> reduce(vcat, [available_capacity(r_hr, f, q)[2] for q in qs]) for f in unique_fuels
	)

	pl = lines(qs, xx[ff])
	lines!(qs, xx_hr[ff])
	pl
	
end

# ╔═╡ 38590154-c38f-4c25-9e30-f6a5ceb4b578
kk = collect(keys(results[ri]))[1]

# ╔═╡ 57232842-7f1b-4b4a-819c-842cb5192c7f
collect(keys(results[ri][kk]))

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BSON = "fbb218c0-5317-5bc6-957e-2ee96dd4b1f0"
CairoMakie = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
Downloads = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
GeoMakie = "db073c08-6b98-4ee5-b6a4-5efafb3259c6"
InlineStrings = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
LightGraphs = "093fc24a-ae57-5d10-9952-331d41423f4d"
Makie = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Proj4 = "9a7e659c-8ee8-5706-894e-f68f43bc57ea"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
TOML = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
XLSX = "fdbf4ff8-1666-58a4-91e7-1b58723a45e0"

[compat]
BSON = "~0.3.5"
CairoMakie = "~0.8.8"
DataFrames = "~1.3.4"
GeoMakie = "~0.4.1"
InlineStrings = "~1.1.2"
LightGraphs = "~1.3.5"
Makie = "~0.17.8"
PlutoUI = "~0.7.39"
Proj4 = "~0.7.6"
StatsBase = "~0.33.17"
XLSX = "~0.7.10"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.2"
manifest_format = "2.0"

[[deps.AbstractFFTs]]
deps = ["ChainRulesCore", "LinearAlgebra"]
git-tree-sha1 = "69f7020bd72f069c219b5e8c236c1fa90d2cb409"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.2.1"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.AbstractTrees]]
git-tree-sha1 = "52b3b436f8f73133d7bc3a6c71ee7ed6ab2ab754"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.3"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "195c5505521008abea5aee4f96930717958eac6f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.4.0"

[[deps.Animations]]
deps = ["Colors"]
git-tree-sha1 = "e81c509d2c8e49592413bfb0bb3b08150056c79d"
uuid = "27a7e980-b3e6-11e9-2bcd-0b925532e340"
version = "0.4.1"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "f87e559f87a45bece9c9ed97458d3afe98b1ebb9"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.1.0"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Automa]]
deps = ["Printf", "ScanByte", "TranscodingStreams"]
git-tree-sha1 = "d50976f217489ce799e366d9561d56a98a30d7fe"
uuid = "67c07d97-cdcb-5c2c-af73-a7f9c32a568b"
version = "0.8.2"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[deps.BSON]]
git-tree-sha1 = "86e9781ac28f4e80e9b98f7f96eae21891332ac2"
uuid = "fbb218c0-5317-5bc6-957e-2ee96dd4b1f0"
version = "0.3.6"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.CEnum]]
git-tree-sha1 = "eb4cb44a499229b3b8426dcfb5dd85333951ff90"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.2"

[[deps.Cairo]]
deps = ["Cairo_jll", "Colors", "Glib_jll", "Graphics", "Libdl", "Pango_jll"]
git-tree-sha1 = "d0b3f8b4ad16cb0a2988c6788646a5e6a17b6b1b"
uuid = "159f3aea-2a34-519c-b102-8c37f9878175"
version = "1.0.5"

[[deps.CairoMakie]]
deps = ["Base64", "Cairo", "Colors", "FFTW", "FileIO", "FreeType", "GeometryBasics", "LinearAlgebra", "Makie", "SHA"]
git-tree-sha1 = "387e0102f240244102814cf73fe9fbbad82b9e9e"
uuid = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
version = "0.8.13"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

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

[[deps.ColorBrewer]]
deps = ["Colors", "JSON", "Test"]
git-tree-sha1 = "61c5334f33d91e570e1d0c3eb5465835242582c4"
uuid = "a2cac450-b92f-5266-8821-25eda20663c8"
version = "0.4.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "1fd869cc3875b57347f7027521f561cf46d1fcd8"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.19.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "d08c20eef1f2cbc6e60fd3612ac4340b89fea322"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.9"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "3ca828fe1b75fa84b021a7860bd039eaea84d2f2"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.3.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.CoordinateTransformations]]
deps = ["LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "681ea870b918e7cff7111da58791d7f718067a19"
uuid = "150eb455-5306-5404-9cee-2592286d6298"
version = "0.6.2"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "e08915633fcb3ea83bf9d6126292e5bc5c739922"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.13.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "db2a9cb664fcea7836da4b414c3278d71dd602d2"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.3.6"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "bee795cdeabc7601776abbd6b9aac2ca62429966"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.77"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "c36550cb29cbe373e95b3f40486b9a4148f89ffd"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.2"

[[deps.Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e3290f2d49e661fbd94046d7e3726ffcb2d41053"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.4+0"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[deps.EzXML]]
deps = ["Printf", "XML2_jll"]
git-tree-sha1 = "0fa3b52a04a4e210aeb1626def9c90df3ae65268"
uuid = "8f5d6c58-4d21-5cfd-889c-e3ad7ee6a615"
version = "1.1.0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "74faea50c1d007c85837327f6775bea60b5492dd"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+2"

[[deps.FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "90630efff0894f8142308e334473eba54c433549"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.5.0"

[[deps.FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "7be5f99f7d15578798f338f5433b6c432ea8037b"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.16.0"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "802bfc139833d2ba893dd9e62ba1767c88d708ae"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.5"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.FreeType]]
deps = ["CEnum", "FreeType2_jll"]
git-tree-sha1 = "cabd77ab6a6fdff49bfd24af2ebe76e6e018a2b4"
uuid = "b38be410-82b0-50bf-ab77-7b57e271db43"
version = "4.0.0"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FreeTypeAbstraction]]
deps = ["ColorVectorSpace", "Colors", "FreeType", "GeometryBasics"]
git-tree-sha1 = "b5c7fe9cea653443736d264b85466bad8c574f4a"
uuid = "663a7486-cb36-511b-a19d-713bb74d65c9"
version = "0.9.9"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GeoInterface]]
deps = ["RecipesBase"]
git-tree-sha1 = "6b1a29c757f56e0ae01a35918a2c39260e2c4b98"
uuid = "cf35fbd7-0cd7-5166-be24-54bfbe79505f"
version = "0.5.7"

[[deps.GeoJSON]]
deps = ["GeoInterface", "JSON3"]
git-tree-sha1 = "4764da92d333658552b2bedc9f6b379f017c727b"
uuid = "61d90e0f-e114-555e-ac52-39dfb47a3ef9"
version = "0.5.1"

[[deps.GeoMakie]]
deps = ["Colors", "Downloads", "GeoInterface", "GeoJSON", "GeometryBasics", "ImageIO", "LinearAlgebra", "Makie", "Proj4", "Reexport", "Statistics", "StructArrays"]
git-tree-sha1 = "058e09689b320721f7abae9291e0b04f6df7f38b"
uuid = "db073c08-6b98-4ee5-b6a4-5efafb3259c6"
version = "0.4.1"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "83ea630384a13fc4f002b77690bc0afeb4255ac9"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.2"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "d3b3624125c1474292d0d8ed0f65554ac37ddb23"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.74.0+2"

[[deps.Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "d61890399bc535850c4bf08e4e0d3a7ad0f21cbd"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.2"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.GridLayoutBase]]
deps = ["GeometryBasics", "InteractiveUtils", "Observables"]
git-tree-sha1 = "678d136003ed5bceaab05cf64519e3f956ffa4ba"
uuid = "3955a311-db13-416c-9275-1d80ed98e5e9"
version = "0.9.1"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "OpenLibm_jll", "SpecialFunctions", "Test"]
git-tree-sha1 = "709d864e3ed6e3545230601f94e11ebc65994641"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.11"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.ImageCore]]
deps = ["AbstractFFTs", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Graphics", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "Reexport"]
git-tree-sha1 = "acf614720ef026d38400b3817614c45882d75500"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.9.4"

[[deps.ImageIO]]
deps = ["FileIO", "IndirectArrays", "JpegTurbo", "LazyModules", "Netpbm", "OpenEXR", "PNGFiles", "QOI", "Sixel", "TiffImages", "UUIDs"]
git-tree-sha1 = "342f789fd041a55166764c351da1710db97ce0e0"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.6.6"

[[deps.Imath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "87f7662e03a649cffa2e05bf19c303e168732d3e"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.1.2+0"

[[deps.IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[deps.Inflate]]
git-tree-sha1 = "5cd07aab533df5170988219191dfad0519391428"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.3"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "d19f9edd8c34760dca2de2b503f969d8700ed288"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.1.4"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Interpolations]]
deps = ["Adapt", "AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "842dd89a6cb75e02e85fdd75c760cdc43f5d6863"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.14.6"

[[deps.IntervalSets]]
deps = ["Dates", "Random", "Statistics"]
git-tree-sha1 = "3f91cd3f56ea48d4d2a75c2a65455c5fc74fa347"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.7.3"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[deps.InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.Isoband]]
deps = ["isoband_jll"]
git-tree-sha1 = "f9b6d97355599074dc867318950adaa6f9946137"
uuid = "f1662d9f-8043-43de-a69a-05efc1cc6ff4"
version = "0.1.1"

[[deps.IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.JSON3]]
deps = ["Dates", "Mmap", "Parsers", "SnoopPrecompile", "StructTypes", "UUIDs"]
git-tree-sha1 = "84b10656a41ef564c39d2d477d7236966d2b5683"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.12.0"

[[deps.JpegTurbo]]
deps = ["CEnum", "FileIO", "ImageCore", "JpegTurbo_jll", "TOML"]
git-tree-sha1 = "a77b273f1ddec645d1b7c4fd5fb98c8f90ad10a5"
uuid = "b835a17e-a41a-41e7-81f0-2f016b05efe0"
version = "0.1.1"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b53380851c6e6664204efb2e62cd24fa5c47e4ba"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.2+0"

[[deps.KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTW", "Interpolations", "StatsBase"]
git-tree-sha1 = "9816b296736292a80b9a3200eb7fbb57aaa3917a"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.5"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LazyModules]]
git-tree-sha1 = "a560dd966b386ac9ae60bdd3a3d3a326062d3c3e"
uuid = "8cdb02fc-e678-4876-92c5-9defec4f444e"
version = "0.3.1"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c7cb1f5d892775ba13767a87c7ada0b980ea0a71"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+2"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "3eb79b0ca5764d4799c06699573fd8f533259713"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.4.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LightGraphs]]
deps = ["ArnoldiMethod", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "432428df5f360964040ed60418dd5601ecd240b6"
uuid = "093fc24a-ae57-5d10-9952-331d41423f4d"
version = "1.3.5"

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

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "2ce8695e1e699b68702c03402672a69f54b8aca9"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2022.2.0+0"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.Makie]]
deps = ["Animations", "Base64", "ColorBrewer", "ColorSchemes", "ColorTypes", "Colors", "Contour", "Distributions", "DocStringExtensions", "FFMPEG", "FileIO", "FixedPointNumbers", "Formatting", "FreeType", "FreeTypeAbstraction", "GeometryBasics", "GridLayoutBase", "ImageIO", "IntervalSets", "Isoband", "KernelDensity", "LaTeXStrings", "LinearAlgebra", "MakieCore", "Markdown", "Match", "MathTeXEngine", "Observables", "OffsetArrays", "Packing", "PlotUtils", "PolygonOps", "Printf", "Random", "RelocatableFolders", "Serialization", "Showoff", "SignedDistanceFields", "SparseArrays", "Statistics", "StatsBase", "StatsFuns", "StructArrays", "UnicodeFun"]
git-tree-sha1 = "b0323393a7190c9bf5b03af442fc115756df8e59"
uuid = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
version = "0.17.13"

[[deps.MakieCore]]
deps = ["Observables"]
git-tree-sha1 = "fbf705d2bdea8fc93f1ae8ca2965d8e03d4ca98c"
uuid = "20f20a25-4f0e-4fdf-b5d1-57303727442b"
version = "0.4.0"

[[deps.MappedArrays]]
git-tree-sha1 = "e8b359ef06ec72e8c030463fe02efe5527ee5142"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.1"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.Match]]
git-tree-sha1 = "1d9bc5c1a6e7ee24effb93f175c9342f9154d97f"
uuid = "7eb4fadd-790c-5f42-8a69-bfa0b872bfbf"
version = "1.2.0"

[[deps.MathTeXEngine]]
deps = ["AbstractTrees", "Automa", "DataStructures", "FreeTypeAbstraction", "GeometryBasics", "LaTeXStrings", "REPL", "RelocatableFolders", "Test"]
git-tree-sha1 = "114ef48a73aea632b8aebcb84f796afcc510ac7c"
uuid = "0a4f8689-d25c-4efe-a92b-7142dfc1aa53"
version = "0.4.3"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "b34e3bc3ca7c94914418637cb10cc4d1d80d877d"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.3"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "a7c3d1da1189a1c2fe843a3bfa04d18d20eb3211"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.1"

[[deps.Netpbm]]
deps = ["FileIO", "ImageCore"]
git-tree-sha1 = "18efc06f6ec36a8b801b23f076e3c6ac7c3bf153"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.0.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.Observables]]
git-tree-sha1 = "6862738f9796b3edc1c09d0890afce4eca9e7e93"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.5.4"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "f71d8950b724e9ff6110fc948dff5a329f901d64"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.12.8"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.OpenEXR]]
deps = ["Colors", "FileIO", "OpenEXR_jll"]
git-tree-sha1 = "327f53360fdb54df7ecd01e96ef1983536d1e633"
uuid = "52e1d378-f018-4a11-a4be-720524705ac7"
version = "0.3.2"

[[deps.OpenEXR_jll]]
deps = ["Artifacts", "Imath_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "923319661e9a22712f24596ce81c54fc0366f304"
uuid = "18a262bb-aa17-5467-a713-aee519bc75cb"
version = "3.1.1+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6e9dba33f9f2c44e08a020b0caf6903be540004"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.19+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "cf494dca75a69712a72b80bc48f59dcf3dea63ec"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.16"

[[deps.PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "f809158b27eba0c18c269cf2a2be6ed751d3e81d"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.3.17"

[[deps.PROJ_jll]]
deps = ["Artifacts", "JLLWrappers", "LibCURL_jll", "LibSSH2_jll", "Libdl", "Libtiff_jll", "MbedTLS_jll", "Pkg", "SQLite_jll", "Zlib_jll", "nghttp2_jll"]
git-tree-sha1 = "2435e91710d7f97f53ef7a4872bf1f948dc8e5f8"
uuid = "58948b4f-47e0-5654-a9ad-f609743f8632"
version = "700.202.100+0"

[[deps.Packing]]
deps = ["GeometryBasics"]
git-tree-sha1 = "1155f6f937fa2b94104162f01fa400e192e4272f"
uuid = "19eb6ba3-879d-56ad-ad62-d5c202156566"
version = "0.4.2"

[[deps.PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "03a7a85b76381a3d04c7a1656039197e70eda03d"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.11"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "84a314e3926ba9ec66ac097e3635e270986b0f10"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.50.9+0"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "b64719e8b4504983c7fca6cc9db3ebc8acc2a4d6"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.1"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "f6cf8e7944e50901594838951729a1861e668cb8"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.3.2"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "SnoopPrecompile", "Statistics"]
git-tree-sha1 = "21303256d239f6b484977314674aef4bb1fe4420"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.1"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "efc140104e6d0ae3e7e30d56c98c4a927154d684"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.48"

[[deps.PolygonOps]]
git-tree-sha1 = "77b3d3605fc1cd0b42d95eba87dfcd2bf67d5ff6"
uuid = "647866c9-e3ac-4575-94e7-e3d426903924"
version = "0.1.2"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "dfb54c4e414caa595a1f2ed759b160f5a3ddcba5"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.3.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "d7a7aef8f8f2d537104f170139553b14dfe39fe9"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.7.2"

[[deps.Proj4]]
deps = ["CEnum", "CoordinateTransformations", "PROJ_jll", "StaticArrays"]
git-tree-sha1 = "5f15f1c647b563e49f655fbbfd4e2ade24bd3c64"
uuid = "9a7e659c-8ee8-5706-894e-f68f43bc57ea"
version = "0.7.6"

[[deps.QOI]]
deps = ["ColorTypes", "FileIO", "FixedPointNumbers"]
git-tree-sha1 = "18e8f4d1426e965c7b532ddd260599e1510d26ce"
uuid = "4b34888f-f399-49d4-9bb3-47ed5cae4e65"
version = "1.0.0"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "97aa253e65b784fd13e83774cadc95b38011d734"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.6.0"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "dc84268fe0e3335a62e315a3a7cf2afa7178a734"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.3"

[[deps.RecipesBase]]
deps = ["SnoopPrecompile"]
git-tree-sha1 = "d12e612bba40d189cead6ff857ddb67bd2e6a387"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.1"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "22c5201127d7b243b9ee1de3b43c408879dff60f"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "0.3.0"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.SIMD]]
git-tree-sha1 = "bc12e315740f3a36a6db85fa2c0212a848bd239e"
uuid = "fdea26ae-647d-5447-a871-4b548cad5224"
version = "3.4.2"

[[deps.SQLite_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "9d920c4ee8cd5684e23bf84f43ead45c0af796e7"
uuid = "76ed43ae-9a5d-5a62-8c75-30186b810ce8"
version = "3.39.4+0"

[[deps.ScanByte]]
deps = ["Libdl", "SIMD"]
git-tree-sha1 = "2436b15f376005e8790e318329560dcc67188e84"
uuid = "7b38b023-a4d7-4c5e-8d43-3f3097f304eb"
version = "0.3.3"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "f94f779c94e58bf9ea243e77a37e16d9de9126bd"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SignedDistanceFields]]
deps = ["Random", "Statistics", "Test"]
git-tree-sha1 = "d263a08ec505853a5ff1c1ebde2070419e3f28e9"
uuid = "73760f76-fbc4-59ce-8f25-708e95d2df96"
version = "0.4.0"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[deps.Sixel]]
deps = ["Dates", "FileIO", "ImageCore", "IndirectArrays", "OffsetArrays", "REPL", "libsixel_jll"]
git-tree-sha1 = "8fb59825be681d451c246a795117f317ecbcaa28"
uuid = "45858cf5-a6b0-47a3-bbea-62219f50df47"
version = "0.1.2"

[[deps.SnoopPrecompile]]
git-tree-sha1 = "f604441450a3c0569830946e5b33b78c928e1a85"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "a4ada03f999bd01b3a25dcaa30b2d929fe537e00"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.0"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

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

[[deps.StatsFuns]]
deps = ["ChainRulesCore", "HypergeometricFunctions", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "5783b877201a82fc0014cbf381e7e6eb130473a4"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.0.1"

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArraysCore", "Tables"]
git-tree-sha1 = "13237798b407150a6d2e2bce5d793d7d9576e99e"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.13"

[[deps.StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "ca4bccb03acf9faaf4137a9abc1881ed1841aa70"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.10.0"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "c79322d36826aa2f4fd8ecfa96ddb47b174ac78d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TiffImages]]
deps = ["ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "Mmap", "OffsetArrays", "PkgVersion", "ProgressMeter", "UUIDs"]
git-tree-sha1 = "70e6d2da9210371c927176cb7a56d41ef1260db7"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.6.1"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "8a75929dcd3c38611db2f8d08546decb514fcadf"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.9"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.URIs]]
git-tree-sha1 = "e59ecc5a41b000fa94423a578d29290c7266fc10"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "de67fa59e33ad156a590055375a30b23c40299d3"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.5"

[[deps.XLSX]]
deps = ["Dates", "EzXML", "Printf", "Tables", "ZipFile"]
git-tree-sha1 = "7fa8618da5c27fdab2ceebdff1da8918c8cd8b5d"
uuid = "fdbf4ff8-1666-58a4-91e7-1b58723a45e0"
version = "0.7.10"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "58443b63fb7e465a8a7210828c91c08b92132dff"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.14+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[deps.ZipFile]]
deps = ["Libdl", "Printf", "Zlib_jll"]
git-tree-sha1 = "3593e69e469d2111389a9bd06bac1f3d730ac6de"
uuid = "a5390f91-8eb1-5f08-bee0-b1d1ffed6cea"
version = "0.9.4"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e45044cd873ded54b6a5bac0eb5c971392cf1927"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.2+0"

[[deps.isoband_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51b5eeb3f98367157a7a12a1fb0aa5328946c03c"
uuid = "9a68df92-36a6-505f-a73e-abb412b6bfb4"
version = "0.2.3+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a2ea60308f0996d26f1e5354e10c24e9ef905d4"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.4.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libsixel_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "libpng_jll"]
git-tree-sha1 = "d4f63314c8aa1e48cd22aa0c17ed76cd1ae48c3c"
uuid = "075b6546-f08a-558a-be8f-8157d0f608a5"
version = "1.10.3+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"
"""

# ╔═╡ Cell order:
# ╠═dd32f064-95ad-4321-a740-d87ff3653b50
# ╠═5303b439-2bbb-4a04-b17e-7df6f2983493
# ╠═b3352ae6-d614-423d-bfa0-2ee28ab5b134
# ╠═d145ef02-6511-4685-bb16-b421703e7dbf
# ╠═64f8e88a-dfbf-4d25-b40e-af688e9e9f00
# ╠═c6c3d56a-3782-4272-b6c2-b1088160d675
# ╠═32e5f26a-9b2f-4fc0-a0cd-1a5f101f0db9
# ╠═e19f3dbe-b54a-45c3-b496-cf762f821ed5
# ╠═4f6b2696-e9b8-439b-ba28-8074be1ae068
# ╠═b2b2e596-0f92-4e3c-ab1c-46a0bff9fb4b
# ╠═3f03a7e6-2889-428d-984c-0995574f1fc3
# ╠═93b1dd21-6f9d-4770-acd3-fe8f625f6d46
# ╠═25d6013f-ac12-4bb6-baa0-28925dc16e66
# ╟─6db70f24-e8ba-461e-8d86-00e9a37b44d3
# ╠═f9fab4fe-baec-4bfd-9d84-ef9caac85f5f
# ╠═d7598abb-2be7-4e3b-af9e-14827ef5a3b0
# ╠═1605bc95-dd10-4ac1-b258-a58e7242d34f
# ╠═45c73bb3-eecf-4b92-8e91-6a4c83addfdc
# ╠═67130163-7a9e-4dc9-8458-b00239a1fb07
# ╠═6de86962-a420-4885-ae7a-18748549c4c2
# ╠═2757231c-ef30-417a-87dd-7d155049ba47
# ╠═9dcbc82a-2ced-4b5a-a879-cc5458d039e4
# ╟─b4f91614-ada2-4961-8913-96855f7ca81b
# ╠═5392f525-ecb3-47c7-a32f-73a6b02967df
# ╠═514b6f5f-c5d7-4937-8dec-a039b50b553c
# ╠═ba2a3175-b445-4227-a401-18ff40fc4c53
# ╠═b6e667a5-d2ed-4ab6-9c94-9e6e45be84e8
# ╠═64627393-f9b2-4c64-95c8-458cc005e237
# ╟─d2bacf4a-af37-4ff9-bebb-3dc3d06edd8a
# ╟─cbc71e2e-0bd1-441c-bf17-c60053a60795
# ╠═7a42f00e-193c-45ea-951f-dcd4e1c1975f
# ╠═5cb1709a-eda0-41b3-8bff-f58c19608be5
# ╠═ee25f56b-b3a0-4e6d-9410-72f95a15b432
# ╠═2d3cf797-4cc2-4aad-bc3e-94f5474e99f9
# ╟─fd640755-2f9d-4845-9524-fce685e9053c
# ╠═73fa2393-d2a2-429b-a84a-493acd8fb841
# ╠═9900463f-5bc6-4649-b970-9456c5712d50
# ╠═effd6c24-94ad-4803-9c30-7186a677480b
# ╠═85f3a3f3-ca15-4e70-8745-a780e069aa9b
# ╠═7771eb73-3ddb-4f80-b487-4685c1838501
# ╟─be39a732-89d0-4a8b-9c88-3acd34f96dcc
# ╠═3878f6d7-fdb5-4fe1-9b92-179f3e576ec0
# ╠═2a6bfa51-8f05-46c9-8fd3-5b3f6dd307c7
# ╠═b0805b35-6545-41ba-8dc3-45cf0072b094
# ╠═f5bc0567-9fa5-45f7-8d70-c86099559984
# ╠═35e55d76-d175-4e77-9b69-930225cb8573
# ╠═7126918a-eb31-40a9-8f2d-7e181a1fcb3b
# ╠═39ff81d3-9890-4291-8391-9cf0dbd9cf7e
# ╠═59316c15-a94c-4c56-a30a-0e6c23629de7
# ╠═07268e37-5b62-4ab3-8d0d-5bab2286cdbe
# ╠═7ffbe1bc-8cc6-4033-a70b-880209164199
# ╠═04d0d66a-8427-48a5-9c0e-e93eb619cd05
# ╠═35ec1921-8f4c-46cd-aa80-778a475b1542
# ╟─a6178160-2471-4e6f-bcd9-debb529d39d4
# ╠═ef79c984-db2a-4a1d-92e5-2d40abadcca3
# ╠═76277c5f-c415-4861-b934-c76cc07a3820
# ╠═fb62741d-d65e-4c6f-a256-5389623362ad
# ╠═a91cbac6-27ba-4238-9b9f-ed561d2267ca
# ╠═6cf44a9c-c4f8-42c8-8b19-753ad53ac62b
# ╟─34461bf7-19e6-4ca9-9238-da512d947ef4
# ╠═4c9f5116-6629-4494-a344-ea9061728956
# ╠═3a92e994-c094-4ee5-8a02-9c5c6df4551f
# ╠═971d68b9-c140-4594-a0af-4bb45f665508
# ╠═3e977d3a-01b6-428e-962f-a5128b739a78
# ╟─d6abbce4-27ba-4a1d-8fb0-ce97a40c716d
# ╠═9d35d4df-5fca-430e-bfae-b801107ffb61
# ╠═f06f51e4-98cb-4691-ab2f-acd9f5290aaa
# ╟─20e85734-92ff-4c34-9572-dd65ddd1d327
# ╠═e1a1acda-1d52-45bd-8257-8b7249318c9b
# ╠═b75419d4-a203-4103-8dc1-ea7c088f0ada
# ╠═b53cc8dd-c36e-4cf8-9f1d-473a0e985234
# ╠═76ddbef6-2ace-44e7-af9f-c71390c4955a
# ╠═5237b37a-1feb-4493-896e-60b4c0427f49
# ╠═fb306c55-5558-46db-a9c6-87a6e079304a
# ╠═0d764950-bb7d-49fb-a8d3-9e12e68c1afe
# ╠═9efcc207-4a79-4cf0-b47a-c2cc2e7e6347
# ╠═c6f2eb39-a0e6-44bf-8649-f25ef72961a4
# ╠═5154fdd8-a58d-4faa-aced-7212ed0dc705
# ╟─7b14b74e-bc68-4fe7-9a6e-5e58f322f02d
# ╠═19bcbdad-4c42-4bbd-a0f9-5db9709e84be
# ╠═d199eb5e-ce69-440f-998d-9c6c09511848
# ╠═f0216b2c-f165-4265-8fba-8b124cc0e9a1
# ╠═de2bb00f-3d3a-4487-bd67-d867a6641e3a
# ╠═abae6ee4-431a-41e2-adce-53c780e5c975
# ╠═dbbe9c67-6a5a-4c31-ba0c-1ae57878e52f
# ╠═0e241122-3b83-4ab9-8f8a-a83f2e154fb9
# ╠═c4275ffc-d383-4da7-8ec6-9877f4343b3d
# ╠═3aeeec7f-764c-4a08-9d6d-3d2653ccf944
# ╠═56065ebb-9d06-427c-bddc-fb02b803203e
# ╠═b633d77f-f32f-4837-bfa6-2bf0d1e24852
# ╠═09b46920-5066-46b0-8df2-787b87a877dc
# ╠═92b92ca5-b89d-4221-8c61-3da679f7fe24
# ╠═d65a97f9-426c-4a21-85f5-76daf68b2b96
# ╠═00eef9dd-ebe5-410b-8aaa-a09743705548
# ╟─6acf8b05-53c1-444c-93e3-d3ff1ce2fb3c
# ╠═cfe44d37-6e91-463c-b18c-0096f5c6b40f
# ╠═f1985da7-f96c-4a01-8e29-2b354349a130
# ╠═12405d50-bcba-4edd-813c-76a5b8775e6b
# ╠═66c5ec69-3155-4a73-af06-4597f2b09dfa
# ╠═eb21dad6-54dd-40aa-9e4d-e877bf901367
# ╠═b7f4a04e-ca6d-4340-8641-e305840e368d
# ╠═66707e17-02ec-416e-b9f0-9b6168acd0ae
# ╠═fd18b8a9-c7d0-483a-9603-82ffe45f2414
# ╠═aca9781b-0ee1-431a-83d0-f15975a03f43
# ╠═d7c4adcb-c0b2-4cc8-9673-eeaca80ec033
# ╠═547d5a4a-b3db-4fb3-acfc-3ab8123e0b6e
# ╠═a1570dd5-53bb-441e-a3b7-0b439ede76f0
# ╠═f816914a-cce7-4f5e-998b-c84666666d73
# ╠═1896e6f3-606f-4b84-88e4-a62a7a739cfe
# ╠═97bf2231-c34a-4086-8d44-cb1c4c6bbeae
# ╠═a64bba16-67e4-4782-858c-4a88308010ad
# ╠═74cc43ef-58c3-4cc0-a0f6-be9066285fc5
# ╠═17780900-89c3-4e92-b35c-a2360aa9c9a0
# ╠═e2bc41ca-37d6-449c-a773-1757947fa09c
# ╠═e317f9b7-b25b-4489-b9af-0ff050cdd0b1
# ╠═86f1d6f6-9dc1-40d2-bac1-3ec14ff214b7
# ╠═28d5a15b-0b6a-45f2-8929-405cd78c85aa
# ╠═f2b80c29-2ddd-43f4-9f84-89c1dfd54502
# ╠═17275cb2-751d-4e12-9810-a394487db6af
# ╠═a5dec126-a70e-44f2-b39f-5cf1e35707f9
# ╠═a53cef1b-e064-407b-82af-9db8ff319dbe
# ╠═f3733150-48df-4511-9578-f46dab8b6b75
# ╠═358f606a-b200-4833-81f1-fd7663c12bba
# ╠═9f994d3d-b343-455e-9da8-2b0c871da5fa
# ╠═51e898b8-6d45-4eb2-ae15-ee88fd153a40
# ╠═5df243e2-3813-4623-86ba-6d6e77d4a8b0
# ╠═c9e431db-49a3-40fe-8437-0b4e95625118
# ╠═76aa2360-d03e-4c92-be36-70f2a0bc0352
# ╠═0b079fc2-8643-4681-aca7-a4b1aeaf6034
# ╠═41b5a11c-df97-485c-a919-e0639d426d33
# ╠═38590154-c38f-4c25-9e30-f6a5ceb4b578
# ╠═57232842-7f1b-4b4a-819c-842cb5192c7f
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
