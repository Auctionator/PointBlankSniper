PointBlankSniperTabFrameMixin = {}

function PointBlankSniperTabFrameMixin:OnLoad()
  Auctionator.Debug.Message("PointBlankSniperTabMixin:OnLoad()")

  self.Alert = CreateAndInitFromMixin(PointBlankSniperAlertMixin)

  Auctionator.EventBus:Register(self, {
    PointBlankSniper.Events.SnipeSearchStart,
    PointBlankSniper.Events.SnipeSearchNewResults,
    PointBlankSniper.Events.SnipeSearchComplete,
    PointBlankSniper.Events.OpenBuyView,
  })
  Auctionator.EventBus:RegisterSource(self, "PointBlankSniperTabFrame")

  PointBlankSniper.Config.InitializeData()

  self:SetupMarketData()
  self.FilterKeySelector:Reset()

  self.ResultsListing:Init(self.DataProvider)
  self.ListName:SetText(PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.CURRENT_LIST))
  self.PriceSource:SetValue(PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.PRICE_SOURCE))
  self.Percentage:SetText(PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.PERCENTAGE) * 100)
  self.FilterKeySelector:SetValue(PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.ITEM_CLASS))
  self.ScanMode:SetSelectedValue(PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.SCAN_MODE))

  self.scanTime = -1
  self.currentBatch = 0
  self.scanCount = 0

  self:UpdateStartButton()
  self:UpdateConfigs()
end

local marketToName = {
  [PointBlankSniper.Constants.Market.None] = AUCTIONATOR_L_NONE,
  [PointBlankSniper.Constants.Market.TUJ_Region] = POINT_BLANK_SNIPER_L_TUJ_REGION,
  [PointBlankSniper.Constants.Market.TUJ_Realm] = POINT_BLANK_SNIPER_L_TUJ_REALM,
  [PointBlankSniper.Constants.Market.TSM_DBMarket] = POINT_BLANK_SNIPER_L_TSM_DBMARKET,
  [PointBlankSniper.Constants.Market.TSM_DBRegionMarketAvg] = POINT_BLANK_SNIPER_L_TSM_DBREGIONMARKETAVG,
  [PointBlankSniper.Constants.Market.TSM_DBRegionSaleAvg] = POINT_BLANK_SNIPER_L_TSM_DBREGIONSALEAVG,
}
function PointBlankSniperTabFrameMixin:SetupMarketData()
  local marketNames = {}
  local marketValues = {}
  for _, m in pairs(PointBlankSniper.Constants.Market) do
    if PointBlankSniper.PriceCheck.IsAvailable(m) then
      table.insert(marketValues, m)
    end
  end

  table.sort(marketValues)
  for _, m in ipairs(marketValues) do
    table.insert(marketNames, marketToName[m])
  end

  -- Try to select some market that isn't None if the chosen market is
  -- unavailable or not configured yet. It will select None if there are no
  -- other options.
  if (not PointBlankSniper.PriceCheck.IsAvailable(PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.PRICE_SOURCE))
      and not PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.WAS_PRICE_SOURCE_CHANGED)
    ) then
    PointBlankSniper.Config.Set(PointBlankSniper.Config.Options.PRICE_SOURCE,  marketValues[2] or PointBlankSniper.Constants.Market.None)
  end

  self.PriceSource:InitAgain(marketNames, marketValues)
end

function PointBlankSniperTabFrameMixin:UpdateStartButton()
  self.StartButton:SetEnabled(Auctionator.ShoppingLists.ListIndex(PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.CURRENT_LIST)) ~= nil)
end

local function FormatTime(scanTime)
  return string.format("%.2f", scanTime / 1000)
end

function PointBlankSniperTabFrameMixin:UpdateStatusMessageOngoing()
  if self.scanTime < 0 then
    self.Status:SetText(POINT_BLANK_SNIPER_L_STATUS_MESSAGE_NO_TIME:format(self.scanCount, self.currentBatch))
  else
    self.Status:SetText(POINT_BLANK_SNIPER_L_STATUS_MESSAGE:format(self.scanCount, self.currentBatch, FormatTime(self.scanTime)))
  end
end

function PointBlankSniperTabFrameMixin:UpdateStatusMessageStopped()
  if self.scanTime < 0 then
    self.Status:SetText(POINT_BLANK_SNIPER_L_STATUS_MESSAGE_STOPPED_NO_TIME:format(self.scanCount))
  else
    self.Status:SetText(POINT_BLANK_SNIPER_L_STATUS_MESSAGE_STOPPED:format(self.scanCount, FormatTime(self.scanTime)))
  end
