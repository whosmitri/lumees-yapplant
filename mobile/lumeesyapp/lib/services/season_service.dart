/* REGRAS
Hemisfério Norte
Data / Estação
21/03 - 20/06:	Primavera
21/06 - 22/09:	Verão
23/09 - 20/12:	Outono
21/12 - 20/03:	Inverno

Hemisfério Sul
Data / Estação
21/03 - 20/06:	Outono
21/06 - 22/09:	Inverno
23/09 - 20/12:	Primavera
21/12 - 20/03:	Verão
*/

class SeasonService {

  // constantes
  static const String summer = 'Verão';
  static const String spring = 'Primavera';
  static const String autumn = 'Outono';
  static const String winter = 'Inverno';


  String getSeason(double latitude) {

    final now = DateTime.now();

    final month = now.month;
    final day = now.day;

    final isNorthernHemisphere = latitude >= 0;

    // primavera / outono
    if ((month == 3 && day >= 21) ||
        month == 4 ||
        month == 5 ||
        (month == 6 && day < 21)) {

      return isNorthernHemisphere
          ? spring
          : autumn;
    }

    // verão / inverno
    if ((month == 6 && day >= 21) ||
        month == 7 ||
        month == 8 ||
        (month == 9 && day < 23)) {

      return isNorthernHemisphere
          ? summer
          : winter;
    }

    // outono / primavera
    if ((month == 9 && day >= 23) ||
        month == 10 ||
        month == 11 ||
        (month == 12 && day < 21)) {

      return isNorthernHemisphere
          ? autumn
          : spring;
    }

    // inverno / verão
    return isNorthernHemisphere
        ? winter
        : summer;
  }

}