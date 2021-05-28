sub init()
  m.top.functionName = "getEnvironmentInfo"
end sub

sub getEnvironmentInfo()
  di = createObject("roDeviceInfo")
  ai = createObject("roAppInfo")
  model = di.GetModel()
  fw_ver = di.getVersion()

  BL_ver = "n/a"
  
  environmentInfo = [
      "SDK IS LOADED & READY"
      "Changes: n/a - stable prod"
      "Debug On: " + m.top.showDebug.toStr()
      "Roku model: " + model
      "OS: " + mid(fw_ver,3,3) + "  Build: " + mid(fw_ver,9,4)
      "video = "+ di.getVideoMode()
      "ui = "+ di.getDisplayMode()
      "ui_resolutions = "+ ai.getValue("ui_resolutions")
  ].join(chr(10))

  m.top.environmentInfo = environmentInfo
  print"environmentInfo: "environmentInfo
end sub
