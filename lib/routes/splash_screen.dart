import "package:flow/routes.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isDotCenter = false;
  bool _isScalTheCircle = false;

  @override
  void initState() {
    super.initState();
    // Auto trigger the animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        setState(() {
          _isDotCenter = true;
        });
        
        Future.delayed(const Duration(milliseconds: 520), () {
          if (!mounted) return;
          setState(() {
            _isScalTheCircle = true;
          });
          
          Future.delayed(const Duration(milliseconds: 600), () {
            if (!mounted) return;
            // Mark splash as finished so redirect allows standard routing
            splashFinished = true;
            
            // Animation finished, navigate to the requested target or home
            final String target = GoRouterState.of(context).uri.queryParameters['target'] ?? '/';
            context.go(target);
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6303C),
      body: SizedBox(
        height: double.infinity,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Center(
              child: AnimatedScale(
                duration: const Duration(milliseconds: 600),
                curve: const Cubic(0.58, -0.30, 0.365, 1),
                scale: _isScalTheCircle ? 10 : 1,
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white,
                  child: Center(
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: _isScalTheCircle
                          ? Colors.white
                          : const Color(0xFFD6303C),
                    ),
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: const Cubic(.47, -1.26, .36, 1),
              left:
                  (MediaQuery.of(context).size.width / 2) -
                  12 -
                  (_isDotCenter ? 0 : 80),
              child: const CircleAvatar(radius: 12, backgroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
