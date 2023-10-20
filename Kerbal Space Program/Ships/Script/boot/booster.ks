set config:ipu to 500.
wait until ship:unpacked.

//if BoosterCore[0]:hasmodule("FARPartModule") {

set LogData to false.
set starship to false.
set ShipFound to false.
set LandSomewhereElse to false.
set idealVS to 0.
set LatCtrl to 0.
set LngCtrl to 0.
set LngError to 0.
set LatError to 0.
set ErrorVector to V(0, 0, 0).
set BoosterEngines to SHIP:PARTSNAMED("SEP.22.BOOSTER.CLUSTER.KOS").
set GridFins to SHIP:PARTSNAMED("SEP.22.BOOSTER.GRIDFIN.KOS").
set BoosterCore to SHIP:PARTSNAMED("SEP.22.BOOSTER.CORE.KOS").
set BoosterInter to SHIP:PARTSNAMED("SEP.22.BOOSTER.INTER.KOS").
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
lock RadarAlt to alt:radar - BoosterHeight.
set stopTime9 to 0.
set TimeStabilized to 0.
set LFBooster to 0.

set RSS to false.
set KSRSS to false.
set STOCK to false.
if bodyexists("Earth") {
    if body("Earth"):radius > 1600000 {
        set RSS to true.
        set Planet to "Earth".
        set LaunchSites to lexicon("KSC", "28.6084,-80.59975").
        set BoosterHeight to 71.04396.
        if BoosterCore[0]:hasmodule("FARPartModule") {
            set LngCtrlPID to PIDLOOP(0.005, 0.0025, 0.0025, -20, 20).
        }
        else {
            set LngCtrlPID to PIDLOOP(0.005, 0.0025, 0.0025, -20, 20).
        }
        set LatCtrlPID to PIDLOOP(0.02, 0.0025, 0.0025, -2, 2).
        set LFBoosterFuelCutOff to 3600.
        set LandHeadingVector to heading(270,0):vector.
        set BoosterLandingFactor to 0.9.
        set BoosterGlideDistance to 12000.
        set Scale to 1.6.
    }
    else {
        set KSRSS to true.
        set Planet to "Earth".
        set LaunchSites to lexicon("KSC", "28.5166,-81.2062").
        set BoosterHeight to 71.04396.
        if BoosterCore[0]:hasmodule("FARPartModule") {
            set LngCtrlPID to PIDLOOP(0.005, 0.0025, 0.0025, -20, 20).
        }
        else {
            set LngCtrlPID to PIDLOOP(0.005, 0.0025, 0.0025, -20, 20).
        }
        set LatCtrlPID to PIDLOOP(0.04, 0.0025, 0.0025, -2.5, 2.5).
        set LFBoosterFuelCutOff to 2400.
        set LandHeadingVector to heading(242,0):vector.
        set BoosterLandingFactor to 1.0.
        set BoosterGlideDistance to 4000.
        set Scale to 1.
    }
}
else {
    if body("Kerbin"):radius > 1000000 {
        set KSRSS to true.
        set Planet to "Kerbin".
        set LaunchSites to lexicon("KSC", "28.5166,-81.2062").
        set BoosterHeight to 71.04396.
        if BoosterCore[0]:hasmodule("FARPartModule") {
            set LngCtrlPID to PIDLOOP(0.005, 0.0025, 0.0025, -20, 20).
        }
        else {
            set LngCtrlPID to PIDLOOP(0.005, 0.0025, 0.0025, -20, 20).
        }
        set LatCtrlPID to PIDLOOP(0.04, 0.0025, 0.0025, -2.5, 2.5).
        set LFBoosterFuelCutOff to 2400.
        set LandHeadingVector to heading(242,0):vector.
        set BoosterLandingFactor to 1.0.
        set BoosterGlideDistance to 4000.
        set Scale to 1.
    }
    else {
        set STOCK to true.
        set Planet to "Kerbin".
        set LaunchSites to lexicon("KSC", "-0.0972,-74.5577", "Dessert", "-6.5604,-143.95", "Woomerang", "45.2896,136.11", "Baikerbanur", "20.6635,-146.4210").
        set BoosterHeight to 44.2.
        set LngCtrlPID to PIDLOOP(0.005, 0.0025, 0.0025, -20, 20).
        set LatCtrlPID to PIDLOOP(0.05, 0.0005, 0.0005, -2, 2).
        set LFBoosterFuelCutOff to 2200.
        set LandHeadingVector to heading(270,0):vector.
        set BoosterLandingFactor to 1.0.
        set BoosterGlideDistance to 5000.
        set Scale to 1.
    }
}

