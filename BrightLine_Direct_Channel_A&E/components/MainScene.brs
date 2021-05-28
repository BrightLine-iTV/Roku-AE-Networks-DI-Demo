sub init()
    m.top.SetFocus(true)
    
    m.top.showDebug = true

    m.top.backgroundURI = "pkg:/Images/background.jpg"

    
    REM The video player is a stubbed out group node, but we have to define it 
    m.videoPlayer = m.top.findNode("VideoPlayer")
    m.titleLabel = m.top.findNode("TitleLabel")
    m.titleLabel.text = "A&E DI CHANNEL"

    m.videoPlayer.width = 1920
    m.videoPlayer.height = 1080
    m.videoPlayer.translation = "[0,0]"
    
    m.videoPlayer.observeFieldScoped("state", "onVideoPlayerState")
    
    m.TitleLabel = m.top.findNode("TitleLabel")
    m.environmentInfoText = m.top.findNode("environmentInfoText")
    
    m.list = m.top.findNode("adList")
    m.list.observeField("itemSelected","onListSelected")
    m.list.setFocus(true)
    channel_font      = "pkg:/Fonts/Thasadith-Regular.ttf"
    channel_bold_font = "pkg:/Fonts/Thasadith-Bold.ttf"
    info_font         = "pkg:/Fonts/Thasadith-Regular.ttf"
    
    m.TitleLabel.font.uri          = info_font
    m.TitleLabel.font.size         = m.TitleLabel.font.size + 30
    m.environmentInfoText.font.uri = info_font
    m.list.font.uri                = channel_font
    m.list.font.size               = m.list.font.size + 8
    m.list.focusedFont.uri         = channel_bold_font
    m.list.focusedFont.size        = m.list.font.size + 18
    
    m.videoPlayer.visible = false
    
    m.storeLocatorSelected = false
    m.extendedLookIsSelected = false
    m.isFullTest = false
    
    m.top.observeField("sdkLoadStatus", "onBrightLineDirectSDKLoad")
    BrightLine_APILoad()
    End sub
    
    sub onBrightLineDirectSDKLoad()
        sdkLoadStatus = m.top.sdkLoadStatus
        if sdkLoadStatus = "ready" then
            m.environmentInfoTask = createObject("roSGNode", "EnvironmentInfoTask")
            m.environmentInfoTask.showDebug = m.top.showDebug
            m.environmentInfoTask.pkgName = m.top.pkgName
            m.environmentInfoTask.observeField("environmentInfo","updateEnvironmentInfo")
            m.environmentInfoTask.control = "run"
        end if
    end sub 
    
    function onVideoPlayerState(msg)
    state = msg.getData()
    print "Channel _____MainScene:onVideoPlayerState:m.videoPlayer.state:", state
    if state = "stopped" then
        m.videoPlayer.seek = 0
    else if state = "finished" then
        m.list.setFocus(true)
        m.videoPlayer.visible = false
    endif
end function


