import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../pages/privacy_policy_page.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  bool get _showDemoDataAction => false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;
    final role = provider.activeRole;

    return Drawer(
      backgroundColor: AppTheme.charcoal2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppTheme.charcoal3, width: 1.5),
                ),
              ),
              child: Row(
                children: [
                  // Logo circular
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.copperGradient,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'MM',
                      style: GoogleFonts.cormorantGaramond(
                        color: AppTheme.charcoal,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MesaMestre',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          color: AppTheme.cream,
                        ),
                      ),
                      Text(
                        'GESTÃO DE RESTAURANTE',
                        style: GoogleFonts.inter(
                          fontSize: 7,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Navegação ───────────────────────────────────────────
            if (role != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 10),
                      child: Text(
                        role.label.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.5,
                          color: AppTheme.copper,
                        ),
                      ),
                    ),
                    ..._buildNavItems(context, role),
                  ],
                ),
              ),

            const Spacer(),

            // ── Rodapé: Perfil + Logout ──────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppTheme.charcoal3, width: 1.5),
                ),
              ),
              child: Column(
                children: [
                  if (user != null) ...[
                    // Card do usuário
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.charcoal3.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: AppTheme.charcoal3, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          // Avatar
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.copper.withValues(alpha: 0.2),
                              border: Border.all(
                                  color:
                                      AppTheme.copper.withValues(alpha: 0.4)),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : 'U',
                              style: GoogleFonts.cormorantGaramond(
                                color: AppTheme.copper,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.cream,
                                  ),
                                ),
                                Text(
                                  user.roleLabel.toUpperCase(),
                                  style: GoogleFonts.inter(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.5,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Botão de logout
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      context.read<AppProvider>().logout();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.wine.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppTheme.wine.withValues(alpha: 0.3),
                            width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.logout,
                              size: 16, color: AppTheme.wine),
                          const SizedBox(width: 10),
                          Text(
                            'SAIR DA CONTA',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: AppTheme.wine,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildNavItems(BuildContext context, dynamic role) {
    return [
      _SidebarItem(
        icon: Icons.dashboard_outlined,
        label: 'Visão Geral',
        active: true,
        onTap: () => Navigator.pop(context),
      ),
      _SidebarItem(
        icon: Icons.privacy_tip_outlined,
        label: 'Política de Privacidade',
        onTap: () {
          Navigator.pop(context); // fecha o drawer
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PrivacyPolicyPage(),
            ),
          );
        },
      ),
      if (_showDemoDataAction)
        _SidebarItem(
          icon: Icons.auto_fix_high_outlined,
          label: 'Gerar Dados Demo',
          onTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Gerando dados de demonstração...',
                  style: GoogleFonts.inter(fontSize: 13),
                ),
                backgroundColor: AppTheme.charcoal2,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                margin: const EdgeInsets.all(16),
              ),
            );
          },
        ),
    ];
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.active || _pressed;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.copper.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? AppTheme.copper.withValues(alpha: 0.4)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              widget.icon,
              size: 18,
              color: isActive ? AppTheme.copper : AppTheme.textMuted,
            ),
            const SizedBox(width: 12),
            Text(
              widget.label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isActive ? AppTheme.cream : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
