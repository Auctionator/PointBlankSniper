PointBlankSniperDataCoreFrameMixin = {}

function PointBlankSniperDataCoreFrameMixin:OnLoad()
  FrameUtil.RegisterFrameForEvents(self, {
    "VARIABLES_LOADED",
  })
  Auctionator.EventBus:Register(self, {
    PointBlankSniper.Events.TabShown
  })
end

function PointBlankSniperDataCoreFrameMixin:ReceiveEvent(eventName, eventData)
  if eventName == PointBlankSniper.Events.TabShown then
    if #POINT_BLANK_SNIPER_ITEM_CACHE.newKeys > 0 and PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.SHOW_NEW_ITEMS_MESSAGES) then
      PointBlankSniper.Utilities.Message(POINT_BLANK_SNIPER_L_ITEMS_RECORDED)
    end

    if POINT_BLANK_SNIPER_ITEM_CACHE.orderedKeys.timestamp < POINT_BLANK_SNIPER_KNOWN_KEYS.timestamp then
      self.NamesLoader = CreateFrame("frame", nil, AuctionHouseFrame, "PointBlankSniperDataNamesLoaderTemplate")
      self.NamesLoader:StartLoading()
    end
  end
end

function PointBlankSniperDataCoreFrameMixin:OnEvent(event, ...)
  if event == "VARIABLES_LOADED" then
    if POINT_BLANK_SNIPER_ITEM_CACHE == nil or POINT_BLANK_SNIPER_ITEM_CACHE.version ~= 2 then
      PointBlankSniper.ItemKeyCache.ClearCache()
    end
    POINT_BLANK_SNIPER_ITEM_CACHE.updateInProgress = false

    PointBlankSniper.ItemKeyCache.SetupHooks()
  end
end
