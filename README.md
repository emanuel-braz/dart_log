### A simple dart console logger (release mode enabled/disabled and "limitless" characters)
  
### Usage
```dart
logger.d('message');
logger.e('message');
logger.i('message');
logger.w('message');
logger.trace('message');
logger.prod('message');
```

```dart
final tagLogger = logger.withTag('MY_TAG');
tagLogger.d('message'); // [MY_TAG]: message
```

```dart
logger.d('{"id": 123}', isJson: true); 
/*
    {
        "id": 123 
    }
*/
```

```dart
// Log in release mode
logger.prod('message');
```

#### All logs enabled in release mode
```s
flutter run --dart-define d_log_verbose="true"
```

#### Print max to "N" chars (useful with long api responses)
```dart
logger.d('long response from API', maxChars: 10000);
```