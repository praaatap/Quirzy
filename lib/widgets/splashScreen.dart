import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/splash/splash.png',
              width: 120,
              height: 120,
              cacheWidth: 120, 
              cacheHeight: 120,
              filterQuality:
                  FilterQuality.low, // Reduce quality for faster rendering
            ),
            SizedBox(height: 20),
            CupertinoActivityIndicator(
              radius: 15,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              animating: true,
            ),
            SizedBox(height: 30),
            Text('Loading Please Wait...', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
