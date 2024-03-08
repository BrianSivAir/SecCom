import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:sec_com/chat.dart';
import 'package:sec_com/database/com_db.dart';
import 'package:sec_com/services/cypher.dart';
import 'package:sec_com/services/sockets.dart';

import 'model/com.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future main() async {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'SecCOM'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<Com>>? futureComs;
  final comDb = ComDB();

  @override
  void initState() {
    super.initState();
    fetchComs();
  }

  void fetchComs() {
    setState(() {
      futureComs = comDb.fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          children: <Widget>[
            FutureBuilder<List<Com>>(
                future: futureComs,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    final coms = snapshot.data!;
                    return coms.isEmpty
                        ? const Center(child: Text('Empty'))
                        : ListView.separated(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final com = coms[index];
                              return ComTile(
                                com: com,
                              );
                            },
                            separatorBuilder: (context, index) =>
                                const SizedBox(
                                  height: 12,
                                ),
                            itemCount: coms.length);
                  }
                }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        tooltip: 'Add COM',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class ComTile extends StatefulWidget {
  final Com com;

  const ComTile({super.key, required this.com});

  @override
  State<ComTile> createState() => _ComTileState();
}

class _ComTileState extends State<ComTile> {
  String status = '';
  Sockets? sockets;
  bool connecting = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(widget.com.name),
        subtitle: Text("${widget.com.lip}:${widget.com.lport}"),
        trailing: IntrinsicWidth(
          child: Builder(builder: (context) {
            if (connecting) {
              return Row(
                children: [
                  Text(status),
                  Container(
                    margin: const EdgeInsets.only(left: 10.0),
                    child: const SizedBox(
                      height: 20.0,
                      width: 20.0,
                      child: Center(
                          child: CircularProgressIndicator(
                        strokeWidth: 3.0,
                      )),
                    ),
                  ),
                ],
              );
            } else {
              return const Text('');
            }
          }),
        ),
        onTap: () => {
              if (sockets != null)
                {
                  sockets!.destroy(),
                  sockets = null,
                  setState(() {
                    connecting = false;
                  }),
                }
              else
                {
                  sockets = Sockets(),
                  sockets!.destroy(),
                  sockets!.connect(
                      widget.com,
                      (value) => {
                            setState(() {
                              status = value;
                            })
                          },
                      () => {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => Chat(com: widget.com),
                                ))
                          },
                      () => {
                        print('!!!ABORTED!!!'),
                          setState(() {
                            connecting = false;
                          }),
                      }),
                  setState(() {
                    connecting = true;
                  }),
                }
            });
  }
}
