wait until ship:unpacked.

if ship:body:radius > 600001 and ship:body:atm:sealevelpressure > 0.6 {
    set RSS to true.
    set Planet to "Earth".
    set LaunchSites to lexicon("KSC", "28.6084,-80.5998").
    set BoosterHeight to 71.04396.
    set LngCtrlPID to PIDLOOP(0.35, 0.001, 0.001, -25, 25).
    set LatCtrlPID to PIDLOOP(0.1, 0.0005, 0.0005, -2, 2).
}
else {
    set RSS to false.
    set Planet to "Kerbin".
    set LaunchSites to lexicon("KSC", "-0.0972,-74.5577", "Dessert", "-6.5604,-143.95", "Woomerang", "45.2896,136.11", "Baikerbanur", "20.6635,-146.4210").
    set BoosterHeight to 44.2.
    set LngCtrlPID to PIDLOOP(0.35, 0.001, 0.001, -15, 15).
    set LatCtrlPID to PIDLOOP(0.1, 0.0005, 0.0005, -2, 2).
}
set LogData to false.
set config:ipu to 500.
set SteeringManager:ROLLCONTROLANGLERANGE to 10.

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
    set config:ipu to 500.

    wait 0.01.
    HUDTEXT("Performing Boostback Burn..", 30, 2, 20, green, false).
    clearscreen.
    print "Starting Boostback".
    set CurrentTime to time:seconds.
    set kuniverse:timewarp:warp to 0.
    set impactpos to ship:body:geopositionof(ship:position).

    rcs on.
    sas off.

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
    //set RollVectorDraw to vecdraw(v(0,0,0), 5 * ApproachVector - 2.5 * up:vector, blue, "RollVector", 20, true, 0.005, true, true).

    if RSS {
        SetLoadDistances(1000000).
    }
    else {
        SetLoadDistances(300000).
    }

    if verticalspeed > 0 {
        if roll = 0 {
            lock steering to lookdirup(AngleAxis(-30, facing:starvector) * facing:forevector, up:vector).
        }
        else {
            lock steering to lookdirup(AngleAxis(30, facing:starvector) * facing:forevector, up:vector).
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
    }
    set ship:control:neutralize to true.

    if RSS {
        lock throttle to min(ErrorVector:mag / 20000 + 0.01, 7.5 * 9.81 / (ship:availablethrust / ship:mass)).
        lock steering to lookdirup(vxcl(up:vector, -ErrorVector):normalized + (1/18) * up:vector, ApproachVector - 0.5 * up:vector).
    }
    else {
        lock throttle to min(ErrorVector:mag / 10000 + 0.01, 7.5 * 9.81 / (ship:availablethrust / ship:mass)).
        lock steering to lookdirup(vxcl(up:vector, -ErrorVector), ApproachVector - 0.5 * up:vector).
    }

    until ErrorVector:mag < 1250 and not (RSS) or ErrorVector:mag < 2500 and RSS or verticalspeed < 0 and not (RSS) {
        SteeringCorrections().
        if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
        SetBoosterActive().
    }
    unlock throttle.
    lock throttle to 0.

    set BoostBackComplete to true.
    HUDTEXT("Starship continues its orbit insertion..", 30, 2, 20, green, false).
    wait 1.

    lock steering to lookdirup(up:vector:normalized + ApproachVector:normalized, ApproachVector - 0.5 * up:vector).

    until verticalspeed < 0 {
        SteeringCorrections().
        SetStarshipActive().
        rcs on.
    }

    lock steering to lookdirup(up:vector, ApproachVector - 0.5 * up:vector).

    until verticalspeed < -100 {
        SteeringCorrections().
        SetStarshipActive().
        rcs on.
    }

    lock steering to lookdirup(up:vector:normalized - ApproachVector:normalized, ApproachVector - 0.5 * up:vector).

    until altitude < 35000 and not (RSS) or altitude < 55000 and verticalspeed < 0 and RSS {
        SteeringCorrections().
        SetStarshipActive().
        rcs on.
    }

    if RSS {
        set SteeringManager:ROLLTS to 5.
        set SteeringManager:YAWTS to 5.
        set SteeringManager:PITCHTS to 5.
    }

    lock steering to lookdirup(-1 * VELOCITY:SURFACE * AngleAxis(-LngCtrl, facing:starvector) * AngleAxis(-LatCtrl, facing:topvector), ApproachVector - 0.5 * up:vector).

    until altitude < 15000 {
        SteeringCorrections().
        rcs on.
    }

    lock maxDecel to (ship:availablethrust / ship:mass) - 9.81.
    lock maxDecel3 to max((1650 / ship:mass) - 9.81, 1.175).
    lock stopTime9 to (verticalspeed + 100) / max(maxDecel, 0.000001).
    lock stopDist9 to 0.5 * max(maxDecel, 0.000001) * stopTime9 * stopTime9.
    lock stopTime3 to min(100, -verticalspeed) / max(maxDecel3, 0.000001).
    lock stopDist3 to 0.5 * max(maxDecel3, 0.000001) * stopTime3 * stopTime3.
    lock TotalstopTime to stopTime9 + stopTime3.
    lock TotalstopDist to stopDist9 + stopDist3.
    lock landingRatio to TotalstopDist / RadarAlt.

    when abs(LngError) < 1500 then {
        set LngCtrlPID to PIDLOOP(0.35, 0.001, 0.001, -15, 15).
        when abs(LngError) < 150 then {
            if RSS {
                set LngCtrlPID to PIDLOOP(0.2, 0.001, 0.001, -10, 10).
            }
            else {
                set LngCtrlPID to PIDLOOP(0.2, 0.001, 0.001, -7.5, 7.5).
            }
        }
    }

    until landingRatio > 1 and alt:radar < 2250 or alt:radar < 2000 {
        SteeringCorrections().
        if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
        rcs on.
        SetBoosterActive().
    }
    
    HUDTEXT("Performing Landing Burn..", 3, 2, 20, green, false).
    lock throttle to (3.5 * 9.81) / MaxDecel.
    lock steering to lookdirup(up:vector - 0.03 * velocity:surface - 0.0025 * ErrorVector, ApproachVector - 0.5 * up:vector).
    set LandingBurnAltitude to altitude.
    rcs on.
    set LandingBurnStarted to true.

    when alt:radar < 2000 then {
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
            }

            when RadarAlt < BoosterHeight then {
                set TimeToZero to -verticalspeed / max(maxDecel, 0.000001).
                set ArmIdealSpeed to 30 / TimeToZero.
                sendMessage(Vessel(OLM), ("MechazillaArms,8," + ArmIdealSpeed + ",60,false")).
            }
        }
    }

    when verticalspeed > -100 and (stopDist3 / RadarAlt) < 1 then {
        BoosterEngines[0]:getmodule("ModuleTundraEngineSwitch"):DOACTION("next engine mode", true).
        lock TotalstopTime to verticalspeed / max(maxDecel, 0.000001).
        lock TotalstopDist to 0.5 * max(maxDecel, 0.000001) * TotalstopTime * TotalstopTime.
        lock landingRatio to TotalstopDist / RadarAlt.
        lock throttle to landingRatio.
        if abs(LngError) > 200 or abs(LatError) > 100 {
            lock RadarAlt to alt:radar - BoosterHeight.
            set LandSomewhereElse to true.
            HUDTEXT("Mechazilla out of range..", 5, 2, 20, red, false).
            HUDTEXT("Landing somewhere else..", 5, 2, 20, red, false).
            lock steering to lookdirup(-1 * velocity:surface, ApproachVector - 0.5 * up:vector).
        }
    }

    until alt:radar < 1250 {
        SteeringCorrections().
        if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
        rcs on.
        SetBoosterActive().
    }
    if not (LandSomewhereElse) {
        lock steering to lookdirup(up:vector - 0.03 * velocity:surface - 0.02 * ErrorVector, ApproachVector - 0.5 * up:vector).
        SteeringManager:RESETTODEFAULT().
    }

    if not (LandSomewhereElse) {
        when verticalspeed > -40 then {
            lock steering to lookdirup(up:vector - 0.03 * velocity:surface - 0.02 * ErrorVector, heading(270,0):vector).
        }
    }

    when verticalspeed > -25 then {
        lock steering to lookdirup(up:vector - 0.02 * velocity:surface, heading(270,0):vector).
        if abs(LngError) > 20 or abs(LatError) > 10 {
            lock RadarAlt to alt:radar - BoosterHeight.
            set LandSomewhereElse to true.
        }
    }

    until verticalspeed > -0.01 and RadarAlt < 5 and ship:status = "LANDED" or verticalspeed > 0.5 {
        SteeringCorrections().
        if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
        rcs on.
        SetBoosterActive().
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
        wait 1.
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
        wait 0.001.
        if vang(ApproachVector, vxcl(up:vector, landingzone:position - ship:position):normalized) > 10 and altitude > 10000 {
            set ApproachVector to vxcl(up:vector, landingzone:position - ship:position):normalized.
            //set ApproachVectorDraw to vecdraw(v(0,0,0), 5 * ApproachVector, green, "ApproachVector", 20, true, 0.005, true, true).
            //set RollVectorDraw to vecdraw(v(0,0,0), 5 * ApproachVector - 5 * up:vector, blue, "RollVector", 20, true, 0.005, true, true).
            //HUDTEXT("Approach Vector Corrected..", 2.5, 2, 20, yellow, false).
        }

        if addons:tr:hasimpact {
            set ErrorVector to ADDONS:TR:IMPACTPOS:POSITION - landingzone:POSITION.
            set impactpos to ship:body:geopositionof(ADDONS:TR:IMPACTPOS:POSITION).
        }
        set LatError to vdot(AngleAxis(-90, ApproachUPVector) * ApproachVector, ErrorVector).
        set LngError to vdot(ApproachVector, ErrorVector).

        if altitude < 15000 or KUniverse:activevessel = vessel(ship:name) {
            set GS to groundspeed.

            if InitialError = -9999 and addons:tr:hasimpact {
                set InitialError to LngError.
            }
            else if RSS {
                set LngCtrlPID:setpoint to min(max(9 * GS, -350), 350).
            }
            else {
                set LngCtrlPID:setpoint to min(max(3 * GS, -125), 125).
            }

            set LngCtrl to -LngCtrlPID:UPDATE(time:seconds, LngError).
            set LatCtrl to -LatCtrlPID:UPDATE(time:seconds, LatError).
            if LngCtrl > 0 {
                set LatCtrl to -LatCtrl.
            }

            if alt:radar < 1250 {
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
        print "Lng Error: " + round(LngError).
        print "Lat Error: " + round(LatError).
        print "Radar Altitude: " + round(RadarAlt).
        print "Ship Distance: " + (round(vessel(starship):distance) / 1000) + "km".
        if addons:tr:hasimpact {
            print "Total Error: " + round((ADDONS:TR:IMPACTPOS:POSITION - landingzone:POSITION):mag).
            //print "Ship Loaded: " + vessel(starship):loaded.
            //print "Ship Unpacked: " + vessel(starship):unpacked.
            //print " ".
            //print "Ship Flying Load Distances: " + vessel(starship):loaddistance:flying:unpack + ", " + vessel(starship):loaddistance:flying:pack + ", " + vessel(starship):loaddistance:flying:unload + ", " + vessel(starship):loaddistance:flying:load.
            //print "Default Flying Load Distances: " + kuniverse:defaultloaddistance:flying:unpack + ", " + kuniverse:defaultloaddistance:flying:pack + ", " + kuniverse:defaultloaddistance:flying:unload + ", " + kuniverse:defaultloaddistance:flying:load.
            //print "Ship Parts Nr: " + vessel(starship):parts:length.
        }


        //if altitude < 15000 {
        //    print "LngCtrl: " + round(LngCtrl, 2).
        //    print "LatCtrl: " + round(LatCtrl, 2).
        //    print " ".
        //    print "GS: " + round(GS).
        //    print "setpoint: " + round(LngCtrlPID:setpoint).
        //    print " ".
        //    print "Max Decel: " + round(maxDecel, 2).
        //    print "Stop Time: " + round(TotalstopTime, 2).
        //    print "Stop Distance: " + round(TotalstopDist, 2).
        //    print "Stop Distance 3: " + round(stopDist3, 2).
        //    print "throttle required: " + round(landingRatio, 2).
        //}
        wait 0.001.
    }
    else {
        clearscreen.
        print "State: Booster coasting back to Launch Site..".
        print "Radar Altitude: " + round(RadarAlt).
        print "Ship Distance: " + (round(vessel(starship):distance) / 1000) + "km".
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