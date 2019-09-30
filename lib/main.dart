//===============================================================================
//Created by Mochamad Nizwar Syafuan
//email : nizwar@merahputih.id
//===============================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jadwal_sholat/logo.dart';
import 'package:shimmer/shimmer.dart';
import 'package:simplehttpconnection/simplehttpconnection.dart';

const String serverAPI = "http://api.aladhan.com/";

void main() {
  return runApp(MaterialApp(
    home: Main(),
  ));
}

class Main extends StatefulWidget {
  @override
  MainState createState() => MainState();
}

class MainState extends State<Main> {
  JadwalSholat selected;
  Map<String, dynamic> data = {};
  bool error = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: customFloatButton(context),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/bg.jpg"), fit: BoxFit.cover)),
        child: Stack(
          children: <Widget>[
            blurBackground(),
            SafeArea(
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: <Widget>[
                  selected == null
                      ? Container()
                      : !error ? detailJadwal() : Container(),
                  data.length == 0
                      ? !error ? listShimmer() : errorNotValid()
                      : !error ? listviewData() : errorNotValid(),
                  SizedBox(
                    height: 80.0,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget detailJadwal() {
    return Container(
      height: 150.0,
      color: Colors.black.withOpacity(.2),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 50.0,
            width: 50.0,
            child: CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(
                selected.icon,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            selected.waktu,
            style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 25.0),
          ),
          Text(selected.judul,
              style: TextStyle(color: Colors.white, fontSize: 20.0)),
          Text(
            selected.tanggal,
            style: TextStyle(color: Colors.white, fontSize: 15.0),
          ),
        ],
      ),
    );
  }

  Widget listShimmer() {
    return ListView.builder(
      physics: ClampingScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(vertical: 5.0),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.withOpacity(.1),
          highlightColor: Colors.white.withOpacity(.3),
          child: ListTile(
            title: shimmerObject(
                width: 100.0, height: 20.0, radius: BorderRadius.circular(3.0)),
            leading: shimmerObject(
                width: 40.0, height: 40.0, radius: BorderRadius.circular(50.0)),
            trailing: shimmerObject(
                width: 50.0, height: 20.0, radius: BorderRadius.circular(3.0)),
          ),
        );
      },
      itemCount: 9,
    );
  }

  Widget errorNotValid() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Text(
        "Sepertinya terjadi sesuatu, Response tidak valid",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 18.0),
      ),
    );
  }

  Widget listviewData() {
    return ListView.builder(
      physics: ClampingScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(vertical: 5.0),
      itemBuilder: (context, index) {
        Map<String, dynamic> dataWaktu = data["data"]["timings"];
        IconData logo = Logo.moon;
        switch (dataWaktu.keys.toList()[index].toLowerCase()) {
          case "fajr":
            logo = Logo.cloud;
            break;
          case "sunrise":
            logo = Logo.sunrise;
            break;
          case "dhuhr":
            logo = Logo.sun;
            break;
          case "asr":
            logo = Logo.cloud_sun;
            break;
          case "sunset":
            logo = Logo.sunrise;
            break;
          case "maghrib":
            logo = Logo.sunrise;
            break;
          case "isha":
            logo = Logo.moon;
            break;
          case "imsak":
            logo = Logo.moon;
            break;
          case "midnight":
            logo = Logo.cloud_moon;
            break;
          default:
            logo = Logo.cloud;
            break;
        }
        //Biar ada ripple effectnya
        return Material(
          color: Colors.transparent,
          child: ListTile(
            onTap: () {
              setState(() {
                selected = JadwalSholat(
                    logo,
                    dataWaktu.keys.toList()[index],
                    dataWaktu.values.toList()[index],
                    data["data"]["date"]["readable"]);
              });
            },
            leading: CircleAvatar(
              child: Icon(
                logo,
                color: Colors.white,
              ),
              backgroundColor: Colors.orange,
            ),
            title: Text(
              dataWaktu.keys.toList()[index],
              style: TextStyle(color: Colors.white),
            ),
            trailing: Text(
              dataWaktu.values.toList()[index],
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  fontSize: 20.0),
            ),
          ),
        );
      },
      itemCount: data["data"]["timings"].length,
    );
  }

  Widget blurBackground({Widget child, double sigmaX, double sigmaY}) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: sigmaX ?? 4, sigmaY: sigmaY ?? 4),
      child: child ??
          Container(
            color: Colors.black.withOpacity(.5),
          ),
    );
  }

  Widget customFloatButton(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 40,
      height: 50.0,
      child: FlatButton(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        color: Colors.orange,
        child: Text(
          "Refresh",
          style: TextStyle(color: Colors.white, fontSize: 18.0),
        ),
        onPressed: () {
          initPosition();
          setState(() {});
        },
      ),
    );
  }

  Widget shimmerObject(
      {BorderRadius radius,
      double width,
      double height,
      EdgeInsetsGeometry margin}) {
    return Container(
      margin: margin ?? EdgeInsets.symmetric(vertical: 5.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: radius ?? BorderRadius.circular(.3)),
      height: height,
      width: width,
    );
  }

  @override
  void initState() {
    super.initState();
    initPosition();
  }

  //===============================================================================
  //Created by Mochamad Nizwar Syafuan
  //email : nizwar@merahputih.id
  //===============================================================================

  //Disini bagian backend =========================================================
  void reset() {
    setState(() {
      data = {};
      error = false;
      selected = null;
    });
  }

  Future initPosition() async {
    reset();
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    await getJadwalSholat(position.latitude, position.longitude);
    setState(() {});
  }

  Future<Map<String, dynamic>> getJadwalSholat(double lat, double lng) async {
    if (lat == null || lng == null) return null;
    Map<String, String> paramsJadwal = {
      "latitude": lat.toString(),
      "longitude": lng.toString(),
      "method": "1"
    };
    ResponseHttp resp = await HttpConnection.doConnection(
        serverAPI +
            "timings/" +
            DateTime.now().microsecondsSinceEpoch.toString().substring(0, 10),
        method: Method.get,
        body: paramsJadwal);
    data = resp.content.asJson();
    if (data["code"] != 200) error = true;
    return resp.content.asJson();
  }
}

class JadwalSholat {
  final IconData icon;
  final String judul, waktu, tanggal;

  JadwalSholat(this.icon, this.judul, this.waktu, this.tanggal);
}
