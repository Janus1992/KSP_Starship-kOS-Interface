set LogData to false.
set BoosterHeight to 44.2.
set BoosterOffset to -30.
set LandSomewhereElse to 0.
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
set LngCtrlPID to PIDLOOP(0.35, 0.001, 0.001, -7.5, 7.5).
set LatCtrlPID to PIDLOOP(0.5, 0.001, 0.001, -1, 1).
set maxDecel to 0.
set TotalstopTime to 0.
set TotalstopDist to 0.
set stopDist3 to 0.
set landingRatio to 0.
set maxstabengage to 50.
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
    clearscreen.
    print "Starting Boostback".
    set CurrentTime to time:seconds.
    set kuniverse:timewarp:warp to 0.

    BoosterEngines[0]:getmodulebyindex(0):DOACTION("next engine mode", true).
    rcs on.
    if roll = 0 {
        set ship:control:pitch to 0.2.
    }
    if roll = 180 {
        set ship:control:pitch to -0.2.
    }
    wait 1.

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
        }
    }

    when vang(facing:forevector, -vxcl(up:vector, ErrorVector)) < 90 then {
        for fin in GridFins {
            fin:getmodule("ModuleControlSurface"):DoAction("activate pitch controls", true).
            fin:getmodule("ModuleControlSurface"):DoAction("activate yaw control", true).
            fin:getmodule("ModuleControlSurface"):DoAction("activate roll control", true).
        }
        set ship:control:neutralize to true.
    }

    until vang(facing:forevector, -vxcl(up:vector, ErrorVector)) < 35 and vang(facing:forevector, -vxcl(up:vector, ErrorVector)) < angularvel:y * 90 {
        SteeringCorrections(1).
        if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
        print angularvel.
    }
    set TempErrorVector to ErrorVector.
    lock throttle to (impactpos:lng - landingzone:lng) + 0.01.
    lock steering to lookdirup(-vxcl(up:vector, TempErrorVector), facing:topvector).

    until impactpos:lng - landingzone:lng < 0.1 {
        SteeringCorrections(1).
        if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
    }
    unlock throttle.
    set throttle to 0.
    lock steering to lookdirup(-vxcl(up:vector, ErrorVector), facing:topvector).
    set oldVector to lookdirup(-vxcl(up:vector, ErrorVector), facing:topvector):vector.
    set BoosterCore[0]:thrustlimit to 25.

    until ErrorVector:mag < 25 {
        SteeringCorrections(1).
        if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
        if vang(lookdirup(-vxcl(up:vector, ErrorVector), facing:topvector):vector, facing:forevector) < 3 {
            set ship:control:translation to v(0, 0, ErrorVector:mag / 500).
        }
        else {
            set ship:control:translation to v(0, 0, 0).
        }
        if vang(lookdirup(-vxcl(up:vector, ErrorVector), facing:topvector):vector, oldVector) > 45 {
            break.
        }
    }
    set ship:control:translation to v(0, 0, 0).
    lock steering to heading(270, 45).
    set BoosterCore[0]:thrustlimit to 100.
    until vang(heading(270, 45):vector, facing:forevector) < 10 {
        SteeringCorrections(0).
    }
    lock steering to up.
    until vang(up:vector, facing:forevector) < 10 {
        SteeringCorrections(0).
    }
    lock steering to heading(90, 70).
    until verticalspeed < -100 {
        SteeringCorrections(0).
    }
    set BoosterCore[0]:thrustlimit to 25.
    lock steering to lookdirup(-1 * VELOCITY:SURFACE, north:starvector).
    until altitude < 45000 {
        SteeringCorrections(0).
    }
    set SteeringManager:ROLLCONTROLANGLERANGE to 20.
    set SteeringManager:PITCHPID:KD to 1.
    set SteeringManager:YAWPID:KD to 1.
    lock steering to lookdirup(-1 * VELOCITY:SURFACE * R(LatCtrl, -LngCtrl, LatCtrl), north:starvector).

    until altitude < 30000 {
        SteeringCorrections(0).
    }
    set BoosterCore[0]:thrustlimit to 100.

    lock maxDecel to (ship:availablethrust / ship:mass) - 9.81.
    lock maxDecel3 to ((ship:availablethrust / ship:mass) / 3) - 9.81.
    lock stopTime9 to (verticalspeed + 100) / max(maxDecel, 0.000001).
    lock stopDist9 to 0.5 * max(maxDecel, 0.000001) * stopTime9 * stopTime9.
    lock stopTime3 to min(100, -verticalspeed) / max(maxDecel3, 0.000001).
    lock stopDist3 to 0.5 * max(maxDecel3, 0.000001) * stopTime3 * stopTime3.
    lock TotalstopTime to stopTime9 + stopTime3.
    lock TotalstopDist to stopDist9 + stopDist3.
    lock landingRatio to TotalstopDist / RadarAlt.

    until landingRatio > 1 and altitude < 2250 {
        SteeringCorrections(0).
        if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
    }
    
    HUDTEXT("Performing Landing Burn..", 3, 2, 20, green, false).
    lock throttle to 1.
    lock steering to lookdirup(up:vector - 0.03 * velocity:surface - 0.0175 * ErrorVector, north:starvector).
    set LandingBurnAltitude to altitude.

    when altitude < 2000 then {
        if OLMexists() {
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
        BoosterEngines[0]:getmodulebyindex(0):DOACTION("next engine mode", true).
        lock TotalstopTime to verticalspeed / max(maxDecel, 0.000001).
        lock TotalstopDist to 0.5 * max(maxDecel, 0.000001) * TotalstopTime * TotalstopTime.
        lock landingRatio to TotalstopDist / RadarAlt.
        lock throttle to landingRatio.
    }

    when verticalspeed > -25 then {
        lock steering to lookdirup(up:vector - 0.02 * velocity:surface, north:starvector).
    }

    until verticalspeed > -0.01 and RadarAlt < 5 and ship:status = "LANDED" or verticalspeed > 0.5 {
        SteeringCorrections(0).
        if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
        //set LdgVectorDraw to vecdraw(v(0, 0, 0), up:vector - 0.03 * velocity:surface - 0.0125 * ErrorVector, green, "Landing Vector", 20, true, 0.005, true, true).
    }
    print "capture at: " + RadarAlt + "m RA".

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
    unlock throttle.
}



