import "package:flutter/foundation.dart";
import "package:latlong2/latlong.dart";

String? downloadedFrom;

String appVersion = "0.0.0";
const bool debugBuild = false;

bool get flowDebugMode => kDebugMode || debugBuild;

final Uri maintainerKoFiLink = Uri.parse("https://flow.gege.mn/donate");
final Uri website = Uri.parse("https://flow.gege.mn");
final Uri guideUrl = Uri.parse("https://flow.gege.mn/docs");


const double sukhbaatarSquareCenterLat = 47.918828;
const double sukhbaatarSquareCenterLong = 106.917604;

const String appleAppStoreId = "6477741670";

/// Consumable "tip the creator" in-app purchase product IDs.
///
/// These must match the products configured in App Store Connect exactly.
/// Tips unlock nothing — they exist purely to support development. iOS only.
const String tipSmallProductId = "mn.flow.flow.tip.small";
const String tipMediumProductId = "mn.flow.flow.tip.medium";
const String tipLargeProductId = "mn.flow.flow.tip.large";

const Set<String> tipProductIds = {
  tipSmallProductId,
  tipMediumProductId,
  tipLargeProductId,
};

final Uri csvImportTemplateUrl = Uri.parse(
  "https://docs.google.com/spreadsheets/d/1wxdJ1T8PSvzayxvGs7bVyqQ9Zu0DPQ1YwiBLy1FluqE/edit?usp=sharing",
);

const LatLng sukhbaatarSquareCenter = LatLng(
  sukhbaatarSquareCenterLat,
  sukhbaatarSquareCenterLong,
);

const String iOSAppGroupId = "group.mn.flow.flow";
