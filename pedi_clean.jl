using DataFrames,CSV 
#Zigui writes the code to remove missing value and duplicate rows.
function remove_missing_duplicate(file; delim = ',', header = 0,miss = missing)
    """
    Remove missing value and duplicate
    """
    dat = CSV.read(file, delim = delim, header = header) # no header 
    dat = unique!(dat) #remove duplicate
    nCol = ncol(dat)
    dat = dropmissing(dat) #Drop the rows containing missing
    if ismissing(miss)
        return dat
    else
        for i in 1:nCol
            dat = dat[dat[:,i].!=miss,:] #Drop the rows containing missing value we defined
        end
    end
    return dat
end

#Testing
dat = remove_missing_duplicate("pedigree_clean.txt",miss = "0")

#Jiayi modifies and optimizes her original code. She deal with the question that same individuals having different parents.
# remove missing value # may need to add an if loop to allow different missing Type
    dropmissing!(dat)

# remove rows that same individuals having different parents
    SameInd = Array{Int,1}(undef, 0)
    Duplicate_index = dat[nonunique(dat, 1), 1]
    unique!(Duplicate_index)
    for ID in Duplicate_index
        IDindex = findall(x -> x == ID, dat[1])
        append!(SameInd, IDindex)
    end
     
    deleterows!(dat, SameInd)

#Tianjing writes the code to deal with the problem that son has different parents and problem that 
#individual appears in both sire and dam

function remove_dup_son(dat)
    """
    remove duplicate son
    """
    dup_ele = nonunique(dat, 1)
    dup_index=findall(x -> x==true, dup_ele)
    deleterows!(dat, dup_index)

    return dat
end

function same_sire_dam(dat)
    """
    remove element in both dam and sire
    """

    nRow = nrow(dat)
    row_record=[]
    for i in 1:nRow
        dam=dat[i,2]
        if dam in dat[3] && dam != '0' #in sire
            push!(row_record, i)
        end
    end

    deleterows!(dat, row_record)

    return dat
end

#Testing
remove_dup_son(dat)
same_sire_dam(dat)

