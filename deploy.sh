#!/bin/bash

if (( $EUID != 0 )); then
  clear
  clear
  echo -e "${RED}#########################################################################${RESET}"
  echo ""
  echo -e "${WHITE_R}#${RESET} The script need to be run as root..."
  echo ""
  echo ""
  echo -e "${WHITE_R}#${RESET} For Ubuntu based systems run the command below to login as root"
  echo -e "${GREEN}#${RESET} sudo -i"
  echo ""
  echo -e "${WHITE_R}#${RESET} For Debian based systems run the command below to login as root"
  echo -e "${GREEN}#${RESET} su"
  echo ""
  echo ""
  exit 1
fi

apt update
apt install default-jre -y

cd ..

#Build Spigot
wget https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar
java -jar BuildTools.jar

#Create folder containing world and copy necessary files
#World will be named after currently logged in user
worldName=$USER
mkdir $worldName
rsync -a MinecraftUtils/start.sh $worldName
chmod +x $worldName/start.sh
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

#Create systemd service to start server at boot and restart on stop
cd ..
sed -i "s/\*\*user\*\*/$USER/" MinecraftUtils/autostart.service
sed -i "s/\*\*worldname\*\*/$worldName/" MinecraftUtils/autostart.service
rsync MinecraftUtils/autostart.service /etc/systemd/system/$worldName.service
systemctl enable $worldName
systemctl start $worldName

#Delete Spigot jar file after finishing
for file in ./*
do
if grep -q spigot "$file"; then
rm $file
fi                                                                                                                      done
