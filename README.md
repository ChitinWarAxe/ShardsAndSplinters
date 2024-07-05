# Shards & Splinters

_As the Dunmer crept deeper into the dank, shadowy dungeon, the air thickened with the stench of decay and impending doom. His heart pounded as he tightened his grip on his trusty sword, its blade worn and nicked from countless battles. Suddenly, from the abyssal darkness, an undead creature lunged with a guttural snarl, eyes burning with unholy fire. The Dunmer swung his weapon with desperate force, steel meeting bone in a fierce clash. But then, a horrifying crack echoed through the chamber—his sword shattered, fragments scattering across the cold, unforgiving stone. He was left defenseless, heart racing, as the relentless foe advanced, the taste of death hanging thick in the air..._

![A drawing of a dunmer with a broken sword](images/dunmer.png "A drawing of a dunmer with a broken sword")

## Features

This mod adds the chance for your weapon to break if you don’t take care of it. Most weapons can shatter, except for high-quality ones like adamantium, dwemer, and daedric. Artifact weapons are safe, your regular magical weapon is not.

When your weapon’s durability drops below a certain threshold, there’s a growing chance it might shatter mid-fight. Your luck attribute decreases this chance.

Tamriel Data items are supported.

![Your chitin war axe broke!](images/broke.png "Your chitin war axe broke!")

## Configuration

Customize the mod to your liking with these settings:

* Enable or disable weapon shattering.
* **Durability Threshold:** Set the durability percentage at below which weapons are at risk.
* **Luck Modifier:** Negativly affects how luck affects weapon breaking chances. (A bigger number increases the chance.)
* **Whitelisted Materials and Types:** List of materials and weapons that won’t shatter. The keywords are based on the model name of the weapon.
* **Debug Log:** Toggle extra console information for debugging.

## Roadmap

* Add chance of weapons shattering - **DONE**
* Add chance of shields shattering - **TBD**
* Magical weapons explode upon shattering, causing their magical damage to you - **Not possible with OpenMW AFAIK** 

**This is my first-ever Lua mod for OpenMW. I hope you enjoy it!**
