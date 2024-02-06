# KSP_Starship-kOS-Interface V2
A **kOS Interface** for the **Starship Expansion Project** in Kerbal Space Program.


![Alt text](/Infographic.png)


## Installation:
- Download and install all requirements listed below (pay attention: SLE and SEP both need the DEV branch (not available on CKAN). They can be downloaded by changing from main to dev branch and clicking the github green button download-all, not the releases).
- If you update: first delete the _StarshipInterface_ folder!
- Download the zip file.
- Extract the contents to a folder.
- Move the contents of the _/Kerbal Space Program_ folder (_GameData_ and _Ships_ folders) into your /Kerbal Space Program folder (and overwrite if you are updating).

- Correct folders:
    _Kerbal Space Program/GameData/StarshipInterface_    (location of the patch)
    _Kerbal Space Program/Ships/Script_                  (here the kOS scripts are saved)
    _Kerbal Space Program/Ships/VAB_                     (location of the .craft files)

- **Optional:** If you wish to use **_Parallax_** on a stock Kerbin, move _SEPKOS patch for stock Kerbin with Parallax.cfg_ to the StarshipInterface folder.

> [!IMPORTANT]
> - Use the provided .craft files (e.g. _Starship Cargo_) located inside the stock craft category in the VAB's vessel loading menu (left hand side). This needs _stock vehicles_ enabled in your savegame.
> - Real Solar System: use _Starship xxx Real Size_ ships.




### REQUIRES:
- Stock-size Kerbin or Real Solar System or KSRSS or SigmaDimensions (2.5-2.7x)

- KSP language set to English

- Starship Expansion Project - [github repository DEV version](https://github.com/Kari1407/Starship-Expansion-Project/tree/V2.1_Dev)
  - [Forum](https://forum.kerbalspaceprogram.com/topic/206555-112x-starship-expansion-project-sep-v2031-november-20th-2023/)

- Starship Launch Expansion - [github repository DEV version](https://github.com/SAMCG14/StarshipLaunchExpansion/tree/Dev)
  - [Forum](https://forum.kerbalspaceprogram.com/index.php?/topic/203952-1129-starship-launch-expansion-v05-beta-may-31/&tab=comments#comment-4008229)

- [kOS](https://github.com/KSP-KOS/KOS/releases)
  - [Forum](https://forum.kerbalspaceprogram.com/index.php?/topic/165628-ksp-1101-and-111-kos-v1310-kos-scriptable-autopilot-system/)

- [Trajectories](https://github.com/neuoy/KSPTrajectories/releases), and its requirements!
  - [Forum](https://forum.kerbalspaceprogram.com/index.php?/topic/162324-18-112x-trajectories-v241-2021-06-27-atmospheric-predictions/)

- [TundraExploration](https://github.com/TundraMods/TundraExploration/releases) (actually only TundraExploration.dll)
  - [Forum](https://forum.kerbalspaceprogram.com/index.php?/topic/166915-112x-tundra-exploration-v600-january-23rd-restockalike-spacex-falcon-9-crew-dragon-xl/)

- [Kerbal Joint Reinforcement Continued](https://github.com/KSP-RO/Kerbal-Joint-Reinforcement-Continued)
  - [Forum](https://forum.kerbalspaceprogram.com/topic/184019-131-14x-15x-16x-17x-kerbal-joint-reinforcement-continued-v340-25-04-2019/)

### RECOMMENDED:
- [HangarExtender](https://spacedock.info/mod/1428/HangerExtender) (easier cargo loading)

### INCOMPATIBLE(!!):
- TweakableEverything
- Ferram AeroSpace Research (FAR)
- Realism Overhaul (RO)
- CKAN


### Known Issues:
- Tank mismatch error:
    - Stock: Check that you don't have _Kopernicus_ installed.
    - Planet mod: Check that you have _Kopernicus_ AND your planet mod properly installed.
    - Check that you removed old versions of SEP and the Interface before installing the new ones.
- Mechjeb Q or G Limiter could cause launch failures.
- On non-stock Kerbin the tower may be glitching upon booster-catch due to the Kraken.


### Bug support guide:
- First carefully read this whole page!
- If you have many mods installed, try moving unnecessary mods away from _/gamedata_ temporarily. The less mods, the better (Only SEPs requirements and those of this mod).

- If you still get script crashes that don't recover themselves: congratulations, you may have found a bug!
- Keep the kOS CPUs open (right hand side) and screenshot any errors or problems.
- Either:
    - File an issue on github, or
    - Write me on: KSP forum SEP thread, or
    - Write me on: SEP Discord
- Be sure to describe the problem as accurately as possible and add the screenshots.
- Videos would be very helpful as well if ship or booster does not perform properly.
- Looking forward to your bugs!


### By the author:
This has been a pet project of mine since around May 2021, and I had a lot of fun making and using this Interface. I hope you will too! Let me know what you think! I thank all the mod makers whose work I have been able to rely on, and without whom none of this would have been possible. Especially I want to thank Kari, Sofie, all others that have contributed to SEP and SAMCG14 for his work on SLE.
