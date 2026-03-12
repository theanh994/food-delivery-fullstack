class OptionItem {
  final String name;
  final double extraPrice;

  OptionItem({required this.name, this.extraPrice = 0});

  factory OptionItem.fromJson(Map<String, dynamic> json) {
    return OptionItem(
      name: json['name'],
      extraPrice: double.parse(json['extra_price'].toString()),
    );
  }
}

class OptionGroup {
  final String name;
  final bool isRequired;
  final bool isMultiSelect;
  final List<OptionItem> options;

  OptionGroup({
    required this.name,
    required this.isRequired,
    required this.isMultiSelect,
    required this.options,
  });

  factory OptionGroup.fromJson(Map<String, dynamic> json) {
    return OptionGroup(
      name: json['name'],
      isRequired: json['is_required'].toString() == '1' || json['is_required'].toString() == 'true',
      isMultiSelect: json['is_multi_select'].toString() == '1' || json['is_multi_select'].toString() == 'true',
      options: (json['options'] as List).map((item) => OptionItem.fromJson(item)).toList(),
    );
  }
}