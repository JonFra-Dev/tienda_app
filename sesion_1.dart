void main(){
  String? nombre = "Jonathan";
  print("Hola $nombre bienvenido a Dart");
  
  List<int> numeros = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  numeros.forEach((numero) {
    print(numero);
  });
  Map<String, int> edades = {
    "John": 30,
    "Jane": 25,
    "Judith": 27,
    "Jeronimo": 29,
    "Jimy": 31
  };
  edades.forEach((nombre, edad) {
    print("$nombre tiene $edad años");
  });
}
