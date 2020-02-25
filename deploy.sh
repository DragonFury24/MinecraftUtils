#!/bin/bash

SUDO=''
if (( $EUID != 0 )); then
    SUDO='sudo'
fi

$SUDO apt update
$SUDO apt install default-jre -y

cd ..

#Build Spigot
wget https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar
java -jar BuildTools.jar

#Create folder containing world and copy necessary files
#World will be named after currently logged in user
worldName=$USER
mkdir $worldName
rsync -a MinecraftUtils/start.sh $worldName
rsync -a MinecraftUtils/config/ $worldName

for file in ./*
do
if grep -q spigot "$file"; then
rsync -a $file $worldName/spigot.jar
fi
done

#First run of Spigot and accept EULA
cd $worldName
java -jar -Xms1G -Xmx1G -jar spigot.jar
sed -i 's/false/true/' eula.txt
