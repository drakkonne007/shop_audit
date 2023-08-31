

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_audit/global/database.dart';
import 'package:shop_audit/global/socket_handler.dart';
import 'package:shop_audit/main.dart';

class LoginPage extends StatefulWidget {

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool _isCorrect = true;
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    SocketHandler().isLoginFunc = catchAccess;
    super.initState();
  }

  @override
  void dispose() {
    SocketHandler().isLoginFunc = null;
    super.dispose();
  }

  void catchAccess(bool result) async
  {
    if(result == true){
      Navigator.of(context).pushNamedAndRemoveUntil('/mapScreen', (route) => false);
    }else{
      setState(() {
        _isCorrect = false;
        isLoading = false;
      });
    }
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
                      controller: loginController,
                    ),
                  ),
                  IconButton(onPressed: (){
                    setState(() {
                      loginController.text = '';
                    });
                  }, icon: const Icon(Icons.cancel_outlined))
                ],
              ),
              const SizedBox(height: 20,),
              Text('Пароль'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: TextFormField(
                      controller: passwordController,
                    ),
                  ),
                  IconButton(onPressed: (){
                    setState(() {
                      passwordController.text = '';
                    });
                  }, icon: const Icon(Icons.cancel_outlined))
                ],
              ),
              const SizedBox(height: 20,),
              isLoading ? const CircularProgressIndicator() : ElevatedButton(onPressed: (){
                if(loginController.text.isEmpty || passwordController.text.isEmpty){
                  return;
                }
                setState(() {
                  isLoading = true;
                });
                SocketHandler().checkAccess(loginController.text, passwordController.text);
              },
                  child: Text('Войти')
              ),
            ]
        ),
      ),
    );
  }
}