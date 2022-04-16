PointBlankSniperItemIconMixin = {}

function PointBlankSniperItemIconMixin:Set(itemKey, itemName, iconTexture, quality, battlePetLink)
  self.itemKey = itemKey
  self.battlePetLink = battlePetLink
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
  GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
  if self.itemKey ~= nil then
    if self.battlePetLink ~= nil then
      BattlePetToolTip_ShowLink(self.battlePetLink)
      AuctionHouseUtil.AppendBattlePetVariationLines(BattlePetTooltip)
    else
      GameTooltip:SetItemKey(self.itemKey.itemID, self.itemKey.itemLevel, self.itemKey.itemSuffix)
      GameTooltip:Show()
    end
  end
end

function PointBlankSniperItemIconMixin:OnLeave()
  if self.itemKey ~= nil then
    if self.itemKey.battlePetSpeciesID ~= 0 then
      BattlePetTooltip:Hide()
    else
      GameTooltip:Hide()
    end
  end
end

