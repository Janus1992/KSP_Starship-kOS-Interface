//
// SEP Starship kOS Script
//
//
// Manual Install:
// - Place this script in Kerbal Space Program/Ships/Script/boot/.
// - Check the bootfile has been selected in the ships kOS unit.
// - Fly, and the GUI should show up!
//
//
// Required Mods:
// - SEP
// - Trajectories
// - kOS
//
// Have Fun!
//
//
//
// Version 1.0 - GNUGPL3
// Janus92
//
//
//


//--------------Self-Update-------------//


wait until ship:unpacked.
unlock steering.
clearguis().
clearscreen.

wait 1.

if homeconnection:isconnected {
    if exists("0:/settings.json") {
        set L to readjson("0:/settings.json").
        if L:haskey("Last Update Time") {
            set LastUpdateTime to L["Last Update Time"].
        }
    }
    //print "Time Difference: " + round(kuniverse:realtime - LastUpdateTime, 2).
    if LastUpdateTime + 5 < kuniverse:realtime {
        switch to 0.
        HUDTEXT("Starting Interface..", 10, 2, 20, green, false).
        print "Starting background update..".
        compile starship.
        copypath("starship.ksm", "1:").
        set core:BOOTFILENAME to "starship.ksm".
        print "Starship Interface background update completed! Rebooting now..".
        set LastUpdateTime to kuniverse:realtime.
        SaveToSettings("Last Update Time", LastUpdateTime).
        reboot.
    }
}
else {
    HUDTEXT("No connection available! Can't update Interface..", 10, 2, 20, red, false).
}


//------------Configurables-------------//


set CustomLZ to "0.0000,0.0000".
set LandingOffset to 6.
set MaxCargoToOrbit to 69420.
set MaxReEntryCargoKerbin to 10000.
set MaxReEntryCargoDuna to 30000.
set SNStart to 30.  // Defines the first Serial Number when multiple ships are found and renaming is necessary.
set LaunchTimeSpanInSeconds to 246.
set MaxTilt to 2.5.  // Defines maximum allowed slope for the Landing Zone Search Function
set ShipHeight to 31.1.
set maxstabengage to 50.  // Defines max closing of the stabilizers after landing.
set config:ipu to 500.


//---------Program Variables-----------//


set startup to false.
set NrOfGuisOpened to 0.
set exit to false.
set AbortInProgress to false.
set AbortComplete to false.
set LaunchComplete to false.
set LandSomewhereElse to false.
set MechaZillaShouldCatchShip to false.
SetPlanetData().
set currentdeltav to 0.
set ShipMass to 200000.
set FuelMass to 1.
set FlipAltitude to 500.
set TargetShip to false.
set FuelVentCutOffValue to 3500.
set FindNewTarget to false.
set executeconfirmed to 0.
set cancelconfirmed to 0.
set InhibitExecute to 1.
set InhibitCancel to 1.
set InhibitPages to 0.
set currVel to SHIP:VELOCITY:ORBIT.
set currTime to time:seconds.
set prevVel to SHIP:VELOCITY:ORBIT.
set prevTime to time:seconds.
set prevFanTime to time:seconds.
set prevTargetFindingTime to time:seconds - 4.
set PrevUpdateTime to TIME:SECONDS.
set prevCargoPageTime to time:seconds.
set prevattroll to 0.
set prevattpitch to aoa.
set towerrot to 8.
set towerang to 0.
set towerhgt to 62.
set towerpush to 0.7.
set towerpushfwd to 0.
set towerstab to 0.
set attroll to 0.
set attpitch to aoa.
set acc TO V(0, 0, 0).
set FacingTheWrongWay to false.
set SteeringIsRunning to false.
set BGUisRunning to false.
set LandButtonIsRunning to false.
set LaunchButtonIsRunning to false.
set OrbitPageIsRunning to false.
set StatusPageIsRunning to false.
set EnginePageIsRunning to false.
set StatusBarIsRunning to false.
set AttitudeIsRunning to false.
set ClosingIsRunning to false.
set CargoPageIsRunning to false.
set CrewPageIsRunning to false.
set towerPageIsRunning to false.
set ManeuverPageIsRunning to false.
set AutodockingIsRunning to false.
set PerformingManeuver to false.
set ShipIsDocked to false.
set ShipType to "".
set CrewOnboard to false.
set EngineTogglesHidden to false.
set Refueling to false.
set CargoCalculationIsRunning to false.
set NewTargetSet to false.
set BurnComplete to false.
set ShowSLdeltaV to true.
set Logging to false.
set fan to false.
set FlapsYawEngaged to true.
set CargoBay to false.
set cargo to 0.
set IdealRCS to 100.
set JustCheckingWhatTheErrorIs to false.
set PreviousAoAError to 0.
set AvailableLandingSpots to list(0, latlng(0,0), 0, 0, 0).
set TargetSelected to false.
set docked to false.
set OnOrbitalMount to false.
set ship:control:translation to v(0, 0, 0).


//---------------Finding Parts-----------------//


function FindParts {
    if ship:dockingports[0]:haspartner {
        set ShipIsDocked to true.
        if startup {}
        else {
            HUDTEXT("Docked.. Waiting until UNDOCK before starting Interface..", 30, 2, 20, red, false).
            wait until ship:dockingports[0]:haspartner = false.
        }
    }
    else {
        set ShipIsDocked to false.
        set SLEngines to SHIP:PARTSNAMED("SEP.RAPTOR.SL").
        set VACEngines to SHIP:PARTSNAMED("SEP.RAPTOR.VAC").
        set NrOfVacEngines to VACEngines:length.

        for res in ship:resources {
            if res:name = "LiquidFuel" {
                set LFcap to res:capacity.
            }
            if res:name = "LqdMethane" {
                set LFcap to res:capacity.
            }
            if res:name = "Oxidizer" {
                set Oxcap to res:capacity.
            }
            if res:name = "ElectricCharge" {
                set ELECcap to res:capacity.
            }
        }

        if SHIP:PARTSNAMED("SEP.B4.Core"):length > 0 {
            set Boosterconnected to true.
            set BoosterEngines to SHIP:PARTSNAMED("SEP.B4.33.Cluster").
            set GridFins to SHIP:PARTSNAMED("SEP.B4.GRIDFIN").
            set BoosterInterstage to SHIP:PARTSNAMED("SEP.B4.INTER").
            set BoosterCore to SHIP:PARTSNAMED("SEP.B4.Core").
            set BoosterCore[0]:getmodule("kOSProcessor"):volume:name to "Booster".
        }
        else {
            set Boosterconnected to false.
        }

        if SHIP:PARTSNAMED("SLE.SS.OLP"):length > 0 {
            set OnOrbitalMount to True.
            set SHIP:PARTSNAMED("SLE.SS.OLP")[0]:getmodule("kOSProcessor"):volume:name to "OrbitalLaunchMount".
            set ArmsHeight to (ship:PARTSNAMED("SLE.SS.OLIT.MZ")[0]:position - Body("Kerbin"):position):mag - SHIP:BODY:RADIUS - ship:geoposition:terrainheight + 7.5.
            SaveToSettings("ArmsHeight", ArmsHeight).
        }
        else {
            set OnOrbitalMount to False.
        }

        set FLflap to SHIP:PARTSNAMED("SEP.S20.FWD.LEFT").
        set FRflap to SHIP:PARTSNAMED("SEP.S20.FWD.RIGHT").
        set ALflap to SHIP:PARTSNAMED("SEP.S20.AFT.LEFT").
        set ARflap to SHIP:PARTSNAMED("SEP.S20.AFT.RIGHT").

        if SHIP:PARTSNAMED("SEP.S20.CARGO"):length > 0 {
            set Nose to SHIP:PARTSNAMED("SEP.S20.CARGO").
            set ShipType to "Cargo".
        }
        if SHIP:PARTSNAMED("SEP.S20.CREW"):length > 0 {
            set Nose to SHIP:PARTSNAMED("SEP.S20.CREW").
            set ShipType to "Crew".
        }
        if SHIP:PARTSNAMED("SEP.S20.TANKER"):length > 0 {
            set Nose to SHIP:PARTSNAMED("SEP.S20.TANKER").
            set ShipType to "Tanker".
        }
        set HeaderTank to SHIP:PARTSNAMED("SEP.S20.HEADER").
        set Tank to SHIP:PARTSNAMED("SEP.S20.BODY").
        set tankname to "".
        if Tank:length = 0 {
            set tankname to "SEP.S20.BODY (" + ship:name + ")".
            set Tank to SHIP:PARTSNAMED(tankname).
        }
        if Tank:length = 0 {
            set tankname to "SEP.S20.BODY (Starship Cargo)".
            set Tank to SHIP:PARTSNAMED(tankname).
            if Tank:length = 0 {
                set tankname to "SEP.S20.BODY (Starship Crew)".
                set Tank to SHIP:PARTSNAMED(tankname).
                if Tank:length = 0 {
                    set tankname to "SEP.S20.BODY (Starship Tanker)".
                    set Tank to SHIP:PARTSNAMED(tankname).
                }
            }
        }
        set Tank[0]:getmodule("kOSProcessor"):volume:name to "Ship".

        for res in tank[0]:resources {
            if res:name = "LiquidFuel" {
                set LiquidMethaneOnBoard to false.
                if ship:body = BODY("Kerbin") {
                    set FuelVentCutOffValue to 375.
                }
                if ship:body = BODY("Duna") {
                    set FuelVentCutOffValue to 8721 - (Cargo / MaxCargoToOrbit) * 6720.
                }
                set VentRate to 17.73.
            }
            if res:name = "LqdMethane" {
                set LiquidMethaneOnBoard to true.
                if ship:body = BODY("Kerbin") {
                    set FuelVentCutOffValue to 375.
                }
                if ship:body = BODY("Duna") {
                    set FuelVentCutOffValue to 45423 - (Cargo / MaxCargoToOrbit) * 35000.
                }
                set VentRate to 17.73.
            }
            if res:name = "Oxidizer" {
                set Oxcap to res:capacity.
            }
        }
    }
}


//-------------Initial Program Start-Up--------------------//


FindParts().
SetRadarAltitude().
set throttle to 0.
unlock throttle.

//tank[0]:getmodule("ModuleB9PartSwitch"):DoEvent("select docking system").

if OnOrbitalMount {
    sendMessage(Processor(volume("OrbitalLaunchMount")), "MechazillaHeight,3,0.5").
    sendMessage(Processor(volume("OrbitalLaunchMount")), "MechazillaArms,8,1,97.5,false").
    sendMessage(Processor(volume("OrbitalLaunchMount")), "MechazillaPushers,0,0.2,0.7,true").
    sendMessage(Processor(volume("OrbitalLaunchMount")), "MechazillaStabilizers,0").
}
set ship:type to "Ship".
if ShipType = "Crew" {
    lights on.
}

list targets in targetlist.
for x in targetlist {
    if x:distance < 350 {
        set NrOfGuisOpened to NrOfGuisOpened + 1.
    }
}

print "Starship Interface startup complete!".


//-------------Start Graphic User Interface-------------//


local g is GUI(600).
    set g:style:bg to "starship_img/starship_background".
    set g:style:border:h to 10.
    set g:style:border:v to 10.
    set g:style:padding:v to 0.
    set g:style:padding:h to 0.
    set g:x to -150.
    set g:y to 150 + (NrOfGuisOpened * 250).


//-------------------------Skin-------------------------//


set g:skin:popupwindow:normal:bg to "starship_img/starship_background".
set g:skin:popupwindow:on:bg to "starship_img/starship_background".
set g:skin:popupwindow:hover:bg to "starship_img/starship_background".
set g:skin:popupwindow:hover_on:bg to "starship_img/starship_background".
set g:skin:popupwindow:active:bg to "starship_img/starship_background".
set g:skin:popupwindow:active_on:bg to "starship_img/starship_background".
set g:skin:popupwindow:focused:bg to "starship_img/starship_background".
set g:skin:popupwindow:focused_on:bg to "starship_img/starship_background".
set g:skin:popupwindow:border:v to 10.
set g:skin:popupwindow:border:h to 10.
set g:skin:popupwindow:margin:v to 0.
set g:skin:popupwindow:margin:h to 0.
set g:skin:popupwindow:padding:v to 0.
set g:skin:popupwindow:padding:h to 0.
set g:skin:popupwindow:height to 125.
set g:skin:popupmenuitem:fontsize to 18.


set g:skin:button:bg to "starship_img/starship_background".
set g:skin:button:on:bg to "starship_img/starship_background_light".
set g:skin:button:hover:bg to "starship_img/starship_background_light".
set g:skin:button:hover_on:bg to "starship_img/starship_background_light".
set g:skin:button:active:bg to "starship_img/starship_background_light".
set g:skin:button:active_on:bg to "starship_img/starship_background_light".
set g:skin:button:border:v to 10.
set g:skin:button:border:h to 10.
set g:skin:button:textcolor to white.

set g:skin:textfield:textcolor to white.
set g:skin:textfield:bg to "starship_img/starship_background".
set g:skin:textfield:on:bg to "starship_img/starship_background_light".
set g:skin:textfield:hover:bg to "starship_img/starship_background_light".
set g:skin:textfield:hover_on:bg to "starship_img/starship_background_light".
set g:skin:textfield:active:bg to "starship_img/starship_background_light".
set g:skin:textfield:active_on:bg to "starship_img/starship_background_light".
set g:skin:textfield:focused:bg to "starship_img/starship_background_light".
set g:skin:textfield:focused_on:bg to "starship_img/starship_background_light".
set g:skin:textfield:border:v to 10.
set g:skin:textfield:border:h to 10.
set g:skin:textfield:fontsize to 19.

set g:skin:toggle:fontsize to 15.
set g:skin:toggle:wordwrap to false.
set g:skin:toggle:bg to "starship_img/starship_radiobutton".
set g:skin:toggle:on:bg to "starship_img/starship_radiobutton_on".
set g:skin:toggle:hover:bg to "starship_img/starship_radiobutton_hover".
set g:skin:toggle:hover_on:bg to "starship_img/starship_radiobutton_on".
set g:skin:toggle:active:bg to "starship_img/starship_radiobutton_on".
set g:skin:toggle:active_on:bg to "starship_img/starship_radiobutton_on".
set g:skin:toggle:border:left to 0.
set g:skin:toggle:border:top to 0.
set g:skin:toggle:border:right to 0.
set g:skin:toggle:border:bottom to 0.

set g:skin:label:textcolor to white.


//---------------Add Buttons and Functions--------------//


local box_all is g:addvlayout().

local topbuttonbar is box_all:addhlayout().
local launchbutton to topbuttonbar:addbutton("<size=16>LAUNCH</size>").
    set launchbutton:toggle to true.
    set launchbutton:style:width to 80.
    set launchbutton:style:height to 35.
    set launchbutton:tooltip to "Prepare the Ship for Launch (with the option to cancel)".
local landbutton to topbuttonbar:addbutton("<size=16>DE-ORBIT & LAND</size>").
    set landbutton:toggle to true.
    set landbutton:style:width to 155.
    set landbutton:style:height to 35.
    set landbutton:tooltip to "Prepare the Ship for Re-Entry and Landing (with the option to cancel)".
local launchlabel to topbuttonbar:addlabel("<size=16><b>LAUNCH</b></size>").
    set launchlabel:style:width to 80.
    set launchlabel:style:height to 35.
    set launchlabel:style:border:v to 10.
    set launchlabel:style:border:h to 10.
    set launchlabel:style:align to "CENTER".
    set launchlabel:style:bg to "starship_img/starship_background_dark".
    set launchlabel:tooltip to "Launch Button Inhibited".
    launchlabel:hide().
local landlabel to topbuttonbar:addlabel("<size=16><b>DE-ORBIT & LAND</b></size>").
    set landlabel:style:width to 155.
    set landlabel:style:height to 35.
    set landlabel:style:border:v to 10.
    set landlabel:style:border:h to 10.
    set landlabel:style:align to "CENTER".
    set landlabel:style:bg to "starship_img/starship_background_dark".
    set landlabel:tooltip to "De-orbit Button Inhibited".
    landlabel:hide().
local statuslabel to topbuttonbar:addlabel("").
    set statuslabel:style:height to 35.
    set statuslabel:style:fontsize to 16.
    set statuslabel:style:align to "center".
    set statuslabel:style:vstretch to true.
    set statuslabel:style:hstretch to true.
local statusbutton is topbuttonbar:addbutton().
    set statusbutton:toggle to true.
    set statusbutton:style:width to 35.
    set statusbutton:style:height to 35.
    set statusbutton:style:bg to "starship_img/starship_status".
    set statusbutton:style:on:bg to "starship_img/starship_status_on".
    set statusbutton:style:hover:bg to "starship_img/starship_status_hover".
    set statusbutton:style:hover_on:bg to "starship_img/starship_status_on".
    set statusbutton:style:active:bg to "starship_img/starship_status_hover".
    set statusbutton:style:active_on:bg to "starship_img/starship_status_hover".
    set statusbutton:style:border:v to 0.
    set statusbutton:style:border:h to 0.
    set statusbutton:tooltip to "Status Page".
local crewbutton is topbuttonbar:addbutton().
    set crewbutton:toggle to true.
    set crewbutton:style:width to 35.
    set crewbutton:style:height to 35.
    set crewbutton:style:bg to "starship_img/starship_crew_icon".
    set crewbutton:style:on:bg to "starship_img/starship_crew_icon_on".
    set crewbutton:style:hover:bg to "starship_img/starship_crew_icon_hover".
    set crewbutton:style:hover_on:bg to "starship_img/starship_crew_icon_on".
    set crewbutton:style:active:bg to "starship_img/starship_crew_icon_hover".
    set crewbutton:style:active_on:bg to "starship_img/starship_crew_icon_hover".
    set crewbutton:style:border:v to 0.
    set crewbutton:style:border:h to 0.
    set crewbutton:tooltip to "Crew Page".
crewbutton:hide().
local orbitbutton is topbuttonbar:addbutton().
    set orbitbutton:toggle to true.
    set orbitbutton:style:width to 35.
    set orbitbutton:style:height to 35.
    set orbitbutton:style:bg to "starship_img/starship_orbit".
    set orbitbutton:style:on:bg to "starship_img/starship_orbit_on".
    set orbitbutton:style:hover:bg to "starship_img/starship_orbit_hover".
    set orbitbutton:style:hover_on:bg to "starship_img/starship_orbit_on".
    set orbitbutton:style:active:bg to "starship_img/starship_orbit_hover".
    set orbitbutton:style:active_on:bg to "starship_img/starship_orbit_hover".
    set orbitbutton:style:border:v to 0.
    set orbitbutton:style:border:h to 0.
    set orbitbutton:tooltip to "Orbit Page".
local maneuverbutton is topbuttonbar:addbutton().
    set maneuverbutton:toggle to true.
    set maneuverbutton:style:width to 35.
    set maneuverbutton:style:height to 35.
    set maneuverbutton:style:bg to "starship_img/starship_maneuver_icon".
    set maneuverbutton:style:on:bg to "starship_img/starship_maneuver_icon_on".
    set maneuverbutton:style:hover:bg to "starship_img/starship_maneuver_icon_hover".
    set maneuverbutton:style:hover_on:bg to "starship_img/starship_maneuver_icon_on".
    set maneuverbutton:style:active:bg to "starship_img/starship_maneuver_icon_hover".
    set maneuverbutton:style:active_on:bg to "starship_img/starship_maneuver_icon_hover".
    set maneuverbutton:style:border:v to 0.
    set maneuverbutton:style:border:h to 0.
    set maneuverbutton:tooltip to "Maneuver Page".
maneuverbutton:hide().
local enginebutton is topbuttonbar:addbutton().
    set enginebutton:toggle to true.
    set enginebutton:style:width to 35.
    set enginebutton:style:height to 35.
    set enginebutton:style:bg to "starship_img/starship_engine".
    set enginebutton:style:on:bg to "starship_img/starship_engine_on".
    set enginebutton:style:hover:bg to "starship_img/starship_engine_hover".
    set enginebutton:style:hover_on:bg to "starship_img/starship_engine_on".
    set enginebutton:style:active:bg to "starship_img/starship_engine_hover".
    set enginebutton:style:active_on:bg to "starship_img/starship_engine_hover".
    set enginebutton:style:border:v to 0.
    set enginebutton:style:border:h to 0.
    set enginebutton:tooltip to "Engines Page".
local attitudebutton is topbuttonbar:addbutton().
    set attitudebutton:toggle to true.
    set attitudebutton:style:width to 35.
    set attitudebutton:style:height to 35.
    set attitudebutton:style:bg to "starship_img/starship_attitude".
    set attitudebutton:style:on:bg to "starship_img/starship_attitude_on".
    set attitudebutton:style:hover:bg to "starship_img/starship_attitude_hover".
    set attitudebutton:style:hover_on:bg to "starship_img/starship_attitude_on".
    set attitudebutton:style:active:bg to "starship_img/starship_attitude_hover".
    set attitudebutton:style:active_on:bg to "starship_img/starship_attitude_hover".
    set attitudebutton:style:border:v to 0.
    set attitudebutton:style:border:h to 0.
    set attitudebutton:tooltip to "Manual Re-Entry Attitude Page (Landing armed @ 10km Radar Altitude)".
local cargobutton is topbuttonbar:addbutton().
    set cargobutton:toggle to true.
    set cargobutton:style:width to 35.
    set cargobutton:style:height to 35.
    set cargobutton:style:bg to "starship_img/starship_cargo".
    set cargobutton:style:on:bg to "starship_img/starship_cargo_on".
    set cargobutton:style:hover:bg to "starship_img/starship_cargo_hover".
    set cargobutton:style:hover_on:bg to "starship_img/starship_cargo_on".
    set cargobutton:style:active:bg to "starship_img/starship_cargo_hover".
    set cargobutton:style:active_on:bg to "starship_img/starship_cargo_hover".
    set cargobutton:style:border:v to 0.
    set cargobutton:style:border:h to 0.
    set cargobutton:tooltip to "Cargo Page".
cargobutton:hide().
local towerbutton is topbuttonbar:addbutton().
    set towerbutton:toggle to true.
    set towerbutton:style:width to 35.
    set towerbutton:style:height to 35.
    set towerbutton:style:bg to "starship_img/starship_tower".
    set towerbutton:style:on:bg to "starship_img/starship_tower_on".
    set towerbutton:style:hover:bg to "starship_img/starship_tower_hover".
    set towerbutton:style:hover_on:bg to "starship_img/starship_tower_on".
    set towerbutton:style:active:bg to "starship_img/starship_tower_hover".
    set towerbutton:style:active_on:bg to "starship_img/starship_tower_hover".
    set towerbutton:style:border:v to 0.
    set towerbutton:style:border:h to 0.
    set towerbutton:tooltip to "Tower Page".
towerbutton:hide().
local settingsbutton is topbuttonbar:addbutton().
    set settingsbutton:toggle to true.
    set settingsbutton:style:width to 35.
    set settingsbutton:style:height to 35.
    set settingsbutton:style:bg to "starship_img/starship_settings".
    set settingsbutton:style:on:bg to "starship_img/starship_settings_on".
    set settingsbutton:style:hover:bg to "starship_img/starship_settings_hover".
    set settingsbutton:style:hover_on:bg to "starship_img/starship_settings_on".
    set settingsbutton:style:active:bg to "starship_img/starship_settings_hover".
    set settingsbutton:style:active_on:bg to "starship_img/starship_settings_hover".
    set settingsbutton:style:border:v to 0.
    set settingsbutton:style:border:h to 0.
    set settingsbutton:tooltip to "Settings Page".
local g_close is topbuttonbar:addbutton("<size=20>X</size>").
    set g_close:style:textcolor to white.
    set g_close:style:bg to "starship_img/starship_blue_bg".
    set g_close:style:on:bg to "starship_img/starship_blue_bg".
    set g_close:style:hover:bg to "starship_img/starship_blue_bg".
    set g_close:style:hover_on:bg to "starship_img/starship_blue_bg".
    set g_close:style:active:bg to "starship_img/starship_blue_bg".
    set g_close:style:active_on:bg to "starship_img/starship_blue_bg".
    set g_close:style:margin:top to 6.
    set g_close:style:margin:right to 6.
    set g_close:style:width to 30.
    set g_close:tooltip to "Close the GUI and shut down the CPU? (toggle CPU power to restart)".

set g_close:onclick to {
    if not ClosingIsRunning {
        set ClosingIsRunning to true.
        Droppriority().
        GoHome().
        set message1:text to "<b><color=red>Are you sure you want to Quit?</color></b>".
        set message2:text to "<b><color=yellow>The Interface will shut down..</color></b>".
        set message3:text to "<b>Quit <color=white>or</color> Cancel?</b><color=white><size=14>  (Restart: Toggle kOS Power in Tank Section)</size></color>".
        set message3:style:textcolor to cyan.
        set cancel:text to "<b>CANCEL</b>".
        set cancel:style:textcolor to cyan.
        set execute:text to "<b>QUIT</b>".
        LogToFile("Close Button Clicked, waiting for confirm").
        if LandButtonIsRunning or LaunchButtonIsRunning or AbortInProgress {InhibitButtons(1, 0, 0).}
        else {InhibitButtons(0, 0, 0).}
        if runningprogram = "Venting Fuel.." {
            ShutdownEngines().
        }
        if confirm() {
            sas on.
            set throttle to 0.
            unlock throttle.
            if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
            LogToFile("Closing GUI confirmed").
            g:hide().
            shutdown.
        }
        else {
            LogToFile("Closing GUI Cancelled").
            set execute:text to "<b>EXECUTE</b>".
            if LandButtonIsRunning or LaunchButtonIsRunning {
                InhibitButtons(1, 1, 0).
                set message1:text to "".
                set message2:text to "".
                set message3:text to "".
                set message3:style:textcolor to white.
                if Boosterconnected {
                    set cancel:text to "<b>ABORT</b>".
                    set cancel:style:textcolor to red.
                }
                else if LaunchButtonIsRunning {
                    InhibitButtons(1, 1, 1).
                }
            }
            else {
                InhibitButtons(0, 1, 1).
                set message1:text to "".
                set message2:text to "".
                set message3:text to "".
                set message3:style:textcolor to white.
                if AttitudeIsRunning {
                    set attitudebutton:pressed to true.
                }
            }

        }
        set ClosingIsRunning to false.
    }
}.

    
local mainbox is box_all:addvlayout().
local flightstack is mainbox:addstack().
local settingsstack is mainbox:addstack().
local cargostack is mainbox:addstack().
local attitudestack is mainbox:addstack().
local statusstack is mainbox:addstack().
local orbitstack is mainbox:addstack().
local enginestack is mainbox:addstack().
local crewstack is mainbox:addstack().
local towerstack is mainbox:addstack().
local maneuverstack is mainbox:addstack().
mainbox:showonly(flightstack).


set settingsbutton:ontoggle to {
    parameter toggle.
    if toggle {
        if InhibitPages = false {
            set cargobutton:pressed to false.
            set attitudebutton:pressed to false.
            set statusbutton:pressed to false.
            set orbitbutton:pressed to false.
            set enginebutton:pressed to false.
            set crewbutton:pressed to false.
            set towerbutton:pressed to false.
            set maneuverbutton:pressed to false.
            mainbox:showonly(settingsstack).
        }
        else {
            set settingsbutton:pressed to false.
            set cargobutton:pressed to false.
            set attitudebutton:pressed to false.
            set statusbutton:pressed to false.
            set orbitbutton:pressed to false.
            set enginebutton:pressed to false.
            set crewbutton:pressed to false.
            set towerbutton:pressed to false.
            set maneuverbutton:pressed to false.
        }
    }
    else {mainbox:showonly(flightstack).}
}.

set cargobutton:ontoggle to {
    parameter toggle.
    if toggle {
        if InhibitPages = false {
            set settingsbutton:pressed to false.
            set attitudebutton:pressed to false.
            set statusbutton:pressed to false.
            set orbitbutton:pressed to false.
            set enginebutton:pressed to false.
            set crewbutton:pressed to false.
            set towerbutton:pressed to false.
            set maneuverbutton:pressed to false.
            mainbox:showonly(cargostack).
        }
        else {
            set cargobutton:pressed to false.
            set settingsbutton:pressed to false.
            set attitudebutton:pressed to false.
            set statusbutton:pressed to false.
            set orbitbutton:pressed to false.
            set enginebutton:pressed to false.
            set crewbutton:pressed to false.
            set towerbutton:pressed to false.
            set maneuverbutton:pressed to false.
        }
    }
    else {mainbox:showonly(flightstack).}
}.
    
set attitudebutton:ontoggle to {
    parameter toggle.
    if toggle {
        if InhibitPages = false {
            set settingsbutton:pressed to false.
            set cargobutton:pressed to false.
            set statusbutton:pressed to false.
            set orbitbutton:pressed to false.
            set enginebutton:pressed to false.
            set crewbutton:pressed to false.
            set towerbutton:pressed to false.
            set maneuverbutton:pressed to false.
            mainbox:showonly(attitudestack).
        }
        else {
            set attitudebutton:pressed to false.
            set settingsbutton:pressed to false.
            set cargobutton:pressed to false.
            set statusbutton:pressed to false.
            set orbitbutton:pressed to false.
            set enginebutton:pressed to false.
            set crewbutton:pressed to false.
            set towerbutton:pressed to false.
            set maneuverbutton:pressed to false.
        }
    }
    else {mainbox:showonly(flightstack).}
}.
    
set statusbutton:ontoggle to {
    parameter toggle.
    if toggle {
        set settingsbutton:pressed to false.
        set cargobutton:pressed to false.
        set attitudebutton:pressed to false.
        set orbitbutton:pressed to false.
        set enginebutton:pressed to false.
        set crewbutton:pressed to false.
        set towerbutton:pressed to false.
        set maneuverbutton:pressed to false.
        mainbox:showonly(statusstack).
    }
    else {mainbox:showonly(flightstack).}
}.
    
set orbitbutton:ontoggle to {
    parameter toggle.
    if toggle {
        set settingsbutton:pressed to false.
        set cargobutton:pressed to false.
        set attitudebutton:pressed to false.
        set statusbutton:pressed to false.
        set enginebutton:pressed to false.
        set crewbutton:pressed to false.
        set towerbutton:pressed to false.
        set maneuverbutton:pressed to false.
        mainbox:showonly(orbitstack).
    }
    else {mainbox:showonly(flightstack).}
}.
    
set enginebutton:ontoggle to {
    parameter toggle.
    if toggle {
        set settingsbutton:pressed to false.
        set cargobutton:pressed to false.
        set attitudebutton:pressed to false.
        set statusbutton:pressed to false.
        set orbitbutton:pressed to false.
        set crewbutton:pressed to false.
        set towerbutton:pressed to false.
        set maneuverbutton:pressed to false.
        mainbox:showonly(enginestack).
    }
    else {mainbox:showonly(flightstack).}
}.

set crewbutton:ontoggle to {
    parameter toggle.
    if toggle {
        set g:style:height to 315.
        set settingsbutton:pressed to false.
        set cargobutton:pressed to false.
        set attitudebutton:pressed to false.
        set statusbutton:pressed to false.
        set enginebutton:pressed to false.
        set orbitbutton:pressed to false.
        set towerbutton:pressed to false.
        set maneuverbutton:pressed to false.
        mainbox:showonly(crewstack).
    }
    else {
        set g:style:height to 192.
        mainbox:showonly(flightstack).
    }
}.

set towerbutton:ontoggle to {
    parameter toggle.
    if toggle {
        set settingsbutton:pressed to false.
        set cargobutton:pressed to false.
        set attitudebutton:pressed to false.
        set statusbutton:pressed to false.
        set enginebutton:pressed to false.
        set orbitbutton:pressed to false.
        set crewbutton:pressed to false.
        set maneuverbutton:pressed to false.
        mainbox:showonly(towerstack).
    }
    else {mainbox:showonly(flightstack).}
}.

set maneuverbutton:ontoggle to {
    parameter toggle.
    if toggle {
        set settingsbutton:pressed to false.
        set cargobutton:pressed to false.
        set attitudebutton:pressed to false.
        set statusbutton:pressed to false.
        set enginebutton:pressed to false.
        set orbitbutton:pressed to false.
        set crewbutton:pressed to false.
        set towerbutton:pressed to false.
        mainbox:showonly(maneuverstack).
    }
    else {mainbox:showonly(flightstack).}
}.


local textbox is flightstack:addhlayout().
    set textbox:style:bg to "starship_img/starship_main_square_bg".
local textboxvlayout1 is textbox:addvlayout().
    set textboxvlayout1:style:vstretch to true.
local textboxvlayout2 is textbox:addvlayout().
    set textboxvlayout2:style:bg to "starship_img/starship_main_square_bg".
    set textboxvlayout2:style:vstretch to true.
    set textboxvlayout2:style:width to 150.
local message1 is textboxvlayout1:addlabel().
    set message1:style:wordwrap to false.
    set message1:style:margin:left to 10.
    set message1:style:margin:top to 10.
    set message1:style:width to 450.
    set message1:style:fontsize to 21.
local message2 is textboxvlayout1:addlabel().
    set message2:style:wordwrap to false.
    set message2:style:margin:left to 10.
    set message2:style:width to 450.
    set message2:style:fontsize to 21.
local message3 is textboxvlayout1:addlabel().
    set message3:style:wordwrap to false.
    set message3:style:margin:left to 10.
    set message3:style:width to 450.
    set message3:style:fontsize to 21.
local message12 is textboxvlayout2:addlabel("           0  CREW").
    set message12:style:wordwrap to false.
    set message12:style:margin:top to 8.
    set message12:style:margin:left to 10.
    set message12:style:width to 30.
    set message12:style:height to 30.
    set message12:style:fontsize to 15.
    set message12:tooltip to "Number of Crew onboard / Cargo Mass".
local message22 is textboxvlayout2:addlabel("          AVNCS 0/3").
    set message22:style:wordwrap to false.
    set message22:style:margin:left to 10.
    set message22:style:width to 30.
    set message22:style:height to 30.
    set message22:style:fontsize to 15.
    set message22:style:textcolor to grey.
    set message22:style:bg to "starship_img/starship_chip".
    set message22:tooltip to "Number of basic requirements for the GUI to run".
local message32 is textboxvlayout2:addlabel("          NO COM").
    set message32:style:wordwrap to false.
    set message32:style:margin:left to 10.
    set message32:style:width to 30.
    set message32:style:height to 30.
    set message32:style:fontsize to 15.
    set message32:style:textcolor to grey.
    set message32:style:bg to "starship_img/starship_signal_grey".
    set message32:tooltip to "COM1 (signal with KSC) / DLK (Downlink) or TLM (Telemetry, logging enabled)".

    

local settingsstackhlayout is settingsstack:addhlayout().
    set settingsstackhlayout:style:bg to "starship_img/starship_main_square_bg".
local settingsstackvlayout1 is settingsstackhlayout:addvlayout().
    set settingsstackvlayout1:style:vstretch to 1.
    set settingsstackvlayout1:style:margin:h to 0.
local settingsstackvlayout2 is settingsstackhlayout:addvlayout().
    set settingsstackvlayout2:style:vstretch to 1.
    set settingsstackvlayout2:style:hstretch to 1.
local settingsstackvlayout3 is settingsstackhlayout:addvlayout().

local setting3label is settingsstackvlayout1:addlabel("<b>Target Landing Zone:</b>").
    set setting3label:style:margin:top to 7.
    set setting3label:style:margin:left to 10.
    set setting3label:style:fontsize to 19.
    set setting3label:style:wordwrap to false.
    set setting3label:style:width to 225.
    set setting3label:style:margin:top to 10.
    set setting3label:tooltip to "Ship Landing Target coördinates (e.g. -0.0972,-74.5577). Default = Launchpad".
local setting3 is settingsstackvlayout2:addtextfield("-0.0972,-74.5577").
    set setting3:style:width to 175.
    set setting3:style:margin:top to 10.
    set setting3:tooltip to "           e.g. -0.0972,-74.5577".

local setting1 is settingsstackvlayout1:addcheckbox("<b>  Show Tooltips</b>").
    set setting1:style:margin:left to 10.
    set setting1:style:margin:top to 7.
    set setting1:style:fontsize to 18.
    set setting1:style:bg to "starship_img/starship_toggle_off".
    set setting1:style:on:bg to "starship_img/starship_toggle_on".
    set setting1:style:hover:bg to "starship_img/starship_toggle_hover".
    set setting1:style:hover_on:bg to "starship_img/starship_toggle_hover".
    set setting1:style:active:bg to "starship_img/starship_toggle_off".
    set setting1:style:active_on:bg to "starship_img/starship_toggle_on".
    set setting1:style:width to 225.
    set setting1:style:height to 29.
    set setting1:style:overflow:right to -197.
    set setting1:style:overflow:left to -3.
    set setting1:style:overflow:top to -4.
    set setting1:style:overflow:bottom to -9.
    set setting1:tooltip to "Show tooltips like this one".
local setting2 is settingsstackvlayout1:addcheckbox("<b>  </b>").
    set setting2:style:margin:left to 10.
    set setting2:style:margin:top to 7.
    set setting2:style:bg to "starship_img/starship_toggle_off".
    set setting2:style:on:bg to "starship_img/starship_toggle_on".
    set setting2:style:hover:bg to "starship_img/starship_toggle_hover".
    set setting2:style:hover_on:bg to "starship_img/starship_toggle_hover".
    set setting2:style:active:bg to "starship_img/starship_toggle_off".
    set setting2:style:active_on:bg to "starship_img/starship_toggle_on".
    set setting2:style:width to 225.
    set setting2:style:height to 29.
    set setting2:style:overflow:right to -197.
    set setting2:style:overflow:left to -3.
    set setting2:style:overflow:top to -4.
    set setting2:style:overflow:bottom to -9.
    set setting2:tooltip to "not yet implemented".
    setting2:hide().

local setting4 is settingsstackvlayout2:addcheckbox("<b>  </b>").
    set setting4:style:margin:left to 10.
    set setting4:style:margin:top to 7.
    set setting4:style:bg to "starship_img/starship_toggle_off".
    set setting4:style:on:bg to "starship_img/starship_toggle_on".
    set setting4:style:hover:bg to "starship_img/starship_toggle_hover".
    set setting4:style:hover_on:bg to "starship_img/starship_toggle_hover".
    set setting4:style:active:bg to "starship_img/starship_toggle_off".
    set setting4:style:active_on:bg to "starship_img/starship_toggle_on".
    set setting4:style:width to 175.
    set setting4:style:height to 29.
    set setting4:style:overflow:right to -147.
    set setting4:style:overflow:left to -3.
    set setting4:style:overflow:top to -4.
    set setting4:style:overflow:bottom to -9.
    set setting4:tooltip to "not yet implemented".
    setting4:hide().

local TargetLZPicker is settingsstackvlayout2:addpopupmenu().
    set TargetLZPicker:style:textcolor to white.
    set TargetLZPicker:style:fontsize to 16.
    set TargetLZPicker:style:width to 175.
    set TargetLZPicker:style:border:v to 10.
    set TargetLZPicker:style:border:h to 10.
    set TargetLZPicker:style:bg to "starship_img/starship_background".
    set TargetLZPicker:style:normal:bg to "starship_img/starship_background".
    set TargetLZPicker:style:on:bg to "starship_img/starship_background_light".
    set TargetLZPicker:style:hover:bg to "starship_img/starship_background_light".
    set TargetLZPicker:style:hover_on:bg to "starship_img/starship_background_light".
    set TargetLZPicker:style:active:bg to "starship_img/starship_background_light".
    set TargetLZPicker:style:active_on:bg to "starship_img/starship_background_light".
    set TargetLZPicker:style:focused:bg to "starship_img/starship_background_light".
    set TargetLZPicker:style:focused_on:bg to "starship_img/starship_background_light".
    set TargetLZPicker:options to list("<color=grey><b>Select existing LZ</b></color>", "<b><color=white>KSC Pad</color></b>", "<b><color=white>Desert Pad</color></b>", "<b><color=white>Woomerang Pad</color></b>", "<b><color=white>Custom LZ</color></b>").
    set TargetLZPicker:tooltip to "Select a predefined Landing Zone here:  e.g.  KSC, Desert, Woomerang".

local setting5 is settingsstackvlayout2:addcheckbox("<b>  </b>").
    set setting5:style:margin:left to 10.
    set setting5:style:margin:top to 7.
    set setting5:style:bg to "starship_img/starship_toggle_off".
    set setting5:style:on:bg to "starship_img/starship_toggle_on".
    set setting5:style:hover:bg to "starship_img/starship_toggle_hover".
    set setting5:style:hover_on:bg to "starship_img/starship_toggle_hover".
    set setting5:style:active:bg to "starship_img/starship_toggle_off".
    set setting5:style:active_on:bg to "starship_img/starship_toggle_on".
    set setting5:style:width to 175.
    set setting5:style:height to 29.
    set setting5:style:overflow:right to -147.
    set setting5:style:overflow:left to -3.
    set setting5:style:overflow:top to -4.
    set setting5:style:overflow:bottom to -9.
    set setting5:tooltip to "not yet implemented".
    setting5:hide().

local settingscheckboxes is settingsstackvlayout3:addvbox().
    set settingscheckboxes:style:vstretch to 1.
    set settingscheckboxes:style:margin:right to 0.
    set settingscheckboxes:style:bg to "starship_img/starship_main_square_bg".
local quicksetting1 is settingscheckboxes:addcheckbox("<b>Auto-Warp</b>").
    set quicksetting1:style:margin:top to 12.
    set quicksetting1:style:margin:left to 10.
    set quicksetting1:style:fontsize to 18.
    set quicksetting1:style:width to 150.
    set quicksetting1:style:height to 29.
    set quicksetting1:style:overflow:right to -130.
    set quicksetting1:style:overflow:left to -3.
    set quicksetting1:style:overflow:top to -4.
    set quicksetting1:style:overflow:bottom to -9.
    set quicksetting1:tooltip to "Auto warps the ship through Launch, Maneuvers and Re-Entries".
local quicksetting2 is settingscheckboxes:addcheckbox("<b>  0° Launch</b>").
    set quicksetting2:style:fontsize to 18.
    set quicksetting2:style:margin:left to 10.
    set quicksetting2:style:bg to "starship_img/starship_toggle_off".
    set quicksetting2:style:on:bg to "starship_img/starship_toggle_on".
    set quicksetting2:style:hover:bg to "starship_img/starship_toggle_hover".
    set quicksetting2:style:hover_on:bg to "starship_img/starship_toggle_hover".
    set quicksetting2:style:active:bg to "starship_img/starship_toggle_off".
    set quicksetting2:style:active_on:bg to "starship_img/starship_toggle_on".
    set quicksetting2:style:width to 150.
    set quicksetting2:style:height to 29.
    set quicksetting2:style:overflow:right to -122.
    set quicksetting2:style:overflow:left to -3.
    set quicksetting2:style:overflow:top to -4.
    set quicksetting2:style:overflow:bottom to -9.
    set quicksetting2:tooltip to "Ship Attitude during Launch: 0° = cockpit up. 180° = cockpit down".
local quicksetting3 is settingscheckboxes:addcheckbox("<b>Log Data</b>").
    set quicksetting3:toggle to true.
    set quicksetting3:style:fontsize to 18.
    set quicksetting3:style:margin:left to 10.
    set quicksetting3:style:width to 150.
    set quicksetting3:style:height to 29.
    set quicksetting3:style:overflow:right to -130.
    set quicksetting3:style:overflow:left to -3.
    set quicksetting3:style:overflow:top to -4.
    set quicksetting3:style:overflow:bottom to -9.
    set quicksetting3:tooltip to "Flight Data Recorder. Saves data in 'KSP folder'/Ships/Script".


set setting1:ontoggle to {
    parameter pressed.
    if pressed {
        SaveToSettings("Setting1", "true").
        set setting1:text to "<b>  Don't show Tooltips</b>".
    }
    if not pressed {
        SaveToSettings("Setting1", "false").
        set setting1:text to "<b>  Show Tooltips</b>".
    }
}.


set setting2:ontoggle to {
    parameter pressed.
    if pressed {
        SaveToSettings("Setting2", "true").
        set setting2:text to "<b>  </b>".
    }
    if not pressed {
        SaveToSettings("Setting2", "false").
        set setting2:text to "<b>  </b>".
    }
}.

set setting3:onconfirm to {
    parameter value.
    if value = "" {
        if homeconnection:isconnected {
            if exists("0:/settings.json") {
                if L:haskey("Launch Coordinates") {
                    set value to L["Launch Coordinates"].
                    set value2 to value:split(",").
                    set landingzone to latlng(value2[0]:toscalar, value2[1]:toscalar).
                }
            }
        }
        else {
            set value to "-0.0972,-74.5577".
            set landingzone to latlng(-0.0972,-74.5577).
        }
        set setting3:text to value.
        SaveToSettings("Landing Coordinates", value).
    }
    else {
        set value to value:split(",").
        if value[0]:toscalar(-9999) = -9999 or value[1]:toscalar(-9999) = -9999 {
            set value to "-0.0972,-74.5577".
            set setting3:text to value.
            SetAccurateLandingZone().
            SaveToSettings("Landing Coordinates", value).
        }
        else {
            set landingzone to latlng(value[0]:toscalar, value[1]:toscalar).
            if KUniverse:activevessel = vessel(ship:name) {
                ADDONS:TR:SETTARGET(landingzone).
            }
            SaveToSettings("Landing Coordinates", (value[0]:toscalar + "," + value[1]:toscalar):tostring).
        }
    }
}.


set TargetLZPicker:onchange to {
    parameter choice.
    if choice = "<b><color=white>KSC Pad</color></b>" {
        set setting3:text to "-0.0972,-74.5577".
        set landingzone to latlng(-0.0972,-74.5577).
        if homeconnection:isconnected {
            SaveToSettings("Landing Coordinates", "-0.0972,-74.5577").
        }
    }
    if choice = "<b><color=white>Desert Pad</color></b>" {
        set setting3:text to "-6.5604,-143.95".
        set landingzone to latlng(-6.5604,-143.95).
        if homeconnection:isconnected {
            SaveToSettings("Landing Coordinates", "-6.5604,-143.95").
        }
    }
    if choice = "<b><color=white>Woomerang Pad</color></b>" {
        set setting3:text to "45.2896,136.11".
        set landingzone to latlng(45.2896,136.11).
        if homeconnection:isconnected {
            SaveToSettings("Landing Coordinates", "45.2896,136.11").
        }
    }
    if choice = "<b><color=white>Custom LZ</color></b>" {
        set setting3:text to CustomLZ.
        set landingzone to latlng(CustomLZ:split(",")[0]:toscalar(0), CustomLZ:split(",")[1]:toscalar(0)).
        if homeconnection:isconnected {
            SaveToSettings("Landing Coordinates", CustomLZ).
        }
    }
}.


set setting4:ontoggle to {
    parameter pressed.
    if pressed {
        SaveToSettings("Setting4", "true").
        set setting4:text to "<b>  </b>".
    }
    if not pressed {
        SaveToSettings("Setting4", "false").
        set setting4:text to "<b>  </b>".
    }
}.


set setting5:ontoggle to {
    parameter pressed.
    if pressed {
        SaveToSettings("Setting5", "true").
        set setting5:text to "<b>  </b>".
    }
    if not pressed {
        SaveToSettings("Setting5", "false").
        set setting5:text to "<b>  </b>".
    }
}.


set quicksetting1:ontoggle to {
    parameter pressed.
    if pressed {
        SaveToSettings("Auto-Warp", "true").
    }
    if not pressed {
        SaveToSettings("Auto-Warp", "false").
    }
}.


set quicksetting2:ontoggle to {
    parameter pressed.
    if pressed {
        SaveToSettings("Roll", "0").
        set quicksetting2:text to "<b>  0° Launch</b>".
    }
    if not pressed {
        SaveToSettings("Roll", "180").
        set quicksetting2:text to "<b>  180° Launch</b>".
    }
}.


set quicksetting3:ontoggle to {
    parameter pressed.
    if pressed {
        if exists("0:/LaunchData.csv") {
            if ship:status = "PRELAUNCH" {
                deletepath("0:/LaunchData.csv").
            }
        }
        if exists("0:/LandingData.csv") {
            deletepath("0:/LandingData.csv").
        }
        if exists("0:/FlightData.txt") {
            deletepath("0:/FlightData.txt").
        }
        if defined PrevLogTime {
            unset PrevLogTime.
        }
        SaveToSettings("Log Data", "true").
        set Logging to true.
        LogToFile("Flight Data Recorder Started").
    }
    if not pressed {
        SaveToSettings("Log Data", "false").
        set Logging to false.
    }
}.

local cargostackhlayout to cargostack:addhlayout().
    set cargostackhlayout:style:bg to "starship_img/starship_main_square_bg".
local cargostackvlayout1 is cargostackhlayout:addvlayout().
local cargostackvlayout2 is cargostackhlayout:addvlayout().
local cargostackvlayout3 is cargostackhlayout:addvlayout().
local cargostackvlayout4 is cargostackhlayout:addvlayout().
local cargostackvlayout5 is cargostackhlayout:addvlayout().
local cargostackvlayout6 is cargostackhlayout:addvlayout().
local cargo1label is cargostackvlayout1:addlabel("<b>Hatch:</b>").
    set cargo1label:style:fontsize to 20.
    set cargo1label:style:width to 75.
    set cargo1label:style:wordwrap to false.
    set cargo1label:style:align to "CENTER".
    set cargo1label:style:margin:top to 7.
local cargo1text is cargostackvlayout2:addlabel("Locked").
    set cargo1text:style:fontsize to 19.
    set cargo1text:style:width to 75.
    set cargo1text:style:margin:top to 7.
    set cargo1text:tooltip to "Door Status".
local cargo1button is cargostackvlayout3:addbutton("<>").
    set cargo1button:style:align to "CENTER".
    set cargo1button:style:width to 35.
    set cargo1button:style:height to 25.
    set cargo1button:style:fontsize to 20.
    set cargo1button:style:margin:top to 7.
    set cargo1button:tooltip to "Open/Close the Hatch/Cargo Door".
local cargoimage is cargostackvlayout4:addlabel().
    set cargoimage:style:width to 80.
    set cargoimage:style:height to 100.
    set cargoimage:style:margin:top to 7.
    set cargoimage:style:bg to "starship_img/starship_cargobay_closed".
    set cargoimage:tooltip to "Visual Representation of current hatch status".
local cargo1label2 is cargostackvlayout5:addlabel("<b>Cargo:</b>").
    set cargo1label2:style:width to 100.
    set cargo1label2:style:fontsize to 20.
    set cargo1label2:style:wordwrap to false.
    set cargo1label2:style:align to "CENTER".
    set cargo1label2:style:margin:top to 7.
    set cargo1label2:tooltip to "Cargo found onboard will be shown here".
local cargo2label is cargostackvlayout1:addlabel("<b>Winch:</b>").
    set cargo2label:style:align to "CENTER".
    set cargo2label:style:margin:top to 25.
    set cargo2label:style:fontsize to 20.
    set cargo2label:tooltip to "not yet implemented".
local cargo2extend is cargostackvlayout2:addbutton("<").
    set cargo2extend:style:margin:top to 10.
    set cargo2extend:style:margin:right to 10.
    set cargo2extend:style:width to 25.
    set cargo2extend:style:height to 25.
    set cargo2extend:style:fontsize to 20.
    set cargo2extend:tooltip to "not yet implemented".
local cargo2retract is cargostackvlayout3:addbutton(">").
    set cargo2retract:style:margin:top to 10.
    set cargo2retract:style:width to 25.
    set cargo2retract:style:height to 25.
    set cargo2retract:style:fontsize to 20.
    set cargo2retract:tooltip to "not yet implemented".
local cargo2label2 is cargostackvlayout5:addlabel("-").
    set cargo2label2:style:width to 100.
    set cargo2label2:style:fontsize to 19.
    set cargo2label2:style:wordwrap to false.
    set cargo2label2:style:align to "CENTER".
    set cargo2label2:style:margin:top to 7.
    set cargo2label2:style:textcolor to grey.
    set cargo2label2:tooltip to "Cargo Mass in kg".
local cargo3lower is cargostackvlayout2:addbutton("v").
    set cargo3lower:style:margin:top to 10.
    set cargo3lower:style:margin:right to 10.
    set cargo3lower:style:width to 25.
    set cargo3lower:style:height to 25.
    set cargo3lower:style:fontsize to 20.
    set cargo3lower:tooltip to "not yet implemented".
local cargo3raise is cargostackvlayout3:addbutton("^").
    set cargo3raise:style:margin:top to 10.
    set cargo3raise:style:width to 25.
    set cargo3raise:style:height to 25.
    set cargo3raise:style:fontsize to 20.
    set cargo3raise:tooltip to "not yet implemented".
local cargo3label2 is cargostackvlayout5:addlabel("-").
    set cargo3label2:style:width to 100.
    set cargo3label2:style:fontsize to 19.
    set cargo3label2:style:wordwrap to false.
    set cargo3label2:style:align to "CENTER".
    set cargo3label2:style:margin:top to 7.
    set cargo3label2:style:textcolor to grey.
    set cargo3label2:tooltip to "index units define the Center of Gravity of the Ship (max 125 i.u. for re-entry)".
    
local cargocheckboxes is cargostackvlayout6:addvbox().
    set cargocheckboxes:style:margin:right to 0.
    set cargocheckboxes:style:vstretch to 1.
    set cargocheckboxes:style:bg to "starship_img/starship_main_square_bg".
local quickcargo1 is cargocheckboxes:addcheckbox("<b>Dome Light</b>").
    set quickcargo1:style:margin:top to 12.
    set quickcargo1:style:margin:left to 10.
    set quickcargo1:style:fontsize to 18.
    set quickcargo1:style:width to 150.
    set quickcargo1:style:height to 29.
    set quickcargo1:style:overflow:right to -130.
    set quickcargo1:style:overflow:left to -3.
    set quickcargo1:style:overflow:top to -4.
    set quickcargo1:style:overflow:bottom to -9.
    set quickcargo1:tooltip to "Toggle Dome Light (function to be expanded)".
local quickcargo2 is cargocheckboxes:addcheckbox("<b>Solar Panels</b>").
    set quickcargo2:style:margin:left to 10.
    set quickcargo2:style:fontsize to 18.
    set quickcargo2:style:width to 150.
    set quickcargo2:style:height to 29.
    set quickcargo2:style:overflow:right to -130.
    set quickcargo2:style:overflow:left to -3.
    set quickcargo2:style:overflow:top to -4.
    set quickcargo2:style:overflow:bottom to -9.
    set quickcargo2:tooltip to "Toggle Solar Panels".
local quickcargo3 is cargocheckboxes:addcheckbox("<b>LR Antenna</b>").
    set quickcargo3:style:margin:left to 10.
    set quickcargo3:style:fontsize to 18.
    set quickcargo3:style:width to 150.
    set quickcargo3:style:height to 29.
    set quickcargo3:style:overflow:right to -130.
    set quickcargo3:style:overflow:left to -3.
    set quickcargo3:style:overflow:top to -4.
    set quickcargo3:style:overflow:bottom to -9.
    set quickcargo3:tooltip to "not yet implemented".

set quickcargo1:ontoggle to {
    parameter click.
    if click {
        lights on.
    }
    else {
        lights off.
    }
}.

set quickcargo2:ontoggle to {
    parameter click.
    if click {
        panels on.
    }
    else {
        panels off.
    }
}.

set quickcargo3:ontoggle to {
    parameter click.
    if click {

    }
    else {

    }
}.

set cargo1button:onclick to {
    set CargoBayOperationComplete to false.
    set CargoBayDoorHalfOpen to false.
    set CargoBayOperationStart to time:seconds.
    if ShipType = "Cargo" {
        nose[0]:getmodule("ModuleAnimateGeneric"):DoAction("toggle cargo door", true).
    }
    else {
        nose[0]:getmodule("ModuleAnimateGeneric"):DoAction("toggle docking hatch", true).
    }
    set cargo1text:text to nose[0]:getmodule("ModuleAnimateGeneric"):getfield("status").
    set cargo1text:style:textcolor to cyan.
    if ShipType = "Cargo" {
        when time:seconds > CargoBayOperationStart + 1.55 and not CargoBayDoorHalfOpen then {
            set CargoBayDoorHalfOpen to true.
            set cargoimage:style:bg to "starship_img/starship_cargobay_moving".
        }
    }
    else {
        when time:seconds > CargoBayOperationStart + 1.55 and not CargoBayDoorHalfOpen then {
            set CargoBayDoorHalfOpen to true.
            set cargoimage:style:bg to "starship_img/starship_crew_hatch_moving".
        }
    }
    when time:seconds > CargoBayOperationStart + 3.1 then {
        if ShipType = "Cargo" {
            if nose[0]:getmodule("ModuleAnimateGeneric"):hasevent("close cargo door") {
                set cargoimage:style:bg to "starship_img/starship_cargobay_open".
                set cargo1text:text to "Open".
                set cargo1text:style:textcolor to yellow.
            }
            else {
                set cargoimage:style:bg to "starship_img/starship_cargobay_closed".
                set cargo1text:text to "Closed".
                set cargo1text:style:textcolor to green.
            }
            LogToFile("Cargo Door Operation Complete").
        }
        else {
            if nose[0]:getmodule("ModuleAnimateGeneric"):hasevent("close docking hatch") {
                set cargoimage:style:bg to "starship_img/starship_crew_hatch_open".
                set cargo1text:text to "Open".
                set cargo1text:style:textcolor to yellow.
            }
            else {
                set cargoimage:style:bg to "starship_img/starship_crew_hatch_closed".
                set cargo1text:text to "Closed".
                set cargo1text:style:textcolor to green.
            }
        }
    }
}.
    

local attitudestackhlayout to attitudestack:addhlayout().
    set attitudestackhlayout:style:bg to "starship_img/starship_main_square_bg".
local attitudestackvlayout1 is attitudestackhlayout:addvlayout().
    set attitudestackvlayout1:style:vstretch to 1.
local attitudestackvlayout2 is attitudestackhlayout:addvlayout().
local attitudestackvlayout3 is attitudestackhlayout:addvlayout().
local attitudestackvlayout4 is attitudestackhlayout:addvlayout().
local attitudestackvlayout5 is attitudestackhlayout:addvlayout().
local attitude1label is attitudestackvlayout1:addlabel("<b>AoA & Roll command:</b>").
    set attitude1label:style:fontsize to 19.
    set attitude1label:style:align to "CENTER".
    set attitude1label:style:margin:left to 20.
    set attitude1label:style:margin:top to 7.
    set attitude1label:style:wordwrap to false.
    set attitude1label:tooltip to "Manual Attitude Control (Landing armed @ 10km Radar Altitude)".
local attitude1text is attitudestackvlayout3:addtextfield(aoa:tostring).
    set attitude1text:style:fontsize to 19.
    set attitude1text:style:margin:top to 10.
    set attitude1text:style:width to 50.
local attitude1text2 is attitudestackvlayout4:addtextfield("0").
    set attitude1text2:style:fontsize to 19.
    set attitude1text2:style:margin:top to 10.
    set attitude1text2:style:width to 60.
local attitude2label is attitudestackvlayout1:addlabel("AoA: -").
    set attitude2label:style:align to "CENTER".
    set attitude2label:style:margin:top to 10.
    set attitude2label:style:margin:left to 20.
    set attitude2label:style:fontsize to 19.
    set attitude2label:style:textcolor to grey.
    set attitude2label:tooltip to "Current AoA. Trk/X-Track Error shown < 50km Alt (Kerbin) / 35km Alt (Duna)".
    set attitude2label:style:wordwrap to false.
    set attitude2label:style:width to 200.
    set attitude2label:style:bg to "starship_img/attitude_page_background".
    set attitude2label:style:overflow:left to -155.
    set attitude2label:style:overflow:right to 25.
    set attitude2label:style:overflow:top to -5.
    set attitude2label:style:overflow:bottom to 40.
local attitude2up is attitudestackvlayout3:addbutton("^").
    set attitude2up:style:margin:top to 10.
    set attitude2up:style:margin:left to 17.
    set attitude2up:style:width to 25.
    set attitude2up:style:height to 25.
    set attitude2up:style:fontsize to 20.
local attitude3button is attitudestackvlayout1:addbutton("<b>RESET</b>").
    set attitude3button:style:margin:top to 12.
    set attitude3button:style:margin:left to 85.
    set attitude3button:style:width to 75.
    set attitude3button:style:height to 25.
    set attitude3button:style:fontsize to 18.
    set attitude3button:tooltip to "Reset to 67° (Kerbin) or 60° (Duna) Angle-of-Attack / 0° Roll".
local attitude3left is attitudestackvlayout2:addbutton("<").
    set attitude3left:style:margin:top to 65.
    set attitude3left:style:margin:left to 20.
    set attitude3left:style:width to 25.
    set attitude3left:style:height to 25.
    set attitude3left:style:fontsize to 20.
local attitude3right is attitudestackvlayout4:addbutton(">").
    set attitude3right:style:margin:top to 27.
    set attitude3right:style:width to 25.
    set attitude3right:style:height to 25.
    set attitude3right:style:fontsize to 20.
local attitude3down is attitudestackvlayout3:addbutton("v").
    set attitude3down:style:margin:top to 10.
    set attitude3down:style:margin:left to 17.
    set attitude3down:style:width to 25.
    set attitude3down:style:height to 25.
    set attitude3down:style:fontsize to 20.
local attituderadiobuttons is attitudestackvlayout5:addvbox().
    set attituderadiobuttons:style:margin:right to 0.
    set attituderadiobuttons:style:vstretch to 1.
    set attituderadiobuttons:style:bg to "starship_img/starship_main_square_bg".
local quickattitude1 is attituderadiobuttons:addradiobutton("<b>Off</b>").
    set quickattitude1:pressed to 1.
    set quickattitude1:style:margin:top to 12.
    set quickattitude1:style:margin:left to 10.
    set quickattitude1:style:fontsize to 18.
    set quickattitude1:style:width to 150.
    set quickattitude1:style:height to 29.
    set quickattitude1:style:overflow:right to -130.
    set quickattitude1:style:overflow:left to -3.
    set quickattitude1:style:overflow:top to -4.
    set quickattitude1:style:overflow:bottom to -9.
    set quickattitude1:tooltip to "Disable Attitude Control".
local quickattitude2 is attituderadiobuttons:addradiobutton("<b>ATT Control</b>").
    set quickattitude2:style:margin:left to 10.
    set quickattitude2:style:fontsize to 18.
    set quickattitude2:style:width to 150.
    set quickattitude2:style:height to 29.
    set quickattitude2:style:overflow:right to -130.
    set quickattitude2:style:overflow:left to -3.
    set quickattitude2:style:overflow:top to -4.
    set quickattitude2:style:overflow:bottom to -9.
    set quickattitude2:tooltip to "Manual Attitude Control (Landing armed @ 10km Radar Altitude)".
local quickattitude3 is attituderadiobuttons:addcheckbox("<b>RCS ON</b>").
    set quickattitude3:style:margin:left to 10.
    set quickattitude3:style:fontsize to 18.
    set quickattitude3:style:width to 150.
    set quickattitude3:style:height to 29.
    set quickattitude3:style:overflow:right to -130.
    set quickattitude3:style:overflow:left to -3.
    set quickattitude3:style:overflow:top to -4.
    set quickattitude3:style:overflow:bottom to -9.
    set quickattitude3:tooltip to "Force RCS ON during Attitude Control".

set attitude1text:onconfirm to {
    parameter string.
    if string = "" {
        set attitude1text:text to (aoa):tostring.
        set attpitch to aoa.
    }
    else {
        if string:toscalar(-9999) = -9999 {
            set attitude1text:text to (prevattpitch):tostring.
        }
        else {
            if string:toscalar > 85 {
                set attitude1text:text to (85):tostring.
                set attpitch to 85.
            }
            else if string:toscalar < 0 {
                set attitude1text:text to (0):tostring.
                set attpitch to 0.
            }
            else {
                set attpitch to string:toscalar.
            }
            set prevattpitch to attpitch.
        }
    }
}.

set attitude1text2:onconfirm to {
    parameter string.
    if string = "" {
        set attroll to 0.
        set attitude1text2:text to (0):tostring.
    }
    else {
        if string:toscalar(-9999) = -9999 {
            set attitude1text2:text to (prevattroll):tostring.
        }
        else {
            if string:toscalar > 60 {
                set attitude1text2:text to (60):tostring.
                set attroll to 60.
            }
            else if string:toscalar < -60 {
                set attitude1text2:text to (-60):tostring.
                set attroll to -60.
            }
            else {
                set attroll to string:toscalar.
            }
            set prevattroll to attroll.
        }
    }
}.

set quickattitude1:onclick to {
    set attitude2label:text to "<b><size=19>AoA: -</size></b>".
    set attitude2label:style:align to "CENTER".
    set attitude2label:style:textcolor to grey.
    set attitude2label:style:bg to "starship_img/attitude_page_background".
    Nose[0]:getmodule("ModuleRCSFX"):SetField("thrust limiter", 100).
    Tank[0]:getmodule("ModuleRCSFX"):SetField("thrust limiter", 100).
    unlock steering.
    SetPlanetData().
    sas on.
    rcs off.
    set quickstatus1:pressed to false.
    set attitude1text:text to (aoa):tostring.
    set attitude1text2:text to (0):tostring.
    set runningprogram to "None".
    LogToFile("Attitude Control Set to OFF").
}.

set quickattitude2:onclick to {
    if not AttitudeIsRunning {
        if ship:body = BODY("Kerbin") or ship:body = BODY("Duna") {
            SetPlanetData().
            set AttitudeIsRunning to true.
            if LaunchButtonIsRunning or LandButtonIsRunning or ship:status = "LANDED" or ship:status = "PRELAUNCH" {
                set quickattitude2:text to "<b><color=red>ATT Control</color></b>".
                wait 0.25.
                set quickattitude2:text to "<b>ATT Control</b>".
                set quickattitude1:pressed to true.
            }
            else {
                set attitudebutton:style:bg to "starship_img/starship_attitude_running".
                set attitudebutton:style:on:bg to "starship_img/starship_attitude_running_on".
                set attitudebutton:style:hover:bg to "starship_img/starship_attitude_running_hover".
                set attitudebutton:style:hover_on:bg to "starship_img/starship_attitude_running_on".
                set attitudebutton:style:active:bg to "starship_img/starship_attitude_running_hover".
                set attitudebutton:style:active_on:bg to "starship_img/starship_attitude_running_hover".
                SetPlanetData().
                set addons:tr:descentmodes to list(true, true, true, true).
                set addons:tr:descentgrades to list(false, false, false, false).
                set addons:tr:descentangles to list(aoa, aoa, aoa, aoa).
                SetRadarAltitude().
                LogToFile("Attitude Control Set to ON").
                Droppriority().
                sas off.
                set quickstatus1:pressed to true.
                if AbortInProgress {
                    set quickattitude3:pressed to true.
                }
                set quickattitude2:text to "<b><color=green>ATT Control</color></b>".
                set attpitch to attitude1text:text:toscalar.
                set attroll to attitude1text2:text:toscalar.
                SetRadarAltitude().
                set flapcargomasscorr to round(10 - ((Cargo / 10000) * 10)).
                if flapcargomasscorr < 0 and ship:body = BODY("Kerbin") {
                    set flapcargomasscorr to 0.
                }
                if flapcargomasscorr < 0 and ship:body = BODY("Duna") {
                    set flapcargomasscorr to 0.75 * flapcargomasscorr.
                }
                lock steering to AttitudeSteering().
                wait until quickattitude1:pressed or RadarAlt < 10000.
                if RadarAlt < 10000 {
                    unlock steering.
                    set quickattitude1:pressed to true.
                    GoHome().
                    sas on.
                    ReEntryAndLand().
                }
                set quickattitude2:text to "<b>ATT Control</b>".
                set attitudebutton:style:bg to "starship_img/starship_attitude".
                set attitudebutton:style:on:bg to "starship_img/starship_attitude_on".
                set attitudebutton:style:hover:bg to "starship_img/starship_attitude_hover".
                set attitudebutton:style:hover_on:bg to "starship_img/starship_attitude_on".
                set attitudebutton:style:active:bg to "starship_img/starship_attitude_hover".
                set attitudebutton:style:active_on:bg to "starship_img/starship_attitude_hover".
                LogToFile("Attitude Control Cancelled").
            }
            set AttitudeIsRunning to false.
        }
        else {
            set quickattitude2:text to "<b><color=red>ATT Control</color></b>".
            wait 0.25.
            set quickattitude2:text to "<b>ATT Control</b>".
            set quickattitude1:pressed to true.
        }
    }
}.

function AttitudeSteering {
    if quickattitude3:pressed {rcs on.} else {rcs off.}
    if airspeed < 450 and kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
    set runningprogram to "Attitude (Landing Armed)".
    set status1:style:textcolor to green.

    if attitude1text:text:toscalar(-9999) = -9999 {}
    else {
        if attitude1text:text:toscalar = attpitch {}
        else {
            set attpitch to attitude1text:text:toscalar.
        }
    }
    if attitude1text2:text:toscalar(-9999) = -9999 {}
    else {
        if attitude1text2:text:toscalar = attroll {}
        else {
            set attroll to attitude1text2:text:toscalar.
        }
    }
    set ManualAoA to attitude1text:text:toscalar(67).
    set addons:tr:descentangles to list(ManualAoA, ManualAoA, ManualAoA, ManualAoA).

    set result to srfprograde * R(- attpitch * cos(attroll), attpitch * sin(attroll), 0).

    set AoAError to vang(result:vector, facing:forevector).
    set AoAErrorRate to AoAError - PreviousAoAError.
    if AoAError > 5 and RadarAlt > 5000 {
        rcs on.
        set IdealRCS to max(AoAErrorRate + (2 * AoAError), 5).
        if quickattitude3:pressed {
            Nose[0]:getmodule("ModuleRCSFX"):SetField("thrust limiter", 100).
            Tank[0]:getmodule("ModuleRCSFX"):SetField("thrust limiter", 100).
        }
        else {
            Nose[0]:getmodule("ModuleRCSFX"):SetField("thrust limiter", min(ship:mass / 60, 1.25) * IdealRCS).
            Tank[0]:getmodule("ModuleRCSFX"):SetField("thrust limiter", min(ship:mass / 60, 1.25) * IdealRCS).
        }
    }
    else if RadarAlt > 2500 {
        if quickattitude3:pressed {rcs on.} else {rcs off.}
        Nose[0]:getmodule("ModuleRCSFX"):SetField("thrust limiter", 100).
        Tank[0]:getmodule("ModuleRCSFX"):SetField("thrust limiter", 100).
    }
    set PreviousAoAError to vang(result:vector, facing:forevector).

    if addons:tr:hasimpact {
        set LngLatErrorList to LngLatError().
        set flapcorr to -1 * LngLatErrorList[0] / 10000.
        if flapcorr > 10 {set flapcorr to 10.}
        if flapcorr < -10 {set flapcorr to -10.}
        if ship:body = BODY("Kerbin") {
            setflaps(55 + flapcorr + flapcargomasscorr, 50 + flapcorr, 1, 30).
        }
        if ship:body = BODY("Duna") {
            setflaps(55 + flapcorr + flapcargomasscorr, 50 + flapcorr - 0.5 * flapcargomasscorr, 1, 30).
        }
    }

    if RadarAlt > 50000 and ship:body = BODY("Kerbin") or RadarAlt > 35000 and ship:body = BODY("Duna") {
        set attitude2label:style:align to "CENTER".
        set attitude2label:text to "<b><size=19><color=magenta>AoA: " + round(vang(ship:facing:forevector, velocity:surface), 1) + "°</color></size></b>".
        set attitude2label:style:bg to "starship_img/attitude_page_background".
    }
    else {
        set attitude2label:style:bg to "".
        set attitude2label:style:align to "LEFT".
        if FacingTheWrongWay {
            set attitude2label:text to "<b><size=15><color=magenta>AoA: " + round(vang(ship:facing:forevector, velocity:surface), 1) + "°</color>  <color=yellow>Facing away from Target</color></size></b>".
        }
        else if addons:tr:hasimpact {
            set attitude2label:text to "<b><size=15><color=magenta>AoA: " + round(vang(ship:facing:forevector, velocity:surface), 1) + "°</color>  <color=cyan>Trk: " + round((LngLatErrorList[0] - LandingOffset)) + "m X-Trk: " + round(LngLatErrorList[1]) + "m</color></size></b>".
        }
        else {
            set attitude2label:text to "<b><size=19><color=magenta>AoA: " + round(vang(ship:facing:forevector, velocity:surface), 1) + "°</color></size></b>".
        }
    }

    if RadarAlt < 10000 and not ClosingIsRunning {
        if LngLatErrorList[0] > 500 or LngLatErrorList[0] < -500 or LngLatErrorList[1] > 250 or LngLatErrorList[1] < -250 {
            set message3:style:textcolor to yellow.
        }
        else {
            set message3:style:textcolor to white.
        }
    }
    if not BGUisRunning {
        BackGroundUpdate().
    }
    return lookdirup(result:vector, vxcl(velocity:surface, result:vector)).
}

set attitude2up:onclick to {
    if attpitch = 85 {}
    else {
        set attpitch to attpitch + 1.
        set attitude1text:text to (attpitch):tostring.
    }
}.
set attitude3down:onclick to {
    if attpitch = 0 {}
    else {
        set attpitch to attpitch - 1.
        set attitude1text:text to (attpitch):tostring.
    }
}.
set attitude3left:onclick to {
    if attroll = -60 {}
    else {
        set attroll to attroll - 1.
        set attitude1text2:text to (attroll):tostring.
    }
}.
set attitude3right:onclick to {
    if attroll = 60 {}
    else {
        set attroll to attroll + 1.
        set attitude1text2:text to (attroll):tostring.
    }
}.
set attitude3button:onclick to {
    set attpitch to aoa.
    set attroll to 0.
    set attitude1text:text to (attpitch):tostring.
    set attitude1text2:text to (attroll):tostring.
}.



local statusstackhlayout to statusstack:addhlayout().
    set statusstackhlayout:style:bg to "starship_img/starship_main_square_bg".
local statusstackvlayout1 is statusstackhlayout:addvlayout().
    set statusstackvlayout1:style:vstretch to 1.
local statusstackvlayout2 is statusstackhlayout:addvlayout().
local statusstackvlayout3 is statusstackhlayout:addvlayout().
local statusstackvlayout4 is statusstackhlayout:addvlayout().
local statusstackvlayout5 is statusstackhlayout:addvlayout().
local statusstackvlayout6 is statusstackhlayout:addvlayout().

    
local status1label1 is statusstackvlayout1:addlabel().
    set status1label1:style:margin:left to 10.
    set status1label1:style:margin:top to 25.
    set status1label1:style:width to 50.
    set status1label1:style:fontsize to 19.
    set status1label1:style:align to "CENTER".
    set status1label1:style:wordwrap to false.
    set status1label1:tooltip to "Left Hand Forward Flap Angle Command".
local status1label2 is statusstackvlayout2:addlabel("<b>FLAP      ANGLE</b>").
    set status1label2:style:margin:left to 5.
    set status1label2:style:margin:top to 3.
    set status1label2:style:width to 50.
    set status1label2:style:align to "CENTER".
    set status1label2:style:fontsize to 18.
    set status1label2:style:overflow:left to 50.
    set status1label2:style:overflow:right to 0.
    set status1label2:style:wordwrap to false.
local status1label3 is statusstackvlayout3:addlabel().
    set status1label3:style:margin:top to 25.
    set status1label3:style:fontsize to 19.
    set status1label3:style:align to "LEFT".
    set status1label3:style:wordwrap to false.
    set status1label3:tooltip to "Right Hand Forward Flap Angle Command".
local status1label4 is statusstackvlayout4:addlabel().
    set status1label4:style:margin:top to 5.
    set status1label4:style:margin:left to 20.
    set status1label4:style:fontsize to 16.
    set status1label4:style:align to "LEFT".
    set status1label4:style:width to 110.
    set status1label4:style:wordwrap to false.
    set status1label4:tooltip to "Current Angle-of-Attack".
local status1label5 is statusstackvlayout5:addlabel().
    set status1label5:style:margin:top to 5.
    set status1label5:style:margin:left to 20.
    set status1label5:style:fontsize to 16.
    set status1label5:style:align to "LEFT".
    set status1label5:style:width to 105.
    set status1label5:style:wordwrap to false.
    set status1label5:tooltip to "Current Ship Mass in metric tons".
    
local status2label1 is statusstackvlayout1:addlabel("-").
    set status2label1:style:textcolor to grey.
    set status2label1:style:margin:left to 5.
    set status2label1:style:width to 50.
    set status2label1:style:wordwrap to false.
    set status2label1:style:fontsize to 12.
    set status2label1:style:align to "LEFT".
    set status2label1:tooltip to "Left Hand Heat-Tile Surface Temperature".
local status2label2 is statusstackvlayout2:addlabel().
    set status2label2:style:bg to "starship_img/starship_symbol".
    set status2label2:style:margin:top to 3.
    set status2label2:style:width to 50.
    set status2label2:style:height to 50.
    set status2label2:style:overflow:top to 25.
    set status2label2:style:overflow:bottom to 25.
    set status2label2:style:overflow:left to 1.
    set status2label2:style:overflow:right to -19.
    set status2label2:tooltip to "Visual Representation of the Hull".
    
local status2label3 is statusstackvlayout3:addlabel("-").
    set status2label3:style:textcolor to grey.
    set status2label3:style:width to 50.
    set status2label3:style:wordwrap to false.
    set status2label3:style:fontsize to 12.
    set status2label3:style:align to "CENTER".
    set status2label3:tooltip to "Right Hand Heat-Tile Surface Temperature".
local status2label4 is statusstackvlayout4:addlabel().
    set status2label4:style:fontsize to 16.
    set status2label4:style:align to "LEFT".
    set status2label4:style:margin:left to 20.
    set status2label4:style:wordwrap to false.
    set status2label4:style:width to 110.
    set status2label4:style:bg to "starship_img/starship_background_white".
    set status2label4:style:border:h to 10.
    set status2label4:style:border:v to 10.
    set status2label4:style:overflow:left to -135.
    set status2label4:style:overflow:right to 128.
    set status2label4:style:overflow:bottom to -1.
    set status2label4:tooltip to "Dynamic Pressure in kPa (orange during max-Q at launch)".
local status2label5 is statusstackvlayout5:addlabel().
    set status2label5:style:margin:left to 20.
    set status2label5:style:fontsize to 16.
    set status2label5:style:align to "CENTER".
    set status2label5:style:wordwrap to false.
    set status2label5:style:width to 105.
    set status2label5:style:bg to "starship_img/starship_background_dark_opacity0".
    set status2label5:style:border:h to 10.
    set status2label5:style:border:v to 10.
    set status2label5:tooltip to "% Methane Fuel Remaining".
    
local status3label1 is statusstackvlayout1:addlabel().
    set status3label1:style:margin:left to 10.
    set status3label1:style:width to 50.
    set status3label1:style:fontsize to 19.
    set status3label1:style:align to "CENTER".
    set status3label1:style:wordwrap to false.
    set status3label1:tooltip to "Left Hand Aft Flap Angle Command".
local status3label3 is statusstackvlayout3:addlabel().
    set status3label3:style:width to 50.
    set status3label3:style:fontsize to 19.
    set status3label3:style:align to "LEFT".
    set status3label3:style:wordwrap to false.
    set status3label3:tooltip to "Right Hand Aft Flap Angle Command".
local status3label4 is statusstackvlayout4:addlabel().
    set status3label4:style:fontsize to 16.
    set status3label4:style:align to "LEFT".
    set status3label4:style:margin:left to 20.
    set status3label4:style:wordwrap to false.
    set status3label4:style:width to 110.
    set status3label4:style:bg to "starship_img/starship_background_white".
    set status3label4:style:border:h to 10.
    set status3label4:style:border:v to 10.
    set status3label4:style:overflow:left to -135.
    set status3label4:style:overflow:right to 128.
    set status3label4:style:overflow:bottom to -1.
    set status3label4:tooltip to "Current Acceleration in G-Force (1G = Kerbin: 9.81 m/s/s)".
local status3label5 is statusstackvlayout5:addlabel().
    set status3label5:style:margin:left to 20.
    set status3label5:style:fontsize to 16.
    set status3label5:style:align to "CENTER".
    set status3label5:style:wordwrap to false.
    set status3label5:style:width to 105.
    set status3label5:style:bg to "starship_img/starship_background_dark_opacity0".
    set status3label5:style:border:h to 10.
    set status3label5:style:border:v to 10.
    set status3label5:tooltip to "% Liquid Oxygen Fuel Remaining".
    
local status4label4 is statusstackvlayout4:addlabel().
    set status4label4:style:fontsize to 16.
    set status4label4:style:align to "LEFT".
    set status4label4:style:margin:left to 20.
    set status4label4:style:wordwrap to false.
    set status4label4:style:width to 110.
    set status4label4:style:height to 19.
    set status4label4:tooltip to "Mach Nr (MACH 1 = 1x speed of sound) or Groundspeed (SPD)".
local status4label5 is statusstackvlayout5:addlabel().
    set status4label5:style:margin:left to 20.
    set status4label5:style:fontsize to 16.
    set status4label5:style:align to "LEFT".
    set status4label5:style:wordwrap to false.
    set status4label5:style:width to 105.
    set status4label5:style:height to 19.
    set status4label5:tooltip to "Vertical Speed in m/s".

local statuscheckboxes is statusstackvlayout6:addvbox().
    set statuscheckboxes:style:margin:right to 0.
    set statuscheckboxes:style:vstretch to 1.
    set statuscheckboxes:style:bg to "starship_img/starship_main_square_bg".
local quickstatus1 is statuscheckboxes:addcheckbox("<b>Flaps</b>").
    set quickstatus1:style:margin:top to 12.
    set quickstatus1:style:margin:left to 10.
    set quickstatus1:style:fontsize to 18.
    set quickstatus1:style:width to 150.
    set quickstatus1:style:height to 29.
    set quickstatus1:style:overflow:right to -130.
    set quickstatus1:style:overflow:left to -3.
    set quickstatus1:style:overflow:top to -4.
    set quickstatus1:style:overflow:bottom to -9.
    set quickstatus1:tooltip to "Activate/Deactivate Flap Steering".
local quickstatus2 is statuscheckboxes:addcheckbox("<b>Lights</b>").
    set quickstatus2:style:margin:left to 10.
    set quickstatus2:style:fontsize to 18.
    set quickstatus2:style:width to 150.
    set quickstatus2:style:height to 29.
    set quickstatus2:style:overflow:right to -130.
    set quickstatus2:style:overflow:left to -3.
    set quickstatus2:style:overflow:top to -4.
    set quickstatus2:style:overflow:bottom to -9.
    set quickstatus2:tooltip to "Lights on/Lights off".
local quickstatus3 is statuscheckboxes:addcheckbox("<b>Gear</b>").
    set quickstatus3:style:margin:left to 10.
    set quickstatus3:style:fontsize to 18.
    set quickstatus3:style:wordwrap to false.
    set quickstatus3:style:width to 150.
    set quickstatus3:style:height to 29.
    set quickstatus3:style:overflow:right to -130.
    set quickstatus3:style:overflow:left to -3.
    set quickstatus3:style:overflow:top to -4.
    set quickstatus3:style:overflow:bottom to -9.
    set quickstatus3:tooltip to "Extend/Retract Gear".
    

set quickstatus1:ontoggle to {
    parameter click.
    if click {
        if ship:status = "PRELAUNCH" or LaunchButtonIsRunning or runningprogram = "After Landing" or runningprogram = "Landing" or runningprogram = "Final Approach" or runningprogram = "Venting Fuel.." {
            set quickstatus1:text to "<b><color=red>Flaps</color></b>".
            wait 0.25.
            set quickstatus1:text to "<b>Flaps</b>".
            if ship:status = "PRELAUNCH" or LaunchButtonIsRunning or runningprogram = "Venting Fuel.." {
                set quickstatus1:pressed to false.
            }
        }
        else {
            set CargoDuringReEntry to TotalCargoMass[0].
            set flapcargomasscorr to round(10 - ((CargoDuringReEntry / 10000) * 10)).
            if flapcargomasscorr < 0 {
                set flapcargomasscorr to 0.
            }
            LogToFile("Flap control ON").
            setflaps(55 + flapcargomasscorr, 50, 1, 30).
        }
    }
    else {
        if not LandButtonIsRunning {
            LogToFile("Flap control OFF").
            setflaps(55, 50, 0, 30).
        }
        else if AttitudeIsRunning {
            LogToFile("Flap control OFF").
            setflaps(55, 50, 0, 30).
        }
        else if runningprogram = "After Landing" or runningprogram = "Landing" or runningprogram = "Final Approach" or runningprogram = "De-orbit & Landing" {
            set quickstatus1:pressed to true.
        }
        else {
            set quickstatus1:text to "<b>Flaps</b>".
        }
    }
}.

set quickstatus2:ontoggle to {
    parameter click.
    if click {
        LIGHTS ON.
    }
    else {
        LIGHTS OFF.
    }
}.

set quickstatus3:ontoggle to {
    parameter click.
    if click {
        GEAR ON.
    }
    else {
        GEAR OFF.
    }
}.


local enginestackhlayout to enginestack:addhlayout().
    set enginestackhlayout:style:bg to "starship_img/starship_main_square_bg".
local enginestackvlayout1 is enginestackhlayout:addvlayout().
    set enginestackvlayout1:style:vstretch to 1.
local enginestackvlayout2 is enginestackhlayout:addvlayout().
local enginestackvlayout3 is enginestackhlayout:addvlayout().
local enginestackvlayout4 is enginestackhlayout:addvlayout().
local enginestackvlayout5 is enginestackhlayout:addvlayout().
local enginestackvlayout6 is enginestackhlayout:addvlayout().
    
local engine1label1 is enginestackvlayout1:addlabel("<b> SL Raptors</b>").
    set engine1label1:style:margin:left to 5.
    set engine1label1:style:margin:top to 10.
    set engine1label1:style:width to 100.
    set engine1label1:style:fontsize to 18.
    set engine1label1:style:wordwrap to false.
    set engine1label1:style:align to "LEFT".
local engine1label2 is enginestackvlayout2:addlabel("-").
    set engine1label2:style:textcolor to grey.
    set engine1label2:style:margin:top to 10.
    set engine1label2:style:width to 40.
    set engine1label2:style:fontsize to 19.
    set engine1label2:style:wordwrap to false.
    set engine1label2:style:align to "LEFT".
local engine1label4 is enginestackvlayout4:addlabel("-").
    set engine1label4:style:textcolor to grey.
    set engine1label4:style:margin:top to 10.
    set engine1label4:style:margin:left to 20.
    set engine1label4:style:width to 40.
    set engine1label4:style:fontsize to 19.
    set engine1label4:style:wordwrap to false.
    set engine1label4:style:align to "LEFT".
local engine1label5 is enginestackvlayout5:addlabel("<b>VAC Raptors</b>").
    set engine1label5:style:margin:top to 10.
    set engine1label5:style:width to 100.
    set engine1label5:style:fontsize to 18.
    set engine1label5:style:wordwrap to false.
    set engine1label5:style:align to "LEFT".
    
local engine2label1 is enginestackvlayout1:addlabel("-").
    set engine2label1:style:textcolor to grey.
    set engine2label1:style:margin:top to 8.
    set engine2label1:style:margin:left to 10.
    set engine2label1:style:width to 100.
    set engine2label1:style:fontsize to 16.
    set engine2label1:style:wordwrap to false.
    set engine2label1:style:align to "CENTER".
    set engine2label1:style:bg to "starship_img/starship_background_white".
    set engine2label1:style:border:h to 10.
    set engine2label1:style:border:v to 10.
    set engine2label1:style:overflow:top to -1.
local engine2label2 is enginestackvlayout2:addlabel().
    set engine2label2:style:margin:top to 8.
    set engine2label2:style:bg to "starship_img/starship_background_dark_opacity0".
    set engine2label2:style:border:h to 10.
    set engine2label2:style:width to 40.
    set engine2label2:style:border:v to 10.
    set engine2label2:style:overflow:left to 110.
    set engine2label2:style:overflow:right to -50.
    set engine2label2:style:overflow:bottom to 0.
local engine2label3 is enginestackvlayout3:addlabel().
    set engine2label3:style:bg to "starship_img/starship_9engine_none_active".
    set engine2label3:style:wordwrap to false.
    set engine2label3:style:width to 70.
    set engine2label3:style:height to 48.
    set engine2label3:style:margin:top to 3.
    set engine2label3:style:margin:bottom to -20.
    set engine2label3:style:overflow:top to -5.
    set engine2label3:style:overflow:bottom to 55.
    set engine2label3:style:overflow:left to 65.
    set engine2label3:style:overflow:right to 65.
    set engine2label3:tooltip to "Visual Representation of current Engine performance".
local engine2label4 is enginestackvlayout4:addlabel().
    set engine2label4:style:margin:top to 8.
    set engine2label4:style:margin:left to 20.
    set engine2label4:style:align to "CENTER".
    set engine2label4:style:width to 40.
    set engine2label4:style:bg to "starship_img/starship_background_white".
    set engine2label4:style:border:h to 10.
    set engine2label4:style:border:v to 10.
    set engine2label4:style:overflow:left to -50.
    set engine2label4:style:overflow:right to 110.
    set engine2label4:style:overflow:bottom to -1.
local engine2label5 is enginestackvlayout5:addlabel("-").
    set engine2label5:style:textcolor to grey.
    set engine2label5:style:margin:top to 8.
    set engine2label5:style:width to 100.
    set engine2label5:style:fontsize to 16.
    set engine2label5:style:wordwrap to false.
    set engine2label5:style:align to "CENTER".
    set engine2label5:style:bg to "starship_img/starship_background_dark_opacity0".
    set engine2label5:style:border:h to 10.
    set engine2label5:style:border:v to 10.
    set engine2label5:style:overflow:bottom to 1.
    
local engine3label1 is enginestackvlayout1:addlabel("Pitch Gimbal").
    set engine3label1:style:margin:top to 2.
    set engine3label1:style:margin:left to 8.
    set engine3label1:style:width to 100.
    set engine3label1:style:fontsize to 19.
    set engine3label1:style:wordwrap to false.
    set engine3label1:style:align to "LEFT".
    set engine3label1:tooltip to "Thrust Vector Angle in the pitch axis".
local engine3label2 is enginestackvlayout2:addlabel("-").
    set engine3label2:style:margin:top to 2.
    set engine3label2:style:margin:left to 5.
    set engine3label2:style:fontsize to 19.
    set engine3label2:style:width to 50.
    set engine3label2:style:wordwrap to false.
    set engine3label2:style:align to "CENTER".
    set engine3label2:tooltip to "Engines pitch gimbal angle".
local engine3label4 is enginestackvlayout4:addlabel("-").
    set engine3label4:style:margin:top to 2.
    set engine3label4:style:margin:left to 0.
    set engine3label4:style:fontsize to 19.
    set engine3label4:style:width to 50.
    set engine3label4:style:wordwrap to false.
    set engine3label4:style:align to "CENTER".
    set engine3label4:tooltip to "Engines yaw gimbal angle".
local engine3label5 is enginestackvlayout5:addlabel("Yaw Gimbal").
    set engine3label5:style:margin:top to 2.
    set engine3label5:style:fontsize to 19.
    set engine3label5:style:wordwrap to false.
    set engine3label5:style:align to "LEFT".
    set engine3label5:tooltip to "Thrust Vector Angle in the yaw axis".

local enginecheckboxes is enginestackvlayout6:addvbox().
    set enginecheckboxes:style:margin:right to 0.
    set enginecheckboxes:style:vstretch to 1.
    set enginecheckboxes:style:bg to "starship_img/starship_main_square_bg".
local quickengine1 is enginecheckboxes:addcheckbox("<b>OFF</b>").
    set quickengine1:exclusive to true.
    set quickengine1:toggle to true.
    set quickengine1:style:margin:top to 12.
    set quickengine1:style:margin:left to 10.
    set quickengine1:style:fontsize to 18.
    set quickengine1:style:width to 150.
    set quickengine1:style:height to 29.
    set quickengine1:style:overflow:right to -130.
    set quickengine1:style:overflow:left to -3.
    set quickengine1:style:overflow:top to -4.
    set quickengine1:style:overflow:bottom to -9.
    set quickengine1:tooltip to "Turn off all engines".
local quickengine2 is enginecheckboxes:addcheckbox("<b>SL Raptors</b>").
    set quickengine2:toggle to true.
    set quickengine2:style:margin:left to 10.
    set quickengine2:style:fontsize to 18.
    set quickengine2:style:width to 150.
    set quickengine2:style:height to 29.
    set quickengine2:style:overflow:right to -130.
    set quickengine2:style:overflow:left to -3.
    set quickengine2:style:overflow:top to -4.
    set quickengine2:style:overflow:bottom to -9.
    set quickengine2:tooltip to "Turn on sea-level Raptors".
local quickengine3 is enginecheckboxes:addcheckbox("<b>VAC Raptors</b>").
    set quickengine3:toggle to true.
    set quickengine3:style:margin:left to 10.
    set quickengine3:style:fontsize to 18.
    set quickengine3:style:width to 150.
    set quickengine3:style:height to 29.
    set quickengine3:style:overflow:right to -130.
    set quickengine3:style:overflow:left to -3.
    set quickengine3:style:overflow:top to -4.
    set quickengine3:style:overflow:bottom to -9.
    set quickengine3:tooltip to "Turn on vacuum Raptors".
    
set quickengine1:ontoggle to {
    parameter click.
    if click {
        LogToFile("Engines OFF").
        ShutdownEngines().
        set ShowSLdeltaV to true.
    }
}.
    
set quickengine2:ontoggle to {
    parameter click.
    if click {
        if ship:status = "PRELAUNCH" {
            set quickengine2:text to "<b><color=red>SL Raptors</color></b>".
            wait 0.25.
            set quickengine2:text to "<b>SL Raptors</b>".
            set quickengine2:pressed to false.
        }
        else {
            LogToFile("SL Engines ON").
            set quickengine1:pressed to false.
            ActivateEngines(0).
            set ShowSLdeltaV to true.
        }
    }
    else {
        if quickengine3:pressed {
            LogToFile("SL Engines OFF").
            for eng in SLEngines {eng:shutdown.}.
        }
        else {
            set quickengine1:pressed to true.
        }
    }
}.
    
set quickengine3:ontoggle to {
    parameter click.
    if click {
        if ship:status = "PRELAUNCH" {
            set quickengine3:text to "<b><color=red>VAC Raptors</color></b>".
            wait 0.25.
            set quickengine3:text to "<b>VAC Raptors</b>".
            set quickengine3:pressed to false.
        }
        else {
            LogToFile("VAC Engines ON").
            set quickengine1:pressed to false.
            ActivateEngines(1).
            set ShowSLdeltaV to false.
        }
    }
    else {
        if quickengine2:pressed {
            LogToFile("VAC Engines OFF").
            for eng in VACEngines {eng:shutdown.}.
        }
        else {
            set quickengine1:pressed to true.
        }
    }
}.

local orbitstackhlayout to orbitstack:addhlayout().
    set orbitstackhlayout:style:bg to "starship_img/starship_main_square_bg".
local orbitstackvlayout1 is orbitstackhlayout:addvlayout().
    set orbitstackvlayout1:style:vstretch to true.
local orbitstackvlayout2 is orbitstackhlayout:addvlayout().
local orbitstackvlayout3 is orbitstackhlayout:addvlayout().
    
local orbit1label1 is orbitstackvlayout1:addlabel().
    set orbit1label1:style:wordwrap to false.
    set orbit1label1:style:margin:left to 10.
    set orbit1label1:style:margin:top to 8.
    set orbit1label1:style:fontsize to 19.
    set orbit1label1:style:width to 200.
    set orbit1label1:style:align to "LEFT".
    set orbit1label1:style:vstretch to true.
    set orbit1label1:tooltip to "Highest point in orbit (km)".
local orbit1label2 is orbitstackvlayout2:addlabel().
    set orbit1label2:style:wordwrap to false.
    set orbit1label2:style:margin:top to 8.
    set orbit1label2:style:fontsize to 19.
    set orbit1label2:style:width to 200.
    set orbit1label2:style:align to "LEFT".
    set orbit1label2:style:vstretch to true.
    set orbit1label2:tooltip to "Time to highest point in orbit".
    set orbit1label2:style:overflow:left to -245.
    set orbit1label2:style:overflow:right to 145.
    set orbit1label2:style:overflow:top to 0.
    set orbit1label2:style:overflow:bottom to 60.
local orbit1label3 is orbitstackvlayout3:addlabel().
    set orbit1label3:style:wordwrap to false.
    set orbit1label3:style:margin:top to 8.
    set orbit1label3:style:fontsize to 19.
    set orbit1label3:style:align to "LEFT".
    set orbit1label3:style:vstretch to true.
    set orbit1label3:style:width to 125.
    set orbit1label3:style:height to 25.
    set orbit1label3:style:overflow:right to -100.
    set orbit1label3:tooltip to "No Maneuver Node = Grey / Maneuver Node = Magenta".
    
local orbit2label1 is orbitstackvlayout1:addlabel().
    set orbit2label1:style:wordwrap to false.
    set orbit2label1:style:margin:left to 10.
    set orbit2label1:style:width to 200.
    set orbit2label1:style:vstretch to true.
    set orbit2label1:style:fontsize to 19.
    set orbit2label1:style:align to "LEFT".
    set orbit2label1:tooltip to "Lowest point in orbit (km). <0 = Below the surface".
local orbit2label2 is orbitstackvlayout2:addlabel().
    set orbit2label2:style:vstretch to true.
    set orbit2label2:style:wordwrap to false.
    set orbit2label2:style:fontsize to 19.
    set orbit2label2:style:width to 200.
    set orbit2label2:style:align to "LEFT".
    set orbit2label2:tooltip to "Time to lowest point in orbit".
local orbit2label3 is orbitstackvlayout3:addlabel().
    set orbit2label3:style:vstretch to true.
    set orbit2label3:style:wordwrap to false.
    set orbit2label3:style:fontsize to 19.
    set orbit2label3:style:width to 125.
    set orbit2label3:style:align to "LEFT".
    set orbit2label3:tooltip to "Required Delta-V for Maneuver".
    
local orbit3label1 is orbitstackvlayout1:addlabel().
    set orbit3label1:style:margin:left to 10.
    set orbit3label1:style:margin:bottom to 9.
    set orbit3label1:style:wordwrap to false.
    set orbit3label1:style:width to 200.
    set orbit3label1:style:vstretch to true.
    set orbit3label1:style:fontsize to 19.
    set orbit3label1:style:align to "LEFT".
    set orbit3label1:tooltip to "Time it takes for 1 full orbit".
local orbit3label2 is orbitstackvlayout2:addlabel().
    set orbit3label2:style:margin:bottom to 9.
    set orbit3label2:style:wordwrap to false.
    set orbit3label2:style:vstretch to true.
    set orbit3label2:style:fontsize to 19.
    set orbit3label2:style:width to 200.
    set orbit3label2:style:align to "LEFT".
    set orbit3label2:tooltip to "Angle between the reference plane and the orbital plane".
local orbit3label3 is orbitstackvlayout3:addlabel().
    set orbit3label3:style:margin:bottom to 9.
    set orbit3label3:style:wordwrap to false.
    set orbit3label3:style:vstretch to true.
    set orbit3label3:style:fontsize to 19.
    set orbit3label3:style:align to "LEFT".
    set orbit3label3:style:width to 125.
    set orbit3label3:style:height to 25.
    set orbit3label3:style:overflow:right to -100.
    set orbit3label3:tooltip to "Navigational Capability: GPS (Satellite), IRS (Inertial) or CBN (Celestial)".
    

local crewstackhlayout to crewstack:addhlayout().
    set crewstackhlayout:style:bg to "starship_img/starship_main_square_bg".
local crewstackvlayout1 is crewstackhlayout:addvlayout().
    set crewstackvlayout1:style:vstretch to true.
local crewstackvlayout2 is crewstackhlayout:addvlayout().
local crewstackvlayout3 is crewstackhlayout:addvlayout().
local crewstackvlayout4 is crewstackhlayout:addvlayout().
local crewstackvlayout5 is crewstackhlayout:addvlayout().
local crewstackvlayout6 is crewstackhlayout:addvlayout().

local crew1label1 is crewstackvlayout1:addlabel().
    set crew1label1:style:wordwrap to false.
    set crew1label1:style:margin:top to 0.
    set crew1label1:style:margin:left to 20.
    set crew1label1:style:fontsize to 19.
    set crew1label1:style:width to 80.
    set crew1label1:style:align to "LEFT".
    set crew1label1:style:vstretch to true.
    set crew1label1:style:overflow:top to -10.
    set crew1label1:style:overflow:bottom to 60.
    set crew1label1:tooltip to "Experience Level".
local crew1label2 is crewstackvlayout2:addlabel().
    set crew1label2:style:wordwrap to false.
    set crew1label2:style:margin:top to 0.
    set crew1label2:style:fontsize to 19.
    set crew1label2:style:width to 80.
    set crew1label2:style:align to "LEFT".
    set crew1label2:style:vstretch to true.
    set crew1label2:style:overflow:top to -10.
    set crew1label2:style:overflow:bottom to 60.
    set crew1label2:tooltip to "Experience Level".
local crew1label3 is crewstackvlayout3:addlabel().
    set crew1label3:style:wordwrap to false.
    set crew1label3:style:margin:top to 0.
    set crew1label3:style:fontsize to 19.
    set crew1label3:style:align to "LEFT".
    set crew1label3:style:vstretch to true.
    set crew1label3:style:width to 80.
    set crew1label3:style:overflow:top to -10.
    set crew1label3:style:overflow:bottom to 60.
    set crew1label3:tooltip to "Experience Level".
local crew1label4 is crewstackvlayout4:addlabel().
    set crew1label4:style:wordwrap to false.
    set crew1label4:style:margin:top to 0.
    set crew1label4:style:fontsize to 19.
    set crew1label4:style:align to "LEFT".
    set crew1label4:style:vstretch to true.
    set crew1label4:style:width to 80.
    set crew1label4:style:overflow:top to -10.
    set crew1label4:style:overflow:bottom to 60.
    set crew1label4:tooltip to "Experience Level".
local crew1label5 is crewstackvlayout5:addlabel().
    set crew1label5:style:wordwrap to false.
    set crew1label5:style:margin:top to 0.
    set crew1label5:style:fontsize to 19.
    set crew1label5:style:align to "LEFT".
    set crew1label5:style:width to 80.
    set crew1label5:style:height to 25.
    set crew1label5:style:overflow:top to -10.
    set crew1label5:style:overflow:bottom to 70.
    set crew1label5:tooltip to "Experience Level".
local crew1label6 is crewstackvlayout6:addlabel().
    set crew1label6:style:wordwrap to false.
    set crew1label6:style:margin:top to 0.
    set crew1label6:style:fontsize to 19.
    set crew1label6:style:align to "LEFT".
    set crew1label6:style:width to 80.
    set crew1label6:style:height to 25.
    set crew1label6:style:overflow:top to -10.
    set crew1label6:style:overflow:bottom to 70.
    set crew1label6:tooltip to "Experience Level".

local crew2label1 is crewstackvlayout1:addlabel().
    set crew2label1:style:wordwrap to false.
    set crew2label1:style:margin:left to 20.
    set crew2label1:style:vstretch to true.
    set crew2label1:style:fontsize to 22.
    set crew2label1:style:align to "CENTER".
    set crew2label1:style:textcolor to grey.
    set crew2label1:style:width to 80.
    set crew2label1:style:overflow:top to 34.
    set crew2label1:style:overflow:bottom to -52.
    set crew2label1:style:overflow:left to -10.
    set crew2label1:style:overflow:right to -10.
    set crew2label1:tooltip to "Crew Member 1".
local crew2label2 is crewstackvlayout2:addlabel().
    set crew2label2:style:vstretch to true.
    set crew2label2:style:wordwrap to false.
    set crew2label2:style:fontsize to 22.
    set crew2label2:style:align to "CENTER".
    set crew2label2:style:textcolor to grey.
    set crew2label2:style:width to 80.
    set crew2label2:style:overflow:top to 34.
    set crew2label2:style:overflow:bottom to -52.
    set crew2label2:style:overflow:left to -10.
    set crew2label2:style:overflow:right to -10.
    set crew2label2:tooltip to "Crew Member 2".
local crew2label3 is crewstackvlayout3:addlabel().
    set crew2label3:style:vstretch to true.
    set crew2label3:style:wordwrap to false.
    set crew2label3:style:fontsize to 22.
    set crew2label3:style:align to "CENTER".
    set crew2label3:style:textcolor to grey.
    set crew2label3:style:width to 80.
    set crew2label3:style:overflow:top to 34.
    set crew2label3:style:overflow:bottom to -52.
    set crew2label3:style:overflow:left to -10.
    set crew2label3:style:overflow:right to -10.
    set crew2label3:tooltip to "Crew Member 3".
local crew2label4 is crewstackvlayout4:addlabel().
    set crew2label4:style:vstretch to true.
    set crew2label4:style:wordwrap to false.
    set crew2label4:style:fontsize to 22.
    set crew2label4:style:align to "CENTER".
    set crew2label4:style:textcolor to grey.
    set crew2label4:style:width to 80.
    set crew2label4:style:overflow:top to 34.
    set crew2label4:style:overflow:bottom to -52.
    set crew2label4:style:overflow:left to -10.
    set crew2label4:style:overflow:right to -10.
    set crew2label4:tooltip to "Crew Member 4".
local crew2label5 is crewstackvlayout5:addlabel().
    set crew2label5:style:vstretch to true.
    set crew2label5:style:wordwrap to false.
    set crew2label5:style:fontsize to 22.
    set crew2label5:style:align to "CENTER".
    set crew2label5:style:textcolor to grey.
    set crew2label5:style:width to 80.
    set crew2label5:style:height to 49.
    set crew2label5:style:overflow:top to 25.
    set crew2label5:style:overflow:bottom to -54.
    set crew2label5:style:overflow:left to -10.
    set crew2label5:style:overflow:right to -10.
    set crew2label5:tooltip to "Crew Member 5".
local crew2label6 is crewstackvlayout6:addlabel().
    set crew2label6:style:vstretch to true.
    set crew2label6:style:wordwrap to false.
    set crew2label6:style:fontsize to 22.
    set crew2label6:style:align to "CENTER".
    set crew2label6:style:textcolor to grey.
    set crew2label6:style:width to 80.
    set crew2label6:style:height to 49.
    set crew2label6:style:overflow:top to 25.
    set crew2label6:style:overflow:bottom to -54.
    set crew2label6:style:overflow:left to -10.
    set crew2label6:style:overflow:right to -10.
    set crew2label6:tooltip to "Crew Member 6".

local crew3label1 is crewstackvlayout1:addlabel().
    set crew3label1:style:margin:top to 5.
    set crew3label1:style:margin:left to 20.
    set crew3label1:style:wordwrap to false.
    set crew3label1:style:vstretch to true.
    set crew3label1:style:fontsize to 18.
    set crew3label1:style:align to "CENTER".
    set crew3label1:style:width to 80.
    set crew3label1:style:overflow:top to 20.
    set crew3label1:style:overflow:bottom to -20.
    set crew3label1:style:overflow:left to 15.
    set crew3label1:style:overflow:right to -65.
    set crew3label1:tooltip to "Name & Role (Pilot, Engineer or Scientist)".
local crew3label2 is crewstackvlayout2:addlabel().
    set crew3label2:style:margin:top to 5.
    set crew3label2:style:wordwrap to false.
    set crew3label2:style:vstretch to true.
    set crew3label2:style:fontsize to 18.
    set crew3label2:style:align to "CENTER".
    set crew3label2:style:width to 80.
    set crew3label2:style:overflow:top to 20.
    set crew3label2:style:overflow:bottom to -20.
    set crew3label2:style:overflow:left to 15.
    set crew3label2:style:overflow:right to -65.
    set crew3label2:tooltip to "Name & Role (Pilot, Engineer or Scientist)".
local crew3label3 is crewstackvlayout3:addlabel().
    set crew3label3:style:margin:top to 5.
    set crew3label3:style:wordwrap to false.
    set crew3label3:style:vstretch to true.
    set crew3label3:style:fontsize to 18.
    set crew3label3:style:align to "CENTER".
    set crew3label3:style:width to 80.
    set crew3label3:style:overflow:top to 20.
    set crew3label3:style:overflow:bottom to -20.
    set crew3label3:style:overflow:left to 15.
    set crew3label3:style:overflow:right to -65.
    set crew3label3:tooltip to "Name & Role (Pilot, Engineer or Scientist)".
local crew3label4 is crewstackvlayout4:addlabel().
    set crew3label4:style:margin:top to 5.
    set crew3label4:style:wordwrap to false.
    set crew3label4:style:vstretch to true.
    set crew3label4:style:fontsize to 18.
    set crew3label4:style:align to "CENTER".
    set crew3label4:style:width to 80.
    set crew3label4:style:overflow:top to 20.
    set crew3label4:style:overflow:bottom to -20.
    set crew3label4:style:overflow:left to 15.
    set crew3label4:style:overflow:right to -65.
    set crew3label4:tooltip to "Name & Role (Pilot, Engineer or Scientist)".
local crew3label5 is crewstackvlayout5:addlabel().
    set crew3label5:style:margin:top to 5.
    set crew3label5:style:wordwrap to false.
    set crew3label5:style:vstretch to true.
    set crew3label5:style:fontsize to 18.
    set crew3label5:style:align to "CENTER".
    set crew3label5:style:width to 80.
    set crew3label5:style:height to 30.
    set crew3label5:style:overflow:top to 20.
    set crew3label5:style:overflow:bottom to -20.
    set crew3label5:style:overflow:left to 15.
    set crew3label5:style:overflow:right to -65.
    set crew3label5:tooltip to "Name & Role (Pilot, Engineer or Scientist)".
local crew3label6 is crewstackvlayout6:addlabel().
    set crew3label6:style:margin:top to 5.
    set crew3label6:style:wordwrap to false.
    set crew3label6:style:vstretch to true.
    set crew3label6:style:fontsize to 18.
    set crew3label6:style:align to "CENTER".
    set crew3label6:style:width to 80.
    set crew3label6:style:height to 30.
    set crew3label6:style:overflow:top to 20.
    set crew3label6:style:overflow:bottom to -20.
    set crew3label6:style:overflow:left to 15.
    set crew3label6:style:overflow:right to -65.
    set crew3label6:tooltip to "Name & Role (Pilot, Engineer or Scientist)".

local crew1label7 is crewstackvlayout1:addlabel().
    set crew1label7:style:wordwrap to false.
    set crew1label7:style:margin:top to 0.
    set crew1label7:style:margin:left to 20.
    set crew1label7:style:fontsize to 19.
    set crew1label7:style:width to 80.
    set crew1label7:style:align to "LEFT".
    set crew1label7:style:vstretch to true.
    set crew1label7:style:overflow:top to -10.
    set crew1label7:style:overflow:bottom to 60.
    set crew1label7:tooltip to "Experience Level".
local crew1label8 is crewstackvlayout2:addlabel().
    set crew1label8:style:wordwrap to false.
    set crew1label8:style:margin:top to 0.
    set crew1label8:style:fontsize to 19.
    set crew1label8:style:width to 80.
    set crew1label8:style:align to "LEFT".
    set crew1label8:style:vstretch to true.
    set crew1label8:style:overflow:top to -10.
    set crew1label8:style:overflow:bottom to 60.
    set crew1label8:tooltip to "Experience Level".
local crew1label9 is crewstackvlayout3:addlabel().
    set crew1label9:style:wordwrap to false.
    set crew1label9:style:margin:top to 0.
    set crew1label9:style:fontsize to 19.
    set crew1label9:style:width to 80.
    set crew1label9:style:align to "LEFT".
    set crew1label9:style:vstretch to true.
    set crew1label9:style:overflow:top to -10.
    set crew1label9:style:overflow:bottom to 60.
    set crew1label9:tooltip to "Experience Level".
local crew1label10 is crewstackvlayout4:addlabel().
    set crew1label10:style:wordwrap to false.
    set crew1label10:style:margin:top to 0.
    set crew1label10:style:fontsize to 19.
    set crew1label10:style:width to 80.
    set crew1label10:style:align to "LEFT".
    set crew1label10:style:vstretch to true.
    set crew1label10:style:overflow:top to -10.
    set crew1label10:style:overflow:bottom to 60.
    set crew1label10:tooltip to "Experience Level".
local crew2label7 is crewstackvlayout1:addlabel().
    set crew2label7:style:wordwrap to false.
    set crew2label7:style:margin:left to 20.
    set crew2label7:style:vstretch to true.
    set crew2label7:style:fontsize to 22.
    set crew2label7:style:align to "CENTER".
    set crew2label7:style:textcolor to grey.
    set crew2label7:style:width to 80.
    set crew2label7:style:overflow:top to 34.
    set crew2label7:style:overflow:bottom to -52.
    set crew2label7:style:overflow:left to -10.
    set crew2label7:style:overflow:right to -10.
    set crew2label7:tooltip to "Crew Member 7".
local crew2label8 is crewstackvlayout2:addlabel().
    set crew2label8:style:wordwrap to false.
    set crew2label8:style:vstretch to true.
    set crew2label8:style:fontsize to 22.
    set crew2label8:style:align to "CENTER".
    set crew2label8:style:textcolor to grey.
    set crew2label8:style:width to 80.
    set crew2label8:style:overflow:top to 34.
    set crew2label8:style:overflow:bottom to -52.
    set crew2label8:style:overflow:left to -10.
    set crew2label8:style:overflow:right to -10.
    set crew2label8:tooltip to "Crew Member 8".
local crew2label9 is crewstackvlayout3:addlabel().
    set crew2label9:style:wordwrap to false.
    set crew2label9:style:vstretch to true.
    set crew2label9:style:fontsize to 22.
    set crew2label9:style:align to "CENTER".
    set crew2label9:style:textcolor to grey.
    set crew2label9:style:width to 80.
    set crew2label9:style:overflow:top to 34.
    set crew2label9:style:overflow:bottom to -52.
    set crew2label9:style:overflow:left to -10.
    set crew2label9:style:overflow:right to -10.
    set crew2label9:tooltip to "Crew Member 9".
local crew2label10 is crewstackvlayout4:addlabel().
    set crew2label10:style:wordwrap to false.
    set crew2label10:style:vstretch to true.
    set crew2label10:style:fontsize to 22.
    set crew2label10:style:align to "CENTER".
    set crew2label10:style:textcolor to grey.
    set crew2label10:style:width to 80.
    set crew2label10:style:overflow:top to 34.
    set crew2label10:style:overflow:bottom to -52.
    set crew2label10:style:overflow:left to -10.
    set crew2label10:style:overflow:right to -10.
    set crew2label10:tooltip to "Crew Member 10".
local crew3label7 is crewstackvlayout1:addlabel().
    set crew3label7:style:margin:top to 5.
    set crew3label7:style:margin:left to 20.
    set crew3label7:style:wordwrap to false.
    set crew3label7:style:vstretch to true.
    set crew3label7:style:fontsize to 18.
    set crew3label7:style:align to "CENTER".
    set crew3label7:style:width to 80.
    set crew3label7:style:overflow:top to 20.
    set crew3label7:style:overflow:bottom to -20.
    set crew3label7:style:overflow:left to 15.
    set crew3label7:style:overflow:right to -65.
    set crew3label7:tooltip to "Name & Role (Pilot, Engineer or Scientist)".
local crew3label8 is crewstackvlayout2:addlabel().
    set crew3label8:style:margin:top to 5.
    set crew3label8:style:wordwrap to false.
    set crew3label8:style:vstretch to true.
    set crew3label8:style:fontsize to 18.
    set crew3label8:style:align to "CENTER".
    set crew3label8:style:width to 80.
    set crew3label8:style:overflow:top to 20.
    set crew3label8:style:overflow:bottom to -20.
    set crew3label8:style:overflow:left to 15.
    set crew3label8:style:overflow:right to -65.
    set crew3label8:tooltip to "Name & Role (Pilot, Engineer or Scientist)".
local crew3label9 is crewstackvlayout3:addlabel().
    set crew3label9:style:margin:top to 5.
    set crew3label9:style:wordwrap to false.
    set crew3label9:style:vstretch to true.
    set crew3label9:style:fontsize to 18.
    set crew3label9:style:align to "CENTER".
    set crew3label9:style:width to 80.
    set crew3label9:style:overflow:top to 20.
    set crew3label9:style:overflow:bottom to -20.
    set crew3label9:style:overflow:left to 15.
    set crew3label9:style:overflow:right to -65.
    set crew3label9:tooltip to "Name & Role (Pilot, Engineer or Scientist)".
local crew3label10 is crewstackvlayout4:addlabel().
    set crew3label10:style:margin:top to 5.
    set crew3label10:style:wordwrap to false.
    set crew3label10:style:vstretch to true.
    set crew3label10:style:fontsize to 18.
    set crew3label10:style:align to "CENTER".
    set crew3label10:style:width to 80.
    set crew3label10:style:overflow:top to 20.
    set crew3label10:style:overflow:bottom to -20.
    set crew3label10:style:overflow:left to 15.
    set crew3label10:style:overflow:right to -65.
    set crew3label10:tooltip to "Name & Role (Pilot, Engineer or Scientist)".

local crewlabel1 is crewstackvlayout5:addlabel("<b>ECLSS</b>").
    set crewlabel1:style:fontsize to 18.
    set crewlabel1:style:margin:top to 15.
    set crewlabel1:style:width to 60.
    set crewlabel1:style:bg to "starship_img/starship_background_dark".
    set crewlabel1:style:overflow:left to 10.
    set crewlabel1:style:overflow:top to 5.
    set crewlabel1:style:overflow:right to 126.
    set crewlabel1:style:overflow:bottom to 75.
    set crewlabel1:style:border:h to 10.
    set crewlabel1:style:border:v to 10.
    set crewlabel1:style:wordwrap to false.
    set crewlabel1:tooltip to "Environmental Control and Life Support System".
local crewlabel2 is crewstackvlayout5:addlabel("<b>P:  <color=green>99.2 kPa</color></b>").
    set crewlabel2:style:fontsize to 13.
    set crewlabel2:style:width to 60.
    set crewlabel2:style:margin:top to 15.
    set crewlabel2:style:wordwrap to false.
    set crewlabel2:tooltip to "Cabin Pressure. Normal: 96.5 kPa - 102.7 kPa".
local crewlabel3 is crewstackvlayout5:addlabel("<b>T:   <color=green>22.3°c</color></b>").
    set crewlabel3:style:fontsize to 13.
    set crewlabel3:style:width to 60.
    set crewlabel3:style:margin:top to 6.
    set crewlabel3:style:wordwrap to false.
    set crewlabel3:tooltip to "Cabin Temperature. Normal: 18.3°c - 26.7°c".
local crewlabel4 is crewstackvlayout6:addlabel("<size=14>3/3 running</size>").
    set crewlabel4:style:fontsize to 18.
    set crewlabel4:style:width to 60.
    set crewlabel4:style:wordwrap to false.
    set crewlabel4:style:margin:top to 15.
    set crewlabel4:style:overflow:left to 30.
    set crewlabel4:style:overflow:right to -70.
    set crewlabel4:style:bg to "starship_img/eclss".
    set crewlabel4:tooltip to "All Environmental Control Systems functioning properly".
local crewlabel5 is crewstackvlayout6:addlabel("<b>AQM:  <color=green>OK</color></b>").
    set crewlabel5:style:fontsize to 13.
    set crewlabel5:style:width to 60.
    set crewlabel5:style:margin:top to 15.
    set crewlabel5:style:wordwrap to false.
    set crewlabel5:tooltip to "Air Quality Monitor".
local crewlabel6 is crewstackvlayout6:addlabel().
    set crewlabel6:style:fontsize to 13.
    set crewlabel6:style:width to 60.
    set crewlabel6:style:margin:top to 6.
    set crewlabel6:style:overflow:left to -5.
    set crewlabel6:style:overflow:right to -5.
    set crewlabel6:tooltip to "Circulation Fan running".

local towerstackhlayout is towerstack:addhlayout().
    set towerstackhlayout:style:bg to "starship_img/starship_main_square_bg".
local towerstackvlayout1 is towerstackhlayout:addvlayout().
local towerstackvlayout2 is towerstackhlayout:addvlayout().
local towerstackvlayout3 is towerstackhlayout:addvlayout().
local towerstackvlayout4 is towerstackhlayout:addvlayout().
local towerstackvlayout5 is towerstackhlayout:addvlayout().
local towerstackvlayout6 is towerstackhlayout:addvlayout().
local towerstackhlayout2 is towerstackhlayout:addhlayout().
    set towerstackhlayout2:style:margin:right to 0.
    set towerstackhlayout2:style:vstretch to 1.
    set towerstackhlayout2:style:bg to "starship_img/starship_main_square_bg".
local towerstackvlayout7 is towerstackhlayout2:addvlayout().
local towerstackvlayout8 is towerstackhlayout2:addvlayout().
local towerstackvlayout9 is towerstackhlayout2:addvlayout().
local towerstackvlayout10 is towerstackhlayout2:addvlayout().
local towerstackvlayout11 is towerstackhlayout2:addvlayout().
local towerstackvlayout12 is towerstackhlayout2:addvlayout().
local towerstackvlayout13 is towerstackhlayout2:addvlayout().


local tower1label2 is towerstackvlayout1:addlabel("<b>ROT</b>").
    set tower1label2:style:wordwrap to false.
    set tower1label2:style:vstretch to true.
    set tower1label2:style:fontsize to 16.
    set tower1label2:style:align to "LEFT".
    set tower1label2:style:width to 35.
    set tower1label2:tooltip to "Mechazilla Arm Rotation".
local tower1label3 is towerstackvlayout1:addlabel("<b>ANG</b>").
    set tower1label3:style:wordwrap to false.
    set tower1label3:style:vstretch to true.
    set tower1label3:style:fontsize to 16.
    set tower1label3:style:align to "LEFT".
    set tower1label3:style:width to 35.
    set tower1label3:tooltip to "Mechazilla Arm Open Angle".
local tower1label4 is towerstackvlayout1:addlabel("<b>HGT</b>").
    set tower1label4:style:wordwrap to false.
    set tower1label4:style:vstretch to true.
    set tower1label4:style:fontsize to 16.
    set tower1label4:style:align to "LEFT".
    set tower1label4:style:width to 35.
    set tower1label4:tooltip to "Mechazilla Arm Height".

local tower2button2 is towerstackvlayout2:addbutton("<b><<</b>").
    set tower2button2:style:margin:top to 8.
    set tower2button2:style:margin:left to 0.
    set tower2button2:style:width to 35.
    set tower2button2:style:height to 25.
    set tower2button2:style:fontsize to 20.
local tower2button3 is towerstackvlayout2:addbutton("<b><<</b>").
    set tower2button3:style:margin:top to 12.
    set tower2button3:style:margin:left to 0.
    set tower2button3:style:width to 35.
    set tower2button3:style:height to 25.
    set tower2button3:style:fontsize to 20.
local tower2button4 is towerstackvlayout2:addbutton("<b>vv</b>").
    set tower2button4:style:margin:top to 12.
    set tower2button4:style:margin:left to 0.
    set tower2button4:style:width to 35.
    set tower2button4:style:height to 25.
    set tower2button4:style:fontsize to 20.

local tower3button2 is towerstackvlayout3:addbutton("<b><</b>").
    set tower3button2:style:margin:top to 8.
    set tower3button2:style:margin:left to 0.
    set tower3button2:style:width to 25.
    set tower3button2:style:height to 25.
    set tower3button2:style:fontsize to 20.
local tower3button3 is towerstackvlayout3:addbutton("<b><</b>").
    set tower3button3:style:margin:top to 12.
    set tower3button3:style:margin:left to 0.
    set tower3button3:style:width to 25.
    set tower3button3:style:height to 25.
    set tower3button3:style:fontsize to 20.
local tower3button4 is towerstackvlayout3:addbutton("<b>v</b>").
    set tower3button4:style:margin:top to 12.
    set tower3button4:style:margin:left to 0.
    set tower3button4:style:width to 25.
    set tower3button4:style:height to 25.
    set tower3button4:style:fontsize to 20.

local tower4label2 is towerstackvlayout4:addlabel("<b>0*</b>").
    set tower4label2:style:wordwrap to false.
    set tower4label2:style:vstretch to true.
    set tower4label2:style:fontsize to 16.
    set tower4label2:style:align to "CENTER".
    set tower4label2:style:width to 50.
    set tower4label2:tooltip to "Mechazilla Current/Desired Rotation".
local tower4label3 is towerstackvlayout4:addlabel("<b>0*</b>").
    set tower4label3:style:wordwrap to false.
    set tower4label3:style:vstretch to true.
    set tower4label3:style:fontsize to 16.
    set tower4label3:style:align to "CENTER".
    set tower4label3:style:width to 50.
    set tower4label3:tooltip to "Mechazilla Current/Desired Arm Open Angle".
local tower4label4 is towerstackvlayout4:addlabel("<b>0*</b>").
    set tower4label4:style:wordwrap to false.
    set tower4label4:style:vstretch to true.
    set tower4label4:style:fontsize to 14.
    set tower4label4:style:align to "CENTER".
    set tower4label4:style:width to 50.
    set tower4label4:tooltip to "Mechazilla Current/Desired Height".

local tower5button2 is towerstackvlayout5:addbutton("<b>></b>").
    set tower5button2:style:margin:top to 8.
    set tower5button2:style:margin:left to 0.
    set tower5button2:style:width to 25.
    set tower5button2:style:height to 25.
    set tower5button2:style:fontsize to 20.
local tower5button3 is towerstackvlayout5:addbutton("<b>></b>").
    set tower5button3:style:margin:top to 12.
    set tower5button3:style:margin:left to 0.
    set tower5button3:style:width to 25.
    set tower5button3:style:height to 25.
    set tower5button3:style:fontsize to 20.
local tower5button4 is towerstackvlayout5:addbutton("<b>^</b>").
    set tower5button4:style:margin:top to 12.
    set tower5button4:style:margin:left to 0.
    set tower5button4:style:width to 25.
    set tower5button4:style:height to 25.
    set tower5button4:style:fontsize to 20.

local tower6button2 is towerstackvlayout6:addbutton("<b>>></b>").
    set tower6button2:style:margin:top to 8.
    set tower6button2:style:margin:left to 0.
    set tower6button2:style:width to 35.
    set tower6button2:style:height to 25.
    set tower6button2:style:fontsize to 20.
local tower6button3 is towerstackvlayout6:addbutton("<b>>></b>").
    set tower6button3:style:margin:top to 12.
    set tower6button3:style:margin:left to 0.
    set tower6button3:style:width to 35.
    set tower6button3:style:height to 25.
    set tower6button3:style:fontsize to 20.
local tower6button4 is towerstackvlayout6:addbutton("<b>^^</b>").
    set tower6button4:style:margin:top to 12.
    set tower6button4:style:margin:left to 0.
    set tower6button4:style:width to 35.
    set tower6button4:style:height to 25.
    set tower6button4:style:fontsize to 20.

local tower7label2 is towerstackvlayout7:addlabel("<b>PUSH</b>").
    set tower7label2:style:wordwrap to false.
    set tower7label2:style:vstretch to true.
    set tower7label2:style:fontsize to 16.
    set tower7label2:style:align to "LEFT".
    set tower7label2:style:width to 45.
    set tower7label2:tooltip to "Mechazilla Pusher Controls".
local tower7label3 is towerstackvlayout7:addlabel("<b>STAB</b>").
    set tower7label3:style:wordwrap to false.
    set tower7label3:style:vstretch to true.
    set tower7label3:style:fontsize to 16.
    set tower7label3:style:align to "LEFT".
    set tower7label3:style:width to 45.
    set tower7label3:tooltip to "Mechazilla Stabilizer Controls".
local tower7label4 is towerstackvlayout7:addlabel("<b>OTHR</b>").
    set tower7label4:style:wordwrap to false.
    set tower7label4:style:vstretch to true.
    set tower7label4:style:fontsize to 16.
    set tower7label4:style:align to "LEFT".
    set tower7label4:style:width to 45.
    set tower7label4:tooltip to "Additional Orbital Launch Mount Controls".
    set tower7label4:style:bg to "starship_img/tower_page_background".
    set tower7label4:style:overflow:top to 35.
    set tower7label4:style:overflow:bottom to 3.
    set tower7label4:style:overflow:right to 110.
    set tower7label4:style:overflow:left to -100.

local tower8button2 is towerstackvlayout8:addbutton("<b>0.2m</b>").
    set tower8button2:style:margin:top to 8.
    set tower8button2:style:margin:left to 0.
    set tower8button2:style:width to 35.
    set tower8button2:style:height to 25.
    set tower8button2:style:fontsize to 12.
    set tower8button2:tooltip to "Mechazilla Pushers Setting for carrying a Booster. <color=red><b>DO NOT USE FOR SHIP</b></color>".

local tower9button2 is towerstackvlayout9:addbutton("<b>0.7m</b>").
    set tower9button2:style:margin:top to 8.
    set tower9button2:style:margin:left to 0.
    set tower9button2:style:width to 35.
    set tower9button2:style:height to 25.
    set tower9button2:style:fontsize to 12.
    set tower9button2:tooltip to "Mechazilla Pushers Setting for carrying a Ship".

local tower10button2 is towerstackvlayout10:addbutton("<b>OPEN</b>").
    set tower10button2:style:margin:top to 8.
    set tower10button2:style:margin:left to 0.
    set tower10button2:style:width to 50.
    set tower10button2:style:height to 25.
    set tower10button2:style:fontsize to 12.
    set tower10button2:tooltip to "Mechazilla Pushers Open Setting".

local tower11button2 is towerstackvlayout11:addbutton("<b><</b>").
    set tower11button2:style:margin:top to 8.
    set tower11button2:style:margin:left to 0.
    set tower11button2:style:width to 50.
    set tower11button2:style:height to 25.
    set tower11button2:style:fontsize to 15.
    set tower11button2:tooltip to "Move Ship Closer to Tower".
local tower11button3 is towerstackvlayout11:addbutton("<b>STOW</b>").
    set tower11button3:style:margin:top to 12.
    set tower11button3:style:margin:left to 0.
    set tower11button3:style:width to 50.
    set tower11button3:style:height to 25.
    set tower11button3:style:fontsize to 12.
    set tower11button3:tooltip to "Disengage Mechazilla Stabilizers".
local tower11button4 is towerstackvlayout11:addbutton("<b>FUEL</b>").
    set tower11button4:style:margin:top to 12.
    set tower11button4:style:margin:left to 0.
    set tower11button4:style:width to 50.
    set tower11button4:style:height to 25.
    set tower11button4:style:align to "CENTER".
    set tower11button4:style:fontsize to 14.
    set tower11button4:tooltip to "Toggle Refueling".

local tower12label2 is towerstackvlayout12:addlabel("<b>0*</b>").
    set tower12label2:style:wordwrap to false.
    set tower12label2:style:vstretch to true.
    set tower12label2:style:fontsize to 15.
    set tower12label2:style:align to "CENTER".
    set tower12label2:style:width to 65.
    set tower12label2:tooltip to "Mechazilla Pushers current/desired FWD/AFT movement".
local tower12label3 is towerstackvlayout12:addlabel("<b>0*</b>").
    set tower12label3:style:wordwrap to false.
    set tower12label3:style:vstretch to true.
    set tower12label3:style:fontsize to 14.
    set tower12label3:style:align to "CENTER".
    set tower12label3:style:width to 65.
    set tower12label3:tooltip to "Mechazilla Stabilizers Status".
local tower12label4 is towerstackvlayout12:addlabel("<b></b>").
    set tower12label4:style:wordwrap to false.
    set tower12label4:style:vstretch to true.
    set tower12label4:style:fontsize to 14.
    set tower12label4:style:align to "CENTER".
    set tower12label4:style:width to 65.

local tower13button2 is towerstackvlayout13:addbutton("<b>></b>").
    set tower13button2:style:margin:top to 8.
    set tower13button2:style:margin:left to 0.
    set tower13button2:style:width to 50.
    set tower13button2:style:height to 25.
    set tower13button2:style:fontsize to 15.
    set tower13button2:tooltip to "Move Ship further away from Tower".
local tower13button3 is towerstackvlayout13:addbutton("<b>ACT.</b>").
    set tower13button3:style:margin:top to 12.
    set tower13button3:style:margin:left to 0.
    set tower13button3:style:width to 50.
    set tower13button3:style:height to 25.
    set tower13button3:style:fontsize to 12.
    set tower13button3:tooltip to "Engage Mechazilla Stabilizers".
local tower13button4 is towerstackvlayout13:addbutton("<b><color=red>STOP!</color></b>").
    set tower13button4:style:margin:top to 12.
    set tower13button4:style:margin:left to 0.
    set tower13button4:style:width to 50.
    set tower13button4:style:height to 25.
    set tower13button4:style:align to "CENTER".
    set tower13button4:style:fontsize to 14.
    set tower13button4:tooltip to "Activate EMERGENCY STOP! Stops all tower movement..".

set tower2button2:onclick to {
    if towerrot = -52 {}
    else {
        if towerrot > 8 {
            set towerrot to 8.
        }
        else {
            set towerrot to - 52.
        }
        if OnOrbitalMount {
            if towerang = 0 {
                sendMessage(Processor(volume("OrbitalLaunchMount")), ("MechazillaArms," + towerrot:tostring + ",1.0," + towerang:tostring + ",false")).
            }
            else {
                sendMessage(Processor(volume("OrbitalLaunchMount")), ("MechazillaArms," + towerrot:tostring + ",1.0," + towerang:tostring + ",true")).
            }
        }
        else {
            if towerang = 0 {
                sendMessage(Vessel("OrbitalLaunchMount"), ("MechazillaArms," + towerrot:tostring + ",1.0," + towerang:tostring + ",false")).
            }
            else {
                sendMessage(Vessel("OrbitalLaunchMount"), ("MechazillaArms," + towerrot:tostring + ",1.0," + towerang:tostring + ",true")).
            }
        }
    }
}.

set tower3button2:onclick to {
    if towerrot = -52 {}
    else {
        set towerrot to towerrot - 1.
        if OnOrbitalMount {
            if towerang = 0 {
                sendMessage(Processor(volume("OrbitalLaunchMount")), ("MechazillaArms," + towerrot:tostring + ",1.0," + towerang:tostring + ",false")).
            }
            else {
                sendMessage(Processor(volume("OrbitalLaunchMount")), ("MechazillaArms," + towerrot:tostring + ",1.0," + towerang:tostring + ",true")).
            }
        }
        else {
            if towerang = 0 {
                sendMessage(Vessel("OrbitalLaunchMount"), ("MechazillaArms," + towerrot:tostring + ",1.0," + towerang:tostring + ",false")).
            }
            else {
                sendMessage(Vessel("OrbitalLaunchMount"), ("MechazillaArms," + towerrot:tostring + ",1.0," + towerang:tostring + ",true")).
            }
        }
    }
}.

set tower5button2:onclick to {
    if towerrot = 52 {}
    else {
        set towerrot to towerrot + 1.
        if OnOrbitalMount {
            if towerang = 0 {
                sendMessage(Processor(volume("OrbitalLaunchMount")), ("MechazillaArms," + towerrot:tostring + ",1.0," + towerang:tostring + ",false")).
            }
            else {
                sendMessage(Processor(volume("OrbitalLaunchMount")), ("MechazillaArms," + towerrot:tostring + ",1.0," + towerang:tostring + ",true")).
            }
        }
        else {
            if towerang = 0 {
                sendMessage(Vessel("OrbitalLaunchMount"), ("MechazillaArms," + towerrot:tostring + ",1.0," + towerang:tostring + ",false")).
            }
            else {
                sendMessage(Vessel("OrbitalLaunchMount"), ("MechazillaArms," + towerrot:tostring + ",1.0," + towerang:tostring + ",true")).
            }
        }
    }
}.

set tower6button2:onclick to {
    if towerrot = 52 {}
    else {
        if towerrot < 8 {
            set towerrot to 8.
        }
        else {
            set towerrot to 52.
        }
        if OnOrbitalMount {
            if towerang = 0 {
                sendMessage(Processor(volume("OrbitalLaunchMount")), ("MechazillaArms," + towerrot:tostring + ",1.0," + towerang:tostring + ",false")).
            }
            else {
                sendMessage(Processor(volume("OrbitalLaunchMount")), ("MechazillaArms," + towerrot:tostring + ",1.0," + towerang:tostring + ",true")).
            }
        }
        else {
            if towerang = 0 {
                sendMessage(Vessel("OrbitalLaunchMount"), ("MechazillaArms," + towerrot:tostring + ",1.0," + towerang:tostring + ",false")).
            }
            else {
                sendMessage(Vessel("OrbitalLaunchMount"), ("MechazillaArms," + towerrot:tostring + ",1.0," + towerang:tostring + ",true")).
            }
        }
    }
}.


set tower2button3:onclick to {
    if towerang = 5 {
        set towerang to 0.
        if OnOrbitalMount {
            sendMessage(Processor(volume("OrbitalLaunchMount")), ("MechazillaArms," + towerrot:tostring + ",1.0," + towerang:tostring + ",false")).
        }
        else {
            sendMessage(Vessel("OrbitalLaunchMount"), ("MechazillaArms," + towerrot:tostring + ",1.0," + towerang:tostring + ",false")).
        }
    }
    else if towerang = 0 {}
    else {
        set towerang to 5.
        if OnOrbitalMount {
            sendMessage(Processor(volume("OrbitalLaunchMount")), ("MechazillaArms," + towerrot:tostring + ",1.0," + towerang:tostring + ",true")).
        }
        else {
            sendMessage(Vessel("OrbitalLaunchMount"), ("MechazillaArms," + towerrot:tostring + ",1.0," + towerang:tostring + ",true")).
        }
    }
}.

set tower3button3:onclick to {
    if towerang = 0 {}
    else if towerang = 5 {}
    else {
        set towerang to towerang - 1.
        if OnOrbitalMount {
            sendMessage(Processor(volume("OrbitalLaunchMount")), ("MechazillaArms," + towerrot:tostring + ",1.0," + towerang:tostring + ",true")).
        }
        else {
            sendMessage(Vessel("OrbitalLaunchMount"), ("MechazillaArms," + towerrot:tostring + ",1.0," + towerang:tostring + ",true")).
        }
    }
}.

set tower5button3:onclick to {
    if towerang = 0 {
        set towerang to 4.
    }
    if towerang = 95 {}
    else {
        set towerang to towerang + 1.
        if OnOrbitalMount {
            sendMessage(Processor(volume("OrbitalLaunchMount")), ("MechazillaArms," + towerrot:tostring + ",1.0," + towerang:tostring + ",true")).
        }
        else {
            sendMessage(Vessel("OrbitalLaunchMount"), ("MechazillaArms," + towerrot:tostring + ",1.0," + towerang:tostring + ",true")).
        }
    }
}.

set tower6button3:onclick to {
    if towerang = 95 {}
    else {
        set towerang to 95.
        if OnOrbitalMount {
            sendMessage(Processor(volume("OrbitalLaunchMount")), ("MechazillaArms," + towerrot:tostring + ",1.0," + towerang:tostring + ",true")).
        }
        else {
            sendMessage(Vessel("OrbitalLaunchMount"), ("MechazillaArms," + towerrot:tostring + ",1.0," + towerang:tostring + ",true")).
        }
    }
}.


set tower2button4:onclick to {
    if towerhgt = 0 {}
    else {
        set towerhgt to 0.
        if OnOrbitalMount {
            sendMessage(Processor(volume("OrbitalLaunchMount")), ("MechazillaHeight," + (65 - towerhgt):tostring + ",0.5")).
        }
        else {
            sendMessage(Vessel("OrbitalLaunchMount"), ("MechazillaHeight," + (65 - towerhgt):tostring + ",0.5")).
        }
    }
}.

set tower3button4:onclick to {
    if towerhgt = 0 {}
    else {
        set towerhgt to towerhgt - 1.
        if OnOrbitalMount {
            sendMessage(Processor(volume("OrbitalLaunchMount")), ("MechazillaHeight," + (65 - towerhgt):tostring + ",0.5")).
        }
        else {
            sendMessage(Vessel("OrbitalLaunchMount"), ("MechazillaHeight," + (65 - towerhgt):tostring + ",0.5")).
        }
    }
}.

set tower5button4:onclick to {
    if towerhgt = 65 {}
    else {
        set towerhgt to towerhgt + 1.
        if OnOrbitalMount {
            sendMessage(Processor(volume("OrbitalLaunchMount")), ("MechazillaHeight," + (65 - towerhgt):tostring + ",0.5")).
        }
        else {
            sendMessage(Vessel("OrbitalLaunchMount"), ("MechazillaHeight," + (65 - towerhgt):tostring + ",0.5")).
        }
    }
}.

set tower6button4:onclick to {
    if towerhgt = 65 {}
    else {
        set towerhgt to 65.
        if OnOrbitalMount {
            sendMessage(Processor(volume("OrbitalLaunchMount")), ("MechazillaHeight," + (65 - towerhgt):tostring + ",0.5")).
        }
        else {
            sendMessage(Vessel("OrbitalLaunchMount"), ("MechazillaHeight," + (65 - towerhgt):tostring + ",0.5")).
        }
    }
}.


set tower8button2:onclick to {
    set towerpush to 0.2.
    if OnOrbitalMount {
        sendMessage(Processor(volume("OrbitalLaunchMount")), ("MechazillaPushers," + towerpushfwd:tostring + ",0.2," + towerpush:tostring + ",true")).
    }
    else {
        sendMessage(Vessel("OrbitalLaunchMount"), ("MechazillaPushers," + towerpushfwd:tostring + ",0.2," + towerpush:tostring + ",true")).
    }
}.
set tower9button2:onclick to {
    set towerpush to 0.7.
    if OnOrbitalMount {
        sendMessage(Processor(volume("OrbitalLaunchMount")), ("MechazillaPushers," + towerpushfwd:tostring + ",0.2," + towerpush:tostring + ",true")).
    }
    else {
        sendMessage(Vessel("OrbitalLaunchMount"), ("MechazillaPushers," + towerpushfwd:tostring + ",0.2," + towerpush:tostring + ",true")).
    }
}.
set tower10button2:onclick to {
    set towerpush to 12.5.
    if OnOrbitalMount {
        sendMessage(Processor(volume("OrbitalLaunchMount")), ("MechazillaPushers," + towerpushfwd:tostring + ",0.2," + towerpush:tostring + ",true")).
    }
    else {
        sendMessage(Vessel("OrbitalLaunchMount"), ("MechazillaPushers," + towerpushfwd:tostring + ",0.2," + towerpush:tostring + ",true")).
    }
}.
set tower11button2:onclick to {
    if towerpushfwd = -6 {}
    else {
        set towerpushfwd to towerpushfwd - 0.25.
        if OnOrbitalMount {
            sendMessage(Processor(volume("OrbitalLaunchMount")), ("MechazillaPushers," + towerpushfwd:tostring + ",0.2," + towerpush:tostring + ",true")).
        }
        else {
            sendMessage(Vessel("OrbitalLaunchMount"), ("MechazillaPushers," + towerpushfwd:tostring + ",0.2," + towerpush:tostring + ",true")).
        }
    }
}.
set tower13button2:onclick to {
    if towerpushfwd = 6 {}
    else {
        set towerpushfwd to towerpushfwd + 0.25.
        if OnOrbitalMount {
            sendMessage(Processor(volume("OrbitalLaunchMount")), ("MechazillaPushers," + towerpushfwd:tostring + ",0.2," + towerpush:tostring + ",true")).
        }
        else {
            sendMessage(Vessel("OrbitalLaunchMount"), ("MechazillaPushers," + towerpushfwd:tostring + ",0.2," + towerpush:tostring + ",true")).
        }
    }
}.


set tower11button3:onclick to {
    if towerstab = 0 {}
    else {
        set towerstab to 0.
        if OnOrbitalMount {
            sendMessage(Processor(volume("OrbitalLaunchMount")), "MechazillaStabilizers,0").
        }
        else {
            sendMessage(Vessel("OrbitalLaunchMount"), ("MechazillaStabilizers,0")).
        }
    }
}.

set tower13button3:onclick to {
    if towerstab = maxstabengage {}
    else {
        set towerstab to maxstabengage.
        if OnOrbitalMount {
            sendMessage(Processor(volume("OrbitalLaunchMount")), ("MechazillaStabilizers," + maxstabengage)).
        }
        else {
            sendMessage(Vessel("OrbitalLaunchMount"), ("MechazillaStabilizers," + maxstabengage)).
        }
    }
}.

set tower11button4:onclick to {
    if OnOrbitalMount {
        if not Refueling {
            set Refueling to true.
            sendMessage(Processor(volume("OrbitalLaunchMount")), "ToggleReFueling,true").
            set tower11button4:text to "<b><color=cyan>FUEL</color></b>".
            if BoosterInterstage:length > 0 {
                BoosterInterstage[0]:getmodule("ModuleToggleCrossfeed"):DoAction("enable crossfeed", true).
            }
        }
        else {
            set Refueling to false.
            sendMessage(Processor(volume("OrbitalLaunchMount")), "ToggleReFueling,false").
            set tower11button4:text to "<b>FUEL</b>".
            if BoosterInterstage:length > 0 {
                BoosterInterstage[0]:getmodule("ModuleToggleCrossfeed"):DoAction("disable crossfeed", true).
            }
        }
    }
}.

set tower13button4:onclick to {
    FindParts().
    if OnOrbitalMount {
        sendMessage(Processor(volume("OrbitalLaunchMount")), "EmergencyStop").
    }
    else {
        sendMessage(Vessel("OrbitalLaunchMount"), "EmergencyStop").
    }
}.


local maneuverstackhlayout to maneuverstack:addhlayout().
    set maneuverstackhlayout:style:bg to "starship_img/starship_main_square_bg".
local maneuverstackvlayout1 is maneuverstackhlayout:addvlayout().
    set maneuverstackvlayout1:style:vstretch to true.
local maneuverstackvlayout2 is maneuverstackhlayout:addvlayout().
local maneuverstackvlayout3 is maneuverstackhlayout:addvlayout().

local maneuver1label1 is maneuverstackvlayout1:addlabel("<b>Selected Maneuver:</b>").
    set maneuver1label1:style:wordwrap to false.
    set maneuver1label1:style:margin:top to 5.
    set maneuver1label1:style:margin:left to 10.
    set maneuver1label1:style:fontsize to 18.
    set maneuver1label1:style:width to 200.
    set maneuver1label1:style:height to 35.
    set maneuver1label1:style:align to "LEFT".
    set maneuver1label1:tooltip to "Select a Maneuver in the next window to start".
local ManeuverPicker is maneuverstackvlayout2:addpopupmenu().
    set ManeuverPicker:style:textcolor to white.
    set ManeuverPicker:style:fontsize to 18.
    set ManeuverPicker:style:margin:top to 5.
    set ManeuverPicker:style:width to 175.
    set ManeuverPicker:style:height to 35.
    set ManeuverPicker:style:border:v to 10.
    set ManeuverPicker:style:border:h to 10.
    set ManeuverPicker:style:bg to "starship_img/starship_background".
    set ManeuverPicker:style:normal:bg to "starship_img/starship_background".
    set ManeuverPicker:style:on:bg to "starship_img/starship_background_light".
    set ManeuverPicker:style:hover:bg to "starship_img/starship_background_light".
    set ManeuverPicker:style:hover_on:bg to "starship_img/starship_background_light".
    set ManeuverPicker:style:active:bg to "starship_img/starship_background_light".
    set ManeuverPicker:style:active_on:bg to "starship_img/starship_background_light".
    set ManeuverPicker:style:focused:bg to "starship_img/starship_background_light".
    set ManeuverPicker:style:focused_on:bg to "starship_img/starship_background_light".
    set ManeuverPicker:options to list("<color=grey><b>Select Maneuver</b></color>", "<b><color=white>Auto-Dock</color></b>", "<b><color=white>Circularize at Pe</color></b>", "<b><color=white>Circularize at Ap</color></b>", "<b><color=white>Execute Burn</color></b>").
    set ManeuverPicker:tooltip to "Select a Maneuver here:  e.g.  docking, circularizing, performing a burn".
local maneuver3button is maneuverstackvlayout3:addbutton("<b>CREATE</b>").
    set maneuver3button:style:margin:top to 5.
    set maneuver3button:style:margin:left to 50.
    set maneuver3button:style:width to 100.
    set maneuver3button:style:height to 35.
    set maneuver3button:style:fontsize to 18.
    set maneuver3button:tooltip to "Create / Start / Execute Maneuver".
set maneuver3button:enabled to false.

local maneuver2label1 is maneuverstackvlayout1:addlabel("").
    set maneuver2label1:style:wordwrap to false.
    set maneuver2label1:style:fontsize to 18.
    set maneuver2label1:style:margin:left to 10.
    set maneuver2label1:style:width to 200.
    set maneuver2label1:style:height to 30.
    set maneuver2label1:style:align to "LEFT".
    set maneuver2label1:tooltip to "Select a Target for Auto-Docking (needs to be within 10km distance)".
local maneuver2label2 is maneuverstackvlayout2:addlabel("").
    set maneuver2label2:style:wordwrap to false.
    set maneuver2label2:style:fontsize to 18.
    set maneuver2label2:style:width to 200.
    set maneuver2label2:style:height to 30.
    set maneuver2label2:style:align to "LEFT".
    set maneuver2label2:tooltip to "".
local TargetPicker is maneuverstackvlayout2:addpopupmenu().
    set TargetPicker:style:textcolor to white.
    set TargetPicker:style:fontsize to 18.
    set TargetPicker:style:width to 175.
    set TargetPicker:style:height to 30.
    set TargetPicker:style:border:v to 10.
    set TargetPicker:style:border:h to 10.
    set TargetPicker:style:bg to "starship_img/starship_background".
    set TargetPicker:style:normal:bg to "starship_img/starship_background".
    set TargetPicker:style:on:bg to "starship_img/starship_background_light".
    set TargetPicker:style:hover:bg to "starship_img/starship_background_light".
    set TargetPicker:style:hover_on:bg to "starship_img/starship_background_light".
    set TargetPicker:style:active:bg to "starship_img/starship_background_light".
    set TargetPicker:style:active_on:bg to "starship_img/starship_background_light".
    set TargetPicker:style:focused:bg to "starship_img/starship_background_light".
    set TargetPicker:style:focused_on:bg to "starship_img/starship_background_light".
    set TargetPicker:options to list("<color=grey><b>Select Target</b></color>").
    set TargetPicker:tooltip to "Select a Target here (targets are checked every 5 seconds)".
TargetPicker:hide().
local maneuver2textfield2 is maneuverstackvlayout2:addtextfield("75").
    set maneuver2textfield2:style:width to 175.
    set maneuver2textfield2:style:height to 30.
    set maneuver2textfield2:tooltip to "".
maneuver2textfield2:hide().
local maneuver2label3 is maneuverstackvlayout3:addlabel("").
    set maneuver2label3:style:wordwrap to false.
    set maneuver2label3:style:fontsize to 18.
    set maneuver2label3:style:width to 175.
    set maneuver2label3:style:height to 30.
    set maneuver2label3:style:align to "LEFT".
    set maneuver2label3:tooltip to "".

local maneuver3label1 is maneuverstackvlayout1:addlabel("").
    set maneuver3label1:style:wordwrap to false.
    set maneuver3label1:style:fontsize to 18.
    set maneuver3label1:style:margin:left to 10.
    set maneuver3label1:style:width to 200.
    set maneuver3label1:style:height to 30.
    set maneuver3label1:style:align to "LEFT".
    set maneuver3label1:tooltip to "".
local maneuver3label2 is maneuverstackvlayout2:addlabel("").
    set maneuver3label2:style:wordwrap to false.
    set maneuver3label2:style:fontsize to 18.
    set maneuver3label2:style:width to 200.
    set maneuver3label2:style:height to 30.
    set maneuver3label2:style:align to "LEFT".
    set maneuver3label2:tooltip to "".
local maneuver3label3 is maneuverstackvlayout3:addlabel("").
    set maneuver3label3:style:wordwrap to false.
    set maneuver3label3:style:fontsize to 18.
    set maneuver3label3:style:width to 175.
    set maneuver3label3:style:height to 30.
    set maneuver3label3:style:align to "LEFT".
    set maneuver3label3:tooltip to "".


set ManeuverPicker:onchange to {
    parameter choice.
    if choice = "<color=grey><b>Select Maneuver</b></color>" {
        set maneuver2label1:text to "".
        set maneuver3button:text to "<b>CREATE</b>".
        set maneuver3button:enabled to false.
        maneuver2textfield2:hide().
        TargetPicker:hide().
        maneuver2label2:show().
    }
    if choice = "<b><color=white>Auto-Dock</color></b>" {
        set maneuver2label1:text to "<b>Select Target (<10km):</b>".
        set maneuver3button:text to "<b>START</b>".
        set maneuver3button:enabled to true.
        maneuver2label2:hide().
        maneuver2textfield2:hide().
        TargetPicker:show().
    }
    if choice = "<b><color=white>Circularize at Pe</color></b>" {
        set maneuver2label1:text to "<b></b>".
        set maneuver3button:text to "<b>CREATE</b>".
        set maneuver3button:enabled to true.
        maneuver2textfield2:hide().
        TargetPicker:hide().
        maneuver2label2:show().
    }
    if choice = "<b><color=white>Circularize at Ap</color></b>" {
        set maneuver2label1:text to "<b></b>".
        set maneuver3button:text to "<b>CREATE</b>".
        set maneuver3button:enabled to true.
        maneuver2textfield2:hide().
        TargetPicker:hide().
        maneuver2label2:show().
    }
    if choice = "<b><color=white>Execute Burn</color></b>" {
        set maneuver2label1:text to "<b></b>".
        set maneuver3button:text to "<b>EXECUTE</b>".
        set maneuver3button:enabled to true.
        maneuver2textfield2:hide().
        TargetPicker:hide().
        maneuver2label2:show().
    }
}.


set TargetPicker:onchange to {
    parameter choice.
    if choice = "<color=grey><b>Select Target</b></color>" {
        set maneuver3label1:text to "".
        set maneuver3label2:text to "".
        set maneuver3label3:text to "".
        set TargetSelected to false.
    }
    else {
        if KUniverse:activevessel = vessel(ship:name) {}
        else {
            set KUniverse:activevessel to vessel(ship:name).
        }
        set target to Vessel(choice).
        set TargetSelected to true.
    }
}.

set maneuver3button:onclick to {
    if not AutodockingIsRunning {
        Droppriority().
        if ManeuverPicker:text = "<color=grey><b>Select Maneuver</b></color>" {

        }
        if ManeuverPicker:text = "<b><color=white>Auto-Dock</color></b>" {
            if TargetPicker:text = "" or TargetPicker:text = "<color=grey><b>Select Target</b></color>" {}
            else {
                InhibitButtons(1,1,0).
                HideEngineToggles(1).
                ShowButtons(0).
                set ship:control:translation to v(0, 0, 0).
                set AutodockingIsRunning to true.
                set message1:style:textcolor to white.
                set message1:style:textcolor to white.
                set message1:style:textcolor to white.
                set maneuver3button:enabled to false.
                set ManeuverPicker:enabled to false.
                set TargetPicker:enabled to false.
                GoHome().
                sas off.
                set Continue to false.
                lock steering to AutoDockSteering().

                until ship:dockingports[0]:state = "Docked (docker)" or ship:dockingports[0]:state = "Docked (dockee)" or ship:dockingports[0]:state = "Docked (same vessel)" or cancelconfirmed {}

                set maneuver3button:enabled to true.
                set ManeuverPicker:enabled to true.
                set TargetPicker:enabled to true.
                unlock steering.
                Droppriority().
                HideEngineToggles(0).
                ShowButtons(1).
                set ship:control:translation to v(0, 0, 0).
                set AutodockingIsRunning to false.
                if ship:dockingports[0]:haspartner {
                    wait 1.
                    set ManeuverPicker:index to 0.
                    HUDTEXT("Docking Port Acquired! 'Docking Complete' may take a few more seconds (when wobbly)..", 10, 2, 20, green, false).
                }
                rcs off.
                ClearInterfaceAndSteering().
            }
        }
        if ManeuverPicker:text = "<b><color=white>Circularize at Pe</color></b>" {
            set PerformingManeuver to true.
            if eta:periapsis > 0 {
                if hasnode {
                    remove nextnode.
                    wait 0.001.
                }
                set OrbitalVelocity to ship:body:radius * sqrt(Planet1G / (ship:body:radius + periapsis)).
                set ProgradeVelocity to OrbitalVelocity - velocityat(ship, time:seconds + eta:periapsis):orbit:mag.
                if not (KUniverse:activevessel = vessel(ship:name)) {
                    set KUniverse:activevessel to vessel(ship:name).
                }
                PerformBurn(eta:periapsis, ProgradeVelocity, 0).
            }
            else {
                GoHome().
                set message1:text to "<b><color=yellow>Can't circularize when escaping..</color></b>".
                wait 3.
            }
            set PerformingManeuver to false.
            ClearInterfaceAndSteering().
        }
        if ManeuverPicker:text = "<b><color=white>Circularize at Ap</color></b>" {
            set PerformingManeuver to true.
            if apoapsis > 0 {
                if hasnode {
                    remove nextnode.
                    wait 0.001.
                }
                set OrbitalVelocity to ship:body:radius * sqrt(Planet1G / (ship:body:radius + apoapsis)).
                set ProgradeVelocity to OrbitalVelocity - velocityat(ship, time:seconds + eta:apoapsis):orbit:mag.
                if not (KUniverse:activevessel = vessel(ship:name)) {
                    set KUniverse:activevessel to vessel(ship:name).
                }
                PerformBurn(eta:apoapsis, ProgradeVelocity, 0).
            }
            else {
                GoHome().
                set message1:text to "<b><color=yellow>Can't circularize when escaping..</color></b>".
                wait 3.
            }
            set PerformingManeuver to false.
            ClearInterfaceAndSteering().
        }
        if ManeuverPicker:text = "<b><color=white>Execute Burn</color></b>" {
            set PerformingManeuver to true.
            if hasnode {
                if not (KUniverse:activevessel = vessel(ship:name)) {
                    set KUniverse:activevessel to vessel(ship:name).
                }
                PerformBurn(0, 0, 1).
            }
            else {
                GoHome().
                set message1:text to "<b><color=yellow>No Maneuver Node found..</color></b>".
                wait 3.
            }
            set PerformingManeuver to false.
            ClearInterfaceAndSteering().
        }
    }
}.


function AutoDockSteering {
    set runningprogram to "Auto-Docking".
    set status1:style:textcolor to green.
    if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
    set RCSFactor to 3.
    if not hastarget {
        set TargetPicker:index to 0.
        set cancelconfirmed to true.
        return lookdirup(facing:forevector, facing:topvector).
    }
    if ship:dockingports[0]:haspartner {
        set TargetPicker:index to 0.
        set cancelconfirmed to true.
        return lookdirup(facing:forevector, facing:topvector).
    }
    if target:distance < 2000 {
        set PortDistanceVector to target:dockingports[0]:nodeposition - ship:dockingports[0]:nodeposition.
        set CheckVector to PortDistanceVector.
    }
    else {
        set PortDistanceVector to target:position - ship:position.
        set CheckVector to PortDistanceVector.
    }
    //print "Angle: " + vang(target:facing:topvector, PortDistanceVector).
    //print "Continue: " + Continue.
    //print "Distance: " + round(PortDistanceVector:mag,1).
    if KUniverse:activevessel = vessel(ship:name) {}
    else {
        set KUniverse:activevessel to vessel(ship:name).
        HUDTEXT("Auto-Docking Cancelled!", 10, 2, 20, red, false).
        HUDTEXT("Switching ships not allowed during Auto-Docking..", 10, 2, 20, red, false).
        set cancelconfirmed to true.
        return lookdirup(facing:forevector, facing:topvector).
    }
    if vang(target:facing:topvector, CheckVector) < 120 and Continue = "False" {
        DetermineSafeVector().
        //print "Distance <120*: " + round(PortDistanceVector:mag,1).
    }
    else if Continue = "False" and vang(target:facing:topvector, CheckVector) < 135 {
        DetermineSafeVector().
        //print "Distance >120*: " + round(PortDistanceVector:mag,1).
    }
    else {
        set Continue to true.
    }
    if vang(target:facing:topvector, CheckVector) > 135 and Continue = "False" or PortDistanceVector:mag < 25 and Continue = "False" {
        set Continue to true.
    }
    set RelativeDistanceX to vdot(facing:forevector, PortDistanceVector).
    set RelativeDistanceY to vdot(facing:starvector, PortDistanceVector).
    set RelativeDistanceZ to vdot(facing:topvector, PortDistanceVector).
    set RelativeVelocityVector to target:velocity:orbit - ship:velocity:orbit.
    set RelativeVelocityX to vdot(facing:forevector, RelativeVelocityVector).
    set RelativeVelocityY to vdot(facing:starvector, RelativeVelocityVector).
    set RelativeVelocityZ to vdot(facing:topvector, RelativeVelocityVector).

    rcs on.
    if not BGUisRunning {
        BackGroundUpdate().
    }

    //clearscreen.
    //print "Rel Vel x: " + round(RelativeVelocityX,2).
    //print "Rel Vel y: " + round(RelativeVelocityY,2).
    //print "Rel Vel z: " + round(RelativeVelocityZ,2).
    //print "".
    //print "Rel Dist x: " + round(RelativeDistanceX,2).
    //print "Rel Dist y: " + round(RelativeDistanceY,2).
    //print "Rel Dist z: " + round(RelativeDistanceZ,2).
    //print "Distance: " + round(PortDistanceVector:mag,2).

    set message1:text to "<b><color=green>Auto-Docking in Progress..</color></b>  <size=13><color=yellow>(DON'T CHANGE VESSEL)</color></size>".
    if Continue {
        set message2:text to "<b>Target:</b>  Docking Port  (" + round(PortDistanceVector:mag, 1) + "m)".
    }
    else {
        set message2:text to "<b>Target:</b>  Intermediate Safe Point  (" + round(PortDistanceVector:mag, 1) + "m)".
    }
    if PortDistanceVector:mag < 15 {
        set message3:text to "<b>Relative Distance (m):   </b><size=14>X: " + round(RelativeDistanceX, 2) + "   Y: " + round(RelativeDistanceY,2) + "   Z: " + round(RelativeDistanceZ,2) + "</size>".
    }
    else {
        set message3:text to "<b>Relative Velocity (m/s):   </b><size=14>X: " + round(RelativeVelocityX, 2) + "   Y: " + round(RelativeVelocityY,2) + "   Z: " + round(RelativeVelocityZ,2) + "</size>".
    }

    if PortDistanceVector:mag > 10000 {
        set cancelconfirmed to true.
        return lookdirup(PortDistanceVector, facing:topvector).
    }
    else if PortDistanceVector:mag > 1500 {
        if vang(PortDistanceVector, facing:forevector) < 2.5 {
            set ship:control:translation to v(0 + RCSFactor * RelativeVelocityY, 0 + RCSFactor * RelativeVelocityZ, 25 * RCSFactor + RCSFactor * RelativeVelocityX).
        }
        return lookdirup(PortDistanceVector, facing:topvector).
    }
    else if PortDistanceVector:mag > 250 and PortDistanceVector:mag < 1500 {
        if vang(PortDistanceVector, facing:forevector) < 2.5 {
            set ship:control:translation to v(0 + RCSFactor * RelativeVelocityY, 0 + RCSFactor * RelativeVelocityZ, 5 * RCSFactor + RCSFactor * RelativeVelocityX).
        }
        return lookdirup(PortDistanceVector, facing:topvector).
    }
    else if PortDistanceVector:mag > 100 and PortDistanceVector:mag < 250 {
        if vang(PortDistanceVector, facing:forevector) < 2.5 {
            set ship:control:translation to v(0 + RCSFactor * RelativeVelocityY, 0 + RCSFactor * RelativeVelocityZ, 2.5 * RCSFactor + RCSFactor * RelativeVelocityX).
        }
        return lookdirup(PortDistanceVector, facing:topvector).
    }
    else if PortDistanceVector:mag > 60 and PortDistanceVector:mag < 100 {
        if vang(PortDistanceVector, facing:forevector) < 2.5 {
            set ship:control:translation to v(0 + RCSFactor * RelativeVelocityY, 0 + RCSFactor * RelativeVelocityZ, 1.25 * RCSFactor + RCSFactor * RelativeVelocityX).
        }
        return lookdirup(PortDistanceVector, facing:topvector).
    }
    else if Continue {
        if RelativeVelocityX < -0.11 and vang(PortDistanceVector, facing:forevector) < 2.5 {
            set ship:control:translation to v(0 + RCSFactor * RelativeVelocityY, 0 + RCSFactor * RelativeVelocityZ, 0.1 + RCSFactor * RelativeVelocityX).
            return lookdirup(PortDistanceVector, facing:topvector).
        }
        else {
            if vang(target:facing:forevector, facing:forevector) < 1.25 and vang(facing:topvector, -target:facing:topvector) < 2.5 {
                set ship:control:translation to v(0 + RelativeDistanceY / RCSFactor + RCSFactor * RelativeVelocityY, 0 + RelativeDistanceZ / RCSFactor + RCSFactor * RelativeVelocityZ, 0 + RelativeDistanceX / RCSFactor + RCSFactor * RelativeVelocityX).
            }
            else {
                set ship:control:translation to v(0, 0, 0).
            }
            return lookdirup(target:facing:forevector, -target:dockingports[0]:portfacing:vector).
        }
    }
    else {
        if vang(PortDistanceVector, facing:forevector) < 2.5 {
            set ship:control:translation to v(0 + RCSFactor * RelativeVelocityY, 0 + RCSFactor * RelativeVelocityZ, 1.25 * RCSFactor + RCSFactor * RelativeVelocityX).
        }
        return lookdirup(PortDistanceVector, facing:topvector).
    }
}

function DetermineSafeVector {
    if target:distance < 2000 {
        set SafeVector1 to target:dockingports[0]:nodeposition + 75 * target:facing:topvector + -50 * target:facing:forevector + 50 * target:facing:starvector - ship:dockingports[0]:nodeposition.
        set SafeVector2 to target:dockingports[0]:nodeposition + 75 * target:facing:topvector + -50 * target:facing:forevector - 50 * target:facing:starvector - ship:dockingports[0]:nodeposition.
        if SafeVector1:mag < SafeVector2:mag {
            set PortDistanceVector to SafeVector1.
        }
        else {
            set PortDistanceVector to SafeVector2.
        }
    }
    else {
        set SafeVector1 to target:position + 75 * target:facing:topvector + -50 * target:facing:forevector + 50 * target:facing:starvector - ship:dockingports[0]:nodeposition.
        set SafeVector2 to target:position + 75 * target:facing:topvector + -50 * target:facing:forevector - 50 * target:facing:starvector - ship:dockingports[0]:nodeposition.
        if SafeVector1:mag < SafeVector2:mag {
            set PortDistanceVector to SafeVector1.
        }
        else {
            set PortDistanceVector to SafeVector2.
        }
    }
}


local statusbar is box_all:addhlayout().
    set statusbar:style:margin:h to 0.
    set statusbar:style:height to 35.
local tooltip is statusbar:addtipdisplay().
    set tooltip:style:wordwrap to false.
    set tooltip:style:hstretch to false.
    set tooltip:style:vstretch to true.
    set tooltip:style:fontsize to 13.
    set tooltip:style:textcolor to rgb(0.75, 0.75, 0.75).
    set tooltip:style:margin:left to 10.
    set tooltip:style:width to 1.
local status1 is statusbar:addlabel().
    set status1:style:wordwrap to false.
    set status1:style:vstretch to true.
    set status1:style:margin:left to 10.
    set status1:style:fontsize to 16.
local statusstretch1 is statusbar:addlabel().
    set statusstretch1:style:hstretch to true.
local status2 is statusbar:addlabel().
    set status2:style:wordwrap to false.
    set status2:style:vstretch to true.
    set status2:style:fontsize to 16.
    set status2:style:align to "CENTER".
local statusstretch2 is statusbar:addlabel().
    set statusstretch2:style:hstretch to true.
local status3 is statusbar:addlabel().
    set status3:style:vstretch to true.
    set status3:style:wordwrap to false.
    set status3:style:width to 80.
    set status3:style:border:top to 0.
    set status3:style:border:bottom to 0.
    set status3:style:border:left to 0.
    set status3:style:border:right to 0.
    set status3:style:overflow:top to -3.
    set status3:style:overflow:bottom to -3.
    set status3:style:overflow:left to -60.
    set status3:style:overflow:right to 0.
    set status3:style:fontsize to 16.
    set status3:style:align to "RIGHT".
local execute is statusbar:addbutton("<b>EXECUTE</b>").
    set execute:style:width to 75.
    set execute:style:margin:left to 10.
    set execute:tooltip to "Execute selected Command".

local cancel is statusbar:addbutton("<b>CANCEL</b>").
    set cancel:style:width to 65.
    set cancel:tooltip to "Cancel selected Command".

set execute:onclick to {
    LogToFile("Execute button clicked").
    if not InhibitExecute {
        if LandButtonIsRunning or LaunchButtonIsRunning or PerformingManeuver or ClosingIsRunning {
            LogToFile("Executing").
            set executeconfirmed to 1.
            set execute:pressed to false.
        }
    }
}.

set cancel:onclick to {
    LogToFile("Cancel button clicked").
    if not InhibitCancel {
        if LandButtonIsRunning or LaunchButtonIsRunning or AutodockingIsRunning or PerformingManeuver or ClosingIsRunning {
            LogToFile("Cancelling").
            set cancelconfirmed to 1.
            set cancel:pressed to false.
        }
    }
}.

    
set launchbutton:ontoggle to {
    parameter click.
    if not LaunchButtonIsRunning and not LaunchComplete {
        set LaunchButtonIsRunning to true.
        LogToFile("Launch button clicked").
        ShowButtons(0).
        Droppriority().
        set landlabel:style:textcolor to grey.
        set landlabel:style:bg to "starship_img/starship_background".
        if click {
            if ship:body = BODY("Kerbin") and Boosterconnected {
                set runningprogram to "Input".
                if alt:radar < 100 {
                    if quicksetting2:pressed {
                        set rolldir to heading(270,0).
                    }
                    else {
                        set rolldir to heading(90,0).
                    }
                    if vang(ship:facing:topvector, rolldir:vector) < 30 and CargoMass < MaxCargoToOrbit + 1 and cargo1text:text = "Closed" {
                        GoHome().
                        InhibitButtons(0, 0, 0).
                        if ShipsInOrbit():length > 0 {
                            set TargetShip to false.
                            until false {
                                for ship in ShipsInOrbit {
                                    if quicksetting2:pressed {
                                        set message1:text to "<b>Launch to Target</b>  (within ± 15km)".
                                    }
                                    else {
                                        set message1:text to "<b>Launch to Target</b>  (within ± 15km, 180° Roll)".
                                    }
                                    set message2:text to "<b>Rendezvous Target:  <color=green>" + ship:name + "</color></b>".
                                    set message3:text to "<b>Confirm <color=white>or</color> Cancel?</b>".
                                    set message3:style:textcolor to cyan.
                                    set execute:text to "<b>CONFIRM</b>".
                                    if confirm() {
                                        set TargetShip to ship.
                                        break.
                                    }
                                }
                                break.
                            }
                            set execute:text to "<b>LAUNCH</b>".
                        }
                        if TargetShip = 0 {
                            if quicksetting2:pressed {
                                set message1:text to "<b>Launch to Parking Orbit</b>  (± 75km)".
                            }
                            else {
                                set message1:text to "<b>Launch to Parking Orbit</b>  (± 75km, 180° Roll)".
                            }
                        }
                        else {
                            set message1:text to "<b>Launch to Ship:  <color=green>" + TargetShip:name + "</color></b>".
                        }
                        set message2:text to "<b>Booster Return to Launch Site</b>".
                        if quicksetting1:pressed {
                            set message3:text to "<b>Launch <color=white>or</color> Cancel?</b>  <color=yellow>(Auto-Warp enabled)</color>".
                        }
                        else {
                            set message3:text to "<b>Launch <color=white>or</color> Cancel?</b>".
                        }
                        set message1:style:textcolor to white.
                        set message2:style:textcolor to white.
                        set message3:style:textcolor to cyan.
                        set execute:text to "<b>LAUNCH</b>".
                        set launchlabel:style:textcolor to white.
                        if confirm() {
                            set execute:text to "<b>EXECUTE</b>".
                            LogToFile("Starting Launch Function").
                            if TargetShip = 0 {}
                            else {
                                set LaunchTimeSpanInSeconds to 244 + (Cargo / MaxCargoToOrbit) * 18.
                                set LaunchDistance to 183000 + (Cargo / MaxCargoToOrbit) * 14000.
                                if NrOfVacEngines = 3 {
                                    set LaunchTimeSpanInSeconds to LaunchTimeSpanInSeconds + 3.
                                }
                                set LongitudeToRendezvous to 360 * (LaunchTimeSpanInSeconds / TargetShip:orbit:period).
                                set OrbitalCircumferenceDelta to (((LongitudeToRendezvous / 360) * 471239) / 4241150) * 360 * 0.5.
                                set LongitudeToRendezvous to LongitudeToRendezvous - OrbitalCircumferenceDelta.
                                //print "delta Longitude: " + LongitudeToRendezvous.
                                set IdealLaunchTargetShipsLongitude to ship:geoposition:lng + (LaunchDistance / (1000 * Planet1Degree)) - LongitudeToRendezvous.
                                //print "Launch when Target passes Longitude: " + IdealLaunchTargetShipsLongitude.

                                set LaunchToRendezvousLng to mod(IdealLaunchTargetShipsLongitude - TargetShip:geoposition:lng, 360).
                                if LaunchToRendezvousLng < 0 {
                                    set LaunchToRendezvousLng to 360 + LaunchToRendezvousLng.
                                }
                                set LaunchToRendezvousTime to (LaunchToRendezvousLng / 360) * TargetShip:orbit:period.
                                set LaunchToRendezvousTime to LaunchToRendezvousTime + ((((LaunchToRendezvousTime + LaunchTimeSpanInSeconds) / (6 * 3600)) * 360) / 360) * TargetShip:orbit:period.

                                set LaunchTime to time:seconds + LaunchToRendezvousTime - 16.

                                InhibitButtons(1, 1, 0).
                                set cancel:text to "<b>ABORT</b>".
                                set cancel:style:textcolor to red.
                                set message3:style:textcolor to white.
                                set runningprogram to "Countdown".
                                until time:seconds > LaunchTime and time:seconds < LaunchTime + 2 or cancelconfirmed {
                                    if kuniverse:timewarp:warp > 5 {
                                        set kuniverse:timewarp:warp to 5.
                                    }
                                    if LaunchTime - time:seconds < 900 and kuniverse:timewarp:warp > 4 {
                                        set kuniverse:timewarp:warp to 4.
                                    }
                                    if LaunchTime - time:seconds < 60 and kuniverse:timewarp:warp > 0 {
                                        set kuniverse:timewarp:warp to 0.
                                    }
                                    set message1:text to "<b>All Systems:              <color=green>GO</color></b>".
                                    set message2:text to "<b>Launch to:                 <color=green>" + TargetShip:name + "</color></b>".
                                    set message3:text to "<b>Launch Countdown:</b>  " + timeSpanCalculator(LaunchTime - time:seconds + 16).
                                    if not BGUisRunning {
                                        BackGroundUpdate().
                                    }
                                }
                                if cancelconfirmed {
                                    ClearInterfaceAndSteering().
                                    return.
                                }
                            }
                            Launch().
                        }
                        else {
                            set execute:text to "<b>EXECUTE</b>".
                            LogToFile("Launch Function cancelled").
                            ClearInterfaceAndSteering().
                        }
                    }
                    else {
                        ClearInterfaceAndSteering().
                        if TotalCargoMass[0] > MaxCargoToOrbit + 1 {
                            LogToFile("Launch cancelled due to too much Cargo").
                            set message1:text to "<b>Error: Over Max Payload.. </b>(" + round(TotalCargoMass[0]) + " kg)".
                            set message2:text to "<b>Maximum Payload: </b>" + MaxCargoToOrbit + " kg".
                            set message3:text to "<b></b>".
                        }
                        else if cargo1text:text = "Open" or cargo1text:text = "Moving..." {
                            LogToFile("Launch cancelled due to Cargo Door Open").
                            set message1:text to "<b>Error: Cargo Door still open!</b>".
                            set message2:text to "<b>Please close the Cargo Door and try again.</b>".
                            set message3:text to "<b></b>".
                        }
                        else {
                            if quicksetting2:pressed {
                                set message1:text to "<b>Error: Ship not rotated for 0° Roll..</b>".
                            }
                            else {
                                set message1:text to "<b>Error: Ship not rotated for 180° Roll..</b>".
                            }
                            LogToFile("Launch cancelled due to wrong roll orientation").
                            set message2:text to "<b>Check the Settings Page.</b>".
                        }
                        set message3:text to "<b>Launch cancelled.</b>".
                        set message1:style:textcolor to yellow.
                        set message2:style:textcolor to yellow.
                        set message3:style:textcolor to yellow.
                        wait 3.
                        ClearInterfaceAndSteering().
                    }
                }
                else if verticalspeed > 1 and periapsis < 70000 {
                    LogToFile("Starting Launch Function").
                    Launch().
                }
                else {
                    ClearInterfaceAndSteering().
                    LogToFile("Launch cancelled due to conditions not fulfilled").
                    set message1:text to "<b>Error: Conditions not fulfilled..</b>".
                    set message2:text to "<b>Launch cancelled.</b>".
                    set message3:text to "".
                    set message1:style:textcolor to yellow.
                    set message2:style:textcolor to yellow.
                    set message3:style:textcolor to yellow.
                    wait 3.
                    ClearInterfaceAndSteering().
                }
            }
            else {
                ClearInterfaceAndSteering().
                LogToFile("Launch cancelled due to conditions not fulfilled").
                if Boosterconnected {
                    set message1:text to "<b>Error: You're not on Kerbin..</b>".
                }
                else {
                    set message1:text to "<b>Error: No Booster found..</b>".
                }
                set message2:text to "<b>Launch cancelled.</b>".
                set message3:text to "".
                set message1:style:textcolor to yellow.
                set message2:style:textcolor to yellow.
                set message3:style:textcolor to yellow.
                wait 3.
                ClearInterfaceAndSteering().
            }
        }
        else {
            LogToFile("Launch button UNclicked").
            ClearInterfaceAndSteering().
        }
    }
}.
    
    
set landbutton:ontoggle to {
    parameter click.
    if not LandButtonIsRunning {
        set LandButtonIsRunning to true.
        LogToFile("Land button clicked").
        ShowButtons(0).
        ShipsInOrbit().
        Droppriority().
        set message1:style:textcolor to white.
        set message2:style:textcolor to white.
        set message3:style:textcolor to white.
        if click {
            if ship:body = BODY("Kerbin") or ship:body = BODY("Duna") {
                GoHome().
                SetPlanetData().
                TotalCargoMass().
                if Cargo > MaxReEntryCargoKerbin and CargoCG < 125 and ship:body = BODY("Kerbin") or Cargo > MaxReEntryCargoDuna and ship:body = BODY("Duna") {
                    ClearInterfaceAndSteering().
                    LogToFile("De-Orbit cancelled due to Cargo Overload").
                    set message1:text to "<b>Error: Too much Cargo onboard!</b>".
                    set message2:text to "<b>Current Cargo Mass: </b><color=yellow>" + round(Cargo) + " kg</color>".
                    if ship:body = BODY("Kerbin") {
                        set message3:text to "<b>Maximum Re-Entry Cargo Mass: </b><color=yellow>" + MaxReEntryCargoKerbin + "kg</color>".
                    }
                    if ship:body = BODY("Duna") {
                        set message3:text to "<b>Maximum Re-Entry Cargo Mass: </b><color=yellow>" + MaxReEntryCargoDuna + "kg</color>".
                    }
                    set message1:style:textcolor to yellow.
                }
                else if CargoCG > 125 and Cargo < MaxReEntryCargoKerbin and ship:body = BODY("Kerbin") {
                    ClearInterfaceAndSteering().
                    LogToFile("De-Orbit cancelled due to Cargo Center of Gravity").
                    set message1:text to "<b>Error: Center of Gravity too far forward!</b>".
                    set message2:text to "<b>Current Cargo CoG: </b><color=yellow>" + round(CargoCG) + " index units</color>".
                    set message3:text to "<b>Maximum Re-Entry Cargo CoG: </b><color=yellow>125 index units</color>".
                    set message1:style:textcolor to yellow.
                }
                else if CargoCG > 125 and Cargo > MaxReEntryCargoKerbin and ship:body = BODY("Kerbin") {
                    ClearInterfaceAndSteering().
                    LogToFile("De-Orbit cancelled due to Cargo Overload").
                    set message1:text to "<b>Error: Too much Cargo onboard!</b>".
                    set message2:text to "<b>Current Cargo: </b><color=yellow>" + round(Cargo) + " kg & " + round(CargoCG) + " index units</color>".
                    set message3:text to "<b>Maximum Re-Entry Cargo: </b><color=yellow>10000 kg & 125 i. u.</color>".
                    set message1:style:textcolor to yellow.
                }
                else if cargo1text:text = "Open" {
                    ClearInterfaceAndSteering().
                    LogToFile("De-Orbit cancelled due to orbit requirements not fulfilled").
                    set message1:text to "<b>Error: Cargo Door still open!</b>".
                    set message2:text to "<b>Please close the Cargo Door and try again.</b>".
                    set message3:text to "<b></b>".
                    set message1:style:textcolor to yellow.
                    set message2:style:textcolor to yellow.
                    set message3:style:textcolor to yellow.
                }
                else {
                    set landlabel:style:textcolor to green.
                    set launchlabel:style:textcolor to grey.
                    set launchlabel:style:bg to "starship_img/starship_background".
                    set runningprogram to "Input".
                    if quickattitude2:pressed {
                        set quickattitude1:pressed to true.
                    }
                    if hasnode {
                        LogToFile("Existing Node removed").
                        remove nextnode.
                        wait 0.1.
                    }
                    if addons:tr:hasimpact {
                        set ErrorVector to ADDONS:TR:IMPACTPOS:POSITION - landingzone:POSITION.
                        if vang(landingzone:position - ship:position, velocity:surface) > 90 {
                            ClearInterfaceAndSteering().
                            LogToFile("Land Function Stopped due to landingzone too far away").
                            set message1:text to "<b>Re-Entry & Landing Cancelled.</b>".
                            set message1:style:textcolor to yellow.
                            set message2:text to "<b>Landingzone is still too far away..</b>".
                            set message2:style:textcolor to yellow.
                            wait 3.
                            ClearInterfaceAndSteering().
                            return.
                        }
                        LandingZoneFinder().
                        set JustCheckingWhatTheErrorIs to true.
                        set LngLatErrorList to LngLatError().
                        set JustCheckingWhatTheErrorIs to false.
                        if ship:body = BODY("Kerbin") {
                            set LongitudinalAcceptanceLimit to 50000.
                            set LatitudinalAcceptanceLimit to 20000.
                        }
                        if ship:body = BODY("Duna") {
                            set LongitudinalAcceptanceLimit to 25000.
                            set LatitudinalAcceptanceLimit to 15000.
                        }
                        if LngLatErrorList[0] > LongitudinalAcceptanceLimit or LngLatErrorList[0] < -LongitudinalAcceptanceLimit or LngLatErrorList[1] > LatitudinalAcceptanceLimit or LngLatErrorList[1] < -LatitudinalAcceptanceLimit {
                            GoHome().
                            set message1:text to "<b>Landingzone out of Range..   Slope:  </b>" + round(AvailableLandingSpots[3], 1) + "°".
                            set message2:text to "<b>Override Re-Entry?</b> (" + round((LngLatErrorList[0] - LandingOffset) / 1000, 2) + "km  " + round((LngLatErrorList[1] / 1000), 2) + "km)".
                            if quicksetting1:pressed {
                                set message3:text to "<b>Execute <color=white>or</color> Cancel?</b>  <color=yellow>(Auto-Warp enabled)</color>".
                            }
                            else {
                                set message3:text to "<b>Execute <color=white>or</color> Cancel?</b>".
                            }
                            set message1:style:textcolor to yellow.
                            set message2:style:textcolor to yellow.
                            set message3:style:textcolor to cyan.
                            set landlabel:style:textcolor to white.
                            InhibitButtons(0, 0, 0).
                            if confirm() {
                                LogToFile("Starting Re-Entry & Land Function").
                                ReEntryAndLand().
                            }
                            else {
                                LogToFile("Land Function cancelled").
                                ClearInterfaceAndSteering().
                                return.
                            }
                        }
                        else {
                            GoHome().
                            set message1:text to aoa + "° <b>AoA Re-Entry</b>".
                            if homeconnection:isconnected {
                                if exists("0:/settings.json") {
                                    set L to readjson("0:/settings.json").
                                    if L:haskey("Launch Coordinates") and L:haskey("Landing Coordinates") {
                                        if L["Landing Coordinates"] = L["Launch Coordinates"] {
                                            if OLMexists() {
                                                if L["Landing Coordinates"] = "-0.0972,-74.5577" {
                                                    set message2:text to "<b>Landing Zone:  <color=green>KSC Mechazilla</color></b>".
                                                }
                                                else {
                                                    set message2:text to "<b>Landing Zone:  <color=green>Mechazilla</color></b>".
                                                }
                                            }
                                            else {
                                                if L["Landing Coordinates"] = "-0.0972,-74.5577" {
                                                    set message2:text to "<b>Landing Zone:  <color=green>KSC Launchpad</color></b>".
                                                }
                                                else if L["Landing Coordinates"] = "-6.5604,-143.95" {
                                                    set message2:text to "<b>Landing Zone:  <color=green>Desert Launchpad</color></b>".
                                                }
                                                else {
                                                    set message2:text to "<b>Landing Zone:  <color=green>Launchpad</color></b>".
                                                }
                                            }
                                        }
                                        else if L["Landing Coordinates"] = "-6.5604,-143.95" {
                                            set message2:text to "<b>Landing Zone:  <color=green>Desert Launchpad</color></b>".
                                        }
                                        else if L["Landing Coordinates"] = "-0.0972,-74.5577" {
                                            set message2:text to "<b>Landing Zone:  <color=green>KSC Launchpad</color></b>".
                                        }
                                        else {
                                            set message2:text to "<b>Landing Zone:</b>  <color=yellow>" + round(landingzone:lat, 4) + "," + round(landingzone:lng, 4) + "</color>   <b>Slope:</b> " + round(AvailableLandingSpots[3], 1) + "°".
                                        }
                                    }
                                }
                            }
                            else {
                                set message2:text to "<b>Landing Zone:</b>  <color=yellow>" + round(landingzone:lat, 4) + "," + round(landingzone:lng, 4) + "</color>   <b>Slope:</b> " + round(AvailableLandingSpots[3], 1) + "°".
                            }
                            set message1:style:textcolor to white.
                            set message2:style:textcolor to white.
                            set message3:style:textcolor to cyan.
                            if quicksetting1:pressed {
                                set message3:text to "<b>Execute <color=white>or</color> Cancel?</b>  <color=yellow>(Auto-Warp enabled)</color>".
                            }
                            else {
                                set message3:text to "<b>Execute <color=white>or</color> Cancel?</b>".
                            }
                            set landlabel:style:textcolor to white.
                            InhibitButtons(0, 0, 0).
                            if confirm() {
                                LogToFile("Starting Re-Entry & Land Function").
                                ReEntryAndLand().
                            }
                            else {
                                LogToFile("Land Function cancelled").
                                ClearInterfaceAndSteering().
                            }
                        }
                    }
                    if not addons:tr:hasimpact and ship:body = BODY("Kerbin") or not addons:tr:hasimpact and ship:body = BODY("Duna") {
                        if ship:status = "LANDED" or ship:status = "PRELAUNCH" {
                            LogToFile("Land Function cancelled due to ship:status").
                            ClearInterfaceAndSteering().
                        }
                        else if apoapsis > 100000 and ship:body = BODY("Kerbin") or periapsis < 70000 and ship:body = BODY("Kerbin") or apoapsis > 75000 and ship:body = BODY("Duna") or periapsis < 50000 and ship:body = BODY("Duna") or max(ship:orbit:inclination, -ship:orbit:inclination) + 2.5 < max(setting3:text:split(",")[0]:toscalar(5), -setting3:text:split(",")[0]:toscalar(5)) {
                            ClearInterfaceAndSteering().
                            LogToFile("De-Orbit cancelled due to orbit requirements not fulfilled").
                            set message1:text to "<b>Automatic De-Orbit Requirements:</b>".
                            if ship:body = BODY("Kerbin") {
                                set message2:text to "<b>Ap/Pe 70-100km   LZ latitude < Inclination</b>".
                            }
                            if ship:body = BODY("Duna") {
                                set message2:text to "<b>Ap/Pe 50-75km   LZ latitude < Inclination</b>".
                            }
                            set message3:text to "<b>Modify orbit or perform manual de-orbit..</b>".
                            set message2:style:textcolor to yellow.
                            set message3:style:textcolor to yellow.
                        }
                        else {
                            set message1:text to "<b>Target Landing Zone:</b>".
                            if homeconnection:isconnected {
                                if exists("0:/settings.json") {
                                    set L to readjson("0:/settings.json").
                                    if L:haskey("Launch Coordinates") and L:haskey("Landing Coordinates") {
                                        if L["Landing Coordinates"] = L["Launch Coordinates"] {
                                            if OLMexists() {
                                                if L["Landing Coordinates"] = "-0.0972,-74.5577" {
                                                    set message2:text to "<b><color=yellow>  KSC Mechazilla</color></b>".
                                                }
                                                else {
                                                    set message2:text to "<b><color=yellow>  Mechazilla</color></b>".
                                                }
                                            }
                                            else {
                                                if L["Landing Coordinates"] = "-0.0972,-74.5577" {
                                                    set message2:text to "<b><color=yellow>  KSC Launch Pad</color></b>".
                                                }
                                                else if L["Landing Coordinates"] = "-6.5604,-143.9500" {
                                                    set message2:text to "<b><color=yellow>  Desert Launch Pad</color></b>".
                                                }
                                                else {
                                                    set message2:text to "<b>Latitude/Longitude:</b>  <color=yellow>" + round(landingzone:lat, 4) + "," + round(landingzone:lng, 4) + "</color>".
                                                }
                                            }
                                        }
                                        else {
                                            set message2:text to "<b>Latitude/Longitude:</b>  <color=yellow>" + round(landingzone:lat, 4) + "," + round(landingzone:lng, 4) + "</color>".
                                        }
                                    }
                                }
                            }
                            else {
                                set message2:text to "<b>Latitude/Longitude:</b>  <color=yellow>" + round(landingzone:lat, 4) + "," + round(landingzone:lng, 4) + "</color>".
                            }
                            set message3:style:textcolor to cyan.
                            set message3:text to "<b>Confirm <color=white>or</color> Cancel?</b>".
                            set execute:text to "<b>CONFIRM</b>".
                            InhibitButtons(0, 0, 0).
                            if confirm() {

                            }
                            else {
                                set execute:text to "<b>EXECUTE</b>".
                                ClearInterfaceAndSteering().
                                set settingsbutton:pressed to true.
                                return.
                            }
                            set execute:text to "<b>EXECUTE</b>".
                            set message3:text to "".
                            if LFShip > FuelVentCutOffValue {
                                GoHome().
                                set drainBegin to LFShip.
                                set landlabel:style:textcolor to white.
                                set message1:text to "<b>Required Fuel Venting:</b>  " + timeSpanCalculator((LFShip - FuelVentCutOffValue) / VentRate).
                                set message2:text to "<b>until ΔV =</b>  ± 450m/s".
                                if quicksetting1:pressed {
                                    set message3:text to "<b>Execute <color=white>or</color> Cancel?</b>  <color=yellow>(Auto-Warp enabled)</color>".
                                }
                                else {
                                    set message3:text to "<b>Execute <color=white>or</color> Cancel?</b>".
                                }
                                set message3:style:textcolor to cyan.
                                InhibitButtons(0, 0, 0).
                                if confirm() {
                                    if KUniverse:activevessel = vessel(ship:name) {}
                                    else {
                                        set KUniverse:activevessel to vessel(ship:name).
                                    }
                                    LogToFile("Start Venting").
                                    set landlabel:style:textcolor to green.
                                    InhibitButtons(0, 1, 0).
                                    sas on.
                                    set runningprogram to "Venting Fuel..".
                                    HideEngineToggles(1).
                                    Nose[0]:activate.
                                    Tank[0]:activate.
                                    set throttle to 0.
                                    set message1:text to "<b>Fuel Vent Progress:</b>".
                                    set message2:text to "".
                                    set message3:text to "".
                                    set message3:style:textcolor to white.
                                    until cancelconfirmed or LFShip < FuelVentCutOffValue or runningprogram = "Input" {
                                        if not cancelconfirmed {
                                            if KUniverse:activevessel = vessel(ship:name) {}
                                            else {
                                                break.
                                            }
                                            set message2:text to round((((drainBegin - FuelVentCutOffValue) - (LFShip - FuelVentCutOffValue)) / (LFcap - (LFcap - drainBegin) - FuelVentCutOffValue)) * 100, 1):tostring + "% Complete".
                                            set message3:text to "<b>Time Remaining:</b> " + timeSpanCalculator((LFShip - FuelVentCutOffValue) / VentRate).
                                            BackGroundUpdate().
                                        }
                                    }
                                    ShutdownEngines().
                                    if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
                                    LogToFile("Stop Venting").
                                    HideEngineToggles(0).
                                    set message1:text to "".
                                    set message2:text to "".
                                    set message3:text to "".
                                    if cancelconfirmed {
                                        ShutdownEngines().
                                        HideEngineToggles(0).
                                        LogToFile("Venting stopped by user").
                                        set BGUisRunning to false.
                                        set runningprogram to "None".
                                        ClearInterfaceAndSteering().
                                    }
                                }
                                else {
                                    ShutdownEngines().
                                    HideEngineToggles(0).
                                    LogToFile("Venting cancelled by user").
                                    ClearInterfaceAndSteering().
                                }
                            }
                            if LFShip < FuelVentCutOffValue {
                                set runningprogram to "Input".
                                if KUniverse:activevessel = vessel(ship:name) {}
                                else {
                                    set KUniverse:activevessel to vessel(ship:name).
                                    wait 3.
                                }
                                GoHome().
                                LandingZoneFinder().
                                InhibitButtons(1,1,1).
                                LogToFile("Calculating De-Orbit Burn").
                                set landlabel:style:textcolor to white.
                                set message1:text to "<b>Looking for suitable Re-Entry Trajectory..</b>".
                                set message2:text to "".
                                set message1:style:textcolor to white.
                                set message2:style:textcolor to white.
                                set deorbitburnstarttime to timestamp(time:seconds + CalculateDeOrbitBurn(0)).
                                set ProgradeVelocity to DeOrbitVelocity().
                                if ProgradeVelocity = 0 and DeOrbitFailed {
                                    set message1:text to "<b>No suitable Trajectory found today..</b>".
                                    set message1:style:textcolor to yellow.
                                    set message2:text to "<b>Try again later..</b>".
                                    set message2:style:textcolor to yellow.
                                    wait 3.
                                    ClearInterfaceAndSteering().
                                    return.
                                }
                                if ProgradeVelocity < CutOff + 1 and ProgradeVelocity > StartPoint {
                                    mainbox:showonly(flightstack).
                                    set settingsbutton:pressed to false.
                                    set cargobutton:pressed to false.
                                    set statusbutton:pressed to false.
                                    set orbitbutton:pressed to false.
                                    set attitudebutton:pressed to false.
                                    set enginebutton:pressed to false.
                                    if (landingzone:position - addons:tr:impactpos:position):mag > ErrorTolerance {
                                        ClearInterfaceAndSteering().
                                        LogToFile("Automatic De-Orbit burn not possible, target too far away from estimaged impact").
                                        set message1:text to "<b>Automatic De-Orbit Burn failed..</b>".
                                        set message1:style:textcolor to yellow.
                                        set message2:text to "<b>Is LZ close enough to the Equator?</b>".
                                        set message2:style:textcolor to yellow.
                                        set message3:text to "<b>De-orbiting manually or try again..</b>".
                                        set message3:style:textcolor to yellow.
                                        wait 3.
                                        ClearInterfaceAndSteering().
                                        return.
                                    }.
                                    set message1:text to "<b>Suggested De-Orbit Burn and Re-Entry:</b>".
                                    if homeconnection:isconnected {
                                        if exists("0:/settings.json") {
                                            set L to readjson("0:/settings.json").
                                            if L:haskey("Launch Coordinates") and L:haskey("Landing Coordinates") {
                                                if L["Landing Coordinates"] = L["Launch Coordinates"] {
                                                    if OLMexists() {
                                                        if L["Landing Coordinates"] = "-0.0972,-74.5577" {
                                                            set message2:text to "<b>@:</b> " + deorbitburnstarttime:hour + ":" + deorbitburnstarttime:minute + ":" + deorbitburnstarttime:second + "<b>UT</b>   <b>ΔV:</b> " + round(ProgradeVelocity, 1) + "m/s   <b>LZ: <color=green>KSC <size=15>Mechazilla</size></color></b>".
                                                        }
                                                        else {
                                                            set message2:text to "<b>@:</b> " + deorbitburnstarttime:hour + ":" + deorbitburnstarttime:minute + ":" + deorbitburnstarttime:second + "<b>UT</b>   <b>ΔV:</b> " + round(ProgradeVelocity, 1) + "m/s   <b>LZ: <color=green>Mechazilla</color></b>".
                                                        }
                                                    }
                                                    else {
                                                        if L["Landing Coordinates"] = "-0.0972,-74.5577" {
                                                            set message2:text to "<b>@:</b> " + deorbitburnstarttime:hour + ":" + deorbitburnstarttime:minute + ":" + deorbitburnstarttime:second + "<b>UT</b>   <b>ΔV:</b> " + round(ProgradeVelocity, 1) + "m/s   <b>LZ: <color=green><size=17>KSC Launchpad</size></color></b>".
                                                        }
                                                        else if L["Landing Coordinates"] = "-6.5604,-143.9500" {
                                                            set message2:text to "<b>@:</b> " + deorbitburnstarttime:hour + ":" + deorbitburnstarttime:minute + ":" + deorbitburnstarttime:second + "<b>UT</b>   <b>ΔV:</b> " + round(ProgradeVelocity, 1) + "m/s   <b>LZ: <color=green><size=15>Desert Launchpad</size></color></b>".
                                                        }
                                                        else {
                                                            set message2:text to "<b>@:</b> " + deorbitburnstarttime:hour + ":" + deorbitburnstarttime:minute + ":" + deorbitburnstarttime:second + "<b>UT</b>   <b>ΔV:</b> " + round(ProgradeVelocity, 1) + "m/s   <b>LZ: <color=green>Launch Pad</color></b>".
                                                        }
                                                    }
                                                }
                                                else {
                                                    set message2:text to "<b>@:</b> " + deorbitburnstarttime:hour + ":" + deorbitburnstarttime:minute + ":" + deorbitburnstarttime:second + "<b>UT</b>   <b>ΔV:</b> " + round(ProgradeVelocity, 1) + "m/s   <b>LZ:</b> <size=17><color=yellow>" + landingzone:lat + "," + landingzone:lng + "</color></size>".
                                                }
                                            }
                                        }
                                    }
                                    else {
                                        set message2:text to "<b>@:</b> " + deorbitburnstarttime:hour + ":" + deorbitburnstarttime:minute + ":" + deorbitburnstarttime:second + "<b>UT</b>   <b>ΔV:</b> " + round(ProgradeVelocity, 1) + "m/s   <b>LZ:</b> <size=17><color=yellow>" + landingzone:lat + "," + landingzone:lng + "</color></size>".
                                    }
                                    if quicksetting1:pressed {
                                        set message3:text to "<b>Execute <color=white>or</color> Cancel?</b>  <color=yellow>(Auto-Warp enabled)</color>".
                                    }
                                    else {
                                        set message3:text to "<b>Execute <color=white>or</color> Cancel?</b>".
                                    }
                                    set message3:style:textcolor to cyan.
                                    set deorbitburn to node(deorbitburnstarttime, 0, 0, ProgradeVelocity).
                                    add deorbitburn.
                                    set deorbitburnstart to deorbitburn:deltav.
                                    InhibitButtons(0, 0, 0).
                                    if confirm() {
                                        LogToFile("Re-orienting for De-Orbit").
                                        InhibitButtons(1, 1, 0).
                                        if KUniverse:activevessel = vessel(ship:name) {}
                                        else {
                                            set KUniverse:activevessel to vessel(ship:name).
                                        }
                                        set landlabel:style:textcolor to green.
                                        set message3:style:textcolor to white.
                                        set runningprogram to "De-Orbit".
                                        HideEngineToggles(1).
                                        rcs on.
                                        Nose[0]:getmodule("ModuleRCSFX"):SetField("thrust limiter", 100).
                                        Tank[0]:getmodule("ModuleRCSFX"):SetField("thrust limiter", 100).
                                        set deorbitAccel to 40/ship:mass.
                                        set BurnDuration to deorbitburn:deltav:mag/deorbitAccel.
                                        sas off.
                                        rcs off.
                                        lock steering to lookdirup(deorbitburn:burnvector, ship:facing:topvector).
                                        if quicksetting1:pressed and deorbitburn:eta - 0.5 * BurnDuration > 60 {
                                            set kuniverse:timewarp:warp to 4.
                                        }
                                        if quicksetting1:pressed and deorbitburn:eta - 0.5 * BurnDuration > 600 {
                                            set kuniverse:timewarp:warp to 5.
                                        }
                                        until deorbitburn:eta < 0.5 * BurnDuration or cancelconfirmed and not ClosingIsRunning {
                                                BackGroundUpdate().
                                                if quicksetting1:pressed and kuniverse:timewarp:warp = 5 and deorbitburn:eta - 0.5 * BurnDuration < 900 or deorbitburn:eta - 0.5 * BurnDuration < 900 and kuniverse:timewarp:warp = 5 {
                                                    set kuniverse:timewarp:warp to 4.
                                                }
                                                if deorbitburn:eta - 0.5 * BurnDuration < 35 {
                                                    set kuniverse:timewarp:warp to 0.
                                                    rcs on.
                                                }
                                                else {rcs off.}
                                                set message1:text to "<b>Starting Burn in:</b>  " + timeSpanCalculator(deorbitburn:eta - 0.5 * BurnDuration).
                                                set message2:text to "<b>Target Attitude:</b>    Burnvector".
                                                set message3:text to "<b>Burn Duration:</b>      " + round(BurnDuration) + "s".
                                        }
                                        if KUniverse:activevessel = vessel(ship:name) {}
                                        else {
                                            set KUniverse:activevessel to vessel(ship:name).
                                        }
                                        if hasnode {
                                            if vang(deorbitburn:burnvector, ship:facing:forevector) < 2 and cancelconfirmed = false {
                                                LogToFile("Starting De-Orbit Burn").
                                                until vdot(deorbitburnstart, deorbitburn:deltav) < 1 or cancelconfirmed = true and not ClosingIsRunning {
                                                    BackGroundUpdate().
                                                    rcs on.
                                                    set ship:control:translation to v(0, 0, 1).
                                                    set ship:control:rotation to v(0, 0, 0).
                                                    set kuniverse:timewarp:warp to 0.
                                                    set message1:text to "<b>Performing De-Orbit Burn..</b>".
                                                    set BurnDuration to deorbitburn:deltav:mag/deorbitAccel.
                                                    set message3:text to "<b>Burn Duration:</b>      " + round(BurnDuration) + "s".
                                                }
                                                remove deorbitburn.
                                                unlock steering.
                                                HideEngineToggles(0).
                                                set ship:control:translation to v(0, 0, 0).
                                                rcs off.
                                                LogToFile("Stopping De-Orbit Burn").
                                                if not cancelconfirmed {
                                                    ReEntryAndLand().
                                                }
                                                else {
                                                    ClearInterfaceAndSteering().
                                                    return.
                                                }
                                            }
                                            else if not cancelconfirmed {
                                                remove deorbitburn.
                                                unlock steering.
                                                unlock throttle.
                                                HideEngineToggles(0).
                                                ClearInterfaceAndSteering().
                                                LogToFile("Stopping De-Orbit Burn due to wrong orientation").
                                                set message1:text to "<b>De-Orbit Burn Cancelled.</b>".
                                                set message1:style:textcolor to yellow.
                                                set message2:text to "<b>Incorrect orientation or stopped..</b>".
                                                set message2:style:textcolor to yellow.
                                            }
                                            else {
                                                ClearInterfaceAndSteering().
                                                HideEngineToggles(0).
                                                set ship:control:translation to v(0, 0, 0).
                                                rcs off.
                                                LogToFile("Stopping De-Orbit Burn due to user cancellation").
                                            }
                                        }
                                        else {
                                            set ship:control:translation to v(0, 0, 0).
                                            rcs off.
                                            HideEngineToggles(0).
                                            LogToFile("Stopping De-Orbit Burn due to loss of node").
                                            ClearInterfaceAndSteering().
                                        }
                                    }
                                    else {
                                        LogToFile("Stopping De-Orbit Burn").
                                        ClearInterfaceAndSteering().
                                    }
                                }
                                else if not DeOrbitFailed {
                                    LogToFile("Recalculating De-Orbit Burn").
                                    ClearInterfaceAndSteering().
                                    set landbutton:pressed to true.
                                }
                            }
                        }
                    }
                    else {
                        ClearInterfaceAndSteering().
                        LogToFile("Land Function Stopped").
                    }
                }
            }
            else {
                ClearInterfaceAndSteering().
                LogToFile("Land Function Stopped").
                set message1:text to "<b>De-Orbit & Landing Cancelled.</b>".
                set message1:style:textcolor to yellow.
                set message2:text to "<b>This program only works on Kerbin..</b>".
                set message2:style:textcolor to yellow.
                wait 3.
                ClearInterfaceAndSteering().
            }
        }
    }
}.


g:show().


if addons:tr:available and not startup {
    if Career():canmakenodes = true and Career():candoactions = true and Career():patchlimit > 0 {
        InhibitButtons(0, 1, 1).
        set runningprogram to "None".
        FindParts().
        if homeconnection:isconnected {
            if exists("0:/settings.json") {
                set L to readjson("0:/settings.json").
                if L:haskey("Switch Back To Ship") {
                    if L["Switch Back To Ship"] = "true" {
                        set setting1:pressed to true.
                    }
                    else {
                        set setting1:pressed to false.
                    }
                }
                if L:haskey("setting2") {
                    if L["setting2"] = "true" {
                        set setting2:pressed to true.
                    }
                    else {
                        set setting2:pressed to false.
                    }
                }
                if L:haskey("setting4") {
                    if L["setting4"] = "true" {
                        set setting4:pressed to true.
                    }
                    else {
                        set setting4:pressed to false.
                    }
                }
                if L:haskey("setting5") {
                    if L["setting5"] = "true" {
                        set setting5:pressed to true.
                    }
                    else {
                        set setting5:pressed to false.
                    }
                }
                if L:haskey("Log Data") {
                    if L["Log Data"] = "true" {
                        set quicksetting3:pressed to true.
                    }
                }
                if L:haskey("Auto-Warp") {
                    if L["Auto-Warp"] = "true" {
                        set quicksetting1:pressed to true.
                    }
                }
                if L:haskey("Landing Coordinates") {
                    set LandingCoords to L["Landing Coordinates"].
                    set setting3:text to LandingCoords.
                }
                else {
                    set LandingCoords to "-0.0972,-74.5577".
                    set setting3:text to LandingCoords.
                }
                if L:haskey("Roll") {
                    if L["Roll"] = "0" {
                        set quicksetting2:pressed to true.
                    }
                    else {
                        set quicksetting2:pressed to true.
                        set quicksetting2:pressed to false.
                    }
                }
                else {
                    set quicksetting2:pressed to true.
                    set quicksetting2:pressed to false.
                    set quicksetting2:pressed to true.
                }
                if L:haskey("ArmsHeight") {
                    set ArmsHeight to L["ArmsHeight"].
                }
            }
            else {
                set L to lexicon().
                set L["Landing Coordinates"] to "-0.0972,-74.5577".
                set LandingCoords to "-0.0972,-74.5577".
                set setting3:text to LandingCoords.
                writejson(L, "0:/settings.json").
            }
        }
        else {
            set LandingCoords to "-0.0972,-74.5577".
            set setting3:text to LandingCoords.
        }
        set LandingCoords to LandingCoords:split(",").
        set landingzone to latlng(LandingCoords[0]:toscalar, LandingCoords[1]:toscalar).
        if setting3:text = "-0.0972,-74.5577" {
            set TargetLZPicker:index to 1.
        }
        else if setting3:text = "-6.5604,-143.95" {
            set TargetLZPicker:index to 2.
        }
        else if setting3:text = "45.2896,136.11" {
            set TargetLZPicker:index to 3.
        }
        else {
            set TargetLZPicker:index to 0.
        }
        if kuniverse:activevessel = ship {
            set addons:tr:descentmodes to list(true, true, true, true).
            set addons:tr:descentgrades to list(false, false, false, false).
            set addons:tr:descentangles to list(aoa, aoa, aoa, aoa).
            ADDONS:TR:SETTARGET(landingzone).
        }
        if LIGHTS {set quickstatus2:pressed to true.}
        if GEAR {set quickstatus3:pressed to true.}
        if FLflap[0]:getmodule("ModuleSEPControlSurface"):GetField("Deploy") = true {
            set quickstatus1:pressed to true.
        }
        if SLEngines[0]:ignition = true and VACEngines[0]:ignition = true {
            set quickengine2:pressed to true.
            set quickengine3:pressed to true.
        }
        if SLEngines[0]:ignition = true {
            set quickengine2:pressed to true.
        }
        else if VACEngines[0]:ignition = true {
            set quickengine3:pressed to true.
        }
        else {
            set quickengine1:pressed to true.
        }
        if Boosterconnected {
            HideEngineToggles(1).
        }
        else {
            HideEngineToggles(0).
        }
        if ShipType = "Cargo" {
            cargobutton:show().
            if nose[0]:getmodule("ModuleAnimateGeneric"):hasevent("close cargo door") {
                set cargoimage:style:bg to "starship_img/starship_cargobay_open".
                set cargo1text:text to "Open".
                set cargo1text:style:textcolor to yellow.
            }
            else {
                set cargoimage:style:bg to "starship_img/starship_cargobay_closed".
                set cargo1text:text to "Closed".
                set cargo1text:style:textcolor to green.
            }
        }
        if ShipType = "Crew" {
            cargobutton:show().
            if nose[0]:getmodule("ModuleAnimateGeneric"):hasevent("close docking hatch") {
                set cargoimage:style:bg to "starship_img/starship_crew_hatch_open".
                set cargo1text:text to "Open".
                set cargo1text:style:textcolor to yellow.
            }
            else {
                set cargoimage:style:bg to "starship_img/starship_crew_hatch_closed".
                set cargo1text:text to "Closed".
                set cargo1text:style:textcolor to green.
            }
        }
        if ShipType = "Tanker" {
            set cargo1text:text to "Closed".
        }
    }
    else {
        set message1:text to "<b>Please upgrade your KSC facilities..</b>".
        set message1:style:textcolor to red.
        set message2:text to "<b>needs: makenodes, candoactions & patchlimit > 0</b>".
        set message2:style:textcolor to red.
        set message3:text to "<b>1 or more capabilities are not available..</b>".
        set message3:style:textcolor to red.
        set runningprogram to "<b>Self-Test Failed</b>".
    }
    set avionics to 0.
    if Career():canmakenodes = true {set avionics to avionics + 1.}
    if Career():candoactions = true {set avionics to avionics + 1.}
    if Career():patchlimit > 0 {set avionics to avionics + 1.}
    if avionics < 3 {
        set message22:text to "          AVNCS " + avionics + "/3".
        set message22:style:textcolor to yellow.
        set message22:style:bg to "starship_img/starship_chip_yellow".
    }
    else {
        set message22:text to "          AVNCS 3/3".
        set message22:style:textcolor to white.
        set message22:style:bg to "starship_img/starship_chip".
    }
    set startup to true.
    updatestatusbar.
    updateCargoPage.
}
else if not startup {
    set message1:text to "<b>Trajectories mod not found..</b>".
    set message1:style:textcolor to red.
    set runningprogram to "<b>Self-Test Failed</b>".
    updatestatusbar.
    set startup to true.
}


WHEN runningprogram = "None" THEN {
    BackGroundUpdate().
    preserve.
}

wait until exit.
LogToFile("Exit is now true, closing GUI").
g:dispose().
shutdown.


//--------------Launch Program--------------------------------//

    

function Launch {
    if not AbortInProgress and not LaunchComplete {
        set LaunchButtonIsRunning to true.
        clearscreen.
        mainbox:showonly(flightstack).
        if hasnode {
            remove nextnode.
            wait 0.001.
        }
        set launchlabel:style:textcolor to green.
        set message1:style:textcolor to white.
        set message2:style:textcolor to white.
        set message3:style:textcolor to white.
        HideEngineToggles(1).
        SetRadarAltitude().
        set BurnDuration to 0.
        LogToFile("Launch Program Started").
        set runningprogram to "Launch".
        ShowButtons(0).
        sas off.
        rcs off.
        setflaps(0, 0, 0, 20).

        SET KUNIVERSE:DEFAULTLOADDISTANCE:FLYING:UNLOAD TO 600000.
        SET KUNIVERSE:DEFAULTLOADDISTANCE:FLYING:LOAD TO 595000.
        WAIT 0.001.
        SET KUNIVERSE:DEFAULTLOADDISTANCE:FLYING:PACK TO 599990.
        SET KUNIVERSE:DEFAULTLOADDISTANCE:FLYING:UNPACK TO 590000.
        wait 0.001.

        SET KUNIVERSE:DEFAULTLOADDISTANCE:SUBORBITAL:UNLOAD TO 600000.
        SET KUNIVERSE:DEFAULTLOADDISTANCE:SUBORBITAL:LOAD TO 595000.
        WAIT 0.001.
        SET KUNIVERSE:DEFAULTLOADDISTANCE:SUBORBITAL:PACK TO 599990.
        SET KUNIVERSE:DEFAULTLOADDISTANCE:SUBORBITAL:UNPACK TO 590000.
        wait 0.001.

        set targetap to 75000.
        set OrbitBurnPitchCorrectionPID to PIDLOOP(0.075, 0, 0, -30, 0).
        set OrbitBurnPitchCorrectionPID:setpoint to targetap.

        if OnOrbitalMount {
            InhibitButtons(1, 1, 0).
            set cancel:text to "<b>ABORT</b>".
            set cancel:style:textcolor to red.
            sendMessage(Processor(volume("OrbitalLaunchMount")), "MechazillaArms,8,5,97.5,true").
            sendMessage(Processor(volume("OrbitalLaunchMount")), "MechazillaPushers,0,2,12.5,true").
            sendMessage(Processor(volume("OrbitalLaunchMount")), "MechazillaStabilizers,0").
            sendMessage(Processor(volume("OrbitalLaunchMount")), "MechazillaHeight,8,0.5").
            set x to time:seconds + 15.
            until x < time:seconds or cancelconfirmed {
                set message1:text to "<b>All Systems:               <color=green>GO</color></b>".
                set message3:text to "<b>Launch Countdown:  </b>" + round(x - time:seconds) + "<b> seconds</b>".
                if not BGUisRunning {
                    BackGroundUpdate().
                }
                if x - time:seconds > 5 {
                    set message2:text to "<b>Stage 0/Mechazilla:    <color=yellow>Disconnecting..</color></b>".
                }
                else {
                    set message2:text to "<b>Booster/Ship:             <color=green>Start-Up Confirmed..</color></b>".
                }
            }
            if cancelconfirmed {
                sendMessage(Processor(volume("OrbitalLaunchMount")), "MechazillaArms,8,5,97.5,false").
                sendMessage(Processor(volume("OrbitalLaunchMount")), "MechazillaPushers,0,0.25,0.7,true").
                sendMessage(Processor(volume("OrbitalLaunchMount")), ("MechazillaStabilizers," + maxstabengage)).
                sendMessage(Processor(volume("OrbitalLaunchMount")), "MechazillaHeight,3,0.5").
                ClearInterfaceAndSteering().
                return.
            }
        }

        if RadarAlt < 100 {
            lock throttle to 1.
            if ShipType = "Cargo" or ShipType = "Tanker" {
                InhibitButtons(1, 1, 1).
            }
            if OnOrbitalMount {
                sendMessage(Processor(volume("OrbitalLaunchMount")), "LiftOff").
            }
            SHIP:PARTSNAMED("SLE.SS.OLP")[0]:getmodule("LaunchClamp"):DoAction("release clamp", true).
            BoosterEngines[0]:getmodule("ModuleEnginesFX"):doaction("activate engine", true).
            set OnOrbitalMount to False.
            if round(ship:geoposition:lat, 3) = round(landingzone:lat, 3) or round(ship:geoposition:lng, 3) = round(landingzone:lng, 3) {}
            else {
                set landingzone to latlng(round(ship:geoposition:lat, 4), round(ship:geoposition:lng, 4)).
                set setting3:text to (landingzone:lat + "," + landingzone:lng).
                SaveToSettings("Landing Coordinates", (landingzone:lat + "," + landingzone:lng)).
            }
            SaveToSettings("Launch Coordinates", (landingzone:lat + "," + landingzone:lng)).
            LogToFile("Lift-Off").
        }
        else if apoapsis < targetap {
            lock throttle to 1.
            LogToFile("Launching").
        }.

        lock steering to LaunchSteering().

        when cancelconfirmed and not ClosingIsRunning and LaunchButtonIsRunning then {
            Droppriority().
            abort().
        }

        if Boosterconnected {
            when apoapsis > 55000 and not AbortInProgress then {
                unlock steering.
                LogToFile("Starting stage-separation").
                if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
                wait 0.001.
                lock throttle to 0.
                set CargoBeforeSeparation to TotalCargoMass[0].
                wait 1.
                if not cancelconfirmed {
                    if quicksetting2:pressed {
                        sendMessage(Processor(volume("Booster")), "Boostback, 0 Roll").
                    }
                    else {
                        sendMessage(Processor(volume("Booster")), "Boostback, 180 Roll").
                    }
                }
                BoosterInterstage[0]:getmodule("ModuleDockingNode"):doaction("undock node", true).
                set Boosterconnected to false.
                set CargoAfterSeparation to TotalCargoMass[0].
                InhibitButtons(1, 1, 1).
                set cancel:text to "<b>CANCEL</b>".
                rcs on.
                lock steering to LaunchSteering().
                set Booster to Vessel("Booster").
                set kuniverse:activevessel to vessel(ship:name).
                SaveToSettings("Ship Name", ship:name).
                HideEngineToggles(1).
                if not cancelconfirmed {
                    set StageSeparationTime to time:seconds.
                    until time:seconds > StageSeparationTime + 5 {
                        if not BGUisRunning {
                            BackGroundUpdate().
                        }
                    }
                }
                set config:ipu to 2000.
                if NrOfVacEngines = 3 {
                    set quickengine2:pressed to true.
                    SLEngines[0]:getmodule("ModuleGimbal"):SetField("gimbal limit", 0).
                    SLEngines[1]:getmodule("ModuleGimbal"):SetField("gimbal limit", 0).
                    SLEngines[2]:getmodule("ModuleGimbal"):SetField("gimbal limit", 0).
                }
                set quickengine3:pressed to true.
                unlock throttle.
                lock throttle to 1.
                LogToFile("Stage-separation Complete").
            }
        }
        else {
            if NrOfVacEngines = 3 {
                set quickengine2:pressed to true.
            }
            set quickengine3:pressed to true.
            lock throttle to 1.
            set cancel:text to "<b>CANCEL</b>".
            InhibitButtons(1, 1, 1).
        }

        when BurnComplete then {
            unlock steering.
            HUDTEXT("Changing Focus to: Booster", 5, 2, 20, red, false).
            wait 0.001.
            set throttle to 0.
            if NrOfVacEngines = 3 {
                SLEngines[0]:getmodule("ModuleGimbal"):SetField("gimbal limit", 100).
                SLEngines[1]:getmodule("ModuleGimbal"):SetField("gimbal limit", 100).
                SLEngines[2]:getmodule("ModuleGimbal"):SetField("gimbal limit", 100).
            }

            wait 0.001.
            unlock throttle.
            if hasnode {
                remove nextnode.
                wait 0.001.
            }
            set quickengine1:pressed to true.
            sas on.
            set message1:text to "<b>Current Orbit:</b>                    " + round(APOAPSIS / 1000, 1) + "km x " + round(PERIAPSIS / 1000, 1) + "km".
            LogToFile("Circularization Burn Finished").
            wait 0.001.
            HideEngineToggles(1).
            wait 0.001.
            Droppriority().

            rcs off.
            wait 1.5.
            HUDTEXT("The Booster will now perform an automated landing at the Launch Site!", 10, 2, 20, green, false).
            wait 0.001.
            set kuniverse:activevessel to vessel("Booster").

            until false or AbortInProgress {
                set kuniverse:timewarp:warp to 0.
                if defined Booster {
                    if not Booster:isdead {
                        if Booster:status = "LANDED" {
                            set message2:text to "<b>Shutdown Message received!</b>".
                            set message3:text to "<b>Booster Landing Confirmed!</b>".
                            LogToFile("Booster has Landed!").
                            BREAK.
                        }
                        else {
                            set message2:text to "<b>Booster Trk/X-Trk:</b>          " + round((latlng(-0.0972,-74.5577):lng - Booster:geoposition:lng) * 10471.975) + "m " + round((latlng(-0.0972,-74.5577):lat - Booster:geoposition:lat) * 10471.975) + "m".
                            set message3:text to "<b>Booster Alt / Spd:</b>            " + round(Booster:altitude - 116) + "m / " + round(Booster:airspeed) + "m/s".
                            BackGroundUpdate().
                        }
                    }
                    else {
                        set message2:text to "<b>Booster Signal:</b>               <color=red>0%</color>".
                        set message3:text to "<b>Booster Loss of Signal..</b>".
                        LogToFile("Booster Signal Lost").
                        BREAK.
                    }
                }
                else {
                    set message3:text to "".
                    BREAK.
                }
            }

            wait 3.
            LogToFile("Launch Program Ended").
            print "Launch Program Ended".
            ClearInterfaceAndSteering().
            set LaunchComplete to true.
        }
        wait until LaunchComplete or AbortInProgress.
        LogToFile("Launch Program has shut down").
    }
}.



Function LaunchSteering {
    if quicksetting1:pressed and altitude > 150 and altitude < 1000 {
        set kuniverse:timewarp:warp to 4.
    }
    if quicksetting1:pressed and altitude > 500 and altitude < 2000 or kuniverse:timewarp:warp > 0 and altitude > 500 and altitude < 2000 {
        set kuniverse:timewarp:warp to 1.
    }
    if quicksetting1:pressed and altitude > 2000 and apoapsis < 50000 or altitude > 2000 and altitude < 2500 and kuniverse:timewarp:warp = 1 {
        set kuniverse:timewarp:warp to 4.
    }
    if periapsis > targetap {
        set BurnComplete to true.
    }
    else if apoapsis > 50000 {
        if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
    }
    set DownRange to ((latlng(-0.0972,-74.5577):lng - ship:geoposition:lng) * -Planet1Degree).
    if altitude < 500 {
        if not ClosingIsRunning {
            set message1:text to "<b>Actual/Target Apoapsis:</b>   " + round(apoapsis/1000,1) + "/" + (targetap / 1000) + "km".
            set message2:text to "<b>Guidance Target:</b>                 " + 90 + "° Pitch".
            set message3:text to "<b>Down Range:</b>                         " + round(DownRange, 1) + "km".
        }
        set result to lookdirup(ship:up:vector, ship:facing:topvector).
    }
    else {
        if not ClosingIsRunning {
            set message1:text to "<b>Actual/Target Apoapsis:</b>   " + round(apoapsis/1000,1) + "/" + (targetap / 1000) + "km".
        }
        else {
            if defined Booster and not ClosingIsRunning {
                if not Booster:isdead {
                    if Booster:status = "LANDED" {
                        set message3:text to "<b>Booster Landing Confirmed!</b>".
                    }
                    else {
                        set message3:text to "<b>Booster Alt / Spd:</b> " + round(Booster:altitude - 116) + "m / " + round(Booster:airspeed) + "m/s".
                    }
                }
                else {
                    set message3:text to "<b>Booster Loss of Signal..</b>".
                    set message3:style:textcolor to yellow.
                }
            }
        }
        if Boosterconnected {
            set targetpitch to 90 - (10 * SQRT(max((altitude - 500), 0)/1000)).
            if not ClosingIsRunning {
                set message2:text to "<b>Guidance Target:</b>                 " + round(targetpitch, 1) + "° Pitch".
                set message3:text to "<b>Down Range:</b>                         " + round(DownRange, 1) + "km".
            }
            if apoapsis > 54000 {
                set throttle to 0.5 + (1 - ((apoapsis - 54000) / 1000)).
            }
            if quicksetting2:pressed {
                set result to heading(90, targetpitch).
            }
            else {
                set result to heading(90, targetpitch) * R(0, 0, 180).
            }
        }
        else {
            if quickengine3:pressed {
                set MaxAccel to (ship:availablethrust / (ship:mass + ((CargoBeforeSeparation - CargoAfterSeparation) / 1000))).
            }
            if not hasnode and quickengine3:pressed {
                set OrbitalVelocity to ship:body:radius * sqrt(9.81 / (ship:body:radius + APOAPSIS)).
                set ApoapsisVelocity to sqrt(Kerbin:mu * ((2 / (ship:body:radius + APOAPSIS)) - (1 / ship:obt:semimajoraxis))).
                set deltaV to (OrbitalVelocity - ApoapsisVelocity).
                set BurnDuration to deltaV/MaxAccel.
            }
            set OrbitBurnPitchCorrection to OrbitBurnPitchCorrectionPID:UPDATE(TIME:SECONDS, apoapsis).

            if ETA:APOAPSIS > 0.5 * BurnDuration and not hasnode {
                if quickengine3:pressed {
                    if periapsis < 0 {
                        set throttle to (0.925 * 9.81) / MaxAccel.
                    }
                    if periapsis > 35000 {
                        set throttle to 0.
                        set OrbitBurnPitchCorrection to 0.
                    }
                }
                if quicksetting2:pressed {
                    set result to ship:prograde * R(-OrbitBurnPitchCorrection, 0, 0).
                }
                else {
                    set result to ship:prograde * R(-OrbitBurnPitchCorrection, 0, 180).
                }
            }
            else {
                if not hasnode and apoapsis > 70000 {
                    if not (KUniverse:activevessel = vessel(ship:name)) {
                        set KUniverse:activevessel to vessel(ship:name).
                    }
                    set CircularizationNode to Node(timespan(ETA:APOAPSIS), 0, 0, deltaV).
                    add CircularizationNode.
                    set CircularizationStart to CircularizationNode:deltav.
                    set BurnAccel to min(MaxAccel, 29.43).
                }
                else if apoapsis > 70000 {
                    if vdot(CircularizationStart, CircularizationNode:deltav) > 5000 {
                        if quicksetting2:pressed {
                            set result to lookdirup(CircularizationNode:burnvector, ship:facing:topvector).
                        }
                        else {
                            set result to CircularizationNode:burnvector:direction + R(0, 0, 90).
                        }
                    }
                    if vdot(CircularizationStart, CircularizationNode:deltav) < 0.5 {
                        set throttle to 0.
                        set BurnComplete to true.
                    }
                    else if ETA:APOAPSIS < 0.5 * BurnDuration or ETA:APOAPSIS > 1000 {
                        if vang(facing:forevector, CircularizationNode:burnvector) < 5 {
                            set throttle to min(CircularizationNode:deltav:mag / MaxAccel, BurnAccel / MaxAccel).
                        }
                    }
                }
            }
            if not ClosingIsRunning {
                if not hasnode {
                    set message2:text to "<b>Guidance Target:</b>                 Prograde (" + round(OrbitBurnPitchCorrection, 1) + "°)".
                }
                else {
                    set message2:text to "<b>Guidance Target:</b>                 Finalizing Vector".
                }
                if defined Booster {
                    if not Booster:isdead {
                        if Booster:status = "LANDED" {
                            set message3:text to "<b>Booster Landing Confirmed!</b>".
                        }
                        else {
                            set message3:text to "<b>Booster Alt / Spd:</b>                " + round(Booster:altitude - 116) + "m / " + round(Booster:airspeed) + "m/s".
                        }
                    }
                    else {
                        set message3:text to "<b>Booster Loss of Signal..</b>".
                        set message3:style:textcolor to yellow.
                    }
                }
            }
        }
    }
    LogToFile("Launch Telemetry").
    BackGroundUpdate().
    return result.
}



//-------------------Abort Program----------------------//



Function Abort {
    if not LandButtonIsRunning {
        unlock steering.
        set AbortInProgress to true.
        set throttle to 1.
        rcs on.
        set LaunchButtonIsRunning to false.
        if Boosterconnected {
            BoosterEngines[0]:shutdown.
            wait 0.1.
            //stage.
            BoosterInterstage[0]:getmodule("ModuleDockingNode"):doaction("undock node", true).
            //wait 0.1.
            //if stage:number = 2 {
            //    stage.
            //}
            set Boosterconnected to false.
        }
        set runningprogram to "Abort!".
        set cancelconfirmed to false.
        LogToFile("Aborting!!").
        set message1:text to "Emergency Escape from Booster!".
        set message2:text to "".
        set message3:text to "".
        HideEngineToggles(0).

        set message1:style:textcolor to red.
        set launchlabel:style:textcolor to red.
        set cancel:text to "<b>CANCEL</b>".
        InhibitButtons (1, 1, 1).
        set quickengine1:pressed to true.
        wait 0.001.
        set quickengine2:pressed to true.
        set quickengine3:pressed to true.
        Nose[0]:activate.
        Tank[0]:activate.
        if apoapsis < 2500 {
            set AbortMode to "Early Abort".
            lock steering to heading(90, 85).
        }
        else if apoapsis < 30000 {
            set AbortMode to "Intermediate Abort".
            set quickstatus1:pressed to true.
            lock steering to ship:prograde.
        }
        else {
            set AbortMode to "Late Abort".
            lock steering to ship:prograde.
        }
        wait 2.
        lock steering to AbortSteering().

        if AbortMode = "Early Abort" {
            LogToFile("Early Abort").
            set message1:text to "<b>Thrusting away from the Booster..</b>".
            set message3:text to "<b>Venting in Progress..</b>".
            until apoapsis > 30000 or LFShip < FuelVentCutOffValue {}
            set quickengine1:pressed to true.
            set throttle to 0.
            set message1:text to "<b>Venting until Main Tanks empty..</b>".
            wait 0.1.
            Nose[0]:activate.
            Tank[0]:activate.
            until LFShip < FuelVentCutOffValue {}
            set quickengine1:pressed to true.
            wait 0.001.
            ShutdownEngines().
            until verticalspeed < 0 {}
            set message3:text to "".
            GoHome().
            InhibitButtons(0, 1, 1).
            set message1:text to "".
            set message1:style:textcolor to white.
            set message3:text to "<b>Manual Control in 3 seconds..</b>".
            wait 1.
            set message3:text to "<b>Manual Control in 2 seconds..</b>".
            wait 1.
            set message3:text to "<b>Manual Control in 1 seconds..</b>".
            wait 1.
            unlock steering.
            set attitudebutton:pressed to true.
            set message1:text to "".
            set message2:text to "".
            set message3:text to "".
            set AbortComplete to true.
            set quickattitude2:pressed to true.
        }

        if AbortMode = "Intermediate Abort" {
            LogToFile("Intermediate Abort").
            set message1:text to "<b>Thrusting away from the Booster..</b>".
            set message3:text to "<b>Venting in Progress..</b>".
            until apoapsis > 40000 or LFShip < FuelVentCutOffValue {}
            set quickengine1:pressed to true.
            set throttle to 0.
            set message1:text to "<b>Venting until Main Tanks empty..</b>".
            wait 0.1.
            Nose[0]:activate.
            Tank[0]:activate.
            until LFShip < FuelVentCutOffValue {}
            set quickengine1:pressed to true.
            wait 0.001.
            ShutdownEngines().
            until verticalspeed < 0 {}
            set message3:text to "".
            GoHome().
            InhibitButtons(0, 1, 1).
            set message1:text to "".
            set message1:style:textcolor to white.
            set message3:text to "<b>Manual Control in 3 seconds..</b>".
            wait 1.
            set message3:text to "<b>Manual Control in 2 seconds..</b>".
            wait 1.
            set message3:text to "<b>Manual Control in 1 seconds..</b>".
            wait 1.
            unlock steering.
            set attitudebutton:pressed to true.
            set message1:text to "".
            set message2:text to "".
            set message3:text to "".
            set AbortComplete to true.
            set quickattitude2:pressed to true.
        }

        if AbortMode = "Late Abort" {
            LogToFile("Late Abort").
            set message1:text to "<b>Thrusting away from the Booster..</b>".
            set message3:text to "<b>Venting in Progress..</b>".
            until apoapsis > 60000 or LFShip < FuelVentCutOffValue {}
            set quickengine1:pressed to true.
            set throttle to 0.
            set message1:text to "<b>Venting until Main Tanks empty..</b>".
            wait 0.1.
            Nose[0]:activate.
            Tank[0]:activate.
            until LFShip < FuelVentCutOffValue {}
            set quickengine1:pressed to true.
            wait 0.001.
            ShutdownEngines().
            until verticalspeed < 0 {}
            set message3:text to "".
            GoHome().
            InhibitButtons(0, 1, 1).
            set message1:text to "".
            set message1:style:textcolor to white.
            set message3:text to "<b>Manual Control in 3 seconds..</b>".
            wait 1.
            set message3:text to "<b>Manual Control in 2 seconds..</b>".
            wait 1.
            set message3:text to "<b>Manual Control in 1 seconds..</b>".
            wait 1.
            unlock steering.
            set attitudebutton:pressed to true.
            set message1:text to "".
            set message2:text to "".
            set message3:text to "".
            set AbortComplete to true.
            set quickattitude2:pressed to true.
        }

        wait until AbortComplete.
        LogToFile("Abort Complete").
        set AbortInProgress to false.
        ClearInterfaceAndSteering().
    }
}


Function AbortSteering {
    if AbortMode = "Early Abort" {
        if throttle = 1 {
            set result to heading(90, 85).
            set message2:text to "<b>Steering: </b>85° pitch".
        }
        else if verticalspeed > 0 {
            set result to velocity:surface.
            set message2:text to "<b>Steering: </b>Surface Velocity".
        }
        else {
            set result to velocity:surface * R(0, 67, 0).
            set message2:text to "<b>Steering: </b>67° AoA".
            if quickstatus1:pressed = False {
                set quickstatus1:pressed to true.
            }
            rcs on.
        }
    }
    if AbortMode = "Intermediate Abort" {
        set result to heading(90, 85).
        set message2:text to "<b>Steering: </b>85° pitch".
    }
    if AbortMode = "Late Abort" {
        set result to ship:prograde * R(-10, 0, 0).
        set message2:text to "<b>Steering: </b>Prograde + 10°".
    }
    BackGroundUpdate().
    return result.
}



//--------------Re-Entry & Landing Program----------------//



function ReEntryAndLand {
    if addons:tr:hasimpact{
        set LandButtonIsRunning to true.
        set LandSomewhereElse to false.
        SetPlanetData().
        set addons:tr:descentmodes to list(true, true, true, true).
        set addons:tr:descentgrades to list(false, false, false, false).
        set addons:tr:descentangles to list(aoa, aoa, aoa, aoa).
        LogToFile("Re-Entry & Landing Program Started").
        set runningprogram to "De-orbit & Landing".
        SetRadarAltitude().
        TotalCargoMass().
        set flapcargomasscorr to round(10 - ((Cargo / 10000) * 10)).
        if flapcargomasscorr < 0 and ship:body = BODY("Kerbin") {
            set flapcargomasscorr to 0.
        }
        if flapcargomasscorr < 0 and ship:body = BODY("Duna") {
            set flapcargomasscorr to 0.75 * flapcargomasscorr.
        }
        set message1:style:textcolor to white.
        set message2:style:textcolor to white.
        set message3:style:textcolor to white.
        set landlabel:style:textcolor to green.
        set launchlabel:style:textcolor to grey.
        HideEngineToggles(1).
        //ActivateEngines(0).
        ShutdownEngines.
        set launchlabel:style:bg to "starship_img/starship_background".
        ShowButtons(0).
        InhibitButtons(1, 1, 0).
        set RepositionOxidizer to TRANSFERALL("OXIDIZER", Tank[0], HeaderTank[0]).
        set RepositionOxidizer to TRANSFERALL("LIQUIDFUEL", Tank[0], HeaderTank[0]).
        set RepositionOxidizer:ACTIVE to TRUE.
        sas off.
        rcs off.
        set SteeringManager:ROLLCONTROLANGLERANGE to 20.
        set STEERINGMANAGER:PITCHTS to 5.
        set STEERINGMANAGER:YAWTS to 5.
        set PitchPID to PIDLOOP(0.0025, 0, 0, -13, 12).
        set YawPID to PIDLOOP(0.025, 0, 0, -60, 60).
        lock STEERING to ReEntrySteering().
        if quicksetting1:pressed and altitude > 30000 {
            set kuniverse:timewarp:warp to 4.
        }
        
        
        when altitude < 70000 and ship:body = BODY("Kerbin") or altitude < 50000 and ship:body = BODY("Duna") then {
            set quickstatus1:pressed to true.
            LogToFile("<Atmosphere Height, Body-Flaps Activated").
            if quicksetting1:pressed and altitude > 30000 {
                set kuniverse:timewarp:warp to 4.
            }
            
            when airspeed < 300 and ship:body = BODY("Kerbin") or airspeed < 450 and ship:body = BODY("Duna") then {
                set config:ipu to 2000.
                if ship:body = BODY("Kerbin") {
                    set PitchPID to PIDLOOP(0.075, 0.02, 0.05, -18, 7).
                }
                if ship:body = BODY("Duna") {
                    set PitchPID to PIDLOOP(0.075, 0.02, 0.05, -25, 15).
                }
                set YawPID to PIDLOOP(0.25, 0.025, 0.025, -15, 15).
                set STEERINGMANAGER:PITCHTS to 2.5.
                set STEERINGMANAGER:YAWTS to 1.
                set FlipAltitude to (ship:mass / 50) * 500.
                set runningprogram to "Final Approach".
                LogToFile("Vehicle is Subsonic, precise steering activated").
                when RadarAlt < 10000 then {
                    InhibitButtons(1, 1, 1).
                    CheckLZReachable().
                }
                if OLMexists() {
                    if homeconnection:isconnected {
                        if exists("0:/settings.json") {
                            set L to readjson("0:/settings.json").
                            if L:haskey("Launch Coordinates") and L:haskey("Landing Coordinates") {
                                if L["Landing Coordinates"] = L["Launch Coordinates"] {
                                    set MechaZillaShouldCatchShip to true.
                                    if L:haskey("ArmsHeight") {
                                        set ArmsHeight to L["ArmsHeight"].
                                    }
                                    else {
                                        set ArmsHeight to 86.42.
                                    }
                                    lock RadarAlt to altitude - ship:geoposition:terrainheight - ArmsHeight + (24.698 - ShipBottomRadarHeight).
                                    when RadarAlt < 2000 then {
                                        sendMessage(Vessel("OrbitalLaunchMount"), "MechazillaHeight,0,2").
                                        sendMessage(Vessel("OrbitalLaunchMount"), "MechazillaArms,8,5,97,true").
                                        sendMessage(Vessel("OrbitalLaunchMount"), "MechazillaPushers,0,1,12,true").
                                        sendMessage(Vessel("OrbitalLaunchMount"), "MechazillaStabilizers,0").
                                    }
                                }
                            }
                        }
                    }
                }
            }

        }
        
        if ship:body = BODY("Kerbin") {
            wait until RadarAlt < FlipAltitude or cancelconfirmed and not ClosingIsRunning.
            LogToFile("Radar Altimeter < " + round(FlipAltitude) + " (" + round(RadarAlt) + "), starting Landing Procedure").
        }
        if ship:body = BODY("Duna") {
            wait until RadarAlt < 2000 or altitude - AvailableLandingSpots[4] < 2000 or cancelconfirmed and not ClosingIsRunning.
            LogToFile("Radar Altimeter < 2000, starting Landing Procedure").
        }
        if cancelconfirmed {
            ClearInterfaceAndSteering().
        }
        
    
//------------------Re-Entry Loop-----------------------///



function ReEntrySteering {
    if not SteeringIsRunning {
        set SteeringIsRunning to true.

        set LngLatErrorList to LngLatError().
        if airspeed < 450 and kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
        
        if LngLatErrorList[1] < 100 and LngLatErrorList[1] > -100 and RadarAlt < 15000 and not LandSomewhereElse {
            FLflap[0]:getmodule("ModuleSEPControlSurface"):DoAction("deactivate yaw control", true).
            FRflap[0]:getmodule("ModuleSEPControlSurface"):DoAction("deactivate yaw control", true).
            ALflap[0]:getmodule("ModuleSEPControlSurface"):DoAction("deactivate yaw control", true).
            ARflap[0]:getmodule("ModuleSEPControlSurface"):DoAction("deactivate yaw control", true).
            set FlapsYawEngaged to false.
        }
        else {
            FLflap[0]:getmodule("ModuleSEPControlSurface"):DoAction("activate yaw control", true).
            FRflap[0]:getmodule("ModuleSEPControlSurface"):DoAction("activate yaw control", true).
            ALflap[0]:getmodule("ModuleSEPControlSurface"):DoAction("activate yaw control", true).
            ARflap[0]:getmodule("ModuleSEPControlSurface"):DoAction("activate yaw control", true).
            set FlapsYawEngaged to true.
        }

        if aoa:typename = "String" {set aoa to (aoa):toscalar.}
        set pitch to -PitchPID:UPDATE(TIME:SECONDS, LngLatErrorList[0]).
        if RadarAlt < 2500 or AbortInProgress {
            set LateReentryVector to srfprograde.
            set yaw to 0.
            set DesiredAoA to aoa + pitch.
            set result to LateReentryVector * R(-DesiredAoA * cos(yaw), DesiredAoA * sin(yaw), 0).
        }
        else {
            set DesiredAoA to aoa + pitch + (10 * ship:control:pilotpitch).
            set yaw to -YawPID:UPDATE(TIME:SECONDS, LngLatErrorList[1]).
            set result to srfprograde * R(-DesiredAoA * cos(yaw), DesiredAoA * sin(yaw), 0).
        }
        if LandSomewhereElse {
            set result to srfprograde * R(-67, 0, 0).
        }
        set result to lookdirup(result:vector, vxcl(velocity:surface, result:vector)).
        
        if ship:control:pilotpitch <> 0 {
            set runningprogram to "Override".
            set status1:style:textcolor to cyan.
        }
        else if airspeed > 300 {
            set runningprogram to "De-orbit & Landing".
            set status1:style:textcolor to green.
        }
        else if RadarAlt > 10000 {
            set runningprogram to "Final Approach".
            set status1:style:textcolor to green.
        }
        else {
            set runningprogram to "Landing".
            set status1:style:textcolor to green.
        }


        set AoAError to vang(result:vector, facing:forevector).
        set AoAErrorRate to AoAError - PreviousAoAError.
        if AoAError > 5 and RadarAlt > 2500 {
            rcs on.
            set IdealRCS to max(AoAErrorRate + (2 * AoAError), 5).
            Nose[0]:getmodule("ModuleRCSFX"):SetField("thrust limiter", min(ship:mass / 60, 1.25) * IdealRCS).
            Tank[0]:getmodule("ModuleRCSFX"):SetField("thrust limiter", min(ship:mass / 60, 1.25) * IdealRCS).
        }
        else if RadarAlt > 2500 {
            rcs off.
            Nose[0]:getmodule("ModuleRCSFX"):SetField("thrust limiter", 100).
            Tank[0]:getmodule("ModuleRCSFX"):SetField("thrust limiter", 100).
        }
        set PreviousAoAError to vang(result:vector, facing:forevector).


        set flapcorr to -1 * LngLatErrorList[0] / 10000.
        if flapcorr > 10 {set flapcorr to 10.}
        if flapcorr < -10 {set flapcorr to -10.}
        if ship:body = BODY("Kerbin") {
            if not AbortInProgress {
                setflaps(55 + flapcorr + flapcargomasscorr, 50 + flapcorr, 1, 30).
            }
        }
        if ship:body = BODY("Duna") {
            setflaps(55 + flapcorr + flapcargomasscorr, 50 + flapcorr - 0.5 * flapcargomasscorr, 1, 30).
        }
        
        
        if (landingzone:lng - ship:geoposition:lng) < -180 {
            set LngDistanceToTarget to ((landingzone:lng - ship:geoposition:lng + 360) * Planet1Degree).
            set LatDistanceToTarget to max(landingzone:lat - ship:geoposition:lat, ship:geoposition:lat - landingzone:lat) * Planet1Degree.
            if LatDistanceToTarget < 0 {set LatDistanceToTarget to -1 * LatDistanceToTarget.}
            set DistanceToTarget to sqrt(LngDistanceToTarget * LngDistanceToTarget + LatDistanceToTarget * LatDistanceToTarget).
        }
        else {
            set LngDistanceToTarget to ((landingzone:lng - ship:geoposition:lng) * Planet1Degree).
            set LatDistanceToTarget to max(landingzone:lat - ship:geoposition:lat, ship:geoposition:lat - landingzone:lat) * Planet1Degree.
            if LatDistanceToTarget < 0 {set LatDistanceToTarget to -1 * LatDistanceToTarget.}
            set DistanceToTarget to sqrt(LngDistanceToTarget * LngDistanceToTarget + LatDistanceToTarget * LatDistanceToTarget).
        }
        
        if not ClosingIsRunning {
            if FindNewTarget {
                if Slope < 2.5 {
                    set message1:text to "<b>Remaining Flight Time:</b>  " + timeSpanCalculator(ADDONS:TR:TIMETILLIMPACT) + "     <color=green><b>Slope:  </b>" + round(Slope, 1) + "°</color>".
                }
                else if Slope > 2.5 and Slope < 5 {
                    set message1:text to "<b>Remaining Flight Time:</b>  " + timeSpanCalculator(ADDONS:TR:TIMETILLIMPACT) + "     <color=yellow><b>Slope:  </b>" + round(Slope, 1) + "°</color>".
                }
                else {
                    set message1:text to "<b>Remaining Flight Time:</b>  " + timeSpanCalculator(ADDONS:TR:TIMETILLIMPACT) + "     <color=red><b>Slope:  </b>" + round(Slope, 1) + "°</color>".
                }
            }
            else {
                set message1:text to "<b>Remaining Flight Time:</b>  " + timeSpanCalculator(ADDONS:TR:TIMETILLIMPACT).
            }
            if DistanceToTarget < 10 {
                set message2:text to "<b>Distance to Target:</b>           " + round(DistanceToTarget, 2) + "km".
            }
            else {
                set message2:text to "<b>Distance to Target:</b>           " + round(DistanceToTarget) + "km".
            }
            if LngLatErrorList[0] < 100 and LngLatErrorList[1] < 100 and RadarAlt < 5000 {
                set message3:text to "<b>Track/X-Trk Error:</b>             " + round((LngLatErrorList[0] - LandingOffset)) + "m  " + round(LngLatErrorList[1]) + "m".
            }
            else {
                if not FacingTheWrongWay {
                    set message3:text to "<b>Track/X-Trk Error:</b>             " + round((LngLatErrorList[0] - LandingOffset) / 1000, 2) + "km  " + round((LngLatErrorList[1] / 1000), 2) + "km".
                }
                else {
                    set message3:text to "<b>Track/X-Trk Error:</b>    <color=yellow>Facing away from Target..</color>".
                }
            }
        }

            
        if RadarAlt < 10000 and not ClosingIsRunning {
            if ship:body = BODY("Kerbin") {
                if LngLatErrorList[0] > 500 or LngLatErrorList[0] < -500 or LngLatErrorList[1] > 250 or LngLatErrorList[1] < -250 {
                    set message3:style:textcolor to yellow.
                }
                else {
                    set message3:style:textcolor to white.
                }
            }
            if ship:body = BODY("Duna") {
                if LngLatErrorList[0] > 1000 or LngLatErrorList[0] < -1000 or LngLatErrorList[1] > 250 or LngLatErrorList[1] < -250 {
                    set message3:style:textcolor to yellow.
                }
                else {
                    set message3:style:textcolor to white.
                }
            }
            if FacingTheWrongWay and not NewTargetSet {
                set impactpos to addons:tr:impactpos.
                set landingzone to latlng(impactpos:lat, impactpos:lng).
                addons:tr:settarget(landingzone).
                set NewTargetSet to true.
            }
        }
        if RadarAlt < 2500 {
            set runningprogram to "Landing".
            Nose[0]:getmodule("ModuleRCSFX"):SetField("thrust limiter", 100).
            Tank[0]:getmodule("ModuleRCSFX"):SetField("thrust limiter", 100).
            if LngLatErrorList[0] - LandingOffset > 50 and ship:body = BODY("Kerbin") or LngLatErrorList[0] - LandingOffset < -50 and ship:body = BODY("Kerbin") or LngLatErrorList[1] > 50 or LngLatErrorList[1] < -50 or LngLatErrorList[0] - LandingOffset > 200 and ship:body = BODY("Duna") or LngLatErrorList[0] - LandingOffset < -200 and ship:body = BODY("Duna") {
                if not ClosingIsRunning {
                    set message3:style:textcolor to yellow.
                }
            }
            else {set message3:style:textcolor to white.}

        }
            
        BackGroundUpdate().
        LogToFile("Re-Entry Telemetry").

        //set ReEntryVector to vecdraw(v(0, 0, 0), result:vector, red, "Re-Entry Vector", 20, true, 0.005, true, true).

        set SteeringIsRunning to false.
        return result.
    }
}


    
//-----------------------Landing---------------------------///



        if LandButtonIsRunning and not LaunchButtonIsRunning and not cancelconfirmed {
            LogToFile("Landing Procedure started. Starting Landing Flip Now!").
            InhibitButtons(1, 1, 1).
            rcs on.
            set SteeringManager:ROLLCONTROLANGLERANGE to 1.
            set STEERINGMANAGER:PITCHTS to 0.5.
            set STEERINGMANAGER:YAWTS to 0.5.
            if ship:body = BODY("Kerbin") {
                set ThrottleMin to 0.4.
                set FlipAngleFactor to 0.25.
                set LandingFlipTime to 4.5.
            }
            if ship:body = BODY("Duna") {
                set ThrottleMin to 0.25 + (ship:mass / 50) * 0.15 - 0.15.
                set FlipAngleFactor to 0.2 * (ship:mass / 50) * 0.5.
                set LandingFlipTime to 4.8 + (3.6 - (ship:mass / 50) * 1.5).
            }
            set throttle to ThrottleMin.
            set FlipAngle to vang(-1 * velocity:surface, ship:facing:forevector).
            set LandingForwardDirection to facing:forevector.
            set LandingLateralDirection to facing:starvector.
            set LandingFlipStart to time:seconds.
            set landingRatio to 0.
            set maxDecel to 0.
            set DesiredDecel to 0.
            lock steering to LandingVector().
            rcs on.
            ShutdownEngines().
            setflaps(0, 80, 1, 0).

            LogToFile("Starting Engines").
            SLEngines[0]:getmodule("ModuleGimbal"):SetField("gimbal limit", 100).
            SLEngines[0]:activate.
            wait 0.25.
            SLEngines[1]:getmodule("ModuleGimbal"):SetField("gimbal limit", 100).
            SLEngines[1]:activate.
            wait 0.25.
            SLEngines[2]:getmodule("ModuleGimbal"):SetField("gimbal limit", 100).
            SLEngines[2]:activate.
            LogToFile("Engines Activated").

            if ship:body = BODY("Kerbin") {
                set Planet1G to 9.80665.
                if LngLatErrorList[0] - LandingOffset > 50 or LngLatErrorList[0] - LandingOffset < -50 or LngLatErrorList[1] > 15 or LngLatErrorList[1] < -15 {
                    set LandSomewhereElse to true.
                    LogToFile("Landing parameters out of bounds, Landing Off-Target").
                }
            }
            if ship:body = BODY("Duna") {
                set Planet1G to 2.94.
                if LngLatErrorList[0] - LandingOffset > 250 or LngLatErrorList[0] - LandingOffset < -250 or LngLatErrorList[1] > 50 or LngLatErrorList[1] < -50 {
                    set LandSomewhereElse to true.
                    LogToFile("Landing parameters out of bounds, Landing Off-Target").
                }
            }
            set message1:text to "<b>Performing Landing Flip..</b>".
            set message2:text to "<b><color=green>Engine Light-Up confirmed..</color></b>".
            set message3:text to "".
            GoHome().

            when vang(-1 * velocity:surface, ship:facing:forevector) < 0.6 * FlipAngle then {
                setflaps(60, 60, 1, 0).
                when vang(-1 * velocity:surface, ship:facing:forevector) < 0.05 * FlipAngle then {
                    if ship:body = BODY("Kerbin") {
                        set DesiredDecel to 12 - 9.81.
                    }
                    if ship:body = BODY("Duna") {
                        set DesiredDecel to 11 - 9.81.
                    }
                    lock maxDecel to (ship:availablethrust / ship:mass).
                    lock stopTime to verticalspeed / DesiredDecel.
                    lock stopDist to 0.5 * DesiredDecel * stopTime * stopTime.
                    lock landingRatio to stopDist / RadarAlt.
                    lock throttle to max(min(((DesiredDecel + Planet1G) / max(maxDecel, 0.000001)) * landingRatio, 2 * 9.81 / max(maxDecel, 0.000001)), ThrottleMin).
                    if OLMexists() and MechaZillaShouldCatchShip {
                        when RadarAlt < 2.5 * ShipHeight then {
                            sendMessage(Vessel("OrbitalLaunchMount"), "MechazillaArms,8,5,60,true").
                            sendMessage(Vessel("OrbitalLaunchMount"), "MechazillaStabilizers,0").
                            when RadarAlt < (0.5 * DesiredDecel * 3 * 3) then {
                                sendMessage(Vessel("OrbitalLaunchMount"), ("MechazillaArms,8," + 10 + ",60,false")).
                            }
                        }

                    }
                }
            }

            when verticalspeed > -40 and landingRatio < 0.5 and ship:body = BODY("Duna") or verticalspeed > -40 and ship:body = BODY("Kerbin") then {
                if ship:body = BODY("Kerbin") {
                    SLEngines[1]:shutdown.
                    SLEngines[1]:getmodule("ModuleSEPRaptor"):DoAction("toggle actuate out", true).
                    LogToFile("3rd engine shutdown; performing a 2-engine landing").
                }
                if ship:body = BODY("Duna") {
                    SLEngines[1]:shutdown.
                    SLEngines[2]:shutdown.
                    LogToFile("2nd and 3rd engine shutdown; performing a 1-engine landing").
                }
            }

            when verticalspeed > -10 then {
                if OLMexists() and MechaZillaShouldCatchShip {
                    setflaps(0, 85, 1, 0).
                }
                else {
                    gear on.
                }
            }

            until verticalspeed > -0.02 and RadarAlt < 5 and ship:status = "LANDED" or verticalspeed > 0.5 {}
            if MechaZillaShouldCatchShip {
                print "capture at: " + RadarAlt + "m RA".
            }



//------------------Landing Loop-----------------------///



function LandingVector {
    if kuniverse:timewarp:warp > 0 {set kuniverse:timewarp:warp to 0.}
    if addons:tr:hasimpact {
        set LngLatErrorList to LngLatError().
        
        if ship:body = BODY("Kerbin") {
            if ErrorVector:MAG > (RadarAlt + 10) and not LandSomewhereElse {
                set LandSomewhereElse to true.
                LogToFile("Uh oh... Landing Off-Target").
            }
        }
        if ship:body = BODY("Duna") {
            if ErrorVector:MAG > 2 * RadarAlt + 10 and not LandSomewhereElse {
                set LandSomewhereElse to true.
                LogToFile("Uh oh... Landing Off-Target").
            }
        }

        set LngError to vdot(LandingForwardDirection, ErrorVector).
        set LatError to vdot(LandingLateralDirection, ErrorVector).
        if RadarAlt < 200 and ship:body = BODY("Kerbin") {
            set ErrorVector to ErrorVector + vxcl(up:vector, ship:position - landingzone:position).
        }

        if ErrorVector:mag > max(min(RadarAlt / 20, 10), 2.5) {
            set ErrorVector to ErrorVector:normalized * max(min(RadarAlt / 20, 10), 2.5).
        }

        if vang(-1 * velocity:surface, ship:facing:forevector) > FlipAngleFactor * FlipAngle and time:seconds - LandingFlipStart < LandingFlipTime {
            if LandSomewhereElse {
                set result to (angleaxis(((time:seconds - LandingFlipStart) / (LandingFlipTime - 1)) * -FlipAngle, LandingLateralDirection) * LandingForwardDirection:direction):vector.
            }
            else {
                set result to (angleaxis(((time:seconds - LandingFlipStart) / (LandingFlipTime - 1)) * -FlipAngle, LandingLateralDirection) * LandingForwardDirection:direction):vector.
            }
        }
        else {
            if LandSomewhereElse {
                if ship:body = BODY("Kerbin") {
                    if ErrorVector:MAG < (RadarAlt + 10) and not LandSomewhereElse {
                        set LandSomewhereElse to false.
                        LogToFile("Re-acquired Target").
                    }
                }
                if ship:body = BODY("Duna") {
                    if ErrorVector:MAG < 2 * RadarAlt and not LandSomewhereElse {
                        set LandSomewhereElse to false.
                        LogToFile("Re-acquired Target").
                    }
                }
                if ship:body = BODY("Kerbin") {
                    set result to ship:up:vector - 0.03 * velocity:surface + 0.02 * facing:starvector.
                }
                if ship:body = BODY("Duna") {
                    set result to ship:up:vector - 0.1 * velocity:surface + 0.04 * facing:topvector.
                }
                set message1:text to "<b>Landing Off-Target..</b>".
                if ErrorVector:MAG < 10000 {
                    set message2:text to "<b>Target Error:</b>                " + round(LngError) + "m " + round(LatError) + "m".
                }
                else {
                    set message2:text to "<b>Target Error:</b>               " + round(ErrorVector:MAG / 1000, 2) + "km".
                }
                set message1:style:textcolor to yellow.
                set message2:style:textcolor to yellow.
                set message3:style:textcolor to yellow.
            }
            else {
                if ship:body = BODY("Kerbin") {
                    if OLMexists() and MechaZillaShouldCatchShip {
                        set result to ship:up:vector - 0.03 * velocity:surface - 0.0125 * ErrorVector + 0.02 * facing:starvector.
                    }
                    else {
                        set result to ship:up:vector - 0.03 * velocity:surface - 0.02 * ErrorVector + 0.02 * facing:starvector.
                    }
                }
                if ship:body = BODY("Duna") {
                    set result to ship:up:vector - 0.04 * velocity:surface - 0.04 * ErrorVector + 0.04 * facing:topvector.
                }
                set message2:text to "<b>Target Error:</b>                " + round(LngError) + "m " + round(LatError) + "m".
                set message1:style:textcolor to white.
                set message2:style:textcolor to white.
                set message3:style:textcolor to white.
            }
        }
        //set LdgVectorDraw to vecdraw(v(0, 0, 0), result, green, "Landing Vector", 20, true, 0.005, true, true).

        //clearscreen.
        //print "RA:" + round(RadarAlt,2).
        //print "Landing Ratio: " + round(landingRatio,2).
        //print "desired decel: " + round(DesiredDecel,2).
        //print "max decel: " + round(maxDecel,2) + "m/s2".
        //if not maxDecel = 0 {
        //    print "current decel: " + round(throttle * maxDecel, 2) + "m/s2".
        //    print "vs: " + round(verticalspeed,2).
        //    print "close arms at: " + round((0.5 * DesiredDecel * 3 * 3), 2) + "m RA".
        //}
        LogToFile("Re-Entry Telemetry").
        set message3:text to "<b>Radar Altimeter:</b>        " + round(RadarAlt) + "m".
        
        BackGroundUpdate().
    }
    if OLMexists() and MechaZillaShouldCatchShip and verticalspeed > -15 {
        return lookDirUp(result, heading(270,0):vector).
    }
    else {
        return lookDirUp(result, facing:topvector).
    }
}



//----------------After Landing------------------//



            set runningprogram to "After Landing".
            set config:ipu to 500.
            set ShutdownComplete to false.
            set ShutdownProcedureStart to time:seconds.
            LogToFile("Vehicle Touchdown, performing self-check").
            if not LandSomewhereElse and not MechaZillaShouldCatchShip {
                set message1:text to "<b><color=green>Successful Landing Confirmed!</color></b> (" + round((SLEngines[0]:position - landingzone:position):mag - 0.5) + "m)".
            }
            else if LandSomewhereElse {
                set message1:text to "<b>Successful Landing Confirmed!</b> (" + round((SLEngines[0]:position - landingzone:position):mag) + "m)".
                set message1:style:textcolor to yellow.
            }
            else {
                set message1:text to "<b><color=green>Successful Landing Confirmed!</color></b>".
            }
            set message2:text to "<b>Performing Vehicle Self-Check..</b>".
            set message2:style:textcolor to white.
            set message3:style:textcolor to white.
            lock steering to lookdirup(ship:up:vector,ship:facing:topvector).
            lock throttle to 0.
            Nose[0]:getmodule("ModuleRCSFX"):SetField("thrust limiter", 25).
            Tank[0]:getmodule("ModuleRCSFX"):SetField("thrust limiter", 25).
            if ship:body = BODY("Kerbin") {
                Nose[0]:activate. Tank[0]:activate.
            }
            SLEngines[0]:shutdown. SLEngines[1]:shutdown. SLEngines[2]:shutdown.

            if OLMexists() and MechaZillaShouldCatchShip {
                sendMessage(Vessel("OrbitalLaunchMount"), "MechazillaPushers,0,1,0.7,true").
                sendMessage(Vessel("OrbitalLaunchMount"), ("MechazillaStabilizers," + maxstabengage)).
                when time:seconds > ShutdownProcedureStart + 3.25 then {
                    sendMessage(Vessel("OrbitalLaunchMount"), "MechazillaPushers,0,0.5,0.7,true").
                }
                when time:seconds > ShutdownProcedureStart + 5.75 then {
                    sendMessage(Vessel("OrbitalLaunchMount"), "MechazillaPushers,0,0.2,0.7,true").
                }
                when time:seconds > ShutdownProcedureStart + 8.25 then {
                    sendMessage(Vessel("OrbitalLaunchMount"), "MechazillaPushers,0,0.1,0.7,true").
                }
            }

            until ShutdownComplete {
                set message3:text to "<b>Please Standby..</b> (" + round((ShutdownProcedureStart + 17) - time:seconds) + "s)".
                BackGroundUpdate().
                if time:seconds > ShutdownProcedureStart + 17 {
                    set ShutdownComplete to true.
                }
            }
            rcs off.
            unlock throttle.
            set ship:control:neutralize to true.
            unlock steering.
            if OLMexists() and MechaZillaShouldCatchShip {
                setflaps(0, 0, 0, 0).
            }
            else {
                setflaps(80, 85, 1, 0).
            }
            FLflap[0]:getmodule("ModuleSEPControlSurface"):DoAction("activate yaw control", true).
            FRflap[0]:getmodule("ModuleSEPControlSurface"):DoAction("activate yaw control", true).
            ALflap[0]:getmodule("ModuleSEPControlSurface"):DoAction("activate yaw control", true).
            ARflap[0]:getmodule("ModuleSEPControlSurface"):DoAction("activate yaw control", true).
            set FlapsYawEngaged to true.
            Nose[0]:getmodule("ModuleRCSFX"):SetField("thrust limiter", 100).
            Tank[0]:getmodule("ModuleRCSFX"):SetField("thrust limiter", 100).
            Nose[0]:shutdown. Tank[0]:shutdown.
            set message1:text to "<b><color=green>Vehicle Self-Check OK!</color></b>".
            set message1:style:textcolor to white.
            //if OLMexists() and MechaZillaShouldCatchShip {
            //    set message2:text to "<b><color=green>Ship has been secured by MechaZilla!</color></b>".
            //    set message3:text to "<b>Crane Operation in progress..</b>".
            //    set ShipDocked to false.
            //    when time:seconds > ShutdownProcedureStart + 20 then {
            //        sendMessage(Vessel("OrbitalLaunchMount"), "MechazillaHeight,12,0.5").
            //    }
            //    when time:seconds > ShutdownProcedureStart + 44 then {
            //        set ShipDocked to true.
            //    }
            //    wait until ShipDocked.
                //sendMessage(Vessel("OrbitalLaunchMount"), "MechazillaArms,8,2.5,25,true").
                //wait 5.
                //sendMessage(Vessel("OrbitalLaunchMount"), "MechazillaHeight,6.5,2.5").
                //wait 3.
                //sendMessage(Vessel("OrbitalLaunchMount"), "MechazillaArms,8,5,60,true").
                //sendMessage(Vessel("OrbitalLaunchMount"), "MechazillaPushers,0,0.2,3,true").
                //sendMessage(Vessel("OrbitalLaunchMount"), "MechazillaStabilizers,50").
                //wait 3.
            //}
            set message2:text to "<b>Re-Entry & Land Program completed..</b>".
            set message3:text to "<b>Hatches may now be opened..</b>".
            set runningprogram to "None".
            unlock steering.
            LogToFile("Self-Check Complete, Re-Entry & Land Program Complete.").
            wait 3.
            ClearInterfaceAndSteering().
        }
    }
    else if altitude > ship:body:atm:height {
        ClearInterfaceAndSteering().
        LogToFile("Re-Entry Cancelled, no impact position found").
        set message1:text to "Error: Ship has no Impact Position..".
        set message2:text to "Adjust your Orbit!".
        set message3:text to "Ideal Accuracy: < 100km from target".
        set message1:style:textcolor to yellow.
        set message2:style:textcolor to yellow.
        set message3:style:textcolor to yellow.
    }.
}.
print "De-Orbit & Land Program Ended".



//----------------Other Functions---------------------//



function LngLatError {
    if addons:tr:hasimpact {
        if defined landingzone {
            set ErrorVector to ADDONS:TR:IMPACTPOS:POSITION - landingzone:POSITION.
            local lngresult to ((ship:position - addons:tr:impactpos:position):mag - (ship:position - landingzone:position):mag).
            if landingzone:distance/1000 < 50 {
                set lngresult to (vdot(heading(landingzone:heading, 0):vector, ErrorVector)).
            }
            local latresult to (vdot(heading(landingzone:heading - 90, 0):vector, ErrorVector)).
            if ship:body = BODY("Kerbin") {
                if OLMexists() and MechaZillaShouldCatchShip {
                    set LngLatOffset to ((60 / ship:mass) * 130) - 117.5.
                }
                else {
                    set LngLatOffset to ((60 / ship:mass) * 130) - 97.5.
                }
            }
            if ship:body = BODY("Duna") {
                set LngLatOffset to ((60 / ship:mass) * 180) - 120.
            }
            if landingzone:bearing > 90 or landingzone:bearing < -90 {
                set FacingTheWrongWay to true.
                if JustCheckingWhatTheErrorIs {
                    return list(lngresult, latresult).
                }
                set lngresult to 0.
                set latresult to 0.
            }
            else {
                set FacingTheWrongWay to false.
            }
            local lngresult to lngresult + LngLatOffset.
            if LandSomewhereElse {
                set lngresult to 0.
                set latresult to 0.
            }
            return list(lngresult, latresult).
        }
    }
}


function setflaps {
    parameter angleFwd, angleAft, deploy, authority.
        FLflap[0]:getmodule("ModuleSEPControlSurface"):SetField("Deploy", deploy).
        FRflap[0]:getmodule("ModuleSEPControlSurface"):SetField("Deploy", deploy).
        ALflap[0]:getmodule("ModuleSEPControlSurface"):SetField("Deploy", deploy).
        ARflap[0]:getmodule("ModuleSEPControlSurface"):SetField("Deploy", deploy).
        
        FLflap[0]:getmodule("ModuleSEPControlSurface"):SetField("Deploy Angle", angleFwd).
        FRflap[0]:getmodule("ModuleSEPControlSurface"):SetField("Deploy Angle", angleFwd).
        ALflap[0]:getmodule("ModuleSEPControlSurface"):SetField("Deploy Angle", angleAft).
        ARflap[0]:getmodule("ModuleSEPControlSurface"):SetField("Deploy Angle", angleAft).
        
        FLflap[0]:getmodule("ModuleSEPControlSurface"):SetField("Authority Limiter", authority).
        FRflap[0]:getmodule("ModuleSEPControlSurface"):SetField("Authority Limiter", authority).
        ALflap[0]:getmodule("ModuleSEPControlSurface"):SetField("Authority Limiter", authority).
        ARflap[0]:getmodule("ModuleSEPControlSurface"):SetField("Authority Limiter", authority).
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


function ActivateEngines {
    parameter WhichEngines.
    if WhichEngines = 0 {
        SLEngines[0]:activate.
        SLEngines[1]:activate.
        SLEngines[2]:activate.
        SLEngines[0]:getmodule("ModuleGimbal"):SetField("gimbal limit", 100).
        SLEngines[1]:getmodule("ModuleGimbal"):SetField("gimbal limit", 100).
        SLEngines[2]:getmodule("ModuleGimbal"):SetField("gimbal limit", 100).
    }
    else {
        for eng in VACEngines {
            eng:activate.
        }
    }
    Nose[0]:shutdown.
    Tank[0]:shutdown.
}


function ShutdownEngines {
    for eng in SLEngines {eng:shutdown.}.
    for eng in VACEngines {eng:shutdown.}.
    Nose[0]:shutdown.
    Tank[0]:shutdown.
    SLEngines[0]:getmodule("ModuleGimbal"):SetField("gimbal limit", 0).
    SLEngines[1]:getmodule("ModuleGimbal"):SetField("gimbal limit", 0).
    SLEngines[2]:getmodule("ModuleGimbal"):SetField("gimbal limit", 0).
}


function confirm {
    set executeconfirmed to 0.
    set cancelconfirmed to 0.
    Droppriority().
    until executeconfirmed or cancelconfirmed {
        BackGroundUpdate.
    }
    if executeconfirmed {set action to 1.}
    if cancelconfirmed {set action to 0.}
    set executeconfirmed to 0.
    set cancelconfirmed to 0.
    return action.
}


function CalculateDeOrbitBurn {
    parameter WaitNrOfOrbits.
    set correctedIdealLng to 0.
    set DeOrbitFailed to false.
    set lngPredict to 180.
    set DegreestoLDGzone to 120.
    set x to 10 + (WaitNrOfOrbits * ship:orbit:period).
    until lngPredict > correctedIdealLng - 2 and lngPredict < correctedIdealLng + 2 {
        set idealLng to landingzone:lng - DegreestoLDGzone + (x / (body:rotationperiod / 360)).
        if idealLng < -180 {set correctedIdealLng to idealLng + 360.} else {set correctedIdealLng to idealLng.}
        set lngPredict to body:geopositionof(positionat(ship, time:seconds + x)):lng.
        set x to x + 10.
        if x > 21600 {
            set DeOrbitFailed to true.
            break.
        }
    }
    return x.
}


function DeOrbitVelocity {
    set Error to 999999.
    set PrevError to Error.
    set WaitNrOfOrbits to 0.
    if ship:body = BODY("Kerbin") {
        set ErrorTolerance to 35000.
        set StartPoint to -100.
        set CutOff to -26.
        set RoughStep to 0.5.
        set FineStep to 0.1.
        set SetBack to 4.
    }
    if ship:body = BODY("Duna") {
        set ErrorTolerance to 20000.
        set StartPoint to -50.
        set CutOff to -10.
        set RoughStep to 0.2.
        set FineStep to 0.05.
        set SetBack to 0.
    }
    set ProgradeVelocity to StartPoint.
    until Error < ErrorTolerance {
        set burn to node(deorbitburnstarttime, 0, 0, ProgradeVelocity).
        add burn.
        until addons:tr:hasimpact {}
        wait 0.001.
        set Error to (landingzone:position - addons:tr:impactpos:position):mag.
        if Error > ErrorTolerance {
            set ProgradeVelocity to ProgradeVelocity + RoughStep.
        }
        remove burn.
        if ProgradeVelocity > CutOff {
            set ProgradeVelocity to StartPoint.
            set WaitNrOfOrbits to WaitNrOfOrbits + RoughStep.
            set deorbitburnstarttime to timestamp(time:seconds + CalculateDeOrbitBurn(WaitNrOfOrbits)).
            if DeOrbitFailed {return 0.}
        }
    }
    set ProgradeVelocity to ProgradeVelocity - SetBack.
    set Error to 999999.
    set PrevError to Error.
    until round(Error) > round(PrevError) + 10 and round(Error) < ErrorTolerance {
        set PrevError to Error.
        set burn to node(deorbitburnstarttime, 0, 0, ProgradeVelocity).
        add burn.
        until addons:tr:hasimpact {}
        wait 0.1.
        set Error to (landingzone:position - addons:tr:impactpos:position):mag.
        if Error < PrevError {
            set ProgradeVelocity to ProgradeVelocity + FineStep.
        }
        remove burn.
    }
    remove burn.
    return ProgradeVelocity.
}


function InhibitButtons {
    parameter pagebuttons.
    parameter executebutton.
    parameter cancelbutton.
    
    if pagebuttons {
        set attitudebutton:style:bg to "starship_img/starship_attitude_inhibited".
        set attitudebutton:style:on:bg to "starship_img/starship_attitude_inhibited".
        set attitudebutton:style:hover:bg to "starship_img/starship_attitude_inhibited_hover".
        set attitudebutton:style:hover_on:bg to "starship_img/starship_attitude_inhibited_hover".
        set attitudebutton:style:active:bg to "starship_img/starship_attitude_inhibited_active".
        set attitudebutton:style:active_on:bg to "starship_img/starship_attitude_inhibited_active".
        set cargobutton:style:bg to "starship_img/starship_cargo_inhibited".
        set cargobutton:style:on:bg to "starship_img/starship_cargo_inhibited".
        set cargobutton:style:hover:bg to "starship_img/starship_cargo_inhibited_hover".
        set cargobutton:style:hover_on:bg to "starship_img/starship_cargo_inhibited_hover".
        set cargobutton:style:active:bg to "starship_img/starship_cargo_inhibited_active".
        set cargobutton:style:active_on:bg to "starship_img/starship_cargo_inhibited_active".
        set settingsbutton:style:bg to "starship_img/starship_settings_inhibited".
        set settingsbutton:style:on:bg to "starship_img/starship_settings_inhibited".
        set settingsbutton:style:hover:bg to "starship_img/starship_settings_inhibited_hover".
        set settingsbutton:style:hover_on:bg to "starship_img/starship_settings_inhibited_hover".
        set settingsbutton:style:active:bg to "starship_img/starship_settings_inhibited_active".
        set settingsbutton:style:active_on:bg to "starship_img/starship_settings_inhibited_active".
        set attitudebutton:tooltip to "Attitude Page inhibited".
        set cargobutton:tooltip to "Cargo Page inhibited".
        set settingsbutton:tooltip to "Settings Page inhibited".
        set InhibitPages to 1.}
    if not pagebuttons {
        set attitudebutton:style:bg to "starship_img/starship_attitude".
        set attitudebutton:style:on:bg to "starship_img/starship_attitude_on".
        set attitudebutton:style:hover:bg to "starship_img/starship_attitude_hover".
        set attitudebutton:style:hover_on:bg to "starship_img/starship_attitude_on".
        set attitudebutton:style:active:bg to "starship_img/starship_attitude_hover".
        set attitudebutton:style:active_on:bg to "starship_img/starship_attitude_hover".
        set cargobutton:style:bg to "starship_img/starship_cargo".
        set cargobutton:style:on:bg to "starship_img/starship_cargo_on".
        set cargobutton:style:hover:bg to "starship_img/starship_cargo_hover".
        set cargobutton:style:hover_on:bg to "starship_img/starship_cargo_on".
        set cargobutton:style:active:bg to "starship_img/starship_cargo_hover".
        set cargobutton:style:active_on:bg to "starship_img/starship_cargo_hover".
        set settingsbutton:style:bg to "starship_img/starship_settings".
        set settingsbutton:style:on:bg to "starship_img/starship_settings_on".
        set settingsbutton:style:hover:bg to "starship_img/starship_settings_hover".
        set settingsbutton:style:hover_on:bg to "starship_img/starship_settings_on".
        set settingsbutton:style:active:bg to "starship_img/starship_settings_hover".
        set settingsbutton:style:active_on:bg to "starship_img/starship_settings_hover".
        set attitudebutton:tooltip to "Manual Attitude Control Page (Landing armed @ 10km Radar Altitude)".
        set cargobutton:tooltip to "Cargo Page".
        set settingsbutton:tooltip to "Settings Page".
        set InhibitPages to 0.}

    if executebutton {   
        set execute:style:textcolor to grey.
        set execute:style:hover:bg to "starship_img/starship_background".
        set execute:style:active:bg to "starship_img/starship_background".
        set execute:style:hover:textcolor to grey.
        set execute:tooltip to "Execute inhibited".
        set InhibitExecute to 1.}
    if not executebutton {
        set execute:style:textcolor to cyan.
        set execute:style:hover:bg to "starship_img/starship_background_light".
        set execute:style:active:bg to "starship_img/starship_background_light".
        set execute:style:hover:textcolor to white.
        set execute:tooltip to "Execute selected Maneuver".
        set InhibitExecute to 0.}
    if cancelbutton {
        set cancel:style:textcolor to grey.
        set cancel:style:hover:bg to "starship_img/starship_background".
        set cancel:style:active:bg to "starship_img/starship_background".
        set cancel:style:hover:textcolor to grey.
        set cancel:tooltip to "Cancel inhibited".
        set InhibitCancel to 1.}
    if not cancelbutton {
        set cancel:style:textcolor to cyan.
        set cancel:style:hover:bg to "starship_img/starship_background_light".
        set cancel:style:active:bg to "starship_img/starship_background_light".
        set cancel:style:hover:textcolor to white.
        set cancel:tooltip to "Cancel selected Maneuver".
        set InhibitCancel to 0.}
}


function timeSpanCalculator {
    parameter InputTimeSpan.
    local time to timespan(InputTimeSpan).
    set timeprocessed to "".
    if time > 0 {
        if time:year > 0 {set timeprocessed to time:year + "y".}
        if time:day > 0 {set timeprocessed to timeprocessed + time:day + "d".}
        if time:hour > 0 {set timeprocessed to timeprocessed + time:hour + "h".}
        if time:minute > 0 and time:year = 0 {set timeprocessed to timeprocessed + time:minute + "m".}
        if time:year = 0 and time:day = 0 {
            set timeprocessed to timeprocessed + time:second + "s".
        }
    }
    else {
        if time:year < -1 {set timeprocessed to (time:year + 1) + "y".}
        if time:day < -1 {set timeprocessed to timeprocessed + (time:day + 1) + "d".}
        if time:hour < -1 {set timeprocessed to timeprocessed + (time:hour + 1) + "h".}
        if time:minute < -1 and time:year = -1 {set timeprocessed to timeprocessed + (time:minute + 1) + "m".}
        if time:year = -1 and time:day = -1 {
            set timeprocessed to timeprocessed + (time:second + 1) + "s".
        }
    }
    return timeprocessed.
}

function updatestatusbar {
    if not StatusBarIsRunning {
        set StatusBarIsRunning to true.
        for res in ship:resources {
            if res:name = "ElectricCharge" {
                set ELECcap to res:capacity.
            }
        }
        local bat to round(100 * (ship:electriccharge / ELECcap), 2).
        set status1:text to "<b>Active: </b>" + runningprogram.
        if defined status1 {
            if runningprogram = "None" or runningprogram = "Checking System.." or runningprogram = "System OK" {
                set status1:style:textcolor to white.
            }
            else if runningprogram = "Input" or runningprogram = "Override" {
                set status1:style:textcolor to cyan.
            }
            else if runningprogram = "Abort!" {
                set status1:style:textcolor to red.
            }
            else {
                set status1:style:textcolor to green.
            }
        }
        for res in Tank[0]:resources {
            if res:name = "LiquidFuel" {
                set LFShip to res:amount.
                set LFShipCap to res:capacity.
            }
            if res:name = "LqdMethane" {
                set LFShip to res:amount.
                set LFShipCap to res:capacity.
            }
            if res:name = "Oxidizer" {
                set OxShip to res:amount.
                set OxShipCap to res:capacity.
            }
        }
        for res in HeaderTank[0]:resources {
            if res:name = "LiquidFuel" {
                set LFShip to LFShip + res:amount.
                set LFShipCap to LFShipCap + res:capacity.
            }
            if res:name = "LqdMethane" {
                set LFShip to LFShip + res:amount.
                set LFShipCap to LFShipCap + res:capacity.
            }
            if res:name = "Oxidizer" {
                set OxShip to OxShip + res:amount.
                set OxShipCap to OxShipCap + res:capacity.
            }
        }
        if not CargoCalculationIsRunning {
            set FuelMass to (Tank[0]:mass - Tank[0]:drymass) + (HeaderTank[0]:mass - HeaderTank[0]:drymass).
            if ShowSLdeltaV {
                set EngineISP to 309.
            }
            else {
                set EngineISP to 378.
            }
            if ShipMass = 0 {
                set ShipMass to 200.
            }
            if FuelMass = 0 {
                set FuelMass to 0.001.
            }
            if ship:dockingports[0]:haspartner {
                set status2:style:textcolor to green.
                set status2:text to "<b><color=white>Status: </color>Docked</b>".
            }
            else {
                if FuelMass * 1000 > ShipMass {
                    set FuelMass to 0.001.
                }
                set currentdeltav to round(9.81 * EngineISP * ln(ShipMass / (ShipMass - (FuelMass * 1000)))).
                if currentdeltav > 350 {set status2:style:textcolor to white.}
                else if currentdeltav < 325 {set status2:style:textcolor to red.}
                else {set status2:style:textcolor to yellow.}
                if ShowSLdeltaV {
                    set status2:text to "<b>ΔV: </b>" + currentdeltav + "m/s <b><size=12>@SL</size></b>".
                }
                else {
                    set status2:text to "<b>ΔV: </b>" + currentdeltav + "m/s <b><size=12>@VAC</size></b>".
                }
            }
        }
        if defined bat {
            set bat to round(100 * (ship:electriccharge / ELECcap), 2).
            if bat < 25 and bat > 15 {
                set status3:style:textcolor to yellow.
                set status3:style:bg to "starship_img/starship_battery".
            }
            if bat < 15 {
                set status3:style:textcolor to red.
                set status3:style:bg to "starship_img/starship_battery_red".
            }
            else {
                set status3:style:textcolor to white.
                set status3:style:bg to "starship_img/starship_battery".
            }
            set status3:text to (bat):tostring + "%      ".
        }
        if tooltip:text = "" {
            status1:show().
            status2:show().
            status3:show().
            set tooltip:style:margin:left to 0.
        }
        else {
            if not setting1:pressed {
                status1:hide().
                status2:hide().
                status3:hide().
                set tooltip:style:margin:left to 10.
                tooltip:show().
            }
            else {
                tooltip:hide().
                status1:show().
                status2:show().
                status3:show().
            }
        }
        set shipconnection to homeconnection:isconnected.
        set shipcrewnr to ship:crew:length.
        if defined shipconnection {
            if homeconnection:isconnected {
                set message32:style:textcolor to white.
                set message32:style:bg to "starship_img/starship_signal_white".
                if Logging {
                    set message32:text to "          COM1/TLM".
                }
                else {
                    set message32:text to "          COM1/DLK".
                }
            }
            else {
                set message32:style:textcolor to yellow.
                set message32:style:bg to "starship_img/starship_signal_grey".
                set message32:text to "          NO COM/-".
            }
        }
        if defined shipcrewnr {
            if time:seconds > prevTime + 0.1 {
                TotalCargoMass().
                set prevTime to time:seconds.
            }
            if ShipType = "Crew" {
                if Cargo = 0 {
                    set message12:text to "          " + ship:crew:length + " CREW".
                    set message12:style:textcolor to white.
                    set message12:style:bg to "starship_img/starship_crew_male_small".
                    set message12:style:overflow:right to 0.
                }
                else {
                    set message12:text to "          " + ship:crew:length + "           " + round(Cargo/1000) + "T".
                    set message12:style:textcolor to white.
                    set message12:style:bg to "starship_img/starship_crew_and_cargo".
                    set message12:style:overflow:right to 65.
                }
            }
            else {
                set message12:style:overflow:right to 0.
                if Cargo = 0 {
                    set message12:text to "          0 kg".
                    set message12:style:textcolor to grey.
                    if ShipType = "Tanker" {
                        set message12:style:bg to "starship_img/starship_fuel_grey".
                    }
                    else {
                        set message12:style:bg to "starship_img/starship_cargo_box_grey".
                    }
                }
                else {
                    set message12:text to "          " + round(Cargo) + " kg".
                    set message12:style:textcolor to white.
                    if ShipType = "Tanker" {
                        set message12:style:bg to "starship_img/starship_fuel".
                    }
                    else {
                        set message12:style:bg to "starship_img/starship_cargo_box".
                    }
                }

            }
        }
        if ShipType = "Tanker" {
            cargobutton:hide().
        }
        else {
            cargobutton:show().
        }
        set StatusBarIsRunning to false.
    }
}


function updateStatus {
    if not StatusPageIsRunning {
        set StatusPageIsRunning to true.
        If time:seconds > PrevUpdateTime + 0.1 {
            if FLflap[0]:getmodule("ModuleSEPControlSurface"):GetField("Deploy") {
                set Fpitch to SLEngines[0]:gimbal:pitchangle * FLflap[0]:getmodule("ModuleSEPControlSurface"):GetField("authority limiter").
                set Fyaw to SLEngines[0]:gimbal:yawangle * FLflap[0]:getmodule("ModuleSEPControlSurface"):GetField("authority limiter").
                set Froll to SLEngines[0]:gimbal:rollangle * ( FLflap[0]:getmodule("ModuleSEPControlSurface"):GetField("authority limiter") / 6).

                if not FlapsYawEngaged {
                    set yaw to 0.
                }

                set FL to round(FLflap[0]:getmodule("ModuleSEPControlSurface"):GetField("deploy angle") - Fpitch + Fyaw - Froll).
                set FR to round(FRflap[0]:getmodule("ModuleSEPControlSurface"):GetField("deploy angle") - Fpitch - Fyaw + Froll).
                set AL to round(ALflap[0]:getmodule("ModuleSEPControlSurface"):GetField("deploy angle") + Fpitch - Fyaw - Froll).
                set AR to round(ARflap[0]:getmodule("ModuleSEPControlSurface"):GetField("deploy angle") + Fpitch + Fyaw + Froll).

                if FL < 5 {set FL to 5.} if FL > 80 {set FL to 80.}
                if FR < 5 {set FR to 5.} if FR > 80 {set FR to 80.}
                if AL < 10 {set AL to 10.} if AL > 70 {set AL to 70.}
                if AR < 10 {set AR to 10.} if AR > 70 {set AR to 70.}

                set status1label1:text to FL:tostring + "°".
                set status1label3:text to FR:tostring + "°".
                set status3label1:text to AL:tostring + "°".
                set status3label3:text to AR:tostring + "°".
            }
            else {
                set status1label1:text to "0°".
                set status1label3:text to "0°".
                set status3label1:text to "5°".
                set status3label3:text to "5°".
                set status1label1:style:textcolor to white.
                set status1label3:style:textcolor to white.
                set status3label1:style:textcolor to white.
                set status3label3:style:textcolor to white.
                set status1label2:style:textcolor to white.
            }
            set PrevUpdateTime to time:seconds.
        }
        CalculateShipTemperature().
        if ship:status = "PRELAUNCH" or ship:status = "LANDED" {set status1label4:text to "<b>AoA:</b>  0°".}
        else{set status1label4:text to "<b>AoA:</b>  " + round(vang(ship:facing:forevector, velocity:surface), 1) + "°".}
        if altitude < body:atm:height {
            set MachNr to airspeed / (airspeed / (sqrt(2 / 1.4 * max(ship:q, 0.000001) / max(body:atm:altitudepressure(altitude), 0.000001)))).
            if MachNr > 0.5 {
                set status4label4:text to "<b>MACH:</b>  " + round(MachNr, 2).
            }
            else {
                set status4label4:text to "<b>GSPD:</b>  " + round(groundspeed) + "m/s".
            }
        }
        if altitude > body:atm:height {
            set status4label4:text to "<b>GSPD:</b>  " + round(groundspeed) + "m/s".
        }
        
        if kuniverse:timewarp:warp = 0 {
            set currVel to SHIP:VELOCITY:ORBIT. set currTime to TIME:SECONDS.
            local timeDelta to currTime - prevTime.
            if timeDelta <> 0 {
                set acc to (currVel - prevVel) * (1 / timeDelta) + UP:FOREVECTOR * (SHIP:BODY:MU / (SHIP:BODY:RADIUS + SHIP:ALTITUDE)^2).}
            set prevVel to SHIP:VELOCITY:ORBIT. set prevTime to TIME:SECONDS.
            set GForce to acc:MAG / 9.81.
            if GForce < 0.1 {
                set status3label4:text to "<b>ACC:</b>  0.00G".
            }
            else {
                set status3label4:text to "<b>ACC:</b>  " + round(GForce, 2) + "G".
            }
            if GForce > 3.02 and GForce < 4 {set status3label4:style:textcolor to yellow.}
            if GForce > 4 {set status3label4:style:textcolor to red.}
            if GForce < 3.02 {set status3label4:style:textcolor to white.}
        }
        else {
            set status3label4:text to "<b>ACC:</b>  <color=grey>in warp..</color>".
        }

        set DynamicQ to 100 * ship:q.
        if DynamicQ > 25 {
            set status2label4:style:textcolor to yellow.
        }
        else {
            set status2label4:style:textcolor to white.
        }
        set status2label4:text to "<b>Q:  </b>" + round(DynamicQ, 2) + "kPa".
        local LQFpct is 100 * (LFShip / LFShipCap).
        local OXpct is 100 * (OxShip / OxShipCap).
        if LQFpct > 10 {set status2label5:style:textcolor to grey.}
        if OXpct > 10 {set status3label5:style:textcolor to grey.}
        if LQFpct < 10 and LQFpct > 6 {set status2label5:style:textcolor to yellow.}
        if OXpct < 10 and OXpct > 6 {set status3label5:style:textcolor to yellow.}
        if LQFpct < 6 {set status2label5:style:textcolor to red.}
        if OXpct < 6 {set status3label5:style:textcolor to red.}
        if OnOrbitalMount {
            set status1label5:text to "<b>MASS:</b>  " + round(ship:mass - SHIP:PARTSNAMED("SLE.SS.OLP")[0]:mass - SHIP:PARTSNAMED("SLE.SS.OLIT.Base")[0]:mass - SHIP:PARTSNAMED("SLE.SS.OLIT.Core")[0]:mass - SHIP:PARTSNAMED("SLE.SS.OLIT.Top")[0]:mass - SHIP:PARTSNAMED("SLE.SS.OLIT.MZ")[0]:mass, 1) + "t".
        }
        else if ship:dockingports[0]:haspartner {
            set status1label5:text to "<b>MASS:</b>  <color=grey><size=12>docked..</size></color>".
        }
        else {
            set status1label5:text to "<b>MASS:</b>  " + round(ship:mass, 1) + "t".
        }
        set status2label5:text to "<b>" + round(LQFpct) + "% CH4</b>".
        if LQFpct < 20 {
            set status2label4:style:border:h to (LQFpct / 20) * 10.
            set status2label4:style:border:v to (LQFpct / 20) * 10.
            set status3label4:style:border:h to (LQFpct / 20) * 10.
            set status3label4:style:border:v to (LQFpct / 20) * 10.
        }
        else {
            set status2label4:style:border:h to 10.
            set status2label4:style:border:v to 10.
            set status3label4:style:border:h to 10.
            set status3label4:style:border:v to 10.
        }
        set status2label4:style:overflow:right to 25 + (LQFpct * 1.03).
        set status3label5:text to "<b>" + round(OXpct) + "% LOX</b>".
        set status3label4:style:overflow:right to 25 + (OXpct * 1.03).
        set status4label5:text to "<b>VS:</b>  " + round(ship:verticalspeed, 1) + "m/s".
        set StatusPageIsRunning to false.
    }
}


function CalculateShipTemperature {
    if FLflap[0]:getmodule("ModuleSEPControlSurface"):GetField("Deploy") = true {
        if runningprogram = "De-orbit & Landing" or runningprogram = "Final Approach" or runningprogram = "Landing" or runningprogram = "After Landing" or runningprogram = "Attitude (Landing Armed)" {
            set FlapsControl to "magenta".
            set status1label1:style:textcolor to magenta.
            set status1label3:style:textcolor to magenta.
            set status3label1:style:textcolor to magenta.
            set status3label3:style:textcolor to magenta.
            set status1label2:style:textcolor to magenta.
        }
        else {
            set FlapsControl to "manual".
            set status1label1:style:textcolor to cyan.
            set status1label3:style:textcolor to cyan.
            set status3label1:style:textcolor to cyan.
            set status3label3:style:textcolor to cyan.
            set status1label2:style:textcolor to cyan.
        }
    }
    else {
        set FlapsControl to "none".
    }
    set ShipTemperature to min(max(body:atm:alttemp(altitude) - 273.15, -86) + (0.15 * max(vang(facing:forevector, velocity:surface), 10) * (ship:q * (airspeed / 100)^3)), 1750).
    if ShipTemperature > 1200 {
        set status2label1:style:textcolor to red.
        set status2label3:style:textcolor to red.
        if FlapsControl = "magenta" {
            set status2label2:style:bg to "starship_img/starship_symbol_flaps_magenta_hot".
        }
        else if FlapsControl = "manual" {
            set status2label2:style:bg to "starship_img/starship_symbol_flaps_cyan_hot".
        }
        else {
            set status2label2:style:bg to "starship_img/starship_symbol_hot".
        }
    }
    else if ShipTemperature > 900 {
        set status2label1:style:textcolor to yellow.
        set status2label3:style:textcolor to yellow.
        if FlapsControl = "magenta" {
            set status2label2:style:bg to "starship_img/starship_symbol_flaps_magenta_warm".
        }
        else if FlapsControl = "manual" {
            set status2label2:style:bg to "starship_img/starship_symbol_flaps_cyan_warm".
        }
        else {
            set status2label2:style:bg to "starship_img/starship_symbol_warm".
        }
    }
    else {
        set status2label1:style:textcolor to white.
        set status2label3:style:textcolor to white.
        if FlapsControl = "magenta" {
            set status2label2:style:bg to "starship_img/starship_symbol_flaps_magenta".
        }
        else if FlapsControl = "manual" {
            set status2label2:style:bg to "starship_img/starship_symbol_flaps_cyan".
        }
        else {
            set status2label2:style:bg to "starship_img/starship_symbol".
        }
    }
    set status2label1:text to round(ShipTemperature + 0.3) + "°C".
    set status2label3:text to round(ShipTemperature - (0.001 * ShipTemperature)) + "°C".
}


function updateEnginePage {
    if not EnginePageIsRunning {
        set EnginePageIsRunning to true.
        if throttle < 0.2 {
            set throttleborder to (throttle / 0.2) * 10.
        }
        else {
            set throttleborder to 10.
        }
        if Boosterconnected {
            set engine1label1:text to "<b>SH Raptors</b>".
            set engine1label1:tooltip to "33 Super Heavy Raptor Engines".
            set engine1label5:tooltip to "Performance Status of the Super Heavy Raptor Engines".
            set engine1label2:tooltip to "Command Status of the Super Heavy Raptor Engines".
            set engine1label4:tooltip to "".
            set engine2label1:tooltip to "Thrust in kN of the Super Heavy Raptor Engines".
            set engine2label5:tooltip to "% of Fuel Remaining in the Booster CH4 & LOX tanks".
            set boosterfuel to 100 * (BoosterCore[0]:resources[0]:amount / BoosterCore[0]:resources[0]:capacity).
            if boosterfuel < 20 {
                set engine2label4:style:border:h to (boosterfuel / 20) * 10.
                set engine2label4:style:border:h to (boosterfuel / 20) * 10.
            }
            else {
                set engine2label4:style:border:h to 10.
                set engine2label4:style:border:h to 10.
            }
            set engine2label4:style:overflow:right to 39 + round(boosterfuel).
            set engine2label5:text to "<b>" + round(boosterfuel) + "% <size=12>CH4/LOX</size></b>".
            if BoosterEngines[0]:ignition and BoosterEngines[0]:thrust > 0 {
                set engine2label3:style:bg to "starship_img/booster_active".
                set engine1label1:style:textcolor to green.
                set engine1label2:style:textcolor to green.
                set engine1label2:text to "ON".
                set engine3label1:style:textcolor to magenta.
                set engine3label2:style:textcolor to magenta.
                set engine3label4:style:textcolor to magenta.
                set engine3label5:style:textcolor to magenta.
                set engine3label2:text to round(BoosterEngines[0]:gimbal:pitchangle * BoosterEngines[0]:gimbal:range) + "°".
                set engine3label4:text to round(BoosterEngines[0]:gimbal:yawangle * BoosterEngines[0]:gimbal:range) + "°".
                set engine2label1:text to round(BoosterEngines[0]:thrust):tostring + " kN".
                set engine2label1:style:overflow:right to -100 + (100 * (BoosterEngines[0]:thrust / max(BoosterEngines[0]:availablethrust, 0.000001))).
                set engine2label1:style:border:h to throttleborder.
                set engine2label1:style:border:v to throttleborder.
                set engine1label5:text to "<b>33/33 OK</b>".
                set engine1label5:style:textcolor to green.
            }
            else if BoosterEngines[0]:ignition {
                set engine2label3:style:bg to "starship_img/booster_ready".
                set engine1label1:style:textcolor to cyan.
                set engine1label2:style:textcolor to cyan.
                set engine1label2:text to "SBY".
                set engine3label1:style:textcolor to magenta.
                set engine3label2:style:textcolor to magenta.
                set engine3label4:style:textcolor to magenta.
                set engine3label5:style:textcolor to magenta.
                set engine3label2:text to round(BoosterEngines[0]:gimbal:pitchangle * SLEngines[0]:gimbal:range) + "°".
                set engine3label4:text to round(BoosterEngines[0]:gimbal:yawangle * SLEngines[0]:gimbal:range) + "°".
                set engine2label1:text to round(BoosterEngines[0]:thrust):tostring + " kN".
                set engine2label1:style:overflow:right to -100.
                set engine2label1:style:border:h to 0.
                set engine2label1:style:border:v to 0.
                set engine1label5:text to "<b>33/33 Ready</b>".
                set engine1label5:style:textcolor to cyan.
            }
            else {
                set engine2label3:style:bg to "starship_img/booster_off".
                set engine1label1:style:textcolor to grey.
                set engine1label2:style:textcolor to grey.
                set engine1label2:text to "OFF".
                set engine3label1:style:textcolor to grey.
                set engine3label2:style:textcolor to grey.
                set engine3label4:style:textcolor to grey.
                set engine3label5:style:textcolor to grey.
                set engine2label1:text to round(BoosterEngines[0]:thrust):tostring + " kN".
                set engine2label1:style:overflow:right to -100.
                set engine2label1:style:border:h to 0.
                set engine2label1:style:border:v to 0.
                set engine3label2:text to "-".
                set engine3label4:text to "-".
                set engine1label5:text to "0/33 Ready".
                set engine1label5:style:textcolor to grey.
            }
        }
        else {
            set engine1label1:text to "<b>SL Raptors</b>".
            set engine1label5:text to "<b>VAC Raptors</b>".
            set engine1label1:tooltip to "Inner 3 Sea-Level Raptor Engines".
            set engine1label5:tooltip to "Outer 6 Vacuum Raptor Engines".
            set engine1label2:tooltip to "Status of the Sea-Level Raptor Engines".
            set engine1label4:tooltip to "Status of the Vacuum Raptor Engines".
            set engine2label1:tooltip to "Thrust in kN of the Sea-Level Raptor Engines".
            set engine2label5:tooltip to "Thrust in kN of the Vacuum Raptor Engines".
            if SLEngines[0]:ignition = false and VACEngines[0]:ignition = false {
                if ship:control:translation:z > 0 or ship:control:pilottranslation:z > 0 {
                    if NrOfVacEngines = 6 {
                        set engine2label3:style:bg to "starship_img/starship_9engine_rcs".
                    }
                    if NrOfVacEngines = 3 {
                        set engine2label3:style:bg to "starship_img/starship_6engine_rcs".
                    }
                }
                else {
                    if NrOfVacEngines = 6 {
                        set engine2label3:style:bg to "starship_img/starship_9engine_none_active".
                    }
                    if NrOfVacEngines = 3 {
                        set engine2label3:style:bg to "starship_img/starship_6engine_none_active".
                    }
                }
                set engine1label1:style:textcolor to white.
                set engine1label5:style:textcolor to white.
                set engine1label2:style:textcolor to grey.
                set engine1label2:text to "OFF".
                set engine1label4:style:textcolor to grey.
                set engine1label4:text to "OFF".
                set engine3label1:style:textcolor to grey.
                set engine3label2:style:textcolor to grey.
                set engine3label4:style:textcolor to grey.
                set engine3label5:style:textcolor to grey.
                set engine3label2:text to "-".
                set engine3label4:text to "-".
                set engine2label1:text to "SBY".
                set engine2label1:style:overflow:right to -100.
                set engine2label1:style:border:h to 0.
                set engine2label1:style:border:v to 0.
                set engine2label4:style:border:h to 0.
                set engine2label4:style:border:v to 0.
                set engine2label5:text to "SBY".
                if EngineTogglesHidden {
                    set engine2label4:style:overflow:right to 39.
                }
                else {
                    set engine2label4:style:overflow:right to 10.
                }
            }
            if SLEngines[0]:ignition = true and VACEngines[0]:ignition = false {
                if SLEngines[0]:thrust > 0 {
                    if NrOfVacEngines = 6 {
                        set engine2label3:style:bg to "starship_img/starship_9engine_sl_active".
                    }
                    if NrOfVacEngines = 3 {
                        set engine2label3:style:bg to "starship_img/starship_6engine_sl_active".
                    }
                }
                else {
                    if NrOfVacEngines = 6 {
                        set engine2label3:style:bg to "starship_img/starship_9engine_sl_ready".
                    }
                    if NrOfVacEngines = 3 {
                        set engine2label3:style:bg to "starship_img/starship_6engine_sl_ready".
                    }
                }
                set engine1label1:style:textcolor to cyan.
                set engine1label5:style:textcolor to white.
                set engine1label2:style:textcolor to cyan.
                set engine1label2:text to "ON".
                set engine1label4:style:textcolor to grey.
                set engine1label4:text to "OFF".
                set engine3label1:style:textcolor to magenta.
                set engine3label2:style:textcolor to magenta.
                set engine3label4:style:textcolor to magenta.
                set engine3label5:style:textcolor to magenta.
                set engine3label2:text to round(SLEngines[0]:gimbal:pitchangle * SLEngines[0]:gimbal:range) + "°".
                set engine3label4:text to round(SLEngines[0]:gimbal:yawangle * SLEngines[0]:gimbal:range) + "°".
                set engine2label1:text to round(3 * SLEngines[0]:thrust):tostring + " kN".
                set engine2label1:style:overflow:right to -100 + (100 * (SLEngines[0]:thrust / max(SLEngines[0]:availablethrust, 0.000001))).
                set engine2label1:style:border:h to throttleborder.
                set engine2label1:style:border:v to throttleborder.
                set engine2label4:style:border:h to 0.
                set engine2label4:style:border:v to 0.
                if EngineTogglesHidden {
                    set engine2label4:style:overflow:right to 39.
                }
                else {
                    set engine2label4:style:overflow:right to 10.
                }
                set engine2label5:text to "SBY".
            }
            if SLEngines[0]:ignition = false and VACEngines[0]:ignition = true {
                if VACEngines[0]:thrust > 0 {
                    if NrOfVacEngines = 6 {
                        set engine2label3:style:bg to "starship_img/starship_9engine_vac_active".
                    }
                    if NrOfVacEngines = 3 {
                        set engine2label3:style:bg to "starship_img/starship_6engine_vac_active".
                    }
                }
                else {
                    if NrOfVacEngines = 6 {
                        set engine2label3:style:bg to "starship_img/starship_9engine_vac_ready".
                    }
                    if NrOfVacEngines = 3 {
                        set engine2label3:style:bg to "starship_img/starship_6engine_vac_ready".
                    }
                }
                set engine1label1:style:textcolor to white.
                set engine1label5:style:textcolor to cyan.
                set engine1label2:style:textcolor to grey.
                set engine1label2:text to "OFF".
                set engine1label4:style:textcolor to cyan.
                set engine1label4:text to "ON".
                set engine3label1:style:textcolor to grey.
                set engine3label2:style:textcolor to grey.
                set engine3label4:style:textcolor to grey.
                set engine3label5:style:textcolor to grey.
                set engine3label2:text to "-".
                set engine3label4:text to "-".
                set engine2label1:text to "SBY".
                set engine2label1:style:border:h to 0.
                set engine2label1:style:border:v to 0.
                set engine2label4:style:border:h to throttleborder.
                set engine2label4:style:border:v to throttleborder.
                set engine2label1:style:overflow:right to -100.
                set engine2label5:text to round(NrOfVacEngines * VACEngines[0]:thrust):tostring + " kN".
                if EngineTogglesHidden {
                    set engine2label4:style:overflow:right to 39 + (100 * (VACEngines[0]:thrust / max(VACEngines[0]:availablethrust, 0.000001))).
                }
                else {
                    set engine2label4:style:overflow:right to 10 + (100 * (VACEngines[0]:thrust / max(VACEngines[0]:availablethrust, 0.000001))).
                }
            }
            if SLEngines[0]:ignition = true and VACEngines[0]:ignition = true {
                if SLEngines[0]:thrust > 0 {
                    if NrOfVacEngines = 6 {
                        set engine2label3:style:bg to "starship_img/starship_9engine_all_active".
                    }
                    if NrOfVacEngines = 3 {
                        set engine2label3:style:bg to "starship_img/starship_6engine_all_active".
                    }
                }
                else {
                    if NrOfVacEngines = 6 {
                        set engine2label3:style:bg to "starship_img/starship_9engine_all_ready".
                    }
                    if NrOfVacEngines = 3 {
                        set engine2label3:style:bg to "starship_img/starship_6engine_all_ready".
                    }
                }
                set engine1label1:style:textcolor to cyan.
                set engine1label5:style:textcolor to cyan.
                set engine1label2:style:textcolor to cyan.
                set engine1label2:text to "ON".
                set engine1label4:style:textcolor to cyan.
                set engine1label4:text to "ON".
                set engine3label1:style:textcolor to magenta.
                set engine3label2:style:textcolor to magenta.
                set engine3label4:style:textcolor to magenta.
                set engine3label5:style:textcolor to magenta.
                set engine3label2:text to round(SLEngines[0]:gimbal:pitchangle * SLEngines[0]:gimbal:range) + "°".
                set engine3label4:text to round(SLEngines[0]:gimbal:yawangle * SLEngines[0]:gimbal:range) + "°".
                set engine2label1:text to round(3 * SLEngines[0]:thrust):tostring + " kN".
                set engine2label1:style:border:h to throttleborder.
                set engine2label1:style:border:v to throttleborder.
                set engine2label4:style:border:h to throttleborder.
                set engine2label4:style:border:v to throttleborder.
                set engine2label1:style:overflow:right to -100 + (100 * (SLEngines[0]:thrust / max(SLEngines[0]:availablethrust, 0.000001))).
                set engine2label5:text to round(3 * VACEngines[0]:thrust):tostring + " kN".
                if EngineTogglesHidden {
                    set engine2label4:style:overflow:right to 39 + (100 * (VACEngines[0]:thrust / max(VACEngines[0]:availablethrust, 0.000001))).
                }
                else {
                    set engine2label4:style:overflow:right to 10 + (100 * (VACEngines[0]:thrust / max(VACEngines[0]:availablethrust, 0.000001))).
                }
            }
        }
        set EnginePageIsRunning to false.
    }
}


function updateOrbit {
    if not OrbitPageIsRunning {
        set OrbitPageIsRunning to true.
        if ship:orbit:hasnextpatch {
            set period to 0.
        }
        else {
            set period to ship:orbit:period.
        }
        if ship:status = "LANDED" or ship:status = "PRELAUNCH" or ship:status = "SPLASHED" {
            set orbit1label1:text to "<b>Apoapsis:    -</b>".
            set orbit2label1:text to "<b>Periapsis:    -</b>".
            set orbit3label1:text to "<b>Period:         -</b>".
            set orbit1label2:text to "<b>Time to Ap:    -</b>".
            set orbit2label2:text to "<b>Time to Pe:    -</b>".
            set orbit3label2:text to "<b>Inclination:    -</b>".
        }
        else {
            if apoapsis > 9999999 {
                set orbit1label1:text to "<b>Apoapsis: </b>" + round(apoapsis / 1000) + "km".
            }
            else {
                set orbit1label1:text to "<b>Apoapsis: </b>" + round(apoapsis / 1000, 3) + "km".
            }
            if periapsis > 9999999 {
                set orbit2label1:text to "<b>Periapsis: </b>" + round(periapsis / 1000) + "km".
            }
            else {
                set orbit2label1:text to "<b>Periapsis: </b>" + round(periapsis / 1000, 3) + "km".
            }
            set orbit3label1:text to "<b>Period: </b>" + timeSpanCalculator(period).
            set orbit1label2:text to "<b>Time to Ap: </b>" + timeSpanCalculator(eta:apoapsis).
            set orbit2label2:text to "<b>Time to Pe: </b>" + timeSpanCalculator(eta:periapsis).
            set orbit3label2:text to "<b>Inclination: </b>" + round(ship:orbit:inclination, 3) + "°".
        }
        if hasnode {
            set orbit1label3:text to "       <b>" + timeSpanCalculator(nextnode:eta) + "</b>".
            set orbit2label3:text to "<b>ΔV: " + round(nextnode:deltav:mag, 1) + "m/s</b>".
            set orbit1label3:style:bg to "starship_img/starship_maneuver_node".
            set orbit1label3:style:textcolor to magenta.
            set orbit2label3:style:textcolor to magenta.}
        else {
            set orbit1label3:text to "".
            set orbit2label3:text to "<b>  -</b>".
            set orbit1label3:style:bg to "starship_img/starship_maneuver_node_grey".
            set orbit1label3:style:textcolor to grey.
            set orbit2label3:style:textcolor to grey.}
        if homeconnection:isconnected {
            if ship:body = BODY("Kerbin") {
                if ship:status = "LANDED" or ship:status = "PRELAUNCH" {
                    set orbit1label2:style:bg to "starship_img/orbit_page_background_kerbin_landed".
                }
                else if ship:status = "SUB_ORBITAL" and verticalspeed > 0 or ship:status = "FLYING" and verticalspeed > 0 {
                    set orbit1label2:style:bg to "starship_img/orbit_page_background_kerbin_launch".
                }
                else if ship:status = "SUB_ORBITAL" and verticalspeed < 0 or ship:status = "FLYING" and verticalspeed < 0 {
                    set orbit1label2:style:bg to "starship_img/orbit_page_background_kerbin_reentry".
                }
                else {
                    set orbit1label2:style:bg to "starship_img/orbit_page_background_kerbin".
                }
                set orbit3label3:style:textcolor to cyan.
                set orbit3label3:style:bg to "starship_img/starship_comms_cyan".
                set orbit3label3:text to "<b>      GPS/GPS</b>".
            }
            else if ship:body = BODY("Duna") {
                if ship:status = "LANDED" or ship:status = "PRELAUNCH" {
                    set orbit1label2:style:bg to "starship_img/orbit_page_background_duna_landed".
                }
                else if ship:status = "SUB_ORBITAL" and verticalspeed > 0 or ship:status = "FLYING" and verticalspeed > 0 {
                    set orbit1label2:style:bg to "starship_img/orbit_page_background_duna_launch".
                }
                else if ship:status = "SUB_ORBITAL" and verticalspeed < 0 or ship:status = "FLYING" and verticalspeed < 0 {
                    set orbit1label2:style:bg to "starship_img/orbit_page_background_duna_reentry".
                }
                else {
                    set orbit1label2:style:bg to "starship_img/orbit_page_background_duna".
                }
                set orbit3label3:style:textcolor to white.
                set orbit3label3:style:bg to "starship_img/starship_comms_celestial_nav".
                set orbit3label3:text to "<b>      CBN/CBN</b>".
            }
            else if ship:body = BODY("Mun") {
                if ship:status = "LANDED" or ship:status = "PRELAUNCH" {
                    set orbit1label2:style:bg to "starship_img/orbit_page_background_mun_landed".
                }
                else if ship:status = "SUB_ORBITAL" and verticalspeed > 0 or ship:status = "FLYING" and verticalspeed > 0 {
                    set orbit1label2:style:bg to "starship_img/orbit_page_background_mun_launch".
                }
                else if ship:status = "SUB_ORBITAL" and verticalspeed < 0 or ship:status = "FLYING" and verticalspeed < 0 {
                    set orbit1label2:style:bg to "starship_img/orbit_page_background_mun_reentry".
                }
                else {
                    set orbit1label2:style:bg to "starship_img/orbit_page_background_mun".
                }
                set orbit3label3:style:textcolor to cyan.
                set orbit3label3:style:bg to "starship_img/starship_comms_cyan".
                set orbit3label3:text to "<b>      GPS/CBN</b>".
            }
            else {
                set orbit1label2:style:bg to "starship_img/orbit_page_background_transfer".
                set orbit3label3:style:textcolor to white.
                set orbit3label3:style:bg to "starship_img/starship_comms_celestial_nav".
                set orbit3label3:text to "<b>      CBN/CBN</b>".
            }
        }
        else {
            set orbit1label2:style:bg to "starship_img/orbit_page_background_unknown_transfer".
            set orbit3label3:style:textcolor to yellow.
            set orbit3label3:style:bg to "starship_img/starship_comms_grey".
            set orbit3label3:text to "<b>      IRS/IRS</b>".
        }
        set OrbitPageIsRunning to false.
    }
}


function updateCrew {
    if not CrewPageIsRunning {
        set CrewPageIsRunning to true.
        set CrewList to ship:crew.
        if CrewList:length > 0 {
            if CrewList[0]:gender = "male" {
                set crew1label1:style:bg to "starship_img/starship_crew_male".
            }
            else {
                set crew1label1:style:bg to "starship_img/starship_crew_female".
            }
            set crew3label1:text to CrewList[0]:name:split(" ")[0].
            set crew2label1:text to "".
            set crew2label1:style:bg to FindExperience(CrewList[0]:experience).
            if CrewList[0]:trait  = "Pilot" {
                set crew3label1:style:bg to "starship_img/starship_crew_pilot".
            }
            if CrewList[0]:trait  = "Engineer" {
                set crew3label1:style:bg to "starship_img/starship_crew_engineer".
            }
            if CrewList[0]:trait  = "Scientist" {
                set crew3label1:style:bg to "starship_img/starship_crew_scientist".
            }
        }
        else {
            set crew1label1:style:bg to "starship_img/starship_crew_grey".
            set crew2label1:text to "<b>1</b>".
            set crew3label1:style:bg to "".
            set crew2label1:style:bg to "".
            set crew1label1:text to "".
            set crew3label1:text to "".
        }
        if CrewList:length > 1 {
            if CrewList[1]:gender = "male" {
                set crew1label2:style:bg to "starship_img/starship_crew_male".
            }
            else {
                set crew1label2:style:bg to "starship_img/starship_crew_female".
            }
            set crew3label2:text to CrewList[1]:name:split(" ")[0].
            set crew2label2:text to "".
            set crew2label2:style:bg to FindExperience(CrewList[1]:experience).
            if CrewList[1]:trait  = "Pilot" {
                set crew3label2:style:bg to "starship_img/starship_crew_pilot".
            }
            if CrewList[1]:trait  = "Engineer" {
                set crew3label2:style:bg to "starship_img/starship_crew_engineer".
            }
            if CrewList[1]:trait  = "Scientist" {
                set crew3label2:style:bg to "starship_img/starship_crew_scientist".
            }
        }
        else {
            set crew1label2:style:bg to "starship_img/starship_crew_grey".
            set crew2label2:text to "<b>2</b>".
            set crew3label2:style:bg to "".
            set crew2label2:style:bg to "".
            set crew1label2:text to "".
            set crew3label2:text to "".
        }
        if CrewList:length > 2 {
            if CrewList[2]:gender = "male" {
                set crew1label3:style:bg to "starship_img/starship_crew_male".
            }
            else {
                set crew1label3:style:bg to "starship_img/starship_crew_female".
            }
            set crew3label3:text to CrewList[2]:name:split(" ")[0].
            set crew2label3:text to "".
            set crew2label3:style:bg to FindExperience(CrewList[2]:experience).
            if CrewList[2]:trait  = "Pilot" {
                set crew3label3:style:bg to "starship_img/starship_crew_pilot".
            }
            if CrewList[2]:trait  = "Engineer" {
                set crew3label3:style:bg to "starship_img/starship_crew_engineer".
            }
            if CrewList[2]:trait  = "Scientist" {
                set crew3label3:style:bg to "starship_img/starship_crew_scientist".
            }
        }
        else {
            set crew1label3:style:bg to "starship_img/starship_crew_grey".
            set crew2label3:text to "<b>3</b>".
            set crew3label3:style:bg to "".
            set crew2label3:style:bg to "".
            set crew1label3:text to "".
            set crew3label3:text to "".
        }
        if CrewList:length > 3 {
            if CrewList[3]:gender = "male" {
                set crew1label4:style:bg to "starship_img/starship_crew_male".
            }
            else {
                set crew1label4:style:bg to "starship_img/starship_crew_female".
            }
            set crew3label4:text to CrewList[3]:name:split(" ")[0].
            set crew2label4:text to "".
            set crew2label4:style:bg to FindExperience(CrewList[3]:experience).
            if CrewList[3]:trait  = "Pilot" {
                set crew3label4:style:bg to "starship_img/starship_crew_pilot".
            }
            if CrewList[3]:trait  = "Engineer" {
                set crew3label4:style:bg to "starship_img/starship_crew_engineer".
            }
            if CrewList[3]:trait  = "Scientist" {
                set crew3label4:style:bg to "starship_img/starship_crew_scientist".
            }
        }
        else {
            set crew1label4:style:bg to "starship_img/starship_crew_grey".
            set crew2label4:text to "<b>4</b>".
            set crew3label4:style:bg to "".
            set crew2label4:style:bg to "".
            set crew1label4:text to "".
            set crew3label4:text to "".
        }
        if CrewList:length > 4 {
            if CrewList[4]:gender = "male" {
                set crew1label5:style:bg to "starship_img/starship_crew_male".
            }
            else {
                set crew1label5:style:bg to "starship_img/starship_crew_female".
            }
            set crew3label5:text to CrewList[4]:name:split(" ")[0].
            set crew2label5:text to "".
            set crew2label5:style:bg to FindExperience(CrewList[4]:experience).
            if CrewList[4]:trait  = "Pilot" {
                set crew3label5:style:bg to "starship_img/starship_crew_pilot".
            }
            if CrewList[4]:trait  = "Engineer" {
                set crew3label5:style:bg to "starship_img/starship_crew_engineer".
            }
            if CrewList[4]:trait  = "Scientist" {
                set crew3label5:style:bg to "starship_img/starship_crew_scientist".
            }
        }
        else {
            set crew1label5:style:bg to "starship_img/starship_crew_grey".
            set crew2label5:text to "<b>5</b>".
            set crew3label5:style:bg to "".
            set crew2label5:style:bg to "".
            set crew1label5:text to "".
            set crew3label5:text to "".
        }
        if CrewList:length > 5 {
            if CrewList[5]:gender = "male" {
                set crew1label6:style:bg to "starship_img/starship_crew_male".
            }
            else {
                set crew1label6:style:bg to "starship_img/starship_crew_female".
            }
            set crew3label6:text to CrewList[5]:name:split(" ")[0].
            set crew2label6:text to "".
            set crew2label6:style:bg to FindExperience(CrewList[5]:experience).
            if CrewList[5]:trait  = "Pilot" {
                set crew3label6:style:bg to "starship_img/starship_crew_pilot".
            }
            if CrewList[5]:trait  = "Engineer" {
                set crew3label6:style:bg to "starship_img/starship_crew_engineer".
            }
            if CrewList[5]:trait  = "Scientist" {
                set crew3label6:style:bg to "starship_img/starship_crew_scientist".
            }
        }
        else {
            set crew1label6:style:bg to "starship_img/starship_crew_grey".
            set crew2label6:text to "<b>6</b>".
            set crew3label6:style:bg to "".
            set crew2label6:style:bg to "".
            set crew1label6:text to "".
            set crew3label6:text to "".
        }
        if CrewList:length > 6 {
            if CrewList[6]:gender = "male" {
                set crew1label7:style:bg to "starship_img/starship_crew_male".
            }
            else {
                set crew1label7:style:bg to "starship_img/starship_crew_female".
            }
            set crew3label7:text to CrewList[6]:name:split(" ")[0].
            set crew2label7:text to "".
            set crew2label7:style:bg to FindExperience(CrewList[6]:experience).
            if CrewList[6]:trait  = "Pilot" {
                set crew3label7:style:bg to "starship_img/starship_crew_pilot".
            }
            if CrewList[6]:trait  = "Engineer" {
                set crew3label7:style:bg to "starship_img/starship_crew_engineer".
            }
            if CrewList[6]:trait  = "Scientist" {
                set crew3label7:style:bg to "starship_img/starship_crew_scientist".
            }
        }
        else {
            set crew1label7:style:bg to "starship_img/starship_crew_grey".
            set crew2label7:text to "<b>7</b>".
            set crew3label7:style:bg to "".
            set crew2label7:style:bg to "".
            set crew1label7:text to "".
            set crew3label7:text to "".
        }
        if CrewList:length > 7 {
            if CrewList[7]:gender = "male" {
                set crew1label8:style:bg to "starship_img/starship_crew_male".
            }
            else {
                set crew1label8:style:bg to "starship_img/starship_crew_female".
            }
            set crew3label8:text to CrewList[7]:name:split(" ")[0].
            set crew2label8:text to "".
            set crew2label8:style:bg to FindExperience(CrewList[7]:experience).
            if CrewList[7]:trait  = "Pilot" {
                set crew3label8:style:bg to "starship_img/starship_crew_pilot".
            }
            if CrewList[7]:trait  = "Engineer" {
                set crew3label8:style:bg to "starship_img/starship_crew_engineer".
            }
            if CrewList[7]:trait  = "Scientist" {
                set crew3label8:style:bg to "starship_img/starship_crew_scientist".
            }
        }
        else {
            set crew1label8:style:bg to "starship_img/starship_crew_grey".
            set crew2label8:text to "<b>8</b>".
            set crew3label8:style:bg to "".
            set crew2label8:style:bg to "".
            set crew1label8:text to "".
            set crew3label8:text to "".
        }
        if CrewList:length > 8 {
            if CrewList[8]:gender = "male" {
                set crew1label9:style:bg to "starship_img/starship_crew_male".
            }
            else {
                set crew1label9:style:bg to "starship_img/starship_crew_female".
            }
            set crew3label9:text to CrewList[8]:name:split(" ")[0].
            set crew2label9:text to "".
            set crew2label9:style:bg to FindExperience(CrewList[8]:experience).
            if CrewList[8]:trait  = "Pilot" {
                set crew3label9:style:bg to "starship_img/starship_crew_pilot".
            }
            if CrewList[8]:trait  = "Engineer" {
                set crew3label9:style:bg to "starship_img/starship_crew_engineer".
            }
            if CrewList[8]:trait  = "Scientist" {
                set crew3label9:style:bg to "starship_img/starship_crew_scientist".
            }
        }
        else {
            set crew1label9:style:bg to "starship_img/starship_crew_grey".
            set crew2label9:text to "<b>9</b>".
            set crew3label9:style:bg to "".
            set crew2label9:style:bg to "".
            set crew1label9:text to "".
            set crew3label9:text to "".
        }
        if CrewList:length > 9 {
            if CrewList[9]:gender = "male" {
                set crew1label10:style:bg to "starship_img/starship_crew_male".
            }
            else {
                set crew1label10:style:bg to "starship_img/starship_crew_female".
            }
            set crew3label10:text to CrewList[9]:name:split(" ")[0].
            set crew2label10:text to "".
            set crew2label10:style:bg to FindExperience(CrewList[9]:experience).
            if CrewList[9]:trait  = "Pilot" {
                set crew3label10:style:bg to "starship_img/starship_crew_pilot".
            }
            if CrewList[9]:trait  = "Engineer" {
                set crew3label10:style:bg to "starship_img/starship_crew_engineer".
            }
            if CrewList[9]:trait  = "Scientist" {
                set crew3label10:style:bg to "starship_img/starship_crew_scientist".
            }
        }
        else {
            set crew1label10:style:bg to "starship_img/starship_crew_grey".
            set crew2label10:text to "<b>10</b>".
            set crew3label10:style:bg to "".
            set crew2label10:style:bg to "".
            set crew1label10:text to "".
            set crew3label10:text to "".
        }
        if time:seconds > prevFanTime + 0.5 {
            if fan {
                set crewlabel6:style:bg to "starship_img/fan_spinning_1".
                set fan to false.
            }
            else {
                set crewlabel6:style:bg to "starship_img/fan_spinning_2".
                set fan to true.
            }
            set TempPressVariations to time:seconds / 3600 - floor(time:seconds / 3600).
            set TempPressVariations to sin(TempPressVariations * 360).
            set crewlabel2:text to "<b>P:  <color=green>" + round(99.2 + (1.5 * TempPressVariations), 1) + " kPa</color></b>".
            set crewlabel3:text to "<b>T:   <color=green>" + round(22.3 - (1.5 * TempPressVariations), 1) + "°c</color></b>".
            if TempPressVariations > 0.5 and TempPressVariations < 0.75 {
                set crewlabel5:text to "<b>AQM:  <color=yellow>MED</color></b>".
            }
            else {
                set crewlabel5:text to "<b>AQM:  <color=green>OK</color></b>".
            }
            set prevFanTime to time:seconds.
        }
        set CrewPageIsRunning to false.
    }
}


function FindExperience {
    parameter experience.
    if experience = 0 {
        return "".
    }
    if experience = 1 {
        return "starship_img/starship_crew_1star".
    }
    if experience = 2 {
        return "starship_img/starship_crew_2star".
    }
    if experience = 3 {
        return "starship_img/starship_crew_3star".
    }
    if experience = 4 {
        return "starship_img/starship_crew_4star".
    }
    if experience = 5 {
        return "starship_img/starship_crew_5star".
    }
}


function ClearInterfaceAndSteering {
    GoHome().
    set throttle to 0.
    ShutdownEngines().
    set ship:control:translation to v(0, 0, 0).
    unlock steering.
    unlock throttle.
    set runningprogram to "None".
    if hasnode {
        remove nextnode.
        wait 0.001.
    }
    InhibitButtons(0, 1, 1).
    set message1:text to "".
    set message2:text to "".
    set message3:text to "".
    set message1:style:textcolor to white.
    set message2:style:textcolor to white.
    set message3:style:textcolor to white.

    set executeconfirmed to false.
    set cancelconfirmed to false.
    set cancel:text to "<b>CANCEL</b>".
    set landbutton:pressed to false.
    set launchbutton:pressed to false.
    wait 0.001.
    set LandButtonIsRunning to false.
    set LaunchButtonIsRunning to false.
    wait 0.001.
    if Boosterconnected {
        HideEngineToggles(1).
    }
    else {
        HideEngineToggles(0).
    }
    wait 0.001.
    set launchlabel:style:textcolor to white.
    set launchlabel:style:bg to "starship_img/starship_background_dark".
    set landlabel:style:textcolor to white.
    set landlabel:style:bg to "starship_img/starship_background_dark".
    ShowButtons(1).
    LogToFile("Interface cleared").
}


function BackGroundUpdate {
    if not BGUisRunning {
        set BGUisRunning to true.
            updatestatusbar().
            if ship:crew:length <> 0 and not CrewOnboard {
                set CrewOnboard to true.
                crewbutton:show().
            }
            else if ship:crew:length = 0 {
                set CrewOnboard to false.
                crewbutton:hide().
                set crewbutton:pressed to false.
            }
            FindParts().
            if OLMexists {
                if Vessel("OrbitalLaunchMount"):distance < 500 and not LaunchButtonIsRunning and not LandButtonIsRunning {
                    towerbutton:show().
                }
                else {
                    towerbutton:hide().
                }
            }
            else if OnOrbitalMount and not LaunchButtonIsRunning and not LandButtonIsRunning {
                towerbutton:show().
            }
            else {
                towerbutton:hide().
            }
            if LaunchButtonIsRunning or LandButtonIsRunning or AttitudeIsRunning {
                maneuverbutton:hide().
            }
            else {
                if ship:status = "ORBITING" or ship:status = "ESCAPING" or ship:status = "SUB_ORBITAL" and apoapsis > 50000 or ship:status = "FLYING" and apoapsis > 50000 {
                    maneuverbutton:show().
                }
                else {
                    maneuverbutton:hide().
                }
            }
            if orbitbutton:pressed {updateOrbit().}
            if statusbutton:pressed {updateStatus().}
            if enginebutton:pressed {updateEnginePage().}
            if cargobutton:pressed {updateCargoPage().}
            if crewbutton:pressed {updateCrew().}
            if towerbutton:pressed {updateTower().}
            if maneuverbutton:pressed {updateManeuver().}
            SetPlanetData().
            wait 0.001.
        set BGUisRunning to false.
    }
}


function ShowButtons {
    parameter show.
    if show = 0 {
        launchbutton:hide().
        landbutton:hide().
        wait 0.1.
        launchlabel:show().
        landlabel:show().
    }
    if show = 1 {
        launchlabel:hide().
        landlabel:hide().
        wait 0.1.
        launchbutton:show().
        landbutton:show().
    }
}


function GoHome {
    set settingsbutton:pressed to false.
    set cargobutton:pressed to false.
    set statusbutton:pressed to false.
    set orbitbutton:pressed to false.
    set attitudebutton:pressed to false.
    set enginebutton:pressed to false.
    set crewbutton:pressed to false.
    set towerbutton:pressed to false.
    set maneuverbutton:pressed to false.
    mainbox:showonly(flightstack).
    LogToFile("Interface set to Main Screen").
}


function LogToFile {
    parameter msg.
    if quicksetting3:pressed {
        if homeconnection:isconnected {
            if msg = "Re-Entry Telemetry" {
                if defined PrevLogTimeLanding {
                    set TimeStep to 1.
                    if RadarAlt > 550 {set TimeStep to 1.}
                    else {set TimeStep to 0.25.}
                    if timestamp(time:seconds) > PrevLogTimeLanding + TimeStep {
                        if (landingzone:lng - ship:geoposition:lng) < -180 {
                            set LngDistanceToTarget to ((landingzone:lng - ship:geoposition:lng + 360) * Planet1Degree).
                            set LatDistanceToTarget to max(landingzone:lat - ship:geoposition:lat, ship:geoposition:lat - landingzone:lat) * Planet1Degree.
                            if LatDistanceToTarget < 0 {set LatDistanceToTarget to -1 * LatDistanceToTarget.}
                            set DistanceToTarget to sqrt(LngDistanceToTarget * LngDistanceToTarget + LatDistanceToTarget * LatDistanceToTarget).
                        }
                        else {
                            set LngDistanceToTarget to ((landingzone:lng - ship:geoposition:lng) * Planet1Degree).
                            set LatDistanceToTarget to max(landingzone:lat - ship:geoposition:lat, ship:geoposition:lat - landingzone:lat) * Planet1Degree.
                            if LatDistanceToTarget < 0 {set LatDistanceToTarget to -1 * LatDistanceToTarget.}
                            set DistanceToTarget to sqrt(LngDistanceToTarget * LngDistanceToTarget + LatDistanceToTarget * LatDistanceToTarget).
                        }
                        if altitude > 1500 {
                            if homeconnection:isconnected {
                                LOG ("Time: " + timestamp():clock + "   Dist: " + round(DistanceToTarget, 3) + "km   Alt: " + round(altitude) + "m   Vert Speed: " + round(ship:verticalspeed,1) + "m/s   Airspeed: " + round(airspeed, 1) + "m/s   Trk/X-Trk Error: " + round((LngLatErrorList[0] - LandingOffset) / 1000, 2) + "km  " + round((LngLatErrorList[1] / 1000), 2) + "km") to "0:/FlightData.txt".
                            }
                            if homeconnection:isconnected {
                                LOG ("                 Actual AoA: " + round(vang(ship:facing:forevector, velocity:surface), 1) + "°   Throttle: " + (100 * throttle) + "%   Battery: " + round(100 * (ship:electriccharge / ELECcap), 2) + "%   Mass: " + round(ship:mass * 1000, 3) + "kg") to "0:/FlightData.txt".
                            }
                            if homeconnection:isconnected {
                                LOG ("                 Radar Altitude: " + round(RadarAlt, 1) + "m") to "0:/FlightData.txt".
                            }
                            if homeconnection:isconnected {
                                LOG "" to "0:/FlightData.txt".
                            }
                            if homeconnection:isconnected {
                                LOG (timestamp():clock + "," + DistanceToTarget + "," + altitude + "," + ship:verticalspeed + "," + airspeed + "," + (LngLatErrorList[0] - LandingOffset) + "," + LngLatErrorList[1] + "," + vang(ship:facing:forevector, velocity:surface) + "," + (100 * throttle) + "," + (100 * (LFShip / LFShipCap)) + "," + (ship:mass * 1000) + "," + RadarAlt) to "0:/LandingData.csv".
                            }
                        }
                        else {
                            LOG ("Time: " + timestamp():clock + "   Dist: " + round(DistanceToTarget, 3) + "km   Alt: " + round(altitude) + "m   Vert Speed: " + round(ship:verticalspeed,1) + "m/s   Airspeed: " + round(airspeed, 1) + "m/s   Trk/X-Trk Error: " + round((LngLatErrorList[0] - LandingOffset) / 1000, 2) + "km  " + round((LngLatErrorList[1] / 1000), 2) + "km") to "0:/FlightData.txt".
                            LOG ("                 Actual AoA: " + round(vang(ship:facing:forevector, velocity:surface), 1) + "°   Throttle: " + (100 * throttle) + "%   Battery: " + round(100 * (ship:electriccharge / ELECcap), 2) + "%   Mass: " + round(ship:mass * 1000, 3) + "kg") to "0:/FlightData.txt".
                            LOG ("                 Radar Altitude: " + round(RadarAlt, 1) + "m") to "0:/FlightData.txt".
                            LOG "" to "0:/FlightData.txt".
                            LOG (timestamp():clock + "," + DistanceToTarget + "," + altitude + "," + ship:verticalspeed + "," + airspeed + "," + (LngLatErrorList[0] - LandingOffset) + "," + LngLatErrorList[1] + "," + vang(ship:facing:forevector, velocity:surface) + "," + (100 * throttle) + "," + (100 * (ship:electriccharge / ELECcap)) + "," + (ship:mass * 1000) + "," + RadarAlt) to "0:/LandingData.csv".
                        }
                        set PrevLogTimeLanding to timestamp(time:seconds).
                    }
                }
                else {
                    set PrevLogTimeLanding to timestamp(time:seconds).
                    if homeconnection:isconnected {
                        LOG "Time, Distance to Target (km), Altitude (m), Vertical Speed (m/s), Airspeed (m/s), Track Error (m), Cross-Track Error (m), Actual AoA (°), Throttle (%), Battery (%), Mass (kg), Radar Altitude" to "0:/LandingData.csv".
                    }
                }
            }
            else if msg = "Launch Telemetry" {
                if defined PrevLogTimeLaunch {
                    set TimeStep to 1.
                    if timestamp(time:seconds) > PrevLogTimeLaunch + TimeStep {
                        set DistanceToTarget to ((landingzone:lng - ship:geoposition:lng) * Planet1Degree).
                        LOG ("Time: " + timestamp():clock + "   Dist: " + round(DistanceToTarget, 3) + "km   Alt: " + round(altitude) + "m   Vert Speed: " + round(ship:verticalspeed,1) + "m/s   Airspeed: " + round(airspeed, 1) + "m/s   Trk/X-Trk Error: " + 0 + "km  " + 0 + "km") to "0:/FlightData.txt".
                        LOG ("                 Actual AoA: " + round(vang(ship:facing:forevector, velocity:surface), 1) + "°   Throttle: " + (100 * throttle) + "%   Battery: " + round(100 * (ship:electriccharge / ELECcap), 2) + "%   Mass: " + round(ship:mass * 1000, 3) + "kg") to "0:/FlightData.txt".
                        LOG ("                 Radar Altitude: " + round(RadarAlt,1) + "m") to "0:/FlightData.txt".
                        LOG "" to "0:/FlightData.txt".
                        LOG (timestamp():clock + "," + DistanceToTarget + "," + altitude + "," + ship:verticalspeed + "," + airspeed + "," + 0 + "," + 0 + "," + vang(ship:facing:forevector, velocity:surface) + "," + (100 * throttle) + "," + (100 * (ship:electriccharge / ELECcap)) + "," + (ship:mass * 1000) + "," + RadarAlt) to "0:/LaunchData.csv".
                        set PrevLogTimeLaunch to timestamp(time:seconds).
                    }
                }
                else {
                    set PrevLogTimeLaunch to timestamp(time:seconds).
                    LOG "Time, Distance to Target (km), Altitude (m), Vertical Speed (m/s), Airspeed (m/s), Track Error (m), Cross-Track Error (m), Actual AoA (°), Throttle (%), Battery (%), Mass (kg), Radar Altitude" to "0:/LaunchData.csv".
                }
            }
            else {
                if homeconnection:isconnected {
                    LOG "" to "0:/FlightData.txt".
                }
                if homeconnection:isconnected {
                    LOG "Time: " + timestamp():clock + "   " + msg to "0:/FlightData.txt".
                }
                if homeconnection:isconnected {
                    LOG "" to "0:/FlightData.txt".
                }
                if homeconnection:isconnected {
                    LOG "" to "0:/FlightData.txt".
                }
            }
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


function HideEngineToggles {
    parameter hide.
    if hide {
        set EngineTogglesHidden to true.
        enginecheckboxes:hide().
        set engine1label1:style:margin:left to 35.
        set engine2label1:style:margin:left to 35.
        set engine2label2:style:overflow:left to 131.
        set engine2label2:style:overflow:right to -70.
        set engine3label1:style:margin:left to 37.
        set engine3label2:style:align to "LEFT".
        set engine1label4:style:align to "RIGHT".
        set engine3label2:style:margin:left to 15.
        set engine3label4:style:margin:left to 35.
        set engine2label4:style:margin:left to 35.
        set engine2label4:style:overflow:left to -79.
        set engine2label4:style:overflow:right to 139.
        if Boosterconnected {
            set engine1label4:text to "".
            set engine2label3:style:overflow:left to 23.
            set engine2label3:style:overflow:right to 43.
            set engine2label3:style:overflow:top to 8.
            set engine2label3:style:overflow:bottom to 71.
        }
        else {
            set engine2label3:style:overflow:left to 65.
            set engine2label3:style:overflow:right to 65.
            set engine2label3:style:overflow:top to -5.
            set engine2label3:style:overflow:bottom to 55.
            if NrOfVacEngines = 6 {
                set engine2label3:style:bg to "starship_img/starship_9engine_none_active".
            }
            if NrOfVacEngines = 3 {
                set engine2label3:style:bg to "starship_img/starship_6engine_none_active".
            }
            set engine1label4:text to "-".
        }
    }
    else {
        set EngineTogglesHidden to false.
        enginecheckboxes:show().
        set engine1label1:style:margin:left to 5.
        set engine2label1:style:margin:left to 10.
        set engine2label2:style:overflow:left to 110.
        set engine2label2:style:overflow:right to -50.
        set engine3label1:style:margin:left to 8.
        set engine3label2:style:align to "CENTER".
        set engine3label2:style:margin:left to 5.
        set engine3label4:style:margin:left to 0.
        set engine2label4:style:margin:left to 20.
        set engine2label3:style:overflow:left to 65.
        set engine2label3:style:overflow:right to 65.
        set engine2label3:style:overflow:top to -5.
        set engine2label3:style:overflow:bottom to 55.
        set engine2label4:style:overflow:left to -50.
        set engine2label4:style:overflow:right to 110.
        set engine1label4:text to "-".
        set engine1label4:style:align to "LEFT".
    }
}


function TotalCargoMass {
    if not CargoCalculationIsRunning {
        set CargoCalculationIsRunning to true.
        if ship:dockingports[0]:haspartner {
            set CargoCalculationIsRunning to false.
            return list(0, 0, 0).
        }
        else {
            set CargoList to ship:parts.
            set CargoList to CargoList:copy.
            set CargoMass to 0.
            set ShipMass to 0.
            set CargoCoG to 0.

            if Boosterconnected {
                if BoosterEngines:length > 0 {
                    CargoList:remove(CargoList:find(BoosterEngines[0])).
                    CargoList:remove(CargoList:find(BoosterInterstage[0])).
                    CargoList:remove(CargoList:find(BoosterCore[0])).
                    for fin in GridFins {
                        CargoList:remove(CargoList:find(fin)).
                    }
                }
            }
            if OnOrbitalMount {
                if SHIP:PARTSNAMED("SLE.SS.OLP"):length > 0 {
                    CargoList:remove(CargoList:find(SHIP:PARTSNAMED("SLE.SS.OLP")[0])).
                    CargoList:remove(CargoList:find(SHIP:PARTSNAMED("SLE.SS.OLIT.Base")[0])).
                    CargoList:remove(CargoList:find(SHIP:PARTSNAMED("SLE.SS.OLIT.Core")[0])).
                    CargoList:remove(CargoList:find(SHIP:PARTSNAMED("SLE.SS.OLIT.Top")[0])).
                    CargoList:remove(CargoList:find(SHIP:PARTSNAMED("SLE.SS.OLIT.MZ")[0])).
                }
            }

            for x in CargoList {
                set ShipMass to ShipMass + (x:mass * 1000).
            }

            CargoList:remove(CargoList:find(FLflap[0])).
            CargoList:remove(CargoList:find(FRflap[0])).
            CargoList:remove(CargoList:find(ALflap[0])).
            CargoList:remove(CargoList:find(ARflap[0])).
            CargoList:remove(CargoList:find(Tank[0])).
            CargoList:remove(CargoList:find(Nose[0])).
            CargoList:remove(CargoList:find(HeaderTank[0])).
            for eng in SLEngines {
                CargoList:remove(CargoList:find(eng)).
            }
            for eng in VACEngines {
                CargoList:remove(CargoList:find(eng)).
            }

            if ShipType = "Cargo" or ShipType = "Crew" {
                for x in CargoList {
                    set CargoMass to CargoMass + (x:mass * 1000).
                    set CargoCoG to CargoCoG + vdot(x:position - Tank[0]:position, facing:forevector) * x:mass.
                }
            }

            if ShipType = "Tanker" {
                set CargoMass to CargoMass + 1000 * (Nose[0]:mass - Nose[0]:drymass).
                //set CargoMass to CargoMass + 1000 * (Tank[0]:mass - Tank[0]:drymass).
            }
            set Cargo to CargoMass.
            set CargoCG to CargoCoG.
        }
        set CargoCalculationIsRunning to false.
        return list(CargoMass, CargoList:length, CargoCoG).
    }
}


function updateCargoPage {
    if not CargoPageIsRunning {
        set CargoPageIsRunning to true.
        if time:seconds > prevCargoPageTime + 0.1 {
            local CargoList is TotalCargoMass().
            if CargoList[1] = 0 {
                set cargo1label2:style:textcolor to grey.
                set cargo2label2:style:textcolor to grey.
                set cargo3label2:style:textcolor to grey.
                set cargo2label2:text to "-".
                set cargo3label2:text to "-".
            }
            else {
                set cargo1label2:style:textcolor to white.
                set cargo2label2:style:textcolor to white.
                set cargo3label2:style:textcolor to white.
                set cargo2label2:text to round(CargoList[0]) + " kg".
                if CargoList[1] = 1 {
                    set cargo3label2:text to "1 Item<size=14> (" + round(CargoList[2]) + "i.u.)</size>".
                }
                else {
                    if Boosterconnected {
                        set cargo3label2:text to CargoList[1] + " Items".
                    }
                    else {
                        if CargoList[2] > 100 {
                            set cargo3label2:text to CargoList[1] + " Items<size=12> (" + round(CargoList[2]) + "i.u.)</size>".
                        }
                        else {
                            set cargo3label2:text to CargoList[1] + " Items<size=14> (" + round(CargoList[2]) + "i.u.)</size>".
                        }
                    }
                }
            }
            set prevCargoPageTime to time:seconds.
        }
        set CargoPageIsRunning to false.
    }
}


function updateTower {
    if not towerPageIsRunning {
        set towerPageIsRunning to true.
        if OLMexists() or SHIP:PARTSNAMED("SLE.SS.OLP"):length > 0 {
            if SHIP:PARTSNAMED("SLE.SS.OLP"):length > 0 {
                if homeconnection:isconnected {
                    if exists("0:/settings.json") {
                        set L to readjson("0:/settings.json").
                        if L:haskey("Tower:arms:rotation") {
                            set tower4label2:text to "<b>" + round(L["Tower:arms:rotation"], 1):tostring + "/" + towerrot + "°</b>".
                            set tower4label3:text to "<b>" + round(L["Tower:arms:angle"], 1):tostring + "/" + towerang + "°</b>".
                            set tower4label4:text to "<b>" + round(65 - L["Tower:arms:height"], 1):tostring + "/" + towerhgt + "m</b>".
                            set tower12label2:text to "<b>" + round(L["Tower:pushers:extension"], 2):tostring + "/" + towerpushfwd + "m</b>".
                            if towerstab = 0 {
                                set tower12label3:text to "<b>STOWED</b>".
                            }
                            else {
                                set tower12label3:text to "<b>ACTIVE</b>".
                            }
                        }
                    }
                }
            }
            else if Vessel("OrbitalLaunchMount"):distance < 500 {
                if homeconnection:isconnected {
                    if exists("0:/settings.json") {
                        set L to readjson("0:/settings.json").
                        if L:haskey("Tower:arms:rotation") {
                            set tower4label2:text to "<b>" + round(L["Tower:arms:rotation"], 1):tostring + "/" + towerrot + "°</b>".
                            set tower4label3:text to "<b>" + round(L["Tower:arms:angle"], 1):tostring + "/" + towerang + "°</b>".
                            set tower4label4:text to "<b>" + round(65 - L["Tower:arms:height"], 1):tostring + "/" + towerhgt + "m</b>".
                            set tower12label2:text to "<b>" + round(L["Tower:pushers:extension"], 2):tostring + "/" + towerpushfwd + "m</b>".
                            if L["Tower:Stabilizers:extension"] = 0 {
                                set tower12label3:text to "<b>STOWED</b>".
                            }
                            else {
                                set tower12label3:text to "<b>ACTIVE</b>".
                            }
                        }
                    }
                }
            }
        }
        set towerPageIsRunning to false.
    }
}


function SetRadarAltitude {
    if ship:rootpart = "SEP.S20.CREW" or ship:rootpart = "SEP.S20.CARGO" or ship:rootpart = "SEP.S20.TANKER" {
        set ShipBottomRadarHeight to 24.698.
    }
    else {
        set ShipBottomRadarHeight to 9.15.
    }
    lock RadarAlt to altitude - ship:geoposition:terrainheight - ShipBottomRadarHeight.
}


function SetPlanetData {
    if ship:body = BODY("Kerbin") {
        set aoa to 67.
        set Planet1Degree to 10.471975.
    }
    else if ship:body = BODY("Duna") {
        set aoa to 60.
        set Planet1Degree to 5.585053.
    }
    else {
        set aoa to 67.
        set Planet1Degree to 10.471975.
    }
    set Planet1G to CONSTANT():G * (ship:body:mass / (ship:body:radius * ship:body:radius)).
}


function CheckSlope {
    parameter NoTarget.
    set IsLandingZoneOkay to false.
    set SuggestedLZ to landingzone.
    set OffsetTargetLat to 0.
    set OffsetTargetLng to 0.
    set NewOffsetTargetLat to 0.
    set NewOffsetTargetLng to 0.
    set iteration to 0.
    set number to 0.
    set targetLZheight to landingzone:terrainheight.
    set StepDistance to 50 / (1000 * Planet1Degree).
    set IsOriginalTarget to false.
    set LowestSlopeDictionary to lexicon().
    set multiplier to 2.

    until IsLandingZoneOkay or cancelconfirmed {
        if ClosingIsRunning or cancelconfirmed or NoTarget and iteration > 5 {
            break.
        }
        set heightWest to latlng(landingzone:lat + OffsetTargetLat, landingzone:lng + OffsetTargetLng - StepDistance):terrainheight.
        set heightEast to latlng(landingzone:lat + OffsetTargetLat, landingzone:lng + OffsetTargetLng + StepDistance):terrainheight.
        set heightNorth to latlng(landingzone:lat + OffsetTargetLat + StepDistance, landingzone:lng + OffsetTargetLng):terrainheight.
        set heightSouth to latlng(landingzone:lat + OffsetTargetLat - StepDistance, landingzone:lng + OffsetTargetLng):terrainheight.
        set targetLZheight to latlng(landingzone:lat + OffsetTargetLat, landingzone:lng + OffsetTargetLng):terrainheight.
        set SlopeWest to arctan((heightWest - targetLZheight) / (StepDistance * 1000 * Planet1Degree)).
        set SlopeEast to arctan((heightEast - targetLZheight) / (StepDistance * 1000 * Planet1Degree)).
        set SlopeNorth to arctan((heightNorth - targetLZheight) / (StepDistance * 1000 * Planet1Degree)).
        set SlopeSouth to arctan((heightSouth - targetLZheight) / (StepDistance * 1000 * Planet1Degree)).
        //clearscreen.
        //print "iteration: " + iteration.
        //print "number: " + number.
        //print latlng(landingzone:lat + OffsetTargetLat, landingzone:lng + OffsetTargetLng).
        //print "Max Upslope: " + max(max(max(SlopeWest, SlopeEast), SlopeNorth), SlopeSouth).
        //print "Max Downslope: " + min(min(min(SlopeWest, SlopeEast), SlopeNorth), SlopeSouth).
        //print "Max Slope: " + max(max(max(max(SlopeWest, SlopeEast), SlopeNorth), SlopeSouth), -1 * min(min(min(SlopeWest, SlopeEast), SlopeNorth), SlopeSouth)).
        //print "LatOffset: " + OffsetTargetLat.
        //print "LngOffset: " + OffsetTargetLng.
        //print "StepDistance: " + StepDistance.
        //print "Slope to West: " + SlopeWest.
        //print "Slope to East: " + SlopeEast.
        //print "Slope to North: " + SlopeNorth.
        //print "Slope to South: " + SlopeSouth.
        //print "Target Height: " + TargetLZheight.
        //print heightWest.
        //print heightEast.
        //print heightNorth.
        //print heightSouth.

        if SlopeWest > MaxTilt or SlopeWest < -MaxTilt or SlopeEast > MaxTilt or SlopeEast < -MaxTilt or SlopeNorth > MaxTilt or SlopeNorth < -MaxTilt or SlopeSouth > MaxTilt or SlopeSouth < -MaxTilt {
            if OffsetTargetLat = iteration * multiplier * StepDistance and OffsetTargetLng = iteration * -multiplier * StepDistance and number > 1 {
                set iteration to iteration + 1.
                set number to 0.
                set OffsetTargetLat to iteration * multiplier * StepDistance.
                set OffsetTargetLng to iteration * -multiplier * StepDistance.
            }
            else {
                set number to number + 1.
                set NewOffsetTargetLat to OffsetTargetLat.
                set NewOffsetTargetLng to OffsetTargetLng.
                if round(OffsetTargetLat, 4) = round(iteration * multiplier * StepDistance, 4) {
                    if round(OffsetTargetLng, 4) = round(iteration * multiplier * StepDistance, 4) {}
                    else {
                        set NewOffsetTargetLng to OffsetTargetLng + multiplier * StepDistance.
                    }
                }
                if round(OffsetTargetLng, 4) = round(iteration * multiplier * StepDistance, 4) {
                    if round(OffsetTargetLat, 4) = round(iteration * -multiplier * StepDistance, 4) {}
                    else {
                        set NewOffsetTargetLat to OffsetTargetLat - multiplier * StepDistance.
                    }
                }
                if round(OffsetTargetLat, 4) = round(iteration * -multiplier * StepDistance, 4) {
                    if round(OffsetTargetLng, 4) = round(iteration * -multiplier * StepDistance, 4) {}
                    else {
                        set NewOffsetTargetLng to OffsetTargetLng - multiplier * StepDistance.
                    }
                }
                if round(OffsetTargetLng, 4) = round(iteration * -multiplier * StepDistance, 4) {
                    if round(OffsetTargetLat, 4) = round(iteration * multiplier * StepDistance, 4) {}
                    else {
                        set NewOffsetTargetLat to OffsetTargetLat + multiplier * StepDistance.
                    }
                }
                if NoTarget {
                    set Slope to max(max(max(max(SlopeWest, SlopeEast), SlopeNorth), SlopeSouth), -1 * min(min(min(SlopeWest, SlopeEast), SlopeNorth), SlopeSouth)).
                    LowestSlopeDictionary:add(((landingzone:lat + OffsetTargetLat) + "," + (landingzone:lng + OffsetTargetLng)), Slope).
                }
                if number > 0 {
                    set OffsetTargetLat to NewOffsetTargetLat.
                    set OffsetTargetLng to NewOffsetTargetLng.
                }
                if number > iteration * 8 {
                    set iteration to iteration + 1.
                    set number to 0.
                    set OffsetTargetLat to iteration * multiplier * StepDistance.
                    set OffsetTargetLng to iteration * -multiplier * StepDistance.
                }
            }
        }
        else {
            set IsLandingZoneOkay to true.
            set SuggestedLZ to latlng(round(landingzone:lat + OffsetTargetLat, 4), round(landingzone:lng + OffsetTargetLng, 4)).
        }
        set Slope to max(max(max(max(SlopeWest, SlopeEast), SlopeNorth), SlopeSouth), -1 * min(min(min(SlopeWest, SlopeEast), SlopeNorth), SlopeSouth)).
        set DistanceFromTargetLZ to sqrt((OffsetTargetLat * 1000 * Planet1Degree) * (OffsetTargetLat * 1000 * Planet1Degree) + (OffsetTargetLng * 1000 * Planet1Degree) * (OffsetTargetLng * 1000 * Planet1Degree)).
        set SlopeAzimuth to vang(latlng(landingzone:lat + OffsetTargetLat, landingzone:lng + OffsetTargetLng):position - landingzone:position, north:vector).
        if OffsetTargetLng < 0 {
            set SlopeAzimuth to 360 - SlopeAzimuth.
        }
        set message3:text to "<b>Distance:</b>  " + round(DistanceFromTargetLZ) + "m     <b>Slope:</b>  <color=red>" + round(Slope, 1) + "°</color>     <b>Az:</b>  " + round(SlopeAzimuth) + "°".
    }
    if NoTarget and not IsLandingZoneOkay {
        set LowestSlopeFound to 90.
        for pos in LowestSlopeDictionary:keys {
            if LowestSlopeDictionary[pos] < LowestSlopeFound {
                set LowestSlopeFound to LowestSlopeDictionary[pos].
                set LowestSlopeLZ to pos.
            }
        }
        set LowestSlopeLZ to LowestSlopeLZ:split(",").
        set SuggestedLZ to latlng(round(LowestSlopeLZ[0]:toscalar, 4), round(LowestSlopeLZ[1]:toscalar, 4)).
        print "Suggested LZ: " + SuggestedLZ + "   Slope: " + round(Slope, 1).
    }
    if landingzone:lat = SuggestedLZ:lat and landingzone:lng = SuggestedLZ:lng {
        set IsOriginalTarget to true.
    }
    set LZAlt to SuggestedLZ:terrainheight.
    //clearscreen.
    return list(IsOriginalTarget, SuggestedLZ, DistanceFromTargetLZ, Slope, LZAlt).
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


function ShipsInOrbit {
    list targets in shiplist.
    set ShipsInOrbitList to list().
    if shiplist:length > 0 {
        for x in shiplist {
            if x:status = "ORBITING" {
                if x:name:length > 12 {
                    if (x:name:substring(0, 13)) = "Starship Crew" and x:body = Body("Kerbin") and x:orbit:apoapsis < 77500 and x:orbit:periapsis > 72500 {
                        ShipsInOrbitList:add(Vessel(x:name)).
                    }
                }
                if x:name:length > 13 {
                    if (x:name:substring(0, 14)) = "Starship Cargo" and x:body = Body("Kerbin") and x:orbit:apoapsis < 77500 and x:orbit:periapsis > 72500 {
                        ShipsInOrbitList:add(Vessel(x:name)).
                    }
                }
                if x:name:length > 14 {
                    if (x:name:substring(0, 15)) = "Starship Tanker" and x:body = Body("Kerbin") and x:orbit:apoapsis < 77500 and x:orbit:periapsis > 72500 {
                        ShipsInOrbitList:add(Vessel(x:name)).
                    }
                }
                if x:name = ship:name {
                    for y in range(SNStart, 10000) {
                        set ship:name to ship:name + " (S" + y + ")".
                        if x:name = ship:name {
                            set y to y + 1.
                        }
                        else {
                            break.
                        }
                    }
                }
            }
        }
    }
    return ShipsInOrbitList.
}


function LandingZoneFinder {
    if setting3:text = "-0.0972,-74.5577" and ship:body = BODY("Kerbin") or setting3:text = "-6.5604,-143.95" and ship:body = BODY("Kerbin") {
        set AvailableLandingSpots to list(true, landingzone, 0, 0).
    }
    else {
        set message1:text to "<b>Error: Landing Zone Slope too steep!</b>".
        set message1:style:textcolor to yellow.
        set message2:text to "<b>Looking for suitable Landing Zones..</b>".
        set message3:text to "<b>This may take a while..</b>".
        InhibitButtons(0, 1, 0).
        set AvailableLandingSpots to CheckSlope(0).
        set message1:text to "".
        set message2:text to "".
        set message3:text to "".
        set message1:style:textcolor to white.
        if AvailableLandingSpots[0] = true {}
        else {
            set message1:text to "<b>Suggested Landing Zone:</b>  <color=yellow>" + round(AvailableLandingSpots[1]:lat, 4) + "," + round(AvailableLandingSpots[1]:lng, 4) + "</color>".
            set message2:text to "<b>Distance:  </b><color=yellow>" + round(AvailableLandingSpots[2]) + "m away</color>      <b>Slope:  </b><color=yellow>" + round(AvailableLandingSpots[3],1) + "°</color>".
            if quicksetting1:pressed {
                set message3:text to "<b>Execute <color=white>or</color> Cancel?</b>  <color=yellow>(Auto-Warp enabled)</color>".
            }
            else {
                set message3:text to "<b>Execute <color=white>or</color> Cancel?</b>".
            }
            set message3:style:textcolor to cyan.
            InhibitButtons(0, 0, 0).
            if confirm() {
                LogToFile("Flatter Landing Zone found and accepted!").
                set landingzone to AvailableLandingSpots[1].
                addons:tr:settarget(landingzone).
                SaveToSettings("Landing Coordinates", (round(landingzone:lat, 4) + "," + round(landingzone:lng, 4)):tostring).
                set setting3:text to (round(landingzone:lat, 4) + "," + round(landingzone:lng, 4)):tostring.
            }
            else {
                LogToFile("Landing Zone Finder Function cancelled").
                set message1:text to "".
                set message3:text to "".
            }
        }
    }
}


function CheckLZReachable {
    set LngLatErrorList to LngLatError().
    if ship:body = BODY("Kerbin") {
        if LngLatErrorList[0] - LandingOffset > 1000 or LngLatErrorList[0] - LandingOffset < -1000 or LngLatErrorList[1] > 500 or LngLatErrorList[1] < -500 or FacingTheWrongWay {
            set impactpos to addons:tr:impactpos.
            set landingzone to latlng(impactpos:lat, impactpos:lng).
            sas on.
            set AvailableLandingSpots to CheckSlope(1).
            set FindNewTarget to true.
            sas off.
            set landingzone to AvailableLandingSpots[1].
            addons:tr:settarget(landingzone).
        }
        LogToFile("Kerbin Automated Landing Activated").
    }
    if ship:body = BODY("Duna") {
        if LngLatErrorList[0] - LandingOffset > 1000 or LngLatErrorList[0] - LandingOffset < -1000 or LngLatErrorList[1] > 500 or LngLatErrorList[1] < -500 or FacingTheWrongWay {
            set impactpos to addons:tr:impactpos.
            set landingzone to latlng(impactpos:lat, impactpos:lng).
            sas on.
            set AvailableLandingSpots to CheckSlope(1).
            set FindNewTarget to true.
            sas off.
            set landingzone to AvailableLandingSpots[1].
            addons:tr:settarget(landingzone).
        }
        LogToFile("Duna Automated Landing Activated").
    }
    set runningprogram to "Landing".
}


function updateManeuver {
    if not ManeuverPageIsRunning {
        set ManeuverPageIsRunning to true.
        if time:seconds > prevTargetFindingTime + 5 {
            list targets in targetlist.
            if targetlist:length > 0 {
                TargetPicker:clear().
                set TargetPicker:options to list("<color=grey><b>Select Target</b></color>").
                for x in targetlist {
                    if x:status = "ORBITING" and x:distance < 10000 {
                        TargetPicker:addoption(x:name).
                    }
                }
            }
            set prevTargetFindingTime to time:seconds.
        }
        if hastarget and TargetSelected and ManeuverPicker:text = "<b><color=white>Auto-Dock</color></b>" {
            if target:distance < 2000 {
                set maneuver3label1:text to "<b>Distance:  </b>" + round((target:dockingports[0]:nodeposition - ship:dockingports[0]:nodeposition):mag, 2) + "m".
                set maneuver3label2:text to "<b>Rel. Velocity:  </b>" + round((target:velocity:orbit - ship:velocity:orbit):mag, 2) + "m/s".
                set maneuver3label3:text to "".
            }
            else {
                set maneuver3label1:text to "<b>Distance:  </b>" + round(target:distance, 2) + "m".
                set maneuver3label2:text to "<b>Rel. Velocity:  </b>" + round((target:velocity:orbit - ship:velocity:orbit):mag, 2) + "m/s".
                set maneuver3label3:text to "".
            }
        }
        set ManeuverPageIsRunning to false.
    }
}


function PerformBurn {
    parameter Burntime, ProgradeVelocity, AlreadyHasNode.
    if AlreadyHasNode {

    }
    else {
        set burn to node(timespan(BurnTime), 0, 0, ProgradeVelocity).
        add burn.
    }
    set burnstart to nextnode:deltav.
    set burnstarttime to timestamp(time:seconds + BurnTime).
    lock deltaV to nextnode:deltav:mag.
    if deltaV < 50 {
        lock MaxAccel to 40/ship:mass.
        set UseRCSforBurn to true.
    }
    else {
        lock MaxAccel to (VACEngines[0]:possiblethrust * NrOfVacEngines) / ship:mass.
        set UseRCSforBurn to false.
    }
    lock BurnAccel to min(19.62, MaxAccel).
    lock BurnDuration to deltaV / BurnAccel.
    GoHome().
    set runningprogram to "Input".
    if AlreadyHasNode {
        set message1:text to "<b>Execute Custom Burn:</b>".
    }
    else {
        set message1:text to "<b>Circularize at Altitude:</b>  <color=yellow>" + round(((positionat(ship, burnstarttime) - ship:body:position):mag - ship:body:radius) / 1000, 1) + "km</color>".
    }
    set message2:text to "<b>@:</b>  " + burnstarttime:hour + ":" + burnstarttime:minute + ":" + burnstarttime:second + "<b>UT</b>   <b>ΔV:</b>  " + round(DeltaV, 1) + "m/s".
    set message3:style:textcolor to cyan.
    if quicksetting1:pressed {
        set message3:text to "<b>Execute <color=white>or</color> Cancel?</b>  <color=yellow>(Auto-Warp enabled)</color>".
    }
    else {
        set message3:text to "<b>Execute <color=white>or</color> Cancel?</b>".
    }
    InhibitButtons(0, 0, 0).
    if confirm() {
        LogToFile("Re-orienting for Burn").
        InhibitButtons(1, 1, 0).
        ShowButtons(0).
        if not (KUniverse:activevessel = vessel(ship:name)) {
            set KUniverse:activevessel to vessel(ship:name).
        }
        set message3:style:textcolor to white.
        set runningprogram to "Performing Burn".
        HideEngineToggles(1).
        Nose[0]:getmodule("ModuleRCSFX"):SetField("thrust limiter", 100).
        Tank[0]:getmodule("ModuleRCSFX"):SetField("thrust limiter", 100).
        sas off.
        rcs off.
        lock steering to lookdirup(nextnode:burnvector, ship:facing:topvector).
        if quicksetting1:pressed and nextnode:eta - 0.5 * BurnDuration > 120 {
            set kuniverse:timewarp:warp to 4.
        }
        if quicksetting1:pressed and nextnode:eta - 0.5 * BurnDuration > 900 {
            set kuniverse:timewarp:warp to 5.
        }
        until nextnode:eta < 0.5 * BurnDuration or cancelconfirmed and not ClosingIsRunning {
            BackGroundUpdate().
            if quicksetting1:pressed and kuniverse:timewarp:warp = 5 and nextnode:eta - 0.5 * BurnDuration < 900 or nextnode:eta - 0.5 * BurnDuration < 900 and kuniverse:timewarp:warp = 5 {
                set kuniverse:timewarp:warp to 4.
            }
            if quicksetting1:pressed and kuniverse:timewarp:warp = 6 and nextnode:eta - 0.5 * BurnDuration < 5400 or nextnode:eta - 0.5 * BurnDuration < 5400 and kuniverse:timewarp:warp = 6 {
                set kuniverse:timewarp:warp to 5.
            }
            if nextnode:eta - 0.5 * BurnDuration < 60 {
                set kuniverse:timewarp:warp to 0.
                rcs on.
            }
            else {rcs off.}
            set message1:text to "<b>Starting Burn in:</b>  " + timeSpanCalculator(nextnode:eta - 0.5 * BurnDuration).
            set message2:text to "<b>Target Attitude:</b>    Burnvector".
            set message3:text to "<b>Burn Duration:</b>      " + round(BurnDuration) + "s".
        }
        if hasnode {
            if vang(nextnode:burnvector, ship:facing:forevector) < 2 and cancelconfirmed = false {
                LogToFile("Starting Burn").
                if UseRCSforBurn {
                }
                else {
                    set quickengine3:pressed to true.
                }
                until vdot(facing:forevector, nextnode:deltav) < 0 or cancelconfirmed = true and not ClosingIsRunning {
                    BackGroundUpdate().
                    if vang(facing:forevector, nextnode:burnvector) < 5 {
                        if UseRCSforBurn {
                            rcs on.
                            set ship:control:translation to v(0, 0, 1).
                            set ship:control:rotation to v(0, 0, 0).
                        }
                        else {
                            set throttle to min(nextnode:deltav:mag / MaxAccel, BurnAccel / MaxAccel).
                        }
                    }
                    if nextnode:deltav:mag > 5 {
                        set steering to lookdirup(nextnode:burnvector, ship:facing:topvector).
                    }
                    set kuniverse:timewarp:warp to 0.
                    set message1:text to "<b>Performing Burn..</b>".
                    set message3:text to "<b>Burn Duration:</b>      " + round(BurnDuration) + "s".
                }
                if UseRCSforBurn {
                    rcs off.
                    set ship:control:translation to v(0, 0, 0).
                    set ship:control:rotation to v(0, 0, 0).
                }
                else {
                    set quickengine3:pressed to false.
                }
                remove nextnode.
                sas on.
                set throttle to 0.
                unlock steering.
                HideEngineToggles(0).
                rcs off.
                LogToFile("Stopping Burn").
                ClearInterfaceAndSteering().
                return.
            }
            else if not cancelconfirmed {
                remove nextnode.
                set throttle to 0.
                unlock steering.
                unlock throttle.
                sas on.
                HideEngineToggles(0).
                ClearInterfaceAndSteering().
                LogToFile("Stopping Burn due to wrong orientation").
                set message1:text to "<b>Burn Cancelled.</b>".
                set message1:style:textcolor to yellow.
                set message2:text to "<b>Incorrect orientation or stopped..</b>".
                set message2:style:textcolor to yellow.
                wait 1.
            }
            else {
                ClearInterfaceAndSteering().
                HideEngineToggles(0).
                set throttle to 0.
                rcs off.
                sas on.
                LogToFile("Stopping Burn due to user cancellation").
            }
        }
        else {
            set throttle to 0.
            rcs off.
            sas on.
            HideEngineToggles(0).
            LogToFile("Stopping Burn due to loss of node").
            ClearInterfaceAndSteering().
        }
    }
    else {
        LogToFile("Stopping Burn").
        ClearInterfaceAndSteering().
    }
}
