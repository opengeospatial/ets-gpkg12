package org.opengis.cite.gpkg12.extensions;

import static org.testng.Assert.assertTrue;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

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
 * GeoPackage's content as it pertains to the metadata extension.
 *
 * <p style="margin-bottom: 0.5em">
 * <strong>Sources</strong>
 * </p>
 * <ul>
 * <li><a href="http://www.geopackage.org/spec/#_extension_mechanism" target= "_blank">
 * GeoPackage Encoding Standard - 2.3 Extension Mechanism</a> (OGC 12-128r13)</li>
 * </ul>
 *
 * @author Jeff Yutzler
 */
public class ExtensionsTests extends CommonFixture
{
	@BeforeClass
	public void validateTableExists(ITestContext testContext) throws SQLException {
		Assert.assertTrue(DatabaseUtility.doesTableOrViewExist(this.databaseConnection, "gpkg_extensions"), 
				ErrorMessage.format(ErrorMessageKeys.CONFORMANCE_CLASS_NOT_USED, "Extensions"));
	}


	/**
	 * A GeoPackage MAY contain a table or updateable view named 
	 * gpkg_extensions. If present this table SHALL be defined per clause 
	 * 2.3.2.1.1 Table Definition, GeoPackage Extensions Table or View 
	 * Definition (Table or View Name: gpkg_extensions) and gpkg_extensions 
	 * Table Definition SQL. An extension SHALL NOT modify the definition or 
	 * semantics of existing columns. An extension MAY define additional tables 
	 * or columns. An extension MAY allow new values or encodings for existing 
	 * columns.
	 *
	 * @see <a href="http://www.geopackage.org/spec/#_r58" target=
	 *      "_blank">2.3.2.1.1. Extensions Table Definition - Requirement 58</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 58")
	public void extensionsTableDefinition() throws SQLException
	{
		try (		// 1
				final Statement statement = this.databaseConnection.createStatement();

				final ResultSet resultSet = statement.executeQuery("PRAGMA table_info('gpkg_extensions');");
				) {
			// 2
			int passFlag = 0;
			final int flagMask = 0b00011111;

			while (resultSet.next()) {
				// 3
				final String name = resultSet.getString("name");
				if ("table_name".equals(name)){
					assertTrue("TEXT".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_extensions", "table_name type"));
					assertTrue(resultSet.getInt("notnull") == 0, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_extensions", "table_name notnull"));
					passFlag |= 1;
				} else if ("column_name".equals(name)){
					assertTrue("TEXT".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_extensions", "column_name type"));
					assertTrue(resultSet.getInt("notnull") == 0, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_extensions", "column_name notnull"));
					passFlag |= (1 << 1);
				} else if ("extension_name".equals(name)){
					assertTrue("TEXT".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_extensions", "extension_name type"));
					assertTrue(resultSet.getInt("notnull") == 1, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_extensions", "extension_name notnull"));
					passFlag |= (1 << 2);
				} else if ("definition".equals(name)){
					assertTrue("TEXT".equals(resultSet.getString("type")), "definition type");
					assertTrue(resultSet.getInt("notnull") == 1, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_extensions", "definition notnull"));
					passFlag |= (1 << 3);
				} else if ("scope".equals(name)){
					assertTrue("TEXT".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_extensions", "scope type"));
					assertTrue(resultSet.getInt("notnull") == 1, "scope notnull");
					passFlag |= (1 << 4);
				}
			} 
			assertTrue((passFlag & flagMask) == flagMask, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkg_extensions", "missing column(s)"));
		}

	}

	/**
	 * Values of the `gpkg_extensions` `table_name` column SHALL reference 
	 * values in the `gpkg_contents` `table_name` column or be NULL.They 
	 * SHALL NOT be NULL for rows where the `column_name` value is not NULL.
	 *
	 * /opt/extension_mechanism/extensions/data/data_values_table_name
	 * 
	 * @see <a href="http://www.geopackage.org/spec/#r60" target=
	 *      "_blank">2.3.2.1.2. Extensions Table Data Values - Requirement 60</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 60")
	public void extensionsTableValues() throws SQLException
	{
		try (		// 1
				final Statement statement = this.databaseConnection.createStatement();

				final ResultSet resultSet = statement.executeQuery("SELECT lower(table_name) AS table_name, column_name FROM gpkg_extensions;");
				) {
			// 2
			while (resultSet.next()) {
				// 3a
				final String tableName = resultSet.getString("table_name");
				final String columnName = resultSet.getString("column_name");

				// 3b
				assertTrue(!((columnName != null) && (tableName == null)), ErrorMessage.format(ErrorMessageKeys.INVALID_DATA_COLUMN, "gpkg_extensions", tableName, columnName));
			}
		}

		try (
				// 4
				final Statement statement2 = this.databaseConnection.createStatement();

				final ResultSet resultSet2 = statement2.executeQuery("SELECT DISTINCT lower(ge.table_name) AS ge_table, lower(sm.tbl_name) AS tbl_name FROM gpkg_extensions AS ge LEFT OUTER JOIN sqlite_master AS sm ON lower(ge.table_name) = lower(sm.tbl_name);");
				) {
			while (resultSet2.next()) {
				// 4a
				final String geTable = resultSet2.getString("ge_table");
				final String tableName = resultSet2.getString("tbl_name");
				assertTrue(((geTable == null) && (tableName == null)) || ((tableName != null) && tableName.equals(geTable)), ErrorMessage.format(ErrorMessageKeys.INVALID_DATA_TABLE, "gpkg_extensions", geTable));
			}
		}
	}   

	/**
	 * The `column_name` column value in a `gpkg_extensions` row SHALL be the 
	 * name of a column in the table specified by the `table_name` column 
	 * value for that row, or be NULL.
	 *
	 * /opt/extension_mechanism/extensions/data/data_values_column_name
	 * 
	 * @see <a href="http://www.geopackage.org/spec/#r61" target=
	 *      "_blank">2.3.2.1.2. Extensions Table Data Values - Requirement 61</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 61")
	public void extensionsColumnValues() throws SQLException
	{
		try (		
				// 1
				final Statement statement = this.databaseConnection.createStatement();

				final ResultSet resultSet = statement.executeQuery("SELECT lower(table_name) AS table_name, lower(column_name) AS column_name FROM gpkg_extensions WHERE column_name IS NOT NULL;");
				) {
			// 2
			while (resultSet.next()) {
				// 3a
				final String tableName = resultSet.getString("table_name");
				final String columnName = resultSet.getString("column_name");

				// 3b
				try (final Statement statement1 = this.databaseConnection.createStatement()) {
					// 3bi
					statement1.executeQuery(String.format("SELECT COUNT(%s) from %s;", columnName, tableName));
				} catch (SQLException exc) {
					Assert.fail(ErrorMessage.format(ErrorMessageKeys.INVALID_DATA_COLUMN, "gpkg_extensions", columnName, tableName));
				}
			}
		}
	}  

	/**
	 * The scope column value in a gpkg_extensions row SHALL be lowercase 
	 * "read-write" for an extension that affects both readers and writers, 
	 * or "write-only" for an extension that affects only writers.
	 *
	 * /opt/extension_mechanism/extensions/data/data_values_scope
	 * 
	 * @see <a href="http://www.geopackage.org/spec/#r64" target=
	 *      "_blank">2.3.2.1.2. Extensions Table Data Values - Requirement 64</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 64")
	public void extensionsColumnScope() throws SQLException
	{
		try (
				// 1
				final Statement statement = this.databaseConnection.createStatement();

				final ResultSet resultSet = statement.executeQuery("SELECT scope FROM gpkg_extensions;");
				) {
			// 2
			while (resultSet.next()) {
				// 3
				final String scope = resultSet.getString("scope");

				assertTrue("read-write".equals(scope) || "write-only".equals(scope), ErrorMessage.format(ErrorMessageKeys.INVALID_EXTENSION_DATA_SCOPE, scope));
			}
		}
	}  
}
