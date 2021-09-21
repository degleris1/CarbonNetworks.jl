{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {
    "toc": true
   },
   "source": [
    "<h1>Table of Contents<span class=\"tocSkip\"></span></h1>\n",
    "<div class=\"toc\"><ul class=\"toc-item\"><li><span><a href=\"#Generate-some-random-data\" data-toc-modified-id=\"Generate-some-random-data-1\"><span class=\"toc-item-num\">1&nbsp;&nbsp;</span>Generate some random data</a></span></li><li><span><a href=\"#Solve-the-carbon-management-problem\" data-toc-modified-id=\"Solve-the-carbon-management-problem-2\"><span class=\"toc-item-num\">2&nbsp;&nbsp;</span>Solve the carbon management problem</a></span></li><li><span><a href=\"#Test-the-dynamic-network\" data-toc-modified-id=\"Test-the-dynamic-network-3\"><span class=\"toc-item-num\">3&nbsp;&nbsp;</span>Test the dynamic network</a></span><ul class=\"toc-item\"><li><span><a href=\"#One-single-timestep,-with-no-battery-capacity\" data-toc-modified-id=\"One-single-timestep,-with-no-battery-capacity-3.1\"><span class=\"toc-item-num\">3.1&nbsp;&nbsp;</span>One single timestep, with no battery capacity</a></span><ul class=\"toc-item\"><li><span><a href=\"#Comparing-with-a-static-network-problem-+-comparing-the-dual-variables\" data-toc-modified-id=\"Comparing-with-a-static-network-problem-+-comparing-the-dual-variables-3.1.1\"><span class=\"toc-item-num\">3.1.1&nbsp;&nbsp;</span>Comparing with a static network problem + comparing the dual variables</a></span></li></ul></li><li><span><a href=\"#Several-timesteps,-with-no-battery-capacity\" data-toc-modified-id=\"Several-timesteps,-with-no-battery-capacity-3.2\"><span class=\"toc-item-num\">3.2&nbsp;&nbsp;</span>Several timesteps, with no battery capacity</a></span><ul class=\"toc-item\"><li><span><a href=\"#Looking-for-indices-where-KKT-\\neq-0\" data-toc-modified-id=\"Looking-for-indices-where-KKT-\\neq-0-3.2.1\"><span class=\"toc-item-num\">3.2.1&nbsp;&nbsp;</span>Looking for indices where <code>KKT \\neq 0</code></a></span></li></ul></li><li><span><a href=\"#Several-timesteps,-with-battery-capacity\" data-toc-modified-id=\"Several-timesteps,-with-battery-capacity-3.3\"><span class=\"toc-item-num\">3.3&nbsp;&nbsp;</span>Several timesteps, with battery capacity</a></span></li><li><span><a href=\"#Several-timesteps,-with-battery-capacity-and-varying-demand\" data-toc-modified-id=\"Several-timesteps,-with-battery-capacity-and-varying-demand-3.4\"><span class=\"toc-item-num\">3.4&nbsp;&nbsp;</span>Several timesteps, with battery capacity and varying demand</a></span></li></ul></li><li><span><a href=\"#Computing-the-KKTs-and-the-Jacobian\" data-toc-modified-id=\"Computing-the-KKTs-and-the-Jacobian-4\"><span class=\"toc-item-num\">4&nbsp;&nbsp;</span>Computing the KKTs and the Jacobian</a></span><ul class=\"toc-item\"><li><span><a href=\"#Figuring-out-the-order-of-constraints/variables\" data-toc-modified-id=\"Figuring-out-the-order-of-constraints/variables-4.1\"><span class=\"toc-item-num\">4.1&nbsp;&nbsp;</span>Figuring out the order of constraints/variables</a></span><ul class=\"toc-item\"><li><span><a href=\"#Looking-for-indices-where-KKT-\\neq-0\" data-toc-modified-id=\"Looking-for-indices-where-KKT-\\neq-0-4.1.1\"><span class=\"toc-item-num\">4.1.1&nbsp;&nbsp;</span>Looking for indices where <code>KKT \\neq 0</code></a></span></li></ul></li><li><span><a href=\"#Test-current-functions\" data-toc-modified-id=\"Test-current-functions-4.2\"><span class=\"toc-item-num\">4.2&nbsp;&nbsp;</span>Test current functions</a></span><ul class=\"toc-item\"><li><span><a href=\"#Primal-variables-extracted-properly?\" data-toc-modified-id=\"Primal-variables-extracted-properly?-4.2.1\"><span class=\"toc-item-num\">4.2.1&nbsp;&nbsp;</span>Primal variables extracted properly?</a></span></li><li><span><a href=\"#Dual-variables-extracted-properly?\" data-toc-modified-id=\"Dual-variables-extracted-properly?-4.2.2\"><span class=\"toc-item-num\">4.2.2&nbsp;&nbsp;</span>Dual variables extracted properly?</a></span></li></ul></li></ul></li><li><span><a href=\"#Sensitivity-demand-checks\" data-toc-modified-id=\"Sensitivity-demand-checks-5\"><span class=\"toc-item-num\">5&nbsp;&nbsp;</span>Sensitivity demand checks</a></span><ul class=\"toc-item\"><li><span><a href=\"#One-timestep---no-storage-capacity\" data-toc-modified-id=\"One-timestep---no-storage-capacity-5.1\"><span class=\"toc-item-num\">5.1&nbsp;&nbsp;</span>One timestep - no storage capacity</a></span><ul class=\"toc-item\"><li><span><a href=\"#Comparing-static-vs-dynamic-mefs\" data-toc-modified-id=\"Comparing-static-vs-dynamic-mefs-5.1.1\"><span class=\"toc-item-num\">5.1.1&nbsp;&nbsp;</span>Comparing static vs dynamic mefs</a></span></li><li><span><a href=\"#Comparing-with-dual-variables\" data-toc-modified-id=\"Comparing-with-dual-variables-5.1.2\"><span class=\"toc-item-num\">5.1.2&nbsp;&nbsp;</span>Comparing with dual variables</a></span></li><li><span><a href=\"#Comparing-solutions\" data-toc-modified-id=\"Comparing-solutions-5.1.3\"><span class=\"toc-item-num\">5.1.3&nbsp;&nbsp;</span>Comparing solutions</a></span></li></ul></li><li><span><a href=\"#Several-timesteps-with-no-storage-capacity\" data-toc-modified-id=\"Several-timesteps-with-no-storage-capacity-5.2\"><span class=\"toc-item-num\">5.2&nbsp;&nbsp;</span>Several timesteps with no storage capacity</a></span><ul class=\"toc-item\"><li><span><a href=\"#Comparing-static-vs-dynamic\" data-toc-modified-id=\"Comparing-static-vs-dynamic-5.2.1\"><span class=\"toc-item-num\">5.2.1&nbsp;&nbsp;</span>Comparing static vs dynamic</a></span></li><li><span><a href=\"#Comparing-with-dual-variables\" data-toc-modified-id=\"Comparing-with-dual-variables-5.2.2\"><span class=\"toc-item-num\">5.2.2&nbsp;&nbsp;</span>Comparing with dual variables</a></span></li><li><span><a href=\"#With-the-compute_mefs-routine\" data-toc-modified-id=\"With-the-compute_mefs-routine-5.2.3\"><span class=\"toc-item-num\">5.2.3&nbsp;&nbsp;</span>With the <code>compute_mefs</code> routine</a></span></li></ul></li></ul></li><li><span><a href=\"#Verifying-sensitivity-computation\" data-toc-modified-id=\"Verifying-sensitivity-computation-6\"><span class=\"toc-item-num\">6&nbsp;&nbsp;</span>Verifying sensitivity computation</a></span><ul class=\"toc-item\"><li><span><a href=\"#Procedure\" data-toc-modified-id=\"Procedure-6.1\"><span class=\"toc-item-num\">6.1&nbsp;&nbsp;</span>Procedure</a></span></li><li><span><a href=\"#Implementation\" data-toc-modified-id=\"Implementation-6.2\"><span class=\"toc-item-num\">6.2&nbsp;&nbsp;</span>Implementation</a></span></li></ul></li><li><span><a href=\"#Plot-results\" data-toc-modified-id=\"Plot-results-7\"><span class=\"toc-item-num\">7&nbsp;&nbsp;</span>Plot results</a></span><ul class=\"toc-item\"><li><span><a href=\"#Plot-demand,-generation,-and-LMPs\" data-toc-modified-id=\"Plot-demand,-generation,-and-LMPs-7.1\"><span class=\"toc-item-num\">7.1&nbsp;&nbsp;</span>Plot demand, generation, and LMPs</a></span></li><li><span><a href=\"#Plot-carbon-LMPs\" data-toc-modified-id=\"Plot-carbon-LMPs-7.2\"><span class=\"toc-item-num\">7.2&nbsp;&nbsp;</span>Plot carbon LMPs</a></span></li></ul></li><li><span><a href=\"#Implicit-diff\" data-toc-modified-id=\"Implicit-diff-8\"><span class=\"toc-item-num\">8&nbsp;&nbsp;</span>Implicit diff</a></span></li><li><span><a href=\"#Compute-MEFs-via-regression\" data-toc-modified-id=\"Compute-MEFs-via-regression-9\"><span class=\"toc-item-num\">9&nbsp;&nbsp;</span>Compute MEFs via regression</a></span></li></ul></div>"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "using Pkg; Pkg.activate()\n",
    "\n",
    "using Plots\n",
    "using Convex, ECOS  # Convex modeling and solver\n",
    "using Distributions, Random  # Seeds and sampling\n",
    "using LightGraphs  # Generating nice random graphs\n",
    "using GraphPlot, Colors  # For plotting\n",
    "using SparseArrays\n",
    "\n",
    "OPT = () -> ECOS.Optimizer(verbose=false)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "using Revise\n",
    "using CarbonNetworks"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Generate some random data"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "Random.seed!(2)\n",
    "n = 4#30\n",
    "l = 4#50\n",
    "\n",
    "# Make graph\n",
    "G = watts_strogatz(n, 3, 0.2)\n",
    "\n",
    "# Convert to incidence matrix\n",
    "A = incidence_matrix(G, oriented=true)\n",
    "m = size(A, 2)\n",
    "\n",
    "# Create generator-node mapping\n",
    "node_map = vcat(collect(1:n), rand(1:n, l-n))\n",
    "B = spzeros(n, l)\n",
    "for (gen, node) in enumerate(node_map)\n",
    "    B[node, gen] = 1\n",
    "end\n",
    "\n",
    "# Generate carbon costs\n",
    "cq = zeros(l)\n",
    "cl = rand(Exponential(2), l)\n",
    "\n",
    "# Generate demands\n",
    "d = rand(Bernoulli(0.8), n) .* rand(Gamma(3.0, 3.0), n)\n",
    "\n",
    "# Generate generation and flow capacities\n",
    "gmax = rand(Gamma(4.0, 3.0), l) + (B'd)  # This is just to make the problem easier\n",
    "pmax = rand(Gamma(1.0, 0.1), m)\n",
    "\n",
    "# Plot network\n",
    "c_node = (B*cl) ./ (B*ones(l))\n",
    "nodesize = maximum(d) .+ d\n",
    "nodefillc = weighted_color_mean.((c_node / maximum(c_node)).^0.5, colorant\"red\", colorant\"green\")\n",
    "edgelinewidth = (pmax / maximum(pmax)).^0.5\n",
    "\n",
    "Random.seed!(0)  # I put a seed here so the spring layout doesn't change\n",
    "plt = gplot(G, nodesize=nodesize, nodefillc=nodefillc, edgelinewidth=edgelinewidth)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Solve the carbon management problem"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "cnet = PowerNetwork(cq, cl, pmax, gmax, A, B);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "cnet = PowerNetwork(cq, cl, pmax, gmax, A, B);\n",
    "carbon_min = PowerManagementProblem(cnet, d)\n",
    "solve!(carbon_min, OPT, verbose=true);"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Test the dynamic network"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## One single timestep, with no battery capacity"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "This should give the same result as above"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "T = 1\n",
    "\n",
    "cq_dyn = [cq for _ in 1:T]\n",
    "cl_dyn = [cl for _ in 1:T]\n",
    "pmax_dyn = [pmax for _ in 1:T]\n",
    "gmax_dyn = [gmax for _ in 1:T]\n",
    "d_dyn = [d for _ in 1:T]\n",
    "\n",
    "P = rand(Exponential(2), n)\n",
    "C = rand(Exponential(2), n)\n",
    "C = zeros(n)\n",
    ";"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "η_c = 1.0\n",
    "η_d = 1.0"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "dnet = DynamicPowerNetwork(\n",
    "    cq_dyn, cl_dyn, pmax_dyn, gmax_dyn, A, B, P, C, T; η_c=η_c, η_d=η_d\n",
    ")\n",
    "dmin = DynamicPowerManagementProblem(dnet, d_dyn);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "solve!(dmin, OPT, verbose=true);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "dmin.p[1].value"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "dmin.g[1].value"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "dmin.s[1].value"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "dmin.problem.optval"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "### Comparing with a static network problem + comparing the dual variables"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# solution with static network\n",
    "cnet = PowerNetwork(cq_dyn[1], cl_dyn[1], pmax_dyn[1], gmax_dyn[1], A, B);\n",
    "carbon_min = PowerManagementProblem(cnet, d_dyn[1])\n",
    "solve!(carbon_min, OPT, verbose=true);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "@show norm(dmin.g[1].value - carbon_min.g.value)\n",
    "@show norm(dmin.p[1].value - carbon_min.p.value);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "x = flatten_variables_dyn(dmin);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "g, p, s, ch, dis, λpl, λpu, λgl, λgu, ν, λsl, λsu, λchl, λchu, λdisl, λdisu, νs = unflatten_variables_dyn(x, n, m, l, T);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "g_, p_, λpl_, λpu_, λgl_, λgu_, ν_ = unflatten_variables(\n",
    "    flatten_variables(carbon_min), n, m, l\n",
    ");"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "@show norm(g[1]-g_)\n",
    "@show norm(p[1]-p_)\n",
    "@show norm(λpl[1]-λpl_)\n",
    "@show norm(λpu[1]-λpu_)\n",
    "@show norm(λgl[1]-λgl_)\n",
    "@show norm(λgu[1]-λgu_)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "It seems that for a single timestep we recover exactly the initial problem. "
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "x = flatten_variables_dyn(dmin);\n",
    "KKT = kkt_dyn(x, dnet, d_dyn);\n",
    "TOL = 1e-6;\n",
    "\n",
    "@show norm(KKT)\n",
    "@show sum(abs.(KKT) .> TOL);"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Several timesteps, with no battery capacity"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "Again, this should be the same as $T$ uncoupled problems because there is no battery capacity (therefore no time dependence). "
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "T = 2\n",
    "\n",
    "cq_dyn = [cq for _ in 1:T]\n",
    "cl_dyn = [cl for _ in 1:T]\n",
    "pmax_dyn = [pmax for _ in 1:T]\n",
    "gmax_dyn = [gmax for _ in 1:T]\n",
    "d_dyn = [d for _ in 1:T]\n",
    "\n",
    "P = rand(Exponential(2), n)\n",
    "C = rand(Exponential(2), n)\n",
    "C = zeros(n)\n",
    ";"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "dnet = DynamicPowerNetwork(\n",
    "    cq_dyn, cl_dyn, pmax_dyn, gmax_dyn, A, B, P, C, T; η_c=η_c, η_d=η_d\n",
    ")\n",
    "dmin = DynamicPowerManagementProblem(dnet, d_dyn);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "solve!(dmin, OPT, verbose=true);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "for t in 1:T\n",
    "    @show dmin.p[t].value\n",
    "    @show dmin.g[t].value\n",
    "    @show dmin.s[t].value\n",
    "end"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "s_vals = zeros(n, T)\n",
    "g_vals = zeros(l, T)\n",
    "for t in 1:T\n",
    "    s_vals[:, t] = dmin.s[t].value\n",
    "    g_vals[:, t] = dmin.g[t].value\n",
    "end"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "plot(s_vals')"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "plot(g_vals')"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "x = flatten_variables_dyn(dmin);\n",
    "KKT = kkt_dyn(x, dnet, d_dyn);\n",
    "TOL=1e-6;\n",
    "\n",
    "@show norm(KKT)\n",
    "@show sum(abs.(KKT).>TOL);"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "### Looking for indices where `KKT \\neq 0`"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "static_length = kkt_dims(n, m, l)\n",
    "storage_length = storage_kkt_dims(n);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# static\n",
    "for t in 1:T\n",
    "    start_stat = (t-1) * static_length\n",
    "    @show t, sum(abs.(KKT[start_stat+1:start_stat + static_length]).> TOL)\n",
    "end"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# storage\n",
    "for t in 1:T\n",
    "    start_stor = T*static_length + (t-1) * storage_length\n",
    "    @show t, sum(abs.(KKT[start_stor+1:start_stor + storage_length]).> TOL)\n",
    "end"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "t = 2\n",
    "start_stor = T*static_length + (t-1) * storage_length\n",
    "KKT_st = KKT[start_stor+1:start_stor + storage_length]\n",
    "for k in 1:5\n",
    "    @show k, norm(KKT_st[(k-1)*n+1:k*n])\n",
    "end\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "k=2\n",
    "KKT_st[(k-1)*n+1:k*n]"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Several timesteps, with battery capacity"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "T = 5\n",
    "\n",
    "cq_dyn = [cq for _ in 1:T]\n",
    "cl_dyn = [cl for _ in 1:T]\n",
    "pmax_dyn = [pmax for _ in 1:T]\n",
    "gmax_dyn = [gmax for _ in 1:T]\n",
    "d_dyn = [d for _ in 1:T]\n",
    "\n",
    "P = rand(Exponential(2), n)\n",
    "C = rand(Exponential(2), n)\n",
    ";"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "dnet = DynamicPowerNetwork(\n",
    "    cq_dyn, cl_dyn, pmax_dyn, gmax_dyn, A, B, P, C, T; η_c=η_c, η_d=η_d\n",
    ")\n",
    "dmin = DynamicPowerManagementProblem(dnet, d_dyn);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "solve!(dmin, OPT, verbose=true);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "s_vals = zeros(n, T)\n",
    "g_vals = zeros(l, T)\n",
    "for t in 1:T\n",
    "    s_vals[:, t] = dmin.s[t].value\n",
    "    g_vals[:, t] = dmin.g[t].value\n",
    "end"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "plot(s_vals')"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "plot(g_vals')"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "x = flatten_variables_dyn(dmin);\n",
    "KKT = kkt_dyn(x, dnet, d_dyn);\n",
    "TOL=1e-6;\n",
    "\n",
    "@show norm(KKT)\n",
    "@show sum(abs.(KKT).>TOL);"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Several timesteps, with battery capacity and varying demand"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "T = 4\n",
    "\n",
    "cq_dyn = [cq for _ in 1:T]\n",
    "cl_dyn = [cl for _ in 1:T]\n",
    "pmax_dyn = [pmax for _ in 1:T]\n",
    "gmax_dyn = [gmax for _ in 1:T]\n",
    "d_dyn = [rand(Bernoulli(0.8), n) .* rand(Gamma(2.0, 2.0), n) for _ in 1:T]\n",
    "\n",
    "P = rand(Exponential(2), n)\n",
    "C = rand(Exponential(2), n)\n",
    ";"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "dnet = DynamicPowerNetwork(\n",
    "    cq_dyn, cl_dyn, pmax_dyn, gmax_dyn, A, B, P, C, T; η_c=η_c, η_d=η_d\n",
    ")\n",
    "dmin = DynamicPowerManagementProblem(dnet, d_dyn);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "solve!(dmin, OPT, verbose=true);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "s_vals = zeros(n, T)\n",
    "g_vals = zeros(l, T)\n",
    "for t in 1:T\n",
    "    s_vals[:, t] = dmin.s[t].value\n",
    "    g_vals[:, t] = dmin.g[t].value\n",
    "end"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "plot(s_vals')\n",
    "xlabel!(\"Timestep\")\n",
    "ylabel!(\"SOC\")"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "plot(g_vals')\n",
    "xlabel!(\"Timestep\")\n",
    "ylabel!(\"g\")"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "x = flatten_variables_dyn(dmin);\n",
    "KKT = kkt_dyn(x, dnet, d_dyn);\n",
    "TOL=1e-6;\n",
    "\n",
    "@show norm(KKT)\n",
    "@show sum(abs.(KKT).>TOL);"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "----"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Computing the KKTs and the Jacobian"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Figuring out the order of constraints/variables"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "x = flatten_variables_dyn(dmin);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "g, p, s, ch, dis, λpl, λpu, λgl, λgu, ν, λsl, λsu, λchl, λchu, λdisl, λdisu, νs = unflatten_variables_dyn(x, n, m, l, T);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "KKT = kkt_dyn(x, dnet, d_dyn);\n",
    "\n",
    "TOL=1e-6;\n",
    "\n",
    "@show norm(KKT)\n",
    "\n",
    "@show sum(abs.(KKT).>TOL);"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "### Looking for indices where `KKT \\neq 0`"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "static_length = kkt_dims(n, m, l)\n",
    "storage_length = storage_kkt_dims(n);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# static\n",
    "for t in 1:T\n",
    "    start_stat = (t-1) * static_length\n",
    "    @show t, sum(abs.(KKT[start_stat+1:start_stat + static_length]).> TOL)\n",
    "end"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# storage\n",
    "for t in 1:T\n",
    "    start_stor = T*static_length + (t-1) * storage_length\n",
    "    @show t, sum(abs.(KKT[start_stor+1:start_stor + storage_length]).> TOL)\n",
    "end"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "t = 2\n",
    "start_stor = T*static_length + (t-1) * storage_length\n",
    "KKT_st = KKT[start_stor+1:start_stor + storage_length]\n",
    "for k in 1:5\n",
    "    @show k, norm(KKT_st[(k-1)*n+1:k*n])\n",
    "end\n"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Test current functions"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "Here below are a few tests for the flatten/unflatten functions"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "x = flatten_variables_dyn(dmin);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "g, p, s, ch, dis, λpl, λpu, λgl, λgu, ν, λsl, λsu, λchl, λchu, λdisl, λdisu, νs = unflatten_variables_dyn(x, n, m, l, T);"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "### Primal variables extracted properly?"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "t = 3;"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "@show norm(g[t] - dmin.g[t].value)\n",
    "@show norm(p[t] - dmin.p[t].value)\n",
    "@show norm(s[t] - dmin.s[t].value);\n",
    "    "
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "### Dual variables extracted properly?"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "n_constraints_static = 5\n",
    "start_index = (t-1)*n_constraints_static\n",
    "\n",
    "@show norm(λpl[t] - dmin.problem.constraints[start_index+1].dual)\n",
    "@show norm(λpu[t] - dmin.problem.constraints[start_index+2].dual)\n",
    "@show norm(λgl[t] - dmin.problem.constraints[start_index+3].dual)\n",
    "@show norm(λgu[t] - dmin.problem.constraints[start_index+4].dual)\n",
    "@show norm(ν[t] - dmin.problem.constraints[start_index+5].dual)\n",
    "\n",
    "start_index = T*n_constraints_static\n",
    "@show norm(λsl[t] - dmin.problem.constraints[start_index+1].dual)\n",
    "@show norm(λsu[t] - dmin.problem.constraints[start_index+2].dual)\n",
    "@show norm(λchl[t] - dmin.problem.constraints[start_index+3].dual)\n",
    "@show norm(λchu[t] - dmin.problem.constraints[start_index+4].dual)\n",
    "@show norm(λdisl[t] - dmin.problem.constraints[start_index+5].dual)\n",
    "@show norm(λdisl[t] - dmin.problem.constraints[start_index+6].dual)\n",
    "@show norm(νs[t] - dmin.problem.constraints[start_index+7].dual);"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Sensitivity demand checks"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "Here we basically test the sensitivity to demand routine. We solve the problem with some linear costs (for which the gradient $\\nabla C$ is very easy to compute). "
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## One timestep - no storage capacity"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "In this case, there is no storage capacity, so it should behave exactly the same as a static network."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "T = 1\n",
    "\n",
    "# cq_dyn = [cq for _ in 1:T]\n",
    "cq_dyn = [zeros(l) for _ in 1:T]\n",
    "cl_dyn = [cl for _ in 1:T]\n",
    "pmax_dyn = [pmax for _ in 1:T]\n",
    "gmax_dyn = [gmax for _ in 1:T]\n",
    "d_dyn = Tuple(d for _ in 1:T)\n",
    "\n",
    "P = rand(Exponential(2), n)\n",
    "# C = rand(Exponential(2), n)\n",
    "C = zeros(n)\n",
    ";"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "dnet = DynamicPowerNetwork(\n",
    "    cq_dyn, cl_dyn, pmax_dyn, gmax_dyn, A, B, P, C, T; η_c=η_c, η_d=η_d\n",
    ")\n",
    "dmin = DynamicPowerManagementProblem(dnet, d_dyn);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "solve!(dmin, OPT, verbose=true);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "x = flatten_variables_dyn(dmin);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "KKT = kkt_dyn(x, dnet, d_dyn);\n",
    "\n",
    "TOL=1e-6;\n",
    "\n",
    "@show norm(KKT);\n",
    "\n",
    "@show sum(abs.(KKT).>TOL);"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "### Comparing static vs dynamic mefs"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# timestep for which we want to compute the MEFS\n",
    "t = 1"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "static_length = kkt_dims(n, m, l);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "idx = (t-1)*static_length;\n",
    "∇C = zeros(kkt_dims_dyn(n, m, l, T))\n",
    "∇C[idx+1:idx+l] .= cl_dyn[t]\n",
    "# ∇C[1:l] .= cl_dyn[t]\n",
    "mefs_dyn = sensitivity_demand_dyn(dmin, dnet, d_dyn, ∇C, t);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# solution with static network\n",
    "∇C = zeros(kkt_dims(n, m, l))\n",
    "∇C[1:l] .= cl_dyn[t]\n",
    "\n",
    "cnet = PowerNetwork(cq_dyn[t], cl_dyn[t], pmax_dyn[t], gmax_dyn[t], A, B);\n",
    "carbon_min = PowerManagementProblem(cnet, d_dyn[t])\n",
    "solve!(carbon_min, OPT, verbose=true);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "x = flatten_variables(carbon_min);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "@show norm(kkt(x, cnet, d_dyn[t]));"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "mefs = sensitivity_demand(carbon_min, ∇C, cnet, d_dyn[t]);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "@show norm(mefs - mefs_dyn)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "### Comparing with dual variables"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "The dual variables $\\nu$ are the ones associated with the continuity equation -- therefore they are the ones telling us about the sensitivity of the problem to demand when the objective is appropriately defined. "
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "g, p, s, ch, dis, λpl, λpu, λgl, λgu, ν, λsl, λsu, λchl, λchu, λdisl, λdisu, νs = unflatten_variables_dyn(\n",
    "    flatten_variables_dyn(dmin), n, m, l, T\n",
    ");"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "@show norm(ν[1]-mefs_dyn)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "@show norm(ν[1]-mefs)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "### Comparing solutions"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "@show norm(dmin.g[t].value - carbon_min.g.value)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Several timesteps with no storage capacity"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "In this case, still no storage capacity. So we should have `T` independent timesteps, and the sensitivities should be retrieved by computing the sensitivity with a simple static network on the given timestep `t`."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "T = 5\n",
    "\n",
    "# cq_dyn = [cq for _ in 1:T]\n",
    "cq_dyn = [zeros(l) for _ in 1:T]\n",
    "cl_dyn = [cl for _ in 1:T]\n",
    "pmax_dyn = [pmax for _ in 1:T]\n",
    "gmax_dyn = [gmax for _ in 1:T]\n",
    "d_dyn = [d for _ in 1:T]\n",
    "\n",
    "P = rand(Exponential(2), n)\n",
    "# C = rand(Exponential(2), n)\n",
    "C = zeros(n)\n",
    ";"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "dnet = DynamicPowerNetwork(\n",
    "    cq_dyn, cl_dyn, pmax_dyn, gmax_dyn, A, B, P, C, T; η_c=η_c, η_d=η_d\n",
    ")\n",
    "dmin = DynamicPowerManagementProblem(dnet, d_dyn);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "solve!(dmin, OPT, verbose=true);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "x = flatten_variables_dyn(dmin);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "KKT = kkt_dyn(x, dnet, d_dyn);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "TOL=1e-6;"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "@show norm(KKT);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "@show sum(abs.(KKT).>TOL);"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "### Comparing static vs dynamic"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "static_length = kkt_dims(n, m, l);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# timestep for which we want to compute the MEFS\n",
    "t = 3;"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "idx = (t-1)*static_length;\n",
    "∇C = zeros(kkt_dims_dyn(n, m, l, T))\n",
    "∇C[idx+1:idx+l] .= cl_dyn[t]\n",
    "# ∇C[1:l] .= cl_dyn[t]\n",
    "mefs_dyn = sensitivity_demand_dyn(dmin, dnet, d_dyn, ∇C, t);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# solution with static network\n",
    "∇C = zeros(kkt_dims(n, m, l))\n",
    "∇C[1:l] .= cl_dyn[t]\n",
    "\n",
    "cnet = PowerNetwork(cq_dyn[t], cl_dyn[t], pmax_dyn[t], gmax_dyn[t], A, B);\n",
    "carbon_min = PowerManagementProblem(cnet, d_dyn[t])\n",
    "solve!(carbon_min, OPT, verbose=true);\n",
    "\n",
    "mefs = sensitivity_demand(carbon_min, ∇C, cnet, d_dyn[t]);\n",
    "\n",
    "@show norm(mefs - mefs_dyn)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "### Comparing with dual variables"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "The dual variables $\\nu$ are the ones associated with the continuity equation -- therefore they are the ones telling us about the sensitivity of the problem to demand when the objective is appropriately defined. "
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "g, p, s, ch, dis, λpl, λpu, λgl, λgu, ν, λsl, λsu, λchl, λchu, λdisl, λdisu, νs = unflatten_variables_dyn(\n",
    "    flatten_variables_dyn(dmin), n, m, l, T\n",
    ");"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "@show norm(ν[t]-mefs_dyn)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "@show norm(ν[t]-mefs)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "### With the `compute_mefs` routine\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "mefs_ = compute_mefs(dmin, dnet, d_dyn, cl_dyn[t], t)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "mefs_t = mefs_[:, t]"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "mefs"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "@show norm(mefs_t-mefs)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "---"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Verifying sensitivity computation\n"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Procedure"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "For any parameter $x$, we have\n",
    "$$\n",
    "z^\\star(x+dx) = z^\\star(x) + \\partial_x z^\\star dx.\n",
    "$$\n",
    "\n",
    "Therefore, the procedure for estimating sensitivity will go as follows: \n",
    "- Fix all parameters of the problem\n",
    "- Solve the optimization problem\n",
    "- Compute the Jacobian\n",
    "- Choose a parameter and disturb it slightly (to first order)\n",
    "- Compute the estimate of the new solution according to the above and, in parallel, compute the optimal solution to the new problem \n",
    "- Repeat this for increasing amounts of perturbation\n",
    "\n",
    "At first order (i.e. for small amounts of perturbation), the resulting curve should be close to linear. We want to investigate whether the two obtained curves are close to each other in this linear regime."
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "This definitely can be functionalized, and may be useful in the future. The structure is completely independent of the details of the code. The only \"issue\" revolves around taking the right derivative and propagating the right vector ($dx$). "
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "So basically, the code would look like the following"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Implementation"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "sum(d) / sum(pmax)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "T = 2\n",
    "Random.seed!(10)\n",
    "\n",
    "# cq_dyn = [cq for _ in 1:T]\n",
    "cq_dyn = [zeros(l) for _ in 1:T]\n",
    "cl_dyn = [cl, 2*cl]\n",
    "pmax_dyn = [zeros(m) for _ in 1:T]  #[100*pmax for _ in 1:T]\n",
    "gmax_dyn = [100*ones(l) for _ in 1:T]  #[100*gmax for _ in 1:T]\n",
    "d_dyn = [d for _ in 1:T]\n",
    "\n",
    "C = 100*ones(n) #rand(Exponential(2), n)\n",
    "P = C\n",
    "# C = zeros(n)\n",
    ";"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "dnet = DynamicPowerNetwork(\n",
    "    cq_dyn, cl_dyn, pmax_dyn, gmax_dyn, A, B, P, C, T; η_c=η_c, η_d=η_d\n",
    ")\n",
    "dmin = DynamicPowerManagementProblem(dnet, d_dyn);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {
    "scrolled": false
   },
   "outputs": [],
   "source": [
    "# node = 4\n",
    "t = 1\n",
    "varName = 's'\n",
    "unit = 1\n",
    "npoints = 10\n",
    "rel_inc = 1e-1\n",
    "\n",
    "plts = []\n",
    "for node in 1:n\n",
    "    subplt = plot_sensitivity_check(dnet, d_dyn, node, t; varName=varName, unit=unit, \n",
    "        npoints=npoints, rel_inc=rel_inc)\n",
    "    plot!(subplt, legend=false, title=\"node = $node\")\n",
    "    push!(plts, subplt)\n",
    "end\n",
    "\n",
    "@show unit\n",
    "plot(plts..., )"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "## plot_sensitivity_check(dnet, d_dyn, node, t; varName=varName, unit=unit, npoints=npoints, rel_inc=rel_inc)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "solve!(dmin, OPT)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "dmin.s[1].value"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "d"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "---"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Plot results\n",
    "\n",
    "`GraphPlot` is only for making simple plots. To do more advanced things (like the plot in the carbon accounting paper), we'll need to draw the graph manually.\n",
    "\n",
    "For now, I'm going to make some simple diagnostic plots."
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Plot demand, generation, and LMPs\n",
    "\n",
    "Here, the LMPs are carbon LMPs."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "λ = get_lmps(carbon_min)  # <-- LMPs\n",
    "\n",
    "# Fancy colors\n",
    "gradient = cgrad(:inferno)\n",
    "lmp_colors = [get(gradient, λi/maximum(λ)) for λi in λ]\n",
    "\n",
    "\n",
    "plt1 = bar(d, label=nothing, c=:blue, ylabel=\"demand\")\n",
    "plt2 = bar(evaluate(carbon_min.g), label=nothing, c=:green, ylabel=\"generation\")\n",
    "plt3 = sticks(λ, label=nothing, ylabel=\"carbon LMP\", xlabel=\"node\")\n",
    "scatter!(plt3, λ, c=lmp_colors, label=nothing)\n",
    "\n",
    "plot(plt1, plt2, plt3, layout=(3, 1))"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Plot carbon LMPs\n",
    "\n",
    "Brighter is more carbon intensive. At the bright nodes (orange and yellow), increasing / decreasing demand has the greatest effect on total emissions."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "Random.seed!(0)  # <-- For the node layout consistency\n",
    "plt = gplot(G, nodesize=nodesize, nodefillc=lmp_colors, edgelinewidth=edgelinewidth)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Implicit diff"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "using CarbonNetworks: kkt, flatten_variables\n",
    "\n",
    "Random.seed!(4)\n",
    "\n",
    "fq = 3 .+ rand(Exponential(3), l)  # generate monetary costs\n",
    "fl = 3 .+ rand(Exponential(3), l)\n",
    "\n",
    "# Solve cost minimization problem\n",
    "net = PowerNetwork(fq, fl, pmax, gmax, A, B)\n",
    "opf = PowerManagementProblem(net, d)\n",
    "solve!(opf, OPT, verbose=true)\n",
    "\n",
    "kkt_resid = kkt(flatten_variables(opf), net, d)\n",
    "@show norm(kkt_resid)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "sum(abs, evaluate(opf.p)) / sum(d)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "∇C = zeros(kkt_dims(n, m, l))\n",
    "∇C[1:l] .= cl\n",
    "\n",
    "mefs = sensitivity_demand(opf, ∇C, net, d)\n",
    "\n",
    "theme(:default, legend=false)\n",
    "plt1a = bar(evaluate(carbon_min.g), title=\"carbon min generation\", color=:green)\n",
    "plt1b = bar(get_lmps(carbon_min), title=\"carbon min LMP\", color=:yellow)\n",
    "plt2a = bar(evaluate(opf.g), title=\"opf generation\", color=:green)\n",
    "plt2b = bar(mefs, title=\"marginal emission factors\", color=:yellow)\n",
    "plot(plt1a, plt1b, plt2a, plt2b, layout=(2, 2), size=(700, 400))"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Compute MEFs via regression"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "using CarbonNetworks: solve_pmp\n",
    "\n",
    "Random.seed!(14)\n",
    "\n",
    "num_cases = 1000\n",
    "ϵ = 0.05\n",
    "\n",
    "d_hidden = rand(Uniform(0.3, 0.7), n) .* (B*gmax)\n",
    "\n",
    "flows = []\n",
    "cases = []\n",
    "for _ in 1:num_cases\n",
    "    d_hidden *= rand(Uniform(0.95, 1.05))\n",
    "    d_obs = d_hidden + ϵ*randn(n)\n",
    "    \n",
    "    g, pmp, _ = solve_pmp(fq, fl, d_obs, pmax, gmax, A, B)\n",
    "    if Int(pmp.problem.status) ∉ [1, 7]\n",
    "        @show pmp.problem.status\n",
    "    end\n",
    "    \n",
    "    push!(cases, (d=d_obs, g=g, pmp=pmp))\n",
    "    push!(flows, sum(abs, evaluate(pmp.p)) / sum(g))\n",
    "end"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "Random.seed!(41)\n",
    "inds = sample(1:n, 5, replace=false)\n",
    "\n",
    "theme(:default, label=nothing, lw=4)\n",
    "plot([d[i] for (d, g) in cases, i in inds], labels=inds')"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "E = [B * (cl .* g) for (d, g) in cases]\n",
    "\n",
    "Δd = hcat([cases[t].d - cases[t-1].d for t in 2:num_cases]...)\n",
    "ΔE = hcat([E[t] - E[t-1] for t in 2:num_cases]...);"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "theme(:default, label=nothing)\n",
    "\n",
    "plts = []\n",
    "for i in 1:n\n",
    "    μi = Δd[i, :] \\ ΔE[i, :]\n",
    "    ΔE_est = Δd[i, :] * μi\n",
    "    correlation = cor(ΔE_est, ΔE[i, :])\n",
    "\n",
    "    #@show correlation\n",
    "    #@show μi\n",
    "\n",
    "    μi_diffs = []\n",
    "\n",
    "    for case in cases[1:100]\n",
    "        params = (fq, fl, case.d, pmax, gmax, A)\n",
    "        ∇C = zeros(kkt_dims(n, m, l))\n",
    "        ∇C[1:l] .= cl\n",
    "\n",
    "        mefs = sensitivity_demand(case.pmp, ∇C, net, case.d)\n",
    "        push!(μi_diffs, mefs[i])\n",
    "    end\n",
    "    μi_diff = mean(μi_diffs)\n",
    "\n",
    "    #@show μi_diff\n",
    "    @show i, minimum(μi_diffs), maximum(μi_diffs)\n",
    "    # println()\n",
    "\n",
    "    x_coords = Δd[i, :]\n",
    "    \n",
    "    label = (i > 1) ? nothing : \"mean mef\"\n",
    "    label2 = (i > 1) ? nothing : \"max mef\"\n",
    "    \n",
    "    sim_mean = μi_diff*x_coords\n",
    "    sim_max = maximum(μi_diffs)*x_coords\n",
    "    sim_min = minimum(μi_diffs)*x_coords\n",
    "\n",
    "    plt = scatter(x_coords, ΔE[i, :], xlabel=\"Δd\", ylabel=\"ΔE\", ms=2, title=\"$i\")\n",
    "    plot!(plt, x_coords, ΔE_est, lw=2) #, label=\"r2=$(round(correlation, digits=2))\", legend=:topleft)\n",
    "    plot!(plt, x_coords, sim_mean, lw=2, label=label, legend=:topleft, color=:Green)\n",
    "    plot!(plt, x_coords, maximum(μi_diffs)*x_coords, lw=2, label=label2, color=:Cyan, ls=:dot)\n",
    "    plot!(plt, x_coords, minimum(μi_diffs)*x_coords, lw=2, label=label2, color=:Cyan, ls=:dot)\n",
    "    push!(plts, plt)\n",
    "end\n",
    "\n",
    "plot(plts..., layout=(2, 5), size=(900, 450))"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "edges_15 = findall(x -> x != 0, A[15, :])\n",
    "edges_16 = findall(x -> x != 0, A[16, :])\n",
    "@show edges_15 edges_16\n",
    "\n",
    "#heatmap(Matrix(neighbors), c=:grays, yflip=true)\n",
    "plot()\n",
    "bar(pmax)\n",
    "bar!(evaluate(cases[100].pmp.p), xticks=([30 34 40], [30, 34, 40]))\n"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Julia 1.6.0",
   "language": "julia",
   "name": "julia-1.6"
  },
  "language_info": {
   "file_extension": ".jl",
   "mimetype": "application/julia",
   "name": "julia",
   "version": "1.6.0"
  },
  "toc": {
   "base_numbering": 1,
   "nav_menu": {},
   "number_sections": true,
   "sideBar": true,
   "skip_h1_title": false,
   "title_cell": "Table of Contents",
   "title_sidebar": "Contents",
   "toc_cell": true,
   "toc_position": {
    "height": "calc(100% - 180px)",
    "left": "10px",
    "top": "150px",
    "width": "165px"
   },
   "toc_section_display": true,
   "toc_window_display": true
  },
  "varInspector": {
   "cols": {
    "lenName": 16,
    "lenType": 16,
    "lenVar": 40
   },
   "kernels_config": {
    "python": {
     "delete_cmd_postfix": "",
     "delete_cmd_prefix": "del ",
     "library": "var_list.py",
     "varRefreshCmd": "print(var_dic_list())"
    },
    "r": {
     "delete_cmd_postfix": ") ",
     "delete_cmd_prefix": "rm(",
     "library": "var_list.r",
     "varRefreshCmd": "cat(var_dic_list()) "
    }
   },
   "types_to_exclude": [
    "module",
    "function",
    "builtin_function_or_method",
    "instance",
    "_Feature"
   ],
   "window_display": false
  }
 },
 "nbformat": 4,
 "nbformat_minor": 5
}
