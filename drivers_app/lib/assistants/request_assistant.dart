import 'dart:convert';

import 'package:http/http.dart' as http;

class RequestAssistant {
  //this recieveRequest() function will return the human readable address taking the latitude and longitude of the current posistion.
  static Future<dynamic> recieveRequest(String url) async {
    http.Response httpResponse = await http.get(Uri.parse(url));
    try {
      if (httpResponse.statusCode == 200) //successful response
      {
        String responseData =
            httpResponse.body; //responseData is in the json data format

        var decodeResponseData = jsonDecode(
            responseData); //here we decode the json data in the human readable address.

        return decodeResponseData; //this 'decodeResponseData' is the human readable address
      } else {
        return "Error Occurred, Failed. No Response.";
      }
    } catch (exp) {
      return "Error Occurred, Failed. No Response.";
    }
  }
}
