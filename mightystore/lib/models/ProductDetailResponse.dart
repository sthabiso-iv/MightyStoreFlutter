import 'ProductResponse.dart';

class ProductDetailResponse {
  var id;
  var name;
  var slug;
  var permalink;
  var dateCreated;
  var dateModified;
  var type;
  var status;
  var featured;
  var catalogVisibility;
  var description;
  var shortDescription;
  var sku;
  var price;
  var regularPrice;
  var salePrice;
  var dateOnSaleFrom;
  var dateOnSaleTo;
  var priceHtml;
  var onSale;
  var purchasable;
  var totalSales;
  var virtual;
  var downloadable;
  var downloadLimit;
  var downloadExpiry;
  var downloadType;
  var externalUrl;
  var buttonText;
  var taxStatus;
  var taxClass;
  var manageStock;
  var stockQuantity;
  var inStock;
  var backorders;
  var backordersAllowed;
  var backOrdered;
  var soldIndividually;
  var weight;
  Dimensions dimensions;
  var shippingRequired;
  var shippingTaxable;
  var shippingClass;
  var shippingClassId;
  var reviewsAllowed;
  var averageRating;
  var ratingCount;
  List<int> relatedIds;
  List<int> upSellIds;
  List<int> crossSellIds;
  List<int> variations;
  var parentId;
  var purchaseNote;
  List<Categories> categories;
  List<Images> images;
  List<Attributes> attributes;
  List<UpsellId> upSellId;
  var menuOrder;
  var isAddedCart;
  var isAddedWishList;
  Store store;
  VideoData woofVideoEmbed;

  ProductDetailResponse(
      {this.id,
      this.name,
      this.slug,
      this.permalink,
      this.dateCreated,
      this.dateModified,
      this.type,
      this.status,
      this.featured,
      this.catalogVisibility,
      this.description,
      this.shortDescription,
      this.sku,
      this.price,
      this.regularPrice,
      this.salePrice,
      this.dateOnSaleFrom,
      this.dateOnSaleTo,
      this.priceHtml,
      this.onSale,
      this.purchasable,
      this.totalSales,
      this.virtual,
      this.downloadable,
      this.downloadLimit,
      this.downloadExpiry,
      this.downloadType,
      this.externalUrl,
      this.buttonText,
      this.taxStatus,
      this.taxClass,
      this.manageStock,
      this.stockQuantity,
      this.inStock,
      this.backorders,
      this.backordersAllowed,
      this.backOrdered,
      this.soldIndividually,
      this.weight,
      this.dimensions,
      this.shippingRequired,
      this.shippingTaxable,
      this.shippingClass,
      this.shippingClassId,
      this.reviewsAllowed,
      this.averageRating,
      this.ratingCount,
      this.relatedIds,
      this.upSellIds,
      this.crossSellIds,
      this.parentId,
      this.purchaseNote,
      this.categories,
      this.images,
      this.attributes,
      this.upSellId,
      this.menuOrder,
      this.isAddedCart,
      this.isAddedWishList,
      this.store,
      this.woofVideoEmbed});

  ProductDetailResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    permalink = json['permalink'];
    dateCreated = json['date_created'];
    dateModified = json['date_modified'];
    type = json['type'];
    status = json['status'];
    featured = json['featured'];
    catalogVisibility = json['catalog_visibility'];
    description = json['description'];
    shortDescription = json['short_description'];
    sku = json['sku'];
    price = json['price'];
    regularPrice = json['regular_price'];
    salePrice = json['sale_price'];
    dateOnSaleFrom = json['date_on_sale_from'];
    dateOnSaleTo = json['date_on_sale_to'];
    priceHtml = json['price_html'];
    onSale = json['on_sale'];
    purchasable = json['purchasable'];
    totalSales = json['total_sales'];
    virtual = json['virtual'];
    downloadable = json['downloadable'];
//    if (json['downloads'] != null) {
//      downloads = new List<Null>();
//      json['downloads'].forEach((v) {
//        downloads.add(new Null.fromJson(v));
//      });
//    }
    downloadLimit = json['download_limit'];
    downloadExpiry = json['download_expiry'];
    downloadType = json['download_type'];
    externalUrl = json['external_url'];
    buttonText = json['button_text'];
    taxStatus = json['tax_status'];
    taxClass = json['tax_class'];
    manageStock = json['manage_stock'];
    stockQuantity = json['stock_quantity'];
    inStock = json['in_stock'];
    backorders = json['backorders'];
    backordersAllowed = json['backorders_allowed'];
    backOrdered = json['backordered'];
    soldIndividually = json['sold_individually'];
    weight = json['weight'];
    dimensions = json['dimensions'] != null ? new Dimensions.fromJson(json['dimensions']) : null;
    shippingRequired = json['shipping_required'];
    shippingTaxable = json['shipping_taxable'];
    shippingClass = json['shipping_class'];
    shippingClassId = json['shipping_class_id'];
    reviewsAllowed = json['reviews_allowed'];
    averageRating = json['average_rating'];
    ratingCount = json['rating_count'];

