import 'package:flutter/material.dart';
import 'package:mightystore/models/ProductResponse.dart';
import 'package:mightystore/screen/VendorProfileScreen.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: must_be_immutable
class VendorListComponent extends StatefulWidget {
  static String tag = '/VendorListComponent';
  List<VendorResponse> mVendorList = [];

  VendorListComponent({Key key, this.mVendorList}) : super(key: key);

  @override
  VendorListComponentState createState() => VendorListComponentState();
}

class VendorListComponentState extends State<VendorListComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget getVendorWidget(VendorResponse vendor, BuildContext context) {
    String img = vendor.banner.isNotEmpty ? vendor.banner.validate() : '';

    var addressText = "";
    if (vendor.address != null) {
      if (vendor.address.street_1 != null) {
        if (vendor.address.street_1.isNotEmpty && addressText.isEmpty) {
          addressText = vendor.address.street_1;
        }
      }
      if (vendor.address.street_2 != null) {
        if (vendor.address.street_2.isNotEmpty) {
          if (addressText.isEmpty) {
            addressText = vendor.address.street_2;
          } else {
            addressText += ", " + vendor.address.street_2;
          }
        }
      }
      if (vendor.address.city != null) {
        if (vendor.address.city.isNotEmpty) {
          if (addressText.isEmpty) {
            addressText = vendor.address.city;
          } else {
            addressText += ", " + vendor.address.city;
          }
        }
      }

      if (vendor.address.zip != null) {
        if (vendor.address.zip.isNotEmpty) {
          if (addressText.isEmpty) {
            addressText = vendor.address.zip;
          } else {
            addressText += " - " + vendor.address.zip;
          }
        }
      }
      if (vendor.address.state != null) {
        if (vendor.address.state.isNotEmpty) {
          if (addressText.isEmpty) {
            addressText = vendor.address.state;
          } else {
            addressText += ", " + vendor.address.state;
          }
        }
      }
      if (vendor.address.country != null) {
        if (!vendor.address.country.isNotEmpty) {
          if (addressText.isEmpty) {
            addressText = vendor.address.country;
          } else {
            addressText += ", " + vendor.address.country;
          }
        }
      }
    }

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: commonCacheImageWidget(img, height: 160, width: context.width(), fit: BoxFit.fill),
          ),
          Row(children: [
            CircleAvatar(backgroundImage: NetworkImage(vendor.avatar), radius: 30),
            10.width,
            Column(mainAxisAlignment: MainAxisAlignment.end, mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              4.height,
              Text(vendor.storeName, style: boldTextStyle()),
              4.height,
              Text(addressText, maxLines: 3, style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle1.color, size: textSizeMedium)),
            ]).expand(),
          ]).paddingAll(8),
        ],
      ),
      margin: EdgeInsets.only(left: 8, right: 8, bottom: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<VendorResponse> mVendorList = widget.mVendorList;
    return ListView.separated(
        separatorBuilder: (context, index) {
          return Divider(thickness: 6, color: Theme.of(context).textTheme.headline4.color);
        },
        itemCount: mVendorList.length,
        padding: EdgeInsets.only(left: 4, right: 4),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, i) {
          return GestureDetector(
              onTap: () {
                VendorProfileScreen(mVendorId: mVendorList[i].id).launch(context);
              },
              child: getVendorWidget(mVendorList[i], context));
        });
  }
}
