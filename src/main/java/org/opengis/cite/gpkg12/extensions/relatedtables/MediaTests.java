package org.opengis.cite.gpkg12.extensions.relatedtables;

import static org.testng.Assert.assertTrue;

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
 * Defines test methods that apply to the "Media" requirements class of the 
 * Related Tables Extension.
 *
 * <p style="margin-bottom: 0.5em">
 * <strong>Sources</strong>
 * </p>
 * <ul>
 * <li><a href="http://docs.opengeospatial.org/is/18-000/18-000.html#media_rc" target= "_blank">
 * GeoPackage Related Tables Extention, Media Requirements Class</a> (OGC 18-000)</li>
 * </ul>
 *
 * @author Jeff Yutzler
 */
public class MediaTests extends RTEBase
{
	/**
	 * A user-defined related data table or view SHALL be a user-defined 
	 * media table or view if the row in gpkgext_relations with a 
	 * corresponding related_table_name has a relation_name of "media".
	 * 
     * @see <a href="http://docs.opengeospatial.org/is/18-000/18-000.html#r12" target=
     *      "_blank">OGC 18-000 Requirement 12</a> 
	 */
	@BeforeClass
	public void activeExtension(ITestContext testContext) throws SQLException {
		super.activeExtension(testContext);
		testRequirementsClassActive("media", "Media");
	}
	
    /**
     * A user-defined media table or view SHALL meet all 
     * requirements of a GPKG attributes table type.
     * 
     * A user-defined media table or view SHALL contain all of the columns 
     * described in User-Defined Media Table Definition.
     * 
     * @see <a href="http://docs.opengeospatial.org/is/18-000/18-000.html#r12" target=
     *      "_blank">OGC 18-000 Requirement 12b, 13</a> 
     */
    @Test(description = "See OGC 18-000: Requirement 12b, 13")
    public void mediaTableDefinition() throws SQLException {
    	testRelatedType("media", "attributes");

		try (
				final Statement statement = this.databaseConnection.createStatement();
				
				final ResultSet resultSet = statement.executeQuery(
						"SELECT related_table_name FROM gpkgext_relations WHERE relation_name = 'media';");
				) {
			
			while (resultSet.next()) {
				int passFlag = 0;
	    		final int flagMask = 0b00000011;
	    		
	    		final String relatedTableName = resultSet.getString("related_table_name");
	    		getPrimaryKeyColumn(relatedTableName, true);
	    		try (
	    				final Statement statement2 = this.databaseConnection.createStatement();
	    				
	    				final ResultSet resultSet2 = statement2.executeQuery(
	    						String.format("PRAGMA table_info(%s)", relatedTableName));
	    				) {
		    		while (resultSet2.next()) {
		    			// 3
		    			final String name = resultSet2.getString("name");
		    			if ("data".equals(name)){
		    				Assert.assertEquals(resultSet2.getString("type"), "BLOB", ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, relatedTableName, "data type"));
		    				Assert.assertEquals(resultSet2.getInt("notnull"), 1, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, relatedTableName, "data notnull"));
		    				Assert.assertEquals(resultSet2.getInt("pk"), 0, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, relatedTableName, "data pk"));
		    				passFlag |= 1;
		    			} else if ("content_type".equals(name)){
		    				Assert.assertEquals(resultSet2.getString("type"), "TEXT", ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, relatedTableName, "content_type type"));
		    				Assert.assertEquals(resultSet2.getInt("notnull"), 1, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, relatedTableName, "content_type notnull"));
		    				Assert.assertEquals(resultSet2.getInt("pk"), 0, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, relatedTableName, "content_type pk"));
		    				passFlag |= (1 << 1);
		    			}
		    		} 
		    		assertTrue((passFlag & flagMask) == flagMask, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, relatedTableName, String.format("missing column(s): code(%s)", passFlag)));
	    		}
			}
		}
    }
}
