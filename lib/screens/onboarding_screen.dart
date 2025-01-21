import 'package:cashflow/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLastPage = false;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Bienvenue sur CashFlow',
      'description':
          'Prenez le contrôle de vos finances personnelles avec une application simple et intuitive.',
      'image': 'assets/img/logo.png',
    },
    {
      'title': 'Fixez vos Objectifs Financiers',
      'description':
          'Définissez des objectifs d\'épargne personnalisés et suivez votre progression en temps réel.',
      'image': 'assets/img/objectis.png',
    },
    {
      'title': 'Analysez vos Dépenses',
      'description':
          'Visualisez clairement vos habitudes financières et prenez des décisions éclairées pour votre avenir.',
      'image': 'assets/img/historique.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _isLastPage = _currentPage == _onboardingData.length - 1;
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  void _onNextPressed() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                  ),
                  child: Text(
                    'Passer',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Main content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                    _isLastPage = index == _onboardingData.length - 1;
                  });
                },
                itemBuilder: (context, index) {
                  final data = _onboardingData[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 24.0 : screenSize.width * 0.1,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image with animation
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 500),
                          opacity: _currentPage == index ? 1.0 : 0.0,
                          child: Container(
                            height: isSmallScreen ? 200 : 250,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Image.asset(
                              data['image']!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 32 : 48),

                        // Title
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 500),
                          opacity: _currentPage == index ? 1.0 : 0.0,
                          child: Text(
                            data['title']!,
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Description
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 500),
                          opacity: _currentPage == index ? 1.0 : 0.0,
                          child: Text(
                            data['description']!,
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Navigation
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 24.0 : 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page indicators
                  Row(
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentPage == index
                              ? colorScheme.primary
                              : colorScheme.primary.withOpacity(0.2),
                        ),
                      ),
                    ),
                  ),

                  // Next/Start button
                  ElevatedButton(
                    onPressed: _onNextPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 24 : 32,
                        vertical: isSmallScreen ? 12 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isLastPage ? 'Commencer' : 'Suivant',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _isLastPage
                              ? Icons.login_rounded
                              : Icons.arrow_forward_rounded,
                          size: isSmallScreen ? 20 : 24,
                        ),
                      ],
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
