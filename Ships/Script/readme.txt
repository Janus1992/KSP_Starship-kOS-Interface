-----------------README-----------------
Janus92s SEP kOS Scripts



IMPORTANT:
-Works only with the provided .craft files ("Starship Cargo", "Starship Crew", "Starship Tanker").


REQUIRES:
-Starship Expansion Project and its dependencies
-Trajectories
-kOS
-TundraExplorations "TundraExploration.dll" (absolutely required for Booster Landing)
-Starship Launch Expansion (for the tower)

OPTIONAL:
-Community Resource Pack (for using "liquid methane" as fuel instead of ksp's standard "liquid fuel").

DOES NOT WORK WITH:
-RSS/RO
-FMRS
-Cryotanks


Version 1.0 - GNUGPL3
// Janus92



------------Issues identified:------------
- SEP & SLE need finishing:
        - Booster/Ship Recovery/ Automatic Re-Stacking operations incomplete.
        - Booster/Ship Docking doesn't work.
        - SLE Tower doesn't produce Liquid Methane for refueling.
        - SEP Booster Engines can't switch the three modes of operation.
        - SEP Ship Flap Angle is not published/available for reading.
        - SEP Booster and Ship mass is wrong:
                - Booster returns with too much fuel (w/ payload: 69t).
                - Crew Ship has same nose weight as empty cargo/tanker:
                        - 5-10 tons of additional weight would be more realistic and still aerodynamically acceptable.
- Auto-docking balance rcs.

- Scripts can probably handle only 1 OLM.


List of seldomly encountered errors:


List of problems encountered by others, but not by me:
        - Duna landing oscillations.


-------------------Ideas--------------------
- Tooltips for main screen info text?
- Use Scrollbox or page enlargement for added functions?
        - Maneuver Page:
                - Suicide Burn?
                -
        - Cargo Page:
                - Operate winch to load/unload cargo/crew?

- Additional Settings?:
        - Target Orbit Inclination?
        - Automatic Re-Stack enable/disable?
