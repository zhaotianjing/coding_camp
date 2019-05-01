# Zigui writes the code to remove missing value and duplicate rows. And try to deal with the white space. But the code is too redundant and needs improvement.
function remove_missing_duplicate(file; delim = ',', header = 0,miss = missing)
    """
    Remove missing value and duplicate
    """
    dat = CSV.read(file, delim = delim, header = header)
    dat = unique!(dat) #remove duplicate
    nCol = ncol(dat)
    dat = dropmissing(dat) 
    #Drop the missing value defined in julia
    
    if ismissing(miss)  
        #Check the if the user defined missing value is the missing
        return dat   
        #The user defined missing value is the missing, already removed
        
    else
    #The user defined missing value is not the missing, we need to remove the 
    #rows containing user defined missing value
        for i in 1:nCol
            dat = dat[dat[:,i].!=miss,:] #Remove rows containing user defined missing value
        end
    end
    return dat
    
end

#Testing
dat = remove_missing_duplicate("pedigree_clean.txt",miss = missing)

#function can deal with the white space,it works but too redundant. Need imporvement.
function remove_missing_duplicate_2(file; delim = ',', header = 0,miss = missing)
    """
    Remove missing value and duplicate and can deal with the case of white space.
    But too redundant, needs improvement
    """
    dat = CSV.read(file, delim = delim, header = header) # no header 
    dat = unique!(dat) #remove duplicate
    nCol = ncol(dat)
    nRow = nrow(dat)
    dat = dropmissing(dat) #Drop the julia missing value (missing)
    
    if ismissing(miss)  
        #Check the if the user defined missing value is the missing
        return dat   
        #The user defined missing value is the missing, already removed
        
    else
    #The user defined missing value is not the missing, we need to remove the 
    #rows containing user defined missing value
        for i in 1:nCol
            row_record = []
            for j in 1:nrow(dat)
                dat[j,i] = strip(dat[j,i])
                if isempty(dat[j,i])
                    push!(row_record,j)
                end
            end
            dat = deleterows!(dat, row_record)
            dat = dat[dat[:,i].!=miss,:] #Remove rows containing user defined missing value
        end
    end
    return dat
    
end

#Testing
dat = remove_missing_duplicate_2("pedigree_clean.txt",miss = "0")

#Jiayi deal with the question that same individuals having different parents and remove missing value. And add three warnings which can be seen in the function documentation.
function ErrorDetection(file; delim = ',', header = 0, missingType = missing)
    """
    Input: pedigree.txt file 
    Output: DataFrame
    Remove missing values given input missing Type, and give corresponding warnings
    Remove leading and trailing whitespace between values
    Remove rows that same individuals having different parents, and give corresponding warnings
    """
    dat = CSV.read(file, delim = delim, header = header) 
    nCol = ncol(dat)
    
    # remove missing value 
    if ismissing(missingType) # if missing values are just left empty in the pedigree
        MissingIndex = findall(ismissing, convert(Array,dat)) # an array of CartesianIndex
        indexForMissing = [value[1] for (i, value) in enumerate(MissingIndex)]
        dropmissing!(dat) 
    else
        indexForMissing =  Array{Int,1}(undef, 0)
        for cols in 1:nCol
            Mindex = findall(x -> x == missingType, dat[cols]) # find all the rows that contain missing values
            append!(indexForMissing, Mindex)
        end
        unique!(indexForMissing) # get the unique combination of rows to delete
        deleterows!(dat, indexForMissing)
    end
        
   if !isempty(indexForMissing)
        sort!(indexForMissing)
        println("Warning: Missing values are found in row $indexForMissing and corresponding rows were deleted!")
   end
    
    # remove leading and trailing whitespace between values
    
    nCol = ncol(dat)
    for cols in 1:nCol 
        if any(typeof.(dat[cols]) .== String) 
        dat[cols] = strip.(dat[cols])
        end
    end
        
    
    # remove duplicate rows
    unique!(dat)
    
    index = collect(1:1:nrow(dat))
    
    # remove rows that same individuals having different parents
    SameInd = Array{Int,1}(undef, 0)
    Duplicate_index = dat[nonunique(dat, 1), 1]
    unique!(Duplicate_index)
    for ID in Duplicate_index
        IDindex = findall(x -> x == ID, dat[1])
        append!(SameInd, IDindex)
    end
    
    Duplicate_index=String.(Duplicate_index)
    println("Warning: Same individuals with different parents are found for individuals $Duplicate_index and corresponding rows were deleted!")
    deleterows!(dat, SameInd)
    return dat
end

#Tianjing re-write the code to deal with the problem that individual appears in both sire and dam.
function remove_dup_son(dat) #HAO: GOOD, SEE LINE 37
    """
    Goal:   remove duplicate son (this step is after removing all duplicate)
    Input:  a4 a1 a2
            a4 a9 a10
            a4 a6 a2
    Output: a4 a1 a2
    """
    dup_ele = nonunique(dat, 1)
    dup_index=findall(x -> x==true, dup_ele)
    deleterows!(dat, dup_index)

    return dat
end

#Testing
dat=remove_dup_son(dat)

function same_sire_dam(dat, root_signal = "0") 
    """
    Goal:   remove element in both dam and sire
    Input:  a8  a4 a6
            a9  a4 a6
            a13 a6 a2
    Output: empty
    """
    dup = intersect(dat[2], dat[3])
    filter!(e -> e ≠ root_signal, dup)  #remove the dam and sire of root, eg. "0"
    dup_both = vcat(findall(x->x in dup, dat[2]),findall(x->x in dup, dat[3])) #find index of dup

    unique!(dup_both)
    sort!(dup_both)

    deleterows!(dat, dup_both)

    return dat
end

#Testing
dat = same_sire_dam(dat)

function quality_control(file; delim = ',', header = 0,miss = missing)
    #Jiayi
    dat = ErrorDetection(file; delim = delim, header = header, missingType = miss)
    
    #zigui 
    #dat = remove_missing_duplicate_2(file; delim = delim, header = header,miss = miss) #Remove missing and duplicate
    
    #Tianjing
    dat = same_sire_dam(dat) #individual appear in sire and dam
    dat = remove_dup_son(dat) #individual has different father and mother
    return dat
end

#Testing
quality_control("pedigree_clean.txt",miss = missing)
