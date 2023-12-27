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



set LogData to false.
set starship to "xxx".
set ShipFound to false.
set LandSomewhereElse to false.
set idealVS to 0.
set LatCtrl to 0.
set LngCtrl to 0.
set LngError to 0.
set LatError to 0.
set ErrorVector to V(0, 0, 0).
set BoosterEngines to SHIP:PARTSNAMED("SEP.23.BOOSTER.CLUSTER").
set GridFins to SHIP:PARTSNAMED("SEP.23.BOOSTER.GRIDFIN").
for part in ship:parts {
    if part:name:contains("SEP.23.BOOSTER.INTEGRATED") {
        set BoosterCore to part.
    }
}
set InitialError to -9999.
set maxDecel to 0.
set TotalstopTime to 0.
set TotalstopDist to 0.
set stopDist3 to 0.
set landingRatio to 0.
set maxstabengage to 50.
set GS to 0.
set BoostBackComplete to false.
set lastVesselChange to time:seconds.
set LandingBurnStarted to false.
set BoosterRA to 0.
set BoosterHeight to 0.
set stopTime9 to 0.
set TimeStabilized to 0.
set LFBooster to 0.
set LiftingPointToGridFinDist to 0.
set MiddleEnginesShutdown to false.
set StarshipExists to false.
set TowerExists to false.
set InitialOverShoot to 0.
set TargetOLM to false.
set BoosterDocked to false.
set QuickSaveLoaded to false.
set ShipNotFound to false.

set RSS to false.
set KSRSS to false.
set STOCK to false.
if bodyexists("Earth") {
    if body("Earth"):radius > 1600000 {
        set RSS to true.
        set Planet to "Earth".
        set LaunchSites to lexicon("KSC", "28.6084,-80.59975").
        set BoosterHeight to 74.9.
        set BoosterRA to 36.24.
        set LiftingPointToGridFinDist to 4.5.
        if BoosterCore:hasmodule("FARPartModule") {
            set LngCtrlPID to PIDLOOP(0.01, 0.001, 0.001, -15, 15).
        }
        else {
            set LngCtrlPID to PIDLOOP(0.01, 0.001, 0.001, -15, 15).
        }
        set LatCtrlPID to PIDLOOP(0.01, 0.0000, 0.0000, -2, 2).
        set LFBoosterFuelCutOff to 3600.
        set LandHeadingVector to heading(270,0):vector.
        set BoosterLandingFactor to 0.8.
        set BoosterGlideDistance to 7500.
        set BoosterReturnMass to 200.
        set BoosterRaptorThrust to 2363.
        set TowerAlignAltitude to 7500.
        set Scale to 1.6.
        set InitialOverShoot to 450.
    }
    else {
        set KSRSS to true.
        set Planet to "Earth".
        set LaunchSites to lexicon("KSC", "28.5166,-81.2062").
        set BoosterHeight to 46.8.
        set BoosterRA to 22.65.
        set LiftingPointToGridFinDist to 0.5.
        if BoosterCore:hasmodule("FARPartModule") {
            set LngCtrlPID to PIDLOOP(0.005, 0.0025, 0.0025, -20, 20).
        }
        else {
            set LngCtrlPID to PIDLOOP(0.005, 0.0025, 0.0025, -20, 20).
        }
        set LatCtrlPID to PIDLOOP(0.04, 0.0025, 0.0025, -2.5, 2.5).
        set LFBoosterFuelCutOff to 2400.
        set LandHeadingVector to heading(242,0):vector.
        set BoosterLandingFactor to 1.05.
        set BoosterGlideDistance to 6000.
        set BoosterReturnMass to 140.
        set BoosterRaptorThrust to 627.
        set TowerAlignAltitude to 4500.
        set Scale to 1.
        set InitialOverShoot to 750.
    }
}
else {
    if body("Kerbin"):radius > 1000000 {
        set KSRSS to true.
        set Planet to "Kerbin".
        set LaunchSites to lexicon("KSC", "28.5166,-81.2062").
        set BoosterHeight to 46.8.
        set BoosterRA to 22.65.
        set LiftingPointToGridFinDist to 0.5.
        if BoosterCore:hasmodule("FARPartModule") {
            set LngCtrlPID to PIDLOOP(0.005, 0.0025, 0.0025, -20, 20).
        }
        else {
            set LngCtrlPID to PIDLOOP(0.005, 0.0025, 0.0025, -20, 20).
        }
        set LatCtrlPID to PIDLOOP(0.04, 0.0025, 0.0025, -2.5, 2.5).
        set LFBoosterFuelCutOff to 2400.
        set LandHeadingVector to heading(242,0):vector.
        set BoosterLandingFactor to 0.75.
        set BoosterGlideDistance to 6000.
        set BoosterReturnMass to 140.
        set BoosterRaptorThrust to 627.
        set TowerAlignAltitude to 6000.
        set Scale to 1.
        set InitialOverShoot to 750.
    }
    else {
        set STOCK to true.
        set Planet to "Kerbin".
        set LaunchSites to lexicon("KSC", "-0.0972,-74.5577", "Dessert", "-6.5604,-143.95", "Woomerang", "45.2896,136.11", "Baikerbanur", "20.6635,-146.4210").
        set BoosterHeight to 46.8.
        set BoosterRA to 22.65.
        set LiftingPointToGridFinDist to 0.5.
        set LngCtrlPID to PIDLOOP(0.005, 0.0025, 0.0025, -20, 20).
        set LatCtrlPID to PIDLOOP(0.05, 0.0005, 0.0005, -1, 1).
        set LFBoosterFuelCutOff to 2200.
        set LandHeadingVector to heading(270,0):vector.
        set BoosterLandingFactor to 0.8.
        set BoosterGlideDistance to 5000.
        set BoosterReturnMass to 138.
        set BoosterRaptorThrust to 667.
        set TowerAlignAltitude to 5500.
        set Scale to 1.
        set InitialOverShoot to 750.
    }
}
lock RadarAlt to alt:radar - BoosterRA.

