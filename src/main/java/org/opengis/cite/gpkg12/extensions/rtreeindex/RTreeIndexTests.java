package org.opengis.cite.gpkg12.extensions.rtreeindex;

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
 * GeoPackage's RTree Index Extension.
 *
 * <p style="margin-bottom: 0.5em">
 * <strong>Sources</strong>
 * </p>
 * <ul>
 * <li><a href="http://www.geopackage.org/spec/#extension_rtree" target= "_blank">
 * GeoPackage Encoding Standard - Annex F.3 RTree Spatial Index</a> (OGC 12-128r14)</li>
 * </ul>
 *
 * @author Jeff Yutzler
 */
public class RTreeIndexTests extends CommonFixture {


	/**
	 * The "gpkg_rtree_index" extension name SHALL be used as a 
	 * gpkg_extensions table extension_name column value to specify 
	 * implementation of spatial indexes on a geometry column.
	 *
	 * @see <a href="http://www.geopackage.org/spec/#r75" target=
	 *      "_blank">Requirement 75</a>
	 *
	 * @param testContext the ITestContext to use
	 * @throws SQLException on any error
	 */
	@BeforeClass
	public void validateExtensionPresent(ITestContext testContext) throws SQLException {
		Assert.assertTrue(DatabaseUtility.doesTableOrViewExist(this.databaseConnection, "gpkg_extensions"), 
				ErrorMessage.format(ErrorMessageKeys.CONFORMANCE_CLASS_NOT_USED, "RTree Spatial Index Extension"));
    	
		try (
				final Statement statement1 = this.databaseConnection.createStatement();
				ResultSet resultSet1 = statement1.executeQuery("SELECT COUNT(*) FROM gpkg_extensions WHERE extension_name = 'gpkg_rtree_index';");
				) {
			resultSet1.next();
			Assert.assertTrue(resultSet1.getInt(1) > 0, ErrorMessage.format(ErrorMessageKeys.CONFORMANCE_CLASS_NOT_USED, "RTree Spatial Index Extension"));  			
		}
	}

	/**
	 * Sets up variables used across methods
	 *
	 * @throws SQLException
	 *             if there is a database error
	 */
	@BeforeClass
	public void setUp() throws SQLException {
	}


	/**
	 * A GeoPackage that implements spatial indexes SHALL have a 
	 * `gpkg_extensions` table that contains a row for each spatially 
	 * indexed column with `extension_name` "gpkg_rtree_index", the 
	 * `table_name` of the table with a spatially indexed column, the 
	 * `column_name` of the spatially indexed column, and a `scope` of 
	 * "write-only".
	 * 
	 * @throws SQLException on any error
	 *
	 * @see <a href="http://www.geopackage.org/spec/#r76" target=
	 *      "_blank">Requirement 76</a>
	 *
	 */
	@Test(description = "See OGC 12-128r14: Requirement 76")
	public void extensionsTableRows() throws SQLException 
	{
		try (
				final Statement statement1 = this.databaseConnection.createStatement();
				ResultSet resultSet1 = statement1.executeQuery("SELECT table_name, column_name, scope FROM gpkg_extensions WHERE extension_name = 'gpkg_rtree_index'");
				) {
			while (resultSet1.next()){
				resultSet1.getString("column_name");
				Assert.assertTrue(!resultSet1.wasNull(), 
						ErrorMessage.format(ErrorMessageKeys.INVALID_RTREE_REFERENCE, resultSet1.getString("table_name"), resultSet1.getString("column_name")));
				Assert.assertTrue("write-only".equals(resultSet1.getString("scope")), 
						ErrorMessage.format(ErrorMessageKeys.ILLEGAL_EXTENSION_DATA_SCOPE, "gpkg_rtree_index", "write-only"));
			}
		}
	}

