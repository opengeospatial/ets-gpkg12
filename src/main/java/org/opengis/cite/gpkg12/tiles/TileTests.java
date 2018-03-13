package org.opengis.cite.gpkg12.tiles;

import static org.testng.Assert.assertTrue;
import static org.testng.AssertJUnit.fail;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.Map;
import java.util.Spliterator;
import java.util.Spliterators;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

import javax.imageio.ImageIO;
import javax.imageio.ImageReader;
import javax.imageio.stream.ImageInputStream;
import javax.imageio.stream.MemoryCacheImageInputStream;

import org.opengis.cite.gpkg12.ColumnDefinition;
import org.opengis.cite.gpkg12.CommonFixture;
import org.opengis.cite.gpkg12.ErrorMessage;
import org.opengis.cite.gpkg12.ErrorMessageKeys;
import org.opengis.cite.gpkg12.ForeignKeyDefinition;
import org.opengis.cite.gpkg12.TableVerifier;
import org.opengis.cite.gpkg12.UniqueDefinition;
import org.opengis.cite.gpkg12.util.DatabaseUtility;
import org.testng.Assert;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;

/**
 * Defines test methods that apply to descriptive information about a
 * GeoPackage's content as it pertains to tiles.
 *
 * <p style="margin-bottom: 0.5em">
 * <strong>Sources</strong>
 * </p>
 * <ul>
 * <li><a href="http://www.geopackage.org/spec/#tiles" target= "_blank">
 * GeoPackage Encoding Standard - 2.2. Tiles</a> (OGC 12-128r12)</li>
 * </ul>
 *
 * @author Luke Lambert, Jeff Yutzler
 */
public class TileTests extends CommonFixture
{
	/**
	 * Sets up variables used across methods
	 *
	 * @throws SQLException if there is a database error
	 */
	@BeforeClass
	public void setUp() throws SQLException
	{
		final Collection<String> extensionTableNames = new ArrayList<String>();

		// We may have tiles tables that are handled by an extension
		if (DatabaseUtility.doesTableOrViewExist(this.databaseConnection, "gpkg_extensions")){
			try (
					final Statement statement2 = this.databaseConnection.createStatement();

					final ResultSet resultSet2 = statement2.executeQuery("SELECT table_name FROM gpkg_extensions WHERE column_name = 'tile_data';");
					) {
				while(resultSet2.next()) {
					final String tableName = resultSet2.getString(1);
					extensionTableNames.add(tableName);
				}
			}
		}

		try (
				final Statement statement = this.databaseConnection.createStatement();

				final ResultSet resultSet = statement.executeQuery(String.format("SELECT table_name FROM gpkg_contents WHERE data_type = '%s';", dataType));
				) {
			while(resultSet.next())
			{
				final String tableName = resultSet.getString(1);
				this.tileTableNames.add(tableName);
			}
			this.tileTableNames.removeAll(extensionTableNames);
			Assert.assertTrue(!this.tileTableNames.isEmpty(), ErrorMessage.format(ErrorMessageKeys.CONFORMANCE_CLASS_NOT_USED, getTestName()));    		
		}
	}

