import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:mightystore/main.dart';
import 'package:mightystore/models/CartModel.dart';
import 'package:mightystore/models/Countries.dart';
import 'package:mightystore/models/CustomerResponse.dart';
import 'package:mightystore/models/Line_items.dart';
import 'package:mightystore/models/OrderModel.dart';
import 'package:mightystore/models/ShippingMethodResponse.dart';
import 'package:mightystore/network/rest_apis.dart';
import 'package:mightystore/screen/DashBoardScreen.dart';
import 'package:mightystore/screen/OrderSummaryScreen.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:mightystore/utils/images.dart';
import 'package:mightystore/utils/shared_pref.dart';
import 'package:nb_utils/nb_utils.dart';

import '../app_localizations.dart';
import 'ApplyCouponScreen.dart';
import 'EditProfileScreen.dart';

// ignore: must_be_immutable
class MyCartScreen extends StatefulWidget {
  static String tag = '/MyCartScreen';

  var isShowBack = false;

  MyCartScreen({this.isShowBack});

  @override
  MyCartScreenState createState() => MyCartScreenState();
}

class MyCartScreenState extends State<MyCartScreen> {
  List<CartModel> mCartModelList = [];
  List<LineItems> mLineItems = [];
  List<Method> shippingMethods = [];
  List<Country> countryList = [];

  Shipping shipping;
  ShippingMethodResponse shippingMethodResponse;

  bool mIsLoggedIn = false;
  bool mIsGuest = false;
  bool mIsLoading = false;
  bool isCoupons = false;
  bool isEnableCoupon = false;

  String mErrorMsg = '';

  double mTotalDiscount = 0;
  double mSaveDiscount = 0;
  double mTotalCount = 0.0;
  double mTotalMrpDiscount = 0.0;
  double mTotalMrp = 0.0;

  var mDiscountedAmount;
  var selectedShipment = 0;
  var mDiscountInfo;

