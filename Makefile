all: app

PROJECT=OpenSourceTestiOS.xcodeproj
SIMULATOR='platform=iOS Simulator,name=iPhone 11'
DERIVED_DATA=$(CURDIR)/DerivedData
SONAR_HOME=$(CURDIR)/.sonar
SONAR_URL=https://sonarcloud.io

clean:
	rm -rf $(DERIVED_DATA)
	set -o pipefail && xcodebuild clean -project $(PROJECT) -scheme OpenSourceTestiOS | xcpretty

app: clean
	set -o pipefail && xcodebuild build -project $(PROJECT) -scheme OpenSourceTestiOS -destination generic/platform=iOS | xcpretty

test: clean
	set -o pipefail && xcodebuild test -project $(PROJECT) -scheme OpenSourceTestiOS -destination $(SIMULATOR) | xcpretty

test-sonar: clean
	# Run tests and create Xcode coverage files
	mkdir -p $(DERIVED_DATA)
	$(SONAR_HOME)/build-wrapper-macosx-x86 --out-dir $(DERIVED_DATA)/compilation-database xcodebuild test -project $(PROJECT) -scheme OpenSourceTestiOS -destination $(SIMULATOR) -enableCodeCoverage YES -derivedDataPath $(DERIVED_DATA)

	# Convert xresult into SonarCloud format
	bash $(SONAR_HOME)/xccov-to-sonarqube-generic.sh $(DERIVED_DATA)/Logs/Test/*.xcresult/ > $(DERIVED_DATA)/sonarqube-generic-coverage.xml

	# Upload result to SonarCloud
	java -Djava.awt.headless=true -classpath .sonar/sonar-scanner-cli-4.2.0.1873.jar -Dproject.home=$(CURDIR) -Dsonar.projectBaseDir=$(CURDIR) -Dsonar.host.url=$(SONAR_URL) org.sonarsource.scanner.cli.Main

ci: test-sonar
