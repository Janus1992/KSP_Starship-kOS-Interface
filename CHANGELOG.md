# V2.4.5 (2024-07-25)
- Fixes for overnight SLE changes.

# V2.4.4 (2024-07-24)
- Rotated SteelPlate for stock/KSRSS crafts.
- Modified OrbitalLaunchMount craft to have opened arms/SQD.

# V2.4.3 (2024-07-23)
- Reworked the Duna landings on stock/KSRSS/RSS.
- Slight change in engine shutdown on landing. Engines only shutting down when absolutely necessary.
- Calibrated stock ship catches, as my landings were falling short by a few meters after the recent changes.
- Parts and crafts updated to work with the latest SLE dev, including the SQD and steel plate.
- I'm not copying the SLE parts anymore, as I can nearly use SLE by default now.
- Fix for SLE deluge effects.

# V2.4.2 (2024-07-10)
- Took out selecting a target during re-entry again. Too unreliable for now.
- Beginning of duna-landing overhaul. Currently not working.
- Fix for cancelled launches with Booster 9 selected.

# V2.4.1 (2024-07-09)
- Fixes for booster landings. Crafts didn't use Booster 9 Variant, which is important for accurate landings. Built in function to not allow launches with boosters other than B9.
- Arms are more opened up initially prior to catch. To avoid the ship landing on top of them.
- New ability to select an OLM as landing target during re-entry.

# V2.4.0 (2024-07-08)
- Ship landing now steeper (75-80 degrees AoA) at the cost of some lateral control.
- Hopefully fixed failing booster catches.
    - Still not sure why some people have a Landing Ratio of 1.3 and increasing..
- More accurate tower arms rotation during catches.
- Fixed a bug where the tower would not be properly initialized and the arms don't open to catch the ship.
- Many changes in the background. Stability will be impacted with this release and bugs are to be expected.

# V2.3.39 (2024-06-25)
- Craft files fixed for bug which caused the ship to lose integrity on relaunching (after catch and restack).
- Depot craft HSR clamp switch set to HSR6.
- Booster final guidance dampened a bit.
- Active target tracking during launch to intercept orbit.
- Ship landing tweaks.

# V2.3.38 (2024-06-21)
- Single Raptor De-orbit burn.
- Wobbly Tower detection reactivated and tweaked.

# V2.3.37 (2024-06-20)
- Auto-docking receives some more love:
    - More accurate final docking.
    - Trying to catch the node error and avoid docking into nowhere. It now gives a warning and terminates the auto-docking.
    - Cancelling velocity upon cancelling the maneuver.
    - Depot auto-docking disabled due to weak RCS authority.
    - Fixed some crashes due to loss of target on dock.
    - Auto-select first suitable target in the popup menu.
    - New Safe-Vectors on every side of the target. Script picks the closest.

# V2.3.36 (2024-06-19)
- Even more agressive booster landing burn.
- IFT-4 fixes.
- Improved rolling for the tower catch to match the towers orientation.
- Kraken mitigations:
    - Tower rotates the mechazilla arms with Booster and Ship on catch.
    - Wobbly Tower bug detected and alternate landingzone will be selected.
    - Booster swinging (not stable) detected, and tower procedure for recovery will wait until the error is small enough not to cause destruction in most cases.
    - Booster CPU shuts down on error during recovery.
    - Tower top gets a built-in invisible Clamp too.
- Auto-docking:
    - Possible fix for docking to nowhere.
    - Faster and smoother final docking.
    - other small changes.
- Fixed craft file for Depot. Engines were missing, resulting in an Interface crash.

# V2.3.35 (2024-06-12)
- Stage SEP maneuver is more closely approximating the IFT 4 procedure now.
- Small fixes.
- Added KSPCF as a dependency. It fixes booster landings now that the HSR is a separate part.
- FAR is not supported anymore. It's stupid.

# V2.3.34 (2024-06-11)
- IFT-4 improvements:
    - Use of SL engines for Ships final orbit completion.
    - Use of 3 center engines for the end of Boosters boostback burn.
    - Less gliding of the booster.
    - Way more aggressive booster landing burn.

# V2.3.33 (2024-06-07)
- Re-entry final steering sharpened.
- Landing flip changes.
- KSRSS LZ changed.

# V2.3.32 (2024-05-24)
- FAR support broken.
- new HSR part has been integrated.

