wait until ship:unpacked.

if not (ship:status = "FLYING") and not (ship:status = "SUB_ORBITAL") {
    if homeconnection:isconnected {
        switch to 0.
        if exists("1:starship.ksm") {
            if homeconnection:isconnected {
                HUDTEXT("Starting Interface..", 5, 2, 20, green, false).
                if open("0:starship.ks"):readall:string = open("1:/boot/starship.ks"):readall:string {}
                else {
                    HUDTEXT("Performing Update..", 5, 2, 20, yellow, false).
                    COMPILE "0:/starship.ks" TO "0:/starship.ksm".
                    if homeconnection:isconnected {
                        copypath("0:starship.ks", "1:/boot/").
                        copypath("starship.ksm", "1:").
                        set core:BOOTFILENAME to "starship.ksm".
                        reboot.
                    }
                    else {
                        HUDTEXT("Connection lost during Update! Can't update Interface..", 10, 2, 20, red, false).
                    }
                }
            }
            else {
                HUDTEXT("Connection lost during Update! Can't update Interface..", 10, 2, 20, red, false).
            }
        }
        else {
            HUDTEXT("First Time Boot detected! Initializing Ship Interface..", 10, 2, 20, green, false).
            print "starship.ksm doesn't yet exist in boot.. creating..".
            COMPILE "0:/starship.ks" TO "0:/starship.ksm".
            copypath("0:starship.ks", "1:/boot/").
            copypath("starship.ksm", "1:").
            set core:BOOTFILENAME to "starship.ksm".
            reboot.
        }
    }
    else {
        HUDTEXT("No connection available! Can't update Interface..", 10, 2, 20, red, false).
        HUDTEXT("Starting Interface..", 5, 2, 20, green, false).
    }
}