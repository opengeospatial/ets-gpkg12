package org.opengis.cite.gpkg12.extensions.webp;

import static org.testng.Assert.assertTrue;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collection;
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
public class WebPTests extends TileTests {
	/**
	 * GeoPackages with one or more rows in the `gpkg_extensions` table with 
	 * an `extension_name` of "gpkg_webp" SHALL comply with this extension.
	 * 
	 * Test case
	 * {@code /extensions/tile_encoding_webp/data/webp_ext_name}
	 *
     * @see <a href="http://www.geopackage.org/spec/#r90" target=
     *      "_blank">WebP Extension - Requirement 90</a>
	 *
	 * @param testContext the test context
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
    @BeforeClass
    public void a_ValidateExtensionPresent(ITestContext testContext) throws SQLException {
		Assert.assertTrue(DatabaseUtility.doesTableOrViewExist(this.databaseConnection, "gpkg_extensions"), 
				ErrorMessage.format(ErrorMessageKeys.CONFORMANCE_CLASS_NOT_USED, "WebP Extension"));
		
  		try (
  				final Statement statement1 = this.databaseConnection.createStatement();
  				ResultSet resultSet1 = statement1.executeQuery("SELECT COUNT(*) FROM gpkg_extensions WHERE extension_name = 'gpkg_webp';");
  				) {
  			resultSet1.next();
  	        Assert.assertTrue(resultSet1.getInt(1) > 0, ErrorMessage.format(ErrorMessageKeys.CONFORMANCE_CLASS_NOT_USED, "WebP Extension"));  	  
  		}
        this.hasExtension = true;
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
		
		try (
				final Statement statement2 = this.databaseConnection.createStatement();
				ResultSet resultSet2 = statement2.executeQuery("SELECT table_name FROM gpkg_extensions WHERE extension_name = 'gpkg_webp';");
				) {
			while (resultSet2.next()) {
				this.tileTableNames.add(resultSet2.getString("table_name"));
			}			
		}
	}

    /**
     * A GeoPackage that contains tile pyramid user data tables with 
     * `tile_data` columns that contain images in WebP format SHALL contain 
     * a `gpkg_extensions` table that contains row records with `table_name` 
     * values for each such table, "tile_data" `column_name` values, 
     * `extension_name` column values of "gpkg_webp", and `scope` column 
     * values of "read-write".
     * 
	 * Test case
	 * {@code /extensions/tile_encoding_webp/data/webp_ext_row}
	 *
     * @see <a href="http://www.geopackage.org/spec/#r91" target=
     *      "_blank">WebP Extension - Requirement 91</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 91")
	public void coverageAncillaryTableDefinition() throws SQLException {
		try (
				// 1
				final Statement statement = this.databaseConnection.createStatement();

				final ResultSet resultSet = statement.executeQuery("SELECT table_name, column_name, scope FROM gpkg_extensions where extension_name = 'gpkg_webp';");
				) {
			// 2
			while (resultSet.next()) {
				// 3
				final String tableName = resultSet.getString("table_name");
				final String columnName = resultSet.getString("column_name");
				final String scope = resultSet.getString("scope");
				assertTrue("tile_data".equals(columnName), 
						ErrorMessage.format(ErrorMessageKeys.ILLEGAL_VALUE, "gpkg_extensions", "extension_name", "gpkg_webp", "column_name", "tile_data", columnName, "table_name", tableName));
				assertTrue("read-write".equals(scope), 
						ErrorMessage.format(ErrorMessageKeys.ILLEGAL_VALUE, "gpkg_extensions", "extension_name", "gpkg_webp", "scope", "read-write", scope, "table_name", tableName));
			}			
		}
	}

	
    /**
     * (extends http://www.geopackage.org/spec/#r36[GPKG-36] and 
     * http://www.geopackage.org/spec/#r37[GPKG-37]) A GeoPackage that 
     * contains a tile pyramid user data table that contains tile data MAY 
     * store tile_data in http://www.ietf.org/rfc/rfc2046.txt[MIME type] 
     * image/x-webp. The http://www.ietf.org/rfc/rfc2046.txt[MIME type] 
     * of values of the `tile_data` column in tile pyramid user data tables 
     * SHALL be `image/x-webp`.
     * 
	 * Test case
	 * {@code /extensions/tiles_encoding_webp/data/mime_type_webp}
	 *
     * @see <a href="http://www.geopackage.org/spec/#r92" target=
     *      "_blank">WebP Extension - Requirement 92</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
     * @throws IOException
     *             If the bytes of an image cause an error when read
     */
    @Test(description = "See OGC 12-128r13: Requirement 92")
    public void imageFormat() throws SQLException, IOException
    {
    	// TODO: Disabled until we get a suitable Webp library in here
//    	super.imageFormat();
    }

    protected static final Collection<ImageReader> webpImageReaders;
    static
    {
    	webpImageReaders = StreamSupport.stream(Spliterators.spliteratorUnknownSize(ImageIO.getImageReadersByMIMEType("image/x-webp"),
                                                                                    Spliterator.ORDERED),
                                                false)
                                        .collect(Collectors.toCollection(ArrayList::new));

    }

    protected boolean isAcceptedImageFormat(final byte[] image) throws IOException
    {
        if(image == null)
        {
            return false;
        }

        final ByteArrayInputStream        byteArray  = new ByteArrayInputStream(image);
        try (final MemoryCacheImageInputStream cacheImage = new MemoryCacheImageInputStream(byteArray)) { 
        	return canReadImage(pngImageReaders, cacheImage) || canReadImage(jpegImageReaders, cacheImage) || canReadImage(webpImageReaders, cacheImage);
        }
    }

    private boolean hasExtension = false;
}
