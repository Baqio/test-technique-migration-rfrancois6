# Notes de reprise
## Décisions
- Les trois codes clients strictement en double (T00101, T01501, T03211) sont fusionnés en un seul enregistrement, les lignes étant identiques. C'est pour ça que la base contient 4 994 clients et non 4 997.
- La table de correspondance des pays ne couvre que la France, la Belgique et l'Allemagne, les trois seuls pays présents dans l'export. Une valeur inconnue est importée sans pays plutôt que devinée. À compléter si d'autres pays apparaissent.
- Les codes postaux français sont complétés à cinq chiffres, pour la même raison. Le remplissage ne s'applique qu'à la France : 9000 est un code belge valide.
- Les 150 téléphones saisis N/C sont importés comme absents : c'est une absence déguisée en valeur, et la colonne stocke des numéros, pas des commentaires.
- Les numéros de téléphone sont complétés du zéro initial qu'Excel a supprimé en les stockant comme entiers, mais leur ponctuation est conservée telle que saisie. On répare, on ne réécrit pas.
- Huit colonnes du fichier clients portent le même intitulé, une fois pour la facturation et une fois pour la livraison. Elles sont lues par position et non par nom, faute de quoi seule la seconde serait conservée.
- Chaque ligne des fichiers source laisse une trace en base : son fichier, son numéro de ligne, la clé lue, ce qu'elle est devenue et pourquoi. La reprise peut ainsi être relancée sans doublon, et tout rejet reste justifiable après coup.
- Les 982 revendeurs deviennent customer, avec une réserve tracée par ligne. Ils sont listés dans le rapport.
- Si les colonnes de livraison contiennent quoi que ce soit, use_billing_address passe à false et on remplit ce qu'on a.
- Les trois doublons exacts : la première ligne crée, la seconde met à jour, les deux sont tracées.
- Inutilisable = 1 donne active = false.
- Les trois clients sans identifiant sont rejetés avec motif.
- contact@baqio.fake est traité comme une absence, chaque cas tracé.
- customer_category reçoit le libellé de famille.
- les numéros de TVA sont nettoyés de leurs espaces internes.

## Questions
- 990 clients n'ont pas de pays renseigné. Importés sans pays. Faut-il les considérer comme français par défaut ?
- Quatre clients déclarés en Belgique ou en Allemagne portent un numéro de TVA français. Les deux valeurs sont importées telles quelles. Lequel des deux champs fait foi ?

## Constats
- Le fichier tarifs annonce lui-même le nombre de produits par section (14, 16, 18, 22, 21, 22). Ces comptes sont lus et serviront de contrôle en fin de reprise.
- Le fichier clients se termine par une ligne annonçant 5 000 tiers, alors qu'il contient 4 997 lignes dont trois doublons, soit 4 994 clients distincts. L'écart sera signalé en fin de reprise.
- trois lignes du fichier n'ont ni raison sociale, ni nom, ni prénom. Elles ne sont pas reprises et figurent dans le rapport avec leur numéro de ligne.