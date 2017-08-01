package org.opengis.cite.gpkg12.extensions.nonlinear;

import static org.testng.Assert.assertTrue;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Arrays;
import java.util.Collection;
import org.opengis.cite.gpkg12.ErrorMessage;
import org.opengis.cite.gpkg12.ErrorMessageKeys;
import org.opengis.cite.gpkg12.features.FeaturesTests;
import org.opengis.cite.gpkg12.util.DatabaseUtility;
import org.testng.Assert;
import org.testng.ITestContext;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;

/**
 * Defines test methods that apply to descriptive information about a
 * GeoPackage's RTree Index Extension.
 *
 * <p style="margin-bottom: 0.5em">
 * <strong>Sources</strong>
 * </p>
 * <ul>
 * <li><a href="http://www.geopackage.org/spec/#extension_geometry_types" target= "_blank">
 * GeoPackage Encoding Standard - Annex F.1 Non-Linear Geometry Types</a> (OGC 12-128r13)</li>
 * </ul>
 *
 * @author Jeff Yutzler
 */
public class NonlinearTests extends FeaturesTests {


	/**
	 * An extension name to specify a feature geometry extension type SHALL 
	 * be defined for the "gpkg" author name using the "gpkg_geom_&lt;gname&gt;" 
	 * template where &lt;gname&gt; is the uppercase name of the extension geometry 
	 * type from Geometry Types (Normative) used in a GeoPackage.
	 *
	 * @see <a href="http://www.geopackage.org/spec/#r67" target=
	 *      "_blank">F.8. Non-Linear Geometry Types - Requirement 67</a>
	 *
	 * @param testContext the ITestContext to use
	 * @throws SQLException on any error
	 */
	@BeforeClass
	public void validateExtensionPresent(ITestContext testContext) throws SQLException {
		Assert.assertTrue(DatabaseUtility.doesTableOrViewExist(this.databaseConnection, "gpkg_extensions"), 
				ErrorMessage.format(ErrorMessageKeys.CONFORMANCE_CLASS_NOT_USED, "Non-Linear Geometry Types Extension"));
    	
		try (
				final Statement statement1 = this.databaseConnection.createStatement();
				ResultSet resultSet1 = statement1.executeQuery("SELECT COUNT(*) FROM gpkg_extensions WHERE extension_name LIKE 'gpkg_geom_%';");
				) {
			resultSet1.next();
			Assert.assertTrue(resultSet1.getInt(1) > 0, ErrorMessage.format(ErrorMessageKeys.CONFORMANCE_CLASS_NOT_USED, "Non-Linear Geometry Types Extension"));
		}
	}

	/**
	 * The `geometry_type_name` value in a `gpkg_geometry_columns` row MAY be 
	 * one of the uppercase extended non-linear geometry type names specified 
	 * in geometry_types.
	 * 
	 * Test case
	 * {@code /extensions/geometry_types/data_values_geometry_type_name}
	 *
	 * Extends test case
	 * {@code /opt/features/geometry_columns/data/data_values_geometry_type_name}
	 *
	 * @see <a href="#r65" target= "_blank">Annex F.1 GeoPackage 
	 * Non-Linear Geometry Types - Requirement 65</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 65")
	public void featureGeometryColumnsDataValuesGeometryType() throws SQLException {
		try (
				// 1
				final Statement statement = this.databaseConnection.createStatement();

				final ResultSet resultSet = statement.executeQuery("SELECT table_name, column_name, geometry_type_name FROM gpkg_geometry_columns");
				) {
			// 2
			while (resultSet.next()){
				// 3
				final String geometryTypeName = resultSet.getString("geometry_type_name");
				final String tableName = resultSet.getString("table_name");

				boolean pass = false;

				if (getGeopackageVersion().equals(GeoPackageVersion.V120)){
					pass |= getAllowedGeometryTypes().contains(geometryTypeName) || extendedGeometryTypes.contains(geometryTypeName);
				} else {
					for (final String geometryType: extendedGeometryTypes){
						if (geometryTypeName.equalsIgnoreCase(geometryType)){
							pass = true;
							break;
						}
					}
					for (final String geometryType: getAllowedGeometryTypes()){
						if (geometryTypeName.equalsIgnoreCase(geometryType)){
							pass = true;
							break;
						}
					}
				}

				assertTrue(pass, ErrorMessage.format(ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID_GEOM, geometryTypeName, tableName));
			}			
		}
	}

	// TODO: No clear way to test R66 as it requires a spatial library

	/**
	 * A GeoPackage that contains a `gpkg_geometry_columns` table or 
	 * updateable view with row records that specify extension 
	 * `geometry_type_name` column values SHALL contain a `gpkg_extensions` 
	 * table that contains row records with `table_name` and `column_name` 
	 * values from the `gpkg_geometry_columns` row records that identify 
	 * extension type uses, and `extension_name` column values for each of 
	 * those geometry types constructed per the previous requirement 
	 * extension_geometry_types_extensions_name.
	 * 
	 * Test case
	 * {@code /extensions/geometry_types/extension_row}
	 *
	 * @see <a href="#r68" target= "_blank">Annex F.1 GeoPackage 
	 * Non-Linear Geometry Types - Requirement 68</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 68")
	public void extensionsRow() throws SQLException {
		try (
				// 1
				final Statement statement1 = this.databaseConnection.createStatement();

				final ResultSet resultSet1 = statement1.executeQuery("SELECT table_name, column_name, geometry_type_name FROM gpkg_geometry_columns");
				) {
			// 2
			while (resultSet1.next()){
				// 3
				final String geometryTypeName = resultSet1.getString("geometry_type_name");

				// 3a
				if(extendedGeometryTypes.contains(geometryTypeName)) {
					final String tableName = resultSet1.getString("table_name");
					final String columnName = resultSet1.getString("column_name");

					try (
							// 3ai
							final Statement statement2 = this.databaseConnection.createStatement();

							final ResultSet resultSet2 = statement2.executeQuery(String.format("SELECT extension_name FROM gpkg_extensions WHERE table_name = '%s' AND column_name = '%s'", tableName, columnName));
							) {
						boolean pass = false;

						while (resultSet2.next()) {
							// 3aii
							if (resultSet2.getString(1).equals(String.format("gpkg_geom_%s", geometryTypeName))) {
								pass |= true;
								break;
							}
						}
						assertTrue(pass, 
								ErrorMessage.format(ErrorMessageKeys.EXTENDED_GEOMETRY_REFERENCE_MISSING, tableName, geometryTypeName));
					}
				}
			}			
		}
	}


	private static final Collection<String> extendedGeometryTypes = 
			Arrays.asList("CIRCULARSTRING", "COMPOUNDCURVE", "CURVEPOLYGON", "MULTICURVE", "MULTISURFACE", "CURVE", "SURFACE");
}
