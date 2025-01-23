import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waygo/Assistants/requestAssistant.dart';
import 'package:waygo/global/mapKey.dart';
import 'package:waygo/infoHandler/app_info.dart';
import 'package:waygo/models/direction.dart';
import 'package:waygo/models/predictedPlaces.dart';
import 'package:waygo/widgets/progress_dialog.dart';

import '../global/global.dart';

class PlacePredictionTileDesign extends StatefulWidget {
  final PredictedPlaces? predictedPlaces;

  PlacePredictionTileDesign({
    this.predictedPlaces,
  });

  @override
  State<PlacePredictionTileDesign> createState() => _PlacePredictionTileDesignState();
}

class _PlacePredictionTileDesignState extends State<PlacePredictionTileDesign> {
  // Fetch place details from the API
  Future<void> getPlaceDirectionDetails(String placeId, BuildContext context) async {
    if (placeId.isEmpty) return;  // Handle empty placeId gracefully

    // Show a loading dialog
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: "Setting Up Drop-off. Please Wait....",
      ),
    );

    // Construct the API URL
    String placeDirectionDetailsUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";

    // Get the API response
    var responseApi = await RequestAssistant.recieveRequest(placeDirectionDetailsUrl);

    // Dismiss the loading dialog
    Navigator.pop(context);

    // If an error occurs, handle it gracefully
    if (responseApi == "Error occured. Failed No response") {
      return;
    }

    // Check if the response is successful
    if (responseApi["status"] == "OK") {
      Directions directions = Directions();
      directions.locationName = responseApi["result"]["name"];
      directions.locationId = placeId;
      directions.locationLatitude =
      responseApi["result"]["geometry"]["location"]["lat"];
      directions.locationLongitude =
      responseApi["result"]["geometry"]["location"]["lng"];

      // Update the drop-off location in the provider
      Provider.of<AppInfo>(context, listen: false)
          .updateDropOffLocationAddress(directions);

      // Update the global drop-off address
      setState(() {
        userDropoffAddress = directions.locationName!;
      });

      // Close the dialog and pass the result back
      Navigator.pop(context, "obtainedDropoff");
    } else {
      // Show an error message if the status is not OK
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to get valid data from the API.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    // Ensure predictedPlaces is not null and provide fallback if necessary
    final predictedPlace = widget.predictedPlaces;
    if (predictedPlace == null) {
      return SizedBox.shrink(); // Return an empty widget if no place data is available
    }

    return ElevatedButton(
      onPressed: () {
        // Check if placeId is available before proceeding
        if (predictedPlace.place_id != null) {
          getPlaceDirectionDetails(predictedPlace.place_id!, context);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: darkTheme ? Colors.black : Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(
              Icons.add_location,
              color: darkTheme ? Colors.amber.shade500 : Colors.blue,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Text
                  Text(
                    predictedPlace.main_text ?? "No Address",  // Null check
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      color: darkTheme ? Colors.amber.shade500 : Colors.blue,
                    ),
                  ),
                  // Secondary Text
                  Text(
                    predictedPlace.secondary_text ?? "No Details",  // Null check
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      color: darkTheme ? Colors.amber.shade500 : Colors.blue,
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