	/**
	 * In a GeoPackage that contains a tile pyramid user data table that
	 * contains tile data, by default, zoom level pixel sizes for that table
	 * SHALL vary by a factor of 2 between adjacent zoom levels in the tile
	 * matrix metadata table.
	 *
	 * @see <a href="http://www.geopackage.org/spec/#_requirement-35" target=
	 *      "_blank">Zoom Times Two - Requirement 35</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r12: Requirement 35")
	public void zoomTimesTwo() throws SQLException
	{
		for(final String tableName : this.tileTableNames)
		{
			try(final PreparedStatement preparedStatement = this.databaseConnection.prepareStatement("SELECT table_name, zoom_level, pixel_x_size, pixel_y_size, matrix_width, matrix_height, tile_width, tile_height FROM gpkg_tile_matrix WHERE table_name = ? ORDER BY zoom_level ASC;"))
			{
				preparedStatement.setString(1, tableName);

				try(final ResultSet resultSet = preparedStatement.executeQuery())
				{
					int    lastZoomLevel  = Integer.MIN_VALUE;
					double lastPixelXSize = 0.0;
					double lastPixelYSize = 0.0;

					while(resultSet.next())
					{
						final int    zoomLevel  = resultSet.getInt   ("zoom_level");
						final double pixelXSize = resultSet.getDouble("pixel_x_size");
						final double pixelYSize = resultSet.getDouble("pixel_y_size");

						if(zoomLevel == lastZoomLevel + 1)
						{
							//noinspection MagicNumber
							assertTrue(isEqual((lastPixelXSize / 2.0), pixelXSize) &&
									isEqual((lastPixelYSize / 2.0), pixelYSize),
									ErrorMessage.format(ErrorMessageKeys.VALUES_DO_NOT_VARY_BY_FACTOR_OF_TWO,
											lastZoomLevel,
											zoomLevel));
						}

						lastZoomLevel  = zoomLevel;
						lastPixelXSize = pixelXSize;
						lastPixelYSize = pixelYSize;
					}
				}
			}
		}
	}

	/**
	 * In a GeoPackage that contains a tile pyramid user data table that
	 * contains tile data that is not <a
	 * href="http://www.ietf.org/rfc/rfc2046.txt">MIME type</a>
	 * <a href="http://www.jpeg.org/public/jfif.pdf">image/jpeg</a>, by default
	 * SHALL store that tile data in <a
	 * href="http://www.iana.org/assignments/media-types/index.html"> MIME type
	 * </a> <a href="http://libpng.org/pub/png/">image/png</a>.
	 *
	 * @see <a href="http://www.geopackage.org/spec/#_requirement-36" target=
	 *      "_blank">MIME Type PNG - Requirement 36</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 * @throws IOException
	 *             If the bytes of an image cause an error when read
	 */
	@Test(description = "See OGC 12-128r12: Requirement 36")
	public void imageFormat() throws SQLException, IOException
	{
		for(final String tableName : this.tileTableNames)
		{
			try(final Statement statement = this.databaseConnection.createStatement();
					final ResultSet resultSet = statement.executeQuery(String.format("SELECT tile_data, id FROM %s;", tableName)))
			{
				final Collection<Integer> failedTileIds = new LinkedList<>();

				while(resultSet.next())
				{
					final byte[] tileData = resultSet.getBytes("tile_data");

					if(!isAcceptedImageFormat(tileData))
					{
						failedTileIds.add(resultSet.getInt("id"));
					}
				}

				// TODO If this assert fails, subsequent tables won't be tested or reported
				assertTrue(failedTileIds.isEmpty(),
						ErrorMessage.format(ErrorMessageKeys.INVALID_IMAGE_FORMAT,
								tableName,
								failedTileIds.stream()
								.map(Object::toString)
								.collect(Collectors.joining(", "))));
			}
		}
	}

	/**
	 * In a GeoPackage that contains a tile pyramid user data table that
	 * contains tile data that is not <a
	 * href="http://www.iana.org/assignments/media-types/index.html">MIME type
	 * </a> <a href="http://libpng.org/pub/png/">image/png</a>, by default
	 * SHALL store that tile data in <a
	 * href="http://www.ietf.org/rfc/rfc2046.txt">MIME type</a> <a
	 * href="http://www.jpeg.org/public/jfif.pdf">image/jpeg</a>.
	 *
	 * @see <a href="http://www.geopackage.org/spec/#_requirement-37" target=
	 *      "_blank">MIME Type JPEG - Requirement 37</a>
	 */
	@Test(description = "See OGC 12-128r12: Requirement 37")
	public void imageFormatJpg()
	{
		// Ignore - this is covered by requirement 36. It doesn't make sense to
		// ask each tile "Are you a PNG? If not, are you a JPG?" *and* "Are you
		// a JPG? If not, are you a PNG?"
	}

