import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../utils/colors.dart';
import '../../../cubit/home_cubit.dart';

class LoanDirectionScreen extends StatefulWidget {
  final HomeCubit homeCubit;
  const LoanDirectionScreen({
    super.key,
    required this.homeCubit,
  });

  @override
  State<LoanDirectionScreen> createState() => _LoanDirectionScreenState();
}

class _LoanDirectionScreenState extends State<LoanDirectionScreen> {
  late String wayType;
  late String wayNumber;
  late String wayNumber2;
  late String wayNumber3;
  late String interior;
  late String additionalInfo;
  late String city;
  bool _isCustomWayType = false;

  final TextEditingController _customWayTypeController = TextEditingController();
  late final TextEditingController _wayNumberController;
  late final TextEditingController _wayNumber2Controller;
  late final TextEditingController _wayNumber3Controller;
  late final TextEditingController _interiorController;
  late final TextEditingController _additionalInfoController;

  static const _knownWayTypes = [
    'Avenida', 'Calle', 'Carrera', 'Circular', 'Diagonal', 'Transversal'
  ];

  @override
  void initState() {
    super.initState();
    final info = widget.homeCubit.state.loanInformation;
    final savedWayType = info.directionWayType;
    final isCustom = savedWayType.isNotEmpty && !_knownWayTypes.contains(savedWayType);

    wayType = savedWayType.isEmpty ? 'Avenida' : savedWayType;
    wayNumber = info.directionWayNumber;
    wayNumber2 = info.directionWayNumber2;
    wayNumber3 = info.directionWayNumber3;
    interior = info.directionInterior;
    additionalInfo = info.directionAdditionalInfo;
    city = info.directionCity.isEmpty ? 'Medellín' : info.directionCity;
    _isCustomWayType = isCustom;

    _wayNumberController = TextEditingController(text: wayNumber);
    _wayNumber2Controller = TextEditingController(text: wayNumber2);
    _wayNumber3Controller = TextEditingController(text: wayNumber3);
    _interiorController = TextEditingController(text: interior);
    _additionalInfoController = TextEditingController(text: additionalInfo);
    if (isCustom) {
      _customWayTypeController.text = wayType;
    }
  }

