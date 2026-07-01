import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../models/post_model.dart';
import '../../providers/news_provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/auth_provider.dart';


class PollView extends StatefulWidget {
  final PostModel post;
  const PollView({super.key, required this.post});

  @override
  State<PollView> createState() => _PollViewState();
}

class _PollViewState extends State<PollView> {
  bool _isVoting = false;

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final options = post.pollOptions ?? [];
    if (options.isEmpty) return const SizedBox.shrink();

    final votesMap = post.pollVotes ?? {};
    final authUser = context.watch<AuthProvider>().currentUserModel;
    final currentUserIdStr = authUser?.id.toString();

    // Determine total votes and vote count for each index
    String? votedOptionIndexStr;
    int totalVotes = 0;
    final Map<String, int> optionVotesCount = {};

    votesMap.forEach((key, value) {
      if (value is List) {
        final count = value.length;
        optionVotesCount[key] = count;
        totalVotes += count;
        if (currentUserIdStr != null &&
            value.map((e) => e.toString()).contains(currentUserIdStr)) {
          votedOptionIndexStr = key;
        }
      }
    });

    final hasVoted = votedOptionIndexStr != null;

    String question = 'आपकी क्या राय है?';

    final createdAt = post.createdAt ?? DateTime.now();
    final expiryDate = createdAt.add(const Duration(days: 5));

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: ThemeConfig.textPrimary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(options.length, (index) {
            final optionText = options[index];
            final optionIdxStr = index.toString();
            final optionVotes = optionVotesCount[optionIdxStr] ?? 0;
            final double percentage =
                totalVotes > 0 ? (optionVotes / totalVotes) : 0.0;
            final isUserChoice = votedOptionIndexStr == optionIdxStr;

            if (hasVoted) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              if (isUserChoice) ...[
                                const Icon(
                                  Icons.check_circle,
                                  color: ThemeConfig.primary,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                              ],
                              Expanded(
                                child: Text(
                                  optionText,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: isUserChoice
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: ThemeConfig.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(percentage * 100).toStringAsFixed(0)}% ($optionVotes)',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isUserChoice
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: ThemeConfig.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: Colors.orange.shade50.withOpacity(0.5),
                        valueColor: AlwaysStoppedAnimation<Color>(ThemeConfig.primary),
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: InkWell(
                  onTap: _isVoting
                      ? null
                      : () async {
                          if (currentUserIdStr == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('वोट करने के लिए लॉगिन आवश्यक है।'),
                                backgroundColor: ThemeConfig.error,
                              ),
                            );
                            return;
                          }
                          final messenger = ScaffoldMessenger.of(context);
                          setState(() => _isVoting = true);
                          
                          final newsProvider = context.read<NewsProvider>();
                          final homeProvider = context.read<HomeProvider>();
                          
                          final updatedPost = await newsProvider.votePoll(post.id, index);
                          
                          if (!mounted) return;
                          
                          if (updatedPost != null) {
                            homeProvider.updatePostLocally(updatedPost);
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('आपका मत सफलतापूर्वक दर्ज हुआ।'),
                                backgroundColor: ThemeConfig.success,
                                duration: Duration(seconds: 1),
                              ),
                            );
                          } else {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('मत दर्ज करने में त्रुटि।'),
                                backgroundColor: ThemeConfig.error,
                              ),
                            );
                          }
                          if (mounted) {
                            setState(() => _isVoting = false);
                          }
                        },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.radio_button_unchecked_outlined,
                          size: 18,
                          color: ThemeConfig.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            optionText,
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: ThemeConfig.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          }),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'कुल वोट: $totalVotes',
                style: const TextStyle(
                  fontSize: 11,
                  color: ThemeConfig.textHint,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'समाप्ति: ${expiryDate.day} ${_getMonthName(expiryDate.month)} ${expiryDate.year}',
                style: const TextStyle(
                  fontSize: 11,
                  color: ThemeConfig.textHint,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'जनवरी',
      'फरवरी',
      'मार्च',
      'अप्रैल',
      'मई',
      'जून',
      'जुलाई',
      'अगस्त',
      'सितंबर',
      'अक्टूबर',
      'नवंबर',
      'दिसंबर'
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }
}
