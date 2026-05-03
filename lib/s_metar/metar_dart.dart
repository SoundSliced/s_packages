/// Public entrypoint for the `s_metar` subpackage.
///
/// Provides parsers and fetchers for aeronautical weather reports
/// (METAR and TAF) from aviation meteorological sources.
library;

export 'src/fetch_metar_taf.dart' show MetarTafFetcher, MetarTafResult;
export 'src/reports/reports.dart' show Metar, Taf;
