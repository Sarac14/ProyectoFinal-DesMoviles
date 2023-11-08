# Documentación de la Aplicación
La aplicación Pokedex es una aplicación que permite a los usuarios obtener información detallada sobre Pokémon utilizando la API pública PokeApi. Además, en nestra versión de la pokedex los usuarios pueden agregar Pokémon a su lista de favoritos y ver detalles de los mismos. La aplicación proporciona información sobre los Pokémon, como su nombre, imagen, tipos, altura y peso; así como también los movimientos de cada uno.

## Cómo Funciona la Aplicación
La aplicación consta de las siguientes partes clave:

- FavoritePokemonScreen: Esta es la pantalla principal de la aplicación. Muestra la lista de Pokémon favoritos en una cuadrícula con detalles básicos. Los Pokémon se pueden tocar para ver detalles adicionales.

- PokeDatabase: Esta clase gestiona la base de datos SQLite de la aplicación. Almacena la información de los Pokémon y permite a los usuarios marcar Pokémon como favoritos.

- PokemonItem: Representa un objeto Pokémon con detalles como el ID, el nombre, la imagen, los tipos, la altura y el peso. También puede analizar los datos de la API para crear instancias de PokemonItem.

## Acceso a los Datos de Pokémon
La aplicación obtiene datos de Pokémon de la API de Pokémon. Aquí hay un resumen de cómo se accede a los datos de la API:

- La clase PokeDatabase contiene métodos para realizar operaciones de base de datos, como insertar Pokémon y marcarlos como favoritos. También proporciona métodos para recuperar la lista de Pokémon favoritos y sus URL de API.

- La función enviandoUrlFavoritoApi() se utiliza para obtener datos específicos de Pokémon de la API. Utiliza las URL de los Pokémon almacenados en la base de datos para realizar solicitudes HTTP a la API y recuperar detalles como el nombre, la imagen, los tipos, la altura y el peso.

## Decisiones de Diseño
- La aplicación utiliza Flutter para la creación de interfaces de usuario multiplataforma.

- Se utiliza una base de datos SQLite para almacenar los Pokémon y sus estados favoritos.

- Los Pokémon favoritos se muestran en una cuadrícula en FavoritePokemonScreen, con una variedad de detalles visuales, como colores basados en tipos y una imagen de Pokeball decorativa.

- Se gestionan errores y mensajes de estado a través de notificaciones emergentes (SnackBar) que informan al usuario sobre problemas o acciones exitosas.

- Se utiliza el patrón FutureBuilder para manejar la carga de datos asincrónicos y mostrar una barra de progreso mientras se obtienen los datos.

## Tecnologías Utilizadas
- Flutter: La aplicación está construida utilizando el framework de desarrollo de aplicaciones móviles Flutter.

- Dart: El lenguaje de programación Dart se utiliza para escribir el código de la aplicación.

- SQLite: Se utiliza una base de datos SQLite para almacenar y gestionar los Pokémon favoritos del usuario.

- HTTP: La biblioteca http se utiliza para realizar solicitudes a la API de Pokémon y obtener datos en formato JSON.

- JSON: Los datos de la API se devuelven en formato JSON y se analizan en objetos Dart.


