local SNIPE_RESULTS_TABLE_LAYOUT = {
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "minPrice" },
    headerText = AUCTIONATOR_L_RESULTS_PRICE_COLUMN,
    cellTemplate = "AuctionatorPriceCellTemplate",
    cellParameters = { "minPrice" },
    width = 140
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "name" },
    headerText = AUCTIONATOR_L_RESULTS_NAME_COLUMN,
    cellTemplate = "AuctionatorItemKeyCellTemplate"
  },
}

PointBlankSniperDataProviderMixin = CreateFromMixins(AuctionatorDataProviderMixin, AuctionatorItemKeyLoadingMixin)

function PointBlankSniperDataProviderMixin:OnLoad()
  Auctionator.Debug.Message("PointBlankSniperDataProviderMixin:OnLoad()")

  self:SetUpEvents()

  AuctionatorDataProviderMixin.OnLoad(self)
  AuctionatorItemKeyLoadingMixin.OnLoad(self)

  self:Reset()
end

function PointBlankSniperDataProviderMixin:SetUpEvents()
  Auctionator.EventBus:RegisterSource(self, "PointBlankSniper Data Provider")

  Auctionator.EventBus:Register(self, {
    PointBlankSniper.Events.SnipeSearchStart,
    PointBlankSniper.Events.SnipeSearchNewResults,
    PointBlankSniper.Events.SnipeSearchComplete,
    PointBlankSniper.Events.SnipeSearchAbort
  })
end

function PointBlankSniperDataProviderMixin:ReceiveEvent(eventName, results, ...)
  if eventName == PointBlankSniper.Events.SnipeSearchStart then
    self.onSearchStarted()
  elseif eventName == PointBlankSniper.Events.SnipeSearchNewResults then
    self.onSearchStarted()
    self:AppendEntries(results)
  elseif eventName == PointBlankSniper.Events.SnipeSearchComplete then
    self:Reset()
    self:AppendEntries(results, true)
  elseif eventName == PointBlankSniper.Events.SnipeSearchAbort then
    self:AppendEntries({}, true)
  end
end

function PointBlankSniperDataProviderMixin:UniqueKey(entry)
  return Auctionator.Utilities.ItemKeyString(entry.itemKey)
end

local COMPARATORS = {
  minPrice = Auctionator.Utilities.NumberComparator,
  name = Auctionator.Utilities.StringComparator,
}

function PointBlankSniperDataProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self:SetDirty()
end

function PointBlankSniperDataProviderMixin:GetTableLayout()
  return SNIPE_RESULTS_TABLE_LAYOUT
end

--[[function PointBlankSniperDataProviderMixin:GetColumnHideStates()
  return Auctionator.Config.Get(Auctionator.Config.Options.COLUMNS_SHOPPING)
end]]

function PointBlankSniperDataProviderMixin:GetRowTemplate()
  return "AuctionatorShoppingListResultsRowTemplate"
end