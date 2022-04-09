local function ToTUJItemString(itemKey)
  if itemKey.battlePetSpeciesID ~= 0 then
    return "battlepet:" .. itemKey.battlePetSpeciesID
  else
    return "item:" .. itemKey.itemID
  end
end

local function ToTSMItemString(itemKey)
  if itemKey.battlePetSpeciesID ~= 0 then
    return "p:" .. itemKey.battlePetSpeciesID
  else
    return "i:" .. tostring(itemKey.itemID)
  end
end

function PointBlankSniper.GetMarketDataFunction()
  local market = PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.PRICE_SOURCE)
  local percentage = PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.PERCENTAGE)

  if TUJMarketInfo then
    if market == PointBlankSniper.Constants.Market.TUJ_Realm then
      return function(result)
        local tujInfo = {}
        TUJMarketInfo(ToTUJItemString(result.itemKey), tujInfo)
        return tujInfo['market'] and result.minPrice <= tujInfo['market'] * percentage
      end
    elseif market == PointBlankSniper.Constants.Market.TUJ_Region then
      return function(result)
        local tujInfo = {}
        TUJMarketInfo(ToTUJItemString(result.itemKey), tujInfo)
        return tujInfo['globalMedian'] and result.minPrice <= tujInfo['globalMedian'] * percentage
      end
    end
  end

  if TSM_API then
    if market == PointBlankSniper.Constants.Market.TSM_DBMarket then
      return function(result)
        local TSMPrice = TSM_API.GetCustomPriceValue("dbmarket", ToTSMItemString(result.itemKey))
        return TSMPrice and result.minPrice <= TSMPrice * percentage
      end
    end
  end
end

function PointBlankSniper.IsMarketDataActive(market)
  if TUJMarketInfo then
    if market == PointBlankSniper.Constants.Market.TUJ_Realm then
      return true
    elseif market == PointBlankSniper.Constants.Market.TUJ_Region then
      return true
    end
  end

  if TSM_API then
    if market == PointBlankSniper.Constants.Market.TSM_DBMarket then
      return true
    end
  end

  if market == PointBlankSniper.Constants.Market.None then
    return true
  end

  return false
end
