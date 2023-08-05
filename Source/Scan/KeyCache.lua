local KEYS_PER_SEARCH = 100

PointBlankSniperListScannerKeyCacheMixin = {}

function PointBlankSniperListScannerKeyCacheMixin:OnLoad()
  Auctionator.EventBus:RegisterSource(self, "PointBlankSniperListScannerKeyCacheMixin")
  self.results = {}
end

function PointBlankSniperListScannerKeyCacheMixin:GotAnyTerms()
  return self.keysToSearchFor ~= nil and #self.keysToSearchFor > 0
end

function PointBlankSniperListScannerKeyCacheMixin:OnHide()
  self:Stop()
end

function PointBlankSniperListScannerKeyCacheMixin:SetPriceCheck(priceCheck)
  self.priceCheck = priceCheck
end

function PointBlankSniperListScannerKeyCacheMixin:SetCategories(categoryString)
  self.filters = Auctionator.Search.GetItemClassCategories(categoryString)
end

function PointBlankSniperListScannerKeyCacheMixin:SetList(listName)
  self.listName = listName
  if PointBlankSniper.ItemKeyCache.State.orderedKeys == nil or #PointBlankSniper.ItemKeyCache.State.orderedKeys.names == 0 then
    PointBlankSniper.Utilities.Message(POINT_BLANK_SNIPER_L_NOT_STARTING_SCAN_NO_INFO)
    return
  end

  local searchTerms = PointBlankSniper.Utilities.ConvertList(Auctionator.Shopping.ListManager:GetByName(listName))
  local keysToSearchFor, keysToPrice, keysToRaw = PointBlankSniper.Scan.GetItemKeys(searchTerms)
  self.keysToSearchFor = {}
  self.keysToPrice = keysToPrice
  self.keysToRaw = keysToRaw

  for _, itemKey in ipairs(keysToSearchFor) do
    local check = true

    if self.filters ~= nil and #self.filters > 0 then
      local gotOne = false
      local classInfo = PointBlankSniper.Utilities.GetClassInfo(itemKey.itemID, itemKey.battlePetSpeciesID)
      for _, f in ipairs(self.filters) do
        if f.classID == classInfo.classID and (not f.subClassID or f.subClassID == classInfo.subClassID) and (not f.inventoryType or f.inventoryType == classInfo.inventoryType) then
          gotOne = true
          break
        end
      end
      check = check and gotOne
    end

    check = check and (not self.keyFilter or self.keyFilter(itemKey))

    if check then
      table.insert(self.keysToSearchFor, itemKey)
    end
  end
end

function PointBlankSniperListScannerKeyCacheMixin:SetKeyFilter(func)
  self.keyFilter = func
end

function PointBlankSniperListScannerKeyCacheMixin:Start(itemKeys, priceMapping, priceCheck)
  assert(self:GotAnyTerms())

  if not self.registered then
    FrameUtil.RegisterFrameForEvents(self, {
      "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED",
      "AUCTION_HOUSE_BROWSE_RESULTS_ADDED",
      "AUCTION_HOUSE_BROWSE_FAILURE",
    })
    self.registered = true
  end

  self.results = {}
  self.keyStartingIndex = 1
  self.cancelled = false

  Auctionator.EventBus:Fire(self, PointBlankSniper.Events.SnipeSearchStart)

  self:DoNextSearch()
end

function PointBlankSniperListScannerKeyCacheMixin:DoNextSearch()
  if self.cancelled then
    return
  end

  local itemKeys = {}
  local index = self.keyStartingIndex
  local limit = self.keyStartingIndex + KEYS_PER_SEARCH
  while index < limit and index <= #self.keysToSearchFor do
    table.insert(itemKeys, self.keysToSearchFor[index])

    index = index + 1
  end

  self.keyStartingIndex = self.keyStartingIndex + KEYS_PER_SEARCH

  C_AuctionHouse.SearchForItemKeys(itemKeys, {})
end

function PointBlankSniperListScannerKeyCacheMixin:ScanItemKeyResults(results)
  for _, currentResult in ipairs(results) do
    if currentResult.minPrice ~= 0 then
      local check = true
      local keyString = Auctionator.Utilities.ItemKeyString(PointBlankSniper.Utilities.CleanItemKey(currentResult.itemKey))
      local price = self.keysToPrice[keyString]
      if price == nil then
        check = check and self.priceCheck:CheckResult(currentResult.minPrice, currentResult.itemKey)
      else
        check = check and currentResult.minPrice <= price
      end

      if check then
        currentResult.comparisonPrice = price
        currentResult.rawSearchTermInfo = {searchTerm = self.keysToRaw[keyString], listName = self.listName}
        table.insert(self.results, currentResult)
      end
    end
  end
end

function PointBlankSniperListScannerKeyCacheMixin:ProcessResults(results)
  self:ScanItemKeyResults(results)

  if self.keyStartingIndex > #self.keysToSearchFor then
    Auctionator.EventBus:Fire(self, PointBlankSniper.Events.SnipeSearchComplete, self.results)
  else
    Auctionator.EventBus:Fire(self, PointBlankSniper.Events.SnipeSearchNewResults, self.results)
    self:DoNextSearch()
  end
end

function PointBlankSniperListScannerKeyCacheMixin:Stop()
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

function PointBlankSniperListScannerKeyCacheMixin:OnEvent(eventName, ...)
  if eventName == "AUCTION_HOUSE_BROWSE_RESULTS_ADDED" then
    local results = ...
    self:ProcessResults(results)
  elseif eventName == "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED" then
    self:ProcessResults(C_AuctionHouse.GetBrowseResults())
  end
end
