# Ohio 2 Development Roadmap

## Build 0.1 — Core loop

- Server-controlled cash, bank, heat, purchases, damage, and rewards
- Persistent inventory and stash with a safe Studio fallback
- Death bags containing carried gear and 25% of wallet cash
- Legal delivery job and risky convenience-store robbery
- Pistol, bat, medkit, two police NPCs, and arcade car
- Editable prototype neighborhood and responsive HUD

## Build 0.2 — Combat foundation

- Pistol and shotgun magazines, ammunition purchases, reloading, recoil, tracers, headshots, and hitmarkers
- Downed state, three-second player revives, bleed-out timer, and finishing damage
- Police pathfinding, arresting, wallet fines, jail, and release flow
- Remaining: animations, sound design, armor, bounty payouts, shot history, and stronger exploit detection

## Build 0.3 — Street survival

- Permanent non-droppable fists on every spawn
- Three-hit combo with 10/12/18 damage and heavy-hit knockback
- Directional melee blocking with reduced movement speed
- Server-controlled sprinting, stamina drain, and regeneration
- Ten-second spawn protection that ends early on attacking or robbery
- Live health, stamina, protection, sprint, and block HUD feedback

## Build 0.4 — Loot & bounty

- Seven searchable dumpsters, crates, and rare safes with global refill timers
- Contested server-wide supply drops with one winner and a two-minute expiry
- Persistent criminal bounties from robbery and player takedowns
- Recent-attacker validation and full bounty payouts on a wanted player's death
- Arrest clears heat and bounty; HUD shows heat and bounty independently
- Ammo persistence raised to support larger loot rewards safely

## Build 0.5 — Expanded district

- Map expanded from 520×520 to 900×900 studs with a six-road grid
- County Clinic, motel, foundry, auto shop, fire station, apartments, junkyard, courts, rail yard, and water tower
- Fifteen total searchable loot locations distributed across central and outer districts
- Working $75 full-health clinic treatment and a second drivable test car
- Detailed procedural pistol, pump shotgun, baseball bat, vehicle, facade, lighting, street-prop, muzzle-flash, and casing assets
- Improved police search radius and supply-drop coverage for the larger world

## Build 0.6 — Living district

- Reusable server-validated route-job framework connecting outer-district POIs
- Medical courier, salvage delivery, and foundry freight jobs paying $575, $500, and $700
- Armored-truck world event with five spawn areas, an eight-second breach, maximum heat, and a $1,500 bounty
- Synchronized sixteen-minute day/night cycle with HUD phase feedback
- Forty-five-second citywide blackouts that disable powered lights and neon, then restore exact prior states
- Accelerated first-event timings for practical two-player Studio testing

## Build 0.7 — Realism & admin

- Replaced distance-based floating world labels with physical `SurfaceGui` signs mounted to map parts
- Added four permanent double-sided roadside billboard structures with steel posts and concrete footings
- Added a purchasable lift-balloon tool and server-controlled 82-power high jump while equipped
- Added configurable user-ID admin authorization, automatic owner access, and Studio-only test access
- Added a keyboard/touch command console with server-side target resolution, rate limits, audit output, and gameplay/world commands
- Added benches, fire hydrants, and road-repair patches for more believable street dressing

## Build 0.8 — City life

- Rebuilt the pistol and shotgun at believable Roblox avatar scale with new grips, receivers, barrels, sights, pumps, stocks, and hold offsets
- Added ten civilian NPCs with six sidewalk routes, wanted-player fleeing, death respawning, and a live population HUD count
- Added server-authoritative civilian/officer assault consequences with cooldown-protected heat and bounty increases
- Added repeatable Rust Belt Auto tow calls with three recovery locations, staged objectives, anti-teleport timing checks, and a fast-return bonus
- Added stocked convenience-store shelves and coolers, clinic monitors and curtains, plus garage lifts and tool cabinets
- Added the `civilians respawn` admin command and preserved all 0.7 admin authorization boundaries

## Build 0.9 — Crime response

