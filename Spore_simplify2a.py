# Spore_simplify2a.py

import sys
import re

countFile=sys.argv[1]
sampleTag=re.search(r"____(.*)_.txt",countFile).groups()[0]

file = open(countFile).read().split("\n")
out = open("Spores_ex1_binary____"+sampleTag+".txt","w")

out.write("chr\tpos_c\tbA1\tbA2\tbB1\tbB2\tbC1\tbC2\tbD1\tbD2\n")

for i in range(1,len(file)-1):
    line = file[i].split("\t")
    chromo = line[0]
    pos_c = line[2]

    b1 = 0 ; b2 = 0 ; b3 = 0 ; b4 = 0
    b5 = 0 ; b6 = 0 ; b7 = 0 ; b8 = 0
    b = [b1,b2,b3,b4,b5,b6,b7,b8]

    pb = 0

    for k in range(8):
        val_c = line[5+k]
        val_k = line[5+k+8]

        if val_c == val_k == "NA":
            pb = 1
            break

        elif val_c == "NA" and val_k != "NA" :
            if int(val_k) > 15 :
                b[k] = 0
            else :
                pb = 1
                break

        elif val_c != "NA" and val_k == "NA" :
            if int(val_c) > 15 :
                b[k] = 1
            else :
                pb = 1
                break

        elif val_c != "NA" and val_k != "NA":
            if int(val_c) > 40 and int(val_k) < 5 :
                b[k] = 1

            elif int(val_c) < 5 and int(val_k) > 40 :
                b[k] = 0

            else :
                pb = 1
                break

    if pb==0 and b[0]==b[1]==b[2]==b[3]==b[4]==b[5]==b[6]==b[7]:
        pb = 1

# ATTENTION A L'ORDRE DES SPORES DANS LE FICHIER DE SORTIE

    if not pb :
        out.write("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" %(chromo,pos_c,
                   b[0],b[1],b[2],b[3],b[4],b[5],b[6],b[7]))

out.close()
