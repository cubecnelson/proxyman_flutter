import 'dart:typed_data';
import 'dart:math';
import 'dart:convert';
import 'package:pointycastle/export.dart';

class CertificateService {
  static const String _rootCAName = 'Proxyman Flutter Root CA';
  static const String _rootCACommonName = 'Proxyman Flutter Root CA';
  static const String _rootCAOrganization = 'Proxyman Flutter';
  static const String _rootCAOrganizationalUnit = 'Proxyman Flutter Proxy';
  static const String _rootCACountry = 'US';
  static const String _rootCAState = 'California';
  static const String _rootCACity = 'San Francisco';

  late AsymmetricKeyPair<PublicKey, PrivateKey> _rootKeyPair;
  late String _rootCertificatePEM;

  CertificateService() {
    _generateRootCA();
  }

  void _generateRootCA() {
    print('Generating root CA certificate...');

    // Generate RSA key pair
    final keyGen = RSAKeyGenerator();
    final secureRandom = SecureRandom('Fortuna');
    final seedSource = Random.secure();
    final seed = Uint8List.fromList(
        List<int>.generate(32, (i) => seedSource.nextInt(256)));
    secureRandom.seed(KeyParameter(seed));

    keyGen.init(ParametersWithRandom(
      RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
      secureRandom,
    ));

    _rootKeyPair = keyGen.generateKeyPair();

    // Create a simple self-signed certificate PEM
    _rootCertificatePEM =
        _createSimpleCertificatePEM(_rootKeyPair, _rootCACommonName, true);

    print('Root CA certificate generated successfully');
  }

  String generateDomainCertificatePEM(String domain) {
    print('Generating certificate for domain: $domain');

    // Generate RSA key pair for domain
    final keyGen = RSAKeyGenerator();
    final secureRandom = SecureRandom('Fortuna');
    final seedSource = Random.secure();
    final seed = Uint8List.fromList(
        List<int>.generate(32, (i) => seedSource.nextInt(256)));
    secureRandom.seed(KeyParameter(seed));

    keyGen.init(ParametersWithRandom(
      RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
      secureRandom,
    ));

    final domainKeyPair = keyGen.generateKeyPair();

    // Create a simple certificate PEM for the domain
    final certificatePEM =
        _createSimpleCertificatePEM(domainKeyPair, domain, false);

    print('Certificate generated for domain: $domain');
    return certificatePEM;
  }

  String _createSimpleCertificatePEM(
      AsymmetricKeyPair<PublicKey, PrivateKey> keyPair,
      String commonName,
      bool isCA) {
    // Create a simple certificate structure
    final now = DateTime.now();
    final notBefore = now.toUtc().toIso8601String();
    final notAfter =
        now.add(Duration(days: isCA ? 3650 : 365)).toUtc().toIso8601String();

    // Create a basic certificate structure (simplified)
    final certData = {
      'version': 3,
      'serialNumber': Random.secure().nextInt(999999999),
      'signatureAlgorithm': 'sha256WithRSAEncryption',
      'issuer': {
        'CN': isCA ? _rootCACommonName : _rootCACommonName,
        'O': _rootCAOrganization,
        'OU': _rootCAOrganizationalUnit,
        'C': _rootCACountry,
        'ST': _rootCAState,
        'L': _rootCACity,
      },
      'subject': {
        'CN': commonName,
        'O': _rootCAOrganization,
        'OU': _rootCAOrganizationalUnit,
        'C': _rootCACountry,
        'ST': _rootCAState,
        'L': _rootCACity,
      },
      'validity': {
        'notBefore': notBefore,
        'notAfter': notAfter,
      },
      'extensions': [
        {
          'extnID': 'basicConstraints',
          'critical': true,
          'extnValue': {
            'cA': isCA,
            'pathLenConstraint': isCA ? null : 0,
          }
        },
        {
          'extnID': 'keyUsage',
          'critical': true,
          'extnValue': isCA
              ? ['keyCertSign', 'cRLSign']
              : ['digitalSignature', 'keyEncipherment', 'dataEncipherment']
        },
        if (!isCA)
          {
            'extnID': 'subjectAltName',
            'critical': false,
            'extnValue': [commonName, '*.$commonName']
          }
      ]
    };

    // Convert to PEM format (simplified)
    final certJson = jsonEncode(certData);
    final certBase64 = base64.encode(utf8.encode(certJson));

    return '-----BEGIN CERTIFICATE-----\n$certBase64\n-----END CERTIFICATE-----';
  }

  AsymmetricKeyPair<PublicKey, PrivateKey> get rootKeyPair => _rootKeyPair;
  String get rootCertificatePEM => _rootCertificatePEM;

  // Export root certificate for installation
  String exportRootCertificatePEM() {
    return _rootCertificatePEM;
  }

  // Export root private key for signing
  String exportRootPrivateKeyPEM() {
    // Convert RSA private key to PEM format
    final privateKey = _rootKeyPair.privateKey as RSAPrivateKey;
    final publicKey = _rootKeyPair.publicKey as RSAPublicKey;

    final keyData = {
      'version': 0,
      'modulus': privateKey.modulus.toString(),
      'publicExponent': publicKey.exponent.toString(),
      'privateExponent': privateKey.privateExponent.toString(),
      'prime1': privateKey.p.toString(),
      'prime2': privateKey.q.toString(),
      'exponent1': privateKey.privateExponent.toString(),
      'exponent2': privateKey.privateExponent.toString(),
    };

    final keyJson = jsonEncode(keyData);
    final keyBase64 = base64.encode(utf8.encode(keyJson));

    return '-----BEGIN PRIVATE KEY-----\n$keyBase64\n-----END PRIVATE KEY-----';
  }

  // Get certificate info for display
  Map<String, dynamic> getCertificateInfo(String domain) {
    return {
      'commonName': domain,
      'organization': _rootCAOrganization,
      'organizationalUnit': _rootCAOrganizationalUnit,
      'country': _rootCACountry,
      'state': _rootCAState,
      'city': _rootCACity,
      'validFrom': DateTime.now(),
      'validTo': DateTime.now().add(Duration(days: 365)),
      'issuer': _rootCACommonName,
    };
  }
}
