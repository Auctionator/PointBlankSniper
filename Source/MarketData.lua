local function ToItemString(itemKey)
  if itemKey.battlePetSpeciesID ~= 0 then
    return "battlepet:" .. itemKey.battlePetSpeciesID
  else
    return "item:" .. itemKey.itemID
  end
end

function PointBlankSniper.GetMarketDataFunction()
  local percentage = POINT_BLANK_SNIPER_MARKET_DATA.percentage
  local market = POINT_BLANK_SNIPER_MARKET_DATA.market

  if TUJMarketInfo then
    if market == PointBlankSniper.Constants.Market.TUJ_Realm then
      return function(result)
        local tujInfo = {}
        TUJMarketInfo(ToItemString(result.itemKey), tujInfo)
        return tujInfo['market'] and result.minPrice <= tujInfo['market'] * percentage
      end
    elseif market == PointBlankSniper.Constants.Market.TUJ_Region then
      return function(result)
        local tujInfo = {}
        TUJMarketInfo(ToItemString(result.itemKey), tujInfo)
        return tujInfo['globalMedian'] and result.minPrice <= tujInfo['globalMedian'] * percentage
      end
    end
  end
end
