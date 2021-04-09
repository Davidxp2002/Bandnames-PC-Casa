import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:japacb/models/band.dart';
import 'package:japacb/services/socket_services.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];
  /* Band(id: '1', name: 'Tercer Cielo', votes: 4),
    Band(id: '2', name: 'New Wine', votes: 2),
    Band(id: '3', name: 'Nardo Encendido', votes: 9),
    Band(id: '4', name: 'Casa de Hijos', votes: 12),
    Band(id: '5', name: 'HillSong', votes: 34), */

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands', (payload) {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'BandNames',
            style: TextStyle(color: Colors.black87),
          ),
          backgroundColor: Colors.white,
          elevation: 1,
          actions: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 10),
              child: (socketService.serverStatus == ServerStatus.Online)
                  ? Icon(
                      Icons.check_circle,
                      color: Colors.blue[900],
                    )
                  : Icon(
                      Icons.offline_bolt_sharp,
                      color: Colors.red[900],
                    ),
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            _grafica(),
            Expanded(
              child: ListView.builder(
                  padding: EdgeInsets.only(right: 5, bottom: 50),
                  itemCount: bands.length,
                  itemBuilder: (context, i) => bandTile(bands[i])),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: addNewBand,
          elevation: 1,
          backgroundColor: Colors.blue[900],
        ));
  }

  Widget bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => socketService.emit('delete-band', {'id': band.id}),
      background: Container(
        padding: EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('Borrar Banda', style: TextStyle(color: Colors.white)),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 2)),
          backgroundColor: Colors.blue[900],
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: TextStyle(fontSize: 20)),
        onTap: () {
          socketService.socket.emit('vote-band', {'id': band.id});
        },
      ),
    );
  }

  addNewBand() {
    final textController = TextEditingController();
    if (Platform.isAndroid) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text('Ingresa el nombre de la nueva Banda'),
                content: TextField(controller: textController),
                actions: <Widget>[
                  MaterialButton(
                    child: Text('Añadir'),
                    elevation: 5,
                    textColor: Colors.blue[900],
                    onPressed: () => addBandtoList(textController.text),
                  )
                ],
              ));
    } else {
      showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
                title: Text('Ingresa el nombre de la nueva Banda'),
                content: CupertinoTextField(
                  controller: textController,
                ),
                actions: <Widget>[
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text('Añadir'),
                    onPressed: () => addBandtoList(textController.text),
                  ),
                  CupertinoDialogAction(
                      isDestructiveAction: true,
                      child: Text('Dismiss'),
                      onPressed: () => Navigator.pop(context)),
                ],
              ));
    }
  }

  void addBandtoList(String name) {
    if (name.length > 1) {
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.emit('add-band', {'name': name});
    }

    Navigator.pop(context);
  }

  Widget _grafica() {
    Map<String, double> dataMap = new Map();
    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    final List<Color> colorList = [
      Colors.blue,
      Colors.red,
      Colors.amber[400],
      Colors.green[100],
      Colors.purple[800],
      Colors.black
    ];
    return Container(
        padding: EdgeInsets.all(15),
        width: double.infinity,
        child: PieChart(
          dataMap: dataMap,
          animationDuration: Duration(milliseconds: 800),
          chartRadius: MediaQuery.of(context).size.width / 2.2,
          colorList: colorList,
          initialAngleInDegree: 0,
          chartType: ChartType.ring,
          legendOptions: LegendOptions(
            showLegendsInRow: false,
            legendPosition: LegendPosition.right,
            showLegends: true,
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          chartValuesOptions: ChartValuesOptions(
            showChartValueBackground: true,
            showChartValues: true,
            showChartValuesInPercentage: true,
            showChartValuesOutside: false,
            decimalPlaces: 1,
          ),
        ));
  }
}
