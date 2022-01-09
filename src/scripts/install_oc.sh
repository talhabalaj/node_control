#!/bin/bash
#
# Name:		install-vpn-server.sh
# Version:	8
# Author:	umar
# Purpose:	(For Cloud Servers) Sets up OCServ for CentOS-7 With Namecheap Certs
# Usage:	bash install-vpn-server.sh
#################################################################################################

echo '-'
## Get Git Username

#read -p "Enter Git Username: " VGPMYGITUSERNAME
#if [ -z $VGPMYGITUSERNAME ] ; then
#    echo 'NO GIT username given, exiting....'
#    exit 1
#fi
#echo '-'
## Get Git Password
#read -p "Enter Git Password: " VGPMYGITPASSWORD
#if [ -z $VGPMYGITPASSWORD ] ; then
#    echo 'NO GIT Password given, exiting....'
#    exit 1
#fi
echo 'Starting The VPN Server Installation Process'

## Install Git if not installed
command -v git >/dev/null 2>&1 || { 
yum install -y git
}

## Create mycode Dir if not created.
if [ ! -d "/etc/mycode/" ];
then
	mkdir /etc/mycode
fi
cd /etc/mycode

if [ ! -d "/etc/mycode/VezNode-Bot/" ];
then
while ! git clone "https://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@github.com/aahhoo/VezNode-Bot.git"; do
  echo 'Git Doesnt Work, Contact Admin' >&2;
  read -e -p "Hit Enter to Retry " VGPMYGITUSERNAME
  #read -e -p "Enter Git Password: " VGPMYGITPASSWORD
done
fi

## Clone Bot Repo from Git, loop untill success


cd

timedatectl set-timezone UTC


# Make server software up-to-date
yum -y update

# Install NodeJS

echo "Downloading and Installing NodeJS, Please Wait...."

curl -sL https://rpm.nodesource.com/setup_14.x | sudo bash -
sudo yum install -y nodejs
npm install pm2@latest -g
pm2 update
pm2 startup



# Install Usefull Utilities
#yum install -y git

# Install the epel
yum install epel-release -y

# Install Firewall
yum install firewalld -y

# Install OCServ
yum install ocserv -y

# Install Usefull Utilities
yum install -y mtr iptraf-ng htop certbot nano nload

# Remove files of earlier install, in case they exist
rm -f /etc/ocserv/ocserv.conf
rm -f /etc/radcli/radiusclient.conf /etc/radcli/servers

# Populate OCServ config file with custom settings
cat <<END > /etc/ocserv/ocserv.conf
auth = "radius [config=/etc/radcli/radiusclient.conf]"
acct = "radius [config=/etc/radcli/radiusclient.conf]"
tcp-port = 443
udp-port = 443
run-as-user = nobody
run-as-group = daemon
socket-file = /var/run/ocserv-socket
ca-cert = /etc/ocserv/bestbuyingguide_shop.ca-bundle
server-cert = /etc/ocserv/bestbuyingguide_shop.crt
server-key = /etc/ocserv/bestbuyingguide_shop.key
isolate-workers = true
max-clients = 50
max-same-clients = 1
keepalive = 15
dpd = 60
session-timeout = 9000
mobile-dpd = 80
try-mtu-discovery = true
cert-user-oid = 0.9.2342.19200300.100.1.1
#compression = true
#no-compress-limit = 50
#tls-priorities = "NORMAL:%SERVER_PRECEDENCE:%COMPAT:-RSA:-VERS-SSL3.0:-ARCFOUR-128"
tls-priorities = "NORMAL:%SERVER_PRECEDENCE:%COMPAT:-RSA:-VERS-SSL3.0:-ARCFOUR-128:-VERS-TLS1.1:-VERS-TLS1.2"
auth-timeout = 40
#idle-timeout = 20
#mobile-idle-timeout = 30
min-reauth-time = 3
max-ban-score = 0
ban-reset-time = 18000
cookie-timeout = 55
deny-roaming = false
rekey-time = 172800
rekey-method = ssl
use-utmp = true
use-occtl = true
pid-file = /var/run/ocserv.pid
device = vpns
predictable-ips = true
default-domain = bestbuyingguide.shop
ipv4-network = 172.31.224.0
ipv4-netmask = 255.255.224.0
tunnel-all-dns = true
dns = 8.8.8.8
dns = 8.8.4.4
ping-leases = false
cisco-client-compat = true
dtls-legacy = true
connect-script = /etc/ocserv/ologit.sh
disconnect-script = /etc/ocserv/ologit.sh
END

