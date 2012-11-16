# ButtonMash - Rotation timers for DPS

This addon is a generic version of <a href="https://github.com/iamcal/ComboMeal">ComboMeal</a>, 
showing DPS cooldowns, combo points and so on for multiple classes.

## Combat Rogue

<img src="http://iamcal.github.com/ComboMeal/ComboMeal.png" />

The top row shows your active rotation abilities. Glowing border means right now, active icon means up next.

The second row shows your current combo points. Green are on your target, yellow are on a previous target (so can be used for SnD, Recuperate or Redirect).

The third row shows your main cooldowns (Adrenaline Rush and Killing Spree) and your Blade Flurry state. KS will be dimmed when it's not sensible to use it (when AR is ready or active, or when you have too much energy).

The fourth row shows profession and racial cooldowns and any on-use trinkets.


These icons are _not_ ability buttons - they cannot be clicked. Set up your keybinds however you normally would - this addon is just to help you monitor rotation and cooldowns.


## TODO - General

1. Add warning icons for missings buffs a la Prec
2. Change drag-cover to individual frames so we can have non-square addons
3. Allow menu hooking for modules
4. Port ComboMeal functionality over


## TODO - Frost DK

1. Add countdowns to diseases expiring
2. Add warning for missing frost presence
3. Figure out max time to wait before frost strike during killing machine
4. Add some cooldowns


## TODO - Combat Rogue

1. Add Redirect to the second row
2. Allow customization of the overlay (keybind) text. These are currently hard-coded.
3. Correctly advise SnD when there are combo points on old targets
4. Add option for Rupture (always, never, grouped, bleed-debuff'd targets)
4. Suggest SnD while out of range (if appropriate)

