# BARCODE MAIL KEEPER

Application 
1. Get image (pdf) file from pop3 server 
2. Try to find barcode in image
3. Send barcode information and image file to smtp server

 
---

##### Start docker container:

```
docker run -i -t -d --restart always --name barcode_mail_keeper -v <place of your config file>:/home/script/scan.conf asdaru/barcode_mail_keeper
```

---
##### Default scan.conf

```
{
	mincolors=>26500,
	scanimage_param=>'--page-height=300 -y 300',
	multi=>1,
	resolution=>250,
	typeEANcodes=>'enable',
	pause_betwen_loading=>5,
	mail=>[{
			pop3_server=>'',
			pop3_ssl=>'',
			pop3_username=>'',
			pop3_password=>'',
			smtp_server=>'',
			smtp_ssl=>'',
			smtp_username=>'',
			smtp_password=>'',
			from=>'',
			to=>'',
			
	}]
};
```
