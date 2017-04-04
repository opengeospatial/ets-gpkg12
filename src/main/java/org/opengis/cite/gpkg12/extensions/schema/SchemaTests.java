package org.opengis.cite.gpkg12.extensions.schema;

import static org.testng.Assert.assertTrue;

import java.io.IOException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Map;

import org.opengis.cite.gpkg12.CommonFixture;
import org.opengis.cite.gpkg12.ErrorMessage;
import org.opengis.cite.gpkg12.ErrorMessageKeys;
import org.opengis.cite.gpkg12.TestRunArg;
import org.opengis.cite.gpkg12.util.DatabaseUtility;
import org.testng.Assert;
import org.testng.ITestContext;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.BeforeTest;
import org.testng.annotations.Test;

/**
 * Defines test methods that apply to descriptive information about a
 * GeoPackage's content as it pertains to the schema extension.
 *
 * <p style="margin-bottom: 0.5em">
 * <strong>Sources</strong>
 * </p>
 * <ul>
 * <li><a href="http://www.geopackage.org/spec/#extension_schema" target= "_blank">
 * GeoPackage Encoding Standard - F.9. Schema</a> (OGC 12-128r13)</li>
 * </ul>
 *
 * @author Jeff Yutzler
 */
public class SchemaTests extends CommonFixture
{
    /**
     * Sets up variables used across methods
     *
     * @throws SQLException if there is a database error
     */
    @BeforeClass
    public void setUp() throws SQLException
    {
    }

    @BeforeTest
    public void validateClassEnabled(ITestContext testContext) throws IOException {
      Map<String, String> params = testContext.getSuite().getXmlSuite().getParameters();
      final String pstr = params.get(TestRunArg.ICS.toString());
      final String testName = testContext.getName();
      HashSet<String> set = new HashSet<String>(Arrays.asList(pstr.split(",")));
      if (set.contains(testName)){
        Assert.assertTrue(true);
      } else {
        Assert.assertTrue(false, String.format("Conformance class %s is not enabled", testName));
      }
    }
    
    @BeforeClass
    public void activeExtension(ITestContext testContext) throws SQLException {
    	// Starting with GPKG 1.2, this is a proper extension.
    	if (getGeopackageVersion() == GeoPackageVersion.V120) {
			Assert.assertTrue(DatabaseUtility.doesTableOrViewExist(this.databaseConnection, "gpkg_extensions"), 
					ErrorMessage.format(ErrorMessageKeys.MISSING_TABLE, "gpkg_extensions"));
			
			final Statement statement = this.databaseConnection.createStatement();
		
			final ResultSet resultSet = statement.executeQuery("SELECT count(*) from gpkg_extensions WHERE extension_name = 'gpkg_schema';");
		
			resultSet.next();
		
			Assert.assertTrue(resultSet.getInt(1) > 0, ErrorMessage.format(ErrorMessageKeys.EXTENSION_MISSING, "gpkg_schema"));
    	}		
    }

