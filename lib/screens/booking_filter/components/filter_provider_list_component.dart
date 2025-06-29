// screens/booking_filter/components/filter_provider_list_component.dart
import 'package:booking_system_flutter/screens/filter/component/filter_age_type_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/empty_error_state_widget.dart';
import '../../../component/image_border_component.dart';
import '../../../component/loader_widget.dart';
import '../../../component/selected_item_widget.dart';
import '../../../main.dart';
import '../../../model/user_data_model.dart';
import '../../../network/rest_apis.dart';
import '../../../utils/constant.dart';

class FilterProviderListComponent extends StatefulWidget {
  @override
  State<FilterProviderListComponent> createState() =>
      _FilterProviderListComponentState();
}

class _FilterProviderListComponentState
    extends State<FilterProviderListComponent> {
  Future<List<UserData>>? future;
  List<UserData> providerList = [];
  int page = 1;
  bool isLastPage = false;
  //editing
  String? selectedGender;
  String? selectedAgeRange;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    future = getHandymanediting(
      page: page,
      list: providerList,
      userTypeHandyman: USER_TYPE_PROVIDER,
      gender: selectedGender,
      ageRange: selectedAgeRange,
      lastPageCallback: (b) {
        isLastPage = b;
      },
    );
  }

  // void applyFilters() {
  //   setState(() {
  //     providerList = providerList.where((provider) {
  //       bool matchesGender =
  //           selectedGender == null || provider.gender == selectedGender;
  //       bool matchesAge = selectedAgeRange == null ||
  //           (provider.age != null &&
  //               checkAgeRange(provider.age!, selectedAgeRange!));
  //       ;
  //       return matchesGender && matchesAge;
  //     }).toList();
  //   });
  // }

  // // bool checkAgeRange(int age, String range) {
  // //   if (age == null) return false;
  // //   switch (range) {
  // //     case '18-25':
  //       return age >= 18 && age <= 25;
  //     case '26-35':
  //       return age >= 26 && age <= 35;
  //     case '36-50':
  //       return age >= 36 && age <= 50;
  //     case '50+':
  //       return age > 50;
  //     default:
  //       return true;
  //   }
  // }

  void setPageToOne() {
    page = 1;
    appStore.setLoading(true);

    init();
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter Dropdowns at the Top
        Padding(
          padding: EdgeInsets.all(16),
          child: FilterDropdownComponent(
            selectedAgeRange: selectedAgeRange,
            selectedGender: selectedGender,
            onAgeChanged: (value) {
              setState(() {
                selectedAgeRange = value;
                setPageToOne();
                //applyFilters();
              });
            },
            onGenderChanged: (value) {
              setState(() {
                selectedGender = value;
                setPageToOne();
                //applyFilters();
              });
            },
          ),
        ),

        // Provider List (Expanded to take remaining space)
        Expanded(
          child: Stack(
            children: [
              SnapHelperWidget<List<UserData>>(
                future: future,
                loadingWidget: LoaderWidget(),
                errorBuilder: (error) {
                  return NoDataWidget(
                    title: error,
                    imageWidget: ErrorStateWidget(),
                    retryText: language.reload,
                    onRetry: () {
                      setPageToOne();
                    },
                  );
                },
                onSuccess: (list) {
                  return AnimatedListView(
                    slideConfiguration: sliderConfigurationGlobal,
                    itemCount: list.length,
                    listAnimationType: ListAnimationType.FadeIn,
                    fadeInConfiguration:
                        FadeInConfiguration(duration: 2.seconds),
                    padding: EdgeInsets.only(
                        left: 16, right: 16, top: 16, bottom: 80),
                    emptyWidget: NoDataWidget(
                      title: language.providerNotFound,
                      imageWidget: EmptyStateWidget(),
                    ),
                    onSwipeRefresh: () async {
                      page = 1;
                      init();
                      setState(() {});
                      return await 2.seconds.delay;
                    },
                    onNextPage: () {
                      if (!isLastPage) {
                        page++;
                        appStore.setLoading(true);
                        init();
                        setState(() {});
                      }
                    },
                    itemBuilder: (context, index) {
                      UserData data = list[index];

                      return Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: boxDecorationWithRoundedCorners(
                          borderRadius: radius(),
                          backgroundColor: context.cardColor,
                          border: appStore.isDarkMode
                              ? Border.all(color: context.dividerColor)
                              : null,
                        ),
                        child: Row(
                          children: [
                            ImageBorder(
                              src: data.profileImage.validate(),
                              height: 45,
                            ),
                            16.width,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data.displayName.validate(),
                                    style: boldTextStyle()),
                                4.height,
                                if (data.age != null ||
                                    data.age != 0 ||
                                    data.gender != null)
                                  Text(
                                    [
                                      if (data.age != null || data.age != 0)
                                        "Age: ${data.age}",
                                      if (data.gender != null)
                                        "Gender: ${data.gender!.capitalizeFirstLetter()}"
                                    ].join(" | "),
                                    style: secondaryTextStyle(size: 12),
                                  ),
                              ],
                            ).expand(),
                            4.width,
                            SelectedItemWidget(
                                isSelected:
                                    filterStore.providerId.contains(data.id)),
                          ],
                        ),
                      ).onTap(() {
                        if (data.isSelected) {
                          data.isSelected = false;
                        } else {
                          data.isSelected = true;
                        }

                        filterStore.providerId = [];

                        providerList.forEach((element) {
                          if (element.isSelected) {
                            filterStore.addToProviderList(
                                prodId: element.id.validate());
                          }
                        });

                        setState(() {});
                      },
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent);
                    },
                  );
                },
              ),
              Observer(
                  builder: (_) =>
                      LoaderWidget().visible(appStore.isLoading && page != 1)),
            ],
          ),
        ),
      ],
    );
  }
}
