import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_core/firebase_core.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
  static final table2 = 'Resultado';
  static final columnId = '_id';
  static final columnName = 'name';
  static final columnEmail = 'email';
  static final columnPassword = 'password';
  static final columnDNI = 'dni';
  static final columnInstituto = 'instituto';
  static final columnIdResult= '_idResult';
  static final columnIdUsuario = '_id';
  static final columnMedida = 'Medida';
  static final columnNombreEstudiante = 'Nombre_estudiante';
  static final columnDuracion = 'Duracion';
  static final columnRepeticiones = 'Repeticiones';

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
    await db.execute('''
    CREATE TABLE $table2 (
      $columnIdResult INTEGER PRIMARY KEY,
      $columnIdUsuario TEXT NOT NULL,
      $columnNombreEstudiante TEXT NOT NULL,
      $columnMedida INTEGER NOT NULL,
      $columnDuracion INTEGER NOT NULL,
      $columnRepeticiones INTEGER NOT NULL,
      FOREIGN KEY ($columnIdUsuario) REFERENCES $table($columnId)
    )
  ''');
  }


  // Helper methods

  // Insert a row in the table
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }
  Future<int> insertResultado(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table2, row);
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
  Future<Map<String, dynamic>> authenticateUserResult(int idResultex) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> results = await db.query(
      table2,
      columns: [columnIdResult, columnIdUsuario, columnNombreEstudiante, columnMedida, columnDuracion, columnRepeticiones],
      where: "$columnIdResult = ?",
      whereArgs: [idResultex],
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
              Text(
                'Nombre',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 8.0),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Ingrese su nombre',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 16.0,
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Por favor, ingrese su nombre';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              Text(
                'Email',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 8.0),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Ingrese su email',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 16.0,
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Por favor, ingrese su correo electrónico';
                  } else if (!RegExp(r'^[\w-.]+@([\w-]+.)+[\w-]{2,4}$')
                      .hasMatch(value!)) {
                    return 'Por favor, ingrese un correo electrónico válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              Text(
                'Contraseña',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 8.0),
              TextFormField(
                controller: _passwordControllerR,
                decoration: InputDecoration(
                  hintText: 'Ingrese su contraseña',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 16.0,
                  ),
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
              Text(
                'Confirmar Contraseña',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 8.0),
              TextFormField(
                controller: _passwordControllerRConfirm,
                decoration: InputDecoration(
                  hintText: 'Ingrese su contraseña nuevamente',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 16.0,
                  ),
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
              Text(
                'DNI',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 8.0),
              TextFormField(
                controller: _DNIController,
                decoration: InputDecoration(
                  hintText: 'Ingrese su número de DNI',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 16.0,
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Por favor, ingrese su número de DNI';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              Text(
                'Instituto',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 8.0),
              TextFormField(
                controller: _institutoController,
                decoration: InputDecoration(
                  hintText: 'Ingrese el nombre de su instituto',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 16.0,
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Por favor, ingrese el nombre de su instituto';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32.0),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
// Send data to API or do something with data
                      Map<String, dynamic> row = {
                        DatabaseHelper.columnName: _nameController.text,
                        DatabaseHelper.columnEmail: _emailController.text,
                        DatabaseHelper.columnPassword:
                        _passwordControllerR.text,
                        DatabaseHelper.columnDNI: _DNIController.text,
                        DatabaseHelper.columnInstituto:
                        _institutoController.text
                      };
                      final id =
                      await DatabaseHelper.instance.insert(row);
                      print('inserted row id: $id');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyHomePage(title: "Login")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    onPrimary: Colors.white,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 32.0,
                    ),
                  ),
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16.0,
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String hintText,
      FormFieldValidator<String>? validator) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
      ),
      obscureText: hintText.toLowerCase().contains('contraseña'),
      validator: validator,
    );
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Bienvenido a Toph!',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 24.0),
                Image.network(
                  'https://i.pinimg.com/736x/d5/03/c9/d503c957e17b0a45dda41e38b0d13d7a.jpg',
                  width: 200.0,
                  height: 200.0,
                ),
                SizedBox(height: 24.0),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Por favor ingresa tu dirección de correo electrónico';
                          } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                            return 'Por favor ingresa una dirección de correo electrónico válida';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Por favor ingresa tu contraseña';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24.0),
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
                      SizedBox(height: 16.0),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => NewActivity()),
                          );
                        },
                        child: Text(
                          'Registrar',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
class InformacionScreen extends StatefulWidget {
  @override
  _InformacionScreenState createState() => _InformacionScreenState();
}

class _InformacionScreenState extends State<InformacionScreen> {
  late int _lecturaResult;
  Map<String, dynamic> _resultList = {};

  @override
  void initState() {
    super.initState();
    _fetchResultList();
  }

  Future<void> _fetchResultList() async {
    final prefs = await SharedPreferences.getInstance();
    final  lecturaResult= prefs.getInt("miID") ?? 0;
    print('${lecturaResult}');
    setState(() {
      _lecturaResult = lecturaResult;
    });
    print('Esto entra a la función: ${_lecturaResult}');
    final resultList = await DatabaseHelper.instance.authenticateUserResult(_lecturaResult);
    setState(() {
      print('Esta lista retorna ${resultList}');
      _resultList = resultList;
      print('Duraciónx: ${_resultList['Duracion']}');
      print('Medidax ${_resultList['Medida']}');
      print('NombreEstudaintex ${_resultList['Nombre_Estudiante']}');
      print('Repeticionesx ${_resultList['Repeticiones']}');
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
                            '${_resultList['Duracion']} segundos',
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
                            'Medida: ',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_resultList['Medida']}',
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
                            'Nombre de estudiante:',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_resultList['Nombre_estudiante']}',
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
                            'Repeticiones:',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_resultList['Repeticiones']}',
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
  int _buttonPressCount = 0;
  late String idUsuario = '';
  late int lecturaResult;
  //Nuevo para añadir la parte del READ
  List<DocumentSnapshot> estudiantes = [];
  DocumentSnapshot? estudianteSeleccionado;
  //---------

  void _togglePlayPause(BuildContext context) {
    setState(() {
      _isPlaying = !_isPlaying;
      _buttonPressCount++;

      if (_buttonPressCount == 2) {
        var resultado = {
          DatabaseHelper.columnIdUsuario: idUsuario,
          DatabaseHelper.columnNombreEstudiante: 'Christopher Abensur Ochoa',
          DatabaseHelper.columnMedida: 10,
          DatabaseHelper.columnDuracion: 5,
          DatabaseHelper.columnRepeticiones: 3,
        };
        Future<int> insertResult = DatabaseHelper.instance.insertResultado(resultado);
        insertResult.then((_idResult) {
            lecturaResult = _idResult;
            print(lecturaResult);
        });
        _buttonPressCount = 0;
      }
    });
  }
  //NUEVO PARA EL READ
  void obtenerEstudiantes() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('estudiantes').get();
    setState(() {
      estudiantes = snapshot.docs;
    });
  }
  //----------
  @override
  void initState() {
    super.initState();
    _leerIdUsuario();
    //Nuevo para el READ
    obtenerEstudiantes();
    //----------
  }

  Future<void> _leerIdUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final correo = prefs.getString('miCorreo') ?? '';

    final db = await DatabaseHelper.instance.database;
    final user = await db.query(
      DatabaseHelper.table,
      where: '${DatabaseHelper.columnEmail} = ?',
      whereArgs: [correo],
    );

    if (user.isNotEmpty) {
      final idUsuarioValue = user.first[DatabaseHelper.columnId].toString();
      setState(() {
        idUsuario = idUsuarioValue;
      });
    }
  }


