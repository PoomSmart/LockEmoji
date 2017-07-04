#import "../PS.h"
#import <UIKit/UIKeyboardInputModeController.h>
#import <UIKit/UIKeyboardPreferencesController.h>

%hook UIKeyboardInputModeController

- (UIKeyboardInputMode *)currentPublicInputMode {
    return self.currentInputMode;
}

%end

int notEmoji = 0;

extern "C" NSString *TIInputModeGetNormalizedIdentifier(UIKeyboardInputMode *);
%hookf(NSString *, TIInputModeGetNormalizedIdentifier, UIKeyboardInputMode *inputMode) {
    NSString *normalizedIdentifier = %orig(inputMode);
    if ([normalizedIdentifier isEqualToString:@"emoji"] && notEmoji >= 2) {
        if (notEmoji == 2)
            notEmoji = 0;
        return @"notemoji";
    }
    return normalizedIdentifier;
}

%hook UIKeyboardImpl

- (void)setDelegate: (id)delegate force: (BOOL)force {
    notEmoji = 4;
    %orig;
    notEmoji = 0;
}

%end

%group iOS8

%hook UIKeyboardPreferencesController

- (void)setLanguageAwareInputModeLastUsed: (UIKeyboardInputMode *)inputMode {
    notEmoji = 4;
    %orig;
    notEmoji = 0;
}

%end

%hook UIKeyboardInputModeController

- (void)setCurrentInputModeInPreference: (UIKeyboardInputMode *)inputMode {
    NSString *identifier = inputMode.identifier;
    if (identifier)
        [UIKeyboardPreferencesController.sharedPreferencesController setValue:identifier forKey:12];
}

%end

%end

%group iOS9

%hook UIInputSwitcherView

- (void)setInputMode: (NSString *)inputMode {
    notEmoji = 4;
    %orig;
    notEmoji = 0;
}

%end

%hook UIKeyboardInputModeController

- (void)updateLastUsedInputMode: (UIKeyboardInputMode *)inputMode {
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

- (BOOL)keyplaneContainsEmojiKey {
    return notEmoji >= 2 ? NO : %orig;
}

%end

%hook UIKeyboardImpl

- (void)setInputModeToNextInPreferredListWithExecutionContext: (id)arg1 {
    notEmoji = 4;
    %orig;
    notEmoji = 0;
}

%end

%end

%ctor {
    %init;
    if (isiOS8Up) {
        %init(iOS8);
        if (isiOS9Up) {
            %init(iOS9);
        }
    }
}
