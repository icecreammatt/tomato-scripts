## SES - DISABLE Adblocking by Yaqui v1.0
if ps | grep tmp/gen ; then
   service dnsmasq stop
   killall -9 dnsmasq
   logger ADBLOCK SES button activated adblock shutdown
   sleep 2
   dnsmasq
   led amber on   #Turn on warning light that adblock is off!
fi