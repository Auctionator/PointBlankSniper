PointBlankSniperItemIconMixin = {}

function PointBlankSniperItemIconMixin:Set(itemKey, itemName, iconTexture, quality)
  self.itemKey = itemKey
  self.Icon:SetTexture(iconTexture)

  self.IconBorder:SetVertexColor(
    ITEM_QUALITY_COLORS[quality].r,
    ITEM_QUALITY_COLORS[quality].g,
    ITEM_QUALITY_COLORS[quality].b,
    1
  )
  local qualityColor = ITEM_QUALITY_COLORS[quality].color
  self.ItemNameText:SetText(qualityColor:WrapTextInColorCode(itemName))
end

function PointBlankSniperItemIconMixin:OnEnter()
  if self.itemKey ~= nil then
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetItemKey(self.itemKey.itemID, self.itemKey.itemLevel, self.itemKey.itemSuffix, self.itemKey.battlePetSpeciesID)
    GameTooltip:Show()
  end
end

function PointBlankSniperItemIconMixin:OnLeave()
  if self.itemKey ~= nil then
    GameTooltip:Hide()
  end
end

