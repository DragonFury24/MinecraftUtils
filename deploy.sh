#!/bin/bash

apt update
apt install default-jre -y

cd ..
wget https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar
java -jar BuildTools.jar
worldName=$USER
mkdir $worldName
rsync -a MinecraftUtils/start.sh $worldName

for file in /*
do
if grep -q spigot "$file"; then
rsync -a $file $worldName/spigot.jar
fi
done

cd $worldName
java -jar -Xms1G -Xmx1G -jar spigot.jar
sed 's/false/true/' eula.txt
