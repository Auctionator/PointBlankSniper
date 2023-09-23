PointBlankSniper.Utilities = {}

function PointBlankSniper.Utilities.CleanSearchString(searchString)
  return string.lower(searchString)
end

local VendorBlacklist = PointBlankSniper.Constants.VendorBlacklist

function PointBlankSniper.Utilities.IsBlacklistedID(itemID)
  return tIndexOf(VendorBlacklist, itemID) ~= nil
end

local function GetStartingIndex(startPoint, endPoint, array, searchString)
  if startPoint >= endPoint then
    return startPoint
  end

  local midPoint = math.floor((startPoint + endPoint)/2)

  local entry = array[midPoint]
  if (midPoint == 1 or array[midPoint - 1] < searchString) and entry >= searchString then
    return midPoint
  elseif entry < searchString then
    return GetStartingIndex(midPoint + 1, endPoint, array, searchString)
  else--if entry >= searchString then
    return GetStartingIndex(startPoint, midPoint - 1, array, searchString)
  end
end

PointBlankSniper.Utilities.GetStartingIndex = GetStartingIndex

function PointBlankSniper.Utilities.ConvertList(list)
  local CleanSearchString = PointBlankSniper.Utilities.CleanSearchString

  local result = {}
  for _, entry in ipairs(list:GetAllItems()) do
    local advancedParams = Auctionator.Search.SplitAdvancedSearch(entry)
    table.insert(result, {
      searchString = CleanSearchString(advancedParams.searchString),
      price = advancedParams.maxPrice,
      minItemLevel = advancedParams.minItemLevel,
      maxItemLevel = advancedParams.maxItemLevel,
      tier = advancedParams.tier,
      isExact = advancedParams.isExact,
      rawSearchTerm = entry,
    })
  end
  return result
end

function PointBlankSniper.Utilities.ItemKeyStringToItemKey(itemKeyString)
  local itemID, itemSuffix, itemLevel, battlePetSpeciesID = itemKeyString:match("(%d+) (%d+) (%d+) (%d+)")
  -- Necessary to create key manually as the C_AuctionHouse function sets the
  -- itemLevel to 20 on battle pets
  return {
    itemID = tonumber(itemID),
    itemLevel = tonumber(itemLevel),
    itemSuffix = tonumber(itemSuffix),
    battlePetSpeciesID = tonumber(battlePetSpeciesID)
  }
end

function PointBlankSniper.Utilities.IsGear(itemID)
  local classID = select(6, GetItemInfoInstant(itemID))
  return classID == Enum.ItemClass.Weapon or classID == Enum.ItemClass.Armor
end

function PointBlankSniper.Utilities.CleanItemKey(itemKey)
  if Auctionator.Constants.PET_CAGE_ID == itemKey.itemID then
    return {
      itemID = itemKey.itemID,
      itemLevel = 0,
      itemSuffix = 0,
      battlePetSpeciesID = itemKey.battlePetSpeciesID,
    }
  else
    return itemKey
  end
end

function PointBlankSniper.Utilities.Message(message)
  print(
    DIM_GREEN_FONT_COLOR:WrapTextInColorCode("Point Blank Sniper: ") ..
    message
  )
end
