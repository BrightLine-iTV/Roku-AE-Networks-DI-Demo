function BrightLine_APILoad() as Boolean
    print "Channel _____BrightLineDirect:BrightLine_APILoad-"
    REM This is where the component library is loaded. 
    m.adlib = createObject("roSGNode", "ComponentLibrary")
    m.brightlineLoaded = false
    m.adlib.observeField("loadStatus", "BrightLineAPI_LoadStatus")
    pkgName = m.top.pkgName
    m.adlib.setField("uri", "http://cdn-media.brightline.tv/sdk/gen2/roku/direct/aetv/prod/BrightLineDirect_2.4.0.pkg")
    return true
end function

sub BrightLineAPI_LoadStatus() as void
    print " _____onAdLibLoadStatusChanged: " m.adlib.loadStatus
    print "m.adlib: " m.adlib
    m.top.sdkLoadStatus = m.adlib.loadStatus '**** Strictly for test channel -- remove in production *****
    
    REM Here we watch the load status of the component library package.
    if (m.adlib.loadStatus = "ready")
        m.adlib.UnobserveField("loadStatus")
        REM Here we create the BrightLineDirect object, by instancing BL_init from the 
        REM loaded library.

        
        m.BrightLineDirect = CreateObject("roSGNode", "BrightLineDirect:BL_init")
       
        m.BrightLineDirect.showDebug = true'm.top.showDebug
        if m.BrightLineDirect <> invalid then
            REM Here we make sure to add it to the view.
            m.top.appendChild(m.BrightLineDirect)
            
            REM We observe the "state" field of the library. This will direct us to make it visible and focused, or not.
            m.BrightLineDirect.observeField("state", "onBrightLineDirectStateChange")
            REM This is the event listener. It tells you when BrightLineDirect
            REM has fired your spot event, as well as other information.
            m.BrightLineDirect.observeField("event", "onBrightLineAPI_event")
            
            m.brightlineLoaded = true
            m.manTask = createObject("RoSGNode", "BrightLineManifestTask")
            m.manTask.observeField("manifest","onManifestLoaded")
            m.manTask.control = "RUN"
            
        else if m.adlib.loadStatus = "failed" then
            m.brightlineLoaded = false
        end if
    end if
end sub

function onBrightLineDirectStateChange(msg)
    print "~~~~~ onBrightLineDirectStateChange", msg.getData()
    print "Channel _____onBrightLineDirectStateChange:",  msg.getData()
    if m.BrightLineDirect.state = "initialized" then
        print "READY"
        m.top.BrightLineDirect = m.BrightLineDirect
    end if
    
    REM BrightLineDirect needs focus when it's in it's "showing" state
    if m.BrightLineDirect.state = "showing" then
        print "SHOWING"
        m.BrightLineDirect.setFocus(true)
    end if
    
    if m.BrightLineDirect.state = "ready" then
        REM Send focus back to whatever you want. 
        REM In this case we're using the video player
        if m.videoPlayer.visible = true then
            m.videoPlayer.setFocus(true)
        end if
    end if 
    
    if m.BrightLineDirect.state = "exited" then
        REM BrightLine has received an "exit" signal
        REM this is the equivalent of pressing the "back" key in a stream. 
        REM You might call up a menu, or just pause the video and expose some UI.
        m.BrightLineDirect.visible = false
        REM We're setting focus back to the menu.
        m.top.findNode("adList").setFocus(true)
        REM And hiding the video player.
        m.videoPlayer.visible = false
    end if
end function

function onBrightLineAPI_event(msg)
    
    REM These are events coming from the BrightLineDirect library. The can be tracking events that have fired, etc.
    print "Channel _____onBrightLineAPI_event", msg.getData()
    if(msg.getData().type = "Video") then
        if(msg.getData().value = "durationEnd") then
            m.BrightLineDirect.visible = false
            m.videoPlayer.setFocus(true)
        end if
    end if
end function

sub onManifestLoaded()
    m.BrightLineDirect.configJSON = m.manTask.manifest
    print"m.BrightLineDirect.configJSON: "m.BrightLineDirect.configJSON
end sub
