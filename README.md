#  Shopping List App

A basic Flutter app for adding and managing groceries.

##  Features

-  Add groceries with a name, quantity, and category
-  Validate item names and quantities
-  Display categories using colours
-  Swipe to remove groceries
-  Store and retrieve groceries using Firebase Realtime Database
-  Display a loading indicator while fetching data
-  Show error and empty-list messages

##  Built With

- Flutter and Dart
- Firebase Realtime Database
- HTTP package

##  Run the App

Open a terminal in the Flutter project folder containing `pubspec.yaml`, then run:

```bash
flutter pub get
flutter run
```

A Flutter SDK installation, a connected device or emulator, and an internet connection are required.

##  Firebase

The app uses Firebase REST requests to load, add, and delete groceries under `shopping-list`. The database URL is configured in `grocery_list.dart` and `new_item.dart`.

The practice database allows unauthenticated access to this path. Use only sample grocery data.

