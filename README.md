# Makhzani App

A full-stack application with Flutter mobile frontend and Node.js backend.

## Project Structure

```
makhzani-app/
├── mobile/          # Flutter mobile application
├── backend/         # Node.js API server
├── docs/           # Documentation
├── deployment/     # Docker and deployment configs
└── README.md       # This file
```

## Prerequisites

Before running this project, make sure you have the following installed:

### For Backend (Node.js API)
- **Node.js** (v16.x or higher)
- **npm** (v8.x or higher)
- **Git**

### For Mobile (Flutter)
- **Flutter SDK** (latest stable version)
- **Dart SDK** (included with Flutter)
- **Android Studio** or **VS Code** with Flutter extension  
- **Android SDK** (for Android development)
- **Xcode** (for iOS development - macOS only)

## Installation & Setup

### 1. Clone the Repository

```bash
git clone https://github.com/YounesAmanay/makhzani-app.git
cd makhzani-app
```

### 2. Backend Setup

```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Copy environment variables
cp .env.example .env

# Edit .env file with your configuration
# Update database credentials, JWT secret, etc.

# Start development server
npm run dev
# or
node server.js
```

The backend server will run on `http://localhost:3000`

### 3. Mobile Setup

```bash
# Navigate to mobile directory
cd mobile

# Get Flutter dependencies
flutter pub get

# Run on connected device or emulator
flutter run
```

## Environment Configuration

### Backend (.env)
Update `backend/.env` with your configuration:

```env
PORT=3000
NODE_ENV=development
DB_HOST=localhost
DB_PORT=5432
DB_NAME=makhzani_db
DB_USER=your_db_user
DB_PASSWORD=your_db_password
JWT_SECRET=your_super_secret_jwt_key_here
```

### Mobile
No additional environment setup required for basic Flutter app.

## Available Scripts

### Backend
- `npm start` - Start production server
- `npm run dev` - Start development server with nodemon
- `npm test` - Run tests (when implemented)

### Mobile
- `flutter run` - Run app on connected device/emulator
- `flutter build apk` - Build APK for Android
- `flutter build ios` - Build for iOS (macOS only)
- `flutter test` - Run tests
- `flutter doctor` - Check Flutter installation

## API Documentation

The backend API provides the following endpoints:

- `GET /` - Health check endpoint
- More endpoints will be documented as they are implemented

## Development Workflow

1. **Start Backend**: `cd backend && npm run dev`
2. **Start Mobile**: `cd mobile && flutter run`
3. **Make changes** to either backend or mobile
4. **Test changes** on connected device/emulator

## Troubleshooting

### Common Issues

**Flutter not recognized:**
- Ensure Flutter is added to your system PATH
- Run `flutter doctor` to verify installation

**Backend port already in use:**
- Change PORT in `.env` file
- Or kill process using the port: `lsof -ti:3000 | xargs kill -9` (macOS/Linux)

**Database connection issues:**
- Verify database credentials in `.env`
- Ensure database server is running
- Check network connectivity

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please open an issue in the GitHub repository.