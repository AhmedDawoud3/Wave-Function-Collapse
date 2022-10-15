function IsInTable(value, table)
  for i, v in ipairs(table) do if v == value then return i end end
  return false
end

function IsTheSameTable(a, b)
  return table.concat(a) == table.concat(b)
end

function FilterBadOnesIfThere(tbl, bad)
  local t = {}
  for i, v in ipairs(tbl) do
    if not IsInTable(v, bad) then
      table.insert(t, v)
    end
  end
  return t
end