# Populate certificate files
#
cat <<END > /etc/ocserv/bestbuyingguide_shop.ca-bundle
-----BEGIN CERTIFICATE-----
MIIGEzCCA/ugAwIBAgIQfVtRJrR2uhHbdBYLvFMNpzANBgkqhkiG9w0BAQwFADCB
iDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCk5ldyBKZXJzZXkxFDASBgNVBAcTC0pl
cnNleSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNV
BAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwHhcNMTgx
MTAyMDAwMDAwWhcNMzAxMjMxMjM1OTU5WjCBjzELMAkGA1UEBhMCR0IxGzAZBgNV
BAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEYMBYGA1UE
ChMPU2VjdGlnbyBMaW1pdGVkMTcwNQYDVQQDEy5TZWN0aWdvIFJTQSBEb21haW4g
VmFsaWRhdGlvbiBTZWN1cmUgU2VydmVyIENBMIIBIjANBgkqhkiG9w0BAQEFAAOC
AQ8AMIIBCgKCAQEA1nMz1tc8INAA0hdFuNY+B6I/x0HuMjDJsGz99J/LEpgPLT+N
TQEMgg8Xf2Iu6bhIefsWg06t1zIlk7cHv7lQP6lMw0Aq6Tn/2YHKHxYyQdqAJrkj
eocgHuP/IJo8lURvh3UGkEC0MpMWCRAIIz7S3YcPb11RFGoKacVPAXJpz9OTTG0E
oKMbgn6xmrntxZ7FN3ifmgg0+1YuWMQJDgZkW7w33PGfKGioVrCSo1yfu4iYCBsk
Haswha6vsC6eep3BwEIc4gLw6uBK0u+QDrTBQBbwb4VCSmT3pDCg/r8uoydajotY
uK3DGReEY+1vVv2Dy2A0xHS+5p3b4eTlygxfFQIDAQABo4IBbjCCAWowHwYDVR0j
BBgwFoAUU3m/WqorSs9UgOHYm8Cd8rIDZsswHQYDVR0OBBYEFI2MXsRUrYrhd+mb
+ZsF4bgBjWHhMA4GA1UdDwEB/wQEAwIBhjASBgNVHRMBAf8ECDAGAQH/AgEAMB0G
A1UdJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjAbBgNVHSAEFDASMAYGBFUdIAAw
CAYGZ4EMAQIBMFAGA1UdHwRJMEcwRaBDoEGGP2h0dHA6Ly9jcmwudXNlcnRydXN0
LmNvbS9VU0VSVHJ1c3RSU0FDZXJ0aWZpY2F0aW9uQXV0aG9yaXR5LmNybDB2Bggr
BgEFBQcBAQRqMGgwPwYIKwYBBQUHMAKGM2h0dHA6Ly9jcnQudXNlcnRydXN0LmNv
bS9VU0VSVHJ1c3RSU0FBZGRUcnVzdENBLmNydDAlBggrBgEFBQcwAYYZaHR0cDov
L29jc3AudXNlcnRydXN0LmNvbTANBgkqhkiG9w0BAQwFAAOCAgEAMr9hvQ5Iw0/H
ukdN+Jx4GQHcEx2Ab/zDcLRSmjEzmldS+zGea6TvVKqJjUAXaPgREHzSyrHxVYbH
7rM2kYb2OVG/Rr8PoLq0935JxCo2F57kaDl6r5ROVm+yezu/Coa9zcV3HAO4OLGi
H19+24rcRki2aArPsrW04jTkZ6k4Zgle0rj8nSg6F0AnwnJOKf0hPHzPE/uWLMUx
RP0T7dWbqWlod3zu4f+k+TY4CFM5ooQ0nBnzvg6s1SQ36yOoeNDT5++SR2RiOSLv
xvcRviKFxmZEJCaOEDKNyJOuB56DPi/Z+fVGjmO+wea03KbNIaiGCpXZLoUmGv38
sbZXQm2V0TP2ORQGgkE49Y9Y3IBbpNV9lXj9p5v//cWoaasm56ekBYdbqbe4oyAL
l6lFhd2zi+WJN44pDfwGF/Y4QA5C5BIG+3vzxhFoYt/jmPQT2BVPi7Fp2RBgvGQq
6jG35LWjOhSbJuMLe/0CjraZwTiXWTb2qHSihrZe68Zk6s+go/lunrotEbaGmAhY
LcmsJWTyXnW0OMGuf1pGg+pRyrbxmRE1a6Vqe8YAsOf4vmSyrcjC8azjUeqkk+B5
yOGBQMkKW+ESPMFgKuOXwIlCypTPRpgSabuY0MLTDXJLR27lk8QyKGOHQ+SwMj4K
00u/I5sUKUErmgQfky3xxzlIPK1aEn8=
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIFgTCCBGmgAwIBAgIQOXJEOvkit1HX02wQ3TE1lTANBgkqhkiG9w0BAQwFADB7
MQswCQYDVQQGEwJHQjEbMBkGA1UECAwSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYD
VQQHDAdTYWxmb3JkMRowGAYDVQQKDBFDb21vZG8gQ0EgTGltaXRlZDEhMB8GA1UE
AwwYQUFBIENlcnRpZmljYXRlIFNlcnZpY2VzMB4XDTE5MDMxMjAwMDAwMFoXDTI4
MTIzMTIzNTk1OVowgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpOZXcgSmVyc2V5
MRQwEgYDVQQHEwtKZXJzZXkgQ2l0eTEeMBwGA1UEChMVVGhlIFVTRVJUUlVTVCBO
ZXR3b3JrMS4wLAYDVQQDEyVVU0VSVHJ1c3QgUlNBIENlcnRpZmljYXRpb24gQXV0
aG9yaXR5MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAgBJlFzYOw9sI
s9CsVw127c0n00ytUINh4qogTQktZAnczomfzD2p7PbPwdzx07HWezcoEStH2jnG
vDoZtF+mvX2do2NCtnbyqTsrkfjib9DsFiCQCT7i6HTJGLSR1GJk23+jBvGIGGqQ
Ijy8/hPwhxR79uQfjtTkUcYRZ0YIUcuGFFQ/vDP+fmyc/xadGL1RjjWmp2bIcmfb
IWax1Jt4A8BQOujM8Ny8nkz+rwWWNR9XWrf/zvk9tyy29lTdyOcSOk2uTIq3XJq0
tyA9yn8iNK5+O2hmAUTnAU5GU5szYPeUvlM3kHND8zLDU+/bqv50TmnHa4xgk97E
xwzf4TKuzJM7UXiVZ4vuPVb+DNBpDxsP8yUmazNt925H+nND5X4OpWaxKXwyhGNV
icQNwZNUMBkTrNN9N6frXTpsNVzbQdcS2qlJC9/YgIoJk2KOtWbPJYjNhLixP6Q5
D9kCnusSTJV882sFqV4Wg8y4Z+LoE53MW4LTTLPtW//e5XOsIzstAL81VXQJSdhJ
WBp/kjbmUZIO8yZ9HE0XvMnsQybQv0FfQKlERPSZ51eHnlAfV1SoPv10Yy+xUGUJ
5lhCLkMaTLTwJUdZ+gQek9QmRkpQgbLevni3/GcV4clXhB4PY9bpYrrWX1Uu6lzG
KAgEJTm4Diup8kyXHAc/DVL17e8vgg8CAwEAAaOB8jCB7zAfBgNVHSMEGDAWgBSg
EQojPpbxB+zirynvgqV/0DCktDAdBgNVHQ4EFgQUU3m/WqorSs9UgOHYm8Cd8rID
ZsswDgYDVR0PAQH/BAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8wEQYDVR0gBAowCDAG
BgRVHSAAMEMGA1UdHwQ8MDowOKA2oDSGMmh0dHA6Ly9jcmwuY29tb2RvY2EuY29t
L0FBQUNlcnRpZmljYXRlU2VydmljZXMuY3JsMDQGCCsGAQUFBwEBBCgwJjAkBggr
BgEFBQcwAYYYaHR0cDovL29jc3AuY29tb2RvY2EuY29tMA0GCSqGSIb3DQEBDAUA
A4IBAQAYh1HcdCE9nIrgJ7cz0C7M7PDmy14R3iJvm3WOnnL+5Nb+qh+cli3vA0p+
rvSNb3I8QzvAP+u431yqqcau8vzY7qN7Q/aGNnwU4M309z/+3ri0ivCRlv79Q2R+
/czSAaF9ffgZGclCKxO/WIu6pKJmBHaIkU4MiRTOok3JMrO66BQavHHxW/BBC5gA
CiIDEOUMsfnNkjcZ7Tvx5Dq2+UUTJnWvu6rvP3t3O9LEApE9GQDTF1w52z97GA1F
zZOFli9d31kWTz9RvdVFGD/tSo7oBmF0Ixa1DVBzJ0RHfxBdiSprhTEUxOipakyA
vGp4z7h/jnZymQyd/teRCBaho1+V
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIEMjCCAxqgAwIBAgIBATANBgkqhkiG9w0BAQUFADB7MQswCQYDVQQGEwJHQjEb
MBkGA1UECAwSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHDAdTYWxmb3JkMRow
GAYDVQQKDBFDb21vZG8gQ0EgTGltaXRlZDEhMB8GA1UEAwwYQUFBIENlcnRpZmlj
YXRlIFNlcnZpY2VzMB4XDTA0MDEwMTAwMDAwMFoXDTI4MTIzMTIzNTk1OVowezEL
MAkGA1UEBhMCR0IxGzAZBgNVBAgMEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UE
BwwHU2FsZm9yZDEaMBgGA1UECgwRQ29tb2RvIENBIExpbWl0ZWQxITAfBgNVBAMM
GEFBQSBDZXJ0aWZpY2F0ZSBTZXJ2aWNlczCCASIwDQYJKoZIhvcNAQEBBQADggEP
ADCCAQoCggEBAL5AnfRu4ep2hxxNRUSOvkbIgwadwSr+GB+O5AL686tdUIoWMQua
BtDFcCLNSS1UY8y2bmhGC1Pqy0wkwLxyTurxFa70VJoSCsN6sjNg4tqJVfMiWPPe
3M/vg4aijJRPn2jymJBGhCfHdr/jzDUsi14HZGWCwEiwqJH5YZ92IFCokcdmtet4
YgNW8IoaE+oxox6gmf049vYnMlhvB/VruPsUK6+3qszWY19zjNoFmag4qMsXeDZR
rOme9Hg6jc8P2ULimAyrL58OAd7vn5lJ8S3frHRNG5i1R8XlKdH5kBjHYpy+g8cm
ez6KJcfA3Z3mNWgQIJ2P2N7Sw4ScDV7oL8kCAwEAAaOBwDCBvTAdBgNVHQ4EFgQU
oBEKIz6W8Qfs4q8p74Klf9AwpLQwDgYDVR0PAQH/BAQDAgEGMA8GA1UdEwEB/wQF
MAMBAf8wewYDVR0fBHQwcjA4oDagNIYyaHR0cDovL2NybC5jb21vZG9jYS5jb20v
QUFBQ2VydGlmaWNhdGVTZXJ2aWNlcy5jcmwwNqA0oDKGMGh0dHA6Ly9jcmwuY29t
b2RvLm5ldC9BQUFDZXJ0aWZpY2F0ZVNlcnZpY2VzLmNybDANBgkqhkiG9w0BAQUF
AAOCAQEACFb8AvCb6P+k+tZ7xkSAzk/ExfYAWMymtrwUSWgEdujm7l3sAg9g1o1Q
GE8mTgHj5rCl7r+8dFRBv/38ErjHT1r0iWAFf2C3BUrz9vHCv8S5dIa2LX1rzNLz
Rt0vxuBqw8M0Ayx9lt1awg6nCpnBBYurDC/zXDrPbDdVCYfeU0BsWO/8tqtlbgT2
G9w84FoVxp7Z8VlIMCFlA2zs6SFz7JsDoeA3raAVGI/6ugLOpyypEBMs1OUIJqsi
l2D4kF501KKaU73yqWjgom7C12yxow+ev+to51byrvLjKzg6CYG1a4XXvi3tPxq3
smPi9WIsgtRqAEFQ8TmDn5XpNpaYbg==
-----END CERTIFICATE-----
END

