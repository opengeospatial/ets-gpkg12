package org.opengis.cite.gpkg12.extensions.elevation;

import static org.testng.Assert.assertTrue;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collection;
import java.util.LinkedList;
import java.util.Spliterator;
import java.util.Spliterators;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

import javax.imageio.ImageIO;
import javax.imageio.ImageReader;
import javax.imageio.stream.MemoryCacheImageInputStream;

import org.opengis.cite.gpkg12.ErrorMessage;
import org.opengis.cite.gpkg12.ErrorMessageKeys;
import org.opengis.cite.gpkg12.tiles.TileTests;
import org.opengis.cite.gpkg12.util.DatabaseUtility;
import org.testng.Assert;
import org.testng.ITestContext;
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
public class ElevationTests extends TileTests {
	public ElevationTests(){
		// This allows all of the tiles tests to run on elevation data
		setDataType("2d-gridded-coverage");
	}

	@BeforeClass
	public void a_ValidateExtensionPresent(ITestContext testContext) throws SQLException {
		Assert.assertTrue(DatabaseUtility.doesTableOrViewExist(this.databaseConnection, "gpkg_extensions"), 
				ErrorMessage.format(ErrorMessageKeys.CONFORMANCE_CLASS_NOT_USED, "Elevation Extension"));
    	
		try (
				final Statement statement1 = this.databaseConnection.createStatement();
				ResultSet resultSet1 = statement1.executeQuery("SELECT COUNT(*) FROM gpkg_extensions WHERE table_name = 'gpkg_2d_gridded_coverage_ancillary';");
				) {
			resultSet1.next();
			Assert.assertTrue(resultSet1.getInt(1) > 0, ErrorMessage.format(ErrorMessageKeys.CONFORMANCE_CLASS_NOT_USED, "Elevation Extension"));
		}
	}

	/**
	 * Sets up variables used across methods, overrides TileTests
	 *
	 * @throws SQLException
	 *             if there is a database error
	 */
	@BeforeClass
	public void setUp() throws SQLException {
		if (!hasExtension){
			return;
		}
		/*
		 * Test case
		 * {@code /extensions/elevation/table_val/gpkg_contents}
		 *
		 * @see <a href="#r120" target= "_blank">Elevation 
		 * Extension - Requirement 124</a>
		 */

		try (
				final Statement statement2 = this.databaseConnection.createStatement();
				ResultSet resultSet2 = statement2.executeQuery("SELECT table_name FROM gpkg_contents WHERE data_type = '2d-gridded-coverage';");
				) {
			while (resultSet2.next()) {
				this.elevationTableNames.add(resultSet2.getString("table_name"));
			}
		}
	}

