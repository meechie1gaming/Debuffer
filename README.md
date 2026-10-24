# Debuffer

Windower 4 addon for FFXI. Uses a cure item on you as soon as you get a debuff it tracks, and keeps using it until the debuff is gone.

**Author:** Meechie
**Version:** 1.8

## Install

1. Create `Windower/addons/Debuffer/`
2. Put `Debuffer.lua` in that folder
3. In game: `//lua load debuffer`

To load it every time, add `lua load debuffer` to `Windower/scripts/init.txt`.

## Commands

There are no addon commands. It runs while loaded.

| Command | What it does |
| --- | --- |
| `//lua load debuffer` | Turns auto-curing on |
| `//lua unload debuffer` | Stops all cure loops and turns it off |

## What It Cures

| Debuff | Items tried, in order |
| --- | --- |
| Poison | Antidote, Remedy |
| Blindness | Eye Drops, Remedy |
| Paralysis | Remedy |
| Silence | Echo Drops, Remedy |
| Disease | Remedy |
| Curse | Holy Water |
| Doom | Holy Water |

## How It Works

- When you gain a tracked debuff, it uses the first item from the list that you have.
- If an item was used, it checks again 2.5 seconds later and uses another if the debuff is still on.
- If you have none of the items, it posts "No cure found" and checks again every 10 seconds.
- It stops as soon as the debuff wears off or is removed, and posts "Stopped curing".
- On load it checks the debuffs you already have.
- Keep the cure items in your inventory.
- Holy Water only has a chance to remove Doom, so it keeps trying every 2.5 seconds until Doom is gone.

## Chat Output

```
[Debuffer] >>> Using "Echo Drops" to cure [silence]!
[Debuffer] Stopped curing silence
[Debuffer] No cure found for doom
```

## Changing the Cure List

Edit the two tables under `Cure Map` at the top of `Debuffer.lua`:

- `debuff_item_map`: which items to try for each debuff, in order
- `item_valid_for_buff`: which debuffs each item is allowed to cure

An item has to be listed in both tables for a debuff before it will be used.
