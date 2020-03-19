all: app

PROJECT=OpenSourceTestiOS.xcodeproj
SIMULATOR='platform=iOS Simulator,name=iPhone 11'
DERIVED_DATA=$(CURDIR)/DerivedData
SONAR_HOME=$(CURDIR)/.sonar

clean:
	rm -rf $(DERIVED_DATA)
	set -o pipefail && xcodebuild clean -project $(PROJECT) -scheme OpenSourceTestiOS | xcpretty

app: clean
	set -o pipefail && xcodebuild build -project $(PROJECT) -scheme OpenSourceTestiOS -destination generic/platform=iOS | xcpretty

test: clean
	set -o pipefail && xcodebuild test -project $(PROJECT) -scheme OpenSourceTestiOS -destination $(SIMULATOR) | xcpretty

test-sonar: clean
	mkdir -p $(DERIVED_DATA)
	$(SONAR_HOME)/build-wrapper-macosx-x86 --out-dir $(DERIVED_DATA)/compilation-database xcodebuild test -project $(PROJECT) -scheme OpenSourceTestiOS -destination $(SIMULATOR) -enableCodeCoverage YES -derivedDataPath $(DERIVED_DATA)
	bash $(SONAR_HOME)/xccov-to-sonarqube-generic.sh $(DERIVED_DATA)/Logs/Test/*.xcresult/ > $(DERIVED_DATA)/sonarqube-generic-coverage.xml

ci: test-sonar
