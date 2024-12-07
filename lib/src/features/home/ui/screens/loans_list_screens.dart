import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../utils/colors.dart';
import '../../../../utils/images.dart';
import '../../cubit/home_cubit.dart';
import 'loan_info_detail_screen.dart';

class LoansListScreen extends StatefulWidget {
  final HomeCubit homeCubit;
  const LoansListScreen({
    super.key,
    required this.homeCubit,
  });

  @override
  State<LoansListScreen> createState() => _LoansListScreenState();
}

class _LoansListScreenState extends State<LoansListScreen> {
  @override
  void initState() {
    widget.homeCubit.getLoans();
    super.initState();
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
          body: Stack(
            children: [
              _body(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, HomeState state) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 6, 16, 0),
      ),
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 30,
          right: 30,
        ),
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        child: state.isLoading
            ? SizedBox(
                height: MediaQuery.sizeOf(context).height,
                width: MediaQuery.sizeOf(context).width,
                child: const Center(
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(
                      color: Colors.grey,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  const Padding(
                    padding: EdgeInsets.only(left: 25),
                    child: Text(
                      'Solicitudes',
                      style: TextStyle(
                        fontFamily: "Unbounded",
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    flex: 5,
                    child: _loansList(context, state),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
      ),
    );
  }

  Widget _loansList(BuildContext context, HomeState state) {
    return ListView.builder(
      itemCount: state.loans.length,
      itemBuilder: (BuildContext context, int index) {
        final loan = state.loans[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoanInfoDetailScreen(
                  loanIndex: index,
                  homeCubit: widget.homeCubit,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withOpacity(0.16),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.16),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    status(loan.status),
                    const SizedBox(height: 10),
                    Text(
                      NumberFormat("#,##0", "en_US").format(loan.amount),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontFamily: "Unbounded",
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      loan.status == "pending" || loan.status == "rejected"
                          ? "Solicitado ${DateFormat('d/M/y').format(loan.createdAt.toDate())}"
                          : loan.status == "in_disbursement_process"
                              ? DateFormat('d/M/y')
                                  .format(loan.createdAt.toDate())
                              : "Desembolso: ${DateFormat('d/M/y').format(loan.createdAt.toDate())}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "Pago ${loan.paymentPeriod}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      "${loan.installments} cuotas",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget status(String status) {
    Map<String, String> statusMap = {
      "pending": "Pendiente",
      "approved": "Aprobado",
      "rejected": "Rechazado",
      "in_process": "En proceso",
      "in_disbursement_process": "En proceso de desembolso",
    };
    Map<String, Color> statusColorMap = {
      "pending": const Color.fromARGB(255, 130, 101, 0),
      "approved": const Color.fromARGB(255, 3, 130, 0),
      "rejected": Colors.red,
      "in_process": Colors.white,
      "in_disbursement_process": Colors.transparent,
    };

    Map<String, String> statusIconMap = {
      "pending": AssetImages.loanClock,
      "approved": AssetImages.loanCheck,
      "rejected": AssetImages.loanCancel,
      "in_process": AssetImages.loanWaitting,
      "in_disbursement_process": AssetImages.loanCash,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color.fromARGB(255, 243, 248, 241).withOpacity(0.2),
        border: Border.all(
          color: statusColorMap[status] ?? Colors.white,
          width: 3,
        ),
      ),
      child: Row(
        children: [
          SvgPicture.asset(statusIconMap[status] ?? AssetImages.loanWaitting),
          const SizedBox(width: 10),
          Text(
            statusMap[status] ?? "",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
