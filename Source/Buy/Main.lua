local PURCHASE_ITEM_EVENTS = {
  "ITEM_SEARCH_RESULTS_UPDATED",
  "COMMODITY_SEARCH_RESULTS_UPDATED",
  "COMMODITY_PRICE_UPDATED",
  "COMMODITY_PRICE_UNAVAILABLE",
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
  self.ghostCount = nil
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

    self.buyResultsCount = C_AuctionHouse.GetCommoditySearchResultsQuantity(itemID)
    if C_AuctionHouse.GetCommoditySearchResultsQuantity(itemID) > 0 then
      self.resultInfo = C_AuctionHouse.GetCommoditySearchResultInfo(itemID, 1)

      local displayPrice = self.resultInfo.unitPrice
      local ghostCount = self.summaryResultsCount - self.buyResultsCount
      if not PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.SHOW_GHOST_COUNT) or displayPrice <= self.expectedPrice or ghostCount <= 0 then
        self.ghostCount = nil
        self.Price:SetText(POINT_BLANK_SNIPER_L_PRICE_COLON_X:format(
          GetMoneyString(displayPrice, true) ..
          Auctionator.Utilities.CreateCountString(self.resultInfo.quantity)
        ))
      else
        if PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.ALLOW_GHOST_PURCHASES) then
          self.ghostCount = ghostCount
        end
        self.Price:SetText(POINT_BLANK_SNIPER_L_GHOST_COLON_X:format(
          GetMoneyString(self.expectedPrice, true) ..
          Auctionator.Utilities.CreateCountString(math.max(0, ghostCount))
        ))
      end
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

      local displayPrice = self.resultInfo.buyoutAmount or 0
      self.Price:SetText(POINT_BLANK_SNIPER_L_PRICE_COLON_X:format(GetMoneyString(displayPrice, true)))
    end
    self:UpdateBuyState()

  elseif eventName == "COMMODITY_PRICE_UPDATED" and self.buyCommodity then
    local unitPrice, totalPrice = ...
    if self.ghostCount or (unitPrice <= self.resultInfo.unitPrice and self.resultInfo.unitPrice <= self.expectedPrice) then
      C_AuctionHouse.ConfirmCommoditiesPurchase(self.expectedItemKey.itemID, self.ghostCount or self.resultInfo.quantity)
    else
      C_AuctionHouse.CancelCommoditiesPurchase()
    end

    self.buyCommodity = false
    self.resultInfo = nil
    self.ghostCount = nil
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
      self.BuyButton:SetEnabled(self.ghostCount or (self.resultInfo and self.resultInfo.quantity > 0 and self.resultInfo.unitPrice <= self.expectedPrice))
    else
      self.BuyButton:SetEnabled(self.resultInfo and self.resultInfo.buyoutAmount ~= nil and self.resultInfo.buyoutAmount <= self.expectedPrice)
    end

    if self.BuyButton:IsEnabled() then
      self.BuyButton:SetText(POINT_BLANK_SNIPER_L_BUY_NOW)
    elseif not self.info.isCommodity and self.resultInfo and self.resultInfo.bidAmount ~= nil and self.resultInfo.buyoutAmount == nil then
      self.BuyButton:SetText(POINT_BLANK_SNIPER_L_BID_ONLY)
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
    C_AuctionHouse.StartCommoditiesPurchase(self.expectedItemKey.itemID, self.ghostCount or self.resultInfo.quantity)
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
  AuctionHouseFrame.displayMode = nil
end

function PointBlankSniperBuyFrameMixin:NameSearch()
  if self.expectedItemKey.battlePetSpeciesID ~= 0 then
    Auctionator.API.v1.MultiSearch(POINT_BLANK_SNIPER_L_POINT_BLANK_SNIPER, {
      self.info.itemName
    })
  else
    local item = Item:CreateFromItemID(self.expectedItemKey.itemID)
    item:ContinueOnItemLoad(function()
      Auctionator.API.v1.MultiSearch(POINT_BLANK_SNIPER_L_POINT_BLANK_SNIPER, {
        item:GetItemName()
      })
    end)
  end
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
    self.summaryResultsCount = details.quantity
    self.Price:SetText(POINT_BLANK_SNIPER_L_PRICE_COLON_X:format(GetMoneyString(details.price, true)))
    self:UpdateBuyState()
    Auctionator.AH.GetItemKeyInfo(details.itemKey, function(itemKeyInfo)
      self.info = itemKeyInfo

      self.Icon:Set(details.itemKey, itemKeyInfo.itemName, itemKeyInfo.iconFileID, itemKeyInfo.quality, itemKeyInfo.battlePetLink)

      FrameUtil.RegisterFrameForEvents(self, PURCHASE_ITEM_EVENTS)

      local sortingOrder

      if self.info.isCommodity then
        sortingOrder = {sortOrder = 0, reverseSort = false}
      else
        sortingOrder = {sortOrder = 4, reverseSort = false}
      end
      Auctionator.AH.SendSearchQueryByItemKey(details.itemKey, {sortingOrder}, false)
    end)
  elseif eventName == PointBlankSniper.Events.SnipeSearchStart then
    self:Hide()
  end
end
