import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.charcoal,
      appBar: AppBar(
        backgroundColor: AppTheme.charcoal2,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.charcoal3, width: 1.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                size: 14, color: AppTheme.textMuted),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Política de Privacidade',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.cream,
              ),
            ),
            Text(
              'MESAMESTRE',
              style: GoogleFonts.inter(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.charcoal2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.copper.withValues(alpha: 0.4), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MesaMestre',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.copper,
                      ),
                    ),
                    Text(
                      'Gestão Profissional de Restaurantes',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(height: 1, color: AppTheme.charcoal3),
                    const SizedBox(height: 12),
                    Text(
                      'Última atualização: junho de 2025',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              _Secao(
                numero: '1',
                titulo: 'Introdução',
                conteudo:
                    'A presente Política de Privacidade descreve como o aplicativo MesaMestre coleta, utiliza, armazena e protege as informações dos seus usuários. Ao utilizar o aplicativo, você concorda com os termos aqui descritos.\n\nO MesaMestre é um sistema de gestão operacional destinado a estabelecimentos gastronômicos, utilizado exclusivamente por funcionários devidamente autorizados — garçons, equipe de cozinha, balconistas e administradores.',
              ),

              _Secao(
                numero: '2',
                titulo: 'Dados Coletados',
                conteudo:
                    'Para o funcionamento do aplicativo, coletamos:\n\n• E-mail profissional utilizado no cadastro\n• Senha de acesso (armazenada de forma criptografada)\n• Perfil de função (garçom, cozinheiro, balconista ou administrador)\n• Nome completo do funcionário\n\nDurante o uso, são gerados registros operacionais:\n\n• Pedidos realizados, itens solicitados e valores\n• Número e status das mesas\n• Histórico de alterações de status de pedidos\n• Registros de horário de criação e atualização\n• Observações inseridas nos pedidos',
              ),

              _Secao(
                numero: '3',
                titulo: 'Finalidade do Uso',
                conteudo:
                    'As informações coletadas são utilizadas exclusivamente para:\n\n• Autenticar e autorizar o acesso dos funcionários\n• Gerenciar o fluxo operacional do restaurante\n• Garantir a segurança e integridade das operações\n• Gerar relatórios internos de desempenho\n• Manutenção e suporte técnico do aplicativo\n• Cumprimento de obrigações legais\n\nO MesaMestre não utiliza os dados para fins publicitários nem os vende a terceiros.',
              ),

              _Secao(
                numero: '4',
                titulo: 'Base Legal (LGPD)',
                conteudo:
                    'O tratamento dos dados pessoais fundamenta-se nas seguintes bases legais, conforme a Lei Geral de Proteção de Dados (Lei nº 13.709/2018):\n\n• Execução de contrato: necessário para viabilizar a relação de trabalho\n• Legítimo interesse: para segurança e operação do aplicativo\n• Cumprimento de obrigação legal: quando exigido por legislação',
              ),

              _Secao(
                numero: '5',
                titulo: 'Compartilhamento de Dados',
                conteudo:
                    'Os dados são tratados de forma confidencial. O compartilhamento pode ocorrer apenas nas seguintes situações:\n\n• Google Firebase: plataforma de backend que armazena e sincroniza os dados em nuvem com segurança (policies.google.com/privacy)\n• Autoridades competentes: quando exigido por ordem judicial\n• Prestadores de serviços técnicos: mediante acordo de confidencialidade',
              ),

              _Secao(
                numero: '6',
                titulo: 'Armazenamento e Segurança',
                conteudo:
                    'Adotamos medidas técnicas para proteger os dados:\n\n• Senhas sempre criptografadas — nunca armazenadas em texto plano\n• Comunicação via HTTPS/TLS\n• Controle de acesso por perfil de função\n• Autenticação via Firebase Authentication\n• Regras de segurança no Firestore\n\nOs dados são retidos enquanto o estabelecimento mantiver conta ativa.',
              ),

              _Secao(
                numero: '7',
                titulo: 'Direitos dos Usuários',
                conteudo:
                    'Em conformidade com a LGPD, você tem direito a:\n\n• Acesso: saber quais dados seus estão armazenados\n• Correção: corrigir dados incompletos ou incorretos\n• Exclusão: solicitar a remoção dos seus dados\n• Portabilidade: receber seus dados em formato estruturado\n• Oposição: opor-se a tratamentos em desconformidade com a lei',
              ),

              _Secao(
                numero: '8',
                titulo: 'Menores de Idade',
                conteudo:
                    'O MesaMestre é destinado exclusivamente ao uso profissional por funcionários adultos. Não coletamos intencionalmente dados de pessoas menores de 18 anos.',
              ),

              _Secao(
                numero: '9',
                titulo: 'Alterações nesta Política',
                conteudo:
                    'Esta Política pode ser atualizada periodicamente. Alterações significativas serão comunicadas pelo próprio aplicativo. O uso continuado após alterações implica aceitação dos novos termos.',
              ),

              _Secao(
                numero: '10',
                titulo: 'Contato',
                conteudo:
                    'Para dúvidas ou solicitações relacionadas a dados pessoais:\n\nE-mail: privacidade@mesamestre.com.br\nPrazo de resposta: até 15 dias úteis',
              ),

              const SizedBox(height: 32),

              // Rodapé
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.charcoal2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.charcoal3, width: 1.5),
                ),
                child: Text(
                  '© MesaMestre · Gestão Profissional de Restaurantes\nEsta política entra em vigor na data de sua publicação.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                    height: 1.8,
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Componente de seção ───────────────────────────────────────────
class _Secao extends StatelessWidget {
  final String numero;
  final String titulo;
  final String conteudo;

  const _Secao({
    required this.numero,
    required this.titulo,
    required this.conteudo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título da seção
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.copper.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: AppTheme.copper.withValues(alpha: 0.4), width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  numero,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.copper,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                titulo,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.cream,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Linha decorativa
          Container(
            height: 1,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.copper.withValues(alpha: 0.4),
                  AppTheme.charcoal3.withValues(alpha: 0),
                ],
              ),
            ),
          ),

          // Conteúdo
          Text(
            conteudo,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.textLight,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}