// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:melodica_app_new/constants/app_colors.dart';
// import 'package:melodica_app_new/widgets/custom_app_bar.dart';

// class NotificationView extends StatefulWidget {
//   const NotificationView({super.key});

//   @override
//   State<NotificationView> createState() => _NotificationViewState();
// }

// class _NotificationViewState extends State<NotificationView> {
//   Future<void> getFCMToken() async {
//     final _firebaseMessaging = await FirebaseMessaging.instance;
//     // Source - https://stackoverflow.com/a
//     // Posted by MSARKrish
//     // Retrieved 2025-12-19, License - CC BY-SA 4.0

//     if (Platform.isIOS) {
//       String? apnsToken = await _firebaseMessaging.getAPNSToken();
//       if (apnsToken != null) {
//         // await _firebaseMessaging.subscribeToTopic(personID);
//       } else {
//         // await Future<void>.delayed(const Duration(seconds: 3));
//         // apnsToken = await _firebaseMessaging.getAPNSToken();
//         // if (apnsToken != null) {
//         //   await _firebaseMessaging.subscribeToTopic(personID);
//         // }
//       }
//       print("FCM Token: $apnsToken");
//     } else {
//       String? token = await FirebaseMessaging.instance.getToken();
//       print("FCM Token: $token");
//       // await _firebaseMessaging.subscribeToTopic(personID);
//     }

//     // Save this token in Firestore/your backend
//   }

//   Widget _buildHeader() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Row(
//         children: [
//           const Icon(Icons.arrow_back, size: 26),
//           const SizedBox(width: 12),
//           const Expanded(
//             child: Text(
//               'Notifications',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//           ),
//           const Icon(Icons.notifications_active_outlined, size: 26),
//         ],
//       ),
//     );
//   }

//   var selectedView = 0;
//   @override
//   Widget build(BuildContext context) {
//     getFCMToken();
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             _buildHeader(),

//             TypeSelection(
//               onTap: (selection) {
//                 setState(() {
//                   selectedView = selection;
//                 });
//               },
//             ),
//             NotificationsList(selectedView: selectedView),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class NotificationsList extends StatefulWidget {
//   final int selectedView;

//   const NotificationsList({super.key, required this.selectedView});

//   @override
//   State<NotificationsList> createState() => _NotificationsListState();
// }

