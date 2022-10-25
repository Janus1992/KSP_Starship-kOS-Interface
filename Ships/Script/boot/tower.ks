//------------Find Parts--------------//


set OrbitalLaunchMount to SHIP:PARTSNAMED("SLE.SS.OLP").
if OrbitalLaunchMount:length = 0 {
    set OrbitalLaunchMount to SHIP:PARTSNAMED("SLE.SS.OLP (OrbitalLaunchMount)")[0].
}
else {
    set OrbitalLaunchMount to OrbitalLaunchMount[0].
}
set TowerBase to SHIP:PARTSNAMED("SLE.SS.OLIT.Base")[0].
set TowerCore to SHIP:PARTSNAMED("SLE.SS.OLIT.Core")[0].
Set TowerTop to SHIP:PARTSNAMED("SLE.SS.OLIT.Top")[0].
Set Mechazilla to SHIP:PARTSNAMED("SLE.SS.OLIT.MZ")[0].
set config:ipu to 500.
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
print "Tower Nominal Operation, awaiting command..".

//print Mechazilla:getmodulebyindex(1).  // vertical movement
//print Mechazilla:getmodulebyindex(2).  // stop arm
//print Mechazilla:getmodulebyindex(3).  // stop arm.
//print Mechazilla:getmodulebyindex(4).  // stop pusher
//print Mechazilla:getmodulebyindex(5).  // stop pusher.
//print Mechazilla:getmodulebyindex(6).  // open/close arms
//print Mechazilla:getmodulebyindex(7).  // open/close pushers
//print Mechazilla:getmodulebyindex(8).  // open/close stabilizers

until False {
    if time:seconds > PrevTime + 0.1 {
        SaveToSettings("Tower:arms:rotation", Mechazilla:getmodulebyindex(NrforOpenCloseArms):getfield("current angle")).
        if Mechazilla:getmodulebyindex(NrforOpenCloseArms):hasevent("open arms") {
            SaveToSettings("Tower:arms:angle", 0).
        }
        else {
            SaveToSettings("Tower:arms:angle", Mechazilla:getmodulebyindex(NrforOpenCloseArms):getfield("arms open angle")).
        }
        SaveToSettings("Tower:pushers:extension", Mechazilla:getmodulebyindex(NrforOpenClosePushers):getfield("current extension")).
        SaveToSettings("Tower:stabilizers:extension", Mechazilla:getmodulebyindex(NrforStabilizers):getfield("current extension")).
        SaveToSettings("Tower:arms:height", Mechazilla:getmodulebyindex(NrforVertMoveMent):getfield("current extension")).
        set PrevTime to time:seconds.
    }

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
}



//-------------Functions-------------------//



function LiftOff {
    //SHIP:PARTSNAMED("SLE.SS.OLP")[0]:getmodule("LaunchClamp"):DoAction("release clamp", true).
    wait 0.1.
    set ship:name to "OrbitalLaunchMount".
    wait 5.
    MechazillaPushers("0", "0.2", "12", "true").
    MechazillaHeight("6.5", "0.5").
    MechazillaArms("8","10","97.5","true").
    set ship:type to "Base".
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
    if Mechazilla:getmodulebyindex(NrforOpenClosePushers):HasField("pushers open limit") {
        if PushersOpen = "true" and Mechazilla:getmodulebyindex(NrforOpenClosePushers):hasevent("open pushers") {
            Mechazilla:getmodulebyindex(NrforOpenClosePushers):DoAction("toggle pushers", true).
        }
        if PushersOpen = "false" and Mechazilla:getmodulebyindex(NrforOpenClosePushers):hasevent("close pushers") {
            Mechazilla:getmodulebyindex(NrforOpenClosePushers):DoAction("toggle pushers", true).
        }
    }
    if Mechazilla:getmodulebyindex(NrforOpenClosePushers):HasField("pushers close limit") {
        if PushersOpen = "false" and Mechazilla:getmodulebyindex(NrforOpenClosePushers):hasevent("open pushers") {
            Mechazilla:getmodulebyindex(NrforOpenClosePushers):DoAction("toggle pushers", true).
        }
        if PushersOpen = "true" and Mechazilla:getmodulebyindex(NrforOpenClosePushers):hasevent("close pushers") {
            Mechazilla:getmodulebyindex(NrforOpenClosePushers):DoAction("toggle pushers", true).
        }
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
        OrbitalLaunchMount:getmodulebyindex(3):DoAction("start fueling", true).
        if OrbitalLaunchMount:getmodulebyindex(3):getfield("generator") = "Off" {
            OrbitalLaunchMount:getmodulebyindex(3):DoAction("toggle generator", true).
        }
    }
    else {
        OrbitalLaunchMount:getmodulebyindex(3):DoAction("stop fueling", true).
        if OrbitalLaunchMount:getmodulebyindex(3):getfield("generator") = "Nominal" {
            OrbitalLaunchMount:getmodulebyindex(3):DoAction("toggle generator", true).
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
