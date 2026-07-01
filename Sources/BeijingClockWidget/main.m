#import <Cocoa/Cocoa.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

static NSString * const BJTFloatAboveWindowsKey = @"floatAboveWindows";
static NSString * const BJTWidgetVisibleKey = @"widgetVisible";
static NSString * const BJTSavedFrameKey = @"savedFrame";

@interface BJTFestival : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSDate *date;
+ (instancetype)festivalWithName:(NSString *)name date:(NSDate *)date;
@end

@implementation BJTFestival

+ (instancetype)festivalWithName:(NSString *)name date:(NSDate *)date {
    BJTFestival *festival = [[BJTFestival alloc] init];
    festival.name = name;
    festival.date = date;
    return festival;
}

@end

static NSTimeZone *BJTTimeZone(void) {
    return [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
}

static NSLocale *BJTChineseLocale(void) {
    return [NSLocale localeWithLocaleIdentifier:@"zh_CN"];
}

static NSCalendar *BJTGregorianCalendar(void) {
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    calendar.timeZone = BJTTimeZone();
    return calendar;
}

static NSCalendar *BJTChineseCalendar(void) {
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierChinese];
    calendar.timeZone = BJTTimeZone();
    return calendar;
}

static NSDate *BJTStartOfDay(NSDate *date) {
    return [BJTGregorianCalendar() startOfDayForDate:date];
}

static NSDate *BJTGregorianDate(NSInteger year, NSInteger month, NSInteger day) {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.calendar = BJTGregorianCalendar();
    components.timeZone = BJTTimeZone();
    components.year = year;
    components.month = month;
    components.day = day;
    return [components.calendar dateFromComponents:components];
}

static NSDate *BJTLunarDate(NSInteger era, NSInteger year, NSInteger month, NSInteger day) {
    NSCalendar *calendar = BJTChineseCalendar();
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.calendar = calendar;
    components.timeZone = BJTTimeZone();
    components.era = era;
    components.year = year;
    components.month = month;
    components.day = day;
    components.leapMonth = NO;
    return [calendar dateFromComponents:components];
}

static void BJTNextChineseYear(NSInteger era, NSInteger year, NSInteger *nextEra, NSInteger *nextYear) {
    NSInteger candidateYear = year + 1;
    NSInteger candidateEra = era;
    if (candidateYear > 60) {
        candidateYear = 1;
        candidateEra += 1;
    }

    *nextEra = candidateEra;
    *nextYear = candidateYear;
}

static void BJTAddFestival(NSMutableArray<BJTFestival *> *festivals, NSString *name, NSDate *date) {
    if (date) {
        [festivals addObject:[BJTFestival festivalWithName:name date:BJTStartOfDay(date)]];
    }
}

static void BJTAddGregorianFestivals(NSMutableArray<BJTFestival *> *festivals, NSInteger year) {
    BJTAddFestival(festivals, @"元旦", BJTGregorianDate(year, 1, 1));
    BJTAddFestival(festivals, @"情人节", BJTGregorianDate(year, 2, 14));
    BJTAddFestival(festivals, @"妇女节", BJTGregorianDate(year, 3, 8));
    BJTAddFestival(festivals, @"植树节", BJTGregorianDate(year, 3, 12));
    BJTAddFestival(festivals, @"劳动节", BJTGregorianDate(year, 5, 1));
    BJTAddFestival(festivals, @"儿童节", BJTGregorianDate(year, 6, 1));
    BJTAddFestival(festivals, @"建党节", BJTGregorianDate(year, 7, 1));
    BJTAddFestival(festivals, @"建军节", BJTGregorianDate(year, 8, 1));
    BJTAddFestival(festivals, @"教师节", BJTGregorianDate(year, 9, 10));
    BJTAddFestival(festivals, @"国庆节", BJTGregorianDate(year, 10, 1));
    BJTAddFestival(festivals, @"圣诞节", BJTGregorianDate(year, 12, 25));
}

