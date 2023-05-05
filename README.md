# KSP_Starship-kOS-Interface V2
An Interface for automating the 'Starship Expansion Project' and 'Starship Launch Expansion' mods within Kerbal Space Program. It's meant only for stock kerbin at the moment.


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
- Stock KSP (no RSS, KSRSS or other planet changing mods) that has the language set to "english" (important).
- Starship Expansion Project
    https://forum.kerbalspaceprogram.com/index.php?/topic/206555-1101-112x-starship-expansion-project-sep-v101-january-30th-2022/
- Trajectories
    https://forum.kerbalspaceprogram.com/index.php?/topic/162324-18-112x-trajectories-v241-2021-06-27-atmospheric-predictions/
- kOS
    https://forum.kerbalspaceprogram.com/index.php?/topic/165628-ksp-1101-and-111-kos-v1310-kos-scriptable-autopilot-system/
- TundraExploration (only TundraExploration.dll)
    https://forum.kerbalspaceprogram.com/index.php?/topic/166915-112x-tundra-exploration-v600-january-23rd-restockalike-spacex-falcon-9-crew-dragon-xl/
- Starship Launch Expansion - the DEV version(!!)
    https://forum.kerbalspaceprogram.com/index.php?/topic/203952-1129-starship-launch-expansion-v05-beta-may-31/&tab=comments#comment-4008229
    Dev Version: https://github.com/SAMCG14/StarshipLaunchExpansion/tree/Dev

# OPTIONAL:
- Kerbal Joint Reinforcement Continued (For use with RSS)
    https://github.com/KSP-RO/Kerbal-Joint-Reinforcement-Continued

# INCOMPATIBLE(!!):
- TweakableEverything



# Notes:
- My mod copies the original SEP parts and changes it's fuel and thrust (and more) values to portray a more playable behaviour on Kerbin. As SEP is optimized for 2.5/2.7x sized Kerbin, SEP default will result in more fuel in orbit than a real life Starship would have in lower Earth orbit. Although SEP's behaviour is realistic for a planet the size of Kerbin, I decided that simulating the tight margins to orbit makes SEP more playable and fun on stock Kerbin.

- Automatic re-stacking/refueling is currently impossible because the SEP & SLE mods lack the ability to dock together.

- When using multiple ships of the same name, they might get renamed by my scripts to avoid Interface crashes.

- Seldom Interface crashes may occur (it makes a little crashing noise). A watchdog computer should try to restart the Interface after 2.5 seconds.

- Existing Ships will automatically try to update the Interface after installing the latest version from here, provided a connection to the KSC is available.

- The KSP delta-V calculations are not correct, so trust the Interface instead! :)



# Tips & Tricks:
To Load Cargo in the Cargo Ship:

- Drag the whole ship down to access the cargo-bay (root: Ships tank section).
- Connect your payload.
- Drage the whole ship up so far that the Tower is completely above ground (or the OLM will explode on booster return).



# Known Issues:
- Your KSP should be set to english for the scripts to work.

- Settings page: Sometimes the landing coördinates cannot be confirmed with "enter" or by pressing away from the text field. Closing the Settings page will however confirm the coördinates.

- Enabling logging of data can seldomly cause a crash when it attempts to write and it loses the connection before/during the writing. Logging is therefore disabled by default.

- Sometimes I've noticed that running some parts of the script generates tiny amounts of liquid fuel? It uses electricity, but generates LF. I haven't gotten to the bottom of this issue. One user reports that the ship can't land since oxidizer somehow gets created after the de-orbit burn. Investigation in progress..

- Being in IVA during Booster Separation can cause problems with returning back into the IVA later on, and break the camera. A reload after launch completion fixes everything.



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
This has been a pet project of mine since around May 2021, and I had a lot of fun making and using this Interface. I hope you will too! Let me know what you think! I thank all the mod makers whose work I have been able to rely on, and without whom none of this would have been possible.
