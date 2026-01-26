import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/providers/auth_provider.dart';
import 'package:melodica_app_new/providers/country_code_provider.dart';
import 'package:melodica_app_new/providers/user_profile_provider.dart';
import 'package:melodica_app_new/views/dashboard/home/package_selection_screen.dart';
import 'package:melodica_app_new/views/dashboard/home/widget/custom_widget.dart';
import 'package:melodica_app_new/views/profile/widget/number_dropdown.dart';
import 'package:melodica_app_new/widgets/custom_appbar.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // String _selectedGender = 'Male';
  // String _selectedRelation = 'Mother';
  // String _selectedLevel = 'Beginner';
  bool? _isMelodicaStudent = true; // true for 'Yes', false for 'No'
  late TextEditingController _areaController;
  late TextEditingController _phoneController;
  String _countryCode = '54';

  final _formKey = GlobalKey<FormState>();

  // controllers
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  String _gender = 'Male';
  String _dob = '';
  String _relation = 'Mother';
  String _level = 'Beginner';
  bool _existingStudent = false;

  bool _loading = false;

  @override
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<UserprofileProvider>(context, listen: false);
    final model = provider.userModel;
    print('model ${model.firstName}');
    if (model != null) {
      _first.text = (_first.text.isEmpty ? model.firstName : _first.text) ?? "";
      _last.text = (_last.text.isEmpty ? model.lastName : _last.text) ?? "";
      _email.text = (_email.text.isEmpty ? model.email : _email.text) ?? "";
      _phone.text =
          (_phone.text.isEmpty ? model.phoneNumber : _phone.text) ?? "";

      _gender = (model.gender != null && model.gender!.isNotEmpty)
          ? model.gender!
          : _gender;

      _dob = (model.dateOfBirth != null && model.dateOfBirth!.isNotEmpty)
          ? model.dateOfBirth!
          : _dob;

      _relation = (model.relation != null && model.relation!.isNotEmpty)
          ? model.relation!
          : _relation;

      _level = (model.level != null && model.level!.isNotEmpty)
          ? model.level!
          : _level;

      _existingStudent = model.isPreviousStudent ?? false;
    }
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final data = {
        'firstName': _first.text.trim(),
        'lastName': _last.text.trim(),
        'email': _email.text.trim(),
        'phoneNumber': _phone.text.trim(), // updated
        "phoneCode": _countryCode,
        'gender': _gender,
        'dateOfBirth': _dob, // updated key
        'relation': _relation,
        'level': _level,
        'isPreviousStudent': _existingStudent, // updated key
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await Provider.of<UserprofileProvider>(
        context,
        listen: false,
      ).updateUserData(context, data: data);
    } catch (e) {
      print('error $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();

    _areaController = TextEditingController();
    _phoneController = TextEditingController();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2004, 2, 8), // Matching screenshot
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary, // header background color
              onPrimary: AppColors.darkText, // header text color
              onSurface: AppColors.darkText, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      String onlyDate =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";

      setState(() {
        _dob = onlyDate;
      });
      print('_dob $_dob');
      // Handle the picked date
      print('Selected date: ${picked.toLocal()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: 'Edit Profile', isShowLogout: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Consumer<UserprofileProvider>(
              builder: (context, provider, child) {
                return InkWell(
                  onTap: () {
                    provider.pickImage(context);
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 3),
                    ),
                    child: ClipOval(
                      child: provider.uint8list == null
                          ? Image.network(
                              'https://cdn-icons-png.flaticon.com/512/219/219983.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: AppColors.secondaryText,
                                  ),
                            )
                          : Image.memory(provider.uint8list!),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // First Name
            CustomTextField(
              labelText: 'First Name',
              initialValue: _first.text,
              controller: _first,
              suffixIcon: Icon(
                Icons.person_outline,
                color: AppColors.secondaryText,
              ), // User icon
            ),
            const SizedBox(height: 20),

            // Last Name
            CustomTextField(
              labelText: 'Last Name',
              initialValue: _last.text,
              controller: _last,
              suffixIcon: Icon(
                Icons.person_outline,
                color: AppColors.secondaryText,
              ), // User icon
            ),
            const SizedBox(height: 20),
            CustomTextField(
              labelText: 'Email',
              initialValue: _email.text,
              readOnly: true,
              suffixIcon: Icon(
                Icons.email,
                color: AppColors.secondaryText,
              ), // User icon
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text(
                  'Phone Number',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  // flex: 3,
                  child: _smallTile(
                    child: TextFormField(
                      controller: _areaController,
                      decoration: InputDecoration(
                        hint: Text('AREA - 971'),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  // flex: 1,
                  child:
                      // CountryCodeDropdown(),
                      _smallTile(
                        child: DropdownButtonFormField<String>(
                          value: _countryCode,
                          items: ['971', '54', "231"]
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _countryCode = v ?? _countryCode),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  // flex: 4,
                  child: _smallTile(
                    child: TextFormField(
                      controller: _phone,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: _phone.text,
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Date of Birth & Gender
            Row(
              children: [
                // Expanded(
                //   child: CustomTextField(
                //     labelText: 'Date of Birth',
                //     initialValue: _dob,
                //     // controller: ,
                //     readOnly: true,
                //     onTap: () => _selectDate(context),
                //     suffixIcon: SvgPicture.asset(
                //       'assets/svg/schedule.svg',
                //       width: 24,
                //       height: 24,
                //     ), // Calendar icon
                //   ),
                // ),
                // const SizedBox(width: 16),
                Expanded(
                  child: CustomDropdownField<String>(
                    labelText: 'Gender',
                    value: _gender,
                    items: const ['Male', 'Female', 'Other'],
                    itemToString: (item) => item,
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          _gender = newValue;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Relation & Level
            Row(
              children: [
                Expanded(
                  child: CustomDropdownField<String>(
                    labelText: 'Relation',
                    value: _relation,
                    items: const ['Mother', 'Father', 'Guardian'],
                    itemToString: (item) => item,
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          _relation = newValue;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomDropdownField<String>(
                    labelText: 'Level',
                    value: _level,
                    items: const ['Beginner', 'Intermediate', 'Advanced'],
                    itemToString: (item) => item,
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          _level = newValue;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Radio Buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Have you been a Melodica student before?',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: _existingStudent,
                      onChanged: (value) {
                        setState(() {
                          _existingStudent = value!;
                        });
                      },
                      activeColor: AppColors.primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const Text(
                      'Yes i am',
                      style: TextStyle(color: AppColors.darkText),
                    ),
                    const SizedBox(width: 24),
                    Radio<bool>(
                      value: false,
                      groupValue: _existingStudent,
                      onChanged: (value) {
                        setState(() {
                          _existingStudent = value!;
                        });
                      },
                      activeColor: AppColors.primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const Text(
                      'No I am new',
                      style: TextStyle(color: AppColors.darkText),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Next Button
            PrimaryButton(
              text: _loading ? "loading..." : 'Save',
              onPressed: () async {
                print('Next button pressed on New Student screen!');
                await _save();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _styledTextField({
    required TextEditingController controller,
    required String hint,
    IconData? prefixIcon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration.collapsed(hintText: hint),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
          ),
          if (prefixIcon != null) Icon(prefixIcon),
        ],
      ),
    );
  }

  Widget _smallTile({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.secondaryText),
      ),
      child: child,
    );
  }
}
