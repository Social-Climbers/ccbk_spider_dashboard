import 'package:flutter/material.dart';

class SponsorBar extends StatelessWidget {
  final bool isDarkTheme;
  
  const SponsorBar({
    super.key,
    this.isDarkTheme = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDarkTheme ? Colors.black : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSponsorLogo('assets/sponsors/cha.png'),
              _buildSponsorLogo('assets/sponsors/cs.png'),
              _buildSponsorLogo('assets/sponsors/la.png'),
              _buildSponsorLogo('assets/sponsors/mojo.png'),
              _buildSponsorLogo('assets/sponsors/petz.png'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSponsorLogo('assets/sponsors/poda.png'),
              _buildSponsorLogo('assets/sponsors/scarpa.png'),
              _buildSponsorLogo('assets/sponsors/shopp.png'),
              _buildSponsorLogo('assets/sponsors/vola.png'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSponsorLogo(String assetPath) {
    return Image.asset(
      assetPath,
      height: 40,
      color: isDarkTheme ? Colors.white : Colors.black,
      fit: BoxFit.contain,
    );
  }
} 