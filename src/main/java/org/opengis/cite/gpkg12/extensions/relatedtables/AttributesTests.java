package org.opengis.cite.gpkg12.extensions.relatedtables;

import java.sql.SQLException;

import org.testng.ITestContext;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;

/**
 * Defines test methods that apply to the "Related Attributes" 
 * requirements class of the Related Tables Extension.
 *
 * <p style="margin-bottom: 0.5em">
 * <strong>Sources</strong>
 * </p>
 * <ul>
 * <li><a href="http://docs.opengeospatial.org/is/18-000/18-000.html#attr_rc" target= "_blank">
 * GeoPackage Related Tables Extension, Related Attributes Requirements Class</a> (OGC 18-000)</li>
 * </ul>
 *
 * @author Jeff Yutzler
 */
public class AttributesTests extends RTEBase
{
	/**
	 * A user-defined related data table or view SHALL be a user-defined 
	 * related attributes table or view if the row in gpkgext_relations 
	 * with a corresponding related_table_name has a relation_name of 
	 * "attributes".
	 * 
     * @see <a href="http://docs.opengeospatial.org/is/18-000/18-000.html#r18" target=
     *      "_blank">OGC 18-000 Requirement 18</a> 
     **/
	@BeforeClass
	public void activeExtension(ITestContext testContext) throws SQLException {
		super.activeExtension(testContext);
		testRequirementsClassActive("attributes", "Related Attributes");
	}
	
    /**
     * A user-defined related attributes table or view SHALL be a GPKG 
     * attributes table type.
     * 
     * @see <a href="http://docs.opengeospatial.org/is/18-000/18-000.html#r19" target=
     *      "_blank">OGC 18-000 Requirement 19</a> 
     */
    @Test(description = "See OGC 18-000: Requirement 19")
    public void attributesTableDefinition() throws SQLException {
    	testRelatedType("attributes", "attributes");
    }
}
