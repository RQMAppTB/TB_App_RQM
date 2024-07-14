import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../API/LoginController.dart';
import '../Data/DistPersoData.dart';
import '../Data/DistTotaleData.dart';
import '../Utils/Result.dart';
import 'InfoScreen.dart';

class Login extends StatefulWidget{
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login>{

  final TextEditingController _controller = TextEditingController();
  //LoginApi _loginApi = LoginApi();
  String _name = "";
  int _dossard = -1;
  bool _visibility = false;


  DistTotaleData _distTotaleData = DistTotaleData();
  DistPersoData _distPersoData = DistPersoData();

  String _snackText = "Awesome SnackBar!";


  @override
  void initState() {
    super.initState();
    DistTotaleData.saveDistTotale(20);
    DistPersoData.saveDistPerso(10);
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
        content: new Text(value)
    ));
  }

  @override
  Widget build(BuildContext context){
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async{
        log("Trying to pop");
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Welcome to the login page'),
              const Text('Please enter your dossard number'),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: const InputDecoration(hintText: 'XXXX'),
              ),
              ElevatedButton(
                onPressed: () async {

                  log("Trying to login");

                  Result tmp = await LoginController.getDossardName(int.parse(_controller.text));

                  if(tmp.error != null){
                    //show snackbar
                    showInSnackBar(tmp.error!);
                    setState(() {
                      _visibility = false;
                    });
                    //throw Exception(tmp.error);
                  }else{
                    setState(() {
                      _name = tmp.value;
                      _dossard = int.parse(_controller.text);
                      _visibility = true;
                    });
                  }
                },
                child: const Text('Login'),
              ),

              Visibility(
                visible: _visibility,
                child: Column(
                  children: <Widget>[
                    const Text("Is this the correct name?"),
                    Text(_name),
                    ElevatedButton(
                      onPressed: () async {
                        log("Name: $_name");
                        //log("Name: $_name");
                        log("Dossard: ${_controller.text}");
                        var tmp = await LoginController.login(_name, _dossard);//int.parse(_controller.text));
                        if(!tmp.hasError) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return const InfoScreen();
                            }),
                          );
                        }else{
                          showInSnackBar(tmp.error!);
                        }
                      },
                      child: const Text('Yes'),
                    ),
                    ElevatedButton(
                      onPressed: (){
                        setState(() {
                          _visibility = false;
                        });
                      },
                      child: const Text('No'),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      )
    );
  }
}