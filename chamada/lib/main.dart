import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chamada Automatizada',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF891946)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? proximaChamada;
  int numeroAula = 0;

  // Simulações de status de localização
  bool localizacaoAtiva = true;
  bool localizacaoCorreta = true;

  @override
  void initState() {
    super.initState();
    _calcularProximaChamada();
  }

  void _calcularProximaChamada() {
    final agora = DateTime.now();

    final List<TimeOfDay> horariosChamadas = [
      const TimeOfDay(hour: 19, minute: 50),
      const TimeOfDay(hour: 20, minute: 40),
      const TimeOfDay(hour: 21, minute: 40),
      const TimeOfDay(hour: 22, minute: 30),
    ];

    DateTime? proxima;
    int? aula;

    for (int i = 0; i < horariosChamadas.length; i++) {
      final h = horariosChamadas[i];
      final chamadaHoje = DateTime(
        agora.year,
        agora.month,
        agora.day,
        h.hour,
        h.minute,
      );

      if (agora.isBefore(chamadaHoje)) {
        proxima = chamadaHoje;
        aula = i + 1;
        break;
      }
    }

    if (proxima == null) {
      final h = horariosChamadas.first;
      proxima = DateTime(
        agora.year,
        agora.month,
        agora.day + 1,
        h.hour,
        h.minute,
      );
      aula = 1;
    }

    setState(() {
      proximaChamada = proxima;
      numeroAula = aula!;
    });
  }

  void _validarChamada() {
    final agora = DateTime.now();
    final diferenca = agora.difference(proximaChamada!).inMinutes;

    // Verificações em ordem
    if (agora.isBefore(proximaChamada!)) {
      _mostrarDialogo(
        titulo: 'Chamada NÃO validada!',
        mensagem:
            'Não é possível validar a chamada ainda, aguarde até o próximo horário.',
      );
    } else if (!localizacaoAtiva) {
      _mostrarDialogo(
        titulo: 'Chamada NÃO validada!',
        mensagem:
            'Sua localização não está ativada. Ative-a nas configurações do app para validar a chamada!',
        justificavel: true,
      );
    } else if (!localizacaoCorreta) {
      _mostrarDialogo(
        titulo: 'Chamada NÃO validada!',
        mensagem:
            'Sua localização atual não corresponde à localização da sala de aula para validar sua presença.',
        justificavel: true,
      );
    } else if (diferenca > 1) {
      _mostrarDialogo(
        titulo: 'Chamada NÃO validada!',
        mensagem:
            'Sua validação ultrapassou o 1 minuto limite. Não é possível validar após o tempo limite.',
        justificavel: true,
      );
    } else {
      _mostrarDialogo(
        titulo: 'Chamada Validada!',
        mensagem: 'Chamada ${numeroAula}ª aula registrada com sucesso!',
        sucesso: true,
      );
      _calcularProximaChamada();
    }
  }

  void _mostrarDialogo({
    required String titulo,
    required String mensagem,
    bool sucesso = false,
    bool justificavel = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.black),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    'X',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                titulo,
                style: TextStyle(
                  color: sucesso ? Colors.green : const Color(0xFF891946),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                mensagem,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 20),
              if (justificavel) ...[
                const Text(
                  'Deseja justificar no relatório?',
                  style: TextStyle(
                    color: Color(0xFF891946),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF891946),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Justificar'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color corPrincipal = Color(0xFF891946);
    const Color fundoSuave = Color(0xFFF0DCE1);

    String dataFormatada = proximaChamada != null
        ? '${proximaChamada!.day.toString().padLeft(2, '0')}/'
              '${proximaChamada!.month.toString().padLeft(2, '0')} '
              '${proximaChamada!.hour.toString().padLeft(2, '0')}:'
              '${proximaChamada!.minute.toString().padLeft(2, '0')}'
        : '--/-- --:--';

    return Scaffold(
      backgroundColor: fundoSuave,
      appBar: AppBar(
        backgroundColor: corPrincipal,
        title: const Text(
          'Chamada Automatizada',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // QUADRO PRINCIPAL
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Próxima Chamada ${numeroAula}ª aula',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dataFormatada,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              _BotaoPrincipal(
                texto: 'Validar Chamada',
                cor: corPrincipal,
                onPressed: _validarChamada,
              ),
              const SizedBox(height: 20),
              _BotaoPrincipal(texto: 'Gerar Relatório', cor: corPrincipal),
              const SizedBox(height: 20),
              _BotaoPrincipal(texto: 'Configurações', cor: corPrincipal),
            ],
          ),
        ),
      ),
    );
  }
}

class _BotaoPrincipal extends StatelessWidget {
  final String texto;
  final Color cor;
  final VoidCallback? onPressed;
  const _BotaoPrincipal({
    required this.texto,
    required this.cor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: cor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Colors.black, width: 1),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          texto,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
