import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hypoglycemia_prediction/modules/settings/account_details_screen.dart';
import 'package:hypoglycemia_prediction/modules/settings/cubit/cubit.dart';
import 'package:hypoglycemia_prediction/modules/settings/cubit/states.dart';
import 'package:hypoglycemia_prediction/modules/settings/email_reset_screen.dart';
import 'package:hypoglycemia_prediction/modules/settings/icr_screen.dart';
import 'package:hypoglycemia_prediction/modules/settings/password_reset_screen.dart';
import 'package:hypoglycemia_prediction/shared/components/resuable_components.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    ProfileSettingsCubit.get(context).getUserDataFromDatabase();

    return BlocConsumer<ProfileSettingsCubit, ProfileSettingsStates>(

      listener: (BuildContext context, ProfileSettingsStates state)
      {
    
      },

      builder: (BuildContext context, ProfileSettingsStates state)
      {
        ProfileSettingsCubit cubit = ProfileSettingsCubit.get(context);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile Settings'),
          ),

          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children:
              [
                buildListItem(
                  context: context,
                  prefixIcon: Icons.person,
                  title: 'Account Details',
                  destinationWidget: AccountDetailsScreen(),
                ),

                const SizedBox(height: 30.0,),

                buildListItem(
                  context: context,
                  prefixIcon: Icons.lock_reset,
                  title: 'Reset Password',
                  destinationWidget: PasswordResetScreen(),
                ),

                const SizedBox(height: 30.0,),

                buildListItem(
                  context: context,
                  prefixIcon: Icons.email,
                  title: 'Reset Email',
                  destinationWidget: EmailResetScreen(),
                ),

                const SizedBox(height: 30.0,),

                buildListItem(
                  context: context,
                  prefixIcon: Icons.health_and_safety,
                  title: 'Insulin-to-Carbohydrate Ratio',
                  destinationWidget: ICRScreen(),
                ),

                const SizedBox(height: 50.0,),

                TextButton(
                  onPressed: ()
                  {
                    cubit.signOut(context: context);
                  },
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
