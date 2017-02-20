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
	
	/**
	 * Test case
	 * {@code /opt/extensions/elevation/table/tile_ancillary}
	 *
	 * @see <a href="requirement_tile_ancillary" target= "_blank">Elevation 
	 * Extension - Requirement 106</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 106")
	public void tileAncillaryTableDefinition() throws SQLException {
		
		if (!hasExtension){
			return;
		}
		
		// 1
		final Statement statement = this.databaseConnection.createStatement();

		final ResultSet resultSet = statement.executeQuery("PRAGMA table_info('gpkg_2d_gridded_tile_ancillary');");

		// 2
		long passFlag = 0;
		final long flagMask = 0b111111111;
		
		while (resultSet.next()) {
			// 3
			final String name = resultSet.getString("name");
			if ("id".equals(name)){
				assertTrue("INTEGER".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "id type"));
//				assertTrue(resultSet.getInt("notnull") == 1, ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID), "id notnull");
				assertTrue(resultSet.getInt("pk") == 1, ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "id pk"));
				passFlag |= 1;
			} else if ("tpudt_name".equals(name)){
				assertTrue("TEXT".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "tpudt_name type"));
				assertTrue(resultSet.getInt("notnull") == 1, ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "tpudt_name notnull"));
				assertTrue(resultSet.getInt("pk") == 0, ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "tpudt_name pk"));
				passFlag |= (1 << 1);
			} else if ("tpudt_id".equals(name)){
				assertTrue("INTEGER".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "tpudt_id type"));
				assertTrue(resultSet.getInt("notnull") == 1, ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "tpudt_id notnull"));
				assertTrue(resultSet.getInt("pk") == 0, ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "tpudt_id pk"));
				passFlag |= (1 << 2);
			} else if ("scale".equals(name)){
				assertTrue("REAL".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "scale type"));
				assertTrue(resultSet.getInt("notnull") == 0, ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "scale notnull"));
				assertTrue(resultSet.getInt("pk") == 0, ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "scale pk"));
				assertTrue(resultSet.getFloat("dflt_value") == 1.0, ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "scale default"));
				passFlag |= (1 << 3);
			} else if ("offset".equals(name)){
				assertTrue("REAL".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "offset type"));
				assertTrue(resultSet.getInt("notnull") == 0, ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "offset notnull"));
				assertTrue(resultSet.getInt("pk") == 0, ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "offset pk"));
				assertTrue(resultSet.getFloat("dflt_value") == 0, ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "offset default"));
				passFlag |= (1 << 4);
			} else if ("min".equals(name)){
				assertTrue("REAL".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "precision type"));
				assertTrue(resultSet.getInt("notnull") == 0, ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "precision type"));
				assertTrue(resultSet.getInt("pk") == 0, ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "precision pk"));
				passFlag |= (1 << 5);
			} else if ("max".equals(name)){
				assertTrue("REAL".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "data_null type"));
				assertTrue(resultSet.getInt("notnull") == 0, ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "data_null notnull"));
				assertTrue(resultSet.getInt("pk") == 0, ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "data_null pk"));
				passFlag |= (1 << 6);
			} else if ("mean".equals(name)){
				assertTrue("REAL".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "mean type"));
				assertTrue(resultSet.getInt("notnull") == 0, ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "mean type"));
				assertTrue(resultSet.getInt("pk") == 0, ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "mean pk"));
				passFlag |= (1 << 7);
			} else if ("std_dev".equals(name)){
				assertTrue("REAL".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "std_dev type"));
				assertTrue(resultSet.getInt("notnull") == 0, ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "std_dev notnull"));
				assertTrue(resultSet.getInt("pk") == 0, ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "std_dev pk"));
				passFlag |= (1 << 8);
			}
		} 
		assertTrue((passFlag & flagMask) == flagMask, ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, String.format("Missing column flag %d", passFlag)));
	}

	/**
	 * Test case
	 * {@code /opt/extensions/elevation/table/tile_ancillary_fk}
	 *
	 * @see <a href="requirement_feature_integer_pk" target= "_blank">Elevation 
	 * Extension - Requirement 106</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 106")
	public void tileAncillaryTableForeignKey() throws SQLException {
		// 1
		final Statement statement = this.databaseConnection.createStatement();

		final ResultSet resultSet = statement.executeQuery("PRAGMA foreign_key_list('gpkg_2d_gridded_tile_ancillary');");
		
		boolean foundFK = false;

		// 2
		while (resultSet.next()){
			// 3
			final String table = resultSet.getString("table");
			if ("gpkg_contents".equals(table)){
				if ("tpudt_name".equals(resultSet.getString("from")) && "table_name".equals(resultSet.getString("to"))){
					foundFK = true;
				}
			}
		}
		assertTrue(foundFK, ErrorMessageKeys.COVERAGE_ANCILLARY_NO_FK);
	}

	/**
	 * Test case
	 * {@code /opt/extensions/elevation/srs/required_rows}
	 *
	 * @see <a href="requirement_feature_integer_pk" target= "_blank">Elevation 
	 * Extension - Requirement 107</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 107")
	public void requiredSRSRows() throws SQLException {
		final Statement statement = this.databaseConnection.createStatement();
        final ResultSet srsDefaultValue = statement.executeQuery(
                "SELECT srs_id FROM gpkg_spatial_ref_sys WHERE organization_coordsys_id = 4979 AND (organization = 'EPSG' OR organization = 'epsg');");
    	assertTrue(srsDefaultValue.next(), ErrorMessage.format(ErrorMessageKeys.NO_ELEVATION_SRS));
    }

	/**
	 * Test case
	 * {@code /opt/extensions/elevation/srs/required_references}
	 *
	 * @see <a href="requirement_feature_integer_pk" target= "_blank">Elevation 
	 * Extension - Requirement 108, 109</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 108, 109")
	public void requiredSRSReferences() throws SQLException {
		
		for (final String tableName : this.elevationTableNames) {
			final Statement statement1 = this.databaseConnection.createStatement();
			final ResultSet resultSet1 = statement1.executeQuery(String.format("SELECT srs_id FROM gpkg_tile_matrix_set WHERE table_name = '%s'", tableName));
			resultSet1.next();
			final String srsID = resultSet1.getString(1);
			final Statement statement2 = this.databaseConnection.createStatement();
			final ResultSet resultSet2 = statement2.executeQuery(String.format("SELECT srs_name FROM gpkg_spatial_ref_sys WHERE srs_id = '%s'", srsID));
			assertTrue(resultSet2.next(), ErrorMessage.format(ErrorMessageKeys.BAD_MATRIX_SET_SRS_REFERENCE, srsID));
		}
    }
	
	/**
	 * Test case
	 * {@code /opt/extensions/elevation/extension_rows}
	 *
	 * @see <a href="requirement_tile_ancillary" target= "_blank">Elevation 
	 * Extension - Requirement 110</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 110")
	public void extensionTableRows() throws SQLException {
		
		if (!hasExtension){
			return;
		}
		
		// 1
		final Statement statement = this.databaseConnection.createStatement();

		final ResultSet resultSet = statement.executeQuery("SELECT table_name, column_name, extension_name, definition, scope from gpkg_extensions");

		// 2
		long passFlag = 0;
		final long flagMask = 0b11;
		
		while (resultSet.next()) {
			// 3
			final String name = resultSet.getString("table_name");
			if ("gpkg_2d_gridded_coverage_ancillary".equals(name)){
				if ((resultSet.getObject("column_name") == null) &&
					"gpkg_elevation_tiles".equals(resultSet.getString("extension_name")) &&
					"http://www.geopackage.org/spec/#extension_tiled_gridded_elevation_data".equals(resultSet.getString("definition")) && 
					"read-write".equals(resultSet.getString("scope"))){
					passFlag |= 1;
				}
			} else if ("gpkg_2d_gridded_tile_ancillary".equals(name)){
				if ((resultSet.getObject("column_name") == null) &&
					"gpkg_elevation_tiles".equals(resultSet.getString("extension_name")) &&
					"http://www.geopackage.org/spec/#extension_tiled_gridded_elevation_data".equals(resultSet.getString("definition")) && 
					"read-write".equals(resultSet.getString("scope"))){
					passFlag |= (1 << 1);
				}
			}
		} 
		assertTrue((passFlag & flagMask) == flagMask, ErrorMessage.format(ErrorMessageKeys.ELEVATION_EXTENSION_ROWS_MISSING, String.format("Missing column flag %d", passFlag)));

		for (final String tableName : this.elevationTableNames) {
			final Statement statement1 = this.databaseConnection.createStatement();
			final ResultSet resultSet1 = statement1.executeQuery(String.format("SELECT column_name, extension_name, definition, scope from gpkg_extensions WHERE table_name = '%s'", tableName));
			resultSet1.next();
			assertTrue(/*(resultSet1.getObject("column_name") == null) && */
					"gpkg_elevation_tiles".equals(resultSet1.getString("extension_name")) &&
					"http://www.geopackage.org/spec/#extension_tiled_gridded_elevation_data".equals(resultSet1.getString("definition")) && 
					"read-write".equals(resultSet1.getString("scope")), ErrorMessageKeys.ELEVATION_EXTENSION_ROWS_MISSING);
		}
	
	}

	private boolean hasExtension = false;
	private final Collection<String> elevationTableNames = new ArrayList<>();
}