function onListSelected(msg) as Void

    m.list_title_selected = m.list.content.getChild(msg.getData()).TITLE
    if(m.list_title_selected = "Store Locator") then 
        m.storeLocatorSelected = true 
    else 
        m.storeLocatorSelected = false 
    end if
    if(m.list_title_selected = "(new) extended look 1" or m.list_title_selected = "(new) extended look 2" or m.list_title_selected = "(new) extended look 3") then
        m.extendedLookIsSelected = true
    else
        m.extendedLookIsSelected = false
    end if

    REM This is the setup for an ad using BrightLineDirect:
    
    if m.brightlineLoaded = false then
        print "*************************** (BrightLineDirect is NOT LOADED) ***************************"
        
        return
    else if m.brightlineLoaded = true then
    REM Here I'm getting the ad JSON url. This can be any approach you choose, but it'll be in the companion
    REM node, and have a "Brightline_RSG" subvert 
    newAd = m.list.content.getChild(msg.getData()).description
    print"m.list.content.getChild(msg.getData()).description: "m.list.content.getChild(msg.getData()).description

    REM We can make BrightLineDirect visible now, if we want. We'll use m.BrightLineDirect.state to determine focus.
    m.BrightLineDirect.visible = true
    
    REM Here are three examples of "setting an action object"
    REM Set a pointer to the stream player
    m.BrightLineDirect.action = {video: m.videoPlayer}
    REM Set the width of the UI
    m.BrightLineDirect.action = {width: 1920}
    REM Set the width of the UI
    m.BrightLineDirect.action = {height: 1080} 
        
    ad = {
            adId: 0315281           REM Populate from your ad
            contentId: 1426392      REM Populate from your ad
            adName: "single ad"     REM Populate from your ad
            streamFormat: "HLS"     REM Populate from your ad
            provider: "BrightLine"  REM This must be "BrightLine" for the library to work.
            adURL: newAd            REM This is where the ad JSON url is passed into the single-ad structure
            startAt: 12             REM This is when in the stream's progress the ad should appear.
            duration: 30            REM This is how long the ad should play.
            tracking: [             REM This array is the created from the ad server response.
                    {               
                        event: "AdStart"
                        time: 12
                        url: "http://www.foo.com/track"
                        triggered: false
                    },
                    
                    {
                        event: "AdComplete"
                        time: 42
                        url: "http://www.foo.com/track"   
                        triggered: false    
                    }
                ]
        }
        
        REM This is your tracking array for the spot quartiles.
    trackers = [
            {
                type:"Impression" 
                url:"http://events.brightline.tv/track?data=%7B%22type%22%3A%22impression%22%2C%22valid%22%3Atrue%2C%22ad_id%22%3A2344293%7D" 
                time:"12"
                triggered: false
            },
            
            {
                type:"FirstQuartile" 
                url:"http://events.brightline.tv/track?data=%7B%22type%22%3A%22duration%22%2C%22duration_type%22%3A%22impression%22%2C%22percent_complete%22%3A25%2C%22ad_id%22%3A2344293%7D" 
                time:"18"
                triggered: false
            },
            
            {
                type:"Midpoint" 
                url:"http://events.brightline.tv/track?data=%7B%22type%22%3A%22duration%22%2C%22duration_type%22%3A%22impression%22%2C%22percent_complete%22%3A50%2C%22ad_id%22%3A2344293%7D" 
                time:"27"
                triggered: false
            },
            
            {
                type:"ThirdQuartile" 
                url:"http://events.brightline.tv/track?data=%7B%22type%22%3A%22duration%22%2C%22duration_type%22%3A%22impression%22%2C%22percent_complete%22%3A75%2C%22ad_id%22%3A2344293%7D" 
                time:"33"
                triggered: false
            },
            
            {
                type:"Complete" 
                url:"http://events.brightline.tv/track?data=%7B%22type%22%3A%22duration%22%2C%22duration_type%22%3A%22impression%22%2C%22percent_complete%22%3A100%2C%22ad_id%22%3A2344293%7D" 
                time:"42"
                triggered: false
            },
        
        ]
        
        REM Let's see if BrightLineDirect is ready…
        if m.BrightLineDirect.state = "ready" OR m.BrightLineDirect.state = "initialized" then    
            REM Here we set the trackers object
            m.BrightLineDirect.trackers = trackers
            REM Here we set the ad, and get the process started.
            m.BrightLineDirect.ad = ad

            REM 
        else 
            REM There seems to be a problem. We can try some commands here: kill, restart, reset etc...
        end if
   end if
        playVideo()
        return
end function

function onVideoPlayerExitedChange()
    if m.videoPlayer.exited = true then
        m.videoPlayer.visible = false
        m.videoPlayer.exited = false
        m.list.setFocus(true)
    endif
end function

sub updateEnvironmentInfo()
  m.top.environmentInfoText = m.environmentInfoTask.environmentInfo
end sub

function playVideo() as Boolean
        if(m.storeLocatorSelected) then 
            videoURL = "http://cdn-media.brightline.tv/videos/ads/dev-roku-storelocator/benmoore.m3u8"
        else if(m.extendedLookIsSelected) then
            videoURL = "http://cdn-media.brightline.tv/jdixon/extendedLook_firstman_testStream_Apple_HLS_h264_SF_16x9_720p/extendedLook_firstman_testStream_Apple_HLS_h264_SF_16x9_720p.m3u8"
        else if(m.isFullTest) then
            videoURL = "http://cdn-media.brightline.tv/campaigns/brightline/dev/media/videos/roku_multiPod_testStream_Apple_HLS_h264_SF_MAR_720p/roku_multiPod_testStream_Apple_HLS_h264_SF_MAR_720p.m3u8"
        else
            videoURL = "http://cdn-media.brightline.tv/videos/ads/server_side_stitching_test/showmewhatyougot02/showmewhatyougot02.m3u8"
        end if
        
        m.videoPlayer.observeFieldScoped("exited", "onVideoPlayerExitedChange")
        
        m.videoPlayer.setFocus(true)
        m.videoPlayer.content = invalid

        videoContent = createObject("RoSGNode", "ContentNode")
        videoContent.url = videoURL
        videoContent.streamformat = "hls"
        
        m.videoPlayer.content = videoContent
        m.videoPlayer.visible = true
        
        if m.videoPlayer.state = "none" then
            m.videoPlayer.control = "play"
        else if m.videoPlayer.state = "stopped" then
            m.videoPlayer.control = "replay"
        end if
        
        return true
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    result = false
    if press = true then
        result = false
        print "Channel SDK____ keyPress", key
        REM don't bubble up
        if key = "play" then
            if m.videoPlayer.state = "playing" then
                m.videoPlayer.control = "pause"
            else if m.videoPlayer.state = "paused" then
                m.videoPlayer.control = "resume"
            end if
            result = false
        end if
    end if
    return result 
end function