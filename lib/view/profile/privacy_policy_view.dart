import 'package:flutter/material.dart';

import '../../common/colo_extension.dart';

/// Adatvédelmi tájékoztató és forrásmegjelölés. Az egészségadat különösen
/// védett kategória, ezért a tárolás, a jogalap és a törlés módja is itt van.
class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  static const List<List<String>> _sections = [
    [
      "Milyen adatot kezelünk",
      "Fiókadat (e-mail), profiladat (keresztnév, nem, születési dátum, testmagasság, testsúly, aktivitási szint, cél), "
          "étkezési napló, edzésnapló és alvásadat. Ezek egészségre vonatkozó adatok, ezért kizárólag a te "
          "hozzájárulásod alapján, a szolgáltatás működtetéséhez kezeljük.",
    ],
    [
      "Hol tároljuk",
      "Az adatok az Európai Unión belüli Supabase (PostgreSQL) adatbázisban vannak, soronkénti hozzáférés-"
          "szabályozással: minden sorhoz csak a saját fiókod férhet hozzá. Az eszközödön ezen kívül egy helyi "
          "másolat is készül, hogy internet nélkül is működjön az alkalmazás.",
    ],
    [
      "Kivel osztjuk meg",
      "Senkivel nem adjuk el és nem adjuk át marketing célra. Vonalkód beolvasásakor a beolvasott számot "
          "elküldjük az Open Food Facts nyilvános terméklekérdezésének. Ez a hívás nem tartalmaz azonosítót rólad.",
    ],
    [
      "Apple Health",
      "Ha a Profilban összekötöd az Apple Health-szel, a Flexio írhatja az edzéseidet, alvásodat, testsúlyodat, "
          "magasságodat és étkezéseidet az Apple Healthbe, és olvashatja a lépésszámot, az alvást, az edzéseket "
          "és a pulzust az Apple Healthből (az utóbbi hónapok, hogy a korábbi adataidhoz is viszonyíthass). "
          "Ha bekapcsolod a felugró értesítést, a Flexio helyi emlékeztetőt küld edzés, alvás és havi fotó előtt; ez az eszközön marad, nem megy szerverre. "
          "Az összekötés önkéntes, "
          "bármikor kikapcsolható. Az Apple Healthben tárolt adatot az Apple kezeli a saját feltételei szerint; "
          "a Flexio kikapcsolása nem törli a már átadott Health-bejegyzéseket. Az engedélyeket az iOS Beállítások → "
          "Egészség menüpontban is visszavonhatod.",
    ],
    [
      "Meddig tároljuk",
      "Amíg a fiókod létezik. A fiók törlésekor a profil, a napló, az edzés- és alvásadatok, valamint a saját "
          "ételeid véglegesen törlődnek a szerverről és az eszközről is.",
    ],
    [
      "A te jogaid",
      "Kérheted az adataid másolatát, javítását vagy törlését. A törlést a Profil oldalon a „Fiók és adatok "
          "törlése” funkcióval magad is elvégezheted, azonnali hatállyal.",
    ],
    [
      "Ételadatok forrása",
      "A termékadatok részben az Open Food Facts közösségi adatbázisából származnak, amely Open Database License "
          "(ODbL) alatt érhető el. Az ebből származtatott adatokat is ugyanezen licenc szerint kezeljük. "
          "A magyar alapanyag-katalógus saját, kurátorolt összeállítás.",
    ],
    [
      "Gyakorlatadatok forrása",
      "Az edzésgyakorlatok leírásai a RepDB (repdb.co) adatain alapulnak.",
    ],
    [
      "Fontos",
      "Az alkalmazás nem gyógyászati eszköz, és nem helyettesíti az orvosi vagy dietetikusi tanácsot. "
          "A számított kalória- és makróértékek becslések.",
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, size: 18, color: TColor.black),
        ),
        title: Text(
          "Adatvédelem",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          itemCount: _sections.length,
          separatorBuilder: (context, index) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            final section = _sections[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section[0],
                  style: TextStyle(
                      color: TColor.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  section[1],
                  style: TextStyle(
                      color: TColor.gray, fontSize: 12, height: 1.5),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
