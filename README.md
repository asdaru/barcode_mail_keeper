# BARCODE MAIL KEEPER

Application 
1. Get image (pdf) file from pop3 server 
2. Try to find barcode in image
3. Send barcode information and image file to smtp server

 


Start docker container:

```
docker build -t barcode_mail_keeper .
docker run -i -t -d --restart always --name barcode_mail_keeper -v <place of your config file>:/home/script/scan.conf barcode_mail_keeper
```