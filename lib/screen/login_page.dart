import 'package:fiado_app/screen/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../service/auth_service.dart';
import '../storage/token_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final cpfController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = AuthService();

  bool isLoading = false;
  bool obscurePassword = true;
  String? errorMessage;

  static const _coral = Color(0xFFD85A30);
  static const _coralLight = Color(0xFFFAECE7);

  Future<void> handleLogin() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final cpf = cpfController.text.trim();
      final password = passwordController.text.trim();

      if (cpf.isEmpty || password.isEmpty) {
        setState(() {
          errorMessage = 'Preencha todos os campos';
        });
        return;
      }

      final result = await authService.login(cpf, password);

      if (result != null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }
      } else {
        setState(() {
          errorMessage = 'CPF ou senha inválidos. Tente novamente.';
        });
      }
    } catch (e) {
      _showErrorModal(e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Top coral band ─────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 40,
                left: 28,
                right: 28,
                bottom: 32,
              ),
              decoration: const BoxDecoration(
                color: _coral,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'CADERNETA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Bem-vindo de volta',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Faça login para continuar',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            // ── Form ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // CPF
                  _buildLabel('CPF'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: cpfController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(fontSize: 14),
                    onSubmitted: (_) => handleLogin(),
                    decoration: _inputDecoration(
                      hint: '000.000.000-00',
                      prefixIcon: Icons.person_outline_rounded,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Senha
                  _buildLabel('SENHA'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    style: const TextStyle(fontSize: 14),
                    onSubmitted: (_) => handleLogin(),
                    decoration: _inputDecoration(
                      hint: '••••••••',
                      prefixIcon: Icons.lock_outline_rounded,
                      highlighted: true,
                      suffix: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 18,
                          color: scheme.onSurfaceVariant,
                        ),
                        onPressed: () =>
                            setState(() => obscurePassword = !obscurePassword),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ),

                  // Error message
                  if (errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCEBEB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFF09595),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: Color(0xFFA32D2D),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFA32D2D),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Botão entrar
                  FilledButton.icon(
                    onPressed: isLoading ? null : handleLogin,
                    icon: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.login_rounded, size: 18),
                    label: Text(
                      isLoading ? 'Entrando...' : 'Entrar',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: _coral,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _coral.withValues(alpha: 0.6),
                      disabledForegroundColor: Colors.white70,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Row(
                  //   children: [
                  //     Expanded(child: Divider(color: scheme.outlineVariant)),
                  //     Padding(
                  //       padding: const EdgeInsets.symmetric(horizontal: 12),
                  //       child: Text(
                  //         'não tem conta?',
                  //         style: TextStyle(
                  //           fontSize: 11,
                  //           color: scheme.onSurfaceVariant,
                  //         ),
                  //       ),
                  //     ),
                  //     Expanded(child: Divider(color: scheme.outlineVariant)),
                  //   ],
                  // ),

                  // const SizedBox(height: 16),

                  // OutlinedButton(
                  //   onPressed: () {
                  //     // futura tela de cadastro
                  //   },
                  //   style: OutlinedButton.styleFrom(
                  //     foregroundColor: scheme.onSurface,
                  //     side: BorderSide(
                  //       color: scheme.outlineVariant,
                  //       width: 0.5,
                  //     ),
                  //     minimumSize: const Size(double.infinity, 50),
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(12),
                  //     ),
                  //   ),
                  //   child: const Text(
                  //     'Criar conta',
                  //     style: TextStyle(
                  //       fontSize: 14,
                  //       fontWeight: FontWeight.w500,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  );

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    bool highlighted = false,
    Widget? suffix,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
      prefixIcon: Icon(
        prefixIcon,
        size: 18,
        color: highlighted ? _coral : scheme.onSurfaceVariant,
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: highlighted
          ? const Color(0xFFFAECE7).withValues(alpha: 0.3)
          : scheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: scheme.outlineVariant, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: highlighted
            ? const BorderSide(color: _coral, width: 1.5)
            : BorderSide(color: scheme.outlineVariant, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _coral, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  void _showErrorModal(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Atenção'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
