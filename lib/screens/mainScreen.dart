import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uber_rider/assistants/assistantMethods.dart';
import 'package:uber_rider/assistants/size_config.dart';
import 'package:uber_rider/dataHandler/appData.dart';
import 'package:uber_rider/map/configMaps.dart';
import 'package:uber_rider/models/directionDetails.dart';
import 'package:uber_rider/screens/loginScreen.dart';
import 'package:uber_rider/screens/searchScreen.dart';
import 'package:uber_rider/widgets/divider.dart';
import 'package:uber_rider/widgets/progressIndicator.dart';

class MainScreen extends StatefulWidget {
  static const idScreen = "mainScreen";
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {

  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController newGoogleMapController;
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  DirectionDetails tripDirectionDetails;

  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  double rideDetailsContainerHeight = 0;
  double searchContainerHeight = 38.8601036 * SizeConfig.heightMultiplier /*300.0*/;
  double requestRideContainerHeight = 0;

  bool drawerOpen = true;

  DatabaseReference rideRequestRef;

   void initState() {
     super.initState();

     AssistantMethods.getCurrentOnlineUserInfo();
   }


   void saveRideRequest(){
     rideRequestRef = FirebaseDatabase.instance.reference().child("Ride Request").push();

     var pickUp = Provider.of<AppData>(context, listen: false).pickUpLocation;
     var dropOff = Provider.of<AppData>(context, listen: false).dropOffLocation;


     Map pickupLocMap = {
       "latitude" : pickUp.latitude.toString(),
       "longitude" : pickUp.longitude.toString(),
     };

     Map dropOffLocMap = {
       "latitude" : dropOff.latitude.toString(),
       "longitude" : dropOff.longitude.toString(),
     };


     Map rideInfoMap = {
       "driver_id": "waiting",
       "payment_method":"cash",
       "pickup":pickupLocMap,
       "dropoff":dropOffLocMap,
       "created_at":DateTime.now().toString(),
       "rider_name": userCurrentInfo.name,
       "rider_phone":userCurrentInfo.phone,
       "pickup_address":pickUp.placeName,
       "dropoff_address":dropOff.placeName
     };

     rideRequestRef.set(rideInfoMap);
     

   }


  resetApp() {
    setState(() {
      drawerOpen = true;
      searchContainerHeight = 38.8601036 * SizeConfig.heightMultiplier /*300.0*/;
      rideDetailsContainerHeight = 0;
      bottomPaddingOfMap = 29.79274611 * SizeConfig.heightMultiplier /*230.0*/ ;
      requestRideContainerHeight = 0;

      polylineSet.clear();
      markersSet.clear();
      circlesSet.clear();
      pLineCoordinates.clear();
    });
    locatePosition();
  }

  void displayRideDetailsContainer() async {
    await getPlaceDirection();
    setState(() {
      searchContainerHeight = 0;
      rideDetailsContainerHeight = 32.3834196 * SizeConfig.heightMultiplier /*250.0*/;
      bottomPaddingOfMap = 29.79274611 * SizeConfig.heightMultiplier /*230.0*/;
      drawerOpen = false;
    });
  }

  void displayRequestRideContainer(){
    setState(() {
      requestRideContainerHeight = 32.3834196 * SizeConfig.heightMultiplier /*250.0*/;
      rideDetailsContainerHeight = 0;
      bottomPaddingOfMap = 25.90673575 * SizeConfig.heightMultiplier /*200.0*/;
      drawerOpen = true;
    });
    saveRideRequest();
  }

  void cancelRideRequest(){
      rideRequestRef.remove();

  }


  Position currentPosition;
  var geoLocator = Geolocator();
  double bottomPaddingOfMap = 0;

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLngPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        new CameraPosition(target: latLngPosition, zoom: 14);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address =
        await AssistantMethods.searchCoordinateAddress(position, context);
    print("This is your address: " + address);
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      // appBar: AppBar(
      //   title: Text("Main Screen"),
      // ),
      drawer: Container(
        color: Colors.white,
        width: 70.8333333 * SizeConfig.widthMultiplier /*255.0*/,
        child: Drawer(
          child: ListView(
            children: [
              Container(
                height: 25.90673575 * SizeConfig.heightMultiplier /*200.0*/,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/images/user_icon.png",
                        height:8.419689119 * SizeConfig.heightMultiplier  /*65.0*/,
                        width: 18.055555 * SizeConfig.widthMultiplier /*65.0*/,
                      ),
                      SizedBox(
                        width: 4.4444444 * SizeConfig.widthMultiplier /*16.0*/,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Profile Name",
                            style: TextStyle(
                                fontSize: 2.072538860 * SizeConfig.textMultiplier /*16.0*/, fontFamily: "Brand-Bold"),
                          ),
                          SizedBox(
                            height: 0.7772 * SizeConfig.heightMultiplier /*6.0*/ ,
                          ),
                          Text("Visit Profile")
                        ],
                      )
                    ],
                  ),
                ),
              ),
              DividerWidget(),

              SizedBox(
                height: 1.5544041450 * SizeConfig.heightMultiplier /*12.0*/,
              ),
              //DRAWER BODY

              ListTile(
                leading: Icon(Icons.history),
                title: Text(
                  "History",
                  style: TextStyle(fontSize: 1.943 * SizeConfig.textMultiplier  /*15.0*/),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text(
                  "Visit Profile",
                  style: TextStyle(fontSize: 1.943 * SizeConfig.textMultiplier  /*15.0*/),
                ),
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text(
                  "About",
                  style: TextStyle(fontSize: 1.943 * SizeConfig.textMultiplier  /*15.0*/),
                ),
              ),
              GestureDetector(
                onTap: (){
                  FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(context, LoginScreen.idScreen, (route) => false);
                },
                child: ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text(
                    "Sign Out",
                    style: TextStyle(fontSize: 1.943 * SizeConfig.textMultiplier  /*15.0*/),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap, top: 3.886010362 * SizeConfig.heightMultiplier /*30*/),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: _kGooglePlex,
            polylines: polylineSet,
            markers: markersSet,
            circles: circlesSet,
            onMapCreated: (GoogleMapController mapController) {
              _controllerGoogleMap.complete(mapController);
              newGoogleMapController = mapController;
              setState(() {
                bottomPaddingOfMap =51.813471502 * SizeConfig.heightMultiplier /*400*/;
              });

              locatePosition();
            },
          ),

          //TODO: DRAWER ICON
          Positioned(
            top: 5.181347150 * SizeConfig.heightMultiplier /*40*/,
            left: 6.11111111 * SizeConfig.widthMultiplier /*22.0*/,
            child: GestureDetector(
              onTap: () {
                if (drawerOpen) {
                  scaffoldKey.currentState.openDrawer();
                } else {
                  resetApp();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 6.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      )
                    ]),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    (drawerOpen ? Icons.menu : Icons.close),
                    color: Colors.black,
                  ),
                  radius: 20.0,
                ),
              ),
            ),
          ),

          //TODO: BOTTOM  SEARCH CONTAINER TO SET DROP OFF LOCATION
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: AnimatedSize(
              vsync: this,
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: searchContainerHeight,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 16,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      )
                    ]),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 6.6666666 * SizeConfig.widthMultiplier /*24.0*/, vertical: 2.3316062 * SizeConfig.heightMultiplier /*18.0*/),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 6.0,
                      ),
                      Text(
                        "Hi there, ",
                        style: TextStyle(fontSize: 1.55440414 * SizeConfig.textMultiplier /*12.0*/),
                      ),
                      Text(
                        "Where to?, ",
                        style:
                            TextStyle(fontSize: 2.59067357 * SizeConfig.textMultiplier /*20.0*/, fontFamily: "Brand-Bold"),
                      ),
                      SizedBox(
                        height: 2.59067357 * SizeConfig.heightMultiplier /*20.0*/,
                      ),
                      //TODO: SEARCH BAR
                      GestureDetector(
                        onTap: () async {
                          var res = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => SearchScreen()));

                          if (res == "obtainDirection") {
                            displayRideDetailsContainer();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 6.0,
                                  spreadRadius: 0.5,
                                  offset: Offset(0.7, 0.7),
                                )
                              ]),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: Colors.blueGrey,
                                ),
                                SizedBox(
                                  width: 2.777777  * SizeConfig.widthMultiplier /*10.0*/,
                                ),
                                Text("Search Drop Off")
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 3.10880829 * SizeConfig.heightMultiplier /*24.0*/,
                      ),
                      DividerWidget(),
                      SizedBox(
                        height: 2.0725388 * SizeConfig.heightMultiplier /*16.0*/,
                      ),
                      //TODO: ADD HOME
                      Row(
                        children: [
                          Icon(
                            Icons.home,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 12.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Provider.of<AppData>(context).pickUpLocation !=
                                        null
                                    ? Provider.of<AppData>(context)
                                        .pickUpLocation
                                        .placeName
                                    : " Add Home",
                                style: TextStyle(fontSize: 1.29533678 * SizeConfig.textMultiplier /*10*/),
                              ),
                              SizedBox(
                                height: 0.518134715 * SizeConfig.heightMultiplier /*4*/,
                              ),
                              Text(
                                "Your living home address",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 1.5544041450 * SizeConfig.textMultiplier /*12*/),
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 1.29533678 * SizeConfig.heightMultiplier /*10*/,
                      ),
                      DividerWidget(),
                      SizedBox(
                        height: 2.07253886010* SizeConfig.heightMultiplier /*16*/,
                      ),
                      //TODO: ADD WORK
                      Row(
                        children: [
                          Icon(
                            Icons.work,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 3.33333333 * SizeConfig.widthMultiplier /*12.0*/,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Add Work"),
                              SizedBox(
                                height: 0.518134715 * SizeConfig.heightMultiplier /*4*/,
                              ),
                              Text(
                                "Your office address",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 1.5544041450 * SizeConfig.textMultiplier /*12*/),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          //TODO: BOTTOM  RIDE CONTAINER TO SET DROP OFF LOCATION
          Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: AnimatedSize(
                vsync: this,
                curve: Curves.bounceIn,
                duration: new Duration(milliseconds: 160),
                child: Container(
                  height: rideDetailsContainerHeight,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.0),
                          topRight: Radius.circular(16.0)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black,
                            blurRadius: 16.0,
                            spreadRadius: 0.5,
                            offset: Offset(0.7, 0.7))
                      ]),
                  child: Padding(
                    padding:  EdgeInsets.symmetric(vertical:2.20207253 * SizeConfig.heightMultiplier /*17*/ ),
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          color: Colors.tealAccent[100],
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.4444444 * SizeConfig.widthMultiplier /*16.0*/),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset(
                                  "assets/images/taxi.png",
                                  height: 9.06735751 * SizeConfig.heightMultiplier /*70*/,
                                  width: 22.2222222 * SizeConfig.widthMultiplier /*80*/,
                                ),
                                SizedBox(
                                  width: 4.44444444 * SizeConfig.widthMultiplier /*16*/,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Car",
                                      style: TextStyle(
                                          fontSize: 2.3316062 * SizeConfig.textMultiplier /*18*/,
                                          fontFamily: "Brand-Bold"),
                                    ),
                                    Text(
                                      ((tripDirectionDetails != null)
                                          ? tripDirectionDetails.distanceText
                                          : ''),
                                      style: TextStyle(
                                          fontSize: 2.07253886 * SizeConfig.textMultiplier /*16*/,
                                          fontFamily: "Brand-Bold",
                                          color: Colors.grey),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width:13.88888888 * SizeConfig.widthMultiplier /*50*/ ,
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                  ((tripDirectionDetails != null
                                      ? '\R\s${AssistantMethods.calculateFares(tripDirectionDetails)}'
                                      : '')),
                                  style: TextStyle(
                                      fontSize: 2.07253886 * SizeConfig.textMultiplier /*16*/,
                                      fontFamily: "Brand-Bold",
                                      color: Colors.grey),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 2.590673575 * SizeConfig.heightMultiplier /*20*/,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.555555555 * SizeConfig.widthMultiplier /*20*/),
                          child: Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.moneyCheckAlt,
                                size: 18.0,
                                color: Colors.black54,
                              ),
                              SizedBox(
                                width: 4.44444444 * SizeConfig.widthMultiplier /*16*/,
                              ),
                              Text("Cash"),
                              SizedBox(
                                width: 1.666666 * SizeConfig.widthMultiplier /*6*/,
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.black54,
                                size: 16.0,
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 3.10880829 * SizeConfig.heightMultiplier /*24*/,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal:  4.44444444 * SizeConfig.widthMultiplier /*16*/),
                          child: RaisedButton(
                            color: Theme.of(context).accentColor,
                            onPressed: () {
                              displayRequestRideContainer();
                            },
                            child: Padding(
                              padding: EdgeInsets.all(17.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Request",
                                    style: TextStyle(
                                        fontSize: 2.5906735751 * SizeConfig.textMultiplier /*20*/,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  Icon(
                                    FontAwesomeIcons.taxi,
                                    color: Colors.white,
                                    size: 26.0,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),

          //TODO: BOTTOM REQUEST RIDE CONTAINER
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        spreadRadius: 0.5,
                        blurRadius: 16,
                        color: Colors.black54,
                        offset: Offset(0.7, 0.7))
                  ]),
              height: requestRideContainerHeight,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 1.554404 * SizeConfig.heightMultiplier /*12*/,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ColorizeAnimatedTextKit(
                        onTap: () {
                          print("Tap Event");
                        },
                        text: [
                          "Requesting a Ride",
                          "Please wait...",
                          "Finding a driver",
                        ],
                        textStyle: TextStyle(fontSize:6.4766839 * SizeConfig.textMultiplier /*50*/, fontFamily: "Signatra"),
                        colors: [
                          Colors.green,
                          Colors.purple,
                          Colors.pink,
                          Colors.blue,
                          Colors.yellow,
                          Colors.red,
                        ],
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: 2.8497409 * SizeConfig.heightMultiplier /*22*/,),
                    GestureDetector(
                      onTap: (){
                        cancelRideRequest();
                        resetApp();
                      },
                      child: Container(
                        height: 7.772020 * SizeConfig.heightMultiplier /*60.0*/,
                        width: 16.666666666 * SizeConfig.widthMultiplier /*60.0*/,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26.0),
                          border: Border.all(width: 2.0, color: Colors.grey),
                        ),
                        child: Icon(Icons.close, size: 26.0,),
                      ),
                    ),
                    SizedBox(height: 1.29533 * SizeConfig.heightMultiplier /*10*/,),
                    Container(
                      width: double.infinity,
                      child: Text("Cancel Ride", textAlign: TextAlign.center, style: TextStyle(fontSize: 12.0),),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> getPlaceDirection() async {
    var initialPos =
        Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;

    var pickUpLatLng = LatLng(initialPos.latitude, initialPos.longitude);
    var dropOffLatLng = LatLng(finalPos.latitude, finalPos.longitude);

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "Please Wait..",
            ));

    var details = await AssistantMethods.obtainPlaceDirectionDetails(
        pickUpLatLng, dropOffLatLng);

    setState(() {
      tripDirectionDetails = details;
    });

    Navigator.pop(context);

    print("this is encoded points");
    print(details.encodedPoint);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointsResult =
        polylinePoints.decodePolyline(details.encodedPoint);

    pLineCoordinates.clear();
    if (decodedPolylinePointsResult.isNotEmpty) {
      decodedPolylinePointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
          color: Colors.blue,
          polylineId: PolylineId("PolyLineId"),
          jointType: JointType.round,
          points: pLineCoordinates,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true);
      polylineSet.add(polyline);
    });

    LatLngBounds latLngBounds;
    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }

    newGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickUpLocMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow:
            InfoWindow(title: initialPos.placeName, snippet: "my location"),
        position: pickUpLatLng,
        markerId: MarkerId("pickUpId"));

    Marker dropOffLocMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow:
            InfoWindow(title: finalPos.placeName, snippet: "my destination"),
        position: dropOffLatLng,
        markerId: MarkerId("dropOffId"));

    setState(() {
      markersSet.add(pickUpLocMarker);
      markersSet.add(dropOffLocMarker);
    });

    Circle pickUpLocCircle = Circle(
      circleId: CircleId("pickUpId"),
      fillColor: Colors.green,
      center: pickUpLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.greenAccent,
    );

    Circle dropOffLocCircle = Circle(
      circleId: CircleId("dropOffId"),
      fillColor: Colors.red,
      center: pickUpLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.redAccent,
    );

    setState(() {
      circlesSet.add(pickUpLocCircle);
      circlesSet.add(dropOffLocCircle);
    });
  }
}

//keytool -genkey -v -keystore F:\keystores\ubercloneKeyStore\key.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias key