	/**
	 * Test case
	 * {@code /extensions/elevation/table_def/gpkg_2d_gridded_coverage_ancillary}
	 *
	 * @see <a href="#r120" target= "_blank">Elevation 
	 * Extension - Requirement 120</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 120")
	public void coverageAncillaryTableDefinition() throws SQLException {

		try (
				// 1
				final Statement statement = this.databaseConnection.createStatement();

				final ResultSet resultSet = statement.executeQuery("PRAGMA table_info('gpkg_2d_gridded_coverage_ancillary');");
				) {
			// 2
			int passFlag = 0;
			final int flagMask = 0b01111111;

			checkPrimaryKey("gpkg_2d_gridded_coverage_ancillary", "id");

			while (resultSet.next()) {
				// 3
				final String name = resultSet.getString("name");
				if ("id".equals(name)){
					// handled with checkPrimaryKey...
					passFlag |= 1;
				} else if ("tile_matrix_set_name".equals(name)){
					assertTrue("TEXT".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "tile_matrix_set_name type"));
					assertTrue(resultSet.getInt("notnull") == 1, ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "tile_matrix_set_name notnull"));
					passFlag |= (1 << 1);
				} else if ("datatype".equals(name)){
					assertTrue("TEXT".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "datatype type"));
					assertTrue(resultSet.getInt("notnull") == 1, ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "datatype notnull"));
					final String def = resultSet.getString("dflt_value");
					assertTrue("integer".equals(def) || "'integer'".equals(def), ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "datatype default"));
					passFlag |= (1 << 2);
				} else if ("scale".equals(name)){
					assertTrue("REAL".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "scale type"));
					assertTrue(resultSet.getInt("notnull") == 1, ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "scale notnull"));
					assertTrue(resultSet.getFloat("dflt_value") == 1.0, ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "scale default"));
					passFlag |= (1 << 3);
				} else if ("offset".equals(name)){
					assertTrue("REAL".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "offset type"));
					assertTrue(resultSet.getInt("notnull") == 1, ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "offset notnull"));
					assertTrue(resultSet.getFloat("dflt_value") == 0, ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "offset default"));
					passFlag |= (1 << 4);
				} else if ("precision".equals(name)){
					assertTrue("REAL".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "precision type"));
					assertTrue(resultSet.getInt("notnull") == 0, ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "precision type"));
					assertTrue(resultSet.getFloat("dflt_value") == 1.0, ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "precision default"));
					passFlag |= (1 << 5);
				} else if ("data_null".equals(name)){
					assertTrue("REAL".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "data_null type"));
					assertTrue(resultSet.getInt("notnull") == 0, ErrorMessage.format(ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID, "data_null notnull"));
					passFlag |= (1 << 6);
				}
			} 
			assertTrue((passFlag & flagMask) == flagMask, ErrorMessageKeys.COVERAGE_ANCILLARY_COLUMNS_INVALID);
		}
	}

	/**
	 * Test case
	 * {@code /extensions/elevation/table_def/gpkg_2d_gridded_tile_ancillary}
	 *
	 * @see <a href="#r121" target= "_blank">Elevation 
	 * Extension - Requirement 121</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 121")
	public void tileAncillaryTableDefinition() throws SQLException {
		try (
				// 1
				final Statement statement = this.databaseConnection.createStatement();

				final ResultSet resultSet = statement.executeQuery("PRAGMA table_info('gpkg_2d_gridded_tile_ancillary');");
				) {

			// 2
			long passFlag = 0;
			final long flagMask = 0b111111111;

			while (resultSet.next()) {
				checkPrimaryKey("gpkg_2d_gridded_tile_ancillary", "id");
				// 3
				final String name = resultSet.getString("name");
				if ("id".equals(name)){
					// handled with checkPrimaryKey...
					passFlag |= 1;
				} else if ("tpudt_name".equals(name)){
					assertTrue("TEXT".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "tpudt_name type"));
					assertTrue(resultSet.getInt("notnull") == 1, ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "tpudt_name notnull"));
					passFlag |= (1 << 1);
				} else if ("tpudt_id".equals(name)){
					assertTrue("INTEGER".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "tpudt_id type"));
					assertTrue(resultSet.getInt("notnull") == 1, ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "tpudt_id notnull"));
					passFlag |= (1 << 2);
				} else if ("scale".equals(name)){
					assertTrue("REAL".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "scale type"));
					assertTrue(resultSet.getInt("notnull") == 1, ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "scale notnull"));
					assertTrue(resultSet.getFloat("dflt_value") == 1.0, ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "scale default"));
					passFlag |= (1 << 3);
				} else if ("offset".equals(name)){
					assertTrue("REAL".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "offset type"));
					assertTrue(resultSet.getInt("notnull") == 1, ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "offset notnull"));
					assertTrue(resultSet.getFloat("dflt_value") == 0, ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "offset default"));
					passFlag |= (1 << 4);
				} else if ("min".equals(name)){
					assertTrue("REAL".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "precision type"));
					assertTrue(resultSet.getInt("notnull") == 0, ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "precision type"));
					passFlag |= (1 << 5);
				} else if ("max".equals(name)){
					assertTrue("REAL".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "data_null type"));
					assertTrue(resultSet.getInt("notnull") == 0, ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "data_null notnull"));
					passFlag |= (1 << 6);
				} else if ("mean".equals(name)){
					assertTrue("REAL".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "mean type"));
					assertTrue(resultSet.getInt("notnull") == 0, ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "mean type"));
					passFlag |= (1 << 7);
				} else if ("std_dev".equals(name)){
					assertTrue("REAL".equals(resultSet.getString("type")), ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "std_dev type"));
					assertTrue(resultSet.getInt("notnull") == 0, ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, "std_dev notnull"));
					passFlag |= (1 << 8);
				}
			} 
			assertTrue((passFlag & flagMask) == flagMask, ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_COLUMNS_INVALID, String.format("Missing column flag %d", passFlag)));
		}
	}

	/**
	 * Test case
	 * {@code /extensions/elevation/table_val/gpkg_spatial_ref_sys/rows}
	 *
	 * @see <a href="#r122" target= "_blank">Elevation 
	 * Extension - Requirement 122</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 122")
	public void requiredSRSRows() throws SQLException {
		try (
				final Statement statement = this.databaseConnection.createStatement();
				final ResultSet srsDefaultValue = statement.executeQuery(
						"SELECT COUNT(*) FROM gpkg_spatial_ref_sys WHERE organization_coordsys_id = 4979 AND (organization = 'EPSG' OR organization = 'epsg');");
				) {
			assertTrue(srsDefaultValue.getInt(1) > 0, ErrorMessage.format(ErrorMessageKeys.NO_ELEVATION_SRS));
		}
	}

	/**
	 * Test case
	 * {@code /opt/extensions/elevation/srs/required_references}
	 *
	 * @see <a href="#r123" target= "_blank">Elevation 
	 * Extension - Requirement 112</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 123")
	public void requiredSRSReferences() throws SQLException {
		for (final String tableName : this.elevationTableNames) {
			try (	
					final Statement statement1 = this.databaseConnection.createStatement();
					final ResultSet resultSet1 = statement1.executeQuery(String.format("SELECT srs_id FROM gpkg_tile_matrix_set WHERE table_name = '%s'", tableName));
					) {
				resultSet1.next();				
				final String srsID = resultSet1.getString(1);
				try (
						final Statement statement2 = this.databaseConnection.createStatement();
						final ResultSet resultSet2 = statement2.executeQuery(String.format("SELECT COUNT(*) FROM gpkg_spatial_ref_sys WHERE srs_id = '%s'", srsID));
						) {
					assertTrue(resultSet2.getInt(1) == 1, ErrorMessage.format(ErrorMessageKeys.BAD_MATRIX_SET_SRS_REFERENCE, srsID));
				}
			}
		}
	}

	/**
	 * Test case
	 * {@code /extensions/elevation/table_val/gpkg_extensions}
	 *
	 * @see <a href="#r125" target= "_blank">Elevation 
	 * Extension - Requirement 125</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 125")
	public void extensionTableRows() throws SQLException {
		try (
				// 1
				final Statement statement = this.databaseConnection.createStatement();

				final ResultSet resultSet = statement.executeQuery("SELECT table_name, column_name, extension_name, definition, scope from gpkg_extensions");
				) {
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
		}


		for (final String tableName : this.elevationTableNames) {
			try (
					final Statement statement1 = this.databaseConnection.createStatement();
					final ResultSet resultSet1 = statement1.executeQuery(String.format("SELECT column_name, definition, scope from gpkg_extensions WHERE extension_name = 'gpkg_elevation_tiles' AND table_name = '%s'", tableName));
					) {
				assertTrue(resultSet1.next() && "tile_data".equals(resultSet1.getObject("column_name")) &&
						"gpkg_elevation_tiles".equals(resultSet1.getString("extension_name")) &&
						"http://www.geopackage.org/spec/#extension_tiled_gridded_elevation_data".equals(resultSet1.getString("definition")) && 
						"read-write".equals(resultSet1.getString("scope")), 
						ErrorMessageKeys.ELEVATION_EXTENSION_ROWS_MISSING);
			}
		}
	}

	/**
	 * Test case
	 * {@code /extensions/elevation/table_ref/gpkg_contents/gpkg_2d_gridded_coverage_ancillary}
	 *
	 * @see <a href="#r126" target= "_blank">Elevation 
	 * Extension - Requirement 126</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 126")
	public void coverageAncillaryValues() throws SQLException {

		for (final String tableName : this.elevationTableNames) {
			try (
					final Statement statement1 = this.databaseConnection.createStatement();
					final ResultSet resultSet1 = statement1.executeQuery(String.format("SELECT COUNT(*) FROM gpkg_2d_gridded_coverage_ancillary WHERE tile_matrix_set_name = '%s'", tableName));
					) {
				resultSet1.next();
				assertTrue(resultSet1.getInt(1) == 1, ErrorMessage.format(ErrorMessageKeys.MISSING_REFERENCE, "gpkg_2d_gridded_coverage_ancillary", "tile_matrix_set_name", tableName));				
			}
		}
	}

	/**
	 * Test case
	 * {@code /extensions/elevation/table_ref/gpkg_2d_gridded_coverage_ancillary/gpkg_tile_matrix_set}
	 *
	 * @see <a href="#r127" target= "_blank">Elevation 
	 * Extension - Requirement 127</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 127")
	public void coverageAncillarySetName() throws SQLException {
		try (
				// 1
				final Statement statement = this.databaseConnection.createStatement();

				final ResultSet resultSet = statement.executeQuery("SELECT tile_matrix_set_name FROM 'gpkg_2d_gridded_coverage_ancillary';");
				) {
			// 2
			while (resultSet.next()){
				// 3
				final String tileMatrixSetName = resultSet.getString(1);
				try (
						final Statement statement2 = this.databaseConnection.createStatement();

						final ResultSet resultSet2 = statement2.executeQuery(String.format("SELECT count(*) FROM gpkg_tile_matrix_set WHERE table_name = '%s';", tileMatrixSetName));
						) {
					assertTrue(resultSet2.getInt(1) == 1, ErrorMessageKeys.UNREFERENCED_COVERAGE_TILE_MATRIX_SET_TABLE);
				}
			}
		}
	}

	/**
	 * Test case
	 * {@code/extensions/elevation/table_val/gpkg_2d_gridded_coverage_ancillary}
	 *
	 * @see <a href="#r128" target= "_blank">Elevation 
	 * Extension - Requirement 128</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 128")
	public void coverageAncillaryDatatype() throws SQLException {
		try (
				// 1
				final Statement statement = this.databaseConnection.createStatement();

				final ResultSet resultSet = statement.executeQuery("SELECT tile_matrix_set_name, datatype, scale, offset FROM 'gpkg_2d_gridded_coverage_ancillary';");
				) {
			// 2
			while (resultSet.next()){
				final String setName = resultSet.getString("tile_matrix_set_name");
				if (!elevationTableNames.contains(setName)) {
					continue;
				}
				// 2a
				final String datatype = resultSet.getString("datatype");
				assertTrue("integer".equals(datatype) || "float".equals(datatype), ErrorMessageKeys.COVERAGE_ANCILLARY_DATATYPE_INVALID);

				if ("float".equals(datatype)){
					final double scale = resultSet.getDouble("scale");
					final double offset = resultSet.getDouble("offset");
					// 2b
					assertTrue(scale == 1.0, 
							ErrorMessage.format(ErrorMessageKeys.ILLEGAL_VALUE, 
									"gpkg_2d_gridded_coverage_ancillary", 
									"datatype", 
									"float", 
									"scale", 
									"1.0", 
									Double.toString(scale), 
									"tile_matrix_set_name", 
									setName));
					// 2c
					assertTrue(offset == 0.0, 
							ErrorMessage.format(ErrorMessageKeys.ILLEGAL_VALUE, 
									"gpkg_2d_gridded_coverage_ancillary", 
									"datatype", 
									"float", 
									"offset", 
									"0.0", 
									Double.toString(offset), 
									"tile_matrix_set_name", 
									setName));
				}
			}	
		}
	}

	/**
	 * Test case
	 * {@code /extensions/elevation/table_ref/tpudt/gpkg_2d_gridded_tile_ancillary}
	 *
	 * @see <a href="#129" target= "_blank">Elevation 
	 * Extension - Requirement 129, 131</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 129, 131")
	public void tileAncillaryTableRef() throws SQLException {
		// 1
		for (final String tableName : this.elevationTableNames) {
			try (
					final Statement statement1 = this.databaseConnection.createStatement();
					final ResultSet resultSet1 = statement1.executeQuery(String.format("SELECT id FROM %s", tableName));
					) {
				while (resultSet1.next()) {
					try (
							final Statement statement2 = this.databaseConnection.createStatement();
							final ResultSet resultSet2 = statement2.executeQuery("SELECT %s.id as tid, gpkg_2d_gridded_tile_ancillary.tpudt_id as taid from %s LEFT OUTER JOIN gpkg_2d_gridded_tile_ancillary ON %s.id = gpkg_2d_gridded_tile_ancillary.tpudt_id AND gpkg_2d_gridded_tile_ancillary.tpudt_name = '%s'".replace("%s",  tableName));
							) {
						while (resultSet2.next()) {
							final String id = resultSet2.getString(1);
							resultSet2.getString(2);
							assertTrue(!resultSet2.wasNull(), ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_REFERENCES, tableName, id));
						}

					}
				}				
			}
		}
	}

	/**
	 * Test case
	 * {@code /extensions/elevation/table_val/gpkg_2d_gridded_tile_ancillary}
	 *
	 * @see <a href="#130" target= "_blank">Elevation 
	 * Extension - Requirement 130</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 130")
	public void tileAncillaryTableVal() throws SQLException {
		try (
				// 1
				final Statement statement1 = this.databaseConnection.createStatement();
				final ResultSet resultSet1 = statement1.executeQuery("SELECT tpudt_name, scale, offset FROM gpkg_2d_gridded_tile_ancillary;");
				) {
			// 2
			while (resultSet1.next()) {
				final String tableName = resultSet1.getString("tpudt_name");
				try (
						final Statement statement2 = this.databaseConnection.createStatement();
						// 2a
						final ResultSet resultSet2 = statement2.executeQuery(String.format("PRAGMA table_info(%s)", tableName));
						) {
					// 2b
					assertTrue(resultSet2.next(), ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_TABLE_REF_INVALID, tableName));					
				}
				try (
						// 2c
						final Statement statement3 = this.databaseConnection.createStatement();
						final ResultSet resultSet3 = statement3.executeQuery(String.format("SELECT datatype from gpkg_2d_gridded_coverage_ancillary WHERE tile_matrix_set_name = '%s'", tableName));
						) {
					// 2d
					assertTrue(resultSet3.next(), ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_TABLE_REF_INVALID, tableName));
					final String datatype = resultSet3.getString("datatype");			
					if("float".equals(datatype)){
						final double scale = resultSet1.getDouble("scale");
						final double offset = resultSet1.getDouble("offset");
						// 2e
						assertTrue(scale == 1.0, 
								ErrorMessage.format(ErrorMessageKeys.ILLEGAL_VALUE, 
										"gpkg_2d_gridded_tile_ancillary", 
										"datatype", 
										"float", 
										"scale", 
										"1.0", 
										Double.toString(scale), 
										"tpudt_name", 
										tableName));
						// 2f
						assertTrue(offset == 0.0, 
								ErrorMessage.format(ErrorMessageKeys.ILLEGAL_VALUE, 
										"gpkg_2d_gridded_tile_ancillary", 
										"datatype", 
										"float", 
										"offset", 
										"0.0", 
										Double.toString(offset), 
										"tpudt_name", 
										tableName));
					}
				}
			}			
		}
	}

	/**
	 * For data where the datatype column of the corresponding row in the 
	 * gpkg_2d_gridded_coverage_ancillary table is integer, 
	 * the tile_data BLOB in the tile pyramid user data table containing tiled, 
	 * gridded elevation data SHALL be of MIME type image/png and the data SHALL 
	 * be 16-bit unsigned integer (single channel - "greyscale").
	 * For data where the datatype column of the corresponding row in the 
	 * gpkg_2d_gridded_coverage_ancillary table is float, 
	 * the tile_data BLOB in the tile pyramid user data table containing tiled, 
	 * gridded elevation data SHALL be of MIME type image/tiff and the data SHALL 
	 * be 32-bit floating point as described by the TIFF Encoding (Requirement 120).
	 * 
	 * @see <a href="#r132" target=
	 *      "_blank">MIME Type PNG or TIFF - Requirement 132/133</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 * @throws IOException
	 *             If the bytes of an image cause an error when read
	 */
	@Test(description = "See OGC 12-128r12: Requirement 132/133")
	public void imageFormat() throws SQLException, IOException
	{
		// 1, 2
		for(final String tableName : this.elevationTableNames)
		{
			final Collection<Integer> failedTileIds = new LinkedList<>();
			try (
					// 2a
					final Statement statement = this.databaseConnection.createStatement();
					final ResultSet resultSet = statement.executeQuery("SELECT t.datatype AS datatype, u.id AS id, u.tile_data AS tile_data FROM gpkg_2d_gridded_coverage_ancillary t, %s u WHERE t.tile_matrix_set_name = '%s';".replace("%s", tableName));
					) {		
				// 2b
				while(resultSet.next())
				{
					final String datatype = resultSet.getString("datatype");
					final int id = resultSet.getInt("id");

					try (final MemoryCacheImageInputStream cacheImage = new MemoryCacheImageInputStream(new ByteArrayInputStream(resultSet.getBytes("tile_data")))) {
						// 2bi
						if ("float".equals(datatype)) {
							if (!canReadImage(tiffImageReaders, cacheImage)){
								failedTileIds.add(id);
							}
							// 2bii
						} else if ("integer".equals(datatype)){
							if (!canReadImage(pngImageReaders, cacheImage)){
								failedTileIds.add(id);
							}
						}                	
					};
				}
			}

			assertTrue(failedTileIds.isEmpty(),
					ErrorMessage.format(ErrorMessageKeys.INVALID_IMAGE_FORMAT,
							tableName,
							failedTileIds.stream()
							.map(Object::toString)
							.collect(Collectors.joining(", "))));
		}
	}

	//TODO: I don't know how to test R134 - R139

	protected static final Collection<ImageReader> tiffImageReaders;
	static
	{
		tiffImageReaders = StreamSupport.stream(Spliterators.spliteratorUnknownSize(ImageIO.getImageReadersByMIMEType("image/tiff"),
				Spliterator.ORDERED),
				false)
				.collect(Collectors.toCollection(ArrayList::new));

	}

	private boolean hasExtension = false;
	private final Collection<String> elevationTableNames = new ArrayList<>();
}
