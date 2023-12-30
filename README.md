# KSP_Starship-kOS-Interface V2
An Interface for automating the 'Starship Expansion Project' and 'Starship Launch Expansion' mods within Kerbal Space Program.


![Alt text](/Infographic.png)


# INSTALL INSTRUCTIONS (NO CKAN SUPPORT!):
- Download and install all requirements listed below (pay attention: SLE and SEP both need the DEV branch (not available on CKAN). They can be downloaded by changing from main to dev branch and clicking the github green button download-all, not the releases).
- If you update: first delete the 'StarshipInterface' folder!
- Download the zip file.
- Extract the contents to a folder.
- Move the contents of the /Kerbal Space Program folder ('GameData' and 'Ships' folders) into your /Kerbal Space Program folder (and overwrite if you are updating).

- It should now look like this:
    Kerbal Space Program/GameData/StarshipInterface  (location of the patch)
    Kerbal Space Program/Ships/Script  (here the kOS scripts are saved)
    Kerbal Space Program/Ships/VAB  (location of the .craft files)


# IMPORTANT!:
- Works best with the provided .craft files ("Starship Cargo", "Starship Crew", "Starship Tanker") located inside the stock craft category (left hand side) in the VAB's vessel loading menu. These can be found if you enable stock vehicles in your savegame, or you copy them manually to your savegame. Real Size ships are for using with RSS.
- Before filing a bug, read the "Bug support guide" at the bottom of this page.

# REQUIRES:
- Stock-size Kerbin, RSS, any 2.5-2.7x sized planet pack, and the language in KSP has to be set to "english" (important).
- Starship Expansion Project - github repository DEV (!!) version and its requirements (!!)
    https://forum.kerbalspaceprogram.com/index.php?/topic/206555-1101-112x-starship-expansion-project-sep-v101-january-30th-2022/
    Github version: https://github.com/Kari1407/Starship-Expansion-Project/tree/V2.1_Dev
- Starship Launch Expansion - the DEV version(!!)
    https://forum.kerbalspaceprogram.com/index.php?/topic/203952-1129-starship-launch-expansion-v05-beta-may-31/&tab=comments#comment-4008229
    Dev Version: https://github.com/SAMCG14/StarshipLaunchExpansion/tree/Dev
- kOS
    https://forum.kerbalspaceprogram.com/index.php?/topic/165628-ksp-1101-and-111-kos-v1310-kos-scriptable-autopilot-system/
- Trajectories, and its requirements!
    https://forum.kerbalspaceprogram.com/index.php?/topic/162324-18-112x-trajectories-v241-2021-06-27-atmospheric-predictions/
- TundraExploration (actually only TundraExploration.dll)
    https://forum.kerbalspaceprogram.com/index.php?/topic/166915-112x-tundra-exploration-v600-january-23rd-restockalike-spacex-falcon-9-crew-dragon-xl/
- Kerbal Joint Reinforcement Continued
    https://github.com/KSP-RO/Kerbal-Joint-Reinforcement-Continued

# RECOMMENDED:
- HangarExtender (Recommended for being able to load cargo without moving the whole ship up and down)
    https://spacedock.info/mod/1428/HangerExtender#stats

# INCOMPATIBLE(!!):
- TweakableEverything
- Ferram AeroSpace Research (FAR)
- Realism Overhaul (RO)


# Known Issues:
- Auto-docking is currently broken until Kari fixes the dev version of SEP.
- Users reported booster catch may fail if you have MechJeb and the Q or G Limiter reduces thrust where the script wouldn't do that.
- On non-stock Kerbin upon booster-catch the tower may be glitching/jumping due to Kraken.


# Bug support guide:
- check first that you fulfill the requirements above (check Incompatible Mods!!) and carefully read this whole page.
- If you have many mods installed, try moving unnecessary mods away from /gamedata temporarily. The less mods, the better (Only SEPs requirements and those of this mod).
- If you still get script crashes that don't recover themselves: congratulations, you may have found a bug!
- Keep the kOS CPUs open (right hand side) and screenshot any errors or problems.
- Either:
    - File an issue on github, or
    - Write me on: KSP forum SEP thread, or
    - Write me on: SEP Discord
- Be sure to describe the problem as accurately as possible and add the screenshots.
- Videos would be very helpful as well if ship or booster does not perform properly.
- Looking forward to your bugs!


# By the author:
This has been a pet project of mine since around May 2021, and I had a lot of fun making and using this Interface. I hope you will too! Let me know what you think! I thank all the mod makers whose work I have been able to rely on, and without whom none of this would have been possible. Especially I want to thank Kari, Sofie, all others that have contributed to SEP and SAMCG14 for his work on SLE.
