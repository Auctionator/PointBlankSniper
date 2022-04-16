local PURCHASE_ITEM_EVENTS = {
  "ITEM_SEARCH_RESULTS_UPDATED",
  "COMMODITY_SEARCH_RESULTS_UPDATED",
  "COMMODITY_PRICE_UPDATED",
}

PointBlankSniperBuyFrameMixin = {}

function PointBlankSniperBuyFrameMixin:OnLoad()
  Auctionator.EventBus:Register(self, {
    PointBlankSniper.Events.SnipeSearchStart,
    PointBlankSniper.Events.OpenBuyView
  })
end

function PointBlankSniperBuyFrameMixin:OnHide()
  FrameUtil.UnregisterFrameForEvents(self, PURCHASE_ITEM_EVENTS)

  if self.buyCommodity then
    C_AuctionHouse.CancelCommoditiesPurchase()
    self.buyCommodity = false
  end
  self:Hide()
end

function PointBlankSniperBuyFrameMixin:Reset()
  self.info = nil
  self.expectedPrice = 0
  self.expectedItemKey = nil
  self.gotResult = false
  self.resultInfo = nil
  self.buyCommodity = false
  self:UpdateBuyState()
end

function PointBlankSniperBuyFrameMixin:OnEvent(eventName, ...)
  if eventName == "COMMODITY_SEARCH_RESULTS_UPDATED" then
    local itemID = ...
    if itemID ~= self.expectedItemKey.itemID then
      return
    end
    self.gotResult = true
    self.resultInfo = nil

    if C_AuctionHouse.GetCommoditySearchResultsQuantity(itemID) > 0 then
      self.resultInfo = C_AuctionHouse.GetCommoditySearchResultInfo(itemID, 1)

      local displayPrice = math.min(self.resultInfo.unitPrice, self.expectedPrice)
      self.Price:SetText(POINT_BLANK_SNIPER_L_PRICE_COLON_X:format(
        Auctionator.Utilities.CreateMoneyString(displayPrice) ..
        Auctionator.Utilities.CreateCountString(self.resultInfo.quantity)
      ))
    end
    self:UpdateBuyState()

  elseif eventName == "ITEM_SEARCH_RESULTS_UPDATED" then
    local itemKey = ...
    if Auctionator.Utilities.ItemKeyString(itemKey) ~=
        Auctionator.Utilities.ItemKeyString(self.expectedItemKey) then
      return
    end
    self.gotResult = true
    self.resultInfo = nil

    if C_AuctionHouse.GetItemSearchResultsQuantity(itemKey) > 0 then
      self.resultInfo = C_AuctionHouse.GetItemSearchResultInfo(itemKey, 1)

      local displayPrice = math.min(self.resultInfo.buyoutAmount, self.expectedPrice)
      self.Price:SetText(POINT_BLANK_SNIPER_L_PRICE_COLON_X:format(Auctionator.Utilities.CreateMoneyString(displayPrice)))
    end
    self:UpdateBuyState()

  elseif eventName == "COMMODITY_PRICE_UPDATED" and self.buyCommodity then
    local unitPrice, totalPrice = ...
    if unitPrice == self.resultInfo.unitPrice and self.resultInfo.unitPrice <= self.expectedPrice then
      C_AuctionHouse.ConfirmCommoditiesPurchase(self.expectedItemKey.itemID, self.resultInfo.quantity)
    else
      C_AuctionHouse.CancelCommoditiesPurchase()
    end

    self.buyCommodity = false
    self.resultInfo = nil
    self:UpdateBuyState()

  elseif eventName == "COMMODITY_PRICE_UNAVAILABLE" and self.buyCommodity then
    C_AuctionHouse.CancelCommoditiesPurchase()

    self.buyCommodity = false
    self.resultInfo = nil
    self:UpdateBuyState()
  end
end

function PointBlankSniperBuyFrameMixin:UpdateBuyState()
  if not self.gotResult then
    self.BuyButton:Disable()
    self.BuyButton:SetText(POINT_BLANK_SNIPER_L_WAITING)

  else
    if self.info.isCommodity then
      self.BuyButton:SetEnabled(self.resultInfo and self.resultInfo.quantity > 0 and self.resultInfo.unitPrice <= self.expectedPrice)
    else
      self.BuyButton:SetEnabled(self.resultInfo and self.resultInfo.buyoutAmount <= self.expectedPrice)
    end

    if self.BuyButton:IsEnabled() then
      self.BuyButton:SetText(POINT_BLANK_SNIPER_L_BUY_NOW)
    else
      self.BuyButton:SetText(POINT_BLANK_SNIPER_L_SOLD)
    end
  end
  DynamicResizeButton_Resize(self.BuyButton)
end

function PointBlankSniperBuyFrameMixin:BuyNow()
  assert(self.BuyButton:IsEnabled())
  if self.info.isCommodity then
    self.buyCommodity = true
    C_AuctionHouse.StartCommoditiesPurchase(self.expectedItemKey.itemID, self.resultInfo.quantity)
  else
    C_AuctionHouse.PlaceBid(self.resultInfo.auctionID, self.resultInfo.buyoutAmount)
  end
  self.BuyButton:Disable()
  self.BuyButton:SetText(POINT_BLANK_SNIPER_L_BUYING)
end

function PointBlankSniperBuyFrameMixin:ViewAll()
  AuctionHouseFrame:SelectBrowseResult({
    itemKey = self.expectedItemKey,
    minPrice = self.expectedPrice,
  })
end

function PointBlankSniperBuyFrameMixin:ReceiveEvent(eventName, ...)
  if eventName == PointBlankSniper.Events.OpenBuyView then
    local details = ...

    self:Show()

    if self.buyCommodity then
      C_AuctionHouse.CancelCommoditiesPurchase()
      self.buyCommodity = false
    end
    self:Reset()

    self.expectedPrice = details.price
    self.expectedItemKey = details.itemKey
    self.Price:SetText(POINT_BLANK_SNIPER_L_PRICE_COLON_X:format(Auctionator.Utilities.CreateMoneyString(details.price)))
    self:UpdateBuyState()
    Auctionator.AH.GetItemKeyInfo(details.itemKey, function(itemKeyInfo)
      self.info = itemKeyInfo

      self.Icon:Set(details.itemKey, itemKeyInfo.itemName, itemKeyInfo.iconFileID, itemKeyInfo.quality)

      FrameUtil.RegisterFrameForEvents(self, PURCHASE_ITEM_EVENTS)

      local sortingOrder

      if self.info.isCommodity then
        sortingOrder = {sortOrder = 0, reverseSort = false}
      else
        sortingOrder = {sortOrder = 4, reverseSort = false}
      end
      Auctionator.AH.SendSearchQuery(details.itemKey, {sortingOrder}, false)
    end)
  elseif eventName == PointBlankSniper.Events.SnipeSearchStart then
    self:Hide()
  end
end
