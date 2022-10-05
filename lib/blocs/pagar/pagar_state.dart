part of 'pagar_bloc.dart';

@immutable
class PagarState {
  final double montoPagar;
  final String moneda;
  final bool tarjetaActiva;
  final TarjetaCredito? tarjeta;

  const PagarState({
    this.montoPagar = 1,
    this.moneda = 'usd',
    this.tarjetaActiva = false,
    this.tarjeta,
  });

  String get montoPagarString => '${(montoPagar * 100).floor()}';

  PagarState copyWith({
    double? montoPagar,
    String? moneda,
    bool? tarjetaActiva,
    TarjetaCredito? tarjeta,
  }) =>
      PagarState(
        montoPagar: montoPagar ?? this.montoPagar,
        moneda: moneda ?? this.moneda,
        tarjetaActiva: tarjetaActiva ?? this.tarjetaActiva,
        tarjeta: tarjeta ?? this.tarjeta,
      );
}
