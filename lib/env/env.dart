import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'GEMINI_API_KEY', obfuscate: true)
  static final String geminiApiKey = _Env.geminiApiKey;

  @EnviedField(varName: 'ROSTER_API_URL', obfuscate: true)
  static final String rosterApiUrl = _Env.rosterApiUrl;

  @EnviedField(varName: 'ROSTER_API_KEY', obfuscate: true)
  static final String rosterApiKey = _Env.rosterApiKey;

  @EnviedField(varName: 'LINE_CHANNEL_ID', obfuscate: true)
  static final String lineChannelId = _Env.lineChannelId;

  @EnviedField(varName: 'LINE_CHANNEL_SECRET', obfuscate: true)
  static final String lineChannelSecret = _Env.lineChannelSecret;

  @EnviedField(varName: 'LINE_CHANNEL_ACCESS_TOKEN', obfuscate: true)
  static final String lineChannelAccessToken = _Env.lineChannelAccessToken;

  @EnviedField(varName: 'LINE_GROUP_ID', obfuscate: true, optional: true)
  static final String? lineGroupId = _Env.lineGroupId;
}
