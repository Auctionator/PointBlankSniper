PointBlankSniper.PriceCheck.PriceCheckMixin = {}

function PointBlankSniper.PriceCheck.PriceCheckMixin:GetValueUsed(itemKey)
  error("This needs to be overridden")
end

function PointBlankSniper.PriceCheck.PriceCheckMixin:CheckResult(price, itemKey)
  error("This needs to be overridden")
end

PointBlankSniper.PriceCheck.NoneMixin = CreateFromMixins(PointBlankSniper.PriceCheck.PriceCheckMixin)

function PointBlankSniper.PriceCheck.NoneMixin:GetValueUsed(itemKey)
  return nil
end

function PointBlankSniper.PriceCheck.NoneMixin:CheckResult(price, itemKey)
  return true
end

PointBlankSniper.PriceCheck.TSMMixin = CreateFromMixins(PointBlankSniper.PriceCheck.PriceCheckMixin)

function PointBlankSniper.PriceCheck.TSMMixin:Init(parameter, percentage)
  self.parameter = parameter
  self.percentage = percentage
end

local function ToTSMItemString(itemKey)
  if itemKey.battlePetSpeciesID ~= 0 then
    return "p:" .. itemKey.battlePetSpeciesID
  else
    return "i:" .. tostring(itemKey.itemID)
  end
end

function PointBlankSniper.PriceCheck.TSMMixin:GetValueUsed(itemKey)
  local TSMPrice = TSM_API.GetCustomPriceValue(self.parameter, ToTSMItemString(itemKey))
  return TSMPrice and TSMPrice * self.percentage
end

function PointBlankSniper.PriceCheck.TSMMixin:CheckResult(price, itemKey)
  local TSMPrice = TSM_API.GetCustomPriceValue(self.parameter, ToTSMItemString(itemKey))
  return TSMPrice and price <= TSMPrice * self.percentage
end

PointBlankSniper.PriceCheck.OEMixin = CreateFromMixins(PointBlankSniper.PriceCheck.PriceCheckMixin)

function PointBlankSniper.PriceCheck.OEMixin:Init(parameter, percentage)
  self.parameter = parameter
  self.percentage = percentage
end

function PointBlankSniper.PriceCheck.OEMixin:GetValueUsed(itemKey)
  local o = {}
  OEMarketInfo(itemKey.itemID, o)
  local OEPrice = o[self.parameter]

  return OEPrice and OEPrice ~= 0 and OEPrice * self.percentage
end

function PointBlankSniper.PriceCheck.OEMixin:CheckResult(price, itemKey)
  local o = {}
  OEMarketInfo(itemKey.itemID, o)
  local OEPrice = o[self.parameter]

  return OEPrice and OEPrice ~= 0 and price <= OEPrice * self.percentage
end
