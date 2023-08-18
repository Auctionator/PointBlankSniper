local LibSerialize = LibStub("LibSerialize")

PointBlankSniperDataCoreFrameMixin = {}

function PointBlankSniperDataCoreFrameMixin:OnLoad()
  FrameUtil.RegisterFrameForEvents(self, {
    "VARIABLES_LOADED",
  })
  Auctionator.EventBus:Register(self, {
    PointBlankSniper.Events.SetupKeysSearch
  })
  PointBlankSniper.ItemKeyCache.State.NotYetLoaded = true
end

function PointBlankSniperDataCoreFrameMixin:ReceiveEvent(eventName, eventData)
  if eventName == PointBlankSniper.Events.SetupKeysSearch then
    if PointBlankSniper.ItemKeyCache.State.NotYetLoaded then
      self:Initialize()
    end

    if #PointBlankSniper.ItemKeyCache.State.newKeys > 0 and PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.SHOW_NEW_ITEMS_MESSAGES) then
      PointBlankSniper.Utilities.Message(POINT_BLANK_SNIPER_L_ITEMS_RECORDED:format(#PointBlankSniper.ItemKeyCache.State.newKeys))
    end

    if PointBlankSniper.ItemKeyCache.State.orderedKeys.timestamp < POINT_BLANK_SNIPER_KNOWN_KEYS.timestamp then
      self.NamesLoader = CreateFrame("frame", nil, AuctionHouseFrame, "PointBlankSniperDataNamesLoaderTemplate")
      self.NamesLoader:StartLoading()
    end
  end
end

function PointBlankSniperDataCoreFrameMixin:OnUpdate()
  local stepLeft = 500
  while stepLeft > 0 do
    if self.seenIndex > #PointBlankSniper.ItemKeyCache.State.orderedKeys.itemKeyStrings then
      self:SetScript("OnUpdate", nil)
      PointBlankSniper.ItemKeyCache.State.NotYetLoaded = false
      break
    end
    for _, key in ipairs(PointBlankSniper.ItemKeyCache.State.orderedKeys.itemKeyStrings[self.seenIndex]) do
      PointBlankSniper.ItemKeyCache.State.keysSeen[key] = true
    end
    stepLeft = stepLeft - 1
    self.seenIndex = self.seenIndex + 1
  end
end

function PointBlankSniperDataCoreFrameMixin:OnEvent(event, ...)
  if event == "VARIABLES_LOADED" then
    if POINT_BLANK_SNIPER_ITEM_CACHE == nil or POINT_BLANK_SNIPER_ITEM_CACHE.version ~= 3 then
      PointBlankSniper.ItemKeyCache.ClearCache()
    end
  end
end

function PointBlankSniperDataCoreFrameMixin:Initialize()
  if POINT_BLANK_SNIPER_ITEM_CACHE.orderedKeys then
    if PointBlankSniper.ItemKeyCache.State.orderedKeys == nil then
      PointBlankSniper.ItemKeyCache.State.orderedKeys = select(2, LibSerialize:Deserialize(POINT_BLANK_SNIPER_ITEM_CACHE.orderedKeys))
    end
  else
    PointBlankSniper.ItemKeyCache.State.orderedKeys = {
      itemKeyStrings = {},
      names = {},
      timestamp = 0,
    }
  end

  self.seenIndex = 1
  self:SetScript("OnUpdate", self.OnUpdate)
  PointBlankSniper.ItemKeyCache.State.keysSeen = {}
  PointBlankSniper.ItemKeyCache.State.newKeys = POINT_BLANK_SNIPER_ITEM_CACHE.newKeys
  for _, key in ipairs(PointBlankSniper.ItemKeyCache.State.newKeys) do
    PointBlankSniper.ItemKeyCache.State.keysSeen[key] = true
  end

  POINT_BLANK_SNIPER_ITEM_CACHE.updateInProgress = false

  PointBlankSniper.ItemKeyCache.SetupHooks()
end
