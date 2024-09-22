local function all(array, condition)
    for _, value in ipairs(array) do
        if not condition(value) then return false end
    end
    return true
end

return all
