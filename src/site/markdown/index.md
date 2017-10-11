
# GeoPackage 1.2 Conformance Test Suite

## Scope

This conformance test suite verifies the structure and content of a GeoPackage 1.2 
data container. The [GeoPackage 1.2 encoding standard](http://www.geopackage.org/spec/) describes 
how a platform-independent [SQLite database file](https://www.sqlite.org/fileformat2.html) 
may contain various types of content, including:

* vector features
* tile matrix sets of imagery and raster maps at various scales
* attributes
* extensions

The basic structure of a GeoPackage database is shown in Figure 1.

**Figure 1: GeoPackage tables**

![GeoPackage tables](./img/geopackage-tables.png)

The following conformance classes have being defined (In bold the classes that have been implemented):

* **Core (Required)**
    - **SQLite Container**
    - **Spatial Reference Systems**
    - **Contents**
* **Features**
* **Tiles**
* Attributes
* **Registered Extensions**
    - **Non-Linear Geometry Types**
    - **RTree Spatial Indexes**
    - Zoom Other Intervals
    - **Tiles Encoding WebP**
    - **Metadata**
    - **Schema**
    - **WKT for Coordinate Reference Systems**
    - **Tiled Gridded Elevation Data**
    
Note: This test also supports GeoPackage 1.1 and 1.0. 

## Test requirements

The documents listed below stipulate requirements that must be satisfied by a 
conforming implementation.

1. [OGC GeoPackage Encoding Standard 1.2.0](http://www.geopackage.org/spec/)
2. [OGC GeoPackage Encoding Standard 1.1.0](https://portal.opengeospatial.org/files/?artifact_id=64506)
3. [OGC GeoPackage Encoding Standard 1.0.1](https://portal.opengeospatial.org/files/?artifact_id=63378)
4. [OGC GeoPackage Encoding Standard 1.0.0](https://portal.opengeospatial.org/files/?artifact_id=56357)
5. [SQLite Database File Format](http://sqlite.org/fileformat2.html)

If any of the following preconditions are not satisfied then all tests in the 
suite will be marked as skipped.

1. The major version number in the SQLITE_VERSION_NUMBER header field is 3.

## Test suite structure

The test suite definition file (testng.xml) is located in the root package, 
`org.opengis.cite.gpkg12`. A conformance class corresponds to a &lt;test&gt; element, each 
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
      <td>org.opengis.cite.gpkg12.core.*</td>
    </tr>
    <tr>
      <td>Features</td>
      <td>org.opengis.cite.gpkg12.features.*</td>
    </tr>
    <tr>
      <td>Tiles</td>
      <td>org.opengis.cite.gpkg12.tiles.*</td>
    </tr>
    <tr>
      <td>Registered Extensions</td>
      <td>org.opengis.cite.gpkg12.extensions.*</td>
    </tr>
    <tr>
      <td>Non-Linear Geometry Types</td>
      <td>org.opengis.cite.gpkg12.extensions.nonlinear.*</td>
    </tr>
    <tr>
      <td>RTree Spatial Indexes</td>
      <td>org.opengis.cite.gpkg12.extensions.rtreeindex.*</td>
    </tr>
    <tr>
      <td>Tiles Encoding WebP</td>
      <td>org.opengis.cite.gpkg12.extensions.webp.*</td>
    </tr>
    <tr>
      <td>Metadata</td>
      <td>org.opengis.cite.gpkg12.extensions.metadata.*</td>
    </tr>
    <tr>
      <td>Schema</td>
      <td>org.opengis.cite.gpkg12.extensions.schema.*</td>
    </tr>
    <tr>
      <td>WKT for Coordinate Reference Systems</td>
      <td>org.opengis.cite.gpkg12.extensions.crswkt.*</td>
    </tr>
    <tr>
      <td>Tiled Gridded Elevation Data</td>
      <td>org.opengis.cite.gpkg12.extensions.elevation.*</td>
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
