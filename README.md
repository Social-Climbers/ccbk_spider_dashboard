# Spider Kids Competition 2025

A web application for managing the Spider Kids climbing competition at Climb Central Bangkok, scheduled for May 10, 2025.

## Features

- Competition registration for three age categories:
  - Kids A (born 2011-2012)
  - Kids B (born 2013-2014)
  - Kids C (born 2015-2018)
- Two climbing disciplines:
  - Top Rope (16 routes, top 10 counted)
  - Boulder (16 problems, top 10 counted)
- Scoring system:
  - Points based on route/problem completion
  - Attempt counting for boulder discipline
  - Maximum 3 attempts for top rope routes
- Real-time results and rankings
- Competitor management system

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Web browser (Chrome recommended for development)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/ccbk_spider_kids_comp.git
   ```

2. Navigate to the project directory:
   ```bash
   cd ccbk_spider_kids_comp
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the application:
   ```bash
   flutter run -d chrome
   ```

## Project Structure

```
lib/
  ├── models/         # Data models
  ├── screens/        # UI screens
  ├── widgets/        # Reusable widgets
  ├── services/       # Business logic
  ├── utils/          # Utility functions
  ├── theme/          # Theme configuration
  └── main.dart       # Application entry point
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Climb Central Bangkok
- All sponsors and partners
- The climbing community
