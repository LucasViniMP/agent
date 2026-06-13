import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/staff_login.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'privacy_policy_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final selectedLogin =
        staffLoginForRole(context.read<AppProvider>().activeRole);

    if (selectedLogin != null) {
      _emailController.text = selectedLogin.email;
      _passwordController.text = selectedLogin.password;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<AppProvider>().login(
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<AppProvider>().authError,
            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          backgroundColor: AppTheme.wine,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final role = provider.activeRole;
    final isLoading = provider.authState == AppState.loading;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        context.read<AppProvider>().clearRole();
      },
      child: Scaffold(
        backgroundColor: AppTheme.charcoal,
        body: Stack(
          children: [
            // Padrão decorativo de fundo
            Positioned.fill(
              child: CustomPaint(painter: _HerringbonePainter()),
            ),

            // Gradiente de fundo
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppTheme.charcoal, Color(0xBB101417)],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Column(
                      children: [
                        // Card de login
                        Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: AppTheme.charcoal2,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.charcoal3,
                              width: 1.5,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x80000000),
                                blurRadius: 40,
                                offset: Offset(0, 16),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header do card
                                Row(
                                  children: [
                                    // Botão voltar
                                    GestureDetector(
                                      onTap: () => context
                                          .read<AppProvider>()
                                          .clearRole(),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: AppTheme.charcoal3,
                                            width: 1.5,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: const Icon(
                                          Icons.arrow_back_ios_new,
                                          size: 14,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            role?.label ?? 'Acesso',
                                            style:
                                                GoogleFonts.cormorantGaramond(
                                              fontSize: 26,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.cream,
                                            ),
                                          ),
                                          Text(
                                            'IDENTIFICAÇÃO REQUERIDA',
                                            style: GoogleFonts.inter(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 2,
                                              color: AppTheme.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Ícone de cadeado decorativo
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppTheme.copper
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.lock_outline,
                                        size: 20,
                                        color: AppTheme.copper,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                // Linha divisória decorativa
                                Row(
                                  children: [
                                    const SizedBox(width: 46),
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppTheme.copper,
                                              AppTheme.charcoal3,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 36),

                                // Campo de e-mail
                                BrutalTextField(
                                  label: 'E-mail Profissional',
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) =>
                                      (v == null || !v.contains('@'))
                                          ? 'E-mail inválido'
                                          : null,
                                ),

                                const SizedBox(height: 20),

                                // Campo de senha
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'SENHA DE ACESSO',
                                      style: GoogleFonts.inter(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 2,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      validator: (v) => (v == null || v.isEmpty)
                                          ? 'Informe a senha'
                                          : null,
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                        color: AppTheme.cream,
                                      ),
                                      decoration: InputDecoration(
                                        suffixIcon: GestureDetector(
                                          onTap: () => setState(() =>
                                              _obscurePassword =
                                                  !_obscurePassword),
                                          child: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: AppTheme.textMuted,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 36),

                                // Botão de entrar
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _handleLogin,
                                    child: isLoading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              color: AppTheme.charcoal,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.restaurant_menu,
                                                  size: 16),
                                              const SizedBox(width: 10),
                                              Text(
                                                'ENTRAR',
                                                style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 2,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(duration: 400.ms).slideY(
                            begin: 0.08,
                            end: 0,
                            duration: 400.ms,
                            curve: Curves.easeOutCubic),

                        const SizedBox(height: 24),

                        // Rodapé
                        Text(
                          '© MesaMestre · Gestão Profissional',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            color: AppTheme.charcoal3,
                            letterSpacing: 1,
                          ),
                        ).animate().fadeIn(delay: 400.ms),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PrivacyPolicyPage()),
                          ),
                          child: Text(
                            'Política de Privacidade',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppTheme.copper,
                              decoration: TextDecoration.underline,
                              decorationColor: AppTheme.copper,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Padrão de espinha de peixe decorativo ────────────────────────
class _HerringbonePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x062DD4BF)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const s = 20.0;
    for (double y = 0; y < size.height + s; y += s) {
      for (double x = 0; x < size.width + s; x += s * 2) {
        canvas.drawLine(
          Offset(x, y),
          Offset(x + s, y - s),
          paint,
        );
        canvas.drawLine(
          Offset(x + s, y - s),
          Offset(x + s * 2, y),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_HerringbonePainter oldDelegate) => false;
}
