set MainCPU to SHIP:PARTSNAMED("SEP.S20.BODY").
if MainCPU:length = 0 {
    set MainCPU to SHIP:PARTSNAMED(("SEP.S20.BODY (" + ship:name + ")"))[0]:getmodule("kOSProcessor").
}
else {
    set MainCPU to MainCPU[0]:getmodule("kOSProcessor").
}

set LastPingReceived to 0.

until false {
    until not core:messages:empty {
        clearscreen.
        if KUniverse:realtime - LastPingReceived > 5 and not (LastPingReceived = 0) {
            wait 1.
            if not (core:messages:empty) {}
            else {
                sas on.
                print "Status: Rebooting Main CPU..".
                HUDTEXT("Rebooting due to Interface Time-Out..", 10, 2, 20, yellow, false).
                MainCPU:deactivate().
                SaveToSettings("Last Update Time", KUniverse:realtime).
                wait 1.
                MainCPU:activate().
                set LastPingReceived to 0.
                wait 4.
            }
        }
        print "WATCHDOG is guarding Main CPU..".
        if not (LastPingReceived = 0) {
            print "Status: Main CPU OK! (" + round(KUniverse:realtime - LastPingReceived, 2) + "s)".
            wait 0.1.
        }
        else {
            print "Status: Waiting for Main CPU..".
            wait 0.1.
        }
    }
    SET RECEIVED TO CORE:MESSAGES:POP.
    IF RECEIVED:CONTENT = "ping" {
        set LastPingReceived to KUniverse:realtime.
    }
    ELSE {
        PRINT "Unexpected message: " + RECEIVED:CONTENT.
    }
}


function SaveToSettings {
    parameter key.
    parameter value.
    if homeconnection:isconnected {
        set L to readjson("0:/settings.json").
        set L[key] to value.
        writejson(L, "0:/settings.json").
    }
    else {
        print "No connection, " + (key) + " : " +  (value) + " not saved".
    }
}
