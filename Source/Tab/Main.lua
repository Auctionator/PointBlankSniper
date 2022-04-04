PointBlankSniperTabFrameMixin = {}

function PointBlankSniperTabFrameMixin:OnLoad()
  Auctionator.Debug.Message("PointBlankSniperTabMixin:OnLoad()")

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
  self.Scanner:SetList(POINT_BLANK_SNIPER_CURRENT_LIST)
  self.Scanner:Start()
end

function PointBlankSniperTabFrameMixin:OnUpdate()
  if self.ListName:GetText() ~= self.oldListName then
    POINT_BLANK_SNIPER_CURRENT_LIST = self.ListName:GetText()
    self.oldListName = self.ListName:GetText()
    self.StartButton:SetEnabled(Auctionator.ShoppingLists.ListIndex(POINT_BLANK_SNIPER_CURRENT_LIST) ~= nil)
    if not self.StartButton:IsEnabled() then
      self:Stop()
    end
  end
end

function PointBlankSniperTabFrameMixin:Stop()
  self.Scanner:Stop()
end

function PointBlankSniperTabFrameMixin:OpenOptions()
  InterfaceOptionsFrame:Show()
  InterfaceOptionsFrame_OpenToCategory(COLLECTIONATOR_L_COLLECTIONATOR)
end