// class _NotificationsListState extends State<NotificationsList> {
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: SingleChildScrollView(
//         child: StreamBuilder(
//           stream: FirebaseFirestore.instance
//               .collection('notifications')
//               .orderBy('timestamp', descending: true)
//               .snapshots(),
//           builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//             if (!snapshot.hasData) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             var docs = snapshot.data!.docs;

//             // Filter according to selected tab
//             if (widget.selectedView == 2) {
//               // Unread → assuming you have `read: false`
//               docs = docs.where((d) => !(d['read'] ?? true)).toList();
//             } else if (widget.selectedView == 4) {
//               // Flagged → assuming you have `flagged: true`
//               docs = docs.where((d) => d['flagged'] == true).toList();
//             }
//             // if selectedView == 0 → All (no filter)

//             return Column(
//               children: List.generate(docs.length, (index) {
//                 var data = docs[index].data() as Map<String, dynamic>;
//                 final DateTime dateTime = (data['timestamp'] as Timestamp)
//                     .toDate();

//                 // Format date (e.g. 2025-08-30)
//                 String formattedDate = DateFormat(
//                   'yyyy-MM-dd',
//                 ).format(dateTime);

//                 // Format time (e.g. 14:35)
//                 String formattedTime = DateFormat('HH:mm').format(dateTime);

//                 // If you want AM/PM style:
//                 String formattedTime12 = DateFormat('hh:mm a').format(dateTime);

//                 print('Date: $formattedDate');
//                 print('Time: $formattedTime');

//                 return Stack(
//                   children: [
//                     Container(
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           color: Colors.grey.shade200,
//                           width: 2,
//                         ),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       padding: const EdgeInsets.only(
//                         top: 10,
//                         left: 10,
//                         right: 20,
//                         bottom: 20,
//                       ),
//                       margin: const EdgeInsets.symmetric(
//                         vertical: 10,
//                         horizontal: 20,
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             data['title'] ?? "No Title",
//                             //  "Summer Offer!",
//                             style: TextStyle(
//                               fontSize: 22,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           Text(
//                             data['body'] ?? "No Body",
//                             //   "This is a test notification, click me if you want to see more!",
//                           ),
//                         ],
//                       ),
//                     ),

//                     // Positioned(
//                     Positioned(
//                       right: 30,
//                       bottom: 2,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Colors.grey.shade200,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 20,
//                               vertical: 2,
//                             ),
//                             margin: const EdgeInsets.symmetric(horizontal: 5),
//                             child: Text(
//                               formattedDate,
//                               // (data['timestamp'] as Timestamp)
//                               //     .toDate()
//                               //     .toString()
//                               //     .substring(0, 16),
//                               //    "Jun 2023",
//                               style: TextStyle(color: Colors.blue),
//                             ),
//                           ),
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Colors.grey.shade200,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 20,
//                               vertical: 2,
//                             ),
//                             margin: const EdgeInsets.symmetric(horizontal: 5),
//                             child: Text(
//                               formattedTime12,
//                               // "9:45 AM",
//                               style: TextStyle(color: Colors.blue),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 );
//               }),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// class TypeSelection extends StatefulWidget {
//   final void Function(int) onTap;
//   const TypeSelection({super.key, required this.onTap});

//   @override
//   State<TypeSelection> createState() => _TypeSelectionState();
// }

// class _TypeSelectionState extends State<TypeSelection> {
//   var selection = 0;
//   var options = ["All", "_", "Unread", "_", "Flagged"];

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           alignment: Alignment.center,
//           decoration: BoxDecoration(
//             color: Colors.transparent,
//             borderRadius: BorderRadius.circular(50),
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
//           height: 35,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             mainAxisSize: MainAxisSize.min,
//             children: List.generate(options.length, (index) {
//               if (options[index] == "_") {
//                 return VerticalDivider(
//                   thickness: 2,
//                   color: Colors.grey.shade400,
//                 );
//               } else {
//                 return GestureDetector(
//                   onTap: () {
//                     selection = index;
//                     widget.onTap(selection);
//                   },
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: selection == index
//                           ? AppColors.primary
//                           : Colors.transparent,
//                       borderRadius: BorderRadius.circular(50),
//                     ),
//                     width: 100,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 5,
//                     ),
//                     child: Text(
//                       options[index],
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: selection == index
//                             ? Colors.black
//                             : Colors.grey.shade600,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 );
//               }
//             }),
//           ),
//         ),
//       ],
//     );
//   }
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:melodica_app_new/constants/app_colors.dart';

// class AppNotification {
//   final String id;
//   final String title;
//   final String body;
//   final DateTime timestamp;
//   final bool read;

//   AppNotification({
//     required this.id,
//     required this.title,
//     required this.body,
//     required this.timestamp,
//     required this.read,
//   });

//   factory AppNotification.fromDoc(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     return AppNotification(
//       id: doc.id,
//       title: data['title'] ?? '',
//       body: data['body'] ?? '',
//       timestamp: (data['timestamp'] as Timestamp).toDate(),
//       read: data['read'] ?? false,
//     );
//   }
// }

// class NotificationView extends StatefulWidget {
//   const NotificationView({super.key});

//   @override
//   State<NotificationView> createState() => _NotificationViewState();
// }

// class _NotificationViewState extends State<NotificationView> {
//   int selectedTab = 0; // 0=All, 1=Read, 2=Unread

//   @override
//   void initState() {
//     super.initState();
//     // _initFCM();
//   }

//   // Future<void> _initFCM() async {
//   //   await FirebaseMessaging.instance.requestPermission();
//   //   // final token = await FirebaseMessaging.instance.getToken();
//   //   final token = await FirebaseMessaging.instance.getAPNSToken();

//   //   debugPrint("FCM Token: $token");
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         title: const Text(
//           "Notifications",
//           style: TextStyle(fontWeight: FontWeight.w600),
//         ),
//         actions: const [
//           Padding(
//             padding: EdgeInsets.only(right: 12),
//             child: Icon(Icons.notifications_none),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           _FilterTabs(
//             selected: selectedTab,
//             onChanged: (v) => setState(() => selectedTab = v),
//           ),
//           const SizedBox(height: 8),
//           Expanded(child: _NotificationsList(selectedTab: selectedTab)),
//         ],
//       ),
//     );
//   }
// }

// class _FilterTabs extends StatelessWidget {
//   final int selected;
//   final ValueChanged<int> onChanged;

//   const _FilterTabs({required this.selected, required this.onChanged});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Row(
//         children: [
//           _chip("All", 0),
//           const SizedBox(width: 8),
//           _chip("Read", 1),
//           const SizedBox(width: 8),
//           _chip("Unread", 2),
//         ],
//       ),
//     );
//   }

//   Widget _chip(String label, int index) {
//     final isActive = selected == index;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => onChanged(index),
//         child: Container(
//           height: 36,
//           alignment: Alignment.center,
//           decoration: BoxDecoration(
//             color: isActive ? AppColors.primary : Colors.grey.shade100,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Text(
//             label,
//             style: TextStyle(
//               fontWeight: FontWeight.w600,
//               color: isActive ? Colors.black : Colors.grey.shade600,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _NotificationsList extends StatelessWidget {
//   final int selectedTab;

//   const _NotificationsList({required this.selectedTab});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream: FirebaseFirestore.instance
//           .collection('notifications')
//           .orderBy('timestamp', descending: true)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         var items = snapshot.data!.docs
//             .map((d) => AppNotification.fromDoc(d))
//             .toList();

//         if (selectedTab == 1) {
//           items = items.where((n) => n.read).toList();
//         } else if (selectedTab == 2) {
//           items = items.where((n) => !n.read).toList();
//         }

//         return ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: items.length,
//           itemBuilder: (_, i) {
//             final n = items[i];
//             return _NotificationTile(notification: n);
//           },
//         );
//       },
//     );
//   }
// }

// class _NotificationTile extends StatelessWidget {
//   final AppNotification notification;

//   const _NotificationTile({required this.notification});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) =>
//                 NotificationDetailScreen(notification: notification),
//           ),
//         );
//       },
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: notification.read ? Colors.white : const Color(0xFFFFF8E1),
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: Colors.grey.shade200),
//         ),
//         child: Row(
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     notification.title,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 16,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     notification.body,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(color: Colors.grey),
//                   ),
//                 ],
//               ),
//             ),
//             Text(
//               DateFormat('hh:mm a').format(notification.timestamp),
//               style: const TextStyle(color: Colors.grey, fontSize: 12),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class NotificationDetailScreen extends StatelessWidget {
//   final AppNotification notification;

//   const NotificationDetailScreen({super.key, required this.notification});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         title: const Text("Notifications"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               notification.title,
//               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               notification.body,
//               style: const TextStyle(fontSize: 16, height: 1.4),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
