set config:ipu to 500.
set RSS to false.
set KSRSS to false.
set STOCK to false.
if bodyexists("Earth") {
    if body("Earth"):radius > 1600000 {
        set RSS to true.
        set LaunchSites to lexicon("KSC", "28.6084,-80.59975").
    }
    else {
        set KSRSS to true.
        set LaunchSites to lexicon("KSC", "28.5166,-81.2062").
    }
}
else {
    if body("Kerbin"):radius > 1000000 {
        set KSRSS to true.
        set LaunchSites to lexicon("KSC", "28.5166,-81.2062").
    }
    else {
        set STOCK to true.
        set LaunchSites to lexicon("KSC", "-0.0972,-74.5577", "Dessert", "-6.5604,-143.95", "Woomerang", "45.2896,136.11", "Baikerbanur", "20.6635,-146.4210").
    }
}


//------------Find Parts--------------//


set OLM to ship:partstitled("Starship Orbital Launch Mount")[0].
set TowerBase to ship:partstitled("Starship Orbital Launch Integration Tower Base")[0].
set TowerCore to ship:partstitled("Starship Orbital Launch Integration Tower Core")[0].
Set TowerTop to ship:partstitled("Starship Orbital Launch Integration Tower Rooftop")[0].
Set Mechazilla to ship:partsnamed("SLE.SS.OLIT.MZ.KOS")[0].
set PrevTime to time:seconds.
clearscreen.


//-------------Get Module Order-------------//



for x in range(0, Mechazilla:modules:length) {
    if Mechazilla:getmodulebyindex(x):hasaction("stop trolley") {
        set NrforVertMoveMent to x.
        break.
    }
}
print "vertical movement: " + NrforVertMoveMent.

for x in range(0, Mechazilla:modules:length) {
    if Mechazilla:getmodulebyindex(x):hasaction("stop arm") {
        set NrforStopArm1 to x.
        break.
    }
}
print "stop Arm 1: " + NrforStopArm1.

for x in range(NrforStopArm1 + 1, Mechazilla:modules:length) {
    if Mechazilla:getmodulebyindex(x):hasaction("stop arm") {
        set NrforStopArm2 to x.
        break.
    }
}
print "stop Arm 2: " + NrforStopArm2.

for x in range(0, Mechazilla:modules:length) {
    if Mechazilla:getmodulebyindex(x):hasaction("stop pusher") {
        set NrforStopPusher1 to x.
        break.
    }
}
print "stop Pusher 1: " + NrforStopPusher1.

for x in range(NrforStopPusher1 + 1, Mechazilla:modules:length) {
    if Mechazilla:getmodulebyindex(x):hasaction("stop pusher") {
        set NrforStopPusher2 to x.
        break.
    }
}
print "stop Pusher 2: " + NrforStopPusher2.

for x in range(0, Mechazilla:modules:length) {
    if Mechazilla:getmodulebyindex(x):hasfield("current angle") {
        set NrforOpenCloseArms to x.
        break.
    }
}
print "Open/Close Arms: " + NrforOpenCloseArms.

for x in range(0, Mechazilla:modules:length) {
    if Mechazilla:getmodulebyindex(x):hasaction("toggle pushers") {
        set NrforOpenClosePushers to x.
        break.
    }
}
print "Open/Close Pushers: " + NrforOpenClosePushers.

for x in range(0, Mechazilla:modules:length) {
    if Mechazilla:getmodulebyindex(x):hasaction("stop stabilizers") {
        set NrforStabilizers to x.
        break.
    }
}
print "Stabilizers: " + NrforStabilizers.



//----------------Program Start-Up---------------//


clearscreen.
if ship:partstitled("Donnager MK-1 Main Body"):length = 0 and ship:partstitled("Donnager MK-1 EXP Main Body"):length = 0 and ship:partstitled("Donnager MK-1 Depot"):length = 0 {
    print "No Ship Detected..".
    for var in LaunchSites:keys {
        if round(LaunchSites[var]:split(",")[0]:toscalar(9999), 2) = round(ship:geoposition:lat, 2) and round(LaunchSites[var]:split(",")[1]:toscalar(9999), 2) = round(ship:geoposition:lng, 2) {
            set ship:name to var + " OrbitalLaunchMount".
            break.
        }
    }
}
print "Tower Nominal Operation, awaiting command..".