for res in BoosterCore:resources {
    if res:name = "LqdMethane" {
        set LFBoosterFuelCutOff to LFBoosterFuelCutOff * 5.310536.
    }
}

for fin in GridFins {
    if fin:hasmodule("ModuleControlSurface") {
        fin:getmodule("ModuleControlSurface"):SetField("authority limiter", 32).
    }
    if fin:hasmodule("SyncModuleControlSurface") {
        fin:getmodule("SyncModuleControlSurface"):SetField("authority limiter", 32).
    }
}

if exists("0:/BoosterFlightData.csv") {
    deletepath("0:/BoosterFlightData.csv").
}

clearscreen.
print "Booster Nominal Operation, awaiting command..".


until False {
    set ShipConnectedToBooster to false.
    for Part in SHIP:PARTS {
        if Part:name:contains("SEP.23.SHIP.BODY") {
            set ShipConnectedToBooster to true.
        }
    }
    if ShipConnectedToBooster = "false" and BoostBackComplete = "false" and not (ship:status = "LANDED") and altitude > 10000 {
        Boostback(0).
    }
    if alt:radar < 150 and alt:radar > 40 and ship:mass - ship:drymass < 50 and ship:partstitled("Starship Orbital Launch Integration Tower Base"):length = 0 {
        setLandingZone().
        setTargetOLM().
        BoosterDocking().
    }
    WAIT UNTIL NOT CORE:MESSAGES:EMPTY.
    SET RECEIVED TO CORE:MESSAGES:POP.
    IF RECEIVED:CONTENT = "Boostback, 0 Roll" {
        Boostback(0).
    }
    else if RECEIVED:CONTENT = "Boostback, 180 Roll" {
        Boostback(180).
    }
    ELSE {
        PRINT "Unexpected message: " + RECEIVED:CONTENT.
    }
    wait 0.01.
}


