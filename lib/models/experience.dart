import 'package:json_annotation/json_annotation.dart';

part 'experience.g.dart';

/// Pengalaman (kerja, riset, volunteer, ...) yang sama dengan
/// `ExperienceSerializer` di API Django (`/api/v1/experiences/`).
///
/// `id` dan `started_at` diisi server, jadi tidak ikut dikirim saat POST/PATCH.
/// `ended_at` yang `null` berarti kegiatannya masih berjalan, dan tetap dikirim
/// sebagai `null` supaya PATCH bisa mengosongkannya lagi.
@JsonSerializable(fieldRename: FieldRename.snake)
class Experience {
  const Experience({
    required this.title,
    required this.description,
    this.category = defaultCategory,
    this.endedAt,
    this.startedAt,
    this.id,
  });

  factory Experience.fromJson(Map<String, dynamic> json) =>
      _$ExperienceFromJson(json);

  /// `EXPERIENCE_CHOICES` di model Django: nilai yang disimpan → label.
  static const Map<String, String> categories = {
    'internship': 'Internship',
    'research': 'Research',
    'volunteer': 'Volunteer',
    'part-time': 'Part-Time',
    'full-time': 'Full-Time',
    'freelance': 'Freelance',
  };

  /// Default `category` di model Django.
  static const String defaultCategory = 'full-time';

  /// Batas `title = models.CharField(max_length=255)`.
  static const int titleMaxLength = 255;

  @JsonKey(includeToJson: false)
  final String? id;
  final String title;
  final String description;
  @JsonKey(defaultValue: defaultCategory)
  final String category;
  @JsonKey(includeToJson: false)
  final DateTime? startedAt;
  final DateTime? endedAt;

  bool get isOngoing => endedAt == null;

  /// Label kategori untuk ditampilkan; nilai yang tidak dikenal tampil apa adanya.
  String get categoryLabel => categories[category] ?? category;

  Map<String, dynamic> toJson() => _$ExperienceToJson(this);
}

/// Format tanggal dd/mm/yyyy tanpa package tambahan.
///
/// Memakai field tanggal milik [date] apa adanya: `ended_at` dikirim sebagai
/// tengah malam UTC dari tanggal yang dipilih, jadi tidak boleh digeser ke
/// zona waktu lokal. Untuk `started_at` (waktu sungguhan) panggil `toLocal()`
/// dulu.
String formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/${date.year}';
