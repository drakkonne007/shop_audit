

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shop_audit/global/database.dart';

class LoginPage extends StatefulWidget {

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _login = '';
  String _password = '';
  bool _isCorrect = true;
  String _enterText = 'Войти';

  Future<void> checkAccess()async{
    bool answer = await DatabaseClient().checkAccess(_login, _password);
    _enterText = 'Войти';
    if(answer == true){
      Navigator.of(context).pushNamedAndRemoveUntil('/mapScreen', (route) => false);
    }else{
      setState(() {
        _isCorrect = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _login = '';
    _password = '';
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_isCorrect ? 'Добро пожаловать' : 'Неверный логин или пароль'),
              SizedBox(height: 20,),
              Text('Логин'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: TextFormField(
                      initialValue: _login,
                      onChanged: (value) {
                        _login = value;
                      },
                    ),
                  ),
                  IconButton(onPressed: (){
                    _login = '';
                    setState(() {});
                  }, icon: const Icon(Icons.cancel_outlined))
                ],
              ),
              Text('Пароль'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: TextFormField(
                      initialValue: _password,
                      onChanged: (value) {
                        _password = value;
                      },
                    ),
                  ),
                  IconButton(onPressed: (){
                    _password = '';
                    setState(() {});
                  }, icon: const Icon(Icons.cancel_outlined))
                ],
              ),
              ElevatedButton(onPressed: (){
                setState(() {
                  _enterText = 'Ждёмс...';
                });
                checkAccess();
              },
                  child: Text(_enterText))
            ]
        ),
      ),
    );
  }
}