function Boostback {
    parameter roll.

    wait until SHIP:PARTSNAMED("SEP.23.SHIP.BODY"):LENGTH = 0 and SHIP:PARTSNAMED("SEP.23.SHIP.BODY.EXP"):LENGTH = 0 and SHIP:PARTSNAMED("SEP.23.SHIP.DEPOT"):LENGTH = 0.
    set ship:name to "Booster".
    unlock steering.
    //if verticalspeed > 0 {
        lock throttle to 1.
    //}
    sas off.
    set SteeringManager:ROLLCONTROLANGLERANGE to 10.
    set SteeringManager:rollts to 5.
    wait 0.1.
    HUDTEXT("Performing Boostback Burn..", 30, 2, 20, green, false).
    clearscreen.
    print "Starting Boostback".
    set CurrentTime to time:seconds.
    set kuniverse:timewarp:warp to 0.
    set impactpos to ship:body:geopositionof(ship:position).

    setLandingZone().
    setTargetOLM().

    set ApproachUPVector to (landingzone:position - body:position):normalized.
    set ApproachVector to vxcl(up:vector, landingzone:position - ship:position):normalized.
    //set ApproachVectorDraw to vecdraw(v(0,0,0), 5 * ApproachVector, green, "ApproachVector", 20, true, 0.005, true, true).

    if RSS {
        SetLoadDistances(1650000).
    }
    else if KSRSS {
        SetLoadDistances(1000000).
    }
    else {
        SetLoadDistances(350000).
    }

    if verticalspeed > 0 {
        if roll = 0 {
            lock SteeringVector to lookdirup(AngleAxis(-30, facing:starvector) * facing:forevector, -up:vector).
            lock steering to SteeringVector.
        }
        else {
            lock SteeringVector to lookdirup(AngleAxis(30, facing:starvector) * facing:forevector, up:vector).
            lock steering to SteeringVector.
        }
        when vang(facing:forevector, -vxcl(up:vector, ErrorVector)) < 90 then {
            ActivateGridFins().
        }
    }

    wait 0.001.
    if defined L {
        if L:haskey("Ship Name") {
            set starship to L["Ship Name"].
            until ShipFound or verticalspeed < 0 or ShipNotFound {
                list targets in tgtlist.
                for tgt in tgtlist {
                    if (tgt:name) = (starship) {
                        set ShipFound to true.
                        print tgt:name.
                        wait 0.001.
                    }
                }
                set ShipNotFound to true.
            }
        }
    }

    until vang(facing:forevector, vxcl(up:vector, -ErrorVector)) < 15 or vang(facing:forevector, vxcl(up:vector, -ErrorVector)) < angularvel:y * 100 or verticalspeed < 0 {
        SteeringCorrections().
        if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
        SetBoosterActive().
        rcs on.
        wait 0.1.
    }

    if verticalspeed > 0 {
        BoosterEngines[0]:getmodule("ModuleTundraEngineSwitch"):DOACTION("previous engine mode", true).
    }
    if RSS {
        lock throttle to min(-(LngError + BoosterGlideDistance - 1000) / 20000 + 0.01, 7.5 * 9.81 / (max(ship:availablethrust, 0.000001) / ship:mass)).
        lock SteeringVector to lookdirup(vxcl(up:vector, -ErrorVector), -up:vector).
        lock steering to SteeringVector.
    }
    else {
        lock throttle to min(-(LngError + BoosterGlideDistance - 1000) / 10000 + 0.01, 7.5 * 9.81 / (max(ship:availablethrust, 0.000001) / ship:mass)).
        lock SteeringVector to lookdirup(vxcl(up:vector, -ErrorVector), -up:vector).
        lock steering to SteeringVector.
    }

    print "Available Thrust: " + round(max(ship:availablethrust, 0.000001)) + "kN".
    wait 0.1.

    until ErrorVector:mag < BoosterGlideDistance + 5000 or verticalspeed < 0 {
        SteeringCorrections().
        if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
        SetBoosterActive().
        wait 0.1.
    }

    set CurrentVec to facing:forevector.
    lock SteeringVector to lookdirup(CurrentVec, ApproachVector:normalized - 0.5 * up:vector:normalized).
    lock steering to SteeringVector.

    until LngError > -BoosterGlideDistance or verticalspeed < 0 {
        SteeringCorrections().
        if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
        SetBoosterActive().
        wait 0.001.
    }
    unlock throttle.
    lock throttle to 0.
    set BoostBackComplete to true.
    set turnTime to time:seconds.
    HUDTEXT("Rotating Booster for re-entry and landing..", 20, 2, 20, green, false).

    CheckFuel().
    if LFBooster > LFBoosterFuelCutOff {
        BoosterCore:activate.
    }

    set SteeringManager:maxstoppingtime to 5.
    lock SteeringVector to lookdirup(CurrentVec * AngleAxis(-6 * min(time:seconds - turnTime, 22.5), lookdirup(CurrentVec, up:vector):starvector), -up:vector).
    lock steering to SteeringVector.

    if vang(facing:forevector, lookdirup(CurrentVec * AngleAxis(-6 * 22.5, lookdirup(CurrentVec, up:vector):starvector), -up:vector):vector) > 10 {
        until time:seconds - turnTime > 15 {
            SteeringCorrections().
            SetBoosterActive().
            rcs on.
            CheckFuel().
            wait 0.1.
        }

        lock SteeringVector to lookdirup(CurrentVec * AngleAxis(-6 * min(time:seconds - turnTime, 22.5), lookdirup(CurrentVec, up:vector):starvector), up:vector).
        lock steering to SteeringVector.

        until time:seconds - turnTime > 19 {
            SteeringCorrections().
            SetBoosterActive().
            rcs on.
            CheckFuel().
            wait 0.1.
        }
        set SteeringManager:maxstoppingtime to 2.

        until time:seconds - turnTime > 30 {
            SteeringCorrections().
            SetBoosterActive().
            rcs on.
            CheckFuel().
            wait 0.1.
        }
    }

    set switchTime to time:seconds.
    until time:seconds > switchTime + 2.5 {
        SteeringCorrections().
        rcs on.
        SetBoosterActive().
        CheckFuel().
        wait 0.1.
    }

    HUDTEXT("Starship will continue its orbit insertion..", 10, 2, 20, green, false).

    until time:seconds > switchTime + 5 {
        SteeringCorrections().
        rcs on.
        SetBoosterActive().
        CheckFuel().
        wait 0.1.
    }

    BoosterCore:getmodule("ModuleRCSFX"):SetField("thrust limiter", 5).

    if not (starship = "xxx") {
        list targets in tlist.
        for tgt in tlist {
            if tgt:name:contains(starship) {
                KUniverse:forceactive(vessel(starship)).
                set StarshipExists to true.
            }
        }
    }
    else {
        if homeconnection:isconnected {
            if exists("0:/settings.json") {
                set L to readjson("0:/settings.json").
                set starship to L["Ship Name"].
                if not (starship = "xxx") {
                    KUniverse:forceactive(vessel(starship)).
                }
                else {
                    print "Couldn't find vessel".
                    wait 2.5.
                }
            }
        }
    }

    until altitude < 30000 and not (RSS) or altitude < 75000 and RSS {
        SteeringCorrections().
        rcs on.
        CheckFuel().
        if abs(steeringmanager:angleerror) > 10 {
            SetBoosterActive().
            BoosterCore:getmodule("ModuleRCSFX"):SetField("thrust limiter", 25).
        }
        else if abs(steeringmanager:angleerror) < 0.25 and KUniverse:activevessel = ship {
            if TimeStabilized = "0" {
                set TimeStabilized to time:seconds.
                SetBoosterActive().
            }
            if time:seconds - TimeStabilized > 5 {
                SetStarshipActive().
                BoosterCore:getmodule("ModuleRCSFX"):SetField("thrust limiter", 10).
                set TimeStabilized to 0.
            }
        }
        else {
            set TimeStabilized to 0.
        }
        wait 0.1.
    }

    BoosterCore:getmodule("ModuleRCSFX"):SetField("thrust limiter", 100).
    //lock SteeringVector to lookdirup(-velocity:surface * AngleAxis(-LngCtrl, lookdirup(-velocity:surface, up:vector):starvector) * AngleAxis(LatCtrl, up:vector), up:vector * AngleAxis(-2 * LatCtrl, ApproachVector)).
    lock SteeringVector to lookdirup(-velocity:surface * AngleAxis(-LngCtrl, lookdirup(-velocity:surface, up:vector):starvector) * AngleAxis(LatCtrl, up:vector), ApproachVector * AngleAxis(2 * LatCtrl, up:vector)).
    lock steering to SteeringVector.

    when RSS and LngError > LngCtrlPID:setpoint - 500 or not (RSS) and LngError > LngCtrlPID:setpoint - 100 then {
        if RSS {
            set LngCtrlPID to PIDLOOP(0.1, 0.005, 0.005, -10, 10).
            //when altitude < TowerAlignAltitude then {
            //    set LngCtrlPID:kp to 0.025.
            //}
        }
        else {
            if BoosterCore:hasmodule("FARPartModule") {
                set LngCtrlPID to PIDLOOP(0.1, 0.015, 0.015, -10, 10).
            }
            else {
                set LngCtrlPID to PIDLOOP(0.1, 0.015, 0.015, -10, 10).
            }
            when altitude < 5000 then {
                set LngCtrlPID:kp to 0.2.
            }
        }
        unlock steering.
        lock steering to SteeringVector.
    }

    until landingRatio > 1 and alt:radar < 3000 or alt:radar < 1850 {
        SteeringCorrections().
        if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
        if altitude > 20000 {
            rcs on.
        }
        else {
            rcs off.
        }
        SetBoosterActive().
        CheckFuel().
        wait 0.1.
    }
    
    lock throttle to (landingRatio * min(maxDecel, 44 - 9.81)) / maxDecel.
    lock SteeringVector to lookdirup(-velocity:surface, ApproachVector).
    lock steering to SteeringVector.

    set LandingBurnAltitude to altitude.
    set LandingBurnStarted to true.
    HUDTEXT("Performing Landing Burn..", 3, 2, 20, green, false).

    if abs(LngError) > 600 or abs(LatError) > 150 {
        set LandSomewhereElse to true.
        lock RadarAlt to alt:radar - BoosterRA.
        HUDTEXT("Mechazilla out of range..", 10, 2, 20, red, false).
        HUDTEXT("Landing somewhere else..", 10, 2, 20, red, false).
        lock SteeringVector to lookdirup(-1 * velocity:surface, ApproachVector).
        lock steering to SteeringVector.
    }

    when RadarAlt < 1500 and not (LandSomewhereElse) then {
        if not (TargetOLM = "false") and TowerExists {
            if Vessel(TargetOLM):distance < 2250 {
                lock RadarAlt to vdot(up:vector, GridFins[0]:position - Vessel(TargetOLM):PARTSNAMED("SLE.SS.OLIT.MZ.KOS")[0]:position) - LiftingPointToGridFinDist.
                when RadarAlt < 5 * BoosterHeight and vxcl(up:vector, landingzone:position - ship:position):mag < 7.5 or RadarAlt < 2 * BoosterHeight then {
                    sendMessage(Vessel(TargetOLM), "MechazillaArms,8,6,60,true").
                    sendMessage(Vessel(TargetOLM), "MechazillaStabilizers,0").
                    when RadarAlt < BoosterHeight then {
                        set TimeToZero to -verticalspeed / min(maxDecel - 9.81, 5 + 9.81) - 0.5.
                        set ArmIdealSpeed to 30 / TimeToZero.
                        sendMessage(Vessel(TargetOLM), ("MechazillaArms,8," + ArmIdealSpeed + ",60,false")).
                    }
                }
            }
        }
    }

    if BoosterCore:hasmodule("FARPartModule") {
        set MaxError to 100.
    }
    else {
        set MaxError to 80.
    }

    when verticalspeed > -100 and (stopDist3 / RadarAlt) < 1 and LngError < MaxError or verticalspeed > -50 or RadarAlt < 500 then {
        set MiddleEnginesShutdown to true.
        BoosterEngines[0]:getmodule("ModuleTundraEngineSwitch"):DOACTION("next engine mode", true).
        lock throttle to (landingRatio * min(maxDecel, 5 + 9.81)) / maxDecel.
        if LngError > 250 or LngError < -50 or abs(LatError) > 25 {
            lock RadarAlt to alt:radar - BoosterRA.
            set LandSomewhereElse to true.
            HUDTEXT("Mechazilla out of range..", 10, 2, 20, red, false).
            HUDTEXT("Landing somewhere else..", 10, 2, 20, red, false).
            lock SteeringVector to lookdirup(-1 * velocity:surface, ApproachVector).
            lock steering to SteeringVector.
            when verticalspeed > -15 then {
                lock SteeringVector to lookdirup(up:vector - 0.03 * velocity:surface, LandHeadingVector).
                lock steering to SteeringVector.
            }
        }
        else {
            lock SteeringVector to lookdirup(up:vector - 0.03 * velocity:surface - 0.025 * ErrorVector, ApproachVector).
            lock steering to SteeringVector.
            when verticalspeed > -80 then {
                if not (LandSomewhereElse) {
                    if not (TargetOLM = "false") {
                        set LandHeadingVector to vxcl(up:vector, Vessel(TargetOLM):partstitled("Starship Orbital Launch Integration Tower Base")[0]:position - Vessel(TargetOLM):partstitled("Starship Orbital Launch Mount")[0]:position).
                    }
                    if RSS {
                        lock SteeringVector to lookdirup(up:vector - 0.03 * velocity:surface - 0.03 * ErrorVector, LandHeadingVector).
                    }
                    else if KSRSS {
                        lock SteeringVector to lookdirup(up:vector - 0.03 * velocity:surface - 0.0275 * ErrorVector, LandHeadingVector).
                    }
                    else {
                        lock SteeringVector to lookdirup(up:vector - 0.03 * velocity:surface - 0.03 * ErrorVector, LandHeadingVector).
                    }
                    lock steering to SteeringVector.
                }
                when abs(LngError) < 10 and abs(LatError) < 10 and vxcl(up:vector, ship:position - landingzone:position):mag < 20 and not RSS or abs(LngError) < 20 and abs(LatError) < 20 and vxcl(up:vector, ship:position - landingzone:position):mag < 50 and RSS then {
                    if RSS {
                        lock SteeringVector to lookdirup(up:vector - 0.015 * velocity:surface - 0.0035 * ErrorVector, LandHeadingVector).
                    }
                    else if KSRSS {
                        lock SteeringVector to lookdirup(up:vector - 0.03 * velocity:surface - 0.0075 * ErrorVector, LandHeadingVector).
                    }
                    else {
                        lock SteeringVector to lookdirup(up:vector - 0.03 * velocity:surface - 0.02 * ErrorVector, LandHeadingVector).
                    }
                    lock steering to SteeringVector.
                }
                when verticalspeed > -15 then {
                    if RSS {
                        lock SteeringVector to lookdirup(up:vector - 0.005 * velocity:surface, LandHeadingVector).
                    }
                    else if KSRSS {
                        lock SteeringVector to lookdirup(up:vector - 0.01 * velocity:surface, LandHeadingVector).
                    }
                    else {
                        lock SteeringVector to lookdirup(up:vector - 0.01 * velocity:surface, LandHeadingVector).
                    }
                    lock steering to SteeringVector.
                    if abs(LngError) > 10 and not (RSS) or abs(LatError) > 10 and not (RSS) or abs(LngError) > 20 and RSS or abs(LatError) > 20 and RSS {
                        set LandSomewhereElse to true.
                        lock RadarAlt to alt:radar - BoosterRA.
                        lock SteeringVector to lookdirup(up:vector - 0.03 * velocity:surface, LandHeadingVector).
                        lock steering to SteeringVector.
                        HUDTEXT("Mechazilla out of range..", 10, 2, 20, red, false).
                        HUDTEXT("Landing somewhere else..", 10, 2, 20, red, false).
                    }
                }
            }
        }
    }


    until verticalspeed > -0.01 and RadarAlt < 1.5 and ship:status = "LANDED" or verticalspeed > 0.25 and RadarAlt < 2.5 {
        SteeringCorrections().
        if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
        if RadarAlt > 500 {
            rcs off.
        }
        else {
            rcs on.
        }
        SetBoosterActive().
        CheckFuel().
        wait 0.1.
    }

    set ship:control:translation to v(0, 0, 0).
    unlock steering.
    lock throttle to 0.
    set ship:control:pilotmainthrottle to 0.
    rcs off.
    clearscreen.
    print "Booster Landed!".
    wait 0.01.
    BoosterEngines[0]:shutdown.
    SetLoadDistances("default").

    DeactivateGridFins().
    BoosterEngines[0]:getmodule("ModuleTundraEngineSwitch"):DOACTION("next engine mode", true).

    if not (LandSomewhereElse) {
        if not (TargetOLM = "false") {
            HUDTEXT("Booster Landing Confirmed! Stand by for Mechazilla operation..", 10, 2, 20, green, false).
            set LandingTime to time:seconds.
            set TowerReset to false.
            set RollAngleExceeded to false.
            BoosterEngines[0]:getmodule("ModuleDockingNode"):SETFIELD("docking acquire force", 200).
            sendMessage(Vessel(TargetOLM), "DockingForce,200").
            print "Tower Operation in Progress..".

            sendMessage(Vessel(TargetOLM), "MechazillaPushers,0,1,0.2,false").
            sendMessage(Vessel(TargetOLM), ("MechazillaStabilizers," + maxstabengage)).

            when time:seconds > LandingTime + 3.25 * Scale then {
                sendMessage(Vessel(TargetOLM), ("MechazillaPushers,0,0.5," + (0.2 * Scale) + ",false")).
                when time:seconds > LandingTime + 5.75 * Scale then {
                    sendMessage(Vessel(TargetOLM), ("MechazillaPushers,0,0.3," + (0.2 * Scale) + ",false")).
                    when time:seconds > LandingTime + 8.25 * Scale then {
                        sendMessage(Vessel(TargetOLM), ("MechazillaPushers,0,0.1," + (0.2 * Scale) + ",false")).
                        when kuniverse:canquicksave and time:seconds > LandingTime + 15 * Scale then {
                            HUDTEXT("Loading current Booster quicksave for safe docking! (Avoid Kraken..)", 10, 2, 20, green, false).
                            sendMessage(Vessel(TargetOLM), ("MechazillaHeight," + (7 * Scale) + ",0.5")).
                            wait 1.5.
                            when kuniverse:canquicksave then {
                                kuniverse:quicksave().
                                wait 0.1.
                                when kuniverse:canquicksave then {
                                    kuniverse:quickload().
                                }
                            }
                        }
                    }
                }
            }

            until TowerReset {
                clearscreen.
                set RollAngle to vang(facing:starvector, AngleAxis(-90, up:vector) * LandHeadingVector).
                print "Roll Angle: " + round(RollAngle,1).
                if RollAngle > 30 or RollAngle < -30 {
                    set RollAngleExceeded to true.
                    set TowerReset to true.
                    break.
                }
            }
            if not RollAngleExceeded {
                print "Booster has been secured & Tower has been reset!".
                HUDTEXT("Tower has been reset, Booster may now be recovered!", 10, 2, 20, green, false).
                print "Booster has been secured!".
                HUDTEXT("Booster may now be recovered!", 10, 2, 20, green, false).
            }
            else {
                sendMessage(Vessel(TargetOLM), "EmergencyStop").
                print "Emergency Stop Activated! Roll Angle exceeded: " + round(RollAngle, 1).
                print "Continue manually with great care..".
                HUDTEXT("Emergency Stop Activated!", 10, 2, 20, red, false).
                HUDTEXT("Continue manually with great care..", 10, 2, 20, red, false).
            }
        }
        else {
            print "Booster has been secured".
            HUDTEXT("Booster may now be recovered!", 10, 2, 20, green, false).
        }
    }
    else {
        print "Booster has touched down somewhere".
        HUDTEXT("Booster may now be recovered!", 10, 2, 20, green, false).
    }

    unlock throttle.
    //if BoosterCore:getmodule("ModuleSepPartSwitchAction"):getfield("current decouple system") = "Decoupler" {
    //    BoosterCore:getmodule("ModuleSepPartSwitchAction"):DoAction("next decouple system", true).
    //}

    HUDTEXT("Booster may now be recovered!", 10, 2, 20, green, false).
}



