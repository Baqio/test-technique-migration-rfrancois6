# Notes de reprise
## décisions
- Les trois codes clients strictement en double (T00101, T01501, T03211) sont fusionnés en un seul enregistrement, les lignes étant identiques. C'est pour ça que la base contient 4 994 clients et non 4 997.
- La table de correspondance des pays ne couvre que la France, la Belgique et l'Allemagne, les trois seuls pays présents dans l'export. Une valeur inconnue est importée sans pays plutôt que devinée. À compléter si d'autres pays apparaissent.

## questions
- 990 clients n'ont pas de pays renseigné. Importés sans pays. Faut-il les considérer comme français par défaut ?
- Quatre clients déclarés en Belgique ou en Allemagne portent un numéro de TVA français. Les deux valeurs sont importées telles quelles. Lequel des deux champs fait foi ?

## constats