for res in BoosterCore[0]:resources {
    if res:name = "LqdMethane" {
        set LFBoosterFuelCutOff to LFBoosterFuelCutOff * 5.310536.
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
        if Part:name:contains("SEP.22.SHIP.BODY.KOS") {
            set ShipConnectedToBooster to true.
        }
    }
    wait 0.1.
    if ShipConnectedToBooster = "false" and BoostBackComplete = "false" and not (ship:status = "LANDED") and altitude > 10000 {
        Boostback(0).
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
}


function Boostback {
    parameter roll.

    wait until SHIP:PARTSNAMED("SEP.22.SHIP.BODY.KOS"):LENGTH = 0 and SHIP:PARTSNAMED("SEP.22.SHIP.BODY.EXP.KOS"):LENGTH = 0 and SHIP:PARTSNAMED("SEP.22.SHIP.DEPOT.KOS"):LENGTH = 0.
    set ship:name to "Booster".
    unlock steering.
    lock throttle to 1.
    sas off.
    set SteeringManager:ROLLCONTROLANGLERANGE to 10.
    wait 0.01.
    HUDTEXT("Performing Boostback Burn..", 30, 2, 20, green, false).
    clearscreen.
    print "Starting Boostback".
    set CurrentTime to time:seconds.
    set kuniverse:timewarp:warp to 0.
    set impactpos to ship:body:geopositionof(ship:position).

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
            if L:haskey("Ship Name") {
                until ShipFound {
                    set starship to L["Ship Name"].
                    list targets in tgtlist.
                    for tgt in tgtlist {
                        if (tgt:name) = (starship) {
                            set ShipFound to true.
                        }
                    }
                }
            }
        }
    }
    else {
        set landingzone to latlng(-000.0972,-074.5577).
    }

    for var in LaunchSites:keys {
        if RSS {
            if round(LaunchSites[var]:split(",")[0]:toscalar(9999), 3) = round(landingzone:lat, 3) and round(LaunchSites[var]:split(",")[1]:toscalar(9999), 3) = round(landingzone:lng, 3) {
                set TargetOLM to var + " OrbitalLaunchMount".
                break.
            }
        }
        else {
            if round(LaunchSites[var]:split(",")[0]:toscalar(9999), 2) = round(landingzone:lat, 2) and round(LaunchSites[var]:split(",")[1]:toscalar(9999), 2) = round(landingzone:lng, 2) {
                set TargetOLM to var + " OrbitalLaunchMount".
                break.
            }
        }
        list targets in OLMTargets.
        if OLMTargets:length > 0 {
            for x in OLMTargets {
                if x:name:contains("OrbitalLaunchMount") {
                    if round(body:geopositionof(x:position):lat, 2) = round(landingzone:lat, 2) and round(body:geopositionof(x:position):lng, 2) = round(landingzone:lng, 2) {
                        set TargetOLM to x:name.
                        break.
                    }
                }
            }
        }
        else {
            set TargetOLM to false.
        }
    }

    set ApproachUPVector to (landingzone:position - body:position):normalized.
    set ApproachVector to vxcl(up:vector, landingzone:position - ship:position):normalized.
    //set ApproachVectorDraw to vecdraw(v(0,0,0), 5 * ApproachVector, green, "ApproachVector", 20, true, 0.005, true, true).

    if RSS {
        SetLoadDistances(1750000).
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
    }

    until vang(facing:forevector, vxcl(up:vector, -ErrorVector)) < 15 or vang(facing:forevector, vxcl(up:vector, -ErrorVector)) < angularvel:y * 100 or verticalspeed < 0 {
        SteeringCorrections().
        if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
        SetBoosterActive().
        rcs on.
    }

    BoosterEngines[0]:getmodule("ModuleTundraEngineSwitch"):DOACTION("previous engine mode", true).
    if RSS {
        lock throttle to min(-(LngError + BoosterGlideDistance - 1000) / 20000 + 0.01, 7.5 * 9.81 / (ship:availablethrust / ship:mass)).
        lock SteeringVector to lookdirup(vxcl(up:vector, -ErrorVector), -up:vector).
        lock steering to SteeringVector.
    }
    else {
        lock throttle to min(-(LngError + BoosterGlideDistance - 1000) / 10000 + 0.01, 7.5 * 9.81 / (ship:availablethrust / ship:mass)).
        lock SteeringVector to lookdirup(vxcl(up:vector, -ErrorVector), -up:vector).
        lock steering to SteeringVector.
    }

    print "Available Thrust: " + round(ship:availablethrust) + "kN".
    wait 0.1.

    until ErrorVector:mag < BoosterGlideDistance + 5000 {
        SteeringCorrections().
        if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
        SetBoosterActive().
    }

    set CurrentVec to facing:forevector.
    lock SteeringVector to lookdirup(CurrentVec, ApproachVector:normalized - 0.5 * up:vector:normalized).
    lock steering to SteeringVector.

    until LngError > -BoosterGlideDistance {
        SteeringCorrections().
        if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
        SetBoosterActive().
    }
    unlock throttle.
    lock throttle to 0.
    set BoostBackComplete to true.
    set turnTime to time:seconds.
    HUDTEXT("Rotating Booster for re-entry and landing..", 20, 2, 20, green, false).

    CheckFuel().
    if LFBooster > LFBoosterFuelCutOff {
        BoosterCore[0]:activate.
    }

    set SteeringManager:maxstoppingtime to 5.
    lock SteeringVector to lookdirup(CurrentVec * AngleAxis(-6 * min(time:seconds - turnTime, 22.5), lookdirup(CurrentVec, up:vector):starvector), -up:vector).
    lock steering to SteeringVector.

    until time:seconds - turnTime > 15 {
        SteeringCorrections().
        SetBoosterActive().
        rcs on.
        CheckFuel().
    }

    lock SteeringVector to lookdirup(CurrentVec * AngleAxis(-6 * min(time:seconds - turnTime, 22.5), lookdirup(CurrentVec, up:vector):starvector), up:vector).
    lock steering to SteeringVector.

    until time:seconds - turnTime > 19 {
        SteeringCorrections().
        SetBoosterActive().
        rcs on.
        CheckFuel().
    }
    set SteeringManager:maxstoppingtime to 2.

    until time:seconds - turnTime > 30 {
        SteeringCorrections().
        SetBoosterActive().
        rcs on.
        CheckFuel().
    }

    set switchTime to time:seconds.
    until time:seconds > switchTime + 2.5 {
        SteeringCorrections().
        rcs on.
        SetBoosterActive().
        CheckFuel().
    }

    HUDTEXT("Starship will continue its orbit insertion..", 10, 2, 20, green, false).

    until time:seconds > switchTime + 5 {
        SteeringCorrections().
        rcs on.
        SetBoosterActive().
        CheckFuel().
    }

    //if not (STOCK) {
    //    BoosterInter[0]:getmodule("ModuleReactionWheel"):setfield("wheel authority", 0).
    //    BoosterCore[0]:getmodule("ModuleRCSFX"):SetField("thrust limiter", 0).
    //}
    //else {
        BoosterCore[0]:getmodule("ModuleRCSFX"):SetField("thrust limiter", 10).
    //}

    KUniverse:forceactive(vessel(starship)).

    until altitude < 30000 and not (RSS) or altitude < 50000 and RSS {
        SteeringCorrections().
        rcs on.
        CheckFuel().
        if abs(steeringmanager:angleerror) > 10 {
            SetBoosterActive().
            BoosterCore[0]:getmodule("ModuleRCSFX"):SetField("thrust limiter", 25).
        }
        else if abs(steeringmanager:angleerror) < 0.25 and KUniverse:activevessel = ship {
            if TimeStabilized = "0" {
                set TimeStabilized to time:seconds.
                SetBoosterActive().
            }
            if time:seconds - TimeStabilized > 5 {
                SetStarshipActive().
                BoosterCore[0]:getmodule("ModuleRCSFX"):SetField("thrust limiter", 10).
                set TimeStabilized to 0.
            }
        }
        else {
            set TimeStabilized to 0.
        }
        wait 0.1.
    }

    BoosterCore[0]:getmodule("ModuleRCSFX"):SetField("thrust limiter", 100).
    //BoosterInter[0]:getmodule("ModuleReactionWheel"):setfield("wheel authority", 100).
    lock SteeringVector to lookdirup(-velocity:surface * AngleAxis(-LngCtrl, lookdirup(-velocity:surface, up:vector):starvector) * AngleAxis(LatCtrl, up:vector), up:vector * AngleAxis(-2 * LatCtrl, ApproachVector)).
    lock steering to SteeringVector.

    if RSS {
        set BoosterMass to max(ship:mass, 238.3).
    }
    else if KSRSS {
        set BoosterMass to max(ship:mass, 139.2).
    }
    else {
        set BoosterMass to max(ship:mass, 123.3).
    }

    lock maxDecel to max((ship:availablethrust / ship:mass), 0.000001).
    if RSS {
        lock maxDecel3 to (6710 / BoosterMass) - 9.81.
    }
    else {
        lock maxDecel3 to (1900 / BoosterMass) - 9.81.
    }
    lock stopTime9 to (airspeed - 100) / min(maxDecel, 44).
    lock stopDist9 to ((airspeed + 100) / 2) * stopTime9.

    lock stopTime3 to min(100, airspeed) / min(maxDecel3, 5).
    lock stopDist3 to (min(100, airspeed) / 2) * stopTime3.

    lock TotalstopTime to stopTime9 + stopTime3.
    lock TotalstopDist to stopDist9 + stopDist3.
    lock landingRatio to TotalstopDist * cos(vang(-velocity:surface, up:vector)) / RadarAlt.

    when RSS and LngError > LngCtrlPID:setpoint - 500 or not (RSS) and LngError > LngCtrlPID:setpoint - 100 then {
        if RSS {
            set LngCtrlPID to PIDLOOP(0.025, 0.005, 0.005, -20, 20).
            when altitude < 5000 then {
                set LngCtrlPID:kp to 0.1.
            }
        }
        else {
            if BoosterCore[0]:hasmodule("FARPartModule") {
                set LngCtrlPID to PIDLOOP(0.1, 0.015, 0.015, -20, 20).
            }
            else {
                set LngCtrlPID to PIDLOOP(0.1, 0.015, 0.015, -20, 20).
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
        wait 0.001.
    }
    
    lock throttle to (landingRatio * min(maxDecel, 44 - 9.81)) / maxDecel.
    lock SteeringVector to lookdirup(-velocity:surface, ApproachVector).
    lock steering to SteeringVector.

    set LandingBurnAltitude to altitude.
    set LandingBurnStarted to true.
    HUDTEXT("Performing Landing Burn..", 3, 2, 20, green, false).

    if abs(LngError) > 600 or abs(LatError) > 150 {
        set LandSomewhereElse to true.
        lock RadarAlt to alt:radar - BoosterHeight.
        HUDTEXT("Mechazilla out of range..", 10, 2, 20, red, false).
        HUDTEXT("Landing somewhere else..", 10, 2, 20, red, false).
        lock SteeringVector to lookdirup(-1 * velocity:surface, ApproachVector).
        lock steering to SteeringVector.
    }

    when alt:radar < 1500 and not (LandSomewhereElse) then {
        if not (TargetOLM = "false") and Vessel(TargetOLM):distance < 2250 {
            if RSS {
                lock RadarAlt to alt:radar - ((Vessel(TargetOLM):PARTSNAMED("SLE.SS.OLIT.MZ.KOS")[0]:position - Body(Planet):position):mag - SHIP:BODY:RADIUS - Vessel(TargetOLM):geoposition:terrainheight) - 3.64.
            }
            else {
                lock RadarAlt to alt:radar - ((Vessel(TargetOLM):PARTSNAMED("SLE.SS.OLIT.MZ.KOS")[0]:position - Body(Planet):position):mag - SHIP:BODY:RADIUS - Vessel(TargetOLM):geoposition:terrainheight).
            }
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

    if BoosterCore[0]:hasmodule("FARPartModule") {
        set MaxError to 100.
    }
    else {
        set MaxError to 80.
    }

    when verticalspeed > -100 and (stopDist3 / RadarAlt) < 1 and LngError < MaxError or verticalspeed > -50 or RadarAlt < 500 then {
        BoosterEngines[0]:getmodule("ModuleTundraEngineSwitch"):DOACTION("next engine mode", true).
        lock maxDecel to max((ship:availablethrust / ship:mass), 0.000001).
        lock TotalstopTime to airspeed / min(maxDecel - 9.81, 5).
        lock TotalstopDist to (airspeed / 2) * TotalstopTime.
        lock landingRatio to TotalstopDist / RadarAlt.
        lock throttle to (landingRatio * min(maxDecel, 5 + 9.81)) / maxDecel.
        if LngError > 250 or LngError < -50 or abs(LatError) > 25 {
            lock RadarAlt to alt:radar - BoosterHeight.
            set LandSomewhereElse to true.
            HUDTEXT("Mechazilla out of range..", 10, 2, 20, red, false).
            HUDTEXT("Landing somewhere else..", 10, 2, 20, red, false).
            lock SteeringVector to lookdirup(-1 * velocity:surface, ApproachVector).
            lock steering to SteeringVector.
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
                        lock SteeringVector to lookdirup(up:vector - 0.03 * velocity:surface - 0.035 * ErrorVector, LandHeadingVector).
                    }
                    else {
                        lock SteeringVector to lookdirup(up:vector - 0.03 * velocity:surface - 0.04 * ErrorVector, LandHeadingVector).
                    }
                    lock steering to SteeringVector.
                }
                when abs(LngError) < 10 and abs(LatError) < 10 and vxcl(up:vector, ship:position - landingzone:position):mag < 20 and not RSS or abs(LngError) < 20 and abs(LatError) < 20 and vxcl(up:vector, ship:position - landingzone:position):mag < 50 and RSS then {
                    if RSS {
                        lock SteeringVector to lookdirup(up:vector - 0.015 * velocity:surface - 0.0025 * ErrorVector, LandHeadingVector).
                    }
                    else if KSRSS {
                        lock SteeringVector to lookdirup(up:vector - 0.03 * velocity:surface - 0.01 * ErrorVector, LandHeadingVector).
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
                        lock SteeringVector to lookdirup(up:vector - 0.0175 * velocity:surface, LandHeadingVector).
                    }
                    lock steering to SteeringVector.
                    if abs(LngError) > 10 and not (RSS) or abs(LatError) > 10 and not (RSS) or abs(LngError) > 20 and RSS or abs(LatError) > 20 and RSS {
                        lock RadarAlt to alt:radar - BoosterHeight.
                        set LandSomewhereElse to true.
                        lock SteeringVector to lookdirup(-1 * velocity:surface, ApproachVector).
                        lock steering to SteeringVector.
                        HUDTEXT("Mechazilla out of range..", 10, 2, 20, red, false).
                        HUDTEXT("Landing somewhere else..", 10, 2, 20, red, false).
                    }
                }
            }
        }
    }


    until verticalspeed > -0.01 and RadarAlt < 1.5 and ship:status = "LANDED" or verticalspeed > 0.75 and RadarAlt < 2.5 {
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
        wait 0.001.
    }

    set ship:control:translation to v(0, 0, 0).
    unlock steering.
    lock throttle to 0.
    rcs off.
    clearscreen.
    print "Booster Landed!".
    wait 0.01.
    BoosterEngines[0]:shutdown.

    if not (LandSomewhereElse) and not (RSS) {
        print "capture at: " + RadarAlt + "m RA".
        print "Landing Burn started at: " + round(LandingBurnAltitude) + "m Altitude".
        if not (TargetOLM = "false") {
            //HUDTEXT("Booster Landing Confirmed! Stand by for Mechazilla Operation..", 10, 2, 20, green, false).
            HUDTEXT("Booster Landing Confirmed! Stand by for Booster Securing..", 10, 2, 20, green, false).
            set LandingTime to time:seconds.
            lock RollAngle to vang(facing:starvector, AngleAxis(-90, up:vector) * LandHeadingVector).
            set TowerReset to false.
            set PusherSpeed5 to false.
            set PusherSpeed2 to false.
            set PusherSpeed1 to false.
            set RollAngleExceeded to false.
            set BoosterSecured to false.
            set BoosterBroughtDown to false.
            set MechazillaGoesUp to false.
            set MechazillaResetsItself to false.
            print "Tower Operation in Progress..".
            sendMessage(Vessel(TargetOLM), "MechazillaPushers,0,1,0.3,false").
            sendMessage(Vessel(TargetOLM), ("MechazillaStabilizers," + maxstabengage)).
            until TowerReset {
                clearscreen.
                print "Roll Angle: " + round(RollAngle,1).
                //set RollVectorDraw to vecdraw(v(0, 0, 0), 2.5 * facing:starvector, green, "Roll Vector", 20, true, 0.005, true, true).
                //set LdgHdgDraw to vecdraw(v(0, 0, 0), 2.5 * LandHeadingVector, blue, "Landing Heading Vector", 20, true, 0.005, true, true).
                if time:seconds > LandingTime + 3.25 * Scale and not PusherSpeed5 {
                    sendMessage(Vessel(TargetOLM), ("MechazillaPushers,0,0.5," + (0.3 * Scale) + ",false")).
                    set PusherSpeed5 to true.
                }
                if time:seconds > LandingTime + 5.75 * Scale and not PusherSpeed2 {
                    sendMessage(Vessel(TargetOLM), ("MechazillaPushers,0,0.3," + (0.3 * Scale) + ",false")).
                    set PusherSpeed2 to true.
                }
                if time:seconds > LandingTime + 8.25 * Scale and not PusherSpeed1 {
                    sendMessage(Vessel(TargetOLM), ("MechazillaPushers,0,0.1," + (0.3 * Scale) + ",false")).
                    set PusherSpeed1 to true.
                }
                if time:seconds > LandingTime + 15 * Scale and time:seconds < LandingTime + 75 * Scale and not BoosterSecured {
                    //sendMessage(Vessel(TargetOLM), "MechazillaHeight,28,0.5").
                    set TowerReset to true.
                }
    //            if time:seconds > LandingTime + 75 and not BoosterSecured {
    //                sendMessage(Vessel(TargetOLM), "MechazillaHeight,42,0.5").
    //                set BoosterSecured to true.
    //            }
    //            if time:seconds > LandingTime + 105 and not BoosterBroughtDown {
    //                sendMessage(Vessel(TargetOLM), "MechazillaArms,8,2.5,60,true").
    //                set BoosterBroughtDown to true.
    //            }
    //            if time:seconds > LandingTime + 114 and not MechazillaGoesUp {
    //                sendMessage(Vessel(TargetOLM), "MechazillaHeight,0,2").
    //                set MechazillaGoesUp to true.
    //            }
    //            if time:seconds > LandingTime + 117 and not MechazillaResetsItself {
    //                sendMessage(Vessel(TargetOLM), "MechazillaArms,8,5,90,true").
    //                if RSS {
    //                    sendMessage(Vessel(TargetOLM), "MechazillaPushers,0,0.3,20,true").
    //                }
    //                else {
    //                    sendMessage(Vessel(TargetOLM), "MechazillaPushers,0,0.3,12.5,true").
    //                }
    //                sendMessage(Vessel(TargetOLM), "MechazillaStabilizers,0").
    //                set MechazillaResetsItself to true.
    //            }
    //            if time:seconds > LandingTime + 135 {
    //                set TowerReset to true.
    //                break.
    //            }
                if RollAngle > 30 or RollAngle < -30 {
                    set RollAngleExceeded to true.
                    break.
                }
            }
            if not RollAngleExceeded {
                // print "Booster has been secured & Tower has been reset!".
                // HUDTEXT("Tower has been reset, Booster may now be recovered!", 10, 2, 20, green, false).
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
        print "Booster has touched down".
        HUDTEXT("Booster may now be recovered!", 10, 2, 20, green, false).
    }
    unlock throttle.

    if RSS {
        wait 2.
        HUDTEXT("Changing focus back to Starship..", 20, 2, 20, green, false).
        SetLoadDistances("default").
        wait 3.
        when ship:status = "LANDED" then {
            SetStarshipActive().
        }
    }
    else {
        SetLoadDistances("default").
        HUDTEXT("Booster may now be recovered!", 10, 2, 20, green, false).
    }
    wait 0.001.
    if BoosterInter[0]:getmodule("ModuleSepPartSwitchAction"):getfield("current decouple system") = "Decoupler" {
        BoosterInter[0]:getmodule("ModuleSepPartSwitchAction"):DoAction("next decouple system", true).
    }
    wait 0.001.
}



FUNCTION SteeringCorrections {
    set ShipExists to false.
    list targets in tgtlist.
    for tgt in tgtlist {
        if tgt:name = (starship) {
            set ShipExists to true.
        }
    }
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
        wait 0.001.

        if addons:tr:hasimpact {
            set ErrorVector to ADDONS:TR:IMPACTPOS:POSITION - landingzone:POSITION.
            set impactpos to ship:body:geopositionof(ADDONS:TR:IMPACTPOS:POSITION).
        }
        set LatError to vdot(AngleAxis(-90, ApproachUPVector) * ApproachVector, ErrorVector).
        set LngError to vdot(ApproachVector, ErrorVector).

        //set ApproachVectorDraw to vecdraw(v(0,0,0), 5 * ApproachVector, green, "ApproachVector", 20, true, 0.005, true, true).
        //set TopVectorDraw to vecdraw(v(0,0,0), 5 * facing:topvector, blue, "TopVector", 20, true, 0.005, true, true).
        //set SteeringTopVectorDraw to vecdraw(v(0,0,0), 5 * SteeringVector:topvector, cyan, "TopVector", 20, true, 0.005, true, true).

        if altitude < 30000 or KUniverse:activevessel = vessel(ship:name) {
            set GS to groundspeed.

            if InitialError = -9999 and addons:tr:hasimpact {
                set InitialError to LngError.
            }

            if altitude > 4000 {
                set LngCtrlPID:setpoint to min(750, 0.5 * vdot(ApproachVector, vxcl(up:vector, landingzone:position - ship:position))).
            }
            else {
                set LngCtrlPID:setpoint to 2 * BoosterLandingFactor * GS.
            }

            set LngCtrl to -LngCtrlPID:UPDATE(time:seconds, LngError).
            set LatCtrl to -LatCtrlPID:UPDATE(time:seconds, LatError).
            if LngCtrl > 0 {
                set LatCtrl to -LatCtrl.
            }

            if alt:radar < 1500 {
                set magnitude to (altitude + 400) / 100.
                if ErrorVector:mag > magnitude and LandingBurnStarted {
                    set ErrorVector to ErrorVector:normalized * magnitude.
                }
            }
        }

        clearscreen.
        //if not LandSomewhereElse {
        //    print "Landing parameters OK".
        //}
        //else {
        //    print "Landing somewhere else..".
        //}
        print "Dynamic Pressure: " + round(100 * ship:q,1) + "kPa".
        print "Lng Error: " + round(LngError).
        print "Lat Error: " + round(LatError).
        print "Radar Altitude: " + round(RadarAlt).
        if ShipExists {
            print "Ship Distance: " + (round(vessel(starship):distance) / 1000) + "km".
        }
        //print " ".
        //print "ErrorVector: " + ErrorVector.
        //print "ApproachVector: " + ApproachVector.
        print " ".

        if addons:tr:hasimpact {
            //print "Total Error: " + round((ADDONS:TR:IMPACTPOS:POSITION - landingzone:POSITION):mag).
            //print "Ship Loaded: " + vessel(starship):loaded.
            //print "Ship Unpacked: " + vessel(starship):unpacked.
            print " ".
            //print "Ship Flying Load Distances: " + vessel(starship):loaddistance:flying:unpack + ", " + vessel(starship):loaddistance:flying:pack + ", " + vessel(starship):loaddistance:flying:unload + ", " + vessel(starship):loaddistance:flying:load.
            //print "Default Flying Load Distances: " + kuniverse:defaultloaddistance:flying:unpack + ", " + kuniverse:defaultloaddistance:flying:pack + ", " + kuniverse:defaultloaddistance:flying:unload + ", " + kuniverse:defaultloaddistance:flying:load.
            //print "Ship Parts Nr: " + vessel(starship):parts:length.
            //print "Impact Pos: " + round(ship:body:geopositionof(ADDONS:TR:IMPACTPOS:POSITION):lat, 4) + "," + round(ship:body:geopositionof(ADDONS:TR:IMPACTPOS:POSITION):lng, 4).
        }


        if altitude < 15000 and not (RSS) or altitude < 50000 and RSS {
            print "LngCtrl: " + round(LngCtrl, 2).
            print "LatCtrl: " + round(LatCtrl, 2).
            print " ".

            print "setpoint: " + round(LngCtrlPID:setpoint).
            print "GS: " + round(GS).
            print " ".
            print "Max Decel: " + round(maxDecel, 2).
            print "Radar Alt: " + round(RadarAlt).
            print "Stop Time: " + round(TotalstopTime, 2).
            print "Stop Distance: " + round(TotalstopDist, 2).
            print "Stop Distance 3: " + round(stopDist3, 2).
            print "Landing Ratio: " + round(landingRatio, 2).
        }
        wait 0.001.
    }
    else {
        clearscreen.
        print "Booster: Coasting back to LZ..".
        print " ".
        print "Radar Altitude: " + round(RadarAlt).
        if ShipExists {
            print "Ship Distance: " + (round(vessel(starship):distance) / 1000) + "km".
        }
    }
    print "Steering Pitch  Error: " + round(SteeringManager:pitcherror, 2).
    print "Steering Yaw    Error: " + round(SteeringManager:yawerror, 2).
    print "Steering Roll   Error: " + round(SteeringManager:rollerror, 2).
    if not (LFBooster = 0) {
        print "LF on Board: " + round(LFBooster).
    }
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
    if KUniverse:activevessel = vessel(ship:name) and time:seconds > lastVesselChange + 2 {
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
    for res in BoosterCore[0]:resources {
        if res:name = "LiquidFuel" {
            set LFBooster to res:amount.
            if LFBooster < LFBoosterFuelCutOff {
                BoosterCore[0]:shutdown.
            }
        }
        if res:name = "LqdMethane" {
            set LFBooster to res:amount.
            if LFBooster < LFBoosterFuelCutOff {
                BoosterCore[0]:shutdown.
            }
        }
    }
}