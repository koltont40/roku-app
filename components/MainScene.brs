sub init()
    m.bg = m.top.findNode("bg")
    m.checkingGroup = m.top.findNode("checkingGroup")
    m.loginGroup = m.top.findNode("loginGroup")
    m.contentGroup = m.top.findNode("contentGroup")
    m.loginStatus = m.top.findNode("loginStatus")
    m.rowList = m.top.findNode("rowList")
    m.cameraInfoLabel = m.top.findNode("cameraInfoLabel")

    m.rowList.observeField("rowItemSelected", "onRowItemSelected")

    m.top.setFocus(true)
    checkAccessAndRoute()
end sub

sub checkAccessAndRoute()
    ipInfo = getDetectedIp()
    ip = ipInfo.ip

    allowedPrefixes = [ "100.64.", "192.168.50." ]
    ok = false

    if ip <> invalid and ip <> "" then
        for each prefix in allowedPrefixes
            if Left(ip, Len(prefix)) = prefix then ok = true
        end for
    end if

    if ok then
        showCameras()
    else
        m.checkingGroup.visible = false
        m.loginGroup.visible = true
        m.loginStatus.text = getLoginStatusMessage(ipInfo)
    end if
end sub

function getDetectedIp() as Object
    di = CreateObject("roDeviceInfo")
    ipAddrs = di.GetIPAddrs()

    if ipAddrs <> invalid and ipAddrs.count() > 0 then
        for each key in ipAddrs
            localIp = ipAddrs[key]
            if localIp <> invalid and localIp <> "" then
                return { ip: localIp, source: "local" }
            end if
        end for
    end if

    externalIp = di.GetExternalIP()
    if externalIp <> invalid and externalIp <> "" then
        return { ip: externalIp, source: "external" }
    end if

    return { ip: "", source: "unknown" }
end function

function getLoginStatusMessage(ipInfo as Object) as String
    if ipInfo.ip = invalid or ipInfo.ip = "" then
        return "Unable to determine IP address."
    end if

    if ipInfo.source = "local" then
        return "Local IP '" + ipInfo.ip + "' is not allowed."
    end if

    return "External IP '" + ipInfo.ip + "' is not allowed."
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press = false then return false

    if m.loginGroup.visible and key = "OK" then
        m.loginStatus.text = "Access granted locally. Loading cameras..."
        showCameras()
        return true
    end if

    return false
end function

sub showCameras()
    m.rowList.content = createSampleContent()
    m.checkingGroup.visible = false
    m.loginGroup.visible = false
    m.contentGroup.visible = true
    m.rowList.setFocus(true)
end sub

function createSampleContent() as Object
    top = CreateObject("roSGNode", "ContentNode")

    r1 = top.CreateChild("ContentNode")
    r1.title = "Weather Cameras"

    c1 = r1.CreateChild("ContentNode")
    c1.title = "Blount County Tower (Sample)"
    c1.hdPosterUrl = "pkg:/images/splash_hd.png"

    c2 = r1.CreateChild("ContentNode")
    c2.title = "St. Clair County Tower (Sample)"
    c2.hdPosterUrl = "pkg:/images/splash_hd.png"

    r2 = top.CreateChild("ContentNode")
    r2.title = "Environmental Data Views"

    d1 = r2.CreateChild("ContentNode")
    d1.title = "Radar + Camera Composite (Sample)"
    d1.hdPosterUrl = "pkg:/images/splash_hd.png"

    return top
end function

sub onRowItemSelected()
    sel = m.rowList.rowItemSelected
    row = sel[0]
    col = sel[1]

    rowNode = m.rowList.content.GetChild(row)
    item = rowNode.GetChild(col)

    if item <> invalid then
        m.cameraInfoLabel.text = "Camera: " + item.title + chr(10) + "Video preview coming soon."
    end if
end sub
