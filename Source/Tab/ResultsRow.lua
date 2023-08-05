PointBlankSniperResultsRowMixin = CreateFromMixins(AuctionatorResultsRowTemplateMixin)

function PointBlankSniperResultsRowMixin:Populate(rowData, ...)
  AuctionatorResultsRowTemplateMixin.Populate(self, rowData, ...)
  self.SelectedHighlight:SetShown(rowData.highlight)
end

function PointBlankSniperResultsRowMixin:OnClick(button, ...)
  Auctionator.Debug.Message("PointBlankSniperResultsRowMixin:OnClick", self.rowData and self.rowData.itemKey.itemID)

  if IsModifiedClick("DRESSUP") then
    AuctionHouseBrowseResultsFrameMixin.OnBrowseResultSelected({}, self.rowData)

  else
    Auctionator.EventBus
      :RegisterSource(self, "PointBlankSniperResultRow")
      :Fire(self, PointBlankSniper.Events.OpenBuyView, {
        itemKey = self.rowData.itemKey,
        price = self.rowData.minPrice,
        quantity = self.rowData.totalQuantity,
        comparisonPrice = self.rowData.comparisonPrice,
        rawSearchTermInfo = self.rowData.rawSearchTermInfo,
      })
      :UnregisterSource(self)
  end
end
