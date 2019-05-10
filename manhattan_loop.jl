using Gadfly
using CSV
using DataFrames

data = CSV.read("C:/Users/ztjsw/Desktop/data.txt", delim = ',', header = true)

data[:chromosome] = string.(data[:chromosome])
data[:neg_log_p] = -log10.(data[:pvalue])
data[:adj_pos] = copy(data[:position])

function cal_adj_pos(data)
    #calculate adjusted position
    start = 0
    for i in 2:nrow(data)
        if data[:chromosome][i] != data[:chromosome][i-1]
            start += data[:position][i-1]
        end
        data[:adj_pos][i] += start
    end
    data
end

data_new = cal_adj_pos(data)


## Plot
#calculate postion for xticks
x_chrom_pos = by(data_new, :chromosome, mid_pos = :adj_pos => d -> (maximum(d) + minimum(d))/2)[2]
x_chrom_label = unique(data_new[:chromosome])

function pos_to_chrom(iPos)
    # return the name of its chromosome for a position
    return x_chrom_label[x_chrom_pos .== iPos][1]
end


p=plot(data_new, x=:adj_pos, y=:neg_log_p, color=:chromosome, Geom.point,
        Guide.xlabel("Chromosome"),
        Guide.ylabel("-log<sub>10</sub>(p)"),
        Guide.xticks(ticks=x_chrom_pos),
        Scale.x_continuous(labels = pos_to_chrom),  #labels is a function which maps a coordinate value to a string label
        Theme(key_position = :none, grid_line_width=0mm, point_size=0.1cm))

display(p)
