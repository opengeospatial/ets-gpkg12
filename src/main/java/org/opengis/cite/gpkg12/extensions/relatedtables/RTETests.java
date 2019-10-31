package org.opengis.cite.gpkg12.extensions.relatedtables;

import static org.testng.Assert.assertTrue;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import org.opengis.cite.gpkg12.ErrorMessage;
import org.opengis.cite.gpkg12.ErrorMessageKeys;
import org.opengis.cite.gpkg12.util.DatabaseUtility;
import org.testng.Assert;
import org.testng.annotations.Test;

/**
 * Defines test methods that apply to descriptive information about a
 * GeoPackage's content as it pertains to the schema extension.
 *
 * <p style="margin-bottom: 0.5em">
 * <strong>Sources</strong>
 * </p>
 * <ul>
 * <li><a href="http://docs.opengeospatial.org/is/18-000/18-000.html" target= "_blank">
 * GeoPackage Related Tables Extension</a> (OGC 18-000)</li>
 * </ul>
 *
 * @author Jeff Yutzler
 */
public class RTETests extends RTEBase
{
    /**
     * A GeoPackage that contains a row in the gpkg_extensions table for 
     * gpkgext_relations as described in Extensions Table Record SHALL comply 
     * with the Related Tables Extension as described by this document.
     * 
     * @see <a href="http://docs.opengeospatial.org/is/18-000/18-000.html#r1" target=
     *      "_blank">OGC 18-000 Requirement 1</a> 
     */
    @Test(description = "See OGC 18-000: Requirement 1")
    public void extensionsTableEntries() throws SQLException
    {
		try (
				final Statement statement = this.databaseConnection.createStatement();
				
				final ResultSet resultSet = statement.executeQuery(
						"SELECT * FROM gpkg_extensions WHERE table_name = 'gpkgext_relations';");
				) {
			
			Assert.assertTrue(resultSet.next(), 
					ErrorMessage.format(ErrorMessageKeys.MISSING_REFERENCE, "gpkg_extensions", "table_name", "gpkgext_relations"));				
		}

		Assert.assertTrue(DatabaseUtility.doesTableOrViewExist(this.databaseConnection, "gpkgext_relations"), 
				ErrorMessage.format(ErrorMessageKeys.MISSING_TABLE, "gpkgext_relations"));				
	}
    
    /**
     * A GeoPackage that contains a row in the gpkg_extensions table for 
     * gpkgext_relations SHALL contain at least one related table relationship.
     * 
     * A GeoPackage that complies with the Related Tables Extension SHALL 
     * contain rows in the gpkg_extensions table for each User Defined Mapping 
     * Table as described in Extensions Table Record.
     * 
     * @see <a href="http://docs.opengeospatial.org/is/18-000/18-000.html#r2" target=
     *      "_blank">OGC 18-000 Requirement 2, 3</a> 
     */
    @Test(description = "See OGC 18-000: Requirement 2, 3")
    public void relationsTableEntries() throws SQLException
    {
		try (
				final Statement statement = this.databaseConnection.createStatement();
				
				final ResultSet resultSet = statement.executeQuery(
						"SELECT table_name, column_name, scope FROM gpkg_extensions WHERE (extension_name IN ('related_tables', 'gpkg_related_tables') AND table_name != 'gpkgext_relations');");
				) {
			boolean hasResults = false;
			while (resultSet.next()) {
				hasResults = true;
				final String tableName = resultSet.getString("table_name");
				Assert.assertTrue(DatabaseUtility.doesTableOrViewExist(this.databaseConnection, tableName), 
						ErrorMessage.format(ErrorMessageKeys.MISSING_TABLE, tableName));				
				Assert.assertNull(resultSet.getObject("column_name"),
						ErrorMessage.format(ErrorMessageKeys.UNEXPECTED_VALUE, "(not null)", "column_name", "gpkg_extensions"));
				final String scope = resultSet.getString("scope");
				Assert.assertEquals(scope, "read-write",
						ErrorMessage.format(ErrorMessageKeys.UNEXPECTED_VALUE, scope, "scope", "gpkg_extensions"));
			}
			
			Assert.assertTrue(hasResults, 
					ErrorMessage.format(ErrorMessageKeys.MISSING_REFERENCE, "gpkg_extensions", "table_name", "a mapping table"));				
		}
	}
    