static void BJTAddLunarFestivals(NSMutableArray<BJTFestival *> *festivals, NSInteger era, NSInteger year) {
    BJTAddFestival(festivals, @"春节", BJTLunarDate(era, year, 1, 1));
    BJTAddFestival(festivals, @"元宵节", BJTLunarDate(era, year, 1, 15));
    BJTAddFestival(festivals, @"龙抬头", BJTLunarDate(era, year, 2, 2));
    BJTAddFestival(festivals, @"端午节", BJTLunarDate(era, year, 5, 5));
    BJTAddFestival(festivals, @"七夕", BJTLunarDate(era, year, 7, 7));
    BJTAddFestival(festivals, @"中秋节", BJTLunarDate(era, year, 8, 15));
    BJTAddFestival(festivals, @"重阳节", BJTLunarDate(era, year, 9, 9));
    BJTAddFestival(festivals, @"腊八节", BJTLunarDate(era, year, 12, 8));

    NSInteger nextEra = 0;
    NSInteger nextYear = 0;
    BJTNextChineseYear(era, year, &nextEra, &nextYear);
    NSDate *nextSpringFestival = BJTLunarDate(nextEra, nextYear, 1, 1);
    NSDate *newYearsEve = [BJTGregorianCalendar() dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:nextSpringFestival options:0];
    BJTAddFestival(festivals, @"除夕", newYearsEve);
}

static NSArray<BJTFestival *> *BJTFestivalCandidates(NSDate *now) {
    NSMutableArray<BJTFestival *> *festivals = [[NSMutableArray alloc] init];
    NSCalendar *gregorianCalendar = BJTGregorianCalendar();
    NSDateComponents *gregorianComponents = [gregorianCalendar components:NSCalendarUnitYear fromDate:now];
    BJTAddGregorianFestivals(festivals, gregorianComponents.year);
    BJTAddGregorianFestivals(festivals, gregorianComponents.year + 1);

    NSCalendar *chineseCalendar = BJTChineseCalendar();
    NSDateComponents *chineseComponents = [chineseCalendar components:NSCalendarUnitEra | NSCalendarUnitYear fromDate:now];
    BJTAddLunarFestivals(festivals, chineseComponents.era, chineseComponents.year);

    NSInteger nextEra = 0;
    NSInteger nextYear = 0;
    BJTNextChineseYear(chineseComponents.era, chineseComponents.year, &nextEra, &nextYear);
    BJTAddLunarFestivals(festivals, nextEra, nextYear);

    [festivals sortUsingComparator:^NSComparisonResult(BJTFestival *left, BJTFestival *right) {
        NSComparisonResult result = [left.date compare:right.date];
        if (result != NSOrderedSame) {
            return result;
        }
        return [left.name compare:right.name];
    }];

    return festivals;
}

static NSInteger BJTDaysBetween(NSDate *startDate, NSDate *endDate) {
    NSDateComponents *components = [BJTGregorianCalendar() components:NSCalendarUnitDay fromDate:startDate toDate:endDate options:0];
    return components.day;
}

static NSArray<NSString *> *BJTFestivalNamesToday(NSDate *now) {
    NSDate *today = BJTStartOfDay(now);
    NSMutableOrderedSet<NSString *> *names = [[NSMutableOrderedSet alloc] init];

    for (BJTFestival *festival in BJTFestivalCandidates(now)) {
        if (BJTDaysBetween(today, festival.date) == 0) {
            [names addObject:festival.name];
        }
    }

    return names.array;
}

static BJTFestival *BJTNextFestivalAfterToday(NSDate *now) {
    NSDate *today = BJTStartOfDay(now);
    for (BJTFestival *festival in BJTFestivalCandidates(now)) {
        if (BJTDaysBetween(today, festival.date) > 0) {
            return festival;
        }
    }

    return nil;
}

