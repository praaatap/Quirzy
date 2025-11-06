import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:quirzy/service/api_service.dart';

class WaitingForInviteScreen extends StatefulWidget {
  final int challengeId;
  final String opponentName;

  const WaitingForInviteScreen({
    super.key,
    required this.challengeId,
    required this.opponentName,
  });

  @override
  State<WaitingForInviteScreen> createState() =>
      _WaitingForInviteScreenState();
}

class _WaitingForInviteScreenState extends State<WaitingForInviteScreen> {
  bool _isCancelLoading = false;
  late bool _isLowEndDevice;
  late double _avatarSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.of(context).size;
    _isLowEndDevice = size.width < 350;
    _avatarSize = _isLowEndDevice ? 100.0 : size.width * 0.4;
  }

  Future<void> _cancelChallenge() async {
    if (_isCancelLoading) return;

    setState(() => _isCancelLoading = true);

    try {
      await ApiService.cancelChallenge(widget.challengeId);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Challenge cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCancelLoading = false);
    }
  }

  Widget _buildAvatar() {
    final theme = Theme.of(context);
    return AvatarGlow(
      glowColor: theme.colorScheme.primary,
      duration: const Duration(milliseconds: 2000),
      repeat: true,
      child: Container(
        width: _avatarSize,
        height: _avatarSize,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: _avatarSize * 0.4,
              color: theme.colorScheme.primary,
            ),
            Positioned(
              right: _avatarSize * 0.15,
              bottom: _avatarSize * 0.15,
              child: Container(
                padding: EdgeInsets.all(_avatarSize * 0.05),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hourglass_bottom,
                  color: Colors.white,
                  size: _avatarSize * 0.12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = _isLowEndDevice ? 16.0 : 24.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenge Sent'),
        centerTitle: true,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: padding,
                  vertical: _isLowEndDevice ? 8.0 : 16.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAvatar(),
                    SizedBox(height: _isLowEndDevice ? 16 : 24),
                    Text(
                      'Waiting for ${widget.opponentName}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: _isLowEndDevice ? 20 : 24,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: _isLowEndDevice ? 8 : 12),
                    Text(
                      'Your challenge has been sent to ${widget.opponentName}.\n'
                      'They have 24 hours to accept your challenge.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: _isLowEndDevice ? 14 : 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: _isLowEndDevice ? 24 : 32),
                    SizedBox(
                      width: _isLowEndDevice ? 32 : 40,
                      height: _isLowEndDevice ? 32 : 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                        strokeWidth: 3,
                      ),
                    ),
                    SizedBox(height: _isLowEndDevice ? 24 : 40),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: _isLowEndDevice ? 16 : 24,
                        top: _isLowEndDevice ? 16 : 24,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.error,
                            foregroundColor: theme.colorScheme.onError,
                            padding: EdgeInsets.symmetric(
                              vertical: _isLowEndDevice ? 12 : 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed:
                              _isCancelLoading ? null : _cancelChallenge,
                          child: _isCancelLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Cancel Challenge',
                                  style: TextStyle(
                                    fontSize: _isLowEndDevice ? 16 : 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
