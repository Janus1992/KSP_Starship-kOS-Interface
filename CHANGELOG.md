# V1.0.2d
- Added to incompatible mods that I can't figure out a patch for: ConfigurableContainers and AnimatedAttachment.

# V1.0.2c
- Hopefully a fix for auto-update loop on startup.

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
