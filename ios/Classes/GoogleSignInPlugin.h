#import <Flutter/Flutter.h>
#import <Google/SignIn.h>

@interface GoogleSignInPlugin : NSObject<GIDSignInDelegate, GIDSignInUIDelegate>
- initWithFlutterView: (FlutterViewController*)flutterView;
- (BOOL)  handleURL:(NSURL*)url
  sourceApplication:(NSString*)sourceApplication
         annotation:(id)annotation;
@end
