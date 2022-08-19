{
 "cells": [
  {
   "cell_type": "code",
   "execution_count": 1,
   "id": "0bbfa041",
   "metadata": {},
   "outputs": [],
   "source": [
    "using GLMakie"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 5,
   "id": "6b23e2b1",
   "metadata": {},
   "outputs": [
    {
     "data": {
      "text/plain": [
       "\"lorenz.webm\""
      ]
     },
     "execution_count": 5,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "Base.@kwdef mutable struct Lorenz\n",
    "    dt::Float64 = 0.01\n",
    "    σ::Float64 = 10\n",
    "    ρ::Float64 = 28\n",
    "    β::Float64 = 8/3\n",
    "    x::Float64 = 1\n",
    "    y::Float64 = 1\n",
    "    z::Float64 = 1\n",
    "end\n",
    "\n",
    "function step!(l::Lorenz)\n",
    "    dx = l.σ * (l.y - l.x)\n",
    "    dy = l.x * (l.ρ - l.z) - l.y\n",
    "    dz = l.x * l.y - l.β * l.z\n",
    "    l.x += l.dt * dx\n",
    "    l.y += l.dt * dy\n",
    "    l.z += l.dt * dz\n",
    "    Point3f(l.x, l.y, l.z)\n",
    "end\n",
    "\n",
    "attractor = Lorenz()\n",
    "\n",
    "points = Observable(Point3f[])\n",
    "colors = Observable(Int[])\n",
    "\n",
    "set_theme!(theme_black())\n",
    "\n",
    "fig, ax, l = lines(points, color = colors,\n",
    "    colormap = :inferno, transparency = true,\n",
    "    axis = (; type = Axis3, protrusions = (0, 0, 0, 0),\n",
    "        viewmode = :fit, limits = (-30, 30, -30, 30, 0, 50)))\n",
    "\n",
    "record(fig, \"lorenz.webm\", 1:120) do frame\n",
    "    for i in 1:50\n",
    "        push!(points[], step!(attractor))\n",
    "        push!(colors[], frame)\n",
    "    end\n",
    "    ax.azimuth[] = 1.7pi + 0.3 * sin(2pi * frame / 120)\n",
    "    notify.((points, colors))\n",
    "    l.colorrange = (0, frame)\n",
    "end"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Julia 1.7.3",
   "language": "julia",
   "name": "julia-1.7"
  },
  "language_info": {
   "file_extension": ".jl",
   "mimetype": "application/julia",
   "name": "julia",
   "version": "1.7.3"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 5
}
