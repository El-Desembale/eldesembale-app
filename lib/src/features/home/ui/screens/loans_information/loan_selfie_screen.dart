// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../utils/colors.dart';

class LoanSelfieScreen extends StatefulWidget {
  final void Function(File) addFile;
  const LoanSelfieScreen({
    super.key,
    required this.addFile,
  });

  @override
  State<LoanSelfieScreen> createState() => _LoanSelfieScreenState();
}

class _LoanSelfieScreenState extends State<LoanSelfieScreen> {
  CameraController? _cameraController;

  bool _isCameraInitialized = false;
  XFile? picture;
  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    List<CameraDescription> cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      CameraDescription cam = cameras.firstWhere(
        (element) => element.lensDirection == CameraLensDirection.front,
      );
      _cameraController = CameraController(
        cam,
        ResolutionPreset.medium,
      );
      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  Future<void> takePicture() async {
    if (!_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final pic = await _cameraController!.takePicture();
      picture = pic;
      setState(() {});
    } catch (_) {}
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: UIColors.primeraGrey.withOpacity(0.15),
          onPressed: () {
            context.pop();
          },
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 35,
          ),
        ),
      ),
      body: _isCameraInitialized
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  const Text(
                    "Asegúrate de que se vean bien todos los datos y la fotografía",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  ClipOval(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.height * 0.5,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 2),
                        borderRadius: BorderRadius.circular(1),
                      ),
                      child: picture != null
                          ? Image.file(File(picture!.path), fit: BoxFit.cover)
                          : CameraPreview(_cameraController!),
                    ),
                  ),
                  const Spacer(),
                  if (picture == null)
                    Center(
                      child: GestureDetector(
                        onTap: takePicture,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(48),
                            color: Color.fromRGBO(47, 255, 0, 1),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(48),
                              color: const Color.fromRGBO(255, 255, 255, 0.5),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.black,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (picture != null)
                    GestureDetector(
                      onTap: () {
                        picture = null;
                        setState(() {});
                      },
                      child: Container(
                        height: 62,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(48),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 25),
                              child: Text(
                                'Tomar fotografía de nuevo',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Container(
                                width: 72,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 47, 255, 0)
                                      .withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                child: const Icon(
                                  Icons.replay_outlined,
                                  color: Colors.black,
                                  size: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (picture != null) Container(height: 20),
                  if (picture != null)
                    GestureDetector(
                      onTap: () {
                        widget.addFile(File(picture!.path));
                        context.pop();
                      },
                      child: Container(
                        height: 62,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(47, 255, 0, 1),
                          borderRadius: BorderRadius.circular(48),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 25),
                              child: Text(
                                'Aceptar',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Container(
                                width: 62,
                                height: 50,
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromRGBO(255, 255, 255, 0.5),
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                child: const Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.black,
                                  size: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const Spacer(),
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
