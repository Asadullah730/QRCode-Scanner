import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:qrcode/apis.dart';
import 'package:url_launcher/url_launcher.dart';

class QRCodeScanner extends StatefulWidget {
  const QRCodeScanner({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRCodeScannerState();
}

class _QRCodeScannerState extends State<QRCodeScanner> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String? scannedcode;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (result != null)
                    InkWell(
                      onTap: () {
                        setState(() {
                          scannedcode = result!.code;
                        });
                        getProduct(
                          scannedcode!,
                        ); // get the product Details using QR code
                        // _openlink(scannedcode!);
                      },
                      child: Text(
                        'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}',

                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.blue,
                        ),
                      ),
                    )
                  else
                    InkWell(
                      onTap:
                          () => _openlink(
                            "https://github.com/Asadullah730/QRCode-Scanner",
                          ),
                      child: Container(
                        height: MediaQuery.of(context).size.width * 0.3,
                        width: MediaQuery.of(context).size.width * 0.5,
                        alignment: Alignment.center,
                        child: const Text(
                          'Qr Code Scanner',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      // Container(
                      //   margin: const EdgeInsets.all(8),
                      //   child: ElevatedButton(
                      //     onPressed: () async {
                      //       await controller?.toggleFlash();
                      //       setState(() {});
                      //     },
                      //     child: FutureBuilder(
                      //       future: controller?.getFlashStatus(),
                      //       builder: (context, snapshot) {
                      //         if (kDebugMode) {
                      //           print("FLASH DATA :${snapshot.data}");
                      //         }
                      //         return Text('Flash: ${snapshot.data}');
                      //       },
                      //     ),
                      //   ),
                      // ),
                      // Container(
                      //   margin: const EdgeInsets.all(8),
                      //   child: ElevatedButton(
                      //     onPressed: () async {
                      //       await controller?.flipCamera();
                      //       setState(() {});
                      //     },
                      //     child: FutureBuilder(
                      //       future: controller?.getCameraInfo(),
                      //       builder: (context, snapshot) {
                      //         if (snapshot.data != null) {
                      //           return Text(
                      //             'Camera facing ${describeEnum(snapshot.data!)}',
                      //           );
                      //         } else {
                      //           return const Text('loading');
                      //         }
                      //       },
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   crossAxisAlignment: CrossAxisAlignment.center,
                  //   children: <Widget>[
                  //     Container(
                  //       margin: const EdgeInsets.all(8),
                  //       child: ElevatedButton(
                  //         onPressed: () async {
                  //           await controller?.pauseCamera();
                  //         },
                  //         child: const Text(
                  //           'pause',
                  //           style: TextStyle(fontSize: 20),
                  //         ),
                  //       ),
                  //     ),
                  //     Container(
                  //       margin: const EdgeInsets.all(8),
                  //       child: ElevatedButton(
                  //         onPressed: () async {
                  //           await controller?.resumeCamera();
                  //         },
                  //         child: const Text(
                  //           'resume',
                  //           style: TextStyle(fontSize: 20),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea =
        (MediaQuery.of(context).size.width < 400 ||
                MediaQuery.of(context).size.height < 400)
            ? 150.0
            : 400.0;

    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p' as num);
    if (!p) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('no Permission')));
    }
  }

  void _openlink(String uri) async {
    final Uri url = Uri.parse(uri);

    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication, // Forces browser
    )) {
      throw Exception('Could not launch $url');
    }
  }
}
