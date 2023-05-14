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
    headerParameters = { "comparisonPrice" },
    headerText = POINT_BLANK_SNIPER_L_COMPARISON_PRICE,
    cellTemplate = "AuctionatorPriceCellTemplate",
    cellParameters = { "comparisonPrice" },
    defaultHide = true,
    width = 140
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "name" },
    headerText = AUCTIONATOR_L_RESULTS_NAME_COLUMN,
    cellTemplate = "AuctionatorItemKeyCellTemplate"
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "isNew" },
    headerText = POINT_BLANK_SNIPER_L_IS_NEW,
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "isNew" },
    width = 80,
    defaultHide = true,
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
    PointBlankSniper.Events.SnipeSearchAbort,
  })

  self.lastRound = {}
  self.thisRound = {}
end

local function ResultKey(result)
  return Auctionator.Utilities.ItemKeyString(result.itemKey) .. " " .. result.minPrice
end

function PointBlankSniperDataProviderMixin:ProcessThisScan(results, lastBatch)
  local showHighlights = PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.HIGHLIGHT_NEW_RESULTS)
  local newResults = CopyTable(results)
  for _, r in ipairs(newResults) do
    local key = ResultKey(r)
    self.thisRound[key] = true
    local isNew = not self.lastRound[key]
    r.highlight = isNew and showHighlights
    r.isNew = isNew and AUCTIONATOR_L_UNDERCUT_YES or AUCTIONATOR_L_UNDERCUT_NO
  end
  self:AppendEntries(newResults, lastBatch)
end

function PointBlankSniperDataProviderMixin:ReceiveEvent(eventName, results, ...)
  if eventName == PointBlankSniper.Events.SnipeSearchStart then
    self.onSearchStarted()
    self.thisRound = {}
  elseif eventName == PointBlankSniper.Events.SnipeSearchNewResults then
    self.onPreserveScroll()
    self.onSearchStarted()
    self:ProcessThisScan(results, false)
  elseif eventName == PointBlankSniper.Events.SnipeSearchComplete then
    self.onPreserveScroll()
    self:Reset()
    self:ProcessThisScan(results, true)
    self.lastRound = self.thisRound
  elseif eventName == PointBlankSniper.Events.SnipeSearchAbort then
    self.onPreserveScroll()
    self:AppendEntries({}, true)
    self.lastRound = self.thisRound
  end
end

function PointBlankSniperDataProviderMixin:UniqueKey(entry)
  return Auctionator.Utilities.ItemKeyString(entry.itemKey)
end

local COMPARATORS = {
  minPrice = Auctionator.Utilities.NumberComparator,
  name = Auctionator.Utilities.StringComparator,
  isNew = Auctionator.Utilities.StringComparator,
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

function PointBlankSniperDataProviderMixin:GetColumnHideStates()
  return PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.COLUMNS)
end

function PointBlankSniperDataProviderMixin:GetRowTemplate()
  return "PointBlankSniperResultsRowTemplate"
end
