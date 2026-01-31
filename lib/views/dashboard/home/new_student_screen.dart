import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/models/country_codes.dart';
import 'package:melodica_app_new/models/student_models.dart';
import 'package:melodica_app_new/providers/student_provider.dart';
import 'package:melodica_app_new/routes/routes.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:melodica_app_new/utils/snacbar_utils.dart';
import 'package:melodica_app_new/views/dashboard/home/package_selection_screen.dart';
import 'package:melodica_app_new/views/dashboard/home/widget/custom_widget.dart';
import 'package:provider/provider.dart';

class NewStudentScreen extends StatefulWidget {
  // final bool isEdit;
  // final Student? student;

  const NewStudentScreen({super.key});

  @override
  State<NewStudentScreen> createState() => _NewStudentScreenState();
}

class _NewStudentScreenState extends State<NewStudentScreen> {
  String _selectedGender = '';
  String _selectedRelation = '';
  String _selectedLevel = '';
  bool? _isMelodicaStudent = true;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameCtrl = TextEditingController();
  final TextEditingController _lastNameCtrl = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _number = TextEditingController();

  @override
  void initState() {
    super.initState();

    /// 👇 PREFILL DATA IF EDIT MODE
    // if (widget.isEdit && widget.student != null) {
    //   final s = widget.student!;

    //   _firstNameCtrl.text = s.firstName;
    //   _lastNameCtrl.text = s.lastName;
    //   _email.text = s.email;
    //   _number.text = "";

    //   _selectedGender = s.gender;
    //   _selectedRelation = '';
    //   _selectedLevel = "";
    //   _isMelodicaStudent = s.isregistred == 'Yes';
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.lightGrey,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New Student',
          style: const TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  labelText: 'First Name',
                  controller: _firstNameCtrl,
                  suffixIcon: const Icon(
                    Icons.person_outline,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  labelText: 'Last Name',
                  controller: _lastNameCtrl,
                  suffixIcon: const Icon(
                    Icons.person_outline,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  labelText: 'Email',
                  controller: _email,
                  suffixIcon: const Icon(
                    Icons.email,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 20),

                CustomDropdownField<String>(
                  labelText: 'Gender',
                  value: _selectedGender,
                  items: const ['', 'Male', 'Female', 'Other'],
                  itemToString: (item) => item,
                  onChanged: (v) => setState(() => _selectedGender = v ?? ''),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 14.0),
                  child: Row(
                    children: [
                      Text(
                        "Number",
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Consumer<CustomerController>(
                  builder: (context, ctrl, child) {
                    // Convert to string to count digits
                    final int totalDigits =
                        ctrl.selectedCountry?.maxnumber ?? 0;

                    final int countryCodeDigits =
                        ctrl.selectedCountry?.callingCode.toString().length ??
                        0;

                    final int areaCodeDigits =
                        ctrl.selectedArea?.value.length ?? 0;
                    int phoneDigits =
                        totalDigits - countryCodeDigits - areaCodeDigits;

                    // 🛡 Safety guard
                    if (phoneDigits <= 0) {
                      phoneDigits = 1;
                    }

                    List<SelectedListItem<CountryCodeModel>> countryCodeItems =
                        ctrl.countryCodes.map((country) {
                          return SelectedListItem<CountryCodeModel>(
                            data: country, // keep the full model
                          );
                        }).toList();

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Country Dropdown
                        Expanded(
                          flex: 4,
                          child: GestureDetector(
                            onTap: () {
                              DropDownState<CountryCodeModel>(
                                dropDown: DropDown<CountryCodeModel>(
                                  listItemBuilder: (context, dataItem) {
                                    return ListTile(
                                      leading: Text(
                                        dataItem.data.name,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      // title: Text(dataItem.data.name),
                                    );
                                  },
                                  data: countryCodeItems,
                                  // countryCodeItems,
                                  /// Search by country name
                                  searchDelegate: (query, dataItems) {
                                    return dataItems
                                        .where(
                                          (item) => item.data.name
                                              .toLowerCase()
                                              .contains(query.toLowerCase()),
                                        )
                                        .toList();
                                  },

                                  /// title of the bottom sheet
                                  bottomSheetTitle: const Text(
                                    "Select Country Code",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),

                                  /// show search by default
                                  isSearchVisible: true,
                                  searchHintText: "Search Country",

                                  /// single selection
                                  enableMultipleSelection: false,

                                  onSelected: (List<dynamic> selectedList) {
                                    if (selectedList.isNotEmpty) {
                                      final selectedItem =
                                          selectedList.first
                                              as SelectedListItem<
                                                CountryCodeModel
                                              >;
                                      ctrl.selectedCountry = selectedItem
                                          .data; // ✅ this is CountryCodeModel
                                      ctrl.notifyListeners();
                                      setState(() {});
                                    }
                                  },
                                ),
                              ).showModal(context);
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Country Code',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      ctrl.selectedCountry != null
                                          ? '${ctrl.selectedCountry!.name} '
                                          : 'Country Codes',
                                      style: const TextStyle(fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),
                        //
                        // Area Code Dropdown
                        // if country code has some selected
                        Visibility(
                          visible:
                              ctrl.selectedCountry?.requiresAreaCode ?? false,
                          child: Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<AreaCodeModel>(
                              value: ctrl.selectedArea,
                              decoration: const InputDecoration(
                                labelText: 'Code',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 0,
                                  vertical: 12,
                                ),
                              ),
                              items: ctrl.areaCodes.map((a) {
                                return DropdownMenuItem(
                                  value: a,
                                  child: Text(a.value),
                                );
                              }).toList(),
                              onChanged: (val) {
                                ctrl.selectedArea = val;
                                ctrl.notifyListeners();
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Phone Number TextField
                        // Max lenght mc_length from api
                        Expanded(
                          flex: 5,
                          child: TextFormField(
                            controller: _number,
                            // maxLength: ctrl.selectedCountry?.maxnumber,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(phoneDigits),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 12,
                              ),
                            ),
                            validator: (value) {
                              if (value == null) return 'Invalid number';

                              final totalDigits =
                                  ctrl.selectedCountry!.maxnumber;

                              // Convert to string to count digits
                              final countryCodeDigits = ctrl
                                  .selectedCountry!
                                  .callingCode
                                  .toString()
                                  .length;

                              final areaCodeDigits = ctrl.allCountryCodes
                                  .toString()
                                  .length;
                              print('areaCodeDigits $areaCodeDigits');
                              final phoneDigits =
                                  totalDigits -
                                  countryCodeDigits -
                                  areaCodeDigits;

                              print('phoneDigits = $phoneDigits');

                              if (value.length != phoneDigits) {
                                return 'Enter a valid $phoneDigits digit number';
                              }

                              return null;
                            },

                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: CustomDropdownField<String>(
                        labelText: 'Relation',
                        value: _selectedRelation,
                        items: const ['', 'Mother', 'Father', 'Guardian'],
                        itemToString: (item) => item,
                        onChanged: (v) =>
                            setState(() => _selectedRelation = v ?? ''),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Expanded(
                    //   child: CustomDropdownField<String>(
                    //     labelText: 'Level',
                    //     value: _selectedLevel,
                    //     items: const ['', 'Beginner', 'Intermediate', 'Advanced'],
                    //     itemToString: (item) => item,
                    //     onChanged: (v) =>
                    //         setState(() => _selectedLevel = v ?? ''),
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 20),

                // Consumer<CustomerController>(
                //   builder: (context, ctrl, child) {
                //     return DropdownButtonFormField<CountryCodeModel>(
                //       value: ctrl.selectedCountry,
                //       decoration: const InputDecoration(
                //         labelText: 'AREA',
                //         border: OutlineInputBorder(),
                //       ),
                //       items: ctrl.countryCodes.map((c) {
                //         return DropdownMenuItem(
                //           value: c,
                //           child: Row(
                //             children: [
                //               Text(c.name.toString()),
                //               Text(c.callingCode.toString()),
                //             ],
                //           ),
                //         );
                //       }).toList(),
                //       onChanged: (val) {
                //         ctrl.selectedCountry = val;
                //         ctrl.notifyListeners();
                //       },
                //     );
                //   },
                // ),
                // Consumer<CustomerController>(
                //   builder: (context, ctrl, child) {
                //     return DropdownButtonFormField<AreaCodeModel>(
                //       value: ctrl.selectedArea,
                //       decoration: const InputDecoration(
                //         labelText: 'Code',
                //         border: OutlineInputBorder(),
                //       ),
                //       items: ctrl.areaCodes.map((a) {
                //         return DropdownMenuItem(value: a, child: Text(a.value));
                //       }).toList(),
                //       onChanged: (val) {
                //         ctrl.selectedArea = val;
                //         ctrl.notifyListeners();
                //       },
                //     );
                //   },
                // ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Have you been a Melodica student before?',
                      style: TextStyle(color: AppColors.secondaryText),
                    ),
                    Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: _isMelodicaStudent,
                          onChanged: (v) =>
                              setState(() => _isMelodicaStudent = v),
                          activeColor: AppColors.primary,
                        ),
                        const Text('Yes I am'),
                        const SizedBox(width: 20),
                        Radio<bool>(
                          value: false,
                          groupValue: _isMelodicaStudent,
                          onChanged: (v) =>
                              setState(() => _isMelodicaStudent = v),
                          activeColor: AppColors.primary,
                        ),
                        const Text('No I am new'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                /// 👇 SAME BUTTON FOR BOTH
                PrimaryButton(
                  child: _isLoading
                      ? CircularProgressIndicator(color: AppColors.black)
                      : Text(
                          'Next',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors
                                .darkText, // Text color is dark on yellow
                          ),
                        ),
                  text: '',
                  onPressed: _submitNew,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isLoading = false;
  Future<void> _submitNew() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGender.isEmpty || _selectedRelation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final ctrl = context.read<CustomerController>();
    await ctrl
        .upsertStudentProfile(
          context,
          firstname: _firstNameCtrl.text,
          lastname: _lastNameCtrl.text,
          email: _email.text,
          phone: _number.text,
          countryCode: "32",
          areaCode: "01",
          level: _selectedLevel,
          gender: _selectedGender,
          type: "New",
          existing: _isMelodicaStudent!, // 👈 NEW STUDENT
          clientId: ctrl.selectedStudent!.mbId.toString(),
        )
        .then((val) {
          if (val) {
            setState(() {
              _isLoading = false;
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PackageSelectionScreen(
                  isShowdanceTab: false,
                  iscomingFromNewStudent: true,
                ),
              ),
            );
            //  showSuccessDialog(context);
          } else {
            setState(() {
              _isLoading = false;
            });
            SnackbarUtils.showError(context, "Error!");
          }
        });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedGender.isEmpty ||
        _selectedRelation.isEmpty ||
        _selectedLevel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }
    print('_isMelodicaStudent ${_isMelodicaStudent}');
    setState(() {
      _isLoading = true;
    });
    final ctrl = context.read<CustomerController>();
    await ctrl
        .upsertStudentProfile(
          context,
          firstname: _firstNameCtrl.text,
          lastname: _lastNameCtrl.text,
          email: _email.text,
          phone: _number.text,
          countryCode: "971",
          areaCode: "52",
          level: _selectedLevel,
          existing: _isMelodicaStudent!,
          type: "Update",
          gender: _selectedGender,
          relationship: _selectedRelation,
          clientId: ctrl.selectedStudent!.mbId.toString(), // CREATE
        )
        .then((val) {
          if (val) {
            setState(() {
              _isLoading = false;
            });
            showSuccessDialog(context);
          } else {
            setState(() {
              _isLoading = false;
            });
            SnackbarUtils.showError(context, "Error!");
          }
        });

    // if (widget.isEdit)
  }
}

void showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Stack(
            children: [
              // Main Content
              Column(
                mainAxisSize: MainAxisSize.min, // Wrap content height
                children: [
                  const SizedBox(height: 10),

                  // Green Checkmark Icon
                  Container(
                    height: 45.h,
                    width: 45.w,
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF47C97E), width: 4),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.check,
                        size: 30.adaptSize,
                        color: Color(0xFF47C97E),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  Text(
                    "The new student has been added.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.fSize,
                      color: Color(0xff636363),
                    ),
                  ),
                  Text(
                    "This usually takes up to 24 hours.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.fSize,
                      color: Color(0xff636363),
                    ),
                  ),

                  SizedBox(height: 15.h),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        // AppColors.primary,
                        Color(0xFF47C97E),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.dashboard);
                    },
                    child: Text('Okay', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class DynamicMobileInput extends StatefulWidget {
  final Function(String fullNumber)? onNumberChanged;

  const DynamicMobileInput({super.key, this.onNumberChanged});

  @override
  State<DynamicMobileInput> createState() => _DynamicMobileInputState();
}

class _DynamicMobileInputState extends State<DynamicMobileInput> {
  // State variables based on the visual values
  String _selectedCountry = "ARE-971";
  String _selectedPrefix = "54";
  final TextEditingController _numberController = TextEditingController();

  // Mock data lists
  // final List<String> _countries = ["ARE-971", "SAU-966", "OMN-968", "QAT-974"];
  final List<String> _prefixes = ["50", "52", "54", "55", "56", "58"];

  void _notifyChange() {
    if (widget.onNumberChanged != null) {
      // Combines selections into a single string for your API
      widget.onNumberChanged!(
        "$_selectedCountry$_selectedPrefix${_numberController.text}",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Mobile Number", //
          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
        ),
        const SizedBox(height: 8),
        Container(
          height: 55,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[500]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // 1. Dynamic Country Dropdown
              _buildDropdownSection(width: 90, child: Text('ARE-971')),

              // 2. Dynamic Prefix Dropdown
              _buildDropdownSection(
                width: 70,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPrefix,
                    icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                    items: _prefixes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() => _selectedPrefix = newValue!);
                      _notifyChange();
                    },
                  ),
                ),
              ),

              // 3. Phone Number Input
              Expanded(
                child: TextField(
                  controller: _numberController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _notifyChange(),
                  decoration: InputDecoration(
                    hintText: "2176521", //
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper to build the bordered sections for the dropdowns
  Widget _buildDropdownSection({required double width, required Widget child}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Color(0xFFD1D5DB))),
      ),
      child: child,
    );
  }
}
