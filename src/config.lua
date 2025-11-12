---@meta purpIe-config-BanManager

return {

  BanManager = false,

  ForceFirstBoonEpic = false,

  -- Bit-packed configs: multiple god configs combined into fewer variables for efficiency
  -- Each packed config is a bitmask combining several god's ban masks

  PackedConfig1 = 0,   -- Aphrodite (22 bits) + Artemis (9 bits) = 31 bits
  PackedConfig2 = 0,   -- Apollo (22) + Athena (8) = 30 bits
  PackedConfig3 = 0,   -- Ares (22) + Dionysus (8) = 30 bits
  PackedConfig4 = 0,   -- Demeter (22) + Hades (8) = 30 bits
  PackedConfig5 = 0,   -- Hephaestus (22) + HadesKeepsake (8) = 30 bits
  PackedConfig6 = 0,   -- Hera (22) + Arachne (8) = 30 bits
  PackedConfig7 = 0,   -- Hestia (22) + Narcissus (9) = 31 bits
  PackedConfig8 = 0,   -- Poseidon (22) + Echo (8) = 30 bits
  PackedConfig9 = 0,   -- Zeus (22) + Medea (8) = 30 bits
  PackedConfig10 = 0,  -- Hermes (13) + Circe (9) + Selene (9) = 31 bits
  PackedConfig11 = 0,  -- Axe (14) + Torch (13) = 27 bits
  PackedConfig12 = 0,  -- Staff (16) + Lob (16) = 32 bits
  PackedConfig13 = 0,  -- Suit (17) + Dagger (15) = 32 bits

}