function PointBlankSniper.ItemKeyCache.MergeKeys()
  local keys = CopyTable(PointBlankSniper.ItemKeyCache.State.orderedKeys)
  local nameMap = {}
  for index, name in ipairs(keys.names) do
    nameMap[name] = keys.itemKeyStrings[index]
  end
  for index, keyString in ipairs(PointBlankSniper.ItemKeyCache.State.newKeys.itemKeyStrings) do
    local name = PointBlankSniper.ItemKeyCache.State.newKeys.names[index]:lower()
    if nameMap[name] then
      table.insert(nameMap[name], keyString)
    else
      nameMap[name] = {keyString}
      table.insert(keys.itemKeyStrings, nameMap[name])
      table.insert(keys.names, name)
    end
  end

  local indexes = {}
  for i = 1, #keys.names do
    indexes[i] = i
  end
  table.sort(indexes, function(a, b) return keys.names[a] < keys.names[b] end)

  local result = {
    itemKeyStrings = {},
    names = {},
  }
  for j, i in ipairs(indexes) do
    result.itemKeyStrings[j] = keys.itemKeyStrings[i]
    result.names[j] = keys.names[i]
  end

  POINT_BLANK_SNIPER_ITEM_CACHE.orderedKeys = C_EncodingUtil.SerializeCBOR(result)
  PointBlankSniper.ItemKeyCache.State.newKeys.names = {}
  PointBlankSniper.ItemKeyCache.State.newKeys.itemKeyStrings = {}
  PointBlankSniper.ItemKeyCache.State.orderedKeys = result
end
