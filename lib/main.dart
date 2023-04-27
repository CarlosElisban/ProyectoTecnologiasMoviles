import 'dart:io';

import 'package:flutter/material.dart';

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
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // TODO: Perform login authentication here
                          // For demo purposes, navigate to the NewActivity screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => NewActivity2()),
                          );
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

class EjercicioDetallesScreen extends StatelessWidget {
  final String imagePath;
  EjercicioDetallesScreen({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Ejercicio'),
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              "https://scontent.ftru5-1.fna.fbcdn.net/v/t39.30808-6/343016082_233756192639185_3369699152325551161_n.jpg?_nc_cat=106&ccb=1-7&_nc_sid=730e14&_nc_eui2=AeFLVV3pd6Y3rgOjA1xcBcp2lzVhMPY44R-XNWEw9jjhH_6PJe9jJG2PLBHqIXDLITFDbED6iKxR4kSOZw2mOJRe&_nc_ohc=6pSVsV0qrkMAX8OSMfv&_nc_zt=23&_nc_ht=scontent.ftru5-1.fna&oh=00_AfBSvGJNyCgaRLKDHiCr8vTyhIDiqCjFOWyjB2esflO9yg&oe=644F2DFA",
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: Icon(Icons.play_arrow),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(20),
                    primary: Colors.blue,
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {},
                  child: Icon(Icons.pause),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(20),
                    primary: Colors.yellow,
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {},
                  child: Icon(Icons.stop),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(20),
                    primary: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}




class _NewActivityState2 extends State<NewActivity2> {
  final List<String> _imagePaths = ['https://images.ecestaticos.com/WAot9QyeV2vzRuE1gVu55WLdv7Y=/0x0:0x0/1200x900/filters:fill(white):format(jpg)/f.elconfidencial.com%2Foriginal%2Fb3c%2Fc7c%2Fff6%2Fb3cc7cff6cc1ee44df172f15afa3e4f9.jpg',
  'https://images.ecestaticos.com/WAot9QyeV2vzRuE1gVu55WLdv7Y=/0x0:0x0/1200x900/filters:fill(white):format(jpg)/f.elconfidencial.com%2Foriginal%2Fb3c%2Fc7c%2Fff6%2Fb3cc7cff6cc1ee44df172f15afa3e4f9.jpg',
  'https://images.ecestaticos.com/WAot9QyeV2vzRuE1gVu55WLdv7Y=/0x0:0x0/1200x900/filters:fill(white):format(jpg)/f.elconfidencial.com%2Foriginal%2Fb3c%2Fc7c%2Fff6%2Fb3cc7cff6cc1ee44df172f15afa3e4f9.jpg',
  'https://images.ecestaticos.com/WAot9QyeV2vzRuE1gVu55WLdv7Y=/0x0:0x0/1200x900/filters:fill(white):format(jpg)/f.elconfidencial.com%2Foriginal%2Fb3c%2Fc7c%2Fff6%2Fb3cc7cff6cc1ee44df172f15afa3e4f9.jpg',
  'https://images.ecestaticos.com/WAot9QyeV2vzRuE1gVu55WLdv7Y=/0x0:0x0/1200x900/filters:fill(white):format(jpg)/f.elconfidencial.com%2Foriginal%2Fb3c%2Fc7c%2Fff6%2Fb3cc7cff6cc1ee44df172f15afa3e4f9.jpg',
  'https://images.ecestaticos.com/WAot9QyeV2vzRuE1gVu55WLdv7Y=/0x0:0x0/1200x900/filters:fill(white):format(jpg)/f.elconfidencial.com%2Foriginal%2Fb3c%2Fc7c%2Fff6%2Fb3cc7cff6cc1ee44df172f15afa3e4f9.jpg'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Opciones de ejercicios'),
      ),
      body: Stack(
        children: [
          GridView.builder(
            itemCount: _imagePaths.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
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
                child: Image.network(
                  _imagePaths[index],
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
          Positioned(
            top: 20.0,
            left: 0.0,
            right: 0.0,
            child: Center(
              child: Text(
                'Selecciona un ejercicio',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _NewActivityState extends State<NewActivity> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactoController = TextEditingController();
  final _especialidadlabController = TextEditingController();
  final _edadController = TextEditingController();
  final _celularController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Activity'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
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
                controller: _contactoController,
                decoration: InputDecoration(
                  labelText: 'Contacto',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your contact name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _especialidadlabController,
                decoration: InputDecoration(
                  labelText: 'Especialidad laboral',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your contact name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _edadController,
                decoration: InputDecoration(
                  labelText: 'Edad',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your contact name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _celularController,
                decoration: InputDecoration(
                  labelText: 'Numero de celular',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your contact name';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


