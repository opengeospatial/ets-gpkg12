package org.opengis.cite.gpkg12.extensions.relatedtables;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import org.opengis.cite.gpkg12.ErrorMessage;
import org.opengis.cite.gpkg12.ErrorMessageKeys;
import org.testng.Assert;
import org.testng.ITestContext;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;

/**
 * Defines test methods that apply to the "features" requirements class of the 
 * Related Tables Extension.
 *
 * <p style="margin-bottom: 0.5em">
 * <strong>Sources</strong>
 * </p>
 * <ul>
 * <li><a href="http://docs.opengeospatial.org/is/18-000/18-000.html#f_rc" target= "_blank">
 * GeoPackage Related Tables Extension, Features Requirements Class</a> (OGC 18-000)</li>
 * </ul>
 *
 * @author Jeff Yutzler
 */
public class FeaturesTests extends RTEBase
{
	@BeforeClass
	public void activeExtension(ITestContext testContext) throws SQLException {
		super.activeExtension(testContext);
		try (
				final Statement statement = this.databaseConnection.createStatement();
				
				final ResultSet resultSet = statement.executeQuery(
						"SELECT COUNT(*) FROM gpkgext_relations WHERE relation_name = 'features'");
				) {
			resultSet.next();
			
			Assert.assertTrue(resultSet.getInt(1) > 0, 
					ErrorMessage.format(ErrorMessageKeys.CONFORMANCE_CLASS_NOT_USED, "Related Tables Extension, Features Requirements Class"));				
		}
	}
    
    /**
     * A user-defined related features table or view SHALL be a GPKG vector 
     * feature table type.
     * 
     * @see <a href="http://docs.opengeospatial.org/is/18-000/18-000.html#r17" target=
     *      "_blank">OGC 18-000 Requirement 17</a> 
     */
    @Test(description = "See OGC 18-000: Requirement 17")
    public void featuresTableDefinition() throws SQLException
    {
		try (
				final Statement statement = this.databaseConnection.createStatement();
				
				final ResultSet resultSet = statement.executeQuery(
						"SELECT related_table_name FROM gpkgext_relations WHERE relation_name = 'features';");
				) {
			while (resultSet.next()) {
				
				final String relatedTableName = resultSet.getString("related_table_name");
				
				try (
						final Statement statement2 = this.databaseConnection.createStatement();
						
						final ResultSet resultSet2 = statement2.executeQuery(
								String.format("SELECT data_type FROM gpkg_contents WHERE table_name = '%s';", relatedTableName));
						) {

					Assert.assertTrue(resultSet2.next(), 
							ErrorMessage.format(ErrorMessageKeys.MISSING_REFERENCE, "gpkg_contents", "table_name", relatedTableName));
					final String dataType = resultSet2.getString("data_type");
					Assert.assertEquals(dataType, "features", 
							ErrorMessage.format(ErrorMessageKeys.INVALID_DATA_TYPE, dataType, relatedTableName, "gpkgext_relations"));
				}
			}
		}
	}
}
