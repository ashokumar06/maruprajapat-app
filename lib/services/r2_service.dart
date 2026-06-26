import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';

class R2Service {
  static final R2Service _instance = R2Service._internal();
  factory R2Service() => _instance;
  R2Service._internal();

  /// Uploads a file buffer directly to Cloudflare R2 bucket.
  /// Returns the uploaded object URL.
  Future<String> uploadObject({
    required Uint8List fileBytes,
    required String objectKey,
    required String contentType,
  }) async {
    final accessKey = EnvConfig.cfR2AccessKeyId;
    final secretKey = EnvConfig.cfR2SecretAccessKey;
    final endpoint = EnvConfig.cfR2Endpoint; // Host prefix
    final bucket = EnvConfig.cfR2BucketName;

    if (accessKey.isEmpty || secretKey.isEmpty || endpoint.isEmpty) {
      throw Exception("Cloudflare R2 credentials are not set in the .env file.");
    }

    // Prepare endpoint URL: e.g. https://<account_id>.r2.cloudflarestorage.com/<bucket>/<objectKey>
    final uri = Uri.parse("$endpoint/$bucket/$objectKey");
    final host = uri.host;

    // Calculate dates
    final now = DateTime.now().toUtc();
    final dateStr =
        '${now.toIso8601String().replaceAll('-', '').replaceAll(':', '').split('.')[0]}Z';
    final shortDateStr = dateStr.substring(0, 8);

    // Headers
    final headers = {
      'host': host,
      'x-amz-content-sha256': _sha256Hex(fileBytes),
      'x-amz-date': dateStr,
      'content-type': contentType,
    };

    // Calculate signature
    final authorization = _calculateSignature(
      method: 'PUT',
      uri: uri,
      headers: headers,
      shortDate: shortDateStr,
      fullDate: dateStr,
      payloadHash: headers['x-amz-content-sha256']!,
      accessKey: accessKey,
      secretKey: secretKey,
    );

    headers['Authorization'] = authorization;

    // Send HTTP PUT request
    final response = await http.put(uri, headers: headers, body: fileBytes);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Returns public URL if configured, otherwise falls back to S3 endpoint path
      final publicUrl = EnvConfig.cfR2PublicUrl;
      return publicUrl.isNotEmpty ? "$publicUrl/$objectKey" : "$endpoint/$bucket/$objectKey";
    } else {
      throw Exception(
        "Failed to upload to Cloudflare R2: Status ${response.statusCode}, Body: ${response.body}",
      );
    }
  }

  // AWS SigV4 Implementation
  String _calculateSignature({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    required String shortDate,
    required String fullDate,
    required String payloadHash,
    required String accessKey,
    required String secretKey,
  }) {
    const region = 'auto'; // Cloudflare R2 region defaults to 'auto'
    const service = 's3';

    // 1. Canonical Headers & Signed Headers
    final sortedHeaderKeys = headers.keys.map((k) => k.toLowerCase()).toList()..sort();
    final canonicalHeaders = '${sortedHeaderKeys
        .map((k) => "$k:${headers[k]?.trim().replaceAll(RegExp(r'\s+'), ' ')}")
        .join('\n')}\n';
    final signedHeaders = sortedHeaderKeys.join(';');

    // 2. Canonical Request
    final canonicalUri = uri.path;
    final canonicalQueryString = ''; // No query parameters for simple PUT upload
    final canonicalRequest = [
      method,
      canonicalUri,
      canonicalQueryString,
      canonicalHeaders,
      signedHeaders,
      payloadHash
    ].join('\n');

    final canonicalRequestHash = _sha256StringHex(canonicalRequest);

    // 3. String to Sign
    const algorithm = 'AWS4-HMAC-SHA256';
    final credentialScope = "$shortDate/$region/$service/aws4_request";
    final stringToSign = [
      algorithm,
      fullDate,
      credentialScope,
      canonicalRequestHash
    ].join('\n');

    // 4. Signature Derivation
    final kDate = _hmacSHA256(utf8.encode("AWS4$secretKey"), shortDate);
    final kRegion = _hmacSHA256(kDate, region);
    final kService = _hmacSHA256(kRegion, service);
    final kSigning = _hmacSHA256(kService, 'aws4_request');

    final signature = _hex(_hmacSHA256(kSigning, stringToSign));

    return "$algorithm Credential=$accessKey/$credentialScope, SignedHeaders=$signedHeaders, Signature=$signature";
  }

  // Cryptographic Helper Functions
  String _sha256Hex(List<int> bytes) {
    return sha256.convert(bytes).toString();
  }

  String _sha256StringHex(String data) {
    return sha256.convert(utf8.encode(data)).toString();
  }

  List<int> _hmacSHA256(List<int> key, String data) {
    final hmac = Hmac(sha256, key);
    return hmac.convert(utf8.encode(data)).bytes;
  }

  String _hex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
