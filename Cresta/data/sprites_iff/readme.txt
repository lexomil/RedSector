Voici les 6 sprites :
 - ils ont tous la meme palette (pour commencer simple)
 - ils sont en 2 bitplans/3 couleurs (couleur 0 = transparence)
 - ils font tous 16 pixel de large et sont de hauteurs variables
 - ils ont un emplacement fixe sur le décor, ce qui permet de les "poser" visuellement sur le sol à l'aide d'une ombre portée qui est dessinée sur le bitmap de sol. Il faudrait donc mettre à jour l'image "ground.iff" également.
 - ils ont chacun une vitesse de défilement qui est la même que la "tranche de sol" sur laquelle ils sont posés.

sprite_0 : (espèce de grande tour en forme de capsule)
coords (x,y) : 82,49 (avec comme origine le début du bitmap de sol)
dimensions : 16x30
zone de scroll : 15 (en partant de zéro à partir du haut)

sprite_1 : (tour/capsule surmontée d'une couronne torique)
coords (x,y) : 220,52
dimensions : 16x22
zone de scroll : 14

sprite_2 : (sorte de pyramide à base carrée)
coords (x,y) : 262,46
dimensions : 16x14
zone de scroll : 11

sprite_3 : (sorte d'antenne en forme de triangle)
coords (x,y) : 26,29
dimensions : 16x26
zone de scroll : 10

sprite_4 : (petite pyramide)
coords (x,y) : 140,30
dimensions : 16x10
zone de scroll : 7

sprite_5 : (truc plat tout en haut)
coords (x,y) : 180,12
dimensions : 16x8
zone de scroll : 3