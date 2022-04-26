local LibSerialize = LibStub("LibSerialize")

PointBlankSniperDataCoreFrameMixin = {}

function PointBlankSniperDataCoreFrameMixin:OnLoad()
  FrameUtil.RegisterFrameForEvents(self, {
    "VARIABLES_LOADED",
    "PLAYER_LOGOUT",
  })
  Auctionator.EventBus:Register(self, {
    PointBlankSniper.Events.TabShown
  })
end

function PointBlankSniperDataCoreFrameMixin:ReceiveEvent(eventName, eventData)
  if eventName == PointBlankSniper.Events.TabShown then
    if #PointBlankSniper.ItemKeyCache.State.newKeys > 0 and PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.SHOW_NEW_ITEMS_MESSAGES) then
      PointBlankSniper.Utilities.Message(POINT_BLANK_SNIPER_L_ITEMS_RECORDED:format(#PointBlankSniper.ItemKeyCache.State.newKeys))
    end

    if PointBlankSniper.ItemKeyCache.State.orderedKeys.timestamp < POINT_BLANK_SNIPER_KNOWN_KEYS.timestamp then
      self.NamesLoader = CreateFrame("frame", nil, AuctionHouseFrame, "PointBlankSniperDataNamesLoaderTemplate")
      self.NamesLoader:StartLoading()
    end
  end
end

function PointBlankSniperDataCoreFrameMixin:OnEvent(event, ...)
  if event == "VARIABLES_LOADED" then
    if POINT_BLANK_SNIPER_ITEM_CACHE == nil or POINT_BLANK_SNIPER_ITEM_CACHE.version ~= 3 then
      PointBlankSniper.ItemKeyCache.ClearCache()
    end

    if POINT_BLANK_SNIPER_ITEM_CACHE.orderedKeys then
      PointBlankSniper.ItemKeyCache.State.orderedKeys = select(2, LibSerialize:Deserialize(POINT_BLANK_SNIPER_ITEM_CACHE.orderedKeys))
    else
      PointBlankSniper.ItemKeyCache.State.orderedKeys = {
        itemKeyStrings = {},
        names = {},
        timestamp = 0,
      }
    end

    if POINT_BLANK_SNIPER_ITEM_CACHE.keysSeen then
      PointBlankSniper.ItemKeyCache.State.keysSeen = select(2, LibSerialize:Deserialize(POINT_BLANK_SNIPER_ITEM_CACHE.keysSeen))
    else
      PointBlankSniper.ItemKeyCache.State.keysSeen = {}
    end
    PointBlankSniper.ItemKeyCache.State.newKeys = POINT_BLANK_SNIPER_ITEM_CACHE.newKeys

    POINT_BLANK_SNIPER_ITEM_CACHE.updateInProgress = false

    PointBlankSniper.ItemKeyCache.SetupHooks()
  elseif event == "PLAYER_LOGOUT" then
    POINT_BLANK_SNIPER_ITEM_CACHE.keysSeen = LibSerialize:Serialize(PointBlankSniper.ItemKeyCache.State.keysSeen)
  end
end
