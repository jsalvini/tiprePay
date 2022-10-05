import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tipre_pay/blocs/blocs.dart';
import 'package:tipre_pay/helpers/helpers.dart';
import 'package:tipre_pay/services/services.dart';

import 'package:pay/pay.dart' as pay;

class TotalPayButton extends StatelessWidget {
  const TotalPayButton({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final pagarBloc = BlocProvider.of<PagarBloc>(context).state;

    return Container(
      width: width,
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Total',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('${pagarBloc.montoPagar} ${pagarBloc.moneda}',
                  style: const TextStyle(fontSize: 24)),
            ],
          ),
          BlocBuilder<PagarBloc, PagarState>(
            builder: (context, state) {
              return _BtnPay(state: state);
            },
          ),
        ],
      ),
    );
  }
}

class _BtnPay extends StatefulWidget {
  final PagarState state;

  const _BtnPay({
    required this.state,
  });

  @override
  State<_BtnPay> createState() => _BtnPayState();
}

class _BtnPayState extends State<_BtnPay> {
  @override
  Widget build(BuildContext context) {
    return widget.state.tarjetaActiva
        ? buildBtnTarjeta(context)
        : buildAppleAndGooglePay(context);
  }

  Widget buildBtnTarjeta(BuildContext context) {
    return MaterialButton(
        height: 45,
        minWidth: 150,
        shape: const StadiumBorder(),
        elevation: 0,
        color: Colors.black,
        onPressed: () async {
          final stripService = StripeService();
          final pagarBloc = BlocProvider.of<PagarBloc>(context).state;
          final tarjeta = pagarBloc.tarjeta;
          final mesAnio = tarjeta!.expiracyDate.split('/');

          final resp = await stripService.pagarConTarjetaExistente(
              amount: pagarBloc.montoPagarString,
              currency: pagarBloc.moneda,
              card: CardDetails(
                number: tarjeta.cardNumber,
                expirationMonth: int.parse(mesAnio[0]),
                expirationYear: int.parse(mesAnio[1]),
                cvc: tarjeta.cvv,
              ));
          if (!mounted) return;
          if (resp.status == 'succeeded') {
            mostrarAlerta(
                context, 'Pago', 'El pago se realizo correctamente', 'ok');
          } else {
            mostrarAlerta(context, 'Error', resp.status, 'error');
          }
        },
        child: Row(
          children: [
            Icon(
                !Platform.isIOS
                    ? FontAwesomeIcons.creditCard
                    : FontAwesomeIcons.apple,
                color: Colors.white),
            const SizedBox(width: 10),
            const Text('Pagar',
                style: TextStyle(color: Colors.white, fontSize: 22)),
          ],
        ));
  }

  Widget buildAppleAndGooglePay(BuildContext context) {
    const paymentItems = [
      pay.PaymentItem(
        label: 'Total',
        amount: '1.00',
        status: pay.PaymentItemStatus.final_price,
      )
    ];

    return MaterialButton(
        height: 45,
        minWidth: 150,
        shape: const StadiumBorder(),
        elevation: 0,
        color: Colors.black,
        onPressed: () async {
          final stripService = StripeService();
          final pagarBloc = BlocProvider.of<PagarBloc>(context).state;

          final resp = await stripService.pagarConApplePayGooglePay(
            amount: pagarBloc.montoPagarString,
            currency: pagarBloc.moneda,
          );

          if (!mounted) return;
          if (resp.status == 'succeeded') {
            mostrarAlerta(
                context, 'Pago', 'El pago se realizo correctamente', 'ok');
          } else {
            mostrarAlerta(context, 'Error', resp.status, 'error');
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            pay.GooglePayButton(
              paymentConfigurationAsset:
                  'default_payment_profile_google_pay.json',
              paymentItems: paymentItems,
              type: pay.GooglePayButtonType.plain,
              margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
              onPaymentResult: onGooglePayResult,
              loadingIndicator: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            pay.ApplePayButton(
              paymentConfigurationAsset:
                  'default_payment_profile_apple_pay.json',
              paymentItems: paymentItems,
              style: pay.ApplePayButtonStyle.black,
              type: pay.ApplePayButtonType.plain,
              margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
              onPaymentResult: onApplePayResult,
              loadingIndicator: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ));
  }
}

void onGooglePayResult(paymentResult) {
  // Send the resulting Google Pay token to your server / PSP
  debugPrint(paymentResult.toString());
}

void onApplePayResult(paymentResult) {
  // Send the resulting Apple Pay token to your server / PSP
  debugPrint(paymentResult.toString());
}

String numberFormatMoneda(double numero) {
  //NumberFormat f = NumberFormat("#,###.0#", "es_US");
  NumberFormat f = NumberFormat("#,###.00#", "en_En");

  String result = f.format(numero);
  return '$result ${f.currencySymbol}';
}
