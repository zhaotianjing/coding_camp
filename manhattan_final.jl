using DataFrames, Plots
input1 = DataFrame(markerID = ["m1", "m2", "m3", "m4", "m5","m5","m5","m5","m5"], chromosome =[1,1,1,2,2,3,3,3,4], 
    position = [16977, 434311, 1025513, 70350, 101135,5,3000,100000,5999], pvalue = [0.001, 0.01, 0.05, 0.1, 0.3,0.3,0.1,0.2,0.1])


function ManhattanPlot(inputFile,alpha = 0.1)
    @warn("This plot is using backend:",backend())
    
    maxPos_CHR = by(inputFile, :chromosome, chr_len = :position => maximum)
    maxPos_CHR[:tot] = cumsum(convert(Matrix,maxPos_CHR), dims = 1)[:, 2] - maxPos_CHR[:chr_len]
    deletecols!(maxPos_CHR, :chr_len)
    dat = join(inputFile, maxPos_CHR, on = :chromosome) # join both data sets 
    sort!(dat, [:chromosome]); # sort data frame by :chromosome column
    dat[:BPcum] = dat[:position] + dat[:tot] # position for markers at the xaxis
    plot_dat = dat[[:chromosome, :pvalue, :BPcum]]
    plot_dat[:pvalue] = -log10.(plot_dat[:pvalue])
    
    #Get the range of each chrosome
    max_range = by(plot_dat, :chromosome, max_num = :BPcum => maximum)
    min_range = by(plot_dat, :chromosome, max_num = :BPcum => minimum)
    overall_min = minimum(plot_dat[:pvalue]) - 1
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
    
    #Plot the position range of each chromsome
    for i in 1:nrow(max_range)
        plot!(p1,min_range[i,2]:max_range[i,2], x -> overall_min, linetype=:l)
    end
    
    #Add vertical line to separate each chrosome
    #for i in 1:nrow(max_range)-1
    #    pos = (max_range[i,2]+min_range[i+1,2])/2
    #    plot!([pos],seriestype = :vline,linecolor = "black")
    #end
    
    
    display(p1)
end


#Testing
ManhattanPlot(input1,0.05)