- Upgraded Quick Stop into a two-stage register and timed back-room safe robbery with separate payouts, bounties, cooldowns, objectives, and a physical alarm beacon
- Added heat-scaled police dispatch: two baseline patrol officers expand to as many as six response units
- Added server-controlled officer equipment, line-of-sight ranged attacks at three-plus heat, police-contact-aware heat decay, and live response/officer HUD state
- Added clear, overcast, and rain weather presets with synchronized world atmosphere plus local precipitation
- Added dusk/night-only streetlight operation and a permanent Foundry Road police checkpoint
- Added secure `weather clear|overcast|rain` admin control while preserving the server-only user-ID authorization gate

## Build 1.0 — Phone & contracts

- Added a keyboard/touch phone with Daily, Contacts, and Profile pages
- Added four deterministic UTC-daily contract types tied to tow calls, legal jobs, fresh searches, and successful police escapes
- Added server-only progress advancement, one-time bank rewards, live attribute replication, and saved progress/claim state
- Added a physical phone-network help kiosk beside spawn
- Added the server-authorized `contracts reset <target>` admin testing command
- Remaining social roadmap: crews, party objectives, guarded crew stashes, trading, multiple missions, vehicle ownership, garages, fuel, repair, and customization

## Build 1.1 — Vehicle ownership

- Added permanent Rust Compact ownership purchased at Rust Belt Auto for $3,500
- Added server-controlled per-player spawning/storage with one active owned vehicle and locked driver access
- Added persistent fuel and condition plus live HUD and phone Profile state
- Added throttle-based fuel drain, collision condition damage, low-condition smoke, and disabled states
- Added Quick Stop refueling and Rust Belt Auto repair pricing with proximity validation
- Added secure admin grant, revoke, refuel, repair, and despawn actions
- Preserved two unlimited-fuel public test cars for immediate multiplayer testing

## Build 1.2 — Audio + weapon art

- Rebuilt the 9mm pistol and pump shotgun at tighter avatar scale with detailed controls, sights, action parts, and hold offsets
- Added client-side articulated pistol slide, removable magazine, shotgun pump, smaller casings, impact marks, material sparks, and thinner tracers
- Added a shared `SoundDefinitions` catalog with per-effect volume, pitch, variance, and 3D rolloff controls
- Added spatial pistol, shotgun, bullet-impact, melee-contact, dry-fire, and reload audio
- Added locally simulated surface-aware footsteps for every visible character while muting the duplicate default running loop
- Added replicated dynamic engine load/pitch, condition sputter, collision audio, and a server-validated driver horn
- Kept damage, ammunition, reloading, melee contact, vehicle ownership, and horn authorization server-controlled

## Current build — 1.3 World + gunplay

- Rebuilt desktop gun input around a locked center-screen crosshair and an over-shoulder camera offset
- Replaced mouse-hit targeting with a camera origin/direction request plus server-side character ray validation
- Allowed full-range shots into open space and improved Humanoid resolution through hats and other accessory descendants
- Moved pistol, shotgun, and police reports to server-created spatial sounds so every nearby player hears the same shot
- Increased common and rare search resets to five and ten minutes, register robbery to ten minutes, and the back-room safe to twenty minutes
- Replaced rapid fixed event loops with randomized production windows for supply drops, armored trucks, weather, and blackouts
- Added gutters, curbs, worn lane markings, utility poles and continuous wires, civic planters, improved trees, and parked traffic
- Added six authored commercial/industrial infill facades plus four West End porch houses to establish district-specific composition
- Enriched reusable POI facades with foundations, parapets, side windows, mullions, sills, awnings, roof equipment, and downspouts
- Rebuilt the Rust Compact as a muted four-door sedan with a detailed cabin, glass, pillars, door skins, mirrors, wheels, grille, lighting, plates, and exhaust

## Build 1.4 — Public testing

- Mobile/controller UX pass and low-end device performance budgets
- Tutorial funnel, analytics, crash/error logging, moderation tools, and reports
- Private test group, balance resets, patch notes, thumbnail/icon work
- Only then: monetization, discovery testing, and creator outreach

## Rule for every build

Every expansion must strengthen the spawn → earn → risk → escape → stash loop and pass a thirty-minute, five-player test before the next district is added. A smaller polished game beats a huge empty one.
