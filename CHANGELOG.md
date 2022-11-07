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