	/**
	 * A GeoPackage that contains a tile pyramid user data table SHALL contain
	 * {@code gpkg_tile_matrix_set} table or view per <a href=
	 * "http://www.geopackage.org/spec/#tile_matrix_set_data_table_definition">
	 * Table Definition</a>, <a href=
	 * "http://www.geopackage.org/spec/#gpkg_tile_matrix_set_cols">Tile
	 * Matrix Set Table or View Definition</a> and <a
	 * href="http://www.geopackage.org/spec/#gpkg_tile_matrix_set_sql">
	 * gpkg_tile_matrix_set Table Creation SQL</a>.
	 *
	 * @see <a href="http://www.geopackage.org/spec/#_requirement-38" target=
	 *      "_blank">Tile Matrix Set - Table Definition - Requirement 38</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r12: Requirement 38")
	public void tileMatrixSetTable() throws SQLException
	{
		final String tableName = "gpkg_tile_matrix_set";

		assertTrue(DatabaseUtility.doesTableOrViewExist(this.databaseConnection, tableName), 
				ErrorMessage.format(ErrorMessageKeys.MISSING_TABLE, tableName));

		try
		{
			final Map<String, ColumnDefinition> tileMatrixSetColumns = new HashMap<>();

			tileMatrixSetColumns.put("table_name", new ColumnDefinition("TEXT",    true, true,  true,  null));
			tileMatrixSetColumns.put("srs_id",     new ColumnDefinition("INTEGER", true, false, false, null));
			tileMatrixSetColumns.put("min_x",      new ColumnDefinition("DOUBLE",  true, false, false, null));
			tileMatrixSetColumns.put("min_y",      new ColumnDefinition("DOUBLE",  true, false, false, null));
			tileMatrixSetColumns.put("max_x",      new ColumnDefinition("DOUBLE",  true, false, false, null));
			tileMatrixSetColumns.put("max_y",      new ColumnDefinition("DOUBLE",  true, false, false, null));

			TableVerifier.verifyTable(this.databaseConnection,
					tableName,
					tileMatrixSetColumns,
					new HashSet<>(Arrays.asList(new ForeignKeyDefinition("gpkg_spatial_ref_sys", "srs_id",     "srs_id"),
							new ForeignKeyDefinition("gpkg_contents",        "table_name", "table_name"))),
					Collections.emptyList());
		}
		catch(final Throwable th)
		{
			fail(ErrorMessage.format(ErrorMessageKeys.BAD_TILE_MATRIX_SET_TABLE_DEFINITION, th.getMessage()));
		}
	}

	/**
	 * Values of the {@code gpkg_tile_matrix_set} {@code table_name} column
	 * SHALL reference values in the gpkg_contents table_name column for rows
	 * with a data type of "tiles".
	 *
	 * @see <a href="http://www.geopackage.org/spec/#_requirement-39" target=
	 *      "_blank">Table Data Values - Requirement 39</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r12: Requirement 39")
	public void matrixSetNamesReferenceTiles() throws SQLException
	{
		for (final String tableName : this.tileTableNames) {
			try (
					final Statement statement1 = this.databaseConnection.createStatement();
					final ResultSet resultSet1 = statement1.executeQuery(String.format("SELECT table_name FROM gpkg_tile_matrix_set WHERE table_name = '%s'", tableName));
					) {
				assertTrue(resultSet1.next(),
						ErrorMessage.format(ErrorMessageKeys.UNREFERENCED_TILE_MATRIX_SET_TABLE, tableName));				
			}
		}
	}

	/**
	 * The {@code gpkg_tile_matrix_set} table or view SHALL contain one row
	 * record for each tile pyramid user data table.
	 *
	 * @see <a href="http://www.geopackage.org/spec/#_requirement-40" target=
	 *      "_blank">Table Data Values - Requirement 40</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r12: Requirement 40")
	public void matrixSetNameForEachTilesTable() throws SQLException
	{
		try(Statement statement = this.databaseConnection.createStatement();
				ResultSet resultSet = statement.executeQuery("SELECT table_name FROM gpkg_tile_matrix_set;"))
		{
			final Collection<String> tableNames = new LinkedList<>();

			while(resultSet.next())
			{
				tableNames.add(resultSet.getString("table_name"));
			}

			for(final String tableName : this.tileTableNames)
			{
				assertTrue(tableNames.contains(tableName),
						ErrorMessage.format(ErrorMessageKeys.UNREFERENCED_TILES_CONTENT_TABLE_NAME, tableName));
			}
		}
	}

	/**
	 * Values of the {@code gpkg_tile_matrix_set} {@code srs_id} column SHALL
	 * reference values in the {@code gpkg_spatial_ref_sys} {@code srs_id}
	 *
	 * @see <a href="http://www.geopackage.org/spec/#_requirement-41" target=
	 *      "_blank">Table Data Values - Requirement 41</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r12: Requirement 41")
	public void matrixSetSrsIdReferencesGoodId() throws SQLException
	{
		try(final Statement statement = this.databaseConnection.createStatement();
				final ResultSet resultSet = statement.executeQuery("SELECT srs_id from gpkg_tile_matrix_set WHERE srs_id NOT IN (SELECT srs_id FROM gpkg_spatial_ref_sys);"))
		{
			if(resultSet.next())
			{
				fail(ErrorMessage.format(ErrorMessageKeys.BAD_MATRIX_SET_SRS_REFERENCE, resultSet.getInt("srs_id")));
			}
		}
	}

	/**
	 * A GeoPackage that contains a tile pyramid user data table SHALL contain
	 * a {@code gpkg_tile_matrix} table or view per clause 2.2.7.1.1 <a href=
	 * "http://www.geopackage.org/spec/#tile_matrix_data_table_definition">
	 * Table Definition</a>, Table <a href=
	 * "http://www.geopackage.org/spec/#gpkg_tile_matrix_cols">Tile Matrix
	 * Metadata Table or View Definition</a> and Table <a href=
	 * "http://www.geopackage.org/spec/#gpkg_tile_matrix_sql">
	 * gpkg_tile_matrix Table Creation SQL</a>.
	 *
	 * @see <a href="http://www.geopackage.org/spec/#_requirement-42" target=
	 *      "_blank">Tile Matrix - Table Definition - Requirement 42</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r12: Requirement 42")
	public void tileMatrixTableDefinition() throws SQLException
	{
		final String tableName = "gpkg_tile_matrix";

		assertTrue(DatabaseUtility.doesTableOrViewExist(this.databaseConnection, tableName), 
				ErrorMessage.format(ErrorMessageKeys.MISSING_TABLE, tableName));

		try
		{
			final Map<String, ColumnDefinition> tileMatrixColumns = new HashMap<>();

			tileMatrixColumns.put("table_name",     new ColumnDefinition("TEXT",    true, true,  true,  null));
			tileMatrixColumns.put("zoom_level",     new ColumnDefinition("INTEGER", true, true,  true,  null));
			tileMatrixColumns.put("matrix_width",   new ColumnDefinition("INTEGER", true, false, false, null));
			tileMatrixColumns.put("matrix_height",  new ColumnDefinition("INTEGER", true, false, false, null));
			tileMatrixColumns.put("tile_width",     new ColumnDefinition("INTEGER", true, false, false, null));
			tileMatrixColumns.put("tile_height",    new ColumnDefinition("INTEGER", true, false, false, null));
			tileMatrixColumns.put("pixel_x_size",   new ColumnDefinition("DOUBLE",  true, false, false, null));
			tileMatrixColumns.put("pixel_y_size",   new ColumnDefinition("DOUBLE",  true, false, false, null));

			TableVerifier.verifyTable(this.databaseConnection,
					tableName,
					tileMatrixColumns,
					new HashSet<>(Arrays.asList(new ForeignKeyDefinition("gpkg_contents", "table_name", "table_name"))),
					Collections.emptyList());
		}
		catch(final Throwable th)
		{
			fail(ErrorMessage.format(ErrorMessageKeys.BAD_TILE_MATRIX_TABLE_DEFINITION, th.getMessage()));
		}
	}

	/**
	 * Values of the {@code gpkg_tile_matrix} {@code table_name}
	 * column SHALL reference values in the {@code gpkg_contents} {@code
	 * table_name} column for rows with a {@code data_type} of
	 * 'tiles'.
	 *
	 * @see <a href="http://www.geopackage.org/spec/#_requirement-43" target=
	 *      "_blank">Tile Matrix - Table Data Values - Requirement 43</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r12: Requirement 43")
	public void tileMatrixTableContentsReferences() throws SQLException
	{
		try(final Statement statement = this.databaseConnection.createStatement();
				final ResultSet resultSet = statement.executeQuery("SELECT table_name FROM gpkg_tile_matrix AS tm WHERE table_name NOT IN (SELECT table_name FROM gpkg_contents AS gc WHERE tm.table_name = gc.table_name);"))
		{
			final Collection<String> unreferencedTables = new LinkedList<>();

			while(resultSet.next())
			{
				unreferencedTables.add(resultSet.getString("table_name"));
			}

			assertTrue(unreferencedTables.isEmpty(),
					ErrorMessage.format(ErrorMessageKeys.BAD_MATRIX_CONTENTS_REFERENCES,
							String.join(", ", unreferencedTables)));
		}
	}

	/**
	 * The {@code gpkg_tile_matrix} table or view SHALL contain one row
	 * record for each zoom level that contains one or more tiles in each tile
	 * pyramid user data table or view.
	 *
	 * @see <a href="http://www.geopackage.org/spec/#_requirement-44" target=
	 *      "_blank">Tile Matrix - Table Data Values - Requirement 44</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r12: Requirement 44")
	public void tileMatrixPerZoomLevel() throws SQLException
	{
		for(final String tableName : this.tileTableNames)
		{
			final Collection<Integer> tileMatrixZooms = new LinkedList<>();

			try(final PreparedStatement statement = this.databaseConnection.prepareStatement("SELECT DISTINCT zoom_level FROM gpkg_tile_matrix WHERE table_name = ? ORDER BY zoom_level;"))
			{
				statement.setString(1, tableName);

				try(final ResultSet gmZoomLevels = statement.executeQuery())
				{
					while(gmZoomLevels.next())
					{
						tileMatrixZooms.add(gmZoomLevels.getInt("zoom_level"));
					}
				}
			}

			final Collection<Integer> tilePyramidZooms = new LinkedList<>();

			try(final Statement statement    = this.databaseConnection.createStatement();
					final ResultSet pyZoomLevels = statement.executeQuery(String.format("SELECT DISTINCT zoom_level FROM %s ORDER BY zoom_level;", tableName)))
			{
				while(pyZoomLevels.next())
				{
					tilePyramidZooms.add(pyZoomLevels.getInt("zoom_level"));
				}
			}

			for(final Integer zoom: tilePyramidZooms)
			{
				assertTrue(tileMatrixZooms.contains(zoom),
						ErrorMessage.format(ErrorMessageKeys.MISSING_TILE_MATRIX_ENTRY, zoom, tableName));
			}
		}
	}

	/**
	 * The width of a tile matrix (the difference between {@code min_x} and
	 * {@code max_x} in {@code gpkg_tile_matrix_set}) SHALL equal the product
	 * of {@code matrix_width}, {@code tile_width}, and {@code pixel_x_size}
	 * for that zoom level. Similarly, height of a tile matrix (the difference
	 * between {@code min_y} and {@code max_y} in {@code gpkg_tile_matrix_set})
	 * SHALL equal the product of {@code matrix_height}, {@code tile_height},
	 * and {@code pixel_y_size} for that zoom level.
	 *
	 * @see <a href="http://www.geopackage.org/spec/#_requirement-45" target=
	 *      "_blank">Tile Matrix - Table Data Values - Requirement 45</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r12: Requirement 45")
	public void tileMatrixDimensionAgreement() throws SQLException
	{
		final Map<String, Collection<Integer>> tableNamesWithBadZooms = new HashMap<>();

		for(final String tableName : this.tileTableNames)
		{
			try(final PreparedStatement preparedStatement = this.databaseConnection.prepareStatement("SELECT min_x, min_y, max_x, max_y FROM gpkg_tile_matrix_set WHERE table_name = ?"))
			{
				preparedStatement.setString(1, tableName);

				try(final ResultSet boundingBox = preparedStatement.executeQuery())
				{
					if(boundingBox.next())
					{
						final double width  = boundingBox.getDouble("max_x") - boundingBox.getDouble("min_x");
						final double height = boundingBox.getDouble("max_y") - boundingBox.getDouble("min_y");

						final Collection<Integer> zoomLevels = new ArrayList<>();

						try(final PreparedStatement statement = this.databaseConnection.prepareStatement("SELECT zoom_level, pixel_x_size, pixel_y_size, matrix_width, matrix_height, tile_width, tile_height FROM gpkg_tile_matrix WHERE table_name = ? ORDER BY zoom_level ASC;"))
						{
							statement.setString(1, tableName);

							try(final ResultSet pixelInfo = statement.executeQuery())
							{
								while(pixelInfo.next())
								{
									final double pixelXSize   = pixelInfo.getDouble("pixel_x_size");
									final double pixelYSize   = pixelInfo.getDouble("pixel_y_size");
									final double matrixHeight = pixelInfo.getInt   ("matrix_height");
									final double matrixWidth  = pixelInfo.getInt   ("matrix_width");
									final double tileHeight   = pixelInfo.getInt   ("tile_height");
									final double tileWidth    = pixelInfo.getInt   ("tile_width");

									if(!isEqual(pixelXSize, (width  / matrixWidth)  / tileWidth) ||
											!isEqual(pixelYSize, (height / matrixHeight) / tileHeight))
									{
										zoomLevels.add(pixelInfo.getInt("zoom_level"));
									}
								}
							}
						}

						if(!zoomLevels.isEmpty())
						{
							tableNamesWithBadZooms.put(tableName, zoomLevels);
						}
					}
				}
			}
		}

		assertTrue(tableNamesWithBadZooms.isEmpty(),
				ErrorMessage.format(ErrorMessageKeys.BAD_PIXEL_DIMENSIONS,
						tableNamesWithBadZooms.entrySet()
						.stream()
						.map(entrySet -> String.format("%s: %s",
								entrySet.getKey(),
								entrySet.getValue()
								.stream()
								.map(Object::toString)
								.collect(Collectors.joining(", "))))
						.collect(Collectors.joining("\n"))));
	}

	/**
	 * The {@code zoom_level} column value in a {@code gpkg_tile_matrix} table
	 * row SHALL not be negative.
	 *
	 * @see <a href="http://www.geopackage.org/spec/#_requirement-46" target=
	 *      "_blank">Tile Matrix - Table Data Values - Requirement 46</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r12: Requirement 46")
	public void zoomLevelNotNegative() throws SQLException
	{
		try(final Statement statement = this.databaseConnection.createStatement();
				final ResultSet resultSet = statement.executeQuery("SELECT zoom_level FROM gpkg_tile_matrix WHERE zoom_level < 0;"))
		{
			if(resultSet.next())
			{
				fail(ErrorMessageKeys.NEGATIVE_ZOOM_LEVEL);
			}
		}
	}

	/**
	 * {@code matrix_width} column value in a {@code gpkg_tile_matrix} table
	 * row SHALL be greater than 0.
	 *
	 * @see <a href="http://www.geopackage.org/spec/#_requirement-47" target=
	 *      "_blank">Tile Matrix - Table Data Values - Requirement 47</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r12: Requirement 47")
	public void matrixWidthGreaterThanZero() throws SQLException
	{
		try(final Statement statement = this.databaseConnection.createStatement();
				final ResultSet resultSet = statement.executeQuery("SELECT matrix_width FROM gpkg_tile_matrix WHERE matrix_width <= 0;"))
		{
			if(resultSet.next())
			{
				fail(ErrorMessageKeys.NON_POSITIVE_MATRIX_WIDTH);
			}
		}
	}

	/**
	 * {@code matrix_height} column value in a {@code gpkg_tile_matrix} table
	 * row SHALL be greater than 0.
	 *
	 * @see <a href="http://www.geopackage.org/spec/#_requirement-48" target=
	 *      "_blank">Tile Matrix - Table Data Values - Requirement 48</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r12: Requirement 48")
	public void matrixHeightGreaterThanZero() throws SQLException
	{
		try(final Statement statement = this.databaseConnection.createStatement();
				final ResultSet resultSet = statement.executeQuery("SELECT matrix_height FROM gpkg_tile_matrix WHERE matrix_height <= 0;"))
		{
			if(resultSet.next())
			{
				fail(ErrorMessageKeys.NON_POSITIVE_MATRIX_HEIGHT);
			}
		}
	}

	/**
	 * {@code tile_width} column value in a {@code gpkg_tile_matrix} table row
	 * SHALL be greater than 0.
	 *
	 * @see <a href="http://www.geopackage.org/spec/#_requirement-49" target=
	 *      "_blank">Tile Matrix - Table Data Values - Requirement 49</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r12: Requirement 49")
	public void tileWidthGreaterThanZero() throws SQLException
	{
		try(final Statement statement = this.databaseConnection.createStatement();
				final ResultSet resultSet = statement.executeQuery("SELECT tile_width FROM gpkg_tile_matrix WHERE tile_width <= 0;"))
		{
			if(resultSet.next())
			{
				fail(ErrorMessageKeys.NON_POSITIVE_TILE_WIDTH);
			}
		}
	}

	/**
	 * {@code tile_height} column value in a {@code gpkg_tile_matrix} table row
	 * SHALL be greater than 0.
	 *
	 * @see <a href="http://www.geopackage.org/spec/#_requirement-50" target=
	 *      "_blank">Tile Matrix - Table Data Values - Requirement 50</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r12: Requirement 50")
	public void tileHeightGreaterThanZero() throws SQLException
	{
		try(final Statement statement = this.databaseConnection.createStatement();
				final ResultSet resultSet = statement.executeQuery("SELECT tile_height FROM gpkg_tile_matrix WHERE tile_height <= 0;"))
		{
			if(resultSet.next())
			{
				fail(ErrorMessageKeys.NON_POSITIVE_TILE_HEIGHT);
			}
		}
	}

	/**
	 * {@code pixel_x_size} column value in a {@code gpkg_tile_matrix} table row
	 * SHALL be greater than 0.
	 *
	 * @see <a href="http://www.geopackage.org/spec/#_requirement-51" target=
	 *      "_blank">Tile Matrix - Table Data Values - Requirement 51</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r12: Requirement 51")
	public void pixelXSizeGreaterThanZero() throws SQLException
	{
		try(final Statement statement = this.databaseConnection.createStatement();
				final ResultSet resultSet = statement.executeQuery("SELECT pixel_x_size FROM gpkg_tile_matrix WHERE pixel_x_size <= 0;"))
		{
			if(resultSet.next())
			{
				fail(ErrorMessageKeys.NON_POSITIVE_PIXEL_X_SIZE);
			}
		}
	}

	/**
	 * {@code pixel_y_size} column value in a {@code gpkg_tile_matrix} table row
	 * SHALL be greater than 0.
	 *
	 * @see <a href="http://www.geopackage.org/spec/#_requirement-52" target=
	 *      "_blank">Tile Matrix - Table Data Values - Requirement 52</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r12: Requirement 52")
	public void pixelYSizeGreaterThanZero() throws SQLException
	{
		try (
				final Statement statement = this.databaseConnection.createStatement();
				final ResultSet resultSet = statement.executeQuery("SELECT pixel_y_size FROM gpkg_tile_matrix WHERE pixel_y_size <= 0;");
				) {
			if (resultSet.next()) {
				fail(ErrorMessageKeys.NON_POSITIVE_PIXEL_Y_SIZE);
			}    		
		}
	}

	/**
	 * The {@code pixel_x_size} and {@code pixel_y_size} column values for
	 * {@code zoom_level} column values in a {@code gpkg_tile_matrix} table
	 * sorted in ascending order SHALL be sorted in descending order.
	 *
	 * @see <a href="http://www.geopackage.org/spec/#_requirement-53" target=
	 *      "_blank">Tile Matrix - Table Data Values - Requirement 53</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 *
	 */
	@Test(description = "See OGC 12-128r12: Requirement 53")
	public void sortedPixelSizes() throws SQLException
	{
		for(final String pyramidTable : this.tileTableNames) {
			try (final PreparedStatement statement = this.databaseConnection.prepareStatement("SELECT pixel_x_size, pixel_y_size FROM gpkg_tile_matrix WHERE table_name = ? ORDER BY zoom_level ASC;")) {
				statement.setString(1, pyramidTable);
				try (final ResultSet resultSet = statement.executeQuery()) {
					if(resultSet.isBeforeFirst()) {
						resultSet.next();

						double lastPixelX = resultSet.getDouble("pixel_x_size");
						double lastPixelY = resultSet.getDouble("pixel_y_size");

						while(resultSet.next()) {
							final double pixelX = resultSet.getDouble("pixel_x_size");
							final double pixelY = resultSet.getDouble("pixel_y_size");

							assertTrue(lastPixelX > pixelX && lastPixelY > pixelY,
									ErrorMessage.format(ErrorMessageKeys.PIXEL_SIZE_NOT_DECREASING, pyramidTable));

							lastPixelX = pixelX;
							lastPixelY = pixelY;
						}
					}                	
				}
			}
		}
	}

