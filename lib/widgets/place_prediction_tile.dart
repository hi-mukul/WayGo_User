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
    this.predictedPlaces
  });

  @override
  State<PlacePredictionTileDesign> createState() => _PlacePredictionTileDesignState();
}

class _PlacePredictionTileDesignState extends State<PlacePredictionTileDesign> {

  getPlaceDirectionDetails(String placeId, context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
          message: "Setting Up Drop-off. Please Wait....",
        ),
    );

    String placeDirectionDetailsUrl= "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";

    var responseApi = await RequestAssistant.recieveRequest(placeDirectionDetailsUrl);

    Navigator.pop(context);

    if(responseApi == "Error occured. Failed No response"){
      return;
    }

    if(responseApi["status"] == "OK"){
      Directions directions = Directions();
      directions.locationName =  responseApi["result"]["name"];
      directions.locationId = placeId;
      directions.locationLatitude =  responseApi["result"]["geometry"]["location"]["lat"];
      directions.locationLongitude =  responseApi["result"]["geometry"]["location"]["lng"];
      
      Provider.of<AppInfo>(context, listen: false).updateDropOffLocationAddress(directions);

      setState(() {
        userDropoffAddress = directions.locationName!;
      });

      Navigator.pop(context, "obtainedDropoff");

    }
  }

  @override
  Widget build(BuildContext context) {

    bool darkTheme=MediaQuery.of(context).platformBrightness==Brightness.dark;

    return ElevatedButton(
        onPressed: (){

        },
        style: ElevatedButton.styleFrom(
          backgroundColor : darkTheme ? Colors.black : Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(
                Icons.add_location,
                color: darkTheme ? Colors.amber.shade500 : Colors.blue,
              ),

              SizedBox(width: 10,),
              
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Main Text
                      Text(
                        widget.predictedPlaces!.main_text!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          color: darkTheme ? Colors.amber.shade500 : Colors.blue,
                        ),
                      ),

                      // Secondary Text
                      Text(
                        widget.predictedPlaces!.secondary_text!,
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
