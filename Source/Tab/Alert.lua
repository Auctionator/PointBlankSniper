PointBlankSniperAlertMixin = {}

function PointBlankSniperAlertMixin:Init()
  Auctionator.EventBus:Register(self, {
    PointBlankSniper.Events.SnipeSearchStart,
    PointBlankSniper.Events.SnipeSearchNewResults,
    PointBlankSniper.Events.SnipeSearchComplete
  })

  self:Reset()
end

function PointBlankSniperAlertMixin:Reset()
  self.seenResults = {}
  self.seenInThisScan = {}
  self.itemsFound = false
end

function PointBlankSniperAlertMixin:DoAlert()
  if PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.USE_BLEEP) then
    PlaySoundFile("Interface\\Addons\\PointBlankSniper\\Tones\\Bleep.mp3")
  end
  if PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.USE_FLASH) then
    FlashClientIcon()
  end
end

local function ResultKey(result)
  return Auctionator.Utilities.ItemKeyString(result.itemKey) .. " " .. result.minPrice
end

function PointBlankSniperAlertMixin:ProcessNewResults(results)
  local doAlert = false
  for _, r in ipairs(results) do
    local key = ResultKey(r)
    if not self.seenResults[key] and not self.seenInThisScan[key] then
      doAlert = true
    end
    self.seenInThisScan[key] = true
    self.itemsFound = true
  end

  if doAlert then
    self:DoAlert()
  end
end

function PointBlankSniperAlertMixin:ReceiveEvent(eventName, eventData)
  if eventName == PointBlankSniper.Events.SnipeSearchStart then
    self.itemsFound = false
  elseif eventName == PointBlankSniper.Events.SnipeSearchNewResults then
    self:ProcessNewResults(eventData)
  elseif eventName == PointBlankSniper.Events.SnipeSearchComplete then
    self:ProcessNewResults(eventData)
    self.seenResults = self.seenInThisScan
    self.seenInThisScan = {}
  end
end

function PointBlankSniperAlertMixin:AnyItemsFound()
  return self.itemsFound
end
