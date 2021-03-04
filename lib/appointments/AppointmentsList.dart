import 'package:flutter/material.dart';
import 'package:flutter_application_test/appointments/Appointments.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'AppointmentsDBWorker.dart';
import 'AppointmentsModel.dart' show Appointment, AppointmentsModel, appointmentsModel;


class AppointmentsList extends StatelessWidget {

  Widget build(BuildContext inContext) {
    EventList<Event> _markedDateMap = EventList();
    for ( int i = 0; i < appointmentsModel.entityList.length; i++ ) {
      Appointment appointment = appointmentsModel.entityList[i];
      List dateParts = appointment.apptDate.split(',');
      DateTime apptDate = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2])
      );
      _markedDateMap.add(apptDate, Event(
        date: apptDate,
        icon: Container(decoration: BoxDecoration(color: Colors.blue))
      ));
    }
    return ScopedModel<AppointmentsModel>(
      model: appointmentsModel,
      child: ScopedModelDescendant<AppointmentsModel>(
        builder: (BuildContext inContext, Widget inChild, AppointmentsModel inModel) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                appointmentsModel.entityBeingEdited = Appointment();
                DateTime now = DateTime.now();
                appointmentsModel.entityBeingEdited.apptDate = '${now.year},${now.month},${now.day}';
                appointmentsModel.setChosenDate(DateFormat.yMMMMd('en_US').format(now.toLocal()));
                appointmentsModel.setApptTime(null);
                appointmentsModel.setStackIndex(1);
              },
            ),
            body: Column(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: CalendarCarousel<Event>(
                      thisMonthDayBorderColor: Colors.grey,
                      daysHaveCircularBorder: false,
                      markedDatesMap: _markedDateMap,
                      onDayPressed: (DateTime inDate, List<Event> inEvents) {
                        _showAppointments(inDate, inContext);
                      },
                    ),
                  ),
                )
              ],
            ),
          );
        }
      ),
    );
  }

  void _showAppointments(DateTime inDate, BuildContext inContext) async {

  }

}