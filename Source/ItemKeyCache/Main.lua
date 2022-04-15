function PointBlankSniper.ItemKeyCache.ClearCache()
  POINT_BLANK_SNIPER_ITEM_CACHE = {
    version = 1,
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

    itemKey = PointBlankSniper.Utilities.CleanItemKey(itemKey)

    local keyString = Auctionator.Utilities.ItemKeyString(itemKey)
    if POINT_BLANK_SNIPER_ITEM_CACHE.updateInProgress or cache[keyString] ~= nil or PointBlankSniper.Utilities.IsGear(itemKey.itemID) then
      return
    end

    PointBlankSniper.ItemKeyCache.CleanGetItemKeyInfo(itemKey, function(itemKeyInfo)
      if cache[keyString] == nil then
        PointBlankSniper.Utilities.Message(POINT_BLANK_SNIPER_L_RECORDING_ITEM_X:format(keyString))
        cache[keyString] = true
        table.insert(POINT_BLANK_SNIPER_ITEM_CACHE.newKeys, keyString)
      end
    end)
  end)
end

function PointBlankSniper.ItemKeyCache.PrintInfo()
  PointBlankSniper.Utilities.Message(
    "ItemKeyCache: Unseen Size = " .. #POINT_BLANK_SNIPER_ITEM_CACHE.newKeys ..
                ", Preinstalled Size = " .. #POINT_BLANK_SNIPER_DATA_KEYS.itemKeyStrings
  )
end

-- REMAINDER IS FOR MERGING CACHES AND GETTING THE RIGHT NAMES OUT

function PointBlankSniper.ItemKeyCache.MergeIntoCache(newCache)
  local data = POINT_BLANK_SNIPER_ITEM_CACHE

  for keyString, _ in ipairs(newCache.keysSeen) do
    if data.keysSeen[keyString] == nil then
      data.keysSeen[keyString] = true
      table.insert(data.newKeys, keyString)
    end
  end
end
