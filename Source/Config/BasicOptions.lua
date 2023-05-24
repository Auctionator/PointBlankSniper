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
end

function PointBlankSniperConfigBasicOptionsFrameMixin:OnShow()
  Auctionator.Debug.Message("PointBlankSniperConfigBasicOptionsFrameMixin:OnShow()")

  self.setup = true

  self.UseBleep:SetChecked(PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.USE_BLEEP))
  self.UseFlash:SetChecked(PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.USE_FLASH))
  self.CarryOnAfterResult:SetChecked(PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.CARRY_ON_AFTER_RESULT))
  self.HighlightNewResults:SetChecked(PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.HIGHLIGHT_NEW_RESULTS))

  self.ShowGhostCount:SetChecked(PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.SHOW_GHOST_COUNT))
  self.AllowGhostPurchases:SetChecked(PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.ALLOW_GHOST_PURCHASES))

  self.ShowNewItemsMessages:SetChecked(PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.SHOW_NEW_ITEMS_MESSAGES))
  self.KeysSearch:SetChecked(PointBlankSniper.Config.Get(PointBlankSniper.Config.Options.KEYS_SEARCH))
end

function PointBlankSniperConfigBasicOptionsFrameMixin:Save()
  Auctionator.Debug.Message("PointBlankSniperConfigBasicOptionsFrameMixin:Save()")

  PointBlankSniper.Config.Set(PointBlankSniper.Config.Options.USE_BLEEP, self.UseBleep:GetChecked())
  PointBlankSniper.Config.Set(PointBlankSniper.Config.Options.USE_FLASH, self.UseFlash:GetChecked())
  PointBlankSniper.Config.Set(PointBlankSniper.Config.Options.CARRY_ON_AFTER_RESULT, self.CarryOnAfterResult:GetChecked())
  PointBlankSniper.Config.Set(PointBlankSniper.Config.Options.HIGHLIGHT_NEW_RESULTS, self.HighlightNewResults:GetChecked())

  PointBlankSniper.Config.Set(PointBlankSniper.Config.Options.SHOW_GHOST_COUNT, self.ShowGhostCount:GetChecked())
  PointBlankSniper.Config.Set(PointBlankSniper.Config.Options.ALLOW_GHOST_PURCHASES, self.AllowGhostPurchases:GetChecked())

  PointBlankSniper.Config.Set(PointBlankSniper.Config.Options.SHOW_NEW_ITEMS_MESSAGES, self.ShowNewItemsMessages:GetChecked())
  PointBlankSniper.Config.Set(PointBlankSniper.Config.Options.KEYS_SEARCH, self.KeysSearch:GetChecked())
end

function PointBlankSniperConfigBasicOptionsFrameMixin:Cancel()
  Auctionator.Debug.Message("PointBlankSniperConfigBasicOptionsFrameMixin:Cancel()")
end
