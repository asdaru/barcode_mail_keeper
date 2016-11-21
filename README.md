Start docker container:

docker run -i -t -d --restart always --name barcode_mail_keeper -v <place of your config file>:/home/script/scan.conf barcode_mail_keeper