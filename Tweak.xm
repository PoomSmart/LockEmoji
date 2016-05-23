#import "../PS.h"

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
	if ([normalizedIdentifier isEqualToString:@"emoji"] && notEmoji >= 2) {
		NSLog(@"get Called %d", notEmoji);
		if (notEmoji == 2)
			notEmoji = 0;
		return @"notemoji";
	}
	return normalizedIdentifier;
}

%hook UIKeyboardImpl

- (void)setDelegate:(id)delegate force:(BOOL)force
{
	%log;
	notEmoji = 4;
	%orig;
	notEmoji = 0;
}

%end

%group iOS8

%hook UIKeyboardPreferencesController

- (void)setLanguageAwareInputModeLastUsed:(UIKeyboardInputMode *)inputMode
{
	%log;
	notEmoji = 4;
	%orig;
	notEmoji = 0;
}

%end

%hook UIKeyboardInputModeController

- (void)setCurrentInputModeInPreference:(UIKeyboardInputMode *)inputMode
{
	%log;
	NSString *identifier = inputMode.identifier;
	if (identifier)
		[UIKeyboardPreferencesController.sharedPreferencesController setValue:identifier forKey:12];
}

%end

%end

%group iOS9

%hook UIInputSwitcherView

- (void)setInputMode:(NSString *)inputMode
{
	%log;
	notEmoji = 4;
	%orig;
	notEmoji = 0;
}

%end

%hook UIKeyboardInputModeController

- (void)updateLastUsedInputMode:(UIKeyboardInputMode *)inputMode
{
	%log;
	if ([inputMode.normalizedIdentifier isEqualToString:@"emoji"]) {
		inputMode.normalizedIdentifier = @"notemoji";
		%orig(inputMode);
		inputMode.normalizedIdentifier = @"emoji";
		return;
	}
	%orig;
}

%end

%hook UIKeyboardLayoutStar

- (BOOL)keyplaneContainsEmojiKey
{
	return notEmoji >= 2 ? NO : %orig;
}

%end

%hook UIKeyboardImpl

- (void)setInputModeToNextInPreferredListWithExecutionContext:(id)arg1
{
	%log;
	notEmoji = 4;
	%orig;
	notEmoji = 0;
}

%end

%end

%ctor
{
	MSHookFunction(TIInputModeGetNormalizedIdentifier, MSHake(TIInputModeGetNormalizedIdentifier));
	%init;
	if (isiOS8Up) {
		%init(iOS8);
		if (isiOS9Up) {
			%init(iOS9);
		}
	}
}