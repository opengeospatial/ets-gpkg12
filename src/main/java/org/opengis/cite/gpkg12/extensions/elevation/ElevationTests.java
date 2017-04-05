package org.opengis.cite.gpkg12.extensions.elevation;

import static org.testng.Assert.assertTrue;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.Map;
import java.util.Spliterator;
import java.util.Spliterators;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

import javax.imageio.ImageIO;
import javax.imageio.ImageReader;
import javax.imageio.stream.MemoryCacheImageInputStream;

import org.opengis.cite.gpkg12.ErrorMessage;
import org.opengis.cite.gpkg12.ErrorMessageKeys;
import org.opengis.cite.gpkg12.TestRunArg;
import org.opengis.cite.gpkg12.tiles.TileTests;
import org.testng.Assert;
import org.testng.ITestContext;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.BeforeTest;
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
		
		setDataType("2d-gridded-coverage");
	}
    @BeforeTest
    public void validateClassEnabled(ITestContext testContext) throws IOException {
	  Map<String, String> params = testContext.getSuite().getXmlSuite().getParameters();
	  final String pstr = params.get(TestRunArg.ICS.toString());
	  final String testName = testContext.getName();
	  HashSet<String> set = new HashSet<String>(Arrays.asList(pstr.split(",")));
	  Assert.assertTrue(set.contains(testName), String.format("Conformance class %s is not enabled", testName));
    }

    @BeforeClass
    public void a_ValidateExtensionPresent(ITestContext testContext) throws SQLException {
  		
		final Statement statement1 = this.databaseConnection.createStatement();
		ResultSet resultSet1 = statement1.executeQuery("SELECT COUNT(*) FROM gpkg_extensions WHERE table_name = 'gpkg_2d_gridded_coverage_ancillary';");
		resultSet1.next();
		hasExtension = resultSet1.getInt(1) > 0;
		
	    Assert.assertTrue(hasExtension, "The Elevation Extension is not in use in this GeoPackage.");
    }

	/**
	 * Sets up variables used across methods
	 *
	 * @throws SQLException
	 *             if there is a database error
	 */
	@BeforeClass
	public void setUp() throws SQLException {
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
		
		// 1
		final Statement statement = this.databaseConnection.createStatement();

		final ResultSet resultSet = statement.executeQuery("PRAGMA table_info('gpkg_2d_gridded_coverage_ancillary');");

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
		// 1
		final Statement statement = this.databaseConnection.createStatement();

		final ResultSet resultSet = statement.executeQuery("PRAGMA table_info('gpkg_2d_gridded_tile_ancillary');");

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
			assertTrue("tile_data".equals(resultSet1.getObject("column_name")) &&
					"gpkg_elevation_tiles".equals(resultSet1.getString("extension_name")) &&
					"http://www.geopackage.org/spec/#extension_tiled_gridded_elevation_data".equals(resultSet1.getString("definition")) && 
					"read-write".equals(resultSet1.getString("scope")), ErrorMessageKeys.ELEVATION_EXTENSION_ROWS_MISSING);
		}
	
	}

	/**
	 * Test case
	 * {@code /opt/extensions/elevation/coverage_ancillary/set_name}
	 *
	 * @see <a href="requirement_feature_integer_pk" target= "_blank">Elevation 
	 * Extension - Requirement 111</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 111")
	public void coverageAncillarySetName() throws SQLException {
		// 1
		final Statement statement = this.databaseConnection.createStatement();

		final ResultSet resultSet = statement.executeQuery("SELECT tile_matrix_set_name FROM 'gpkg_2d_gridded_coverage_ancillary';");
		
		// 2
		while (resultSet.next()){
			// 3
			final String tileMatrixSetName = resultSet.getString(1);
			final Statement statement2 = this.databaseConnection.createStatement();

			final ResultSet resultSet2 = statement2.executeQuery(String.format("SELECT count(*) FROM gpkg_tile_matrix_set WHERE table_name = '%s';", tileMatrixSetName));
			assertTrue(resultSet2.getInt(1) == 1, ErrorMessageKeys.UNREFERENCED_COVERAGE_TILE_MATRIX_SET_TABLE);
		}
	}

	/**
	 * Test case
	 * {@code /opt/extensions/elevation/coverage_ancillary/datatype}
	 *
	 * @see <a href="requirement_feature_integer_pk" target= "_blank">Elevation 
	 * Extension - Requirement 112</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 112")
	public void coverageAncillaryDatatype() throws SQLException {
		// 1
		final Statement statement = this.databaseConnection.createStatement();

		final ResultSet resultSet = statement.executeQuery("SELECT tile_matrix_set_name, datatype, scale, offset FROM 'gpkg_2d_gridded_coverage_ancillary';");
		
		// 2
		while (resultSet.next()){
			final String setName = resultSet.getString("tile_matrix_set_name");
			// 3
			if (!elevationTableNames.contains(setName)) {
				continue;
			}
			// 4
			final String datatype = resultSet.getString("datatype");
			assertTrue("integer".equals(datatype) || "float".equals(datatype), ErrorMessageKeys.COVERAGE_ANCILLARY_DATATYPE_INVALID);
			
			// 5
			if ("float".equals(datatype)){
				assertTrue((resultSet.getObject("scale") == null) && (resultSet.getObject("offset") == null), ErrorMessageKeys.COVERAGE_ANCILLARY_FLOAT_SCALE_OFFSET);
			}
		}
	}

	/**
	 * Test case
	 * {@code /opt/extensions/elevation/tile_ancillary/table_reference}
	 *
	 * @see <a href="requirement_feature_integer_pk" target= "_blank">Elevation 
	 * Extension - Requirement 113</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 113")
	public void tileAncillaryTableRef() throws SQLException {
		// 1
		final Statement statement = this.databaseConnection.createStatement();

		final ResultSet resultSet = statement.executeQuery("SELECT DISTINCT tpudt_name FROM 'gpkg_2d_gridded_tile_ancillary';");
		
		// 2
		while (resultSet.next()){
			// 3
			final String tableName = resultSet.getString("tpudt_name");
			
			final Statement statement2 = this.databaseConnection.createStatement();
			
			final ResultSet resultSet2 = statement2.executeQuery(String.format("SELECT type, name FROM sqlite_master WHERE type IN ('table','view') AND name = '%s'",
					 tableName));
			// 4
			assertTrue(resultSet2.next(), ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_TABLE_REF_INVALID, tableName));
		}
	}
	
	/**
	 * Test case
	 * {@code /opt/extensions/elevation/tpudt/required_references}
	 *
	 * @see <a href="requirement_feature_integer_pk" target= "_blank">Elevation 
	 * Extension - Requirement 114</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 114")
	public void tpudtReferences() throws SQLException {
		for (final String tableName : this.elevationTableNames) {
			final Statement statement1 = this.databaseConnection.createStatement();
			final ResultSet resultSet1 = statement1.executeQuery(String.format("SELECT count(*) from %s", tableName));
			resultSet1.next();
			final Statement statement2 = this.databaseConnection.createStatement();
			final ResultSet resultSet2 = statement2.executeQuery(String.format("SELECT count(*) from %s where id IN (select tpudt_id from gpkg_2d_gridded_tile_ancillary WHERE tpudt_name = '%s')", tableName, tableName));
			resultSet2.next();
			assertTrue(resultSet1.getInt(1) == resultSet2.getInt(1), ErrorMessage.format(ErrorMessageKeys.TILE_ANCILLARY_REFERENCES, tableName));
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
     * @see <a href="http://www.geopackage.org/spec/#_requirement-115" target=
     *      "_blank">MIME Type PNG or TIFF - Requirement 115/116</a>
     *
     * @throws SQLException
     *             If an SQL query causes an error
     * @throws IOException
     *             If the bytes of an image cause an error when read
     */
    @Test(description = "See OGC 12-128r12: Requirement 115/116")
    public void imageFormat() throws SQLException, IOException
    {
    	// 1
        for(final String tableName : this.elevationTableNames)
        {
        	// 2
            try(final Statement statement = this.databaseConnection.createStatement();
                final ResultSet resultSet = statement.executeQuery(String.format("SELECT tile_data, id FROM %s;", tableName)))
            {
                final Collection<Integer> failedTileIds = new LinkedList<>();

                // 3
                while(resultSet.next())
                {
                    final byte[] tileData = resultSet.getBytes("tile_data");

                    // 4
                    if(!isAcceptedImageFormat(tileData))
                    {
                        failedTileIds.add(resultSet.getInt("id"));
                    }
                }

                // 5
                assertTrue(failedTileIds.isEmpty(),
                           ErrorMessage.format(ErrorMessageKeys.INVALID_IMAGE_FORMAT,
                                               tableName,
                                               failedTileIds.stream()
                                                            .map(Object::toString)
                                                            .collect(Collectors.joining(", "))));
            }
        }
    }

    //TODO: I don't know how to test R117 - R122

    protected static final Collection<ImageReader> tiffImageReaders;
    static
    {
    	tiffImageReaders = StreamSupport.stream(Spliterators.spliteratorUnknownSize(ImageIO.getImageReadersByMIMEType("image/tiff"),
                                                                                    Spliterator.ORDERED),
                                                false)
                                        .collect(Collectors.toCollection(ArrayList::new));

    }

    private static boolean isAcceptedImageFormat(final byte[] image) throws IOException
    {
        if(image == null)
        {
            return false;
        }

        try(final ByteArrayInputStream        byteArray  = new ByteArrayInputStream(image);
            final MemoryCacheImageInputStream cacheImage = new MemoryCacheImageInputStream(byteArray))
        {
            return canReadImage(pngImageReaders, cacheImage) || canReadImage(tiffImageReaders, cacheImage);
        }
    }

    private boolean hasExtension = false;
	private final Collection<String> elevationTableNames = new ArrayList<>();
}
