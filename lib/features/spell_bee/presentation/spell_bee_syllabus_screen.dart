import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/profile/profile_provider.dart';
import '../../../data/local/local_storage_service.dart';
import '../../../data/models/student_profile.dart';
import '../../../presentation/widgets/ad_banner_widget.dart';
import '../domain/spell_bee_repository.dart';
import '../domain/spell_bee_word.dart';

/// Official Competition Syllabus & 500+ Word Bank Explorer
class SpellBeeSyllabusScreen extends ConsumerStatefulWidget {
  const SpellBeeSyllabusScreen({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SpellBeeSyllabusScreen()),
    );
  }

  @override
  ConsumerState<SpellBeeSyllabusScreen> createState() => _SpellBeeSyllabusScreenState();
}

class _SpellBeeSyllabusScreenState extends ConsumerState<SpellBeeSyllabusScreen> {
  final SpellBeeRepository _repo = SpellBeeRepository.instance;
  StudentClass? _selectedClass;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedClass = ref.read(studentProfileProvider).studentClass;
    _repo.ensureLoaded();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = LocalStorageService.instance.getAppLanguage() == 'hi';
    final words = _repo.searchWords(_searchQuery, filterClass: _selectedClass);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBEB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF78350F)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isHindi ? 'प्रतियोगिता वर्ड बैंक (Word Banks)' : 'Competition Word Banks',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF78350F)),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() => _searchQuery = val);
                },
                decoration: InputDecoration(
                  hintText: isHindi ? 'शब्द, अर्थ या मूल भाषा खोजें...' : 'Search word, meaning, or origin...',
                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFB45309)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: Color(0xFF9CA3AF)),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFFDE68A)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFFDE68A)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
                  ),
                ),
              ),
            ),

            // Class Filter Chips
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: _selectedClass == null,
                      label: Text(isHindi ? 'सभी कक्षाएं' : 'All Classes'),
                      selectedColor: const Color(0xFFF59E0B),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: _selectedClass == null ? Colors.white : const Color(0xFF78350F),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                      onSelected: (_) {
                        setState(() => _selectedClass = null);
                      },
                    ),
                  ),
                  ...StudentClass.values.map((sc) {
                    final isSel = _selectedClass == sc;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSel,
                        label: Text(sc.label),
                        selectedColor: const Color(0xFFF59E0B),
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : const Color(0xFF78350F),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                        onSelected: (_) {
                          setState(() => _selectedClass = isSel ? null : sc);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Result Count Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  Text(
                    '${words.length} ${isHindi ? "शब्द मिले" : "words found"}',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF92400E), fontSize: 13),
                  ),
                  const Spacer(),
                  Text(
                    _selectedClass != null ? _selectedClass!.label : (isHindi ? 'सभी स्तर' : 'All Tiers'),
                    style: const TextStyle(color: Color(0xFFB45309), fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Word List
            Expanded(
              child: words.isEmpty
                  ? Center(
                      child: Text(
                        isHindi ? 'कोई शब्द नहीं मिला' : 'No matching words found',
                        style: const TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      itemCount: words.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, idx) {
                        final item = words[idx];
                        return _buildWordCard(item, isHindi);
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  Widget _buildWordCard(SpellBeeWord word, bool isHindi) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(word.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            word.word,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1F2937),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            word.targetClass.label,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (word.phonetic.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        word.phonetic,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFF59E0B)),
                onPressed: () => AudioService.instance.speakPrompt(word.word),
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_add_outlined, color: Color(0xFF6B7280)),
                tooltip: isHindi ? 'मिस्टेक वॉल्ट में जोड़ें' : 'Save to Practice Vault',
                onPressed: () {
                  LocalStorageService.instance.addSpellBeeMistake(word.word);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isHindi
                            ? '"${word.word}" वॉल्ट में जोड़ा गया!'
                            : 'Added "${word.word}" to Mistake Vault!',
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            word.definition,
            style: const TextStyle(fontSize: 13, color: Color(0xFF374151), height: 1.25),
          ),
          const SizedBox(height: 6),
          Text(
            '"${word.exampleSentence}"',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Root: ${word.origin}',
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF4B5563)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E7FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  word.partOfSpeech,
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF3730A3)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
