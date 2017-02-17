package org.opengis.cite.gpkg12.extensions.elevation;

import static org.testng.Assert.assertTrue;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collection;

import org.opengis.cite.gpkg12.CommonFixture;
import org.opengis.cite.gpkg12.ErrorMessage;
import org.opengis.cite.gpkg12.ErrorMessageKeys;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;

/**
 * Defines test methods that apply to descriptive information about a
 * GeoPackage's content as it pertains to tiled, gridded elevation data.
 *
 * <p style="margin-bottom: 0.5em">
 * <strong>Sources</strong>
 * </p>
 * <ul>
 * <li><a href="http://www.geopackage.org/spec/#features" target= "_blank">
 * GeoPackage Encoding Standard - Annex F.11 Elevation</a> (OGC 12-128r13)</li>
 * </ul>
 *
 * @author Jeff Yutzler
 */
public class ElevationTests extends CommonFixture {
	/**
	 * Sets up variables used across methods
	 *
	 * @throws SQLException
	 *             if there is a database error
	 */
	@BeforeClass
	public void setUp() throws SQLException {
		
		final Statement statement1 = this.databaseConnection.createStatement();
		ResultSet resultSet1 = statement1.executeQuery("SELECT COUNT(*) FROM gpkg_extensions WHERE table_name = 'gpkg_2d_gridded_coverage_ancillary';");
		resultSet1.next();
		hasExtension = resultSet1.getInt(1) > 0;
		
		if (!hasExtension){
			return;
		}
		
		final Statement statement2 = this.databaseConnection.createStatement();
		ResultSet resultSet2 = statement2.executeQuery("SELECT table_name FROM gpkg_contents WHERE data_type = '2d-gridded-coverage';");
		while (resultSet2.next()) {
			this.elevationTableNames.add(resultSet2.getString("table_name"));
		}
	}
	
	/**
	 * Test case
	 * {@code /opt/extensions/elevation/table/coverage_ancillary}
	 *
	 * @see <a href="requirement_feature_integer_pk" target= "_blank">Elevation 
	 * Extension - Requirement 105</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 105")
	public void coverageAncillaryTableDefinition() throws SQLException {
		
		if (!hasExtension){
			return;
		}
		
		// 1
		final Statement statement = this.databaseConnection.createStatement();

		final ResultSet resultSet = statement.executeQuery("PRAGMA table_info('gpkg_2d_gridded_coverage_ancillary');");

		// 2
		int passFlag = 0;
		final int flagMask = 0b01111111;
		
		while (resultSet.next()) {
			// 3
			final String name = resultSet.getString("name");
			if ("id".equals(name)){
				assertTrue("INTEGER".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "id type"));
//				assertTrue(resultSet.getInt("notnull") == 1, ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID), "id notnull");
				assertTrue(resultSet.getInt("pk") == 1, ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "id pk"));
				passFlag |= 1;
			} else if ("tile_matrix_set_name".equals(name)){
				assertTrue("TEXT".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "tile_matrix_set_name type"));
				assertTrue(resultSet.getInt("notnull") == 1, ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "tile_matrix_set_name notnull"));
				assertTrue(resultSet.getInt("pk") == 0, ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "tile_matrix_set_name pk"));
				passFlag |= (1 << 1);
			} else if ("datatype".equals(name)){
				assertTrue("TEXT".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "datatype type"));
				assertTrue(resultSet.getInt("notnull") == 1, ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "datatype notnull"));
				assertTrue(resultSet.getInt("pk") == 0, ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "datatype pk"));
//				assertTrue(resultSet.getString("dflt_value") == "integer", ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "datatype default"));
				passFlag |= (1 << 2);
			} else if ("scale".equals(name)){
				assertTrue("REAL".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "scale type"));
				assertTrue(resultSet.getInt("notnull") == 0, ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "scale notnull"));
				assertTrue(resultSet.getInt("pk") == 0, ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "scale pk"));
				assertTrue(resultSet.getFloat("dflt_value") == 1.0, ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "scale default"));
				passFlag |= (1 << 3);
			} else if ("offset".equals(name)){
				assertTrue("REAL".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "offset type"));
				assertTrue(resultSet.getInt("notnull") == 0, ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "offset notnull"));
				assertTrue(resultSet.getInt("pk") == 0, ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "offset pk"));
				assertTrue(resultSet.getFloat("dflt_value") == 0, ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "offset default"));
				passFlag |= (1 << 4);
			} else if ("precision".equals(name)){
				assertTrue("REAL".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "precision type"));
				assertTrue(resultSet.getInt("notnull") == 0, ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "precision type"));
				assertTrue(resultSet.getInt("pk") == 0, ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "precision pk"));
				assertTrue(resultSet.getFloat("dflt_value") == 1.0, ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "precision default"));
				passFlag |= (1 << 5);
			} else if ("data_null".equals(name)){
				assertTrue("REAL".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "data_null type"));
				assertTrue(resultSet.getInt("notnull") == 0, ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "data_null notnull"));
				assertTrue(resultSet.getInt("pk") == 0, ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "data_null pk"));
				passFlag |= (1 << 6);
			}
		} 
		assertTrue((passFlag & flagMask) == flagMask, ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID);
	}

	/**
	 * Test case
	 * {@code /opt/extensions/elevation/table/coverage_ancillary_fk}
	 *
	 * @see <a href="requirement_feature_integer_pk" target= "_blank">Elevation 
	 * Extension - Requirement 105</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 105")
	public void coverageAncillaryTableForeignKey() throws SQLException {
		// 1
		final Statement statement = this.databaseConnection.createStatement();

		final ResultSet resultSet = statement.executeQuery("PRAGMA foreign_key_list('gpkg_2d_gridded_coverage_ancillary');");
		
		boolean foundFK = false;

		// 2
		while (resultSet.next()){
			// 3
			final String table = resultSet.getString("table");
			if ("gpkg_tile_matrix_set".equals(table)){
				if ("tile_matrix_set_name".equals(resultSet.getString("from")) && "table_name".equals(resultSet.getString("to"))){
					foundFK = true;
				}
			}
		}
		assertTrue(foundFK, ErrorMessageKeys.COVERAGE_ANCILLARY_NO_FK);
	}

//	/**
//	 * Test case
//	 * {@code /opt/extensions/elevation/table/coverage_ancillary}
//	 *
//	 * @see <a href="requirement_feature_integer_pk" target= "_blank">Elevation 
//	 * Extension - Requirement 105</a>
//	 *
//	 * @throws SQLException
//	 *             If an SQL query causes an error
//	 */
//	@Test(description = "See OGC 12-128r13: Requirement 105")
//	public void featureTableIntegerPrimaryKey() throws SQLException {
//		for (final String tableName : this.elevationTableNames) {
//		}
//	}

	private boolean hasExtension = false;
	private final Collection<String> elevationTableNames = new ArrayList<>();
}