    /**
     * A GeoPackage that complies with this extension SHALL contain a 
     * gpkgext_relations table as per Extended Relations Table Definition 
     * and Extended Relations Table Definition SQL (Normative).
     * 
     * @see <a href="http://docs.opengeospatial.org/is/18-000/18-000.html#r4" target=
     *      "_blank">OGC 18-000 Requirement 4</a> 
     */
    @Test(description = "See OGC 18-000: Requirement 4")
    public void relationsTableStructure() throws SQLException {

		try (
				final Statement statement = this.databaseConnection.createStatement();
				
				final ResultSet resultSet = statement.executeQuery(
						"PRAGMA table_info('gpkgext_relations');");
				) {

			int passFlag = 0;
    		final int flagMask = 0b01111111;
    		
    		while (resultSet.next()) {
    			// 3
    			final String name = resultSet.getString("name");
    			if ("id".equals(name)){
    				Assert.assertEquals(resultSet.getString("type"), "INTEGER", ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkgext_relations", "id type"));
    				Assert.assertEquals(resultSet.getInt("notnull"), 0, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkgext_relations", "id notnull"));
    				Assert.assertEquals(resultSet.getInt("pk"), 1, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkgext_relations", "id pk"));
    				passFlag |= 1;
    			} else if ("base_table_name".equals(name)){
    				Assert.assertEquals(resultSet.getString("type"), "TEXT", ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkgext_relations", "base_table_name type"));
    				Assert.assertEquals(resultSet.getInt("notnull"), 1, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkgext_relations", "base_table_name notnull"));
    				Assert.assertEquals(resultSet.getInt("pk"), 0, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkgext_relations", "base_table_name pk"));
    				passFlag |= (1 << 1);
    			} else if ("base_primary_column".equals(name)){
    				Assert.assertEquals(resultSet.getString("type"), "TEXT", ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkgext_relations", "base_primary_column type"));
    				Assert.assertEquals(resultSet.getInt("notnull"), 1, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkgext_relations", "base_primary_column notnull"));
    				Assert.assertEquals(resultSet.getInt("pk"), 0, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkgext_relations", "base_primary_column pk"));
    				passFlag |= (1 << 2);
    			} else if ("related_table_name".equals(name)){
    				Assert.assertEquals(resultSet.getString("type"), "TEXT", ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkgext_relations", "related_table_name type"));
    				Assert.assertEquals(resultSet.getInt("notnull"), 1, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkgext_relations", "related_table_name notnull"));
    				Assert.assertEquals(resultSet.getInt("pk"), 0, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkgext_relations", "related_table_name pk"));
    				passFlag |= (1 << 3);
    			} else if ("related_primary_column".equals(name)){
    				Assert.assertEquals(resultSet.getString("type"), "TEXT", ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkgext_relations", "related_primary_column type"));
    				Assert.assertEquals(resultSet.getInt("notnull"), 1, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkgext_relations", "related_primary_column notnull"));
    				Assert.assertEquals(resultSet.getInt("pk"), 0, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkgext_relations", "related_primary_column pk"));
    				passFlag |= (1 << 4);
    			} else if ("relation_name".equals(name)){
    				Assert.assertEquals(resultSet.getString("type"), "TEXT", ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkgext_relations", "relation_name type"));
    				Assert.assertEquals(resultSet.getInt("notnull"), 1, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkgext_relations", "relation_name notnull"));
    				Assert.assertEquals(resultSet.getInt("pk"), 0, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkgext_relations", "relation_name pk"));
    				passFlag |= (1 << 5);
    			} else if ("mapping_table_name".equals(name)){
    				Assert.assertEquals(resultSet.getString("type"), "TEXT", ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkgext_relations", "mapping_table_name type"));
    				Assert.assertEquals(resultSet.getInt("notnull"), 1, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkgext_relations", "mapping_table_name notnull"));
    				Assert.assertEquals(resultSet.getInt("pk"), 0, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkgext_relations", "mapping_table_name pk"));
    				passFlag |= (1 << 6);
    			}
    		} 
    		assertTrue((passFlag & flagMask) == flagMask, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, "gpkgext_relations", String.format("missing column(s): code(%s)", passFlag)));
		}
    }
    
    /**
     * For each row in gpkgext_relations, there SHALL be a table or view of 
     * the name referenced in base_table_name and that table or view SHALL 
     * have an entry in gpkg_contents.
     *
     * For each row in gpkgext_relations, there SHALL be a table or view of 
     * the name referenced in related_table_name and that table or view SHALL 
     * have an entry in gpkg_contents.
     * 
     * For each row in gpkgext_relations, the mapping_table_name column SHALL 
     * contain the name of a user-defined mapping table or view as described 
     * by User-Defined Mapping Tables.
     * 
     * Each relation_name column in a gpkgext_relations row SHALL either match a relation_name from the Requirements Classes for User-Defined Related Data Tables in this or other OGC standards (e.g. media for [Media Requirement Class]), or be of the form x-<author>_<relation_name> where <author> indicates the person or organization that developed and maintains this set of User-Defined Related Tables.
     * 
     * @see <a href="http://docs.opengeospatial.org/is/18-000/18-000.html#r5" target=
     *      "_blank">OGC 18-000 Requirement 5, 6, 7</a> 
     */
    @Test(description = "See OGC 18-000: Requirement 5, 6, 7")
    public void relationsTableValues() throws SQLException {
		try (
				final Statement statement = this.databaseConnection.createStatement();
				
				final ResultSet resultSet = statement.executeQuery(
						"SELECT base_table_name, related_table_name, mapping_table_name FROM gpkgext_relations;");
				) {
			boolean hasResults = false;
			while (resultSet.next()) {
				hasResults = true;
				final String baseTableName = resultSet.getString("base_table_name");
				Assert.assertTrue(DatabaseUtility.doesTableOrViewExist(this.databaseConnection, baseTableName), 
						ErrorMessage.format(ErrorMessageKeys.MISSING_TABLE, baseTableName));
				try (
					final Statement statement2 = this.databaseConnection.createStatement();
					final ResultSet resultSet2 = statement2.executeQuery(
						String.format("SELECT table_name FROM gpkg_contents WHERE table_name = '%s'", baseTableName));

						) {
					Assert.assertTrue(resultSet2.next(), 
							ErrorMessage.format(ErrorMessageKeys.MISSING_REFERENCE, "gpkg_contents", "table_name", baseTableName));				
				}
				final String relatedTableName = resultSet.getString("related_table_name");
				Assert.assertTrue(DatabaseUtility.doesTableOrViewExist(this.databaseConnection, relatedTableName), 
						ErrorMessage.format(ErrorMessageKeys.MISSING_TABLE, relatedTableName));
				try (
					final Statement statement2 = this.databaseConnection.createStatement();
					final ResultSet resultSet3 = statement2.executeQuery(
							String.format("SELECT table_name FROM gpkg_contents WHERE table_name = '%s'", relatedTableName));
						) {
					Assert.assertTrue(resultSet3.next(), 
							ErrorMessage.format(ErrorMessageKeys.MISSING_REFERENCE, "gpkg_contents", "table_name", relatedTableName));				
				}
				final String mappingTableName = resultSet.getString("mapping_table_name");
				Assert.assertTrue(DatabaseUtility.doesTableOrViewExist(this.databaseConnection, mappingTableName), 
						ErrorMessage.format(ErrorMessageKeys.MISSING_TABLE, mappingTableName));
			}
			Assert.assertTrue(hasResults, 
					ErrorMessage.format(ErrorMessageKeys.MISSING_ROW, "gpkgext_relations"));				
		}
    }
    
    /**
     * Each relation_name column in a gpkgext_relations row SHALL either 
     * match a relation_name from the Requirements Classes for User-Defined 
     * Related Data Tables in this or other OGC standards (e.g. media for 
     * [Media Requirement Class]), or be of the form 
     * x-<author>_<relation_name> where <author> indicates the person or 
     * organization that developed and maintains this set of User-Defined 
     * Related Tables.
     * 
     * @see <a href="http://docs.opengeospatial.org/is/18-000/18-000.html#r8" target=
     *      "_blank">OGC 18-000 Requirement 8</a> 
     */
    @Test(description = "See OGC 18-000: Requirement 8")
    public void relationName() throws SQLException {
		final String query = "SELECT base_table_name, relation_name FROM gpkgext_relations WHERE (relation_name NOT IN ('features', 'simple_attributes', 'media', 'attributes', 'tiles') AND relation_name NOT LIKE 'x-%\\_%' ESCAPE '\\');";
		try (
				final Statement statement = this.databaseConnection.createStatement();
				final ResultSet resultSet = statement.executeQuery(query);
				) {	
			if (resultSet.next()) {
				Assert.fail(ErrorMessage.format(ErrorMessageKeys.UNEXPECTED_VALUE, resultSet.getString("relation_name"), "relation_name", "gpkgext_relations"));
			}
		}
	}
    
    /**
     * A user-defined mapping table or view SHALL contain all of the columns 
     * described in User-Defined Mapping Table Definition.
     * 
     * @see <a href="http://docs.opengeospatial.org/is/18-000/18-000.html#r9" target=
     *      "_blank">OGC 18-000 Requirement 9</a> 
     */
    @Test(description = "See OGC 18-000: Requirement 9")
    public void udmtTableStructure() throws SQLException {
    	
		try (
				final Statement statement = this.databaseConnection.createStatement();
				
				final ResultSet resultSet = statement.executeQuery(
						"SELECT mapping_table_name FROM gpkgext_relations;");
				) {
			boolean hasResults = false;
			
			while (resultSet.next()) {
				hasResults = true;
				int passFlag = 0;
	    		final int flagMask = 0b00000011;
	    		
	    		final String mappingTableName = resultSet.getString("mapping_table_name");
	    		try (
	    				final Statement statement2 = this.databaseConnection.createStatement();
	    				
	    				final ResultSet resultSet2 = statement2.executeQuery(
	    						String.format("PRAGMA table_info(%s)", mappingTableName));
	    				) {
		    		while (resultSet2.next()) {
		    			// 3
		    			final String name = resultSet2.getString("name");
		    			if ("base_id".equals(name)){
		    				Assert.assertEquals(resultSet2.getString("type"), "INTEGER", ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, mappingTableName, "base_id type"));
		    				Assert.assertEquals(resultSet2.getInt("notnull"), 1, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, mappingTableName, "base_id notnull"));
		    				Assert.assertEquals(resultSet2.getInt("pk"), 0, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, mappingTableName, "base_id pk"));
		    				passFlag |= 1;
		    			} else if ("related_id".equals(name)){
		    				Assert.assertEquals(resultSet2.getString("type"), "INTEGER", ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, mappingTableName, "related_id type"));
		    				Assert.assertEquals(resultSet2.getInt("notnull"), 1, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, mappingTableName, "related_id notnull"));
		    				Assert.assertEquals(resultSet2.getInt("pk"), 0, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, mappingTableName, "related_id pk"));
		    				passFlag |= (1 << 1);
		    			}
		    		} 
		    		assertTrue((passFlag & flagMask) == flagMask, ErrorMessage.format(ErrorMessageKeys.TABLE_DEFINITION_INVALID, mappingTableName, String.format("missing column(s): code(%s)", passFlag)));
	    		}
			}
			Assert.assertTrue(hasResults, 
					ErrorMessage.format(ErrorMessageKeys.MISSING_ROW, "gpkgext_relations"));				
		}
    }
    
    /**
     * For each row of a user-defined mapping table, the base_id column SHALL 
     * correlate to the primary key of the corresponding base table (as 
     * identified by the base_primary_column of the associated row in 
     * gpkgext_relations).
     * 
     * @see <a href="http://docs.opengeospatial.org/is/18-000/18-000.html#r10" target=
     *      "_blank">OGC 18-000 Requirement 10</a> 
     */
    @Test(description = "See OGC 18-000: Requirement 10")
    public void udmtBaseIDs() throws SQLException {
		try (
				final Statement statement = this.databaseConnection.createStatement();
				
				final ResultSet resultSet = statement.executeQuery(
						"SELECT base_table_name, base_primary_column, mapping_table_name FROM gpkgext_relations;");
				) {
			while (resultSet.next()) {
				final String baseTableName = resultSet.getString("base_table_name");
				final String basePrimaryColumn = resultSet.getString("base_primary_column");
				final String mappingTableName = resultSet.getString("mapping_table_name");
				
				try (
						final Statement statement2 = this.databaseConnection.createStatement();
						
						final ResultSet resultSet2 = statement2.executeQuery(
								String.format("SELECT mapping_id FROM (SELECT a.base_id AS mapping_id, b.%s AS base_id FROM %s a LEFT OUTER JOIN %s b ON a.base_id = b.%s) WHERE base_id IS NULL;", 
										basePrimaryColumn, mappingTableName, baseTableName, basePrimaryColumn));
						) {
					if (resultSet2.next()) {
						Assert.fail(ErrorMessage.format(ErrorMessageKeys.MISSING_REFERENCE, 
								baseTableName, 
								basePrimaryColumn, 
								String.format("%s from the base_id column of %s", resultSet2.getInt("mapping_id"), mappingTableName)));
					}
				}
			}
		}
    }
    
    /**
     * For each row of a user-defined mapping table, the related_id column 
     * SHALL correlate to the primary key of the corresponding related data 
     * table (as identified by the related_primary_column of the associated 
     * row in gpkgext_relations).
     * 
     * @see <a href="http://docs.opengeospatial.org/is/18-000/18-000.html#r11" target=
     *      "_blank">OGC 18-000 Requirement 11</a> 
     */
    @Test(description = "See OGC 18-000: Requirement 11")
    public void udmtRelatedIDs() throws SQLException {
		try (
				final Statement statement = this.databaseConnection.createStatement();
				
				final ResultSet resultSet = statement.executeQuery(
						"SELECT related_table_name, related_primary_column, mapping_table_name FROM gpkgext_relations;");
				) {
			while (resultSet.next()) {
				final String relatedTableName = resultSet.getString("related_table_name");
				final String relatedPrimaryColumn = resultSet.getString("related_primary_column");
				final String mappingTableName = resultSet.getString("mapping_table_name");
				
				try (
						final Statement statement2 = this.databaseConnection.createStatement();
						
						final ResultSet resultSet2 = statement2.executeQuery(
								String.format("SELECT mapping_id FROM (SELECT a.related_id AS mapping_id, b.%s AS related_id FROM %s a LEFT OUTER JOIN %s b ON a.related_id = b.%s) WHERE related_id IS NULL;", 
										relatedPrimaryColumn, mappingTableName, relatedTableName, relatedPrimaryColumn));
						) {
					if (resultSet2.next()) {
						Assert.fail(ErrorMessage.format(ErrorMessageKeys.MISSING_REFERENCE, 
								relatedTableName, 
								relatedPrimaryColumn, 
								String.format("%s from the related_id column of %s", resultSet2.getInt("mapping_id"), mappingTableName)));
					}
				}
			}
		}
    }
}
