# KSP_Starship-kOS-Interface V2
An Interface for automating the 'Starship Expansion Project' and 'Starship Launch Expansion' mods within Kerbal Space Program.


![Alt text](/Infographic.png)

# IF YOU HAVE AN OLD VERSION previously installed, make sure to delete the 'StarshipInterface' folder in /gamedata before installing the updated version of the Interface!

# INSTALL INSTRUCTIONS (NO CKAN SUPPORT!):
- Download and install all requirements listed below (SLE needs the DEV version, not available on CKAN).
- Download the zip file.
- Extract the contents to a folder.
- Copy the contents of the /Kerbal Space Program folder ('GameData' and 'Ships' folders) into your /Kerbal Space Program folder.
    - It should look like this:
        Kerbal Space Program/GameData/StarshipInterface
        Kerbal Space Program/Ships/Script  (here the scripts are saved)
        Kerbal Space Program/Ships/VAB
(To Update do the same, but first delete the 'StarshipInterface' folder and overwrite anything else!)


# IMPORTANT!:
- Works only with the provided .craft files ("Starship Cargo", "Starship Crew", "Starship Tanker"). These can be found if you enable stock vehicles in your savegame, or you copy them manually to your savegame.
- If the Interface or ship doesn't show up, check again that you fulfill all the requirements listed below or try reinstalling!
- Before filing a bug, read the "Bug support guide" at the bottom of this page.

# REQUIRES:
- Stock KSP, RSS or KSRSS (no other planet changing mods, and don´t change the default scale!), and the language has to be set to "english" (important).
- Starship Expansion Project - github repository version and its requirements (!!)
    https://forum.kerbalspaceprogram.com/index.php?/topic/206555-1101-112x-starship-expansion-project-sep-v101-january-30th-2022/
    Github version: https://github.com/Kari1407/Starship-Expansion-Project
- Starship Launch Expansion - the DEV version(!!)
    https://forum.kerbalspaceprogram.com/index.php?/topic/203952-1129-starship-launch-expansion-v05-beta-may-31/&tab=comments#comment-4008229
    Dev Version: https://github.com/SAMCG14/StarshipLaunchExpansion/tree/Dev
- kOS
    https://forum.kerbalspaceprogram.com/index.php?/topic/165628-ksp-1101-and-111-kos-v1310-kos-scriptable-autopilot-system/
- Trajectories, and its requirements!`
    https://forum.kerbalspaceprogram.com/index.php?/topic/162324-18-112x-trajectories-v241-2021-06-27-atmospheric-predictions/
- TundraExploration (actually only TundraExploration.dll)
    https://forum.kerbalspaceprogram.com/index.php?/topic/166915-112x-tundra-exploration-v600-january-23rd-restockalike-spacex-falcon-9-crew-dragon-xl/
- Kerbal Joint Reinforcement Continued
    https://github.com/KSP-RO/Kerbal-Joint-Reinforcement-Continued

# RECOMMENDED:
- HangarExtender (Recommended for being able to load cargo)
    https://spacedock.info/mod/1428/HangerExtender#stats

# INCOMPATIBLE(!!):
- TweakableEverything
- Ferram AeroSpace Research (FAR)
- Realism Overhaul (RO)


# Notes:
- The recommended way of loading a craft is from the stock craft category in the VAB. If you can't find this category, you need to enter settings from the KSC default view and enable 'Include Stock Vessels'.

- Automatic re-stacking/refueling is currently impossible because the Booster lacks the ability to dock to the tower.

- When using multiple ships of the same name, they might get renamed by my scripts to avoid Interface crashes.

- Seldom Interface crashes may/will occur (it makes a little crashing noise). A watchdog computer should try to restart the Interface after 5 seconds.

- Existing Ships out on a trip will automatically try to update the Interface after one installs the latest version from here, provided a connection to the KSC is available.

- The KSP delta-V calculations are not correct, so trust the Interface instead! :)

- If you have anything installed by Fossil Industries then also install the plume, because if you don't the plume will not show up. This is a patch limitation at this point. If you want to have default SEP plumes, you'll need to delete the entire Fossil Industries folder from /gamedata, as that is what the patch checks for.


# Known Issues:
- Your KSP should be set to english for the scripts to work.

- RSS issues:
    - On booster catch the tower may be glitching due to Kraken, and if catch succeeds the booster is probably not recoverable (looking for a fix).
    - Booster/Ship control gets wonky with big ship distances. May cause Ship to fully lose control during booster catching.

- Being in IVA during Booster Separation can cause problems with returning back into the IVA later on, and break the camera. A reload after launch completion fixes everything.

- Enabling logging of data can seldomly cause a crash when it attempts to write and it loses the connection before/during the writing. Logging is therefore disabled by default.



# Bug support guide:
- check first that you fulfill the requirements above (check Incompatible Mods!!) and carefully (!!) read this whole page.
- If you have many mods installed, try moving unnecessary mods away from /gamedata temporarily. The less mods, the better (Only SEPs requirements and those of this mod).
- If you still get script crashes that don't recover themselves: congratulations, you may have found a bug!
- Keep the kOS CPUs open (right hand side) and screenshot any errors or problems.
- Either:
    - File an issue on github, or
    - Write me on: KSP forum SEP thread, or
    - Write me on: SEP Discord
- Be sure to describe the problem as accurately as possible and add the screenshots.
- Videos would be very helpful as well if ship or booster does not perform properly.



# By the author:
This has been a pet project of mine since around May 2021, and I had a lot of fun making and using this Interface. I hope you will too! Let me know what you think! I thank all the mod makers whose work I have been able to rely on, and without whom none of this would have been possible. Especially I want to thank the makers of SEP: Kari, Sofie, etc.. and SAMCG14 for his work on the Launch Tower, both of whose CFGs I'm modifying.
