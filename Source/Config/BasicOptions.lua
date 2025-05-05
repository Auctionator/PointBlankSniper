PointBlankSniperConfigBasicOptionsFrameMixin = {}

function PointBlankSniperConfigBasicOptionsFrameMixin:OnLoad()
  Auctionator.Debug.Message("PointBlankSniperConfigBasicOptionsFrameMixin:OnLoad()")

  self.name = POINT_BLANK_SNIPER_L_POINT_BLANK_SNIPER

  self.setup = false

  self.OnCommit = function()
    if self.setup then
      self:Save()
    end
  end
  self.OnDefault = function() end
  self.OnRefresh = function() end

  local category = Settings.RegisterCanvasLayoutCategory(self, self.name)
  category.ID = self.name
  Settings.RegisterAddOnCategory(category)

  Auctionator.EventBus:RegisterSource(self, "PointBlankSniperBasicOptions")
end

function PointBlankSniperConfigBasicOptionsFrameMixin:OnShow()
  Auctionator.Debug.Message("PointBlankSniperConfigBasicOptionsFrameMixin:OnShow()")

  self.setup = true

  self.UseBleep:SetChecked(PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.USE_BLEEP))
  self.UseFlash:SetChecked(PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.USE_FLASH))
  self.CarryOnAfterResult:SetChecked(PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.CARRY_ON_AFTER_RESULT))
  self.HighlightNewResults:SetChecked(PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.HIGHLIGHT_NEW_RESULTS))

  self.ShowNewItemsMessages:SetChecked(PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.SHOW_NEW_ITEMS_MESSAGES))
  self.KeysSearch:SetChecked(PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.KEYS_SEARCH))

  local listNames = {}
  for i = 1, Auctionator.Shopping.ListManager:GetCount() do
    table.insert(listNames, Auctionator.Shopping.ListManager:GetByIndex(i):GetName())
  end
  self.ListName:InitAgain(listNames, listNames)
end

function PointBlankSniperConfigBasicOptionsFrameMixin:ReducePrices()
  PointBlankSniper.Utilities.Message(POINT_BLANK_SNIPER_L_CONFIG_REDUCING_ON_X:format(self.ListName:GetValue(), PointBlankSniper.Constants.MarketToName[PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.PRICE_SOURCE)]))
  if not PointBlankSniper.PriceCheck.IsAvailable(PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.PRICE_SOURCE)) then
    PointBlankSniper.Utilities.Message(POINT_BLANK_SNIPER_L_REDUCE_PRICES_NO_SOURCE)
    return
  end

  local list = Auctionator.Shopping.ListManager:GetByName(self.ListName:GetValue())

  local priceSource = PointBlankSniper.PriceCheck.Get()

  for index, search in ipairs(PointBlankSniper.Utilities.ConvertList(list)) do
    if not search.minItemLevel and not search.maxItemLevel then
      local keys = PointBlankSniper.Scan.GetItemKeys({search})
      local itemIDSeen
      local mismatch = false
      for _, itemKey in ipairs(keys) do
        itemIDSeen = itemIDSeen or itemKey.itemID
        if itemKey.itemID ~= itemIDSeen then
          mismatch = true
        end
      end
      if itemIDSeen ~= nil and not mismatch then
        if search.price then
          local realSearch = Auctionator.Search.SplitAdvancedSearch(search.rawSearchTerm)
          local cmp = priceSource:GetValueUsed(keys[1])
          if cmp then
            realSearch.maxPrice = math.min(cmp, realSearch.maxPrice)
            list:AlterItem(index, Auctionator.Search.ReconstituteAdvancedSearch(realSearch))
            PointBlankSniper.Utilities.Message(POINT_BLANK_SNIPER_L_CONFIG_ADJUSTED_X_TO_X:format(Auctionator.Search.PrettifySearchString(search.rawSearchTerm), GetMoneyString(realSearch.maxPrice)))
          end
        end
      end
    end
  end
end

function PointBlankSniperConfigBasicOptionsFrameMixin:Save()
  Auctionator.Debug.Message("PointBlankSniperConfigBasicOptionsFrameMixin:Save()")

  PointBlankSniper.Config.Set(PointBlankSniper.Config.Options.USE_BLEEP, self.UseBleep:GetChecked())
  PointBlankSniper.Config.Set(PointBlankSniper.Config.Options.USE_FLASH, self.UseFlash:GetChecked())
  PointBlankSniper.Config.Set(PointBlankSniper.Config.Options.CARRY_ON_AFTER_RESULT, self.CarryOnAfterResult:GetChecked())
  PointBlankSniper.Config.Set(PointBlankSniper.Config.Options.HIGHLIGHT_NEW_RESULTS, self.HighlightNewResults:GetChecked())

  PointBlankSniper.Config.Set(PointBlankSniper.Config.Options.SHOW_NEW_ITEMS_MESSAGES, self.ShowNewItemsMessages:GetChecked())
  PointBlankSniper.Config.Set(PointBlankSniper.Config.Options.KEYS_SEARCH, self.KeysSearch:GetChecked())
end

function PointBlankSniperConfigBasicOptionsFrameMixin:Cancel()
  Auctionator.Debug.Message("PointBlankSniperConfigBasicOptionsFrameMixin:Cancel()")
end
