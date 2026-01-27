import 'package:flutter/material.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Row(
          children: [
            // Logo skeleton
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            // App title skeleton
            Container(
              width: 120,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          // Notification icon skeleton
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section Skeleton
            _buildWelcomeSectionSkeleton(),
            const SizedBox(height: 20),

            // Stats Overview Skeleton
            _buildStatsOverviewSkeleton(),
            const SizedBox(height: 20),

            // Quick Actions Skeleton
            _buildQuickActionsSkeleton(),
            const SizedBox(height: 20),

            // Performance Overview Skeleton
            _buildPerformanceOverviewSkeleton(),
            const SizedBox(height: 20),

            // Recent Activity Skeleton
            _buildRecentActivitySkeleton(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSectionSkeleton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting skeleton
          Container(
            width: 120,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 8),
          // Welcome message skeleton
          Container(
            width: 200,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 8),
          // Summary message skeleton
          Container(
            width: 180,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverviewSkeleton() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCardSkeleton()),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCardSkeleton()),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCardSkeleton()),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCardSkeleton()),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCardSkeleton()),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCardSkeleton()),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCardSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Value skeleton
          Container(
            width: 60,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 8),
          // Label skeleton
          Container(
            width: 80,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title skeleton
        Container(
          width: 100,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0,
          children: [
            _buildActionTileSkeleton(),
            _buildActionTileSkeleton(),
          ],
        ),
      ],
    );
  }

  Widget _buildActionTileSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon skeleton
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 12),
          // Title skeleton
          Container(
            width: 60,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 6),
          // Subtitle skeleton
          Container(
            width: 80,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceOverviewSkeleton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title skeleton
          Container(
            width: 160,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 16),
          // Chart placeholder skeleton
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Section title skeleton
            Container(
              width: 120,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            // View all button skeleton
            Container(
              width: 60,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Activity items skeletons
        for (int i = 0; i < 3; i++) ...[
          _buildActivityItemSkeleton(),
          if (i < 2) const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildActivityItemSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Icon skeleton
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title skeleton
                Container(
                  width: 140,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                // Subtitle skeleton
                Container(
                  width: 100,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          // Time skeleton
          Container(
            width: 50,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}