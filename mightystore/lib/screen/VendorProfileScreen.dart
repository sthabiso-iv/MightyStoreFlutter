import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mightystore/component/Product.dart';
import 'package:mightystore/models/ProductResponse.dart';
import 'package:mightystore/network/rest_apis.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:mightystore/utils/colors.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../app_localizations.dart';

class VendorProfileScreen extends StatefulWidget {
  static String tag = '/VendorProfileScreen';
  final int mVendorId;

  VendorProfileScreen({Key key, this.mVendorId}) : super(key: key);

  @override
  _VendorProfileScreenState createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  VendorResponse mVendorModel;
  List<ProductResponse> mVendorProductList = [];
  bool isLoading = false;
  String mErrorMsg = '';

  @override
  void initState() {
    super.initState();
    log(widget.mVendorId.toString());
    fetchVendorProfile();
    fetchVendorProduct();
  }

  Future fetchVendorProfile() async {
    setState(() {
      isLoading = true;
    });
    await getVendorProfile(widget.mVendorId).then((res) {
      if (!mounted) return;
      VendorResponse methodResponse = VendorResponse.fromJson(res);
      setState(() {
        isLoading = false;
        mVendorModel = methodResponse;
        mErrorMsg = '';
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        mErrorMsg = 'No Products';
      });
    });
  }

  Future fetchVendorProduct() async {
    setState(() {
      isLoading = true;
    });
    await getVendorProduct(widget.mVendorId).then((res) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        mErrorMsg = '';
        Iterable list = res;
        mVendorProductList = list.map((model) => ProductResponse.fromJson(model)).toList();
      });
    }).catchError(
      (error) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          mErrorMsg = 'No Products';
        });
      },
    );
  }

  Widget mOption(var value, var color, {maxLine = 1}) {
    return Text(
      value,
      style: primaryTextStyle(color: color),
      maxLines: maxLine,
    ).paddingOnly(left: 10, right: 16);
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context);
    var addressText = "";

    if (mVendorModel != null) {
      if (mVendorModel.address != null) {
        if (mVendorModel.address.street_1.isNotEmpty && addressText.isEmpty) {
          addressText = mVendorModel.address.street_1;
        }
        if (mVendorModel.address.street_2.isNotEmpty) {
          if (addressText.isEmpty) {
            addressText = mVendorModel.address.street_2;
          } else {
            addressText += ", " + mVendorModel.address.street_2;
          }
        }

        if (mVendorModel.address.city.isNotEmpty) {
          if (addressText.isEmpty) {
            addressText = mVendorModel.address.city;
          } else {
            addressText += ", " + mVendorModel.address.city;
          }
        }
        if (mVendorModel.address.zip.isNotEmpty) {
          if (addressText.isEmpty) {
            addressText = mVendorModel.address.zip;
          } else {
            addressText += " - " + mVendorModel.address.zip;
          }
        }
        if (mVendorModel.address.state.isNotEmpty) {
          if (addressText.isEmpty) {
            addressText = mVendorModel.address.state;
          } else {
            addressText += ", " + mVendorModel.address.state;
          }
        }
        if (mVendorModel.address.country.isNotEmpty) {
          if (addressText.isEmpty) {
            addressText = mVendorModel.address.country;
          } else {
            addressText += ", " + mVendorModel.address.country;
          }
        }
      }
    }

    final body = mVendorModel != null
        ? SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                mVendorModel.banner.isNotEmpty
                    ? Container(
                        height: 200,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                          fit: BoxFit.fill,
                          image: CachedNetworkImageProvider(mVendorModel.banner.validate()),
                        ))).cornerRadiusWithClipRRect(10).paddingAll(10)
                    : SizedBox(),
                16.height,
                Text(mVendorModel.storeName != null ? mVendorModel.storeName : '', style: boldTextStyle(size: textSizeNormal)).paddingOnly(left: 10, right: 16).visible(mVendorModel.storeName.isNotEmpty),
                10.height,
                mOption(mVendorModel.phone != null ? mVendorModel.phone : '', Theme.of(context).textTheme.subtitle1.color).visible(!mVendorModel.phone.isEmptyOrNull),
                10.height,
                mOption(addressText, Theme.of(context).textTheme.subtitle1.color, maxLine: 3),
                10.height,
                Divider(color: view_color, thickness: 4).paddingOnly(left: 8, right: 8),
                10.height,
                Text(appLocalization.translate('lbl_product_list'), style: boldTextStyle()).paddingLeft(16).visible(mVendorProductList.isNotEmpty),
                mVendorProductList.isNotEmpty
                    ? StaggeredGridView.countBuilder(
                        scrollDirection: Axis.vertical,
                        itemCount: mVendorProductList.length,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.all(8),
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        staggeredTileBuilder: (index) {
                          return StaggeredTile.fit(1);
                        },
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                        itemBuilder: (context, index) {
                          return Product(mProductModel: mVendorProductList[index]);
                        },
                      )
                    : Text(appLocalization.translate('lbl_data_not_found'), style: boldTextStyle()).paddingOnly(left: 8, right: 8)
              ],
            ),
          )
        : SizedBox();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: mTop(context, mVendorModel != null ? mVendorModel.storeName : ' ', showBack: true),
        body: mInternetConnection(
          Stack(
            alignment: Alignment.bottomLeft,
            children: <Widget>[
              body.visible(mVendorModel != null),
              Center(child: mProgress()).visible(isLoading),
              Text(mErrorMsg.validate(), style: boldTextStyle(size: 20, color: Theme.of(context).textTheme.subtitle1.color)).center().visible(mErrorMsg.isNotEmpty),
            ],
          ),
        ),
      ),
    );
  }
}