end

local function ChangeCheck(config, newValue)
  local oldValue = PointBlankSniper.Config.Get(config)
  if oldValue ~= newValue then
    PointBlankSniper.Config.Set(config, newValue)
    return true
  end
  return false
end

function PointBlankSniperTabFrameMixin:UpdateConfigs()
  if ChangeCheck(PointBlankSniper.Config.Options.CURRENT_LIST, self.ListName:GetText()) then
    self:Stop()
  end

  if ChangeCheck(PointBlankSniper.Config.Options.PRICE_SOURCE, self.PriceSource:GetValue()) then
    PointBlankSniper.Config.Set(PointBlankSniper.Config.Options.WAS_PRICE_SOURCE_CHANGED, true)
    self:Stop()
  end

  local percentage = tonumber(self.Percentage:GetText())
  if percentage ~= nil and percentage >= 0 and ChangeCheck(PointBlankSniper.Config.Options.PERCENTAGE, percentage / 100) then
    self:Stop()
  end

  if ChangeCheck(PointBlankSniper.Config.Options.ITEM_CLASS, self.FilterKeySelector:GetValue()) then
    self:Stop()
  end

  if ChangeCheck(PointBlankSniper.Config.Options.SCAN_MODE, self.ScanMode:GetValue()) then
    self:Stop()
  end
end

function PointBlankSniperTabFrameMixin:OnShow()
  Auctionator.EventBus:Fire(self, PointBlankSniper.Events.TabShown)
  self:UpdateStartButton()
  if self.StartButton:IsEnabled() then
    self:Start()
  end
end

function PointBlankSniperTabFrameMixin:Start()
  self.ScannerKeyCache:Stop()
  self.ScannerNameCache:Stop()

  if PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.SCAN_MODE) == PointBlankSniper.Constants.ScanModes.Blank then
    self.Scanner = self.ScannerNameCache
  elseif PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.SCAN_MODE) == PointBlankSniper.Constants.ScanModes.Keys then
    self.Scanner = self.ScannerKeyCache
    self.Scanner:SetKeyFilter(nil)
  elseif PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.SCAN_MODE) == PointBlankSniper.Constants.ScanModes.NoGear then
    self.Scanner = self.ScannerKeyCache
    self.Scanner:SetKeyFilter(function(itemKey)
      return not PointBlankSniper.Utilities.IsGear(itemKey.itemID)
    end)
  end

  self.Scanner:SetPriceCheck(PointBlankSniper.PriceCheck.Get())
  self.Scanner:SetCategories(self.FilterKeySelector:GetValue())
  self.Scanner:SetList(PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.CURRENT_LIST))
  if self.Scanner:GotAnyTerms() then
    self.Scanner:Start()
  end
end

function PointBlankSniperTabFrameMixin:OnUpdate()
  self:UpdateConfigs()
  self:UpdateStartButton()
end

function PointBlankSniperTabFrameMixin:Stop()
  self.ScannerKeyCache:Stop()
  self.ScannerNameCache:Stop()

  self:UpdateStatusMessageStopped()
end

function PointBlankSniperTabFrameMixin:ReceiveEvent(eventName, ...)
  if eventName == PointBlankSniper.Events.SnipeSearchStart then
    self.currentBatch = 1
    self.scanCount = self.scanCount + 1
    self.scanStartTime = debugprofilestop()
    self:UpdateStatusMessageOngoing()
  elseif eventName == PointBlankSniper.Events.SnipeSearchNewResults then
    self.currentBatch = self.currentBatch + 1
    self:UpdateStatusMessageOngoing()
  elseif eventName == PointBlankSniper.Events.SnipeSearchComplete then
    self.scanTime = debugprofilestop() - self.scanStartTime
    self:UpdateStatusMessageOngoing()
    if PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.CARRY_ON_AFTER_RESULT) or not self.Alert:AnyItemsFound() then
      self.Scanner:Start()
    else
      self:Stop()
    end
  elseif eventName == PointBlankSniper.Events.OpenBuyView then
    self:Stop()
  end
end

function PointBlankSniperTabFrameMixin:OpenOptions()
  InterfaceOptionsFrame:Show()
  InterfaceOptionsFrame_OpenToCategory(POINT_BLANK_SNIPER_L_POINT_BLANK_SNIPER)
end