    /**
     * A GeoPackage MAY contain a table or updateable view named 
     * gpkg_data_columns. If present it SHALL be defined per clause 2.3.2.1.1 
     * Table Definition, Data Columns Table or View Definition and 
     * gpkg_data_columns Table Definition SQL.
     * 
     * @see <a href="http://www.geopackage.org/spec/#r103" target=
     *      "_blank">F.9. Schema - Requirement 103</a>
     *
     * @throws SQLException
     *             If an SQL query causes an error
     */
    @Test(description = "See OGC 12-128r13: Requirement 103")
    public void dataColumnsTableDefinition() throws SQLException
    {
		// 1
		final Statement statement = this.databaseConnection.createStatement();

		final ResultSet resultSet = statement.executeQuery("PRAGMA table_info('gpkg_data_columns');");

		// 2
		int passFlag = 0;
		final int flagMask = 0b01111111;
		
		while (resultSet.next()) {
			// 3
			final String name = resultSet.getString("name");
			if ("table_name".equals(name)){
				assertTrue("TEXT".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_columns", "table_name type"));
				assertTrue(resultSet.getInt("notnull") == 1, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_columns", "table_name notnull"));
				assertTrue(resultSet.getInt("pk") > 0, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_columns", "table_name pk"));
				passFlag |= 1;
			} else if ("column_name".equals(name)){
				assertTrue("TEXT".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_columns", "column_name type"));
				assertTrue(resultSet.getInt("notnull") == 1, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_columns", "column_name notnull"));
				assertTrue(resultSet.getInt("pk") > 0, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_columns", "column_name pk"));
				passFlag |= (1 << 1);
			} else if ("name".equals(name)){
				assertTrue("TEXT".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_columns", "name type"));

				// Huh? How can a unique value be allowed to be null?
				assertTrue(resultSet.getInt("notnull") == 0, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_columns", "name notnull"));
				
				// unique constraint??
				passFlag |= (1 << 2);
			} else if ("title".equals(name)){
				assertTrue("TEXT".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_columns", "title type"));
				assertTrue(resultSet.getInt("notnull") == 0, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_columns", "title notnull"));
				passFlag |= (1 << 3);
			} else if ("description".equals(name)){
				assertTrue("TEXT".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_columns", "description type"));
				assertTrue(resultSet.getInt("notnull") == 0, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_columns", "description notnull"));
				passFlag |= (1 << 4);
			} else if ("mime_type".equals(name)){
				assertTrue("TEXT".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_columns", "mime_type type"));
				assertTrue(resultSet.getInt("notnull") == 0, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_columns", "mime_type notnull"));
				passFlag |= (1 << 5);
			} else if ("constraint_name".equals(name)){
				assertTrue("TEXT".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_columns", "constraint_name type"));
				assertTrue(resultSet.getInt("notnull") == 0, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_columns", "constraint_name notnull"));
				passFlag |= (1 << 6);
			}
		} 
		assertTrue((passFlag & flagMask) == flagMask, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_columns", "missing column(s)"));
    }


    /**
     * Values of the gpkg_data_columns table table_name column value SHALL 
     * reference values in the gpkg_contents table_name column.
     * 
     * @see <a href="http://www.geopackage.org/spec/#r104" target=
     *      "_blank">F.9. Schema - Requirement 104</a>
     *
     * @throws SQLException
     *             If an SQL query causes an error
     */
    @Test(description = "See OGC 12-128r13: Requirement 104")
    public void dataColumnsTableName() throws SQLException
    {
    	// 1
		final Statement statement1 = this.databaseConnection.createStatement();

		final ResultSet resultSet1 = statement1.executeQuery("SELECT DISTINCT gdc.table_name AS gdc_table, gc.table_name AS gc_table FROM gpkg_data_columns AS gdc LEFT OUTER JOIN gpkg_contents AS gc ON gdc.table_name = gc.table_name;");

		// 2
		while (resultSet1.next()) {
			// 3
			final String gcTable = resultSet1.getString("gc_table");
			final String gdcTable = resultSet1.getString("gdc_table");

			// 3a
			assertTrue(gcTable != null, ErrorMessage.format(ErrorMessageKeys.INVALID_DATA_TABLE, "gpkg_data_columns", gdcTable));
		}
    }
    
    /**
     * The `column_name` column value in a `gpkg_data_columns` table row 
     * SHALL contain the name of a column in the SQLite table or view 
     * identified by the `table_name` column value.
     * 
     * @see <a href="http://www.geopackage.org/spec/#r105" target=
     *      "_blank">F.9. Schema - Requirement 105</a>
     *
     * @throws SQLException
     *             If an SQL query causes an error
     */
    @Test(description = "See OGC 12-128r13: Requirement 105")
    public void dataColumnsColumnName() throws SQLException
    {
    	// 1
		final Statement statement1 = this.databaseConnection.createStatement();

		final ResultSet resultSet1 = statement1.executeQuery("SELECT table_name, column_name FROM gpkg_data_columns;");

		// 2
		while (resultSet1.next()) {
			// 3
			final Statement statement2 = this.databaseConnection.createStatement();
			final String columnName = resultSet1.getString("column_name");
			final String tableName = resultSet1.getString("table_name");

			try {
				// 3bi
				statement2.executeQuery(String.format("SELECT COUNT(%s) from %s;", columnName, tableName));
			} catch (SQLException exc) {
				Assert.fail(ErrorMessage.format(ErrorMessageKeys.INVALID_DATA_COLUMN, "gpkg_extensions", columnName, tableName));
			}
		}
    }
    
    /**
     * A GeoPackage MAY contain a table or updateable view named 
     * gpkg_data_column_constraints. If present it SHALL be defined per 
     * clause 2.3.3.1.1 Table Definition, Data Column Constraints Table or 
     * View Definition and gpkg_data_columns Table Definition SQL.
     * 
     * @see <a href="http://www.geopackage.org/spec/#r107" target=
     *      "_blank">F.9. Schema - Requirement 107</a>
     *
     * @throws SQLException
     *             If an SQL query causes an error
     */
    @Test(description = "See OGC 12-128r13: Requirement 107")
    public void dataColumnConstraintsTableDefinition() throws SQLException
    {
		// 1
		final Statement statement = this.databaseConnection.createStatement();

		final ResultSet resultSet = statement.executeQuery("PRAGMA table_info('gpkg_data_column_constraints');");

		// 2
		int passFlag = 0;
		final int flagMask = 0b11111111;
		
		while (resultSet.next()) {
			// 3
			final String name = resultSet.getString("name");
			if ("constraint_name".equals(name)){
				assertTrue("TEXT".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_column_constraints", "constraint_name type"));
				assertTrue(resultSet.getInt("notnull") == 1, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_column_constraints", "constraint_name notnull"));
				passFlag |= 1;
			} else if ("constraint_type".equals(name)){
				assertTrue("TEXT".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_column_constraints", "constraint_type type"));
				assertTrue(resultSet.getInt("notnull") == 1, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_column_constraints", "constraint_type notnull"));
				passFlag |= (1 << 1);
			} else if ("value".equals(name)){
				assertTrue("TEXT".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_column_constraints", "value type"));

				// Huh? How can a unique value be allowed to be null?
				assertTrue(resultSet.getInt("notnull") == 0, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_column_constraints", "value notnull"));
				
				// unique constraint??
				passFlag |= (1 << 2);
			} else if ("min".equals(name)){
				assertTrue("NUMERIC".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_column_constraints", "min type"));
				assertTrue(resultSet.getInt("notnull") == 0, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_column_constraints", "min notnull"));
				passFlag |= (1 << 3);
			} else if ("min_is_inclusive".equals(name)){
				if (getGeopackageVersion().equals(GeoPackageVersion.V110) || getGeopackageVersion().equals(GeoPackageVersion.V120)){
					assertTrue("BOOLEAN".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_column_constraints", "min_is_inclusive type"));
					assertTrue(resultSet.getInt("notnull") == 0, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_column_constraints", "min_is_inclusive notnull"));
					passFlag |= (1 << 4);
				}
			} else if ("minIsInclusive".equals(name)){
				if (getGeopackageVersion().equals(GeoPackageVersion.V102)){
					assertTrue("BOOLEAN".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_column_constraints", "min_is_inclusive type"));
					assertTrue(resultSet.getInt("notnull") == 0, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_column_constraints", "min_is_inclusive notnull"));
					passFlag |= (1 << 4);
				}
			} else if ("max".equals(name)){
				assertTrue("NUMERIC".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_column_constraints", "max type"));
				assertTrue(resultSet.getInt("notnull") == 0, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_column_constraints", "max notnull"));
				passFlag |= (1 << 5);
			} else if ("max_is_inclusive".equals(name)){
				if (getGeopackageVersion().equals(GeoPackageVersion.V110) || getGeopackageVersion().equals(GeoPackageVersion.V120)){
					assertTrue("BOOLEAN".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_column_constraints", "max_is_inclusive type"));
					assertTrue(resultSet.getInt("notnull") == 0, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_column_constraints", "max_is_inclusive notnull"));
					passFlag |= (1 << 6);
				}
			} else if ("maxIsInclusive".equals(name)){
				if (getGeopackageVersion().equals(GeoPackageVersion.V102)){
					assertTrue("BOOLEAN".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_column_constraints", "max_is_inclusive type"));
					assertTrue(resultSet.getInt("notnull") == 0, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_column_constraints", "max_is_inclusive notnull"));
					passFlag |= (1 << 6);
				}
			} else if ("description".equals(name)){
				assertTrue("TEXT".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_column_constraints", "description type"));
				assertTrue(resultSet.getInt("notnull") == 0, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_column_constraints", "description notnull"));
				passFlag |= (1 << 7);
			}
		} 
		assertTrue((passFlag & flagMask) == flagMask, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_data_column_constraints", "missing column(s)"));
    }

    /**
     * The gpkg_data_column_constraints table MAY be empty. If it contains 
     * data, the lowercase constraint_type column values SHALL be one of 
     * "range", "enum", or "glob".
     * 
     * @see <a href="http://www.geopackage.org/spec/#r108" target=
     *      "_blank">F.9. Schema - Requirement 108</a>
     *
     * @throws SQLException
     *             If an SQL query causes an error
     */
    @Test(description = "See OGC 12-128r13: Requirement 108")
    public void dataColumnConstraintsType() throws SQLException
    {
    	// 1
		final Statement statement1 = this.databaseConnection.createStatement();

		final ResultSet resultSet1 = statement1.executeQuery("SELECT DISTINCT constraint_type FROM gpkg_data_column_constraints");
		
		// 2
		while (resultSet1.next()) {
			// 3
			final String constraintType = resultSet1.getString("constraint_type");

			Assert.assertTrue(AllowedConstraintTypes.contains(constraintType), 
					ErrorMessage.format(ErrorMessageKeys.UNEXPECTED_VALUE, constraintType, "constraint_type", "gpkg_data_column_constraints"));
		}
    }

    /**
     * gpkg_data_column_constraint constraint_name values for rows with 
     * constraint_type values of "range" and "glob" SHALL be unique.
     * 
     * @see <a href="http://www.geopackage.org/spec/#r109" target=
     *      "_blank">F.9. Schema - Requirement 109</a>
     *
     * @throws SQLException
     *             If an SQL query causes an error
     */
    @Test(description = "See OGC 12-128r13: Requirement 109")
    public void dataColumnConstraintsName() throws SQLException
    {
    	// 1
		final Statement statement1 = this.databaseConnection.createStatement();

		final ResultSet resultSet1 = statement1.executeQuery("SELECT DISTINCT constraint_name FROM gpkg_data_column_constraints WHERE constraint_type IN ('range', 'glob')");
		
		// 2
		while (resultSet1.next()) {
			// 3
			final String constraintName = resultSet1.getString("constraint_name");

			final Statement statement2 = this.databaseConnection.createStatement();

			final ResultSet resultSet2 = statement2.executeQuery(String.format("SELECT COUNT(*) FROM gpkg_data_column_constraints WHERE constraint_name = %s", constraintName));
			
			Assert.assertTrue(resultSet2.getInt("1") <= 1, 
					ErrorMessage.format(ErrorMessageKeys.NON_UNIQUE_VALUE, "constraint_name", "gpkg_data_column_constraints", constraintName));
		}
    }

    /**
     * The gpkg_data_column_constraints table MAY be empty. If it contains 
     * rows with constraint_type column values of "range", the value column 
     * values for those rows SHALL be NULL.
     * 
     * @see <a href="http://www.geopackage.org/spec/#r110" target=
     *      "_blank">F.9. Schema - Requirement 110</a>
     *
     * @throws SQLException
     *             If an SQL query causes an error
     */
    @Test(description = "See OGC 12-128r13: Requirement 110")
    public void dataColumnConstraintsValue() throws SQLException
    {
    	// 1
		final Statement statement1 = this.databaseConnection.createStatement();

		final ResultSet resultSet1 = statement1.executeQuery("SELECT constraint_name, value FROM gpkg_data_column_constraints WHERE constraint_type = 'range'");
		
		// 2
		while (resultSet1.next()) {
			// 3
			final String constraintName = resultSet1.getString("constraint_name");
			final String value = resultSet1.getString("value");

			Assert.assertTrue(value == null, 
					ErrorMessage.format(ErrorMessageKeys.CONSTRAINT_NON_NULL_VALUE, value, constraintName));
		}
    }
    static private List<String> AllowedConstraintTypes = Arrays.asList("range", "enum", "glob");

}
