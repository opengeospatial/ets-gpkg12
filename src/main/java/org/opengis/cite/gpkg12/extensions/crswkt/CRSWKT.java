package org.opengis.cite.gpkg12.extensions.crswkt;

import static org.testng.Assert.assertTrue;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.regex.Pattern;

import org.opengis.cite.gpkg12.CommonFixture;
import org.opengis.cite.gpkg12.ErrorMessage;
import org.opengis.cite.gpkg12.ErrorMessageKeys;
import org.opengis.cite.gpkg12.util.DatabaseUtility;
import org.testng.Assert;
import org.testng.ITestContext;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;

/**
 * Defines test methods that apply to descriptive information about a
 * GeoPackage's content as it pertains to the CRS WKT extension.
 *
 * <p style="margin-bottom: 0.5em">
 * <strong>Sources</strong>
 * </p>
 * <ul>
 * <li><a href="http://www.geopackage.org/spec/#extension_crs_wkt" target= "_blank">
 * GeoPackage Encoding Standard - F.10. CRS WKT	</a> (OGC 12-128r13)</li>
 * </ul>
 *
 * @author Luke Lambert, Jeff Yutzler
 */
public class CRSWKT extends CommonFixture
{
    @BeforeClass
    public void activeExtension(ITestContext testContext) throws SQLException {
		Assert.assertTrue(DatabaseUtility.doesTableOrViewExist(this.databaseConnection, "gpkg_extensions"), 
				ErrorMessage.format(ErrorMessageKeys.CONFORMANCE_CLASS_NOT_USED, "CRS WKT Extension"));
    	
		try (
				final Statement statement = this.databaseConnection.createStatement();
				final ResultSet resultSet = statement.executeQuery("SELECT count(*) from gpkg_extensions WHERE extension_name = 'gpkg_crs_wkt';");
			) {
			resultSet.next();
			
			Assert.assertTrue(resultSet.getInt(1) > 0, ErrorMessage.format(ErrorMessageKeys.CONFORMANCE_CLASS_NOT_USED, "CRS WKT Extension"));			
		}
	
    }

    /**
     * For GeoPackages conforming to this extension, the 
     * gpkg_spatial_ref_sys table SHALL have an additional column called 
     * definition_12_063 as per Spatial Ref Sys Table Definition and 
     * gpkg_spatial_ref_sys Table Definition SQL (CRS WKT Extension).
     *
     * @see <a href="http://www.geopackage.org/spec/#r115" target=
     *      "_blank">F.10. CRS WKT - Requirement 115</a>
     *
     * @throws SQLException
     *             If an SQL query causes an error
     */
    @Test(description = "See OGC 12-128r13: Requirement 115")
    public void tableDefinition() throws SQLException
    {
    	try (
    			// 1
    			final Statement statement = this.databaseConnection.createStatement();
    			final ResultSet resultSet = statement.executeQuery("PRAGMA table_info('gpkg_spatial_ref_sys');");
    			) {

    		// 2
    		int passFlag = 0;
    		final int flagMask = 0b00000001;

    		while (resultSet.next()) {
    			// 3
    			final String name = resultSet.getString("name");
    			if ("definition_12_063".equals(name)){
    				assertTrue("TEXT".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_spatial_ref_sys", "definition_16_063 type"));
    				assertTrue(resultSet.getInt("notnull") == 1, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_spatial_ref_sys", "definition_16_063 notnull"));
    				assertTrue(resultSet.getInt("pk") == 0, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_spatial_ref_sys", "definition_16_063 pk"));
    				assertTrue(Pattern.compile("\\A([\"']?)undefined(\\1)\\z").matcher(resultSet.getString("dflt_value")).find(), ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_spatial_ref_sys", "definition_16_063 dflt_value"));
    				passFlag |= 1;
    			}
    		} 
    		assertTrue((passFlag & flagMask) == flagMask, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_spatial_ref_sys", "missing column(s)"));
    	}

    }

    // Requirement 116 is not testable with these tools
    
    /**
     * At least one definition column SHALL be defined with a valid 
     * definition unless the value of the srs_id column is 0 or -1. Both 
     * columns SHOULD be defined. If it is not possible to produce a valid 
     * [32] definition then the value of the definition column MAY be 
     * undefined. If it is not possible to produce a valid [34] definition 
     * then the value of the definition_12_063 column MAY be undefined.
     *
     * @see <a href="http://www.geopackage.org/spec/#r117" target=
     *      "_blank">F.10. CRS WKT - Requirement 117</a>
     *
     * @throws SQLException
     *             If an SQL query causes an error
     */
    @Test(description = "See OGC 12-128r13: Requirement 117")
    public void crsTableValues() throws SQLException
    {
    	try (
    			// 1
    			final Statement statement = this.databaseConnection.createStatement();

    			final ResultSet resultSet = statement.executeQuery("SELECT srs_id, definition, definition_12_063 FROM gpkg_spatial_ref_sys WHERE srs_id NOT IN (0, -1);");
    			) {

    		// 2
    		while (resultSet.next()) {
    			// 3
    			assertTrue(!("undefined".equals(resultSet.getString("definition")) && "undefined".equals(resultSet.getString("definition_12_063"))), 
    					ErrorMessage.format(ErrorMessageKeys.UNDEFINED_SRS, resultSet.getString("srs_id")));
    		} 
    	}
		
    }
}
