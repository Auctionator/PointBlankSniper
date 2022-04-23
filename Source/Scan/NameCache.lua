PointBlankSniperListScannerNameCacheMixin = {}

function PointBlankSniperListScannerNameCacheMixin:OnLoad()
  Auctionator.EventBus:RegisterSource(self, "PointBlankSniperListScannerNameCacheMixin")
  self.results = {}
end

function PointBlankSniperListScannerNameCacheMixin:OnHide()
  self:Stop()
end

function PointBlankSniperListScannerNameCacheMixin:SetPriceCheck(priceCheck)
  self.priceCheck = priceCheck
end

function PointBlankSniperListScannerNameCacheMixin:SetCategories(categoryString)
  self.filters = Auctionator.Search.GetItemClassCategories(categoryString) or {}
end

function PointBlankSniperListScannerNameCacheMixin:SetList(listName)
  self.searchFor = PointBlankSniper.Utilities.ConvertList(Auctionator.ShoppingLists.GetListByName(listName))
end

function PointBlankSniperListScannerNameCacheMixin:SetThresholdCheck(thresholdCheck)
  self.thresholdCheck = thresholdCheck
end

function PointBlankSniperListScannerNameCacheMixin:GotAnyTerms()
  return true
end

local sortPrice = {
  {sortOrder = Enum.AuctionHouseSortOrder.Price, reverseSort = false},
  {sortOrder = Enum.AuctionHouseSortOrder.Name, reverseSort = false},
}

function PointBlankSniperListScannerNameCacheMixin:Start()
  if not self.registered then
    FrameUtil.RegisterFrameForEvents(self, {
      "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED",
      "AUCTION_HOUSE_BROWSE_RESULTS_ADDED",
      "AUCTION_HOUSE_BROWSE_FAILURE",
    })
    self.registered = true
  end

  self.results = {}
  self.blankSearchResultsWaiting = 0
  self.cancelled = false

  local sorts
  if self.thresholdCheck == nil then
    sorts = Auctionator.Constants.ShoppingListSorts
  else
    sorts = sortPrice
  end

  Auctionator.AH.SendBrowseQuery({
      searchString = "",
      filters = {},
      itemClassFilters = self.filters,
      sorts = sorts,
  })

  Auctionator.EventBus:Fire(self, PointBlankSniper.Events.SnipeSearchStart)
end

function PointBlankSniperListScannerNameCacheMixin:CachingCompleteCheck()
  return self.blankSearchResultsWaiting <= 0 and Auctionator.AH.HasFullBrowseResults()
end

-- Processes each batch of results, saving the names in advance before
-- submitting them to another function to do the query on them
function PointBlankSniperListScannerNameCacheMixin:CacheAndProcessSearchResults(addedResults)
  local resultsInfo = {
    cache = {},
    names = {},
    namesWaiting = 0,
    announcedReady = false,
    cachingComplete = false,
  }
  local CleanSearchString = PointBlankSniper.Utilities.CleanSearchString
  self.blankSearchResultsWaiting = self.blankSearchResultsWaiting + 1
  resultsInfo.namesWaiting = resultsInfo.namesWaiting + #addedResults

  for _, result in ipairs(addedResults) do
    if result.totalQuantity ~= 0 then
      table.insert(resultsInfo.cache, result)
      local index = #resultsInfo.cache
      table.insert(resultsInfo.names, "")
      Auctionator.AH.GetItemKeyInfo(result.itemKey, function(itemKeyInfo, wasCached)
        resultsInfo.namesWaiting = resultsInfo.namesWaiting - 1
        resultsInfo.names[index] = CleanSearchString(itemKeyInfo.itemName)
        if resultsInfo.namesWaiting <= 0 then
          resultsInfo.announcedReady = true

          self.blankSearchResultsWaiting = self.blankSearchResultsWaiting - 1
          resultsInfo.cachingComplete = self:CachingCompleteCheck() or (self.thresholdCheck and self.thresholdCheck(resultsInfo.cache[#resultsInfo.cache].minPrice))

          self:ProcessCachedResults(resultsInfo)
        end
      end)
    else
      resultsInfo.namesWaiting = resultsInfo.namesWaiting - 1
    end
  end

  if resultsInfo.namesWaiting <= 0 and not resultsInfo.announcedReady then
    resultsInfo.announcedReady = true

    self.blankSearchResultsWaiting = self.blankSearchResultsWaiting - 1
    resultsInfo.cachingComplete = self:CachingCompleteCheck() or (self.thresholdCheck and self.thresholdCheck(resultsInfo.cache[#resultsInfo.cache].minPrice))

    self:ProcessCachedResults(resultsInfo)
  end
end

function PointBlankSniperListScannerNameCacheMixin:DoShoppingListSearch(resultsInfo)
  if #resultsInfo.cache == 0 then
    return
  end

  local strFind = string.find
  local nameCache = resultsInfo.names
  local GetStartingIndex = PointBlankSniper.Utilities.GetStartingIndex
  local IsBlacklistedID = PointBlankSniper.Utilities.IsBlacklistedID
  for _, search in ipairs(self.searchFor) do
    local searchString = search.searchString
    local index = GetStartingIndex(1, #nameCache, nameCache, searchString)
    while index < #nameCache and strFind(nameCache[index], searchString, 1, true) ~= nil do
      local currentResult = resultsInfo.cache[index]
      local check = true
      if not search.price then
        check = check and self.priceCheck:CheckResult(currentResult.minPrice, currentResult.itemKey)
      else
        check = check and currentResult.minPrice <= search.price
      end

      if search.minItemLevel ~= nil then
        check = check and currentResult.itemKey.itemLevel >= search.minItemLevel
      end

      check = check and (not search.isExact or searchString == nameCache[index])

      check = check and not IsBlacklistedID(currentResult.itemKey.itemID)

      if check then
        if tIndexOf(self.results, currentResult) == nil then
          currentResult.comparisonPrice = search.price
          table.insert(self.results, currentResult)
        end
      end
      index = index + 1
    end
  end
end

function PointBlankSniperListScannerNameCacheMixin:ProcessCachedResults(resultsInfo)
  self:DoShoppingListSearch(resultsInfo)

  if resultsInfo.cachingComplete then
    Auctionator.EventBus:Fire(self, PointBlankSniper.Events.SnipeSearchComplete, self.results)
  else
    Auctionator.EventBus:Fire(self, PointBlankSniper.Events.SnipeSearchNewResults, self.results)

    if not self.cancelled and not Auctionator.AH.HasFullBrowseResults() then
      Auctionator.AH.RequestMoreBrowseResults()
    end
  end
end

function PointBlankSniperListScannerNameCacheMixin:Stop()
  if self.registered then
    FrameUtil.UnregisterFrameForEvents(self, {
      "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED",
      "AUCTION_HOUSE_BROWSE_RESULTS_ADDED",
      "AUCTION_HOUSE_BROWSE_FAILURE",
    })
    self.registered = false
  end
  self.cancelled = true
  Auctionator.EventBus:Fire(self, PointBlankSniper.Events.SnipeSearchAbort, self.results)
end

function PointBlankSniperListScannerNameCacheMixin:OnEvent(eventName, ...)
  if eventName == "AUCTION_HOUSE_BROWSE_RESULTS_ADDED" then
    local results = ...
    self:CacheAndProcessSearchResults(results)
  elseif eventName == "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED" then
    self:CacheAndProcessSearchResults(C_AuctionHouse.GetBrowseResults())
  end
end
