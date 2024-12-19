begin
    values1 = findall(((0:2^24-1) .<< 24) .+ good[1]) do v
        r = program2(v)
        length(r) >= 13 && (@view(program2(v)[1:13]) == instructions[1:13])
    end
    values2 = findall(((0:2^24-1) .<< 24) .+ good[2]) do v
        r = program2(v)
        length(r) >= 13 && (@view(program2(v)[1:13]) == instructions[1:13])
    end
    values3 = findall(((0:2^24-1) .<< 24) .+ good[3]) do v
        r = program2(v)
        length(r) >= 13 && (@view(program2(v)[1:13]) == instructions[1:13])
    end
    values4 = findall(((0:2^24-1) .<< 24) .+ good[4]) do v
        r = program2(v)
        length(r) >= 13 && (@view(program2(v)[1:13]) == instructions[1:13])
    end
    values5 = findall(((0:2^24-1) .<< 24) .+ good[5]) do v
        r = program2(v)
        length(r) >= 13 && (@view(program2(v)[1:13]) == instructions[1:13])
    end
    nums1 = ((0:2^24-1) .<< 24) .+ good[1]
    nums2 = ((0:2^24-1) .<< 24) .+ good[2]
    nums3 = ((0:2^24-1) .<< 24) .+ good[3]
    nums4 = ((0:2^24-1) .<< 24) .+ good[4]
    nums5 = ((0:2^24-1) .<< 24) .+ good[5]
    good = unique(vcat(nums1[values1], nums2[values2], nums3[values3], nums4[values4], nums5[values5]) .% 2^27)
end

