import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/services/device_info_helper.dart';
import '../../../data/local/local_storage_service.dart';
import '../data/feedback_model.dart';
import '../domain/feedback_service.dart';

/// Kid-safe, Parental-gated feedback and review sheet for Curio Academy
class FeedbackBottomSheet extends StatefulWidget {
  final bool initialGatePassed;

  const FeedbackBottomSheet({
    super.key,
    this.initialGatePassed = false,
  });

  static Future<void> show(BuildContext context, {bool skipGate = false}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FeedbackBottomSheet(initialGatePassed: skipGate),
    );
  }

  @override
  State<FeedbackBottomSheet> createState() => _FeedbackBottomSheetState();
}

class _FeedbackBottomSheetState extends State<FeedbackBottomSheet> {
  late bool _gatePassed;
  late int _num1;
  late int _num2;
  final TextEditingController _gateController = TextEditingController();
  String? _gateError;

  int _rating = 5;
  FeedbackCategory _selectedCategory = FeedbackCategory.feature;
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  bool _isSubmitting = false;
  bool _isSubmitted = false;
  AppDeviceDetails? _deviceDetails;

  @override
  void initState() {
    super.initState();
    _gatePassed = widget.initialGatePassed;
    _generateChallenge();
    _loadDeviceInfo();
  }

  void _loadDeviceInfo() async {
    final details = await DeviceInfoHelper.getDeviceDetails();
    if (mounted) {
      setState(() => _deviceDetails = details);
    }
  }

  @override
  void dispose() {
    _gateController.dispose();
    _commentController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _generateChallenge() {
    final rand = Random();
    _num1 = rand.nextInt(7) + 3; // 3 to 9
    _num2 = rand.nextInt(7) + 3; // 3 to 9
  }

  void _verifyGate() {
    final expected = _num1 * _num2;
    final entered = int.tryParse(_gateController.text.trim());
    if (entered == expected) {
      AudioService.instance.playSfx(CurioSfx.correctCheer);
      setState(() {
        _gatePassed = true;
        _gateError = null;
      });
    } else {
      AudioService.instance.playSfx(CurioSfx.gentleWobble);
      setState(() {
        _gateError = 'Incorrect answer. Please try again!';
        _generateChallenge();
        _gateController.clear();
      });
    }
  }

  String _getRatingLabel(int rating, bool isHindi) {
    if (isHindi) {
      switch (rating) {
        case 1:
          return 'सुधार की आवश्यकता 😕';
        case 2:
          return 'ठीक-ठाक 🙂';
        case 3:
          return 'अच्छा 👍';
        case 4:
          return 'बहुत बढ़िया! 🌟';
        case 5:
        default:
          return 'अति उत्तम! शानदार! ❤️';
      }
    } else {
      switch (rating) {
        case 1:
          return 'Needs Improvement 😕';
        case 2:
          return 'Fair 🙂';
        case 3:
          return 'Good 👍';
        case 4:
          return 'Very Good! 🌟';
        case 5:
        default:
          return 'Loved It! Amazing ❤️';
      }
    }
  }

  Future<void> _handleSubmit(bool isHindi) async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty && _rating < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isHindi
              ? 'कृपया हमें बताएं कि हम कैसे सुधार कर सकते हैं'
              : 'Please write a brief note on how we can improve!',
          ),
          backgroundColor: Colors.orange.shade800,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    AudioService.instance.playSfx(CurioSfx.click);

