# PPAR_TP6

Pour plus d'info, se referer au pdf

## Optimising memory access

2 - Nombre de reads par cellule : 9 (myself et les 8 alentour)
Lectures coalescentes ? Théoriquement oui par groupe de 3, en pratique non.

3 - Lectures d'un block de 1 * nbthreads : (1 + 2)*(nbthreads + 2) blocks à lire. Donc avec des blocks de 64, ça fait 3*66 = 198 lectures.
4 - Avec des blocks bidimensionnels, on se retrouve avec un nombre de lecture de (a+2)*(b+2), avec a et b les cotés du rectangle de lecture. Pour minimiser le nombre de lectures, la forme carrée est logique, donc avec 64 threads, on a :
(sqrt(nbthreads)+2)², soit 10² = 100 lectures

## Optimizing computations and datatypes

6 - 
