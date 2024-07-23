import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../API/LoginController.dart';
import '../Data/DistPersoData.dart';
import '../Data/DistTotaleData.dart';
import '../Utils/Result.dart';
import '../Utils/config.dart';
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

  void _getUserame() async {

    log("Trying to login");

    Result dosNumResult = await LoginController.getDossardName(int.parse(_controller.text));

    if(dosNumResult.error != null){
      //show snackbar
      showInSnackBar(dosNumResult.error!);
      setState(() {
        _visibility = false;
      });
      //throw Exception(tmp.error);
    }else{
      setState(() {
        _name = dosNumResult.value;
        _dossard = int.parse(_controller.text);
        _visibility = true;
      });
    }
  }

  @override
  Widget build(BuildContext context){
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async{
        log("Trying to pop");
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(Config.COLOR_APP_BAR),
          centerTitle: true,
          title: const Text(
              style: TextStyle(color: Color(Config.COLOR_TITRE)),
              'Login'
          )
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Expanded(
                flex: 2,
                child: Image(image: AssetImage('assets/pictures/LogoText.png')),
              ),
              Expanded(
                  flex: 8,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text(
                          style: TextStyle(
                            fontSize: 20,
                          ),
                          'Bienvenue'
                          ),
                      const Text(
                          style: TextStyle(
                            fontSize: 20,
                          ),
                          'Veuillez entrer votre dossard'
                      ),
                      TextField(
                        controller: _controller,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(4),
                        ],
                        decoration: const InputDecoration(hintText: 'XXXX'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(Config.COLOR_BUTTON)
                        ),
                        onPressed: _getUserame/*

                        () async {

                          log("Trying to login");

                          Result dosNumResult = await LoginController.getDossardName(int.parse(_controller.text));

                          if(dosNumResult.error != null){
                            //show snackbar
                            showInSnackBar(dosNumResult.error!);
                            setState(() {
                              _visibility = false;
                            });
                            //throw Exception(tmp.error);
                          }else{
                            setState(() {
                              _name = dosNumResult.value;
                              _dossard = int.parse(_controller.text);
                              _visibility = true;
                            });
                          }
                        }

                        */,
                        child: const Text('Login'),
                      ),

                      Visibility(
                        visible: _visibility,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            const Text(
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                                "Est-ce le bon nom?"
                            ),
                            Text(
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                                _name
                            ),
                            const Padding(padding: EdgeInsets.all(20)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(Config.COLOR_BUTTON)
                                  ),
                                  onPressed: () async {
                                    log("Name: $_name");
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
                                  child: const Text('Oui'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(Config.COLOR_BUTTON)
                                  ),
                                  onPressed: (){
                                    setState(() {
                                      _visibility = false;
                                    });
                                  },
                                  child: const Text('Non'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
              )



            ],
          ),
        ),
      )
    );
  }
}