//  Expanded(
//               child: _isLoading
//                   ? Center(child: CircularProgressIndicator())
//                   : ListView(
//                       // Changed to ListView to handle footer button easily
//                       padding: EdgeInsets.symmetric(horizontal: 16),
//                       children: [
//                         // FIND THE ORIGINAL TEACHER
//                         ..._slots.where((t) => t.id == widget.s.ClientID).map((
//                           teacher,
//                         ) {
//                           print(
//                             't.id == widget.s.ClientID ${teacher.id == widget.s.ClientID}',
//                           );
//                           return Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // IF NO SLOTS: Show the "Please note" message
//                               if (teacher.slots.isEmpty)
//                                 Container(
//                                   margin: EdgeInsets.only(bottom: 10),
//                                   padding: EdgeInsets.all(12),
//                                   decoration: BoxDecoration(
//                                     color: Color(0xFFFFF7EC),
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   child: Text(
//                                     "Your teacher doesn't have any available times on this date. You'll find other available teachers listed below.",
//                                     style: TextStyle(
//                                       color: Colors.orange[800],
//                                       fontSize: 13,
//                                     ),
//                                   ),
//                                 ),

//                               // THE ORIGINAL TEACHER CARD
//                               _buildTeacherCard(teacher),
//                             ],
//                           );
//                         }).toList(),

//                         // "SHOW OTHER TEACHERS" BUTTON
//                         if (!_showOthers)
//                           Center(
//                             child: TextButton(
//                               onPressed: () =>
//                                   setState(() => _showOthers = true),
//                               child: Text(
//                                 "Show other teachers",
//                                 style: TextStyle(
//                                   color: Colors.blue,
//                                   decoration: TextDecoration.underline,
//                                 ),
//                               ),
//                             ),
//                           ),

//                         // SHOW OTHER TEACHERS LIST
//                         if (_showOthers)
//                           ..._slots
//                               .where((t) => t.id != widget.s.ClientID)
//                               .map((teacher) => _buildTeacherCard(teacher))
//                               .toList(),
//                       ],
//                     ),
//             ),
