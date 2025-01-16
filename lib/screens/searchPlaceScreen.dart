import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:waygo/Assistants/requestAssistant.dart';
import 'package:waygo/global/mapKey.dart';
import 'package:waygo/models/predictedPlaces.dart';
import 'package:waygo/widgets/place_prediction_tile.dart';

class SearchPlaceScreen extends StatefulWidget {
  const SearchPlaceScreen({super.key});

  @override
  State<SearchPlaceScreen> createState() => _SearchPlaceScreenState();
}

class _SearchPlaceScreenState extends State<SearchPlaceScreen> {

  List<PredictedPlaces> placesPredictedList = [];

  findPlaceAutoCompleteSearchValue(String inputText) async {
    if(inputText.length > 1 && inputText.isNotEmpty){
      String urlAutoCompleteSearch = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKey&components=country:IN";

      var responseAutoCompleteSearch = await RequestAssistant.recieveRequest(urlAutoCompleteSearch);

      if(responseAutoCompleteSearch == "Error occured. Failed No response"){
        return;
      }

      if(responseAutoCompleteSearch["status"]=="OK"){
        var placePredictions = responseAutoCompleteSearch["predictions"];

        var placePredictionsList = (placePredictions as List).map((jsonData) => PredictedPlaces.fromJson(jsonData)).toList();

        setState(() {
          placesPredictedList =  placePredictionsList;
        });
      }
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
        backgroundColor: darkTheme ? Colors.black : Colors.white,
        appBar: AppBar(
          backgroundColor: darkTheme ? Colors.amber.shade500 : Colors.blue,
          leading: GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back, color: darkTheme ? Colors.black : Colors.white,
            ),
          ),
          title: Text(
              "Search & Set dropoff location",
            style: TextStyle(
              color: darkTheme ? Colors.black : Colors.white,
            ),
          ),
          elevation: 0.0,
        ),
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: darkTheme? Colors.amber.shade500 : Colors.blue,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white54,
                    blurRadius: 8,
                    spreadRadius: 0.5,
                    offset: Offset(
                        0.7,
                        0.7
                    ),
                  ),
                ],
              ),

              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.adjust_sharp,
                      color: darkTheme? Colors.black : Colors.white,
                    ),

                    SizedBox(height: 18.0,),

                    Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: TextField(
                            onChanged: (value){
                              findPlaceAutoCompleteSearchValue(value);
                            },
                            decoration: InputDecoration(
                              hintText: "Search Location Here...",
                              hintStyle: TextStyle(
                                color: darkTheme ? Colors.black : Colors.white54,
                              ),
                              fillColor: darkTheme ? Colors.black : Colors.white54,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.only(
                                left: 11,
                                top: 8,
                                bottom: 8,
                              ),
                            ),
                            style: TextStyle(
                              color: darkTheme ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                    ),

                  ],
                ),
              ),
            ),

            // Display place predictions result

            (placesPredictedList.length > 0)
            ? Expanded(
                child:  ListView.separated(
                  itemCount: placesPredictedList.length,
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (context, index){
                    return PlacePredictionTileDesign(
                      predictedPlaces: placesPredictedList[index],
                    );
                  },
                  separatorBuilder: (BuildContext context, int index){
                    return Divider(
                      height: 0,
                      color: darkTheme ? Colors.amber.shade500 : Colors.blue,
                      thickness: 0,
                    );
                  },

                ),
            ) : Container(),
          ],
        ),
      ),
    );
  }
}
