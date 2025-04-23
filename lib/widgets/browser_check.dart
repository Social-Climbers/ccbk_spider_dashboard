import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

class BrowserCheck extends StatefulWidget {
  final Widget child;
  
  const BrowserCheck({
    super.key,
    required this.child,
  });

  @override
  State<BrowserCheck> createState() => _BrowserCheckState();
}

class _BrowserCheckState extends State<BrowserCheck> {
  bool _redirectAttempted = false;
  bool _redirectFailed = false;

  bool _isInAppBrowser() {
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    return userAgent.contains('instagram') || 
           userAgent.contains('line') || 
           userAgent.contains('facebook') ||
           userAgent.contains('twitter') ||
           userAgent.contains('messenger');
  }

  String _getBrowserName() {
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    if (userAgent.contains('instagram')) return 'Instagram';
    if (userAgent.contains('line')) return 'LINE';
    if (userAgent.contains('facebook')) return 'Facebook';
    if (userAgent.contains('twitter')) return 'Twitter';
    if (userAgent.contains('messenger')) return 'Messenger';
    return 'this app';
  }

  List<String> _getInstructions() {
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    if (userAgent.contains('instagram')) {
      return [
        '1. Tap the three dots (•••) in the top right',
        '2. Select "Open in browser"',
      ];
    }
    if (userAgent.contains('line')) {
      return [
        '1. Tap the three dots (•••) in the top right',
        '2. Select "Open in external browser"',
      ];
    }
    if (userAgent.contains('facebook')) {
      return [
        '1. Tap the three dots (•••) in the top right',
        '2. Select "Open in browser"',
      ];
    }
    if (userAgent.contains('twitter')) {
      return [
        '1. Tap the share icon in the top right',
        '2. Select "Open in browser"',
      ];
    }
    if (userAgent.contains('messenger')) {
      return [
        '1. Tap the three dots (•••) in the top right',
        '2. Select "Open in browser"',
      ];
    }
    return [];
  }

  void _redirectToDefaultBrowser() {
    if (!_redirectAttempted) {
      _redirectAttempted = true;
      try {
        final currentUrl = html.window.location.href;
        html.window.location.href = currentUrl;
        
        // If we're still here after 2 seconds, the redirect probably failed
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _redirectFailed = true;
            });
          }
        });
      } catch (e) {
        if (mounted) {
          setState(() {
            _redirectFailed = true;
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (_isInAppBrowser()) {
      _redirectToDefaultBrowser();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInAppBrowser()) {
      return widget.child;
    }

    final browserName = _getBrowserName();
    final instructions = _getInstructions();
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            height: 300,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/ccbklogow.png',
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'SPIDER KIDS',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '10 MAY 2025',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '9:00 AM - 4:00 PM',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 300,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _redirectFailed ? 'Please open in a browser' : 'Redirecting to browser...',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'This app needs to be opened in a regular browser instead of $browserName\'s in-app browser.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_redirectFailed && instructions.isNotEmpty)
                    Column(
                      children: [
                        Text(
                          'To open in browser:',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...instructions.map((instruction) => _buildStep(
                          context,
                          instruction,
                          instruction.contains('dots') ? Icons.more_vert : 
                          instruction.contains('share') ? Icons.share :
                          Icons.open_in_browser,
                        )),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
} 