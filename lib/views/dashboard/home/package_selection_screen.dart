import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/views/dashboard/home/checkout/checkout_screen.dart';
import 'package:melodica_app_new/views/dashboard/home/widget/custom_widget.dart';

class PackageSelectionScreen extends StatefulWidget {
  const PackageSelectionScreen({super.key});

  @override
  State<PackageSelectionScreen> createState() => _PackageSelectionScreenState();
}

class _PackageSelectionScreenState extends State<PackageSelectionScreen> {
  String _selectedCategory = 'Music'; // 'Music' or 'Dance'
  String _selectedCourse = 'Piano';
  String _selectedDuration = '30 Min';
  String? _selectedPackageId;

  // --- Data for Music Tab ---
  final List<Map<String, String>> _musicPackages = const [
    {
      'id': 'm_1',
      'title': 'Silver Package',
      'unit': '12 Classes',
      'details': 'Cancellation -- 2Times\nFreezing ------ 1 Week',
      'price': '₫ 1,620',
      'perClass': '150 per Class',
    },
    {
      'id': 'm_2',
      'title': 'Silver Package',
      'unit': '12 Classes',
      'details': 'Cancellation -- 2Times\nFreezing ------ 1 Week',
      'price': '₫ 1,620',
      'perClass': '150 per Class',
    },
    {
      'id': 'm_3',
      'title': 'Silver Package',
      'unit': '12 Classes',
      'details': 'Cancellation -- 2Times\nFreezing ------ 1 Week',
      'price': '₫ 1,620',
      'perClass': '150 per Class',
    },
  ];

  // --- Data for Dance Tab ---
  final List<Map<String, String>> _dancePackages = const [
    {
      'id': 'd_1',
      'title': 'Silver Package',
      'unit': '4 Weeks',
      'details': 'Cancellation -- 2Times\nFreezing ------ 1 Week',
      'price': '₫ 1,620',
      'perClass': '150 per Class',
    },
    {
      'id': 'd_2',
      'title': 'Silver Package',
      'unit': '7 Weeks',
      'details': 'Cancellation -- 2Times\nFreezing ------ 1 Week',
      'price': '₫ 1,620',
      'perClass': '150 per Class',
    },
    {
      'id': 'd_3',
      'title': 'Silver Package',
      'unit': '12 Weeks',
      'details': 'Cancellation -- 2Times\nFreezing ------ 1 Week',
      'price': '₫ 1,620',
      'perClass': '150 per Class',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Package Selection',
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/svg/exit.svg',
              width: 24,
              height: 24,
            ),
            onPressed: () {
              // Handle forward action
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Music/Dance Toggle
                  Row(
                    children: [
                      _buildToggleButton('Music', _selectedCategory == 'Music'),
                      const SizedBox(width: 16),
                      _buildToggleButton('Dance', _selectedCategory == 'Dance'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Conditional Content based on selected category
                  _selectedCategory == 'Music'
                      ? _buildMusicContent()
                      : _buildDanceContent(),
                ],
              ),
            ),
          ),
          // Next Button at the bottom
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: PrimaryButton(
              text: 'Next',
              onPressed: () {
                print('Next button pressed on Package Selection screen!');
                print('Selected package ID: $_selectedPackageId');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CheckoutScreen(),
                  ),
                );
                // Handle navigation or form submission
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMusicContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Select Course Dropdown (Music specific)
        CustomDropdownField<String>(
          labelText: 'Select Course',
          value: _selectedCourse,
          items: const ['Piano', 'Guitar', 'Violin', 'Drums'],
          itemToString: (item) => item,
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                _selectedCourse = newValue;
              });
            }
          },
        ),
        const SizedBox(height: 24),

        // Duration Buttons
        Row(
          children: [
            _buildDurationButton('30 Min'),
            const SizedBox(width: 16),
            _buildDurationButton('45 Min'),
            const SizedBox(width: 16),
            _buildDurationButton('60 Min'),
          ],
        ),
        const SizedBox(height: 24),

        // Package Cards
        ..._musicPackages
            .map(
              (pkg) => Column(
                children: [
                  _buildPackageCard(
                    id: pkg['id']!,
                    title: pkg['title']!,
                    unit: pkg['unit']!,
                    details: pkg['details']!,
                    price: pkg['price']!,
                    pricePerClass: pkg['perClass']!,
                    isMusic: true, // Use music card style
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildDanceContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Course we offer',
          style: TextStyle(fontSize: 14, color: AppColors.secondaryText),
        ),
        const SizedBox(height: 4),
        const Text(
          'Ballet, Hip Hop, Contemporary & Belly Dance',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 24),

        // Package Cards (Dance specific)
        ..._dancePackages
            .map(
              (pkg) => Column(
                children: [
                  _buildPackageCard(
                    id: pkg['id']!,
                    title: pkg['title']!,
                    unit: pkg['unit']!,
                    details: pkg['details']!,
                    price: pkg['price']!,
                    pricePerClass: pkg['perClass']!,
                    isMusic: false, // Use dance card style
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildToggleButton(String text, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = text;
            _selectedPackageId = null; // Clear package selection on tab change
          });
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(25),
            border: isSelected
                ? Border.all(color: AppColors.primary, width: 2)
                : Border.all(color: AppColors.secondaryText),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.darkText,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDurationButton(String text) {
    bool isSelected = _selectedDuration == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDuration = text;
        });
      },
      child: Container(
        width: 100, // Fixed width for duration buttons
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(25),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : Border.all(color: AppColors.secondaryText),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.darkText,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPackageCard({
    required String id,
    required String title,
    required String unit, // Will be Classes for music, Weeks for dance
    required String details,
    required String price,
    required String pricePerClass,
    required bool isMusic, // New flag to determine layout
  }) {
    bool isSelected = _selectedPackageId == id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPackageId = id;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : Border.all(color: AppColors.secondaryText.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      // Conditional text size/content based on Music/Dance
                      Text(
                        unit,
                        style: TextStyle(
                          fontSize: isMusic
                              ? 18
                              : 16, // Classes is slightly bigger font
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        details,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 20% OFF tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '20%\nOFF',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Price
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    // Price per class/unit (only show if not a simple week package)
                    if (isMusic) // Only show 150 per class for music, based on screenshot difference
                      Text(
                        pricePerClass,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText,
                        ),
                      ),
                  ],
                ),
                // Radio Button
                Radio<String>(
                  value: id,
                  groupValue: _selectedPackageId,
                  onChanged: (value) {
                    setState(() {
                      _selectedPackageId = value;
                    });
                  },
                  activeColor: AppColors.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
