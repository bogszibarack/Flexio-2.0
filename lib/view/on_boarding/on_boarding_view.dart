import 'package:fitness/common_widget/on_boarding_page.dart';
import 'package:fitness/view/login/signup_view.dart';
import 'package:flutter/material.dart';

import '../../common/colo_extension.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  int selectPage = 0;
  PageController controller = PageController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    controller.addListener(() {
        selectPage = controller.page?.round() ?? 0;

      setState(() {
        
      });
    });
  }

  List pageArr = [
    {
      "title": "Kövesd a céljaidat",
      "subtitle":
          "Ne aggódj, ha még nem tudod pontosan, mit szeretnél elérni. Segítünk kitűzni és lépésről lépésre nyomon követni a céljaidat.",
      "image": "assets/img/on_1.png"
    },
    {
      "title": "Legyél kitartó",
      "subtitle":
          "Lendülj formába és érd el a céljaidat. A kitartó munka meghozza a gyümölcsét – ne állj meg félúton!",
      "image": "assets/img/on_2.png"
    },
    {
      "title": "Étkezz tudatosan",
      "subtitle":
          "Kezdd velünk az egészséges életmódot. Segítünk összeállítani a napi étrendedet, hogy a finom ételek mellett is formában maradhass",
      "image": "assets/img/on_3.png"
    },
    {
      "title": "Pihentető alvás",
      "subtitle":
          "Javíts az alvásminőségeden a jobb regenerációért. A megfelelő pihenés garantálja, hogy minden reggel energikusan ébredj.",
      "image": "assets/img/on_4.png"
    },
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: TColor.white,
      body: Stack(
        alignment: Alignment.bottomRight,
        children: [
          PageView.builder(
              controller: controller,
              itemCount: pageArr.length,
              itemBuilder: (context, index) {
                var pObj = pageArr[index] as Map? ?? {};
                return OnBoardingPage(pObj: pObj) ;
              }),

          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [

                SizedBox(
                  width: 70,
                  height: 70,
                  child: CircularProgressIndicator(
                    color: TColor.primaryColor1,
                    value: (selectPage + 1) / 4 ,
                    strokeWidth: 2,
                  ),
                ),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(color: TColor.primaryColor1, borderRadius: BorderRadius.circular(35)),
                  child: IconButton(icon: Icon( Icons.navigate_next, color: TColor.white, ), onPressed: (){
          
                      if(selectPage < 3) {
          
                         selectPage = selectPage + 1;

                        controller.animateToPage(selectPage, duration: const Duration(milliseconds: 600), curve: Curves.bounceInOut);
                        
                        // controller.jumpToPage(selectPage);
                        
                          setState(() {
                            
                          });
          
                      }else{
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpView() ));
                      }
                      
                  },),
                ),

                
              ],
            ),
          )
        ],
      ),
    );
  }
}