static BJTFestival *BJTNearestFestivalOnOrAfterToday(NSDate *now) {
    NSDate *today = BJTStartOfDay(now);
    for (BJTFestival *festival in BJTFestivalCandidates(now)) {
        if (BJTDaysBetween(today, festival.date) >= 0) {
            return festival;
        }
    }

    return nil;
}

@interface BJTClockPanel : NSPanel
@end

@implementation BJTClockPanel

- (BOOL)canBecomeKeyWindow {
    return NO;
}

- (BOOL)canBecomeMainWindow {
    return NO;
}

@end

@interface BJTClockView : NSVisualEffectView
@property (nonatomic, strong) NSTextField *titleLabel;
@property (nonatomic, strong) NSTextField *timeLabel;
@property (nonatomic, strong) NSTextField *dateLabel;
@property (nonatomic, strong) NSTextField *festivalLabel;
@property (nonatomic, strong) NSTextField *countdownLabel;
@property (nonatomic, strong) NSStackView *stackView;
@property (nonatomic, strong) NSDateFormatter *timeFormatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation BJTClockView

- (BOOL)mouseDownCanMoveWindow {
    return YES;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (!self) {
        return nil;
    }

    [self configureAppearance];
    [self configureFormatters];
    [self configureLabels];
    [self updateTime];

    self.timer = [NSTimer timerWithTimeInterval:1.0
                                         target:self
                                       selector:@selector(updateTime)
                                       userInfo:nil
                                        repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];

    return self;
}

- (void)dealloc {
    [self.timer invalidate];
}

- (void)configureAppearance {
    self.material = NSVisualEffectMaterialHUDWindow;
    self.blendingMode = NSVisualEffectBlendingModeBehindWindow;
    self.state = NSVisualEffectStateActive;
    self.wantsLayer = YES;
    self.layer.cornerRadius = 26.0;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 0.0;
    self.layer.borderColor = [NSColor clearColor].CGColor;
}

- (void)configureFormatters {
    NSTimeZone *beijingTimeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"zh_CN"];

    self.timeFormatter = [[NSDateFormatter alloc] init];
    self.timeFormatter.locale = locale;
    self.timeFormatter.timeZone = beijingTimeZone;
    self.timeFormatter.dateFormat = @"HH:mm:ss";

    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.locale = locale;
    self.dateFormatter.timeZone = beijingTimeZone;
    self.dateFormatter.dateFormat = @"yyyy年M月d日 EEEE";
}

- (void)configureLabels {
    self.titleLabel = [NSTextField labelWithString:@"北京时间"];
    self.timeLabel = [NSTextField labelWithString:@"--:--:--"];
    self.dateLabel = [NSTextField labelWithString:@""];
    self.festivalLabel = [NSTextField labelWithString:@""];
    self.countdownLabel = [NSTextField labelWithString:@""];

    NSArray<NSTextField *> *labels = @[self.titleLabel, self.timeLabel, self.dateLabel, self.festivalLabel, self.countdownLabel];
    for (NSTextField *label in labels) {
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.alignment = NSTextAlignmentCenter;
        label.lineBreakMode = NSLineBreakByClipping;
    }

    self.titleLabel.font = [NSFont systemFontOfSize:13.0 weight:NSFontWeightSemibold];
    self.titleLabel.textColor = [NSColor secondaryLabelColor];

    self.timeLabel.font = [NSFont monospacedDigitSystemFontOfSize:31.0 weight:NSFontWeightSemibold];
    self.timeLabel.textColor = [NSColor labelColor];

    self.dateLabel.font = [NSFont systemFontOfSize:12.0 weight:NSFontWeightRegular];
    self.dateLabel.textColor = [NSColor secondaryLabelColor];

    self.festivalLabel.font = [NSFont systemFontOfSize:12.0 weight:NSFontWeightSemibold];
    self.festivalLabel.textColor = [NSColor labelColor];

    self.countdownLabel.font = [NSFont systemFontOfSize:13.0 weight:NSFontWeightSemibold];
    self.countdownLabel.textColor = [NSColor labelColor];

    self.stackView = [[NSStackView alloc] initWithFrame:NSZeroRect];
    self.stackView.translatesAutoresizingMaskIntoConstraints = NO;
    self.stackView.orientation = NSUserInterfaceLayoutOrientationVertical;
    self.stackView.alignment = NSLayoutAttributeWidth;
    self.stackView.distribution = NSStackViewDistributionGravityAreas;
    self.stackView.spacing = 3.0;
    [self addSubview:self.stackView];

    for (NSTextField *label in labels) {
        [self.stackView addArrangedSubview:label];
    }
    [self.stackView setCustomSpacing:9.0 afterView:self.dateLabel];

    [NSLayoutConstraint activateConstraints:@[
        [self.stackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:13.0],
        [self.stackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-13.0],
        [self.stackView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor constant:1.0],
        [self.stackView.topAnchor constraintGreaterThanOrEqualToAnchor:self.topAnchor constant:14.0],
        [self.stackView.bottomAnchor constraintLessThanOrEqualToAnchor:self.bottomAnchor constant:-14.0]
    ]];
}

