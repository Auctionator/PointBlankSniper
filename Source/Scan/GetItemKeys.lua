function PointBlankSniper.Scan.GetItemKeys(searchTerms)
  local strFind = string.find
  local nameCache = PointBlankSniper.ItemKeyCache.State.orderedKeys.names
  local keyCache = PointBlankSniper.ItemKeyCache.State.orderedKeys.itemKeyStrings
  local GetStartingIndex = PointBlankSniper.Utilities.GetStartingIndex
  local IsBlacklistedID = PointBlankSniper.Utilities.IsBlacklistedID

  local keysToSearchFor = {}
  local keysToPrice = {}

  for _, search in ipairs(searchTerms) do
    local searchString = search.searchString
    local index = GetStartingIndex(1, #nameCache, nameCache, searchString)
    while index < #nameCache and strFind(nameCache[index], searchString, 1, true) ~= nil do
      for _, keyString in ipairs(keyCache[index]) do
        local check = true
        local itemKey = PointBlankSniper.Utilities.ItemKeyStringToItemKey(keyString)

        if search.minItemLevel ~= nil then
          check = check and itemKey.itemLevel >= search.minItemLevel
        end

        check = check and (not search.isExact or searchString == nameCache[index])

        check = check and not IsBlacklistedID(itemKey.itemID)

        if check then
          if keysToPrice[keyString] ~= nil then
            keysToPrice[keyString] = math.max(keysToPrice[keyString], search.price or 0)
          else
            table.insert(keysToSearchFor, itemKey)
            keysToPrice[keyString] = search.price
          end
        end
      end
      index = index + 1
    end
  end

  return keysToSearchFor, keysToPrice
end
