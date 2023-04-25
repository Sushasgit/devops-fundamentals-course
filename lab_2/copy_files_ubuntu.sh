#!/bin/bash

server_folder_name="server"
client_folder_name="client"

read -p "Enter SSH username: " ssh_user

server_folder="/home/$ssh_user/devops-fundamentals-course/lab_2/server/dist"
client_folder="/home/$ssh_user/devops-fundamentals-course/lab_2/client/dist"
package_json="/home/$ssh_user/devops-fundamentals-course/lab_2/server/package.json"

sudo mkdir -p /var/app/$server_folder_name /var/www/$client_folder_name
sudo chown $ssh_user:$ssh_user /var/app/$server_folder_name /var/www/$client_folder_name

sudo cp -r $server_folder $package_json /var/app/$server_folder_name
sudo chown -R $ssh_user:$ssh_user /var/app/$server_folder_name

sudo cp -r $client_folder/* /var/www/$client_folder_name
sudo chown -R $ssh_user:$ssh_user /var/www/$client_folder_name

echo "Apps uploaded successfully!"