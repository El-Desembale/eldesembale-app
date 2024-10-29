import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/auth/cubit/auth_cubit.dart';
import '../../../../config/routes/routes.dart';
import '../../../../core/di/injection_dependency.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/images.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Drawer build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 6, 16, 0),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.05,
                ),
                Row(
                  children: [
                    const SizedBox(width: 25),
                    FloatingActionButton(
                      shape: const CircleBorder(),
                      backgroundColor: UIColors.primeraGrey.withOpacity(0.15),
                      onPressed: () {
                        context.pop();
                      },
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.03,
                ),
                _drawerItem(
                  "Mi cuenta",
                  AssetImages.person,
                  () {},
                ),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.01,
                ),
                _drawerItem(
                  "Mis solcitudes",
                  AssetImages.request,
                  () {
                    context.push(AppRoutes.loansList);
                  },
                ),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.01,
                ),
                _drawerItem(
                  "Cerrar sesión",
                  AssetImages.back,
                  () {
                    sl<AuthCubit>(instanceName: 'auth').logout();
                    context.go(AppRoutes.login);
                  },
                ),
              ],
            ),
          ),
          Container(
            width: 3,
            color: Colors.white.withOpacity(0.35),
          )
        ],
      ),
    );
  }

  static Widget _drawerItem(String title, String icon, void Function()? onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 5,
      ),
      leading: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(
          icon,
          height: 28,
          width: 28,
        ),
      ),
      title: Text(
        title,
        textAlign: TextAlign.start,
        style: const TextStyle(
          fontFamily: "Unbounded",
          color: Colors.white,
          fontSize: 18,
        ),
      ),
      onTap: onTap,
    );
  }
}
