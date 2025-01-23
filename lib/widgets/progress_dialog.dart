import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget {
  final String message;

  ProgressDialog({this.message = "Loading..."});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black54,
      child: Container(
        margin: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),  // Add padding to prevent text from touching the edges
          child: Row(
            mainAxisSize: MainAxisSize.min,  // Ensures the dialog size wraps content
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              SizedBox(width: 16.0),  // More space between the progress and text
              Flexible(
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,  // Increased font size for better readability
                  ),
                  overflow: TextOverflow.ellipsis,  // Handles long text by truncating
                  maxLines: 2,  // Limits the number of lines
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