cat <<END > /etc/ocserv/bestbuyingguide_shop.crt
-----BEGIN CERTIFICATE-----
MIIGSTCCBTGgAwIBAgIRAMucPIdq1Z3Qa/qc0tYPu4YwDQYJKoZIhvcNAQELBQAw
gY8xCzAJBgNVBAYTAkdCMRswGQYDVQQIExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAO
BgNVBAcTB1NhbGZvcmQxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDE3MDUGA1UE
AxMuU2VjdGlnbyBSU0EgRG9tYWluIFZhbGlkYXRpb24gU2VjdXJlIFNlcnZlciBD
QTAeFw0yMTA1MTUwMDAwMDBaFw0yMjA1MTUyMzU5NTlaMB8xHTAbBgNVBAMTFGJl
c3RidXlpbmdndWlkZS5zaG9wMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC
AQEAvBZjPMZuKGKVNr1r4RKQbd0heipIT2HgJrnACiwsDXmXZf2hm9tv3iaE6CN3
hBZIMimGfOjAUg4+RWhp5bVoc+vK7T1Rr0tFeVDOYmxXFCLC+tc/l1/aTdwftV00
PQfGwaJvnlfZcEp3v0ky3XxuZhcfkXo5j1SQoCScjs/ReHBqG7nNi9vm92YtVSmy
HYAWSpdI3YFIJAbohZ+Q9rjFbVAzxGS8v/29DAjhbH/YzjQLfmMTVildTMHmm4/k
eyU5RMS4eR0VuRNigdiVTanT7ek90w26e4Zvb54e4+0fJHfCuDiYHRP81+JyBWe/
QceBq2xGLv7XR19vfvcq/zoBlQIDAQABo4IDDTCCAwkwHwYDVR0jBBgwFoAUjYxe
xFStiuF36Zv5mwXhuAGNYeEwHQYDVR0OBBYEFFNT59sqsZ944sdST0wsyNtKzC2u
MA4GA1UdDwEB/wQEAwIFoDAMBgNVHRMBAf8EAjAAMB0GA1UdJQQWMBQGCCsGAQUF
BwMBBggrBgEFBQcDAjBJBgNVHSAEQjBAMDQGCysGAQQBsjEBAgIHMCUwIwYIKwYB
BQUHAgEWF2h0dHBzOi8vc2VjdGlnby5jb20vQ1BTMAgGBmeBDAECATCBhAYIKwYB
BQUHAQEEeDB2ME8GCCsGAQUFBzAChkNodHRwOi8vY3J0LnNlY3RpZ28uY29tL1Nl
Y3RpZ29SU0FEb21haW5WYWxpZGF0aW9uU2VjdXJlU2VydmVyQ0EuY3J0MCMGCCsG
AQUFBzABhhdodHRwOi8vb2NzcC5zZWN0aWdvLmNvbTA5BgNVHREEMjAwghRiZXN0
YnV5aW5nZ3VpZGUuc2hvcIIYd3d3LmJlc3RidXlpbmdndWlkZS5zaG9wMIIBewYK
KwYBBAHWeQIEAgSCAWsEggFnAWUAdQBGpVXrdfqRIDC1oolp9PN9ESxBdL79SbiF
q/L8cP5tRwAAAXlxECu3AAAEAwBGMEQCIFKEpPHotsucLhgONWc1Vx8nKg5ImdS2
0lWjBXrZuYUCAiAV1TyP7I5k/Pib/2CnJmgsP2f2KhVJ59XbaJw4ZPPUkAB1AEHI
yrHfIkZKEMahOglCh15OMYsbA+vrS8do8JBilgb2AAABeXEQK3MAAAQDAEYwRAIg
GB5drsONj9okDuDE1ozdA+QbGyL/lqEC+8RCsyQOANoCIAZNZlBpjnS2RBBzmuY0
0yVCoj2oJRh6B2+j36BwfSttAHUAKXm+8J45OSHwVnOfY6V35b5XfZxgCvj5TV0m
XCVdx4QAAAF5cRArSgAABAMARjBEAiBKisBAsR97TJAD91VeFxcdDEKJscNLRgKs
1ESV+ABphgIgJ6mXGKrB153eXL6WcsK2xrMq4awEmKagR5xedtHcMeIwDQYJKoZI
hvcNAQELBQADggEBALj9WuPT6RDcnYv3/iJQBkGgkX1iGahjU1xAOAZH4cuaEAJN
MQ3Z+s0/eFMgKhO2K1Cz5EikKes5eC+F7ua5q0dl5xnx6NNqe0epGLl1BSj09DWe
smySjdiwLzKWuGwJcirid3Bj/IBVdwFVpiI0+S02S8XG8ZQwbWiJcbiZusTxyZop
XrHlyCYV3ysIvWVCC4kOiPNX6veU1P7Me3FaDUqWtTXaUaWx3Wa/a9P2c1ovSYsP
a9xBk606pYY94OhPSoaASZRevan4GBrhkYRz+8v0eq0vCCkM94oym1QBHGsvS5UV
XoFk0JRUZuU7VF8s38h0ZKEMHT8YDhr8bo2LdWM=
-----END CERTIFICATE-----
END

