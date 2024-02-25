function postostring(pos)
    return pos.x .. ' ' .. pos.y .. ' ' .. pos.z
end

function dirtostring(dir)
    for k, v in pairs(Directions) do
        if v == dir then
            return k
        end
    end
end

function comma_value(n)
    local left, num, right = string.match(n, '^([^%d]*%d)(%d*)(.-)$')
    return left .. (num:reverse():gsub('(%d%d%d)', '%1,'):reverse()) .. right
end


function dd(table)
  for index, data in ipairs(table) do
      print(index)

      for key, value in pairs(data) do
          print(key, value)
      end
  end
end

function print_r(arr, indentLevel)
    local str = ""
    local indentStr = "#"

    if(indentLevel == nil) then
        print(print_r(arr, 0))
        return
    end

    for i = 0, indentLevel do
        indentStr = indentStr.."\t"
    end

    for index,value in pairs(arr) do
        if type(value) == "table" then
            str = str..indentStr..index..": \n"..print_r(value, (indentLevel + 1))
        else
            str = str..indentStr..index..": "..value.."\n"
        end
    end
    return str
end

function inArray(id, elements)
  for i=1, #elements do
    if elements[i] == id then
       return true
     end
  end

  return false
end

function isInArray(array, value) return table.contains(array, value) end


function esc(x)
   return (x:gsub('%+', '%%+')
            :gsub('%-', '%%-')
            )
end
