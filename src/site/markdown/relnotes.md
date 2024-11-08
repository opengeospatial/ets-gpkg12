# Release Notes GeoPackage (gpkg) 1.2

## 1.3 (2024-11-07)

Attention: Java 17 and Tomcat 10.1 are required.

* [#134](https://github.com/opengeospatial/ets-gpkg12/pull/134): Migration to Java 17 and Tomcat 10.1
* [#137](https://github.com/opengeospatial/ets-gpkg12/pull/137): Set ets-common version to 13

## 1.2 (2024-10-29)
* [#127](https://github.com/opengeospatial/ets-gpkg12/issues/127): Feature Geometry Encoding Testing returns java.lang.NullPointerException
* [#128](https://github.com/opengeospatial/ets-gpkg12/issues/128): Column Data Types - Invalid data type for TEXT column
* [#129](https://github.com/opengeospatial/ets-gpkg12/issues/129): Data Columns Column Name test has wrong table name in description
* [#135](https://github.com/opengeospatial/ets-gpkg12/pull/135): Set TEAM Engine dependencies to version 5.7 and add exclusions
* [#124](https://github.com/opengeospatial/ets-gpkg12/pull/124): Add credentials to SoapUI project
* [#123](https://github.com/opengeospatial/ets-gpkg12/pull/123): Bump xercesImpl from 2.12.1 to 2.12.2
* [#122](https://github.com/opengeospatial/ets-gpkg12/pull/122): Bump commons-io from 1.3.2 to 2.7

## 1.1 (2021-03-23)
* Fix [#118](https://github.com/opengeospatial/ets-gpkg12/issues/118): Integration tests are failing
* Fix [#79](https://github.com/opengeospatial/ets-gpkg12/pull/79): Requirement 147 test
* Fix [#102](https://github.com/opengeospatial/ets-gpkg12/issues/102): Standalone jar requires net connection even for local GeoPackage
* Fix [#120](https://github.com/opengeospatial/ets-gpkg12/pull/120): Bump xercesImpl from 2.11.0 to 2.12.1
* Fix [#111](https://github.com/opengeospatial/ets-gpkg12/issues/111): Cleanup dependencies
* Fix [#113](https://github.com/opengeospatial/ets-gpkg12/issues/113): Add template to get an XML/JSON response via rest endpoint
* Fix [#117](https://github.com/opengeospatial/ets-gpkg12/pull/117): Set Docker TEAM Engine version to 5.4.1
* Fix [#106](https://github.com/opengeospatial/ets-gpkg12/issues/106): Test method featureGeometryEncodingTesting fail on null geometries
* Fix [#99](https://github.com/opengeospatial/ets-gpkg12/issues/99): Req. 78 is still being enforced
* Fix [#98](https://github.com/opengeospatial/ets-gpkg12/issues/98): Failed tests with disabled conformance classes.
* Fix [#95](https://github.com/opengeospatial/ets-gpkg12/issues/95): Typo in org.opengis.cite.gpkg12.extensions.crswkt.CRSWKT.tableDefinition()
* Fix [#107](https://github.com/opengeospatial/ets-gpkg12/issues/107): Relocate "commons-io" in pom
* Fix [#78](https://github.com/opengeospatial/ets-gpkg12/issues/78): No requirement can be found for test "feature S R Sconsistency"
* Fix [#89](https://github.com/opengeospatial/ets-gpkg12/issues/89): Create SoapUI tests and integrate them into Maven and Jenkinsfile
* Fix [#94](https://github.com/opengeospatial/ets-gpkg12/pull/94): Related Tables Extension test updates
* Fix [#86](https://github.com/opengeospatial/ets-gpkg12/issues/86): NullPointerException on CRSWKT.tableDefinition test

## 1.0 (2018-12-21)
* Fix [#75](https://github.com/opengeospatial/ets-gpkg12/issues/75): Test setupVersion is executed multiple times
* Fix [#81](https://github.com/opengeospatial/ets-gpkg12/issues/81): Introduce Dockerfile and Maven Docker plugin

## 0.7 (2018-07-13)
* Fix [#76](https://github.com/opengeospatial/ets-gpkg12/issues/76): Several tests are executed multiple times
* Fix [#64](https://github.com/opengeospatial/ets-gpkg12/issues/64): Failure due to space in filename
* Merge [#73](https://github.com/opengeospatial/ets-gpkg12/pull/73): R146 147
* Fix [#51](https://github.com/opengeospatial/ets-gpkg12/issues/51): Review test requiredSRSReferences
* Fix [#63](https://github.com/opengeospatial/ets-gpkg12/issues/63): ETS does not permit views
* Fix [#60](https://github.com/opengeospatial/ets-gpkg12/issues/60): The spatial issue revisited
* Merge [#69](https://github.com/opengeospatial/ets-gpkg12/pull/69): Adding two samples
* Merge [#65](https://github.com/opengeospatial/ets-gpkg12/pull/65): Adding a test case with a file with a space in it

## 0.6 (2018-05-16)
* Fix [#52](https://github.com/opengeospatial/ets-gpkg12/issues/52): ETS fails on poorly named contents tables

## 0.5 (2018-04-13)
* Fix [#46](https://github.com/opengeospatial/ets-gpkg12/issues/46): Rename Tiled Gridded Elevation Data conformance class
* Merge[#50](https://github.com/opengeospatial/ets-gpkg12/pull/50): flexible white space in RTree regexes
* Merge[#49](https://github.com/opengeospatial/ets-gpkg12/pull/49): updated gridded coverage gpkg_extensions extension_name and definition values
* Merge[#47](https://github.com/opengeospatial/ets-gpkg12/pull/47): Refining gpkg_spatial_ref_sys tests
* Merge[#45](https://github.com/opengeospatial/ets-gpkg12/pull/45): updating trigger, but leaving older versions grandfathered
* Merge[ #44](https://github.com/opengeospatial/ets-gpkg12/pull/44): being more flexible WRT white space in regexes
* Merge[#43](https://github.com/opengeospatial/ets-gpkg12/pull/43): clarifying tests for NOT NULL on primary keys

## 0.4 (2018-02-28)
* Fix [#37](https://github.com/opengeospatial/ets-gpkg12/issues/37): Review list of implemented conformance classes in test report and documentation
* Merge [#39](https://github.com/opengeospatial/ets-gpkg12/pull/39): 1.2 Test Suite Input Conformance Classes
* Fix [#27](https://github.com/opengeospatial/ets-gpkg12/issues/27): REST API: All tests are skipped

## 0.3 (2017-11-17)
* Fix [#26](https://github.com/opengeospatial/ets-gpkg12/issues/26): Encoding Conformance Classes

## 0.2 (2017-10-30)
* Fix [#25](https://github.com/opengeospatial/ets-gpkg12/pull/25): Attributes
* Fix [#22](https://github.com/opengeospatial/ets-gpkg12/pull/22): Implement attribute tests, and tests for those tests.
* Fix [#21](https://github.com/opengeospatial/ets-gpkg12/pull/21): Add Jacoco coverage test.
* Fix [#20](https://github.com/opengeospatial/ets-gpkg12/pull/20): Remove unused code.
* Fix [#19](https://github.com/opengeospatial/ets-gpkg12/pull/19): Fix cut-n-paste error in feature test docs.
* Fix [#14](https://github.com/opengeospatial/ets-gpkg12/pull/14): Ongoing ETS maintenance
* Fix [#16](https://github.com/opengeospatial/ets-gpkg12/issues/16): All tests are skipped if official test data are used
* Fix [#17](https://github.com/opengeospatial/ets-gpkg12/issues/17): HTML report is not created with TEAM Engine 5.0 when using Web Browser Interface
* Fix [#15](https://github.com/opengeospatial/ets-gpkg12/issues/15): Consistency in documentation and UI about what conformance classes are available

## 0.1 (2017-04-30)
Initial release based on [1.0 test](https://github.com/opengeospatial/ets-gpkg10).
 