FUNCTION SteeringCorrections {
    if KUniverse:activevessel = ship {
        set addons:tr:descentmodes to list(true, true, true, true).
        set addons:tr:descentgrades to list(true, true, true, true).
        set addons:tr:descentangles to list(180, 180, 180, 180).
        if not addons:tr:hastarget {
            ADDONS:TR:SETTARGET(landingzone).
        }
        if altitude > 15000 and KUniverse:activevessel = vessel(ship:name) {
            set ApproachVector to vxcl(up:vector, landingzone:position - ship:position):normalized.
        }

        if addons:tr:hasimpact {
            set ErrorVector to ADDONS:TR:IMPACTPOS:POSITION - landingzone:POSITION.
            set impactpos to ship:body:geopositionof(ADDONS:TR:IMPACTPOS:POSITION).
        }
        set LatError to vdot(AngleAxis(-90, ApproachUPVector) * ApproachVector, ErrorVector).
        set LngError to vdot(ApproachVector, ErrorVector).

        if altitude < 30000 or KUniverse:activevessel = vessel(ship:name) {
            set GS to groundspeed.

            if InitialError = -9999 and addons:tr:hasimpact {
                set InitialError to LngError.
            }

            if altitude > TowerAlignAltitude {
                set LngCtrlPID:setpoint to min(InitialOverShoot, 0.5 * vdot(ApproachVector, vxcl(up:vector, landingzone:position - ship:position))).
            }
            else {
                set LngCtrlPID:setpoint to min(2 * BoosterLandingFactor * GS, 350).
            }

            set LngCtrl to -LngCtrlPID:UPDATE(time:seconds, LngError).
            set LatCtrl to -LatCtrlPID:UPDATE(time:seconds, LatError).
            if LngCtrl > 0 {
                set LatCtrl to -LatCtrl.
            }

            set maxDecel to max((ship:availablethrust / ship:mass), 0.000001).
            set maxDecel3 to (3 * BoosterRaptorThrust / max(ship:mass, BoosterReturnMass)) - 9.81.

            if not (MiddleEnginesShutdown) {
                set stopTime9 to (airspeed - 100) / min(maxDecel, 44).
                set stopDist9 to ((airspeed + 100) / 2) * stopTime9.
                set stopTime3 to min(100, airspeed) / min(maxDecel3, 5).
                set stopDist3 to (min(100, airspeed) / 2) * stopTime3.
                set TotalstopTime to stopTime9 + stopTime3.
                set TotalstopDist to stopDist9 + stopDist3.
                set landingRatio to TotalstopDist * cos(vang(-velocity:surface, up:vector)) / RadarAlt.
            }
            else {
                set TotalstopTime to airspeed / min(maxDecel - 9.81, 5).
                set TotalstopDist to (airspeed / 2) * TotalstopTime.
                set landingRatio to TotalstopDist / RadarAlt.
            }

            if alt:radar < 1500 {
                set magnitude to (altitude + 400) / 100.
                if ErrorVector:mag > magnitude and LandingBurnStarted {
                    set ErrorVector to ErrorVector:normalized * magnitude.
                }
            }

            if LandSomewhereElse {
                set RadarAlt to alt:radar - BoosterRA.
            }
        }

        clearscreen.
        print "Lng Error: " + round(LngError) + " / " + round(LngCtrlPID:setpoint).
        print "Lat Error: " + round(LatError).
        print "Radar Alt: " + round(RadarAlt) + "m".
        //print " ".

        //if altitude < 15000 and not (RSS) or altitude < 50000 and RSS {
        //    print "LngCtrl: " + round(LngCtrl, 2).
        //    print "LatCtrl: " + round(LatCtrl, 2).
        //    print " ".
        //    print "Max Decel: " + round(maxDecel, 2).
        //    print "Radar Alt: " + round(RadarAlt).
        //    print "Stop Time: " + round(TotalstopTime, 2).
        //    print "Stop Distance: " + round(TotalstopDist, 2).
        //    print "Stop Distance 3: " + round(stopDist3, 2).
        //    print "Landing Ratio: " + round(landingRatio, 2).
        //}
    }
    else {
        clearscreen.
        //print "Booster: Coasting back to LZ..".
        //print " ".
        print "Radar Altitude: " + round(RadarAlt).
        //if ShipExists {
        //    print "Ship Distance: " + (round(vessel(starship):distance) / 1000) + "km".
        //}
    }
    if not (LFBooster = 0) {
        print "LF on Board: " + round(LFBooster, 1) + " / " + round(LFBoosterFuelCutOff).
    }
    print " ".
    print "Steering Error: " + round(SteeringManager:angleerror, 2).
    //print "OPCodes left: " + opcodesleft.
    LogBoosterFlightData().
}