until False {
    if CORE:MESSAGES:length > 0 or SHIP:MESSAGES:length > 0 {
        if ship:messages:empty {
            SET RECEIVED TO CORE:MESSAGES:POP.
        }
        else {
            SET RECEIVED TO SHIP:MESSAGES:POP.
        }
        //print "Command received: " + RECEIVED:CONTENT.
        if RECEIVED:CONTENT:CONTAINS(",") {
            set message to RECEIVED:CONTENT:SPLIT(",").
            set command to message[0].
            if message:length > 1 {
                set parameter1 to message[1].
            }
            if message:length > 2 {
                set parameter2 to message[2].
            }
            if message:length > 3 {
                set parameter3 to message[3].
            }
            if message:length > 4 {
                set parameter4 to message[4].
            }
        }
        else {
            set command to RECEIVED:CONTENT.
        }
        print timestamp(time:seconds):full + "   " + received:content.
        if command = "MechazillaHeight" {
            MechazillaHeight(parameter1, parameter2).
        }
        else if command = "MechazillaArms" {
            MechazillaArms(parameter1, parameter2, parameter3, parameter4).
        }
        else if command = "MechazillaPushers" {
            MechazillaPushers(parameter1, parameter2, parameter3, parameter4).
        }
        else if command = "LiftOff" {
            LiftOff().
        }
        else if command = "MechazillaStabilizers" {
            MechazillaStabilizers(parameter1).
        }
        else if command = "EmergencyStop" {
            EmergencyStop().
        }
        else if command = "ToggleReFueling" {
            ToggleReFueling(parameter1).
        }
        else {
            PRINT "Unexpected message: " + RECEIVED:CONTENT.
        }
    }
    if time:seconds > PrevTime + 0.25 {
        SaveToSettings("Tower:arms:rotation", Mechazilla:getmodulebyindex(NrforOpenCloseArms):getfield("current angle")).
        if Mechazilla:getmodulebyindex(NrforOpenCloseArms):hasevent("open arms") {
            SaveToSettings("Tower:arms:angle", 0).
        }
        else {
            SaveToSettings("Tower:arms:angle", Mechazilla:getmodulebyindex(NrforOpenCloseArms):getfield("arms open angle")).
        }
        SaveToSettings("Tower:pushers:extension", Mechazilla:getmodulebyindex(NrforOpenClosePushers):getfield("current extension")).
        SaveToSettings("Tower:stabilizers:extension", Mechazilla:getmodulebyindex(NrforStabilizers):getfield("current extension")).
        if RSS {
            SaveToSettings("Tower:arms:height", Mechazilla:getmodulebyindex(NrforVertMoveMent):getfield("current extension")).
        }
        else {
            SaveToSettings("Tower:arms:height", Mechazilla:getmodulebyindex(NrforVertMoveMent):getfield("current extension")).
        }
        set PrevTime to time:seconds.
    }
}



//-------------Functions-------------------//



function LiftOff {
    //OLM:getmodule("LaunchClamp"):DoAction("release clamp", true).
    OLM:getmodule("ModuleAnimateGeneric"):doevent("close clamps + qd").
    wait 0.1.
    for var in LaunchSites:keys {
        if round(LaunchSites[var]:split(",")[0]:toscalar(9999), 2) = round(ship:geoposition:lat, 2) and round(LaunchSites[var]:split(",")[1]:toscalar(9999), 2) = round(ship:geoposition:lng, 2) {
            set ship:name to var + " OrbitalLaunchMount".
            break.
        }
        set ship:name to "OrbitalLaunchMount".
    }
    wait 5.
    MechazillaPushers("0", "0.2", "12", "true").
    MechazillaHeight("6.5", "0.5").
    MechazillaArms("8","10","97.5","true").
    set ship:type to "Base".
    if ship:partstitled("Starship Orbital Launch Mount")[0]:getmodule("ModuleEnginesFX"):hasevent("shutdown engine") {
        ship:partstitled("Starship Orbital Launch Mount")[0]:getmodule("ModuleEnginesFX"):doevent("shutdown engine").
    }
}


