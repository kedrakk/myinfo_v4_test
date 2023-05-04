const String img = "assets/images/retrieve.png";
const String backendURL = "https://test.api.myinfo.gov.sg/com/v4";
const String authoriseJWKSURL =
    "https://test.authorise.singpass.gov.sg/.well-known/keys.json";
const String purpose = "demonstration";
const String scope = "uinfin name";
const String clientId = "STG2-MYINFO-SELF-TEST";
const String callBackURL = "http://localhost:3001/callback";
const String responseType = "code";
const String codeChallengeMethod = "S256";
const String typ = "dpop+jwt";
const String alg = "ES256";
const String clientAssertionType =
    "urn:ietf:params:oauth:client-assertion-type:jwt-bearer";
const String signingKeyPath = "assets/cert/app-signing-private-key.pem";
const String encryptionKeyPath =
    "assets/cert/encryption-private-keys/app-encryption-private-key.pem";
