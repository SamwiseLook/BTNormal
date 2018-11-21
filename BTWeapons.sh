#!/bin/bash

Weapon_Directory="/Users/slook/Library/Application Support/Steam/steamapps/common/BATTLETECH/BattleTech.app/Contents/Resources/Data/StreamingAssets/data/weapon"
Ammo_Directory="/Users/slook/Library/Application Support/Steam/steamapps/common/BATTLETECH/BattleTech.app/Contents/Resources/Data/StreamingAssets/data/ammunitionBox"

HeatSink_Per_Ton=3
Minimum_Shots=10


get_value() {
  key=$1
  value=$(cat "$Weapon_Directory/$The_Weapon_File" | awk "/\"$1\" :/" | sed -e s/.*://g -e s/\"//g -e s/,//g)
  echo $value
}

for The_Weapon_File in $(ls "$Weapon_Directory" | awk '/Weapon_/ && /.json/ && !/DFAAttack/ && !/MeleeAttack/ && !/AI_Imaginary/');
do
UIName=$(get_value 'UIName' | sed -e s/+\ /+/g)
Manufacturer=$(get_value 'Manufacturer')
Damage=$(get_value 'Damage')
HeatGenerated=$(get_value 'HeatGenerated')
Tonnage=$(get_value 'Tonnage')
ShotsWhenFired=$(get_value 'ShotsWhenFired')
AmmoCategory=$(get_value 'AmmoCategory')

Ammo_Tonnage=0
Ammo_File=$(ls -1 "$Ammo_Directory" | awk "/$AmmoCategory/ && !/Flamer/" | head -1)
if [[ $Ammo_File ]];then
Capacity=$(cat "$Ammo_Directory/$Ammo_File" | awk "/\"Capacity\" :/" | sed -e s/.*://g -e s/\"//g -e s/,//g)
Ammo_Tonnage=$(echo "(($ShotsWhenFired / $Capacity) * $Minimum_Shots)" | bc -l)
fi

Total_Damage=$(echo "($Damage * $ShotsWhenFired)" | bc -l)
Heat_Tonnage=$(echo "($HeatGenerated/$HeatSink_Per_Ton)" | bc -l)

Ton_Damage=$(echo "scale=2; ($Total_Damage/($Tonnage+$Heat_Tonnage+$Ammo_Tonnage))" | bc -l)
echo "$Ton_Damage $UIName $Manufacturer"
done