cat <<END > /etc/ocserv/bestbuyingguide_shop.key
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC8FmM8xm4oYpU2
vWvhEpBt3SF6KkhPYeAmucAKLCwNeZdl/aGb22/eJoToI3eEFkgyKYZ86MBSDj5F
aGnltWhz68rtPVGvS0V5UM5ibFcUIsL61z+XX9pN3B+1XTQ9B8bBom+eV9lwSne/
STLdfG5mFx+RejmPVJCgJJyOz9F4cGobuc2L2+b3Zi1VKbIdgBZKl0jdgUgkBuiF
n5D2uMVtUDPEZLy//b0MCOFsf9jONAt+YxNWKV1Mweabj+R7JTlExLh5HRW5E2KB
2JVNqdPt6T3TDbp7hm9vnh7j7R8kd8K4OJgdE/zX4nIFZ79Bx4GrbEYu/tdHX29+
9yr/OgGVAgMBAAECggEAXP6otDzb7EXJxtXjB9ZY6KkDy1YqiG05GYyPobfzU/pB
W+EKTXgymGDtJ6WZiwpFSd/0KcAejrOSIFkeur911JLJs4C06XnK8M9+K3WrnD4P
r1xLibmPwx1J5C8gC+jTYZvBmkWPMZDwIfi8GHxUTU+zgQcwfGhwVW2kpouj4urA
sCaazJ7NR9BLhZH4uQXLo5SaqZ0SZxbtU+I7IkANzbsy7pt/VgrXULrlJJ90d6oM
3sqBz3stR9XOTIXJAZRjcjI46VNmriBofOYqPnxW3U9n5ajq7OrrE+rG1sY+kKco
PZeoktIP4N1D3oOYYJE9cBm8KXf05liPxFVXDWIn5QKBgQDkoKAPE6iDfkkQ+eub
MKzXAfJSuvyHH0UwCC+Cya5mrbIs7dR/Q60iFc1/QUrA4gZiMoFe5fhv+u/KxK7s
mu11P24i5/Xs0P60kUK+yVmnWlvzX33uNkSq2BVygS3bzWQnzrTLHFVe2vKlLXCc
7HgzLjIaHuK3bH9BcyicI5H9BwKBgQDSmzjA/vRyL9cDzX7nKKC98RC8+xrlH2L/
jHG66qi0I4r3KDxGKft5faUZ4gtEePofQpRs3iBwyKzbWE/jHEY7OBHph3rz1bAN
xTzssDxBErNSfFczto8rUMk48HEl6V1PTGX5nwSsXBDHau9MNGIuTMGbvio3TSEO
0vxQkJOBgwKBgQCAAgdcKa+SYCTc4nGuZKSBhc99zsARj8qXSB4B5pZFWz+FtGvk
DapkiTyT4aTPNj5IwOp6jdx6JlAYgeNHCr+lhCxQUvv46lOSGjr6w5X1A7y0GWVS
+QOdfHsVr4pTpT5Mo4nKp0SNZZ2yKi0BT81FKrpWsbBS7uaZaLb2JVxaBQKBgCnS
NQTuG/CI23Of3PFeOf0934sHeiHBh9EjPHpXmsSawj+uN7nfIFbRwnVPU9l3BIQs
nni36006LEkqUkLRHIkp6zSqeJnu9xTk8+I0ZOKvKfjZRB+6wtdhJXQvGujiXGsg
yqc1EqJ/bb2L2JUTWePDzjZ1HsD4ifX9o6kD7KatAoGALvO5ElqOUmSbjfK4G7UG
0RtysOa5QZyQIR5FxJ376vdTjsHbUeA4a+yZvpxPhi7VneYWZT+4xawU1oa03CrU
yu3k+CVWHx2P+82Ae5eNFzu6Hlk3acdyeKaxBmtpCte3N7QqkTvsNfHTR10EaYLW
oqK7NFxhxlombElbi009sXY=
-----END PRIVATE KEY-----
END



