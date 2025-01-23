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
  bool isLoading = false;

  findPlaceAutoCompleteSearchValue(String inputText) async {
    if (inputText.length > 1 && inputText.isNotEmpty) {
      setState(() {
        isLoading = true; // Show loading indicator while waiting for results
      });

      String urlAutoCompleteSearch =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKey&components=country:IN";

      try {
        var responseAutoCompleteSearch = await RequestAssistant.recieveRequest(urlAutoCompleteSearch);

        if (responseAutoCompleteSearch == "Error occured. Failed No response") {
          setState(() {
            isLoading = false;
          });
          return;
        }

        if (responseAutoCompleteSearch["status"] == "OK") {
          var placePredictions = responseAutoCompleteSearch["predictions"];
          var placePredictionsList = (placePredictions as List).map((jsonData) => PredictedPlaces.fromJson(jsonData)).toList();

          setState(() {
            placesPredictedList = placePredictionsList;
            isLoading = false; // Hide loading indicator once results are fetched
          });
        }
      } catch (error) {
        setState(() {
          isLoading = false;
        });
        // Handle the error and possibly show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error occurred while fetching places. Please try again later.')),
        );
      }
    } else {
      setState(() {
        placesPredictedList = []; // Clear the list when input is empty or too short
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: darkTheme ? Colors.black : Colors.white,
        appBar: AppBar(
          backgroundColor: darkTheme ? Colors.amber.shade500 : Colors.blue,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back, color: darkTheme ? Colors.black : Colors.white,
            ),
          ),
          title: Text(
            "Search & Set Dropoff Location",
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
                color: darkTheme ? Colors.amber.shade500 : Colors.blue,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white54,
                    blurRadius: 8,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.adjust_sharp,
                      color: darkTheme ? Colors.black : Colors.white,
                    ),
                    SizedBox(height: 18.0),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: TextField(
                          onChanged: (value) {
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
            // Loading indicator
            isLoading
                ? Center(child: CircularProgressIndicator(color: darkTheme ? Colors.amber.shade500 : Colors.blue))
                : placesPredictedList.isNotEmpty
                ? Expanded(
              child: ListView.builder(
                itemCount: placesPredictedList.length,
                itemBuilder: (context, index) {
                  return PlacePredictionTileDesign(
                    predictedPlaces: placesPredictedList[index],
                  );
                },
              ),
            )
                : Container(),
          ],
        ),
      ),
    );
  }
}
