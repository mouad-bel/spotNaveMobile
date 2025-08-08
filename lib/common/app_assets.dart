class AppAssets {
  static const images = (
    // General App Images
    logo: 'assets/images/logo.png',

    // Map Specific Images
    map: (nearby: 'assets/images/nearby-map.png'),
    marker: (
      user: 'assets/images/user-marker.png',
      destination: 'assets/images/destination-marker.png',
    ),

    // Auth
    loginMethods: [
      'assets/images/brands/google.png',
      'assets/images/brands/apple.png',
      'assets/images/brands/facebook.png',
    ],

    // Failures
    failures: (
      cache: 'assets/images/failures/cache-failure.png',
      network: 'assets/images/failures/network-failure.png',
      noConnection: 'assets/images/failures/no-connection-failure.png',
      notFound: 'assets/images/failures/not-found-failure.png',
      server: 'assets/images/failures/server-failure.png',
      serviceUnavailable:
          'assets/images/failures/service-unavailable-failure.png',
      unauthenticated: 'assets/images/failures/unauthenticated-failure.png',
      unexpected: 'assets/images/failures/unexpected-failure.png',
    ),
  );

  static const icons = (
    // Primary Navigation & Feature Icons
    home: (
      outline: 'assets/icons/home-2.png',
      fill: 'assets/icons/home-2-fill.png',
    ),
    discover: (
      outline: 'assets/icons/discover.png',
      fill: 'assets/icons/discover-fill.png',
    ),
    account: (
      outline: 'assets/icons/profile-circle.png',
      fill: 'assets/icons/profile-circle-fill.png',
    ),

    // Map & Location Related Icons
    map: 'assets/icons/map.png',
    coordinate: 'assets/icons/gps.png',
    radar: 'assets/icons/radar-2.png',

    // General UI Actions
    search: 'assets/icons/search-normal.png',
    filter: 'assets/icons/filter.png',
    refresh: 'assets/icons/refresh-2.png',
    edit: 'assets/icons/edit-2.png',
    copy: 'assets/icons/copy.png',
    checked: 'assets/icons/checked.png',
    fit: 'assets/icons/maximize-2.png',
    zoomIn: 'assets/icons/search-zoom-in.png',
    zoomOut: 'assets/icons/search-zoom-out.png',

    // User & Authentication Related
    name: 'assets/icons/user-square.png',
    email: 'assets/icons/sms.png',
    password: 'assets/icons/password-check.png',
    visibility: (
      active: 'assets/icons/eye.png',
      inactive: 'assets/icons/eye-slash.png',
    ),
    user: (
      profile: 'assets/icons/user.png',
      remove: 'assets/icons/user-remove.png',
    ),
    logout: 'assets/icons/logout.png',

    // Content/Feature Specific
    location: 'assets/icons/location.png',
    star: 'assets/icons/star.png',
    calendar: 'assets/icons/calendar.png',
    dollar: 'assets/icons/dollar-square.png',
    journey: 'assets/icons/routing.png',
    weather: (moon: 'assets/icons/moon.png'),

    // Archiving & Saving
    archive: (
      add: 'assets/icons/archive-add.png',
      remove: 'assets/icons/archive-minus.png',
      outline: 'assets/icons/save-2.png',
    ),

    // Information & Support
    notification: 'assets/icons/notification-bing.png',
    info: 'assets/icons/info-circle.png',
    feedback: 'assets/icons/like-dislike.png',
    language: 'assets/icons/language-square.png',
    support: 'assets/icons/message-question.png',
    settings: 'assets/icons/setting-2.png',

    // Arrows & Navigation Controls
    arrow: (
      right: 'assets/icons/arrow-right.png',
      left: 'assets/icons/arrow-left.png',
    ),
    navigation: (
      next: 'assets/icons/navigation-next.png',
      before: 'assets/icons/navigation-before.png',
    ),
  );
}
