git remote update origin --prune
sudo alien -i rpmpackage.rpm

dpkg --get-selections | grep 'skype'
sudo apt-get --purge remove skypeforlinux

#php trait

# vargant

vagrant box list
vagrant box add training training2.box
vagrant up
vagrant halt /stop vagrant
vagrant plugin install vagrant-hostsupdater

ssh vargant: vagrant ssh
sudo chmod +x bin/cake

# cakephp

bin/cake migrations migrate
bin/cake migrations seed

# crontab
crontab -l
bin/cake CrontabRegister vagrant
sudo crontab -unginx -l
sudo crontab -unginx -r #clear crontab

# bootbox ~ Modal

# open port
/sbin/iptables -I INPUT -p tcp --dport 80 -j ACCEPT

bin/cake server -H 192.168.13.37 -p 5673

# docker
docker-compose up
sudo docker exec -it angelnet_php /bin/sh
docker system prune ~ g

# laravel
npm run dev
php artisan server

UPDATE `articles` SET `number` = (number%100 + 800) WHERE SUBSTRING(number,-3,1) = 0;

# zsh --> nâng cấp của command line
# phpcs with PSR2

# SOLID
SOLID là viết tắt của 5 chữ cái đầu trong 5 nguyên tắc thiết kế hướng đối tượng, giúp cho developer viết ra những đoạn code dễ đọc, dễ hiểu, dễ maintain

# azure data studio --> connect mysql server

# build node js
npm i

# mongo
- Test port: mongo --port 30000
- Connect mongo: ssh -L 30000:localhost:27017 web_user@210.148.155.78 pass: cV9KKYSEYfon0CyssbSg

# export data to file
mysql -u webuser -p -D databasename -e  "select user_id from user where application_id = 'eazy';" > ~/UserEmptyEazy.txt

# grep find
2019-12-31.+(?=result=SUCCESS)

# count search vi
%s/pattern//ng
