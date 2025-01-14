import 'dart:convert';

import 'package:http/http.dart' as http;

class RequestAssistant {
  static Future<dynamic> recieveRequest(String url) async {
    http.Response httpResponse = await http.get(Uri.parse(url));

    try{
      if(httpResponse.statusCode==200){ // Successful responseS
      String responseData = httpResponse.body; //json response
      var deCodeResponseData = jsonDecode(responseData);
       return deCodeResponseData;
      }
      else{
        return "Error occured. Failed No response";
      }
    } catch(exp){
      return "Error occured. Failed No response";
    }
  }
}
