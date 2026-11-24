import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

/// Proyek portofolio, sama dengan `ProjectSerializer` di API Django
/// (`/api/v1/projects/`).
@JsonSerializable(fieldRename: FieldRename.snake)
class Project {
  const Project({
    required this.title,
    required this.description,
    required this.techStack,
    required this.projectUrl,
    this.projectImageUrl = '',
    this.id,
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  /// UUID dibuat oleh Django, jadi tidak ikut dikirim saat POST.
  @JsonKey(includeToJson: false)
  final String? id;
  final String title;
  final String description;
  final String techStack;
  @JsonKey(defaultValue: '')
  final String projectUrl;
  @JsonKey(defaultValue: '')
  final String projectImageUrl;

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}
