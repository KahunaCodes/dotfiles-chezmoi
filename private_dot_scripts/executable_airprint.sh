#!/bin/zsh
# airprint.sh - Advertise a CUPS printer as AirPrint
# This script runs dns-sd to broadcast the printer for iOS/iPadOS devices
# 
# Usage: Run this script to enable AirPrint for the Logia shipping printer
# Note: This is main-mac specific (printer is connected there)

dns-sd -R "AirPrint Shipping Printer" _ipp._tcp.,_universal . 631 \
txtvers=1 \
qtotal=1 \
rp="printers/_Logia_Printer_2" \
ty="Logia Printer" \
adminurl=https://brandons-mac.local.:631/printers/_Logia_Printer_2 \
note="Brandon's Mac" \
priority=0 \
product="(Logia)" \
pdl=application/octet-stream,application/pdf,image/ipeg,image/png,image/pwg-raster,image/urf \
UUID=80f243d2-e023-3cb2-6803-eb2201d04ea1 \
TLS=1.2 \
Copies=T \
Color=F \
Label=T \
Duplex=F \
air=none \
printer-state=3 \
printer-type=0x9046 \
URF=W8,CP255,RS300-600
