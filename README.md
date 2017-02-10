## GeoPackage 1.0 Conformance Test Suite

### Scope

This test suite verifies the structure and content of a GeoPackage 1.0 data container.
The [GeoPackage specification](http://www.opengis.net/doc/IS/geopackage/1.0) describes how a
platform-independent [SQLite database file](https://www.sqlite.org/fileformat2.html)
may contain various types of content, including:

* vector geospatial features
* tile matrix sets of imagery and raster maps at various scales
* metadata

Visit the [project documentation website](http://opengeospatial.github.io/ets-gpkg10/)
for more information, including the API documentation.

### How to run the tests
The test suite is built using [Apache Maven v3](https://maven.apache.org/). The options
for running the suite are summarized below.

#### 1. Integrated development environment (IDE)

Use a Java IDE such as Eclipse, NetBeans, or IntelliJ. Clone the repository and build the project.

Set the main class to run: `org.opengis.cite.gpkg10.TestNGController`

Arguments: The first argument must refer to an XML properties file containing the
required test run arguments. If not specified, the default location at `$
{user.home}/test-run-props.xml` will be used.

You can modify the sample file in `src/main/config/test-run-props.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties version="1.0">
  <comment>Test run arguments</comment>
  <entry key="iut">http://www.geopackage.org/data/simple_sewer_features.gpkg</entry>
</properties>
```

The TestNG results file (`testng-results.xml`) will be written to a subdirectory
in `${user.home}/testng/` having a UUID value as its name.

#### 2. Command shell (console)

One of the build artifacts is an "all-in-one" JAR file that includes the test
suite and all of its dependencies; this makes it very easy to execute the test
suite in a command shell:

`java -jar ets-gpkg10-0.3-SNAPSHOT-aio.jar [-o|--outputDir $TMPDIR] [test-run-props.xml]`

#### 3. OGC test harness

Use [TEAM Engine](https://github.com/opengeospatial/teamengine), the official OGC test harness.
The latest test suite release are usually available at the [beta testing facility](http://cite.opengeospatial.org/te2/).
You can also [build and deploy](https://github.com/opengeospatial/teamengine) the test
harness yourself and use a local installation.


### How to contribute

If you would like to get involved, you can:

* [Report an issue](https://github.com/opengeospatial/ets-gpkg10/issues) such as a defect or
an enhancement request
* Help to resolve an [open issue](https://github.com/opengeospatial/ets-gpkg10/issues?q=is%3Aopen)
* Fix a bug: Fork the repository, apply the fix, and create a pull request
* Add new tests: Fork the repository, implement and verify the tests on a new topic branch,
and create a pull request (don't forget to periodically rebase long-lived branches so
there are no extraneous conflicts)
