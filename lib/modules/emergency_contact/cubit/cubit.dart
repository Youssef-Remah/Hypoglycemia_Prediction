import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hypoglycemia_prediction/models/emergency_contact_model.dart';
import 'package:hypoglycemia_prediction/modules/emergency_contact/cubit/states.dart';
import 'package:hypoglycemia_prediction/shared/components/constants.dart';
import 'package:hypoglycemia_prediction/shared/network/local/cache_helper.dart';

class EmergencyContactCubit extends Cubit<EmergencyContactStates> {
  EmergencyContactCubit() : super(EmergencyContactInitialState());

  static EmergencyContactCubit get(context) => BlocProvider.of(context);

  List<EmergencyContactModel> contactList = [];

  EmergencyContactModel? singleContactModel;

  bool highestPriority = false;

  void addEmergencyContact({
    required String? name,
    required String? email,
    required String number,
  }) {
    emit(AddEmergencyContactLoadingState());

    getEmergencyContacts().then((value) {
      if (contactList.isEmpty) {
        highestPriority = true;
      }
      EmergencyContactModel model = EmergencyContactModel(
        contactName: name,
        contactEmail: email,
        contactNumber: number,
        isHighestPriority: highestPriority,
      );

      FirebaseFirestore.instance
          .collection('users')
          .doc(uId)
          .collection('emergencyContact')
          .add(model.toMap())
          .then((DocumentReference doc) {
        String docId = doc.id;

        doc.update({'contactId': docId}).then((value) {
          if (highestPriority) {
            globalEmergencyContactNumber = number;
            CacheHelper.saveData(
                key: 'globalEmergencyContactNumber', value: number);

            checkAndModifyContactsPriority(docId).then((value) {
              highestPriority = false;

              emit(AddEmergencyContactSuccessState());
            });
          } else {
            highestPriority = false;

            emit(AddEmergencyContactSuccessState());
          }
        });
      }).catchError((error) {
        print(error.toString());
      });
    });
  }

  Future<void> getEmergencyContacts() async {
    highestPriority = false;

    emit(GetEmergencyContactLoadingState());

    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection('emergencyContact')
        .get()
        .then((QuerySnapshot querySnapshot) {
      contactList = [];

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          contactList.add(EmergencyContactModel.fromJson(
              doc.data() as Map<String, dynamic>));
        }
      }
      emit(GetEmergencyContactSuccessState());
    }).catchError((error) {
      emit(GetEmergencyContactErrorState());
      print(error.toString());
    });
  }

  void getSingleEmergencyContact({
    required String? contactId,
  }) {
    emit(GetSingleEmergencyContactLoadingState());

    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection('emergencyContact')
        .doc(contactId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      singleContactModel = EmergencyContactModel.fromJson(
          documentSnapshot.data() as Map<String, dynamic>);

      highestPriority = singleContactModel!.isHighestPriority!;

      emit(GetSingleEmergencyContactSuccessState());
    }).catchError((error) {
      emit(GetSingleEmergencyContactErrorState());
      print(error.toString());
    });
  }

  Future<void> updateSingleEmergencyContact({
    required String? contactId,
    required String? newName,
    required String? newEmail,
    required String newNumber,
  }) async {
    emit(UpdateSingleEmergencyContactLoadingState());

    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection('emergencyContact')
        .doc(contactId)
        .update({
      'contactName': newName,
      'contactEmail': newEmail,
      'contactNumber': newNumber,
      'isHighestPriority': highestPriority,
    }).then((value) {
      if (highestPriority) {
        globalEmergencyContactNumber = newNumber;
        CacheHelper.saveData(
            key: 'globalEmergencyContactNumber', value: newNumber);

        checkAndModifyContactsPriority(contactId!).then((value) {
          highestPriority = false;

          emit(UpdateSingleEmergencyContactSuccessState());
        });
      } else {
        highestPriority = false;

        emit(UpdateSingleEmergencyContactSuccessState());
      }
    }).catchError((error) {
      print(error.toString());
      emit(UpdateSingleEmergencyContactErrorState());
    });
  }

  void deleteSingleEmergencyContact({
    required String? contactId,
  }) {
    emit(DeleteSingleEmergencyContactLoadingState());

    bool tempPriority = singleContactModel!.isHighestPriority!;

    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection('emergencyContact')
        .doc(contactId)
        .delete()
        .then((value) {
      getEmergencyContacts().then((value) {
        if (tempPriority) {
          globalEmergencyContactNumber = '';
          CacheHelper.removeData(key: 'globalEmergencyContactNumber');

          if (contactList.length > 1) {
            String? tempID;

            for (EmergencyContactModel model in contactList) {
              if (model.contactId != contactId) {
                tempID = model.contactId;

                break;
              }
            }

            FirebaseFirestore.instance
                .collection('users')
                .doc(uId)
                .collection('emergencyContact')
                .doc(tempID)
                .update({
              'isHighestPriority': true,
            }).then((value) {
              highestPriority = false;
              emit(DeleteSingleEmergencyContactSuccessState());
            }).catchError((error) {
              emit(DeleteSingleEmergencyContactErrorState());
              print(error.toString());
            });
          } else {
            highestPriority = false;

            emit(DeleteSingleEmergencyContactSuccessState());
          }
        } else {
          highestPriority = false;

          emit(DeleteSingleEmergencyContactSuccessState());
        }
      });
    }).catchError((error) {
      emit(DeleteSingleEmergencyContactErrorState());
      print(error.toString());
    });
  }

  void changePriority() {
    highestPriority = !highestPriority;

    emit(ChangeContactPriorityState());
  }

  Future<void> checkAndModifyContactsPriority(String id) async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection('emergencyContact')
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          EmergencyContactModel model = EmergencyContactModel.fromJson(
              doc.data() as Map<String, dynamic>);

          if (id != model.contactId) {
            if (model.isHighestPriority!) {
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(uId)
                  .collection('emergencyContact')
                  .doc(model.contactId)
                  .update({
                'isHighestPriority': false,
              }).then((value) {
                return;
              }).catchError((error) {
                emit(PriorityModificationErrorState());
              });
            }
          }
        }
      }
    }).catchError((error) {
      emit(PriorityModificationErrorState());
    });
  }
}
