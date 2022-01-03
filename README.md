# DCS Simple Spawn Menu
A script for DCS that uses group names to create a spawn menu.

## Introduction
Do you want to dynamically spawn, respawn and despawn groups in your DCS mission? Do you want to have sub folders in the F10 menu? Did they tell you need to learn LUA coding and the DCS scripting environment to do it? Well, I learned LUA so you don't have to.

This script will do it all for you. So how does it work?

## How it works
This script will create submenu's in the F10 menu based on the names of groups. It will create a sub menu for every group that has within a spawn and despawn button, these do exactly that. For now it's possible to have 1 submenu and also to add multiple groups to 1 spawn/despawn button. The syntax (which is changable if you don't like it) is as follows:

### ```!Submenu Name!```
Every group name has to start with an ```!```. This will trigger the script to look at that group and something with it. After the ```!``` you can create a sub menu by giving it a name and then ending with another ```!```. You can also leave the space between empty (```!!```) to put the menu for that group in the root F10 menu. To end where the script is looking and start with the name of the group use a ```|``` (that's the shifted key above your enter).

So ```!First Wave!|QRF``` will create a submenu in the F10 menu called ```First Wave```. In that submenu there will be another submenu called ```QRF```. In that submenu there will be 2 buttons: Spawn and Despawn.

And if you want a group in the F10 root menu it would be something like ```!!|QRF```.

### ```*Bulk Name*```
If you want to spawn and despawn multiple groups with one button use this format. As stated above if you want this script to parse this group you'll have to at least have ```!!```. But bulk's can also be added to a submenu. 

So if you have 2 groups and name them: ```!Red Air!*QRA*|Flight 1``` and ```!Red Air!*QRA*|Flight 2```. A submenu in the F10 menu will be created with the name ```Red Air```. Inside will be a submenu called ```QRA``` that holds inside 2 buttons: Spawn and Despawn. These buttons will spawn, respawn or despawn both groups.

### Important
As you can read above every group you want this script to look at **requires** a ```!!``` whether you want a submenu or not. Otherwise the script will crash (I havn't learned LUA error handling yet. Also it is **required** to end with a ```|``` before writing the group name, again the script will crash if you don't.

Make sure you don't use any of the ```!, * or |``` in your other groups names as this might cause issues.

Also, at the moment this script doesn't do sorting so all menu's will be placed at random.

## Installation
To use this script simply download it from the releases page on GitHub. After that add it to your mission with trigger 'Start Mission' and action 'Do Script File'. This script requires [mist](https://github.com/mrSkortch/MissionScriptingTools) and you have to add it to your mission before you load the pssm.lua file. 


