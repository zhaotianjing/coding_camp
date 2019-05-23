using LinearAlgebra,DataFrames,Plots,StatsBase

function ManhattanPlot(inputFile,alpha = 0.1)
    @warn("This plot is using backend:",backend())
    
    maxPos_CHR = sort(by(inputFile, :chromosome, chr_len = :position => maximum),[:chromosome])
    maxPos_CHR[:tot] = cumsum(maxPos_CHR[:chr_len]) - maxPos_CHR[:chr_len]
    deletecols!(maxPos_CHR, :chr_len)
    dat = join(inputFile, maxPos_CHR, on = :chromosome, kind = :left) # join both data sets 
    sort!(dat, [:chromosome]); # sort data frame by :chromosome column
    dat[:BPcum] = dat[:position] + dat[:tot] # position for markers at the xaxis
    plot_dat = dat[[:chromosome, :pvalue, :BPcum]]
    plot_dat[:pvalue] = -log10.(plot_dat[:pvalue])
    

    #convert factors of :chromosome to columns
    plot_data = unstack(plot_dat, :chromosome, :pvalue) 
    ncolumn = ncol(plot_data)
    
    # replace all missing values by NaN
    for i = 2:ncolumn 
        plot_data[i] = coalesce.(plot_data[i], NaN)
        
    end
    
    plot_data = convert(Matrix, plot_data)
    axisdf = by(dat, :chromosome, center = :BPcum => x -> (maximum(x) + minimum(x))/2) # position for x axis 
    p1 = scatter(plot_data[:,1], plot_data[:, 2:end], legend = false, xticks = (axisdf[:center], axisdf[:chromosome]),
    xlabel = "chromosome", ylab = ("-log(p)"))
    
    #Plot the significant line
    plot!([-log10(alpha)],seriestype = :hline,linecolor = "black")
    
    #display(p1)
end

#Testing
nmarkers  = 500
chrlength = 1*100*1_000_000 #one morgan
input1 = DataFrame(markerID = fill("m1",nmarkers), chromosome = sample(1:10,nmarkers),position = sample(1:chrlength,nmarkers), pvalue = rand(nmarkers))

#@time ManhattanPlot(input1,0.05)
ManhattanPlot(input1,0.05)