    relatedIds = json['related_ids'] != null ? new List<int>.from(json['related_ids']) : null;
    upSellIds = json['upsell_ids'] != null ? new List<int>.from(json['upsell_ids']) : null;
    crossSellIds = json['cross_sell_ids'] != null ? new List<int>.from(json['cross_sell_ids']) : null;
    parentId = json['parent_id'];
    purchaseNote = json['purchase_note'];
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((v) {
        categories.add(new Categories.fromJson(v));
      });
    }

    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images.add(new Images.fromJson(v));
      });
    }
    if (json['attributes'] != null) {
      attributes = <Attributes>[];
      json['attributes'].forEach((v) {
        attributes.add(new Attributes.fromJson(v));
      });
    }

    variations = json['variations'] != null ? new List<int>.from(json['variations']) : null;

    if (json['upsell_id'] != null) {
      upSellId = <UpsellId>[];
      json['upsell_id'].forEach((v) {
        upSellId.add(new UpsellId.fromJson(v));
      });
    }

    menuOrder = json['menu_order'];
    isAddedCart = json['is_added_cart'];
    isAddedWishList = json['is_added_wishlist'];
    store = json['store'] != null ? new Store.fromJson(json['store']) : null;
    woofVideoEmbed =  json['woofv_video_embed'] != null ? VideoData.fromJson(json['woofv_video_embed']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['slug'] = this.slug;
    data['permalink'] = this.permalink;
    data['date_created'] = this.dateCreated;
    data['date_modified'] = this.dateModified;
    data['type'] = this.type;
    data['status'] = this.status;
    data['featured'] = this.featured;
    data['catalog_visibility'] = this.catalogVisibility;
    data['description'] = this.description;
    data['short_description'] = this.shortDescription;
    data['sku'] = this.sku;
    data['price'] = this.price;
    data['regular_price'] = this.regularPrice;
    data['sale_price'] = this.salePrice;
    data['date_on_sale_from'] = this.dateOnSaleFrom;
    data['date_on_sale_to'] = this.dateOnSaleTo;
    data['price_html'] = this.priceHtml;
    data['on_sale'] = this.onSale;
    data['purchasable'] = this.purchasable;
    data['total_sales'] = this.totalSales;
    data['virtual'] = this.virtual;
    data['downloadable'] = this.downloadable;
//    if (this.downloads != null) {
//      data['downloads'] = this.downloads.map((v) => v.toJson()).toList();
//    }
    data['download_limit'] = this.downloadLimit;
    data['download_expiry'] = this.downloadExpiry;
    data['download_type'] = this.downloadType;
    data['external_url'] = this.externalUrl;
    data['button_text'] = this.buttonText;
    data['tax_status'] = this.taxStatus;
    data['tax_class'] = this.taxClass;
    data['manage_stock'] = this.manageStock;
    data['stock_quantity'] = this.stockQuantity;
    data['in_stock'] = this.inStock;
    data['backorders'] = this.backorders;
    data['backorders_allowed'] = this.backordersAllowed;
    data['backordered'] = this.backOrdered;
    data['sold_individually'] = this.soldIndividually;
    data['weight'] = this.weight;
    if (this.dimensions != null) {
      data['dimensions'] = this.dimensions.toJson();
    }
    data['shipping_required'] = this.shippingRequired;
    data['shipping_taxable'] = this.shippingTaxable;
    data['shipping_class'] = this.shippingClass;
    data['shipping_class_id'] = this.shippingClassId;
    data['reviews_allowed'] = this.reviewsAllowed;
    data['average_rating'] = this.averageRating;
    data['rating_count'] = this.ratingCount;
    data['related_ids'] = this.relatedIds;
    data['upsell_ids'] = this.upSellIds;
    data['cross_sell_ids'] = this.crossSellIds;
    data['variations'] = this.variations;
    data['parent_id'] = this.parentId;
    data['purchase_note'] = this.purchaseNote;
    if (this.categories != null) {
      data['categories'] = this.categories.map((v) => v.toJson()).toList();
    }
//    if (this.tags != null) {
//      data['tags'] = this.tags.map((v) => v.toJson()).toList();
//    }
    if (this.images != null) {
      data['images'] = this.images.map((v) => v.toJson()).toList();
    }
    if (this.attributes != null) {
      data['attributes'] = this.attributes.map((v) => v.toJson()).toList();
    }
//    if (this.defaultAttributes != null) {
//      data['default_attributes'] =
//          this.defaultAttributes.map((v) => v.toJson()).toList();
//    }

//    if (this.groupedProducts != null) {
//      data['grouped_products'] =
//          this.groupedProducts.map((v) => v.toJson()).toList();
//    }
    if (this.upSellId != null) {
      data['upsell_id'] = this.upSellId.map((v) => v.toJson()).toList();
    }
    data['menu_order'] = this.menuOrder;
    data['is_added_cart'] = this.isAddedCart;
    data['is_added_wishlist'] = this.isAddedWishList;
    if (this.store != null) {
      data['store'] = this.store.toJson();
    }
    if (this.woofVideoEmbed != null) {
      data['woofv_video_embed'] = this.woofVideoEmbed.toJson();
    }
    return data;
  }
}

