import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hypoglycemia_prediction/modules/emergency_contact/add_contact_screen.dart';
import 'package:hypoglycemia_prediction/modules/emergency_contact/cubit/cubit.dart';
import 'package:hypoglycemia_prediction/modules/emergency_contact/cubit/states.dart';
import 'package:hypoglycemia_prediction/modules/emergency_contact/edit_contact_screen.dart';

class EmergencyContactScreen extends StatelessWidget {

  EmergencyContactScreen({super.key});

  var searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    EmergencyContactCubit.get(context).contactList = [];

    EmergencyContactCubit.get(context).getEmergencyContacts();

    return BlocConsumer<EmergencyContactCubit, EmergencyContactStates>(

      listener: (BuildContext context, EmergencyContactStates state)
      {
        if(state is AddEmergencyContactSuccessState
            || state is UpdateSingleEmergencyContactSuccessState
            || state is DeleteSingleEmergencyContactSuccessState)
        {
          Navigator.pop(context);
        }
      },

      builder: (BuildContext context, EmergencyContactStates state)
      {
        EmergencyContactCubit cubit = EmergencyContactCubit.get(context);

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Emergency Contacts'),
            centerTitle: true,
            actions:
            [
              IconButton(
                onPressed: ()
                {
                  Navigator.push(
                    context,
                    MaterialPageRoute (
                      builder: (BuildContext context) => AddContactScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),

          body: ConditionalBuilder(
            condition: state is! GetEmergencyContactLoadingState,
            builder: (BuildContext context) => Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                  [
                    const Text(
                      'Emergency Contacts',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),

                    const SizedBox(height: 15.0,),

                    Text(
                      '${cubit.contactList.length} Contacts',
                      style: const TextStyle(
                        fontSize: 18.0,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 30.0,),

                    if(cubit.contactList.isNotEmpty)
                      buildContactList(
                        context: context,
                        contactList: cubit.contactList,
                      ),
                  ],
                ),
              ),
            ),
            fallback: (BuildContext context) => const Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }

  Widget buildContactItem({
    required context,
    required String? name,
    required String? contactId,
    required bool highestPriority,
  })
  {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0,),
      child: Row(
        children:
        [
          CircleAvatar(
            backgroundColor: Colors.grey[200],
            radius: 25.0,
            child: Text(
              name![0].toUpperCase(),
              style: const TextStyle(
                fontSize: 20.0,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(width: 20.0,),

          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 18.0,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),

          if(highestPriority)
            const Row(
              children:
              [
                Icon(
                  Icons.star_outlined,
                  color: Colors.amber,
                ),

                SizedBox(width: 10.0,),
              ],
            ),

          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute (
                    builder: (BuildContext context) => EditContactScreen(contactId: contactId,),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward_ios_rounded)
          )
        ],
      ),
    );
  }

  Widget buildContactList({
    required context,
    required List<dynamic> contactList,
  })
  {
    return Expanded(
      child: ListView.separated(
        itemBuilder: (BuildContext context, int index)
        {
          var element = contactList[index];

          return buildContactItem(
            context: context,
            name: element.contactName,
            contactId: element.contactId,
            highestPriority: element.isHighestPriority,
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemCount: contactList.length,
      ),
    );
  }
}
