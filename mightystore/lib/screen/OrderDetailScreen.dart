import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mightystore/main.dart';
import 'package:mightystore/models/Coupon_lines.dart';
import 'package:mightystore/models/OrderModel.dart';
import 'package:mightystore/models/OrderTracking.dart';
import 'package:mightystore/models/TrackingResponse.dart';
import 'package:mightystore/network/rest_apis.dart';
import 'package:mightystore/screen/WebViewExternalProductScreen.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:mightystore/utils/common.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:mightystore/utils/dashed_ract.dart';
import 'package:nb_utils/nb_utils.dart';

import '../app_localizations.dart';
import '../utils/app_Widget.dart';
import '../utils/constants.dart';
import 'ProductDetailScreen.dart';

class OrderDetailScreen extends StatefulWidget {
  static String tag = '/OrderDetailScreen';
  final OrderResponse mOrderModel;

  OrderDetailScreen({Key key, this.mOrderModel}) : super(key: key);

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  List<OrderResponse> mOrderModel = [];
  List<OrderTracking> mOrderTrackingModel = [];
  List<TrackingResponse> mGetTrackingModel = [];
  final List<String> mCancelList = [
    'Product is being delivered to a wrong address',
    'Product is not required anymore',
    'Cheaper alternative available for lesser price',
    'The price of the product has fallen due to sales/discounts and customer wants to get it at a lesser price.',
    'Bad review from friends/relatives after ordering the product.',
    'Order placed by mistake',
  ].toList();

  bool isLoading = false;
  String mValue;
  var value = "";

  @override
  void initState() {
    mValue = mCancelList.first;
    super.initState();
    init();
    fetchTrackingData();
    getTracking();
  }