# V2.3.31 (2024-05-23)
- Initial FAR support. Needs the very latest SEP dev.
- Experimental booster catch slower deceleration if it is too far from the tower at a Radar Altitude of less than 300m. May fail, couldn't test yet.

# V2.3.30 (2024-05-21)
- Fixed a refueling issue that mainly happens on KSRSS.
- Add invisible clamp to Tower Base.
- reset pitch trim when cancelling a program.

# V2.3.29 (2024-05-20)
- Prevent venting of the header tank (due to unforeseen changes in fuel priority) by disabling the tank momentarily.
- Change heat properties of the OLM to prevent long-term overheating.
- Launch initial pitch reset to 90.
- Fixed some craft files fuel priority.
- Added a check before engaging auto-docking to ask if QD docking mode has been set on both vehicles.

# V2.3.28 (2024-05-19)
- Fuel vent fixes.

# V2.3.27 (2024-05-05)
- I got married yesterday!
- Changed the optional patch and it's wording on github. It's actually the combination of Kopernicus and a stock Kerbin that causes some fuel tank issues. Using Parallax is just one situation that requires Kopernicus to be installed on a stock Kerbin.

# V2.3.26 (2024-04-26)
- Built in a check for simultaneously having LF and Lqdmethane on board and then stopping the interface from working.

# V2.3.25 (2024-04-11)
- Booster LZ fix when no connection is available when queried.
- Ship/Tower naming bugs fixed.
- Expendable Ship bug fixed.
- 1 Degree pitch over on launch clamp release.
- Trial: Clamp tower to the ground.

# V2.3.24 (2024-04-01)
- fixed the optional patch for parallax on a stock Kerbin.
- tiny XyphosAerospace patch fix.

# V2.3.23 (2024-03-20)
- New caution message warning for the IVA stage sep bug.

# V2.3.22 (2024-03-13)
- Added support for AECS Motion Suppressor.

# V2.3.21 (2024-02-14)
- Hopefully avoid too early renaming of the tower causing the ship to be renamed too.
- Built in safeguard against starship having an OLM name during launch.

# V2.3.20 (2024-02-13)
- Provide warning when kOS start-on-archive was active and the scene needs to be reloaded.

# V2.3.19 (2024-02-12)
- targetap error fix upon crash during launch.

# V2.3.18 (2024-02-10)
- Fixed another bug that causes the ship to not roll 90 degrees during launch.
- Tuned Booster flip.

# V2.3.17 (2024-02-09)
- Lowered sensitivity for high speed re-entries (from mun, minmus etc).

# V2.3.16 (2024-02-08)
- Fix for manually flown re-entries followed by automatic landings on Duna.
- Fix for booster crash when the tower explodes.
- Fix for ship auto-stacking not starting after landing (quicksave stuck).
- Fix for problems due to changing to other ship during auto-stacking.

# V2.3.15 (2024-02-07)
- Fix for booster not rolling a clean 90 degrees during launch. It should now always roll 90 degrees with the top facing north.
- Possible fix for newly used modules renamed by AtmosphereAutopilot.
- Avoid a superfluous message when launching into negative inclinations.

# V2.3.14 (2024-02-06)
- included an optional patch for use with parallax on a stock Kerbin.

# V2.3.13 (2024-01-13)
- bugfix for no key found error after booster landing.

