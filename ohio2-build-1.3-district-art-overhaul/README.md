# Ohio 2 — World + Gunplay Prototype 1.3

Build 1.3 is a world-authorship and gunplay reliability pass. The district now has curb-and-gutter street edges, worn markings, permanent utility lines, older storefront infill, West End porches, industrial facades, civic planters, improved trees, parked traffic, and a rebuilt slate-blue Rust Compact with a recognizable four-door sedan silhouette and detailed interior. Guns now lock desktop aim to an exact center-screen crosshair, raycast from the camera through that crosshair, validate damage from the character on the server, reliably find Humanoids through accessories, fire into open sky, and create server-replicated spatial reports that every nearby player can hear. Search, robbery, weather, blackout, supply-drop, and armored-truck pacing now uses production-length cooldowns with randomized event windows. Build 1.2's weapon art/audio and every earlier vehicle, contract, crime, police, NPC, job, and admin system remain included.

## Install it in Roblox Studio

1. Extract this ZIP somewhere easy to find.
2. Open `Ohio2_Installer.lua` in Notepad, VS Code, or another text editor.
3. Press **Ctrl+A**, then **Ctrl+C** to copy the entire file.
4. Open your blank baseplate in **Roblox Studio**. Make sure you are **not** currently play-testing.
5. Press **Ctrl+9** to open the Command Bar at the bottom. You can also use the **Script** toolbar or **Window → Script → Command Bar**.
6. Click the Command Bar, paste the script, and press **Ctrl+Enter** once (or click its **Run** button).
7. Wait for `OHIO 2 WORLD + GUNPLAY 1.3 INSTALLED SUCCESSFULLY` in the Output window.
8. Press **Play**.

You can run the installer again to upgrade an earlier prototype. It replaces the prototype's exact named scripts and placeholder map, so save custom map edits elsewhere before rerunning it.

The installer only replaces objects carrying these exact prototype names: `Ohio2`, `Ohio2Server`, `Ohio2AdminServer`, `Ohio2Client`, `Ohio2AdminClient`, `Ohio2AdminConfig`, `Ohio2AdminBridge`, `Ohio2Tools`, `Ohio2Police`, `Ohio2CivilianTemplates`, `Ohio2VehicleTemplates`, `Ohio2Map`, `Ohio2Drops`, `Ohio2NPCs`, and `Ohio2Vehicles`. Roblox Studio's undo history receives before/after waypoints.

## Customize the sound effects

Run the installer, then open **Explorer → ReplicatedStorage → Ohio2 → Shared → SoundDefinitions**. Every audio entry has a `SoundId`, volume, pitch, variance, and 3D distance range. The included catalog uses Roblox Creator Store effects plus Roblox's built-in character sounds, so the prototype works immediately. Replace entries with audio uploaded or licensed for your experience; no combat, vehicle, or HUD code needs to change. If an asset is unavailable to the experience, grant it permission in Creator Dashboard or replace only that catalog entry.

## Set your admin user IDs

The installer includes a secure, dependency-free Cmdr-style console. It does not insert unofficial marketplace copies of Cmdr. Every command is permission-checked and executed on the server.

1. Run the installer, then open **Explorer → ServerStorage → Ohio2AdminConfig**.
2. Select **AdminUserIds**.
3. In **Properties → Value**, enter numeric Roblox user IDs separated by commas, such as `123456789, 987654321`.
4. The experience owner is automatically an admin when **CreatorIsAdmin** is enabled.
5. **StudioPlayersAreAdmin** is enabled for easy local testing; it has no effect in a live server.
6. Start a fresh test session after changing the list. Press **F2** or **semicolon (`;`)**, or tap the **CMDR** button.

Useful commands include `help`, `heal me`, `bring PlayerName`, `give me Balloon`, `cash all 500`, `setcash me 5000`, `heat PlayerName 5`, `bounty PlayerName 1500`, `speed me 30`, `jump me 100`, `event supply`, `event truck`, `civilians respawn`, `contracts reset me`, `vehicle me grant`, `vehicle me refuel`, `vehicle me repair`, `weather rain`, `weather overcast`, `weather clear`, `blackout on`, `day`, `night`, `announce message`, and `kick PlayerName reason`. Targets accept `me`, `all`, `others`, usernames, display names, unique name prefixes, and numeric user IDs.

