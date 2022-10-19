function PointBlankSniper.PriceCheck.Get()
  local market = PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.PRICE_SOURCE)
  local percentage = PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.PERCENTAGE)

  if TUJMarketInfo then
    if market == PointBlankSniper.Constants.Market.TUJ_Realm then
      return CreateAndInitFromMixin(PointBlankSniper.PriceCheck.TUJMixin, 'market', percentage)
    elseif market == PointBlankSniper.Constants.Market.TUJ_Region then
      return CreateAndInitFromMixin(PointBlankSniper.PriceCheck.TUJMixin, 'globalMedian', percentage)
    end
  end

  if TSM_API then
    if market == PointBlankSniper.Constants.Market.TSM_DBMarket then
      return CreateAndInitFromMixin(PointBlankSniper.PriceCheck.TSMMixin, 'dbmarket', percentage)
    elseif market == PointBlankSniper.Constants.Market.TSM_DBRegionMarketAvg then
      return CreateAndInitFromMixin(PointBlankSniper.PriceCheck.TSMMixin, 'dbregionmarketavg', percentage)
    elseif market == PointBlankSniper.Constants.Market.TSM_DBRegionSaleAvg then
      return CreateAndInitFromMixin(PointBlankSniper.PriceCheck.TSMMixin, 'dbregionsaleavg', percentage)
    elseif market == PointBlankSniper.Constants.Market.TSM_VendorSellPrice then
      return CreateAndInitFromMixin(PointBlankSniper.PriceCheck.TSMMixin, 'vendorsell', percentage)
    end
  end

  if OEMarketInfo then
    if market == PointBlankSniper.Constants.Market.OE_Realm then
      return CreateAndInitFromMixin(PointBlankSniper.PriceCheck.OEMixin, 'market', percentage)
    elseif market == PointBlankSniper.Constants.Market.OE_Region then
      return CreateAndInitFromMixin(PointBlankSniper.PriceCheck.OEMixin, 'region', percentage)
    end
  end

  return CreateFromMixins(PointBlankSniper.PriceCheck.NoneMixin)
end

function PointBlankSniper.PriceCheck.IsAvailable(marketDataType)
  if TUJMarketInfo then
    if marketDataType == PointBlankSniper.Constants.Market.TUJ_Realm then
      return true
    elseif marketDataType == PointBlankSniper.Constants.Market.TUJ_Region then
      return true
    end
  end

  if TSM_API then
    if marketDataType == PointBlankSniper.Constants.Market.TSM_DBMarket then
      return true
    elseif marketDataType == PointBlankSniper.Constants.Market.TSM_DBRegionMarketAvg then
      return true
    elseif marketDataType == PointBlankSniper.Constants.Market.TSM_DBRegionSaleAvg then
      return true
    elseif marketDataType == PointBlankSniper.Constants.Market.TSM_VendorSellPrice then
      return true
    end
  end

  if OEMarketInfo then
    if marketDataType == PointBlankSniper.Constants.Market.OE_Realm then
      return true
    elseif marketDataType == PointBlankSniper.Constants.Market.OE_Region then
      return true
    end
  end

  if marketDataType == PointBlankSniper.Constants.Market.None then
    return true
  end

  return false
end