function MechazillaHeight {
    parameter targetheight.
    parameter targetspeed.
    Mechazilla:getmodulebyindex(NrforVertMoveMent):SetField("target extension", targetheight:toscalar).
    Mechazilla:getmodulebyindex(NrforVertMoveMent):SetField("target speed", targetspeed:toscalar).
}


function MechazillaArms {
    parameter targetangle.
    parameter targetspeed.
    parameter armsopenangle.
    parameter ArmsOpen.
    //print targetangle.
    //print targetspeed.
    //print armsopenangle.
    //print ArmsOpen.
    Mechazilla:getmodulebyindex(NrforOpenCloseArms):SetField("target angle", targetangle:toscalar).
    Mechazilla:getmodulebyindex(NrforOpenCloseArms):SetField("target speed", targetspeed:toscalar).
    Mechazilla:getmodulebyindex(NrforOpenCloseArms):SetField("arms open angle", armsopenangle:toscalar).
    if ArmsOpen = "true" and Mechazilla:getmodulebyindex(NrforOpenCloseArms):hasevent("open arms") {
        Mechazilla:getmodulebyindex(NrforOpenCloseArms):DoAction("toggle arms", true).
    }
    if ArmsOpen = "false" and Mechazilla:getmodulebyindex(NrforOpenCloseArms):hasevent("close arms") {
        Mechazilla:getmodulebyindex(NrforOpenCloseArms):DoAction("toggle arms", true).
    }
}


function MechazillaPushers {
    parameter targetextension.
    parameter targetspeed.
    parameter pushersopenlimit.
    parameter PushersOpen.
    Mechazilla:getmodulebyindex(NrforOpenClosePushers):SetField("target extension", targetextension:toscalar).
    Mechazilla:getmodulebyindex(NrforOpenClosePushers):SetField("target speed", targetspeed:toscalar).
    if Mechazilla:getmodulebyindex(NrforOpenClosePushers):HasField("pushers close limit") {
        Mechazilla:getmodulebyindex(NrforOpenClosePushers):SetField("pushers close limit", pushersopenlimit:toscalar).
    }
    if Mechazilla:getmodulebyindex(NrforOpenClosePushers):HasField("pushers open limit") {
        Mechazilla:getmodulebyindex(NrforOpenClosePushers):SetField("pushers open limit", pushersopenlimit:toscalar).
    }
    if PushersOpen = "true" and Mechazilla:getmodulebyindex(NrforOpenClosePushers):hasevent("open pushers") {
        Mechazilla:getmodulebyindex(NrforOpenClosePushers):DoEvent("open pushers").
    }
    if PushersOpen = "false" and Mechazilla:getmodulebyindex(NrforOpenClosePushers):hasevent("close pushers") {
        Mechazilla:getmodulebyindex(NrforOpenClosePushers):DoEvent("close pushers").
    }
}


function MechazillaStabilizers {
    parameter StabilizerPercent.
    Mechazilla:getmodulebyindex(NrforStabilizers):SetField("target extension", StabilizerPercent:toscalar(0)).
}


function EmergencyStop {
    Mechazilla:getmodulebyindex(NrforVertMoveMent):SetField("target extension", Mechazilla:getmodulebyindex(NrforVertMoveMent):GetField("current extension")).
    Mechazilla:getmodulebyindex(NrforStopArm1):DoAction("stop arm", true).
    Mechazilla:getmodulebyindex(NrforStopArm2):DoAction("stop arm", true).
    Mechazilla:getmodulebyindex(NrforStopPusher1):DoAction("stop pusher", true).
    Mechazilla:getmodulebyindex(NrforStopPusher2):DoAction("stop pusher", true).
    HUDTEXT("Emergency Stop Activated! Operate the tower yourself with care..", 3, 2, 20, red, false).
}


function ToggleReFueling {
    parameter ReFueling.
    if Refueling = "true" {
        OLM:getmodulebyindex(3):DoAction("start fueling", true).
        if OLM:getmodulebyindex(3):getfield("generator") = "Off" {
            OLM:getmodulebyindex(3):DoAction("toggle generator", true).
        }
    }
    else {
        OLM:getmodulebyindex(3):DoAction("stop fueling", true).
        if OLM:getmodulebyindex(3):getfield("generator") = "Nominal" {
            OLM:getmodulebyindex(3):DoAction("toggle generator", true).
        }
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
        print "No connection".
    }
}