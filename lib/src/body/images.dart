import 'package:flutter/material.dart';

class Bianca extends StatelessWidget {
  const Bianca({super.key});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          print("TAPPED BIANCA.");
        },
        child: const AspectRatio(
          aspectRatio: 1,
          child: FadeInImage(
            alignment: Alignment.center,
            placeholder: AssetImage('images/load-icon-png-7952.png'),
            image: AssetImage('images/developer-logo-512x512.png'),
            fit: BoxFit.fill, // AVOIDS A POSSIBLE MARGIN AROUND IF IMAGE SIZE SMALLER THAN PARENT WIDGET
            //width: 600, // GETS IGNORED
          ),
        ),
      );
}

class Pepper extends StatelessWidget {
  const Pepper({super.key});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          print("TAPPED PEPPER.");
        },
        child: const FadeInImage(
          alignment: Alignment.center,
          placeholder: AssetImage('images/load-icon-png-7952.png'),
          image: AssetImage('images/pepper-and-aibo.png'),
          fit: BoxFit.cover,
          width: 900,
          height: 900,
        ),
      );
}
