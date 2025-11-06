# BanManager

A comprehensive mod for Hades 2 that allows you to ban specific boons, hexes, and upgrades from various sources, giving you fine-grained control over your runs.

The mod uses a config menu configuration instead of profiles. It supports bonus Olympians such as Artemis, Athena, and Dionysus, as well as NPC blessings from Arachne, Narcissus, Echo, Hades, Medea, and Circe. Additionally, it allows for banning Selene spells and Daedalus upgrades, and includes an option to force the first boon to be Epic rarity.

## Features

### Boon/Hex Banning
- **God Boons**: Ban individual boons from all Olympian gods (Zeus, Poseidon, Athena, etc.)
- **NPC Blessings/Curses**: Ban specific offerings from NPCs like Arachne, Narcissus, Circe, etc.
- **Selene Spells**: Ban individual lunar spells from Selene encounters
- **Daedalus Upgrades**: Ban specific hammer upgrades (Staff, Dagger, Axe, Torch, Lob, Suit)
- **Hades Keepsakes**: Separate banning controls for keepsake boons vs. regular Hades boons

## Installation

- Install from Thunderstore mod using any mod manager (e.g., r2modman)

## Usage

### In-Game Menu
- Press the configured key to open the mod menu (default: Configure menu in ImGui)
- Enable "BanManager" to activate the mod
- Use the collapsible sections to ban/unban specific boons from each source
- "Reset All Bans" button to clear all bans at once

### Configuration
The mod uses Chalk for persistent configuration. Settings are saved automatically:
- `BanManager`: Master toggle for the mod
- `ForceFirstBoonEpic`: Force minimum Epic rarity for first boon encounter
- Packed config variables store the ban masks efficiently

### Ban Interface
- Each god/NPC/source has its own section
- Checkboxes toggle individual boons on/off
- Banned count is displayed next to each source name
- Red coloring indicates banned items

## Technical Details

### Architecture
- **main.lua**: Mod initialization and dependency loading
- **config.lua**: Persistent configuration with bit-packed storage
- **imgui.lua**: Real-time UI for ban management
- **mods/ban_manager.lua**: Core logic for filtering and rarity forcing

### Function Hooks
- `IsTraitEligible`: Filters banned traits from appearing
- `GetEligibleSpells`: Filters banned Selene spells
- `GetRarityChances`: Forces Epic rarity for first boon set
- `AddTraitToHero`: Resets rarity forcing after first boon

### Performance
- Bit-packed configs reduce memory usage
- Efficient lookups using pre-built trait mappings
- Minimal function wrapping to avoid performance impact

## Compatibility

- Requires Hell2Modding framework
- Compatible with other mods that don't conflict with trait filtering
- May conflict with mods that modify boon selection or rarity systems

## Troubleshooting

### Mod Not Loading
- Verify Hell2Modding is properly installed
- Check mod folder structure
- Enable mods in Hades 2 launcher

### Bans Not Applying
- Ensure "BanManager" is enabled in the menu
- Try reloading the mod with ReLoad
- Check that banned boons aren't forced by other systems

### UI Not Appearing
- Access via the "Configure" menu in ImGui
- Verify ImGui is enabled in your mod setup

## Contributing

This mod is built using the Hell2Modding framework. To modify:
1. Edit the Lua files in the mod directory
2. Use the provided template structure for reference
3. Test changes with the ReLoad hot-reloading system

## Credits

- Built for Hades 2 by Supergiant Games
- Uses Hell2Modding framework
- Inspired by Hades modding community
- Credits to Jowday and his mod "BanManager" for the inspiration and starting point. A couple of bits of code were directly taken from his mod.

## Version History

- v1.0: Initial release with basic banning functionality
- v1.1: Added bit-packing, UI improvements, Selene/Daedalus support
- v1.2: Added keepsake separation and first boon Epic forcing</content>

# License
This mod is provided as-is without warranty. You are free to modify and distribute it, but please credit the original author. Do not use this mod for commercial purposes without permission.