# KSP_Starship-kOS-Interface V2
An Interface for automating the 'Starship Expansion Project' and 'Starship Launch Expansion' mods within Kerbal Space Program. It's meant only for stock kerbin at the moment.


# IMPORTANT to users of older versions than V2.1
- Please remove the SEP_kOS_Guidance.cfg that is located in /gamedata before/after installing V2.1
- In V2.1 the structure of the mod has been changed to reduce the amount of unreliable patching.


![Alt text](/Infographic.png)


# TO INSTALL (NO CKAN):
- Download and install all requirements listed below (SLE needs the DEV version, not available on CKAN).
- Download the zip file.
- Extract the contents to a folder.
- Copy the 'GameData' and 'Ships' folders into your /Kerbal Space Program folder.

# IMPORTANT!:
- Works only with the provided .craft files ("Starship Cargo", "Starship Crew", "Starship Tanker"). These can be found if you enable stock vehicles in your savegame, or you copy them manually to your savegame.
- If the Interface or ship doesn't show up, check again that you fulfill all the requirements listed below!
- Before filing a bug, read the "Bug support guide" at the bottom of this page.

# REQUIRES:
- Stock KSP, RSS or KSRSS (no other planet changing mods), and the language has to be set to "english" (important).
- Starship Expansion Project
    https://forum.kerbalspaceprogram.com/index.php?/topic/206555-1101-112x-starship-expansion-project-sep-v101-january-30th-2022/
- Starship Launch Expansion - the DEV version(!!)
    https://forum.kerbalspaceprogram.com/index.php?/topic/203952-1129-starship-launch-expansion-v05-beta-may-31/&tab=comments#comment-4008229
    Dev Version: https://github.com/SAMCG14/StarshipLaunchExpansion/tree/Dev
- kOS
    https://forum.kerbalspaceprogram.com/index.php?/topic/165628-ksp-1101-and-111-kos-v1310-kos-scriptable-autopilot-system/
- Trajectories
    https://forum.kerbalspaceprogram.com/index.php?/topic/162324-18-112x-trajectories-v241-2021-06-27-atmospheric-predictions/
- TundraExploration (actually only TundraExploration.dll)
    https://forum.kerbalspaceprogram.com/index.php?/topic/166915-112x-tundra-exploration-v600-january-23rd-restockalike-spacex-falcon-9-crew-dragon-xl/
- Kerbal Joint Reinforcement Continued
    https://github.com/KSP-RO/Kerbal-Joint-Reinforcement-Continued

# INCOMPATIBLE(!!):
- TweakableEverything
- Ferram AeroSpace Research (FAR)



# Notes:
- Concerning stock KSP: My mod copies the original SEP parts and changes its fuel and thrust (and more) values to portray a more "usable" behaviour on Kerbin. As SEP is optimized for 2.5/2.7x sized Kerbin, SEP default will result in more fuel in orbit than a real life Starship would have in lower (stock) Kerbin orbit. I decided that simulating the tight margins to orbit makes SEP more playable and fun on stock Kerbin.

- Automatic re-stacking/refueling is currently impossible because the Booster lacks the ability to dock to the tower.

- When using multiple ships of the same name, they might get renamed by my scripts to avoid Interface crashes.

- Seldom Interface crashes may/will occur (it makes a little crashing noise). A watchdog computer should try to restart the Interface after 5 seconds.

- Existing Ships out on a trip will automatically try to update the Interface after one installs the latest version from here, provided a connection to the KSC is available.

- The KSP delta-V calculations are not correct, so trust the Interface instead! :)



# Tips & Tricks:
To Load Cargo in the Cargo Ship (due to the vehicle not fitting in the VAB):

- Drag the whole ship down to access the cargo-bay (root: Ships tank section).
- Insert your payload.
- Drage the whole ship up so far that the Tower is completely above ground (or the OLM will explode on booster return).



# Known Issues:
- Your KSP should be set to english for the scripts to work.

- In RSS on booster catch the tower may be glitching due to Kraken.

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
This has been a pet project of mine since around May 2021, and I had a lot of fun making and using this Interface. I hope you will too! Let me know what you think! I thank all the mod makers whose work I have been able to rely on, and without whom none of this would have been possible. Especially I want to thank the makers of SEP: Kari, Sofie, etc.. and SAMCG14 for his work on the Launch Tower, both of whose CFGs I'm modifying for better stability across different peoples use cases.
