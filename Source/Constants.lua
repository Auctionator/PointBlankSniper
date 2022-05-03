PointBlankSniper.Constants = {
  Market = {
    None = 0,
    TUJ_Region = 1,
    TUJ_Realm = 2,
    TSM_DBMarket = 3,
    TSM_DBRegionMarketAvg = 4,
    TSM_DBRegionSaleAvg = 5,
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
  DefaultFilters = {
    Enum.AuctionHouseFilter.PoorQuality,
    Enum.AuctionHouseFilter.CommonQuality,
    Enum.AuctionHouseFilter.UncommonQuality,
    Enum.AuctionHouseFilter.RareQuality,
    Enum.AuctionHouseFilter.EpicQuality,
    Enum.AuctionHouseFilter.LegendaryQuality,
    Enum.AuctionHouseFilter.ArtifactQuality,
  },
}
