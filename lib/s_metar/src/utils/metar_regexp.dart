part of 'utils.dart';

// Regular expressions to decode various groups of the METAR code
class MetarRegExp {
  static final RegExp type = RegExp(r'^(?<type>METAR|SPECI|TAF)$');

  static final RegExp station = RegExp(r'^(?<station>[A-Z][A-Z0-9]{3})$');

  static final RegExp time = RegExp(r'^(?<day>0[1-9]|[12][0-9]|3[01])'
      r'(?<hour>[0-1]\d|2[0-4])'
      r'(?<min>[0-5]\d)Z$');

  static final RegExp modifier =
      RegExp(r'^(?<mod>COR(R)?|AMD|NIL|TEST|FINO|AUTO)$');

  // ignore: valid_regexps
  static final RegExp wind = RegExp(r'^(?<dir>([0-2][0-9]|3[0-6])0|///|VRB)'
      r'P?(?<speed>\d{2,3}|//|///)'
      r'(G(P)?(?<gust>\d{2,3}))?'
      r'(?<units>KT|MPS)$');

  static final RegExp windVariation =
      RegExp(r'^(?<from>(0[1-9]|[12][0-9]|3[0-6])0)'
          r'V(?<to>(0[1-9]|[12][0-9]|3[0-6])0)$');

  static final RegExp visibility = RegExp(r'^((?<vis>\d{4}|//\//)'
      r'(?<dir>[NSEW]([EW])?)?|'
      r'(M|P)?(?<integer>\d{1,2})?_?'
      r'(?<fraction>\d/\d)?'
      r'(?<units>SM|KM|U)|'
      r'(?<cavok>CAVOK))$');

  static final RegExp minimumVisibility =
      RegExp(r'^(?<vis>\d{4}|//\//)' r'(?<dir>[NSEW]([EW])?)?$');

  static final RegExp runwayRange = RegExp(r'^R(?<name>\d{2}[RLC]?)/'
      r'(?<rvrlow>[MP])?'
      r'(?<low>\d{2,4})'
      r'(V(?<rvrhigh>[MP])?'
      r'(?<high>\d{2,4}))?'
      r'(?<units>FT)?'
      r'(?<trend>[NDU])?$');

  static final RegExp weather = RegExp(r'^((?<int>(-|\+|VC))?'
      r'(?<desc>MI|PR|BC|DR|BL|SH|TS|FZ)?'
      r'((?<prec>(?:DZ|RA|SN|SG|IC|PL|GR|GS|UP){1,3})|'
      r'(?<obsc>BR|FG|FU|VA|DU|SA|HZ|PY)|'
      r'(?<other>PO|SQ|FC|SS|DS|NSW|/))?)$');

  static final RegExp cloud =
      RegExp(r'^(?<cover>VV|CLR|SKC|NSC|NCD|BKN|SCT|FEW|OVC|///)'
          r'(?<height>\d{3}|///)?'
          r'(?<type>TCU|CB|///)?$');

  static final RegExp temperatures = RegExp(r'^(?<tsign>M|-)?'
      r'(?<temp>\d{2}|//|XX|MM)/'
      r'(?<dsign>M|-)?'
      r'(?<dewpt>\d{2}|//|XX|MM)$');

  static final RegExp pressure = RegExp(r'^(?<units>A|Q|QNH)?'
      r'(?<press>\d{4}|\//\//)'
      r'(?<units2>INS)?$');

  static final RegExp recentWeather =
      RegExp(r'^RE(?<desc>MI|PR|BC|DR|BL|SH|TS|FZ)?'
          r'(?<prec>DZ|RA|SN|SG|IC|PL|GR|GS|UP)?'
          r'(?<obsc>BR|FG|VA|DU|SA|HZ|PY)?'
          r'(?<other>PO|SQ|FC|SS|DS)?$');

  static final RegExp windshear = RegExp(r'^WS(?<all>_ALL)?'
      r'_(RWY|R(?<name>\d{2}[RCL]?))$');

  static final RegExp seaState = RegExp(r'^W(?<sign>M)?'
      r'(?<temp>\d{2})'
      r'/(S(?<state>\d)'
      r'|H(?<height>\d{3}))$');

  static final RegExp runwayState = RegExp(r'^R(?<name>\d{2}([RLC])?)?/('
      r'(?<deposit>\d|/)'
      r'(?<cont>\d|/)'
      r'(?<depth>\d\d|//)'
      r'(?<fric>\d\d|//)|'
      r'(?<snoclo>SNOCLO)|'
      r'(?<clrd>CLRD//))$');

  static final RegExp changeIndicator = RegExp(r'^TEMPO|BECMG|NOSIG$');

  static final RegExp trendTimePeriod = RegExp(
      r'^(?<prefix>FM|TL|AT)' r'(?<hour>[01]\d|2[0-4])' r'(?<min>[0-5]\d)$');

  static final RegExp remark = RegExp(r'^(?<rmk>RMK(S)?)$');
}
