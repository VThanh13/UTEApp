import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/src/resources/login_screen.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  final TextEditingController _emailController = TextEditingController();
  final StreamController _emailControl = StreamController.broadcast();
  Stream get emailControl => _emailControl.stream;

  @override
  void dispose() {
    _emailControl.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reset password'),
        ),
        body: Material(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  StreamBuilder(
                    stream: emailControl,
                    builder: (context, snapshot) {
                      return TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          errorText: snapshot.hasError? snapshot.error.toString() : null,
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your email address';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _email = value!;
                        },
                      );
                    }
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: (){
                      try{
                        if(_submitForm()){
                          setState(() {
                            _emailController.text = '';
                          });
                          Navigator.pushReplacement(context, MaterialPageRoute(
                              builder: (context) => const LoginScreen()));
                        }else{
                          setState(() {
                            _emailController.text = '';
                          });
                          showErrorMessage('Reset password failed');
                        }
                      }catch(e){
                        //
                      }
                    },
                    child: const Text('Reset Password'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      _resetPassword();
    }
  }

  void _resetPassword() {
    FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Password reset email sent to $_email'),
      ),
    );
  }
  void showSuccessMessage(String message) {
    final snackBar = SnackBar(content: Text(message,
      style: const TextStyle(color: Colors.white),
    ), backgroundColor: Colors.blueAccent,);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(content: Text(message,
      style: const TextStyle(color: Colors.white),
    ),backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


}