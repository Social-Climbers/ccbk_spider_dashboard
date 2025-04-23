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

    if (!_redirectFailed) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 24),
              Text(
                'Redirecting to browser...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final browserName = _getBrowserName();
    
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 64,
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              Text(
                'Please open in a browser',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'This app needs to be opened in a regular browser instead of $browserName\'s in-app browser.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              if (browserName == 'Instagram' || browserName == 'LINE')
                Column(
                  children: [
                    Text(
                      'To open in browser:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (browserName == 'Instagram')
                      _buildStep(
                        context,
                        '1. Tap the three dots (•••) in the top right',
                        Icons.more_vert,
                      ),
                    if (browserName == 'Instagram')
                      _buildStep(
                        context,
                        '2. Select "Open in browser"',
                        Icons.open_in_browser,
                      ),
                    if (browserName == 'LINE')
                      _buildStep(
                        context,
                        '1. Tap the three dots (•••) in the top right',
                        Icons.more_vert,
                      ),
                    if (browserName == 'LINE')
                      _buildStep(
                        context,
                        '2. Select "Open in external browser"',
                        Icons.open_in_browser,
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
} 