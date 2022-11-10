set LogData to false.
set config:ipu to 500.
set SteeringManager:ROLLCONTROLANGLERANGE to 10.
set BoosterHeight to 44.2.
set LandSomewhereElse to false.
set idealVS to 0.
set LatCtrl to 0.
set LngCtrl to 0.
set LngError to 0.
set LatError to 0.
set ErrorVector to V(0, 0, 0).
set landingzone to latlng(-000.0972,-074.5577).
set BoosterEngines to SHIP:PARTSNAMED("SEP.B4.33.CLUSTER").
set GridFins to SHIP:PARTSNAMED("SEP.B4.GRIDFIN").
set BoosterCore to SHIP:PARTSNAMED("SEP.B4.CORE").
set LngCtrlPID to PIDLOOP(0.35, 0.001, 0.001, -15, 15).
set LatCtrlPID to PIDLOOP(0.1, 0.001, 0.001, -1, 1).
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
if stage:number > 2 {
    if exists("0:/BoosterFlightData.csv") {
        deletepath("0:/BoosterFlightData.csv").
    }
}
unlock throttle.
set throttle to 0.

clearscreen.
print "Booster Nominal Operation, awaiting command..".

until False {
    set ShipConnectedToBooster to false.
    for Part in SHIP:PARTS {
        if Part:name:contains("SEP.S20.BODY") {
            set ShipConnectedToBooster to true.
        }
    }
    if not (ShipConnectedToBooster) and not (BoostBackComplete) {
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
    unlock throttle.
    wait 0.001.
    set throttle to 0.
    unlock steering.
    lock throttle to 0.
    set config:ipu to 500.
    set ship:name to "Booster".
    wait 0.01.
    HUDTEXT("Performing Boostback Burn..", 30, 2, 20, green, false).
    clearscreen.
    print "Starting Boostback".
    set CurrentTime to time:seconds.
    set kuniverse:timewarp:warp to 0.
    set impactpos to ship:body:geopositionof(ship:position).

    rcs on.
    sas off.
    if verticalspeed > 0 {
        if roll = 0 {
            set ship:control:pitch to 0.2.
        }
        if roll = 180 {
            set ship:control:pitch to -0.2.
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
            set ship:control:neutralize to true.
        }
        wait 1.
    }

    set ApproachUPVector to (landingzone:position - body:position):normalized.
    set ApproachVector to vxcl(ApproachUPVector, landingzone:position - ship:position):normalized.
    //set ApproachVectorDraw to vecdraw(v(0,0,0), 5 * ApproachVector, green, "ApproachVector", 20, true, 0.005, true, true).

    SteeringCorrections().

    if homeconnection:isconnected {
        if exists("0:/settings.json") {
            set L to readjson("0:/settings.json").
            if L:haskey("Log Data") {
                if L["Log Data"] = "true" {
                    set LogData to true.
                }
            }
            if L:haskey("Launch Coordinates") {
                set LandingCoords to L["Launch Coordinates"].
            }
            else {
                set LandingCoords to "-0.0972,-74.5577".
            }
            set LandingCoords to LandingCoords:split(",").
            set landingzone to latlng(LandingCoords[0]:toscalar, LandingCoords[1]:toscalar).
            if L:haskey("Ship Name") {
                set starship to L["Ship Name"].
            }
        }
    }

    until vang(facing:forevector, vxcl(up:vector, -ErrorVector)) < 30 or vang(facing:forevector, vxcl(up:vector, -ErrorVector)) < angularvel:y * 90 or verticalspeed < 0 {
        SteeringCorrections().
        if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
        SetBoosterActive().
    }
    lock throttle to ErrorVector:mag / 10000 + 0.01.
    lock steering to lookdirup(vxcl(up:vector, -ErrorVector), ApproachVector - up:vector).

    until ErrorVector:mag < 1250 or verticalspeed < 0 {
        SteeringCorrections().
        if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
        SetBoosterActive().
    }
    unlock throttle.
    set throttle to 0.
    lock steering to lookdirup(up:vector:normalized + ApproachVector:normalized, ApproachVector - up:vector).
    lock throttle to 0.
    set BoostBackComplete to true.
    wait 1.
    HUDTEXT("Starship continues its orbit insertion..", 30, 2, 20, green, false).

    lock steering to lookdirup(up:vector, ApproachVector - up:vector).

    until verticalspeed < -100 {
        SetStarshipActive().
    }
    lock steering to lookdirup(-1 * VELOCITY:SURFACE * AngleAxis(-LngCtrl, facing:starvector) * AngleAxis(-LatCtrl, facing:topvector), ApproachVector - up:vector).

    wait 3.

    until altitude < 30000 {
        SetStarshipActive().
    }
    until altitude < 15000 {}

    lock maxDecel to (ship:availablethrust / ship:mass) - 9.81.
    lock maxDecel3 to max((1650 / ship:mass) - 9.81, 1.175).
    lock stopTime9 to (verticalspeed + 100) / max(maxDecel, 0.000001).
    lock stopDist9 to 0.5 * max(maxDecel, 0.000001) * stopTime9 * stopTime9.
    lock stopTime3 to min(100, -verticalspeed) / max(maxDecel3, 0.000001).
    lock stopDist3 to 0.5 * max(maxDecel3, 0.000001) * stopTime3 * stopTime3.
    lock TotalstopTime to stopTime9 + stopTime3.
    lock TotalstopDist to stopDist9 + stopDist3.
    lock landingRatio to TotalstopDist / RadarAlt.

    until landingRatio > 1 and altitude < 2250 or altitude < 2000 {
        SteeringCorrections().
        if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
        rcs on.
        SetBoosterActive().
    }
    
    HUDTEXT("Performing Landing Burn..", 3, 2, 20, green, false).
    lock throttle to 1.
    lock steering to lookdirup(up:vector - 0.03 * velocity:surface, ApproachVector - up:vector).
    set LandingBurnAltitude to altitude.
    rcs on.
    set LandingBurnStarted to true.

    when altitude < 2000 then {
        if OLMexists() and Vessel("OrbitalLaunchMount"):distance < 2000 {
            lock RadarAlt to alt:radar - ((Vessel("OrbitalLaunchMount"):PARTSNAMED("SLE.SS.OLIT.MZ")[0]:position - Body("Kerbin"):position):mag - SHIP:BODY:RADIUS - Vessel("OrbitalLaunchMount"):geoposition:terrainheight).
            when RadarAlt < 5 * BoosterHeight then {
                sendMessage(Vessel("OrbitalLaunchMount"), "MechazillaArms,8,6,60,true").
                sendMessage(Vessel("OrbitalLaunchMount"), "MechazillaStabilizers,0").
            }

            when RadarAlt < BoosterHeight then {
                set TimeToZero to -verticalspeed / max(maxDecel, 0.000001).
                set ArmIdealSpeed to 30 / TimeToZero.
                sendMessage(Vessel("OrbitalLaunchMount"), ("MechazillaArms,8," + ArmIdealSpeed + ",60,false")).
            }
        }
    }

    when verticalspeed > -100 and (stopDist3 / RadarAlt) < 1 then {
        BoosterEngines[0]:getmodule("ModuleTundraEngineSwitch"):DOACTION("next engine mode", true).
        lock TotalstopTime to verticalspeed / max(maxDecel, 0.000001).
        lock TotalstopDist to 0.5 * max(maxDecel, 0.000001) * TotalstopTime * TotalstopTime.
        lock landingRatio to TotalstopDist / RadarAlt.
        lock throttle to landingRatio.
        if abs(LngError) > 200 or abs(LatError) > 50 {
            lock RadarAlt to alt:radar - BoosterHeight.
            set LandSomewhereElse to true.
            HUDTEXT("Mechazilla out of range..", 5, 2, 20, red, false).
            HUDTEXT("Landing somewhere else..", 5, 2, 20, red, false).
            lock steering to lookdirup(-1 * velocity:surface, ApproachVector - up:vector).
        }
    }

    until altitude < 1250 {}
    lock steering to lookdirup(up:vector - 0.03 * velocity:surface - 0.0175 * ErrorVector, ApproachVector - up:vector).

    when verticalspeed > -40 then {
        lock steering to lookdirup(up:vector - 0.03 * velocity:surface - 0.0175 * ErrorVector, heading(270,0):vector).
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
        //set LdgVectorDraw to vecdraw(v(0, 0, 0), up:vector - 0.03 * velocity:surface - 0.0125 * ErrorVector, green, "Landing Vector", 20, true, 0.005, true, true).
    }

    set ship:control:translation to v(0, 0, 0).
    unlock steering.
    set throttle to 0.
    rcs off.
    clearscreen.
    print "Booster Landed!".
    wait 0.001.
    unlock throttle.
    lock throttle to 0.
    BoosterEngines[0]:shutdown.

    if not LandSomewhereElse {
        print "capture at: " + RadarAlt + "m RA".

        SET KUNIVERSE:DEFAULTLOADDISTANCE:FLYING:UNLOAD TO 22500.
        SET KUNIVERSE:DEFAULTLOADDISTANCE:FLYING:LOAD TO 2250.
        WAIT 0.001.
        SET KUNIVERSE:DEFAULTLOADDISTANCE:FLYING:PACK TO 25000.
        SET KUNIVERSE:DEFAULTLOADDISTANCE:FLYING:UNPACK TO 2000.
        wait 0.001.

        SET KUNIVERSE:DEFAULTLOADDISTANCE:SUBORBITAL:UNLOAD TO 15000.
        SET KUNIVERSE:DEFAULTLOADDISTANCE:SUBORBITAL:LOAD TO 2250.
        WAIT 0.001.
        SET KUNIVERSE:DEFAULTLOADDISTANCE:SUBORBITAL:PACK TO 10000.
        SET KUNIVERSE:DEFAULTLOADDISTANCE:SUBORBITAL:UNPACK TO 200.
        wait 0.001.

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
            sendMessage(Vessel("OrbitalLaunchMount"), "MechazillaPushers,0,1,0.2,true").
            sendMessage(Vessel("OrbitalLaunchMount"), ("MechazillaStabilizers," + maxstabengage)).
            until TowerReset {
                clearscreen.
                print "Roll Angle: " + round(RollAngle,1).
                if time:seconds > LandingTime + 3.25 and not PusherSpeed5 {
                    sendMessage(Vessel("OrbitalLaunchMount"), "MechazillaPushers,0,0.5,0.2,true").
                    set PusherSpeed5 to true.
                }
                if time:seconds > LandingTime + 5.75 and not PusherSpeed2 {
                    sendMessage(Vessel("OrbitalLaunchMount"), "MechazillaPushers,0,0.2,0.2,true").
                    set PusherSpeed2 to true.
                }
                if time:seconds > LandingTime + 8.25 and not PusherSpeed1 {
                    sendMessage(Vessel("OrbitalLaunchMount"), "MechazillaPushers,0,0.1,0.2,true").
                    set PusherSpeed1 to true.
                }
                if time:seconds > LandingTime + 15 and time:seconds < LandingTime + 75 and not BoosterSecured {
                    sendMessage(Vessel("OrbitalLaunchMount"), "MechazillaHeight,28,0.5").
                }
                if time:seconds > LandingTime + 75 and not BoosterSecured {
                    sendMessage(Vessel("OrbitalLaunchMount"), "MechazillaHeight,42,0.5").
                    set BoosterSecured to true.
                }
                if time:seconds > LandingTime + 105 and not BoosterBroughtDown {
                    sendMessage(Vessel("OrbitalLaunchMount"), "MechazillaArms,8,2.5,60,true").
                    set BoosterBroughtDown to true.
                }
                if time:seconds > LandingTime + 114 and not MechazillaGoesUp {
                    sendMessage(Vessel("OrbitalLaunchMount"), "MechazillaHeight,0,2").
                    set MechazillaGoesUp to true.
                }
                if time:seconds > LandingTime + 117 and not MechazillaResetsItself {
                    sendMessage(Vessel("OrbitalLaunchMount"), "MechazillaArms,8,5,90,true").
                    sendMessage(Vessel("OrbitalLaunchMount"), "MechazillaPushers,0,0.2,12,true").
                    sendMessage(Vessel("OrbitalLaunchMount"), "MechazillaStabilizers,0").
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
                print "Booster has been recovered & Tower has been reset!".
            }
            else {
                sendMessage(Vessel("OrbitalLaunchMount"), "EmergencyStop").
                print "Emergency Stop Activated! Roll Angle exceeded: " + round(RollAngle, 1).
                print "Continue manually with great care..".
            }
            HUDTEXT("Tower has been reset, Booster may now be recovered!", 10, 2, 20, green, false).
        }
        else {
            print "Booster has been secured".
            HUDTEXT("Booster may now be recovered!", 10, 2, 20, green, false).
        }
    }
    unlock throttle.
}



FUNCTION SteeringCorrections {
    clearscreen.
    if KUniverse:activevessel = ship {
        set addons:tr:descentmodes to list(true, true, true, true).
        set addons:tr:descentgrades to list(true, true, true, true).
        set addons:tr:descentangles to list(180, 180, 180, 180).
        if not addons:tr:hastarget {
            ADDONS:TR:SETTARGET(landingzone).
        }
        wait 0.001.

        if addons:tr:hasimpact {
            set ErrorVector to ADDONS:TR:IMPACTPOS:POSITION - landingzone:POSITION.
            set impactpos to ship:body:geopositionof(ADDONS:TR:IMPACTPOS:POSITION).
        }
        set LatError to vdot(AngleAxis(-90, ApproachUPVector) * ApproachVector, ErrorVector).
        set LngError to vdot(ApproachVector, ErrorVector).

        if altitude < 15000 {
            set GS to groundspeed.

            if abs(LngError) < 150 {
                set LngCtrlPID to PIDLOOP(0.2, 0.001, 0.001, -7.5, 7.5).
            }

            if InitialError = -9999 and addons:tr:hasimpact {
                set InitialError to LngError.
            }
            else {
                set LngCtrlPID:setpoint to min(max(3 * GS, -125), 125).
            }

            set LatCtrl to -LatCtrlPID:UPDATE(time:seconds, LatError).
            set LngCtrl to -LngCtrlPID:UPDATE(time:seconds, LngError).


            set magnitude to (altitude + 400) / 100.
            if ErrorVector:mag > magnitude and LandingBurnStarted {
                set ErrorVector to ErrorVector:normalized * magnitude.
            }
        }

        //if not LandSomewhereElse {
        //    print "Landing parameters OK".
        //}
        //else {
        //    print "Landing somewhere else..".
        //}
        print "Lng Error: " + round(LngError).
        print "Lat Error: " + round(LatError).

        //print "Radar Altitude: " + round(RadarAlt).
        //if altitude < 15000 {
            //print "LngCtrl: " + round(LngCtrl, 2).
            //print "LatCtrl: " + round(LatCtrl, 2).
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
        print "State: Booster coasting back to Launch Site..".
    }
    LogBoosterFlightData().
}


function LogBoosterFlightData {
    if LogData {
        if defined PrevLogTime {
            set TimeStep to 1.
            if timestamp(time:seconds) > PrevLogTime + TimeStep {
                set DistanceToTarget to ((landingzone:lng - ship:geoposition:lng) * 10.471975).
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


function sendMessage{
    parameter v, msg.
    set cnx to v:connection.
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
        }
        return false.
    }
    else {
        return false.
    }
}


function SetBoosterActive {
    if KUniverse:activevessel = vessel(ship:name) {}
    else if time:seconds > lastVesselChange + 1 {
        KUniverse:forceactive(vessel("Booster")).
        set lastVesselChange to time:seconds.
    }
}


function SetStarshipActive {
    if KUniverse:activevessel = vessel(ship:name) and time:seconds > lastVesselChange + 1 {
        KUniverse:forceactive(vessel(starship)).
        set lastVesselChange to time:seconds.
    }
    else {}
}
