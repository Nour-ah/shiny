// screens/filter/component/filter_age_type_component.dart
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../app_theme.dart';
import '../../../locale/app_localizations.dart';
import '../../../main.dart';
import '../../../utils/common.dart';
import '../../../utils/constant.dart';
import '../../../utils/images.dart';

class FilterAgeTypeComponent extends StatefulWidget {
  const FilterAgeTypeComponent({super.key});

  @override
  State<FilterAgeTypeComponent> createState() => _FilterAgeTypeComponentState();
}

class _FilterAgeTypeComponentState extends State<FilterAgeTypeComponent> {
  DateTime? selectedDate;
  String selectedGender = "male";
  DateTime currentDateTime = DateTime.now();

  void selectDate(BuildContext context) async {
    await showDatePicker(
      context: context,
      initialDate: selectedDate ?? currentDateTime,
      firstDate: currentDateTime.subtract(Duration(days: 365 * 50)),
      lastDate: currentDateTime,
      locale: Locale(appStore.selectedLanguageCode),
      cancelText: language.lblCancel,
      confirmText: language.lblOk,
      helpText: language.lblSelectDate,
      builder: (_, child) {
        return Theme(
          data: appStore.isDarkMode ? ThemeData.dark() : AppTheme.lightTheme(),
          child: child!,
        );
      },
    ).then((date) async {
      if (date != null) {
        selectedDate = date;
        setState(() {});
      }
    });
  }

  int selectedIndex = 0;
  void selectGender(int index) async {
    setState(() {
      if (index == 0) {
        selectedGender = "male";
        selectedIndex = index;
      } else {
        selectedGender = "female";
        selectedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        selectedDate == null
            ? GestureDetector(
                onTap: () async {
                  selectDate(context);
                },
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: DottedBorderWidget(
                    color: context.primaryColor,
                    radius: defaultRadius,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      height: 150,
                      alignment: Alignment.center,
                      decoration: boxDecorationWithShadow(
                          blurRadius: 0,
                          backgroundColor: context.cardColor,
                          borderRadius: radius()),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ic_calendar.iconImage(size: 26),
                          8.height,
                          Text(language.chooseDateTime,
                              style: secondaryTextStyle()),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : Padding(
                padding: EdgeInsets.all(8.0),
                child: DottedBorderWidget(
                  color: context.primaryColor,
                  radius: defaultRadius,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    height: 100,
                    decoration: boxDecorationDefault(color: context.cardColor),
                    width: context.width(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text("${language.lblDate}: ",
                                    style: secondaryTextStyle()),
                                Text(
                                    formatBookingDate(
                                        selectedDate!.toIso8601String(),
                                        format: DATE_FORMAT_3),
                                    style: boldTextStyle(size: 12)),
                              ],
                            ),
                            8.height,
                          ],
                        ),
                        IconButton(
                          icon: ic_edit_square.iconImage(size: 18),
                          visualDensity: VisualDensity.compact,
                          onPressed: () async {
                            selectDate(context);
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: DottedBorderWidget(
            color: context.primaryColor,
            radius: defaultRadius,
            child: Container(
              height: 150,
              child: Row(
                children: List.generate(
                  2,
                  (index) => Expanded(
                    child: InkWell(
                      onTap: () {
                        selectGender(index);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadiusDirectional.horizontal(
                            start: index == 0
                                ? Radius.circular(defaultRadius)
                                : Radius.zero,
                            end: index == 1
                                ? Radius.circular(defaultRadius)
                                : Radius.zero,
                          ),
                          color: (selectedIndex == 0 && index == 0)
                              ? context.primaryColor
                              : (selectedIndex == 1 && index == 1)
                                  ? Colors.pinkAccent
                                  : Colors.transparent,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              selectedIndex == 0 ? Icons.male : Icons.female,
                              size: 50,
                              color: context.cardColor,
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              selectedGender,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: context.cardColor,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class FilterDropdownComponent extends StatelessWidget {
  final String? selectedAgeRange;
  final String? selectedGender;
  final Function(String?) onAgeChanged;
  final Function(String?) onGenderChanged;

  final List<String> ageRanges = ["18-25", "26-35", "36-50", "50+"];

  FilterDropdownComponent({
    required this.selectedAgeRange,
    required this.selectedGender,
    required this.onAgeChanged,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, String> genderOptions = {
      "Male": language.male,
      "Female": language.female,
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DropdownButton<String>(
          value: selectedAgeRange,
          hint: Text(
            language.selectAge,
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color),
          ),
          items: ageRanges.map((String age) {
            return DropdownMenuItem<String>(
              value: age,
              child: Text(
                age,
                style: TextStyle(color: Colors.grey),
              ),
            );
          }).toList(),
          onChanged: onAgeChanged,
        ),
        DropdownButton<String>(
          value: selectedGender,
          hint: Text(
            language.selectGender,
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color),
          ),
          items: genderOptions.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(
                entry.value,
                style: TextStyle(color: Colors.grey),
                //style: TextStyle(
                //    color: Theme.of(context).textTheme.bodyLarge!.color),
              ),
            );
          }).toList(),
          onChanged: onGenderChanged,
        ),
      ],
    );
  }
}
