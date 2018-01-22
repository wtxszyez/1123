-- We Suck Less menu item

platform = (FuPLATFORM_WINDOWS and "Windows") or (FuPLATFORM_MAC and "Mac") or (FuPLATFORM_LINUX and "Linux")
function OpenURL(siteName, path)
  if platform == "Windows" then
    -- Running on Windows
    command = "explorer \"" .. path .. "\""
  elseif platform == "Mac" then
    -- Running on Mac
    command = "open \"" .. path .. "\" &"
  elseif platform == "Linux" then
    -- Running on Linux
    command = "xdg-open \"" .. path .. "\" &"
  else
    print("[Error] There is an invalid Fusion platform detected")
    return
  end
  os.execute(command)
  -- print("[Launch Command] ", command)
  print("[Opening URL] [" .. siteName .. "] " .. path)
end

OpenURL("We Suck Less", "https://www.steakunderwater.com/")
