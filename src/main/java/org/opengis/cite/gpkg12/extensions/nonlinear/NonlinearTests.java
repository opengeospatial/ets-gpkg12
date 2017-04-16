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
     * be defined for the "gpkg" author name using the "gpkg_geom_<gname>" 
     * template where <gname> is the uppercase name of the extension geometry 
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
  		
		final Statement statement1 = this.databaseConnection.createStatement();
		ResultSet resultSet1 = statement1.executeQuery("SELECT COUNT(*) FROM gpkg_extensions WHERE extension_name LIKE 'gpkg_geom_%';");
		resultSet1.next();
        Assert.assertTrue(resultSet1.getInt(1) > 0, ErrorMessage.format(ErrorMessageKeys.CONFORMANCE_CLASS_NOT_USED, "RTree Spatial Index Extension"));
    }


	/**
	 * The `geometry_type_name` value in a `gpkg_geometry_columns` row MAY be 
	 * one of the uppercase extended non-linear geometry type names specified 
	 * in <<geometry_types>>.
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
		// 1
		final Statement statement = this.databaseConnection.createStatement();

		final ResultSet resultSet = statement.executeQuery("SELECT table_name, column_name, geometry_type_name FROM gpkg_geometry_columns");
		
		// 2
		while (resultSet.next()){
			// 3
			final String geometryTypeName = resultSet.getString("geometry_type_name");
			final String tableName = resultSet.getString("table_name");
			
			boolean pass = false;

			if (getGeopackageVersion().equals(GeoPackageVersion.V120)){
				pass = allowedGeometryTypes.contains(geometryTypeName);
			} else {
				for (String geometryType: allowedGeometryTypes){
					if (geometryTypeName.equalsIgnoreCase(geometryType)){
						pass = true;
						break;
					}
				}
			}
			
			assertTrue(pass, ErrorMessage.format(ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID_GEOM, geometryTypeName, tableName));
		}
	}

	private static final Collection<String> allowedGeometryTypes = 
			Arrays.asList("GEOMETRY","POINT","LINESTRING","POLYGON","MULTIPOINT","MULTILINESTRING","MULTIPOLYGON","GEOMETRYCOLLECTION",
					"CIRCULARSTRING", "COMPOUNDCURVE", "CURVEPOLYGON", "MULTICURVE", "MULTISURFACE", "CURVE", "SURFACE");
}
