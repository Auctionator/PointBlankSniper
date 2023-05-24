PointBlankSniper.Config.Options = {
  USE_BLEEP = "use_bleep_2",
  USE_FLASH = "use_flash_2",
  CARRY_ON_AFTER_RESULT = "carry_on_after_result_2",
  HIGHLIGHT_NEW_RESULTS = "highlight_new_results",
  PRICE_SOURCE = "price_source",
  PERCENTAGE = "percentage",
  WAS_PRICE_SOURCE_CHANGED = "was_price_source_changed",
  CURRENT_LIST = "current_list",
  ITEM_CLASS = "item_class",
  SCAN_MODE = "scan_mode",
  SHOW_NEW_ITEMS_MESSAGES = "show_new_items_messages_2",
  KEYS_SEARCH = "keys_search_2",
  SHOW_GHOST_COUNT = "ghost_count",
  ALLOW_GHOST_PURCHASES = "allow_ghost_purchases",
  COLUMNS = "columns",
}

PointBlankSniper.Config.Defaults = {
  [PointBlankSniper.Config.Options.USE_BLEEP] = true,
  [PointBlankSniper.Config.Options.USE_FLASH] = true,
  [PointBlankSniper.Config.Options.CARRY_ON_AFTER_RESULT] = true,
  [PointBlankSniper.Config.Options.HIGHLIGHT_NEW_RESULTS] = false,
  [PointBlankSniper.Config.Options.PRICE_SOURCE] = PointBlankSniper.Constants.Market.None,
  [PointBlankSniper.Config.Options.PERCENTAGE] = 0.15,
  [PointBlankSniper.Config.Options.WAS_PRICE_SOURCE_CHANGED] = false,
  [PointBlankSniper.Config.Options.SHOW_NEW_ITEMS_MESSAGES] = true,
  [PointBlankSniper.Config.Options.CURRENT_LIST] = "",
  [PointBlankSniper.Config.Options.ITEM_CLASS] = "",
  [PointBlankSniper.Config.Options.SCAN_MODE] = PointBlankSniper.Constants.ScanModes.Blank,
  [PointBlankSniper.Config.Options.KEYS_SEARCH] = false,
  [PointBlankSniper.Config.Options.SHOW_GHOST_COUNT] = false,
  [PointBlankSniper.Config.Options.ALLOW_GHOST_PURCHASES] = false,
  [PointBlankSniper.Config.Options.COLUMNS] = {},
}

function PointBlankSniper.Config.IsValidOption(name)
  for _, option in pairs(PointBlankSniper.Config.Options) do
    if option == name then
      return true
    end
  end
  return false
end

function PointBlankSniper.Config.Create(constant, name, defaultValue)
  PointBlankSniper.Config.Options[constant] = name

  PointBlankSniper.Config.Defaults[PointBlankSniper.Config.Options[constant]] = defaultValue

  if POINT_BLANK_SNIPER_CONFIG ~= nil and POINT_BLANK_SNIPER_CONFIG[name] == nil then
    POINT_BLANK_SNIPER_CONFIG[name] = defaultValue
  end
end

function PointBlankSniper.Config.Set(name, value)
  if POINT_BLANK_SNIPER_CONFIG == nil then
    error("POINT_BLANK_SNIPER_CONFIG not initialized")
  elseif not PointBlankSniper.Config.IsValidOption(name) then
    error("Invalid option '" .. name .. "'")
  else
    POINT_BLANK_SNIPER_CONFIG[name] = value
  end
end

function PointBlankSniper.Config.Reset()
  POINT_BLANK_SNIPER_CONFIG = {}
  for option, value in pairs(PointBlankSniper.Config.Defaults) do
    POINT_BLANK_SNIPER_CONFIG[option] = value
  end
end

function PointBlankSniper.Config.InitializeData()
  if POINT_BLANK_SNIPER_CONFIG == nil then
    PointBlankSniper.Config.Reset()
  else
    for option, value in pairs(PointBlankSniper.Config.Defaults) do
      if POINT_BLANK_SNIPER_CONFIG[option] == nil then
        POINT_BLANK_SNIPER_CONFIG[option] = value
      end
    end
  end
end

function PointBlankSniper.Config.Get(name)
  -- This is ONLY if a config is asked for before variables are loaded
  if POINT_BLANK_SNIPER_CONFIG == nil then
    return PointBlankSniper.Config.Defaults[name]
  else
    return POINT_BLANK_SNIPER_CONFIG[name]
  end
end
