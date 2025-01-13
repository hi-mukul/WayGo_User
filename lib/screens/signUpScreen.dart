import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:waygo/global/global.dart';
import 'package:waygo/screens/forgetPasswordScreen.dart';
import 'package:waygo/screens/loginScreen.dart';
import 'package:waygo/screens/mainScreen.dart';

class Signupscreen extends StatefulWidget {
  const Signupscreen({super.key});

  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
  final nameTextEditingController=TextEditingController();
  final emailTextEditingController=TextEditingController();
  final phoneTextEditingController=TextEditingController();
  final addressTextEditingController=TextEditingController();
  final passwordTextEditingController=TextEditingController();
  final confirmPasswordTextEditingController=TextEditingController();

  bool _passwordVisible = false;

  void _submit() async{
    // if all the field are validate
    if(_formKey.currentState!.validate()){
      await firebaseAuth.createUserWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim(),
      ).then((auth)async{
        currentUser=auth.user;
        if(currentUser != null){
          Map userMap={
            "id": currentUser!.uid,
            "name": nameTextEditingController.text.trim(),
            "email": emailTextEditingController.text.trim(),
            "address": addressTextEditingController.text.trim(),
            "phone": phoneTextEditingController.text.trim(),
          };

          DatabaseReference userRef=FirebaseDatabase.instance.ref().child("users");
          userRef.child(currentUser!.uid).set(userMap);
        }
        await Fluttertoast.showToast(
          msg: "Successfully Registered",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.push(context, MaterialPageRoute(builder: (c)=>MainScreen()));
      }).catchError((errorMessage){
        Fluttertoast.showToast(msg: "Error occured: \n $errorMessage");
      });
    }
    else{
      Fluttertoast.showToast(msg: "All field are not valid");
    }
  }

  // declare a globle key

  final _formKey = GlobalKey<FormState>();
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
              child: Text('SignUp', style: TextStyle(color: darkTheme? Colors.amber.shade500 : Colors.blue,
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

                        //////  Name  ////
                        TextFormField(inputFormatters: [LengthLimitingTextInputFormatter(50)],
                          decoration: InputDecoration(
                            hintText: 'Name',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            ),
                            filled: true,
                            fillColor: darkTheme? Colors.black45:Colors.grey.shade300,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(35),
                              borderSide: BorderSide(width: 0, style: BorderStyle.none),
                            ),
                            prefixIcon: Icon(Icons.person, color: darkTheme? Colors.amber.shade500: Colors.grey,)
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (text){
                            if(text == null || text.isEmpty){
                              return "Name can\'t be empty";
                            }
                            if(text.length<2){
                              return "Please Enter a valid name";
                            }
                            if(text.length>50){
                              return "Name can\'t be more than 50";
                            }
                          },
                          onChanged: (text)=> setState(() {
                            nameTextEditingController.text=text;
                          }),
                        ),

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

                        ///// Phone number /////
                        SizedBox(height: 10,),
                        IntlPhoneField(
                          showCountryFlag: false,
                          dropdownIcon: Icon(
                            Icons.arrow_drop_down,
                            color: darkTheme? Colors.amber.shade500 : Colors.grey,
                          ),
                          decoration: InputDecoration(
                              hintText: "Phone",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: darkTheme? Colors.black45:Colors.grey.shade300,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(35),
                                borderSide: BorderSide(width: 0, style: BorderStyle.none),
                              ),
                          ),
                          initialCountryCode: 'IND',
                          onChanged: (text)=> setState(() {
                            phoneTextEditingController.text=text.completeNumber;
                          }),
                        ),

                        ///// Address //////
                        SizedBox(height: 10,),
                        TextFormField(inputFormatters: [LengthLimitingTextInputFormatter(100)],
                          decoration: InputDecoration(
                              hintText: 'Address',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: darkTheme? Colors.black45:Colors.grey.shade300,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(35),
                                borderSide: BorderSide(width: 0, style: BorderStyle.none),
                              ),
                              prefixIcon: Icon(Icons.location_city, color: darkTheme? Colors.amber.shade500: Colors.grey,)
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (text){
                            if(text == null || text.isEmpty){
                              return "Address can\'t be empty";
                            }
                            if(text.length<15){
                              return "Please Enter a valid address";
                            }
                            if(text.length>100){
                              return "Address can\'t be more than 100";
                            }
                          },
                          onChanged: (text)=> setState(() {
                            addressTextEditingController.text=text;
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

                        ////// Confirm Password
                        SizedBox(height: 10,),
                        TextFormField(
                          obscureText: !_passwordVisible,
                          inputFormatters: [LengthLimitingTextInputFormatter(15)],
                          decoration: InputDecoration(
                            hintText: 'Confirm Password',
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
                              return "Confirm Password can\'t be empty";
                            }
                            if(text != passwordTextEditingController.text){
                              return "Password do not match";
                            }
                            if(text.length<6){
                              return "Please Enter a valid Confirm password";
                            }
                            if(text.length>20){
                              return "Confirm Password can\'t be more than 20";
                            }
                            return null;
                          },
                          onChanged: (text)=> setState(() {
                            confirmPasswordTextEditingController.text=text;
                          }),
                        ),

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
                        }, child: Text('SignUp', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20 ),)),
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
                            Text("Have an Account?", style: TextStyle(color: Colors.grey, fontSize: 16),),
                            SizedBox(width: 5,),
                            GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (c)=>Loginscreen()));
                              },
                              child: Text('Login', style: TextStyle(fontSize: 16, color: darkTheme? Colors.amber.shade500 : Colors.blue),),
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
