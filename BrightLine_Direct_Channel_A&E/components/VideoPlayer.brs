sub init()
    'print "CHANNEL ___VideoPlayer:init"
    m.videoPlayer = m.top.findNode("VideoPlayer")
    m.top.observeField("focusedChild", "onFocusedChildChange")
    setVideoPlayerColors()
end sub

function controlVideo()
    'print "Channel _____VideoPlayer:controlVideo: " , msg.getData()
    REM This is a stub for control. 
    REM You can handle all of your video UI operations 
    REM here before you pass control to the video object itself.
    
    if m.top.control = "play" then

    end if
    
    if m.top.control = "replay" then

    end if
    
    print "CHANNEL ___VideoPlayer:controlVideo:", m.top.control
    if m.top.control <> invalid then
        if m.videoPlayer <> invalid then
            m.videoPlayer.control = m.top.control
        end if
    end if
end function


function onFocusedChildChange()
    'print "Channel _____VideoPlayer:onFocusedChildChange"
end function

sub setVideoPlayerColors()
    videoPlayer = m.videoPlayer

    videoPlayerColor = "#0972F5"

    rtBar = videoPlayer.retrievingBar
    rtBar.filledBarBlendColor = videoPlayerColor

    tpbar = videoPlayer.trickPlayBar
    tpbar.filledBarBlendColor = videoPlayerColor

    bfBar = videoPlayer.bufferingBar
    bfBar.filledBarBlendColor = videoPlayerColor
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    REM set to bubble
    result = false
    
    if press = true then
        print "Channel __________videoPlayer Stub___ onKeyEvent:", key
        REM don't bubble up
        result = true '<<<<< why?'
        if key = "OK" then
            REM
        end if
        if key = "back" then
            m.videoPlayer.control = "stop"
            m.top.visible = false
            m.top.exited = true
            result = true
        end if
        if key = "play" then
            if m.videoPlayer.state = "stopped" then
                m.videoPlayer.control = "play"
                ?"Channel __________videoPlayer: play video"
                result = true
            end if
            if m.videoPlayer.state = "playing" then
                m.videoPlayer.control = "pause"
                ?"Channel __________videoPlayer: pause video"
                result = true
            end if
            if m.videoPlayer.state = "paused" then
                m.videoPlayer.control = "resume"
                ?"Channel __________videoPlayer: resume video"
                m.top.setFocus(true)
                result = true
            end if
        
        end if
        
    end if

    return result 
end function
