#import "../PS.h"

//#include "InspCWrapper.m"

@interface UIKeyboardInputMode : NSObject
@property(retain, nonatomic) NSString *primaryLanguage;
@property(retain, nonatomic) NSString *identifier;
@property(retain, nonatomic) NSString *normalizedIdentifier;
@end

@interface UIKeyboardInputModeController : NSObject
@property(retain, nonatomic) UIKeyboardInputMode *currentInputMode;
@end

@interface UIKeyboardPreferencesController : NSObject
+ (UIKeyboardPreferencesController *)sharedPreferencesController;
- (void)setValue:(id)value forKey:(NSInteger)key;
@end

extern NSString *UIKeyboardInputMode_emoji;

%hook UIKeyboardInputModeController

- (UIKeyboardInputMode *)currentPublicInputMode
{
	return self.currentInputMode;
}

%end

int notEmoji = 0;

extern "C" NSString *TIInputModeGetNormalizedIdentifier(UIKeyboardInputMode *);
MSHook(NSString *, TIInputModeGetNormalizedIdentifier, UIKeyboardInputMode *inputMode)
{
	NSString *normalizedIdentifier = _TIInputModeGetNormalizedIdentifier(inputMode);
	if ([normalizedIdentifier isEqualToString:@"emoji"] && notEmoji == 2) {
		notEmoji = 0;
		return @"notemoji";
	}
	return normalizedIdentifier;
}

%hook UIKeyboardImpl

- (void)setDelegate:(id)delegate force:(BOOL)force
{
	notEmoji = 2;
	%orig;
}

%end

%group iOS8

%hook UIKeyboardPreferencesController

- (void)setLanguageAwareInputModeLastUsed:(UIKeyboardInputMode *)inputMode
{
	notEmoji = 2;
	%orig;
}

%end

%hook UIKeyboardInputModeController

- (void)setCurrentInputModeInPreference:(UIKeyboardInputMode *)inputMode
{
	NSString *identifier = inputMode.identifier;
	if (identifier)
		[[%c(UIKeyboardPreferencesController) sharedPreferencesController] setValue:identifier forKey:12];
}

%end

%end

%ctor
{
	MSHookFunction(TIInputModeGetNormalizedIdentifier, MSHake(TIInputModeGetNormalizedIdentifier));
	%init;
	if (isiOS8Up) {
		%init(iOS8);
	}
}
