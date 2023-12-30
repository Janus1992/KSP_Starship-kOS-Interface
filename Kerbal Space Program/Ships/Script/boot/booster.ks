wait until ship:unpacked.

if not (ship:status = "FLYING") and not (ship:status = "SUB_ORBITAL") {
    if homeconnection:isconnected {
        switch to 0.
        if exists("1:booster.ksm") {
            if homeconnection:isconnected {
                if open("0:booster.ks"):readall:string = open("1:/boot/booster.ks"):readall:string {}
                else {
                    COMPILE "0:/booster.ks" TO "0:/booster.ksm".
                    if homeconnection:isconnected {
                        copypath("0:booster.ks", "1:/boot/").
                        copypath("booster.ksm", "1:").
                        set core:BOOTFILENAME to "booster.ksm".
                        reboot.
                    }
                }
            }
        }
        else {
            print "booster.ksm doesn't yet exist in boot.. creating..".
            COMPILE "0:/booster.ks" TO "0:/booster.ksm".
            copypath("0:booster.ks", "1:/boot/").
            copypath("booster.ksm", "1:").
            set core:BOOTFILENAME to "booster.ksm".
            reboot.
        }
    }
}