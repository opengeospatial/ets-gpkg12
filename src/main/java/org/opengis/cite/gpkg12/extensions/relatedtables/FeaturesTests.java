package org.opengis.cite.gpkg12.extensions.relatedtables;

import java.sql.SQLException;

import org.testng.ITestContext;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;

/**
 * Defines test methods that apply to the "Related Features" requirements class of the 
 * Related Tables Extension.
 *
 * <p style="margin-bottom: 0.5em">
 * <strong>Sources</strong>
 * </p>
 * <ul>
 * <li><a href="http://docs.opengeospatial.org/is/18-000/18-000.html#f_rc" target= "_blank">
 * GeoPackage Related Tables Extension, Related Features Requirements Class</a> (OGC 18-000)</li>
 * </ul>
 *
 * @author Jeff Yutzler
 */
public class FeaturesTests extends RTEBase
{
	/**
	 * A user-defined related data table or view SHALL be a user-defined 
	 * features table or view if the row in gpkgext_relations 
	 * with a corresponding related_table_name has a relation_name of 
	 * "features".
	 * 
	 * @param testContext a test context
	 * 
	 * @throws SQLException
	 *             On any SQL query error or test failure
	 *             
     * @see <a href="http://docs.opengeospatial.org/is/18-000/18-000.html#r16" target=
     *      "_blank">OGC 18-000 Requirement 16</a> 
     **/
	@BeforeClass
	public void activeExtension(ITestContext testContext) throws SQLException {
		super.activeExtension(testContext);
		testRequirementsClassActive("features", "Related Features");
	}
    
    /**
     * A user-defined related features table or view SHALL be a GPKG vector 
     * feature table type.
     * 
	 * @throws SQLException
	 *             On any SQL query error or test failure
	 *             
     * @see <a href="http://docs.opengeospatial.org/is/18-000/18-000.html#r17" target=
     *      "_blank">OGC 18-000 Requirement 17</a> 
     */
    @Test(description = "See OGC 18-000: Requirement 17")
    public void featuresTableDefinition() throws SQLException
    {
    	testRelatedType("feature", "features");
	}
}
