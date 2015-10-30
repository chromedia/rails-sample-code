After do |scenario|
  if scenario.failed?
    page.save_screenshot("features/_screenshots/#{scenario.__id__}.png")
    embed("#{scenario.__id__}.png", 'image/png', 'SCREENSHOT')
  end
end