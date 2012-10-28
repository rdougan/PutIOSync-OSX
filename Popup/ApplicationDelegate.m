#import "ApplicationDelegate.h"

#import "MASPreferencesWindowController.h"
#import "GeneralPreferences.h"
#import "AccountPreferences.h"
#import "SyncPreferences.h"

@implementation ApplicationDelegate

#pragma mark -

- (void)dealloc
{
    [_panelController removeObserver:self forKeyPath:@"hasActivePanel"];
}

#pragma mark -

void *kContextActivePanel = &kContextActivePanel;

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == kContextActivePanel) {
        self.menubarController.hasActiveIcon = self.panelController.hasActivePanel;
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Getters/Setters

- (NSWindowController *)preferencesWindowController
{
    if (_preferencesWindowController == nil)
    {
        NSArray *preferencePanes = @[
            [[GeneralPreferences alloc] init],
            [[AccountPreferences alloc] init],
            [[SyncPreferences alloc] init]
        ];
        NSString *title = NSLocalizedString(@"Preferences", @"preferences.title");
        _preferencesWindowController = [[MASPreferencesWindowController alloc] initWithViewControllers:preferencePanes title:title];
    }
    return _preferencesWindowController;
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [ApplicationDelegate setupUserDefaults];
    // Install icon into the menu bar
    self.menubarController = [[MenubarController alloc] init];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Explicitly remove the icon from the menu bar
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.menubarController = nil;
    return NSTerminateNow;
}

#pragma mark - Actions

- (IBAction)togglePanel:(id)sender
{
    self.menubarController.hasActiveIcon = !self.menubarController.hasActiveIcon;
    self.panelController.hasActivePanel = self.menubarController.hasActiveIcon;
}

- (IBAction)showPreferences:(id)sender
{
    [self.preferencesWindowController showWindow:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

#pragma mark - Public accessors

- (PanelController *)panelController
{
    if (_panelController == nil) {
        _panelController = [[TransfersPanel alloc] initWithDelegate:self];
        [_panelController addObserver:self forKeyPath:@"hasActivePanel" options:0 context:kContextActivePanel];
    }
    return _panelController;
}

#pragma mark - PanelControllerDelegate

- (StatusItemView *)statusItemViewForPanelController:(PanelController *)controller
{
    return self.menubarController.statusItemView;
}

+(void)setupUserDefaults
{
    NSString *userDefaultsValuesPath;
    NSDictionary *userDefaultsValuesDict;
    
    // load the default values for the user defaults
    userDefaultsValuesPath = [[NSBundle mainBundle] pathForResource:@"UserDefaults"
                                                           ofType:@"plist"];
    userDefaultsValuesDict = [NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath];
    
    // set them in the standard user defaults
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsValuesDict];
}

@end
