wait until ship:unpacked.

if homeconnection:isconnected {
    switch to 0.
    if exists("1:/watchdog.ks") {
        if open("0:/boot/watchdog.ks"):readall:string = open("1:/watchdog.ks"):readall:string {
            print "starting up..".
            wait 1.
        }
        else {
            if homeconnection:isconnected {
                copypath("0:/boot/watchdog.ks", "1:/").
                set core:BOOTFILENAME to "watchdog.ks".
                print "updating..".
                wait 1.
                reboot.
            }
        }
    }
    else {
        copypath("0:/boot/watchdog.ks", "1:/").
        set core:BOOTFILENAME to "watchdog.ks".
        print "adding bootfile..".
        wait 1.
        reboot.
    }
}

for x in ship:parts {
    if x:name:contains("SEP.S20.BODY") {
        set MainCPU to x:getmodule("kOSProcessor").
    }
}

set LastPingReceived to 0.
set LastPingReceivedRealTime to 0.

until false {
    until not core:messages:empty {
        clearscreen.
        if min(time:seconds - LastPingReceived, kuniverse:realtime - LastPingReceivedRealTime) > 5 and not (LastPingReceived = 0) and kuniverse:timewarp:warp = 0 {
            wait 1.
            if not (core:messages:empty) or min(time:seconds - LastPingReceived, kuniverse:realtime - LastPingReceivedRealTime) < 5 {}
            else {
                sas on.
                print "Status: Rebooting Main CPU..".
                HUDTEXT("Rebooting due to Interface Time-Out..", 5, 2, 20, yellow, false).
                MainCPU:deactivate().
                wait 0.001.
                MainCPU:activate().
                set LastPingReceived to 0.
            }
        }
        else {
            print "WATCHDOG is guarding Main CPU..".
            if not (LastPingReceived = 0) {
                print "Status: Main CPU OK! (" + round(min(time:seconds - LastPingReceived, kuniverse:realtime - LastPingReceivedRealTime), 2) + "s)".
                wait 0.1.
            }
            else {
                print "Status: Waiting for Main CPU..".
                wait 0.1.
            }
        }
    }
    SET RECEIVED TO CORE:MESSAGES:POP.
    IF RECEIVED:CONTENT = "ping" {
        set LastPingReceived to time:seconds.
        set LastPingReceivedRealTime to kuniverse:realtime.
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
