PointBlankSniperDataCoreFrameMixin = {}

function PointBlankSniperDataCoreFrameMixin:OnLoad()
  FrameUtil.RegisterFrameForEvents(self, {
    "VARIABLES_LOADED",
  })
  Auctionator.EventBus:Register(self, {
    PointBlankSniper.Events.SetupKeysSearch,
    PointBlankSniper.Events.MergeKeys,
  })
  PointBlankSniper.ItemKeyCache.State.NotYetLoaded = true
end

function PointBlankSniperDataCoreFrameMixin:ReceiveEvent(eventName, eventData)
  if eventName == PointBlankSniper.Events.SetupKeysSearch then
    if PointBlankSniper.ItemKeyCache.State.NotYetLoaded then
      PointBlankSniper.ItemKeyCache.State.NotYetLoaded = false
      self:Initialize()
    end

    if #PointBlankSniper.ItemKeyCache.State.newKeys.names > 0 and PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.SHOW_NEW_ITEMS_MESSAGES) then
      PointBlankSniper.Utilities.Message(POINT_BLANK_SNIPER_L_ITEMS_RECORDED:format(#PointBlankSniper.ItemKeyCache.State.newKeys.names))
    end
  elseif eventName == PointBlankSniper.Events.MergeKeys then
    if PointBlankSniper.ItemKeyCache.State.NotYetLoaded then
      return
    end
    PointBlankSniper.ItemKeyCache.MergeKeys()
  end
end

function PointBlankSniperDataCoreFrameMixin:OnEvent(event, addonName)
  if event == "ADDON_LOADED" and addonName == "PointBlankSniper" then
    if POINT_BLANK_SNIPER_ITEM_CACHE == nil or POINT_BLANK_SNIPER_ITEM_CACHE.version ~= 4 then
      PointBlankSniper.ItemKeyCache.ClearCache()
    end
  end
end

function PointBlankSniperDataCoreFrameMixin:Initialize()
  if POINT_BLANK_SNIPER_ITEM_CACHE.orderedKeys then
    if PointBlankSniper.ItemKeyCache.State.orderedKeys == nil then
      PointBlankSniper.ItemKeyCache.State.orderedKeys = C_EncodingUtil.DeserializeCBOR(POINT_BLANK_SNIPER_ITEM_CACHE.orderedKeys)
    end
  else
    PointBlankSniper.ItemKeyCache.State.orderedKeys = {
      itemKeyStrings = {},
      names = {},
    }
  end

  PointBlankSniper.ItemKeyCache.State.keysSeen = {}
  PointBlankSniper.ItemKeyCache.State.newKeys = POINT_BLANK_SNIPER_ITEM_CACHE.newKeys
  for _, keys in ipairs(PointBlankSniper.ItemKeyCache.State.orderedKeys.itemKeyStrings) do
    for _, k in ipairs(keys) do
      PointBlankSniper.ItemKeyCache.State.keysSeen[k] = true
    end
  end
  for _, key in ipairs(PointBlankSniper.ItemKeyCache.State.newKeys) do
    PointBlankSniper.ItemKeyCache.State.keysSeen[key] = true
  end

  POINT_BLANK_SNIPER_ITEM_CACHE.updateInProgress = false

  PointBlankSniper.ItemKeyCache.SetupHooks()
end
