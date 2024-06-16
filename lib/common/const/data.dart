import 'dart:io';

const ACCESS_TOKEN_KEY = 'ACCESS_TOKEN';
const REFRESH_TOKEN_KEY = 'REFRESH_TOKEN';

final emulatorIpBase = '10.0.2.2';
final simulatorIpBase = '127.0.0.1';

final commonServerPort = '8080';
final apiServerPort = '8081';

final commonServerIp = Platform.isIOS ? '$simulatorIpBase:$commonServerPort' : '$emulatorIpBase:$commonServerPort';
final apiServerIp = Platform.isIOS ? '$simulatorIpBase:$apiServerPort' : '$emulatorIpBase:$apiServerPort';

final commonServerBaseUrl = '$commonServerIp';
final apiServerBaseUrl = '$apiServerIp';
