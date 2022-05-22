PointBlankSniperResultsRowMixin = CreateFromMixins(AuctionatorResultsRowTemplateMixin)

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
      })
      :UnregisterSource(self)
  end
end