function LogBoosterFlightData {
    if LogData {
        if homeconnection:isconnected {
            if defined PrevLogTime {
                set TimeStep to 1.
                if timestamp(time:seconds) > PrevLogTime + TimeStep {
                    set DistanceToTarget to (vxcl(up:vector, landingzone:position - ship:position):mag * (ship:body:radius / 1000 * 2 * constant:pi) / 360).
                    LOG (timestamp():clock + "," + DistanceToTarget + "," + altitude + "," + ship:verticalspeed + "," + airspeed + "," + LngError + "," + LatError + "," + vang(ship:facing:forevector, -velocity:surface) + "," + throttle + "," + (ship:mass * 1000)) to "0:/BoosterFlightData.csv".
                    set PrevLogTime to timestamp(time:seconds).
                }
            }
            else {
                set PrevLogTime to timestamp(time:seconds).
                LOG "Time, Distance to Target (km), Altitude (m), Vertical Speed (m/s), Airspeed (m/s), Longitude Error (m), Latitude Error (m), Actual AoA (°), Throttle (%), Mass (kg)" to "0:/BoosterFlightData.csv".
            }
        }
    }
}


function sendMessage{
    parameter ves, msg.
    set cnx to ves:connection.
    if cnx:isconnected {
        if cnx:sendmessage(msg) {
            //print "message sent..(" + msg + ")".
        }
        else {
            //print "message could not be sent..".
        }.
    }
    else {
        //print "connection could not be established..".
    }
}


