import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hypoglycemia_prediction/modules/insights/cubit/cubit.dart';
import 'package:hypoglycemia_prediction/modules/insights/cubit/states.dart';

class InsightsScreen extends StatelessWidget
{
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context)
  {
    return BlocProvider(
      create: (BuildContext context) => InsightsCubit()..getGlucoseData(),

      child: BlocConsumer<InsightsCubit, InsightsStates>(
        listener: (BuildContext context, InsightsStates state)
        {

        },

        builder: (BuildContext context, InsightsStates state)
        {
          InsightsCubit cubit = InsightsCubit.get(context);

          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "Glucose History",
              ),
            ),

            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                  children:
                  [
                    ConditionalBuilder(
                      condition: state is! GetGlucoseFromDatabaseLoadingState,

                      builder: (BuildContext context)
                      {
                        return ConditionalBuilder(
                          condition: state is EmptyGlucoseHistoryState,

                          builder: (BuildContext context)
                          {
                            return const Center(
                              child: Text(
                                'No Glucose History Yet',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                          fallback: (BuildContext context)
                          {
                            if(state is GetGlucoseFromDatabaseSuccessState)
                            {
                              return buildGlucoseHistoryList(glucoseReadings: cubit.userModel!.glucoseReadings!);
                            }
                            else
                            {
                              return const Center(
                                child: Text('No Glucose History Yet'),
                              );
                            }
                          },
                        );
                      },

                      fallback: (BuildContext context) => const Center(child: CircularProgressIndicator()),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildGlucoseHistoryCard({
    required String readingDate,
    required String readingTime,
    required String glucoseLevel,
    required String unit,
  })
  {
    return Container(
      width: 300,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey[200], // Light grey color
        borderRadius: BorderRadius.circular(20), // More rounded edges
        border: Border.all(
          color: Colors.grey, // Border color
          width: 2, // Border width
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Slight shadow
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:
        [
          Text(
            'Date: $readingDate',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
    
          Text(
            'Time: $readingTime',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
    
          Text(
            'Glucose Level: $glucoseLevel $unit',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGlucoseHistoryList({
    required List<dynamic> glucoseReadings,
  })
  {
    return Expanded(
      child: ListView.separated(
        itemBuilder: (BuildContext context, int index)
        {
          return buildGlucoseHistoryCard(
            readingDate: glucoseReadings[index]['timeStamp'].substring(0, 10),
            readingTime: glucoseReadings[index]['timeStamp'].substring(11),
            glucoseLevel: glucoseReadings[index]['glucoseLevel'].toString(),
            unit: glucoseReadings[index]['unit'],
          );
        },
      
        separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 40.0,),
      
        itemCount: glucoseReadings.length,
      ),
    );
  }

}

