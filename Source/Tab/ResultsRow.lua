PointBlankSniperResultsRowMixin = CreateFromMixins(AuctionatorResultsRowTemplateMixin)

function PointBlankSniperResultsRowMixin:OnClick(button, ...)
  Auctionator.Debug.Message("PointBlankSniperResultsRowMixin:OnClick", self.rowData and self.rowData.itemKey.itemID)

  if IsModifiedClick("DRESSUP") then
    DressUpLink(self.rowData.itemLink);

  elseif IsModifiedClick("CHATLINK") then
    ChatEdit_InsertLink(self.rowData.itemLink)

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
