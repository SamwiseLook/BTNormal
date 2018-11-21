#!/bin/bash

Weapon_Directory="/Users/slook/Library/Application Support/Steam/steamapps/common/BATTLETECH/BattleTech.app/Contents/Resources/Data/StreamingAssets/data/weapon"

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
echo "$UIName $Manufacturer $Damage $HeatGenerated $Tonnage"
done