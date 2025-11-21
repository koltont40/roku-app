sub init()
    m.bg = m.top.findNode("bg")
    m.checkingGroup = m.top.findNode("checkingGroup")
    m.loginGroup = m.top.findNode("loginGroup")
    m.contentGroup = m.top.findNode("contentGroup")
    m.loginStatus = m.top.findNode("loginStatus")
    m.rowList = m.top.findNode("rowList")
    m.cameraInfoLabel = m.top.findNode("cameraInfoLabel")

    m.rowList.observeField("rowItemSelected", "onRowItemSelected")

    setupLoginUi()
    m.top.setFocus(true)
    checkAccessAndRoute()
end sub

sub setupLoginUi()
    if m.loginGroup = invalid then
        m.loginGroup = CreateObject("roSGNode", "Group")
        m.loginGroup.id = "loginGroup"
        m.loginGroup.visible = false
        m.top.appendChild(m.loginGroup)
    end if

    if m.loginTitle = invalid then
        m.loginTitle = CreateObject("roSGNode", "Label")
        m.loginTitle.text = "Login Required"
        m.loginTitle.translation = [ 90, 120 ]
        m.loginTitle.font = "font:LargeBoldSystemFont"
        m.loginGroup.appendChild(m.loginTitle)
    end if

    if m.loginStatus = invalid then
        m.loginStatus = CreateObject("roSGNode", "Label")
        m.loginStatus.id = "loginStatus"
        m.loginStatus.translation = [ 90, 170 ]
        m.loginStatus.font = "font:MediumSystemFont"
        m.loginGroup.appendChild(m.loginStatus)
    end if

    if m.loginHint = invalid then
        m.loginHint = CreateObject("roSGNode", "Label")
        m.loginHint.translation = [ 90, 210 ]
        m.loginHint.font = "font:SmallSystemFont"
        m.loginHint.text = "You are off the permitted subnet. Authenticate to continue."
        m.loginGroup.appendChild(m.loginHint)
    end if

    if m.loginButton = invalid then
        m.loginButton = CreateObject("roSGNode", "Button")
        m.loginButton.id = "loginButton"
        m.loginButton.translation = [ 90, 260 ]
        m.loginButton.minWidth = 400
        m.loginButton.minHeight = 60
        m.loginButton.text = "Request Access"
        m.loginGroup.appendChild(m.loginButton)
        m.loginButton.observeField("buttonSelected", "onLoginButtonSelected")
    end if
end sub

sub checkAccessAndRoute()
    ipInfo = getDetectedIp()
    ip = ipInfo.ip

    allowedPrefixes = [ "100.64." ]
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
        if m.loginButton <> invalid then m.loginButton.setFocus(true)
    end if
end sub

function isPrivateIp(ip as String) as Boolean
    if ip = invalid or ip = "" then return true

    if Left(ip, 3) = "10." then return true
    if Left(ip, 8) = "192.168." then return true

    if Left(ip, 4) = "172." then
        parts = ip.split(".")
        if parts.count() >= 2 then
            secondOctet = val(parts[1])
            if secondOctet >= 16 and secondOctet <= 31 then return true
        end if
    end if

    if Left(ip, 8) = "169.254" then return true

    return false
end function

function getDetectedIp() as Object
    di = CreateObject("roDeviceInfo")
    ipAddrs = di.GetIPAddrs()

    if ipAddrs <> invalid and ipAddrs.count() > 0 then
        for each key in ipAddrs
            localIp = ipAddrs[key]
            if localIp <> invalid and localIp <> "" and not isPrivateIp(localIp) then
                return { ip: localIp, source: "local" }
            end if
        end for
    end if

    externalIp = di.GetExternalIP()
    if externalIp <> invalid and externalIp <> "" and not isPrivateIp(externalIp) then
        return { ip: externalIp, source: "external" }
    end if

    return { ip: "", source: "unknown" }
end function

function getLoginStatusMessage(ipInfo as Object) as String
    if ipInfo.ip = invalid or ipInfo.ip = "" then
        return "Unable to determine non-private IP address."
    end if

    if ipInfo.source = "local" then
        return "Detected on-net address '" + ipInfo.ip + "' is not allowed for this app."
    end if

    return "Detected external address '" + ipInfo.ip + "' is not allowed for this app."
end function

sub onLoginButtonSelected(msg as Object)
    if m.loginGroup.visible and msg <> invalid and msg.getData() = true then
        m.loginStatus.text = "Requesting access..."
        showCameras()
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press = false then return false

    if m.loginGroup.visible then
        if key = "OK" then
            m.loginStatus.text = "Requesting access..."
            showCameras()
            return true
        else if key = "back" or key = "Back" then
            m.loginStatus.text = "Access required."
            return true
        end if
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