- (void)updateTime {
    NSDate *now = [NSDate date];
    self.timeLabel.stringValue = [self.timeFormatter stringFromDate:now];
    self.dateLabel.stringValue = [self.dateFormatter stringFromDate:now];

    NSArray<NSString *> *todaysFestivals = BJTFestivalNamesToday(now);
    NSDate *today = BJTStartOfDay(now);

    if (todaysFestivals.count > 0) {
        self.festivalLabel.stringValue = [NSString stringWithFormat:@"今日：%@", [todaysFestivals componentsJoinedByString:@"、"]];

        BJTFestival *nextFestival = BJTNextFestivalAfterToday(now);
        if (nextFestival) {
            NSInteger days = BJTDaysBetween(today, nextFestival.date);
            self.countdownLabel.stringValue = [NSString stringWithFormat:@"下个：%@ · %ld天后", nextFestival.name, (long)days];
        } else {
            self.countdownLabel.stringValue = @"今天就是最近的节日";
        }
    } else {
        BJTFestival *nearestFestival = BJTNearestFestivalOnOrAfterToday(now);
        if (nearestFestival) {
            NSInteger days = BJTDaysBetween(today, nearestFestival.date);
            self.festivalLabel.stringValue = @"最近节日";
            self.countdownLabel.stringValue = [NSString stringWithFormat:@"%@ · %ld天后", nearestFestival.name, (long)days];
        } else {
            self.festivalLabel.stringValue = @"最近节日";
            self.countdownLabel.stringValue = @"暂无节日数据";
        }
    }
}

@end

@interface BJTAppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate, NSWindowDelegate>
@property (nonatomic, assign) NSSize widgetSize;
@property (nonatomic, strong) BJTClockPanel *panel;
@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, strong) NSDateFormatter *statusTimeFormatter;
@property (nonatomic, strong) NSDateFormatter *statusTooltipFormatter;
@property (nonatomic, strong) NSTimer *statusTimer;
@end

@implementation BJTAppDelegate

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    self.widgetSize = NSMakeSize(164.0, 164.0);
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    (void)notification;
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
    [self configureFormatters];
    [self configureStatusItem];
    [self configurePanel];
    if ([self widgetVisible]) {
        [self showWidget];
    }
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    (void)notification;
    [self saveFrame];
    [self.statusTimer invalidate];
}

- (void)windowDidMove:(NSNotification *)notification {
    (void)notification;
    [self saveFrame];
}

