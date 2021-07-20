import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_camera/constants/colors.dart';
import 'package:my_camera/styles/theme.dart';

class DetailsScreen extends StatefulWidget {
  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {

  var rowSpacer=TableRow(
      children: [
        SizedBox(height: 27),
        SizedBox(height: 27)
      ]
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(top: 70),
        decoration: BoxDecoration(
          gradient: backgroundGradient
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
                icon: SvgPicture.asset(
                  "assets/icons/Back.svg",
                  height: 24,
                  width: 12,
                  color: whiteColor,
                ),
                onPressed: (){
                  Navigator.pop(context);
                }
            ),
            SizedBox(
              height: 30,
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 30, right: 60),
                child: ListView(
                  children: [
                    Text(
                      "Details Info",
                      style: TextStyle(
                        color: whiteColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 30
                      ),
                    ),
                    SizedBox(height: 54),
                    Table(
                      border: TableBorder.all(color: Colors.transparent),
                      children: [
                        TableRow(
                          children: [
                            TableCell(
                              child: Text(
                                "Lorem Ispum:",
                                style: detailsTextStyle,
                                softWrap: true,
                              ),
                            ),
                            TableCell(
                              child: Text(
                                "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                                style: detailsTextStyle,
                                softWrap: true,
                              ),
                            )
                          ]
                        ),
                        rowSpacer,
                        TableRow(
                            children: [
                              TableCell(
                                child: Text(
                                  "Lorem Ispum:",
                                  style: detailsTextStyle,
                                  softWrap: true,
                                ),
                              ),
                              TableCell(
                                child: Text(
                                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                                  style: detailsTextStyle,
                                  softWrap: true,
                                ),
                              )
                            ]
                        ),
                        rowSpacer,
                        TableRow(
                            children: [
                              TableCell(
                                child: Text(
                                  "Lorem Ispum:",
                                  style: detailsTextStyle,
                                  softWrap: true,
                                ),
                              ),
                              TableCell(
                                child: Text(
                                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                                  style: detailsTextStyle,
                                  softWrap: true,
                                ),
                              )
                            ]
                        ),
                        rowSpacer,
                        TableRow(
                            children: [
                              TableCell(
                                child: Text(
                                  "Lorem Ispum:",
                                  style: detailsTextStyle,
                                  softWrap: true,
                                ),
                              ),
                              TableCell(
                                child: Text(
                                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                                  style: detailsTextStyle,
                                  softWrap: true,
                                ),
                              )
                            ]
                        ),
                        rowSpacer,
                        TableRow(
                            children: [
                              TableCell(
                                child: Text(
                                  "Lorem Ispum:",
                                  style: detailsTextStyle,
                                  softWrap: true,
                                ),
                              ),
                              TableCell(
                                child: Text(
                                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                                  style: detailsTextStyle,
                                  softWrap: true,
                                ),
                              )
                            ]
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