# V2.3.12 (2024-01-10)
- Auto-docking works again with the latest SEP dev version.
- Disable the watchdog CPU during ship landing (so it can't time-out).

# V2.3.11 (2024-01-04)
- Fix for RSS when ship was renamed.

# V2.3.10 (2024-01-02)
- Change in wording for the fuel tank mismatch error.

# V2.3.9 (2024-01-01)
- Tiny fixes for RSS launch using the new IFT-2 profile.

# V2.3.8 (2023-12-30)
- IFT-2 Launch Profile implemented.
- Booster can use gridfins for roll during launch.
- Auto-warp replaced by auto-stack option.
- Tooltips disabled by default.

# V2.3.7 (2023-12-29)
- Bug fixes for relaunching.

# V2.3.6 (2023-12-27)
- Fix for accidental renaming of ship to tower name.

# V2.3.5 (2023-12-17)
- Fixes for ship/booster landings.
- Booster docking delayed by 25 seconds after loading the quicksave to avoid booster wiggle.

# V2.3.4 (2023-12-16)
- Fixes for mun/duna landings.
- Check that OLM has booster before starting stacking.

# V2.3.3 (2023-12-14)
- Fixes for stacking and reflying starship.

# V2.3.2 (2023-12-12)
- Fixes for stock orbit completion.
- RSS ship landing fix.

# V2.3.1 (2023-12-11)
- Added automatic re-stacking capability. Doesn't work in RSS.
- Modified ship landing properties.
- Fix for expendable cargo ship.

# V2.3.0 (2023-12-05)
- Update to work with the SEP dev version, may have some new bugs!

# V2.2.18 (2023-11-21)
- New airlock/docking hatch/cargo door logic and new images. Now it completely follows the actual door statuses.
- Enabled SL engines for stock again for 15 seconds after hotstaging.
- SL engines now actuate out from the moment of hotstaging until 5 seconds after hotstaging is complete.

# V2.2.17 (2023-11-20)
- Fix for not launching to 0 degr. incl. target correctly on stock with an inclination set higher than required.
- Improved Crew airlock/docking hatch logic. Less likely to unsync.
- Higher RSS fuel vent cutoff value, so as not to return with too little fuel on board.
- Slightly decreased booster control sensitivity in the final catch stage on stock (> -15m/s VS).

# V2.2.16 (2023-11-18)
- fix for Interface failing to start. Cause was a variable for Rescale 2.5x.

# V2.2.15 (2023-11-15)
- Possible fix for faulty LZ reacquire even though the LZ is out of limits.
- Other minor fixes.

# v2.2.14 (2023-11-14)
- Fixed SCANsat page top text.
- Added "electrical humming" background noise to IVA.
- Fixed Radar Altitude in IVA, using a custom variable, correcting also for the ocean.
- Added Alerts to PFDs:
    - temperature/overheat
    - slope (>2.5%)
    - engine failure (engine flame-out due to lack of fuel)
    - gear warning (not deployed shortly before touchdown)
    - docking collision danger (when approaching way too fast)
    - impact warning (when descending way too fast)
    - Battery low (<15%)
- Reworked Resources and Crew Pages.
- Fixed an issue where the booster would float when it can't land at the tower.
- Initial Rescale 2.5x support! Make sure you have the "Rescale 2.5x" Folder in your /GameData!!
- Removed camera from PFD3, as the camera-transform of JSIHeadsUpDisplay was causing visual glitches.
- Fixed Radar Altitude on the PFD again.
- Forgot a camera.

# V2.2.13 (2023-11-11)
- FreeIVA is not a required mod for the IVA anymore. Very much recommended though.
- Navball fixed by latest RPM release. Download it!
- Fixed resource page bar bug.
- Improved positions of text on PFDs.

# V2.2.12 (2023-11-10)
- Fix for displaced text on the Ship Info page of the MFD.

# V2.2.11 (2023-11-09)
- Reworked the IVA:
    - The IVA now has touchscreen interfaces, with self-made RPM pages! Until SEP updates they will only be available in my parts.
        - known issues:
            - PFD nr. 3 needs a good camera-transform, the current one is just grey (inside vehicle).
            - Docking Camera needs its own camera-transform that is at the docking port, the current one is behind the docking hatch on the Crew part. It will show stuff when you open the docking hatch.
            - PFD navballs are not round, issue has been reported to RPM mod maker. Will hopefully be fixed in the next few months.
    - New wall texture with bumpmap!
    - Turned around the big interior hatch between floors, so it doesn't clip into the wall so much as before.

# V2.2.10 (2023-11-02)
- Fix for kOS-for-all Mod.
- Fix for having a folder called "Starship" inside the /Script folder.

# V2.2.9 (2023-10-30)
- Added DRE and Lifesupport CFGs.
- Provide the option to refuel or not if empty ship tanks are detected before launch.
- Fix for stock ship oscillations during launch (kOS overestimates available torque).
- Landing without atmo procedure gets a bit more cpu time and doesn´t fail due to constant time-out anymore.

# V2.2.8 (2023-10-29)
- Enable launch to coplanar orbit of Mun/Minmus, Moon and other targets.
- Custom Burn holds vector better now, without wiggling or rotating during the final m/s delta-v.
- Fix for no-atmo landing program.
- Timewarp continues down to 30 secs from a launch, or 60 secs for performing a burn.
- Launch to rendezvous for stock fixed.
- Autodocking doesn't enter intermediate stage so quickly. Angle increased.

# V2.2.7 (2023-10-28)
- Implemented a check for tanks that are not full before launch, and automatic refuel until it is.

# V2.2.6 (2023-10-27)
- Quality of life improvements:
    - when the script extends the gear, the button is also set to pressed.
    - Throttle is now fully set to 0 upon clearing the Interface (initiated after many a procedure).
    - Automatic inhibiting of the Launch and Land buttons depending on ship status (e.g. orbiting, landed, sub-orbital).
    - maneuver button is hidden when landed or prelaunch.
    - tower button is already hidden when pressing launch.
    - while using the manual attitude control, land button is inhibited.
- Fixed oversteering on empty ships in stock.
- Booster core vent is now stronger than the vent of the other parts.
- Smoother final orbit circularization.
- Attempt to fix wrong fuel settings for B9 tanks (using CRP).

# V2.2.5 (2023-10-26)
- Reduced vent rates, as I got them way too powerful during my rework of the patches.
- Timewarp overhaul for performing burns or waiting for launch.
- Auto-docking fixes.
- Reworked De-Orbit-Burn planning for planets with atmosphere.

# V2.2.4 (2023-10-24)
- Fossil plume fix didn't work, so from now on: If you have any mod of Fossil (like the QD), you'll need to install the plumes also, or you'll have no plume. If you want default plumes you'll need to delete the whole Fossil Industries folder from /gamedata.
- Reworked the Launch-to-Rendezvous/Target Orbit procedure, re-enabled for RSS.
- Fix vent rates.
- Enabled Launch to Depot.
- Fix for KSRSS tanker running Lqdmethane. The amount of the tanks was not set correctly after I changed it.

# V2.2.3 (2023-10-23)
- Booster got its own optimised .ksm file that auto-updates.
- Booster code flow optimized for controlling electricity use and cpu load.
- Tower doesn't set cpu speed to 500/s anymore. It caused slow updating of the Interface upon booster landing/tower unpack.
- Launch Interface update locked to a maximum of 10x per second.

# V2.2.2 (2023-10-21)
- fossil plume fix (didn't work - 2023-10-24)

# V2.2.1 (2023-10-20)
- Fix for default SEP plumes, which were invisible due to a wrong dependency check.
- Latest version of script.

# V2.2.0 (2023-10-19)
- Major rework of the patch-system, to align with SEPs modular patches. Requires deleting the old StarshipInterface folder!!
- Lowered the Boosters CoM by 2.5m for better control authority during re-entry.
- Set Booster RCS and Roll Reaction Wheels to SEP standard, and modified all Booster control functions.
- Provide support for Fossils custom plumes for SEP.
- If Booster control gets inaccurate (KSRSS & RSS), it will switch back to the booster to correct the error and then switch back to the ship.
- Simple Hotstaging implemented and all launch trajectories modified accordingly.
- Fix for Booster overshooting the tower when too low on fuel. Booster will still crash if it has too little fuel already.
- Abort procedure added in case of clamp failure (accidental self docking again on clamp release due to ksp..).
- Reworked clamp release (undock) and refueling procedure.
- Booster engines throttle up before clamp release.
- The launch procedure uses less CPU time now, improving performance on slow computers.
- Further bug fixes.

# V2.1.13 (2023-10-12)
- Script now warns of too high inclination to do an automatic de-orbit burn before suggesting fuel venting.
- Winch/LR Antenna buttons greyed out to highlight that they are not yet implemented.
- Booster switches to docking mode after landing.

# V2.1.12 (2023-10-03)
- Remove fixed fuel quantities from cfgs. I forgot about those and they caused issues.

# V2.1.11 (2023-10-02)
- Fully implementing a vehicle self check that checks fuel tank sizes and correct craft according to stock, KSRSS or RSS and show messages in the Interface when errors have been detected.
- De-orbit burn with rcs is now facing prograde instead of retrograde.

# V2.1.10 (2023-10-01)
- Quick fix for LF/Ox where ship landing/catch fails because of a bug.

# V2.1.9 (2023-09-30)
- Fixed the OLM refueling function for Liquid Methane (CRP).
- Enabled background updates and launch abort in the moment between engine start-up and clamp release/lift off.
- Minor fixes for auto-docking.
- Fixed .craft files for normal LF/OX. They sometimes were overloaded. Implementing a feature that checks the tanks capacity for correctness.

# V2.1.8 (2023-09-27)
- Smoother final stage of Auto-Docking, and hopefully quicker/more stable docking.
- Major rework of the fuel system to fit more closely to SEPs goals of compatibility with standard ksp fuel ratios. Please land/retire old ships before installing this update!! With this update I'm moving from the old 1:3.6 ratio to the standard 0.9:1.1 LF to Ox ratio.
- Reimplementing Liquid Methane Support, with the standard SEP ratio, but with different amounts to keep the same mass as while using LF/Ox. Install CommunityResourcePack to enable automatic Liquid Methane usage.

# V2.1.7 (2023-09-20)
- Added RO as an incompatible mod. This was a long time overdue.
- Added a safeguard against launching with too little Cluster Thrust. Launch will now be aborted before clamp release.
- Changed Launch Labels, azimuth and pitch are changed around. Steering errors show only the error in yellow or red now.

# V2.1.6 (2023-06-25)
- Introducing my own temporary plumes. Fixes the macOS and linux shader problems with SEPs default waterfall plumes. Will be removed once fossils plumes/clouds are completely built into SEP.

# V2.1.5 (2023-06-24)
- Launch gets cancelled when multiple towers are in use, and names collide (causing booster crash on landing).

# V2.1.4 (2023-06-21)
- Increased booster fuel margins for depot starship.

# V2.1.3 (2023-06-20)
- Booster now rotates to align itself with the tower upon landing.
- Booster landing trajectory modified to work better accross different setups.
- Fixed KSRSS Booster Thrust. I used the wrong value before.
- Minor Ship fixes.
- Ship shows guidance error during launch (yellow and red coloring as well).
- Fix an issue where the tower would not be found when not in the list of standard launch coordinates.

# V2.1.2 (2023-06-18)
- Added .craft files for the Expendable and Depot Starship versions.
- A minor tweak to the boosters landing burn.

# V2.1.1 (2023-06-15)
- Fixed Cluster rotation on stock and RSS .craft files.

# V2.1 (2023-06-12) - MAJOR CHANGE
- Reworked the structure of the mod in an effort to make the mod work more reliably across different systems. Instead of patching most changes, I reduce the patching to a minimum by using pre-made CFGs for the parts.
- Fixed an issue where the ship would not set the Radar Altimeter correctly for catching into the arms.
- Renamed the waterfall plumes to work with the latest SEP.

# V2.0.22 (2023-06-02)
- Fixed an issue where ship would vent too much for a duna landing.
- Fixed a Moon Landing Issue where it would burn for too long due to script hang.
- Enabled rcs during venting.
- 2 Engine RVAC landing on the Moon engine page fixed.
- KSRSS booster fix: fuel vent stopped to late.

# V2.0.21 (2023-06-01)
- Fixed an issue where KSRSS was not recognized correctly.
- Fixed a small number of moon landing problems.
- Introducing fuel venting for moon landings.

# V2.0.20 (2023-05-31)
- Fixed an issue with stock crew kerbin de-orbit (too high CoG reported).
- Fixed a number of Moon Landing problems.

# V2.0.19 (2023-05-30)
- Change in orbit-completion sequence to reduce crashes and enable booster recovery in KSRSS/RSS.
- Fix for 6RVAC Moon Landing: shut down 2 more engines for landing.

# V2.0.18 (2023-05-29)
- Attempt to fix RSS ship rotation on catch.
- Tower location now gets updated at 300m RA in case it moves slightly (for example in RSS).
- Added earth, mars and moon images for the orbit page.
- RSS re-entry PIDloop less sensitive on final approach (less prone to spinning out of control).
- Changed .crafts to fix engine rotations.

# V2.0.17 (2023-05-28)
- Fixed a Cryotanks bug. Header Tank fuel should be normal again.

# V2.0.16 (2023-05-25)
- If a user turns off the header tank or main tank of the ship, it gets enabled again automatically.
- Fixed a landing bug that I created a few days ago.

# V2.0.15 (2023-05-23)
- Numerous RSS improvements (landing, 6RVAC, etc).
- Booster landing adjustments.
- Fixed a problem during launch where Ap would get to high and cause 0 thrust.
- Fixed a problem with the background update after orbit completion, but before booster landing.

# V2.0.14 (2023-05-22)
- Fixed a launch issue for 6 RVACs.
- Changed the ship catching guidance vectors. Might impact landings (hopefully in a positive way).
- RSS: Reduced sensitivity on the initial re-entry guidance to avoid high rcs usage.
- Fixed a ship landing issue where the ship rolls when the tower is destroyed after starting the landing program.

# V2.0.13 (2023-05-14)
- New Mars/Duna Landing Mechanism allowing max cargo to be landed on Mars/Duna (RSS, KSRSS and stock).
- Fixes to Moon/Mun landings allowing max cargo to be landed on Moon/Mun (RSS, KSRSS and stock).

# V2.0.12 (2023-05-10)
- Initial KSRSS support (ship landings only without FAR).

# V2.0.11 (2023-05-09)
- Enabled precise Earth landings with ship in RSS (without FAR!).

# V2.0.10 (2023-05-08)
- Fixed some booster and ship landing bugs.
- Fixed an error when calculating a de-orbit burn and Trajectories doesn't find an impact position.

# V2.0.9 (2023-05-05)
- FAR is an accepted mod again. However ship re-entry and landing won't work with FAR yet. Only launches are currently supported until the flap module has been rewritten to work with FAR.

# V2.0.8 (2023-05-03)
- Major rework of the booster and ship launch trajectory, booster landing and circularization burn for working with RSS. The new code could have bugs. Let me know if you find any.
- Major rework of patches (for example drag cubes) for RSS and stock.
- New .craft files. Don't use old ones.
- Many more behind the scenes changes.

# V2.0.7 (2023-03-26)
- Auto-docking bug fixed (due to changes in vessel loading sequences).
- Fix Ship crash on final re-entry when Breaking ground was not installed.

# V2.0.6 (2023-03-18)
- Fix Booster crash when Breaking ground was not installed.

# V2.0.5a (2023-03-14)
- More patch fixes, FAR added as incompatible. TweakableEverything is now fully blocked.

# V2.0.5 (2023-03-13)
- Hopefully another patch fix.

# V2.0.4 (2023-03-06)
- Catch an error on launch when the default docking system has been changed from what my .craft specifies.

# V2.0.3 (2023-03-01)
- Hopefully a patching fix for the missing OLM.

# V2.0.2 (2023-02-28)
- Fixed booster drag after patching issue.
- Fixed nuisance logging spam in ksp.log
- Fixed Booster swing direction after booster separation during crew launch.
- Fixed wrong fuel dump when re-entering at Duna.
- Fixed a radar altimeter problem at Duna.

# V2.0.1 (2023-02-27)
- Fixed a patching issue when Community Resource Pack was installed.
- Fixed a general patching issue.
- Fixed a launch to rendezvous error.

# V2.0.0 (2023-02-26)
- Ready for SEPs 2.0 update.
- Implemented a CoM balancing system through fuel transfer between the header tank and the main tanks. Solves a lot of ksps control problems.
- Reworked the Auto-docking function.
- Removed support for liquid methane (too many headaches).
- Too many other bugfixes and changes to list.
- Started work on RSS capability, but it's still buggy. (if you want to try: install RSS, but don't apply SEPs realism overhaul patch in the extras folder of SEP)

# V1.0.6b (2022-12-03)
- Fixed an issue causing the deorbit-finder to stop early.
- Fixed Mechazilla missing a command by brute forcing my way to success.
- Made the Ship have a 25cm higher target Radar Altitude on Landing into the Mechazilla so the flaps stay healthy more often (read: don't get destroyed by the arms).

# V1.0.6a (2022-11-18)
- Code cleanup (performburn function).
- Small bugfixes in many items.
- landing zone gets the slope checked again (turned that off by accident).

# V1.0.6 (2022-11-15)
- Better use of the maneuver page:
    - "Align Planes" now shows target, its orbit and the relative inclination.
    - "Execute Burn" now shows Burn timestamp, delta-V required, burn time and type of thrust used (Vac engines or RCS thrusters).
- Realigned crew images on the Crew Page.
- Removed "Configurable Containers" and "AnimatedAttachment" from mods that don't work with the Interface (patch changed).
- Made a dictionary of known launch sites, which can be used for selecting a landing zone instead of a big bunch of code.
- Fixed all the booster landing issues that occured when not launching from the KSC (problems due to elevation, etc).
- Multiple OLMs can now be used for launching from and landing onto:
    - Many bugs in the re-entry and landing were fixed to allow landings everywhere.
    - Because of changes, also fixes for Duna Landings and the Mun.
    - The OLMs get assigned a name based on a dictionary with known launch sites. Only these bases allow a Mechazilla catch now.
- The Re-Entry and Land Program gets automatically reloaded in case of a crash during Re-Entry, no action required.

# V1.0.5e (2022-11-11)
- Watchdog is now self-updating when a connection exists.
- "Launch to Intercept Orbit" gets the ships a bit closer now instead of just into the same orbit.
- A simple "Align Planes" maneuver was added for aligning planes with ships in orbit.
- fixed a watchdog bug during quick timewarp reductions.

# V1.0.5d (2022-11-10)
- Added "Launch to Inclination" feature.
- Hopefully fixed the slowmotion bug which sometimes occurred when the scene was reloaded during launch (only happens sometimes).
- Added "Launch to Intercept Orbit" feature for launching to a target ships inclination.
- Fixed a watchdog bug.

# V1.0.5c (2022-11-09)
- Removed "AtmosphereAutopilot" from mods that don't work with the Interface (patch changed).
- Removed "launch with 0/180 degrees" (upside down) toggle on the settings page as the Interface can detect it automatically now.
- Added CPU Speed toggle in the settings.
- Faster Interface Start-Up, better update mechanism.
- Fixed error where the boostback was being called twice causing a forced loading of the starship that's in orbit.

# V1.0.5b (2022-11-08)
- Fixed a watchdog issue on "revert to launch".

# V1.0.5a (2022-11-07)
- Cancel button becomes the "Undock" button when docked.
- Fixed ship renaming when more than two ships of one variant exist simultaneously.
- Fixed a watchdog issue causing the de-orbit velocity calculation to fail.
- Fixed more watchdog issues.

# V1.0.5 (2022-11-07)
- !! You need to recover all your existing ships before applying this update !!
- Minmus landings now possible.
- Booster Boostback and landing overhauled. After separation the Booster will now be active to make the boostback more reliable and consistent across different computer setups (using the trajectories mod).
- Watchdog CPU implemented:
    - If the Interface doesn't send a ping to the Watchdog CPU for 5 seconds, the watchdog CPU will restart the Interface (in case of crashes/time-outs).

# V1.0.4h (2022-10-31)
- fixed a mun-landing encapsulation crash on touchdown.
- Cleaned up code a bit.
- fixed steeper angle mun landings. Deceleration burn was wrongly calculated.
- fuel venting bug for tanker ships.

# V1.0.4g (2022-10-30)
- fixed the message sent crash.
- Slightly more accurate Launch-to-Rendezvous (LFO and LCH4).
- Fixed an automatic mun deorbit bug causing too high approach over LZ, and a bug that caused correcting in the wrong direction in some cases.
- Delta-V Calculation shown properly depending on engines selected and preflight situation.

# V1.0.4f (2022-10-29)
- Overhauled the indexing of all ships parts, and the calculation of all Masses. Shows correct mass and delta-v of the ship that the Interface belongs to while being docked to another.
- Fixed overlapping Interfaces for up to 2 ships in close proximity. The Interface for the active ship will always be on top, and the inactive ship below. When docked: crew or cargo on top, tanker at the bottom. crew + cargo will still overlap.
- Fixed a bug where the ship would steer the wrong way during re-entry.
- New calculation of the flap angles to reflect that they need time to move (actual values are unfortunately not shared by the mod).
- New temperature calculation for the heatshield (still just eye-candy).
- Improved Duna Landings (no oscillations found anymore).
- Improved ksp performance (reduced the time that the cpu runs the highest possible 2000 lines per second).
- When a message is succesfully sent, the symbol on the main page will now light up green.

# V1.0.4e (2022-10-26)
- Oscillation during orbit entry for starship tanker fixed.
- new: a Booster separation message.

# V1.0.4d (2022-10-25)
- Fixed Tower if the order of the modules was messed up (bug noticed after an OS reinstall, which changed some behaviours and caused some issues).
- When EVA'ing during fuel vent the Interface no longer hangs.
- When clicking 'log data' and no connection is available, the Interface no longer crashes.
- Fixed an Interface crash upon booster separation (a small time delay avoids looking for the Booster when it hasn't fully separated yet).

# V1.0.4c (2022-10-24)
- Fixed a bug when confirming a planned maneuver too close to the start of the burn.

# V1.0.4b (2022-10-11)
- Fixed an issue causing the towers arms not to open before ship catching sometimes.
- Fixed an issue causing the booster to sometimes land a few meters offset from the actual target (target was set wrongly).
- Fixed some mun landing bugs.

# V1.0.4a (2022-10-07)
- Fixed some Mun Landing Bugs.
- Planning a de-orbit on the mun will always plan a point 8km over the Landing Zone before landing vertically.
- Single/Dual engine landings now show only one or two engine running on the engines page.
- Mun landings are smoother and less scary (at the cost of a little delta-v).

# V1.0.4 (2022-10-06)
- Preliminary Mun Automatic De-Orbit & Landing capability introduced.
- Major change to the process of looking for a suitable de-orbit trajectory.
    - I sacrificed looking 6 hours ahead for a de-orbit for a faster and more reliable lookup of only the 1 orbit ahead.
- Added a sticker on the homepage of the Interface to identify which Ships Interface you're looking at (useful when you have multiple craft close by in orbit).
- Fixed some minor bugs I found.

# V1.0.3a (2022-09-12)
- Fixed a crash that happened after undocking.

# V1.0.3 (2022-09-07)
- Fixed an issue where the correct Angle-of-Attack would not be correctly set when transferring from Duna to Kerbin, causing a failure of the auto de-orbit function.
- Introduced a new function that automatically dumps excess fuel during the re-entry after a manual de-orbit, to avoid returning manually, activating the re-entry procedure only and failing the landing due to too high Mass (and fuel).
- Fixed an issue with the Crew Ship. Due to the increased mass of the crew module, the flaps didn't have their proper neutral angle. Reduced Crew Module Mass slightly (15t now vs. SEP default 10t).
- Fixed the acceleration (g-force) measuring that I broke some time ago.
- Fixed an issue where the Center of Gravity was affected when Community Resource Pack was installed, resulting in failed ship re-entries.

# V1.0.2e
- Changed the Boosters final approach mechanism. Fixes the overshooting/undershooting due to users having a different Booster trajectory than I have (still to be investigated).

# V1.0.2d
- Added these mods as incompatible mods that I can't figure out a patch for: ConfigurableContainers and AnimatedAttachment.

# V1.0.2c
- Fix for auto-update loop on startup.

# V1.0.2b
- Changed the patch to hopefully make things more reliable for users with many mods. In case a mod is detected that is not compatible no kOS modules will be added to the vehicle and therefore failing to load the interface.

# V1.0.2a
- Fixed the patch to work with the CryoTanks mod.

# V1.0.2
- Due to BIG structural and procedural CHANGES please dispose of (or land) any already existing starships in your savegame to avoid kerbal deaths!
- Booster/Ship flight profile is now flatter:
    - Booster has more fuel and the ship has less fuel, better matching the real starship.
    - Booster glides more during final re-entry.
- Reconfigured the fuel tanks for more consistency:
    - Methane - Oxidizer ratio is now 1 : 3.6.
    - Liquid Fuel - Oxidizer ratio is now 1 : 3.6.
    - RCS more efficient (to simulate running on ullage gas).
- Ship now supports both 6 and 9-engine versions (you need to modify the craft yourself).
- Fixed missing circulation-fan symbol on the crew page.
- Orbit Insertion Burn is slightly more accurate.
- Launch to Rendezvous text bug fixed.

# V1.0.1c
- More reliable Booster Engine Mode switching.
- Incompatibility added with Atmospheric Autopilot. It changes the names of certain modules.

# V1.0.1b
- More accurate maneuver page burns.
- More reliable auto-updating itself.
- Yet another delta-v calculation crash fixed.

# V1.0.1a
- Ship mass correct during launch.
- More hudtexts built in to inform the user.
- Delta-V Calculation fixed. It caused a crash when some required value returned a false value.
- Fixed background update while waiting for launch to rendezvous.
- Fixed tower cpu to allow for latest update of SLE to work.

# V1.0.1
- New Ships will from now on *automatically update* (if a connection to the KSC is available) on loading when you download and install a new version of my interface!
    - This means you won't have to delete all the active ships (and create new ships at the VAB) anymore.
    - Start-Up will take a few seconds longer.
    - Old ships of V1.0.0 or before can still be updated if they have a radio connection and the following commands are issued from the kOS CPU:
        - switch to 0.
        - run starship.
- Auto-Docking has received some small fixes.
- 'Cargo Mass' is now correct when docked. Ship Mass and Delta-V have been blocked.

# V1.0.0
- First Release!!
