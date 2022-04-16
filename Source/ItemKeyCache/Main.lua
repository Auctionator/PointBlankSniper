--/run POINT_BLANK_SNIPER_ITEM_CACHE.orderedKeys.timestamp = 0
function PointBlankSniper.ItemKeyCache.ClearCache()
  POINT_BLANK_SNIPER_ITEM_CACHE = {
    version = 2,
    orderedKeys = {
      itemKeyStrings = {},
      names = {},
      timestamp = 0,
    },
    updateInProgress = false,
    keysSeen = {},
    newKeys = {},
    missing = {},
  }
end

PointBlankSniper.ItemKeyCache.CleanGetItemKeyInfo = Auctionator.AH.GetItemKeyInfo
function PointBlankSniper.ItemKeyCache.SetupHooks()
  hooksecurefunc(Auctionator.AH, "GetItemKeyInfo", function(itemKey, callback)
    local cache = POINT_BLANK_SNIPER_ITEM_CACHE.keysSeen
    local allNames = POINT_BLANK_SNIPER_ITEM_CACHE.orderedKeys.names
    local allKeyStrings = POINT_BLANK_SNIPER_ITEM_CACHE.orderedKeys.itemKeyStrings

    itemKey = PointBlankSniper.Utilities.CleanItemKey(itemKey)

    local keyString = Auctionator.Utilities.ItemKeyString(itemKey)
    if POINT_BLANK_SNIPER_ITEM_CACHE.updateInProgress or cache[keyString] ~= nil then
      return
    end

    PointBlankSniper.ItemKeyCache.CleanGetItemKeyInfo(itemKey, function(itemKeyInfo)
      if cache[keyString] == nil then
        local name = PointBlankSniper.Utilities.CleanSearchString(itemKeyInfo.itemName)
        local index = PointBlankSniper.Utilities.GetStartingIndex(1, #allNames, allNames, name)
        if allNames[index] == name then
          table.insert(allKeyStrings[index], keyString)
        end
        cache[keyString] = true
        table.insert(POINT_BLANK_SNIPER_ITEM_CACHE.newKeys, keyString)
      end
    end)
  end)
end
