import 'package:clicker/music_player.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardPage extends StatelessWidget {
  final player = MusicPlayer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Leaderboard')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("leaderboard")
            .orderBy("time", descending: false)
            .limit(10)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          var leaders = snapshot.data!.docs;
          return ListView.builder(
            itemCount: leaders.length,
            itemBuilder: (context, index) {
              var leader = leaders[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(leader["name"] ?? "Unknown"),
                subtitle: Text("Time: ${leader["time"]} sec"),
                leading: Text("#${index + 1}"),
                onTap: () {
                  player.playSoundEffect("sfx/_leaderbord.mp3");
                },
              );
            },
          );
        },
      ),
    );
  }
}
