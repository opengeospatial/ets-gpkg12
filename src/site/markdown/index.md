
# GeoPackage 1.0 Conformance Test Suite

## Scope

This conformance test suite verifies the structure and content of a GeoPackage 1.0 
data container. The [GeoPackage 1.0 specification](http://www.opengis.net/doc/IS/geopackage/1.0) describes 
how a platform-independent [SQLite database file](https://www.sqlite.org/fileformat2.html) 
may contain various types of content, including:

* vector geospatial features
* tile matrix sets of imagery and raster maps at various scales
* metadata

The basic structure of a GeoPackage database is shown in Figure 1.

**Figure 1: GeoPackage tables**

![GeoPackage tables](img/geopackage-tables.png)

The following conformance classes have being defined (In bold the classes that have been implemented):

* **Core (Required)**
    - **SQLite Container**
    - **Spatial Reference Systems**
    - **Contents**
* Features
* **Tiles**
* Schema
* **Metadata**
* Registered Extensions
    - Features
    - Tiles
    
Note: This test doesn’t support GeoPackage 1.1. To follow the issue or support the development of a 1.1 test, please  provide a comment in the [GitHub issue tracker](https://github.com/opengeospatial/ets-gpkg10/issues/4).   

## Test requirements

The documents listed below stipulate requirements that must be satisfied by a 
conforming implementation.

1. [OGC GeoPackage Encoding Standard 1.0.2](http://www.geopackage.org/spec/)
2. [SQLite Database File Format](http://sqlite.org/fileformat2.html)

If any of the following preconditions are not satisfied then all tests in the 
suite will be marked as skipped.

1. The major version number in the SQLITE_VERSION_NUMBER header field is 3.

## Test suite structure

The test suite definition file (testng.xml) is located in the root package, 
`org.opengis.cite.gpkg10`. A conformance class corresponds to a &lt;test&gt; element, each 
of which includes a set of test classes that contain the actual test methods. 
The general structure of the test suite is shown in Table 1.

<table>
  <caption>Table 1 - Test suite structure</caption>
  <thead>
    <tr style="text-align: left; background-color: LightCyan">
      <th>Conformance class</th>
      <th>Test classes</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Core</td>
      <td>org.opengis.cite.gpkg10.core.*</td>
    </tr>
    <tr>
      <td>Tiles</td>
      <td>org.opengis.cite.gpkg10.tiles.*</td>
    </tr>
  </tbody>
</table>

The Javadoc documentation provides more detailed information about the test 
methods that constitute the suite.


## Test run arguments

The test run arguments are summarized in Table 2. The _Obligation_ descriptor can 
have the following values: M (mandatory), O (optional), or C (conditional).

<table>
	<caption>Table 2 - Test run arguments</caption>
	<thead>
    <tr>
      <th>Name</th>
      <th>Value domain</th>
	    <th>Obligation</th>
	    <th>Description</th>
    </tr>
  </thead>
	<tbody>
    <tr>
      <td>iut</td>
      <td>URI</td>
      <td>M</td>
      <td>A URI that refers to a GeoPackage file. Ampersand ('&amp;') characters 
      must be percent-encoded as '%26'.</td>
    </tr>
	  <tr>
      <td>ics</td>
      <td>A comma-separated list of string values.</td>
      <td>O</td>
      <td>An implementation conformance statement that indicates which conformance 
      classes or options are supported.</td>
    </tr>
	</tbody>
</table>
