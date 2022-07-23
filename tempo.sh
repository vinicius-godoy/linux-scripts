#!/usr/bin/env bash

clear;echo
echo -e "Converter segundos em minutos e segundos"
read -p "Tempo em segundos: " tempo
minutos=$[tempo/60]
segundos=$[tempo-minutos*60];echo
echo -e "Seu tempo em minutos e segundos é de: $minutos \bm e $segundos \bs!"
echo
