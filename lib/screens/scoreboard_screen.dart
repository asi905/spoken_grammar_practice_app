import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScoreboardScreen extends StatelessWidget {
  const ScoreboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Scorers',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 22)),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF311B92), Color(0xFF1A237E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A237E), Color(0xFF00154F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .orderBy('score', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.white));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('এখনো কোনো স্কোর নেই!',
                    style: TextStyle(fontSize: 18, color: Colors.white70)),
              );
            }

            final users = snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final name = data['name']?.toString().trim() ?? '';
              return name.isNotEmpty && name.toLowerCase() != 'learner';
            }).toList();

            if (users.isEmpty) {
              return const Center(
                child: Text('এখনো কোনো ভেরিফাইড স্কোর নেই!',
                    style: TextStyle(fontSize: 18, color: Colors.white70)),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final userData = users[index].data() as Map<String, dynamic>;

                if (index < 3) {
                  return _buildPremiumCard(context, userData, index);
                } else {
                  return _buildBlackCard(context, userData, index);
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildPremiumCard(
      BuildContext context, Map<String, dynamic> userData, int index) {
    final String name = userData['name'] ?? 'Unknown User';
    final int score = (userData['score'] as num?)?.toInt() ?? 0;
    final String photoUrl = userData['photoUrl'] ?? '';

    List<Color> gradientColors;
    Color borderColor;
    String medalEmoji;

    if (index == 0) {
      gradientColors = [const Color(0xFFFFD700), const Color(0xFFFFA500)];
      borderColor = Colors.amber.shade800;
      medalEmoji = '👑';
    } else if (index == 1) {
      gradientColors = [const Color(0xFFE0E0E0), const Color(0xFF9E9E9E)];
      borderColor = Colors.grey.shade700;
      medalEmoji = '🥈';
    } else {
      gradientColors = [const Color(0xFFFFCC80), const Color(0xFFFF8A65)];
      borderColor = Colors.deepOrange.shade800;
      medalEmoji = '🥉';
    }

    return GestureDetector(
      onTap: () => _showUserDetails(context, userData, index + 1),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
                color: borderColor.withOpacity(0.6),
                blurRadius: 15,
                offset: const Offset(0, 8))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(medalEmoji, style: const TextStyle(fontSize: 32)),
                  Text('#${index + 1}',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                ],
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 29,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                      photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                  child: photoUrl.isEmpty
                      ? Icon(Icons.person,
                          color: Colors.grey.shade400, size: 30)
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12)),
                      child: Text('$score Pts',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: borderColor)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlackCard(
      BuildContext context, Map<String, dynamic> userData, int index) {
    final String name = userData['name'] ?? 'Unknown User';
    final int score = (userData['score'] as num?)?.toInt() ?? 0;
    final String photoUrl = userData['photoUrl'] ?? '';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.15), width: 1),
      ),
      color: Colors.black87,
      child: ListTile(
        onTap: () => _showUserDetails(context, userData, index + 1),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 30,
              child: Text('#${index + 1}',
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70),
                  textAlign: TextAlign.center),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.grey.shade800,
              backgroundImage:
                  photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
              child: photoUrl.isEmpty
                  ? const Icon(Icons.person, color: Colors.white54)
                  : null,
            ),
          ],
        ),
        title: Text(name,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        trailing: Text('$score Pts',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent)),
      ),
    );
  }

  // 📊 ইউজারের বিস্তারিত দেখানোর ডায়ালগ (OverFlow Fix করা হয়েছে)
  void _showUserDetails(
      BuildContext context, Map<String, dynamic> userData, int rank) {
    final String name = userData['name'] ?? 'Unknown User';
    final int score = (userData['score'] as num?)?.toInt() ?? 0;
    final int vocabCount = (userData['vocabCount'] as num?)?.toInt() ?? 0;
    final String photoUrl = userData['photoUrl'] ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // ✅ ফিক্স ১: এটি ডায়ালগকে প্রয়োজনে বেশি জায়গা নেওয়ার অনুমতি দেবে
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          // ✅ ফিক্স ২: SingleChildScrollView যোগ করা হয়েছে যাতে ছোট স্ক্রিনে স্ক্রল করা যায়
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                // স্ক্রিনের নিচের সেফ এরিয়া বা কীবোর্ডের জন্য ডায়নামিক প্যাডিং
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF1A237E),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black54,
                      blurRadius: 10,
                      offset: Offset(0, -5))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                          color: Colors.white30,
                          borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 37,
                      backgroundColor: Colors.grey.shade800,
                      backgroundImage:
                          photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                      child: photoUrl.isEmpty
                          ? const Icon(Icons.person,
                              size: 40, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(name,
                      textAlign: TextAlign
                          .center, // ✅ বড় নাম হলে সুন্দরভাবে সেন্টারে থাকবে
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Rank #$rank',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber)),
                  const SizedBox(height: 24),
                  _buildDetailRow(Icons.emoji_events, 'MCQ Points',
                      '$score Pts', Colors.amber),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.menu_book, 'Vocabulary Learned',
                      '$vocabCount Words', Colors.greenAccent),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
      IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            // ✅ এখানেও Expanded দেওয়া হলো যাতে ছোট স্ক্রিনে টেক্সট ওভারফ্লো না হয়
            child: Text(title,
                style: const TextStyle(fontSize: 15, color: Colors.white70)),
          ),
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
