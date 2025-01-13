import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:waygo/global/global.dart';
import 'package:waygo/screens/loginScreen.dart';
import 'package:waygo/screens/signUpScreen.dart';

class Forgetpasswordscreen extends StatefulWidget {
  const Forgetpasswordscreen({super.key});

  @override
  State<Forgetpasswordscreen> createState() => _ForgetpasswordscreenState();
}

class _ForgetpasswordscreenState extends State<Forgetpasswordscreen> {
  @override

  final emailTextEditingController=TextEditingController();

  // Declare a global Key
  final _formKey = GlobalKey<FormState>();

   void _submit(){
     firebaseAuth.sendPasswordResetEmail(
         email: emailTextEditingController.text.trim(),
     ).then((value){
       Fluttertoast.showToast(msg: "We have sent you a email to recover password, Please check email");
     }).onError((error, stackTrace){
       Fluttertoast.showToast(msg: "Error Occured: \n ${error.toString()} ");
     });
   }

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
              child: Text('Forget Password', style: TextStyle(color: darkTheme? Colors.amber.shade500 : Colors.blue,
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
                            }, child: Text('Frget Password', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20 ),)),
                        SizedBox(height: 10,),

                        GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (c)=> Loginscreen()));
                          },
                          child: Text('Login', style: TextStyle(color: darkTheme? Colors.amber.shade500 : Colors.blue),),
                        ),

                        SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Doesn't have an Account?", style: TextStyle(color: Colors.grey, fontSize: 16),),
                            SizedBox(width: 5,),
                            GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (c)=>Signupscreen()));
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
