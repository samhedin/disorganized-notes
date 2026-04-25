set export

DISORGANIZED_ENV := "dev"

export-users:
	firebase auth:export users.csv --format=csv

oneplus:
	adb kill-server
	sudo adb start-server
	sudo adb devices

test:
	just phone
	maestro test ui-tests/save-note.yaml

phone:
	adb shell setprop debug.firebase.analytics.app com.disorganized.disorganized
	clj -M:cljd flutter | grep -E "^(I/flutter|Error|E/flutter)"

startup-profile:
	flutter run --trace-startup --profile

profile:
	adb shell setprop debug.firebase.analytics.app com.disorganized.disorganized
	clj -M:cljd flutter --profile

phone2:
	adb shell setprop debug.firebase.analytics.app com.disorganized.disorganized
	clj -M:cljd flutter

fuck-gradle:
	cd android; ./gradlew --stop; rm -rf ~/.gradle/cache

emulator:
	clj -M:cljd flutter -d emulator-5554

appbundle:
	clj -M:cljd compile
	flutter build appbundle

release:
	clj -M:cljd compile
	cd android; bundle exec fastlane release_play_store

web-deploy:
	clj -M:cljd compile
	flutter build web --release
	firebase deploy --only hosting

web:
	clj -M:cljd flutter -d chrome --web-port 7357 --web-hostname localhost

linux:
	clj -M:cljd flutter -d linux

functions-deploy:
	firebase deploy --only functions

ios:
	clj -M:cljd compile
	cd ios; bundle install; bundle exec fastlane release_app_store
	ios/Pods/FirebaseCrashlytics/upload-symbols -gsp ios/Runner/GoogleService-Info.plist -p ios build/ios/archive/Runner.xcarchive/dSYMs

export-emails:
	firebase auth:export save_file.csv --format=csv --project disorganized-537c1

reset-ios:
	flutter clean
	flutter pub get
	cd ios; pod deintegrate; pod cache clean --all; rm -rf Pods; rm -rf Podfile.lock; pod install
	cd ios; rm Podfile
	flutter clean
	flutter pub get
	cd ios; pod install

pem:
	cd ios; fastlane pem -a com.disorganized.cljdDisorganized -u sam.hedin@gmail.com -p "hello"
	cd ios; fastlane pem -a com.disorganized.cljdDisorganized -u sam.hedin@gmail.com -p "hello" --development