  ScrollController _scrollController = ScrollController();
  NumberFormat nf = NumberFormat('##.00');

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    mIsGuest = getBoolAsync(IS_GUEST_USER, defaultValue: false);
    mIsLoggedIn = getBoolAsync(IS_LOGGED_IN, defaultValue: false);
    if (!await isGuestUser() && await isLoggedIn()) {
      fetchCartData();
    } else if (await isGuestUser()) {
      fetchPrefData();
    } else {
      setState(() {
        mIsLoading = false;
        mErrorMsg = 'An Empty shopping basket is a lonely shopping basket. Go On, add shopping';
      });
    }
  }

  fetchShipmentData() async {
    if (countryList.isEmpty) {
      String countries = getStringAsync(COUNTRIES);
      if (countries == '') {
        await getCountries().then((value) async {
          setState(() {
            mIsLoading = false;
          });
          setValue(COUNTRIES, jsonEncode(value));
          fetchShippingMethod(value);
        }).catchError((error) {
          setState(() {
            mIsLoading = false;
          });
          toast(error);
        });
      } else {
        fetchShippingMethod(jsonDecode(countries));
      }
    } else {
      setState(() {
        mIsLoading = false;
      });
      loadShippingMethod();
    }
  }

  fetchShippingMethod(var value) async {
    setState(() {
      mIsLoading = false;
    });
    Iterable list = value;
    var countris = list.map((model) => Country.fromJson(model)).toList();
    setState(() {
      countryList.addAll(countris);
    });

    if (getStringAsync(SHIPPING).isNotEmpty) {
      if (jsonDecode(getStringAsync(SHIPPING)) != null) {
        setState(() {
          shipping = Shipping.fromJson(jsonDecode(getStringAsync(SHIPPING)));
        });
        log(shipping);
        var mShippingPostcode = shipping.postcode;
        var mShippingCountry = shipping.country;
        var mShippingState = shipping.state;
        var countryCode = "";
        var stateCode = "";
        if (mShippingCountry != null && mShippingCountry.isNotEmpty) {
          countryList.forEach((element) {
            if (element.name == mShippingCountry) {
              countryCode = element.code;
              if (mShippingState != null && mShippingState.isNotEmpty) {
                if (element.states != null && element.states.isNotEmpty) {
                  element.states.forEach((state) {
                    if (state.name == mShippingState) {
                      stateCode = state.code;
                    }
                  });
                }
              }
            }
          });
        }
        var request = {"country_code": countryCode, "state_code": stateCode, "postcode": mShippingPostcode};
        await getShippingMethod(request).then((value) {
          shippingMethodResponse = ShippingMethodResponse.fromJson(value);
          setState(() {
            mIsLoading = false;
            loadShippingMethod();
          });
          setState(() {});
        }).catchError((error) {
          setState(() {
            mIsLoading = false;
          });
          toast(error);
        });
      }
    }
  }

  loadShippingMethod() {
    setState(() {
      shippingMethods.clear();
      if (shippingMethodResponse != null && shippingMethodResponse.data.methods != null) {
        shippingMethodResponse.data.methods.forEach((method) {
          if (shouldApply(method)) {
            shippingMethods.add(method);
          } else {
            log("Title" + method.title);
          }
        });
        if (shippingMethods.isNotEmpty) {
          selectedShipment = 0;
        }
      }
    });
  }

  fetchCartData() async {
    setState(() {
      mIsLoading = true;
      isEnableCoupon = getBoolAsync(ENABLECOUPON);
    });
    await getCartList().then((res) {
      if (!mounted) return;
      setState(() {
        Iterable list = res['data'];
        mCartModelList = list.map((model) => CartModel.fromJson(model)).toList();
        mErrorMsg = '';
        mTotalCount = 0.0;
        mTotalMrpDiscount = 0.0;
        mTotalMrp = 0.0;
        mLineItems.clear();
        if (mCartModelList.isEmpty) {
          mErrorMsg = ('An Empty shopping basket is a lonely shopping basket. Go On, add shopping');
          mIsLoading = false;
          appStore.setCount(0);
        } else {
          mErrorMsg = '';
          for (var i = 0; i < mCartModelList.length; i++) {
            var mItem = LineItems();
            mItem.proId = mCartModelList[i].proId;
            mItem.quantity = mCartModelList[i].quantity;
            mLineItems.add(mItem);
            if (mCartModelList[i].onSale) {
              mTotalCount += double.parse(mCartModelList[i].salePrice) * int.parse(mCartModelList[i].quantity);
              mTotalMrpDiscount -= (double.parse(mCartModelList[i].salePrice) * int.parse(mCartModelList[i].quantity)) - (double.parse(mCartModelList[i].regularPrice) * int.parse(mCartModelList[i].quantity));
              mTotalMrp += double.parse(mCartModelList[i].regularPrice) * int.parse(mCartModelList[i].quantity);
            } else {
              mTotalCount += double.parse(mCartModelList[i].regularPrice.toString().isNotEmpty ? mCartModelList[i].regularPrice : mCartModelList[i].price) * int.parse(mCartModelList[i].quantity);
              mTotalMrp += double.parse(mCartModelList[i].regularPrice.toString().isNotEmpty ? mCartModelList[i].regularPrice : mCartModelList[i].price) * int.parse(mCartModelList[i].quantity);
            }
          }
          fetchShipmentData();
        }
      });
    }).catchError((error) {
      log(error);
      setState(() {
        mIsLoading = false;
        mCartModelList.clear();
        mErrorMsg = error.toString();
      });
    });
  }

  fetchPrefData() {
    setState(() {
      mCartModelList = appStore.mCartList;
      mTotalCount = 0.0;
      mTotalMrpDiscount = 0.0;
      mTotalMrp = 0.0;
      mLineItems.clear();
      if (mCartModelList.isEmpty) {
        mErrorMsg = ('An Empty shopping basket is a lonely shopping basket. Go On, add shopping');
        mIsLoading = false;
        appStore.setCount(0);
      } else {
        mIsLoading = false;
        mErrorMsg = '';
        for (var i = 0; i < mCartModelList.length; i++) {
          var mItem = LineItems();
          mItem.proId = mCartModelList[i].proId;
          mItem.quantity = mCartModelList[i].quantity.toString();
          mLineItems.add(mItem);
          if (mCartModelList[i].onSale) {
            mTotalCount += double.parse(mCartModelList[i].salePrice) * int.parse(mCartModelList[i].quantity);
            mTotalMrpDiscount -= (double.parse(mCartModelList[i].salePrice) * int.parse(mCartModelList[i].quantity)) - (double.parse(mCartModelList[i].regularPrice) * int.parse(mCartModelList[i].quantity));
            mTotalMrp += double.parse(mCartModelList[i].regularPrice) * int.parse(mCartModelList[i].quantity);
          } else {
            mTotalCount += double.parse(mCartModelList[i].regularPrice.toString().isNotEmpty ? mCartModelList[i].regularPrice : mCartModelList[i].price) * int.parse(mCartModelList[i].quantity);
            mTotalMrp += double.parse(mCartModelList[i].regularPrice.toString().isNotEmpty ? mCartModelList[i].regularPrice : mCartModelList[i].price) * int.parse(mCartModelList[i].quantity);
          }
        }
        fetchShipmentData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future updateCartItemApi(request) async {
    updateCartItem(request).then((res) {
      setState(() {
        mIsLoading = false;
      });
      fetchCartData();
    }).catchError((error) {
      toast(error.toString());
      mIsLoading = false;
      fetchCartData();
    });
  }

  Future removeCartItemApi(proId, index) async {
    var request = {
      'pro_id': proId,
    };
    mCartModelList.removeAt(index);
    setState(() {
      mIsLoading = true;
    });
    removeCartItem(request).then((res) {
      fetchCartData();
    }).catchError((error) {
      appStore.increment();
      fetchCartData();
    });
  }

  @override
  Widget build(BuildContext context) {
    setValue(CARTCOUNT, appStore.count);
    var appLocalization = AppLocalizations.of(context);

    Widget mCartInfo = ListView.separated(
      separatorBuilder: (context, index) {
        return Divider();
      },
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: mCartModelList.length,
      itemBuilder: (context, i) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            mCartModelList[i].full == null
                ? CachedNetworkImage(imageUrl: mCartModelList[i].gallery[0].toString().validate(), fit: BoxFit.cover, height: 85, width: 85).cornerRadiusWithClipRRect(8)
                : CachedNetworkImage(imageUrl: mCartModelList[i].full.toString().validate(), fit: BoxFit.cover, height: 85, width: 85).cornerRadiusWithClipRRect(8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mCartModelList[i].name, maxLines: 2, style: primaryTextStyle()).paddingLeft(16),
                  8.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          PriceWidget(
                            price: nf.format(double.parse(mCartModelList[i].price) * double.parse(mCartModelList[i].quantity)),
                            size: 16,
                            color: Theme.of(context).textTheme.subtitle2.color,
                          ),
                          PriceWidget(
                            price: mCartModelList[i].regularPrice.toString().isEmpty ? '' : nf.format(double.parse(mCartModelList[i].regularPrice) * double.parse(mCartModelList[i].quantity)),
                            size: 16,
                            isLineThroughEnabled: true,
                            color: Theme.of(context).textTheme.subtitle1.color,
                          ).paddingOnly(left: 4).visible(mCartModelList[i].salePrice.toString().validate().isNotEmpty && mCartModelList[i].onSale == true),
                        ],
                      ).paddingLeft(16),
                      Row(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () async {
                              var qty = int.parse(mCartModelList[i].quantity);
                              if (qty == 1 || qty < 1) {
                                qty = 1;
                              } else {
                                qty = qty - 1;
                                mIsLoading = true;
                                appStore.decrement();
                                if (!await isGuestUser()) {
                                  var request = {
                                    'pro_id': mCartModelList[i].proId,
                                    'cart_id': mCartModelList[i].cartId,
                                    'quantity': qty,
                                  };
                                  updateCartItemApi(request);
                                } else {
                                  setState(() {
                                    mIsLoading = false;
                                  });
                                  CartModel mCartModel = CartModel();
                                  mCartModel.name = mCartModelList[i].name;
                                  mCartModel.proId = mCartModelList[i].proId;
                                  mCartModel.onSale = mCartModelList[i].onSale;
                                  mCartModel.salePrice = mCartModelList[i].salePrice;
                                  mCartModel.regularPrice = mCartModelList[i].regularPrice;
                                  mCartModel.price = mCartModelList[i].price;
                                  mCartModel.gallery = mCartModelList[i].gallery;
                                  mCartModel.quantity = qty.toString();
                                  mCartModel.full = mCartModelList[i].full;
                                  mCartModel.cartId = mCartModelList[i].cartId;
                                  appStore.removeFromCartList(mCartModelList[i]);
                                  appStore.addToCartList(mCartModel);
                                  fetchPrefData();
                                }
                                setState(() {});
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(2),
                              margin: EdgeInsets.only(left: spacing_standard.toDouble(), right: spacing_middle.toDouble()),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.remove,
                                color: white,
                                size: 16,
                              ),
                            ),
                          ),
                          Text(
                            mCartModelList[i].quantity,
                            style: boldTextStyle(),
                          ),
                          GestureDetector(
                            onTap: () async {
                              var qty = int.parse(mCartModelList[i].quantity);
                              var value = qty + 1;
                              mIsLoading = true;
                              appStore.increment();
                              if (!await isGuestUser()) {
                                var request = {
                                  'pro_id': mCartModelList[i].proId,
                                  'cart_id': mCartModelList[i].cartId,
                                  'quantity': value,
                                };
                                updateCartItemApi(request);
                              } else {
                                setState(() {
                                  mIsLoading = false;
                                });
                                CartModel mCartModel = CartModel();
                                mCartModel.name = mCartModelList[i].name;
                                mCartModel.proId = mCartModelList[i].proId;
                                mCartModel.onSale = mCartModelList[i].onSale;
                                mCartModel.salePrice = mCartModelList[i].salePrice;
                                mCartModel.regularPrice = mCartModelList[i].regularPrice;
                                mCartModel.price = mCartModelList[i].price;
                                mCartModel.gallery = mCartModelList[i].gallery;
                                mCartModel.quantity = value.toString();
                                mCartModel.full = mCartModelList[i].full;
                                mCartModel.cartId = mCartModelList[i].cartId;
                                appStore.removeFromCartList(mCartModelList[i]);
                                appStore.addToCartList(mCartModel);
                                fetchPrefData();
                              }
                              setState(() {});
                            },
                            child: Container(
                              padding: EdgeInsets.all(2),
                              margin: EdgeInsets.only(left: spacing_middle.toDouble(), right: spacing_middle.toDouble()),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add,
                                size: 16,
                                color: white,
                              ),
                            ),
                          ),
                        ],
                      ).paddingLeft(8),
                    ],
                  ),
                  8.height,
                  Divider(thickness: 0.5, color: grey.withOpacity(0.2)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(Icons.delete, size: 20, color: lightGrey), 8.width, Text(appLocalization.translate('lbl_remove'), style: secondaryTextStyle(size: 16))],
                  ).onTap(() async {
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Theme.of(context).cardTheme.color,
                          content: Text(appLocalization.translate("msg_confirmation")),
                          actions: <Widget>[
                            TextButton(
                              child: Text(appLocalization.translate("lbl_cancel"), style: secondaryTextStyle()),
                              onPressed: () {
                                finish(context);
                              },
                            ),
                            TextButton(
                              child: Text(appLocalization.translate("lbl_remove"), style: TextStyle(color: Colors.red)),
                              onPressed: () async {
                                appStore.decrement();
                                if (!await isGuestUser()) {
                                  removeCartItemApi(mCartModelList[i].proId, i);
                                  finish(context);
                                } else {
                                  appStore.removeFromCartList(mCartModelList[i]);
                                  finish(context);
                                  setState(() {});
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }),
                  8.height,
                ],
              ),
            )
          ],
        ).paddingOnly(left: 16, right: 16, bottom: 8, top: 8);
      },
    );

    _navigateAndDisplaySelection(BuildContext context) async {
      var result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ApplyCouponScreen()),
      );
      setState(() {
        mDiscountInfo = jsonDecode(result);
        if (mDiscountInfo != null) {
          isCoupons = true;
          loadShippingMethod();
        }
      });
    }

    String getTotalAmount() {
      if (shippingMethodResponse != null && shippingMethods.isNotEmpty && shippingMethods[selectedShipment].cost != null && shippingMethods[selectedShipment].cost.isNotEmpty) {
        return ((mDiscountInfo != null
                    ? isCoupons
                        ? mDiscountedAmount
                        : mTotalCount
                    : mTotalCount) +
                double.parse(shippingMethods[selectedShipment].cost))
            .toString();
      } else {
        return mDiscountInfo != null
            ? isCoupons
                ? mDiscountedAmount.toString()
                : mTotalCount.toString()
            : mTotalCount.toString();
      }
    }

    Widget mCouponInfo(var text, var status) {
      if (mDiscountInfo != null) {
        switch (mDiscountInfo['discount_type']) {
          case "percent":
            {
              mSaveDiscount = ((mTotalCount * double.parse(mDiscountInfo['amount'])) / 100);
            }
            break;
          case "fixed_cart":
            {
              mSaveDiscount = double.parse(mDiscountInfo['amount']);
            }
            break;
          case "fixed_product":
            {
              var finalAmount = mDiscountInfo['amount'].split(".");
              mSaveDiscount = (int.parse(finalAmount[0]) * (mCartModelList.length)).toDouble();
            }
            break;
          default:
            {
              mSaveDiscount = mDiscountInfo['amount'];
            }
            break;
        }
      } else {
        mSaveDiscount = 0;
      }
      return Column(
        children: [
          8.height,
          Divider(thickness: 6, color: Theme.of(context).textTheme.headline4.color),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Image.asset(ic_coupon, width: 18, height: 18, color: Theme.of(context).iconTheme.color),
                    16.width,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isCoupons ? text : 'Coupon Code',
                          maxLines: 2,
                          style: primaryTextStyle(),
                        ),
                        Text(
                          appLocalization.translate('lbl_you_saved_additional') + " " + mSaveDiscount.toString(),
                          style: secondaryTextStyle(color: primaryColor),
                        ).paddingTop(4).visible(isCoupons),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                isCoupons ? status : appLocalization.translate('lbl_apply'),
                style: primaryTextStyle(color: primaryColor),
              ).onTap(() {
                setState(() {
                  if (isCoupons) {
                    isCoupons = !isCoupons;
                    mDiscountInfo = null;
                    loadShippingMethod();
                  } else {
                    _navigateAndDisplaySelection(context);
                  }
                });
              }),
            ],
          ).paddingAll(spacing_standard_new.toDouble()),
        ],
      );
    }

    Widget mCouponInformation() {
      if (mDiscountInfo != null) {
        return mCouponInfo("Applied Coupon: " + mDiscountInfo['code'], appLocalization.translate('lbl_remove'));
      } else {
        return mCouponInfo(appLocalization.translate('lbl_coupon_code'), appLocalization.translate('lbl_apply'));
      }
    }

    Widget mDiscount(var text, var value) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(isCoupons ? text : "Coupon Discount", style: secondaryTextStyle(size: textSizeMedium)),
          Row(
            children: [
              Text("-", style: primaryTextStyle(color: primaryColor)),
              PriceWidget(price: isCoupons ? value : '0', size: textSizeMedium.toDouble(), color: primaryColor),
            ],
          ),
        ],
      );
    }

    Widget mDiscountLabelCondition() {
      if (mDiscountInfo != null) {
        log('discount' + mDiscountInfo.toString());
        var type = mDiscountInfo['discount_type'];
        log(type);
        switch (type) {
          case "percent":
            {
              mTotalDiscount = ((mTotalCount * double.parse(mDiscountInfo['amount'])) / 100);
              mDiscountedAmount = mTotalCount - mTotalDiscount;
              return mDiscount('Coupon Discount' + ' (' + mDiscountInfo['amount'] + '% off)', mTotalDiscount);
            }
            break;

          case "fixed_cart":
            {
              mTotalDiscount = double.parse(mDiscountInfo['amount']);
              mDiscountedAmount = mTotalCount - mTotalDiscount;
              return mDiscount('Coupon Discount (Flat ' + mDiscountInfo['amount'].toString() + '% off)', mTotalDiscount);
            }
            break;
          case "fixed_product":
            {
              var finalAmount = mDiscountInfo['amount'].split(".");
              mTotalDiscount = (int.parse(finalAmount[0]) * (mCartModelList.length)).toDouble();
              mDiscountedAmount = mTotalCount - mTotalDiscount;
              return mDiscount('Coupon Discount', mTotalDiscount);
            }
            break;

          default:
            {
              mTotalDiscount = mDiscountInfo['amount'];
              mDiscountedAmount = mTotalCount - mTotalDiscount;
              return mDiscount('Coupon Discount (Flat ' + mDiscountInfo['amount'] + ' off)', mTotalDiscount);
            }
            break;
        }
      } else {
        mTotalDiscount = 0;
        return mDiscount('Coupon Discount ', "0");
      }
    }

    Widget mPaymentInfo() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(thickness: 6, color: Theme.of(context).textTheme.headline4.color),
          16.height,
          Row(
            children: [Text(appLocalization.translate('lbl_price_detail'), style: boldTextStyle()), 2.width, Text("(" + mCartModelList.length.toString() + " Items)", style: boldTextStyle())],
          ),
          8.height,
          Divider(),
          8.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(appLocalization.translate('lbl_total_mrp'), style: secondaryTextStyle(size: textSizeMedium)), PriceWidget(price: mTotalMrp, color: Theme.of(context).textTheme.subtitle1.color, size: 16)],
          ),
          4.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(appLocalization.translate('lbl_discount_on_mrp'), style: secondaryTextStyle(size: textSizeMedium)),
              Row(
                children: [
                  Text("-", style: primaryTextStyle(color: primaryColor)),
                  PriceWidget(price: mTotalMrpDiscount, color: primaryColor, size: 16),
                ],
              )
            ],
          ).visible(mTotalMrpDiscount != 0.0),
          4.height,
          mDiscountLabelCondition().visible(isEnableCoupon == true),
          spacing_control.height,
          shippingMethodResponse != null && shippingMethods != null && shippingMethods.isNotEmpty
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(appLocalization.translate("lbl_Shipping"), style: secondaryTextStyle(size: textSizeMedium)),
                    shippingMethods[selectedShipment].cost != null && shippingMethods[selectedShipment].cost.isNotEmpty
                        ? PriceWidget(price: shippingMethods[selectedShipment].cost, color: Theme.of(context).textTheme.subtitle1.color, size: 16)
                        : Text(appLocalization.translate('lbl_free'), style: boldTextStyle(color: Colors.green))
                  ],
                )
              : SizedBox(),
          Divider(),
          spacing_control.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(appLocalization.translate('lbl_total_amount_'), style: boldTextStyle()),
              PriceWidget(price: getTotalAmount(), size: textSizeMedium.toDouble(), color: Theme.of(context).textTheme.subtitle2.color),
            ],
          ),
          spacing_standard_new.height,
        ],
      ).paddingAll(spacing_middle.toDouble());
    }

    Widget _shipping = getBoolAsync(IS_GUEST_USER) == true || shipping != null && shippingMethodResponse != null
        ? Column(
            children: [
              Divider(thickness: 6, color: Theme.of(context).textTheme.headline4.color),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(appLocalization.translate("lbl_Shipping"), style: boldTextStyle()),
                      Text(appLocalization.translate("lbl_change"), style: secondaryTextStyle(color: primaryColor, size: textSizeSMedium)).onTap(() async {
                        bool isChanged = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditProfileScreen()),
                        );
                        if (isChanged) {
                          setState(() {
                            countryList.clear();
                            mIsLoading = true;
                            shippingMethodResponse = null;
                          });
                          init();
                        }
                        setState(() {});
                      }),
                    ],
                  ),
                  4.height,
                  shippingMethods != null && shippingMethods.isNotEmpty
                      ? Text(
                          "(" + shipping.getAddress() + ")",
                          style: secondaryTextStyle(),
                        ).visible(shipping.getAddress().isNotEmpty)
                      : SizedBox(),
                  shippingMethods != null && shippingMethods.isNotEmpty
                      ? Text(
                          appLocalization.translate('lbl_please_update_shipping_address'),
                          style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle1.color),
                        ).paddingTop(8).visible(shipping.getAddress().isEmpty)
                      : Text(
                          appLocalization.translate('lbl_please_update_shipping_address'),
                          style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle1.color),
                        ).paddingTop(8),
                  shippingMethods != null && shippingMethods.isNotEmpty
                      ? ListView.builder(
                          itemCount: shippingMethods.length,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          padding: EdgeInsets.only(top: 8),
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            Method method = shippingMethods[index];
                            return Container(
                              padding: EdgeInsets.only(top: spacing_control.toDouble(), bottom: spacing_control.toDouble()),
                              child: Row(
                                children: [
                                  Container(
                                    decoration: boxDecorationWithRoundedCorners(borderRadius: radius(4), backgroundColor: selectedShipment == index ? primaryColor : Colors.grey.withOpacity(0.3)),
                                    width: 16,
                                    height: 16,
                                    child: Icon(Icons.done, size: 12, color: Colors.white).visible(selectedShipment == index),
                                  ),
                                  Text(
                                    method.id != "free_shipping" ? method.methodTitle + ":" : method.methodTitle,
                                    style: primaryTextStyle(),
                                  ).paddingLeft(spacing_standard.toDouble()),
                                ],
                              ),
                            ).onTap(() {
                              setState(() {
                                selectedShipment = index;
                              });
                            });
                          })
                      : Text(appLocalization.translate('lbl_free_shipping'), style: boldTextStyle(color: Theme.of(context).textTheme.subtitle1.color)).paddingTop(spacing_standard.toDouble())
                ],
              ).paddingAll(16),
            ],
          )
        : Container();

    Widget mBody = Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.only(bottom: 200),
          child: Column(
            children: [mCartInfo, mCouponInformation().visible(isEnableCoupon == true), _shipping, mPaymentInfo()],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: <BoxShadow>[
                BoxShadow(color: Theme.of(context).hoverColor.withOpacity(0.8), blurRadius: 15.0, offset: Offset(0.0, 0.75)),
              ],
            ),
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PriceWidget(price: getTotalAmount(), size: textSizeMedium.toDouble(), color: Theme.of(context).textTheme.subtitle2.color),
                    8.height,
                    Text(appLocalization.translate('lbl_view_details'), style: primaryTextStyle(color: primaryColor)).onTap(() {
                      _scrollController.animateTo(_scrollController.position.maxScrollExtent, curve: Curves.easeOut, duration: const Duration(milliseconds: 300));
                    })
                  ],
                ).expand(),
                spacing_standard_new.height,
                AppButton(
                  text: appLocalization.translate('lbl_continue'),
                  textStyle: primaryTextStyle(color: white),
                  color: primaryColor,
                  onTap: () async {
                    ShippingLines shippingLine;
                    Method method;
                    if (shippingMethodResponse != null && !mIsLoading && shipping.getAddress().isNotEmpty) {
                      if (shippingMethodResponse != null && shippingMethods.isNotEmpty) {
                        method = shippingMethods[selectedShipment];
                        shippingLine = ShippingLines(methodId: shippingMethods[selectedShipment].id, methodTitle: shippingMethods[selectedShipment].methodTitle, total: shippingMethods[selectedShipment].cost);
                      }
                      OrderSummaryScreen(
                              mCartProduct: mCartModelList,
                              mCouponData: mDiscountInfo != null && isCoupons ? mDiscountInfo['code'] : '',
                              mPrice: getTotalAmount().toString(),
                              shippingLines: shippingLine,
                              method: method,
                              subtotal: mTotalMrp,
                              discount: isCoupons ? mTotalDiscount : 0,
                              mRPDiscount: mTotalMrpDiscount)
                          .launch(context);
                    } else {
                      mIsLoading = false;
                      toast(appLocalization.translate('lbl_please_add_shipping_details'));
                      bool isChanged = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditProfileScreen()),
                      );
                      if (isChanged) {
                        setState(() {
                          countryList.clear();
                          mIsLoading = true;
                          shippingMethodResponse = null;
                        });
                        init();
                      }
                      setState(() {});
                    }
                  },
                ).expand(),
              ],
            ).paddingAll(16),
          ),
        )
      ],
    ).visible(mCartModelList.isNotEmpty);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: mTop(context, appLocalization.translate('lbl_my_cart'), showBack: widget.isShowBack ? true : false),
        body: mErrorMsg.isEmpty
            ? mCartModelList.isNotEmpty
                ? Stack(
                    alignment: Alignment.center,
                    children: <Widget>[mBody, mProgress().center().visible(mIsLoading)],
                  )
                : Center(child: mProgress())
            : Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Image.asset(ic_shopping_cart, height: 80, width: 80, color: primaryColor),
                20.height,
                Text(appLocalization.translate("msg_empty_basket"), style: primaryTextStyle(size: 22), textAlign: TextAlign.center).paddingOnly(left: 20, right: 20),
                30.height,
                Container(
                        width: context.width(),
                        child: AppButton(
                            width: context.width(),
                            text: appLocalization.translate('lbl_start_shopping'),
                            textStyle: primaryTextStyle(color: white),
                            color: primaryColor,
                            onTap: () {
                              DashBoardScreen().launch(context);
                            }).paddingAll(spacing_standard_new.toDouble()))
                    .paddingOnly(left: 20, right: 20),
              ])),
      ),
    );
  }

  // ignore: missing_return
  bool shouldApply(Method method) {
    if (method.enabled == "yes") {
      if (method.id == "free_shipping") {
        if (method.requires.isEmpty) {
          return true;
        } else {
          if (method.requires == "min_amount") {
            return freeShippingOnMinAmount(method);
          } else if (method.requires == "coupon") {
            return freeShippingOnCoupon(method);
          } else if (method.requires == "either") {
            return freeShippingOnMinAmount(method) == true || freeShippingOnCoupon(method) == true;
          } else if (method.requires == "both") {
            return freeShippingOnMinAmount(method) == true && freeShippingOnCoupon(method) == true;
          }
        }
      } else {
        return true;
      }
    } else {
      return false;
    }
  }

  bool freeShippingOnMinAmount(Method method) {
    return isCoupons
        ? method.instanceSettings.ignoreDiscounts == "yes"
            ? mTotalCount >= double.parse(method.minAmount)
            : mDiscountedAmount >= double.parse(method.minAmount)
        : mTotalCount >= double.parse(method.minAmount);
  }

  bool freeShippingOnCoupon(Method method) {
    if (isCoupons && mDiscountInfo != null) {
      return mDiscountInfo['free_shipping'];
    } else {
      return false;
    }
  }
}
