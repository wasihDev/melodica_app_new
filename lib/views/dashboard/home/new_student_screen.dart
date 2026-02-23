import 'package:country_flags/country_flags.dart';
import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/models/country_codes.dart';
import 'package:melodica_app_new/models/student_models.dart';
import 'package:melodica_app_new/providers/services_provider.dart';
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
  // String _selectedGender = '';
  // String _selectedRelation = '';
  // String _selectedLevel = '';
  // bool? _isMelodicaStudent = true;

  final _formKey = GlobalKey<FormState>();

  // final TextEditingController firstNameCtrl = TextEditingController();
  // final TextEditingController lastNameCtrl = TextEditingController();
  // final TextEditingController email = TextEditingController();
  // final TextEditingController number = TextEditingController();

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

  DateTime? _selectedDate;
  final TextEditingController _dobController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ?? DateTime(2000), // Default to a sensible adult age
      firstDate: DateTime(1920), // Earliest possible birth year
      lastDate: DateTime.now(), // Cannot be born in the future
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(
                0xFFFFD152,
              ), // Matches your app's yellow/primary color
              onPrimary: Colors.black,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Formatting the date to show in the text field
        _dobController.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  Widget flagFromModel(CountryCodeModel model) {
    // "AFG-93" → "AFG"
    final alpha3 = model.name.split('-').first;

    final alpha2 = alpha3ToAlpha2[alpha3] ?? "US";

    return CountryFlag.fromCountryCode(alpha2);
  }

  // Widget flagFromApiName(String mcName) {
  //   // Example: "AFG-93" → "AFG"
  //   final alpha3 = mcName.split('-').first;

  //   final country = CountryCodeModel.detailsForCountry(alpha3);

  //   final alpha2 = country?.alpha2Code ?? "US";

  //   return CountryFlag.fromCountryCode(alpha2);
  // }

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
          padding: const EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: Consumer<CustomerController>(
              builder: (context, ctrl, child) {
                return Column(
                  children: [
                    CustomTextField(
                      labelText: 'First Name',
                      controller: ctrl.firstNameCtrl,
                      suffixIcon: const Icon(
                        Icons.person_outline,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 20),

                    CustomTextField(
                      labelText: 'Last Name',
                      controller: ctrl.lastNameCtrl,
                      suffixIcon: const Icon(
                        Icons.person_outline,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 20),

                    CustomTextField(
                      labelText: 'Email',
                      controller: ctrl.emailCtrl,
                      suffixIcon: const Icon(
                        Icons.email,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 20),

                    CustomDropdownField<String>(
                      labelText: 'Gender',
                      value: ctrl.selectedGender.isEmpty
                          ? null
                          : ctrl.selectedGender,
                      items: const ['Male', 'Female', 'Other'],
                      itemToString: (item) => item,
                      onChanged: (v) {
                        if (v == null) return;
                        ctrl.setGender(v);
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0, bottom: 5.0),
                      child: Row(
                        children: [
                          Text(
                            "Date of Time",
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextFormField(
                      controller: _dobController,
                      readOnly: true, // Prevents the keyboard from appearing
                      onTap: () => _selectDate(context),
                      decoration: InputDecoration(
                        hintText: "Select your birth date",
                        prefixIcon: const Icon(
                          Icons.calendar_today,
                          color: Colors.grey,
                        ),
                        suffixIcon: const Icon(Icons.arrow_drop_down),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
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
                            ctrl.selectedCountry?.callingCode
                                .toString()
                                .length ??
                            0;

                        final int areaCodeDigits =
                            ctrl.selectedArea?.value.length ?? 0;
                        int phoneDigits =
                            totalDigits - countryCodeDigits - areaCodeDigits;

                        // 🛡 Safety guard
                        if (phoneDigits <= 0) {
                          phoneDigits = 1;
                        }

                        List<SelectedListItem<CountryCodeModel>>
                        countryCodeItems = ctrl.countryCodes.map((country) {
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
                                          //  if (ctrl.selectedCountry != null)
                                          leading: flagFromModel(dataItem.data),
                                          title: Text(
                                            dataItem.data.name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),

                                          // title: Text(dataItem.data.name),
                                        );
                                      },
                                      data: countryCodeItems,
                                      // countryCodeItems,
                                      /// Search by country name
                                      searchDelegate: (query, dataItems) {
                                        final lowercaseQuery = query
                                            .toLowerCase();

                                        return dataItems.where((item) {
                                          // Search in the full Country Name (e.g., Afghanistan)
                                          final matchesCountry = item
                                              .data
                                              .countryName
                                              .toLowerCase()
                                              .contains(lowercaseQuery);

                                          final matchesShortName = item
                                              .data
                                              .name
                                              .toLowerCase()
                                              .contains(lowercaseQuery);

                                          return matchesCountry ||
                                              matchesShortName;
                                        }).toList();
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
                                    labelText: 'Country Codes',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 10,
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
                                          style: TextStyle(fontSize: 12.fSize),
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
                                  ctrl.selectedCountry?.requiresAreaCode ??
                                  false,
                              child: Expanded(
                                flex: 4,
                                child: DropdownButtonFormField<AreaCodeModel>(
                                  value:
                                      ctrl.areaCodes.contains(ctrl.selectedArea)
                                      ? ctrl.selectedArea
                                      : null,
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
                                      child: Text(
                                        a.value,
                                        style: TextStyle(fontSize: 12.fSize),
                                      ),
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
                                controller: ctrl.phoneCtrl,
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
                            value: ctrl.selectedRelation,
                            items: const ['', 'Mother', 'Father', 'Guardian'],
                            itemToString: (item) => item,
                            onChanged: (v) =>
                                setState(() => ctrl.setRelation(v!)),
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
                              groupValue: ctrl.isMelodicaStudent,
                              onChanged: (v) => ctrl.setIsMelodicaStudent(v!),
                            ),
                            const Text('Yes I am'),
                            const SizedBox(width: 20),
                            Radio<bool>(
                              value: false,
                              groupValue: ctrl.isMelodicaStudent,
                              onChanged: (v) => ctrl.setIsMelodicaStudent(v!),
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
                      onPressed: () => _submitNew(ctrl),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  bool _isLoading = false;
  Future<void> _submitNew(CustomerController ctrls) async {
    if (!_formKey.currentState!.validate()) return;
    if (ctrls.selectedGender.isEmpty || ctrls.selectedRelation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    // final ctrl = context.read<CustomerController>();
    final serviceCtrl = context.read<ServicesProvider>();
    await ctrls
        .upsertStudentProfile(
          context,
          firstname: ctrls.firstNameCtrl.text,
          lastname: ctrls.lastNameCtrl.text,
          email: ctrls.emailCtrl.text,
          phone: ctrls.phoneCtrl.text,
          countryCode: " ${ctrls.selectedArea}",
          areaCode: "${ctrls.areaCodes}",
          level: ctrls.selectedLevel,
          gender: ctrls.selectedGender,
          type: "New",
          dateofbirth: _dobController.text,
          existing: ctrls.isMelodicaStudent!, // 👈 NEW STUDENT
          clientId: "",
          // ctrls.selectedStudent!.mbId.toString(),
        )
        .then((val) {
          if (val) {
            setState(() {
              _isLoading = false;
            });
            serviceCtrl.isStudentNew = true;

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

  // Future<void> _submit() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   if (_selectedGender.isEmpty ||
  //       _selectedRelation.isEmpty ||
  //       _selectedLevel.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please complete all required fields')),
  //     );
  //     return;
  //   }
  //   print('_isMelodicaStudent ${_isMelodicaStudent}');
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   final ctrl = context.read<CustomerController>();
  //   await ctrl
  //       .upsertStudentProfile(
  //         context,
  //         firstname: _firstNameCtrl.text,
  //         lastname: _lastNameCtrl.text,
  //         email: _email.text,
  //         phone: _number.text,
  //         countryCode: "971",
  //         areaCode: "52",
  //         level: _selectedLevel,
  //         existing: _isMelodicaStudent!,
  //         type: "Update",
  //         gender: _selectedGender,
  //         relationship: _selectedRelation,
  //         clientId: ctrl.selectedStudent!.mbId.toString(), // CREATE
  //       )
  //       .then((val) {
  //         if (val) {
  //           setState(() {
  //             _isLoading = false;
  //           });
  //           showSuccessDialog(context);
  //         } else {
  //           setState(() {
  //             _isLoading = false;
  //           });
  //           SnackbarUtils.showError(context, "Error!");
  //         }
  //       });

  //   // if (widget.isEdit)
  // }
  Map<String, String> alpha3ToAlpha2 = {
    "AFG": "AF",
    "ALA": "AX",
    "ALB": "AL",
    "DZA": "DZ",
    "ASM": "AS",
    "AND": "AD",
    "AGO": "AO",
    "AIA": "AI",
    "ATA": "AQ",
    "ATG": "AG",
    "ARG": "AR",
    "ARM": "AM",
    "ABW": "AW",
    "AUS": "AU",
    "AUT": "AT",
    "AZE": "AZ",
    "BHS": "BS",
    "BHR": "BH",
    "BGD": "BD",
    "BRB": "BB",
    "BLR": "BY",
    "BEL": "BE",
    "BLZ": "BZ",
    "BEN": "BJ",
    "BMU": "BM",
    "BTN": "BT",
    "BOL": "BO",
    "BES": "BQ",
    "BIH": "BA",
    "BWA": "BW",
    "BVT": "BV",
    "BRA": "BR",
    "IOT": "IO",
    "BRN": "BN",
    "BGR": "BG",
    "BFA": "BF",
    "BDI": "BI",
    "CPV": "CV",
    "KHM": "KH",
    "CMR": "CM",
    "CAN": "CA",
    "CYM": "KY",
    "CAF": "CF",
    "TCD": "TD",
    "CHL": "CL",
    "CHN": "CN",
    "CXR": "CX",
    "CCK": "CC",
    "COL": "CO",
    "COM": "KM",
    "COG": "CG",
    "COD": "CD",
    "COK": "CK",
    "CRI": "CR",
    "CIV": "CI",
    "HRV": "HR",
    "CUB": "CU",
    "CUW": "CW",
    "CYP": "CY",
    "CZE": "CZ",
    "DNK": "DK",
    "DJI": "DJ",
    "DMA": "DM",
    "DOM": "DO",
    "ECU": "EC",
    "EGY": "EG",
    "SLV": "SV",
    "GNQ": "GQ",
    "ERI": "ER",
    "EST": "EE",
    "SWZ": "SZ",
    "ETH": "ET",
    "FLK": "FK",
    "FRO": "FO",
    "FJI": "FJ",
    "FIN": "FI",
    "FRA": "FR",
    "GUF": "GF",
    "PYF": "PF",
    "ATF": "TF",
    "GAB": "GA",
    "GMB": "GM",
    "GEO": "GE",
    "DEU": "DE",
    "GHA": "GH",
    "GIB": "GI",
    "GRC": "GR",
    "GRL": "GL",
    "GRD": "GD",
    "GLP": "GP",
    "GUM": "GU",
    "GTM": "GT",
    "GGY": "GG",
    "GIN": "GN",
    "GNB": "GW",
    "GUY": "GY",
    "HTI": "HT",
    "HMD": "HM",
    "VAT": "VA",
    "HND": "HN",
    "HKG": "HK",
    "HUN": "HU",
    "ISL": "IS",
    "IND": "IN",
    "IDN": "ID",
    "IRN": "IR",
    "IRQ": "IQ",
    "IRL": "IE",
    "IMN": "IM",
    "ISR": "IL",
    "ITA": "IT",
    "JAM": "JM",
    "JPN": "JP",
    "JEY": "JE",
    "JOR": "JO",
    "KAZ": "KZ",
    "KEN": "KE",
    "KIR": "KI",
    "PRK": "KP",
    "KOR": "KR",
    "KWT": "KW",
    "KGZ": "KG",
    "LAO": "LA",
    "LVA": "LV",
    "LBN": "LB",
    "LSO": "LS",
    "LBR": "LR",
    "LBY": "LY",
    "LIE": "LI",
    "LTU": "LT",
    "LUX": "LU",
    "MAC": "MO",
    "MDG": "MG",
    "MWI": "MW",
    "MYS": "MY",
    "MDV": "MV",
    "MLI": "ML",
    "MLT": "MT",
    "MHL": "MH",
    "MTQ": "MQ",
    "MRT": "MR",
    "MUS": "MU",
    "MYT": "YT",
    "MEX": "MX",
    "FSM": "FM",
    "MDA": "MD",
    "MCO": "MC",
    "MNG": "MN",
    "MNE": "ME",
    "MSR": "MS",
    "MAR": "MA",
    "MOZ": "MZ",
    "MMR": "MM",
    "NAM": "NA",
    "NRU": "NR",
    "NPL": "NP",
    "NLD": "NL",
    "NCL": "NC",
    "NZL": "NZ",
    "NIC": "NI",
    "NER": "NE",
    "NGA": "NG",
    "NIU": "NU",
    "NFK": "NF",
    "MKD": "MK",
    "MNP": "MP",
    "NOR": "NO",
    "OMN": "OM",
    "PAK": "PK",
    "PLW": "PW",
    "PSE": "PS",
    "PAN": "PA",
    "PNG": "PG",
    "PRY": "PY",
    "PER": "PE",
    "PHL": "PH",
    "PCN": "PN",
    "POL": "PL",
    "PRT": "PT",
    "PRI": "PR",
    "QAT": "QA",
    "REU": "RE",
    "ROU": "RO",
    "RUS": "RU",
    "RWA": "RW",
    "BLM": "BL",
    "SHN": "SH",
    "KNA": "KN",
    "LCA": "LC",
    "MAF": "MF",
    "SPM": "PM",
    "VCT": "VC",
    "WSM": "WS",
    "SMR": "SM",
    "STP": "ST",
    "SAU": "SA",
    "SEN": "SN",
    "SRB": "RS",
    "SYC": "SC",
    "SLE": "SL",
    "SGP": "SG",
    "SXM": "SX",
    "SVK": "SK",
    "SVN": "SI",
    "SLB": "SB",
    "SOM": "SO",
    "ZAF": "ZA",
    "SGS": "GS",
    "SSD": "SS",
    "ESP": "ES",
    "LKA": "LK",
    "SDN": "SD",
    "SUR": "SR",
    "SJM": "SJ",
    "SWE": "SE",
    "CHE": "CH",
    "SYR": "SY",
    "TWN": "TW",
    "TJK": "TJ",
    "TZA": "TZ",
    "THA": "TH",
    "TLS": "TL",
    "TGO": "TG",
    "TKL": "TK",
    "TON": "TO",
    "TTO": "TT",
    "TUN": "TN",
    "TUR": "TR",
    "TKM": "TM",
    "TCA": "TC",
    "TUV": "TV",
    "UGA": "UG",
    "UKR": "UA",
    "ARE": "AE",
    "UAE": "AE",
    "GBR": "GB",
    "USA": "US",
    "URY": "UY",
    "UZB": "UZ",
    "VUT": "VU",
    "VEN": "VE",
    "VNM": "VN",
    "VGB": "VG",
    "VIR": "VI",
    "WLF": "WF",
    "ESH": "EH",
    "YEM": "YE",
    "ZMB": "ZM",
    "ZWE": "ZW",
  };
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