function SetBoosterActive {
    if KUniverse:activevessel = vessel(ship:name) {}
    else if time:seconds > lastVesselChange + 2 {
        HUDTEXT("Setting focus to Booster..", 3, 2, 20, yellow, false).
        KUniverse:forceactive(vessel("Booster")).
        set lastVesselChange to time:seconds.
    }
}


function SetStarshipActive {
    if KUniverse:activevessel = vessel(ship:name) and time:seconds > lastVesselChange + 2 and StarshipExists {
        HUDTEXT("Setting focus to Ship..", 3, 2, 20, yellow, false).
        KUniverse:forceactive(vessel(starship)).
        set lastVesselChange to time:seconds.
    }
    else {}
}

function SetLoadDistances {
    parameter distance.

    if distance = "default" {
        set ship:loaddistance:flying:unload to 22500.
        set ship:loaddistance:flying:load to 2250.
        wait 0.001.
        set ship:loaddistance:flying:pack to 25000.
        set ship:loaddistance:flying:unpack to 2000.
        wait 0.001.
        set ship:loaddistance:suborbital:unload to 15000.
        set ship:loaddistance:suborbital:load to 2250.
        wait 0.001.
        set ship:loaddistance:suborbital:pack to 10000.
        set ship:loaddistance:suborbital:unpack to 200.
        wait 0.001.
        set ship:loaddistance:landed:unload to 2500.
        set ship:loaddistance:landed:load to 2250.
        wait 0.001.
        set ship:loaddistance:landed:pack to 350.
        set ship:loaddistance:landed:unpack to 200.
        wait 0.001.
    }
    else {
        set ship:loaddistance:flying:unload to distance.
        set ship:loaddistance:flying:load to distance - 5000.
        wait 0.001.
        set ship:loaddistance:flying:pack to distance - 2500.
        set ship:loaddistance:flying:unpack to distance - 10000.
        wait 0.001.
        set ship:loaddistance:suborbital:unload to distance.
        set ship:loaddistance:suborbital:load to distance - 5000.
        wait 0.001.
        set ship:loaddistance:suborbital:pack to distance - 2500.
        set ship:loaddistance:suborbital:unpack to distance - 10000.
        wait 0.001.
        set ship:loaddistance:landed:unload to distance.
        set ship:loaddistance:landed:load to distance - 5000.
        wait 0.001.
        set ship:loaddistance:landed:pack to distance - 2500.
        set ship:loaddistance:landed:unpack to distance - 10000.
        wait 0.001.
    }
}


