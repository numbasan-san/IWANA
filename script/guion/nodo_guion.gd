class_name NodoGuion

# Esta es la superclase común a todos los elementos del guión que pueden
# conectarse para determinar el orden en que debe ejecutarse. Actualmente
# las clases hijas son Unidad y OpcionDialogo. Cada nodo solo puede tener
# una conexión saliente a otro nodo, pero muchos nodos pueden tener conexiones
# salientes al mismo. Además, si hay una opción de diálogo en la cadena esta
# debe ser el primer elemento

var siguiente: NodoGuion
