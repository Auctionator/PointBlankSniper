local function CleanSearchString(searchString)
  return string.gsub(string.lower(searchString), "\"", "")
end

PointBlankSniperListScannerMixin = {}

function PointBlankSniperListScannerMixin:OnLoad()
  Auctionator.EventBus:RegisterSource(self, "PointBlankSniperListScannerMixin")
end

function PointBlankSniperListScannerMixin:SetList(listName)
  local list = Auctionator.ShoppingLists.GetListByName(listName)

  self.searchFor = {}
  for _, entry in ipairs(list.items) do
    local advancedParams = Auctionator.Search.SplitAdvancedSearch(entry)
    table.insert(self.searchFor, {
      searchString = CleanSearchString(advancedParams.searchString),
      price = advancedParams.maxPrice,
      minItemLevel = advancedParams.minItemLevel or 0,
      isExact = advancedParams.isExact
    })
  end
end

function PointBlankSniperListScannerMixin:SetMarketCheck(checkFunc)
  self.marketDataCheck = checkFunc or (function() return true end)
end

function PointBlankSniperListScannerMixin:OnShow()
  self.searchFor = {}
end

function PointBlankSniperListScannerMixin:OnHide()
  self:Stop()
end

function PointBlankSniperListScannerMixin:Start()
  FrameUtil.RegisterFrameForEvents(self, {
    "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED",
    "AUCTION_HOUSE_BROWSE_RESULTS_ADDED",
    "AUCTION_HOUSE_BROWSE_FAILURE",
  })

  self.results = {}
  self.blankSearchResultsWaiting = 0

  Auctionator.AH.SendBrowseQuery({
      searchString = "",
      filters = {},
      itemClassFilters = {},
      sorts = Auctionator.Constants.ShoppingListSorts,
  })

  Auctionator.EventBus:Fire(self, PointBlankSniper.Events.SnipeSearchStart)
end

-- Processes each batch of results, saving the names in advance before
-- submitting them to another function to do the query on them
function PointBlankSniperListScannerMixin:CacheSearchResults(addedResults)
  if not Auctionator.AH.HasFullBrowseResults() then
    Auctionator.AH.RequestMoreBrowseResults()
  end

  local resultsInfo = {
    cache = {},
    names = {},
    namesWaiting = 0,
    gotCompleteCache = false,
    announcedReady = false,
  }
  self.blankSearchResultsWaiting = self.blankSearchResultsWaiting + 1
  resultsInfo.namesWaiting = resultsInfo.namesWaiting + #addedResults

  for _, result in ipairs(addedResults) do
    if result.totalQuantity ~= 0 then
      table.insert(resultsInfo.cache, result)
      local index = #resultsInfo.cache
      table.insert(resultsInfo.names, "")
      Auctionator.AH.GetItemKeyInfo(result.itemKey, function(itemKeyInfo)
        resultsInfo.namesWaiting = resultsInfo.namesWaiting - 1
        resultsInfo.names[index] = CleanSearchString(itemKeyInfo.itemName)
        if resultsInfo.namesWaiting <= 0 then
          self.blankSearchResultsWaiting = self.blankSearchResultsWaiting - 1
          resultsInfo.announcedReady = self.blankSearchResultsWaiting <= 0 and Auctionator.AH.HasFullBrowseResults()
          self:DoInternalSearch(resultsInfo)
        end
      end)
    else
      resultsInfo.namesWaiting = resultsInfo.namesWaiting - 1
    end
  end

  if resultsInfo.namesWaiting <= 0 and self.blankSearchResultsWaiting <= 0 and Auctionator.AH.HasFullBrowseResults() and not resultsInfo.announcedReady then
    resultsInfo.announcedReady = true
    self:DoInternalSearch(resultsInfo)
  end
end

function PointBlankSniperListScannerMixin:SaveResults(results)
  self:CacheSearchResults(results)
end

local function GetStartingIndex(startPoint, endPoint, array, searchString)
  if startPoint == endPoint then
    return startPoint
  end

  local midPoint = math.floor((startPoint + endPoint)/2)

  local entry = array[midPoint]
  if (midPoint == 1 or array[midPoint - 1] < searchString) and entry >= searchString then
    return midPoint
  elseif entry < searchString then
    return GetStartingIndex(midPoint + 1, endPoint, array, searchString)
  else--if entry >= searchString then
    return GetStartingIndex(startPoint, midPoint - 1, array, searchString)
  end
end

function PointBlankSniperListScannerMixin:DoShoppingListSearch(resultsInfo)
  local strFind = string.find
  local nameCache = resultsInfo.names
  for _, search in ipairs(self.searchFor) do
    local searchString = search.searchString
    local index = GetStartingIndex(1, #nameCache, nameCache, searchString)
    while index < #nameCache and strFind(nameCache[index], searchString, 1, true) ~= nil do
      local currentResult = resultsInfo.cache[index]
      local check = true
      if not search.price then
        check = check and self.marketDataCheck(currentResult)
      else
        check = check and currentResult.minPrice <= search.price
      end

      if search.minItemLevel ~= nil then
        check = check and currentResult.itemKey.itemLevel >= search.minItemLevel
      end

      check = check and (not search.isExact or searchString == nameCache[index])

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

function PointBlankSniperListScannerMixin:DoInternalSearch(resultsInfo)
  self:DoShoppingListSearch(resultsInfo)

  if resultsInfo.announcedReady then
    Auctionator.EventBus:Fire(self, PointBlankSniper.Events.SnipeSearchComplete, self.results)
  else
    Auctionator.EventBus:Fire(self, PointBlankSniper.Events.SnipeSearchNewResults, self.results)
  end
end

function PointBlankSniperListScannerMixin:Stop()
  FrameUtil.UnregisterFrameForEvents(self, {
    "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED",
    "AUCTION_HOUSE_BROWSE_RESULTS_ADDED",
    "AUCTION_HOUSE_BROWSE_FAILURE",
  })
  Auctionator.EventBus:Fire(self, PointBlankSniper.Events.SnipeSearchAbort, self.results)
end

function PointBlankSniperListScannerMixin:OnEvent(eventName, ...)
  if eventName == "AUCTION_HOUSE_BROWSE_RESULTS_ADDED" then
    local results = ...
    self:SaveResults(results)
  elseif eventName == "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED" then
    self:SaveResults(C_AuctionHouse.GetBrowseResults())
  end
end
