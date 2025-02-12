import 'package:dartz/dartz.dart';
import 'package:defifundr_mobile/features/authentication/data/data_source/authentication_local_datasource.dart';
import 'package:defifundr_mobile/features/authentication/data/data_source/authentication_remote_data_source.dart';
import 'package:defifundr_mobile/features/authentication/data/repositories/authentication_repository.dart';
import 'package:defifundr_mobile/features/authentication/domain/entities/base_entity/base_entity.dart';
import 'package:defifundr_mobile/features/authentication/domain/entities/check_user_entity/check_user_entity.dart';
import 'package:defifundr_mobile/features/authentication/domain/entities/last_user_cache_details/last_user_cache_details.dart';
import 'package:defifundr_mobile/features/authentication/domain/entities/login_entity/login_response_entity.dart'
    as login;
import 'package:defifundr_mobile/features/authentication/domain/entities/register_entity/create_account_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// @GenerateMocks([AuthenticationRemoteDataSource], customMocks: [MockSpec<CreateAccountResponse>(returnNullOnMissingStub: true)])

class MockAuthenticationRemoteDataSource extends Mock
    implements AuthenticationRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late MockAuthenticationRemoteDataSource mockRemoteDataSource;
  late IAuthenticationRepository authenticationRepositoryImpl;

  late MockAuthLocalDataSource mockAuthLocalDataSource;

  late String tUsername = "test";
  late String tEmail = "test@test.com";
  late String tPassword = "test";
  late String tOtpCode = "123456";
  late int tImageId = 1;
  late CreateAccountResponse tCreateAccountResponse;
  late login.LoginResponse tLoginResponse;
  late BaseEntity tBaseResponse;
  late CheckUserEntity tCheckUserEntity;
  late login.UserResponse tUserResponse;

  setUpAll(() {
    mockRemoteDataSource = MockAuthenticationRemoteDataSource();
    mockAuthLocalDataSource = MockAuthLocalDataSource();
    authenticationRepositoryImpl = IAuthenticationRepository(
      remoteDataSource: mockRemoteDataSource,
      authLocalDataSource: mockAuthLocalDataSource,
    );
    tCreateAccountResponse = const CreateAccountResponse(
        data: Data(
            username: "test",
            email: "test@test.com",
            passwordChangedAt: null,
            createdAt: null,
            address: "0xtest",
            balance: "0"),
        message: "success",
        status: 200);
  });

  tUserResponse = const login.UserResponse(
    username: "ademola1",
    email: "",
    passwordChangedAt: null,
    createdAt: null,
    address: "0x1C803Ba37C0494ecD088Fb878d687FAEb5a2EB5E",
    balance: "0.1",
  );

  tCheckUserEntity = const CheckUserEntity(
    data: true,
    message: "success",
    status: 200,
  );

  tLoginResponse = const login.LoginResponse(
    data: login.Data(
      sessionId: "",
      accessToken: "",
      accessTokenExpiresAt: null,
      refreshToken: "",
      refreshTokenExpiresAt: null,
      user: login.UserResponse(
        username: "ademola1",
        email: "",
        passwordChangedAt: null,
        createdAt: null,
        address: "0x1C803Ba37C0494ecD088Fb878d687FAEb5a2EB5E",
        balance: "0.1",
      ),
    ),
    message: "success",
    status: 200,
  );

  tBaseResponse = const BaseEntity(
    message: "success",
    data: "Passed",
    status: 200,
  );

  group("create a new account for users", () {
    test(
        "should return remote data when the call to remote data source is successful",
        () async {
      // arrange
      when(() => mockRemoteDataSource.createAccount(any(), any()))
          .thenAnswer((_) async => tCreateAccountResponse);
      final result = await authenticationRepositoryImpl.createAccount(
        username: tUsername,
        email: tEmail,
      );
      // assert
      verify(() => mockRemoteDataSource.createAccount(any(), any()));
      expect(result, equals(Right(tCreateAccountResponse)));
    });
  });

  group("login user account", () {
    test(
        "should return remote data when the call to remote data source is successful",
        () async {
      // arrange
      when(() => mockRemoteDataSource.login(any(), any()))
          .thenAnswer((_) async {
        return tLoginResponse;
      });

      // act
      final result = await authenticationRepositoryImpl.login(
        username: tUsername,
        password: tPassword,
      );

      final lastCacheDetails = LastUserCachedDetails(
        password: tPassword,
        username: tUsername,
        email: tLoginResponse.data!.user.email,
        isBiometric: tLoginResponse.data!.user.biometrics,
      );

      await mockAuthLocalDataSource.cacheUserLoginData(
          lastUserCachedDetails: lastCacheDetails);

      await mockAuthLocalDataSource.cacheUserDetails(user: tUserResponse);

      await mockAuthLocalDataSource.saveAccessToken(
          token: tLoginResponse.data!.accessToken);

      // assert
      verify(() => mockRemoteDataSource.login(any(), any()));
      expect(result, equals(Right(tLoginResponse)));
    });
  });

  group("verifyOtp user account", () {
    test(
        "should return remote data when the call to remote data source is successful",
        () async {
      // arrange
      when(() => mockRemoteDataSource.verifyOtp(
              username: any(
                named: "username",
              ),
              otpCode: any(named: "otpCode")))
          .thenAnswer((_) async => tBaseResponse);
      // act
      final result = await authenticationRepositoryImpl.verifyOtp(
        username: tUsername,
        otpCode: tOtpCode,
      );
      // assert
      verify(() => mockRemoteDataSource.verifyOtp(
          username: any(named: "username"), otpCode: any(named: "otpCode")));
      expect(result, equals(Right(tBaseResponse)));
    });
  });

  group("resendOTP user account", () {
    test(
        "should return remote data when the call to remote data source is successful",
        () async {
      // arrange
      when(() => mockRemoteDataSource.resendOTP(
            userId: any(
              named: "userId",
            ),
          )).thenAnswer((_) async => tBaseResponse);
      // act
      final result = await authenticationRepositoryImpl.resendOTP(
        userId: tUsername,
      );
      // assert
      verify(() => mockRemoteDataSource.resendOTP(
            userId: any(named: "userId"),
          ));
      expect(result, equals(Right(tBaseResponse)));
    });
  });

  group("resetPassword user account", () {
    test(
        "should return remote data when the call to remote data source is successful",
        () async {
      // arrange
      when(() => mockRemoteDataSource.resetPassword(
            username: any(
              named: "username",
            ),
          )).thenAnswer((_) async => tBaseResponse);
      // act
      final result = await authenticationRepositoryImpl.resetPassword(
        username: tUsername,
      );
      // assert
      verify(() => mockRemoteDataSource.resetPassword(
            username: any(named: "username"),
          ));
      expect(result, equals(Right(tBaseResponse)));
    });
  });

  group("verifyPasswordResetCode user account", () {
    test(
        "should return remote data when the call to remote data source is successful",
        () async {
      // arrange
      when(() => mockRemoteDataSource.verifyPasswordResetCode(
              username: any(
                named: "username",
              ),
              otpCode: any(named: "otpCode"),
              password: any(named: "password")))
          .thenAnswer((_) async => tBaseResponse);
      // act
      final result = await authenticationRepositoryImpl.verifyPasswordResetCode(
          username: tUsername, otpCode: tOtpCode, password: tPassword);
      // assert
      verify(() => mockRemoteDataSource.verifyPasswordResetCode(
          username: any(
            named: "username",
          ),
          otpCode: any(named: "otpCode"),
          password: any(named: "password")));
      expect(result, equals(Right(tBaseResponse)));
    });
  });

  // checkUsernameExists
  group("checkUsernameExists user account", () {
    test(
        "should return remote data when the call to remote data source is successful",
        () async {
      // arrange
      when(() => mockRemoteDataSource.checkUsernameExists(
              username: any(
            named: "username",
          ))).thenAnswer((_) async => tCheckUserEntity);
      // act
      final result = await authenticationRepositoryImpl.checkUsernameExists(
          username: tUsername);
      // assert
      verify(() => mockRemoteDataSource.checkUsernameExists(
              username: any(
            named: "username",
          )));
      expect(result, equals(Right(tCheckUserEntity)));
    });
  });

  // setProfileAvatar
  group("setProfileAvatar user account", () {
    test(
        "should return remote data when the call to remote data source is successful",
        () async {
      // arrange
      when(() => mockRemoteDataSource.setProfile(
            imageId: any(
              named: "imageId",
            ),
          )).thenAnswer((_) async => tUserResponse);
      // act
      final result = await authenticationRepositoryImpl.setProfileAvatar(
          imageId: tImageId);
      // assert
      verify(() => mockRemoteDataSource.setProfile(
            imageId: any(
              named: "imageId",
            ),
          ));
      expect(result, equals(Right(tUserResponse)));
    });
  });

  // getUserDetails
  group("getUserDetails user account", () {
    test(
        "should return remote data when the call to remote data source is successful",
        () async {
      // arrange
      when(() => mockRemoteDataSource.getUserDetails())
          .thenAnswer((_) async => tUserResponse);
      // act
      final result = await authenticationRepositoryImpl.getUserDetails();
      await mockAuthLocalDataSource.cacheUserDetails(user: tUserResponse);
      // assert
      verify(() => mockRemoteDataSource.getUserDetails());
      expect(result, equals(Right(tUserResponse)));
    });
  });
}
