Create a new data model for "$ARGUMENTS".

1. Create `lib/models/{model_name}.dart` with:
   - `import 'package:json_annotation/json_annotation.dart';`
   - `part '{model_name}.g.dart';`
   - `@JsonSerializable()` class with an `id` field (String) and other fields inferred from the model name
   - `factory fromJson` and `toJson` methods using generated `_$` functions
   - A manual `copyWith` method
2. Run `dart run build_runner build --delete-conflicting-outputs` to generate the `.g.dart` file.
3. Run `dart analyze lib/models/` to confirm no issues.

If the user provides field definitions (e.g., "category with name:String, icon:String, color:int"), use those exact fields. Otherwise, infer sensible fields from the model name and ask the user to adjust.