- (void)menuNeedsUpdate:(NSMenu *)menu {
    for (NSMenuItem *item in menu.itemArray) {
        if (item.action == @selector(toggleVisibility:)) {
            item.title = self.panel.isVisible ? @"隐藏小组件" : @"显示小组件";
            item.state = [self widgetVisible] ? NSControlStateValueOn : NSControlStateValueOff;
        } else if (item.action == @selector(toggleFloatAboveWindows:)) {
            item.state = [self floatAboveWindows] ? NSControlStateValueOn : NSControlStateValueOff;
        }
    }
}

- (void)configureFormatters {
    self.statusTimeFormatter = [[NSDateFormatter alloc] init];
    self.statusTimeFormatter.locale = BJTChineseLocale();
    self.statusTimeFormatter.timeZone = BJTTimeZone();
    self.statusTimeFormatter.dateFormat = @"HH:mm";

    self.statusTooltipFormatter = [[NSDateFormatter alloc] init];
    self.statusTooltipFormatter.locale = BJTChineseLocale();
    self.statusTooltipFormatter.timeZone = BJTTimeZone();
    self.statusTooltipFormatter.dateFormat = @"yyyy年M月d日 EEEE HH:mm:ss";
}

- (void)configureStatusItem {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];

    NSStatusBarButton *button = self.statusItem.button;
    button.image = nil;
    button.title = @"CN--:--";
    button.toolTip = @"北京时间小组件";

    self.statusItem.menu = [self makeMenu];
    [self updateStatusItem];

    self.statusTimer = [NSTimer timerWithTimeInterval:1.0
                                               target:self
                                             selector:@selector(updateStatusItem)
                                             userInfo:nil
                                              repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.statusTimer forMode:NSRunLoopCommonModes];
}

- (void)configurePanel {
    self.panel = [[BJTClockPanel alloc] initWithContentRect:[self defaultFrame]
                                                  styleMask:NSWindowStyleMaskBorderless | NSWindowStyleMaskNonactivatingPanel
                                                    backing:NSBackingStoreBuffered
                                                      defer:NO];
    self.panel.delegate = self;
    self.panel.releasedWhenClosed = NO;
    self.panel.opaque = NO;
    self.panel.backgroundColor = [NSColor clearColor];
    self.panel.hasShadow = NO;
    self.panel.hidesOnDeactivate = NO;
    self.panel.movableByWindowBackground = YES;
    self.panel.collectionBehavior = NSWindowCollectionBehaviorCanJoinAllSpaces |
        NSWindowCollectionBehaviorStationary |
        NSWindowCollectionBehaviorIgnoresCycle;

    BJTClockView *view = [[BJTClockView alloc] initWithFrame:NSMakeRect(0.0, 0.0, self.widgetSize.width, self.widgetSize.height)];
    view.menu = [self makeMenu];
    self.panel.contentView = view;

    [self restoreFrameIfPossible];
    [self applyWindowLevel];
}

- (NSMenu *)makeMenu {
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
    menu.delegate = self;

    NSMenuItem *showHideItem = [[NSMenuItem alloc] initWithTitle:@"隐藏小组件"
                                                          action:@selector(toggleVisibility:)
                                                   keyEquivalent:@""];
    showHideItem.target = self;
    [menu addItem:showHideItem];

    NSMenuItem *floatItem = [[NSMenuItem alloc] initWithTitle:@"临时置顶"
                                                       action:@selector(toggleFloatAboveWindows:)
                                                keyEquivalent:@""];
    floatItem.target = self;
    [menu addItem:floatItem];

    NSMenuItem *resetItem = [[NSMenuItem alloc] initWithTitle:@"重置位置"
                                                       action:@selector(resetPosition:)
                                                keyEquivalent:@""];
    resetItem.target = self;
    [menu addItem:resetItem];

    [menu addItem:[NSMenuItem separatorItem]];

    NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:@"退出"
                                                      action:@selector(quit:)
                                               keyEquivalent:@"q"];
    quitItem.target = self;
    [menu addItem:quitItem];

    return menu;
}

