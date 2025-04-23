import 'package:flutter/material.dart';

class SponsorBar extends StatelessWidget {
  const SponsorBar({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final logoSize = isSmallScreen ? 40.0 : 48.0;
    final padding = isSmallScreen ? 4.0 : 8.0;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: padding),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSponsorLogo('assets/sponsors/blackdiamond.png', logoSize),
            _buildSponsorLogo('assets/sponsors/petzl.png', logoSize),
            _buildSponsorLogo('assets/sponsors/la_sportiva.png', logoSize),
            _buildSponsorLogo('assets/sponsors/grivel.png', logoSize),
            _buildSponsorLogo('assets/sponsors/edelrid.png', logoSize),
            _buildSponsorLogo('assets/sponsors/ocun.png', logoSize),
            _buildSponsorLogo('assets/sponsors/blackdiamond.png', logoSize),
            _buildSponsorLogo('assets/sponsors/petzl.png', logoSize),
            _buildSponsorLogo('assets/sponsors/la_sportiva.png', logoSize),
          ],
        ),
      ),
    );
  }

  Widget _buildSponsorLogo(String assetPath, double size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Image.asset(
        assetPath,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.image_not_supported),
            ),
          );
        },
      ),
    );
  }
} 