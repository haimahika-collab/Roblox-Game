# The Last Delivery

A Roblox cooperative horror prototype for 1–4 players. Deliver three parcels to a silent neighborhood, obey the tenants' instructions, and get the whole crew back to the van before dawn.

## Play in Roblox Studio

### New: unpredictable deliveries

Each shift shuffles three tasks across the addresses. The HUD shows both the safety rule and the current task; the gold marker points to the correct interaction.

- **Mailbox:** put the parcel in the roadside mailbox, rather than at the door.
- **Signature:** interact at the door, wait three seconds for the tenant, then interact again to collect the signature.
- **Photo proof:** place the parcel at the door, walk to the gold street marker, turn your character toward the door, and use **Take photo**. This is an in-game proof action, not a saved screenshot or camera upload.

Approaching an address with its parcel triggers one random atmospheric encounter: a window silhouette, a three-second streetlight outage, or knocking-from-the-parcel captions. These events do not deal surprise damage. Encounters and temporary lights reset between shifts.

The **dispatch radio** displays queued story captions from dispatch, tenants, and an unknown signal. Press **R** (controller D-pad Up) to replay the last transmission once the radio is idle. This version uses text transmissions, not recorded voice or knocking audio. The mission panel background is transparent.

### Open the place

1. Download/open `build/LastDelivery.rbxlx` in Roblox Studio (generated with the build command below).
2. Press **Play**, not Run, to spawn a character and the HUD.
3. Follow the gold **COLLECT PARCEL 13** marker to the box beside the van. Press **E** once (or tap the prompt) to collect it.
4. Follow the gold destination marker to houses **13 → 27 → 41**, returning to the pickup box for each parcel. Houses have large illuminated roadside numbers and number plates above the doors.
5. After the third delivery, bring living teammates within 28 studs of the van and interact with the driver door on its left side.

The environment is generated automatically when the server starts. No external models, audio assets, credentials, HTTP access, or DataStores are required. Use Studio's **Server & Clients** test mode with two clients to test cooperation. Set the published experience's maximum player count to **4** in Roblox's experience settings; the prototype also enforces a four-player server limit.

## Controls and rules

| Action | Keyboard | Controller | Mobile |
| --- | --- | --- | --- |
| Interact | E / on-screen prompt | Prompt's displayed button | Tap prompt |
| Flashlight | F | Y | Light button |
| Sprint | Hold Left Shift | Hold L3 | Hold Sprint button |

- **House 13:** deliver once. Ringing a completed house again enrages the follower.
- **House 27:** release sprint and wait at least three seconds after running before delivery.
- **House 41:** turn the flashlight off before delivery.
- Sprinting and flashlights increase the follower's detection range. Breaking a rule makes it faster for 12 seconds.
- The well-lit van area is safe. The follower cannot attack players at or behind the street's safe boundary.
- Being caught deals damage. Death returns you to dispatch after five seconds and returns your parcel to the hatch. This forgiving prototype lets the crew continue the route.
- The shift lasts ten minutes. Victory or timeout starts a 15-second intermission, then another shift automatically begins.

## Development

The project uses **Rojo 7.5.1** and **Luau 0.693**. On Linux x86_64:

```sh
./tools/bootstrap.sh
./tools/check.sh
```

The check script runs the rule regression suite, compiles every Luau source, and builds `build/LastDelivery.rbxlx`. Generated files and downloaded tools are ignored by Git. To sync edits live with the official Rojo Studio plugin:

```sh
tools/bin/rojo serve default.project.json
```

Connect the plugin to the displayed server address. Studio runs on your own Windows or macOS machine; this Linux cloud workspace cannot execute the Roblox engine.

### Project layout

- `src/server/Main.server.luau`: generated neighborhood, authoritative interactions, round lifecycle, parcel ownership, flashlight/sprint state, and follower movement/damage.
- `src/client/Main.client.luau`: responsive dispatch HUD, input bindings, notices, and damage/scare overlay.
- `src/shared/Config.luau`: route, timing, speed, damage, and detection tuning.
- `src/shared/Rules.luau`: delivery and detection rules exercised by `tests/Rules.spec.luau`.

### Studio acceptance checks

These require the Roblox engine and are not replaced by command-line checks:

- Complete all three deliveries solo, then escape from the driver door. Verify the next round resets the route.
- Verify every shift contains one mailbox, one signature, and one photo task. Confirm the marker and available prompt follow each task stage. Try collecting a signature too early and taking a photo while facing away; neither should finish the delivery.
- Die or disconnect after placing a photo parcel and verify that dispatch offers it again with a fresh task. Verify encounter lights restore and silhouettes disappear after their timers, including across round resets. Check radio captions on both clients and replay using R.
- From spawn, walk straight down the center of the street without jumping; the van must not block you. Verify parcel pickup works with one E press/tap, the marker changes to house 13, and all three roadside address signs are readable from the road.
- Attempt delivery without a parcel, at the wrong address, and at an already completed address. Only the correct carrier/address should advance the route.
- Sprint to house 27 and attempt delivery immediately; retry after walking and waiting. At house 41, try with the light on, then off.
- Let the follower approach and attack. Verify damage, death, respawn, parcel recovery, and safety by the van.
- With two clients, collect a parcel on one client and verify the other sees the carrier's name and cannot deliver it. Disconnect or die while carrying; verify the parcel can be collected again.
- With two living players, try escaping while one is far away; regroup and retry.
- Temporarily lower `RoundSeconds` locally to verify timeout, intermission, and replay. Restore the tuning afterward.
- Check touch/gamepad controls in Studio's device emulator and inspect Output for runtime errors.

## Prototype scope

This is an original asset-free blockout, with fixed house order, shuffled delivery tasks, random atmospheric encounters, a caption-based dispatch radio, and a simple follower constrained to the open street corridor. It does not yet include driving, procedural routes, sound design, saved progression, monetization, or a learning monster. Multiplayer replication, physics, visual balance, and engine behavior still need Studio playtesting before release.
