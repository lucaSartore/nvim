local function find(element, array, compare)
    for _, value in pairs(array) do
        if compare(element,value) then
            return true
        end
    end
    return false
end

return find
