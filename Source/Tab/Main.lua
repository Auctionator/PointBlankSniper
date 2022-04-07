PointBlankSniperTabFrameMixin = {}

function PointBlankSniperTabFrameMixin:OnLoad()
  Auctionator.Debug.Message("PointBlankSniperTabMixin:OnLoad()")

  Auctionator.EventBus:Register(self, {
    PointBlankSniper.Events.SnipeSearchNewResults,
    PointBlankSniper.Events.SnipeSearchComplete
  })

  POINT_BLANK_SNIPER_CURRENT_LIST = POINT_BLANK_SNIPER_CURRENT_LIST or ""
  POINT_BLANK_SNIPER_DISABLE_BLEEP = POINT_BLANK_SNIPER_DISABLE_BLEEP or false
  POINT_BLANK_SNIPER_DISABLE_FLASH = POINT_BLANK_SNIPER_DISABLE_FLASH or false
  POINT_BLANK_SNIPER_MARKET_DATA = POINT_BLANK_SNIPER_MARKET_DATA or {
    market = PointBlankSniper.Constants.Market.TUJ_Region,
    percentage = 0.15
  }

  self:SetupMarketDataMarketDropdown()

  self.ResultsListing:Init(self.DataProvider)
  self.ListName:SetText(POINT_BLANK_SNIPER_CURRENT_LIST)
  self.UseBleep:SetChecked(not POINT_BLANK_SNIPER_DISABLE_BLEEP)
  self.UseFlash:SetChecked(not POINT_BLANK_SNIPER_DISABLE_FLASH)
  self.MarketDataMarket:SetValue(POINT_BLANK_SNIPER_MARKET_DATA.market)

  self:UpdateStartButton()
  self:UpdateConfigs()
end

function PointBlankSniperTabFrameMixin:SetupMarketDataMarketDropdown()
  self.MarketDataMarket:InitAgain({
    AUCTIONATOR_L_NONE,
    POINT_BLANK_SNIPER_L_TUJ_REGION,
    POINT_BLANK_SNIPER_L_TUJ_REALM
  }, {
    PointBlankSniper.Constants.Market.None,
    PointBlankSniper.Constants.Market.TUJ_Region,
    PointBlankSniper.Constants.Market.TUJ_Realm
  })

  self.MarketDataMarket:SetValue(POINT_BLANK_SNIPER_MARKET_DATA.market)
end

function PointBlankSniperTabFrameMixin:UpdateStartButton()
  self.StartButton:SetEnabled(Auctionator.ShoppingLists.ListIndex(POINT_BLANK_SNIPER_CURRENT_LIST) ~= nil)
end

function PointBlankSniperTabFrameMixin:UpdateConfigs()
  POINT_BLANK_SNIPER_CURRENT_LIST = self.ListName:GetText()
  POINT_BLANK_SNIPER_DISABLE_BLEEP = not self.UseBleep:GetChecked()
  POINT_BLANK_SNIPER_DISABLE_FLASH = not self.UseFlash:GetChecked()

  POINT_BLANK_SNIPER_MARKET_DATA.market = self.MarketDataMarket:GetValue()
end

function PointBlankSniperTabFrameMixin:OnShow()
  self:UpdateStartButton()
  if self.StartButton:IsEnabled() then
    self:Start()
  end
end

function PointBlankSniperTabFrameMixin:Start()
  self.oldResultsCount = 0

  self.Scanner:SetList(POINT_BLANK_SNIPER_CURRENT_LIST)
  self.Scanner:SetMarketCheck(PointBlankSniper.GetMarketDataFunction())
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
end

function PointBlankSniperTabFrameMixin:DoAlert()
  if not POINT_BLANK_SNIPER_DISABLE_BLEEP then
    PlaySoundFile("Interface\\Addons\\PointBlankSniper\\Tones\\Bleep.mp3")
  end
  if not POINT_BLANK_SNIPER_DISABLE_FLASH then
    FlashClientIcon()
  end
end

function PointBlankSniperTabFrameMixin:ReceiveEvent(eventName, ...)
  if eventName == PointBlankSniper.Events.SnipeSearchStart then
  elseif eventName == PointBlankSniper.Events.SnipeSearchNewResults then
    local results = ...
    if #results ~= self.oldResultsCount then
      self.oldResultsCount = #results
      self:DoAlert()
    end
  elseif eventName == PointBlankSniper.Events.SnipeSearchComplete then
    local results = ...
    if #results ~= self.oldResultsCount then
      self.oldResultsCount = #results
      self:DoAlert()
    end
    self.Scanner:Start()
  end
end

function PointBlankSniperTabFrameMixin:OpenOptions()
  InterfaceOptionsFrame:Show()
  InterfaceOptionsFrame_OpenToCategory(COLLECTIONATOR_L_COLLECTIONATOR)
end
