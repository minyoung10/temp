import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../themepage/theme.dart';
import '../add/notification_add.dart';
import '../detail/notification_detail.dart';

class MissionTab extends StatefulWidget {
  final String id;
  const MissionTab({super.key, required this.id});
  @override
  State<MissionTab> createState() => MissionTabState();
}

class MissionTabState extends State<MissionTab> {
  final firestore = FirebaseFirestore.instance;
  XFile? _pickedFile;
  String? roomDataId;
  String? userindex;

  int? image_count;
  int? check_count = 0;
  var scroll = ScrollController();
  @override
  Widget build(BuildContext context) {
    final _imageSize = MediaQuery.of(context).size.width / 4;
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: firestore
                .collection('Smallinfo')
                .doc(widget.id)
                .collection('notifications')
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final docs = snapshot.data!.docs;

              if (docs.isNotEmpty) {
                final roomData = docs.toList();

                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        print(roomData[index]['id']);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificationDetail(
                              roomId: widget.id,
                              docId: roomData[index]['id'],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 25, right: 25, bottom: 25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              roomData[index]['title'],
                              style: blackw700.copyWith(fontSize: 18),
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              color: Color.fromRGBO(227, 255, 217, 1), // 연두색 설정
                              child: Text(
                                roomData[index]['context'],
                                style: blackw500.copyWith(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                return const Text('No data found.');
              }
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddNotification(
                    id: widget.id,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              disabledBackgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: Container(
              width: 343,
              height: 45,
              child: const Center(
                child: Text(
                  '공지 작성하기',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
