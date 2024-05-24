import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mightystore/main.dart';
import 'package:mightystore/models/OrderModel.dart';
import 'package:mightystore/network/rest_apis.dart';
import 'package:mightystore/screen/DashBoardScreen.dart';
import 'package:mightystore/screen/OrderDetailScreen.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:mightystore/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
import '../app_localizations.dart';
import '../utils/app_Widget.dart';
import '../utils/constants.dart';

class OrderList extends StatefulWidget {
  static String tag = '/OrderList';

  @override
  _OrderListState createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  List<OrderResponse> mOrderModel = [];
  String mErrorMsg = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future fetchOrderData() async {
    setState(() {
      isLoading = true;
    });
    await getOrders().then((res) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        Iterable mOrderDetails = res;
        mOrderModel = mOrderDetails.map((model) => OrderResponse.fromJson(model)).toList();
        if (mOrderModel.isEmpty) {
          mErrorMsg = '';
        }
      });
    }).catchError((error) {
      if (!mounted) return;
      log(error);
      setState(() {
        isLoading = false;
        mOrderModel.clear();
        mErrorMsg = error.toString();
        log("Test" + error.toString());
      });
    });
  }

  init() async {
    fetchOrderData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context);
    Widget mBody = ListView.separated(
        separatorBuilder: (context, index) {
          return Divider(thickness: 6, color: Theme.of(context).textTheme.headline4.color);
        },
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: mOrderModel.length,
        padding: EdgeInsets.only(left: 8, right: 8),
        itemBuilder: (context, i) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              10.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  if (mOrderModel[i].lineItems.isNotEmpty.validate())
                    if (mOrderModel[i].lineItems[0].productImages[0].src.isNotEmpty.validate())
                      commonCacheImageWidget(mOrderModel[i].lineItems[0].productImages[0].src.validate(), height: 65, width: 65, fit: BoxFit.cover).cornerRadiusWithClipRRect(8),
                  10.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        if (mOrderModel[i].lineItems.isNotEmpty)
                          if (mOrderModel[i].lineItems.length > 1)
                            Text(mOrderModel[i].lineItems[0].name.validate() + " + " + " more items".toString(), maxLines: 2, style: primaryTextStyle())
                          else
                            Text(mOrderModel[i].lineItems[0].name.validate(), maxLines: 2, overflow: TextOverflow.ellipsis, style: primaryTextStyle())
                        else
                          Text(mOrderModel[i].id.toString().validate(), style: primaryTextStyle(size: textSizeLargeMedium)),
                        spacing_standard.height,
                        Text(mOrderModel[i].status, style: boldTextStyle(color: primaryColor)),
                      ],
                    ),
                  ),
                ],
              ),
              10.height,
            ],
          ).paddingOnly(left: 8, right: 8).onTap(() async {
            bool isChanged = await OrderDetailScreen(mOrderModel: mOrderModel[i]).launch(context);
            if (isChanged != null) {
              setState(() {
                isLoading = true;
              });
              init();
            }
          });
        });

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: mTop(context, appLocalization.translate('lbl_orders'), showBack: true),
        body: mInternetConnection(
          Stack(
            children: [
              mOrderModel.isNotEmpty
                  ? mBody
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(ic_order, height: 80, width: 80, color: primaryColor),
                          20.height,
                          Text(appLocalization.translate("msg_empty_order"), style: primaryTextStyle(size: 22), textAlign: TextAlign.center).paddingOnly(left: 20, right: 20),
                          4.height,
                          Text(appLocalization.translate("msg_info_empty_order"), style: secondaryTextStyle(size: 16), textAlign: TextAlign.center).paddingOnly(left: 20, right: 20),
                          30.height,
                          Container(
                            width: context.width(),
                            child: AppButton(
                                width: context.width(),
                                textStyle: primaryTextStyle(color: white),
                                text: appLocalization.translate('lbl_start_shopping'),
                                color: primaryColor,
                                onTap: () {
                                  DashBoardScreen().launch(context);
                                }),
                          ).paddingOnly(left: 20, right: 20),
                        ],
                      ),
                    ).visible(!isLoading && mErrorMsg.isEmpty),
              Center(child: mProgress()).visible(isLoading),
              Center(
                child: Text(mErrorMsg, style: primaryTextStyle(), textAlign: TextAlign.center).visible(!isLoading),
              ).visible(mErrorMsg.isNotEmpty),
            ],
          ),
        ),
      ),
    );
  }
}