  @override
  void dispose() {
    _customWayTypeController.dispose();
    _wayNumberController.dispose();
    _wayNumber2Controller.dispose();
    _wayNumber3Controller.dispose();
    _interiorController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  Widget _label(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: RichText(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
            letterSpacing: 0.5,
          ),
          children: required
              ? [
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: Color.fromRGBO(47, 255, 0, 1),
                      fontSize: 12,
                    ),
                  )
                ]
              : [],
        ),
      ),
    );
  }

  Widget _inputBox({required Widget child}) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      bloc: widget.homeCubit,
      builder: (BuildContext context, HomeState state) {
        return Scaffold(
          drawerEnableOpenDragGesture: false,
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: false,
          floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
          floatingActionButton: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: FloatingActionButton(
              shape: const CircleBorder(),
              backgroundColor: UIColors.primeraGrey.withOpacity(0.15),
              onPressed: () => context.pop(),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 35),
            ),
          ),
          body: _body(context, state),
        );
      },
    );
  }

  Widget _body(BuildContext context, HomeState state) {
    return Container(
      decoration: const BoxDecoration(color: Color.fromARGB(255, 6, 16, 0)),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 30,
        right: 30,
      ),
      height: MediaQuery.sizeOf(context).height,
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 70),
          const Text(
            'Dirección de residencia',
            style: TextStyle(
              fontFamily: "Unbounded",
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),

          // Fila 1: Tipo de vía + Número de vía
          _label('Tipo de vía', required: true),
          Row(
            children: [
              Expanded(
                child: _inputBox(
                  child: _isCustomWayType
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _customWayTypeController,
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: 'Ej: Diagonal, Circular...',
                                  hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.35),
                                    fontSize: 13,
                                  ),
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(color: Colors.white),
                                onChanged: (value) => wayType = value,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isCustomWayType = false;
                                  wayType = 'Avenida';
                                  _customWayTypeController.clear();
                                });
                              },
                              child: Icon(Icons.close,
                                  color: Colors.white.withOpacity(0.4),
                                  size: 18),
                            ),
                          ],
                        )
                      : DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            dropdownColor: const Color.fromARGB(255, 15, 25, 10),
                            value: wayType,
                            isExpanded: true,
                            icon: Icon(Icons.keyboard_arrow_down,
                                color: Colors.white.withOpacity(0.5)),
                            items: ['Avenida', 'Calle', 'Carrera', 'Circular', 'Diagonal', 'Transversal', 'Otra']
                                .map((v) => DropdownMenuItem(
                                      value: v,
                                      child: Text(v,
                                          style: const TextStyle(color: Colors.white)),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value == 'Otra') {
                                setState(() {
                                  _isCustomWayType = true;
                                  wayType = '';
                                });
                              } else if (value != null) {
                                setState(() => wayType = value);
                              }
                            },
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _inputBox(
                  child: TextField(
                    controller: _wayNumberController,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                    ],
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: 'Número',
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.35)),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) => setState(() => wayNumber = value),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Fila 2: Numeración
          _label('Numeración', required: true),
          Row(
            children: [
              Expanded(
                child: _inputBox(
                  child: TextField(
                    controller: _wayNumber2Controller,
                    onChanged: (value) => setState(() => wayNumber2 = value),
                    decoration: InputDecoration(
                      hintText: '# Principal',
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.35)),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _inputBox(
                  child: TextField(
                    controller: _wayNumber3Controller,
                    onChanged: (value) => setState(() => wayNumber3 = value),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                    ],
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: '# Secundario',
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.35)),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Interior
          _label('Interior'),
          _inputBox(
            child: TextField(
              controller: _interiorController,
              onChanged: (value) => interior = value,
              decoration: InputDecoration(
                hintText: 'Apartamento, Casa, Piso',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
                border: InputBorder.none,
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),

          // Referencia
          _label('Referencia'),
          Container(
            constraints: const BoxConstraints(minHeight: 56, maxHeight: 120),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: TextField(
              controller: _additionalInfoController,
              onChanged: (value) => additionalInfo = value,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: 'Ayúdanos a encontrar tu dirección',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),

          // Ciudad
          _label('Ciudad'),
          _inputBox(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: const Color.fromARGB(255, 15, 25, 10),
                value: 'Medellín',
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down,
                    color: Colors.white.withOpacity(0.5)),
                items: ['Medellín']
                    .map((v) => DropdownMenuItem(
                          value: v,
                          child: Text(v,
                              style: const TextStyle(color: Colors.white)),
                        ))
                    .toList(),
                onChanged: (value) {},
              ),
            ),
          ),

          const Spacer(),

          GestureDetector(
            onTap: () {
              final isValid = wayType.isNotEmpty &&
                  wayNumber.isNotEmpty &&
                  wayNumber2.isNotEmpty &&
                  wayNumber3.isNotEmpty;
              if (!isValid) return;
              widget.homeCubit.updateDirectionParts(
                wayType: wayType,
                wayNumber: wayNumber,
                wayNumber2: wayNumber2,
                wayNumber3: wayNumber3,
                interior: interior,
                additionalInfo: additionalInfo,
                city: city,
              );
              context.pop();
            },
            child: Builder(builder: (context) {
              final enabled = wayType.isNotEmpty &&
                  wayNumber.isNotEmpty &&
                  wayNumber2.isNotEmpty &&
                  wayNumber3.isNotEmpty;
              return Container(
              height: 62,
              decoration: BoxDecoration(
                color: enabled
                    ? const Color.fromRGBO(47, 255, 0, 1)
                    : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(48),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Text(
                      'Aceptar',
                      style: TextStyle(
                        color: enabled ? Colors.black : Colors.white.withOpacity(0.3),
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
                        color: enabled
                            ? const Color.fromRGBO(255, 255, 255, 0.5)
                            : Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Icon(Icons.check_circle_outline,
                          color: enabled ? Colors.black : Colors.white.withOpacity(0.3),
                          size: 30),
                    ),
                  ),
                ],
              ),
            );
            }),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