# Next, populate radius config files
#
cat  <<END > /etc/radcli/radiusclient.conf
## CONTENT OF /etc/radcli/radiusclient.conf

# RADIUS settings

# The name to be used to identify this NAS (server). If set it will
# be used in NAS-Identifier field and will override any such setting
# by the application.
#
nas-identifier ocserv

# Override the IP (or IPv6) address of the NAS.
#nas-ip 	10.100.5.3
#nas-ip 	::1

# RADIUS server to use for authentication requests.
# optionally you can specify a the port number on which is remote
# RADIUS listens separated by a colon from the hostname. if
# no port is specified /etc/services is consulted of the radius
# service. if this fails also a compiled in default is used.
# For IPv6 addresses use the '[IPv6]:port:secret' format, or
# simply '[IPv6]'. You may specify more than a single server
# in a comma-separated list.
#
#authserver 	95.154.194.55
authserver      92.204.174.198
#authserver 	127.1.1.1:9999,172.17.0.1

# RADIUS server to use for accouting requests. All that is
# written for authserver applies, in acctserver as well. 
#
#acctserver 	95.154.194.55
acctserver      92.204.174.198

# File holding shared secrets used for the communication
# between the RADIUS client and server. When multiple
# server
servers		/etc/radcli/servers

# Dictionary of allowed attributes and values. That depends
# heavily on the features of your server. A default dictionary
# is installed in /usr/share/radcli/dictionary
dictionary 	/etc/radcli/dictionary

