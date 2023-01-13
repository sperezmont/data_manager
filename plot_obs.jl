"""
    Aim: This script aims to plot glacyal cycles proxies (time series, spectrum, wavelet) \n
    Author: Sergio Pérez Montero (github.com/sperezmont)                                  \n
    Date: 2023.01.11                                                                      \n
"""

## Preamble
using Pkg
Pkg.activate("data_manager_env")                    # -- activate virtual environment
using NCDatasets, CairoMakie, DSP, Statistics, Wavelets, ContinuousWavelets, Interpolations                        

# -- Variables
path2dir = "/home/sergio/entra/ice_data/Reconstructions/Luthi-etal_2008/"#"/home/sergio/entra/ice_data/Reconstructions/Waelbroeck-etal_2002/" #"/home/sergio/entra/ice_data/Reconstructions/Spratt-Lisiecki_2016/" 
obs_file = "luthi-etal_2008.nc"#"waelbroeck-etal_2002.nc" # "spratt-lisiecki_2016.nc" 
var2plot =  "CO2" #"RSL" # "SeaLev_longPC1" 
errors2plot = [] # ["SeaLev_longPC1_err_lo", "SeaLev_longPC1_err_up"] 
sigma = 0.6π    # central frequency parameter σ, which controls the time-frequency trade-off 

# -- Some predefined variables
new_name = obs_file[1:end-3]*".png"
new_var_name = var2plot #"Sea Level"
fgsz, fntsz = (1000, 800), 20

## Script
# Load data
d = NCDataset(path2dir * obs_file)[var2plot]
if errors2plot != []
    err_lo = NCDataset(path2dir * obs_file)[errors2plot[1]]
    err_up = NCDataset(path2dir * obs_file)[errors2plot[2]]
end
t = NCDataset(path2dir * obs_file)[keys(d)[1]]

# Let's make some calculations
# -- Spectra
function calc_spectrum(d, fs)
    # -- spectrum blackman tuckey
    N = length(d)
    Nmax = Int(ceil(N / 2))
    P = periodogram(d, onesided=true, fs=fs, window=blackman(N))
    G, freq = P.power, P.freq
    return G, freq
end

new_d = Vector{Float64}(undef, length(d))
new_d[:] = d[:]

G, f = calc_spectrum(new_d, 1/(t[2] - t[1])) 
G, f = G[f .> 1/abs(t[1] - t[end])], f[f .> 1/abs(t[1] - t[end])]   # filtering
G = G ./ sum(G)
periods = 1 ./ f    # kyr

# -- Wavelet
function calc_spectrogram(d, fs; sigma=π)
    wvt = ContinuousWavelets.wavelet(Morlet(sigma), averagingType=NoAve(), β=1)
    S = ContinuousWavelets.cwt(d, wvt)                                           
    freq= getMeanFreq(ContinuousWavelets.computeWavelets(length(d), wvt)[1], fs)  
    S = abs.(S) .^ 2 
    S = S ./ sum(S, dims=2)
    return S, freq
end

S_wv, f_wv = calc_spectrogram(new_d, 1/(t[2] - t[1]); sigma=sigma)
periods_wv = 1 ./ f_wv

# Plot data
# -- setting up figure template ...
fig = Figure(resolution=fgsz)
fontsize_theme = Theme(font="Dejavu Serif", fontsize=fntsz)
set_theme!(fontsize_theme)

# -- setting up axes ...
ax = Axis(fig[1, 1], xlabelsize=fntsz, ylabelsize=fntsz, ylabel=new_var_name * " (" * d.attrib["units"] * ")", xticklabelsvisible = false)
ax_wv = Axis(fig[2, 1], xlabelsize=fntsz, ylabelsize=fntsz, xlabel="Time (kyr)", ylabel="Period (kyr)")
ax_pd = Axis(fig[2, 2], xlabelsize=fntsz, ylabelsize=fntsz, xaxisposition=:top, yticklabelsvisible = false)
update_theme!()

# -- plotting data
if errors2plot != []
    band!(ax, t, err_lo, err_up, color=(:black, 0.3), label="Error in "*new_var_name)
end
lines!(ax, t, d, color=:black, label=new_var_name)
leg = Legend(fig[1, 2], ax, halign=:left)

c = contourf!(ax_wv, t, periods_wv, S_wv, colormap=:cividis)
hlines!(ax_wv, [21, 41, 100], color=:red, linestyle=:dash)

hlines!(ax_pd, [21, 41, 100], color=:red, linestyle=:dash)
barplot!(ax_pd, periods, G, color=G, colormap=:cividis, width=5, direction=:x)

Colorbar(fig[1, 2], c, height=Relative(0.1), width=Relative(0.8), vertical=false, label="Normalized PSD", labelsize=fntsz, valign=:bottom, halign=:left)    # PSD = Power Spectral Density

# -- cutting
colsize!(fig.layout, 2, 0.3*fgsz[1])
update_theme!()


xlen = length(t)
if mod(xlen, 2) == 0
    xstep = Int(ceil(xlen / 10))
else
    xstep = Int((ceil((xlen - 1) / 10)))
end
ax.xticks = t[1:xstep:end]
ax.xtickformat = k -> string.(Int.(ceil.(k / 10) * 10))
ax_wv.xticks = t[1:xstep:end]
ax_wv.xtickformat = k -> string.(Int.(ceil.(k / 10) * 10))

xlims!(ax, (t[1], t[end]))
xlims!(ax_wv, (t[1], t[end]))

ylims!(ax_wv, (0, 120))
ylims!(ax_pd, (0, 120))

save(path2dir * new_name, fig)