function CheckFuel {
    for res in BoosterCore:resources {
        if res:name = "LiquidFuel" {
            set LFBooster to res:amount.
            if LFBooster < LFBoosterFuelCutOff {
                BoosterCore:shutdown.
            }
        }
        if res:name = "LqdMethane" {
            set LFBooster to res:amount.
            if LFBooster < LFBoosterFuelCutOff {
                BoosterCore:shutdown.
            }
        }
    }
}


function setLandingZone {
    if homeconnection:isconnected {
        if exists("0:/settings.json") {
            set L to readjson("0:/settings.json").
            if L:haskey("Log Data") {
                if L["Log Data"] = "true" {
                    set LogData to true.
                }
            }
            if L:haskey("Launch Coordinates") {
                if RSS {
                    set landingzone to latlng(L["Launch Coordinates"]:split(",")[0]:toscalar(28.6084), L["Launch Coordinates"]:split(",")[1]:toscalar(-80.5998)).
                }
                else {
                    set landingzone to latlng(L["Launch Coordinates"]:split(",")[0]:toscalar(-000.0972), L["Launch Coordinates"]:split(",")[1]:toscalar(-074.5577)).
                }
            }
            else {
                set landingzone to latlng(-000.0972,-074.5577).
            }
        }
    }
    else {
        set landingzone to latlng(-000.0972,-074.5577).
    }
}