# default authentication realm to append to all usernames if no
# realm was explicitly specified by the user
# the radiusd directly form Livingston doesnt use any realms, so leave
# it blank then
default_realm

# time to wait for a reply from the RADIUS server
radius_timeout	10

# resend request this many times before trying the next server
radius_retries	3

# local address from which radius packets have to be sent
bindaddr	*

# Transport Protocol Support
# Available options - 'tcp', 'udp', 'tls' and 'dtls'. 
# If commented out, udp will be used.
#serv-type	udp

# Namespace in which all sockets of Radcli are to be opened. This is effectively same as the        
# Radcli existing on that namespace.                                                                 
# If commented out, the default existing Namespace will be used.                                    
#namespace   namespace-name                                                                         

# Support for IPv6 non-temporary address support. This is an IPv6-only option
# and is valid only when IPv6 Privacy Extensions are enabled in system.
# If this option is set to "true", the radius packets will be sent with the
# IPv6 Global address and will not use the temporary adresses. If commented
# out, temporary IPv6 addresses will be used as source address for the packets
# sent.
#use-public-addr	true

# To enable verbose debugging messages in syslog, enable the following
#clientdebug 1

END

cat  <<END > /etc/radcli/servers
## Server Name or Client/Server pair		Key		
## ----------------				---------------
#
#portmaster.elemental.net			hardlyasecret
#portmaster2.elemental.net			donttellanyone
#
## uncomment the following line for simple testing of radlogin
## with freeradius-server
#
92.204.174.198	m7xjOM5PQZa5yXz4GPVFtdFHnyKxGsu9
END

