# KSP_Starship-kOS-Interface V2.0.0
An Interface for automating the 'Starship Expansion Project' and 'Starship Launch Expansion' mods within Kerbal Space Program. It's meant only for stock kerbin at the moment.

# IMPORTANT CHANGE!! To Users using versions OLDER than v2.0:
- Please delete GameData/Janus92_kOS_Automation_patch.cfg from your current KSP install location.

![Alt text](/Infographic.png)

# TO INSTALL:
- Download the zip file.
- Extract the contents to a folder.
- Copy the 'GameData' and 'Ships' folders into your /Kerbal Space Program folder.


# IMPORTANT!:
- Works only with the provided .craft files ("Starship Cargo", "Starship Crew", "Starship Tanker"). These can be found if you enable stock vehicles in your savegame, or you copy them manually to your savegame.
- If the Interface doesn't show up, check again that you don't have any of the mods installed that the Interface doesn't work with (listed below).

# REQUIRES:
- Starship Expansion Project
    https://forum.kerbalspaceprogram.com/index.php?/topic/206555-1101-112x-starship-expansion-project-sep-v101-january-30th-2022/
- Trajectories
    https://forum.kerbalspaceprogram.com/index.php?/topic/162324-18-112x-trajectories-v241-2021-06-27-atmospheric-predictions/
- kOS
    https://forum.kerbalspaceprogram.com/index.php?/topic/165628-ksp-1101-and-111-kos-v1310-kos-scriptable-autopilot-system/
- TundraExploration (only TundraExploration.dll)
    https://forum.kerbalspaceprogram.com/index.php?/topic/166915-112x-tundra-exploration-v600-january-23rd-restockalike-spacex-falcon-9-crew-dragon-xl/
- Starship Launch Expansion
    https://forum.kerbalspaceprogram.com/index.php?/topic/203952-1129-starship-launch-expansion-v05-beta-may-31/&tab=comments#comment-4008229

# OPTIONAL:
- Kerbal Joint Reinforcement Continued (Required for use with RSS, as the flaps will break off)
    https://github.com/KSP-RO/Kerbal-Joint-Reinforcement-Continued

# Incompatible Mods:
- TweakableEverything

# Tips & Tricks:
To Load Cargo in the Cargo Ship:
- Drag the whole ship down to access the cargo-bay (root: Ships tank section).
- Connect your payload.
- Drage the whole ship up so far that the Tower is completely above ground (or the OLM will explode on booster return).


# Notes:
- Automatic re-stacking/refueling is currently impossible because the SEP & SLE mods lack the ability to dock together.
- When using multiple ships of the same name, they might get renamed by my scripts to avoid Interface crashes.
- Seldom Interface crashes may occur (it makes a little crashing noise). A watchdog computer should try to restart the Interface after 2.5 seconds.
- Existing Ships will automatically try to update the Interface after installing the latest version from here, provided a connection is available.
- The KSP delta-V calculations are not correct, so trust the Interface instead! :)


# Known Issues:
- Settings page: Sometimes the landing coördinates cannot be confirmed with "enter" or by pressing away from the text field. Closing the Settings page will however confirm the coördinates.
- Enabling logging of data can seldomly cause a crash when it attempts to write and it loses the connection before/during the writing. Logging is therefore disabled by default.
- Sometimes I've noticed that running some parts of the script generates tiny amounts of liquid fuel? It uses electricity, but generates LF. Very strange, but not really intrusive.


# By the author:
This has been a pet project of mine since 2021, and I had a lot of fun making and using this Interface. I hope you will too! Let me know what you think! I thank all the mod makers whose work I have been able to rely on, and without whom none of this would have been possible.