FUNCTION SteeringCorrections {
    parameter CalculateOrbit.
    if CalculateOrbit {
        set calcVS to verticalspeed.
        set calcAlt to altitude.
        set timetoimpact to 0.
        set timestep to 0.1.
        until calcAlt < 0 {
            set timetoimpact to timetoimpact + timestep.
            set calcVS to calcVS - (9.81 * timestep).
            set calcAlt to calcAlt + (calcVS * timestep).
        }
        set GSEast to -vdot(vxcl(up:vector, velocity:surface), north:starvector).
        set GSNorth to vdot(vxcl(up:vector, velocity:surface), north:vector).

        set NewLng to ship:geoposition:lng + (GSEast * timetoimpact) / 10471.1975.
        set NewLat to ship:geoposition:lat + (GSNorth * timetoimpact) / 10471.1975.

        set impactpos to LATLNG(NewLat, NewLng).
        set ErrorVector to impactpos:POSITION - landingzone:POSITION.
    }
    else {
        if KUniverse:activevessel = VESSEL("Booster") {
            set addons:tr:descentmodes to list(true, true, true, true).
            set addons:tr:descentgrades to list(true, true, true, true).
            set addons:tr:descentangles to list(180, 180, 180, 180).
            if not addons:tr:hastarget {
                ADDONS:TR:SETTARGET(landingzone).
                set LngCtrlPID:setpoint to BoosterOffset.
            }
            wait 0.001.
            if addons:tr:hasimpact {
                set ErrorVector to ADDONS:TR:IMPACTPOS:POSITION - landingzone:POSITION.
            }
            if addons:tr:hasimpact {
                set LatError to (ADDONS:TR:IMPACTPOS:lat - landingzone:lat) * 10471.1975.
            }
            if addons:tr:hasimpact {
                set LngError to (ADDONS:TR:IMPACTPOS:lng - landingzone:lng) * 10471.1975.
            }

            set LatCtrl to -LatCtrlPID:UPDATE(time:seconds, LatError).
            set LngCtrl to -LngCtrlPID:UPDATE(time:seconds, LngError).

            if LatError > 25 and altitude > 2500 or LatError < -25 and altitude > 2500 {
                set LatCtrl to -15 * LatCtrl.
            }

            set magnitude to (altitude + 400) / 100.
            if ErrorVector:mag > magnitude {
                set ErrorVector to ErrorVector:normalized * magnitude.
            }
        }
        else {
            set LatError to (ship:geoposition:lat - landingzone:lat) * 10471.1975.
            set LngError to (ship:geoposition:lng - landingzone:lng) * 10471.1975.
            set FlightPath to EstimateFlightPath().
            set LngEstimate to FlightPath[0].
            set LatEstimate to FlightPath[1].

            set LatCtrl to -LatCtrlPID:UPDATE(time:seconds, LatError + LatEstimate).
            set LngCtrl to -LngCtrlPID:UPDATE(time:seconds, LngError + LngEstimate).

            if (LatError + LatEstimate) > 25 and altitude > 2500 or (LatError + LatEstimate) < -25 and altitude > 2500 {
                set LatCtrl to -15 * LatCtrl.
            }

            set ErrorVector to vxcl(up:vector, latlng(ship:geoposition:lat + (LatEstimate / 10471.1975), ((ship:geoposition:lng) + (LngEstimate / 10471.1975))):position - landingzone:POSITION).
            set magnitude to (altitude + 400) / 100.
            if ErrorVector:mag > magnitude {
                set ErrorVector to ErrorVector:normalized * magnitude.
            }
        }
    }
    clearscreen.
    if CalculateOrbit {
        print "Impact Position: " + round(impactpos:lng, 4) + "," + round(impactpos:lat, 4).
        print "Time to Impact: " + timetoimpact.
        print "GS E/N: " + round(GSEast) + "   " + round(GSNorth).
    }
    else {
        print "Radar Altitude: " + round(RadarAlt).
        print "Lng Error: " + round(LngError).
        print "Lat Error: " + round(LatError).
        if KUniverse:activevessel = VESSEL("Booster") {}
        else {
            //print "Lng Error Prediction: " + round(LngError + LngEstimate).
            //print "Lat Error Prediction: " + round(LatError + LatEstimate).
        }
        //print "LngCtrl: " + round(LngCtrl, 2).
        //print "LatCtrl: " + round(LatCtrl, 2).
        //print "Max Decel: " + round(maxDecel, 2).
        //print "Stop Time: " + round(TotalstopTime, 2).
        //print "Stop Distance: " + round(TotalstopDist, 2).
        //print "Stop Distance 3: " + round(stopDist3, 2).
        //print "throttle required: " + round(landingRatio, 2).
    }
    //print "Error: " + round(ErrorVector:mag).
    //print "Ship Position: " + round(ship:geoposition:lng, 4) + "," + round(ship:geoposition:lat, 4).
    //print "Landing Zone: " + landingzone:lng + "," + landingzone:lat.

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


function EstimateFlightPath {
    set GSEast to -vdot(vxcl(up:vector, velocity:surface), north:starvector).
    set GSNorth to vdot(vxcl(up:vector, velocity:surface), north:vector).

    set TimeToGround to (RadarAlt / -verticalspeed).

    //print "Time to Ground: " + round(TimeToGround, 1).
    //print "GS East/West: " + -vdot(vxcl(up:vector, velocity:surface), north:starvector).
    //print "GS North/South: " + vdot(vxcl(up:vector, velocity:surface), north:vector).

    set LngDistance to 0.6 * GSEast * TimeToGround.
    set LatDistance to 0.6 * GSNorth * TimeToGround.

    return list(LngDistance, LatDistance).
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
