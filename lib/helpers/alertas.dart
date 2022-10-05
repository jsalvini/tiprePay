part of 'helpers.dart';

mostrarLoading(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const AlertDialog(
        title: Text('Espere un momento por favor.'),
        content: LinearProgressIndicator(),
      );
    },
  );
}

mostrarAlerta(BuildContext context, String titulo, String mensaje, String type) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(titulo),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
           Icon(
            (type == 'ok') ? Icons.check_circle : Icons.error,
            color: (type == 'ok') ? Colors.green : Colors.red,
            size: 64,
          ),
          const SizedBox(height: 10),
          Text(mensaje),
        ],
      ),
      actions: [
        MaterialButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Ok'),
        )
      ],
    ),
  );
}
