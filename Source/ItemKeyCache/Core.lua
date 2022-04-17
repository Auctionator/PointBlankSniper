PointBlankSniperDataCoreFrameMixin = {}

function PointBlankSniperDataCoreFrameMixin:OnLoad()
  FrameUtil.RegisterFrameForEvents(self, {
    "VARIABLES_LOADED",
    "AUCTION_HOUSE_SHOW",
  })
end

function PointBlankSniperDataCoreFrameMixin:ReceiveEvent(eventName, eventData)
  if eventName == Auctionator.FullScan.Events.ScanComplete then
  end
end

function PointBlankSniperDataCoreFrameMixin:OnEvent(event, ...)
  if event == "VARIABLES_LOADED" then
    if POINT_BLANK_SNIPER_ITEM_CACHE == nil or POINT_BLANK_SNIPER_ITEM_CACHE.version ~= 1 then
      PointBlankSniper.ItemKeyCache.ClearCache()
    end
    POINT_BLANK_SNIPER_ITEM_CACHE.updateInProgress = false

    PointBlankSniper.ItemKeyCache.SetupHooks()

  elseif event == "AUCTION_HOUSE_SHOW" and POINT_BLANK_SNIPER_ITEM_CACHE.orderedKeys.timestamp < POINT_BLANK_SNIPER_KNOWN_COMMODITY_KEYS.timestamp then
    self.NamesLoader = CreateFrame("frame", nil, AuctionHouseFrame, "PointBlankSniperDataNamesLoaderTemplate")
    self.NamesLoader:StartLoading()
  end
end
