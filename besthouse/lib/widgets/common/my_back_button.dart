import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyBackButton extends StatelessWidget {
  final VoidCallback? onpressedHanlder;

  const MyBackButton({this.onpressedHanlder, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text(
        'Back',
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      onPressed: () {
        if (onpressedHanlder != null) {
          onpressedHanlder!();
        }
        Navigator.of(context).pop();
      },
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