## What to test

- Equip either gun on desktop. The mouse icon should disappear, the camera should move to an over-shoulder view, and the pointer should lock to the exact center-screen crosshair until the gun is unequipped or the phone opens.
- Aim the crosshair at a player's body, head, accessory, and an NPC accessory. The crosshair should turn red over a living Humanoid, hits should register consistently, and headshots should still receive their multiplier.
- Aim straight upward or into open space and fire. Ammunition, recoil, muzzle flash, report, and the full-range tracer should work even when the ray hits nothing.
- Fire each gun beside player two, then have player two walk away. The report is created by the server at the muzzle, should be heard by both users, and should roll off naturally with distance without a doubled local report.
- Walk the central, West End, Southline, and industrial blocks. Check that storefront ages and shapes vary, houses have porches and trim, utility wires form continuous streets, curbs meet sidewalks, and the new infill does not block jobs or roads.
- Compare the rebuilt Rust Compact with the earlier box car. Verify its four-door cabin, glass, pillars, lights, grille, mirrors, dashboard, seats, wheels, bumpers, plates, and muted paint read as one compact sedan at avatar scale.
- Compare the pistol and shotgun against build 1.1. They should sit closer to the avatar hand, no part should dominate the character, and the pistol slide, magazine, and shotgun pump should move during fire/reload feedback.
- Fire each gun near and far from player two. Reports and impacts must be spatial, must fade with distance, and the shotgun must produce one report rather than eight overlapping pellet reports.
- Shoot concrete, metal, wood, grass, and dirt. Impact color/pitch should vary, metal should spark more strongly, and temporary bullet marks should clean themselves up.
- Empty a magazine and attempt another shot to hear dry fire. Reload both guns and verify local mechanical audio, HUD state, and moving parts return to their exact resting positions.
- Punch and hit with the bat. Contact audio must only play after server-validated contact; swinging through empty air must not create a false hit sound.
- Walk and sprint across roads, sidewalks, metal, wood, grass, dirt, and sand. Footstep pitch/volume should react to floor material and movement speed without doubling Roblox's default running loop.
- Drive both public cars and an owned Rust Compact. Engine pitch should rise with speed and throttle; damaged owned cars should sputter, collisions should scale crash volume, and the loop must stop after leaving the seat.
- Press **H** while occupying a vehicle's driver seat. Nearby players should hear the horn; spamming H or pressing it outside a valid Ohio 2 driver seat must do nothing.
- Edit one `SoundDefinitions` entry, rerun a test, and verify the replacement propagates without editing combat scripts.
- Earn $3,500 wallet cash and buy the **Rust Compact** at Rust Belt Auto. A second purchase attempt must not charge again.
- Use the green personal-garage terminal to spawn the owned car in the marked bay. Use it again to store the active car and preserve fuel/condition.
- Have player two attempt to drive player one's Rust Compact. The non-owner must be ejected while either public test car remains freely drivable.
- Drive the owned vehicle and verify fuel drains only while throttle is applied. The top-right vehicle HUD and phone Profile must remain synchronized.
- Park beside the Quick Stop pump and refill at $3 per missing fuel unit. Refueling without the owned car nearby must fail.
- Hit a solid wall above collision speed to reduce condition. At 35% or lower the car should smoke; at zero it must stop driving.
- Bring the car into Rust Belt Auto's service bay and repair it for $8 per missing point with a $50 minimum.
- Store, rejoin an API-enabled test, and respawn the Rust Compact with its ownership, fuel, and condition intact.
- Test `vehicle me grant`, `vehicle me refuel`, `vehicle me repair`, `vehicle me despawn`, and `vehicle me revoke` from the authorized admin console.
- Press **P** or tap **PHONE**. Verify the phone opens on Daily and can switch between Daily, Contacts, and Profile without interrupting normal HUD updates.
- Check the assigned daily mission. Each player receives one UTC-daily contract determined by their user ID and the day: one tow, two legal jobs, five fresh searches, or one successful police escape.
- Complete the matching server activity and watch phone progress update immediately. Unrelated activities must not advance it.
- Claim a completed contract once. The $850–$1,250 reward must enter bank cash, the button must change to claimed, and repeated requests must pay nothing.
- Rejoin a published API-enabled test and confirm same-day progress and claimed status persist. A different UTC day should assign the next deterministic contract.
- As a Studio admin, run `contracts reset me` and confirm only that target's current progress/claim state resets.
- Inspect the phone's Contacts page for POI guidance and Profile for live wallet, bank, heat, bounty, and current objective.
- Read the physical CITY PHONE NETWORK kiosk beside spawn.
- Every spawn receives **Fists** automatically. Fists never drop on death and require no purchase.
- Equip Fists and click/tap three times. Punches deal 10, 12, then 18 damage; the heavy third hit knocks the target backward.
- Hold **F** while facing an attacker to block 65% of incoming melee damage. Blocking does not stop bullets or attacks from behind.
- Hold **Left Shift** to sprint. Stamina drains while moving and regenerates when sprinting stops. Touch-friendly Sprint and Block buttons are included.
- Newly spawned players receive ten seconds of protection. Attacking or starting a robbery ends it immediately.
- Read the district directory beside spawn, then explore County Clinic, Riverside Motor Lodge, Buckeye Foundry, Rust Belt Auto, Fire Station 17, West End Apartments, Eastside Salvage, Southline Courts, the rail yard, and the water tower.
- Inspect the permanent roadside billboard structures and building signs from far away. Their text is mounted to physical parts and no longer appears only when a player approaches.
- Buy a **Lift Balloon** for $200 at the vendor beside Southline Courts. Equip it to raise jump power from 50 to 82; unequip it to return to normal.
- Watch ten civilians follow sidewalk routes around the district. Wanted players cause nearby civilians to run; attacking one creates two heat and a $350 bounty.
- Start a tow call at **Rust Belt Auto**, secure the assigned disabled vehicle at the motel, apartments, or clinic, and return to the blue bay for $650 plus a $100 fast-return bonus.
- Compare the rebuilt pistol and shotgun in-hand. Both now use compact avatar-scale dimensions rather than the oversized 0.7 proportions.
- Inspect stocked Quick Stop shelves and coolers, clinic privacy curtains and patient monitors, and Rust Belt Auto lifts and tool cabinets.
- Search fifteen marked dumpsters, crates, lockers, and safes for cash, ammunition, shells, and occasional medkits. Common spots now refill after five minutes; rare spots refill after ten minutes.
- Take damage and visit **County Clinic**. The treatment prompt charges $75 and restores full health.
- Start the $575 **Medical Run** at County Clinic and deliver to Fire Station 17.
- Start the $500 **Salvage Run** at Eastside Salvage and deliver to Rust Belt Auto.
- Start the $700 **Foundry Freight** job at Buckeye Foundry and deliver to Southline Rail Yard. Only one job can be active at a time.
- For natural pacing, expect the first contested supply drop after a randomized 8–12 minutes, then every 15–25 minutes. Admins can use `event supply` for immediate testing. The gold beacon lasts two minutes, and only the first player to finish the three-second claim receives its high-value loot.
- Expect the first armored-truck event after a randomized 12–18 minutes, then every 25–40 minutes. Admins can use `event truck` for immediate testing. The robbery pays $1,800–$2,600, creates maximum heat, and adds a $1,500 bounty.
- Watch the world-status text above the objective. It reports weather, Quick Stop alarms, police response level, active officer count, and the sixteen-minute dawn/day/dusk/night cycle.
- Weather naturally changes after a randomized 5–8 minutes and then every 10–15 minutes. Admins can use `weather rain`, `weather overcast`, and `weather clear` for immediate testing. During rain, verify local precipitation follows the camera without becoming a server-wide part storm.
- Compare streetlights during day and night, and inspect the permanent Foundry Road police checkpoint plus the officers' vests, badges, belts, radios, caps, and sidearms.
- The first citywide blackout now arrives after a randomized 15–25 minutes and repeats every 30–50 minutes. Admins can use `blackout on` for immediate testing. Powered lighting and neon stay dark for 90 seconds before the grid recovers.
- Start a legal $350 delivery at **County Courier** and finish it at the green **Quick Stop** counter.
- Rob the red Quick Stop register for $700–$1,200. This starts the alarm, adds three heat and a $500 bounty, unlocks the back-room safe for 75 seconds, and empties the register globally for ten minutes.
- Hold the back-room safe prompt for ten seconds to steal another $1,200–$1,800. The safe adds maximum heat and $750 more bounty, then enters a twenty-minute global security lockout.
- Buy a bat, pistol, shotgun, ammunition, shells, or medkit from **Pawn & Tool**. Inspect the rebuilt multi-part weapon models, local muzzle flashes, and ejected casings.
- Equip a weapon from the Roblox hotbar and click/tap to use it. Guns follow the center crosshair; melee still follows the character's facing direction.
- Press **R** or use the HUD button to reload. Pistol and shotgun magazines consume carried ammunition.
- Shoot an avatar's head to test headshot damage, recoil, tracers, and hitmarkers.
- Reduce another player's health to zero to down them. A different player can hold their revive prompt for three seconds.
- Downing another player adds $200 to your own bounty. Finish a wanted player within the credit window to claim their full bounty as wallet cash.
- Raise heat from one through five stars and confirm police scale from search patrols to a maximum six-unit response. At three or more stars, officers with clear line of sight can fire their sidearms.
- Break police contact for at least 18 seconds, then wait for the 25-second heat tick. Heat must not cool while an officer remains within contact range.
- Get downed while wanted and let an officer reach you to test arrest, the wallet fine, bounty removal, and County Jail.
- Deposit wallet cash at the safehouse ATM.
- Stash carried equipment at the safehouse locker.
- Die while carrying equipment to see the loot-bag system. Banked cash and stashed gear remain safe.
- Drive either public slate-blue test car using normal Roblox controls, then compare it with the persistent owner-locked Rust Compact.

