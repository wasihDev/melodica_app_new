import 'package:flutter/material.dart';
import 'package:melodica_app_new/providers/country_code_provider.dart';
import 'package:provider/provider.dart';

class CountryCodeDropdown extends StatelessWidget {
  CountryCodeDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CountryCodeProvider>(context, listen: false);
    print('provider ${provider}');
    final items = provider.items;

    // If you want to display different attribute in dropdown, replace `.mcLength` with `.mcName` or others.
    final values = items.where((e) => e.mcLength != null).toList();

    if (values.isEmpty) {
      return const Center(child: Text('No items with mc_length available'));
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: DropdownButtonFormField<int>(
        decoration: const InputDecoration(
          border: InputBorder.none,
          // remove default underline
        ),
        value: provider.selectedLength,
        isExpanded: true,
        items: values.map((e) {
          // Display: length on left, country name on right (you can change)
          final label = '${e.mcLength}';
          final subtitle = e.countryName ?? e.mcName;
          return DropdownMenuItem<int>(
            value: e.mcLength,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(subtitle ?? '', style: const TextStyle(fontSize: 14)),
              ],
            ),
          );
        }).toList(),
        onChanged: (newVal) {
          provider.setSelectedLength(newVal);
          // optionally do something else with the selection:
          final selected = provider.findByLength(newVal ?? -1);
          if (selected != null) {
            // example: print selected item
            debugPrint(
              'Selected: ${selected.mcName} (${selected.mcCountryCodeId})',
            );
          }
        },
        icon: const Icon(Icons.arrow_drop_down, size: 28),
      ),
    );
  }
}
