PointBlankSniperAlertMixin = {}

function PointBlankSniperAlertMixin:Init()
  Auctionator.EventBus:Register(self, {
    PointBlankSniper.Events.SnipeSearchStart,
    PointBlankSniper.Events.SnipeSearchNewResults,
    PointBlankSniper.Events.SnipeSearchComplete
  })

  self.seenResults = {}
  self.seenInThisScan = {}
end

function PointBlankSniperAlertMixin:DoAlert()
  if not POINT_BLANK_SNIPER_DISABLE_BLEEP then
    PlaySoundFile("Interface\\Addons\\PointBlankSniper\\Tones\\Bleep.mp3")
  end
  if not POINT_BLANK_SNIPER_DISABLE_FLASH then
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
    if not self.seenResults[key] then
      self.seenResults[key] = true
      doAlert = true
    end
    self.seenInThisScan[key] = true
  end

  if doAlert then
    self:DoAlert()
  end
end

function PointBlankSniperAlertMixin:ReceiveEvent(eventName, eventData)
  if eventName == PointBlankSniper.Events.SnipeSearchStart then
  elseif eventName == PointBlankSniper.Events.SnipeSearchNewResults then
    self:ProcessNewResults(eventData)
  elseif eventName == PointBlankSniper.Events.SnipeSearchComplete then
    self:ProcessNewResults(eventData)
    self.seenResults = self.seenInThisScan
    self.seenInThisScan = {}
  end
end
