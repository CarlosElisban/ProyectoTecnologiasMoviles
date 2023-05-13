import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/new_activity': (context) => NewActivity(),
      },
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class DatabaseHelper {
  static final _databaseName = "mydatabase.db";
  static final _databaseVersion = 1;
  static final table = 'users';
  static final columnId = '_id';
  static final columnName = 'name';
  static final columnEmail = 'email';
  static final columnPassword = 'password';
  static final columnDNI = 'dni';
  static final columnInstituto = 'instituto';

  // Make this a singleton class.
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only have a single app-wide reference to the database.
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // open the database
  _initDatabase() async {
    String path = await getDatabasesPath();
    path = join(path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL string to create the database and table
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnName TEXT NOT NULL,
            $columnEmail TEXT NOT NULL,
            $columnPassword TEXT NOT NULL,
            $columnDNI TEXT NOT NULL,
            $columnInstituto TEXT NOT NULL
          )
          ''');
  }

  // Helper methods

  // Insert a row in the table
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  // Authenticate user with email and password
  Future<Map<String, dynamic>> authenticateUser(String email, String password) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> results = await db.query(
      table,
      columns: [columnId, columnName, columnEmail, columnPassword, columnDNI, columnInstituto],
      where: "$columnEmail = ? AND $columnPassword = ?",
      whereArgs: [email, password],
      limit: 1,
    );

    if (results.length > 0) {
      return results[0];
    } else {
      return {};
    }
  }
  Future<Map<String, dynamic>> authenticateUserPerfil(String email) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> results = await db.query(
      table,
      columns: [columnId, columnName, columnEmail, columnPassword, columnDNI, columnInstituto],
      where: "$columnEmail = ?",
      whereArgs: [email],
      limit: 1,
    );
    return results[0];
  }
  Future<int> updateUser(String email, Map<String, dynamic> updatedUser) async {
    final db = await instance.database;
    return await db.update(
      table,
      updatedUser,
      where: '$columnEmail = ?',
      whereArgs: [email],
    );
  }
  Future<int> deleteUser(String email) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
  }
}


class _NewActivityState extends State<NewActivity> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordControllerR = TextEditingController();
  final _passwordControllerRConfirm = TextEditingController();
  final _DNIController = TextEditingController();
  final _institutoController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar usuario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Nombre"),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Ingrese su nombre',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Por favor, ingrese su nombre';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              Text("Email"),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Ingrese su email',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Por favor, ingrese su correo electrónico';
                  } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                    return 'Por favor, ingrese un correo electrónico válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              Text("Contraseña"),
              TextFormField(
                controller: _passwordControllerR,
                decoration: InputDecoration(
                  hintText: 'Ingrese su contraseña',
                ),
                obscureText: true,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Por favor, ingrese su contraseña';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              Text("Confirmar Contraseña"),
              TextFormField(
                controller: _passwordControllerRConfirm,
                decoration: InputDecoration(
                  hintText: 'Ingrese su contraseña nuevamente',
                ),
                obscureText: true,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Por favor, ingrese su contraseña';
                  } else if (value != _passwordControllerR.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              Text("DNI"),
              TextFormField(
                controller: _DNIController,
                decoration: const InputDecoration(
                  hintText: 'Ingrese su número de DNI',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Por favor, ingrese su número de DNI';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              Text("Instituto"),
              TextFormField(
                controller: _institutoController,
                decoration: const InputDecoration(
                  hintText: 'Ingrese el nombre de su instituto',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Por favor, ingrese el nombre de su instituto';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Send data to API or do something with data
                    Map<String, dynamic> row = {
                      DatabaseHelper.columnName: _nameController.text,
                      DatabaseHelper.columnEmail: _emailController.text,
                      DatabaseHelper.columnPassword: _passwordControllerR.text,
                      DatabaseHelper.columnDNI: _DNIController.text,
                      DatabaseHelper.columnInstituto: _institutoController.text
                    };
                    final id = await DatabaseHelper.instance.insert(row);
                    print('inserted row id: $id');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage(title: "Login")),

                    );
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




  class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Bienvenido a Toph!',
               style: TextStyle(fontSize: 24.0),
            ),
            const SizedBox(height: 16), // Separador vertical
            Image.network(
              'https://i.pinimg.com/736x/d5/03/c9/d503c957e17b0a45dda41e38b0d13d7a.jpg',
              width: 200, // Ancho de la imagen
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your email address';
                        } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final email = _emailController.text;
                          final password = _passwordController.text;
                          final user = await DatabaseHelper.instance.authenticateUser(email, password);
                          print(user);
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString("miCorreo", email);
                          if (user.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => NewActivity2()),
                            );
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('ERROR'),
                                  content: Text('El correo electrónico o la contraseña son incorrectos.'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        }
                      },
                      child: Text('Iniciar sesión'),
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewActivity()),
                );
              },
              child: Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }
}

class NewActivity extends StatefulWidget {
  const NewActivity({Key? key}) : super(key: key);

  @override
  _NewActivityState createState() => _NewActivityState();
}
class NewActivity2 extends StatefulWidget {
  const NewActivity2({Key? key}) : super(key: key);

  @override
  _NewActivityState2 createState() => _NewActivityState2();
}
class EjercicioDetallesScreen extends StatefulWidget {
  final String imagePath;
  EjercicioDetallesScreen({required this.imagePath});
  @override
  _EjercicioDetallesScreenState createState() =>
      _EjercicioDetallesScreenState();
}
class InformacionScreen extends StatelessWidget {
  void _abrirActividadC(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ActividadC()),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Información'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // Mostrar menú desplegable del perfil
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(
                  MediaQuery.of(context).size.width - 100.0,
                  kToolbarHeight,
                  0.0,
                  0.0,
                ),
                items: [
                  PopupMenuItem(
                    value: 'perfil',
                    child: Text('Mi perfil'),
                  ),
                  PopupMenuItem(
                    value: 'configuracion',
                    child: Text('Configuración'),
                  ),
                  PopupMenuItem(
                    value: 'cerrar_sesion',
                    child: Text('Cerrar sesión'),
                  ),
                ],
              ).then((value) {
                if (value == 'perfil') {
                  _abrirActividadC(context);
                }
              });
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 1,
            ),
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                "https://scontent.faqp2-3.fna.fbcdn.net/v/t39.30808-6/344311406_542428821429320_8500364704444899324_n.jpg?_nc_cat=103&ccb=1-7&_nc_sid=730e14&_nc_eui2=AeEnW-YaIOfOLKUPZccX5R_VIPpMiCr3ZWEg-kyIKvdlYQa1f0c2QGzG1LGgzA3c_Pttqtda9aHp7K86dP9Y-LpQ&_nc_ohc=ra2xnLxVNWMAX-wmIu3&_nc_ht=scontent.faqp2-3.fna&oh=00_AfDIdm8gJbnTHlEEssd9fCV4n6d-xM5T0uaeXqLis2YigQ&oe=645EF680",
                width: 320,
                height: 320,
              ),
              SizedBox(height: 0),
              Text(
                'Información del ejercicio',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Duración:',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '30 segundos',
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dificultad:',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Media',
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 7),
              Row(
                children: [
                  Expanded(
                   child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Movimiento del tren superior:',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Correcta',
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Consejos:',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Ninguno',
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 7),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Movimiento del tren inferior:',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Incorrecta',
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Consejos:',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Se requiere que ambos pies esten en el suelo',
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 7),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resultado completo:',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '60/100',
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Repeticiones:',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '10',
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        //Cambiar mas adelante
                        MaterialPageRoute(builder: (context) => NewActivity2()),
                      );
                    },
                    child: Text(
                      'Confirmar',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class _EjercicioDetallesScreenState extends State<EjercicioDetallesScreen> {
  bool _isPlaying = true;

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }
  void _abrirActividadC(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ActividadC()),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Ejercicio'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // Mostrar menú desplegable del perfil
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(
                  MediaQuery.of(context).size.width - 100.0,
                  kToolbarHeight,
                  0.0,
                  0.0,
                ),
                items: [
                  PopupMenuItem(
                    value: 'perfil',
                    child: Text('Mi perfil'),
                  ),
                  PopupMenuItem(
                    value: 'configuracion',
                    child: Text('Configuración'),
                  ),
                  PopupMenuItem(
                    value: 'cerrar_sesion',
                    child: Text('Cerrar sesión'),
                  ),
                ],
              ).then((value) {
                if (value == 'perfil') {
                  _abrirActividadC(context);
                }
              });
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              "https://scontent.faqp2-1.fna.fbcdn.net/v/t39.30808-6/343016082_233756192639185_3369699152325551161_n.jpg?_nc_cat=106&ccb=1-7&_nc_sid=730e14&_nc_eui2=AeFLVV3pd6Y3rgOjA1xcBcp2lzVhMPY44R-XNWEw9jjhH_6PJe9jJG2PLBHqIXDLITFDbED6iKxR4kSOZw2mOJRe&_nc_ohc=SNr_Pzch5pQAX9OabOl&_nc_ht=scontent.faqp2-1.fna&oh=00_AfAVrOXr8672J9sJL5tq2hKKdvDeKn48Cq8YQHn0EK7WDw&oe=645EFFFA",
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showDialog(context);
                  },
                  child: Icon(Icons.redo),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(20),
                    primary: Colors.orange,
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _togglePlayPause,
                  child: Icon(
                    _isPlaying ? Icons.play_arrow : Icons.stop,
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(20),
                    primary: _isPlaying ? Colors.blue : Colors.red,
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => InformacionScreen()),
                    );
                  },
                  child: Icon(Icons.info),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(20),
                    primary: Colors.yellow,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Borrar grabación'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('¿Esta seguro de eliminar la grabación?'),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Si'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('No'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NewActivityState2 extends State<NewActivity2> {
  final List<String> _imagePaths = [    'https://images.ecestaticos.com/WAot9QyeV2vzRuE1gVu55WLdv7Y=/0x0:0x0/1200x900/filters:fill(white):format(jpg)/f.elconfidencial.com%2Foriginal%2Fb3c%2Fc7c%2Fff6%2Fb3cc7cff6cc1ee44df172f15afa3e4f9.jpg',    'https://www.sportlife.es/uploads/s1/76/28/31/1/article-flexion-hacia-delante-sentada-isquiotibiales-580f4b65a2c89.jpeg',    'https://media.istockphoto.com/id/1327616016/es/vector/atleta-masculino-saltando-en-el-estadio.jpg?s=612x612&w=0&k=20&c=nUIjYqI_OVV-Le43QPdQT55xPDPbUgOnFSmRykCWPc0=',    'https://calmatel.com/assets/wp-content/uploads/2018/12/sentadillas.jpg',    'https://images.vexels.com/media/users/3/191646/isolated/lists/06b52fbff7982a431f671f7ce7349f29-gran-silueta-de-rutina-de-ejercicios.png',    'https://st2.depositphotos.com/3837271/10204/i/450/depositphotos_102044118-stock-photo-coming-soon-written-on-track.jpg',  ];

  void _handleProfileMenuSelection(String value) {
    // Manejar la selección del elemento del menú
    // Aquí puede agregar lógica para navegar a diferentes pantallas o realizar otras acciones
  }
  void _abrirActividadC(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ActividadC()),
    );
  }
  void _abrirConfiguracion(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Configuracion()),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Opciones de ejercicios'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // Mostrar menú desplegable del perfil
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(
                  MediaQuery.of(context).size.width - 100.0,
                  kToolbarHeight,
                  0.0,
                  0.0,
                ),
                items: [
                  PopupMenuItem(
                    value: 'perfil',
                    child: Text('Mi perfil'),
                  ),
                  PopupMenuItem(
                    value: 'configuracion',
                    child: Text('Configuración'),
                  ),
                  PopupMenuItem(
                    value: 'cerrar_sesion',
                    child: Text('Cerrar sesión'),
                  ),
                ],
              ).then((value) {
                 if (value == 'perfil') {
                    _abrirActividadC(context);
                }else if (value == 'configuracion') {
                   _abrirConfiguracion(context);
                 }
            });
              },
          ),
      ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Selecciona un ejercicio',
              style: TextStyle(fontSize: 24.0),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: GridView.builder(
                itemCount: _imagePaths.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EjercicioDetallesScreen(
                            imagePath: _imagePaths[index],
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        _imagePaths[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class ActividadC extends StatefulWidget {
  const ActividadC({Key? key}) : super(key: key);

  @override
  _ActividadCState createState() => _ActividadCState();
}

class _ActividadCState extends State<ActividadC> {
  late String _valor;
  Map<String, dynamic> _userLogin = {};

  @override
  void initState() {
    super.initState();
    _leerValorDeSharedPreferences();
  }

  Future<void> _leerValorDeSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final valor = prefs.getString('miCorreo') ?? '';
    setState(() {
      _valor = valor;
    });

    final userlogin = await DatabaseHelper.instance.authenticateUserPerfil(_valor);
    setState(() {
      _userLogin = userlogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi perfil'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: _userLogin.isNotEmpty
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 20.0),
                child: Image.network(
                  'https://p16-va-default.akamaized.net/img/musically-maliva-obj/1665282759496710~c5_720x720.jpeg',
                  height: 200,
                ),
              ),
              Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  'Correo: ${_userLogin['email']}',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              SizedBox(height: 10.0),
              Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  'Nombre: ${_userLogin['name']}',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              SizedBox(height: 10.0),
              Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  'DNI: ${_userLogin['dni']}',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              SizedBox(height: 10.0),
              Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  'Instituto: ${_userLogin['instituto']}',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          )
              : CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class Configuracion extends StatefulWidget {
  const Configuracion({Key? key}) : super(key: key);

  @override
  _ConfiguracionState createState() => _ConfiguracionState();
}

class _ConfiguracionState extends State<Configuracion> {
  final _formKey = GlobalKey<FormState>();
  late String _valor;
  Map<String, dynamic> _userLogin = {};

  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _dniController = TextEditingController();
  final _institutoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _leerValorDeSharedPreferences();
  }

  Future<void> _leerValorDeSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final valor = prefs.getString('miCorreo') ?? '';
    setState(() {
      _valor = valor;
    });

    final userlogin = await DatabaseHelper.instance.authenticateUserPerfil(_valor);
    setState(() {
      _userLogin = userlogin;
      _emailController.text = _userLogin['email'] ?? '';
      _nameController.text = _userLogin['name'] ?? '';
      _dniController.text = _userLogin['dni'] ?? '';
      _institutoController.text = _userLogin['instituto'] ?? '';
    });
  }

  Future<void> _actualizarDatos() async {
    if (_formKey.currentState!.validate()) {
      final updatedUser = {
        'email': _emailController.text,
        'name': _nameController.text,
        'dni': _dniController.text,
        'instituto': _institutoController.text,
      };

      final rowsAffected = await DatabaseHelper.instance.updateUser(_valor, updatedUser);
      if (rowsAffected > 0) {
        setState(() {
          _userLogin = updatedUser;
        });
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(SnackBar(content: Text('Datos actualizados')));
      } else {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(SnackBar(content: Text('Error al actualizar los datos')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Configuración'),
        ),
        body: Padding(
        padding: const EdgeInsets.all(16.0),
    child: Form(
    key: _formKey,
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    TextFormField(
    controller: _emailController,
    decoration: InputDecoration(labelText: 'Correo'),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Por favor ingrese un correo';
    }
    return null;
    },
    ),
    TextFormField(
    controller: _nameController,
    decoration: InputDecoration(labelText: 'Nombre'),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Por favor ingrese un nombre';
    }
    return null;
    },
    ),
    TextFormField(
    controller: _dniController,
    decoration: InputDecoration(labelText: 'DNI'),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Por favor ingrese un DNI';
    }
    return null;
    },
    ),
      TextFormField(
        controller: _institutoController,
        decoration: InputDecoration(labelText: 'Instituto'),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingrese un instituto';
          }
          return null;
        },
      ),
      SizedBox(height: 16),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _actualizarDatos();
          }
        },
        child: Text('Actualizar datos'),
      ),
      ElevatedButton(
        onPressed: () async {
          final confirm = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Eliminar cuenta'),
              content: Text('¿Está seguro que desea eliminar su cuenta? Esta acción no se puede deshacer.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Eliminar'),
                ),
              ],
            ),
          );
          if (confirm == true) {
            await DatabaseHelper.instance.deleteUser(_valor);
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage(title:"Login")));
          }
        },
        style: ElevatedButton.styleFrom(
          primary: Colors.red,
        ),
        child: Text('Eliminar cuenta'),
      ),
    ],
    ),
    ),
        ),
    );
  }
}








