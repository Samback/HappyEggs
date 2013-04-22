#import "AppDelegate.h"

#define DELEGATE ((AppDelegate *)([[UIApplication sharedApplication] delegate]))

#define APP_NAME @"Happy Eggs"

#define BASE_URL @"http://ukr.net"
#define BUMP_API_KEY @"de703e6680454adbbf3d1ac99727c9b0"
#define VK_APP_ID @"3592400"

#define SHARING_IMAGE @"sharing_image.png"
#define SHARING_URL_FOR_APP @"http://ukr.net"
#define SHARING_TEXT NSLocalizedString(@"Мне понравилось это приложение, сыграй со мной :)", @"Text for sharing")

#define DELETE_EGG_MESSAGE NSLocalizedString(@"Вы действительно хотите удалить этот скин?", @"Text for egg delete")

#define WIN_MESSAGE  NSLocalizedString(@"Ура, вы победили!", @"Win")
#define LOSE_MESSAGE NSLocalizedString(@"Жаль, вы проиграли, возможно выберите другое яйцо и попробуте еще?", @"Lose")
#define TIE_MESSAGE  NSLocalizedString(@"Вот это да! Оба яйца сварили так круто, что ни одно не разбилось!", @"Tie")

#define YES_MESSAGE NSLocalizedString(@"Да", @"Text Yes")

#define NO_MESSAGE NSLocalizedString(@"Нет", @"Text NO")


#define GA_API_KEY @"UA-38756409-2"
#define TIME_OF_GA_UPDATE 10

#define ATTACK_KEY @"attack"

#define ADD_NEW_EGG_TYPE @"Add new egg"
#define DEFAULT_EGG_TYPE @"Default egg"
#define USER_EGG_TYPE @"Custom egg"
