import 'package:flutter/material.dart';
import 'package:spotnav/data/models/notification_model.dart';
import 'package:spotnav/data/repositories/firebase_notification_repository.dart';
import 'package:spotnav/presentation/notifications/views/notification_panel.dart';
import 'package:spotnav/presentation/notifications/bloc/notification_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotnav/core/di_firebase.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.initFirebase();
  runApp(NotificationTestApp());
}

class NotificationTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notification Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: BlocProvider(
        create: (context) => NotificationBloc(
          repository: di.sl<FirebaseNotificationRepository>(),
          firebaseAuth: di.sl<FirebaseAuth>(),
        )..add(LoadNotificationsEvent()),
        child: NotificationTestPage(),
      ),
    );
  }
}

class NotificationTestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Test'),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              int unreadCount = 0;
              if (state is NotificationLoaded) {
                unreadCount = state.unreadCount;
              }
              return Center(
                child: Container(
                  margin: EdgeInsets.only(right: 16),
                  child: Text(
                    'Unread: $unreadCount',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: context.read<NotificationBloc>(),
                      child: NotificationPanel(),
                    ),
                  ),
                );
              },
              child: Text('Open Notification Panel'),
            ),
            SizedBox(height: 20),
            BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                if (state is NotificationLoaded) {
                  return Column(
                    children: [
                      Text('Total Notifications: ${state.notifications.length}'),
                      Text('Unread Count: ${state.unreadCount}'),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          context.read<NotificationBloc>().add(MarkAllAsReadEvent());
                        },
                        child: Text('Mark All as Read'),
                      ),
                    ],
                  );
                }
                return Text('Loading...');
              },
            ),
          ],
        ),
      ),
    );
  }
} 
