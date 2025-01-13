import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter/services.dart


import 'package:fluttertoast/fluttertoast.dart';
import 'package:waygo/screens/forgetPasswordScreen.dart';
import 'package:waygo/screens/signUpScreen.dart';
import '../global/global.dart';
import 'mainScreen.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

bool _passwordVisible = false;

class _LoginscreenState extends State<Loginscreen> {

  final emailTextEditingController=TextEditingController();
  final passwordTextEditingController=TextEditingController();

  // Declare a global Key
  final _formKey = GlobalKey<FormState>();


  void _submit() async {
    // Validate the form
    if (_formKey.currentState!.validate()) {
      try {
        // Try to sign in the user
        UserCredential auth = await firebaseAuth.signInWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim(),
        );

        // If successful, store the user and navigate to Mainpage
        currentUser = auth.user;
        await Fluttertoast.showToast(
          msg: "Successfully Logged In",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      } on FirebaseAuthException catch (e) {
        // Handle specific FirebaseAuth exceptions
        String errorMessage;

        if (e.code == 'user-not-found') {
          errorMessage = "No user found for this email. Please sign up first.";
        } else if (e.code == 'wrong-password') {
          errorMessage = "Incorrect password. Please try again.";
        } else if (e.code == 'invalid-email') {
          errorMessage = "Invalid email format.";
        } else if (e.code == 'invalid-credential') {
          errorMessage = "The email or password is invalid. Please try again.";
        } else if (e.code == 'too-many-requests') {
          errorMessage =
          "Too many attempts. Please try again later or reset your password.";
        } else {
          errorMessage = "An error occurred: ${e.message}";
        }

        await Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } catch (error) {
        // Handle any other unexpected errors
        await Fluttertoast.showToast(
          msg: "An unexpected error occurred. Please try again.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } else {
      // If form validation fails
      Fluttertoast.showToast(
        msg: "Please fill in all fields correctly.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }



  @override
  Widget build(BuildContext context) {

    bool darkTheme=MediaQuery.of(context).platformBrightness==Brightness.dark;

    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    // image: DecorationImage(fit: BoxFit.cover,
                    //   image: AssetImage(darkTheme? 'assets/images/cityNight.jpg': 'assets/images/cityDay.jpeg'),
                    // ),
                  ),
                  child: Image.asset(darkTheme? 'assets/images/cityNight.jpg': 'assets/images/cityDay.jpeg'),
                ),
              ],
            ),

            SizedBox(height: 20,),

            Center(
              child: Text('Login', style: TextStyle(color: darkTheme? Colors.amber.shade500 : Colors.blue,
                  fontSize: 25, fontWeight: FontWeight.bold),),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(15, 20, 15, 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        ////// Email /////
                        SizedBox(height: 10,),
                        TextFormField(inputFormatters: [LengthLimitingTextInputFormatter(50)],
                          decoration: InputDecoration(
                              hintText: "Email",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: darkTheme? Colors.black45:Colors.grey.shade300,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(35),
                                borderSide: BorderSide(width: 0, style: BorderStyle.none),
                              ),
                              prefixIcon: Icon(Icons.email, color: darkTheme? Colors.amber.shade500: Colors.grey,)
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (text){
                            if(text == null || text.isEmpty){
                              return "Email can\'t be empty";
                            }
                            if(EmailValidator.validate(text)==true){
                              return null;
                            }
                            if(text.length<2){
                              return "Please Enter a valid email";
                            }
                            if(text.length>50){
                              return "Email can\'t be more than 50";
                            }
                          },
                          onChanged: (text)=> setState(() {
                            emailTextEditingController.text=text;
                          }),
                        ),


                        ////// Password ////
                        SizedBox(height: 10,),
                        TextFormField(
                          obscureText: !_passwordVisible,
                          inputFormatters: [LengthLimitingTextInputFormatter(15)],
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            ),
                            filled: true,
                            fillColor: darkTheme? Colors.black45:Colors.grey.shade300,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(35),
                              borderSide: BorderSide(width: 0, style: BorderStyle.none),
                            ),
                            prefixIcon: Icon(Icons.password, color: darkTheme? Colors.amber.shade500: Colors.grey,),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                color: darkTheme? Colors.amber.shade500 : Colors.grey,
                              ),
                              onPressed:(){
                                //update the state i.e. toggle password Visible variable
                                setState(() {
                                  _passwordVisible =! _passwordVisible;
                                });
                              },

                            ),
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (text){
                            if(text == null || text.isEmpty){
                              return "Password can\'t be empty";
                            }
                            if(text.length<6){
                              return "Please Enter a valid password";
                            }
                            if(text.length>20){
                              return "Password can\'t be more than 20";
                            }
                            return null;
                          },
                          onChanged: (text)=> setState(() {
                            passwordTextEditingController.text=text;
                          }),
                        ),


                        // Login Button
                        SizedBox(height: 10,),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: darkTheme? Colors.amber.shade500 : Colors.blue,
                              foregroundColor: darkTheme? Colors.black : Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              minimumSize: Size(double.infinity, 50),
                            ),
                            onPressed: (){
                              _submit();
                            }, child: Text('Login', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20 ),)),
                        SizedBox(height: 10,),

                        GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (c)=>Forgetpasswordscreen()));
                          },
                          child: Text('forget Password?', style: TextStyle(color: darkTheme? Colors.amber.shade500 : Colors.blue),),
                        ),

                        SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Doesn't have an Account?", style: TextStyle(color: Colors.grey, fontSize: 16),),
                            SizedBox(width: 5,),
                            GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (c)=> Signupscreen()));
                              },
                              child: Text('SignUp', style: TextStyle(fontSize: 16, color: darkTheme? Colors.amber.shade500 : Colors.blue),),
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
