## ALL-U-NEED AdBlocking By YAQUI 5/1/09
## Dnsmasq Ed. v2.92
sleep 20

## Auto Update? (Y or N)
AUPD="N"

## Create ADBLOCK.sh
rm -f /tmp/ADBLOCK.sh
ADB="/tmp/ADBLOCK.sh"
touch $ADB
(
cat <<'ENDF'
#!/bin/sh

## EDITABLE VARIABLES
OPTIMISE="N"
S1="http://www.mvps.org/winhelp2002/hosts.txt"                      # ~612K
S2="http://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts"  # ~72K
S3="http://someonewhocares.org/hosts/hosts"                         # ~208K
S4="http://hostsfile.mine.nu/Hosts"                                 # ~2.59M
GETS1="Y"
GETS2="Y"
GETS3="N"
GETS4="N"
USEWHITELIST="Y"
# Enter sites in format below
WHITE="editme.com
editme.com
editme.com"

## DO NOT EDIT BELOW
NIP="0.0.0.0"
GEN="/tmp/gen"
TMP="/tmp/temp"
D=""

## FUNCTIONS
CLR ()
{
rm -f $GEN
rm -f $TMP
touch $GEN
touch $TMP
}

FMEM ()
{
service dnsmasq stop
killall -9 dnsmasq
logger ADBLOCK Freeing Memory
}

DS1 ()
{
##(Inline grep for 127.0.0.1 & Delete DOS Format Returns)
D=0
if [[ $GETS1 == "Y" ]] ; then
if wget $S1 -O - | grep 127.0.0.1 | tr -d "\r" >> $GEN ; then
logger ADBLOCK Retrieved S1 $S1
D=1
else
logger ADBLOCK S1 ERROR
fi
fi
}

DS2 ()
{
D=0
if [[ $GETS2 == "Y" ]] ; then
if wget $S2 -O - | grep 127.0.0.1 | tr -d "\r" >> $GEN ; then
logger ADBLOCK Retrieved S2 $S2
D=1
else
logger ADBLOCK S2 ERROR
fi
fi
}

DS3 ()
{
D=0
if [[ $GETS3 == "Y" ]] ; then
if wget $S3 -O - | grep 127.0.0.1 | tr -d "\r" >> $GEN ; then
logger ADBLOCK Retrieved S3 $S3
D=1
else
logger ADBLOCK S3 ERROR
fi
fi
}

DS4 ()
{
D=0
if [[ $GETS4 == "Y" ]] ; then
if wget $S4 -O - | grep 127.0.0.1 | tr -d "\r" >> $GEN ; then
logger ADBLOCK Retrieved S4 $S4
D=1
else
logger ADBLOCK S4 ERROR
fi
fi
}

CLN ()
{
if [[ $D = 1 ]] ; then
sed -i -e 's/[[:cntrl:][:blank:]]//g' $GEN
sed -i -e '/\#.*$/ s/\#.*$//' $GEN
sed -i -e '/\[.*\]/ s/\[.*\]//' $GEN
sed -i -e '/^$/d' $GEN
sed -i -e '/127\.0\.0\.1/ s/127\.0\.0\.1//' $GEN
sed -i -e '/^www[0-9]*\./ s/^www[0-9]*\.//' $GEN
sed -i -e '/^[0-9]*www[0-9]*\./ s/^[0-9]*www[0-9]*\.//' $GEN
sed -i -e '/^www\./ s/^www\.//' $GEN
sed -i -e '/</d' $GEN
sed -i -e 's/^[ \t]*//;s/[ \t]*$//' $GEN
cat $GEN | sort -u > $TMP
mv $TMP $GEN
rm -f $TMP
logger ADBLOCK List Cleaned
fi
}

FDNSM ()
{
sed -i -e 's|$|/'$NIP'|' $GEN
sed -i -e 's|^|address=/|' $GEN
}

LCFG ()
{
cat /etc/dnsmasq.conf >> $GEN
}

OPT ()
{
if [[ $OPTIMISE == "Y" ]] ; then
cat >> $GEN <<EOF
cache-size=2048
log-async=5
EOF
fi
}

LWHT ()
{
if [[ $USEWHITELIST == "Y" ]] ; then
for site in $WHITE
do
sed -i -e "/$site/d" $GEN
done
logger ADBLOCK Whitelist Applied
fi
}

LBLK ()
{
dnsmasq --conf-file=$GEN
}

TST ()
{
sleep 15
if sed -n -e '/^address=\/ad\..*\..*\/0\.0\.0\.0$/p' $GEN ; then
TOT=`wc -l $GEN | cut -d" " -f5`
logger ADBLOCK List Sample Format SUCCESS
logger ADBLOCK List Contains End Total of $TOT Entries
else
logger ADBLOCK List ERROR
fi
}

FS ()
{
if ps | grep -E "dnsmasq" | grep -E "nobody" ; then
logger ADBLOCK Dnsmasq is Running Failsafe Ignored
else
logger ADBLOCK Dnsmasq NOT Running Dnsmasq Restarting
service dnsmasq stop
killall -9 dnsmasq
dnsmasq
fi
}

## Run Functions
CLR
FMEM
DS1
CLN
DS2
CLN
DS3
CLN
DS4
CLN
FDNSM
LCFG
OPT
LWHT
LBLK
TST
FS
CLR

## End of ADBLOCK.sh
ENDF
) > $ADB

AUP ()
{
if [[ $AUPD == "Y" ]] ; then
if [[ $(cru l | grep AdUpd | cut -d "#" -f2) != "AdUpd" ]] ; then
## cru (a)dd <name> "min hr day mo wkday <cmd>"
## min=0-59 hour=0-23 day=1-31 month=1-12 sun=0 *=all
cru a AdUpd "0 0 * * 2 $ADB"
fi
fi
}

## Run ADBLOCK.sh & AUP
chmod 777 $ADB
$ADB
AUP