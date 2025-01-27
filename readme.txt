Profe,

En caso de que no nos pueda escribir a tiempo, le adjuntamos el proyecto (main.erl) y le copiamos unas notas sobre él:

Nosotros no suponemos que la matriz o el vector se encuentran en un archivo, en nuestra implementación estas estructuras se deben pasar por parámetro, por ejemplo:

Nodos = 6,
Trabajadores = 6,
Reductores = -1,
Matrix = {{3, 6}, {2, 5}, {1}, {}, {5, 6}, {2, 3, 4}},
Vector = [1/6, 1/6, 1/6, 1/6, 1/6, 1/6],
multMatriz(Nodos, Trabajadores, Reductores, Matrix, Vector).

Además, como puede ver no utilizamos el parámetro Reductores, nuestro algoritmo determina la cantidad de reductores que va a requerir y los distribuye de forma balanceada entre los nodos.

Nota: Dentro del archivo del proyecto definimos una función main, y además la multMatriz.

Saludos,

José Somarribas, Wilberth Castro.
