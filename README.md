# DCS Simple Spawn Menu
A script for DCS that uses group names to create a spawn menu.

## Introduction
Do you want to dynamically spawn, respawn and despawn groups in your DCS mission? Do you want to have sub folders in the F10 menu? Did they tell you need to learn LUA coding and the DCS scripting environment to do it? Well, I learned LUA so you don't have to.

This script will do it all for you. So how does it work?

## How it works
This script will create submenu's in the F10 menu based on the names of groups. It will create a sub menu for every group that has within a spawn and despawn button, these do exactly that. For now it's possible to have 1 submenu and also to add multiple groups to 1 spawn/despawn button. The syntax (which is changable if you don't like it) is as follows:

### ```!DSSM syntax!```
You can see the ```!``` as the opening and closing brackets for this script. Between it you will put the syntax that makes the scrip do things. 

The bare minimum ```!! Your group Name``` will add a submenu to the F10 menu called ```Your group name``` with within a spawn and despawn button.

### ```?Submenu Name?```
To create a new submenu you can use the ```?```. 

So ```!?First Wave?!QRF``` will create a submenu in the F10 menu called ```First Wave```. In that submenu there will be another submenu called ```QRF```. In that submenu there will be 2 buttons: Spawn and Despawn.


### ```*Bulk Name*```
If you want to spawn and despawn multiple groups with one button use this format. As stated above if you want this script to parse this group you'll have to at least have ```!!```. But bulk's can also be added to a submenu. 

So if you have 2 groups and name them: ```!?Red Air?*QRA*!Flight 1``` and ```!?Red Air?*QRA*!Flight 2```. A submenu in the F10 menu will be created with the name ```Red Air```. Inside will be a submenu called ```QRA``` that holds inside 2 buttons: Spawn and Despawn. These buttons will spawn, respawn or despawn both groups.

### Example
If I have the following groups:

- ```!! Red 1```
- ```!*Bulk 1*! Red 2```
- ```!*Bulk 1*! Red 3```
- ```!?Wave 1?! Red 3```
- ```!?Wave 1?! Red 4```
- ```!?Wave 2?*BULK 2*! Red 5```
- ```!?Wave 2?*BULK 2*! Red 6```

The following menu will be created:

![ezgif-5-3325404021](https://user-images.githubusercontent.com/7512733/148083674-40139be1-c814-4a63-8523-720268d3885f.gif)

- Red 1
  - Spawn
  - Despawn
- Bulk 1
  - Spawn
  - Despawn
- Wave 1
  - Red 3
    - Spawn 
    - Despawn
  - Red 4
    - Spawn 
    - Despawn
- Wave 2
  - BULK 2
    - Spawn
    - Despawn

As you can see Red 2, 3, 4 and 5 are not shown as they are a part of a bulk and can be spawned or despawned by their respective buttons.

### Respawning
It is possible to respawn a killed or despawned group. Additionally when a group is still alive, pressing the spawn button wil respawn the group at it's original location. This can be turned off by setting the ```respawn``` variable in the script to false. In that case nothing will happen when the group is alive and Spawn is pressed.

### Important
As you can read above every group you want this script to look at **requires** a ```!!``` whether you want a submenu or not.

Make sure you don't use any of the ```!, * or |``` in your other groups names as this might cause issues.

Also, at the moment this script doesn't do sorting so all menu's will be placed at random.

## Installation
Installation is like any other script but keep in mind Mission Scripting Tools are **required**:

1. Download Mission Scripting Tools: [mist](https://github.com/mrSkortch/MissionScriptingTools/releases)
2. Download DCS Simple Spawn Menu: [dssm](https://github.com/Markoudstaal/DCS-Simple-Spawn-Menu/releases)
3. Open DCS and open or create a mission.
4. Go to triggers and press ```NEW```.
5. Set type to ```4 MISSION START``` and give it a name.
6. Below the ```ACTIONS``` windows press ```NEW```.
7. Set ```ACTION``` to ```DO SCRIPT FILE``` and select the mist lua file.
8. Repeat steps 6 and 7 with dssm.lua
9. Create your groups with the correct names.
10. Profit!

## Media
For any direct questions you can find me on Discord: Popper#7527

Forum post: [DCS Simple Spawn Menu](https://forums.eagle.ru/topic/290315-dcs-simple-spawn-menu-create-an-f10-spawn-despawn-and-respawn-menu-without-coding/)

Youtube: [710th Goat Herders](https://www.youtube.com/channel/UCn-TZnAaI9qzF97O1_wiNyA)


