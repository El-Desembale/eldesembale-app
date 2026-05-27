import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/auth/cubit/auth_cubit.dart';
import '../../../../config/routes/routes.dart';
import '../../../../core/di/injection_dependency.dart';
import '../../../../core/preferences/shared_preference.dart';
import '../../../../utils/design_tokens.dart';
import '../../../../utils/images.dart';
import '../../../shared/widgets/back_circle_button.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Drawer build(BuildContext context) {
    return Drawer(
      backgroundColor: kBgScreen,
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
                    BackCircleButton(
                      heroTag: 'drawer_fab',
                      onPressed: () {
                        context.pop();
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.03,
                ),
                _drawerItem(
                  "Mi cuenta",
                  AssetImages.person,
                  () {
                    context.push(AppRoutes.accountInformation);
                  },
                ),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.01,
                ),
                _drawerItem(
                  "Mis solicitudes",
                  AssetImages.request,
                  () {
                    Navigator.of(context).pop(); // cierra el drawer
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
                    final prefs = sl<LocalSharedPreferences>(
                      instanceName: 'prefs',
                    );
                    prefs.clear();
                    prefs.isLogged = true;
                    sl<AuthCubit>(instanceName: 'auth').logout();
                    context.go(AppRoutes.login);
                  },
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(
                    "Versión 1.0.1",
                    style: TextStyle(
                      color: kTextSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 3,
            color: kBorderFaint,
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
          color: kSurfaceSoft,
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(
          icon,
          height: 28,
          width: 28,
          colorFilter: const ColorFilter.mode(
            kPrimaryGreenMuted,
            BlendMode.srcIn,
          ),
        ),
      ),
      title: Text(
        title,
        textAlign: TextAlign.start,
        style: const TextStyle(
          color: kTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
    );
  }
}
