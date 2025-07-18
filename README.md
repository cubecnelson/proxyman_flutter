# Proxyman Flutter

A Proxyman-like network debugging proxy tool built with Flutter. This application allows you to inspect HTTP/HTTPS traffic in real-time, similar to the popular Proxyman desktop application.

## Features

### 🚀 Core Features
- **Real-time HTTP Traffic Monitoring**: Capture and display HTTP requests and responses
- **Request/Response Inspection**: Detailed view of headers, body, and timing information
- **Status Code Visualization**: Color-coded status indicators for quick identification
- **Method-based Filtering**: Visual distinction between HTTP methods (GET, POST, PUT, DELETE, etc.)
- **Timing Information**: Request duration and timing breakdown
- **Modern UI**: Clean, intuitive interface inspired by Proxyman

### 📊 Transaction Details
- **Request Tab**: View URL, method, headers, and body
- **Response Tab**: Status codes, response headers, and body content
- **Headers Tab**: Detailed view of all request and response headers
- **Timing Tab**: Request timing breakdown and performance metrics

### 🎛️ Controls
- **Start/Stop Proxy**: Control proxy server operation
- **Clear Transactions**: Reset captured traffic
- **Real-time Status**: Visual indicator of proxy server status

### ✏️ Modification Features
- **Request Editing**: Edit HTTP method, URL, headers, and body
- **Response Editing**: Modify status codes, response headers, and body
- **Real-time Updates**: Changes are immediately reflected in the UI
- **Header Management**: Add, edit, or remove request and response headers

## Screenshots

The application features a split-pane interface:
- **Left Panel**: List of HTTP transactions with method, URL, status, and timing
- **Right Panel**: Detailed view of selected transaction with tabbed interface

## Getting Started

### Prerequisites
- Flutter SDK (3.2.3 or higher)
- Dart SDK
- iOS Simulator or Android Emulator (for testing)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd proxyman_flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Usage

1. **Start the Proxy**
   - Click the "Start" button in the toolbar
   - The proxy will begin capturing HTTP traffic
   - Status indicator will show "Running"

2. **View Transactions**
   - HTTP transactions will appear in the left panel
   - Each transaction shows method, URL, status, and timing
   - Color-coded indicators for different HTTP methods

3. **Inspect Details**
   - Click on any transaction to view detailed information
   - Use the tabbed interface to explore:
     - **Request**: URL and body information
     - **Response**: Status codes and response data
     - **Headers**: All request and response headers
     - **Timing**: Performance metrics and timing breakdown

4. **Control Operations**
   - **Stop**: Pause traffic capture
   - **Clear**: Remove all captured transactions
   - **Start**: Resume traffic capture

5. **Modify Transactions**
   - **Edit Request**: Click the edit icon (✏️) in the transaction header to modify request details
   - **Edit Response**: Click the edit note icon (📝) to modify response details
   - **Update Headers**: Add, edit, or remove headers in the modification interface
   - **Save Changes**: Click "Save" to apply modifications to the transaction

## Architecture

### Models
- `HttpRequest`: Represents HTTP request data
- `HttpResponse`: Represents HTTP response data
- `HttpTransaction`: Combines request and response with timing

### Services
- `ProxyService`: Manages proxy operations and traffic simulation

### Widgets
- `TransactionList`: Displays list of HTTP transactions
- `TransactionDetail`: Shows detailed transaction information
- `MainScreen`: Main application interface

## Development

### Project Structure
```
lib/
├── models/
│   ├── http_request.dart
│   ├── http_response.dart
│   └── http_transaction.dart
├── services/
│   └── proxy_service.dart
├── screens/
│   └── main_screen.dart
├── widgets/
│   ├── transaction_list.dart
│   └── transaction_detail.dart
└── main.dart
```

### Dependencies
- `flutter`: Core Flutter framework
- `http`: HTTP client for network requests
- `dio`: Advanced HTTP client
- `intl`: Internationalization and formatting
- `provider`: State management (for future enhancements)

## Current Implementation

This is a **simulated proxy** that generates mock HTTP transactions to demonstrate the UI and functionality. The application includes:

- ✅ Complete UI implementation
- ✅ Transaction list with filtering and selection
- ✅ Detailed transaction view with tabs
- ✅ Real-time status updates
- ✅ Mock data generation for demonstration

## Future Enhancements

### Planned Features
- [ ] **Real HTTP Proxy**: Actual network traffic interception
- [ ] **SSL/TLS Support**: HTTPS traffic inspection
- [x] **Request Modification**: Edit requests before sending
- [x] **Response Modification**: Modify responses
- [x] **Filtering**: Filter transactions by method, status, domain
- [x] **Search**: Search through transaction data
- [ ] **Export**: Export transactions to various formats
- [ ] **Breakpoints**: Set breakpoints for specific requests
- [ ] **Mobile Support**: Run on mobile devices
- [ ] **Network Configuration**: Custom proxy settings

### Technical Improvements
- [ ] **Real Proxy Server**: Implement actual HTTP proxy functionality
- [ ] **Certificate Management**: Handle SSL certificates
- [ ] **Performance Optimization**: Improve large transaction handling
- [ ] **Persistence**: Save transactions to local storage
- [ ] **Real-time Updates**: WebSocket-based real-time updates

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Inspired by [Proxyman](https://proxyman.io/)
- Built with [Flutter](https://flutter.dev/)
- Icons from [Material Design](https://material.io/)

## Support

For support and questions, please open an issue on GitHub or contact the development team. 