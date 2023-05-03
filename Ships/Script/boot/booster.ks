set config:ipu to 500.
wait until ship:unpacked.



if ship:body:radius > 600001 and ship:body:atm:sealevelpressure > 0.6 {
    set RSS to true.
    set Planet to "Earth".
    set LaunchSites to lexicon("KSC", "28.6084,-80.59975").
    set BoosterHeight to 71.04396.
    set LngCtrlPID to PIDLOOP(0.0025, 0.01, 0.01, -30, 30).
    set LatCtrlPID to PIDLOOP(0.05, 0.0005, 0.0005, -2, 2).
    set LFBoosterFuelCutOff to 2000.
}
else {
    set RSS to false.
    set Planet to "Kerbin".
    set LaunchSites to lexicon("KSC", "-0.0972,-74.5577", "Dessert", "-6.5604,-143.95", "Woomerang", "45.2896,136.11", "Baikerbanur", "20.6635,-146.4210").
    set BoosterHeight to 44.2.
    set LngCtrlPID to PIDLOOP(0.0025, 0.0005, 0.0005, -30, 30).
    set LatCtrlPID to PIDLOOP(0.05, 0.0005, 0.0005, -2, 2).
    set LFBoosterFuelCutOff to 1500.
}
set LogData to false.

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

    set ship:name to "Booster".
    unlock throttle.
    wait 0.001.
    lock throttle to 0.
    unlock steering.
    lock throttle to 0.
    sas off.

    //set SteeringManager:ROLLTS to 1.
    //set SteeringManager:YAWTS to 0.33.
    //set SteeringManager:PITCHTS to 0.33.
    //set SteeringManager:maxstoppingtime to 2.5.
    //set steeringmanager:rolltorquefactor to 100.
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
                    for var in LaunchSites:keys {
                        if round(LaunchSites[var]:split(",")[0]:toscalar(9999), 2) = round(L["Launch Coordinates"]:split(",")[0]:toscalar(28.6084), 2) and round(LaunchSites[var]:split(",")[1]:toscalar(9999), 2) = round(L["Launch Coordinates"]:split(",")[1]:toscalar(-80.5998), 2) {
                            set OLM to var + " OrbitalLaunchMount".
                            break.
                        }
                        set OLM to "OrbitalLaunchMount".
                    }
                }
                else {
                    set landingzone to latlng(L["Launch Coordinates"]:split(",")[0]:toscalar(-000.0972), L["Launch Coordinates"]:split(",")[1]:toscalar(-074.5577)).
                    for var in LaunchSites:keys {
                        if round(LaunchSites[var]:split(",")[0]:toscalar(9999), 2) = round(L["Launch Coordinates"]:split(",")[0]:toscalar(-000.0972), 2) and round(LaunchSites[var]:split(",")[1]:toscalar(9999), 2) = round(L["Launch Coordinates"]:split(",")[1]:toscalar(-074.5577), 2) {
                            set OLM to var + " OrbitalLaunchMount".
                            break.
                        }
                        set OLM to "OrbitalLaunchMount".
                    }
                }
            }
            else {
                set landingzone to latlng(-000.0972,-074.5577).
            }
            if L:haskey("Ship Name") {
                wait 0.5.
                set starship to L["Ship Name"].
            }
        }
    }
    else {
        set landingzone to latlng(-000.0972,-074.5577).
    }

    set ApproachUPVector to (landingzone:position - body:position):normalized.
    set ApproachVector to vxcl(up:vector, landingzone:position - ship:position):normalized.
    //set ApproachVectorDraw to vecdraw(v(0,0,0), 5 * ApproachVector, green, "ApproachVector", 20, true, 0.005, true, true).

    if RSS {
        SetLoadDistances(1500000).
    }
    else {
        SetLoadDistances(300000).
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

    until vang(facing:forevector, vxcl(up:vector, -ErrorVector)) < 35 or vang(facing:forevector, vxcl(up:vector, -ErrorVector)) < angularvel:y * 100 or verticalspeed < 0 {
        SteeringCorrections().
        if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
        SetBoosterActive().
        rcs on.
    }

    if RSS {
        lock throttle to min(-(LngError + 7500) / 20000 + 0.01, 7.5 * 9.81 / (ship:availablethrust / ship:mass)).
        lock SteeringVector to lookdirup(vxcl(up:vector, -ErrorVector), -up:vector).
        lock steering to SteeringVector.
    }
    else {
        lock throttle to min(-(LngError + 7500) / 10000 + 0.01, 7.5 * 9.81 / (ship:availablethrust / ship:mass)).
        lock SteeringVector to lookdirup(vxcl(up:vector, -ErrorVector), -up:vector).
        lock steering to SteeringVector.
    }

    print "Available Thrust: " + round(ship:availablethrust) + "kN".
    wait 0.1.

    until ErrorVector:mag < 15000 {
        SteeringCorrections().
        if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
        SetBoosterActive().
    }

    set CurrentVec to facing:forevector.
    lock SteeringVector to lookdirup(CurrentVec, ApproachVector:normalized - 0.5 * up:vector:normalized).
    lock steering to SteeringVector.

    until LngError > -10000 {
        SteeringCorrections().
        if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
        SetBoosterActive().
    }
    unlock throttle.
    lock throttle to 0.
    set BoostBackComplete to true.
    set turnTime to time:seconds.

    CheckFuel().
    if LFBooster > LFBoosterFuelCutOff {
        BoosterCore[0]:activate.
        when LFBooster < LFBoosterFuelCutOff then {
            BoosterCore[0]:shutdown.
        }
    }

    lock SteeringVector to lookdirup(CurrentVec * AngleAxis(-9 * min(time:seconds - turnTime, 15), lookdirup(CurrentVec, up:vector):starvector), -up:vector).
    lock steering to SteeringVector.

    until time:seconds - turnTime > 10 {
        SteeringCorrections().
        SetBoosterActive().
        rcs on.
        CheckFuel().
    }

    lock SteeringVector to lookdirup(CurrentVec * AngleAxis(-9 * min(time:seconds - turnTime, 15), lookdirup(CurrentVec, up:vector):starvector), up:vector).
    lock steering to SteeringVector.

    until time:seconds - turnTime > 20 {
        SteeringCorrections().
        SetBoosterActive().
        rcs on.
        CheckFuel().
    }

    if LngError > -1000 and KUniverse:activevessel = ship {
        until LngError < -1000 {
            SteeringCorrections().
            SetBoosterActive().
            rcs on.
            if LngError > -1000 {
                set ship:control:translation to v(0, 0, 1).
            }
            else {
                set ship:control:translation to v(0, 0, 0).
            }
        }
    }
    set ship:control:translation to v(0, 0, 0).

    wait 5.
    BoosterCore[0]:getmodule("ModuleRCSFX"):SetField("thrust limiter", 25).
    HUDTEXT("Starship will continue its orbit insertion..", 20, 2, 20, green, false).
    wait 1.



    until altitude < 30000 and not (RSS) or altitude < 50000 and RSS {
        SteeringCorrections().
        rcs on.
        SetStarshipActive().
        CheckFuel().
    }

    BoosterCore[0]:getmodule("ModuleRCSFX"):SetField("thrust limiter", 100).
    lock SteeringVector to lookdirup(-velocity:surface * AngleAxis(-LngCtrl, lookdirup(-velocity:surface, up:vector):starvector) * AngleAxis(LatCtrl, up:vector), up:vector * AngleAxis(-2 * LatCtrl, ApproachVector)).
    lock steering to SteeringVector.

    lock maxDecel to max((ship:availablethrust / ship:mass) - 9.81, 0.000001).
    if RSS {
        lock maxDecel3 to (6710 / ship:mass) - 9.81.
    }
    else {
        lock maxDecel3 to (1900 / ship:mass) - 9.81.
    }
    lock stopTime9 to (abs(verticalspeed) - 100) / min(maxDecel, 34).
    lock stopDist9 to (abs(verticalspeed) / 2) * stopTime9.

    lock stopTime3 to min(100, abs(verticalspeed)) / min(maxDecel3, 5).
    lock stopDist3 to (min(100, abs(verticalspeed)) / 2) * stopTime3.

    lock TotalstopTime to stopTime9 + stopTime3.
    lock TotalstopDist to stopDist9 + stopDist3.
    lock landingRatio to TotalstopDist / RadarAlt.

    when altitude < 20000 and RSS then {
        set LngCtrlPID to PIDLOOP(0.0025, 0.01, 0.01, -15, 15).
    }

    when LngError > LngCtrlPID:setpoint then {
        if RSS {
            set LngCtrlPID to PIDLOOP(0.05, 0.005, 0.005, -10, 7.5).
        }
        else {
            set LngCtrlPID to PIDLOOP(0.05, 0.005, 0.005, -10, 7.5).
        }
        unlock steering.
        lock steering to SteeringVector.
    }


    until landingRatio > 1 and alt:radar < 3000 or alt:radar < 1650 {
        SteeringCorrections().
        if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
        rcs on.
        SetBoosterActive().
        CheckFuel().
    }
    
    HUDTEXT("Performing Landing Burn..", 3, 2, 20, green, false).
    lock throttle to (landingRatio * min(maxDecel, 34)) / maxDecel.
    lock SteeringVector to lookdirup(up:vector - 0.03 * velocity:surface, ApproachVector).
    lock steering to SteeringVector.

    set LandingBurnAltitude to altitude.
    set LandingBurnStarted to true.

    if abs(LngError) > 600 or abs(LatError) > 150 {
        set LandSomewhereElse to true.
        HUDTEXT("Mechazilla out of range..", 10, 2, 20, red, false).
        HUDTEXT("Landing somewhere else..", 10, 2, 20, red, false).
        lock SteeringVector to lookdirup(-1 * velocity:surface, ApproachVector).
        lock steering to SteeringVector.
    }

    when alt:radar < 2000 and not (LandSomewhereElse) then {
        if OLMexists() and Vessel(OLM):distance < 2250 {
            if RSS {
                lock RadarAlt to alt:radar - ((Vessel(OLM):PARTSNAMED("SLE.SS.OLIT.MZ.KOS")[0]:position - Body(Planet):position):mag - SHIP:BODY:RADIUS - Vessel(OLM):geoposition:terrainheight) - 3.64.
            }
            else {
                lock RadarAlt to alt:radar - ((Vessel(OLM):PARTSNAMED("SLE.SS.OLIT.MZ.KOS")[0]:position - Body(Planet):position):mag - SHIP:BODY:RADIUS - Vessel(OLM):geoposition:terrainheight).
            }
            when RadarAlt < 5 * BoosterHeight then {
                sendMessage(Vessel(OLM), "MechazillaArms,8,6,60,true").
                sendMessage(Vessel(OLM), "MechazillaStabilizers,0").
                when RadarAlt < BoosterHeight then {
                    set TimeToZero to -verticalspeed / maxDecel.
                    set ArmIdealSpeed to 30 / TimeToZero.
                    sendMessage(Vessel(OLM), ("MechazillaArms,8," + ArmIdealSpeed + ",60,false")).
                }
            }
        }
    }

    when verticalspeed > -100 and (stopDist3 / RadarAlt) < 1 then {
        BoosterEngines[0]:getmodule("ModuleTundraEngineSwitch"):DOACTION("next engine mode", true).
        lock TotalstopTime to abs(verticalspeed) / min(maxDecel, 5).
        lock TotalstopDist to (abs(verticalspeed) / 2) * TotalstopTime.
        lock landingRatio to TotalstopDist / RadarAlt.
        lock throttle to (landingRatio * min(maxDecel, 5)) / maxDecel.
        if abs(LngError) > 200 or abs(LatError) > 100 {
            lock RadarAlt to alt:radar - BoosterHeight.
            set LandSomewhereElse to true.
            HUDTEXT("Mechazilla out of range..", 10, 2, 20, red, false).
            HUDTEXT("Landing somewhere else..", 10, 2, 20, red, false).
            lock SteeringVector to lookdirup(-1 * velocity:surface, ApproachVector).
            lock steering to SteeringVector.
        }
        else {
            lock SteeringVector to lookdirup(up:vector - 0.03 * velocity:surface, ApproachVector).
            lock steering to SteeringVector.
            when verticalspeed > -80 then {
                lock SteeringVector to lookdirup(up:vector - 0.03 * velocity:surface - 0.02 * ErrorVector, heading(270,0):vector).
                lock steering to SteeringVector.
                when verticalspeed > -25 then {
                    lock SteeringVector to lookdirup(up:vector - 0.02 * velocity:surface, heading(270,0):vector).
                    lock steering to SteeringVector.
                    if abs(LngError) > 20 or abs(LatError) > 10 {
                        lock RadarAlt to alt:radar - BoosterHeight.
                        set LandSomewhereElse to true.
                        HUDTEXT("Mechazilla out of range..", 10, 2, 20, red, false).
                        HUDTEXT("Landing somewhere else..", 10, 2, 20, red, false).
                    }
                }
            }
        }

    }


    until verticalspeed > -0.01 and RadarAlt < 5 and ship:status = "LANDED" or verticalspeed > 0.5 {
        SteeringCorrections().
        if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
        rcs on.
        SetBoosterActive().
        CheckFuel().
    }

    set ship:control:translation to v(0, 0, 0).
    unlock steering.
    lock throttle to 0.
    rcs off.
    clearscreen.
    print "Booster Landed!".
    wait 0.001.
    unlock throttle.
    BoosterEngines[0]:shutdown.
    SetLoadDistances("default").

    if not (LandSomewhereElse) and not (RSS) {
        print "capture at: " + RadarAlt + "m RA".

        print "Landing Burn started at: " + round(LandingBurnAltitude) + "m Altitude".

        if OLMexists() {
            HUDTEXT("Booster Landing Confirmed! Stand by for Mechazilla Operation..", 10, 2, 20, green, false).
            set LandingTime to time:seconds.
            lock RollAngle to vang(facing:starvector, heading(180,0):vector).
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
            sendMessage(Vessel(OLM), "MechazillaPushers,0,1,0.3,false").
            sendMessage(Vessel(OLM), ("MechazillaStabilizers," + maxstabengage)).
            until TowerReset {
                clearscreen.
                print "Roll Angle: " + round(RollAngle,1).
                if time:seconds > LandingTime + 3.25 and not PusherSpeed5 {
                    sendMessage(Vessel(OLM), "MechazillaPushers,0,0.5,0.3,false").
                    set PusherSpeed5 to true.
                }
                if time:seconds > LandingTime + 5.75 and not PusherSpeed2 {
                    sendMessage(Vessel(OLM), "MechazillaPushers,0,0.3,0.3,false").
                    set PusherSpeed2 to true.
                }
                if time:seconds > LandingTime + 8.25 and not PusherSpeed1 {
                    sendMessage(Vessel(OLM), "MechazillaPushers,0,0.1,0.3,false").
                    set PusherSpeed1 to true.
                }
                if time:seconds > LandingTime + 15 and time:seconds < LandingTime + 75 and not BoosterSecured {
                    sendMessage(Vessel(OLM), "MechazillaHeight,28,0.5").
                }
                if time:seconds > LandingTime + 75 and not BoosterSecured {
                    sendMessage(Vessel(OLM), "MechazillaHeight,42,0.5").
                    set BoosterSecured to true.
                }
                if time:seconds > LandingTime + 105 and not BoosterBroughtDown {
                    sendMessage(Vessel(OLM), "MechazillaArms,8,2.5,60,true").
                    set BoosterBroughtDown to true.
                }
                if time:seconds > LandingTime + 114 and not MechazillaGoesUp {
                    sendMessage(Vessel(OLM), "MechazillaHeight,0,2").
                    set MechazillaGoesUp to true.
                }
                if time:seconds > LandingTime + 117 and not MechazillaResetsItself {
                    sendMessage(Vessel(OLM), "MechazillaArms,8,5,90,true").
                    if RSS {
                        sendMessage(Vessel(OLM), "MechazillaPushers,0,0.3,20,true").
                    }
                    else {
                        sendMessage(Vessel(OLM), "MechazillaPushers,0,0.3,12.5,true").
                    }
                    sendMessage(Vessel(OLM), "MechazillaStabilizers,0").
                    set MechazillaResetsItself to true.
                }
                if time:seconds > LandingTime + 135 {
                    set TowerReset to true.
                    break.
                }
                if RollAngle > 15 or RollAngle < -15 {
                    set RollAngleExceeded to true.
                    break.
                }
            }
            if not RollAngleExceeded {
                print "Booster has been secured & Tower has been reset!".
                HUDTEXT("Tower has been reset, Booster may now be recovered!", 10, 2, 20, green, false).
            }
            else {
                sendMessage(Vessel(OLM), "EmergencyStop").
                print "Emergency Stop Activated! Roll Angle exceeded: " + round(RollAngle, 1).
                print "Continue manually with great care..".
            }
        }
        else {
            print "Booster has been secured".
            HUDTEXT("Booster may now be recovered!", 10, 2, 20, green, false).
        }
    }
    unlock throttle.

    if RSS {
        wait 5.
        SetStarshipActive().
    }
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

            if altitude > 5500 and not (RSS) or altitude > 5500 and RSS {
                if RSS {
                    set LngCtrlPID:setpoint to 1000.
                }
                else {
                    set LngCtrlPID:setpoint to 1000.
                }
            }
            else if RSS {
                set LngCtrlPID:setpoint to 1 * GS.
            }
            else {
                set LngCtrlPID:setpoint to 1.375 * GS.
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
        print "Ship Distance: " + (round(vessel(starship):distance) / 1000) + "km".
        print " ".
        //print "Steering Target: " + steeringmanager:target.
        //print "Steering Direction: " + facing:forevector.
        print "Steering Roll   Error: " + round(SteeringManager:rollerror, 2).
        print "Steering Total  Error: " + round(SteeringManager:angleerror, 2).

        if addons:tr:hasimpact {
            print "Total Error: " + round((ADDONS:TR:IMPACTPOS:POSITION - landingzone:POSITION):mag).
            //print "Ship Loaded: " + vessel(starship):loaded.
            //print "Ship Unpacked: " + vessel(starship):unpacked.
            //print " ".
            //print "Ship Flying Load Distances: " + vessel(starship):loaddistance:flying:unpack + ", " + vessel(starship):loaddistance:flying:pack + ", " + vessel(starship):loaddistance:flying:unload + ", " + vessel(starship):loaddistance:flying:load.
            //print "Default Flying Load Distances: " + kuniverse:defaultloaddistance:flying:unpack + ", " + kuniverse:defaultloaddistance:flying:pack + ", " + kuniverse:defaultloaddistance:flying:unload + ", " + kuniverse:defaultloaddistance:flying:load.
            //print "Ship Parts Nr: " + vessel(starship):parts:length.
        }


        if altitude < 15000 and not (RSS) or altitude < 50000 and RSS {
            print "LngCtrl: " + round(LngCtrl, 2).
            print "LatCtrl: " + round(LatCtrl, 2).
            print " ".
            print "GS: " + round(GS).
            print "setpoint: " + round(LngCtrlPID:setpoint).
            print " ".
            print "Max Decel: " + round(maxDecel, 2).
            print "Radar Alt: " + round(RadarAlt).
            print "Stop Time: " + round(TotalstopTime, 2).
            print "Stop Distance: " + round(TotalstopDist, 2).
            print "Stop Distance 3: " + round(stopDist3, 2).
            print "throttle required: " + round(landingRatio, 2).
        }
        wait 0.001.
    }
    else {
        clearscreen.
        print "State: Booster coasting back to Launch Site..".
        print "Radar Altitude: " + round(RadarAlt).
        print "Ship Distance: " + (round(vessel(starship):distance) / 1000) + "km".
        //print "Steering Target: " + steeringmanager:target.
        //print "Steering Direction: " + facing:forevector.
        print "Steering Roll   Error: " + round(SteeringManager:rollerror, 2).
        print "Steering Total  Error: " + round(SteeringManager:angleerror, 2).
    }
    LogBoosterFlightData().
}


function LogBoosterFlightData {
    if LogData {
        if homeconnection:isconnected {
            if defined PrevLogTime {
                set TimeStep to 1.
                if timestamp(time:seconds) > PrevLogTime + TimeStep {
                    set DistanceToTarget to ((landingzone:lng - ship:geoposition:lng) * (ship:body:radius / 1000 * 2 * constant:pi) / 360).
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


function OLMexists {
    list targets in shiplist.
    if shiplist:length > 0 {
        for x in shiplist {
            if x:name = "OrbitalLaunchMount" {
                return true.
                break.
            }
            else if x:name = OLM {
                return true.
                break.
            }
        }
        return false.
    }
    else {
        return false.
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
    }
}


function CheckFuel {
    for res in BoosterCore[0]:resources {
        if res:name = "LiquidFuel" {
            set LFBooster to res:amount.
        }
    }
}