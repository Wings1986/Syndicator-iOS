//
//  SSConstants.h
//  StarSiteCMS
//
//  Created by Vincent Tuscano on 9/27/14.
//  Copyright (c) 2014 Vincent Tuscano. All rights reserved.
//



// Changing the API version number must be done in 2 parts: First the String definition and then the Pre-Procecessor Symbol


#define API_VERSION_NUMBER @"3.4"     // String def.
#define API_3_4                        //  Pre-Procecessor Symbol for this string version



#define kEnvironment 1

#if kEnvironment == 1

#ifdef DARWINAPI
#define WEB_SERVICE_ROOT @"http://darwin.on.starsite.com/api/"
#endif

#ifdef GEEKAPI
#define WEB_SERVICE_ROOT @"http://geek.starsite.com/api/"
#endif

#ifdef BETAAPI
#define WEB_SERVICE_ROOT @"http://beta.starsite.com/api/"
#endif

#endif

#if kEnvironment == 2
#define WEB_SERVICE_ROOT @"http://darwin-local.on.starsite.com/api/"
#endif


#define URL_TERMS @"http://darwin.on.starsite.com/template/_terms.php"
#define URL_PRIVACY @"http://darwin.on.starsite.com/template/_privacy.php"


#define FONT_ICONS @"starsite"
#define COLOR_GOLD @"#FFB300"
#define COLOR_PURPLE @"#9701A4"
#define COLOR_GRAY_LINE @"#444444"

#define COLOR_TAN @"#CAA163"
#define COLOR_TEAL @"#5F9CA5"
#define COLOR_PINK @"#DB736E"

#define COLOR_PURPLE_BEGIN @"#B6ADC3"
#define COLOR_PURPLE_END @"#9082A0"

#define COLOR_TEAL_BEGIN @"#A2B6BA"
#define COLOR_TEAL_END @"#829B9F"

#define COLOR_PEACH_BEGIN @"#BFA7AF"
#define COLOR_PEACH_END @"#A1828C"


#define COLOR_DARK_BEGIN @"#404E58"
#define COLOR_DARK_END @"#070B0E"

#define COLOR_TWITTER_BLUE @"#1DAEEC"

#define FONT_HELVETICA_NEUE_BOLD @"HelveticaNeue-Bold"
#define FONT_HELVETICA_NEUE_LIGHT @"HelveticaNeue-Light"
#define FONT_HELVETICA_NEUE_THIN @"HelveticaNeue-Thin"
#define FONT_HELVETICA_NEUE @"HelveticaNeue"

#define AVIERY_KEY @"269ed7dcaebea885"
#define AVIERY_SECRET @"2d5f9334e87e1e12"

#define TW_KEY @"rOnDmArOdei9TqZpqqJ53x4Il"
#define TW_SECRET @"9sJv3d8zjTb9WNrYTdtlDiiblhCog2plq6A0ZvS4Mli2bqxCRL"

#define NOTIFICATION_UPLOAD_PROGRESS @"NOTIFICATION_UPLOAD_PROGRESS"
#define NOTIFICATION_ACCOUNT_STORE_CHANGED @"NOTIFICATION_ACCOUNT_STORE_CHANGED"
#define NOTIFICATION_BACK_FROM_FB_AUTH @"NOTIFICATION_BACK_FROM_FB_AUTH"
#define NOTIFICATION_ENTERED_BACKGROUND @"NOTIFICATION_ENTERED_BACKGROUND"
#define NOTIFICATION_ENTERED_FOREGROUND @"NOTIFICATION_ENTERED_FOREGROUND"
#define NOTIFICATION_ADJUST_SHARING_VIEW @"NOTIFICATION_ADJUST_SHARING_VIEW"
#define NOTIFICATION_EDITING_LOWER_SHARING @"NOTIFICATION_EDITING_LOWER_SHARING"

#define NOTIFICATION_PARING_ADD_MORE @"NOTIFICATION_PARING_ADD_MORE"
#define NOTIFICATION_PARING_TOGGLE_CHANGED @"NOTIFICATION_PARING_TOGGLE_CHANGED"

#define NOTIFICATION_USER_INFO_UPDATED @"NOTIFICATION_USER_INFO_UPDATED"
#define NOTIFICATION_UPDATE_LOGIN_DETAILS @"NOTIFICATION_UPDATE_LOGIN_DETAILS"

#define NOTIFICATION_USER_SOCIAL_OAUTH_ID_PAIRED @"NOTIFICATION_USER_SOCIAL_OAUTH_ID_PAIRED"
#define NOTIFICATION_PUSH_RECEIVED @"NOTIFICATION_PUSH_RECEIVED"