function setTargetOLM {
    list targets in OLMTargets.
    if OLMTargets:length > 0 {
        for x in OLMTargets {
            if x:name:contains("OrbitalLaunchMount") {
                set TowerExists to true.
                if round(body:geopositionof(x:position):lat, 2) = round(landingzone:lat, 2) and round(body:geopositionof(x:position):lng, 2) = round(landingzone:lng, 2) {
                    set TargetOLM to x:name.
                }
            }
        }
    }
}


function BoosterDocking {
    HUDTEXT("Wait for Booster docking to start..", 20, 2, 20, green, false).
    wait 25.
    sendMessage(Vessel(TargetOLM), ("MechazillaHeight," + (29.9 * Scale) + ",0.5")).
    DeactivateGridFins().
    set LandingTime to time:seconds.
    clearscreen.
    print "Booster docking in progress..".
    HUDTEXT("Booster docking in progress..", 50, 2, 20, green, false).
    when time:seconds > LandingTime + 50 * Scale and not (BoosterDocked) then {
        HUDTEXT("Docking Booster..", 10, 2, 20, green, false).
        sendMessage(Vessel(TargetOLM), ("MechazillaHeight," + (29.6 * Scale) + ",0.05")).
        wait 6 * Scale.
        sendMessage(Vessel(TargetOLM), ("MechazillaHeight," + (29.9 * Scale) + ",0.05")).
        wait 6 * Scale.
        preserve.
    }
    when ship:partstitled("Starship Orbital Launch Integration Tower Base"):length > 0 then {
        set BoosterDocked to true.
    }

    when BoosterDocked then {
        HUDTEXT("Booster Docked! Resetting tower..", 20, 2, 20, green, false).
        sendMessage(Vessel(TargetOLM), ("MechazillaHeight," + (32.5 * Scale) + ",0.5")).
        sendMessage(Vessel(TargetOLM), "MechazillaArms,8,2.5,60,true").
        set DockedTime to time:seconds.
        when time:seconds > DockedTime + 12.5 then {
            sendMessage(Vessel(TargetOLM), "MechazillaHeight,0,2").
            sendMessage(Vessel(TargetOLM), "MechazillaArms,8,5,90,true").
            sendMessage(Vessel(TargetOLM), ("MechazillaPushers,0,1," + (12.5 * Scale) + ",true")).
            sendMessage(Vessel(TargetOLM), "MechazillaStabilizers,0").
            if ship:partstitled("Starship Orbital Launch Mount"):length > 0 {
                if ship:partstitled("Starship Orbital Launch Mount")[0]:getmodule("ModuleAnimateGeneric"):hasevent("open clamps + qd") {
                    ship:partstitled("Starship Orbital Launch Mount")[0]:getmodule("ModuleAnimateGeneric"):DoAction("toggle clamps + qd", true).
                }
            }
            when time:seconds > DockedTime + 39 then {
                set TowerReset to true.
                HUDTEXT("Booster recovery complete!", 10, 2, 20, green, false).
                //if BoosterCore:getmodule("ModuleSepPartSwitchAction"):getfield("current decouple system") = "Decoupler" {
                //BoosterCore:getmodule("ModuleSepPartSwitchAction"):DoAction("next decouple system", true).
                //}
                reboot.
            }
        }
    }
}


function ActivateGridFins {
    for fin in GridFins {
        if fin:hasmodule("ModuleControlSurface") {
            fin:getmodule("ModuleControlSurface"):DoAction("activate pitch controls", true).
            fin:getmodule("ModuleControlSurface"):DoAction("activate yaw control", true).
            fin:getmodule("ModuleControlSurface"):DoAction("activate roll control", true).
        }
        if fin:hasmodule("SyncModuleControlSurface") {
            fin:getmodule("SyncModuleControlSurface"):DoAction("activate pitch controls", true).
            fin:getmodule("SyncModuleControlSurface"):DoAction("activate yaw control", true).
            fin:getmodule("SyncModuleControlSurface"):DoAction("activate roll control", true).
        }
    }
}


function DeactivateGridFins {
    for fin in GridFins {
        if fin:hasmodule("ModuleControlSurface") {
            fin:getmodule("ModuleControlSurface"):DoAction("deactivate pitch control", true).
            fin:getmodule("ModuleControlSurface"):DoAction("deactivate yaw control", true).
            fin:getmodule("ModuleControlSurface"):DoAction("deactivate roll control", true).
        }
        if fin:hasmodule("SyncModuleControlSurface") {
            fin:getmodule("SyncModuleControlSurface"):DoAction("deactivate pitch control", true).
            fin:getmodule("SyncModuleControlSurface"):DoAction("deactivate yaw control", true).
            fin:getmodule("SyncModuleControlSurface"):DoAction("deactivate roll control", true).
        }
    }
}