	/**
	 * Each tile matrix set in a GeoPackage SHALL be stored in a different tile
	 * pyramid user data table or updateable view with a unique name that SHALL
	 * have a column named "id" with column type INTEGER and <em>PRIMARY KEY
	 * AUTOINCREMENT</em> column constraints per Clause 2.2.8.1.1 <a
	 * href="http://www.geopackage.org/spec/#tiles_user_tables_data_table_definition">
	 * Table Definition</a>, <a
	 * href="http://www.geopackage.org/spec/#example_tiles_table_cols">Tiles
	 * Table or View Definition</a> and <a
	 * href="http://www.geopackage.org/spec/#example_tiles_table_insert_sql">
	 * EXAMPLE: tiles table Insert Statement (Informative)</a>.
	 *
	 * @see <a href="http://www.geopackage.org/spec/#_requirement-54" target=
	 *      "_blank">Tile Pyramid User Data Tables - Table Definition - Requirement 54</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r12: Requirement 54")
	public void tilesTableDefinitions() throws SQLException
	{
		final Map<String, ColumnDefinition> expectedColumns = new HashMap<>();

		expectedColumns.put("id",          new ColumnDefinition("INTEGER", true, true,  true,  null));
		expectedColumns.put("zoom_level",  new ColumnDefinition("INTEGER", true,  false, false, null));
		expectedColumns.put("tile_column", new ColumnDefinition("INTEGER", true,  false, false, null));
		expectedColumns.put("tile_row",    new ColumnDefinition("INTEGER", true,  false, false, null));
		expectedColumns.put("tile_data",   new ColumnDefinition("BLOB",    true,  false, false, null));

		for(final String tableName : this.tileTableNames) {
			try {
				TableVerifier.verifyTable(this.databaseConnection,
						tableName,
						expectedColumns,
						Collections.emptySet(),
						new HashSet<>(Arrays.asList(new UniqueDefinition("zoom_level", "tile_column", "tile_row"))));
			}
			catch(final Throwable th)
			{
				fail(ErrorMessage.format(ErrorMessageKeys.BAD_TILE_PYRAMID_USER_DATA_TABLE_DEFINITION,
						tableName,
						th.getMessage()));
			}
		}
	}

	/**
	 * For each distinct {@code table_name} from the {@code gpkg_tile_matrix}
	 * (tm) table, the tile pyramid (tp) user data table {@code zoom_level}
	 * column value in a GeoPackage SHALL be in the range {@code min(tm.zoom_level) <=
	 * tp.zoom_level <= max(tm.zoom_level)}.
	 *
	 * @see <a href="http://www.geopackage.org/spec/#_requirement-55" target=
	 *      "_blank">Tile Pyramid User Data Tables - Table Data Values - Requirement 55</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r12: Requirement 55")
	public void zoomLevelRange() throws SQLException
	{
		for(final String tableName : this.tileTableNames) {
			final boolean nullZoom;
			final int minZoom, maxZoom;




			try (final PreparedStatement statement = this.databaseConnection.prepareStatement("SELECT MIN(zoom_level) AS min_zoom, MAX(zoom_level) AS max_zoom FROM gpkg_tile_matrix WHERE table_name = ?;")) {
				statement.setString(1, tableName);
				try (final ResultSet minMaxZoom = statement.executeQuery()) {
					minZoom = minMaxZoom.getInt("min_zoom");
					maxZoom = minMaxZoom.getInt("max_zoom");    
					nullZoom = minMaxZoom.wasNull();
				}
			}


			if (nullZoom) { return; }

			try (final PreparedStatement zoomStatement = this.databaseConnection.prepareStatement(String.format("SELECT zoom_level FROM %s WHERE zoom_level < ? OR zoom_level > ?", tableName))) {
				zoomStatement.setInt(1, minZoom);
				zoomStatement.setInt(2, maxZoom);

				try (final ResultSet invalidZooms = zoomStatement.executeQuery()) {
					if(invalidZooms.next())
					{
						fail(ErrorMessage.format(ErrorMessageKeys.UNDEFINED_ZOOM_LEVEL,
								tableName,
								invalidZooms.getInt("zoom_level")));
					}                	
				}        		
			}		
		}
	}

	/**
	 * For each distinct {@code table_name} from the {@code gpkg_tile_matrix}
	 * (tm) table, the tile pyramid (tp) user data table {@code tile_column}
	 * column value in a GeoPackage SHALL be in the range {@code <= tp.tile_column
	 * <= tm.matrix_width - 1} where the tm and tp {@code zoom_level} column
	 * values are equal.
	 *
	 * @see <a href="http://www.geopackage.org/spec/#_requirement-56" target=
	 *      "_blank">Tile Pyramid User Data Tables - Table Data Values - Requirement 56</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r12: Requirement 56")
	public void tileColumnRange() throws SQLException
	{
		for(final String tableName : this.tileTableNames)
		{
			final String query = String.format("SELECT zoom_level as zl, matrix_width as width " +
					"FROM   gpkg_tile_matrix "        +
					"WHERE  table_name = ? "       +
					"AND (zoom_level in (SELECT zoom_level FROM %1$s WHERE tile_column < 0) " +
					"OR  (EXISTS(SELECT NULL FROM %1$s WHERE zoom_level = zl AND tile_column > width - 1)));",
					tableName);

			try (final PreparedStatement statement = this.databaseConnection.prepareStatement(query)) {
				statement.setString(1, tableName);
				try (final ResultSet resultSet = statement.executeQuery()) {
					while(resultSet.next()) {
						final int matrixWidth = resultSet.getInt("width");
						final int zoomLevel   = resultSet.getInt("zl");

						fail(ErrorMessage.format(ErrorMessageKeys.TILE_COLUMN_OUT_OF_RANGE,
								tableName,
								matrixWidth-1,
								zoomLevel));
					}					
				}
			}
		}
	}

	/**
	 * For each distinct {@code table_name} from the {@code gpkg_tile_matrix}
	 * (tm) table, the tile pyramid (tp) user data table {@code tile_row}
	 * column value in a GeoPackage SHALL be in the range {@code 0 <= tp.tile_row <=
	 * tm.matrix_height - 1} where the tm and tp {@code zoom_level} column
	 * values are equal.
	 *
	 * @see <a href="http://www.geopackage.org/spec/#_requirement-57" target=
	 *      "_blank">Tile Pyramid User Data Tables - Table Data Values - Requirement 57</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r12: Requirement 57")
	public void tileRowRange() throws SQLException
	{
		for(final String tableName : this.tileTableNames)
		{
			final String query = String.format("SELECT zoom_level as zl, matrix_height as height " +
					"FROM   gpkg_tile_matrix "        +
					"WHERE  table_name = ? "       +
					"AND (zoom_level in (SELECT zoom_level FROM %1$s WHERE tile_row < 0) " +
					"OR  (EXISTS(SELECT NULL FROM %1$s WHERE zoom_level = zl AND tile_row > height - 1)));",
					tableName);

			try (final PreparedStatement statement = this.databaseConnection.prepareStatement(query)) {
				statement.setString(1, tableName);
				try (final ResultSet resultSet = statement.executeQuery()) {
					while(resultSet.next()) {
						final int matrixHeight = resultSet.getInt("height");
						final int zoomLevel   = resultSet.getInt("zl");

						fail(ErrorMessage.format(ErrorMessageKeys.TILE_ROW_OUT_OF_RANGE,
								tableName,
								matrixHeight-1,
								zoomLevel));
					}
				}
			}
		}
	}

	private static boolean isEqual(final double first, final double second)
	{
		return Math.abs(first - second) < EPSILON;
	}

	protected boolean isAcceptedImageFormat(final byte[] image) throws IOException
	{
		if(image == null)
		{
			return false;
		}

		try(final ByteArrayInputStream        byteArray  = new ByteArrayInputStream(image);
				final MemoryCacheImageInputStream cacheImage = new MemoryCacheImageInputStream(byteArray))
		{
			return canReadImage(pngImageReaders, cacheImage) || canReadImage(jpegImageReaders, cacheImage);
		}
	}

	protected static boolean canReadImage(final Iterable<ImageReader> imageReaders, final ImageInputStream image) throws IOException
	{
		for(final ImageReader imageReader : imageReaders)
		{
			try
			{
				image.mark();
				if(imageReader.getOriginatingProvider().canDecodeInput(image))
				{
					return true;
				}
			}
			finally
			{
				image.reset();
			}
		}

		return false;
	}

	public String getDataType() {
		return dataType;
	}

	public void setDataType(String dataType) {
		this.dataType = dataType;
	}

	private String dataType = "tiles";

	protected final Collection<String> tileTableNames = new ArrayList<String>();

	private static final double EPSILON = 0.0001;   // TODO should this be made configurable?

	protected static final Collection<ImageReader> jpegImageReaders;
	protected static final Collection<ImageReader> pngImageReaders;

	private static final Map<String, ColumnDefinition> TileTableExpectedColumns;

	static
	{
		jpegImageReaders = StreamSupport.stream(Spliterators.spliteratorUnknownSize(ImageIO.getImageReadersByMIMEType("image/jpeg"),
				Spliterator.ORDERED),
				false)
				.collect(Collectors.toCollection(ArrayList::new));

		pngImageReaders  = StreamSupport.stream(Spliterators.spliteratorUnknownSize(ImageIO.getImageReadersByMIMEType("image/png"),
				Spliterator.ORDERED),
				false)
				.collect(Collectors.toCollection(ArrayList::new));

		TileTableExpectedColumns = new HashMap<>();

		TileTableExpectedColumns.put("id",           new ColumnDefinition("INTEGER", false, true,  true,  null));
		TileTableExpectedColumns.put("zoom_level",   new ColumnDefinition("INTEGER", true,  false, false, null));
		TileTableExpectedColumns.put("tile_column",  new ColumnDefinition("INTEGER", true,  false, false, null));
		TileTableExpectedColumns.put("tile_row",     new ColumnDefinition("INTEGER", true,  false, false, null));
		TileTableExpectedColumns.put("tile_data",    new ColumnDefinition("BLOB",    true,  false, false, null));
	}
}
