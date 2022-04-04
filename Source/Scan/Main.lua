-- Limits per-frame processing to minimise impact on frame rate. Increasing this
-- value usually speeds up the search, but drops the frame rate slightly.
local PROCESSING_PER_FRAME_LIMIT = 400

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
  self:DoSearch()
end

function PointBlankSniperListScannerMixin:DoSearch()
  self.blankSearchResults = {
    cache = {},
    names = {},
    namesWaiting = 0,
    gotCompleteCache = false,
    announcedReady = false,
  }
  self.results = {}

  Auctionator.AH.SendBrowseQuery({
      searchString = "",
      filters = {},
      itemClassFilters = {},
      sorts = Auctionator.Constants.ShoppingListSorts,
  })
end

-- Cache the results of the blank search with the associated item names for the
-- results. Called multiple times to process each batch of results.
function PointBlankSniperListScannerMixin:CacheSearchResults(addedResults)
  if not Auctionator.AH.HasFullBrowseResults() then
    Auctionator.AH.RequestMoreBrowseResults()
  end

  local resultsInfo = self.blankSearchResults
  resultsInfo.gotCompleteCache = Auctionator.AH.HasFullBrowseResults()
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
          if resultsInfo.gotCompleteCache then
            resultsInfo.announcedReady = true
          end
          self:DoInternalSearch()
        end
      end)
    else
      resultsInfo.namesWaiting = resultsInfo.namesWaiting - 1
    end
  end

  if resultsInfo.namesWaiting <= 0 and resultsInfo.gotCompleteCache and not resultsInfo.announcedReady then
    self:UnregisterEvents(CACHING_SEARCH_EVENTS)
    self:SearchGroupReady()
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

function PointBlankSniperListScannerMixin:DoInternalSearch()
  local strFind = string.find
  local nameCache = self.blankSearchResults.names
  for _, search in ipairs(self.searchFor) do
    -- These parameters are cached in locals for performance. Testing indicates
    -- time savings of at least 50% just from this.
    local searchString = search.searchString
    local index = GetStartingIndex(1, #nameCache, nameCache, searchString)
    while index < #nameCache and strFind(nameCache[index], searchString, 1, true) ~= nil do
      local currentResult = self.blankSearchResults.cache[index]
      if (not search.price or (
          currentResult.minPrice <= search.price and
          currentResult.itemKey.itemLevel >= search.minItemLevel
          )
        )
        and (
          not search.isExact or searchString == nameCache[index]
        )
then
        table.insert(self.results, self.blankSearchResults.cache[index])
      end
      index = index + 1
    end
  end

  if self.blankSearchResults.announcedReady then
    Auctionator.EventBus:Fire(self, PointBlankSniper.Events.SnipeSearchComplete, self.results)
    self:DoSearch()
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
