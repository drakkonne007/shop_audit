

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
  bool _obscured = true;

  @override
  void initState() {
    _isCorrect = true;
    socketHandler.isLoginFunc = catchAccess;
    super.initState();
  }

  @override
  void dispose() {
    socketHandler.isLoginFunc = null;
    super.dispose();
  }

  void catchAccess(bool result) async
  {
    _isCorrect = true;
    if(result == true){
      socketHandler.loadShops(true);
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: TextFormField(
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never, //Hides label on focus or if filled
                        labelText: "Логин",
                        filled: true, // Needed for adding a fill color
                        fillColor: Colors.orange[200],
                        isDense: true,  // Reduces height a bit
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,              // No border
                          borderRadius: BorderRadius.circular(12),  // Apply corner radius
                        ),
                        prefixIcon: const Icon(Icons.supervised_user_circle, size: 24),
                      ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: TextFormField(
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: _obscured,
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never, //Hides label on focus or if filled
                        labelText: "Пароль",
                        filled: true, // Needed for adding a fill color
                        fillColor: Colors.orange[200],
                        isDense: true,  // Reduces height a bit
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,              // No border
                          borderRadius: BorderRadius.circular(12),  // Apply corner radius
                        ),
                        prefixIcon: Icon(Icons.lock_rounded, size: 24),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _obscured = !_obscured;
                              });
                            },
                            child: Icon(
                              _obscured
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
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
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Заполните все поля'), duration: Duration(seconds: 2),));
                  return;
                }
                mainShared?.setString('pwd', passwordController.text);
                mainShared?.setString('login', loginController.text);
                setState(() {
                  isLoading = true;
                });
                socketHandler.checkAccess(loginController.text, passwordController.text);
              },
                  child: Text('Войти')
              ),
            ]
        ),
      ),
    );
  }
}