// Rest of the code...

  void _abrirActividadC(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ActividadC()),
    );
  }
  void _abrirInterfazRegistroEstudiante(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistroEstudianteScreen()),
    );
  }
  //NUEVO par READ
  void _abrirInterfazSeleccionEstudiante(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InterfazSeleccionEstudiante(estudiantes)),
    ).then((estudiante) {
      setState(() {
        estudianteSeleccionado = estudiante;
      });
    });
  }
  //-----------
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
                  PopupMenuItem(
                    value: 'registrar_estudiante',
                    child: Text('Registrar estudiante'),
                  ),
                  //NUEVO PARA READ
                  PopupMenuItem(
                    value: 'seleccionar_estudiante',
                    child: Text('Seleccionar estudiante'),
                  ),
                  //-----
                ],
              ).then((value) {
                if (value == 'perfil') {
                  _abrirActividadC(context);
                } else if (value == 'registrar_estudiante') {
                  _abrirInterfazRegistroEstudiante(context);
                }
                else if (value == 'seleccionar_estudiante') {
                  _abrirInterfazSeleccionEstudiante(context);
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
              "https://scontent.flim1-2.fna.fbcdn.net/v/t39.30808-6/343016082_233756192639185_3369699152325551161_n.jpg?_nc_cat=106&ccb=1-7&_nc_sid=730e14&_nc_eui2=AeFLVV3pd6Y3rgOjA1xcBcp2lzVhMPY44R-XNWEw9jjhH_6PJe9jJG2PLBHqIXDLITFDbED6iKxR4kSOZw2mOJRe&_nc_ohc=92dsx3NOsdQAX-uP14k&_nc_ht=scontent.flim1-2.fna&oh=00_AfARZJqawmhEpYawJpYrh3xpRUrkx0TL5zIu0rnykFbYaw&oe=6472C67A",
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
            //READ
            Text(
              'Estudiante seleccionado: ${estudianteSeleccionado != null ? estudianteSeleccionado!['nombre'] : 'Ninguno'}',
              style: TextStyle(color: Colors.white), // Color de fuente blanco
            ),
            //----
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
                  onPressed: () {
                    _togglePlayPause(context);
                  },
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
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setInt("miID", lecturaResult);
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
  final List<String> _imagePaths = [
    'https://images.ecestaticos.com/WAot9QyeV2vzRuE1gVu55WLdv7Y=/0x0:0x0/1200x900/filters:fill(white):format(jpg)/f.elconfidencial.com%2Foriginal%2Fb3c%2Fc7c%2Fff6%2Fb3cc7cff6cc1ee44df172f15afa3e4f9.jpg',
    'https://www.sportlife.es/uploads/s1/76/28/31/1/article-flexion-hacia-delante-sentada-isquiotibiales-580f4b65a2c89.jpeg',
    'https://media.istockphoto.com/id/1327616016/es/vector/atleta-masculino-saltando-en-el-estadio.jpg?s=612x612&w=0&k=20&c=nUIjYqI_OVV-Le43QPdQT55xPDPbUgOnFSmRykCWPc0=',
    'https://calmatel.com/assets/wp-content/uploads/2018/12/sentadillas.jpg',
    'https://images.vexels.com/media/users/3/191646/isolated/lists/06b52fbff7982a431f671f7ce7349f29-gran-silueta-de-rutina-de-ejercicios.png',
    'https://st2.depositphotos.com/3837271/10204/i/450/depositphotos_102044118-stock-photo-coming-soon-written-on-track.jpg',
  ];

  void _handleProfileMenuSelection(String value, BuildContext context) {
    // Manejar la selección del elemento del menú
    // Aquí puedes agregar lógica para navegar a diferentes pantallas o realizar otras acciones
    if (value == 'perfil') {
      _abrirActividadC(context);
    } else if (value == 'configuracion') {
      _abrirConfiguracion(context);
    } else if (value == 'editar_estudiantes') {
      _abrirEdicionEstudiantes(context);
    } else if (value == 'cerrar_sesion') {
      _cerrarSesion();
    }
  }

  void _abrirActividadC(BuildContext context) {
    // Navegar a la pantalla de actividad C
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ActividadC()),
    );
  }

  void _abrirConfiguracion(BuildContext context) {
    // Navegar a la pantalla de configuración
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Configuracion()),
    );
  }

  void _abrirEdicionEstudiantes(BuildContext context) {
    // Navegar a la pantalla de edición de estudiantes
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EdicionEstudiantes()),
    );
  }

  void _abrirEditarSingleEstudiante(BuildContext context, Estudiante estudiante) {
    // Navegar a la pantalla de edición de un estudiante específico
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditarSingleEstudiante(estudiante: estudiante)),
    );
  }

  void _abrirLogin(BuildContext context) {
    // Navegar a la pantalla de inicio de sesión
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _abrirRegistroUsuario(BuildContext context) {
    // Navegar a la pantalla de registro de usuario
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistroUsuarioScreen()),
    );
  }

  void _cerrarSesion() {
    // Lógica para cerrar sesión del usuario
    // ...
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
                    value: 'editar_estudiantes',
                    child: Text('Editar estudiantes'),
                  ),
                  PopupMenuItem(
                    value: 'cerrar_sesion',
                    child: Text('Cerrar sesión'),
                  ),
                ],
              ).then((value) {
                if (value != null) {
                  _handleProfileMenuSelection(value, context);
                }
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Selecciona un ejercicio',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
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
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.black, width: 2.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6.0),
                        child: Image.network(
                          _imagePaths[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Mostrar menú desplegable de opciones adicionales
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                child: Wrap(
                  children: [
                    ListTile(
                      leading: Icon(Icons.lock),
                      title: Text('Iniciar sesión'),
                      onTap: () {
                        _abrirLogin(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.folder),
                      title: Text('Registrarse a FitTrackFile'),
                      onTap: () {
                        _abrirRegistroUsuario(context);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';

  bool _isLoggedIn = false;
  String _errorMessage = '';

  void _onEmailChanged(String value) {
    setState(() {
      email = value;
      _errorMessage = ''; // Limpiar el mensaje de error al cambiar el valor del campo de correo electrónico
    });
  }

  void _onPasswordChanged(String value) {
    setState(() {
      password = value;
      _errorMessage = ''; // Limpiar el mensaje de error al cambiar el valor del campo de contraseña
    });
  }

  void _validateLogin() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      setState(() {
        _isLoggedIn = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al iniciar sesión. Verifica tus credenciales.'; // Establecer el mensaje de error en caso de error de inicio de sesión
      });
    }
  }

  void _openResetPasswordScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RestablecerContrasenaScreen()),
    );
  }

  void _goToRegistroDocumentosScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DocumentosRegistroEjerciciosScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: _isLoggedIn
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('¡Has iniciado sesión!'),
            ElevatedButton(
              onPressed: () {
                _goToRegistroDocumentosScreen(context); // Redireccionar a DocumentosRegistroEjerciciosScreen
              },
              child: Text('Ir a Registro de documentos'),
            ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Pantalla de inicio de sesión'),
            TextFormField(
              decoration: InputDecoration(labelText: 'Email'),
              onChanged: _onEmailChanged,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              onChanged: _onPasswordChanged,
            ),
            ElevatedButton(
              onPressed: _validateLogin,
              child: Text('Iniciar sesión'),
            ),
            TextButton(
              onPressed: () {
                _openResetPasswordScreen(context);
              },
              child: Text('¿Olvidaste tu contraseña?'),
            ),
            _errorMessage.isNotEmpty
                ? Text(
              _errorMessage,
              style: TextStyle(
                color: Colors.red,
              ),
            )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}

class DocumentosRegistroEjerciciosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de documentos de ejercicios'),
      ),
      body: Center(
        child: Text('Pantalla de registro de documentos de ejercicios'),
      ),
    );
  }
}


