sub init()
    ?">>>>>> CHANNEL MANIFEST TASK INIT"
    m.top.functionName = "manifestLoad"
    m.configurationServiceURL = "http://services.brightline.tv/api/v2/config/9"

end sub

function onManifestChange() 
    print "CHANNEL:____Manifest Changed"', m.top.manifest
end function

function manifestLoad() as Object

    'retrieveManifestFromServer = function() as String
        tracking = "1"
        if get_IsAdIdTrackingDisabled() = true then
            tracking = "0"
        end if
        port = CreateObject("roMessagePort")
        requestUrl = m.configurationServiceURL
        
        request = CreateObject("roUrlTransfer")
        request.SetMessagePort(port)
        request.AddHeader("Content-Type","application/json")
        analyticRequestParams = {}
        analyticRequestParams.append({
        
            advertisingIdentifier: get_advertiser_id()
            applicationIdentifier: get_platform_app_id()
            deviceUUID: device_id()
            'screenResolution: "1920,1080"
            'mobileCarrier: ""
            osVersion: Str(getFirmware()).Trim()
            trackFlag: tracking
            os: "roku"
            deviceModel: device_model()
            'applicationName: "BasicExample"
            manufacturer: "roku"
            'deviceConnectionType: "WiFi"
            sdkVersion: "2.0.0"
            platformName: "roku_sg"
            applicationVersion: "1"
        })

        requestString = FormatJson(analyticRequestParams)
        print"requestString = FormatJson(analyticRequestParams): "requestString = FormatJson(analyticRequestParams)

        request.SetUrl(requestUrl) 
    
        if (request.AsyncPostFromString(requestString))
            while (true)
                msg = wait(0, port)
                if (type(msg) = "roUrlEvent")
                    code = msg.GetResponseCode()
                    if (code = 200)
                        Print ">>>>>>>>> MANIFEST: " msg.GetString()
                        json = ParseJSON(msg.GetString())
                        Print"json: " json
                        'the assumption is that hulu is prepending here also'
                        json.resources.images = "http:" + json.resources.images
                        json.resources.videos = "http:" + json.resources.videos
                        m.top.manifest = json
                        return msg
                    endif
                else if (event = invalid)
                    request.AsyncCancel()
                end if
            end while
        end if
        return invalid

    'end function
    
   '' retrieveManifestFromServer()
end function




function getFirmware() as Float
  deviceInfo_ = CreateObject("roDeviceInfo")
  firmware_ = deviceInfo_.GetVersion()
  firmware_ = firmware_.Mid(2, 4)
  return firmware_.toFloat()
end function

function get_IsAdIdTrackingDisabled() as Boolean
    deviceData = CreateObject("roDeviceInfo")
    return deviceData.IsRIDADisabled()
end function

function device_model() as String
    di = CreateObject("roDeviceInfo")
    return di.GetModel()
end function

function get_advertiser_id() as String
    deviceData = CreateObject("roDeviceInfo")
    return deviceData.GetRIDA()
end function

function device_id() as String
    di = CreateObject("roDeviceInfo")
    return  di.GetChannelClientID()
end function

function get_platform_app_id() as String
    appInfo = CreateObject("roAppInfo")
    return appInfo.GetID()
end function