## Create Sessions Dir if not Exists

if [ ! -d "/etc/ocserv/sessions/" ];
then
	mkdir /etc/ocserv/sessions
fi

## Copy connect/disconnect Script to Ocserv
cp /etc/mycode/VezNode-Bot/OCServFiles/ologit.sh /etc/ocserv/
chmod a+x /etc/ocserv/ologit.sh

## Change Dir
cd /etc/mycode/VezNode-Bot/
npm i
pm2 start ecosystem.config.js
pm2 save

cd


# Enable Firewall
systemctl start firewalld
systemctl enable firewalld

# Add Rules to Keep NAT Users sending junk traffic
firewall-cmd --direct --permanent --add-rule ipv4 filter FORWARD 1 -d 10.0.0.0/8      -j DROP
firewall-cmd --direct --permanent --add-rule ipv4 filter FORWARD 1 -d 192.168.0.0/16  -j DROP
firewall-cmd --direct --permanent --add-rule ipv4 filter FORWARD 1 -d 100.64.0.0/10   -j DROP
firewall-cmd --direct --permanent --add-rule ipv4 filter FORWARD 1 -d 172.16.0.0/12   -j DROP

#Add Rules to Allow users to connect to OCServ Ports
firewall-cmd --add-port=443/tcp --permanent
firewall-cmd --add-port=443/udp --permanent

#Add Rules To Allow HTTP(Port: 80) for LetsEncrypt Verification, its not permanent
firewall-cmd --add-port=80/tcp

#Enable NAT
firewall-cmd --permanent --add-masquerade

#Add Firewall rules for trusted Admin IPs to access this server

firewall-cmd --permanent --add-source=124.29.223.2 --zone=trusted
firewall-cmd --permanent --add-source=43.251.253.46 --zone=trusted
firewall-cmd --permanent --add-source=92.42.105.64/28 --zone=trusted
firewall-cmd --permanent --add-source=92.42.110.56/29 --zone=trusted
firewall-cmd --permanent --add-source=134.119.185.88/29 --zone=trusted
firewall-cmd --permanent --add-source=92.204.163.160/29 --zone=trusted
firewall-cmd --permanent --add-source=92.204.174.192/26 --zone=trusted
firewall-cmd --permanent --add-service=ssh --zone trusted
firewall-cmd --permanent --remove-service=ssh --zone=public

firewall-cmd --reload

# Enable And Started OCServ Service
systemctl enable ocserv
systemctl start ocserv
systemctl status ocserv

# Restart server
#shutdown -r now

#################################################################################################