class Dimensions {
  var length;
  var width;
  var height;

  Dimensions({this.length, this.width, this.height});

  Dimensions.fromJson(Map<String, dynamic> json) {
    length = json['length'];
    width = json['width'];
    height = json['height'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['length'] = this.length;
    data['width'] = this.width;
    data['height'] = this.height;
    return data;
  }
}

class Categories {
  var id;
  var name;
  var slug;

  Categories({this.id, this.name, this.slug});

  Categories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['slug'] = this.slug;
    return data;
  }
}

class Images {
  var id;
  var dateCreated;
  var dateModified;
  String src;
  var name;
  var alt;
  var position;

  Images({this.id, this.dateCreated, this.dateModified, this.src, this.name, this.alt, this.position});

  Images.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    dateCreated = json['date_created'];
    dateModified = json['date_modified'];
    src = json['src'];
    name = json['name'];
    alt = json['alt'];
    position = json['position'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['date_created'] = this.dateCreated;
    data['date_modified'] = this.dateModified;
    data['src'] = this.src;
    data['name'] = this.name;
    data['alt'] = this.alt;
    data['position'] = this.position;
    return data;
  }
}

class Attributes {
  var id;
  var name;
  var position;
  var visible;
  var variation;
  List<String> options;
  String option;

  Attributes({this.id, this.name, this.position, this.visible, this.variation, this.option, this.options});

//  Attributes.fromJson(Map<String, dynamic> json) {
//    id = json['id'];
//    name = json['name'];
//    position = json['position'];
//    visible = json['visible'];
//    variation = json['variation'];
//    options = json['options'] != null
//        ? new List<String>.from(json['options'])
//        : null;
//  }
  factory Attributes.fromJson(Map<String, dynamic> json) {
    return Attributes(
      id: json['id'],
      name: json['name'],
      position: json['position'],
      visible: json['visible'],
      variation: json['variation'],
      option: json['option'],
      options: json['options'] != null ? new List<String>.from(json['options']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['position'] = this.position;
    data['visible'] = this.visible;
    data['variation'] = this.variation;
    data['option'] = this.option;
    if (this.options != null) {
      data['options'] = this.options;
    }
    return data;
  }
}

class UpsellId {
  var id;
  var name;
  var slug;
  var price;
  var regularPrice;
  var salePrice;
  List<Images> images;

  UpsellId({this.id, this.name, this.slug, this.price, this.regularPrice, this.salePrice, this.images});

  UpsellId.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    price = json['price'];
    regularPrice = json['regular_price'];
    salePrice = json['sale_price'];
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images.add(new Images.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['slug'] = this.slug;
    data['price'] = this.price;
    data['regular_price'] = this.regularPrice;
    data['sale_price'] = this.salePrice;
    if (this.images != null) {
      data['images'] = this.images.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VideoData {
  bool autoplay;
  String poster;
  String thumbnail;
  String url;

  VideoData({this.autoplay, this.poster, this.thumbnail, this.url});

  factory VideoData.fromJson(Map<String, dynamic> json) {
    return VideoData(
      autoplay: json['autoplay'],
      poster: json['poster'],
      thumbnail: json['thumbnail'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['autoplay'] = this.autoplay;
    data['poster'] = this.poster;
    data['thumbnail'] = this.thumbnail;
    data['url'] = this.url;
    return data;
  }
}
