local function map(func, arr)
  local result = {}
  for _, v in ipairs(arr) do
    table.insert(result, func(v))
  end
  return result
end

return map