- (BOOL)widgetVisible {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:BJTWidgetVisibleKey] == nil) {
        return YES;
    }
    return [defaults boolForKey:BJTWidgetVisibleKey];
}

- (void)setWidgetVisible:(BOOL)visible {
    [[NSUserDefaults standardUserDefaults] setBool:visible forKey:BJTWidgetVisibleKey];
}

- (BOOL)floatAboveWindows {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:BJTFloatAboveWindowsKey] == nil) {
        return NO;
    }
    return [defaults boolForKey:BJTFloatAboveWindowsKey];
}

- (void)setFloatAboveWindows:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:BJTFloatAboveWindowsKey];
    [self applyWindowLevel];
}

- (void)applyWindowLevel {
    if ([self floatAboveWindows]) {
        self.panel.level = NSFloatingWindowLevel;
    } else {
        self.panel.level = (NSWindowLevel)CGWindowLevelForKey(kCGDesktopIconWindowLevelKey) + 1;
    }
}

- (void)showWidget {
    [self setWidgetVisible:YES];
    [self.panel orderFrontRegardless];
}

- (void)updateStatusItem {
    NSDate *now = [NSDate date];
    NSStatusBarButton *button = self.statusItem.button;
    button.title = [NSString stringWithFormat:@"CN%@", [self.statusTimeFormatter stringFromDate:now]];
    button.toolTip = [NSString stringWithFormat:@"北京时间 %@", [self.statusTooltipFormatter stringFromDate:now]];
}

- (void)saveFrame {
    if (!self.panel) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:NSStringFromRect(self.panel.frame) forKey:BJTSavedFrameKey];
}

- (void)restoreFrameIfPossible {
    NSString *saved = [[NSUserDefaults standardUserDefaults] stringForKey:BJTSavedFrameKey];
    if (!saved) {
        return;
    }

    NSRect frame = NSRectFromString(saved);
    frame.size = self.widgetSize;
    if (frame.size.width > 80.0 && frame.size.height > 40.0 && [self isVisibleOnAnyScreen:frame]) {
        [self.panel setFrame:frame display:NO];
    }
}

- (NSRect)defaultFrame {
    NSScreen *screen = [NSScreen mainScreen];
    NSRect visibleFrame = screen ? screen.visibleFrame : NSMakeRect(0.0, 0.0, 1440.0, 900.0);
    return NSMakeRect(
        NSMaxX(visibleFrame) - self.widgetSize.width - 28.0,
        NSMaxY(visibleFrame) - self.widgetSize.height - 44.0,
        self.widgetSize.width,
        self.widgetSize.height
    );
}

- (BOOL)isVisibleOnAnyScreen:(NSRect)frame {
    for (NSScreen *screen in [NSScreen screens]) {
        NSRect intersection = NSIntersectionRect(screen.visibleFrame, frame);
        if (intersection.size.width > 40.0 && intersection.size.height > 30.0) {
            return YES;
        }
    }
    return NO;
}

- (void)toggleVisibility:(id)sender {
    (void)sender;
    if (self.panel.isVisible) {
        [self.panel orderOut:nil];
        [self setWidgetVisible:NO];
    } else {
        [self showWidget];
    }
}

- (void)toggleFloatAboveWindows:(id)sender {
    (void)sender;
    [self setFloatAboveWindows:![self floatAboveWindows]];
    [self showWidget];
}

- (void)resetPosition:(id)sender {
    (void)sender;
    [self.panel setFrame:[self defaultFrame] display:YES animate:YES];
    [self saveFrame];
    [self showWidget];
}

- (void)quit:(id)sender {
    (void)sender;
    [NSApp terminate:nil];
}

@end

int main(int argc, const char * argv[]) {
    (void)argc;
    (void)argv;

    @autoreleasepool {
        NSApplication *application = [NSApplication sharedApplication];
        BJTAppDelegate *delegate = [[BJTAppDelegate alloc] init];
        application.delegate = delegate;
        [application run];
    }

    return 0;
}
