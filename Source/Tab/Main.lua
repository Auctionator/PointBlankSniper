PointBlankSniperTabFrameMixin = {}

function PointBlankSniperTabFrameMixin:OnLoad()
  Auctionator.Debug.Message("PointBlankSniperTabMixin:OnLoad()")

  Auctionator.EventBus:Register(self, {
    PointBlankSniper.Events.SnipeSearchStart,
    PointBlankSniper.Events.SnipeSearchNewResults,
    PointBlankSniper.Events.SnipeSearchComplete
  })

  PointBlankSniper.Config.InitializeData()

  self.Alert = CreateAndInitFromMixin(PointBlankSniperAlertMixin)

  self:SetupMarketData()

  self.ResultsListing:Init(self.DataProvider)
  self.ListName:SetText(PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.CURRENT_LIST))
  self.UseBleep:SetChecked(PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.USE_BLEEP))
  self.UseFlash:SetChecked(PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.USE_FLASH))
  self.CarryOnAfterResult:SetChecked(PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.CARRY_ON_AFTER_RESULT))
  self.PriceSource:SetValue(PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.PRICE_SOURCE))
  self.Percentage:SetText(PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.PERCENTAGE) * 100)

  self.scanTime = -1
  self.currentBatch = 0
  self.scanCount = 0

  self:UpdateStartButton()
  self:UpdateConfigs()
  self.FilterKeySelector:Reset()
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
    if PointBlankSniper.IsMarketDataActive(m) then
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
  if (not PointBlankSniper.IsMarketDataActive(PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.PRICE_SOURCE))
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

function PointBlankSniperTabFrameMixin:UpdateConfigs()
  PointBlankSniper.Config.Set(PointBlankSniper.Config.Options.CURRENT_LIST, self.ListName:GetText())
  PointBlankSniper.Config.Set(PointBlankSniper.Config.Options.USE_BLEEP, self.UseBleep:GetChecked())
  PointBlankSniper.Config.Set(PointBlankSniper.Config.Options.USE_FLASH, self.UseFlash:GetChecked())
  PointBlankSniper.Config.Set(PointBlankSniper.Config.Options.CARRY_ON_AFTER_RESULT, self.CarryOnAfterResult:GetChecked())

  local oldMarket = PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.PRICE_SOURCE)
  if oldMarket ~= self.PriceSource:GetValue() then
    PointBlankSniper.Config.Set(PointBlankSniper.Config.Options.PRICE_SOURCE, self.PriceSource:GetValue())
    PointBlankSniper.Config.Set(PointBlankSniper.Config.Options.WAS_PRICE_SOURCE_CHANGED, true)
  end

  local percentage = tonumber(self.Percentage:GetText())
  if percentage ~= nil and percentage >= 0 then
    PointBlankSniper.Config.Set(PointBlankSniper.Config.Options.PERCENTAGE, percentage / 100)
  end
end

function PointBlankSniperTabFrameMixin:OnShow()
  self:UpdateStartButton()
  if self.StartButton:IsEnabled() then
    self:Start()
  end
end

function PointBlankSniperTabFrameMixin:Start()
  self.oldResultsCount = 0

  self.Scanner:SetList(PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.CURRENT_LIST))
  self.Scanner:SetMarketCheck(PointBlankSniper.GetMarketDataFunction())
  self.Scanner:SetCategories(self.FilterKeySelector:GetValue())
  self.Scanner:Start()
end

function PointBlankSniperTabFrameMixin:OnUpdate()
  self:UpdateConfigs()
  self:UpdateStartButton()
  if not self.StartButton:IsEnabled() then
    self:Stop()
  end
end

function PointBlankSniperTabFrameMixin:Stop()
  self.Scanner:Stop()
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
  end
end

function PointBlankSniperTabFrameMixin:OpenOptions()
  InterfaceOptionsFrame:Show()
  InterfaceOptionsFrame_OpenToCategory(COLLECTIONATOR_L_COLLECTIONATOR)
end