	/**
	 * A GeoPackage SHALL implement spatial indexes on feature table geometry 
	 * columns using the SQLite Virtual Table RTrees and triggers specified 
	 * below. The tables below contain SQL templates with variables. Replace 
	 * the following template variables with the specified values to create 
	 * the required SQL statements:
	 * &lt;t&gt;: The name of the feature table containing the geometry column
	 * &lt;c&gt;: The name of the geometry column in &lt;t&gt; that is being indexed
	 * &lt;i&gt;: The name of the integer primary key column in &lt;t&gt; as specified 
	 * in [r29]
	 * 
	 * @throws SQLException on any error
	 *
	 * @see <a href="http://www.geopackage.org/spec/#r77" target=
	 *      "_blank">Requirement 77</a>
	 *
	 */
	@Test(description = "See OGC 12-128r14: Requirement 77")
	public void extensionIndexImplementation() throws SQLException 
	{
		try (
				// 1
				final Statement statement1 = this.databaseConnection.createStatement();
				ResultSet resultSet1 = statement1.executeQuery("SELECT table_name, column_name FROM gpkg_geometry_columns WHERE table_name IN (SELECT table_name FROM gpkg_extensions WHERE extension_name == 'gpkg_rtree_index')");
				) {
			// 2
			while (resultSet1.next()){
				// 3
				final String tableName = resultSet1.getString("table_name");
				final String columnName = resultSet1.getString("column_name");

				try (
						// 3a
						final Statement statement3a = this.databaseConnection.createStatement();
						ResultSet resultSet3a = statement3a.executeQuery(String.format("SELECT sql FROM sqlite_master WHERE tbl_name = 'rtree_%s_%s'", tableName, columnName));
						) {
					String index = String.format("CREATE\\sVIRTUAL\\sTABLE\\s\"?rtree_%s_%s\"?\\sUSING\\srtree\\s?\\(id,\\s?minx,\\s?maxx,\\s?miny,\\s?maxy\\)", tableName, columnName);
					final String sql3a = resultSet3a.getString("sql");
					if (!Pattern.compile(index, Pattern.CASE_INSENSITIVE).matcher(sql3a).matches()){
						Assert.assertTrue(false, ErrorMessage.format(ErrorMessageKeys.INVALID_RTREE_DEFINITION, "virtual table", tableName));
					}

				}

				try (
						// 3d
						final Statement statement3d = this.databaseConnection.createStatement();
						ResultSet resultSet3d = statement3d.executeQuery(String.format("SELECT sql FROM sqlite_master WHERE type='trigger' AND name = 'rtree_%s_%s_delete'", tableName, columnName));
						) {
					String trigger3d = "CREATE\\sTRIGGER\\s\"?rtree_<t>_<c>_delete\"?\\sAFTER\\sDELETE\\sON\\s\"?<t>\"?\\s*WHEN\\sOLD.\"?<c>\"?\\sNOT\\sNULL\\s*BEGIN\\s*DELETE\\sFROM\\s\"?rtree_<t>_<c>\"?\\sWHERE\\s\\w*\\s?=\\s?OLD.\"?\\w*\"?;\\s*END";
					trigger3d = trigger3d.replaceAll("<t>", tableName).replaceAll("<c>", columnName);
					final String sql3d = resultSet3d.getString("sql");
					if(!Pattern.compile(trigger3d, Pattern.CASE_INSENSITIVE).matcher(sql3d).matches()){
						Assert.assertTrue(false, 
								ErrorMessage.format(ErrorMessageKeys.INVALID_RTREE_DEFINITION, "delete trigger", tableName));
					}

				}

				try (
						// 3c
						final Statement statement3c = this.databaseConnection.createStatement();
						ResultSet resultSet3c = statement3c.executeQuery(String.format("SELECT sql FROM sqlite_master WHERE type='trigger' AND name LIKE 'rtree_%s_%s_update%%' ORDER BY name ASC", tableName, columnName));
						) {
					// Update 1
					resultSet3c.next();
					final String sql3c1 = resultSet3c.getString("sql");
					String trigger1 = "CREATE\\sTRIGGER\\s\"?rtree_<t>_<c>_update1\"?\\sAFTER\\sUPDATE\\sOF\\s\"?<c>\"?\\sON\\s\"?<t>\"?\\s*WHEN\\sOLD.\"?\\w*\"?\\s?=\\s?NEW.\"?\\w*\"?\\sAND\\s*\\(NEW.\"?<c>\"?\\sNOT\\s?NULL\\sAND\\sNOT\\sST_IsEmpty\\s?\\(NEW.\"?<c>\"?\\)\\)\\s*BEGIN\\s*INSERT\\sOR\\sREPLACE\\sINTO\\s\"?rtree_<t>_<c>\"?\\sVALUES\\s?\\(\\s*NEW.\"?\\w*\"?,\\s*ST_MinX\\(NEW.\"?<c>\"?\\),\\s?ST_MaxX\\(NEW.\"?<c>\"?\\),\\s*ST_MinY\\(NEW.\"?<c>\"?\\),\\s?ST_MaxY\\(NEW.\"?<c>\"?\\)\\s*\\);\\s*END;?";
					trigger1 = trigger1.replaceAll("<t>", tableName).replaceAll("<c>", columnName);
					if(!Pattern.compile(trigger1, Pattern.CASE_INSENSITIVE).matcher(sql3c1).matches()){
						Assert.assertTrue(false, 
								ErrorMessage.format(ErrorMessageKeys.INVALID_RTREE_DEFINITION, "update trigger 1", tableName));
					}

					// Update 2
					resultSet3c.next();
					final String sql3c2 = resultSet3c.getString("sql");
					String trigger2 = "CREATE\\sTRIGGER\\s\"?rtree_<t>_<c>_update2\"?\\sAFTER\\sUPDATE\\sOF\\s\"?<c>\"?\\sON\\s\"?<t>\"?\\s*WHEN\\sOLD.\"?\\w*\"?\\s?=\\s?NEW.\"?\\w*\"?\\sAND\\s*\\(\\s?NEW.\"?<c>\"?\\sIS\\s?NULL\\sOR\\sST_IsEmpty\\s?\\(\\s?NEW.\"?<c>\"?\\)\\)\\s*BEGIN\\s*DELETE\\sFROM\\s\"?rtree_<t>_<c>\"?\\sWHERE\\s\\w*\\s?=\\s?OLD.\"?\\w*\"?;\\s*END";
					trigger2 = trigger2.replaceAll("<t>", tableName).replaceAll("<c>", columnName);
					if(!Pattern.compile(trigger2, Pattern.CASE_INSENSITIVE).matcher(sql3c2).matches()){
						Assert.assertTrue(false, 
								ErrorMessage.format(ErrorMessageKeys.INVALID_RTREE_DEFINITION, "update trigger 2", tableName));
					}

					// Update 3
					resultSet3c.next();
					final String sql3c3 = resultSet3c.getString("sql");
					String trigger3 = "CREATE\\sTRIGGER\\s\"?rtree_<t>_<c>_update3\"?\\sAFTER\\sUPDATE\\sOF\\s\"?<c>\"?\\sON\\s\"?<t>\"?\\s*WHEN\\sOLD.\"?\\w*\"?\\s?!=\\s?NEW.\"?\\w*\"?\\sAND\\s*\\(\\s?NEW.\"?<c>\"?\\sNOT\\s?NULL\\sAND\\sNOT\\sST_IsEmpty\\s?\\(\\s?NEW.\"?<c>\"?\\)\\)\\s*BEGIN\\s*DELETE\\sFROM\\s\"?rtree_<t>_<c>\"?\\sWHERE\\s\\w*\\s?=\\s?OLD.\"?\\w*\"?;\\s*INSERT\\sOR\\sREPLACE\\sINTO\\s\"?rtree_<t>_<c>\"?\\sVALUES\\s?\\(\\s*NEW.\"?\\w*\"?,\\s*ST_MinX\\(\\s?NEW.\"?<c>\"?\\),\\s?ST_MaxX\\(NEW.\"?<c>\"?\\),\\s*ST_MinY\\(\\s?NEW.\"?<c>\"?\\),\\s?ST_MaxY\\(\\s?NEW.\"?<c>\"?\\)\\s*\\);\\s*END";
					trigger3 = trigger3.replaceAll("<t>", tableName).replaceAll("<c>", columnName);
					if(!Pattern.compile(trigger3, Pattern.CASE_INSENSITIVE).matcher(sql3c3).matches()){
						Assert.assertTrue(false, 
								ErrorMessage.format(ErrorMessageKeys.INVALID_RTREE_DEFINITION, "update trigger 3", tableName));
					}

					// Update 4
					resultSet3c.next();
					final String sql3c4 = resultSet3c.getString("sql");
					String trigger4 = "CREATE\\sTRIGGER\\s\"?rtree_<t>_<c>_update4\"?\\sAFTER\\sUPDATE\\sON\\s\"?<t>\"?\\s*WHEN\\sOLD.\"?\\w*\"?\\s?!=\\s?NEW.\"?\\w*\"?\\sAND\\s*\\(\\s?NEW.\"?<c>\"?\\sIS\\s?NULL\\sOR\\sST_IsEmpty\\s?\\(\\s?NEW.\"?<c>\"?\\)\\)\\s*BEGIN\\s*DELETE\\sFROM\\s\"?rtree_<t>_<c>\"?\\sWHERE\\s\\w*\\sIN\\s?\\(\\s?OLD.\"?\\w*\"?\\s?,\\s?NEW.\"?\\w*\"?\\);\\s*END";
					trigger4 = trigger4.replaceAll("<t>", tableName).replaceAll("<c>", columnName);
					if(!Pattern.compile(trigger4, Pattern.CASE_INSENSITIVE).matcher(sql3c4).matches()){
						Assert.assertTrue(false, 
								ErrorMessage.format(ErrorMessageKeys.INVALID_RTREE_DEFINITION, "update trigger 4", tableName));
					}					
				}

				try (
						// 3b
						final Statement statement3b = this.databaseConnection.createStatement();
						ResultSet resultSet3b = statement3b.executeQuery(String.format("SELECT sql FROM sqlite_master WHERE type='trigger' AND name = 'rtree_%s_%s_insert'", tableName, columnName));
						) {
					String trigger3b = "CREATE\\sTRIGGER\\s\"?rtree_<t>_<c>_insert\"?\\sAFTER\\sINSERT\\sON\\s\"?<t>\"?\\s*WHEN\\s?\\(new.\"?<c>\"?\\sNOT\\s?NULL\\sAND\\sNOT\\sST_IsEmpty\\(NEW.\"?<c>\"?\\)\\)\\s*BEGIN\\s*INSERT\\sOR\\sREPLACE\\sINTO\\s\"?rtree_<t>_<c>\"?\\sVALUES\\s\\(\\s*NEW.\"?\\w+\"?,\\s*ST_MinX\\(NEW.\"?<c>\"?\\),\\s?ST_MaxX\\(NEW.\"?<c>\"?\\),\\s*ST_MinY\\(NEW.\"?<c>\"?\\),\\s?ST_MaxY\\(NEW.\"?<c>\"?\\)\\s*\\);\\s*END;?";
					trigger3b = trigger3b.replaceAll("<t>", tableName).replaceAll("<c>", columnName);
					final String sql3b = resultSet3b.getString("sql");
					if(!Pattern.compile(trigger3b, Pattern.CASE_INSENSITIVE).matcher(sql3b).matches()){
						Assert.assertTrue(false, 
								ErrorMessage.format(ErrorMessageKeys.INVALID_RTREE_DEFINITION, "insert trigger", tableName));
					}
				}
			}
		}
	}
}