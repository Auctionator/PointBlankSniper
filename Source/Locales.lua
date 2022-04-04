local currentLocale = {}

local function FixMissingTranslations(incomplete, locale)
  if locale == "enUS" then
    return
  end

  local enUS = POINT_BLANK_SNIPER_LOCALES["enUS"]()
  for key, val in pairs(enUS) do
    if incomplete[key] == nil then
      incomplete[key] = val
    end
  end
end

if POINT_BLANK_SNIPER_LOCALES[GetLocale()] ~= nil then
  currentLocale = POINT_BLANK_SNIPER_LOCALES[GetLocale()]()

  FixMissingTranslations(currentLocale, GetLocale())
else
  currentLocale = POINT_BLANK_SNIPER_LOCALES["enUS"]()
end

-- Export constants into the global scope (for XML frames to use)
for key, value in pairs(currentLocale) do
  _G["POINT_BLANK_SNIPER_L_"..key] = value
end