  init() async {
    if (widget.mOrderModel.metaData != null) {
      widget.mOrderModel.metaData.forEach((element) {
        if (element.key == "delivery_date") {
          value = element.value;
          log("element:- $value");
        }
      });
    } else {
      value = "";
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future fetchTrackingData() async {
    setState(() {
      isLoading = true;
    });
    await getOrdersTracking(widget.mOrderModel.id).then((res) {
      if (!mounted) return;
      isLoading = false;
      setState(() {
        Iterable mCategory = res;
        mOrderTrackingModel = mCategory.map((model) => OrderTracking.fromJson(model)).toList();
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        toast(error.toString());
      });
    });
  }

  Future getTracking() async {
    setState(() {
      isLoading = true;
    });
    await getTrackingInfo(widget.mOrderModel.id).then((res) {
      if (!mounted) return;
      isLoading = false;
      setState(() {
        Iterable mTracking = res;
        mGetTrackingModel = mTracking.map((model) => TrackingResponse.fromJson(model)).toList();
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        toast(error.toString());
      });
    });
  }

  void cancelOrderData(String mValue) async {
    setState(() {
      isLoading = true;
    });
    var request = {
      "status": "cancelled",
      "customer_note": mValue,
    };
    await cancelOrder(widget.mOrderModel.id, request).then((res) {
      if (!mounted) return;
      setState(() {
        var request = {
          'customer_note': true,
          'note': "{\n" + "\"status\":\"Cancelled\",\n" + "\"message\":\"Order Canceled by you due to " + mValue + ".\"\n" + "} ",
        };
        createOrderNotes(widget.mOrderModel.id, request).then((res) {
          if (!mounted) return;
          isLoading = false;
          setState(() {
            finish(context, true);
          });
        }).catchError((error) {
          if (!mounted) return;
          setState(() {
            isLoading = false;
            finish(context, true);
            toast(error.toString());
          });
        });
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        toast(error.toString());
        finish(context, true);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context);

    Widget mData(OrderTracking orderTracking) {
      Tracking tracking;
      try {
        var x = jsonDecode(orderTracking.note) as Map<String, dynamic>;
        tracking = Tracking.fromJson(x);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[Text(tracking.status.validate(), style: boldTextStyle()), Text(tracking.message.validate(), style: secondaryTextStyle())],
        );
      } on FormatException catch (e) {
        log(e);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(appLocalization.translate('lbl_by_admin'), style: boldTextStyle()),
            Text(orderTracking.note.validate(), style: secondaryTextStyle(size: 16)),
          ],
        );
      }
    }

    Widget mTracking() {
      return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: mOrderTrackingModel.length,
        itemBuilder: (context, i) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 4, 0, 0),
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(color: primaryColor, borderRadius: radius(16)),
                  ),
                  SizedBox(height: 100, child: DashedRect(gap: 2, color: primaryColor)),
                ],
              ),
              8.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[mData(mOrderTrackingModel[i]), 8.height, Text(convertDate(mOrderTrackingModel[i].dateCreated.validate()), style: secondaryTextStyle())],
                ),
              )
            ],
          );
        },
      );
    }

    Widget mCancelOrder() {
      if (widget.mOrderModel.status == COMPLETED || widget.mOrderModel.status == REFUNDED || widget.mOrderModel.status == CANCELED || widget.mOrderModel.status == TRASH || widget.mOrderModel.status == FAILED) {
        return SizedBox();
      } else {
        return GestureDetector(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                            backgroundColor: Theme.of(context).cardTheme.color,
                            title: Text(appLocalization.translate('title_cancel_order'), style: primaryTextStyle()),
                            content: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: boxDecorationWithRoundedCorners(borderRadius: radius(8), backgroundColor: Theme.of(context).colorScheme.background),
                                child: SingleChildScrollView(
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                                  Theme(
                                    data: Theme.of(context).copyWith(canvasColor: Theme.of(context).cardTheme.color),
                                    child: DropdownButton<String>(
                                      value: mValue,
                                      isExpanded: true,
                                      underline: SizedBox(),
                                      onChanged: (String newValue) {
                                        setState(() {
                                          mValue = newValue;
                                        });
                                      },
                                      items: mCancelList.map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value, style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle1.color)).paddingOnly(left: 8, right: 8),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  20.height,
                                  AppButton(
                                      width: context.width(),
                                      textStyle: primaryTextStyle(color: white),
                                      text: appLocalization.translate('lbl_cancel_order'),
                                      color: primaryColor,
                                      onTap: () {
                                        Navigator.pop(context);
                                        setState(() {
                                          isLoading = true;
                                        });
                                        cancelOrderData(mValue);
                                      })
                                ]))));
                      },
                    );
                  });
            },
            child: Container(
                padding: EdgeInsets.only(top: spacing_middle.toDouble(), bottom: spacing_middle.toDouble()),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(
                    appLocalization.translate('lbl_cancel_order'),
                    style: primaryTextStyle(color: primaryColor),
                  ),
                  Icon(Icons.chevron_right)
                ])));
      }
    }

    Widget mBody(BuildContext context) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            commonCacheImageWidget(
              widget.mOrderModel.lineItems[0].productImages[0].src,
              height: 140,
              width: 120,
              fit: BoxFit.fill,
            ).center().cornerRadiusWithClipRRect(8),
            Text(
              widget.mOrderModel.lineItems[0].name,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: boldTextStyle(),
            ).center().paddingOnly(left: 20, right: 20, top: 10, bottom: 10),
            Container(
              width: context.width(),
              decoration: boxDecorationWithRoundedCorners(borderRadius: radius(8), backgroundColor: Theme.of(context).colorScheme.background),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.mOrderModel.status.toUpperCase(), style: boldTextStyle(color: primaryColor)),
                  4.height,
                  Text(appLocalization.translate('lbl_deliver_on') + " " + createDateFormat(value), style: secondaryTextStyle()).visible(value.isNotEmpty)
                ],
              ).paddingAll(16),
            ).paddingOnly(left: 16, bottom: 16, right: 16),
            GestureDetector(
              onTap: () {
                WebViewExternalProductScreen(mExternal_URL: mGetTrackingModel[0].trackingLink, title: "Track your order").launch(context);
              },
              child: Container(
                width: context.width(),
                decoration: boxDecorationWithRoundedCorners(borderRadius: radius(8), backgroundColor: Theme.of(context).colorScheme.background),
                child: Text(
                  appLocalization.translate('lbl_tracking'),
                  style: boldTextStyle(color: primaryColor),
                ).paddingAll(16).center(),
              )
                  .paddingOnly(left: 16, bottom: 16, right: 16)
                  .visible(mGetTrackingModel.isNotEmpty && (widget.mOrderModel.status == "pending" || widget.mOrderModel.status == "processing" || widget.mOrderModel.status == "on-hold")),
            ),
            Divider(thickness: 6, color: Theme.of(context).textTheme.headline4.color),
            Container(
              width: context.width(),
              margin: EdgeInsets.only(bottom: spacing_standard.toDouble()),
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  spacing_standard.height,
                  Text(
                    appLocalization.translate('lbl_delivery_address'),
                    style: boldTextStyle(size: 18),
                  ),
                  10.height,
                  Text(
                    widget.mOrderModel.shipping.firstName + " " + widget.mOrderModel.shipping.lastName,
                    style: boldTextStyle(),
                  ),
                  2.height,
                  Text(widget.mOrderModel.shipping.address1 + " " + widget.mOrderModel.shipping.city + " " + widget.mOrderModel.shipping.country + " " + widget.mOrderModel.shipping.state,
                      style: secondaryTextStyle(size: textSizeMedium)),
                  spacing_control.height,
                ],
              ),
            ),
            Divider(thickness: 6, color: Theme.of(context).textTheme.headline4.color).visible(mOrderTrackingModel.isNotEmpty),
            Container(
              margin: EdgeInsets.only(
                bottom: spacing_standard.toDouble(),
              ),
              padding: EdgeInsets.fromLTRB(spacing_standard_new.toDouble(), spacing_standard.toDouble(), spacing_standard_new.toDouble(), spacing_standard.toDouble()),
              child: Column(
                children: [mTracking(), mCancelOrder()],
              ),
            ).visible(mOrderTrackingModel.isNotEmpty),
            Divider(thickness: 6, color: Theme.of(context).textTheme.headline4.color),
            Container(
              width: context.width(),
              margin: EdgeInsets.only(
                bottom: spacing_standard.toDouble(),
              ),
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  spacing_standard.height,
                  Text(
                    appLocalization.translate('lbl_other_item_in_cart'),
                    style: boldTextStyle(size: 18),
                  ),
                  Text(
                    appLocalization.translate('lbl_order_id') + widget.mOrderModel.id.toString(),
                    style: secondaryTextStyle(),
                  ),
                  16.height,
                  ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: widget.mOrderModel.lineItems.length,
                    itemBuilder: (context, i) {
                      return GestureDetector(
                        onTap: () {
                          ProductDetailScreen(mProId: widget.mOrderModel.lineItems[0].productId).launch(context);
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: spacing_middle.toDouble()),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              commonCacheImageWidget(
                                widget.mOrderModel.lineItems[i].productImages[0].src.validate(),
                                height: 70,
                                width: 70,
                                fit: BoxFit.cover,
                              ).cornerRadiusWithClipRRect(8),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.mOrderModel.lineItems[i].name,
                                      style: primaryTextStyle(),
                                      maxLines: 2,
                                    ),
                                    spacing_standard_new.height,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        PriceWidget(
                                          price: widget.mOrderModel.lineItems[i].total.toString(),
                                          size: textSizeLargeMedium.toDouble(),
                                          color: Theme.of(context).textTheme.subtitle1.color,
                                        ),
                                        4.width,
                                        Text(
                                          appLocalization.translate('lbl_qty') + " " + widget.mOrderModel.lineItems[i].quantity.toString(),
                                          style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle1.color),
                                        ),
                                      ],
                                    )
                                  ],
                                ).paddingOnly(left: spacing_standard_new.toDouble(), right: spacing_standard_new.toDouble(), top: spacing_control.toDouble()),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Divider(),
                  8.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        appLocalization.translate('lbl_Shipping'),
                        style: secondaryTextStyle(color: Theme.of(context).textTheme.subtitle2.color, size: 16),
                      ),
                      PriceWidget(
                        price: widget.mOrderModel.shippingTotal.isNotEmpty ? widget.mOrderModel.shippingTotal : "Free",
                        size: 16,
                        color: Theme.of(context).textTheme.subtitle2.color,
                      ),
                    ],
                  ),
                  8.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        appLocalization.translate("lbl_total_order_price"),
                        style: boldTextStyle(),
                      ),
                      PriceWidget(price: widget.mOrderModel.total, size: 16, color: primaryColor),
                    ],
                  ),
                  createRichText(list: [
                    TextSpan(text: appLocalization.translate('lbl_you_saved') + " ", style: secondaryTextStyle()),
                    TextSpan(text: widget.mOrderModel.discountTotal, style: boldTextStyle(color: Theme.of(context).accentColor)),
                    TextSpan(text: " " + appLocalization.translate('lbl_on_this_order'), style: secondaryTextStyle()),
                  ]).visible(int.parse(widget.mOrderModel.discountTotal) > 0),
                ],
              ),
            ),
            Divider(thickness: 6, color: Theme.of(context).textTheme.headline4.color),
            Container(
              width: context.width(),
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  spacing_standard.height,
                  Text(
                    appLocalization.translate('lbl_update_sent_to'),
                    style: boldTextStyle(size: 18),
                  ),
                  10.height,
                  RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          child: Icon(Icons.call, size: 16, color: Theme.of(context).textTheme.subtitle1.color).paddingRight(10),
                        ),
                        TextSpan(text: widget.mOrderModel.billing.phone, style: secondaryTextStyle()),
                      ],
                    ),
                  ),
                  8.height,
                  RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          child: Icon(Icons.email, size: 16, color: Theme.of(context).textTheme.subtitle1.color).paddingRight(10),
                        ),
                        TextSpan(text: widget.mOrderModel.billing.email, style: secondaryTextStyle()),
                      ],
                    ),
                  ),
                  16.height
                ],
              ),
            )
          ],
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: mTop(context, appLocalization.translate('lbl_order_details'), showBack: true),
          body: Stack(
            alignment: Alignment.center,
            children: [
              mBody(context),
              mProgress().center().visible(isLoading),
            ],
          )),
    );
  }
}
