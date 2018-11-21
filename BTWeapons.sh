#!/bin/bash

Weapon_Directory="/Users/slook/Library/Application Support/Steam/steamapps/common/BATTLETECH/BattleTech.app/Contents/Resources/Data/StreamingAssets/data/weapon"
Ammo_Directory="/Users/slook/Library/Application Support/Steam/steamapps/common/BATTLETECH/BattleTech.app/Contents/Resources/Data/StreamingAssets/data/ammunitionBox"

HeatSink_Per_Ton=3 #Amount of heat dispersed per ton of Heat Sinks, higher is more effective.
Minimum_Shots=10 #Minimum shots per game considered viable, higher is less effective.
PPC_Effect=10 #Damage equivalent of the PPC affect, higher is more effective.
Range_Effect=1000 #Hypothetical number of metres at which damage value is doubled, higher is less effective.
Point_Damage_Effect=100 #Hypothetical point damage at which damage value is doubled, higher is less effective.
Stability_Damage_Divider=1 #Stability Damage to have the same effect as Damage, higher is less effective.
Heat_Damage_Divider=1 #Heat Damage to have the same effect as Damage, higher is less effective.

rm BTWep.out

get_value() {
  key=$1
  value=$(cat "$Weapon_Directory/$The_Weapon_File" | awk "/\"$1\" :/" | sed -e s/.*://g -e s/\"//g -e s/,//g)
  echo $value
}

for The_Weapon_File in $(ls "$Weapon_Directory" | awk '/Weapon_/ && /.json/ && !/DFAAttack/ && !/MeleeAttack/ && !/AI_Imaginary/');
do
UIName=$(get_value 'UIName' | sed -e s/+\ /+/g)
echo $UIName
Manufacturer=$(get_value 'Manufacturer')
Damage=$(get_value 'Damage')
HeatGenerated=$(get_value 'HeatGenerated')
Tonnage=$(get_value 'Tonnage')
ShotsWhenFired=$(get_value 'ShotsWhenFired')
AmmoCategory=$(get_value 'AmmoCategory')
Type=$(get_value 'Type')
MinRange=$(get_value 'MinRange')
MaxRange=$(get_value 'MaxRange')
Instability=$(get_value 'Instability')
HeatDamage=$(get_value 'HeatDamage')

Heat_Damage_Effect=$(echo "($HeatDamage / $Heat_Damage_Divider)" | bc -l)
echo $Heat_Damage_Effect
Instability_Damage=$(echo "($Instability / $Stability_Damage_Divider)" | bc -l)
Point_Multiplier=$(echo "1 + ($Damage / $Point_Damage_Effect)" | bc -l)

Range_Multiplier=$(echo "1 + (($MaxRange + $MinRange) / $Range_Effect)" | bc -l)

if [[ "$Type" == "PPC" ]];then
Damage=$(echo "($Damage + $PPC_Effect)" | bc -l)
fi

Ammo_Tonnage=0
Ammo_File=$(ls -1 "$Ammo_Directory" | awk "/$AmmoCategory/ && !/Flamer/" | head -1)
if [[ $Ammo_File ]];then
Capacity=$(cat "$Ammo_Directory/$Ammo_File" | awk "/\"Capacity\" :/" | sed -e s/.*://g -e s/\"//g -e s/,//g)
Ammo_Tonnage=$(echo "(($ShotsWhenFired / $Capacity) * $Minimum_Shots)" | bc -l)
fi

Total_Damage=$(echo "(($Damage + $Instability_Damage + $Heat_Damage_Effect) * $ShotsWhenFired)" | bc -l)
Heat_Tonnage=$(echo "($HeatGenerated/$HeatSink_Per_Ton)" | bc -l)

Ton_Damage=$(echo "scale=2; (($Total_Damage * $Range_Multiplier * $Point_Multiplier) / ($Tonnage+$Heat_Tonnage+$Ammo_Tonnage))" | bc -l)
echo "${Ton_Damage} $UIName $Manufacturer" >> BTWep.out
done
cat BTWep.out | sort -g
Epoch=$(date +"%s")
echo "$HeatSink_Per_Ton $Minimum_Shots $PPC_Effect $Range_Effect $Stability_Damage_Divider" >> ${Epoch}.txt
cat BTWep.out | sort -g >> ${Epoch}.txt