import 'package:flutter/material.dart';
import '../Services/AppColors.dart';
import '../Services/api-service.dart';

class RewardPage extends StatefulWidget {
  final int userId;
  const RewardPage({super.key, required this.userId});

  @override
  State<RewardPage> createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage> {
  int totalViews = 0;
  String badge = "Loading...";
  Color badgeColor = AppColors.textMuted;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserViews();
  }

  void fetchUserViews() async {
    try {
      int views = await ApiService().getUserTotalViews(widget.userId);
      if (!mounted) return;

      setState(() {
        totalViews = views;
        _updateBadgeLogic(views);
        isLoading = false;
      });
    } catch (e) {
      debugPrint("--- Error: $e ---");
      setState(() => isLoading = false);
    }
  }

  void _updateBadgeLogic(int views) {
    if (views <= 10) {
      badge = "Bronze";
      badgeColor = Colors.brown.shade400;
    } else if (views <= 30) {
      badge = "Silver";
      badgeColor = Colors.blueGrey.shade300;
    } else if (views <= 60) {
      badge = "Gold";
      badgeColor = Colors.orangeAccent;
    } else {
      badge = "Platinum";
      badgeColor = Colors.cyanAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text("Rewards Center",
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 30),
            const Text(
              "Milestones",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            _buildMilestoneList(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    // Calculate progress towards next goal (simplified logic)
    double progress = (totalViews / 100).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              CircleAvatar(
                radius: 50,
                backgroundColor: badgeColor.withOpacity(0.9),
                child: Icon(Icons.stars_rounded, size: 50, color: Colors.white.withOpacity(0.9)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            badge,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const Text(
            "Current Achievement",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const Divider(height: 30, color: Colors.white24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _infoTile("Total Views", totalViews.toString()),
              _infoTile("Next Goal", "100"),
            ],
          )
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }

  Widget _buildMilestoneList() {
    return Column(
      children: [
        _modernRewardCard("Bronze", 0, 10, Colors.brown.shade400),
        _modernRewardCard("Silver", 11, 30, Colors.blueGrey.shade300),
        _modernRewardCard("Gold", 31, 60, Colors.orangeAccent),
        _modernRewardCard("Platinum", 61, 100, Colors.cyanAccent),
      ],
    );
  }

  Widget _modernRewardCard(String title, int min, int max, Color color) {
    bool isEarned = totalViews >= min;
    bool isCurrent = totalViews >= min && totalViews <= max;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrent ? AppColors.cardBg : AppColors.cardBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: isCurrent ? Border.all(color: color, width: 2) : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEarned ? Icons.check_circle : Icons.lock_outline,
              color: color,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$title Badge",
                  style: TextStyle(
                    color: isEarned ? AppColors.textPrimary : AppColors.textMuted,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Required: $min - $max views",
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text("Active", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}