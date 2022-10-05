import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tipre_pay/blocs/blocs.dart';
import 'package:tipre_pay/pages/pages.dart';
import 'package:tipre_pay/services/services.dart';

void main() {
  //Inicializar servicio pago
  StripeService stripeService = StripeService();
  stripeService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => PagarBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        //theme: customAppTheme,
        title: 'TiprePay',
        initialRoute: 'home',
        routes: {
          'home': (context) => const HomePage(),
          'pago': (context) => const PagoPage(),
        },

        theme: ThemeData.light().copyWith(
            primaryColor: const Color(0xff284879),
            scaffoldBackgroundColor: const Color(0xff21232a)),
      ),
    );
  }
}

final customAppTheme = ThemeData(
  colorScheme: const ColorScheme.light(
    primary: Color(0xff6058F7),
    secondary: Color(0xff6058F7),
  ),
  primaryColor: const Color(0xff21232a),
  appBarTheme: const AppBarTheme(elevation: 1),
);
