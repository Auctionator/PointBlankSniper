local NAME_TO_INVENTORY_SLOT = {}

local ArmorInventoryTypes = {
  Enum.InventoryType.IndexHeadType,
  Enum.InventoryType.IndexShoulderType,
  Enum.InventoryType.IndexChestType,
  Enum.InventoryType.IndexWaistType,
  Enum.InventoryType.IndexLegsType,
  Enum.InventoryType.IndexFeetType,
  Enum.InventoryType.IndexWristType,
  Enum.InventoryType.IndexHandType,
  Enum.InventoryType.IndexCloakType,
  Enum.InventoryType.IndexFingerType,
  Enum.InventoryType.IndexTrinketType,
  Enum.InventoryType.IndexHoldableType,
  Enum.InventoryType.IndexBodyType,
  Enum.InventoryType.IndexHeadType,
  Enum.InventoryType.IndexNeckType,
  Enum.InventoryType.IndexTabardType,
}

for _, id in pairs(Enum.InventoryType) do
  NAME_TO_INVENTORY_SLOT[GetItemInventorySlotInfo(id)] = id
end

function PointBlankSniper.Utilities.GetClassInfo(itemID, battlePetSpeciesID)
  local _, _, _, inventorySlotStr, _, classID, subClassID = GetItemInfoInstant(itemID)
  local inventoryType = NAME_TO_INVENTORY_SLOT[_G[inventorySlotStr]]

  if classID == Enum.ItemClass.Battlepet then
    subClassID = (select(3, C_PetJournal.GetPetInfoBySpeciesID(battlePetSpeciesID))) - 1
  end

  return {
    classID = classID, subClassID = subClassID, inventoryType = inventoryType,
  }
end
