

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final students = [
//       Student(name: 'Tonald Drump', id: '000123', avatar: '👩🏻'),
//       Student(name: 'Bul Gates', id: '000124', avatar: '👨🏿‍💼'),
//       Student(name: 'Tonald Drump', id: '000128', avatar: '👨🏻‍⚕️'),
//     ];

//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       body: SafeArea(
//         child: Row(
//           children: [
//             // Sidebar
//             Container(
//               width: 380,
//               margin: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(24),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   const SizedBox(height: 20),
//                   // Student List
//                   Expanded(
//                     child: ListView.builder(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       itemCount: students.length,
//                       itemBuilder: (context, index) {
//                         return _buildStudentItem(students[index]);
//                       },
//                     ),
//                   ),
//                   // Add new students button
//                   InkWell(
//                     onTap: () {},
//                     child: Container(
//                       margin: const EdgeInsets.all(16),
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       decoration: BoxDecoration(
//                         border: Border(
//                           top: BorderSide(color: Colors.grey[200]!),
//                         ),
//                       ),
//                       child: const Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.add, size: 20),
//                           SizedBox(width: 8),
//                           Text(
//                             'Add new students',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
           
//             // Main Content
//             Expanded(
//               child: Column(
//                 children: [
//                   // Header
//                   Padding(
//                     padding: const EdgeInsets.all(20),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           '08:15',
//                           style: TextStyle(
//                             fontSize: 28,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Row(
//                           children: [
//                             Icon(Icons.signal_cellular_4_bar, size: 20),
//                             const SizedBox(width: 8),
//                             Icon(Icons.wifi, size: 20),
//                             const SizedBox(width: 8),
//                             Icon(Icons.battery_full, size: 20),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   // User Info
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           children: [
//                             Container(
//                               width: 60,
//                               height: 60,
//                               decoration: BoxDecoration(
//                                 color: Colors.pink[100],
//                                 shape: BoxShape.circle,
//                               ),
//                               child: const Center(
//                                 child: Text('👩🏻', style: TextStyle(fontSize: 30)),
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     const Text(
//                                       'Tonald Drump',
//                                       style: TextStyle(
//                                         fontSize: 24,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Icon(Icons.arrow_drop_down, size: 28),
//                                   ],
//                                 ),
//                                 const Text(
//                                   'ID: 000123',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                         Stack(
//                           children: [
//                             const Text('🔔', style: TextStyle(fontSize: 32)),
//                             Positioned(
//                               right: 0,
//                               top: 0,
//                               child: Container(
//                                 width: 18,
//                                 height: 18,
//                                 decoration: const BoxDecoration(
//                                   color: Colors.red,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: const Center(
//                                   child: Text(
//                                     '1',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                   // Welcome Banner
//                   Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 20),
//                     padding: const EdgeInsets.all(32),
//                     decoration: BoxDecoration(
//                       color: Colors.amber[600],
//                       borderRadius: BorderRadius.circular(24),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'Welcome',
//                               style: TextStyle(
//                                 fontSize: 36,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               'Keep Shine in the Worlds',
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 color: Colors.black.withOpacity(0.8),
//                               ),
//                             ),
//                           ],
//                         ),
//                         Stack(
//                           children: [
//                             const Text('🎹', style: TextStyle(fontSize: 80)),
//                             Positioned(
//                               right: -10,
//                               top: -10,
//                               child: Text('✨', style: TextStyle(fontSize: 20)),
//                             ),
//                             Positioned(
//                               right: 20,
//                               top: 10,
//                               child: Text('✨', style: TextStyle(fontSize: 16)),
//                             ),
//                             Positioned(
//                               right: -5,
//                               bottom: 15,
//                               child: Text('✨', style: TextStyle(fontSize: 14)),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                   // Category Cards
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Row(
//                       children: [
//                         _buildCategoryCard('🎹', 'Music Class'),
//                         const SizedBox(width: 16),
//                         _buildCategoryCard('🩰', 'Dance Class'),
//                         const SizedBox(width: 16),
//                         _buildCategoryCard('🎵', 'Packages'),
//                         const SizedBox(width: 16),
//                         _buildCategoryCard('🏪', 'Online Store'),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
         
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStudentItem(Student student) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(12),
//       child: Row(
//         children: [
//           Container(
//             width: 56,
//             height: 56,
//             decoration: BoxDecoration(
//               color: Colors.pink[100],
//               shape: BoxShape.circle,
//             ),
//             child: Center(
//               child: Text(student.avatar, style: const TextStyle(fontSize: 28)),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 student.name,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 'ID: ${student.id}',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey[600],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCategoryCard(String emoji, String label) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(24),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Text(emoji, style: const TextStyle(fontSize: 56)),
//             const SizedBox(height: 12),
//             Text(
//               label,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.black87,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }