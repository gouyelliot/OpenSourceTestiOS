all: app

PROJECT=OpenSourceTestiOS.xcodeproj
SIMULATOR='platform=iOS Simulator,name=iPhone 11'
DERIVED_DATA=$(CURDIR)/DerivedData

clean:
	set -o pipefail && xcodebuild clean -project $(PROJECT) -scheme OpenSourceTestiOS | xcpretty

app: clean
	set -o pipefail && xcodebuild build -project $(PROJECT) -scheme OpenSourceTestiOS -destination generic/platform=iOS | xcpretty

test: clean
	set -o pipefail && xcodebuild test -project $(PROJECT) -scheme OpenSourceTestiOS -destination $(SIMULATOR) | xcpretty

test-coverage: clean
	set -o pipefail && xcodebuild test -project $(PROJECT) -scheme OpenSourceTestiOS -destination $(SIMULATOR) -enableCodeCoverage YES -derivedDataPath $(DERIVED_DATA) | xcpretty

multi_test: clean
	set -o pipefail && \
	xcodebuild test -project $(PROJECT) \
	-scheme Batch \
	-destination $(SIMULATOR) \
	-destination 'platform=iOS Simulator,name=iPhone 6,OS=8.4' \
	-destination 'platform=iOS Simulator,name=iPhone 6s,OS=9.3' \
	-destination 'platform=iOS Simulator,name=iPhone 5,OS=8.4' \
	-destination 'platform=iOS Simulator,name=iPhone 5,OS=9.3' \
	-destination 'platform=iOS Simulator,name=iPhone 5,OS=10.3.1' \
	| xcpretty

ci: test
