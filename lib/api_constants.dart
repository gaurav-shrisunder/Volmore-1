/// Base URL            https://development.d2l5864qp4uooq.amplifyapp.com/login
const String baseUrl = "https://dev.volmore.maizelab-cloud.com/";
// const String baseUrl = "https://volmore.maizelab-cloud.com/";         ///PROD

/// Api endpoints
const String signUpApi = "api/v1/users/signup";
const String loginApi = "api/v1/users/login";
const String deleteUserApi = "api/v1/users/";
const String refreshTokenApi = "api/v1/auth/refreshToken";
const String rolesApi = "api/v1/roles";
const String organisationListApi = "api/v1/organizations";
const String changePasswordApi = "api/v1/users/changePassword";
const String resetPasswordApi = "api/v1/users/resetPassword";
const String sendOtpApi = "api/v1/users/sendOTP";
const String verifyOtpApi = "api/v1/users/verifyOTP";

/// Events related Endpoints
const String createEventCategoryListApi = "api/v1/events/eventCategory";
const String eventParticipantsApi = "api/v1/events/eventParticipant";
const String createEventApi = "api/v1/events/event";
const String deleteEventApi = "api/v1/events/event";
const String deleteEventInstanceApi = "api/v1/events/eventInstance";
const String logPastHours = "api/v1/events/pastEventParticipant";
const String getEventCategoryApi = "api/v1/events/eventCategory/";
const String getEventApi = "api/v1/events/";
const String getEvent = "api/v1/events/eventInstances/details/";
const String getNonVerifiedEventApi = "api/v1/events/nonVerifiedEvents/";

const String leaderboardApi = "api/v1/leaderboard";
const String leaderboardRankingApi = "api/v1/leaderboard/influenceBoard";

//Profile related Endpoint
const String getWeeklyStat = "api/v1/eventStatistics/";

//Transcript
const String getTranscripts = "api/v1/events/users/transcripts/";
const String sharedTranscriptEmails = "api/v1/events/users/recipientsTranscripts/";
const String shareWithTeacherApi = "api/v1/events/users/transcripts/share";