## Important saving note

The game safely falls back to temporary session data when DataStore access is unavailable. Live published servers can use DataStores normally. To test saving inside Studio, publish a separate test experience and enable **Game Settings → Security → Enable Studio Access to API Services**. Avoid enabling Studio access against valuable live data.

## Installed Explorer structure

```text
ReplicatedStorage
└── Ohio2
    ├── Remotes
    └── Shared
        ├── ItemDefinitions
        └── SoundDefinitions
ServerScriptService
├── Ohio2Server
└── Ohio2AdminServer
ServerStorage
├── Ohio2Tools
├── Ohio2Police
├── Ohio2CivilianTemplates
├── Ohio2VehicleTemplates
├── Ohio2AdminConfig
└── Ohio2AdminBridge
StarterPlayer
└── StarterPlayerScripts
    ├── Ohio2Client
    └── Ohio2AdminClient
Workspace
├── Ohio2Map
├── Ohio2Drops
├── Ohio2NPCs
└── Ohio2Vehicles
```

## Prototype limitations

- The buildings, props, vehicles, civilians, and articulated weapons are editable low-poly models generated from Roblox parts, not final textured mesh art.
- Build 1.3 provides centered aiming plus procedural slide, magazine, pump, recoil, impact, and sound feedback. Full-body equip/reload animation tracks still require animation assets published by the experience owner.
- The included audio catalog is editable and intentionally centralized. Custom studio-recorded sounds should replace individual entries after they are uploaded and permissioned for the experience.
- Fists still use the standard Roblox tool pose until owner-published full-body combat animations are added.
- Police now scale, pathfind, arrest, and use validated line-of-sight gunfire, but they do not yet drive pursuit vehicles, flank as squads, or use cover.
- Phone contacts are informational rather than player-to-player messaging. Crews, parties, trading, multiple simultaneous missions, and real-time push notifications remain future systems.
- Vehicles use a lightweight server-authoritative arcade controller without suspension, gears, doors, headlights controls, cosmetic customization, or pursuit AI.
- The inventory is intentionally small and does not yet include a trading UI.
- Search-container placements are fixed for learnability; supply drops and armored trucks choose among multiple authored spawn areas.
- Dynamic events now use longer randomized production pacing. Use the authorized admin commands when testing an event on demand.
- The bundled admin console provides the needed Ohio 2 commands but is not the third-party Cmdr package. If the project later adopts official Cmdr through a source/Rojo workflow, keep the same server-only ID authorization boundary.

Keep this ZIP. The included `src` folder contains the readable source files we will improve in later versions.
