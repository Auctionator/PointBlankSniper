PointBlankSniperTabFrameMixin = {}

function PointBlankSniperTabFrameMixin:OnLoad()
  Auctionator.Debug.Message("PointBlankSniperTabMixin:OnLoad()")

  Auctionator.EventBus:Register(self, {
    PointBlankSniper.Events.SnipeSearchNewResults,
    PointBlankSniper.Events.SnipeSearchComplete
  })

  POINT_BLANK_SNIPER_CURRENT_LIST = POINT_BLANK_SNIPER_CURRENT_LIST or ""

  self.ResultsListing:Init(self.DataProvider)
  self.ListName:SetText(POINT_BLANK_SNIPER_CURRENT_LIST)
  self.StartButton:SetEnabled(Auctionator.ShoppingLists.ListIndex(POINT_BLANK_SNIPER_CURRENT_LIST) ~= nil)
end

function PointBlankSniperTabFrameMixin:OnShow()
  if self.StartButton:IsEnabled() then
    self:Start()
  end
end

function PointBlankSniperTabFrameMixin:Start()
  self.oldResultsCount = 0

  self.Scanner:SetList(POINT_BLANK_SNIPER_CURRENT_LIST)
  self.Scanner:Start()
end

function PointBlankSniperTabFrameMixin:OnUpdate()
  POINT_BLANK_SNIPER_CURRENT_LIST = self.ListName:GetText()
  self.StartButton:SetEnabled(Auctionator.ShoppingLists.ListIndex(POINT_BLANK_SNIPER_CURRENT_LIST) ~= nil)
  if not self.StartButton:IsEnabled() then
    self:Stop()
  end
end

function PointBlankSniperTabFrameMixin:Stop()
  self.Scanner:Stop()
end

function PointBlankSniperTabFrameMixin:ReceiveEvent(eventName, ...)
  if eventName == PointBlankSniper.Events.SnipeSearchStart then
  elseif eventName == PointBlankSniper.Events.SnipeSearchNewResults then
    local results = ...
    if #results ~= self.oldResultsCount then
      self.oldResultsCount = #results
      PlaySoundFile("Interface\\Addons\\PointBlankSniper\\Tones\\Bleep.mp3")
    end
  elseif eventName == PointBlankSniper.Events.SnipeSearchComplete then
    local results = ...
    if #results ~= self.oldResultsCount then
      self.oldResultsCount = #results
      PlaySoundFile("Interface\\Addons\\PointBlankSniper\\Tones\\Bleep.mp3")
    end
  end
end

function PointBlankSniperTabFrameMixin:OpenOptions()
  InterfaceOptionsFrame:Show()
  InterfaceOptionsFrame_OpenToCategory(COLLECTIONATOR_L_COLLECTIONATOR)
end