import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _heartController;
  late AnimationController _fadeController;

  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _textSlide;
  late Animation<double> _heartBeat;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _heartController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Define animations
    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoRotation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    _textSlide = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    _heartBeat = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _heartController,
      curve: Curves.easeInOut,
    ));

    _fadeIn = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    // Start animations in sequence
    _startAnimations();
  }

  void _startAnimations() async {
    // Start logo animation
    _logoController.forward();

    // Wait and start text animation
    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();

    // Wait and start heart animation
    await Future.delayed(const Duration(milliseconds: 300));
    _heartController.repeat(reverse: true);

    // Wait and start fade animation
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();

    // Wait for all animations to complete
    await Future.delayed(const Duration(milliseconds: 2000));

    // Navigate to next screen based on auth state
    if (mounted) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.isLoggedIn) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/auth');
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _heartController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
      ),
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF7FB),
              Color(0xFFFFF0F5),
              Color(0xFFFFE6EE),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated logo section
              Expanded(
                flex: 3,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScale.value,
                        child: Transform.rotate(
                          angle: _logoRotation.value * 0.1,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFC2185B),
                                  Color(0xFF8E24AA),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFFC2185B).withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.white,
                              size: 60,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Animated text section
              Expanded(
                flex: 2,
                child: AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _textSlide.value),
                      child: Column(
                        children: [
                          // App title with heart animation
                          AnimatedBuilder(
                            animation: _heartController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _heartBeat.value,
                                child: const Text(
                                  '💍 Sangam',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFC2185B),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          // Subtitle with fade animation
                          AnimatedBuilder(
                            animation: _fadeController,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _fadeIn.value,
                                child: const Text(
                                  'Where Two Hearts Meet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF8E24AA),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Loading indicator
              Expanded(
                flex: 1,
                child: AnimatedBuilder(
                  animation: _fadeController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeIn.value,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Preparing your wedding journey...',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
