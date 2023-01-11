local generators = {}

local function gen_ordered_index(t)
    local ordered_index = {}
    for key in pairs(t) do
        table.insert(ordered_index, key)
    end
    table.sort(ordered_index)
    return ordered_index
end

local function ordered_next(t, state)
    local key = nil
    if state == nil then
        t.__ordered_index = gen_ordered_index(t)
        key = t.__ordered_index[1]
    else
        for i = 1, #t.__ordered_index do
            if t.__ordered_index[i] == state then
                key = t.__ordered_index[i + 1]
            end
        end
    end

    if key then
        return key, t[key]
    end

    t.__ordered_index = nil
end

function generators.sorted_pairs(t)
    return ordered_next, t, nil
end

return generators
