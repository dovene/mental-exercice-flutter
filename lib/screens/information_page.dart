import '../screens/privacy_policy_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/subscription_page.dart';

class InformationPage extends StatelessWidget {
  final String contactEmail = "office@inaxxe.com";
  final String contactPhone = "+33 6 60 50 66 26";
  final String privacyPolicyUrl = "https://inaxxe.com/mathomagic/privacy-mathomagic.html";

  const InformationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informations',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo.shade100.withOpacity(0.3),
              Colors.white,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionTitle(context, 'Bienvenue dans notre espace informations'),
            const SizedBox(height: 24),
            _buildSubscriptionSection(context),
            const SizedBox(height: 24),
            _buildContactSection(context),
            const SizedBox(height: 24),
            _buildPrivacyPolicySection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Center(
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 100,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionSection(BuildContext context) {
    return _buildInfoCard(
      context,
      title: 'Gérer vos abonnements',
      icon: Icons.card_membership,
      iconColor: Colors.indigo,
      description: 'Accédez à toutes nos formules d\'abonnement pour profiter de l\'expérience complète Math Pour Enfants.',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SubscriptionPage(),
            settings: const RouteSettings(name: 'subscription_page'),
          ),
        );
      },
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.contact_support, color: Colors.blue.shade700, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Contactez nous',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Notre équipe est disponible pour répondre à toutes vos questions.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            _buildContactMethod(
              context,
              icon: Icons.email_outlined,
              title: 'Email',
              subtitle: contactEmail,
              onTap: () => _launchEmail(context),
              showCopy: true,
              valueToCopy: contactEmail,
            ),
            const SizedBox(height: 16),
            _buildContactMethod(
              context,
              icon: Icons.phone_outlined,
              title: 'Téléphone',
              subtitle: contactPhone,
              onTap: () => _launchPhone(context),
              showCopy: true,
              valueToCopy: contactPhone,
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              'Disponible du lundi au vendredi de 9h à 18h.\nUtilisez de préférence Whatsapp.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactMethod(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
        bool showCopy = false,
        String? valueToCopy,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.indigo),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (showCopy && valueToCopy != null)
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: valueToCopy));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$title copié !'),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                tooltip: 'Copier',
                color: Colors.grey.shade600,
              ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyPolicySection(BuildContext context) {
    return _buildInfoCard(
      context,
      title: 'Politique de confidentialité',
      icon: Icons.security,
      iconColor: Colors.green.shade700,
      description: 'Consultez notre politique de confidentialité pour en savoir plus sur la façon dont nous protégeons vos données.',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PrivacyPolicyPage(url: privacyPolicyUrl),
            settings: const RouteSettings(name: 'privacy_policy_page'),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color iconColor,
        required String description,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: contactEmail,
      query: _encodeQueryParameters(<String, String>{
        'subject': 'Support Math Pour Enfants',
        'body': 'Bonjour',
      }),
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        // Fallback: copy email to clipboard and show dialog
        await _showContactFallback(context, 'Email', contactEmail);
      }
    } catch (e) {
      await _showContactFallback(context, 'Email', contactEmail);
    }
  }

  Future<void> _launchPhone(BuildContext context) async {
    // Clean phone number for tel: scheme
    final String cleanPhone = contactPhone.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri phoneUri = Uri(scheme: 'tel', path: cleanPhone);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        // Fallback: copy phone to clipboard and show dialog
        await _showContactFallback(context, 'Téléphone', contactPhone);
      }
    } catch (e) {
      await _showContactFallback(context, 'Téléphone', contactPhone);
    }
  }

  Future<void> _showContactFallback(BuildContext context, String type, String value) async {
    // Copy to clipboard
    await Clipboard.setData(ClipboardData(text: value));

    // Show dialog with options
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Contacter par $type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Aucune application disponible pour ouvrir automatiquement ce lien.'),
              const SizedBox(height: 16),
              Text('$type: $value'),
              const SizedBox(height: 8),
              Text('✓ Copié dans le presse-papiers',
                  style: TextStyle(color: Colors.green.shade700)),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
    '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}