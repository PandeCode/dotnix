use ~/dotnix/config/nushell/themes/tokyo-night.nu

$env.config = ($env.config | merge {color_config: (tokyo-night)})