    try {
      final profile = await LocalStorageService.instance.getStudentProfile();
      final deviceDetails = _deviceDetails ?? await DeviceInfoHelper.getDeviceDetails();

      final feedback = UserFeedback(
        rating: _rating,
        category: _selectedCategory,
        comment: comment.isEmpty ? 'Rating: $_rating Stars' : comment,
        contactInfo: _contactController.text.trim().isEmpty ? null : _contactController.text.trim(),
        studentName: profile?.studentName,
        studentClass: profile?.studentClass.label,
        board: profile?.board.code,
        appVersion: deviceDetails.appVersion,
        buildNumber: deviceDetails.buildNumber,
        platform: deviceDetails.platform,
        deviceModel: deviceDetails.deviceModel,
        deviceBrand: deviceDetails.deviceBrand,
        deviceManufacturer: deviceDetails.deviceManufacturer,
        osVersion: deviceDetails.osVersion,
        osSdkInt: deviceDetails.osSdkInt,
        createdAt: DateTime.now(),
      );

      await FeedbackService.instance.submitFeedback(feedback);

      AudioService.instance.playSfx(CurioSfx.correctCheer);
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isSubmitted = true;
        });

        await Future.delayed(const Duration(milliseconds: 1600));
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = LocalStorageService.instance.getAppLanguage() == 'hi';

    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 14,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top drag indicator
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),

              if (!_gatePassed)
                _buildParentalGate(isHindi)
              else if (_isSubmitted)
                _buildSuccessView(isHindi)
              else
                _buildFeedbackForm(isHindi),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParentalGate(bool isHindi) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            color: Color(0xFFEEF2FF),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.family_restroom_rounded,
            size: 34,
            color: Color(0xFF6366F1),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          isHindi ? 'अभिभावक सत्यापन 🛡️' : 'Parent Zone Check 🛡️',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isHindi
              ? 'कृपया अपनी प्रतिक्रिया साझा करने से पहले इस गणित के प्रश्न को हल करें।'
              : 'Please solve this simple math question to proceed to feedback.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFC7D2FE)),
          ),
          child: Text(
            '$_num1  ×  $_num2  =  ?',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF3730A3),
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: 140,
          child: TextField(
            controller: _gateController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            autofocus: true,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: '?',
              errorText: _gateError,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onSubmitted: (_) => _verifyGate(),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
          onPressed: _verifyGate,
          child: Text(
            isHindi ? 'सत्यापित करें' : 'Verify & Continue',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildSuccessView(bool isHindi) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFECFDF5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF10B981),
              size: 54,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isHindi ? 'आपकी प्रतिक्रिया के लिए धन्यवाद! 🎉' : 'Thank You So Much! 🎉',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isHindi
                ? 'आपके बहुमूल्य सुझाव हमें ऐप को और बेहतर बनाने में मदद करेंगे।'
                : 'Your feedback directly helps us create better lessons and activities!',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackForm(bool isHindi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.rate_review_rounded,
                color: Color(0xFF6366F1),
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isHindi ? 'प्रतिक्रिया और सुझाव 💬' : 'Feedback & Suggestions 💬',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    isHindi
                        ? 'हमें बताएं कि हम आपके बच्चे के लिए ऐप को और कैसे बेहतर बना सकते हैं'
                        : 'Help us improve Curio Academy for your child',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Interactive 5-Star Rating Row
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              final isFilled = starIndex <= _rating;
              return GestureDetector(
                onTap: () {
                  AudioService.instance.playSfx(CurioSfx.click);
                  setState(() => _rating = starIndex);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: isFilled ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
                    size: 38,
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            _getRatingLabel(_rating, isHindi),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Feedback Category Chips
        Text(
          isHindi ? 'विषय चुनें' : 'Feedback Category',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: FeedbackCategory.values.map((cat) {
            final isSelected = _selectedCategory == cat;
            return ChoiceChip(
              label: Text(
                cat.localized(isHindi),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
              ),
              selected: isSelected,
              selectedColor: const Color(0xFF6366F1),
              backgroundColor: const Color(0xFFF1F5F9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
                ),
              ),
              onSelected: (selected) {
                if (selected) {
                  AudioService.instance.playSfx(CurioSfx.click);
                  setState(() => _selectedCategory = cat);
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Text input for comment
        TextField(
          controller: _commentController,
          maxLines: 3,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: isHindi
                ? 'अपने सुझाव, विचार या किसी समस्या के बारे में लिखें...'
                : 'Share your ideas, feature requests, or any issues...',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Optional contact info
        TextField(
          controller: _contactController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.alternate_email_rounded, size: 18, color: Color(0xFF64748B)),
            hintText: isHindi
                ? 'ईमेल या फोन (वैकल्पिक - यदि आप उत्तर चाहते हैं)'
                : 'Email or Phone (Optional, if you would like a reply)',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Google Play Store Promotion Banner (Shown if rating is 5 stars)
        if (_rating == 5) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isHindi
                        ? 'Google Play पर भी 5-स्टार रेटिंग देकर हमें सपोर्ट करें!'
                        : 'Love Curio? A 5-star review on Google Play helps us grow!',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  onPressed: () {
                    FeedbackService.instance.openPlayStoreReview();
                  },
                  child: Text(
                    isHindi ? 'रेट करें ⭐' : 'Rate Us ⭐',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Submit Button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            elevation: 2,
          ),
          onPressed: _isSubmitting ? null : () => _handleSubmit(isHindi),
          child: _isSubmitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.send_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      isHindi ? 'प्रतिक्रिया भेजें 🚀' : 'Submit Feedback 🚀',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
        ),
        if (_deviceDetails != null) ...[
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 13, color: Color(0xFF64748B)),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      '${_deviceDetails!.deviceBrand.toUpperCase()} ${_deviceDetails!.deviceModel} • ${_deviceDetails!.osVersion} • v${_deviceDetails!.fullAppVersion}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
