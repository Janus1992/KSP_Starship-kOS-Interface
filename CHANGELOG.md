# V2.0.22 (2023-06-02)
- Fixed an issue where ship would vent too much for a duna landing.
- Fixed a Moon Landing Issue where it would burn for too long due to script hang.
- Enabled rcs during venting.
- 2 Engine RVAC landing on the Moon engine page fixed.
- KSRSS booster landing fix for if the booster is too light.

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
