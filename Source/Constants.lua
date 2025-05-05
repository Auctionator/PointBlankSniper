PointBlankSniper.Constants = {
  Market = {
    None = 0,
    TSM_DBMarket = 3,
    TSM_DBRecent = 4,
    TSM_DBRegionMarketAvg = 5,
    TSM_DBRegionSaleAvg = 6,
    TSM_VendorSellPrice = 7,
    OE_Realm = 13,
    OE_Region = 14,
  },
  VendorBlacklist = {
    38, --Recruit's Shirt (vendor version)
    45, --Squire's Shirt (vendor version)
  },
  ScanModes = {
    Blank = 1,
    Keys = 2,
    NoGear = 3,
    Threshold = 4,
  },

  KeysThreshold = 20000,
}

PointBlankSniper.Constants.MarketToName = {
  [PointBlankSniper.Constants.Market.None] = AUCTIONATOR_L_NONE,
  [PointBlankSniper.Constants.Market.TSM_DBMarket] = POINT_BLANK_SNIPER_L_TSM_DBMARKET,
  [PointBlankSniper.Constants.Market.TSM_DBRecent] = POINT_BLANK_SNIPER_L_TSM_DBRECENT,
  [PointBlankSniper.Constants.Market.TSM_DBRegionMarketAvg] = POINT_BLANK_SNIPER_L_TSM_DBREGIONMARKETAVG,
  [PointBlankSniper.Constants.Market.TSM_DBRegionSaleAvg] = POINT_BLANK_SNIPER_L_TSM_DBREGIONSALEAVG,
  [PointBlankSniper.Constants.Market.TSM_VendorSellPrice] = POINT_BLANK_SNIPER_L_TSM_VENDORSELL,
  [PointBlankSniper.Constants.Market.OE_Realm] = POINT_BLANK_SNIPER_L_OE_REALM,
  [PointBlankSniper.Constants.Market.OE_Region] = POINT_BLANK_SNIPER_L_OE_REGION,
}
