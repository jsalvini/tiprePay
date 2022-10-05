import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_credit_card/credit_card_brand.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:tipre_pay/blocs/blocs.dart';
import 'package:tipre_pay/data/tarjetas.dart';
import 'package:tipre_pay/helpers/helpers.dart';
import 'package:tipre_pay/pages/tarjeta_page.dart';
import 'package:tipre_pay/services/services.dart';
import 'package:tipre_pay/widgets/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final sizeScreen = MediaQuery.of(context).size;
    final stripeService = StripeService();
    final pagarBloc = BlocProvider.of<PagarBloc>(context);

    const billingDetails = BillingDetails(
      name: 'José Salvni',
      email: 'josesalvini@gmail.com',
      phone: '+48888000888',
      address: Address(
        city: 'Córdoba',
        country: 'AR',
        line1: 'Calle Publica 123',
        line2: '',
        state: 'Córdoba',
        postalCode: '5003',
      ),
    );

    return Scaffold(
        appBar: AppBar(
          title: const Text('Pagar'),
          actions: [
            IconButton(
              onPressed: () async {
                //mostrarLoading(context);
                //await Future.delayed(const Duration(seconds: 1));
                //if (!mounted) return;
                //Navigator.pop(context);

                final amount = pagarBloc.state.montoPagarString;
                final currency = pagarBloc.state.moneda;

                final response = await stripeService.pagarConTarjetaNueva(
                  amount: amount,
                  currency: currency,
                );
                await Stripe.instance.initPaymentSheet(
                    paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: response.clientSecret,
                  // applePay: const PaymentSheetApplePay(merchantCountryCode: '+92',),
                  // googlePay: const PaymentSheetGooglePay(testEnv: true, currencyCode: "US", merchantCountryCode: "+92"),
                  style: ThemeMode.dark,
                  merchantDisplayName: 'José',
                  appearance: const PaymentSheetAppearance(
                    colors: PaymentSheetAppearanceColors(
                      background: Colors.white,
                      primary: Colors.black,
                      componentBorder: Colors.redAccent,
                    ),
                    shapes: PaymentSheetShape(
                      borderWidth: 4,
                      shadow: PaymentSheetShadowParams(color: Colors.redAccent),
                    ),
                    primaryButton: PaymentSheetPrimaryButtonAppearance(
                      shapes: PaymentSheetPrimaryButtonShape(blurRadius: 8),
                      colors: PaymentSheetPrimaryButtonTheme(
                        light: PaymentSheetPrimaryButtonThemeColors(
                          background: Colors.green,
                          text: Colors.white,
                          border: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  billingDetails: billingDetails,
                ));
                if (!mounted) return;
                //mostrarLoading(context);
                //Navigator.of(context);
                try {
                  await Stripe.instance.presentPaymentSheet().then((value) {
                    mostrarAlerta(context, 'Pago',
                        'El pago se realizo correctamente', 'ok');
                  });
                } catch (e) {
                  log('Error: $e');
                }
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: Stack(
          children: [
            Positioned(
              width: sizeScreen.width,
              height: sizeScreen.height,
              top: 50,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.85),
                physics: const BouncingScrollPhysics(),
                itemCount: tarjetas.length,
                itemBuilder: (BuildContext context, int index) {
                  final tarjeta = tarjetas[index];

                  return GestureDetector(
                    onTap: () {
                      //log('Nombre tarjeta: ${tarjeta.cardHolderName}');
                      final pagarBloc = BlocProvider.of<PagarBloc>(context);

                      pagarBloc.add(OnSeleccionarTarjeta(tarjeta));

                      Navigator.push(
                          context, navegarFadeIn(context, const TarjetaPage()));
                    },
                    child: Hero(
                      tag: tarjeta.cardNumber,
                      child: CreditCardWidget(
                        expiryDate: tarjeta.expiracyDate,
                        cardHolderName: tarjeta.cardHolderName,
                        cvvCode: tarjeta.cvv,
                        cardNumber: tarjeta.cardNumber,
                        bankName: 'Tipre Bank',
                        showBackView: false,
                        obscureCardNumber: true,
                        obscureCardCvv: true,
                        animationDuration: const Duration(milliseconds: 300),
                        onCreditCardWidgetChange: (CreditCardBrand brand) {},
                        chipColor: Colors.amberAccent,
                        //glassmorphismConfig: Glassmorphism.defaultConfig(),
                        isHolderNameVisible: true,
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'halter',
                          fontSize: 12,
                          package: 'flutter_credit_card',
                        ),
                        backgroundImage: 'assets/card_bg.png',
                        isChipVisible: false,
                        isSwipeGestureEnabled: true,
                      ),
                    ),
                  );
                },
              ),
            ),
            const Positioned(
              bottom: 0,
              child: TotalPayButton(),
            ),
          ],
        ));
  }
}
