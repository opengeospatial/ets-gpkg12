package org.opengis.cite.gpkg12.extensions.relatedtables;

import java.sql.SQLException;

import org.testng.ITestContext;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;

/**
 * Defines test methods that apply to the "tiles" requirements class of the 
 * Related Tables Extension.
 *
 * <p style="margin-bottom: 0.5em">
 * <strong>Sources</strong>
 * </p>
 * <ul>
 * <li><a href="http://docs.opengeospatial.org/is/18-000/18-000.html#tiles_rc" target= "_blank">
 * GeoPackage Related Tables Extension, Tiles Requirements Class</a> (OGC 18-000)</li>
 * </ul>
 *
 * @author Jeff Yutzler
 */
public class TilesTests extends RTEBase
{
	/**
	 * A user-defined related data table or view SHALL be a user-defined 
	 * related tiles table or view if the row in gpkgext_relations with a 
	 * corresponding related_table_name has a relation_name of "tiles".
	 * 
	 * @param testContext a test context
	 * 
	 * @throws SQLException
	 *             On any SQL query error or test failure
	 *             
     * @see <a href="http://docs.opengeospatial.org/is/18-000/18-000.html#r20" target=
     *      "_blank">OGC 18-000 Requirement 20</a> 
	 */
	@BeforeClass
	public void activeExtension(ITestContext testContext) throws SQLException {
		super.activeExtension(testContext);
		testRequirementsClassActive("tiles", "Tiles");
	}
    
    /**
     * A user-defined related features table or view SHALL be a GPKG 
     * tile pyramid table type.
     * 
	 * @throws SQLException
	 *             On any SQL query error or test failure
	 *             
     * @see <a href="http://docs.opengeospatial.org/is/18-000/18-000.html#r17" target=
     *      "_blank">OGC 18-000 Requirement 17</a> 
     */
    @Test(description = "See OGC 18-000: Requirement 17")
    public void tilesTableDefinition() throws SQLException
    {
    	testRelatedType("tiles", "tiles");
	}
}
