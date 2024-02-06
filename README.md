# KSP_Starship-kOS-Interface V2
An Interface for automating the 'Starship Expansion Project' and 'Starship Launch Expansion' mods within Kerbal Space Program.


![Alt text](/Infographic.png)


# INSTALL INSTRUCTIONS (NO CKAN SUPPORT!):
- Download and install all requirements listed below (pay attention: SLE and SEP both need the DEV branch (not available on CKAN). They can be downloaded by changing from main to dev branch and clicking the github green button download-all, not the releases).
- If you update: first delete the 'StarshipInterface' folder!
- Download the zip file.
- Extract the contents to a folder.
- Move the contents of the /Kerbal Space Program folder ('GameData' and 'Ships' folders) into your /Kerbal Space Program folder (and overwrite if you are updating).

- Correct folders:
    Kerbal Space Program/GameData/StarshipInterface     (location of the patch)
    Kerbal Space Program/Ships/Script                   (here the kOS scripts are saved)
    Kerbal Space Program/Ships/VAB                      (location of the .craft files)

- Optional: If you wish to use Parallax on a stock kerbin, move "SEPKOS patch for stock Kerbin with Parallax.cfg" to the StarshipInterface folder.


# IMPORTANT!:
- Use the provided .craft files (e.g. "Starship Cargo") located inside the stock craft category in the VAB's vessel loading menu (left hand side).
    - This needs stock vehicles enabled in your savegame. Real Solar System: use "Starship xxx Real Size" ships.
- Before filing a bug, read the "Bug support guide" at the bottom of this page.


# REQUIRES:
- Stock-size Kerbin or Real Solar System or KSRSS or SigmaDimensions (2.5-2.7x)

- KSP language set to English

- Starship Expansion Project - github repository DEV version
    https://forum.kerbalspaceprogram.com/topic/206555-112x-starship-expansion-project-sep-v2031-november-20th-2023/
    https://github.com/Kari1407/Starship-Expansion-Project/tree/V2.1_Dev

- Starship Launch Expansion - github repository DEV version
    https://forum.kerbalspaceprogram.com/index.php?/topic/203952-1129-starship-launch-expansion-v05-beta-may-31/&tab=comments#comment-4008229
    https://github.com/SAMCG14/StarshipLaunchExpansion/tree/Dev

- kOS
    https://forum.kerbalspaceprogram.com/index.php?/topic/165628-ksp-1101-and-111-kos-v1310-kos-scriptable-autopilot-system/
    https://github.com/KSP-KOS/KOS/releases

- Trajectories, and its requirements!
    https://forum.kerbalspaceprogram.com/index.php?/topic/162324-18-112x-trajectories-v241-2021-06-27-atmospheric-predictions/
    https://github.com/neuoy/KSPTrajectories/releases

- TundraExploration (actually only TundraExploration.dll)
    https://forum.kerbalspaceprogram.com/index.php?/topic/166915-112x-tundra-exploration-v600-january-23rd-restockalike-spacex-falcon-9-crew-dragon-xl/
    https://github.com/TundraMods/TundraExploration/releases

- Kerbal Joint Reinforcement Continued
    https://forum.kerbalspaceprogram.com/topic/184019-131-14x-15x-16x-17x-kerbal-joint-reinforcement-continued-v340-25-04-2019/
    https://github.com/KSP-RO/Kerbal-Joint-Reinforcement-Continued

# RECOMMENDED:
- HangarExtender (Recommended for being able to load cargo without moving the whole ship up and down)
    https://spacedock.info/mod/1428/HangerExtender

# INCOMPATIBLE(!!):
- TweakableEverything
- Ferram AeroSpace Research (FAR)
- Realism Overhaul (RO)


# Known Issues:
- If you get the tank mismatch error:
    - Stock: Check that you don't have Kopernicus installed.
    - Planet mod: Check that you have Kopernicus AND your planet mod properly installed.
    - Check that you removed old versions of SEP and the Interface before installing the new ones.
- Users reported booster catch may fail if you have MechJeb and the Q or G Limiter reduces thrust where the script wouldn't do that.
- On non-stock Kerbin the tower may be glitching/jumping upon booster-catch due to the Kraken.


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
