import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_credit_card/credit_card_brand.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:tipre_pay/blocs/blocs.dart';
import 'package:tipre_pay/widgets/widgets.dart';

class TarjetaPage extends StatelessWidget {
  const TarjetaPage({super.key});
  @override
  Widget build(BuildContext context) {
    final pagarBloc = BlocProvider.of<PagarBloc>(context);
    final tarjeta = pagarBloc.state.tarjeta!;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Pagar'),
          leading: IconButton(
            onPressed: () {
              pagarBloc.add(OnDesactivarTrajeta());

              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: Stack(
          children: [
            Container(),
            Hero(
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
                height: 220,
                width: MediaQuery.of(context).size.width,
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'halter',
                  fontSize: 14,
                  package: 'flutter_credit_card',
                ),
                backgroundImage: 'assets/card_bg.png',
                isChipVisible: false,
                labelCardHolder: 'Tarjeta de crédito',
                isSwipeGestureEnabled: true,
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
