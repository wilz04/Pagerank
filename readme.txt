No se supone que la matriz o el vector se encuentran en un archivo, en nuestra implementación, estas estructuras se deben pasar por parámetro, por ejemplo:

Nodos = 6,
Trabajadores = 6,
Reductores = -1,
Matrix = {{3, 6}, {2, 5}, {1}, {}, {5, 6}, {2, 3, 4}},
Vector = [1/6, 1/6, 1/6, 1/6, 1/6, 1/6],
multMatriz(Nodos, Trabajadores, Reductores, Matrix, Vector).

Además, no se utiliza el parámetro Reductores, el algoritmo determina la cantidad de reductores que va a requerir y los distribuye de forma balanceada entre los nodos.

Nota: main y multMatriz están definidos dentro del archivo del proyecto.
