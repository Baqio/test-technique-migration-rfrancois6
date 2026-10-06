# Notes de reprise

Les points marqués [confirmé] ont fait l'objet d'une réponse du client le 5 octobre.

## Décisions

- Trois codes clients apparaissent deux fois à l'identique (T00101, T01501, T03211) et sont fusionnés en une seule fiche. Au total, le fichier contient 4 997 lignes client, dont trois doublons exacts et trois lignes sans aucun identifiant qui ne sont pas reprises, soit 4 991 clients en base.
- Un client sans pays renseigné est considéré comme français. 989 clients sont concernés. [confirmé]
- La correspondance des pays ne couvre que la France, la Belgique et l'Allemagne, les trois seuls présents dans l'export. Un pays renseigné mais inconnu est importé sans valeur plutôt que deviné, et signalé. À compléter si d'autres apparaissent.
- La même règle s'applique aux adresses de livraison sans pays : 401 d'entre elles sont traitées comme françaises. La réponse du client ne portait que sur l'adresse principale, ce point reste à confirmer.
- Les codes postaux français sont complétés à cinq chiffres, le tableur ayant supprimé leur zéro initial en les stockant comme des nombres. Le complément ne s'applique qu'à la France : 9000 est un code belge valide.
- Les numéros de téléphone retrouvent eux aussi leur zéro initial, mais leur ponctuation est conservée telle qu'elle a été saisie. On répare ce que le tableur a cassé, on ne réécrit pas ce que le client a écrit.
- Les téléphones saisis « N/C » sont importés comme absents : c'est une absence déguisée en valeur, et le champ stocke des numéros, pas des commentaires. 207 valeurs sont concernées, chez 150 clients.
- L'adresse de remplissage contact@baqio.fake, portée par 497 clients, est elle aussi traitée comme une absence. Chaque cas est signalé. [confirmé]
- Huit colonnes du fichier clients portent le même intitulé, une fois pour la facturation et une fois pour la livraison. Elles sont distinguées par leur position, faute de quoi seule la seconde serait conservée.
- Quand le fichier indique une adresse de livraison distincte, elle est reprise comme telle ; sinon le client est marqué comme livré à son adresse de facturation.
- Les clients marqués « inutilisable » dans la source sont importés comme inactifs. Ils sont 340.
- Le fichier distingue quatre familles de tiers : clients, prospects, fournisseurs et revendeurs. Les 982 revendeurs sont importés comme clients, et leur famille d'origine est conservée dans la catégorie client. [confirmé]
- Le libellé de famille n'est pas repris du fichier, où il apparaît sous deux casses différentes (« CLIENT FRANCE » et « Client France »). Il est déduit du code famille, ce qui garantit un libellé unique par famille. [confirmé]
- Les numéros de TVA sont nettoyés de leurs espaces internes.
- Six références produit désignent chacune deux articles différents — TER232 est à la fois « Terrasses du Sud 2023 » et « Eau de source 2023 ». L'ordre des lignes ne permet pas de savoir laquelle fait foi : les douze lignes concernées ne sont pas reprises et sont listées dans le rapport, en attendant les références corrigées. [confirmé]
- La grille EXPO est saisie en TTC. Elle est convertie en HT avec le taux de TVA de chaque produit, et non avec un taux unique : dix produits sont à 5,5 %, les autres à 20 %.
- Soixante-trois cases de prix sont vides (60 en SALON, 3 en PART). Aucun tarif n'est créé pour ces grilles : un prix absent n'est pas un prix à zéro. Le rapport en compte 56, les sept autres appartenant à des lignes écartées pour référence en double.
- Le volume est lu dans le libellé du contenant, exprimé en centilitres (« ½ Bouteille - 37.5 » donne 375 ml). Treize produits n'ont pas de contenant renseigné et sont importés sans volume. Deux libellés décrivent un conditionnement et non un contenant (« 6 x 75 » et « Carton 6 ») : ils sont importés sans volume et signalés.
- Le millésime est séparé du nom du produit : « Coteaux Nord 2019 » donne « Coteaux Nord » et 2019. La mention « N.M. », qui signifie non millésimé, est conservée telle quelle.
- Chaque ligne des fichiers source laisse une trace de ce qu'elle est devenue et pourquoi, afin que la reprise puisse être relancée sans créer de doublon et que tout rejet reste justifiable après coup.

## Points confirmés par le client

- Un client sans pays renseigné est français.
- Trois clients déclarés en Belgique ou en Allemagne portent un numéro de TVA français (T00331, T02756, T04101) : les deux informations sont justes, ces clients ont une adresse à l'étranger mais sont facturés via une structure française.
- Une fois ramenée en HT, la grille EXPO est identique à la grille DEPC sur 112 des 113 produits : c'est volontaire, le prix export est le même que le prix départ cave.
- Le total de 5 000 tiers annoncé par le fichier inclut des fiches supprimées dans CaveGest. Il ne manque donc pas de clients.
- Le produit HAU214 « Tradition 2019 » affiche un prix DEPC de 34,35 € alors que ses autres grilles correspondent à un prix de base d'environ 7,37 €. Le client confirme une erreur de saisie. Cette ligne fait par ailleurs partie des références en double et n'est pas reprise.

## Reste à confirmer

- Le pays de livraison absent sur 401 adresses, traité comme français par analogie avec l'adresse principale.
- Cinq clients sont rattachés à la grille tarifaire GDCPT, qui ne figure dans aucun tarif du catalogue. À l'inverse, la grille SALON est tarifée sur 48 produits mais n'est portée par aucun client.

## Constats

- Le fichier clients compte 4 997 lignes client, avec quatre lignes vides intercalées aux positions 602, 2102, 3602 et 5002. L'export lui-même semble donc avoir eu des ratés.
- Trois lignes du fichier clients n'ont ni raison sociale, ni nom, ni prénom. Elles ne sont pas reprises et figurent dans le rapport avec leur numéro de ligne.
- Le fichier tarifs annonce lui-même le nombre de produits par section (14, 16, 18, 22, 21, 22). Ces comptes ne sont pas encore recoupés avec la base : la section n'est pas stockée, le contrôle demanderait de relire le fichier pour reconstituer la correspondance.
- Le taux de TVA est saisi de trois manières dans le fichier tarifs : 20 sur 102 lignes, 20% sur une seule, et 5,50 pour les dix produits non alcoolisés. Les trois formes sont lues correctement.