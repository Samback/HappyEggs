#import "HEAppDelegate.h"

//#define NSLog(...)
#define DELEGATE ((HEAppDelegate *)([[UIApplication sharedApplication] delegate]))

#define HEIGHT_IPHONE_5 568
#define IS_IPHONE_5 ([[UIScreen mainScreen] bounds ].size.height == HEIGHT_IPHONE_5 )

#define TOP_GROUND_IMAGE_NAME (IS_IPHONE_5 ? @"egg_iphone_5" : @"egg_iphone")

#define APP_NAME @"Happy Eggs"

#define BASE_URL @"http://egg.localhome.in.ua"
#define POST_TAIL_URL @"/app/chart/add/"
#define CHART_TAIL_URL @"/app/chart/list/"

#define BUMP_API_KEY @"de703e6680454adbbf3d1ac99727c9b0"
#define VK_APP_ID @"3592400"

#define SHARING_IMAGE @"sharing_image.png"
#define SHARING_URL_FOR_APP BASE_URL
#define SHARING_TEXT NSLocalizedString(@"Мне понравилось это приложение, сыграй со мной :)", @"Text for sharing")

#define DELETE_EGG_MESSAGE NSLocalizedString(@"Вы действительно хотите удалить этот скин?", @"Text for egg delete")

#define WIN_MESSAGE  NSLocalizedString(@"Ура, вы победили!", @"Win")
#define LOSE_MESSAGE NSLocalizedString(@"Вы проиграли. Выберите новое яйцо.", @"Lose")
#define TIE_MESSAGE  NSLocalizedString(@"Вот это да! Оба яйца сварили так круто, что ни одно не разбилось!", @"Tie")
#define UPDATE_YOUR_EGG NSLocalizedString(@"Ваше яйцо разбито. Выберите новое яйцо.", @"Lose")

#define UNSUPORTED_SCHEME_ERROR @"Sorry, this device doesn't support this feature"
#define WEBVIEW_LOADING_ERROR @"Sorry, some problems with the server occured. Please try again later."

#define YES_MESSAGE NSLocalizedString(@"Да", @"Text Yes")

#define NO_MESSAGE NSLocalizedString(@"Нет", @"Text NO")

#define USERNAME_KEY @"username"
#define UUID @"uuid"


#define GA_API_KEY @"UA-38756409-2"
#define MY_BANNER_UNIT_ID @""
#define TIME_OF_GA_UPDATE 10
#define CHILD_BROWSER @"Open statistic"

#define ATTACK_KEY @"attack"

#define ADD_NEW_EGG_TYPE @"Add new egg"
#define DEFAULT_EGG_TYPE @"Default egg"
#define USER_EGG_TYPE @"Custom egg"