class RestablecerContrasenaScreen extends StatefulWidget {
  @override
  _RestablecerContrasenaScreenState createState() => _RestablecerContrasenaScreenState();
}

class _RestablecerContrasenaScreenState extends State<RestablecerContrasenaScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String email = '';

  void _onEmailChanged(String value) {
    setState(() {
      email = value;
    });
  }

  void _enviarEnlaceRestablecerContrasena(BuildContext context) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Enlace enviado'),
            content: Text('Se ha enviado un enlace para restablecer la contraseña a su correo electrónico.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restablecimiento de Contraseña'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ingrese su correo correspondiente'),
            TextFormField(
              decoration: InputDecoration(labelText: 'Correo electrónico'),
              onChanged: _onEmailChanged,
            ),
            ElevatedButton(
              onPressed: () {
                _enviarEnlaceRestablecerContrasena(context);
              },
              child: Text('Restablecer contraseña'),
            ),
          ],
        ),
      ),
    );
  }
}
class RegistroUsuarioScreen extends StatefulWidget {
  @override
  _RegistroUsuarioScreenState createState() => _RegistroUsuarioScreenState();
}

class _RegistroUsuarioScreenState extends State<RegistroUsuarioScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';

  void _onEmailChanged(String value) {
    setState(() {
      email = value;
    });
  }

  void _onPasswordChanged(String value) {
    setState(() {
      password = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Usuario'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Pantalla de registro de usuario'),
            TextFormField(
              decoration: InputDecoration(labelText: 'Correo electrónico'),
              onChanged: _onEmailChanged,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
              onChanged: _onPasswordChanged,
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
                    email: email,
                    password: password,
                  );
                } catch (e) {
                  print(e.toString());
                }
              },
              child: Text('Registrarse'),
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
class RegistroEstudianteScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  late String _nombre;
  late DateTime _fechaNacimiento;
  late String _dni;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Estudiante'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.lightBlueAccent, Colors.blueAccent],
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¡Bienvenido al Registro de Estudiantes!',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 24.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nombre completo',
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el nombre completo del estudiante';
                  }
                  return null;
                },
                onSaved: (value) {
                  _nombre = value!;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Fecha de nacimiento (YYYY-MM-DD)',
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese la fecha de nacimiento';
                  }
                  return null;
                },
                onSaved: (value) {
                  // Aquí puedes realizar el parseo de la fecha si es necesario
                  // Por ejemplo: _fechaNacimiento = DateTime.parse(value!);
                  _fechaNacimiento = DateTime.now(); // Ejemplo: establecer la fecha actual
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'DNI',
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el número de identificación (DNI)';
                  }
                  return null;
                },
                onSaved: (value) {
                  _dni = value!;
                },
              ),
              SizedBox(height: 24.0),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Llamada a la función para enviar los datos a Firebase
                      FirebaseFirestore.instance.collection('estudiantes').add({
                        'nombre': _nombre,
                        'fecha_nacimiento': _fechaNacimiento,
                        'dni': _dni,
                      }).then((value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('¡Registro exitoso!'),
                          ),
                        );
                      }).catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al registrar'),
                          ),
                        );
                      });
                    }
                  },
                  child: Text(
                    'Registrar',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.lightBlueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class InterfazSeleccionEstudiante extends StatelessWidget {
  final List<DocumentSnapshot> estudiantes;

  InterfazSeleccionEstudiante(this.estudiantes);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Seleccionar Estudiante',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: estudiantes.length,
        itemBuilder: (context, index) {
          final estudiante = estudiantes[index];
          final dni = estudiante['dni'];
          final fechaNacimiento = estudiante['fecha_nacimiento'];
          final nombre = estudiante['nombre'];
          return Container(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1.0,
              ),
            ),
            child: ListTile(
              title: Text(
                nombre,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DNI: $dni',
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                  Text(
                    'Fecha de nacimiento: $fechaNacimiento',
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.pop(context, estudiante);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Icon(Icons.check),
      ),
    );
  }
}

class EdicionEstudiantes extends StatefulWidget {
  @override
  _EdicionEstudiantesState createState() => _EdicionEstudiantesState();
}

class _EdicionEstudiantesState extends State<EdicionEstudiantes> {
  List<Estudiante> _estudiantes = [];

  @override
  void initState() {
    super.initState();
    // Recuperando los estudiantes de la base de datos Firestore
    FirebaseFirestore.instance.collection('estudiantes').get().then((QuerySnapshot snapshot) {
      // Iterando sobre los documentos recuperados
      snapshot.docs.forEach((QueryDocumentSnapshot document) {
        // Obteniendo los datos del documento y realizando la conversión a Map<String, dynamic>
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

        // Obteniendo los campos "nombre" y "dni" de manera segura utilizando el operador null-aware (?.)
        String? nombre = data['nombre'] as String?;
        String? dni = data['dni'] as String?;

        // Verificando si los campos "nombre" y "dni" no son nulos antes de crear el objeto Estudiante
        if (nombre != null && dni != null) {
          // Creando un objeto Estudiante y agregándolo a la lista _estudiantes
          Estudiante estudiante = Estudiante(nombre: nombre, dni: dni);
          setState(() {
            _estudiantes.add(estudiante);
          });
        }
      });
    }).catchError((error) {
      print('Error al recuperar los estudiantes: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edición de Estudiantes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: _estudiantes.length,
          itemBuilder: (context, index) {
            final estudiante = _estudiantes[index];
            return Container(
              margin: EdgeInsets.only(bottom: 10.0),
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
              child: ListTile(
                title: Text(
                  estudiante.nombre,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                subtitle: Text(
                  'DNI: ${estudiante.dni}',
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                ),
                onTap: () {
                  _abrirEditarSingleEstudiante(context, estudiante);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _abrirEditarSingleEstudiante(BuildContext context, Estudiante estudiante) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditarSingleEstudiante(estudiante: estudiante)),
    );
  }
}
class EditarSingleEstudiante extends StatefulWidget {
  final Estudiante estudiante;

  const EditarSingleEstudiante({required this.estudiante});

  @override
  _EditarSingleEstudianteState createState() => _EditarSingleEstudianteState();
}

class _EditarSingleEstudianteState extends State<EditarSingleEstudiante> {
  // Variables para editar la información del estudiante
  String? nombreINI;
  String? dniINI;
  String? nombre;
  String? dni;

  @override
  void initState() {
    super.initState();
    // Inicializar las variables de nombre y dni con los valores actuales del estudiante
    nombreINI = widget.estudiante.nombre;
    dniINI = widget.estudiante.dni;
    nombre = widget.estudiante.nombre;
    dni = widget.estudiante.dni;
    nombreController.text = nombre!;
    dniController.text = dni!;
  }
  Future<String?> findEstudianteId(String? nombre, String? dni) async {
    String? estudianteId;
    print ('${nombre} y ${dni} se imprimen');
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('estudiantes')
        .where('nombre', isEqualTo: nombre)
        .where('dni', isEqualTo: dni)
        .get();

    if (snapshot.docs.length > 0) {
      // Si se encontró un estudiante con los valores proporcionados,
      // obtenemos el ID del primer documento de la consulta
      print('Si se encontro');
      estudianteId = snapshot.docs[0].id;
    }
    print('Este Id se esta encontrando a ver: ${estudianteId}');
    return estudianteId;
  }

  String? estudianteIdR;

  void obtenerEstudianteId(nombre,dni) async {
    estudianteIdR = await findEstudianteId(nombreINI, dniINI);

    if (estudianteIdR != null) {
      DocumentReference estudianteRef = FirebaseFirestore.instance.collection('estudiantes').doc(estudianteIdR);

      Map<String, dynamic> data = {
        'nombre': nombre,
        'dni': dni,
        // Agrega aquí otros campos que desees actualizar
      };

      // Actualiza los datos del estudiante en la base de datos Firestore
      estudianteRef.update(data).then((value) {
        print('Datos del estudiante actualizados correctamente.');
      }).catchError((error) {
        print('Error al actualizar los datos del estudiante: $error');
      });
    }
  }
  void eliminarEstudiante() async {
    estudianteIdR = await findEstudianteId(nombreINI, dniINI);

    if (estudianteIdR != null) {
      DocumentReference estudianteRef = FirebaseFirestore.instance.collection('estudiantes').doc(estudianteIdR);

      // Elimina el documento del estudiante de la base de datos Firestore
      estudianteRef.delete().then((value) {
        print('Estudiante eliminado correctamente.');
        // Aquí puedes agregar cualquier otra lógica adicional después de eliminar el estudiante
      }).catchError((error) {
        print('Error al eliminar el estudiante: $error');
      });
    }
  }
  void _mostrarDialogoConfirmacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Confirmación'),
          content: Text('¿Estás seguro de que deseas eliminar este estudiante?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Cierra el diálogo
              },
            ),
            TextButton(
              child: Text('Eliminar'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Cierra el diálogo
                eliminarEstudiante(); // Llama al método eliminarEstudiante
              },
            ),
          ],
        );
      },
    );
  }



  TextEditingController nombreController = TextEditingController();
  TextEditingController dniController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar estudiante'),
      ),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Nombre',
            ),
            onChanged: (value) {
              setState(() {
                 nombre = value;
              });
            },
            controller: nombreController,
          ),
          TextField(
            decoration: InputDecoration(
              labelText: 'DNI',
            ),
            onChanged: (value) {
              setState(() {
                 dni = value;
              });
            },
            controller: dniController,
          ),
          ElevatedButton(
            onPressed: () {
              obtenerEstudianteId(nombre, dni);
            },
            child: Text('Guardar cambios'),
          ),
          ElevatedButton(
            onPressed: () {
              _mostrarDialogoConfirmacion(context);
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.red,
            ),
            child: Text('Eliminar estudiante'),
          ),
        ],
      ),
    );
  }
}

class Estudiante {
  final String nombre;
  final String dni;

  Estudiante({required this.nombre, required this.dni});
}
