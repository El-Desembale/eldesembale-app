import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../utils/colors.dart';

import '../../../cubit/home_cubit.dart';
import '../../../data/entities/loan_information_entity.dart';

class LoanRefencesScreen extends StatefulWidget {
  final HomeCubit homeCubit;
  const LoanRefencesScreen({
    super.key,
    required this.homeCubit,
  });

  @override
  State<LoanRefencesScreen> createState() => _LoanRefencesScreenState();
}

class _LoanRefencesScreenState extends State<LoanRefencesScreen> {
  PageController _pageController = PageController();
  String firstReferenceRelationship = '';
  String firstOtherRelationship = '';
  int firstPhoneNumber = 0;

  String secondReferenceRelationship = '';
  String secondOtherRelationship = '';
  int secondPhoneNumber = 0;

  List<String> relationshipList = [
    'Madre',
    'Padre',
    'Hermano (a)',
    'Amigo (a)',
    'Otro',
  ];
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
              onPressed: () {
                if (_pageController.hasClients) {
                  if (_pageController.page == 0) {
                    context.pop();
                  } else {
                    _pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  }
                }
              },
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 35,
              ),
            ),
          ),
          body: _body(context, state),
        );
      },
    );
  }

  Widget _body(BuildContext context, HomeState state) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 6, 16, 0),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 30,
        right: 30,
      ),
      height: MediaQuery.sizeOf(context).height,
      width: MediaQuery.sizeOf(context).width,
      child: PageView(
        controller: _pageController,
        children: [
          ListView(
            children: [
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.09),
              const Text(
                'Primera Referencia',
                style: TextStyle(
                  fontFamily: "Unbounded",
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),
              Column(
                children: List.generate(
                  relationshipList.length,
                  (index) => GestureDetector(
                    onTap: () {
                      if (firstReferenceRelationship ==
                          relationshipList[index]) {
                        firstReferenceRelationship = '';
                      } else {
                        firstReferenceRelationship = relationshipList[index];
                        // Si la segunda referencia es igual, limpiarla
                        if (secondReferenceRelationship == firstReferenceRelationship &&
                            firstReferenceRelationship != 'Otro') {
                          secondReferenceRelationship = '';
                          secondPhoneNumber = 0;
                        }
                      }
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 21, 28, 16),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: firstReferenceRelationship ==
                                  relationshipList[index]
                              ? Colors.white
                              : Colors.transparent,
                        ),
                      ),
                      child: Center(
                        child: Row(
                          children: [
                            Text(
                              relationshipList[index],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            firstReferenceRelationship ==
                                    relationshipList[index]
                                ? const Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: Colors.white,
                                    size: 30,
                                  )
                                : const Icon(
                                    Icons.circle_outlined,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),
              if (firstReferenceRelationship == 'Otro')
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(22.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                        size: 30,
                      ),
                      const SizedBox(width: 15.0),
                      Expanded(
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '¿Qué otro?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                            ),
                          ),
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Ingrese el nombre',
                              hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.6)),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.name,
                            onChanged: (value) {
                              firstOtherRelationship = value;
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 15),
              if (firstReferenceRelationship.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(22.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                      const SizedBox(width: 15.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Teléfono de $firstReferenceRelationship',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'Ingrese el teléfono',
                                hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.6)),
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  firstPhoneNumber = 0;
                                } else {
                                  firstPhoneNumber = int.parse(value);
                                }
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 35),
              Builder(builder: (context) {
                final isFirstValid = firstReferenceRelationship == 'Otro'
                    ? firstOtherRelationship.isNotEmpty && firstPhoneNumber != 0
                    : firstReferenceRelationship.isNotEmpty && firstPhoneNumber != 0;
                return GestureDetector(
                  onTap: () {
                    if (isFirstValid) {
                      _pageController.animateToPage(
                        1,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Container(
                    height: 62,
                    decoration: BoxDecoration(
                      color: isFirstValid
                          ? const Color.fromRGBO(47, 255, 0, 1)
                          : Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(
                            'Continuar',
                            style: TextStyle(
                              color: isFirstValid ? Colors.black : Colors.white24,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Container(
                            width: 46,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isFirstValid
                                  ? Colors.black.withOpacity(0.1)
                                  : Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: isFirstValid ? Colors.black : Colors.white24,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 30),
            ],
          ),
          ListView(
            children: [
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.09),
              const Text(
                'Segunda Referencia',
                style: TextStyle(
                  fontFamily: "Unbounded",
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),
              Column(
                children: List.generate(
                  relationshipList.length,
                  (index) {
                    // No permitir repetir el mismo tipo (excepto "Otro")
                    final item = relationshipList[index];
                    final isDisabled = item != 'Otro' &&
                        item == firstReferenceRelationship;
                    return GestureDetector(
                    onTap: isDisabled ? null : () {
                      if (secondReferenceRelationship ==
                          relationshipList[index]) {
                        secondReferenceRelationship = '';
                      } else {
                        secondReferenceRelationship = relationshipList[index];
                      }
                      setState(() {});
                    },
                    child: Opacity(
                      opacity: isDisabled ? 0.3 : 1.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 20,
                        ),
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 21, 28, 16),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: secondReferenceRelationship ==
                                    relationshipList[index]
                                ? Colors.white
                                : Colors.transparent,
                          ),
                        ),
                        child: Center(
                          child: Row(
                            children: [
                              Text(
                                relationshipList[index],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              secondReferenceRelationship ==
                                      relationshipList[index]
                                  ? const Icon(
                                      Icons.check_circle_outline_rounded,
                                      color: Colors.white,
                                      size: 30,
                                    )
                                  : const Icon(
                                      Icons.circle_outlined,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                  },
                ),
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),
              if (secondReferenceRelationship == 'Otro')
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(22.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                        size: 30,
                      ),
                      const SizedBox(width: 15.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '¿Qué otro?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'Ingrese el nombre',
                                hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.6)),
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.name,
                              onChanged: (value) {
                                secondOtherRelationship = value;
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 15),
              if (secondReferenceRelationship.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(22.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                      const SizedBox(width: 15.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Teléfono de $secondReferenceRelationship',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'Ingrese el teléfono',
                                hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.6)),
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  secondPhoneNumber = 0;
                                } else {
                                  secondPhoneNumber = int.parse(value);
                                }
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 35),
              Builder(builder: (context) {
                final isSecondValid = secondReferenceRelationship == "Otro"
                    ? secondOtherRelationship.isNotEmpty && secondPhoneNumber != 0
                    : secondReferenceRelationship.isNotEmpty && secondPhoneNumber != 0;
                return GestureDetector(
                  onTap: () {
                    if (isSecondValid) {
                      widget.homeCubit.setReferences(
                        LoanReferenceEntity(
                          relationship: firstReferenceRelationship == "Otro"
                              ? firstOtherRelationship
                              : firstReferenceRelationship,
                          phone: firstPhoneNumber,
                        ),
                        LoanReferenceEntity(
                          relationship: secondReferenceRelationship == "Otro"
                              ? secondOtherRelationship
                              : secondReferenceRelationship,
                          phone: secondPhoneNumber,
                        ),
                      );
                      context.pop();
                    }
                  },
                  child: Container(
                    height: 62,
                    decoration: BoxDecoration(
                      color: isSecondValid
                          ? const Color.fromRGBO(47, 255, 0, 1)
                          : Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(
                            'Aceptar',
                            style: TextStyle(
                              color: isSecondValid ? Colors.black : Colors.white24,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Container(
                            width: 46,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isSecondValid
                                  ? Colors.black.withOpacity(0.1)
                                  : Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: isSecondValid ? Colors.black : Colors.white24,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 30),
            ],
          ),
        ],
      ),
    );
  }
}
